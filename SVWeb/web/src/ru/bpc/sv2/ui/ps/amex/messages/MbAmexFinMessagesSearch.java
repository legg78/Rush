package ru.bpc.sv2.ui.ps.amex.messages;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;
import ru.bpc.sv2.constants.DatePatterns;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.AmexDao;
import ru.bpc.sv2.ps.amex.AmexFinMessage;
import ru.bpc.sv2.ps.amex.AmexFinMessageAddendum;
import ru.bpc.sv2.ui.ps.amex.files.MbAmexRejectSearchBottom;
import ru.bpc.sv2.ui.ps.mir.messages.MbAmexFinMessageAddendum;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataListModel;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.TableRowSelection;
import util.auxil.ManagedBeanWrapper;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.model.SelectItem;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@ViewScoped
@ManagedBean (name = "MbAmexFinMessagesSearch")
public class MbAmexFinMessagesSearch extends AbstractBean {
    private static final long serialVersionUID = 1562402854449134601L;
    private static final Logger logger = Logger.getLogger("AMEX");

    private static final String ADDENDUM_TAB = "addendumTab";
    private static final String REJECT_TAB = "rejectTab";
    private static final String REJECT_CODE_TAB = "rejectCodeTab";
    private static final String DETAILS_TAB = "detailsTab";

    private static String COMPONENT_ID = "1982:finMessageTable";

    private AmexDao amexDao = new AmexDao();

    private ArrayList<SelectItem> institutions;
    private AmexFinMessage filter;
    private final DaoDataModel<AmexFinMessage> messageSource;

    private AmexFinMessage activeItem;
    private AmexFinMessage newFinMessage;
    private final TableRowSelection<AmexFinMessage> itemSelection;
    private HashMap<String, Boolean> loadedTabs = new HashMap<String, Boolean>();
    private String tabName;
    private String needRerender;
    private List<String> rerenderList;
    private Map<String, Object> paramMap;
    private Integer rejected;
    private List<SelectItem> yesNoLov;

    public MbAmexFinMessagesSearch(){
        pageLink = "amx|financial_messages";
        messageSource = new DaoDataListModel<AmexFinMessage>(logger){
            private static final long serialVersionUID = 6886825197574225937L;
            @Override
            protected List<AmexFinMessage> loadDaoListData(SelectionParams params) {
                if (searching) {
                    setFilters();
                    params.setFilters(filters);
                    return amexDao.getFinancialMessages(userSessionId, params);
                }
                return new ArrayList<AmexFinMessage>();
            }

            @Override
            protected int loadDaoDataSize(SelectionParams params) {
                if (searching) {
                    setFilters();
                    params.setFilters(filters);
                    return amexDao.getFinancialMessagesCount(userSessionId, params);
                }
                return 0;
            }
        };

        itemSelection = new TableRowSelection<AmexFinMessage>(null, messageSource);
        tabName = DETAILS_TAB;
    }

    private void setFilters() {
        filters = new ArrayList<Filter>();
        filters.add(Filter.create("lang", userLang));

        if (getFilter().getSessionId()!= null){
            filters.add(Filter.create("sessionId", getFilter().getSessionId()));
        }
        if (getFilter().getFileName()!= null && getFilter().getFileName().trim().length() > 0){
            filters.add(Filter.create("fileName", Filter.mask(getFilter().getFileName())));
        }
        if (getFilter().getDateFrom() != null) {
            filters.add(Filter.create("dateFrom", new SimpleDateFormat(DatePatterns.DATE_PATTERN).format(getFilter().getDateFrom())));
        }
        if (getFilter().getDateTo() != null) {
            filters.add(Filter.create("dateTo", new SimpleDateFormat(DatePatterns.DATE_PATTERN).format(getFilter().getDateTo())));
        }
        if (rejected != null) {
            filters.add(Filter.create("isRejected", rejected));
        }
    }

    public SimpleSelection getItemSelection() {
        if (activeItem == null && messageSource.getRowCount() > 0) {
            setFirstRowActive();
        } else if (activeItem != null && messageSource.getRowCount() > 0) {
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
        messageSource.setRowIndex(0);
        SimpleSelection selection = new SimpleSelection();
        activeItem = (AmexFinMessage)messageSource.getRowData();
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
            if (tabName.equalsIgnoreCase(ADDENDUM_TAB)) {
                MbAmexFinMessageAddendum mbAddendum = (MbAmexFinMessageAddendum) ManagedBeanWrapper.getManagedBean(MbAmexFinMessageAddendum.class);
                AmexFinMessageAddendum addendumFilter = new AmexFinMessageAddendum();
                addendumFilter.setFinId(activeItem.getId());
                mbAddendum.setFilter(addendumFilter);
                mbAddendum.search();
            } else if (tabName.equalsIgnoreCase(REJECT_TAB)) {
                MbAmexRejectSearchBottom mbReject = (MbAmexRejectSearchBottom) ManagedBeanWrapper.getManagedBean(MbAmexRejectSearchBottom.class);
                mbReject.loadReject(activeItem.getRejectId());
            }
            needRerender = tabName;
            loadedTabs.put(tabName, Boolean.TRUE);
        }
    }

    public void search() {
        setSearching(true);
        clearBean();
        paramMap = new HashMap<String, Object>();
    }

    private void clearBean(){
        messageSource.flushCache();
        clearDependencies();
        itemSelection.clearSelection();
        activeItem = null;
    }

    public void clearFilter(){
        filter = null;
        rejected = null;
        setSearching(false);
        clearBean();
        setDefaultValues();
    }

    private void clearDependencies(){
        MbAmexFinMessageAddendum addendum = (MbAmexFinMessageAddendum) ManagedBeanWrapper.getManagedBean(MbAmexFinMessageAddendum.class);
        addendum.clearFilter();
        MbAmexRejectSearchBottom reject = (MbAmexRejectSearchBottom) ManagedBeanWrapper.getManagedBean(MbAmexRejectSearchBottom.class);
        reject.clearFilter();
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
    public void setFilter(AmexFinMessage filter) {
        this.filter = filter;
    }

    public AmexFinMessage getFilter() {
        if (filter == null){
            filter = new AmexFinMessage();
        }
        return filter;
    }

    public DaoDataModel<AmexFinMessage> getItems(){
        return messageSource;
    }
    public AmexFinMessage getActiveItem(){
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
        filter = new AmexFinMessage();
    }

    public Map<String, Object> getParamMap() {
        if (paramMap == null){
            paramMap = new HashMap<String, Object>();
        }
        return paramMap;
    }

    public void setParamMap(Map<String, Object> paramMap) {
        this.paramMap = paramMap;
    }

    public Integer getRejected() {
        return rejected;
    }

    public void setRejected(Integer rejected) {
        this.rejected = rejected;
    }

    public List<SelectItem> getYesNoLov() {
        if (yesNoLov == null) {
            yesNoLov = getDictUtils().getLov(LovConstants.BOOLEAN);
        }
        return yesNoLov;
    }

    public AmexFinMessage getNewFinMessage() {
        if (newFinMessage == null) {
            newFinMessage = new AmexFinMessage();
        }
        return newFinMessage;
    }

    public void setNewFinMessage(AmexFinMessage newFinMessage) {
        this.newFinMessage = newFinMessage;
    }

}
