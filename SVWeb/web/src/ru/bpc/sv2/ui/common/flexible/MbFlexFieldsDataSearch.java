package ru.bpc.sv2.ui.common.flexible;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;

import java.util.List;


import ru.bpc.sv2.logic.utility.db.DataAccessException;
import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.model.SelectItem;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;

import ru.bpc.sv2.common.FlexField;
import ru.bpc.sv2.common.FlexFieldData;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.invocation.Filter.Operator;
import ru.bpc.sv2.logic.CommonDao;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.TableRowSelection;

@ViewScoped
@ManagedBean (name = "MbFlexFieldsDataSearch")
public class MbFlexFieldsDataSearch extends AbstractBean {
	private static final Logger logger = Logger.getLogger("COMMON");

	private CommonDao _commonDao = new CommonDao();

	private FlexFieldData filter;
	private FlexFieldData _activeFlexFieldData;
	private FlexFieldData newFlexField;

	
	private String backLink;
	private boolean selectMode;

	private static String COMPONENT_ID = "flexDataTable";
	private String tabName;
	private String parentSectionId;
	
	private final DaoDataModel<FlexFieldData> _flexFieldDatasSource;

	private final TableRowSelection<FlexFieldData> _itemSelection;
	private ArrayList<SelectItem> dataTypes;

	public MbFlexFieldsDataSearch() {
		
		filter = new FlexFieldData();

		_flexFieldDatasSource = new DaoDataModel<FlexFieldData>() {
			@Override
			protected FlexFieldData[] loadDaoData(SelectionParams params) {
				if (!searching || getFilter().getEntityType() == null)
					return new FlexFieldData[0];
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return getFilter().getChildEntityFilter() != null
							? _commonDao.getFlexFieldsDataWithChildEntities(userSessionId, params)
							: _commonDao.getFlexFieldsData(userSessionId, params);
				} catch (Exception e) {
					setDataSize(0);
					logger.error("", e);
					FacesUtils.addMessageError(e);
				}
				return new FlexFieldData[0];
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (!searching || getFilter().getEntityType() == null)
					return 0;
				try {	
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));			 
					return getFilter().getChildEntityFilter() != null
							? _commonDao.getFlexFieldsDataWithChildEntitiesCount(userSessionId, params)
							: _commonDao.getFlexFieldsDataCount(userSessionId, params);
				} catch (Exception e) {
					logger.error("", e);
					FacesUtils.addMessageError(e);
				}
				return 0;
			}
		};

		_itemSelection = new TableRowSelection<FlexFieldData>(null, _flexFieldDatasSource);
	}

	public DaoDataModel<FlexFieldData> getFlexFieldsData() {
		return _flexFieldDatasSource;
	}

	public FlexFieldData getActiveFlexFieldData() {
		return _activeFlexFieldData;
	}

	public void setActiveFlexFieldData(FlexFieldData flexFieldData) {
		_activeFlexFieldData = flexFieldData;
	}

	public SimpleSelection getItemSelection() {
		if (_activeFlexFieldData == null && _flexFieldDatasSource.getRowCount() > 0) {
			setFirstRowActive();
		} else if (_activeFlexFieldData != null && _flexFieldDatasSource.getRowCount() > 0) {
			SimpleSelection selection = new SimpleSelection();
			selection.addKey(_activeFlexFieldData.getModelId());
			_itemSelection.setWrappedSelection(selection);
			_activeFlexFieldData = _itemSelection.getSingleSelection();
		}
		return _itemSelection.getWrappedSelection();
	}

	public void setFirstRowActive() {
		_flexFieldDatasSource.setRowIndex(0);
		SimpleSelection selection = new SimpleSelection();
		_activeFlexFieldData = (FlexFieldData) _flexFieldDatasSource.getRowData();
		selection.addKey(_activeFlexFieldData.getModelId());
		_itemSelection.setWrappedSelection(selection);
		if (_activeFlexFieldData != null) {
			// setInfo();
		}
	}

	public void setItemSelection(SimpleSelection selection) {
		_itemSelection.setWrappedSelection(selection);
		_activeFlexFieldData = _itemSelection.getSingleSelection();
		if (_activeFlexFieldData != null) {
			// setInfo();
		}
	}

	public void edit() {
		_activeFlexFieldData.setLang(userLang);
	}

	public void saveFlexFieldData() {
		try {
			if (_activeFlexFieldData.getEntityType().equals(getFilter().getEntityType())) {
				//the selected flex field is related to the parent entity
				_activeFlexFieldData.setObjectId(getFilter().getObjectId());
			} else if (getFilter().getChildEntityFilter() != null) {
				//the selected flex field is related to the child entity
				_activeFlexFieldData.setObjectId(getFilter().getChildEntityFilter().getObjectId());		
			} else {
				throw new DataAccessException(String.format("Unable to determine Object ID for "
						+ "[Entity Type = %s]. Flexible field data won't be modified."
						, _activeFlexFieldData.getEntityType()));
			}			
			_commonDao.setFlexFieldData(userSessionId, _activeFlexFieldData);
			_flexFieldDatasSource.flushCache();
		} catch (DataAccessException ee) {
			_flexFieldDatasSource.flushCache();
			FacesUtils.addMessageError(ee);
			logger.error("", ee);
		}
	}

	public void search() {
		setSearching(true);
		_itemSelection.clearSelection();
		_activeFlexFieldData = null;
		_flexFieldDatasSource.flushCache();
	}

	public void setFilters() {
		List<Filter> filtersList = new ArrayList<Filter>();
		Filter paramFilter = null;
		if (getFilter().getEntityType() != null && !getFilter().getEntityType().equals("")) {
			paramFilter = new Filter();
			paramFilter.setElement("entityType");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(filter.getEntityType());
			filtersList.add(paramFilter);
		}
		if (getFilter().getObjectType() != null && !getFilter().getObjectType().equals("")) {
			paramFilter = new Filter();
			paramFilter.setElement("objectType");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(filter.getObjectType());
			filtersList.add(paramFilter);
		}
		if (getFilter().getObjectId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("objectId");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(getFilter().getObjectId().toString());
			filtersList.add(paramFilter);
		}

		if (getFilter().getInstId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("instId");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(getFilter().getInstId().toString());
			filtersList.add(paramFilter);
		}		
		
		if( getFilter().getChildEntityFilter() != null ){
			FlexFieldData childEntityFilter = getFilter().getChildEntityFilter();
			if (childEntityFilter.getEntityType() != null && !childEntityFilter.getEntityType().equals("")) {
				paramFilter = new Filter();
				paramFilter.setElement("childEntityEntityType");
				paramFilter.setOp(Operator.eq);
				paramFilter.setValue(childEntityFilter.getEntityType());
				filtersList.add(paramFilter);
			}
			if (childEntityFilter.getObjectType() != null && !childEntityFilter.getObjectType().equals("")) {
				paramFilter = new Filter();
				paramFilter.setElement("childEntityObjectType");
				paramFilter.setOp(Operator.eq);
				paramFilter.setValue(childEntityFilter.getObjectType());
				filtersList.add(paramFilter);
			}
			if (childEntityFilter.getObjectId() != null) {
				paramFilter = new Filter();
				paramFilter.setElement("childEntityObjectId");
				paramFilter.setOp(Operator.eq);
				paramFilter.setValue(childEntityFilter.getObjectId().toString());
				filtersList.add(paramFilter);
			}

			if (childEntityFilter.getInstId() != null) {
				paramFilter = new Filter();
				paramFilter.setElement("childEntityInstId");
				paramFilter.setOp(Operator.eq);
				paramFilter.setValue(childEntityFilter.getInstId().toString());
				filtersList.add(paramFilter);
			}
		}

		paramFilter = new Filter();
		paramFilter.setElement("lang");
		paramFilter.setOp(Operator.eq);
		paramFilter.setValue(userLang);
		filtersList.add(paramFilter);

		filters = filtersList;
	}

	public FlexFieldData getFilter() {
		if (filter == null)
			filter = new FlexFieldData();
		return filter;
	}

	public void setFilter(FlexFieldData filter) {
		this.filter = filter;
	}

	public List<Filter> getFilters() {
		return filters;
	}

	public void setFilters(List<Filter> filters) {
		this.filters = filters;
	}

	public void cancel() {
		_activeFlexFieldData = null;
		newFlexField = null;
	}

	public String getBackLink() {
		return backLink;
	}

	public void setBackLink(String backLink) {
		this.backLink = backLink;
	}

	public boolean isSelectMode() {
		return selectMode;
	}

	public void setSelectMode(boolean selectMode) {
		this.selectMode = selectMode;
	}

	public List<SelectItem> getListValues() {
		return getDictUtils().getLov(_activeFlexFieldData.getLovId());
	}

	public ArrayList<SelectItem> getDataTypes() {
		if (dataTypes == null){
			dataTypes = (ArrayList<SelectItem>) getDictUtils().getLov(LovConstants.DATA_TYPES);
		}
		return dataTypes;
	}

	public FlexField getNewFlexField() {
		if (newFlexField == null) {
			newFlexField = new FlexFieldData();
		}
		return newFlexField;
	}

	public void setNewFlexField(FlexFieldData newFlexField) {
		this.newFlexField = newFlexField;
	}

	public List<SelectItem> getLovs() {
		if (getNewFlexField().getDataType() == null) {
			return new ArrayList<SelectItem>(0);
		}

		Map<String, Object> params = new HashMap<String, Object>(1);
		params.put("DATA_TYPE", getNewFlexField().getDataType());
		return getDictUtils().getLov(LovConstants.LOVS_LOV, params);
	}

	public boolean isSearching() {
		return searching;
	}

	public void setSearching(boolean searching) {
		this.searching = searching;
	}

	public void clearBean() {
		_activeFlexFieldData = null;
		_itemSelection.clearSelection();
		_flexFieldDatasSource.flushCache();
	}
	
	public void clearFilter() {
		filter = null;
		searching = false;
		clearBean();
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
