package ru.bpc.sv2.ui.accounts;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;
import ru.bpc.sv2.accounts.Balance;
import ru.bpc.sv2.accounts.Entry;
import ru.bpc.sv2.constants.DictNames;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.Filter.Operator;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.AccountsDao;
import ru.bpc.sv2.ui.navigation.Menu;
import ru.bpc.sv2.ui.utils.*;
import util.auxil.ManagedBeanWrapper;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.event.ValueChangeEvent;
import javax.faces.model.SelectItem;
import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.*;

@ViewScoped
@ManagedBean (name = "MbEntriesForAccount")
public class MbEntriesForAccount extends AbstractBean{
	private static final Logger logger = Logger.getLogger("ISSUING");
	
	private AccountsDao _accountsDao = new AccountsDao();
	
	DictUtils dictUtils;

    private List<Filter> filtersEntry;
	private boolean searchingEntry;
    
    private Balance filter;
    
    private Entry filterEntry;
    private Entry _activeEntry;
    private Entry newEntry;
    private String timeZone;
	private final DaoDataModel<Entry> _entriesSource;

	private final TableRowSelection<Entry> _itemSelection;

	private final DaoDataModel<Balance> _balancesSource;

	private final TableRowSelection<Balance> _balancesSelection;
	private Map<Object, Boolean> selectedList;
    private Map<Long, String> balanceTypes;
	
	private boolean selectAll = false; // auxiliary variable. Used only for correct displaying of checkboxes. 
	
	private static String COMPONENT_ID = "entriesTable";
	private String tabName;
	private String parentSectionId;
	
	public MbEntriesForAccount() {
		dictUtils = (DictUtils)ManagedBeanWrapper.getManagedBean("DictUtils");
		selectedList = new HashMap<Object, Boolean>();
        balanceTypes = new HashMap<Long, String>();
		filter = new Balance();
		
		filtersEntry = new ArrayList<Filter>();
		filterEntry = new Entry();
		
		DateFormat df = DateFormat.getInstance();
		df.setCalendar(Calendar.getInstance());
		timeZone = df.getTimeZone().getID();
		
		Menu menu = (Menu) ManagedBeanWrapper.getManagedBean("menu");
		 
		_balancesSource = new DaoDataModel<Balance>()
		{
			@Override
			protected Balance[] loadDaoData(SelectionParams params) {
				if (!searching) {
					return new Balance[0];
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					params.setRowIndexEnd(-1);

                    Balance[] res = _accountsDao.getBalances( userSessionId, params);
                    balanceTypes.clear();
                    for(Balance bal : res) {
                        balanceTypes.put(bal.getId(), bal.getBalanceType());
                    }

					return res;
				} catch (Exception e) {
					FacesUtils.addMessageError(e);
					logger.error("", e);
					setDataSize(0);
				}
				return new Balance[0];
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (!searching) {
					return 0;
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					params.setRowIndexEnd(-1);
					return _accountsDao.getBalancesCount( userSessionId, params);
				} catch (Exception e) {
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return 0;
			}
		};

		_balancesSelection = new TableRowSelection<Balance>( null, _balancesSource);
		
		_entriesSource = new DaoDataModel<Entry>()
		{
			@Override
			protected Entry[] loadDaoData(SelectionParams params) {
				if (!searchingEntry) {
					return new Entry[0];
				}
				try {
					setFiltersEntry();
					params.setFilters(filtersEntry.toArray(new Filter[filters.size()]));
					params.setRowIndexEnd(-1);
					return _accountsDao.getEntries( userSessionId, params);
				} catch (Exception e) {
					FacesUtils.addMessageError(e);
					setDataSize(0);
				}
				return new Entry[0];
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (!searchingEntry) {
					return 0;
				}
				try {
					setFiltersEntry();
					params.setFilters(filtersEntry.toArray(new Filter[filters.size()]));
					params.setRowIndexEnd(-1);
					return _accountsDao.getEntriesCount( userSessionId, params);
				} catch (Exception e) {
					FacesUtils.addMessageError(e);
				}
				return 0;
			}
		};

		_itemSelection = new TableRowSelection<Entry>( null, _entriesSource);
		
		if (!menu.isKeepState()) {
        	// if user came here from menu, we don't need to select previously selected tab
			clearFilter();		
        	clearBeansStates();
        } 
    }

    public DaoDataModel<Entry> getEntries() {
		return _entriesSource;
	}
    
    public DaoDataModel<Balance> getBalances() {
		return _balancesSource;
	}


	public Entry getActiveEntry() {
		return _activeEntry;
	}

	public void setActiveEntry(Entry activeEntry) {
		_activeEntry = activeEntry;
	}

	public SimpleSelection getItemSelection() {
		if (_activeEntry == null && _entriesSource.getRowCount() > 0) {
			setFirstRowActive();
		}
		else if (_activeEntry != null && _entriesSource.getRowCount() > 0)
		{
			SimpleSelection selection = new SimpleSelection();
			selection.addKey(_activeEntry.getModelId());
			_itemSelection.setWrappedSelection(selection);
			_activeEntry = _itemSelection.getSingleSelection();			
		}
		return _itemSelection.getWrappedSelection();
	}

	public void setFirstRowActive() {
		_entriesSource.setRowIndex(0);
		SimpleSelection selection = new SimpleSelection();
		_activeEntry = (Entry) _entriesSource.getRowData();
		selection.addKey(_activeEntry.getModelId());
		_itemSelection.setWrappedSelection(selection);
		if (_activeEntry != null) {
			setInfo();
		}
	}
	
	public void setItemSelection(SimpleSelection selection) {
		_itemSelection.setWrappedSelection( selection );
		_activeEntry = _itemSelection.getSingleSelection();
		if (_activeEntry != null) {
			setInfo();
		}
	}

	public SimpleSelection getBalancesSelection() {
		return _balancesSelection.getWrappedSelection();
	}
	
	public void setBalancesSelection(SimpleSelection selection) {
		_balancesSelection.setWrappedSelection( selection );		
	}
	
	public void setInfo() {
		
	}
	
	public void search() {
		selectAll = false;
		selectedList.clear();
        balanceTypes.clear();
		clearState();
		clearBeansStates();
		searching = true;		
	}
	
	public void searchEntries() {
		clearStateEntry();
		boolean found = false;
		if (selectedList != null && !selectedList.isEmpty()) {
			List<Balance> balances = _balancesSource.getActivePage();
			for (Balance bal : balances) {
                balanceTypes.put(bal.getId(), bal.getBalanceType());
				Boolean value = selectedList.get(bal.getModelId());
				if (Boolean.TRUE.equals(value)) {
					found = true;
				}
			}			
		}
		
		// if no selected balances found then we must not search for entries at all
		
		if (found) {
			searchingEntry = true;
		}
	}

    public boolean isShowHoldDate(){
        boolean result = false;
        if (selectedList != null && !selectedList.isEmpty()) {
            for(Object key : selectedList.keySet()) {
                Boolean val = selectedList.get(key);
                if(val != null && val) {
                    String bType = balanceTypes.get(key);
                    if (bType != null && bType.equals("BLTP0002")) {
                        result = true;
                        break;
                    }
                }
            }
        }
        return  result;
    }
	
	public void clearFilter() {
		filter = new Balance();
		filterEntry = new Entry();		
		clearState();
		searching = false;
	}
	
	public Balance getFilter() {
		if (filter == null)
			filter = new Balance();
		return filter;
	}

	public void setFilter(Balance filter) {
		this.filter = filter;
	}
	
	public Entry getFilterEntry() {
		if (filterEntry == null)
			filterEntry = new Entry();
		return filterEntry;
	}

	public void setFilterEntry(Entry filterEntry) {
		this.filterEntry = filterEntry;
	}

	private void setFilters() {
		filter = getFilter();
		filters = new ArrayList<Filter>();

		Filter paramFilter;
		
		if (filter.getAccountId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("accountId");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(filter.getAccountId().toString());
			filters.add(paramFilter);
		}
	}
	
	private void setFiltersEntry() {
		filterEntry = getFilterEntry();
		filtersEntry = new ArrayList<Filter>();

		Filter paramFilter;
		
		if (filter.getAccountId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("accountId");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(filter.getAccountId().toString());
			filtersEntry.add(paramFilter);
		}
		
		List<String> balanceType = null;
		if (selectedList != null && !selectedList.isEmpty()) {
			List<Balance> balances = _balancesSource.getActivePage();
			balanceType = new ArrayList<String>();
			for (Balance bal : balances) {
				Boolean value = selectedList.get(bal.getModelId());
				if (Boolean.TRUE.equals(value)) {
					balanceType.add(bal.getBalanceType());
				}
			}
			if (balanceType != null && balanceType.size() > 0) {
				paramFilter = new Filter();
				paramFilter.setElement("balanceTypes");
				paramFilter.setOp(Operator.eq);
				paramFilter.setValueList(balanceType);
				filtersEntry.add(paramFilter);
			}
		}
		
		String dbDateFormat = "dd.MM.yyyy";
		SimpleDateFormat df = new SimpleDateFormat(dbDateFormat);
		if (filterEntry.getOperationDateFrom() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("operationDateFrom");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(df.format(filterEntry.getOperationDateFrom()));
			filtersEntry.add(paramFilter);
		}
		if (filterEntry.getOperationDateTo() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("operationDateTo");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(df.format(filterEntry.getOperationDateTo()));
			filtersEntry.add(paramFilter);
		}
	}

	public void add() {
		newEntry = new Entry();
		curMode = NEW_MODE;
	}

	public void edit() {	
		curMode = EDIT_MODE;
	}

	public void view() {
		
	}
	
	public void close() {
		curMode = VIEW_MODE;
	}

	public Entry getNewEntry() {
		if (newEntry == null) {
			newEntry = new Entry();		
		}
		return newEntry;
	}

	public void setNewEntry(Entry newEntry) {
		this.newEntry = newEntry;
	}

	public void clearState() {
		_balancesSelection.clearSelection();
//		_activeBalance = null;			
		_balancesSource.flushCache();
		curLang = userLang;		
		clearStateEntry();
	}
	
	public void clearStateEntry() {
		_itemSelection.clearSelection();
		_activeEntry = null;			
		_entriesSource.flushCache();
		searchingEntry = false;		
	}
	
	public void clearBeansStates() {
		
	}
	
	public ArrayList<SelectItem> getEntryTypes() {
		return getDictUtils().getArticles(DictNames.BALANCE_TYPE, false, false);
	}

	public ArrayList<SelectItem> getEntryStatuses() {
		return getDictUtils().getArticles(DictNames.BALANCE_STATUS, false, false);
	}	
	
	public void changeLanguage(ValueChangeEvent event) {	
		curLang = (String)event.getNewValue();		
	}

	public Map<Object, Boolean> getSelectedList() {
		return selectedList;
	}

	public void setSelectedList(Map<Object, Boolean> selectedList) {
		this.selectedList = selectedList;
	}

	public String getTimeZone() {
		return timeZone;
	}

	public void setTimeZone(String timeZone) {
		this.timeZone = timeZone;
	}

	public boolean isSelectAll() {
		return selectAll;
	}

	public void setSelectAll(boolean selectAll) {
		this.selectAll = selectAll;
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
