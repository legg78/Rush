package ru.bpc.sv2.ui.acm;

import org.ajax4jsf.model.KeepAlive;
import org.apache.log4j.Logger;
import org.openfaces.util.Faces;
import org.richfaces.model.selection.SimpleSelection;
import ru.bpc.sv2.acm.AcmActionValue;
import ru.bpc.sv2.acm.SectionParameter;
import ru.bpc.sv2.constants.DataTypes;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.constants.SystemConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.AccessManagementDao;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.TableRowSelection;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.RequestScoped;
import javax.faces.event.ValueChangeEvent;
import javax.faces.model.SelectItem;
import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

@RequestScoped
@KeepAlive
@ManagedBean (name = "MbAcmActionValues")
public class MbAcmActionValues extends AbstractBean {
	private static final long serialVersionUID = 2941351331618105525L;

	private static final Logger logger = Logger.getLogger("ACCESS_MANAGEMENT");

	private final String VALUE_VALUE = "value";
	private final String VALUE_FUNCTION = "function";
	
	private AccessManagementDao _acmDao = new AccessManagementDao();

	private AcmActionValue filter;
	private AcmActionValue newAcmActionValue;

	private final DaoDataModel<AcmActionValue> _actionValuesSource;
	private final TableRowSelection<AcmActionValue> _itemSelection;
	private AcmActionValue _activeAcmActionValue;

	private ArrayList<SelectItem> institutions;

	private Integer sectionId;
	private HashMap<Integer, SectionParameter> sectionParams;
	private Integer lovId;
	private String dataType;
	private String valueType;
	
	private static String COMPONENT_ID = "actionValuesTable";
	private String tabName;
	private String parentSectionId;
	
	public MbAcmActionValues() {
		_actionValuesSource = new DaoDataModel<AcmActionValue>() {
			private static final long serialVersionUID = -5044560516896743337L;

			@Override
			protected AcmActionValue[] loadDaoData(SelectionParams params) {
				if (!searching || getFilter().getActionId() == null) {
					return new AcmActionValue[0];
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _acmDao.getAcmActionValues(userSessionId, params);
				} catch (Exception e) {
					setDataSize(0);
					logger.error("", e);
					FacesUtils.addMessageError(e);
					return new AcmActionValue[0];
				}
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (!searching || getFilter().getActionId() == null) {
					return 0;
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _acmDao.getAcmActionValuesCount(userSessionId, params);
				} catch (Exception e) {
					logger.error("", e);
					FacesUtils.addMessageError(e);
					return 0;
				}
			}
		};

		_itemSelection = new TableRowSelection<AcmActionValue>(null, _actionValuesSource);
	}

	public DaoDataModel<AcmActionValue> getAcmActionValues() {
		return _actionValuesSource;
	}

	public AcmActionValue getActiveAcmActionValue() {
		return _activeAcmActionValue;
	}

	public void setActiveAcmActionValue(AcmActionValue activeAcmActionValue) {
		_activeAcmActionValue = activeAcmActionValue;
	}

	public SimpleSelection getItemSelection() {
		try {
			if (_activeAcmActionValue == null && _actionValuesSource.getRowCount() > 0) {
				setFirstRowActive();
			} else if (_activeAcmActionValue != null && _actionValuesSource.getRowCount() > 0) {
				SimpleSelection selection = new SimpleSelection();
				selection.addKey(_activeAcmActionValue.getModelId());
				_itemSelection.setWrappedSelection(selection);
				_activeAcmActionValue = _itemSelection.getSingleSelection();
			}
		} catch (Exception e) {
			logger.error("", e);
			FacesUtils.addMessageError(e);
		}
		return _itemSelection.getWrappedSelection();
	}

	public void setItemSelection(SimpleSelection selection) {
		_itemSelection.setWrappedSelection(selection);
		_activeAcmActionValue = _itemSelection.getSingleSelection();

		if (_activeAcmActionValue != null) {
			setBeans();
		}
	}

	public void setFirstRowActive() {
		_actionValuesSource.setRowIndex(0);
		SimpleSelection selection = new SimpleSelection();
		_activeAcmActionValue = (AcmActionValue) _actionValuesSource.getRowData();
		selection.addKey(_activeAcmActionValue.getModelId());
		_itemSelection.setWrappedSelection(selection);

		setBeans();
	}

	/**
	 * Sets data for backing beans used by dependent pages
	 */
	public void setBeans() {
	}

	public void setFilters() {
		getFilter();
		filters = new ArrayList<Filter>();

		Filter paramFilter = new Filter();
		paramFilter.setElement("lang");
		paramFilter.setValue(curLang);
		filters.add(paramFilter);

		paramFilter = new Filter();
		paramFilter.setElement("actionId");
		paramFilter.setValue(filter.getActionId());
		filters.add(paramFilter);

		if (filter.getId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("id");
			paramFilter.setValue(filter.getId());
			filters.add(paramFilter);
		}
		if (filter.getParamId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("paramId");
			paramFilter.setValue(filter.getParamId());
			filters.add(paramFilter);
		}
		if (filter.getSystemName() != null && filter.getSystemName().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("systemName");
			paramFilter.setValue(filter.getSystemName().trim().toUpperCase().replaceAll("[*]", "%")
					.replaceAll("[?]", "_"));
			filters.add(paramFilter);
		}
		if (filter.getDataType() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("dataType");
			paramFilter.setValue(filter.getDataType());
			filters.add(paramFilter);
		}
		if (filter.getLabel() != null && filter.getLabel().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("label");
			paramFilter.setValue(filter.getLabel().trim().toUpperCase().replaceAll("[*]", "%")
					.replaceAll("[?]", "_"));
			filters.add(paramFilter);
		}
	}

	public AcmActionValue getFilter() {
		if (filter == null) {
			filter = new AcmActionValue();
		}
		return filter;
	}

	public void setFilter(AcmActionValue filter) {
		this.filter = filter;
	}

	public void clearFilter() {
		filter = null;
		clearBean();

		searching = false;
	}

	public void fullCleanBean() {
		clearFilter();
		sectionId = null;
		lovId = null;
		dataType = null;
		sectionParams = null;
	}
	
	public void search() {
		curMode = VIEW_MODE;
		clearBean();
		searching = true;
	}

//	public void add() {
//		newAcmActionValue = new AcmActionValue();
//		newAcmActionValue.setLang(userLang);
//		
//		lovId = null;
//		dataType = null;
//		curMode = NEW_MODE;
//	}
//
//	public void edit() {
//		try {
//			newAcmActionValue = (AcmActionValue) _activeAcmActionValue.clone();
//		} catch (CloneNotSupportedException e) {
//			logger.error("", e);
//			newAcmActionValue = _activeAcmActionValue;
//		}
//		lovId = newAcmActionValue.getLovId();
//		dataType = newAcmActionValue.getDataType();
//		curMode = EDIT_MODE;
//	}

	public void delete() {
		try {
			_acmDao.removeAcmActionValue(userSessionId, _activeAcmActionValue);

//			_activeAcmActionValue = _itemSelection.removeObjectFromList(_activeAcmActionValue);
//			if (_activeAcmActionValue == null) {
//				clearBean();
//			} else {
//				setBeans();
//			}
			
			_activeAcmActionValue.setId(null);
			_activeAcmActionValue.setValueD(null);
			_activeAcmActionValue.setValueN((BigDecimal)null);
			_activeAcmActionValue.setValueV(null);
			_activeAcmActionValue.setParamFunction(null);
			_activeAcmActionValue.setParamValue(null);
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void set() {
		try {
			newAcmActionValue = (AcmActionValue) _activeAcmActionValue.clone();
		} catch (CloneNotSupportedException e) {
			logger.error("", e);
			newAcmActionValue = _activeAcmActionValue;
		}
		lovId = newAcmActionValue.getLovId();
		dataType = newAcmActionValue.getDataType();

		curMode = newAcmActionValue.getId() == null ? NEW_MODE : EDIT_MODE;
		valueType = newAcmActionValue.getParamFunction() == null ? VALUE_VALUE : VALUE_FUNCTION;
	}
	
	public void save() {
		try {
			if (isValueValue()) {
				if (isCharValue()) {
					newAcmActionValue.setParamValue(newAcmActionValue.getValueV());
				} else if (isNumberValue()) {
					newAcmActionValue.setParamValue(newAcmActionValue.getValueN());
				} else if (isDateValue()) {
					newAcmActionValue.setParamValue(newAcmActionValue.getValueD());
				}
				newAcmActionValue.setParamFunction(null);
			} else {
				newAcmActionValue.setParamValue(null);
			}
			
			if (isNewMode()) {
				newAcmActionValue = _acmDao.addAcmActionValue(userSessionId, newAcmActionValue);
//				_itemSelection.addNewObjectToList(newAcmActionValue);
			} else {
				newAcmActionValue = _acmDao.modifyAcmActionValue(userSessionId, newAcmActionValue);
//				_actionValuesSource.replaceObject(_activeAcmActionValue, newAcmActionValue);
			}
			_actionValuesSource.replaceObject(_activeAcmActionValue, newAcmActionValue);
			_activeAcmActionValue = newAcmActionValue;
			curMode = VIEW_MODE;
			setBeans();
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void cancel() {
		curMode = VIEW_MODE;
	}

	public AcmActionValue getNewAcmActionValue() {
		if (newAcmActionValue == null) {
			newAcmActionValue = new AcmActionValue();
		}
		return newAcmActionValue;
	}

	public void setNewAcmActionValue(AcmActionValue newAcmActionValue) {
		this.newAcmActionValue = newAcmActionValue;
	}

	public void clearBean() {
		curLang = userLang;
		_actionValuesSource.flushCache();
		_itemSelection.clearSelection();
		_activeAcmActionValue = null;
	}

	public void changeLanguage(ValueChangeEvent event) {
		curLang = (String) event.getNewValue();

		Filter[] filters = new Filter[2];
		filters[0] = new Filter();
		filters[0].setElement("id");
		filters[0].setValue(_activeAcmActionValue.getId().toString());
		filters[1] = new Filter();
		filters[1].setElement("lang");
		filters[1].setValue(curLang);

		SelectionParams params = new SelectionParams();
		params.setFilters(filters);
		try {
			AcmActionValue[] types = _acmDao.getAcmActionValues(userSessionId, params);
			if (types != null && types.length > 0) {
				_activeAcmActionValue = types[0];
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public ArrayList<SelectItem> getInstitutions() {
		if (institutions == null) {
			institutions = (ArrayList<SelectItem>) getDictUtils().getLov(LovConstants.INSTITUTIONS);
		}
		if (institutions == null)
			institutions = new ArrayList<SelectItem>();
		return institutions;
	}

	public List<SelectItem> getSectionParameters() {
		if (sectionId != null) {
			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("sectionId");
			filters[0].setValue(sectionId);
			filters[1] = new Filter();
			filters[1].setElement("lang");
			filters[1].setValue(userLang);
			
			SelectionParams params = new SelectionParams();
			params.setFilters(filters);
			params.setRowIndexEnd(Integer.MAX_VALUE);
			try {
				SectionParameter[] sParams = _acmDao.getSectionParameters(userSessionId, params);
				List<SelectItem> items = new ArrayList<SelectItem>(sParams.length);
				sectionParams = new HashMap<Integer, SectionParameter>(sParams.length);
				for (SectionParameter param: sParams) {
					items.add(new SelectItem(param.getId(), param.getLabel()));
					sectionParams.put(param.getId(), param);
				}
				return items;
			} catch (Exception e) {
				logger.error("", e);
				if (e.getMessage().indexOf(SystemConstants.INSUFFICIENT_PRIVILEGES_ERROR) < 0) {
					FacesUtils.addMessageError(e);
				}
			}
		}
		return new ArrayList<SelectItem>(0);
	}

	public void changeParameter(ValueChangeEvent event) {
		Integer newValue = (Integer) event.getNewValue();
		if (newValue != null) {
			lovId = sectionParams.get(newValue).getLovId();
			dataType = sectionParams.get(newValue).getDataType();
		} else {
			lovId = null;
			dataType = null;
		}
	}

	public List<SelectItem> getLovValues() {
		if (lovId == null) { 
			return new ArrayList<SelectItem>(0);
		}
		return getDictUtils().getLov(lovId);
	}
	
	public void confirmEditLanguage() {
		Filter[] filters = new Filter[2];
		filters[0] = new Filter();
		filters[0].setElement("id");
		filters[0].setValue(newAcmActionValue.getId());
		filters[1] = new Filter();
		filters[1].setElement("lang");
		filters[1].setValue(newAcmActionValue.getLang());

		SelectionParams params = new SelectionParams();
		params.setFilters(filters);
		try {
			AcmActionValue[] types = _acmDao.getAcmActionValues(userSessionId, params);
			if (types != null && types.length > 0) {
				newAcmActionValue = types[0];
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public boolean isDateValue() {
		if (dataType != null) {
			return DataTypes.DATE.equals(dataType);
		}
		return false;
	}

	public boolean isCharValue() {
		if (dataType != null) {
			return DataTypes.CHAR.equals(dataType);
		}
		return true;
	}

	public boolean isNumberValue() {
		if (dataType != null) {
			return DataTypes.NUMBER.equals(dataType);
		}
		return false;
	}

	public Integer getSectionId() {
		return sectionId;
	}

	public void setSectionId(Integer sectionId) {
		this.sectionId = sectionId;
	}
	
	private AcmActionValue getCurrentItem() {
		return (AcmActionValue) Faces.var("item");
	}

	public String getLovValue() {
		AcmActionValue currentItem = getCurrentItem();
		
		if (currentItem == null || currentItem.getParamValue() == null) {
			return null;
		}
		
		try {
			List<SelectItem> lovs = getDictUtils().getLov(currentItem.getLovId());
			for (SelectItem lov: lovs) {
				// lov.getValue() != null is redundant, i think, but
				// during development such situations are possible, unfortunately.
				if (lov.getValue() != null) {
					if (lov.getValue().equals(currentItem.getParamValue())
							|| (currentItem.isNumberValue() && currentItem.getValueN() != null 
									&& lov.getValue().equals(
									String.valueOf(currentItem.getValueN().longValue())))) {
						return lov.getLabel();
					}
				}
			}
		} catch (Exception e) {
			logger.error("", e);
			FacesUtils.addMessageError(e);
		}
		return currentItem.getParamValue().toString();
	}

	public Integer getLovId() {
		return lovId;
	}

	public void setLovId(Integer lovId) {
		this.lovId = lovId;
	}

	public String getValueType() {
		return valueType;
	}

	public void setValueType(String valueType) {
		this.valueType = valueType;
	}
	
	public String getValueTypeValue() {
		return VALUE_VALUE;
	}

	public String getValueTypeFunction() {
		return VALUE_FUNCTION;
	}
	
	public boolean isValueValue() {
		return VALUE_VALUE.equals(valueType);
	}

	public boolean isValueFunction() {
		return VALUE_FUNCTION.equals(valueType);
	}
	
	public String getComponentId() {
		return parentSectionId + ":" + tabName + ":" + COMPONENT_ID;
	}

	public void setTabName(String tabName) {
		this.tabName = tabName;
	}

	public void setParentSectionId(String parentSectionId) {
		this.parentSectionId = parentSectionId;
	}

}
