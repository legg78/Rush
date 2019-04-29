package ru.bpc.sv2.ui.application;

import java.util.ArrayList;
import java.util.List;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;

import ru.bpc.sv2.application.Application;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.Filter.Operator;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.ApplicationDao;
import ru.bpc.sv2.ui.utils.*;

@ViewScoped
@ManagedBean(name = "MbObjectApplicationsSearch")
public class MbObjectApplicationsSearch extends AbstractBean {

	private static final long serialVersionUID = -3530069602978460585L;

	private static final Logger logger = Logger.getLogger("AUTH_PROCESSING");

	private ApplicationDao _appDao = new ApplicationDao();

	private Long objectId;
	private String entityType;

	private Application _activeObject;
	
	private final DaoDataModel<Application> _appsSource;
	private final TableRowSelection<Application> _itemSelection;
	
	private static String COMPONENT_ID = "applicationsTable";
	private String tabName;
	private String parentSectionId;

	public MbObjectApplicationsSearch() {
		_appsSource = new DaoDataListModel<Application>(logger) {
			private static final long serialVersionUID = 1L;

			@Override
			protected List<Application> loadDaoListData(SelectionParams params) {
				if (objectId != null) {
					setFilters();
					params.setFilters(filters);
					return _appDao.getApplications(userSessionId, params);
				}
				return new ArrayList<Application>();
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (objectId != null) {
					setFilters();
					params.setFilters(filters);
					return _appDao.getApplicationsCount(userSessionId, params);
				}
				return 0;
			}
		};

		_itemSelection = new TableRowSelection<Application>(null, _appsSource);
	}

	public DaoDataModel<Application> getApplications() {
		return _appsSource;
	}

	public Application getActiveObject() {
		return _activeObject;
	}

	public void setActiveObject(Application activeObject) {
		_activeObject = activeObject;
	}

	public SimpleSelection getItemSelection() {
		if (_activeObject == null && _appsSource.getRowCount() > 0) {
			setFirstRowActive();
		} else if (_activeObject != null && _appsSource.getRowCount() > 0) {
			SimpleSelection selection = new SimpleSelection();
			selection.addKey(_activeObject.getModelId());
			_itemSelection.setWrappedSelection(selection);
			_activeObject = _itemSelection.getSingleSelection();
		}
		return _itemSelection.getWrappedSelection();
	}

	public void setItemSelection(SimpleSelection selection) {
		_itemSelection.setWrappedSelection(selection);
		_activeObject = _itemSelection.getSingleSelection();
	}

	public void setFirstRowActive() {
		_appsSource.setRowIndex(0);
		SimpleSelection selection = new SimpleSelection();
		_activeObject = (Application) _appsSource.getRowData();
		selection.addKey(_activeObject.getModelId());
		_itemSelection.setWrappedSelection(selection);
	}

	public void search() {
		clearState();
		setSearching(true);
	}

	private void setFilters() {
		filters = new ArrayList<Filter>();
		if (entityType != null && !"".equals(entityType)) {
			Filter paramFilter = new Filter();
			paramFilter.setElement("entity_type");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(entityType);
			filters.add(paramFilter);
		}
		if (objectId != null) {
			Filter paramFilter = new Filter();
			paramFilter.setElement("object_id");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(objectId);
			filters.add(paramFilter);
		}
		
		Filter paramFilter = new Filter();
		paramFilter.setElement("lang");
		paramFilter.setOp(Operator.eq);
		paramFilter.setValue(curLang);
		filters.add(paramFilter);
	}

	public void close() {
		curMode = VIEW_MODE;
	}

	public void view() {
		curMode = VIEW_MODE;
	}

	public void clearState() {
		_activeObject = null;
		_appsSource.flushCache();
		_itemSelection.clearSelection();
	}

	public void fullCleanBean() {
		objectId = null;
		entityType = null;
		clearState();
	}

	public Long getObjectId() {
		return objectId;
	}

	public void setObjectId(Long objectId) {
		this.objectId = objectId;
	}

	public String getEntityType() {
		return entityType;
	}

	public void setEntityType(String entityType) {
		this.entityType = entityType;
	}

	@Override
	public void clearFilter() {
		clearState();
		searching = false;
		objectId = null;
		entityType = null;
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
