package ru.bpc.sv2.ui.accounts;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;
import ru.bpc.sv2.accounts.PriorityAccount;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.AccountsDao;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.TableRowSelection;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import java.util.ArrayList;

@ViewScoped
@ManagedBean (name = "MbPriorityAccounts")
public class MbPriorityAccounts extends AbstractBean {
    private static final Logger logger = Logger.getLogger("ACCOUNTING");

    private static String COMPONENT_ID = "2451:priorityAccountsTable";

    private AccountsDao _accountsDao = new AccountsDao();

    private PriorityAccount filter;


    private final DaoDataModel<PriorityAccount> _priorityAccountsSource;
    private final TableRowSelection<PriorityAccount> _itemSelection;
    private PriorityAccount _activeSelection;

    public MbPriorityAccounts() {

        pageLink = "monitoring|priorityAccounts";
        _priorityAccountsSource = new DaoDataModel<PriorityAccount>() {
            @Override
            protected PriorityAccount[] loadDaoData(SelectionParams params) {
                if (!searching) {
                    return new PriorityAccount[0];
                }
                try {
                    setFilters();
                    params.setFilters(filters.toArray(new Filter[filters.size()]));
                    return _accountsDao.getPriorityAccounts(userSessionId, params);
                } catch (Exception e) {
                    setDataSize(0);
                    logger.error("", e);
                    FacesUtils.addMessageError(e);
                    return new PriorityAccount[0];
                }
            }

            @Override
            protected int loadDaoDataSize(SelectionParams params) {
                if (!searching) {
                    return 0;
                }
                try {
                    setFilters();
                    params.setFilters(filters.toArray(new Filter[filters.size()]));
                    return _accountsDao.getPriorityAccountsCount(userSessionId, params);
                } catch (Exception e) {
                    logger.error("", e);
                    FacesUtils.addMessageError(e);
                    return 0;
                }
            }
        };

        _itemSelection = new TableRowSelection<PriorityAccount>(null, _priorityAccountsSource);
    }

    public DaoDataModel<PriorityAccount> getPriorityAccounts() {
        return _priorityAccountsSource;
    }

    public PriorityAccount getActiveSelection() {
        return _activeSelection;
    }

    public void setActiveSelection(PriorityAccount activeSelection) {
        _activeSelection = activeSelection;
    }

    public SimpleSelection getItemSelection() {
        try {
            if (_activeSelection == null && _priorityAccountsSource.getRowCount() > 0) {
                setFirstRowActive();
            } else if (_activeSelection != null && _priorityAccountsSource.getRowCount() > 0) {
                SimpleSelection selection = new SimpleSelection();
                selection.addKey(_activeSelection.getModelId());
                _itemSelection.setWrappedSelection(selection);
                _activeSelection = _itemSelection.getSingleSelection();
            }
        } catch (Exception e) {
            logger.error("", e);
            FacesUtils.addMessageError(e);
        }
        return _itemSelection.getWrappedSelection();
    }

    public void setItemSelection(SimpleSelection selection) {
        _itemSelection.setWrappedSelection(selection);
        _activeSelection = _itemSelection.getSingleSelection();

        if (_activeSelection != null) {
            setBeans();
        }
    }

    public void setFirstRowActive() {
        _priorityAccountsSource.setRowIndex(0);
        SimpleSelection selection = new SimpleSelection();
        _activeSelection = (PriorityAccount) _priorityAccountsSource.getRowData();
        selection.addKey(_activeSelection.getModelId());
        _itemSelection.setWrappedSelection(selection);

        setBeans();
    }

    /**
     * Sets data for backing beans used by dependent pages
     */
    public void setBeans() {
    }

    public void setFilters() {
        getFilter();
        filters = new ArrayList<Filter>();

        if (filter.getId() != null) {
            filters.add(new Filter("id", filter.getId()));
        }
        if (filter.getDateFrom() != null) {
            filters.add(new Filter("fileDateFrom", filter.getDateFrom()));
        }
        if (filter.getDateTo() != null) {
            filters.add(new Filter("fileDateTo", filter.getDateTo()));
        }
        if (filter.getCustomerNumber() != null && !filter.getCustomerNumber().trim().isEmpty()) {
            filters.add(new Filter("customerNumber", Filter.mask(filter.getCustomerNumber())));
        }
        if (filter.getAccountNumber() != null && !filter.getAccountNumber().trim().isEmpty()) {
            filters.add(new Filter("accountNumber", Filter.mask(filter.getAccountNumber())));
        }
        if (filter.getAccountBalance() != null) {
            filters.add(new Filter("accountBalance", filter.getAccountBalance()));
        }
        if (filter.getCustomerBalance() != null) {
            filters.add(new Filter("customerBalance", filter.getAccountBalance()));
        }
        if (filter.getAgentNumber() != null && !filter.getAgentNumber().trim().isEmpty()) {
            filters.add(new Filter("agentNumber", Filter.mask(filter.getAgentNumber())));
        }
        if (filter.getProductNumber() != null && !filter.getProductNumber().trim().isEmpty()) {
            filters.add(new Filter("productNumber", Filter.mask(filter.getProductNumber())));
        }
    }

    public PriorityAccount getFilter() {
        if (filter == null) {
            filter = new PriorityAccount();
        }
        return filter;
    }

    public void setFilter(PriorityAccount filter) {
        this.filter = filter;
    }

    public void clearFilter() {
        filter = null;
        clearBean();

        searching = false;
    }

    public void search() {
        curMode = VIEW_MODE;
        clearBean();
        searching = true;
    }

    public void clearBean() {
        curLang = userLang;
        _priorityAccountsSource.flushCache();
        _itemSelection.clearSelection();
        _activeSelection = null;

        clearBeans();
    }

    private void clearBeans() {

    }

    public String getComponentId() {
        return COMPONENT_ID;
    }

    public Logger getLogger() {
        return logger;
    }

}
