package ru.bpc.sv2.invocation;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

public class SelectionParams implements Serializable {

	private static final long serialVersionUID = 1L;


	private int _rowIndexStart = 0;
	private int _rowIndexEnd = 0;
	private SortElement[] _sortElement = null;
	private Filter[] _filters = null;
	private String limitation = null;
	private Integer threshold;
	private Long startWith;
	private String privilege;
	private String module;
	private int networkId;
	private String table;
	private String tableSuffix;
	private String user;
	private Integer rowCount = null;

	public String getTable() {
		return table;
	}

	public void setTable(String table) {
		this.table = table;
	}

	public int getNetworkId() {
		return networkId;
	}

	public void setNetworkId(int networkId) {
		this.networkId = networkId;
	}

	public String getModule() {
		return module;
	}

	public void setModule(String module) {
		this.module = module;
	}

	public SelectionParams(List<Filter> lFilters) {
		_filters = lFilters.toArray(new Filter[lFilters.size()]);
	}

	public SelectionParams(List<Filter> lFilters, List<SortElement> lSortElement) {
		_filters = lFilters.toArray(new Filter[lFilters.size()]);
		_sortElement = lSortElement.toArray(new SortElement[lSortElement.size()]);
	}

	public SelectionParams(int _rowIndexStart, int _rowIndexEnd, Filter... _filters) {
		this._rowIndexStart = _rowIndexStart;
		this._rowIndexEnd = _rowIndexEnd;
		this._filters = _filters;
	}

	public SelectionParams(int _rowIndexStart, int _rowIndexEnd, List<Filter> lFilters) {
		this._rowIndexStart = _rowIndexStart;
		this._rowIndexEnd = _rowIndexEnd;
		_filters = lFilters.toArray(new Filter[lFilters.size()]);
	}

	public SelectionParams(int _rowIndexStart, int _rowIndexEnd, List<Filter> lFilters, List<SortElement> lSortElement) {
		this._rowIndexStart = _rowIndexStart;
		this._rowIndexEnd = _rowIndexEnd;
		_filters = lFilters.toArray(new Filter[lFilters.size()]);
		_sortElement = lSortElement.toArray(new SortElement[lSortElement.size()]);
	}

	public SelectionParams(Filter... filters) {
		_filters = filters;
	}

	public SelectionParams(Filter filter) {
		_filters = new Filter[]{filter};
	}

	public SelectionParams() {
	}

	public int getRowIndexStart() {
		return _rowIndexStart;
	}

	public void setRowIndexStart(int rowIndexStart) {
		_rowIndexStart = rowIndexStart;
	}

	public int getRowIndexEnd() {
		return _rowIndexEnd;
	}

	public void setRowIndexEnd(int rowIndexEnd) {
		_rowIndexEnd = rowIndexEnd;
	}

	public SelectionParams setRowIndexAll() {
		setRowIndexStart(0);
		setRowIndexEnd(Integer.MAX_VALUE);
		return this;
	}

	public SelectionParams setSortElement(List<SortElement> lsortElement) {
		return setSortElement(lsortElement.toArray(new SortElement[lsortElement.size()]));
	}

	public SelectionParams setSortElement(SortElement... sortElement) {
		_sortElement = sortElement;
		return this;
	}

	public SortElement[] getSortElement() {
		return _sortElement;
	}

	public Filter[] getFilters() {
		return _filters;
	}

	public void setFilters(Filter... filters) {
		_filters = filters;
	}

	public void setFilters(List<Filter> filters) {
		setFilters(filters.toArray(new Filter[filters.size()]));
	}

	public String getLimitation() {
		return limitation;
	}

	public void setLimitation(String limitation) {
		this.limitation = limitation;
	}

	public Integer getThreshold() {
		return threshold;
	}

	public void setThreshold(Integer threshold) {
		this.threshold = threshold;
	}

	public Long getStartWith() {
		return startWith;
	}

	public void setStartWith(Long startWith) {
		this.startWith = startWith;
	}

	public String getPrivilege() {
		return privilege;
	}

	public void setPrivilege(String privilege) {
		this.privilege = privilege;
	}

	public String getUser() {
		return user;
	}

	public void setUser(String user) {
		this.user = user;
	}

	public String getTableSuffix() {
		return tableSuffix;
	}

	public void setTableSuffix(String tableSuffix) {
		this.tableSuffix = tableSuffix;
	}

	/**
	 * Build a new SelectionParams object.</br>
	 * Benefit of this method is that we don't need to bother about Filter objects.
	 * All what we need, it's just put all the element names and values together as a method parameter.
	 * It's much easy just to take a look at how the method works:
	 * </br>
	 * <code>
	 * int id = 3;</br>
	 * float amount = 2.5f;</br>
	 * boolean exist = true;</br>
	 * SelectionParams sp = SelectionParams.build("ID", id, "AMOUNT", amount, "IS_EXIST", exit);</br>
	 * </code>
	 */
	public static SelectionParams build(Object... filters) {
		return build(false, filters);
	}

	public static SelectionParams build(boolean ignoreNullValues, Object... filters) {
		if (filters.length < 2) {
			throw new IllegalArgumentException("Size of \'filters\' is less than 2");
		}
		if (filters.length % 2 != 0) {
			throw new IllegalArgumentException("Size of \'filters\' isn't even number");
		}
		int filtersCount = filters.length / 2;
		List<Filter> filtersForParams = new ArrayList<Filter>(filtersCount);
		for (int i = 0; i < filtersCount; i++) {
			int elementIdx = i * 2;
			if (!(filters[elementIdx] instanceof String)) {
				throw new IllegalArgumentException("Type of all the odd elements of \'filters\' shoud be String");
			}
			String element = (String) filters[elementIdx];
			int valueIdx = elementIdx + 1;
			Object value = filters[valueIdx];
			if (value == null && ignoreNullValues) {
				continue;
			}
			Filter filter = new Filter(element, value);
			filtersForParams.add(filter);
		}
		return new SelectionParams(filtersForParams);
	}

	@SuppressWarnings("RedundantIfStatement")
	@Override
	public boolean equals(Object o) {
		if (this == o) return true;
		if (o == null || getClass() != o.getClass()) return false;

		SelectionParams that = (SelectionParams) o;

		if (_rowIndexEnd != that._rowIndexEnd) return false;
		if (_rowIndexStart != that._rowIndexStart) return false;
		if (!Arrays.equals(_filters, that._filters)) return false;
		if (!Arrays.equals(_sortElement, that._sortElement)) return false;
		if (limitation != null ? !limitation.equals(that.limitation) : that.limitation != null) return false;
		if (privilege != null ? !privilege.equals(that.privilege) : that.privilege != null) return false;
		if (startWith != null ? !startWith.equals(that.startWith) : that.startWith != null) return false;
		if (threshold != null ? !threshold.equals(that.threshold) : that.threshold != null) return false;
		if (table != null ? !table.equals(that.table) : that.table != null) return false;
		if (user != null ? !user.equals(that.user) : that.user != null) return false;
		if (tableSuffix != null ? !tableSuffix.equals(that.tableSuffix) : that.tableSuffix != null) return false;
		return true;
	}

	@Override
	public int hashCode() {
		int result = _rowIndexStart;
		result = 31 * result + _rowIndexEnd;
		result = 31 * result + (_sortElement != null ? Arrays.hashCode(_sortElement) : 0);
		result = 31 * result + (_filters != null ? Arrays.hashCode(_filters) : 0);
		result = 31 * result + (limitation != null ? limitation.hashCode() : 0);
		result = 31 * result + (threshold != null ? threshold.hashCode() : 0);
		result = 31 * result + (startWith != null ? startWith.hashCode() : 0);
		result = 31 * result + (privilege != null ? privilege.hashCode() : 0);
		result = 31 * result + (table != null ? table.hashCode() : 0);
		result = 31 * result + (user != null ? user.hashCode() : 0);
		result = 31 * result + (tableSuffix != null ? tableSuffix.hashCode() : 0);
		return result;
	}

    public Integer getRowCount() {
        return rowCount;
    }

    public void setRowCount(Integer rowCount) {
        this.rowCount = rowCount;
    }

    public boolean hasFilter(String name) {
		if (_filters == null || name == null) {
			return false;
		}

		for(Filter filter: _filters) {
			if(filter != null && name.equals(filter.getElement())) {
				return true;
			}
		}

		return false;
    }
}
