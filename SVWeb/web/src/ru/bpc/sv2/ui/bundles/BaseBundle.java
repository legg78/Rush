package ru.bpc.sv2.ui.bundles;


import org.apache.commons.lang3.StringUtils;
import org.apache.log4j.Logger;
import org.springframework.jdbc.support.JdbcUtils;
import ru.bpc.sv2.constants.SystemConstants;
import ru.bpc.sv2.logic.utility.JndiUtils;
import ru.bpc.sv2.ui.session.UserSession;
import sun.util.ResourceBundleEnumeration;
import util.auxil.ManagedBeanWrapper;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.*;

public abstract class BaseBundle extends ResourceBundle {
    private static final String DEFAULT_LANGUAGE = SystemConstants.ENGLISH_LANGUAGE;

    private static final Logger logger = Logger.getLogger(BaseBundle.class);

    private Map<String, Map<String, Object>> lookup = new HashMap<String, Map<String, Object>>();

    public String getModule() {
        return module;
    }

    private String module;

    public BaseBundle(Bundle bundle) {
        this.module = bundle.name().toLowerCase();
    }

    public static void clearAll(String lang) {
        for(Bundle b: Bundle.values()) {
            BaseBundle bundle = (BaseBundle) ResourceBundle.getBundle(b.getBundleName());
            bundle.clear(lang);
        }
    }

    public static void clear(String fullKey, String lang) {
        if (StringUtils.isEmpty(fullKey)) return;
        int index = fullKey.indexOf('.');
        String module = index == -1 ? fullKey : fullKey.substring(0, index);

        for(Bundle b: Bundle.values()) {
            BaseBundle bundle = (BaseBundle) ResourceBundle.getBundle(b.getBundleName());
            if (bundle.getModule().equalsIgnoreCase(module)) {
                bundle.clear(lang);
                break;
            }
        }
    }

    @Override
    protected Object handleGetObject(String key) {
        if (key == null) {
            throw new NullPointerException();
        }
        String lang = getUserLanguage();
        if (!loadLookup(lang)) {
            return null;
        }

        String fullKey = (module + "." + key).toLowerCase();

        if (lookup.get(lang).containsKey(fullKey)) {
            return lookup.get(lang).get(fullKey);
        } else if (lookup.containsKey(DEFAULT_LANGUAGE)) {
            return lookup.get(DEFAULT_LANGUAGE).get(fullKey);
        } else {
            return null;
        }
    }

    @Override
    public Enumeration<String> getKeys() {
        String lang = getUserLanguage();
        if (loadLookup(lang)) {
            return new ResourceBundleEnumeration(handleKeySet(), null);
        }
        return new ResourceBundleEnumeration(new HashSet<String>(), null);
    }

    @Override
    protected Set<String> handleKeySet() {
        String lang = getUserLanguage();
        if (loadLookup(lang)) {
            HashSet<String> set = new HashSet<String>();
            set.addAll(lookup.get(lang).keySet());

            if (!DEFAULT_LANGUAGE.equals(lang) && lookup.containsKey(DEFAULT_LANGUAGE)) {
                set.addAll(lookup.get(DEFAULT_LANGUAGE).keySet());
            }
            return set;
        }
        return null;
    }

    public void clear(String lang) {
        synchronized (lookup) {
            if (lookup.containsKey(lang)) {
                lookup.remove(lang);
            }
        }
    }

    private String getUserLanguage() {
        UserSession session = ManagedBeanWrapper.getManagedBean("usession");

        if (session == null) {
            return DEFAULT_LANGUAGE;
        }

        String lang = session.getUserLanguage();
        if (StringUtils.isEmpty(lang)) {
            return DEFAULT_LANGUAGE;
        }

        return lang;
    }

    private boolean loadLookup(String lang) {
        if (lookup.containsKey(lang)) {
            return true;
        }
        synchronized (lookup) {
            if (!DEFAULT_LANGUAGE.equals(lang) && !lookup.containsKey(DEFAULT_LANGUAGE)) {
                loadLookup(DEFAULT_LANGUAGE, module);
            }
            return loadLookup(lang, module);
        }
    }

    private boolean loadLookup(String lang, String module) {
        Connection con = null;
        PreparedStatement pstm = null;
        ResultSet rs = null;
        try {
            con = JndiUtils.getConnection();
            pstm = con.prepareStatement(
                    "SELECT l.name, i.text FROM com_i18n i, com_label l " +
                            "WHERE l.id = i.object_id AND l.label_type = 'CAPTION' " +
                            "AND i.table_name = 'COM_LABEL' AND i.column_name = 'NAME' " +
                            "AND i.lang = ? AND lower(l.name) LIKE lower(? || '.%')");

            pstm.setString(1, lang);
            pstm.setString(2, module);
            rs = pstm.executeQuery();
            Map<String, Object> map = new HashMap<String, Object>();
            while(rs.next()) {
                map.put(rs.getString("name").toLowerCase(), rs.getString("text"));
            }
            lookup.put(lang, map);
            return true;
        } catch (SQLException e) {
            logger.error("Get localized labels error", e);
        } finally {
            JdbcUtils.closeResultSet(rs);
            JdbcUtils.closeStatement(pstm);
            JdbcUtils.closeConnection(con);
        }
        return false;
    }
}
