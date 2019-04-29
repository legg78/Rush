package ru.bpc.sv2.ui.ps.amex.reconciliation;

import org.apache.commons.lang3.StringUtils;
import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;
import ru.bpc.sv2.constants.DatePatterns;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.AmexDao;
import ru.bpc.sv2.ps.amex.AmexAtmReconciliation;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataListModel;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.TableRowSelection;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

@ViewScoped
@ManagedBean (name = "MbAmexAtmReconciliationsSearch")
public class MbAmexAtmReconciliationsSearch extends AbstractBean {
    private static final long serialVersionUID = 1L;
    private static final Logger logger = Logger.getLogger("AMEX");

    private static final String DETAILS_TAB = "detailsTab";

    private static String COMPONENT_ID = "2453:atmReconTable";

    private AmexDao amexDao = new AmexDao();

    private AmexAtmReconciliation filter;
    private final DaoDataModel<AmexAtmReconciliation> atmReconSource;

    private AmexAtmReconciliation activeItem;
    private final TableRowSelection<AmexAtmReconciliation> itemSelection;
    private HashMap<String, Boolean> loadedTabs = new HashMap<String, Boolean>();
    private String tabName;
    private String needRerender;
    private List<String> rerenderList;

    public MbAmexAtmReconciliationsSearch(){
        pageLink = "amx|atm_reconciliations";
        atmReconSource = new DaoDataListModel<AmexAtmReconciliation>(logger){
            private static final long serialVersionUID = 1L;
            @Override
            protected List<AmexAtmReconciliation> loadDaoListData(SelectionParams params) {
                if (searching) {
                    setFilters();
                    params.setFilters(filters);
                    return amexDao.getAtmReconciliations(userSessionId, params);
                }
                return new ArrayList<AmexAtmReconciliation>();
            }

            @Override
            protected int loadDaoDataSize(SelectionParams params) {
                if (searching) {
                    setFilters();
                    params.setFilters(filters);
                    return amexDao.getAtmReconciliationsCount(userSessionId, params);
                }
                return 0;
            }
        };

        itemSelection = new TableRowSelection<AmexAtmReconciliation>(null, atmReconSource);
        tabName = DETAILS_TAB;
    }

    private void setFilters() {
        filters = new ArrayList<Filter>();
        filters.add(Filter.create("lang", userLang));

        if (getFilter().getSessionId()!= null){
            filters.add(Filter.create("sessionId", getFilter().getSessionId()));
        }
        if (StringUtils.isNotBlank(getFilter().getFileName())){
            filters.add(Filter.create("fileName", Filter.mask(getFilter().getFileName())));
        }
        if (getFilter().getDateFrom() != null) {
            filters.add(Filter.create("dateFrom", new SimpleDateFormat(DatePatterns.DATE_PATTERN).format(getFilter().getDateFrom())));
        }
        if (getFilter().getDateTo() != null) {
            filters.add(Filter.create("dateTo", new SimpleDateFormat(DatePatterns.DATE_PATTERN).format(getFilter().getDateTo())));
        }
    }

    public SimpleSelection getItemSelection() {
        if (activeItem == null && atmReconSource.getRowCount() > 0) {
            setFirstRowActive();
        } else if (activeItem != null && atmReconSource.getRowCount() > 0) {
            SimpleSelection selection = new SimpleSelection();
            selection.addKey(activeItem.getModelId());
            itemSelection.setWrappedSelection(selection);
            activeItem = itemSelection.getSingleSelection();
        }
        return itemSelection.getWrappedSelection();
    }

    public void setItemSelection(SimpleSelection selection) {
        itemSelection.setWrappedSelection(selection);
        activeItem = itemSelection.getSingleSelection();
        if (activeItem != null) {
            setInfo();
        }
    }

    private void setFirstRowActive() {
        atmReconSource.setRowIndex(0);
        SimpleSelection selection = new SimpleSelection();
        activeItem = (AmexAtmReconciliation)atmReconSource.getRowData();
        selection.addKey(activeItem.getModelId());
        itemSelection.setWrappedSelection(selection);
        if (activeItem != null) {
            setInfo();
        }
    }

    private void setInfo() {
        loadedTabs.clear();
        loadTab(getTabName());
    }

    private void loadTab(String tabName){
        if (tabName != null && activeItem != null) {
            needRerender = tabName;
            loadedTabs.put(tabName, Boolean.TRUE);
        }
    }

    public void search() {
        setSearching(true);
        clearBean();
    }

    private void clearBean(){
        atmReconSource.flushCache();
        itemSelection.clearSelection();
        activeItem = null;
    }

    public void clearFilter(){
        filter = null;
        setSearching(false);
        clearBean();
        setDefaultValues();
    }

    public void setTabName(String tabName) {
        needRerender = tabName;
        this.tabName = tabName;
        if ((loadedTabs.get(tabName) != null) ? loadedTabs.get(tabName) : false) {
            return;
        }
        loadTab(tabName);
    }

    public boolean getSearching(){
        return searching;
    }
    public String getTabName(){
        return tabName;
    }
    public void setFilter(AmexAtmReconciliation filter) {
        this.filter = filter;
    }

    public AmexAtmReconciliation getFilter() {
        if (filter == null){
            filter = new AmexAtmReconciliation();
        }
        return filter;
    }

    public DaoDataModel<AmexAtmReconciliation> getAtmRecons(){
        return atmReconSource;
    }

    public AmexAtmReconciliation getActiveItem(){
        return activeItem;
    }

    public void setRowsNum(int rowsNum) {
        this.rowsNum = rowsNum;
    }

    public int getRowsNum(){
        return rowsNum;
    }

    public List<String> getRerenderList(){
        rerenderList = new ArrayList<String>();
        if (needRerender != null) {
            rerenderList.add(needRerender);
        }
        rerenderList.add("err_ajax");
        rerenderList.add(tabName);
        return rerenderList;
    }

    public String getComponentId() {
        return COMPONENT_ID;
    }

    public Logger getLogger() {
        return logger;
    }

    private void setDefaultValues() {
        filter = new AmexAtmReconciliation();
    }

}
