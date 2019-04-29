package ru.bpc.sv2.ui.ps.mastercard.messages;

import java.text.SimpleDateFormat;
import java.util.*;

import javax.annotation.PostConstruct;

import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.model.SelectItem;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;

import ru.bpc.sv2.constants.SectionIdConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.Filter.Operator;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.MastercardDao;
import ru.bpc.sv2.ps.mastercard.McwReject;
import ru.bpc.sv2.ui.utils.*;
import util.auxil.ManagedBeanWrapper;

@ViewScoped
@ManagedBean (name = "MbMcwRejectSearch")
public class MbMcwRejectSearch extends AbstractBean{
    private static final long serialVersionUID = 9180917082872879256L;

    private static final Logger logger = Logger.getLogger("CREDIT"); //todo must be changed to appropriate

    private static final String REJECT_CODE_TAB = "rejectCodeTab";

    private static String COMPONENT_ID = "1982:rejectsTable"; //todo must be changed

    private MastercardDao masterDao = new MastercardDao();

    private ArrayList<SelectItem> institutions;
    private McwReject filter;
    private final DaoDataModel<McwReject> messageSource;

    private McwReject activeItem;
    private final TableRowSelection<McwReject> itemSelection;
    private HashMap<String, Boolean> loadedTabs = new HashMap<String, Boolean>();
    private String tabName;
    private String needRerender;
    private List<String> rerenderList;
    private Map<String, Object> paramMap;

    public MbMcwRejectSearch(){
        pageLink = "mastercard|rejects";
        messageSource = new DaoDataListModel<McwReject>(logger){
            private static final long serialVersionUID = 6886825197574225937L;

            @Override
            protected List<McwReject> loadDaoListData(SelectionParams params) {
                if (isSearching()) {
                    setFilters();
                    params.setFilters(filters);
                    return masterDao.getMcwRejects(userSessionId, params);
                }
                return new ArrayList<McwReject>();
            }

            @Override
            protected int loadDaoDataSize(SelectionParams params) {
                if (isSearching()) {
                    setFilters();
                    params.setFilters(filters);
                    return masterDao.getMcwRejectsCount(userSessionId, params);
                }
                return 0;
            }
        };

        itemSelection = new TableRowSelection<McwReject>(null, messageSource);
        tabName = "detailsTab";
    }

    @PostConstruct
    public void init() {
        setDefaultValues();
    }

    private void setFilters(){
        //todo must be revisited
        McwReject messageFilter = getFilter();
        filters = new ArrayList<Filter>();
        Filter paramFilter;

        if (messageFilter.getSessionId()!= null){
            paramFilter = new Filter();
            paramFilter.setElement("sessionId");
            paramFilter.setOp(Operator.eq);
            paramFilter.setValue(messageFilter.getSessionId());
            filters.add(paramFilter);
        }

        if (messageFilter.getFileName()!= null && messageFilter.getFileName().trim().length() > 0){
            paramFilter = new Filter();
            paramFilter.setElement("fileName");
            paramFilter.setOp(Operator.like);
            paramFilter.setValue(messageFilter.getFileName().trim().toUpperCase()
                    .replaceAll("[*]", "%").replaceAll("[?]", "_"));
            filters.add(paramFilter);
        }

        String dbDateFormat = "dd.MM.yyyy";
        SimpleDateFormat df = new SimpleDateFormat(dbDateFormat);
        if (messageFilter.getDateFrom() != null) {
            paramFilter = new Filter();
            paramFilter.setElement("dateFrom");
            paramFilter.setValue(df.format(messageFilter.getDateFrom()));
            filters.add(paramFilter);
        }
        if (messageFilter.getDateTo() != null) {
            paramFilter = new Filter();
            paramFilter.setElement("dateTo");
            paramFilter.setValue(df.format(messageFilter.getDateTo()));
            filters.add(paramFilter);
        }

        paramFilter = new Filter();
        paramFilter.setElement("lang");
        paramFilter.setValue(userLang);
        filters.add(paramFilter);
    }

    public SimpleSelection getItemSelection(){
        if (activeItem == null && messageSource.getRowCount() > 0){
            setFirstRowActive();
        } else if (activeItem != null && messageSource.getRowCount() > 0){
            SimpleSelection selection = new SimpleSelection();
            selection.addKey(activeItem.getModelId());
            itemSelection.setWrappedSelection(selection);
            activeItem = itemSelection.getSingleSelection();
        }
        return itemSelection.getWrappedSelection();
    }

    public void setItemSelection(SimpleSelection selection){
        itemSelection.setWrappedSelection(selection);
        activeItem = itemSelection.getSingleSelection();
        if (activeItem != null){
            setInfo();
        }
    }

    private void setFirstRowActive(){
        messageSource.setRowIndex(0);
        SimpleSelection selection = new SimpleSelection();
        activeItem = (McwReject)messageSource.getRowData();
        selection.addKey(activeItem.getModelId());
        itemSelection.setWrappedSelection(selection);
        if (activeItem != null) {
            setInfo();
        }
    }

    private void setInfo(){
        loadedTabs.clear();
        loadTab(getTabName());
    }
    private void loadTab(String tabName){
        if (tabName == null){
            return;
        }

        if (activeItem == null){
            return;
        }

        if (tabName.equalsIgnoreCase(REJECT_CODE_TAB)){
        	MbMcwRejectCodeSearchBottom mbRejectCode = (MbMcwRejectCodeSearchBottom) ManagedBeanWrapper
                    .getManagedBean("MbMcwRejectCodeSearchBottom");
        	Map<String, Object> params = new HashMap<String, Object>();
        	params.put("rejectId", activeItem.getId());
            mbRejectCode.setFilterMap(params);
            mbRejectCode.search();
        }

        needRerender = tabName;
        loadedTabs.put(tabName, Boolean.TRUE);
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
        setSearching(false);
        clearBean();
        setDefaultValues();
    }

    private void clearDependencies(){
       MbMcwRejectCodeSearchBottom rejectCodeBean = (MbMcwRejectCodeSearchBottom) ManagedBeanWrapper
                .getManagedBean("MbMcwRejectCodeSearchBottom");
        rejectCodeBean.clearFilter();
    }

    public void setTabName(String tabName){
        needRerender = null;
        this.tabName = tabName;

        Boolean isLoadedCurrentTab = loadedTabs.get(tabName);

        if (isLoadedCurrentTab == null) {
            isLoadedCurrentTab = Boolean.FALSE;
        }

        if (isLoadedCurrentTab.equals(Boolean.TRUE)) {
            return;
        }

        loadTab(tabName);

        if (tabName.equalsIgnoreCase(REJECT_CODE_TAB)) {
            MbMcwRejectCodeSearchBottom bean = (MbMcwRejectCodeSearchBottom) ManagedBeanWrapper
                    .getManagedBean("MbMcwRejectCodeSearchBottom");
            bean.setTabName(tabName);
            bean.setParentSectionId(getSectionId());
            bean.setTableState(getSateFromDB(bean.getComponentId()));
        }
    }

    public String getSectionId() {
        return SectionIdConstants.ISSUING_CREDIT_DEBT;
    }

    public boolean getSearching(){
        return searching;
    }
    public String getTabName(){
        return tabName;
    }
    public void setFilter(McwReject filter) {
        this.filter = filter;
    }

    public McwReject getFilter() {
        if (filter == null){
            filter = new McwReject();
        }
        return filter;
    }

    public DaoDataModel<McwReject> getItems(){
        return messageSource;
    }
    public McwReject getActiveItem(){
        return activeItem;
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
        filter = new McwReject();
    }

}
