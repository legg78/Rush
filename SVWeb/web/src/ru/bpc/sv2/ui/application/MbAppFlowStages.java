package ru.bpc.sv2.ui.application;

import org.ajax4jsf.model.KeepAlive;
import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;
import ru.bpc.sv2.application.ApplicationFlow;
import ru.bpc.sv2.application.ApplicationFlowStage;
import ru.bpc.sv2.constants.DictNames;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.constants.application.ApplicationConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.ApplicationDao;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.TableRowSelection;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.RequestScoped;
import javax.faces.model.SelectItem;
import java.util.ArrayList;
import java.util.List;

@RequestScoped
@KeepAlive
@ManagedBean (name = "MbAppFlowStages")
public class MbAppFlowStages extends AbstractBean {

	private static final Logger logger = Logger.getLogger("APPLICATIONS");

	private ApplicationDao _applicationDao = new ApplicationDao();

	private List<Filter> filters;
	private ApplicationFlowStage filter;
	private final DaoDataModel<ApplicationFlowStage> _flowStageSource;
	private final TableRowSelection<ApplicationFlowStage> _itemSelection;

	private ApplicationFlowStage _activeFlowStage;
	private ApplicationFlowStage newAppFlowStage;

	private ApplicationFlow applicationFlow;
	
	private static String COMPONENT_ID = "flowStagesTable";
	private String tabName;
	private String parentSectionId;

	public MbAppFlowStages() {
		filters = new ArrayList<Filter>();
		
		_flowStageSource = new DaoDataModel<ApplicationFlowStage>() {
			@Override
			protected ApplicationFlowStage[] loadDaoData(SelectionParams params) {
				if (applicationFlow == null || !searching) {
					return new ApplicationFlowStage[0];
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _applicationDao.getApplicationFlowStages(userSessionId, params);
				} catch (Exception e) {
					setDataSize(0);
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return new ApplicationFlowStage[0];
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (applicationFlow == null || !searching) {
					return 0;
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _applicationDao.getApplicationFlowStagesCount(userSessionId, params);
				} catch (Exception e) {
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return 0;
			}
		};

		_itemSelection = new TableRowSelection<ApplicationFlowStage>(null, _flowStageSource);
	}

	public DaoDataModel<ApplicationFlowStage> getFlowStages() {
		return _flowStageSource;
	}

	public ApplicationFlowStage getActiveFlowStage() {
		return _activeFlowStage;
	}

	public void setActiveFlowStage(ApplicationFlowStage activeTemplate) {
		_activeFlowStage = activeTemplate;
	}

	public SimpleSelection getItemSelection() {
		if (_activeFlowStage == null && _flowStageSource.getRowCount() > 0) {
			setFirstRowActive();
		} else if (_activeFlowStage != null && _flowStageSource.getRowCount() > 0) {
			SimpleSelection selection = new SimpleSelection();
			selection.addKey(_activeFlowStage.getModelId());
			_itemSelection.setWrappedSelection(selection);
			_activeFlowStage = _itemSelection.getSingleSelection();
		}
		return _itemSelection.getWrappedSelection();
	}

	public void setItemSelection(SimpleSelection selection) {
		_itemSelection.setWrappedSelection(selection);
		_activeFlowStage = _itemSelection.getSingleSelection();
	}

	public void setFirstRowActive() {
		_flowStageSource.setRowIndex(0);
		SimpleSelection selection = new SimpleSelection();
		_activeFlowStage = (ApplicationFlowStage) _flowStageSource.getRowData();
		selection.addKey(_activeFlowStage.getModelId());
		_itemSelection.setWrappedSelection(selection);
		if (_activeFlowStage != null) {
			// setInfo();
		}
	}

	public ApplicationFlow getApplicationFlow() {
		return applicationFlow;
	}

	public void setApplicationFlow(ApplicationFlow applicationFlow) {
		this.applicationFlow = applicationFlow;
	}

	public void search() {
		curLang = userLang;
		clearState();
		searching = true;
	}

	public void clearBean() {
		_flowStageSource.flushCache();
		_itemSelection.clearSelection();
		_activeFlowStage = null;
		applicationFlow = null;
	}

	public void fullCleanBean() {
		clearBean();
	}

	public void clearState() {
		_itemSelection.clearSelection();
		_activeFlowStage = null;
		_flowStageSource.flushCache();
	}

	public ApplicationFlowStage getFilter() {
		if (filter == null) {
			filter = new ApplicationFlowStage();
		}
		return filter;
	}

	public void setFilter(ApplicationFlowStage filter) {
		this.filter = filter;
	}

	private void setFilters() {
		filter = getFilter();
		filters = new ArrayList<Filter>();

		if (applicationFlow != null) {
			filters.add(Filter.create("flowId", applicationFlow.getId()));
		}
		if (filter.getId() != null) {
			filters.add(Filter.create("id", filter.getId().toString()));
		}
		if (filter.getAppStatus() != null && filter.getAppStatus().trim().length() > 0) {
			filters.add(Filter.create("status", filter.getAppStatus()));
		}
		if (filter.getFlowName() != null && filter.getFlowName().trim().length() > 0) {
			filters.add(Filter.create("flowName", filter.getFlowName()));
		}
		if (filter.getHandlerType() != null){
			filters.add(Filter.create("handlerType", filter.getHandlerType()));
		}
		if (filter.getRoleId() != null){
			filters.add(Filter.create("roleId", filter.getRoleId()));
		}
	}

	public void view() {
		curMode = VIEW_MODE;
	}

	public void add() {
		curMode = NEW_MODE;
		newAppFlowStage = new ApplicationFlowStage();
		newAppFlowStage.setFlowId(applicationFlow.getId());
	}

	public void edit() {
		try {
			newAppFlowStage = (ApplicationFlowStage) _activeFlowStage.clone();
		} catch (CloneNotSupportedException e) {
			logger.error("", e);
			newAppFlowStage = _activeFlowStage;
		}
		curMode = EDIT_MODE;
	}

	public void delete() {
		try {
			_applicationDao.deleteApplicationFlowStage(userSessionId, _activeFlowStage);

			String msg = FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.App", "flow_stage_deleted",
			        "(id = " + _activeFlowStage.getId() + ")");

			_activeFlowStage = _itemSelection.removeObjectFromList(_activeFlowStage);
			if (_activeFlowStage == null) {
				clearBean();
			}

			FacesUtils.addMessageInfo(msg);
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void save() {
		try {
			if (isNewMode()) {
				newAppFlowStage = _applicationDao.addApplicationFlowStage(userSessionId, newAppFlowStage);
				_itemSelection.addNewObjectToList(newAppFlowStage);
			} else {
				newAppFlowStage = _applicationDao.editApplicationFlowStage(userSessionId, newAppFlowStage);
				_flowStageSource.replaceObject(_activeFlowStage, newAppFlowStage);
			}
			_activeFlowStage = newAppFlowStage;
			curMode = VIEW_MODE;

			FacesUtils.addMessageInfo(FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.App",
			        "flow_stage_saved"));

		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void close() {
		curMode = VIEW_MODE;
	}

	public ApplicationFlowStage getNewAppFlowStage() {
		if (newAppFlowStage == null) {
			newAppFlowStage = new ApplicationFlowStage();
		}
		return newAppFlowStage;
	}

	public void setNewAppFlowStage(ApplicationFlowStage newAppFlowStage) {
		this.newAppFlowStage = newAppFlowStage;
	}

	public List<SelectItem> getApplicationStatuses() {
		return getDictUtils().getArticles(DictNames.AP_STATUSES, false, true);
	}

	public List<SelectItem> getHandlerTypes(){
		List<SelectItem> result;
		result = getDictUtils().getLov(LovConstants.HANDLER_TYPE);
		return result;
	}

	public List<SelectItem> getRejectCodes() {
	    if (applicationFlow == null) return null;
	    if (ApplicationConstants.TYPE_DISPUTES.equals(applicationFlow.getAppType())) {
	        return getDictUtils().getLov(LovConstants.DISPUTE_APPLICATION_REJECT_CODE);
        } else {
            return getDictUtils().getLov(LovConstants.APPLICATION_REJECT_CODE);
        }
	}

	public List<SelectItem> getRoles() {
		return getDictUtils().getLov(LovConstants.ROLES);
	}

	@Override
	public void clearFilter() {}

	public void resetHandler(){
		getNewAppFlowStage().setHandler(null);
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
