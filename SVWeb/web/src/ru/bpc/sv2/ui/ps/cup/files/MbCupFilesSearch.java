package ru.bpc.sv2.ui.ps.cup.files;


import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.constants.SectionIdConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.CupDao;
import ru.bpc.sv2.ps.cup.CupFee;
import ru.bpc.sv2.ps.cup.CupFile;
import ru.bpc.sv2.ps.cup.CupFinMessage;
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
@ManagedBean(name = "MbCupFilesSearch")
public class MbCupFilesSearch extends AbstractBean {
    private static final long serialVersionUID = 1562402854449134601L;
    private static final Logger logger = Logger.getLogger("CUP");
    private static final String FILE_FIN_MESSAGES_TAB = "fileFinMessagesTab";
    private static final String FILE_FIN_MESSAGE_MANAGE_BEAN = "MbCupFileFinMessagesBottom";
    private static final String FILE_FEES_TAB = "fileFeesTab";
    private static final String FILE_FEE_MANAGE_BEAN = "MbCupFileFees";
    private static final String COMPONENT_ID = "fileFinMessageTable";

    private CupDao cupDao = new CupDao();
    private CupFile filter;
    private final DaoDataModel<CupFile> fileSource;
    private CupFile activeItem;
    private final TableRowSelection<CupFile> itemSelection;
    private HashMap<String, Boolean> loadedTabs = new HashMap<String, Boolean>();
    private String tabName;
    private String needRerender;
    private List<String> rerenderList;
    private Map<String, Object> paramMap;
    private List<SelectItem> yesNoLov;

    public MbCupFilesSearch(){
        pageLink = "cup|files";
        fileSource = new DaoDataModel<CupFile>(){
            private static final long serialVersionUID = 6886825197574225937L;
            @Override
            protected CupFile[] loadDaoData(SelectionParams params) {
                if (searching) {
                    try {
                        setFilters();
                        params.setFilters(filters.toArray(new Filter[filters.size()]));
                        return cupDao.getCupFiles(userSessionId, params);
                    } catch (Exception e) {
                        setDataSize(0);
                        FacesUtils.addMessageError(e);
                        logger.error("", e);
                    }
                }
                return new CupFile[0];
            }
            @Override
            protected int loadDaoDataSize(SelectionParams params) {
                if (searching) {
                    try {
                        setFilters();
                        params.setFilters(filters.toArray(new Filter[filters.size()]));
                        return cupDao.getCupFilesCount(userSessionId, params);
                    } catch (Exception e){
                        setDataSize(0);
                        FacesUtils.addMessageError(e);
                        logger.error("", e);
                    }
                }
                return 0;
            }
        };
        itemSelection = new TableRowSelection<CupFile>(null, fileSource);
        tabName = FILE_FIN_MESSAGES_TAB;
    }

    @PostConstruct
    public void init() {
        setDefaultValues();
    }

    private void setFilters(){

        CupFile fileFilter = getFilter();
        filters = new ArrayList<Filter>();
        Filter paramFilter;

        if (fileFilter.getId()!= null){
            paramFilter = new Filter();
            paramFilter.setElement("networkId");
            paramFilter.setOp(Filter.Operator.eq);
            paramFilter.setValue(fileFilter.getId());
            filters.add(paramFilter);
        }
        if (fileFilter.getInstituteId()!= null){
            paramFilter = new Filter();
            paramFilter.setElement("instituteId");
            paramFilter.setValue(fileFilter.getInstituteId());
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
        activeItem = (CupFile)fileSource.getRowData();
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
            MbCupFileFinMessagesBottom mbFileFinMessage = (MbCupFileFinMessagesBottom)ManagedBeanWrapper
                    .getManagedBean(FILE_FIN_MESSAGE_MANAGE_BEAN);
            CupFinMessage cupFinMessageFilter = new CupFinMessage();
            cupFinMessageFilter.setFileId(activeItem.getId());
            mbFileFinMessage.setFilter(cupFinMessageFilter);
            mbFileFinMessage.search();
        }

        if (tabName.equalsIgnoreCase(FILE_FEES_TAB)){
            MbCupFileFees mbFileFee = (MbCupFileFees)ManagedBeanWrapper
                    .getManagedBean(FILE_FEE_MANAGE_BEAN);
            CupFee cupFeeFilter = new CupFee();
            cupFeeFilter.setFileId(activeItem.getId());
            mbFileFee.setFilter(cupFeeFilter);
            mbFileFee.search();
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
        MbCupFileFinMessagesBottom bean = (MbCupFileFinMessagesBottom) ManagedBeanWrapper
                .getManagedBean(FILE_FIN_MESSAGE_MANAGE_BEAN);
        bean.clearFilter();

        MbCupFileFees feeBean = (MbCupFileFees) ManagedBeanWrapper
                .getManagedBean(FILE_FEE_MANAGE_BEAN);
        feeBean.clearFilter();
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
            MbCupFileFinMessagesBottom bean = (MbCupFileFinMessagesBottom) ManagedBeanWrapper
                    .getManagedBean(FILE_FIN_MESSAGE_MANAGE_BEAN);
            bean.setTabName(tabName);
            bean.setParentSectionId(getSectionId());
            bean.setTableState(getSateFromDB(bean.getComponentId()));
        }

        if (tabName.equalsIgnoreCase(FILE_FEES_TAB)) {
            MbCupFileFees bean = (MbCupFileFees) ManagedBeanWrapper
                    .getManagedBean(FILE_FEE_MANAGE_BEAN);
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
    public void setFilter(CupFile filter) {
        this.filter = filter;
    }

    public CupFile getFilter() {
        if (filter == null){
            filter = new CupFile();
        }
        return filter;
    }

    public DaoDataModel<CupFile> getItems(){
        return fileSource;
    }
    public CupFile getActiveItem(){
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
        filter = new CupFile();
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

    @Override
    protected void applySectionFilter(Integer filterId) {
        try {
            FilterFactory factory = (FilterFactory) ManagedBeanWrapper
                    .getManagedBean("filterFactory");
            Map<String, String> filterRec = factory.getSectionFilterRecs(filterId);
            sectionFilter = factory.getUserSectionFiltersObjects().get(filterId);
            if (filterRec != null) {
                filter = new CupFile();
                if (filterRec.get("instituteId") != null) {
                    filter.setInstituteId(Integer.parseInt(filterRec.get("instituteId")));
                }
                String dbDateFormat = "dd.MM.yyyy";
                SimpleDateFormat df = new SimpleDateFormat(dbDateFormat);
                if (filterRec.get("dateFrom") != null) {
                    filter.setDateFrom(df.parse(filterRec.get("dateFrom")));
                }
                if (filterRec.get("networkId") != null) {
                    filter.setNetworkId(Integer.parseInt(filterRec.get("networkId")));
                }
                if (filterRec.get("dateTo") != null) {
                    filter.setDateTo(df.parse(filterRec.get("dateTo")));
                }
            }
            if (searchAutomatically) {
                search();
            }
            sectionFilterModeEdit = true;
        } catch (Exception e) {
            FacesUtils.addMessageError(e);
            logger.error("", e);
        }
    }

    @Override
    public void saveSectionFilter() {
        try {
            FilterFactory factory = (FilterFactory) ManagedBeanWrapper
                    .getManagedBean("filterFactory");

            Map<String, String> filterRec = new HashMap<String, String>();
            filter = getFilter();
            if (filter.getInstituteId() != null) {
                filterRec.put("instituteId", filter.getInstituteId().toString());
            }
            String dbDateFormat = "dd.MM.yyyy";
            SimpleDateFormat df = new SimpleDateFormat(dbDateFormat);
            if (filter.getDateFrom() != null) {
                filterRec.put("dateFrom", df.format(filter.getDateFrom()));
            }
            if (filter.getNetworkId() != null) {
                filterRec.put("networkId", filter.getNetworkId().toString());
            }
            if (filter.getDateTo() != null) {
                filterRec.put("dateTo", df.format(filter.getDateTo()));
            }
            sectionFilter = getSectionFilter();
            sectionFilter.setRecs(filterRec);

            factory.saveSectionFilter(sectionFilter, sectionFilterModeEdit);
            selectedSectionFilter = sectionFilter.getId();
            sectionFilterModeEdit = true;
        } catch (Exception e) {
            FacesUtils.addMessageError(e);
            logger.error("", e);
        }
    }
}

