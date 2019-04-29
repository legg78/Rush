package ru.bpc.sv2.ui.stoplist;

import java.util.ArrayList;

import java.util.List;

import javax.faces.bean.ManagedBean;
import javax.faces.bean.RequestScoped;

import org.richfaces.model.selection.SimpleSelection;

import org.ajax4jsf.model.KeepAlive;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.stoplist.StoplistCardEntry;
import ru.bpc.sv2.ui.navigation.Menu;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.DictUtils;
import ru.bpc.sv2.ui.utils.TableRowSelection;
import util.auxil.ManagedBeanWrapper;

@RequestScoped
@KeepAlive
@ManagedBean(name = "MbStoplistCardSearch")
public class MbStoplistCardSearch extends AbstractBean {
	private static final long serialVersionUID = 1L;

	private StoplistCardEntry _activeEntry;
	private transient DictUtils dictUtils;
	private StoplistCardEntry filter;
	private List<Filter> filters;
	private String backLink;
	private boolean searching;
	private boolean showModal;
	private boolean selectMode;
	private MbStoplistCard stoplistBean;
	private boolean bottomMode;
	private int rowsNum = 20;

	private final DaoDataModel<StoplistCardEntry> _entriesSource;

	private final TableRowSelection<StoplistCardEntry> _itemSelection;

	public MbStoplistCardSearch() {
		bottomMode = false;
		stoplistBean = (MbStoplistCard) ManagedBeanWrapper.getManagedBean("MbStoplistCard");

		Menu menu = (Menu) ManagedBeanWrapper.getManagedBean("menu");
		if (!menu.isKeepState()) {
			stoplistBean.setTabName("");
		} else {
			_activeEntry = stoplistBean.getStoplistCardEntry();
			backLink = stoplistBean.getBackLink();
			searching = stoplistBean.isSearching();
		}

		_entriesSource = new DaoDataModel<StoplistCardEntry>() {
			private static final long serialVersionUID = 1L;

			@Override
			protected StoplistCardEntry[] loadDaoData(SelectionParams params) {
				if (!isSearching())
					return new StoplistCardEntry[0];
				setFilters();
				params.setFilters(filters.toArray(new Filter[filters.size()]));
				// TODO invoke appropriate dao methods
				// return _processDao.getProcesses( userSessionId, params );
				return new StoplistCardEntry[0];
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (!isSearching())
					return 0;
				setFilters();
				params.setFilters(filters.toArray(new Filter[filters.size()]));

				// return _processDao.getProcessesCount( userSessionId, params
				// );
				return 0;
			}
		};

		if (_activeEntry != null) {

			SimpleSelection selection = new SimpleSelection();
			selection.addKey(_activeEntry.getModelId());
			_itemSelection = new TableRowSelection<StoplistCardEntry>(selection, _entriesSource);
			setInfo();
		} else {
			_itemSelection = new TableRowSelection<StoplistCardEntry>(null, _entriesSource);
		}
	}

	public DaoDataModel<StoplistCardEntry> getStoplistEntries() {
		return _entriesSource;
	}

	public StoplistCardEntry getActiveEntry() {
		return _activeEntry;
	}

	public void setActiveEntry(StoplistCardEntry activeEntry) {
		_activeEntry = activeEntry;
	}

	public SimpleSelection getItemSelection() {
		setFirstRowActive();
		return _itemSelection.getWrappedSelection();
	}

	public void setFirstRowActive() {
		if (_activeEntry == null && _entriesSource.getRowCount() > 0) {
			_entriesSource.setRowIndex(0);
			SimpleSelection selection = new SimpleSelection();
			_activeEntry = (StoplistCardEntry) _entriesSource.getRowData();
			selection.addKey(_activeEntry.getModelId());
			_itemSelection.setWrappedSelection(selection);
			stoplistBean.setStoplistCardEntry(_activeEntry);
			setInfo();
		}
	}

	public void setItemSelection(SimpleSelection selection) {
		_itemSelection.setWrappedSelection(selection);
		_activeEntry = _itemSelection.getSingleSelection();
		stoplistBean.setStoplistCardEntry(_activeEntry);
		setInfo();
	}

	public void setInfo() {
		// MbProcessFilesSearch procFileBean =
		// (MbProcessFilesSearch)ManagedBeanWrapper.getManagedBean("MbProcessFilesSearch");
		if (_activeEntry != null) {

		}
	}

	public void search() {
		setSearching(true);
		_entriesSource.flushCache();
		_activeEntry = null;
	}

	public void clearBean() {
		_entriesSource.flushCache();

		if (_activeEntry != null) {
			if (_itemSelection != null) {
				_itemSelection.unselect(_activeEntry);
			}
			_activeEntry = null;
		}

		// TODO clear dependent bean
	}

	public void setFilters() {
		List<Filter> filtersList = new ArrayList<Filter>();
		/*
		 * if (getFilter().getShortDesc() != null &&
		 * !getFilter().getShortDesc().equals("")) { Filter paramFilter = new
		 * Filter(); paramFilter.setElement("shortDesc");
		 * paramFilter.setOp(Operator.eq);
		 * paramFilter.setValue(getFilter().getShortDesc()
		 * .toUpperCase().replaceAll("[*]", "%").replaceAll("[?]", "_")););
		 * filtersList.add(paramFilter); } if (getFilter().getGroupId() != null)
		 * { Filter paramFilter = new Filter();
		 * paramFilter.setElement("groupId"); paramFilter.setOp(Operator.eq);
		 * paramFilter.setValue(getFilter().getGroupId().toString());
		 * filtersList.add(paramFilter); } if (getFilter().getContainerId() !=
		 * null) { Filter paramFilter = new Filter();
		 * paramFilter.setElement("containerId");
		 * paramFilter.setOp(Operator.eq);
		 * paramFilter.setValue(getFilter().getContainerId().toString());
		 * filtersList.add(paramFilter); }
		 */
		filters = filtersList;
	}

	public StoplistCardEntry getFilter() {
		if (filter == null)
			filter = new StoplistCardEntry();
		return filter;
	}

	public void setFilter(StoplistCardEntry filter) {
		this.filter = filter;
	}

	public List<Filter> getFilters() {
		return filters;
	}

	public void setFilters(List<Filter> filters) {
		this.filters = filters;
	}

	public String getBackLink() {
		return backLink;
	}

	public void setBackLink(String backLink) {
		this.backLink = backLink;
	}

	public boolean isShowModal() {
		return showModal;
	}

	public void setShowModal(boolean showModal) {
		this.showModal = showModal;
	}

	public boolean isSearching() {
		return searching;
	}

	public void setSearching(boolean searching) {
		this.searching = searching;
		stoplistBean.setSearching(searching);
	}

	public String cancelSelect() {
		return backLink;
	}

	public boolean isSelectMode() {
		return selectMode;
	}

	public void setSelectMode(boolean selectMode) {
		this.selectMode = selectMode;
	}

	public String addProcess() {

		setSelectMode(true);
		Menu menu = (Menu) ManagedBeanWrapper.getManagedBean("menu");
		menu.setKeepState(true);
		clearState();
		search();
		return "prc_processes"; // TODO replace with appropriate path
	}

	public void clearState() {
		if (_itemSelection.getWrappedSelection() != null) {
			_itemSelection.clearSelection();
		}
	}

	public boolean isBottomMode() {
		return bottomMode;
	}

	public void setBottomMode(boolean bottomMode) {
		this.bottomMode = bottomMode;
	}

	public String selectProcess() {

		return backLink;
	}

	public int getRowsNum() {
		return rowsNum;
	}

	public void setRowsNum(int rowsNum) {
		this.rowsNum = rowsNum;
	}

    @Override
    public void clearFilter() {
        //do nothing
    }

    public DictUtils getDictUtils() {
		if (dictUtils == null) {
			dictUtils = (DictUtils) ManagedBeanWrapper.getManagedBean("DictUtils");
		}
		return dictUtils;
	}
}
