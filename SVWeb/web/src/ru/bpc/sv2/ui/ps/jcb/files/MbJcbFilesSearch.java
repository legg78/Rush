package ru.bpc.sv2.ui.ps.jcb.files;


import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.constants.SectionIdConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.JcbDao;
import ru.bpc.sv2.ps.jcb.JcbFile;
import ru.bpc.sv2.ps.jcb.JcbFinMessage;
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
@ManagedBean(name = "MbJcbFilesSearch")
public class MbJcbFilesSearch extends AbstractBean {
    private static final long serialVersionUID = 1562402854449134601L;
    private static final Logger logger = Logger.getLogger("JCB");
    private static final String FILE_FIN_MESSAGES_TAB = "fileFinMessagesTab";
    private static final String FILE_FIN_MESSAGE_MANAGE_BEAN = "MbJcbFileFinMessagesBottom";
    private static final String COMPONENT_ID = "fileFinMessageTable";

    private JcbDao jcbDao = new JcbDao();
    private JcbFile filter;
    private final DaoDataModel<JcbFile> fileSource;
    private JcbFile activeItem;
    private final TableRowSelection<JcbFile> itemSelection;
    private HashMap<String, Boolean> loadedTabs = new HashMap<String, Boolean>();
    private String tabName;
    private String needRerender;
    private List<String> rerenderList;
    private Map<String, Object> paramMap;
    private List<SelectItem> yesNoLov;

    public MbJcbFilesSearch(){
        pageLink = "jcb|files";
        fileSource = new DaoDataModel<JcbFile>(){
            private static final long serialVersionUID = 6886825197574225937L;
            @Override
            protected JcbFile[] loadDaoData(SelectionParams params) {
                if (searching) {
                    try {
                        setFilters();
                        params.setFilters(filters.toArray(new Filter[filters.size()]));
                        return jcbDao.getJcbFiles(userSessionId, params);
                    } catch (Exception e) {
                        setDataSize(0);
                        FacesUtils.addMessageError(e);
                        logger.error("", e);
                    }
                }
                return new JcbFile[0];
            }
            @Override
            protected int loadDaoDataSize(SelectionParams params) {
                if (searching) {
                    try {
                        setFilters();
                        params.setFilters(filters.toArray(new Filter[filters.size()]));
                        return jcbDao.getJcbFilesCount(userSessionId, params);
                    } catch (Exception e){
                        setDataSize(0);
                        FacesUtils.addMessageError(e);
                        logger.error("", e);
                    }
                }
                return 0;
            }
        };
        itemSelection = new TableRowSelection<JcbFile>(null, fileSource);
        tabName = FILE_FIN_MESSAGES_TAB;
    }

    @PostConstruct
    public void init() {
        setDefaultValues();
    }

    private void setFilters(){

        JcbFile fileFilter = getFilter();
        filters = new ArrayList<Filter>();
        Filter paramFilter;

        if (fileFilter.getId()!= null){
            paramFilter = new Filter();
            paramFilter.setElement("fileId");
            paramFilter.setOp(Filter.Operator.eq);
            paramFilter.setValue(fileFilter.getId());
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
        activeItem = (JcbFile)fileSource.getRowData();
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
            MbJcbFileFinMessagesBottom mbFileFinMessage = (MbJcbFileFinMessagesBottom)ManagedBeanWrapper
                                                          .getManagedBean(FILE_FIN_MESSAGE_MANAGE_BEAN);
            JcbFinMessage jcbFinMessageFilter = new JcbFinMessage();
            jcbFinMessageFilter.setFileId(activeItem.getId());
            mbFileFinMessage.setFilter(jcbFinMessageFilter);
            mbFileFinMessage.search();
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
        setSearching(false);
        clearBean();
        setDefaultValues();
    }

    private void clearDependencies(){
        MbJcbFileFinMessagesBottom bean = (MbJcbFileFinMessagesBottom) ManagedBeanWrapper
                .getManagedBean(FILE_FIN_MESSAGE_MANAGE_BEAN);
        bean.clearFilter();
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
            MbJcbFileFinMessagesBottom bean = (MbJcbFileFinMessagesBottom) ManagedBeanWrapper
                    .getManagedBean(FILE_FIN_MESSAGE_MANAGE_BEAN);
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
    public void setFilter(JcbFile filter) {
        this.filter = filter;
    }

    public JcbFile getFilter() {
        if (filter == null){
            filter = new JcbFile();
        }
        return filter;
    }

    public DaoDataModel<JcbFile> getItems(){
        return fileSource;
    }
    public JcbFile getActiveItem(){
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
        filter = new JcbFile();
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

    public List<SelectItem> getYesNoLov() {
        if (yesNoLov == null) {
            yesNoLov = getDictUtils().getLov(LovConstants.BOOLEAN);
        }
        return yesNoLov;
    }
}

