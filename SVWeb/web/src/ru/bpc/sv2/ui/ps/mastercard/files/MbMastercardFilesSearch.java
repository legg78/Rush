package ru.bpc.sv2.ui.ps.mastercard.files;


import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.constants.SectionIdConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.MastercardDao;
import ru.bpc.sv2.ps.mastercard.*;

import ru.bpc.sv2.ui.ps.mastercard.messages.MbMcwRejectSearchBottom;
import ru.bpc.sv2.ui.utils.*;
import util.auxil.ManagedBeanWrapper;


import javax.annotation.PostConstruct;

import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.model.SelectItem;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@ViewScoped
@ManagedBean(name = "MbMastercardFilesSearch")
public class MbMastercardFilesSearch extends AbstractBean {
    private static final long serialVersionUID = 1562402854449134601L;

    private static final Logger logger = Logger.getLogger("MCW");

    private static final String FILE_FIN_MESSAGES_TAB = "fileFinMessagesTab";
    private static final String REJECT_TAB = "rejectTab";

    private static final String FILE_FIN_MESSAGE_MANAGE_BEAN = "MbFileFinMessagesBottom";
    private static final String REJECT_MANAGE_BEAN = "MbMcwRejectSearchBottom";



    private static String COMPONENT_ID = "fileFinMessageTable";

    private MastercardDao masterDao = new MastercardDao();


    private MasterFile filter;
    private final DaoDataModel<MasterFile> fileSource;

    private MasterFile activeItem;
    private final TableRowSelection<MasterFile> itemSelection;
    private HashMap<String, Boolean> loadedTabs = new HashMap<String, Boolean>();
    private String tabName;
    private String needRerender;
    private List<String> rerenderList;
    private Map<String, Object> paramMap;
    private Integer rejected;
    private List<SelectItem> yesNoLov;

    public MbMastercardFilesSearch(){
        pageLink = "mastercard|files";
        fileSource = new DaoDataListModel<MasterFile>(logger){
            private static final long serialVersionUID = 6886825197574225937L;

            @Override
            protected List<MasterFile> loadDaoListData(SelectionParams params) {
                if (isSearching()) {
                    setFilters();
                    params.setFilters(filters);
                    return masterDao.getFiles(userSessionId, params);
                }
                return new ArrayList<MasterFile>();
            }

            @Override
            protected int loadDaoDataSize(SelectionParams params) {
                if (isSearching()) {
                    setFilters();
                    params.setFilters(filters);
                    return masterDao.getFilesCount(userSessionId, params);
                }
                return 0;
            }
        };

        itemSelection = new TableRowSelection<MasterFile>(null, fileSource);
        tabName = "detailsTab";
    }

    @PostConstruct
    public void init() {
        setDefaultValues();
    }

    private void setFilters(){

        MasterFile fileFilter = getFilter();
        filters = new ArrayList<Filter>();
        Filter paramFilter;

        if (fileFilter.getId()!= null){
            paramFilter = new Filter();
            paramFilter.setElement("fileId");
            paramFilter.setOp(Filter.Operator.eq);
            paramFilter.setValue(fileFilter.getId());
            filters.add(paramFilter);
        }


        if (fileFilter.getSessionId()!= null){
            paramFilter = new Filter();
            paramFilter.setElement("sessionId");
            paramFilter.setOp(Filter.Operator.eq);
            paramFilter.setValue(fileFilter.getSessionId());
            filters.add(paramFilter);
        }

        if (fileFilter.getFileName()!= null && fileFilter.getFileName().trim().length() > 0){
            paramFilter = new Filter();
            paramFilter.setElement("fileName");
            paramFilter.setOp(Filter.Operator.like);
            paramFilter.setValue(fileFilter.getFileName().trim().toUpperCase()
                    .replaceAll("[*]", "%").replaceAll("[?]", "_"));
            filters.add(paramFilter);
        }

        String dbDateFormat = "dd.MM.yyyy";
        SimpleDateFormat df = new SimpleDateFormat(dbDateFormat);
        if (fileFilter.getDateFrom() != null) {
            paramFilter = new Filter();
            paramFilter.setElement("dateFrom");
            paramFilter.setValue(df.format(fileFilter.getDateFrom()));
            filters.add(paramFilter);
        }
        if (fileFilter.getDateTo() != null) {
            paramFilter = new Filter();
            paramFilter.setElement("dateTo");
            paramFilter.setValue(df.format(fileFilter.getDateTo()));
            filters.add(paramFilter);
        }

        if (rejected != null) {
            filters.add(new Filter("isRejected", rejected));
        }

        paramFilter = new Filter();
        paramFilter.setElement("lang");
        paramFilter.setValue(userLang);
        filters.add(paramFilter);
    }

    public SimpleSelection getItemSelection(){
        if (activeItem == null && fileSource.getRowCount() > 0){
            setFirstRowActive();
        } else if (activeItem != null && fileSource.getRowCount() > 0){
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
        fileSource.setRowIndex(0);
        SimpleSelection selection = new SimpleSelection();
        activeItem = (MasterFile)fileSource.getRowData();
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

        if (tabName.equalsIgnoreCase(FILE_FIN_MESSAGES_TAB)){
            MbFileFinMessagesBottom mbFileFinMessage = (MbFileFinMessagesBottom) ManagedBeanWrapper
                    .getManagedBean(FILE_FIN_MESSAGE_MANAGE_BEAN);
            MasterFinMessage masterFinMessageFilter = new MasterFinMessage();
            masterFinMessageFilter.setFileId(activeItem.getId());
            mbFileFinMessage.setFilter(masterFinMessageFilter);
            mbFileFinMessage.search();
        }
        else if (tabName.equalsIgnoreCase(REJECT_TAB)){
            MbMcwRejectSearchBottom mbReject = (MbMcwRejectSearchBottom) ManagedBeanWrapper
                    .getManagedBean(REJECT_MANAGE_BEAN);
            McwReject mcwRejectFilter = new McwReject();
            mcwRejectFilter.setFileId(activeItem.getId().intValue());
            mbReject.setFilter(mcwRejectFilter);
            mbReject.search();
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
        fileSource.flushCache();
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
        MbFileFinMessagesBottom bean = (MbFileFinMessagesBottom) ManagedBeanWrapper
                .getManagedBean(FILE_FIN_MESSAGE_MANAGE_BEAN);
        bean.clearFilter();
        MbMcwRejectSearchBottom rejectBean = (MbMcwRejectSearchBottom) ManagedBeanWrapper
                .getManagedBean(REJECT_MANAGE_BEAN);
        rejectBean.clearFilter();
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

        if (tabName.equalsIgnoreCase(FILE_FIN_MESSAGES_TAB)) {
            MbFileFinMessagesBottom bean = (MbFileFinMessagesBottom) ManagedBeanWrapper
                    .getManagedBean(FILE_FIN_MESSAGE_MANAGE_BEAN);
            bean.setTabName(tabName);
            bean.setParentSectionId(getSectionId());
            bean.setTableState(getSateFromDB(bean.getComponentId()));
        }

        if (tabName.equalsIgnoreCase(REJECT_TAB)) {
            MbMcwRejectSearchBottom bean = (MbMcwRejectSearchBottom) ManagedBeanWrapper
                    .getManagedBean(REJECT_MANAGE_BEAN);
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
    public void setFilter(MasterFile filter) {
        this.filter = filter;
    }

    public MasterFile getFilter() {
        if (filter == null){
            filter = new MasterFile();
        }
        return filter;
    }

    public DaoDataModel<MasterFile> getItems(){
        return fileSource;
    }
    public MasterFile getActiveItem(){
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
        filter = new MasterFile();
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
}

