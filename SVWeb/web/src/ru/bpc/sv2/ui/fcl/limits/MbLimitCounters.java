package ru.bpc.sv2.ui.fcl.limits;

import java.util.ArrayList;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;

import ru.bpc.sv2.fcl.limits.LimitCounter;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.LimitsDao;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.TableRowSelection;

@ViewScoped
@ManagedBean (name = "MbLimitCounters")
public class MbLimitCounters extends AbstractBean {
	private static final Logger logger = Logger.getLogger("FCL");

	private LimitsDao _limitsDao = new LimitsDao();

	private LimitCounter _activeLimitCounter;
	private final DaoDataModel<LimitCounter> _limitCountersSource;
	private final TableRowSelection<LimitCounter> _itemSelection;

	private LimitCounter filter;
	
	private static String COMPONENT_ID = "countersTable";
	private String tabName;
	private String parentSectionId;
	
		public MbLimitCounters() {
		_limitCountersSource = new DaoDataModel<LimitCounter>() {
			@Override
			protected LimitCounter[] loadDaoData(SelectionParams params) {
				if (!searching)
					return new LimitCounter[0];
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _limitsDao.getLimitCountersCur(userSessionId, params);
				} catch (Exception e) {
					logger.error("", e);
					FacesUtils.addMessageError(e);
					setDataSize(0);
					return new LimitCounter[0];
				}
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (!searching)
					return 0;
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _limitsDao.getLimitCountersCurCount(userSessionId,
							params);
				} catch (Exception e) {
					logger.error("", e);
					FacesUtils.addMessageError(e);
					return 0;
				}
			}
		};

		_itemSelection = new TableRowSelection<LimitCounter>(null,
				_limitCountersSource);
	}

	public DaoDataModel<LimitCounter> getLimitCounters() {
		return _limitCountersSource;
	}

	public LimitCounter getActiveLimitCounter() {
		return _activeLimitCounter;
	}

	public void setActiveLimitCounter(LimitCounter activeLimitCounter) {
		_activeLimitCounter = activeLimitCounter;
	}

	public SimpleSelection getItemSelection() {
		if (_activeLimitCounter == null
				&& _limitCountersSource.getRowCount() > 0) {
			setFirstRowActive();
		} else if (_activeLimitCounter != null
				&& _limitCountersSource.getRowCount() > 0) {
			SimpleSelection selection = new SimpleSelection();
			selection.addKey(_activeLimitCounter.getModelId());
			_itemSelection.setWrappedSelection(selection);
			_activeLimitCounter = _itemSelection.getSingleSelection();
			setBeans();
		}
		return _itemSelection.getWrappedSelection();
	}

	public void setItemSelection(SimpleSelection selection) {
		_itemSelection.setWrappedSelection(selection);
		_activeLimitCounter = _itemSelection.getSingleSelection();

		if (_activeLimitCounter != null) {
			setBeans();
		}
	}

	public void setFirstRowActive() {
		_limitCountersSource.setRowIndex(0);
		SimpleSelection selection = new SimpleSelection();
		_activeLimitCounter = (LimitCounter) _limitCountersSource.getRowData();
		selection.addKey(_activeLimitCounter.getModelId());
		_itemSelection.setWrappedSelection(selection);

		setBeans();
	}

	/**
	 * Sets data for backing beans used by dependent pages
	 */
	public void setBeans() {

	}

	public void search() {
		clearBean();
		searching = true;
	}

	public void clearBean() {
		_limitCountersSource.flushCache();
		_itemSelection.clearSelection();
		_activeLimitCounter = null;
	}
	
	public void setFilters() {
		getFilter();
		filters = new ArrayList<Filter>();

		Filter paramFilter;
		if (filter.getId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("id");
			paramFilter.setValue(filter.getId().toString());
			filters.add(paramFilter);
		}
		
		if (filter.getEntityType() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("entityType");
			paramFilter.setValue(filter.getEntityType());
			filters.add(paramFilter);
		}
		
		if (filter.getObjectId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("objectId");
			paramFilter.setValue(filter.getObjectId());
			filters.add(paramFilter);
		}
		
		if (filter.getLimitType() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("cycleType");
			paramFilter.setValue(filter.getLimitType());
			filters.add(paramFilter);
		}
		
		if (filter.getInstId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("instId");
			paramFilter.setValue(filter.getInstId());
			filters.add(paramFilter);
		}
	}

	public LimitCounter getFilter() {
		if (filter == null)
			filter = new LimitCounter();
		return filter;
	}

	public void setFilter(LimitCounter filter) {
		this.filter = filter;
	}

	public void cancel() {
		_activeLimitCounter = null;
	}

	public void clearFilter() {
		filter = null;
		clearBean();
		searching = false;
		clearSectionFilter();
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
