package ru.bpc.sv2.ui.common.arrays;

import java.util.ArrayList;
import java.util.List;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.event.ValueChangeEvent;
import javax.faces.model.SelectItem;

import org.apache.commons.lang3.StringUtils;
import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;

import ru.bpc.sv2.common.arrays.ArrayConversion;
import ru.bpc.sv2.constants.DictNames;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.constants.SectionIdConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.CommonDao;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.TableRowSelection;
import util.auxil.ManagedBeanWrapper;

@ViewScoped
@ManagedBean (name = "MbArraysConversion")
public class MbArraysConversion extends AbstractBean {

	private static final Logger logger = Logger.getLogger("COMMON");

	private static String COMPONENT_ID = "1922:arrayConversionTable";

	private CommonDao _commonDao = new CommonDao();

	

	private ArrayConversion filter;
	private ArrayConversion newArrayConversion;
	private ArrayConversion detailArrayConversion;

	private final DaoDataModel<ArrayConversion> _arrayConversionSource;
	private final TableRowSelection<ArrayConversion> _itemSelection;
	private ArrayConversion _activeArrayConversion;
	private String oldLang;
	private String tabName;

	public MbArraysConversion() {
		pageLink = "arrays|arraysConversion";
		_arrayConversionSource = new DaoDataModel<ArrayConversion>() {
			@Override
			protected ArrayConversion[] loadDaoData(SelectionParams params) {
				if (!searching) {
					return new ArrayConversion[0];
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _commonDao.getArraysConversion(userSessionId, params);
				} catch (Exception e) {
					setDataSize(0);
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return new ArrayConversion[0];
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (!searching) {
					return 0;
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _commonDao.getArraysConversionCount(userSessionId, params);
				} catch (Exception e) {
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return 0;
			}
		};

		_itemSelection = new TableRowSelection<ArrayConversion>(null, _arrayConversionSource);
	}

	public DaoDataModel<ArrayConversion> getArrayConversions() {
		return _arrayConversionSource;
	}

	public ArrayConversion getActiveArrayConversion() {
		return _activeArrayConversion;
	}

	public void setActiveArrayConversion(ArrayConversion activeArrayConversion) {
		_activeArrayConversion = activeArrayConversion;
	}

	public SimpleSelection getItemSelection() {
		try {
			if (_activeArrayConversion == null && _arrayConversionSource.getRowCount() > 0) {
				setFirstRowActive();
			} else if (_activeArrayConversion != null && _arrayConversionSource.getRowCount() > 0) {
				SimpleSelection selection = new SimpleSelection();
				selection.addKey(_activeArrayConversion.getModelId());
				_itemSelection.setWrappedSelection(selection);
				_activeArrayConversion = _itemSelection.getSingleSelection();
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
					&& !_itemSelection.getSingleSelection().getId().equals(_activeArrayConversion.getId())) {
				changeSelect = true;
			}
			_activeArrayConversion = _itemSelection.getSingleSelection();
	
			if (_activeArrayConversion != null) {
				setBeans();
				if (changeSelect) {
					detailArrayConversion = (ArrayConversion) _activeArrayConversion.clone();
				}
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void setFirstRowActive() throws CloneNotSupportedException {
		_arrayConversionSource.setRowIndex(0);
		SimpleSelection selection = new SimpleSelection();
		_activeArrayConversion = (ArrayConversion) _arrayConversionSource.getRowData();
		selection.addKey(_activeArrayConversion.getModelId());
		_itemSelection.setWrappedSelection(selection);
		if (_activeArrayConversion != null) {
			setBeans();
			detailArrayConversion = (ArrayConversion) _activeArrayConversion.clone();
		}
	}

	/**
	 * Sets data for backing beans used by dependent pages
	 */
	public void setBeans() {
		MbArrayConvElems elementBean = (MbArrayConvElems) ManagedBeanWrapper.getManagedBean("MbArrayConvElems");
		elementBean.setConversion(_activeArrayConversion);
		elementBean.search();
	}

	public void search() {
		curLang = userLang;
		clearBean();
		searching = true;
	}

	public void clearFilter() {
		curLang = userLang;
		filter = new ArrayConversion();
		searching = false;
	}

	public void setFilters() {
		filter = getFilter();

		filters = new ArrayList<Filter>();

		filters.add(new Filter("lang", userLang));

		if (StringUtils.isNotEmpty(filter.getIdFilter())) {
			filters.add(new Filter("id", filter.getIdFilter().trim().replaceAll("[*]", "%")
					.replaceAll("[?]", "_")));
		}
		if (StringUtils.isNotEmpty(filter.getName())) {
			filters.add(new Filter("name", filter.getName().trim().toUpperCase().replaceAll("[*]", "%")
					.replaceAll("[?]", "_")));
		}
		if (StringUtils.isNotEmpty(filter.getConvType())) {
			filters.add(new Filter("convType", filter.getConvType()));
		}
	}

	public ArrayConversion getFilter() {
		if (filter == null) {
			filter = new ArrayConversion();
		}
		return filter;
	}

	public void setFilter(ArrayConversion filter) {
		this.filter = filter;
	}

	public void add() {
		newArrayConversion = new ArrayConversion();
		newArrayConversion.setLang(userLang);
		curLang = newArrayConversion.getLang();
		curMode = NEW_MODE;
	}

	public void edit() {
		try {
			newArrayConversion = (ArrayConversion) detailArrayConversion.clone();
		} catch (CloneNotSupportedException e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
		curMode = EDIT_MODE;
	}

	public void delete() {
		try {
			_commonDao.deleteArrayConversion(userSessionId, _activeArrayConversion);
			_activeArrayConversion = _itemSelection.removeObjectFromList(_activeArrayConversion);

			if (_activeArrayConversion == null) {
				clearBean();
			} else {
				setBeans();
				detailArrayConversion = (ArrayConversion) _activeArrayConversion.clone();
			}
			curMode = VIEW_MODE;
			FacesUtils.addMessageInfo(FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Common",
			        "array_conversion_deleted"));
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void save() {
		try {
			if (isNewMode()) {
				newArrayConversion = _commonDao.addArrayConversion(userSessionId, newArrayConversion);
				detailArrayConversion = (ArrayConversion) newArrayConversion.clone();
				_itemSelection.addNewObjectToList(newArrayConversion);
			} else {
				newArrayConversion = _commonDao.editArrayConversion(userSessionId, newArrayConversion);
				detailArrayConversion = (ArrayConversion) newArrayConversion.clone();
				if (!userLang.equals(newArrayConversion.getLang())) {
					newArrayConversion = getNodeByLang(_activeArrayConversion.getId(), userLang);
				}
				_arrayConversionSource.replaceObject(_activeArrayConversion, newArrayConversion);
			}
			_activeArrayConversion = newArrayConversion;
			setBeans();

			curMode = VIEW_MODE;
			
			FacesUtils.addMessageInfo(FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Common",
			        "array_conversion_saved"));
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void cancel() {
		curMode = VIEW_MODE;
	}

	public ArrayConversion getNewArrayConversion() {
		if (newArrayConversion == null) {
			newArrayConversion = new ArrayConversion();
		}
		return newArrayConversion;
	}

	public void setNewArray(ArrayConversion newArrayConversion) {
		this.newArrayConversion = newArrayConversion;
	}

	public String getTabName() {
		return tabName;
	}

	public void setTabName(String tabName) {
		this.tabName = tabName;
		
		if (tabName.equalsIgnoreCase("elementsTab")) {
			MbArrayConvElems bean = (MbArrayConvElems) ManagedBeanWrapper
					.getManagedBean("MbArrayConvElems");
			bean.setTabName(tabName);
			bean.setParentSectionId(getSectionId());
			bean.setTableState(getSateFromDB(bean.getComponentId()));
		}
	}
	
	public String getSectionId() {
		return SectionIdConstants.CONFIGURATION_ARR_CONV;
	}

	public void clearBean() {
		_arrayConversionSource.flushCache();
		_itemSelection.clearSelection();
		_activeArrayConversion = null;
		detailArrayConversion = null;
	}

	public List<SelectItem> getLovs() {
		return getDictUtils().getLov(LovConstants.LOVS_LOV);
	}

	public List<SelectItem> getArrays() {
		return getDictUtils().getLov(LovConstants.ARRAY_FOR_CONVERSION);
	}

	public ArrayList<SelectItem> getConvTypes() {
		return getDictUtils().getArticles(DictNames.CONV_TYPE, false, false);
	}

	public void changeLanguage(ValueChangeEvent event) {
		if (_activeArrayConversion != null) {
			curLang = (String) event.getNewValue();
			detailArrayConversion = getNodeByLang(detailArrayConversion.getId(), curLang);
		}
	}
	
	public ArrayConversion getNodeByLang (Integer id, String lang) {
		if (_activeArrayConversion != null) {
			List<Filter> filtersList = new ArrayList<Filter>();

			filtersList.add(new Filter("id", id.toString()));

			filtersList.add(new Filter("lang", lang));

			filters = filtersList;
			SelectionParams params = new SelectionParams();
			params.setFilters(filters.toArray(new Filter[filters.size()]));
			try {
				ArrayConversion[] arrayConvs = _commonDao.getArraysConversion(userSessionId, params);
				if (arrayConvs != null && arrayConvs.length > 0) {
					return arrayConvs[0];
				}
			} catch (Exception e) {
				FacesUtils.addMessageError(e);
				logger.error("", e);
			}
		}
		return null;
	}

	public void editLanguage(ValueChangeEvent event) {
		oldLang = (String) event.getOldValue();
	}

	public void confirmEditLanguage() {
		curLang = newArrayConversion.getLang();
		ArrayConversion tmp = getNodeByLang(newArrayConversion.getId(), newArrayConversion.getLang());
		if (tmp != null) {
			newArrayConversion.setName(tmp.getName());
			newArrayConversion.setDescription(tmp.getDescription());
		}
	}

	public void cancelEditLanguage() {
		newArrayConversion.setLang(oldLang);
	}

	public String getComponentId() {
		return COMPONENT_ID;
	}

	public Logger getLogger() {
		return logger;
	}

	public ArrayConversion getDetailArrayConversion() {
		return detailArrayConversion;
	}

	public void setDetailArrayConversion(ArrayConversion detailArrayConversion) {
		this.detailArrayConversion = detailArrayConversion;
	}
	

}
