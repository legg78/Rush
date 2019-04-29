package ru.bpc.sv2.ui.process.monitoring;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.OperationDao;
import ru.bpc.sv2.operations.EntryStat;
import ru.bpc.sv2.ui.utils.*;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import java.text.DateFormat;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.List;
import java.util.Map;

@ViewScoped
@ManagedBean (name = "MbEntriesStat")
public class MbEntriesStat extends AbstractBean {
	private OperationDao _operationsDAO = new OperationDao();

	private final DaoDataModel<EntryStat> _processStatSource;

	private final TableRowSelection<EntryStat> _processStatSelection;
	private static final Logger logger = Logger.getLogger("PROCESSES");
	private EntryStat activeEntryStat;
	
	private static String COMPONENT_ID = "statTable";
	private String tabName;
	private String parentSectionId;

	private boolean groupByTransType;
	private boolean groupByAccountType;
	private boolean groupByCurrency;
	private boolean groupByBalanceType;
	private boolean groupByAmountPurpose;
	
	private Map<String, Object> params;
	private EntryStat filter;
	
	public MbEntriesStat() {
		DateFormat df = DateFormat.getInstance();
		df.setCalendar(Calendar.getInstance());
		groupByCurrency = true;

		_processStatSource = new DaoDataListAllModel<EntryStat>(logger) {
			@Override
			protected List<EntryStat> loadDaoListData(SelectionParams params) {
				if (!searching)	return null;
				try {
					setFilters();
                    params.setFilters(filters);
                    if (MbEntriesStat.this.params.get("sessionFileId") != null) {
                        return _operationsDAO.getEntriesStatsFiles(userSessionId, params);
                    } else {
                        return _operationsDAO.getEntriesStatsLogs(userSessionId, params);
                    }
				} catch (Exception e) {
					setDataSize(0);
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return null;
			}
		};
		_processStatSelection = new TableRowSelection<EntryStat>(null, _processStatSource);
	}

	public DaoDataModel<EntryStat> getStats() {
		return _processStatSource;
	}

	public SimpleSelection getItemSelection() {
		if (activeEntryStat == null && _processStatSource.getRowCount() > 0) {
			_processStatSource.setRowIndex(0);
			SimpleSelection selection = new SimpleSelection();
			activeEntryStat = (EntryStat) _processStatSource.getRowData();
			selection.addKey(activeEntryStat.getModelId());
			_processStatSelection.setWrappedSelection(selection);
		}
		return _processStatSelection.getWrappedSelection();
	}

	public void setItemSelection(SimpleSelection selection) {
		_processStatSelection.setWrappedSelection(selection);
		activeEntryStat = _processStatSelection.getSingleSelection();
	}

	public void setFilters() {
		List<Filter> filtersList = new ArrayList<Filter>();
		/*external parameters (from operation Stat)*/
		Long sessionId = (Long)params.get("sessionId");
		if (sessionId != null) {
			filtersList.add(new Filter("sessionId", sessionId));
		}
		sessionId = (Long)params.get("sessionFileId");
		if (sessionId != null) {
			filtersList.add(new Filter("sessionFileId", sessionId));
		}
		String param = (String)params.get("status");
		if (param != null) {
			filtersList.add(new Filter("status", param));
		}
		param = (String)params.get("operType");
		if (param != null) {
			filtersList.add(new Filter("operType", param));
		}
		param = (String)params.get("msgType");
		if (param != null) {
			filtersList.add(new Filter("msgType", param));
		}
		param = (String)params.get("sttlType");
		if (param != null) {
			filtersList.add(new Filter("sttlType", param));
		}
		param = (String)params.get("currency");
		if (param != null) {
			filtersList.add(new Filter("currency", param));
			groupByCurrency = true;
		}
		Boolean boolParam = (Boolean)params.get("reversal");
		if (boolParam != null) {
			filtersList.add(new Filter("reversal", boolParam));
		}
		
		/*internal filter parameters*/
		if (getFilter().getAccountType() != null && getFilter().getAccountType().trim().length() > 0) {
			filtersList.add(new Filter("accountType", getFilter().getAccountType()));
		}
		if (getFilter().getTransType() != null && getFilter().getTransType().trim().length() > 0) {
			filtersList.add(new Filter("transType", getFilter().getTransType()));
		}
		if (getFilter().getAmountPurpose() != null && getFilter().getAmountPurpose().trim().length() > 0) {
			filtersList.add(new Filter("amountPurpose", getFilter().getAmountPurpose()));
		}
		if (getFilter().getBalanceType() != null && getFilter().getBalanceType().trim().length() > 0) {
			filtersList.add(new Filter("balanceType", getFilter().getBalanceType()));
		}
		if (getFilter().getCurrency() != null && getFilter().getCurrency().trim().length() > 0) {
			filtersList.add(new Filter("currency", getFilter().getCurrency()));
		}
		/*groupping*/
		List<String> groupByResultList = new ArrayList<String>();
		List<String> groupByList = new ArrayList<String>();
		if (groupByAccountType) {
			groupByList.add("accountType");
			groupByResultList.add("accountType");
		} else {
			groupByResultList.add("null accountType");
		}
		if (groupByAmountPurpose) {
			groupByList.add("amountPurpose");
			groupByResultList.add("amountPurpose");
		} else {
			groupByResultList.add("null amountPurpose");
		}
		if (groupByTransType) {
			groupByList.add("transType");
			groupByResultList.add("transType");
		} else {
			groupByResultList.add("null transType");
		}
		if (groupByBalanceType) {
			groupByList.add("balanceType");
			groupByResultList.add("balanceType");
		} else {
			groupByResultList.add("null balanceType");
		}
		if (groupByCurrency) {
			groupByList.add("currency");
			groupByResultList.add("currency");
		} else {
			groupByResultList.add("null currency");
		}
		filtersList.add(new Filter("groupBy", null, groupByList));
		filtersList.add(new Filter("groupByResult", null, groupByResultList));
		filters = filtersList;
	}

	public void search() {
		_processStatSource.flushCache();
		activeEntryStat = null;
		searching = true;
	}

	public void clear() {
        _processStatSource.flushCache();
        activeEntryStat = null;
        clearFilter();
    }

	@Override
	public void clearFilter() {
		params = null;
		searching = false;
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
	
	public boolean isGroupByCurrency() {
		return groupByCurrency;
	}

	public void setGroupByCurrency(boolean groupByCurrency) {
		this.groupByCurrency = groupByCurrency;
	}

	public boolean isGroupByTransType() {
		return groupByTransType;
	}

	public void setGroupByTransType(boolean groupByTransType) {
		this.groupByTransType = groupByTransType;
	}

	public boolean isGroupByAccountType() {
		return groupByAccountType;
	}

	public void setGroupByAccountType(boolean groupByAccountType) {
		this.groupByAccountType = groupByAccountType;
	}

	public boolean isGroupByBalanceType() {
		return groupByBalanceType;
	}

	public void setGroupByBalanceType(boolean groupByBalanceType) {
		this.groupByBalanceType = groupByBalanceType;
	}

	public boolean isGroupByAmountPurpose() {
		return groupByAmountPurpose;
	}

	public void setGroupByAmountPurpose(boolean groupByAmountPurpose) {
		this.groupByAmountPurpose = groupByAmountPurpose;
	}

	public void setFilter(Map<String, Object> params) {
		this.params = params;
	}

	public EntryStat getFilter() {
		if (filter == null) {
			filter = new EntryStat();
		}
		return filter;
	}

	public void setFilter(EntryStat filter) {
		this.filter = filter;
	}

    public Map<String, Object> getParams() {
        return params;
    }
}
