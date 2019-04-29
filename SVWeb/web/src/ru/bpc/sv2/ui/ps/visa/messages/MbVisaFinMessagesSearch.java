package ru.bpc.sv2.ui.ps.visa.messages;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.annotation.PostConstruct;

import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;

import ru.bpc.sv2.constants.SectionIdConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.VisaDao;
import ru.bpc.sv2.ps.visa.VisaFinMessage;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.TableRowSelection;
import util.auxil.ManagedBeanWrapper;

@ViewScoped
@ManagedBean (name = "MbVisaFinMessagesSearch")
public class MbVisaFinMessagesSearch extends AbstractBean{
    private static final long serialVersionUID = 9180917082872879256L;

    private static final Logger logger = Logger.getLogger("OPER_RPOCESSING");

    private static final String DETAILS_TAB = "visaFinMessagesDetailsTab";
    private static final String ADDENDUM_TAB = "addendumTab";
    private static final String FEE_TAB = "feeTab";

    private static String COMPONENT_ID = "1982:visaFinTable"; 

    private VisaDao visaDao = new VisaDao();

    private VisaFinMessage filter;
    private final DaoDataModel<VisaFinMessage> messageSource;

    private VisaFinMessage activeItem;
    private final TableRowSelection<VisaFinMessage> itemSelection;
    private HashMap<String, Boolean> loadedTabs = new HashMap<String, Boolean>();
    private String tabName;
    private String needRerender;
    private List<String> rerenderList;
    private Map<String, Object> paramMap;

    public MbVisaFinMessagesSearch(){
        pageLink = "visa|financial_messages";
        messageSource = new DaoDataModel<VisaFinMessage>(){
            private static final long serialVersionUID = 6886825197574225937L;
            @Override
            protected VisaFinMessage[] loadDaoData(SelectionParams params) {
                if (!searching)
                    return new VisaFinMessage[0];
                try {
                    setFilters();
                    params.setFilters(filters.toArray(new Filter[filters.size()]));
                    return visaDao.getVisaFinMessages(userSessionId, params);
                } catch (Exception e) {
                    setDataSize(0);
                    FacesUtils.addMessageError(e);
                    logger.error("", e);
                }
                return new VisaFinMessage[0];
            }
            @Override
            protected int loadDaoDataSize(SelectionParams params) {
                if (!searching)
                    return 0;
                try {
                    setFilters();
                    params.setFilters(filters.toArray(new Filter[filters.size()]));
                    return visaDao.getVisaFinMessagesCount(userSessionId, params);
                } catch (Exception e){
                    setDataSize(0);
                    FacesUtils.addMessageError(e);
                    logger.error("", e);
                }
                return 0;
            }
        };

        itemSelection = new TableRowSelection<VisaFinMessage>(null, messageSource);
        tabName = DETAILS_TAB;
    }

    @PostConstruct
    public void init() {
        setDefaultValues();
    }

    private void setFilters(){
        VisaFinMessage messageFilter = getFilter();
        filters = new ArrayList<Filter>();

        if (messageFilter.getSessionId()!= null){
            filters.add(new Filter("sessionId", messageFilter.getSessionId()));
        }

        if (messageFilter.getFileName()!= null && messageFilter.getFileName().trim().length() > 0){
            filters.add(new Filter("fileName", messageFilter.getFileName().trim().toUpperCase()
                    .replaceAll("[*]", "%").replaceAll("[?]", "_")));
        }

        if (messageFilter.getDateFrom() != null) {
            filters.add(new Filter("dateFrom", messageFilter.getDateFrom()));
        }
        if (messageFilter.getDateTo() != null) {
            filters.add(new Filter("dateTo", messageFilter.getDateTo()));
        }
        
        if (messageFilter.getOperDateFrom() != null) {
            filters.add(new Filter("operDateFrom", messageFilter.getOperDateFrom()));
        }
        if (messageFilter.getOperDateTo() != null) {
            filters.add(new Filter("operDateTo", messageFilter.getOperDateTo()));
        }
        
        if (messageFilter.getArn() != null && messageFilter.getArn().trim().length() > 0){
            filters.add(new Filter("arn", messageFilter.getArn().trim().toUpperCase()
                    .replaceAll("[*]", "%").replaceAll("[?]", "_")));
        } 
        if (messageFilter.getTerminalNumber() != null && messageFilter.getTerminalNumber().trim().length() > 0){
            filters.add(new Filter("terminalNumber", messageFilter.getTerminalNumber().trim().toUpperCase()
                    .replaceAll("[*]", "%").replaceAll("[?]", "_")));
        }  
        if (messageFilter.getAuthCode() != null && messageFilter.getAuthCode().trim().length() > 0){
            filters.add(new Filter("authCode", messageFilter.getAuthCode().trim().toUpperCase()
                    .replaceAll("[*]", "%").replaceAll("[?]", "_")));
        }
        if (messageFilter.getCardMask() != null && messageFilter.getCardMask().trim().length() > 0){
            filters.add(new Filter("cardNumber", messageFilter.getCardMask().trim().toUpperCase()
                    .replaceAll("[*]", "%").replaceAll("[?]", "_")));
        }
        if (messageFilter.getTransCode() != null && messageFilter.getTransCode().trim().length() > 0){
            filters.add(new Filter("transCode", messageFilter.getTransCode().trim().toUpperCase()
                    .replaceAll("[*]", "%").replaceAll("[?]", "_")));
        }

        filters.add(new Filter("lang", userLang));
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
        activeItem = (VisaFinMessage)messageSource.getRowData();
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

        if (tabName.equalsIgnoreCase(ADDENDUM_TAB)){
            MbVisaAddendumSearchBottom mbAddendum = (MbVisaAddendumSearchBottom) ManagedBeanWrapper
                    .getManagedBean("MbVisaAddendumSearchBottom");
            Map<String, Object> params = new HashMap<String, Object>();
            params.put("finMessageId", activeItem.getId());
            mbAddendum.setFilterMap(params);
            mbAddendum.search();
        } else if (tabName.equalsIgnoreCase(FEE_TAB)){
            MbVisaFeesSearchBottom mbFee  = (MbVisaFeesSearchBottom) ManagedBeanWrapper
                    .getManagedBean("MbVisaFeesSearchBottom");
            mbFee.loadFee(activeItem.getId());
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
        MbVisaAddendumSearchBottom bean = (MbVisaAddendumSearchBottom) ManagedBeanWrapper
                .getManagedBean("MbVisaAddendumSearchBottom");
        bean.clearFilter();
        
        MbVisaFeesSearchBottom feesBean = (MbVisaFeesSearchBottom) ManagedBeanWrapper
                .getManagedBean("MbVisaFeesSearchBottom");
        feesBean.clearFilter();
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

        if (tabName.equalsIgnoreCase(ADDENDUM_TAB)) {
            MbVisaAddendumSearchBottom bean = (MbVisaAddendumSearchBottom) ManagedBeanWrapper
                    .getManagedBean("MbVisaAddendumSearchBottom");
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
    public void setFilter(VisaFinMessage filter) {
        this.filter = filter;
    }

    public VisaFinMessage getFilter() {
        if (filter == null){
            filter = new VisaFinMessage();
        }
        return filter;
    }

    public DaoDataModel<VisaFinMessage> getItems(){
        return messageSource;
    }
    public VisaFinMessage getActiveItem(){
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
        filter = new VisaFinMessage();
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
}
