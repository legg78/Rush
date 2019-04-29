package ru.bpc.sv2.ui.utils;


import org.apache.log4j.Logger;
import ru.bpc.sv2.common.Appearance;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.invocation.SortElement;
import ru.bpc.sv2.invocation.SortElement.Direction;
import ru.bpc.sv2.logic.CommonDao;
import ru.bpc.sv2.utils.KeyLabelItem;
import util.auxil.ManagedBeanWrapper;

import javax.faces.bean.ManagedBean;
import javax.faces.bean.SessionScoped;
import javax.faces.model.SelectItem;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@SessionScoped
@ManagedBean(name = "EntityIcons")
public class EntityIcons {
	private CommonDao commonDao;
	private static volatile EntityIcons instance;
	private Map<String, Map<Object, String>> objectsMap = null;
	private static final Logger logger = Logger.getLogger("COMMON");

	private transient DictUtils dictUtils;

	public EntityIcons() {
		commonDao = new CommonDao();
	}

	public static EntityIcons getInstance() {
		if (instance == null) {
			synchronized (EntityIcons.class) {
				if (instance == null) {
					instance = new EntityIcons();
					instance.loadObjectsMap();
				}
			}
		}
		return instance;
	}

	public static void destroyInstance() {
		instance = null;
	}

	public Map<String, Map<Object, String>> getObjectsMap() {
		if (objectsMap == null) {
			loadObjectsMap();
		}
		return objectsMap;
	}

	public void reload() {
		loadObjectsMap();
	}

	private void loadObjectsMap() {
		objectsMap = new HashMap<String, Map<Object, String>>();
		Map<Object, String> iconsMap;
		try {
			SelectionParams selectionParams = new SelectionParams();
			selectionParams.setRowIndexEnd(-1);
			selectionParams.setSortElement(new SortElement("entityType", Direction.ASC));
			Appearance[] appearances = commonDao.getAppearances(null, selectionParams);

			for (Appearance appearance : appearances) {
				String entityType = appearance.getEntityType();
				if ("ENTT0046".equals(entityType)) {
					continue;
				}
				iconsMap = objectsMap.get(entityType);
				boolean isNew = false;
				if (iconsMap == null) {
					iconsMap = new HashMap<Object, String>();
					isNew = true;
				}				
			
				try {
					iconsMap.put(Integer.parseInt(appearance.getObjectReference()), appearance.getCssClass());
				} catch (NumberFormatException e) {
					iconsMap.put(appearance.getObjectReference(), appearance.getCssClass());
				}

				if (isNew) {
					objectsMap.put(entityType, iconsMap);
				}
			}

			iconsMap = new HashMap<Object, String>();
			iconsMap.putAll(CurrencyCache.getInstance().getCurrencyFlagByLang("LANGENG"));
			objectsMap.put("ENTT0046", iconsMap);
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public Map<String, Map<Object, String>> getObjectsMapS() {
		if (objectsMap == null) {
			loadObjectsMap();
		}
		return objectsMap;
	}

	public List<SelectItem> getLov(int lovId) {
		List<SelectItem> items = null;
		try {
			KeyLabelItem[] lovItems = getDictUtils().getLovItems(lovId);
			SelectItem si;
			items = new ArrayList<SelectItem>();
			for (KeyLabelItem item : lovItems) {
				si = new SelectItem(item.getValue(), item.getLabel(), item.getLabel());
				items.add(si);
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		} finally {
			if (items == null)
				items = new ArrayList<SelectItem>(0);
		}
		return items;
	}

	public DictUtils getDictUtils() {
		if (dictUtils == null) {
			dictUtils = (DictUtils) ManagedBeanWrapper.getManagedBean("DictUtils");
		}
		return dictUtils;
	}
}
