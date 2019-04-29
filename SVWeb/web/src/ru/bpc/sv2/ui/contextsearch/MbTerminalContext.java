package ru.bpc.sv2.ui.contextsearch;

import org.apache.log4j.Logger;
import ru.bpc.sv2.acquiring.Terminal;
import ru.bpc.sv2.atm.AtmDispenser;
import ru.bpc.sv2.cmn.TcpIpDevice;
import ru.bpc.sv2.common.FlexFieldData;
import ru.bpc.sv2.constants.EntityNames;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.AcquiringDao;
import ru.bpc.sv2.notes.ObjectNoteFilter;
import ru.bpc.sv2.ui.accounts.MbAccountsSearch;
import ru.bpc.sv2.ui.acquiring.MbMccSelection;
import ru.bpc.sv2.ui.acquiring.MbRevenueSharingBottom;
import ru.bpc.sv2.ui.atm.MbAtmCashIns;
import ru.bpc.sv2.ui.atm.MbAtmCollectionsSearch;
import ru.bpc.sv2.ui.atm.MbAtmDispensersSearch;
import ru.bpc.sv2.ui.atm.MbTerminalATMs;
import ru.bpc.sv2.ui.aup.MbAupSchemeObjects;
import ru.bpc.sv2.ui.cmn.MbTcpIpDevices;
import ru.bpc.sv2.ui.common.MbAddressesSearch;
import ru.bpc.sv2.ui.common.MbContactSearch;
import ru.bpc.sv2.ui.common.flexible.MbFlexFieldsDataSearch;
import ru.bpc.sv2.ui.events.MbStatusLogs;
import ru.bpc.sv2.ui.fcl.cycles.MbCycleCounters;
import ru.bpc.sv2.ui.fcl.limits.MbLimitCounters;
import ru.bpc.sv2.ui.network.MbIfConfig;
import ru.bpc.sv2.ui.notes.MbNotesSearch;
import ru.bpc.sv2.ui.pmo.MbObjectPurposes;
import ru.bpc.sv2.ui.products.MbCustomersDependent;
import ru.bpc.sv2.ui.products.MbObjectAttributes;
import ru.bpc.sv2.ui.security.MbDesKeysBottom;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.vch.MbVouchersBatches;
import util.auxil.ManagedBeanWrapper;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.model.SelectItem;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@ViewScoped
@ManagedBean(name = "MbTerminalContext")
public class MbTerminalContext extends AbstractBean {
/**
	 * 
	 */
	private static final long serialVersionUID = 1L;

private static final Logger logger = Logger.getLogger("ACQUIRING");
	
	public static final String OBJECT_ID = "OBJECT_ID";
	private static final String CTX_MENU_PARAMS = "CTX_MENU_PARAMS";	
	
	private Long id;
	private Terminal terminal;
	
	private AcquiringDao _acquireDao = new AcquiringDao();
	
	protected String tabName;
	
	
	public void setId(Long id){
		this.id = id;
	}
	
	public Terminal getActiveTerminal() {
		return getTerminal();
	}
	
	public Terminal getTerminal(){
		try {
			if (terminal == null && id != null) {
				Filter[] filters = new Filter[]{new Filter("id", id),
						new Filter("lang", curLang)};
				Terminal[] terminals = _acquireDao.getTerminals(userSessionId,
						new SelectionParams(filters));
				if (terminals.length > 0) {
					terminal = terminals[0];
				}
			}
			return terminal;
		}catch (Exception e){
			logger.error(e.getMessage(), e);
			FacesUtils.addMessageError(e);
		}
		return  null;
	}
	
	public void initializeModalPanel(){
		logger.debug("MbTerminalDetails initializing...");
		reset();
		if (FacesUtils.getSessionMapValue(CTX_MENU_PARAMS) != null) {
			Map<String, Object> ctxMenuParams = (Map<String, Object>) FacesUtils
					.getSessionMapValue(CTX_MENU_PARAMS);
			FacesUtils.setSessionMapValue(CTX_MENU_PARAMS, null);
			if (ctxMenuParams.containsKey(OBJECT_ID)){
				id = (Long) ctxMenuParams.get(OBJECT_ID);
			} 
		} else {
			if (FacesUtils.getSessionMapValue(OBJECT_ID) != null) {
				id = (Long) FacesUtils.getSessionMapValue(OBJECT_ID);
//				FacesUtils.setSessionMapValue(OBJECT_ID, null);
			}	
		}
		if (id == null){
			objectIdIsNotSet();
		}
		getActiveTerminal();
	}	
	
	private boolean objectIdIsNotSet(){
		String message = "Object ID is not set";
		logger.error(message);
		FacesUtils.addErrorExceptionMessage(message);
		return false;
	}	
	

	public void reset(){
		terminal = null;
		id = null;
	}
	
	public void setTabName(String tabName) {
		this.tabName = tabName;
	}
	
	public String getTabName(){
		return tabName;
	}
	
	public void loadCurrentTab() {
		loadTab(tabName);
	}
	
	private void loadTab(String tab) {
		if (tab == null)
			return;
		if (getActiveTerminal() == null || getActiveTerminal().getId() == null) {
			return;
		}

		if (tab.equalsIgnoreCase("accountsContextTab")) {
			// get accounts for this terminal
			MbAccountsSearch accountsBean = (MbAccountsSearch) ManagedBeanWrapper
					.getManagedBean("MbAccountsContextSearch");
			accountsBean.clearFilter();
			accountsBean.getFilter().setObjectId(getActiveTerminal().getId().longValue());
			accountsBean.getFilter().setInstId(getActiveTerminal().getInstId());
			accountsBean.setSearchByObject(true);
			accountsBean.setBackLink(thisBackLink);
			accountsBean.search();
		} else if (tab.equalsIgnoreCase("contactsContextTab")) {
			// get contacts for this terminal
			MbContactSearch cont = (MbContactSearch) ManagedBeanWrapper
					.getManagedBean("MbContactSearchContext");
			cont.setBackLink("acq_terminals");
			cont.setObjectId(getActiveTerminal().getId().longValue());
			cont.setEntityType(EntityNames.TERMINAL);
			cont.setActiveContact(null);
			cont.search();
		} else if (tab.equalsIgnoreCase("addressesContextTab")) {
			// get addresses for this terminal
			MbAddressesSearch addr = (MbAddressesSearch) ManagedBeanWrapper
					.getManagedBean("MbAddressesContextSearch");
			addr.fullCleanBean();
            addr.getFilter().setEntityType(EntityNames.TERMINAL);
            addr.getFilter().setObjectId(getActiveTerminal().getId().longValue());
			addr.setCurLang(userLang);
            addr.search();
		} else if (tab.equalsIgnoreCase("additionalContextTab")) {
			// get flexible data for this terminal
			MbFlexFieldsDataSearch flexible = (MbFlexFieldsDataSearch) ManagedBeanWrapper
					.getManagedBean("MbFlexFieldsDataContextSearch");
			FlexFieldData filterFlex = new FlexFieldData();
			filterFlex.setInstId(getActiveTerminal().getInstId());
			filterFlex.setEntityType(EntityNames.TERMINAL);
			filterFlex.setObjectType(getActiveTerminal().getTerminalType());
			filterFlex.setObjectId(getActiveTerminal().getId().longValue());
			flexible.setFilter(filterFlex);
			flexible.search();
		} else if (tab.equalsIgnoreCase("keysContextTab")) {
			MbDesKeysBottom keys = (MbDesKeysBottom) ManagedBeanWrapper.getManagedBean("MbDesKeysContext");
			keys.fullCleanBean();
			keys.getFilter().setEntityType(EntityNames.TERMINAL);
			keys.getFilter().setObjectId(getActiveTerminal().getId().longValue());
			keys.setDeviceId(getActiveTerminal().getDeviceId());
			keys.setInstId(getActiveTerminal().getInstId());
			keys.setShowTranslate(false);
			keys.search();
		} else if (tab.equalsIgnoreCase("notesContextTab")) {
			MbNotesSearch notesSearch = (MbNotesSearch) ManagedBeanWrapper
					.getManagedBean("MbNotesContextSearch");
			ObjectNoteFilter filterNote = new ObjectNoteFilter();
			filterNote.setEntityType(EntityNames.TERMINAL);
			filterNote.setObjectId(getActiveTerminal().getId().longValue());
			notesSearch.setFilter(filterNote);
			notesSearch.search();
		} else if (tab.equalsIgnoreCase("attrsContextTab")) {
			MbObjectAttributes attrs = (MbObjectAttributes) ManagedBeanWrapper
					.getManagedBean("MbObjectContextAttributes");
			attrs.fullCleanBean();
			attrs.setObjectId(getActiveTerminal().getId().longValue());
			attrs.setProductId(getActiveTerminal().getProductId());
			attrs.setEntityType(EntityNames.TERMINAL);
			attrs.setInstId(getActiveTerminal().getInstId());
			attrs.setProductType(getActiveTerminal().getProductType());
		} else if (tab.equalsIgnoreCase("connectivityContextTab")) {
			loadTerminalDevice();
		} else if (tab.equalsIgnoreCase("limitCountersContextTab")) {
			MbLimitCounters limitCounters = (MbLimitCounters) ManagedBeanWrapper
					.getManagedBean("MbLimitCountersContext");
			limitCounters.setFilter(null);
			limitCounters.getFilter().setObjectId(getActiveTerminal().getId().longValue());
			limitCounters.getFilter().setInstId(getActiveTerminal().getInstId());
			limitCounters.getFilter().setEntityType(EntityNames.TERMINAL);
			limitCounters.search();
		} else if (tab.equalsIgnoreCase("cycleCountersContextTab")) {
			MbCycleCounters cycleCounters = (MbCycleCounters) ManagedBeanWrapper
					.getManagedBean("MbCycleCountersContext");
			cycleCounters.setFilter(null);
			cycleCounters.getFilter().setObjectId(getActiveTerminal().getId().longValue());
			cycleCounters.getFilter().setInstId(getActiveTerminal().getInstId());
			cycleCounters.getFilter().setEntityType(EntityNames.TERMINAL);
			cycleCounters.search();
		} else if (tab.equalsIgnoreCase("customerContextTab")) {
			MbCustomersDependent custBean = (MbCustomersDependent) ManagedBeanWrapper
					.getManagedBean("MbCustomersDependentContext");
			custBean.getCustomer(getActiveTerminal().getCustomerId(), getActiveTerminal().getCustomerType());
		} else if (tab.equalsIgnoreCase("standardsContextTab")) {
			MbIfConfig versions = (MbIfConfig) ManagedBeanWrapper.getManagedBean("MbIfConfigContext");
			versions.fullCleanBean();
			versions.setParamEntityType(EntityNames.TERMINAL);
			versions.setParamObjectId(getActiveTerminal().getId().longValue());
			versions.setValuesEntityType(EntityNames.TERMINAL);
			versions.setValuesObjectId(getActiveTerminal().getId().longValue());
			versions.setPageTitle(FacesUtils
					.getMessage("ru.bpc.sv2.ui.bundles.Net", "if_config_title_short", FacesUtils
							.getMessage("ru.bpc.sv2.ui.bundles.Acq", "terminal"), getDictUtils()
							.getAllArticlesDesc().get(getActiveTerminal().getTerminalType()),
							getActiveTerminal().getTerminalNumber()));
			versions.setBackLink(thisBackLink);
			versions.setHideVersions(false);
			// add bread crumbs, prevent menu selection
			versions.setDirectAccess(false);
			// versions.setPreviousPageName(pageName);
			versions.search();
		} else if (tab.equalsIgnoreCase("paymentsContextTab")) {
			MbObjectPurposes payments = (MbObjectPurposes) ManagedBeanWrapper
					.getManagedBean("MbObjectPurposesContext");
			payments.setPurposeFilter(null);
			payments.getPurposeFilter().setObjectId(getActiveTerminal().getId().longValue());
			payments.getPurposeFilter().setEntityType("ENTTTRMN");
			payments.search();
		} else if (tab.equalsIgnoreCase("SCHEMESCONTEXTTAB")) {
			MbAupSchemeObjects schemeBean = (MbAupSchemeObjects) ManagedBeanWrapper
					.getManagedBean("MbAupSchemeObjectsContext");
			schemeBean.setObjectId(getActiveTerminal().getId().longValue());
			schemeBean.setInstId(getActiveTerminal().getInstId());
			schemeBean.setDefaultEntityType(EntityNames.TERMINAL);
			schemeBean.search();
		} else if (tab.equalsIgnoreCase("TERMATMSCONTEXTTAB")) {
			MbTerminalATMs terminalATMs = (MbTerminalATMs) ManagedBeanWrapper.getManagedBean("MbTerminalATMsContext");
			terminalATMs.setSlaveMode(true);
			terminalATMs.clearFilter();
			terminalATMs.getFilter().setId(getActiveTerminal().getId());
			terminalATMs.setTemplate(false);
			terminalATMs.loadTerminalATM();
		} else if (tab.equalsIgnoreCase("DISPENSERSCONTEXTTAB")) {
			MbAtmDispensersSearch dispensers = (MbAtmDispensersSearch) ManagedBeanWrapper
					.getManagedBean("MbAtmDispensersContextSearch");
			AtmDispenser dispenserFilter = new AtmDispenser();
			dispenserFilter.setTerminalId(getActiveTerminal().getId());
			dispensers.setDispenserFilter(dispenserFilter);
			dispensers.search();
		} else if (tab.equalsIgnoreCase("cashInContextTab")) {
			MbAtmCashIns cashInBean = (MbAtmCashIns) ManagedBeanWrapper
					.getManagedBean("MbAtmCashInsContext");
			cashInBean.clearFilter();
			cashInBean.getFilter().setTerminalId(getActiveTerminal().getId());
			cashInBean.search();
		} else if (tab.equalsIgnoreCase("mccRedefinitionsContextTab")) {
			MbMccSelection mbMccSelection = (MbMccSelection) ManagedBeanWrapper
					.getManagedBean("MbMccSelectionContext");
			mbMccSelection.getFilter().setMccTemplateId(getActiveTerminal().getMccTemplateId());
			mbMccSelection.search();
		} else if (tab.equalsIgnoreCase("statusLogsContextTab")) {
			MbStatusLogs statusLogs = (MbStatusLogs) ManagedBeanWrapper
					.getManagedBean("MbStatusLogsContext");
			statusLogs.clearFilter();
			statusLogs.getFilter().setObjectId(getActiveTerminal().getId().longValue());

			// logs are written for card instances
			statusLogs.getFilter().setEntityType(EntityNames.TERMINAL);
			statusLogs.search();
		} else if (tab.equalsIgnoreCase("collectionsContextTab")) {
			MbAtmCollectionsSearch collectBean = (MbAtmCollectionsSearch) ManagedBeanWrapper
					.getManagedBean("MbAtmCollectionsContextSearch");
			collectBean.clearFilter();
			collectBean.getCollectionFilter().setTerminalId(getActiveTerminal().getId());
			collectBean.search();
		} else if (tab.equalsIgnoreCase("revenueSharingContextTab")) {
			MbRevenueSharingBottom revenueSharingBean = (MbRevenueSharingBottom) ManagedBeanWrapper
					.getManagedBean("MbRevenueSharingBottomContext");
			revenueSharingBean.clearFilter();
			revenueSharingBean.getFilter().setTerminalId(getActiveTerminal().getId().longValue());
			revenueSharingBean.search();
		} else if (tab.equalsIgnoreCase("vouchersBatchesContextTab")) {
			MbVouchersBatches mbVouchersBatches = (MbVouchersBatches) ManagedBeanWrapper
					.getManagedBean("MbVouchersBatchesContext");
			mbVouchersBatches.clearFilter();
			mbVouchersBatches.getFilter().setTerminalId(getActiveTerminal().getId());
			mbVouchersBatches.getFilter().setMerchantId(getActiveTerminal().getMerchantId());
			mbVouchersBatches.getFilter().setInstId(getActiveTerminal().getInstId());
			mbVouchersBatches.search();
		}
	}

	private void loadTerminalDevice() {
		Filter[] filters = new Filter[2];
		filters[0] = new Filter("lang", curLang);
		filters[1] = new Filter("id", getActiveTerminal().getDeviceId());
		
		SelectionParams params = new SelectionParams(filters);
		MbTcpIpDevices tcpIpDevicesBean = (MbTcpIpDevices) ManagedBeanWrapper
				.getManagedBean("MbTcpIpDevicesContext");
		try {
			TcpIpDevice[] devices = _acquireDao.getTerminalDevices(userSessionId, params);
			if (devices.length > 0) {
				tcpIpDevicesBean.setActiveDevice(devices[0]);
			} else {
				tcpIpDevicesBean.setActiveDevice(null);
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	private Map<Long, String> mccSelectionTemplatesMap;
	public Map<Long, String> getMccSelectionTemplatesMap(){
		if (mccSelectionTemplatesMap == null){
			List<SelectItem> selectionTemplates = getDictUtils().getLov(LovConstants.MCC_SELECTION_TEMPLATE);
			mccSelectionTemplatesMap = new HashMap<Long, String>();
			for (SelectItem item : selectionTemplates){
				mccSelectionTemplatesMap.put(new Long(item.getValue().toString()), item.getLabel());
			}
		}
		return mccSelectionTemplatesMap;
	}
	
	@Override
	public void clearFilter() {
		// TODO Auto-generated method stub
		
	}
}
