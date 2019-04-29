package ru.bpc.sv2.ui.fraud;

import java.util.ArrayList;
import java.util.Calendar;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.model.SelectItem;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;

import ru.bpc.sv2.constants.SystemConstants;
import ru.bpc.sv2.fraud.FraudObject;
import ru.bpc.sv2.fraud.FraudPrivConstants;
import ru.bpc.sv2.fraud.Suite;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.invocation.Filter.Operator;
import ru.bpc.sv2.logic.FraudDao;
import ru.bpc.sv2.ui.utils.*;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import util.auxil.ManagedBeanWrapper;

@ViewScoped
@ManagedBean (name = "MbFraudObjects")
public class MbFraudObjects extends AbstractBean {
	
	private static final Logger logger = Logger.getLogger("FRAUD_PREVENTION");
	
	private final DaoDataModel<FraudObject> _objectSource;
	private final TableRowSelection<FraudObject> _itemSelection;
	
	private FraudObject objectFilter;
	private FraudObject _activeObject;
	private FraudObject newSuiteObject;
	
	private static String COMPONENT_ID = "suiteObjectsTable";
	
	private String tabName;
	private String parentSectionId;
	
	private Long objectId;
	private String entityType;

	private FraudDao _fraudDao = new FraudDao();
	private String privilege;
	
	public MbFraudObjects() {
		privilege = FraudPrivConstants.VIEW_TAB_SUITE;
		_objectSource = new DaoDataModel<FraudObject>() {
			private static final long serialVersionUID = 1L;

			@Override
			protected FraudObject[] loadDaoData(SelectionParams params) {
				if (entityType == null && objectId == null) {
					return new FraudObject[0];
				}
				if (!searching) {
					return new FraudObject[0];
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					params.setPrivilege(privilege);
					return _fraudDao.getFraudObjects(userSessionId, params);
				} catch (Exception e) {
					setDataSize(0);
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return new FraudObject[0];
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (entityType == null && objectId == null) {
					return 0;
				}
				if (!searching) {
					return 0;
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					params.setPrivilege(privilege);
					return _fraudDao.getFraudObjectCount(userSessionId, params);
				} catch (Exception e) {
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return 0;
			}
		};

		_itemSelection = new TableRowSelection<FraudObject>(null, _objectSource);
	}

	@Override
	public void clearFilter() {
		// TODO Auto-generated method stub

	}

	public FraudObject getFilter() {
		if (objectFilter == null)
			objectFilter = new FraudObject();
		return objectFilter;
	}

	public void setFilter(FraudObject filter) {
		this.objectFilter = filter;
	}

	private void setFilters() {
		filters = new ArrayList<Filter>();
		if (entityType != null) {
			Filter paramFilter = new Filter();
			paramFilter.setElement("entityType");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(entityType);
			filters.add(paramFilter);
		}
		if (objectId != null) {
			Filter paramFilter = new Filter();
			paramFilter.setElement("objectId");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(objectId);
			filters.add(paramFilter);
		}
	}
	
	public DaoDataModel<FraudObject> getObjects() {
		return _objectSource;
	}
	
	public FraudObject getActiveObject() {
		return _activeObject;
	}

	public void setActiveObject(FraudObject activeObject) {
		_activeObject = activeObject;
	}
	
	public void setItemSelection(SimpleSelection selection) {
		_itemSelection.setWrappedSelection(selection);
		_activeObject = _itemSelection.getSingleSelection();
	}
	
	public SimpleSelection getItemSelection() {
		if (_activeObject == null && _objectSource.getRowCount() > 0) {
			setFirstRowActive();
		} else if (_activeObject != null && _objectSource.getRowCount() > 0) {
			SimpleSelection selection = new SimpleSelection();
			selection.addKey(_activeObject.getModelId());
			_itemSelection.setWrappedSelection(selection);
			_activeObject = _itemSelection.getSingleSelection();
		}
		return _itemSelection.getWrappedSelection();
	}
	
	public void setFirstRowActive() {
		_objectSource.setRowIndex(0);
		SimpleSelection selection = new SimpleSelection();
		_activeObject = (FraudObject) _objectSource.getRowData();
		selection.addKey(_activeObject.getModelId());
		_itemSelection.setWrappedSelection(selection);
	}
	
	public void search() {
		clearState();
		setSearching(true);
	}
	
	public void clearState() {
		_activeObject = null;
		_objectSource.flushCache();
		_itemSelection.clearSelection();
	}

	public void fullCleanBean() {
		objectId=null;
		entityType=null;
		searching = false;
		clearState();
	}
	
	public ArrayList<SelectItem> getSuites() {
		
		Filter[] filters = new Filter[1];
		filters[0] = new Filter();
		filters[0].setElement("lang");
		filters[0].setValue(curLang);
		
		SelectionParams params = new SelectionParams();
		params.setFilters(filters);
		params.setRowIndexEnd(Integer.MAX_VALUE);
		params.setPrivilege(privilege);
		
		try {
			Suite[] suites = _fraudDao.getSuites(userSessionId, params);
			ArrayList<SelectItem> items = new ArrayList<SelectItem>(suites.length);
			
			for (Suite suite: suites) {
				items.add(new SelectItem(suite.getId(), suite.getLabel()));
			}
			return items;
		} catch (Exception e) {
			logger.error("", e);
			if (e.getMessage().indexOf(SystemConstants.INSUFFICIENT_PRIVILEGES_ERROR) < 0) {
				FacesUtils.addMessageError(e);
			}
		}
		return new ArrayList<SelectItem>(0);
	}
	
	public void add() {
		newSuiteObject = new FraudObject();
		newSuiteObject.setObjectId(objectId);
		newSuiteObject.setEntityType(entityType);
		curMode = NEW_MODE;
	}
	
	public void edit() {
		try {
			newSuiteObject = _activeObject.clone();
		} catch (CloneNotSupportedException e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
			newSuiteObject = _activeObject;
		}
		curMode = EDIT_MODE;
	}
	
	public void cancel() {
		curMode = VIEW_MODE;
	}
	
	public void save() {
		if (!checkDate()) {
			return;
		}
		try {
			if (isNewMode()) {
				newSuiteObject = _fraudDao.addSuiteObject(userSessionId, newSuiteObject);
				_itemSelection.addNewObjectToList(newSuiteObject);
			} else {
				newSuiteObject = _fraudDao.modifySuiteObject(userSessionId, newSuiteObject);
				_objectSource.replaceObject(_activeObject, newSuiteObject);
			}
			_activeObject = (FraudObject) newSuiteObject.clone();
			curMode = VIEW_MODE;
			FacesUtils.addMessageInfo("Saved!");
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}
	
	public boolean checkDate() {
		CommonUtils common = (CommonUtils) ManagedBeanWrapper.getManagedBean("CommonUtils");
		boolean success = true;

		Calendar now = Calendar.getInstance(common.getTimeZone());

		Calendar startDate = null;
		if (newSuiteObject.getStartDate() == null) {
			FacesUtils.addMessageError(new Exception(FacesUtils.getMessage(
					"ru.bpc.sv2.ui.bundles.Msg", "specify_start_date")));
			return false;
		} else {
			startDate = Calendar.getInstance(common.getTimeZone());
			startDate.setTime(newSuiteObject.getStartDate());
		}
		Calendar endDate = null;
		if (newSuiteObject.getEndDate() != null) {
			endDate = Calendar.getInstance(common.getTimeZone());
			endDate.setTime(newSuiteObject.getEndDate());
		}

		if (endDate != null && endDate.before(now)) {
			FacesUtils.addMessageError(new Exception(FacesUtils.getMessage(
					"ru.bpc.sv2.ui.bundles.Msg", "end_date_passed")));
			success = false;
		}
		// end date can't be less than start date
		if (endDate != null && startDate.after(endDate)) {
			FacesUtils.addMessageError(new Exception(FacesUtils.getMessage(
					"ru.bpc.sv2.ui.bundles.Msg", "start_date_after_end_date")));
			success = false;
		}

		return success;
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

	public FraudObject getNewSuiteObject() {
		return newSuiteObject;
	}
	
	public void setTabName(String tabName) {
		this.tabName = tabName;
	}

	public void setParentSectionId(String parentSectionId) {
		this.parentSectionId = parentSectionId;
	}
	
	public void setTableState(String tableState) {
		this.tableState = tableState;
	}
	
	public String getComponentId() {
		return parentSectionId + ":" + tabName + ":" + COMPONENT_ID;
	}

	public void setPrivilege(String privilege) {
		this.privilege = privilege;
	}
}
