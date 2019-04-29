package ru.bpc.sv2.ui.ps.diners.messages;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;
import ru.bpc.sv2.constants.SectionIdConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.DinersDao;
import ru.bpc.sv2.ps.diners.DinersFinMessage;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.TableRowSelection;
import util.auxil.ManagedBeanWrapper;

import javax.annotation.PostConstruct;

import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@ViewScoped
@ManagedBean (name = "MbDinFinMessagesSearch")
public class MbDinFinMessagesSearch extends AbstractBean{
    private static final long serialVersionUID = 9180917082872879256L;
    private static final Logger logger = Logger.getLogger("OPER_RPOCESSING");
    private static final String DETAILS_TAB = "dinDetailTab";
    private static final String ADDENDUM_TAB = "dinAddendumTab";
    private static final String FEE_TAB = "dinFeeTab";
    private static String COMPONENT_ID = "1982:DinFinTable";
    private final DaoDataModel<DinersFinMessage> messageSource;
    private final TableRowSelection<DinersFinMessage> itemSelection;
    private DinersDao dinersDao = new DinersDao();
    private DinersFinMessage filter;
    private DinersFinMessage activeItem;
    private HashMap<String, Boolean> loadedTabs = new HashMap<String, Boolean>();
    private String tabName;
    private String needRerender;
    private List<String> rerenderList;
    private Map<String, Object> paramMap;

    public MbDinFinMessagesSearch() {
        pageLink = "din|financial_messages";
        messageSource = new DaoDataModel<DinersFinMessage>() {
            private static final long serialVersionUID = 6886825197574225937L;
            @Override
            protected DinersFinMessage[] loadDaoData(SelectionParams params) {
                if (searching) {
                    try {
                        setFilters();
                        params.setFilters(filters.toArray(new Filter[filters.size()]));
                        return dinersDao.getDinFinMessages(userSessionId, params);
                    } catch(Exception e) {
                        setDataSize(0);
                        FacesUtils.addMessageError(e);
                        logger.error("", e);
                    }
                }
                return new DinersFinMessage[0];
            }
            @Override
            protected int loadDaoDataSize(SelectionParams params) {
                if (searching) {
                    try {
                        setFilters();
                        params.setFilters(filters.toArray(new Filter[filters.size()]));
                        return dinersDao.getDinFinMessagesCount(userSessionId, params);
                    } catch(Exception e) {
                        setDataSize(0);
                        FacesUtils.addMessageError(e);
                        logger.error("", e);
                    }
                }
                return 0;
            }
        };
        itemSelection = new TableRowSelection<DinersFinMessage>(null, messageSource);
        tabName = DETAILS_TAB;
    }

    @PostConstruct
    public void init() {
        setDefaultValues();
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

    public void setParamMap(Map<String, Object> paramMap) {
        this.paramMap = paramMap;
    }

    public Map<String, Object> getParamMap() {
        if (paramMap == null){
            paramMap = new HashMap<String, Object>();
        }
        return paramMap;
    }

    public void setTabName(String tabName){
        needRerender = null;
        this.tabName = tabName;
        Boolean isLoadedCurrentTab = loadedTabs.get( tabName );
        if(isLoadedCurrentTab == null) {
            isLoadedCurrentTab = Boolean.FALSE;
        }
        if (isLoadedCurrentTab.equals(Boolean.FALSE)) {
            loadTab(tabName);
            if (tabName.equalsIgnoreCase(ADDENDUM_TAB)) {
                MbDinAddendumSearchBottom bean = (MbDinAddendumSearchBottom)ManagedBeanWrapper
                                                 .getManagedBean("MbDinAddendumSearchBottom");
                if (bean != null) {
                    bean.setTabName(tabName);
                    bean.setParentSectionId(getSectionId());
                    bean.setTableState(getSateFromDB(bean.getComponentId()));
                }
            } else if (tabName.equalsIgnoreCase(FEE_TAB)) {
                MbDinFeesSearchBottom bean = (MbDinFeesSearchBottom)ManagedBeanWrapper
                                             .getManagedBean("MbDinFeesSearchBottom");
                if (bean != null) {
                    bean.setTabName(tabName);
                    bean.setParentSectionId(getSectionId());
                    bean.setTableState(getSateFromDB(bean.getComponentId()));
                }
            }
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

    public void setFilter(DinersFinMessage filter) {
        this.filter = filter;
    }

    public DinersFinMessage getFilter() {
        if (filter == null){
            filter = new DinersFinMessage();
        }
        return filter;
    }

    public DaoDataModel<DinersFinMessage> getItems(){
        return messageSource;
    }

    public DinersFinMessage getActiveItem(){
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

    public void search() {
        setSearching(true);
        clearBean();
        paramMap = new HashMap<String, Object>();
    }

    @Override
    public void setRowsNum(int rowsNum) {
        this.rowsNum = rowsNum;
    }
    @Override
    public int getRowsNum(){
        return rowsNum;
    }

    @Override
    public String getComponentId() {
        return COMPONENT_ID;
    }

    @Override
    public Logger getLogger() {
        return logger;
    }

    @Override
    public void clearFilter(){
        filter = null;
        setSearching(false);
        clearBean();
        setDefaultValues();
    }

    private void setFilters(){
        DinersFinMessage messageFilter = getFilter();
        filters = new ArrayList<Filter>();
        if (messageFilter.getId() != null) {
            filters.add(new Filter("id", messageFilter.getId()));
        }
        if (messageFilter.getCardNumber() != null && messageFilter.getCardNumber().trim().length() > 0) {
            filters.add(new Filter("cardNumber", messageFilter.getCardNumber().trim().toUpperCase()
                    .replaceAll("[*]", "%").replaceAll("[?]", "_")));
        }
        if (messageFilter.getNetworkRefnum() != null && messageFilter.getNetworkRefnum().trim().length() > 0) {
            filters.add(new Filter("networkRefnum", messageFilter.getNetworkRefnum()));
        }
        if (messageFilter.getFileName() != null && messageFilter.getFileName().trim().length() > 0) {
            filters.add(new Filter("fileName", messageFilter.getFileName().trim().toUpperCase()
                    .replaceAll("[*]", "%").replaceAll("[?]", "_")));
        }
        if (messageFilter.getHostDate() != null) {
            filters.add(new Filter("hostDate", messageFilter.getHostDate()));
        }
        filters.add(new Filter("lang", userLang));
    }

    private void setFirstRowActive(){
        messageSource.setRowIndex(0);
        SimpleSelection selection = new SimpleSelection();
        activeItem = (DinersFinMessage)messageSource.getRowData();
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
        if (tabName == null || activeItem == null){
            return;
        }
        if (tabName.equalsIgnoreCase(ADDENDUM_TAB)) {
            MbDinAddendumSearchBottom mbAddendum = (MbDinAddendumSearchBottom)ManagedBeanWrapper
                                                   .getManagedBean("MbDinAddendumSearchBottom");
            if (mbAddendum != null) {
                Map<String, Object> params = new HashMap<String, Object>();
                params.put("finMessageId", activeItem.getId());
                mbAddendum.setFilterMap(params);
                mbAddendum.search();
            }
        } else if (tabName.equalsIgnoreCase(FEE_TAB)) {
            MbDinFeesSearchBottom mbFee = (MbDinFeesSearchBottom)ManagedBeanWrapper
                                          .getManagedBean("MbDinFeesSearchBottom");
            if (mbFee != null) {
                mbFee.loadFee(activeItem.getId());
            }
        }
        needRerender = tabName;
        loadedTabs.put(tabName, Boolean.TRUE);
    }

    private void clearBean(){
        messageSource.flushCache();
        clearDependencies();
        itemSelection.clearSelection();
        activeItem = null;
    }

    private void clearDependencies(){
        MbDinAddendumSearchBottom mbAddendum = (MbDinAddendumSearchBottom)ManagedBeanWrapper
                                               .getManagedBean("MbDinAddendumSearchBottom");
        if (mbAddendum != null) {
            mbAddendum.clearFilter();
        }
        MbDinFeesSearchBottom mbFee = (MbDinFeesSearchBottom)ManagedBeanWrapper
                                      .getManagedBean("MbDinFeesSearchBottom");
        if (mbFee != null) {
            mbFee.clearFilter();
        }
    }

    private void setDefaultValues() {
        filter = new DinersFinMessage();
    }
}
