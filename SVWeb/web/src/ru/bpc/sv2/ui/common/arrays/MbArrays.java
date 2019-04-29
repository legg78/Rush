package ru.bpc.sv2.ui.common.arrays;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.event.ValueChangeEvent;
import javax.faces.model.SelectItem;

import org.apache.commons.lang3.StringUtils;
import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;

import ru.bpc.sv2.common.arrays.Array;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.constants.SectionIdConstants;
import ru.bpc.sv2.constants.scale.ScaleConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.CommonDao;
import ru.bpc.sv2.ui.common.arrays.elements.MbBaseArrayElements;
import ru.bpc.sv2.ui.navigation.Menu;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.TableRowSelection;
import util.auxil.ManagedBeanWrapper;

@ViewScoped
@ManagedBean (name = "MbArrays")
public class MbArrays extends AbstractBean {

	private static final Logger logger = Logger.getLogger("COMMON");

	private static String COMPONENT_ID = "1903:arraysTable";

	private CommonDao _commonDao = new CommonDao();

	private Array filter;
	private Array newArray;
	private Array detailArray;
	private String tabName;

	private final DaoDataModel<Array> _arraySource;
	private final TableRowSelection<Array> _itemSelection;
	private Array _activeArray;

	private ArrayList<SelectItem> institutions;
    private ArrayList<SelectItem> agents;
    private ArrayList<SelectItem> modifiers;

	private String oldLang;
	private String backLink;

	public MbArrays() {
		tabName = "detailsTab";
		pageLink = "arrays|arrays";
		_arraySource = new DaoDataModel<Array>() {
			@Override
			protected Array[] loadDaoData(SelectionParams params) {
				if (!searching) {
					return new Array[0];
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _commonDao.getArrays(userSessionId, params);
				} catch (Exception e) {
					setDataSize(0);
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return new Array[0];
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (!searching) {
					return 0;
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _commonDao.getArraysCount(userSessionId, params);
				} catch (Exception e) {
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return 0;
			}
		};

		_itemSelection = new TableRowSelection<Array>(null, _arraySource);
		restoreFilter();
	}
	
	private void restoreFilter(){
		HashMap<String,Object> queueFilter = getQueueFilter("MbArrays");

		if (queueFilter==null)
			return;
		if (queueFilter.containsKey("arrayTypeId")){
			getFilter().setArrayTypeId((Integer)queueFilter.get("arrayTypeId"));
		}
		if (queueFilter.containsKey("backLink")){
			backLink=(String)queueFilter.get("backLink");
		}
		
		search();
	}

	public DaoDataModel<Array> getArrays() {
		return _arraySource;
	}

	public Array getActiveArray() {
		return _activeArray;
	}

	public void setActiveArray(Array activeArray) {
		_activeArray = activeArray;
	}

	public SimpleSelection getItemSelection() {
		try { 
			if (_activeArray == null && _arraySource.getRowCount() > 0) {
				setFirstRowActive();
			} else if (_activeArray != null && _arraySource.getRowCount() > 0) {
				SimpleSelection selection = new SimpleSelection();
				selection.addKey(_activeArray.getModelId());
				_itemSelection.setWrappedSelection(selection);
				_activeArray = _itemSelection.getSingleSelection();
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}	
		return _itemSelection.getWrappedSelection();
	}

	public void setItemSelection(SimpleSelection selection) {
		try {
			_itemSelection.setWrappedSelection(selection);
			boolean changeSelect = false;
			if (_itemSelection.getSingleSelection() != null
					&& !_itemSelection.getSingleSelection().getId().equals(_activeArray.getId())) {
				changeSelect = true;
			}
			_activeArray = _itemSelection.getSingleSelection();
	
			if (_activeArray != null) {
				setBeans();
				if (changeSelect) {
					detailArray = (Array) _activeArray.clone();
				}
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void setFirstRowActive() throws CloneNotSupportedException {
		_arraySource.setRowIndex(0);
		SimpleSelection selection = new SimpleSelection();
		_activeArray = (Array) _arraySource.getRowData();
		selection.addKey(_activeArray.getModelId());
		_itemSelection.setWrappedSelection(selection);
		if (_activeArray != null) {
			setBeans();
			detailArray = (Array) _activeArray.clone();
		}
	}

	/**
	 * Sets data for backing beans used by dependent pages
	 */
	public void setBeans() {
        MbBaseArrayElements elementBean = getElementsManageBean();
		elementBean.setArray(_activeArray);
		elementBean.search();
	}

	public void search() {
		curLang = userLang;
		clearBean();
		searching = true;
	}

	public void clearFilter() {
		curLang = userLang;
		filter = new Array();
		searching = false;
	}

	public void setFilters() {
		filter = getFilter();

		filters = new ArrayList<Filter>();

		filters.add(new Filter("lang", userLang));

		if (StringUtils.isNotEmpty(filter.getName())) {
			filters.add(new Filter("name", filter.getName().trim().toUpperCase().replaceAll("[*]", "%")
					.replaceAll("[?]", "_")));
		}
		if (filter.getArrayTypeId() != null) {
			filters.add(new Filter("arrayTypeId", filter.getArrayTypeId()));
		}

		if (filter.getInstId() != null) {
			filters.add(new Filter("instId", filter.getInstId()));
		}
		if (StringUtils.isNotEmpty(filter.getIdFilter())) {
			filters.add(new Filter("id", filter.getIdFilter().trim().replaceAll("[*]", "%")
					.replaceAll("[?]", "_")));
		}
	}

	public Array getFilter() {
		if (filter == null) {
			filter = new Array();
		}
		return filter;
	}

	public void setFilter(Array filter) {
		this.filter = filter;
	}

	public void add() {
		newArray = new Array();
		newArray.setLang(userLang);
		curLang = newArray.getLang();
		curMode = NEW_MODE;
	}

	public void edit() {
		try {
			newArray = (Array) detailArray.clone();
		} catch (CloneNotSupportedException e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
		curMode = EDIT_MODE;
	}

	public void delete() {
		try {
			_commonDao.deleteArray(userSessionId, _activeArray);
			_activeArray = _itemSelection.removeObjectFromList(_activeArray);

			if (_activeArray == null) {
				clearBean();
			} else {
				setBeans();
				detailArray = (Array) _activeArray.clone();
			}
			curMode = VIEW_MODE;
			FacesUtils.addMessageInfo(FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Common",
			        "array_deleted"));
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void save() {
		try {
			if (isNewMode()) {
				newArray = _commonDao.addArray(userSessionId, newArray);
				detailArray = (Array) newArray.clone();
				_itemSelection.addNewObjectToList(newArray);
			} else {
				newArray = _commonDao.editArray(userSessionId, newArray);
				detailArray = (Array) newArray.clone();
				if (!userLang.equals(newArray.getLang())) {
					newArray = getNodeByLang(_activeArray.getId(), userLang);
				}
				_arraySource.replaceObject(_activeArray, newArray);
			}
			_activeArray = newArray;
			setBeans();
			curMode = VIEW_MODE;

			FacesUtils.addMessageInfo(FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Common",
			        "array_saved"));
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void cancel() {
		curMode = VIEW_MODE;
	}

	public Array getNewArray() {
		if (newArray == null) {
			newArray = new Array();
		}
		return newArray;
	}

	public void setNewArray(Array newArray) {
		this.newArray = newArray;
	}

	public String getTabName() {
		return tabName;
	}

    private String getDefaultElementsBeanClassName(){
        return "MbDefaultArrayElements";
    }

    public MbBaseArrayElements getElementsManageBean(){
        String defaultElementBeanClassName = getDefaultElementsBeanClassName();
        String elementsBeanClassName = _activeArray != null
                ? _activeArray.getClassName() : defaultElementBeanClassName;
        if(elementsBeanClassName == null) elementsBeanClassName = defaultElementBeanClassName;
        MbBaseArrayElements elementBean = (MbBaseArrayElements) ManagedBeanWrapper
                .getManagedBean(elementsBeanClassName);
        if(elementBean == null) {
            logger.error("Elements tab source class with the specified name \""
                    + elementsBeanClassName + "\" is not found or registered.");
            //todo probably need to show error message to client about problem with name of bean class...
            elementBean = (MbBaseArrayElements) ManagedBeanWrapper.getManagedBean(getDefaultElementsBeanClassName());
        }
        return elementBean;
    }

	public void setTabName(String tabName) {
		this.tabName = tabName;
		
		if (tabName.equalsIgnoreCase("elementsTab")) {
            MbBaseArrayElements elementBean = getElementsManageBean();
			elementBean.setTabName(tabName);
			elementBean.setParentSectionId(getSectionId());
			elementBean.setTableState(getSateFromDB(elementBean.getComponentId()));
		}
	}

	public String getSectionId() {
		return SectionIdConstants.CONFIGURATION_ARR_ARR;
	}

	public void clearBean() {
		_arraySource.flushCache();
		_itemSelection.clearSelection();
		_activeArray = null;
		detailArray = null;
		clearBeansStates();
	}

	public void clearBeansStates() {
		// clear dependent beans
		MbBaseArrayElements elementBean = getElementsManageBean();
		elementBean.fullCleanBean();
	}

	public void changeLanguage(ValueChangeEvent event) {
		if (_activeArray != null) {
			curLang = (String) event.getNewValue();
			detailArray = getNodeByLang(detailArray.getId(), curLang);
		}
	}
	
	public Array getNodeByLang(Integer id, String lang) {
		if (_activeArray != null) {
			List<Filter> filtersList = new ArrayList<Filter>();

			filtersList.add(new Filter("id", id.toString()));

			filtersList.add(new Filter("lang", lang));

			filters = filtersList;
			SelectionParams params = new SelectionParams();
			params.setFilters(filters.toArray(new Filter[filters.size()]));
			try {
				Array[] arrays = _commonDao.getArrays(userSessionId, params);
				if (arrays != null && arrays.length > 0) {
					return arrays[0];
				}
			} catch (Exception e) {
				FacesUtils.addMessageError(e);
				logger.error("", e);
			}
		}
		return null;
	}

	public ArrayList<SelectItem> getInstitutions() {
		if (institutions == null) {
			institutions = (ArrayList<SelectItem>) getDictUtils().getLov(LovConstants.INSTITUTIONS_SYS);
		}
		if (institutions == null)
			institutions = new ArrayList<SelectItem>();
		return institutions;
	}

    public ArrayList<SelectItem> getAgents() {
        Integer selectedInstId = getNewArray().getInstId();
        if(selectedInstId == null) {
            agents = new ArrayList<SelectItem>();
        }else {
            Map<String, Object> paramMap = new HashMap<String, Object>();
            paramMap.put("INSTITUTION_ID", selectedInstId);
            agents =  (ArrayList<SelectItem>)getDictUtils().getLov(LovConstants.AGENTS, paramMap);
        }
        return agents;
    }

    public ArrayList<SelectItem> getModifiers() {
        Integer selectedInstId = getNewArray().getInstId();
        if(selectedInstId == null) {
            modifiers = new ArrayList<SelectItem>();
        }else {
            Map<String, Object> paramMap = new HashMap<String, Object>();
            paramMap.put("INSTITUTION_ID", selectedInstId);
            paramMap.put("SCALE_TYPE", ScaleConstants.SCALE_FOR_ARRAYS);
            modifiers =  (ArrayList<SelectItem>)getDictUtils().getLov(LovConstants.MODIFIER_LIST, paramMap);
        }
        return modifiers;
    }

	public List<SelectItem> getArrayTypes() {
		return getDictUtils().getLov(LovConstants.ARRAY_TYPE);
	}

	public void editLanguage(ValueChangeEvent event) {
		oldLang = (String) event.getOldValue();
	}

	public void confirmEditLanguage() {
		curLang = newArray.getLang();
		Array tmp = getNodeByLang(newArray.getId(), newArray.getLang());
		if (tmp != null) {
			newArray.setName(tmp.getName());
			newArray.setDescription(tmp.getDescription());
		}
	}

	public void cancelEditLanguage() {
		newArray.setLang(oldLang);
	}

	public String getComponentId() {
		return COMPONENT_ID;
	}

	public Logger getLogger() {
		return logger;
	}

	public Array getDetailArray() {
		return detailArray;
	}

	public void setDetailArray(Array detailArray) {
		this.detailArray = detailArray;
	}

	public String getBackLink() {
		return backLink;
	}

	public void setBackLink(String backLink) {
		this.backLink = backLink;
	}
	
	public String back() {
		Menu mbMenu = (Menu) ManagedBeanWrapper.getManagedBean("menu");
		mbMenu.externalSelect(backLink);
		return backLink;
	}

	public boolean isShowBackBtn() {
		return backLink == null ? false : (backLink.trim().length() > 0 ? true : false);
	}
	
}
