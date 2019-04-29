package ru.bpc.sv2.ui.fraud;

import java.util.ArrayList;
import java.util.List;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.RequestScoped;
import javax.faces.model.SelectItem;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;

import org.ajax4jsf.model.KeepAlive;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.fraud.CaseEvent;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.FraudDao;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.TableRowSelection;

@RequestScoped
@KeepAlive
@ManagedBean (name = "MbCaseEvents")
public class MbCaseEvents extends AbstractBean {
	private static final Logger logger = Logger.getLogger("FRAUD_PREVENTION");

	private FraudDao _fraudDao = new FraudDao();

	private CaseEvent filter;
	private CaseEvent _activeCaseEvent;
	private CaseEvent newCaseEvent;

	private final DaoDataModel<CaseEvent> _caseEventsSource;
	private final TableRowSelection<CaseEvent> _itemSelection;
	
	private static String COMPONENT_ID = "caseEventsTable";
	private String tabName;
	private String parentSectionId;
	
	public MbCaseEvents() {
		

		_caseEventsSource = new DaoDataModel<CaseEvent>() {
			@Override
			protected CaseEvent[] loadDaoData(SelectionParams params) {
				if (!searching) {
					return new CaseEvent[0];
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _fraudDao.getCaseEvents(userSessionId, params);
				} catch (Exception e) {
					setDataSize(0);
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return new CaseEvent[0];
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (!searching) {
					return 0;
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _fraudDao.getCaseEventsCount(userSessionId, params);
				} catch (Exception e) {
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return 0;
			}
		};

		_itemSelection = new TableRowSelection<CaseEvent>(null, _caseEventsSource);
	}

	public DaoDataModel<CaseEvent> getCaseEvents() {
		return _caseEventsSource;
	}

	public CaseEvent getActiveCaseEvent() {
		return _activeCaseEvent;
	}

	public void setActiveCaseEvent(CaseEvent activeCaseEvent) {
		_activeCaseEvent = activeCaseEvent;
	}

	public SimpleSelection getItemSelection() {
		try {
			if (_activeCaseEvent == null && _caseEventsSource.getRowCount() > 0) {
				setFirstRowActive();
			} else if (_activeCaseEvent != null && _caseEventsSource.getRowCount() > 0) {
				SimpleSelection selection = new SimpleSelection();
				selection.addKey(_activeCaseEvent.getModelId());
				_itemSelection.setWrappedSelection(selection);
				_activeCaseEvent = _itemSelection.getSingleSelection();
			}
		} catch (Exception e) {
			logger.error("", e);
			FacesUtils.addMessageError(e);
		}
		return _itemSelection.getWrappedSelection();
	}

	public void setFirstRowActive() {
		_caseEventsSource.setRowIndex(0);
		SimpleSelection selection = new SimpleSelection();
		_activeCaseEvent = (CaseEvent) _caseEventsSource.getRowData();
		selection.addKey(_activeCaseEvent.getModelId());
		_itemSelection.setWrappedSelection(selection);

		setBeans();
	}

	public void setItemSelection(SimpleSelection selection) {
		_itemSelection.setWrappedSelection(selection);
		_activeCaseEvent = _itemSelection.getSingleSelection();
		if (_activeCaseEvent != null) {
			setBeans();
		}
	}

	public void search() {
		clearState();
		searching = true;
	}

	public void setBeans() {

	}

	public void clearBeansStates() {

	}

	public void fullCleanBean() {
		clearFilter();
	}
	
	public void clearFilter() {
		filter = null;

		clearState();
		searching = false;
	}

	public CaseEvent getFilter() {
		if (filter == null) {
			filter = new CaseEvent();
		}
		return filter;
	}

	public void setFilter(CaseEvent filter) {
		this.filter = filter;
	}

	private void setFilters() {
		getFilter();
		filters = new ArrayList<Filter>();

		Filter paramFilter = new Filter();
		paramFilter.setElement("lang");
		paramFilter.setValue(userLang);
		filters.add(paramFilter);

		if (filter.getId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("id");
			paramFilter.setValue(filter.getId());
			filters.add(paramFilter);
		}
		if (filter.getCaseId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("caseId");
			paramFilter.setValue(filter.getCaseId());
			filters.add(paramFilter);
		}
		if (filter.getEventType() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("eventType");
			paramFilter.setValue(filter.getEventType());
			filters.add(paramFilter);
		}
		if (filter.getRiskThreshold() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("riskThreshold");
			paramFilter.setValue(filter.getRiskThreshold());
			filters.add(paramFilter);
		}
	}

	public void add() {
		newCaseEvent = new CaseEvent();
		newCaseEvent.setCaseId(getFilter().getCaseId());
		curMode = NEW_MODE;
	}

	public void edit() {
		try {
			newCaseEvent = (CaseEvent) _activeCaseEvent.clone();
		} catch (CloneNotSupportedException e) {
			logger.error("", e);
			newCaseEvent = _activeCaseEvent;
		}
		curMode = EDIT_MODE;
	}

	public void save() {
		try {
			if (isNewMode()) {
				newCaseEvent = _fraudDao.addCaseEvent(userSessionId, newCaseEvent);
				_itemSelection.addNewObjectToList(newCaseEvent);
			} else if (isEditMode()) {
				newCaseEvent = _fraudDao.modifyCaseEvent(userSessionId, newCaseEvent);
				_caseEventsSource.replaceObject(_activeCaseEvent, newCaseEvent);
			}
			_activeCaseEvent = newCaseEvent;
			setBeans();
			curMode = VIEW_MODE;
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void delete() {
		try {
			_fraudDao.removeCaseEvent(userSessionId, _activeCaseEvent);
			_activeCaseEvent = _itemSelection.removeObjectFromList(_activeCaseEvent);

			if (_activeCaseEvent == null) {
				clearState();
			} else {
				setBeans();
			}

			curMode = VIEW_MODE;
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void cancel() {
		curMode = VIEW_MODE;
	}

	public CaseEvent getNewCaseEvent() {
		if (newCaseEvent == null) {
			newCaseEvent = new CaseEvent();
		}
		return newCaseEvent;
	}

	public void setNewCaseEvent(CaseEvent newCaseEvent) {
		this.newCaseEvent = newCaseEvent;
	}

	public void clearState() {
		_itemSelection.clearSelection();
		_activeCaseEvent = null;
		_caseEventsSource.flushCache();

		clearBeansStates();
	}

	public List<SelectItem> getEventTypes() {
		return getDictUtils().getLov(LovConstants.FRAUD_EVENT_TYPES);
	}
	
	public List<SelectItem> getResponseCodes() {
		return getDictUtils().getLov(LovConstants.RESPONSE_CODES);
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
