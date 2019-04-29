package ru.bpc.sv2.logic.utility.db;

import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SortElement;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class QueryParams {
	private String userName;

	private QueryRange _range;

	private boolean _limitByInst;
	private boolean _limitByAgent;
	private Map<String, Boolean> _limitByAttr;

	private List<Filter> _filters;
	private List<SortElement> _sorting;
	private String _lang;
	private String limitation;
	private Integer threshold;
	private Long startWith;
	private String module;
	private int networkId;
	private String tableSuffix;

	private QueryParams() {
		_limitByAttr = new HashMap<String, Boolean>();

		_filters = new ArrayList<Filter>();
		_sorting = new ArrayList<SortElement>();
		_lang = null;
	}

	public QueryParams(String userName, QueryRange range, String lang, boolean limitByInst,
					   boolean limitByAgent, Map<String, Boolean> limitByAttr, String limitation, Integer threshold,
					   Long startWith) {
		this();

		setUserName(userName);
		setRange(range);
		setLang(lang);
		setLimitByInst(limitByInst);
		setLimitByAgent(limitByAgent);
		setLimitation(limitation);
		setThreshold(threshold);
		setStartWith(startWith);
		if (limitByAttr != null) {
			setLimitByAttr(limitByAttr);
		}
	}

	public QueryParams(String userName, QueryRange range, String lang, boolean limitByInst,
					   boolean limitByAgent, Map<String, Boolean> limitByAttr,
					   Filter[] filters, SortElement[] sorting, String limitation, Integer threshold, Long startWith,
					   String module, int networkId, String tableSuffix) {
		this();

		setUserName(userName);
		setRange(range);
		setLang(lang);
		setLimitByInst(limitByInst);
		setLimitByAgent(limitByAgent);
		setLimitation(limitation);
		setThreshold(threshold);
		setStartWith(startWith);
		if (limitByAttr != null) {
			setLimitByAttr(limitByAttr);
		}

		addFilters(filters);
		addSorting(sorting);
		this.module = module;
		this.networkId = networkId;
		setTableSuffix(tableSuffix);
	}

	public String getUserName() {
		return userName;
	}

	public void setUserName(String userName) {
		this.userName = userName;
	}

	public QueryRange getRange() {
		return _range;
	}

	public void setRange(QueryRange range) {
		if (range == null) {
			throw new NullPointerException("Range should not be null");
		}

		_range = range;
	}

	public boolean isLimitByInst() {
		return _limitByInst;
	}

	public void setLimitByInst(boolean limitByInst) {
		_limitByInst = limitByInst;
	}

	public boolean isLimitByAgent() {
		return _limitByAgent;
	}

	public void setLimitByAgent(boolean limitByAgent) {
		_limitByAgent = limitByAgent;
	}

	public Map<String, Boolean> getLimitByAttr() {
		return _limitByAttr;
	}

	public void setLimitByAttr(Map<String, Boolean> limitByAttr) {
		if (_limitByAttr == null) {
			throw new NullPointerException("Filtering attributes map should not be null");
		}

		_limitByAttr = limitByAttr;
	}

	public List<SortElement> getSorting() {
		return _sorting;
	}

	public void setSorting(List<SortElement> sorting) {
		if (sorting == null) {
			throw new NullPointerException("Sorting params array should not be null");
		}

		_sorting = sorting;
	}

	public void addSorting(SortElement[] sorting) {
		if (sorting == null) {
			return;
		}

		for (SortElement elem : sorting) {
			getSorting().add(elem);
		}
	}

	public List<Filter> getFilters() {
		return _filters;
	}

	public void setFilters(List<Filter> filters) {

		if (filters == null) {
			throw new NullPointerException("Filtering params array should not be null");
		}

		_filters = filters;
	}

	public void addFilters(Filter[] filters) {
		if (filters == null) {
			return;
		}

		for (Filter elem : filters) {
			getFilters().add(elem);
		}
	}

	public String getLang() {
		return _lang;
	}

	public void setLang(String lang) {
		_lang = lang;
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

	public String getTableSuffix() {
		return tableSuffix;
	}

	public void setTableSuffix(String tableSuffix) {
		this.tableSuffix = tableSuffix;
	}
}
