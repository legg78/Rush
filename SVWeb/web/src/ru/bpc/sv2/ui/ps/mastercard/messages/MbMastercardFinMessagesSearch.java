package ru.bpc.sv2.ui.ps.mastercard.messages;

import java.text.SimpleDateFormat;
import java.util.*;

import javax.annotation.PostConstruct;

import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.model.SelectItem;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;

import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.constants.SectionIdConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.Filter.Operator;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.MastercardDao;
import ru.bpc.sv2.ps.mastercard.MasterFinMessage;
import ru.bpc.sv2.ps.mastercard.MasterFinMessageAddendum;
import ru.bpc.sv2.ui.utils.*;
import util.auxil.ManagedBeanWrapper;

@ViewScoped
@ManagedBean (name = "MbMastercardFinMessagesSearch")
public class MbMastercardFinMessagesSearch extends AbstractBean{
    private static final long serialVersionUID = 9180917082872879256L;

    private static final Logger logger = Logger.getLogger("CREDIT"); //todo must be changed to appropriate

    private static final String ADDENDUM_TAB = "addendumTab";
    private static final String REJECT_TAB = "rejectTab";
    private static final String REJECT_CODE_TAB = "rejectCodeTab";
    private static final String DETAILS_TAB = "masterFinMessageDetailsTab";

    private static String COMPONENT_ID = "1982:finMessageTable"; //todo must be changed

    private MastercardDao masterDao = new MastercardDao();

    private ArrayList<SelectItem> institutions;
    private MasterFinMessage filter;
    private final DaoDataModel<MasterFinMessage> messageSource;

    private MasterFinMessage activeItem;
    private MasterFinMessage newFinMessage;
    private final TableRowSelection<MasterFinMessage> itemSelection;
    private HashMap<String, Boolean> loadedTabs = new HashMap<String, Boolean>();
    private String tabName;
    private String needRerender;
    private List<String> rerenderList;
    private Map<String, Object> paramMap;
    private Integer rejected;
    private List<SelectItem> yesNoLov;
    
    public MbMastercardFinMessagesSearch(){
        pageLink = "mastercard|financial_messages";
        messageSource = new DaoDataListModel<MasterFinMessage>(logger){
            private static final long serialVersionUID = 6886825197574225937L;
            @Override
            protected List<MasterFinMessage> loadDaoListData(SelectionParams params) {
                if (isSearching()) {
                    setFilters();
                    params.setFilters(filters);
                    return masterDao.getFinancialMessages(userSessionId, params);
                }
                return new ArrayList<MasterFinMessage>();
            }
            @Override
            protected int loadDaoDataSize(SelectionParams params) {
                if (isSearching()) {
                    setFilters();
                    params.setFilters(filters);
                    return masterDao.getFinancialMessagesCount(userSessionId, params);
                }
                return 0;
            }
        };

        itemSelection = new TableRowSelection<MasterFinMessage>(null, messageSource);
        tabName = DETAILS_TAB;
    }

    @PostConstruct
    public void init() {
        setDefaultValues();
    }

    private void setFilters(){
        //todo must be revisited
        MasterFinMessage messageFilter = getFilter();
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
        
        if (rejected != null) {
        	filters.add(new Filter("isRejected", rejected));
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
        activeItem = (MasterFinMessage)messageSource.getRowData();
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
			newFinMessage = (MasterFinMessage) activeItem.clone();
		} catch (CloneNotSupportedException e) {
			logger.error("", e);
			newFinMessage = activeItem;
		}
		curMode = EDIT_MODE;
	}
    
    public void save() {
		try {
			newFinMessage = masterDao.modifyFinMessage(userSessionId, newFinMessage);
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

        if (tabName.equalsIgnoreCase(ADDENDUM_TAB)){
            MbMasterFinMessageAddendum mbAddendum = (MbMasterFinMessageAddendum) ManagedBeanWrapper
                    .getManagedBean("MbMasterFinMessageAddendum");
            MasterFinMessageAddendum addendumFilter = new MasterFinMessageAddendum();
            addendumFilter.setFinId(activeItem.getId());
            mbAddendum.setFilter(addendumFilter);
            mbAddendum.search();
        } else if (tabName.equalsIgnoreCase(REJECT_TAB)){
            MbMcwRejectSearchBottom mbReject = (MbMcwRejectSearchBottom) ManagedBeanWrapper
                    .getManagedBean("MbMcwRejectSearchBottom");
            mbReject.loadReject(activeItem.getRejectId());
        } else if (tabName.equalsIgnoreCase(REJECT_CODE_TAB)){
        	MbMcwRejectCodeSearchBottom mbRejectCode = (MbMcwRejectCodeSearchBottom) ManagedBeanWrapper
                    .getManagedBean("MbMcwRejectCodeSearchBottom");
        	if (activeItem.getRejectId() != null) {
	        	Map<String, Object> params = new HashMap<String, Object>();
	        	params.put("rejectId", activeItem.getRejectId());
	            mbRejectCode.setFilterMap(params);
	            mbRejectCode.search();
        	}
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
        rejected = null;
        setSearching(false);
        clearBean();
        setDefaultValues();
    }

    private void clearDependencies(){
        MbMasterFinMessageAddendum bean = (MbMasterFinMessageAddendum) ManagedBeanWrapper
                .getManagedBean("MbMasterFinMessageAddendum");
        bean.clearFilter();
        
        MbMcwRejectSearchBottom rejectBean = (MbMcwRejectSearchBottom) ManagedBeanWrapper
                .getManagedBean("MbMcwRejectSearchBottom");
        rejectBean.clearFilter();
        
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

        if (tabName.equalsIgnoreCase(ADDENDUM_TAB)) {
            MbMasterFinMessageAddendum bean = (MbMasterFinMessageAddendum) ManagedBeanWrapper
                    .getManagedBean("MbMasterFinMessageAddendum");
            bean.setTabName(tabName);
            bean.setParentSectionId(getSectionId());
            bean.setTableState(getSateFromDB(bean.getComponentId()));
        }
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
    public void setFilter(MasterFinMessage filter) {
        this.filter = filter;
    }

    public MasterFinMessage getFilter() {
        if (filter == null){
            filter = new MasterFinMessage();
        }
        return filter;
    }

    public DaoDataModel<MasterFinMessage> getItems(){
        return messageSource;
    }
    public MasterFinMessage getActiveItem(){
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
        filter = new MasterFinMessage();
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

	public MasterFinMessage getNewFinMessage() {
		if (newFinMessage == null) {
			newFinMessage = new MasterFinMessage();
		}
		return newFinMessage;
	}

	public void setNewFinMessage(MasterFinMessage newFinMessage) {
		this.newFinMessage = newFinMessage;
	}
	
}
