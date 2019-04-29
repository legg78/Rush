package com.bpcbt.svng.auth;

import com.bpcbt.svng.auth.beans.*;
import com.bpcbt.svng.auth.dao.AuthDao;
import com.bpcbt.svng.auth.providers.ModuleDataProvider;
import org.apache.log4j.Logger;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.logic.CommonDao;
import ru.bpc.sv2.utils.KeyLabelItem;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class Sv2ModuleProvider extends ModuleDataProvider {
	private static final Logger logger = Logger.getLogger(Sv2ModuleProvider.class);

	private Map<String, String> langMap;
	private AuthDao dao = new AuthDao();

	public Sv2ModuleProvider() {
		langMap = new HashMap<String, String>();
		langMap.put("en_US", "LANGENG");
		langMap.put("ru_RU", "LANGRUS");
	}

	private String getLang(String locale) {
		String lang = langMap.get(locale);
		if (lang == null) {
			lang = "LANGENG";
		}
		return lang;
	}

	@Override
	protected List<Dictionary> getDictionaries(String locale) {
		try {
			List<Dictionary> list = new ArrayList<Dictionary>();
			CommonDao commonDao = new CommonDao();
			KeyLabelItem[] institutions = commonDao.getLov(LovConstants.INSTITUTIONS);
			Dictionary d = new Dictionary();
			d.setDescription("Institutions of SVBO");
			d.setName("SVBO_INSTITUTIONS");
			d.setDataType(DataType.INTEGER);
			List<DictionaryValue> dvList = new ArrayList<DictionaryValue>();
			for (KeyLabelItem kli : institutions) {
				DictionaryValue dv = new DictionaryValue();
				dv.setValue(kli.getValue().toString());
				dv.setDescription(kli.getLabel());
				dvList.add(dv);
			}
			d.setValues(dvList);
			list.add(d);
			return list;
		} catch (Exception ex) {
			logger.error("Get dictionaries error", ex);
		}
		return null;
	}

	@Override
	protected List<AppPrivilege> getAppPrivileges(String locale) {
		List<AppPrivilege> list = new ArrayList<AppPrivilege>();
		List<AppPrivilegeData> data = dao.getAppPrivileges(getLang(locale));
		for (AppPrivilegeData d : data) {
			AppPrivilege ap = new AppPrivilege();
			ap.setId(d.getId());
			ap.setName(d.getName());
			if(d.getSection()==null){
				ap.setSection("-1");
			}else {
				ap.setSection(d.getSection());
			}
			ap.setDescription(d.getDescription());
			list.add(ap);
		}
		return list;
	}

	@Override
	protected List<DataPrivilegeTemplate> getDataPrivileges(String locale) {
		List<DataPrivilegeTemplate> list = new ArrayList<DataPrivilegeTemplate>();
		DataPrivilegeTemplate dp = new DataPrivilegeTemplate();
		dp.setName("SVBO_INSTITUTION_FILTER");
		dp.setDataType(DataType.INTEGER);
		dp.setDescription("SVBO institution filter");
		dp.setOperator(Operator.IN);
		dp.setDictionary("SVBO_INSTITUTIONS");
		list.add(dp);
		return list;
	}

	@Override
	protected Menu getApplicationMenu(String locale) {
		try {
			List<MenuSimpleNode> nodes = dao.getMenu(getLang(locale));
			Menu menu = new Menu();
			menu.setName("Root");
			menu.setSection("0");
			menu.setChildren(findChildren(nodes, null));
			Menu m=new Menu();
			m.setName("Not distributed privileges");
			m.setSection("-1");
			menu.getChildren().add(m);
			return menu;
		} catch (Exception ex) {
			logger.error("Get application menu error", ex);
		}
		return null;
	}

	private List<Menu> findChildren(List<MenuSimpleNode> nodes, String section) {
		List<Menu> menu = new ArrayList<Menu>();
		for (int i = 0; i < nodes.size(); i++) {
			MenuSimpleNode node = nodes.get(i);
			if (node.getParentId() == null && section == null ||
					node.getParentId() != null && section != null && node.getParentId().equals(section)) {
				nodes.remove(i);
				i--;
				Menu m = new Menu();
				m.setSection(node.getId());
				m.setName(node.getName());
				m.setChildren(findChildren(nodes, m.getSection()));
				menu.add(m);
			}
		}
		return menu;
	}
}
