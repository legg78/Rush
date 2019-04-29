package ru.bpc.sv2.ui.ps.nbc.messages;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.annotation.PostConstruct;

import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.model.SelectItem;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;

import ru.bpc.sv2.constants.SectionIdConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.NbcDao;
import ru.bpc.sv2.ps.nbc.NbcFinMessage;
import ru.bpc.sv2.ui.utils.*;

@ViewScoped
@ManagedBean (name = "MbNbcFinMessagesSearch")
public class MbNbcFinMessagesSearch extends AbstractBean{
    private static final long serialVersionUID = 9180917082872879256L;

    private static final Logger logger = Logger.getLogger("OPER_RPOCESSING");

    private static final String DETAILS_TAB = "nbcFinMessagesDetailsTab";

    private static final int DISPUTE_RES_LOV = 521;

    private static String COMPONENT_ID = "1982:nbcFinTable";

    private NbcDao nbcDao = new NbcDao();

    private NbcFinMessage filter;
    private final DaoDataModel<NbcFinMessage> messageSource;

    private NbcFinMessage activeItem;
    private NbcFinMessage newFinMessage;
    private final TableRowSelection<NbcFinMessage> itemSelection;
    private HashMap<String, Boolean> loadedTabs = new HashMap<String, Boolean>();
    private String tabName;
    private String needRerender;
    private List<String> rerenderList;
    private Map<String, Object> paramMap;

    public MbNbcFinMessagesSearch(){
        pageLink = "nbc|financial_messages";
        messageSource = new DaoDataListModel<NbcFinMessage>(logger){
            private static final long serialVersionUID = 6886825197574225937L;
            @Override
            protected List<NbcFinMessage> loadDaoListData(SelectionParams params) {
                if (!searching)
                    return new ArrayList<NbcFinMessage>();
                try {
                    setFilters();
                    params.setFilters(filters.toArray(new Filter[filters.size()]));
                    return nbcDao.getFinancialMessages(userSessionId, params);
                } catch (Exception e) {
                    setDataSize(0);
                    FacesUtils.addMessageError(e);
                    logger.error("", e);
                }
                return new ArrayList<NbcFinMessage>();
            }
            @Override
            protected int loadDaoDataSize(SelectionParams params) {
                if (!searching)
                    return 0;
                try {
                    setFilters();
                    params.setFilters(filters.toArray(new Filter[filters.size()]));
                    return nbcDao.getFinancialMessagesCount(userSessionId, params);
                } catch (Exception e){
                    setDataSize(0);
                    FacesUtils.addMessageError(e);
                    logger.error("", e);
                }
                return 0;
            }
        };

        itemSelection = new TableRowSelection<NbcFinMessage>(null, messageSource);
        tabName = DETAILS_TAB;
    }

    @PostConstruct
    public void init() {
        setDefaultValues();
    }

    private void setFilters(){
        NbcFinMessage messageFilter = getFilter();
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

        if (messageFilter.getCardMask() != null && messageFilter.getCardMask().trim().length() > 0){
            filters.add(new Filter("cardMask", messageFilter.getCardMask().trim().toUpperCase()
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

    public boolean isDisableEditButton() {
        if (activeItem == null) {
            return (true);
        }
        else {
            if ("CLMS0040".equals(activeItem.getStatus())) {
                if ("DSP".equals(activeItem.getParticipantType()) && "DF".equals(activeItem.getMsgFileType())) {
                    return (false);
                }
                return (true);
            }
            else {
                return (false);
            }
        }
    }

    private void setFirstRowActive(){
        messageSource.setRowIndex(0);
        SimpleSelection selection = new SimpleSelection();
        activeItem = (NbcFinMessage)messageSource.getRowData();
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

    public void edit() {
        try {
            newFinMessage = (NbcFinMessage) activeItem.clone();
        } catch (CloneNotSupportedException e) {
            logger.error("", e);
            newFinMessage = activeItem;
        }
        curMode = EDIT_MODE;
    }

    public void save() {
        try {
            newFinMessage = nbcDao.modifyFinMessage(userSessionId, newFinMessage);
            messageSource.replaceObject(activeItem, newFinMessage);
            activeItem = newFinMessage;
            setInfo();
            curMode = VIEW_MODE;
        } catch (Exception e) {
            FacesUtils.addMessageError(e);
            logger.error("", e);
        }
    }

    private void loadTab(String tabName){
        if (tabName == null){
            return;
        }

        if (activeItem == null){
            return;
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
        itemSelection.clearSelection();
        activeItem = null;
    }

    public void clearFilter(){
        filter = null;
        setSearching(false);
        clearBean();
        setDefaultValues();
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
    public void setFilter(NbcFinMessage filter) {
        this.filter = filter;
    }

    public NbcFinMessage getFilter() {
        if (filter == null){
            filter = new NbcFinMessage();
        }
        return filter;
    }

    public DaoDataModel<NbcFinMessage> getItems(){
        return messageSource;
    }
    public NbcFinMessage getActiveItem(){
        return activeItem;
    }
    public NbcFinMessage getNewFinMessage() {
        return newFinMessage;
    }

    public void setNewFinMessage(NbcFinMessage newFinMessage) {
        this.newFinMessage = newFinMessage;
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

    public List<SelectItem> getLovValues() {
        return getDictUtils().getLov(DISPUTE_RES_LOV);
    }

    public String getComponentId() {
        return COMPONENT_ID;
    }

    public Logger getLogger() {
        return logger;
    }

    private void setDefaultValues() {
        filter = new NbcFinMessage();
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
