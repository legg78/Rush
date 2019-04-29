package ru.bpc.sv2.ui.administrative;

import java.util.ArrayList;
import java.util.List;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.RequestScoped;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;

import org.ajax4jsf.model.KeepAlive;
import ru.bpc.sv2.administrative.Partition;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.Filter.Operator;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.AccessManagementDao;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.TableRowSelection;

/**
 * Manage Bean for List Partition bottom tab.
 */
@RequestScoped
@KeepAlive
@ManagedBean (name = "MbPartitionsSearch")
public class MbPartitionsSearch extends AbstractBean {
	private static final long serialVersionUID = 1L;

	private static final Logger logger = Logger.getLogger("ACCESS_MANAGEMENT");

	private AccessManagementDao _acmDao = new AccessManagementDao();

	private Partition _activePartition;
//	private PmoHost newHost;

	private Partition partitionFilter;
	private List<Filter> partitionFilters;

	private boolean selectMode;

	private final DaoDataModel<Partition> _partitionsSource;

	private final TableRowSelection<Partition> _partitionSelection;

	private static String COMPONENT_ID = "bottomPartitionsTable";
	private String tabName;
	private String parentSectionId;

	public MbPartitionsSearch() {
		_partitionsSource = new DaoDataModel<Partition>() {
			private static final long serialVersionUID = 1L;

			@Override
			protected Partition[] loadDaoData(SelectionParams params) {
				if (!isSearching())
					return new Partition[0];
				try {
					setPartitionsFilters();
					params.setFilters(partitionFilters.toArray(new Filter[partitionFilters.size()]));
					return _acmDao.getPartitions(userSessionId, params);
				} catch (Exception e) {
					setDataSize(0);
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return new Partition[0];
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (!isSearching())
					return 0;
				try {
					setPartitionsFilters();
					params.setFilters(partitionFilters.toArray(new Filter[partitionFilters.size()]));
					return _acmDao.getPartitionsCount(userSessionId, params);
				} catch (Exception e) {
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return 0;
			}
		};
		_partitionSelection = new TableRowSelection<Partition>(null, _partitionsSource);
	}

	public DaoDataModel<Partition> getPartitions() {
		return _partitionsSource;
	}

	public Partition getActivePartition() {
		return _activePartition;
	}

	public void setActivePartition(Partition activePartition) {
		this._activePartition = activePartition;
	}

	public SimpleSelection getPartitionSelection() {
		if (_activePartition == null && _partitionsSource.getRowCount() > 0) {
			setFirstRowActive();
		} else if (_activePartition != null && _partitionsSource.getRowCount() > 0) {
			SimpleSelection selection = new SimpleSelection();
			selection.addKey(_activePartition.getModelId());
			_partitionSelection.setWrappedSelection(selection);
			_activePartition = _partitionSelection.getSingleSelection();
		}
		return _partitionSelection.getWrappedSelection();
	}

	public void setFirstRowActive() {
		_partitionsSource.setRowIndex(0);
		SimpleSelection selection = new SimpleSelection();
		_activePartition = (Partition) _partitionsSource.getRowData();
		selection.addKey(_activePartition.getModelId());
		_partitionSelection.setWrappedSelection(selection);
		if (_activePartition != null) {
			setInfo();
		}
	}

	public void setInfo() {

	}

	public void setPartitionSelection(SimpleSelection selection) {
		_partitionSelection.setWrappedSelection(selection);
		_activePartition = _partitionSelection.getSingleSelection();
		if (_activePartition != null) {
			setInfo();
		}
	}

	public void search() {
		clearBean();
		boolean found = false;
		if (getPartitionFilter().getTableName() != null) {
			found = true;
		}
		// if no selected providers found then we must not search for partitions
		// at all
		if (found) {
			searching = true;
		}
	}

	public void clearFilter() {
		partitionFilter = null;
		clearBean();
	}

	public void clearBean() {
		searching = false;
		curLang = userLang;
		_partitionsSource.flushCache();
		if (_partitionSelection != null) {
			_partitionSelection.clearSelection();
		}
		_activePartition = null;
	}

	public void setPartitionsFilters() {
		List<Filter> filtersList = new ArrayList<Filter>();
		if (getPartitionFilter().getTableName() != null) {
			Filter paramFilter = new Filter();
			paramFilter.setElement("tableName");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(getPartitionFilter().getTableName());
			filtersList.add(paramFilter);
		}

		partitionFilters = filtersList;
	}

	public Partition getPartitionFilter() {
		if (partitionFilter == null)
			partitionFilter = new Partition();
		return partitionFilter;
	}

	public void setPartitionFilter(Partition partitionFilter) {
		this.partitionFilter = partitionFilter;
	}

	public List<Filter> getPartitionFilters() {
		return partitionFilters;
	}

	public void setPartitionFilters(List<Filter> partitionFilters) {
		this.partitionFilters = partitionFilters;
	}

	public boolean isSelectMode() {
		return selectMode;
	}

	public void setSelectMode(boolean selectMode) {
		this.selectMode = selectMode;
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
