package ru.bpc.sv2.ui.vch;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;
import ru.bpc.sv2.acquiring.Merchant;
import ru.bpc.sv2.acquiring.Terminal;
import ru.bpc.sv2.constants.DictNames;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.constants.SectionIdConstants;
import ru.bpc.sv2.constants.application.ApplicationConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.VchDao;
import ru.bpc.sv2.ui.acquiring.MbMerchant;
import ru.bpc.sv2.ui.acquiring.MbTerminal;
import ru.bpc.sv2.ui.utils.*;
import ru.bpc.sv2.vch.VouchersBatch;
import util.auxil.ManagedBeanWrapper;

import javax.annotation.PostConstruct;

import ru.bpc.sv2.logic.utility.db.DataAccessException;
import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.model.SelectItem;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@ViewScoped
@ManagedBean (name = "MbVouchersBatches")
public class MbVouchersBatches extends AbstractBean {
	private static final long serialVersionUID = 7371827885726560796L;

	private static final Logger logger = Logger.getLogger("VCH");
	
	private VchDao vchDao = new VchDao();
	
	private CurrencyUtils currencyUtils;
	private MbMerchant mbMerchant;
	private MbTerminal mbTerminal;
	private MbVouchers mbVouchers;
	
	private VouchersBatch filter;
	private Merchant selectedMerchant;
	private Terminal selectedTerminal;
	
	private VouchersBatch activeItem;
	
	private final DaoDataModel<VouchersBatch> dataModel;
	private final TableRowSelection<VouchersBatch> tableRowSelection;
	
	private VouchersBatch editingItem;
	private List<SelectItem> cachedCardNetwork;
	private List<SelectItem> cachedUserNames;
	private List<SelectItem> cachedInstitutions;
	
	private static final String COMPONENT_ID = "VouchersBatchTable";
	private String tabName;
	private String parentSectionId;
	private List<SelectItem> statuses;
	private List<SelectItem> statusReasons;

	public MbVouchersBatches(){
		pageLink = "vch|vouchersBatches";
		tabName = "detailsTab";
		currencyUtils = (CurrencyUtils) ManagedBeanWrapper.getManagedBean("CurrencyUtils");
		mbMerchant = (MbMerchant) ManagedBeanWrapper.getManagedBean("MbMerchant");
		mbTerminal = (MbTerminal) ManagedBeanWrapper.getManagedBean("MbTerminal");
		mbVouchers = (MbVouchers) ManagedBeanWrapper.getManagedBean("MbVouchers");
		dataModel = new DaoDataModel<VouchersBatch>(){
			private static final long serialVersionUID = 4078179653690240433L;

			@Override
			protected VouchersBatch[] loadDaoData(SelectionParams params) {
				VouchersBatch[] result = null;
				if (searching) {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					try{
						result = vchDao.getVouchersBatches(userSessionId, params);
					}catch (DataAccessException e){
			    		FacesUtils.addMessageError(e);
    					logger.error("", e);
					}
				} else {
					result = new VouchersBatch[0];
				}
				return result;
			}
			
			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				int result = 0;
				if (searching){
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					try{
						result = vchDao.getVouchersBatchesCount(userSessionId, params);
					}catch (DataAccessException e){
			    		FacesUtils.addMessageError(e);
    					logger.error("", e);						
					}
				} else {
					result = 0;
				}
				return result;
			}
		};
		tableRowSelection = new TableRowSelection<VouchersBatch>(null, dataModel);
		statuses = getDictUtils().getArticles(DictNames.VOUCHERS_BATCH_STATUS, true, true);
		statusReasons = getDictUtils().getArticles(DictNames.STATUS_REASON, true, true);
	}
	
	@PostConstruct
	public void init() {
		setDefaultValues();
	}
	
	private void setFilters() {
		filters = new ArrayList<Filter>();
		
		Filter f = new Filter();
		f.setElement("lang");
		f.setValue(curLang);
		filters.add(f);
		
		if (filter.getTerminalId() != null){
			f = new Filter();
			f.setElement("terminalId");
			f.setValue(filter.getTerminalId());
			filters.add(f);
		}
		
		if (filter.getMerchantId() != null){
			f = new Filter();
			f.setElement("merchantId");
			f.setValue(filter.getMerchantId());
			filters.add(f);			
		}
		
		if (filter.getInstId() != null){
			f = new Filter();
			f.setElement("instId");
			f.setValue(filter.getInstId());
			filters.add(f);
		}
	}
	
	public void search() {
		clearState();
		clearBeansStates();
		searching = true;
	}
	
	public void clearState() {
		tableRowSelection.clearSelection();
		activeItem = null;
		dataModel.flushCache();
		curLang = userLang;
	}
	
	public void clearBeansStates(){
		mbVouchers.clearFilter();
	}
	
	public void clearFilter() {
		filter = null;
		clearState();
		clearBeansStates();
		setDefaultValues();
		searching = false;
		selectedMerchant = null;
		selectedTerminal = null;
	}
	
	public void createNewVouchersBatch(){
		editingItem = new VouchersBatch();
		editingItem.setTerminalId(filter.getTerminalId());
		editingItem.setMerchantId(filter.getMerchantId());
		editingItem.setInstId(filter.getInstId());
		
		curMode = AbstractBean.NEW_MODE;
	}
	
	public void editActiveVouchersBatch(){
		editingItem = activeItem;
		curMode = AbstractBean.EDIT_MODE;
	}
	
	public void saveEditingVouchersBatch(){
		try {
			if (isNewMode()) {
				editingItem = vchDao.createVouchersBatch(userSessionId, editingItem);
			} else if (isEditMode()) {
				editingItem = vchDao.modifyVouchersBatch(userSessionId, editingItem);
			}
		}catch (DataAccessException e){
			FacesUtils.addMessageError(e);
			logger.error("", e);
			return;
		}
		if (isNewMode()) {
			tableRowSelection.addNewObjectToList(editingItem);
		} else {
			try{
				dataModel.replaceObject(activeItem, editingItem);
			}catch(Exception e){
				e.printStackTrace();
			}
		}
		activeItem = editingItem;
		resetEditingVouchersBatch();
	}
	
	public void resetEditingVouchersBatch(){
		curMode = AbstractBean.VIEW_MODE;
		editingItem = null;
	}
	
	public void deleteActiveVouchersBatch(){
		try{
			vchDao.removeVouchersBatch(userSessionId, activeItem);
		}catch (DataAccessException e){
			FacesUtils.addMessageError(e);
			logger.error("", e);
			return;
		}
		activeItem = tableRowSelection.removeObjectFromList(activeItem);		
		if (activeItem == null){
			clearState();
		}
	}

	public SimpleSelection getItemSelection() {
		if (activeItem == null && dataModel.getRowCount() > 0){
			prepareItemSelection();
		}
		return tableRowSelection.getWrappedSelection();
	}
	
	public void prepareItemSelection(){
		dataModel.setRowIndex(0);
		SimpleSelection selection = new SimpleSelection();
		activeItem = (VouchersBatch)dataModel.getRowData();
		selection.addKey(activeItem.getModelId());
		tableRowSelection.setWrappedSelection(selection);
		if (activeItem != null) {
			setBeansState();
		}
	}
	
	public void setItemSelection(SimpleSelection selection) {
		tableRowSelection.setWrappedSelection(selection);
		activeItem = tableRowSelection.getSingleSelection();
		if (activeItem != null) {
			setBeansState();
		}
	}
	
	private void setBeansState(){
		mbVouchers.clearFilter();
		mbVouchers.getFilter().setBatchId(activeItem.getId());
		mbVouchers.search();
	}
	
	public VouchersBatch getFilter() {
		if (filter == null) {
			filter = new VouchersBatch();
		}
		return filter;
	}
	
	public DaoDataModel<VouchersBatch> getDataModel(){
		return dataModel;
	}
	
	public VouchersBatch getActiveItem(){
		return activeItem;
	}
	
	public VouchersBatch getEditingItem(){
		return editingItem;
	}
	
	public List<SelectItem> getStatuses(){
		return statuses;
	}
	
	public List<SelectItem> getCurrencies(){
		return currencyUtils.getAllCurrencies();
	}
	public List<SelectItem> getStatusReasons(){
		return statusReasons;
	}
	
	public List<SelectItem> getCardNetworks(){
		if (cachedCardNetwork == null){
			cachedCardNetwork = getDictUtils().getLov(LovConstants.CARD_NETWORK);
		}
		return cachedCardNetwork;
	}
	
	public List<SelectItem> getUserNames(){
		if (cachedUserNames == null){
			cachedUserNames = getDictUtils().getLov(LovConstants.USER_NAME);
		}
		return cachedUserNames;
	}
	
	public void loadMerchant(){
		selectedMerchant = mbMerchant.getNode();
        if (selectedMerchant != null && mbMerchant.getNodeChildren() != null && mbMerchant.getNodeChildren().size() > 0) {
			getFilter().setMerchantId(selectedMerchant.getId().intValue());
			if (selectedTerminal != null && selectedMerchant != null){
				if (!new Integer(selectedMerchant.getId().intValue()).equals(selectedTerminal.getMerchantId())){
					selectedTerminal = null;
					getFilter().setMerchantId(null);
				}
			}
		}
	}

	public Merchant getSelectedMerchant() {
		if (selectedMerchant == null){
			selectedMerchant = new Merchant();
		}
		return selectedMerchant;
	}

	public void setSelectedMerchant(Merchant merchantFilter) {
		this.selectedMerchant = merchantFilter;
	}

	public void resetSelectedMerchant(){
		selectedMerchant = null;
		getFilter().setMerchantId(null);
	}

	public Terminal getSelectedTerminal() {
		if (selectedTerminal == null){
			selectedTerminal = new Terminal();
		}
		return selectedTerminal;
	}

	public void setSelectedTerminal(Terminal terminalFilter) {
		this.selectedTerminal = terminalFilter;		
	}
	
	public void loadTerminal(){
		selectedTerminal = mbTerminal.getActiveTerminal();
        if (selectedTerminal != null) {
	        getFilter().setTerminalId(selectedTerminal.getId());
	        getFilter().setMerchantId(selectedTerminal.getMerchantId());
	        findMerchant(selectedTerminal.getMerchantId(), selectedTerminal.getInstId());
        }
	}

	private void findMerchant(Integer merchantId, Integer instId){
		MbMerchant merchants = ManagedBeanWrapper.getManagedBean(MbMerchant.class);
		merchants.getFilter().setId(merchantId.longValue());
		merchants.getFilter().setInstId(instId);
		merchants.searchMerchants();
		if (merchants.getNode() != null){
			selectedMerchant = merchants.getNode();
			if (mbMerchant.getNodeChildren() != null && mbMerchant.getNodeChildren().size() > 0)
				getFilter().setMerchantId(selectedMerchant.getId().intValue());
		}
	}
	
	public void resetSelectedTerminal(){
		selectedTerminal = null;
		getFilter().setTerminalId(null);
	}
	
	public List<SelectItem> getInstitutions(){
		if (cachedInstitutions == null){
			cachedInstitutions = getDictUtils().getLov(LovConstants.INSTITUTIONS);
		}
		return cachedInstitutions;
	}

	private void setDefaultValues() {
		if (sectionFilterModeEdit) return;
		
		Integer defaultInstId;
		List<SelectItem> instList = getInstitutions();
		if (userInstId == ApplicationConstants.DEFAULT_INSTITUTION && !instList.isEmpty()) {
			// instId from LOV is for some reason String 
			defaultInstId = Integer.valueOf((String) getInstitutions().get(0).getValue());
		} else {
			defaultInstId = userInstId;
		}

		filter = new VouchersBatch();
		filter.setInstId(defaultInstId);
	}
	
	public String getComponentId() {
		return parentSectionId + ":" + tabName + ":" + COMPONENT_ID;
	}

	public void setTabName(String tabName) {
		this.tabName = tabName;
		
		if (tabName.equalsIgnoreCase("vouchersTab")) {
			MbVouchers bean = (MbVouchers) ManagedBeanWrapper
					.getManagedBean("MbVouchers");
			bean.setTabName(tabName);
			bean.setParentSectionId(getSectionId());
			bean.setTableState(getSateFromDB(bean.getComponentId()));
		}
	}
	
	public String getTabName() {
		return tabName;
	}

	public void keepTabName(String tabName) {
		this.tabName = tabName;
	}

	public String getSectionId() {
		return SectionIdConstants.ACQUIRING_VCH_BATCH;
	}
	
	public void setParentSectionId(String parentSectionId) {
		this.parentSectionId = parentSectionId;
	}

	public void clearMerchantFilter(){
		MbMerchant merchant = (MbMerchant) ManagedBeanWrapper.getManagedBean(MbMerchant.class);
		merchant.clearFilter();
		if (selectedMerchant != null){
			merchant.getFilter().setMerchantNumber(selectedMerchant.getMerchantNumber());
		}

	}

	public  void clearTerminalFilter(){
		MbTerminal terminal = (MbTerminal) ManagedBeanWrapper.getManagedBean(MbTerminal.class);
		terminal.clearFilter();
		if (selectedTerminal != null){
			terminal.getFilter().setTerminalNumber(selectedTerminal.getTerminalNumber());
		}
		if (selectedMerchant != null){
			terminal.getFilter().setMerchantNumber(selectedMerchant.getMerchantNumber());
		}
	}

	@Override
	protected void applySectionFilter(Integer filterId) {
		try {
			FilterFactory factory = (FilterFactory) ManagedBeanWrapper
					.getManagedBean("filterFactory");
			Map<String, String> filterRec = factory.getSectionFilterRecs(filterId);
			sectionFilter = factory.getUserSectionFiltersObjects().get(filterId);
			if (filterRec != null) {
				filter = new VouchersBatch();
				if (filterRec.get("instId") != null) {
					filter.setInstId(Integer.parseInt(filterRec.get("instId")));
				}

				selectedMerchant = getSelectedMerchant();
				if (filterRec.get("merchantNumber") != null) {
					selectedMerchant.setMerchantNumber(filterRec.get("merchantNumber"));
				}
				if (filterRec.get("merchantName") != null) {
					selectedMerchant.setMerchantName(filterRec.get("merchantName"));
				}
				if (filterRec.get("merchantId") != null) {
					selectedMerchant.setId(Long.parseLong(filterRec.get("merchantId")));
				}

				selectedTerminal = getSelectedTerminal();
				if (filterRec.get("terminalNumber") != null) {
					selectedTerminal.setTerminalNumber(filterRec.get("terminalNumber"));
				}
				if (filterRec.get("terminalName") != null) {
					selectedTerminal.setTerminalName(filterRec.get("terminalName"));
				}
				if (filterRec.get("terminalId") != null) {
					selectedTerminal.setId(Integer.parseInt(filterRec.get("terminalId")));
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
			selectedMerchant = getSelectedMerchant();
			if (selectedMerchant.getMerchantNumber() != null) {
				filterRec.put("merchantNumber", selectedMerchant.getMerchantNumber());
			}
			if (selectedMerchant.getMerchantName() != null) {
				filterRec.put("merchantName", selectedMerchant.getMerchantName());
			}
			if (selectedMerchant.getId() != null) {
				filterRec.put("merchantId", selectedMerchant.getId().toString());
			}
			selectedTerminal = getSelectedTerminal();
			if (selectedTerminal.getTerminalNumber() != null) {
				filterRec.put("terminalNumber", selectedTerminal.getTerminalNumber());
			}
			if (selectedTerminal.getTerminalName() != null) {
				filterRec.put("terminalName", selectedTerminal.getTerminalName());
			}
			if (selectedTerminal.getId() != null) {
				filterRec.put("terminalId", selectedTerminal.getId().toString());
			}
			if (filter.getInstId() != null) {
				filterRec.put("instId", filter.getInstId().toString());
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
