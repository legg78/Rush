package ru.bpc.sv2.logic;

import com.ibatis.sqlmap.client.SqlMapSession;
import org.apache.commons.lang3.StringUtils;
import org.apache.log4j.Logger;
import ru.bpc.sv2.common.CommonParamRec;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.IAuditableObject;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.controller.CommonController;
import ru.bpc.sv2.logic.utility.db.IbatisAware;
import ru.bpc.sv2.logic.utility.db.IbatisSessionCallback;
import ru.bpc.sv2.ps.mastercard.AbuFile;
import ru.bpc.sv2.utils.AuditParamUtil;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public abstract class AbstractDao extends IbatisAware {
    protected abstract Logger getLogger();
    protected abstract String getSqlMap();

    private String formatQuery(String query) {
        if (StringUtils.isNotBlank(getSqlMap())) {
            return getSqlMap() + "." + query;
        } else {
            return query;
        }
    }

    @SuppressWarnings("unchecked")
    public <T extends IAuditableObject> List<T> getObjects(Long sessionId, final SelectionParams params, final String privilege, final String query) {
        return executeWithSession(sessionId, privilege, params, getLogger(), new IbatisSessionCallback<List<T>>() {
            @Override
            public List<T> doInSession(SqlMapSession ssn) throws Exception {
                Object list = null;
                if (StringUtils.isNotBlank(privilege)) {
                    String limitation = CommonController.getLimitationByPriv(ssn, privilege);
                    list = ssn.queryForList(formatQuery(query), convertQueryParams(params, limitation));
                } else {
                    list = ssn.queryForList(formatQuery(query), convertQueryParams(params));
                }
                return (list != null) ? (List<T>) list : new ArrayList<T>();
            }
        });
    }
    public <T extends IAuditableObject> List<T> getObjects(Long sessionId, final SelectionParams params, final String query) {
        return getObjects(sessionId, params, null, query);
    }

    @SuppressWarnings("unchecked")
    public int getCount(Long sessionId, final SelectionParams params, final String privilege, final String query) {
        return executeWithSession(sessionId, privilege, params, getLogger(), new IbatisSessionCallback<Integer>() {
            @Override
            public Integer doInSession(SqlMapSession ssn) throws Exception {
                Object count = null;
                if (StringUtils.isNotBlank(privilege)) {
                    String limitation = CommonController.getLimitationByPriv(ssn, privilege);
                    count = ssn.queryForObject(formatQuery(query), convertQueryParams(params, limitation));
                } else {
                    count = ssn.queryForObject(formatQuery(query), convertQueryParams(params));
                }
                return (count != null) ? (Integer)count : 0;
            }
        });
    }
    public int getCount(Long sessionId, final SelectionParams params, final String query) {
        return getCount(sessionId, params, null, query);
    }

    @SuppressWarnings("unchecked")
    public <T extends IAuditableObject> T insert(Long sessionId, final T object, final String privilege, final String query) {
        CommonParamRec[] params = AuditParamUtil.getCommonParamRec(object.getAuditParameters());
        return executeWithSession(sessionId, privilege, params, getLogger(), new IbatisSessionCallback<T>() {
            @Override
            public T doInSession(SqlMapSession ssn) throws Exception {
                Object out = ssn.queryForObject(formatQuery(query), object);
                return (out != null) ? (T) out : object;
            }
        });
    }
    public <T extends IAuditableObject> T insert(Long sessionId, final T object, final String query) {
        return update(sessionId, object, null, query);
    }
    public <T extends IAuditableObject> T insert(final T object, final String query) {
        return update(null, object, null, query);
    }

    @SuppressWarnings("unchecked")
    public <T extends IAuditableObject> T update(Long sessionId, final T object, final String privilege, final String query) {
        CommonParamRec[] params = AuditParamUtil.getCommonParamRec(object.getAuditParameters());
        return executeWithSession(sessionId, privilege, params, getLogger(), new IbatisSessionCallback<T>() {
            @Override
            public T doInSession(SqlMapSession ssn) throws Exception {
                Object out = ssn.queryForObject(formatQuery(query), object);
                return (out != null) ? (T)out : object;
            }
        });
    }
    public <T extends IAuditableObject> T update(Long sessionId, final T object, final String query) {
        return update(sessionId, object, null, query);
    }
    public <T extends IAuditableObject> T update(final T object, final String query) {
        return update(null, object, null, query);
    }

    @SuppressWarnings("unchecked")
    public <T> void delete(Long sessionId, final T object, final String privilege, final String query) {
        executeWithSession(sessionId, privilege, getLogger(), new IbatisSessionCallback<Void>() {
            @Override
            public Void doInSession(SqlMapSession ssn) throws Exception {
                ssn.delete(formatQuery(query), object);
                return null;
            }
        });
    }
    public <T> void delete(Long sessionId, final T object, final String query) {
        delete(sessionId, object, null, query);
    }
    public <T> void delete(final T object, final String query) {
        delete(null, object, null, query);
    }

    @SuppressWarnings("unchecked")
    public <T> Object execute(Long sessionId, final T object, final String privilege, final String query) {
        CommonParamRec[] params = null;
        if (object instanceof IAuditableObject) {
            params = AuditParamUtil.getCommonParamRec(((IAuditableObject)object).getAuditParameters());
        }
        return executeWithSession(sessionId, privilege, params, getLogger(), new IbatisSessionCallback<Object>() {
            @Override
            public Object doInSession(SqlMapSession ssn) throws Exception {
                return ssn.queryForObject(formatQuery(query), object);
            }
        });
    }
    public <T> Object execute(Long sessionId, final T object, final String query) {
        return execute(sessionId, object, null, query);
    }

    @SuppressWarnings("unchecked")
    public Map execute(Long sessionId, final Map in, final String privilege, final String query) {
        return executeWithSession(sessionId, privilege, getLogger(), new IbatisSessionCallback<Map>() {
            @Override
            public Map doInSession(SqlMapSession ssn) throws Exception {
                ssn.queryForObject(formatQuery(query), in);
                return new HashMap<>(in);
            }
        });
    }
    public Map execute(Long sessionId, final Map in, final String query) {
        return execute(sessionId, in, null, query);
    }
}
