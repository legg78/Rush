package ru.bpc.sv2.ui.ps.visa.files;


import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.constants.SectionIdConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.VisaDao;
import ru.bpc.sv2.ps.visa.VisaFile;
import ru.bpc.sv2.ps.visa.VisaFinMessage;
import ru.bpc.sv2.ps.visa.VisaReturn;
import ru.bpc.sv2.ui.ps.visa.messages.MbVisaReturnSearchBottom;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.TableRowSelection;
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
@ManagedBean(name = "MbVisaFilesSearch")
public class MbVisaFilesSearch extends AbstractBean {
    private static final long serialVersionUID = 5662034143010595090L;

    private static final Logger logger = Logger.getLogger("VIS");

    private static final String FILE_FIN_MESSAGES_TAB = "fileFinMessagesTab";
    private static final String RETURN_TAB = "returnTab";

    private static final String FILE_FIN_MESSAGE_MANAGE_BEAN = "MbVisaFileFinMessagesBottom";
    private static final String RETURN_MANAGE_BEAN = "MbVisaReturnSearchBottom";

    private static String COMPONENT_ID = "fileFinMessageTable";

    private VisaDao visaDao = new VisaDao();


    private VisaFile filter;
    private final DaoDataModel<VisaFile> fileSource;

    private VisaFile activeItem;
    private final TableRowSelection<VisaFile> itemSelection;
    private HashMap<String, Boolean> loadedTabs = new HashMap<String, Boolean>();
    private String tabName;
    private String needRerender;
    private List<String> rerenderList;
    private Map<String, Object> paramMap;
    private Integer rejected;
    private List<SelectItem> yesNoLov;

    public MbVisaFilesSearch(){
        pageLink = "visa|files";
        fileSource = new DaoDataModel<VisaFile>(){
            private static final long serialVersionUID = 6886825197574225937L;
            @Override
            protected VisaFile[] loadDaoData(SelectionParams params) {
                if (!searching)
                    return new VisaFile[0];
                try {
                    setFilters();
                    params.setFilters(filters.toArray(new Filter[filters.size()]));
                    return visaDao.getFiles(userSessionId, params);
                } catch (Exception e) {
                    setDataSize(0);
                    FacesUtils.addMessageError(e);
                    logger.error("", e);
                }
                return new VisaFile[0];
            }
            @Override
            protected int loadDaoDataSize(SelectionParams params) {
                if (!searching)
                    return 0;
                try {
                    setFilters();
                    params.setFilters(filters.toArray(new Filter[filters.size()]));
                    return visaDao.getFilesCount(userSessionId, params);
                } catch (Exception e){
                    setDataSize(0);
                    FacesUtils.addMessageError(e);
                    logger.error("", e);
                }
                return 0;
            }
        };

        itemSelection = new TableRowSelection<VisaFile>(null, fileSource);
        tabName = "detailsTab";
    }

    @PostConstruct
    public void init() {
        setDefaultValues();
    }

    private void setFilters(){

        VisaFile fileFilter = getFilter();
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
        activeItem = (VisaFile)fileSource.getRowData();
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
            MbVisaFileFinMessagesBottom mbVisaFileFinMessage = (MbVisaFileFinMessagesBottom) ManagedBeanWrapper
                    .getManagedBean(FILE_FIN_MESSAGE_MANAGE_BEAN);
            VisaFinMessage visaFinMessageFilter = new VisaFinMessage();
            visaFinMessageFilter.setFileId(activeItem.getId());
            mbVisaFileFinMessage.setFilter(visaFinMessageFilter);
            mbVisaFileFinMessage.search();
        }
        else if (tabName.equalsIgnoreCase(RETURN_TAB)){
            MbVisaReturnSearchBottom mbReturn = (MbVisaReturnSearchBottom) ManagedBeanWrapper
                    .getManagedBean(RETURN_MANAGE_BEAN);
            VisaReturn visaReturnFilter = new VisaReturn();
            visaReturnFilter.setFileId(activeItem.getId());
            mbReturn.setFilter(visaReturnFilter);
            mbReturn.search();
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
        MbVisaFileFinMessagesBottom bean = (MbVisaFileFinMessagesBottom) ManagedBeanWrapper
                .getManagedBean(FILE_FIN_MESSAGE_MANAGE_BEAN);
        bean.clearFilter();
        MbVisaReturnSearchBottom returnBean = (MbVisaReturnSearchBottom) ManagedBeanWrapper
                .getManagedBean(RETURN_MANAGE_BEAN);
        returnBean.clearFilter();
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
            MbVisaFileFinMessagesBottom bean = (MbVisaFileFinMessagesBottom) ManagedBeanWrapper
                    .getManagedBean(FILE_FIN_MESSAGE_MANAGE_BEAN);
            bean.setTabName(tabName);
            bean.setParentSectionId(getSectionId());
            bean.setTableState(getSateFromDB(bean.getComponentId()));
        }

        if (tabName.equalsIgnoreCase(RETURN_TAB)) {
            MbVisaReturnSearchBottom bean = (MbVisaReturnSearchBottom) ManagedBeanWrapper
                    .getManagedBean(RETURN_MANAGE_BEAN);
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
    public void setFilter(VisaFile filter) {
        this.filter = filter;
    }

    public VisaFile getFilter() {
        if (filter == null){
            filter = new VisaFile();
        }
        return filter;
    }

    public DaoDataModel<VisaFile> getItems(){
        return fileSource;
    }
    public VisaFile getActiveItem(){
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
        filter = new VisaFile();
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


