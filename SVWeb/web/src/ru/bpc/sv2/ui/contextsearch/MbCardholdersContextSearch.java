package ru.bpc.sv2.ui.contextsearch;

import org.apache.log4j.Logger;
import ru.bpc.sv2.common.FlexFieldData;
import ru.bpc.sv2.constants.EntityNames;
import ru.bpc.sv2.issuing.Card;
import ru.bpc.sv2.issuing.Cardholder;
import ru.bpc.sv2.issuing.IssuingPrivConstants;
import ru.bpc.sv2.ui.common.MbAddressesSearch;
import ru.bpc.sv2.ui.common.MbContactSearch;
import ru.bpc.sv2.ui.common.MbPersonId;
import ru.bpc.sv2.ui.common.flexible.MbFlexFieldsDataSearch;
import ru.bpc.sv2.ui.issuing.MbCardholdersSearch;
import ru.bpc.sv2.ui.issuing.MbCardsBottomSearch;
import ru.bpc.sv2.ui.utils.FacesUtils;
import util.auxil.ManagedBeanWrapper;

import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import java.util.Map;

@ViewScoped

@ManagedBean(name = "MbCardholdersContextSearch")
public class MbCardholdersContextSearch extends MbCardholdersSearch {
	
	private static final long serialVersionUID = 1L;

	private static final Logger logger = Logger.getLogger("ISSUING");
	
	public static final String OBJECT_ID = "OBJECT_ID";
	private static final String CTX_MENU_PARAMS = "CTX_MENU_PARAMS";
	
	private Long id;
	private Cardholder cardholder;

	public Cardholder getActiveCardholder() {
		super.setActiveCardholder(getCardholder());
		return super.getActiveCardholder();
	}

	public void initializeModalPanel(){
		logger.debug("MbAccountDetails initializing...");
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
//			objectIdIsNotSet();
		}
		getActiveCardholder();
	}
	
	private boolean objectIdIsNotSet(){
		String message = "Object ID is not set";
		logger.error(message);
		FacesUtils.addErrorExceptionMessage(message);
		return false;
	}
	
	public void setId(Long id){
		this.id = id;
	}
	
	public Cardholder getCardholder(){
		try {
			if (cardholder == null && id != null) {
				Cardholder filterCardholder = new Cardholder();
				filterCardholder.setId(id);
				setFilter(filterCardholder);
			}
			getParams().setPrivilege(IssuingPrivConstants.VIEW_CARDHOLDERS_TAB);
			cardholder = super.getCardholder();
			return cardholder;
		}catch (Exception e){
			logger.error(e.getMessage(), e);
			FacesUtils.addMessageError(e);
		}
		return  null;
	}
	
	public void reset(){
		id = null;
		cardholder = null;
	}
	
	public void setTabName(String tabName) {
		this.tabName = tabName;
	}

	public void loadCurrentTab() {
		loadTab(tabName);
	}

	private void loadTab(String tab) {
		if (tab == null)
			return;
		if (cardholder == null)
			return;

		if (tab.equalsIgnoreCase("cardsContextTab")) {
			MbCardsBottomSearch cardsSearch = (MbCardsBottomSearch) ManagedBeanWrapper
					.getManagedBean("MbCardsBottomContextSearch");
			Card cardFilter = new Card();
			cardFilter.setCardholderId(cardholder.getId());
			cardsSearch.setFilter(cardFilter);
			cardsSearch.setSearchByHolder(true);
			cardsSearch.setSearchTabName("CARDHOLDER");
			cardsSearch.search();
		} else if (tab.equalsIgnoreCase("personIdsContextTab")) {
			// TODO change MbPersonId loadDaoData()
			MbPersonId doc = (MbPersonId) ManagedBeanWrapper.getManagedBean("MbPersonIdContext");
			doc.setIdOfPerson(cardholder.getPersonId());
			doc.search();
		} else if (tab.equalsIgnoreCase("flexibleFieldsContextTab")) {
			// get flexible data for this institution
			MbFlexFieldsDataSearch flexible = (MbFlexFieldsDataSearch) ManagedBeanWrapper
					.getManagedBean("MbFlexFieldsDataContextSearch");
			FlexFieldData filterFlex = new FlexFieldData();
			filterFlex.setInstId(cardholder.getInstId());
			filterFlex.setEntityType(EntityNames.CARDHOLDER);
			filterFlex.setObjectId(cardholder.getId());
			flexible.setFilter(filterFlex);
			flexible.search();
		} else if (tab.equalsIgnoreCase("contactsContextTab")) {
			// get contacts for this institution
			MbContactSearch cont = (MbContactSearch) ManagedBeanWrapper.getManagedBean("MbContactContextSearch");
			cont.setBackLink(thisBackLink);
			cont.setObjectId(cardholder.getId());
			cont.setEntityType(EntityNames.CARDHOLDER);
			cont.search();
		} else if (tab.equalsIgnoreCase("addressesContextTab")) {
			// get addresses for this institution
			MbAddressesSearch addr = (MbAddressesSearch) ManagedBeanWrapper
					.getManagedBean("MbAddressesContextSearch");
            addr.fullCleanBean();
            addr.getFilter().setEntityType(EntityNames.CARDHOLDER);
            addr.getFilter().setObjectId(cardholder.getId());
			addr.setCurLang(userLang);
			addr.search();
		}
		loadedTabs.put(tab, Boolean.TRUE);
	}
}
