package ru.bpc.sv2.ui.aup;

import java.util.ArrayList;
import java.util.Calendar;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.model.SelectItem;

import org.apache.commons.lang3.time.DateUtils;
import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;

import ru.bpc.sv2.aup.AuthScheme;
import ru.bpc.sv2.aup.AuthSchemeObject;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.Filter.Operator;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.AuthProcessingDao;
import ru.bpc.sv2.ui.utils.*;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import util.auxil.ManagedBeanWrapper;

@ViewScoped
@ManagedBean (name = "MbAupSchemeObjects")
public class MbAupSchemeObjects extends AbstractBean {

	private static final long serialVersionUID = -3530069602978460585L;

	private static final Logger logger = Logger.getLogger("AUTH_PROCESSING");

	private AuthProcessingDao _aupDao = new AuthProcessingDao();

	private Long objectId;
	private Integer instId;

	private AuthSchemeObject objectFilter;
	private AuthSchemeObject _activeObject;
	private AuthSchemeObject newObject;
	private AuthSchemeObject initialNewObject;
	
	private AuthScheme scheme;

	private final DaoDataModel<AuthSchemeObject> _objectSource;
	private final TableRowSelection<AuthSchemeObject> _itemSelection;

	private static String COMPONENT_ID = "schemesTable";
	private String tabName;
	private String parentSectionId;
	
	private String defaultEntityType;

	public MbAupSchemeObjects() {
		
		_objectSource = new DaoDataModel<AuthSchemeObject>() {
			private static final long serialVersionUID = 1L;

			@Override
			protected AuthSchemeObject[] loadDaoData(SelectionParams params) {
				if (scheme == null && objectId == null) {
					return new AuthSchemeObject[0];
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _aupDao.getObjectsForScheme(userSessionId, params);
				} catch (Exception e) {
					setDataSize(0);
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return new AuthSchemeObject[0];
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (scheme == null && objectId == null) {
					return 0;
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _aupDao.getObjectsForSchemeCount(userSessionId, params);
				} catch (Exception e) {
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return 0;
			}
		};

		_itemSelection = new TableRowSelection<AuthSchemeObject>(null, _objectSource);
	}

	public DaoDataModel<AuthSchemeObject> getObjects() {
		return _objectSource;
	}

	public AuthSchemeObject getActiveObject() {
		return _activeObject;
	}

	public void setActiveObject(AuthSchemeObject activeObject) {
		_activeObject = activeObject;
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

	public void setItemSelection(SimpleSelection selection) {
		_itemSelection.setWrappedSelection(selection);
		_activeObject = _itemSelection.getSingleSelection();
	}

	public void setFirstRowActive() {
		_objectSource.setRowIndex(0);
		SimpleSelection selection = new SimpleSelection();
		_activeObject = (AuthSchemeObject) _objectSource.getRowData();
		selection.addKey(_activeObject.getModelId());
		_itemSelection.setWrappedSelection(selection);
	}

	public void search() {
		clearState();
		setSearching(true);
	}

	public AuthSchemeObject getFilter() {
		if (objectFilter == null)
			objectFilter = new AuthSchemeObject();
		return objectFilter;
	}

	public void setFilter(AuthSchemeObject filter) {
		this.objectFilter = filter;
	}

	private void setFilters() {
		filters = new ArrayList<Filter>();
		if (scheme != null) {
			Filter paramFilter = new Filter();
			paramFilter.setElement("schemeId");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(scheme.getId());
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

	public void close() {
		curMode = VIEW_MODE;
	}

	public void view() {
		curMode = VIEW_MODE;
	}

	public void add() {
		newObject = new AuthSchemeObject();
		newObject.setObjectId(objectId);
		newObject.setEntityType(defaultEntityType);
		initialNewObject = null;
		curMode = NEW_MODE;
	}

	public void edit() {
		try {
			newObject = (AuthSchemeObject) _activeObject.clone();
		} catch (CloneNotSupportedException e) {
			logger.error("", e);
			newObject = _activeObject;
		}
		initialNewObject = new AuthSchemeObject();
		initialNewObject.setEndDate((_activeObject.getEndDate()==null) ? null : new Date(_activeObject.getEndDate().getTime()));
		initialNewObject.setStartDate(new Date(_activeObject.getStartDate().getTime()));
		curMode = EDIT_MODE;
	}

	public void save() {
		if (!checkDate()) {
			return;
		}
		try {
			if (isNewMode()) {
				newObject = _aupDao.addSchemeObject(userSessionId, newObject);
				_itemSelection.addNewObjectToList(newObject);
			} else {
				newObject = _aupDao.editSchemeObject(userSessionId, newObject);
				_objectSource.replaceObject(_activeObject, newObject);
			}
			_activeObject = newObject;
			curMode = VIEW_MODE;

			FacesUtils.addMessageInfo(FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Aup",
			        "scheme_object_saved"));
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}
	
	public void delete() {
		try {
			_aupDao.removeSchemeObject(userSessionId, _activeObject);
			_activeObject = _itemSelection.removeObjectFromList(_activeObject);

			if (_activeObject == null) {
				clearState();
			} else {
				
			}
			curMode = VIEW_MODE;
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public AuthSchemeObject getNewObject() {
		if (newObject == null) {
			newObject = new AuthSchemeObject();
		}
		return newObject;
	}

	public void setNewObject(AuthSchemeObject newObject) {
		this.newObject = newObject;
	}

	public void clearState() {
		_activeObject = null;
		_objectSource.flushCache();
		_itemSelection.clearSelection();
	}

	public void fullCleanBean() {
		objectId = null;
		scheme = null;
		defaultEntityType = null;
		clearState();
	}

	public AuthScheme getScheme() {
		return scheme;
	}

	public void setScheme(AuthScheme scheme) {
		this.scheme = scheme;
	}

	public Long getObjectId() {
		return objectId;
	}

	public void setObjectId(Long objectId) {
		this.objectId = objectId;
	}

	public Integer getInstId() {
		return instId;
	}

	public void setInstId(Integer instId) {
		this.instId = instId;
	}

	public List<SelectItem> getSchemes() {
		if (getInstId() == null) {
			return new ArrayList<SelectItem>();
		}
		Map<String, Object> paramMap = new HashMap<String, Object>();
		paramMap.put("instutition_id", getInstId());
		return getDictUtils().getLov(LovConstants.AUTHORIZATION_SCHEMES, paramMap);
	}

	public boolean checkDate() {
		CommonUtils common = (CommonUtils) ManagedBeanWrapper.getManagedBean("CommonUtils");
		boolean success = true;

		Calendar now = Calendar.getInstance(common.getTimeZone());

		Calendar startDate = null;
		if (newObject.getStartDate() == null) {
			FacesUtils.addMessageError(new Exception(FacesUtils.getMessage(
					"ru.bpc.sv2.ui.bundles.Msg", "specify_start_date")));
			return false;
		} else {
			startDate = Calendar.getInstance(common.getTimeZone());
			startDate.setTime(newObject.getStartDate());
		}
		Calendar endDate = null;
		if (newObject.getEndDate() != null) {
			endDate = Calendar.getInstance(common.getTimeZone());
			endDate.setTime(newObject.getEndDate());
		}

		Calendar initialStartDate = null;
		if (isEditMode() && initialNewObject != null && initialNewObject.getStartDate() != null) {
			initialStartDate = Calendar.getInstance(common.getTimeZone());
			initialStartDate.setTime(initialNewObject.getStartDate());
			/**
			 * TODO: either delete it completely (because fields should be disabled on form)
			 * or make a check of whole form if anything was changed except of end date.
			 */
//			if (!initialStartDate.after(today)) {
//				FacesUtils.addMessageError(new Exception(FacesUtils.getMessage(
//						"ru.bpc.sv2.ui.bundles.Msg", "eff_period_started")));
//				return false;
//			}
		}

		Calendar initialEndDate = null;
		if (isEditMode() && initialNewObject != null && initialNewObject.getEndDate() != null) {
			initialEndDate = Calendar.getInstance(common.getTimeZone());
			initialEndDate.setTime(initialNewObject.getEndDate());
			// when editing one can't change end date if it's in the past
			// (actually, editing must be locked completely)
			if (initialEndDate.before(now)) {
				FacesUtils.addMessageError(new Exception(FacesUtils.getMessage(
						"ru.bpc.sv2.ui.bundles.Msg", "eff_period_ended")));
				return false;
			}
		}

		// Check if start date is in the past. It makes sense only when attribute value
		// is created or when it is edited and its initial start date is in the future.
		if ((isNewMode() || (isEditMode() && initialStartDate != null && initialStartDate
				.after(now))) && DateUtils.truncatedCompareTo(startDate, now, Calendar.DATE) < 0) {
			FacesUtils.addMessageError(new Exception(FacesUtils.getMessage(
					"ru.bpc.sv2.ui.bundles.Msg", "start_date_passed")));
			success = false;
		}
		// end date can't be in the past
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

	public String getDefaultEntityType() {
		return defaultEntityType;
	}

	public void setDefaultEntityType(String defaultEntityType) {
		this.defaultEntityType = defaultEntityType;
	}

	@Override
	public void clearFilter() {
		// TODO Auto-generated method stub
		
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
