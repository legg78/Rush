package ru.bpc.sv2.ui.application;

import org.ajax4jsf.model.KeepAlive;
import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;
import ru.bpc.sv2.application.ApplicationFlow;
import ru.bpc.sv2.application.ApplicationFlowStage;
import ru.bpc.sv2.application.ApplicationFlowTransition;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.constants.SystemConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.Filter.Operator;
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
@ManagedBean (name = "MbAppFlowTransitions")
public class MbAppFlowTransitions extends AbstractBean {

	private static final long serialVersionUID = 7867474153311997107L;

	private static final Logger logger = Logger.getLogger("APPLICATIONS");

	private ApplicationDao _applicationDao = new ApplicationDao();
	
	private List<Filter> filters;
	private ApplicationFlowTransition filter;
	private final DaoDataModel<ApplicationFlowTransition> _transitionSource;
	private final TableRowSelection<ApplicationFlowTransition> _itemSelection;

	private ApplicationFlowTransition _activeTransition;
	private ApplicationFlowTransition newTransition;

	private ApplicationFlow applicationFlow;
	
	private static String COMPONENT_ID = "flowTransitionsTable";
	private String tabName;
	private String parentSectionId;

	public MbAppFlowTransitions() {
		filters = new ArrayList<Filter>();
		_transitionSource = new DaoDataModel<ApplicationFlowTransition>() {
			private static final long serialVersionUID = -4724506990667992157L;

			@Override
			protected ApplicationFlowTransition[] loadDaoData(SelectionParams params) {
				if (applicationFlow == null || !searching) {
					return new ApplicationFlowTransition[0];
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _applicationDao.getApplicationFlowTransitions(userSessionId, params);
				} catch (Exception e) {
					setDataSize(0);
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return new ApplicationFlowTransition[0];
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (applicationFlow == null || !searching) {
					return 0;
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _applicationDao.getApplicationFlowTransitionsCount(userSessionId, params);
				} catch (Exception e) {
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return 0;
			}
		};

		_itemSelection = new TableRowSelection<ApplicationFlowTransition>(null, _transitionSource);
	}

	public DaoDataModel<ApplicationFlowTransition> getTransitions() {
		return _transitionSource;
	}

	public ApplicationFlowTransition getActiveTransition() {
		return _activeTransition;
	}

	public void setActiveTransition(ApplicationFlowTransition activeTemplate) {
		_activeTransition = activeTemplate;
	}

	public SimpleSelection getItemSelection() {
		if (_activeTransition == null && _transitionSource.getRowCount() > 0) {
			setFirstRowActive();
		} else if (_activeTransition != null && _transitionSource.getRowCount() > 0) {
			SimpleSelection selection = new SimpleSelection();
			selection.addKey(_activeTransition.getModelId());
			_itemSelection.setWrappedSelection(selection);
			_activeTransition = _itemSelection.getSingleSelection();
		}
		return _itemSelection.getWrappedSelection();
	}

	public void setItemSelection(SimpleSelection selection) {
		_itemSelection.setWrappedSelection(selection);
		_activeTransition = _itemSelection.getSingleSelection();
	}

	public void setFirstRowActive() {
		_transitionSource.setRowIndex(0);
		SimpleSelection selection = new SimpleSelection();
		_activeTransition = (ApplicationFlowTransition) _transitionSource.getRowData();
		selection.addKey(_activeTransition.getModelId());
		_itemSelection.setWrappedSelection(selection);
		if (_activeTransition != null) {
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
		_transitionSource.flushCache();
		_itemSelection.clearSelection();
		_activeTransition = null;
		applicationFlow = null;
	}

	public void fullCleanBean() {
		clearBean();
	}

	public void clearState() {
		_itemSelection.clearSelection();
		_activeTransition = null;
		_transitionSource.flushCache();
	}

	public ApplicationFlowTransition getFilter() {
		if (filter == null) {
			filter = new ApplicationFlowTransition();
		}
		return filter;
	}

	public void setFilter(ApplicationFlowTransition filter) {
		this.filter = filter;
	}

	private void setFilters() {
		filter = getFilter();
		filters = new ArrayList<Filter>();

		Filter paramFilter;
		if (applicationFlow != null) {
			filters.add(Filter.create("flowId", applicationFlow.getId()));
		}
		if (filter.getId() != null) {
			filters.add(Filter.create("id", filter.getId().toString()));
		}
		if (filter.getAppStatus() != null && filter.getAppStatus().trim().length() > 0) {
			filters.add(Filter.create("status", filter.getAppStatus()));
		}
		if (filter.getAppStatusName() != null && filter.getAppStatusName().trim().length() > 0) {
			filters.add(Filter.create("appStatusName", filter.getAppStatusName()));
		}
		if (filter.getPreStatus() != null && filter.getPreStatus().trim().length() > 0) {
			filters.add(Filter.create("preStatus", filter.getPreStatus()));
		}
		if (filter.getPreStatusName() != null && filter.getPreStatusName().trim().length() > 0) {
			filters.add(Filter.create("preStatusName", filter.getPreStatusName()));
		}
		if (filter.getStageId() != null) {
			filters.add(Filter.create("stageId", filter.getStageId()));
		}
		if (filter.getTransitionStageId() != null) {
			filters.add(Filter.create("transitionStageId", filter.getTransitionStageId()));
		}
		if (filter.getStageResult() != null) {
			filters.add(Filter.create("stageResult", filter.getStageResult()));
		}
		if (filter.getReasonCode() != null) {
			filters.add(Filter.create("reasonCode", filter.getReasonCode()));
		}
	}

	public void view() {
		curMode = VIEW_MODE;
	}

	public void add() {
		curMode = NEW_MODE;
		newTransition = new ApplicationFlowTransition();
		newTransition.setFlowId(applicationFlow.getId());
	}

	public void edit() {
		try {
			newTransition = (ApplicationFlowTransition) _activeTransition.clone();
		} catch (CloneNotSupportedException e) {
			logger.error("", e);
			newTransition = _activeTransition;
		}
		curMode = EDIT_MODE;
	}

	public void delete() {
		try {
			_applicationDao.deleteApplicationFlowTransition(userSessionId, _activeTransition);

			String msg = FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.App", "flow_transition_deleted",
			        "(id = " + _activeTransition.getId() + ")");

			_activeTransition = _itemSelection.removeObjectFromList(_activeTransition);
			if (_activeTransition == null) {
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
				newTransition = _applicationDao.addApplicationFlowTransition(userSessionId, newTransition);
				_itemSelection.addNewObjectToList(newTransition);
			} else {
				newTransition = _applicationDao.editApplicationFlowTransition(userSessionId, newTransition);
				_transitionSource.replaceObject(_activeTransition, newTransition);
			}
			_activeTransition = newTransition;
			curMode = VIEW_MODE;

			FacesUtils.addMessageInfo(FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.App",
			        "flow_transition_saved"));

		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void close() {
		curMode = VIEW_MODE;
	}

	public ApplicationFlowTransition getNewTransition() {
		if (newTransition == null) {
			newTransition = new ApplicationFlowTransition();
		}
		return newTransition;
	}

	public void setNewTransition(ApplicationFlowTransition newTransition) {
		this.newTransition = newTransition;
	}

	public List<SelectItem> getEventTypes() {
		return getDictUtils().getLov(LovConstants.EVENT_TYPES);
	}

	public List<SelectItem> getStages() {
		List<SelectItem> allStages = new ArrayList<SelectItem>();
		try {
			SelectionParams params = new SelectionParams();
			List<Filter> filters = new ArrayList<Filter>();
			if (applicationFlow != null) {
				Filter paramFilter = new Filter();
				paramFilter.setElement("flowId");
				paramFilter.setOp(Operator.eq);
				paramFilter.setValue(applicationFlow.getId());
				filters.add(paramFilter);
			}
			params.setFilters(filters.toArray(new Filter[filters.size()]));
			params.setRowIndexEnd(-1);
			ApplicationFlowStage[] stages = _applicationDao.getApplicationFlowStages(userSessionId, params);
			for (ApplicationFlowStage stage : stages) {
				allStages.add(new SelectItem(stage.getId(), stage.getStatusRejectLabel(getDictUtils().getAllArticlesDesc())));
			}
		} catch (Exception e) {
			logger.error("", e);
			if (e.getMessage().indexOf(SystemConstants.INSUFFICIENT_PRIVILEGES_ERROR) < 0) {
				FacesUtils.addMessageError(e);
			}
		}
		return allStages;
	}
	
	public List<SelectItem> getStageResults(){
		List<SelectItem> result = getDictUtils().getLov(LovConstants.RES_APPLICATION_STAGE);
		return result;
	}

	public List<SelectItem> getReasonCodes() {
		return getDictUtils().getLov(LovConstants.APPL_TRANSITION_REASON_CODES);
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
