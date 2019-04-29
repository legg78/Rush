package ru.bpc.sv2.ui.fcl.cycles;

import java.util.ArrayList;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;

import ru.bpc.sv2.fcl.cycles.CycleCounter;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.CyclesDao;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.TableRowSelection;

@ViewScoped
@ManagedBean (name = "MbCycleCounters")
public class MbCycleCounters extends AbstractBean {
	private static final Logger logger = Logger.getLogger("FCL");

	private CyclesDao _cyclesDao = new CyclesDao();

	private CycleCounter _activeCycleCounter;
	private final DaoDataModel<CycleCounter> _cycleCountersSource;
	private final TableRowSelection<CycleCounter> _itemSelection;

	private CycleCounter filter;
	
	private static String COMPONENT_ID = "countersTable";
	private String tabName;
	private String parentSectionId;

	public MbCycleCounters() {
		_cycleCountersSource = new DaoDataModel<CycleCounter>() {
			@Override
			protected CycleCounter[] loadDaoData(SelectionParams params) {
				if (!searching)
					return new CycleCounter[0];
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _cyclesDao.getCycleCounters(userSessionId, params);
				} catch (Exception e) {
					logger.error("", e);
					FacesUtils.addMessageError(e);
					setDataSize(0);
					return new CycleCounter[0];
				}
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (!searching)
					return 0;
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _cyclesDao.getCycleCountersCount(userSessionId,
							params);
				} catch (Exception e) {
					logger.error("", e);
					FacesUtils.addMessageError(e);
					return 0;
				}
			}
		};

		_itemSelection = new TableRowSelection<CycleCounter>(null,
				_cycleCountersSource);
	}

	public DaoDataModel<CycleCounter> getCycleCounters() {
		return _cycleCountersSource;
	}

	public CycleCounter getActiveCycleCounter() {
		return _activeCycleCounter;
	}

	public void setActiveCycleCounter(CycleCounter activeCycleCounter) {
		_activeCycleCounter = activeCycleCounter;
	}

	public SimpleSelection getItemSelection() {
		if (_activeCycleCounter == null
				&& _cycleCountersSource.getRowCount() > 0) {
			setFirstRowActive();
		} else if (_activeCycleCounter != null
				&& _cycleCountersSource.getRowCount() > 0) {
			SimpleSelection selection = new SimpleSelection();
			selection.addKey(_activeCycleCounter.getModelId());
			_itemSelection.setWrappedSelection(selection);
			_activeCycleCounter = _itemSelection.getSingleSelection();
			setBeans();
		}
		return _itemSelection.getWrappedSelection();
	}

	public void setItemSelection(SimpleSelection selection) {
		_itemSelection.setWrappedSelection(selection);
		_activeCycleCounter = _itemSelection.getSingleSelection();

		if (_activeCycleCounter != null) {
			setBeans();
		}
	}

	public void setFirstRowActive() {
		_cycleCountersSource.setRowIndex(0);
		SimpleSelection selection = new SimpleSelection();
		_activeCycleCounter = (CycleCounter) _cycleCountersSource.getRowData();
		selection.addKey(_activeCycleCounter.getModelId());
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
		_cycleCountersSource.flushCache();
		_itemSelection.clearSelection();
		_activeCycleCounter = null;
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
			paramFilter.setValue(filter.getObjectId().toString());
			filters.add(paramFilter);
		}
		
		if (filter.getCycleType() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("cycleType");
			paramFilter.setValue(filter.getCycleType());
			filters.add(paramFilter);
		}
		
		if (filter.getInstId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("instId");
			paramFilter.setValue(filter.getInstId().toString());
			filters.add(paramFilter);
		}
	}

	public CycleCounter getFilter() {
		if (filter == null)
			filter = new CycleCounter();
		return filter;
	}

	public void setFilter(CycleCounter filter) {
		this.filter = filter;
	}

	public void cancel() {
		_activeCycleCounter = null;
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
