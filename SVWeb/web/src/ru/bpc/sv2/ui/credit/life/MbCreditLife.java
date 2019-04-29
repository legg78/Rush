package ru.bpc.sv2.ui.credit.life;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.event.ValueChangeEvent;
import javax.faces.model.SelectItem;

import org.ajax4jsf.model.ExtendedDataModel;
import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;

import ru.bpc.sv2.accounts.BunchType;
import ru.bpc.sv2.accounts.EntryTemplatePair;
import ru.bpc.sv2.audit.EntityType;
import ru.bpc.sv2.common.Dictionary;
import ru.bpc.sv2.constants.DictNames;
import ru.bpc.sv2.constants.EntityNames;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.credit.CreditEventBunchType;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.AccountsDao;
import ru.bpc.sv2.logic.CommonDao;
import ru.bpc.sv2.logic.CreditDao;
import ru.bpc.sv2.ui.accounts.MbEntryTemplates;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.TableRowSelection;
import util.auxil.ManagedBeanWrapper;

@ViewScoped
@ManagedBean (name = "MbCreditLife")
public class MbCreditLife extends AbstractBean {
	private static final Logger logger = Logger.getLogger("CREDIT");

	private static final String BUNCH_TAB = "bunchTab";
	private static final String DETAILS_TAB = "detailsTab";
	private static final String ADD_BUNCH_TAB = "additionalBunchTab";

	private static String COMPONENT_ID = "2102:eventBunchTypesTable";

	private CreditDao creditDao = new CreditDao();

	private AccountsDao accountsDao = new AccountsDao();

	private CommonDao commonDao = new CommonDao();

	

	private transient DaoDataModel<CreditEventBunchType> eventBunchTypesSource;

	private CreditEventBunchType filter;
	private TableRowSelection<CreditEventBunchType> itemSelection;
	private HashMap<String, Boolean> loadedTabs = new HashMap<String, Boolean>();
	private String tabName;
	private CreditEventBunchType activeEventBunchType;

	private CreditEventBunchType newEventBunchType;
	private BunchType newBunchType;
	private EntryTemplatePair newEntryTemplatePair;

	private ArrayList<SelectItem> institutions;
	private HashMap<String, EntityType> entityTypes;

	public MbCreditLife() {
		pageLink = "credit|life";
		filter = new CreditEventBunchType();
		
		eventBunchTypesSource = new DaoDataModel<CreditEventBunchType>() {
			@Override
			protected CreditEventBunchType[] loadDaoData(SelectionParams params) {
				if (!searching)
					return new CreditEventBunchType[0];
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return creditDao.getEventBunchTypes(userSessionId, params);
				} catch (Exception e) {
					setDataSize(0);
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return new CreditEventBunchType[0];
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (!searching)
					return 0;
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return creditDao.getEventBunchTypesCount(userSessionId, params);
				} catch (Exception e) {
					setDataSize(0);
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return 0;
			}
		};
		tabName = BUNCH_TAB;
		itemSelection = new TableRowSelection<CreditEventBunchType>(null, eventBunchTypesSource);
	}

	public void clearFilter() {
		searching = false;
		filter = new CreditEventBunchType();
		clearBean();
	}

	public void search() {
		searching = true;
		clearBean(); // unimplemented
	}

	private void clearBean() {
		itemSelection.clearSelection();
		activeEventBunchType = null;
		eventBunchTypesSource.flushCache();

		MbEntryTemplates bean = (MbEntryTemplates) ManagedBeanWrapper.getManagedBean("MbEntryTemplates");
		bean.fullCleanBean();
		bean.setSearching(false);
	}

	private void setFilters() {
		filters = new ArrayList<Filter>();
		Filter tmpFilter = null;
		if (filter.getInstId() != null) {
			tmpFilter = new Filter();
			tmpFilter.setElement("instId");
			tmpFilter.setValue(filter.getInstId());
			filters.add(tmpFilter);
		}
		if (filter.getEventType() != null && !filter.getEventType().trim().isEmpty()) {
			tmpFilter = new Filter();
			tmpFilter.setElement("eventType");
			tmpFilter.setValue(filter.getEventType());
			filters.add(tmpFilter);
		}
		if (filter.getBalanceType() != null && !filter.getBalanceType().trim().isEmpty()) {
			tmpFilter = new Filter();
			tmpFilter.setElement("balanceType");
			tmpFilter.setValue(filter.getBalanceType());
			filters.add(tmpFilter);
		}
		tmpFilter = new Filter();
		tmpFilter.setElement("lang");
		tmpFilter.setValue(userLang);
		filters.add(tmpFilter);
	}

	public void createEventBunchType() {
		newEventBunchType = new CreditEventBunchType();
		curMode = NEW_MODE;
	}

	public void editEventBunchType() {
		newEventBunchType = (CreditEventBunchType) activeEventBunchType.clone();
		curMode = EDIT_MODE;
	}

	public void saveEventBunchType() {
		try {
			if (isNewMode()) {
				newEventBunchType = creditDao.addEventBunchType(userSessionId, newEventBunchType, userLang);
				itemSelection.addNewObjectToList(newEventBunchType);
			} else if (isEditMode()) {
				newEventBunchType = creditDao.editEventBunchType(userSessionId, newEventBunchType, userLang);
				eventBunchTypesSource.replaceObject(activeEventBunchType, newEventBunchType);
			}
			activeEventBunchType = newEventBunchType;
			setBeans();
			curMode = VIEW_MODE;
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void cancelEventBunchType() {
		newEventBunchType = null;
		close();
	}

	public void close() {
		curMode = VIEW_MODE;
	}

	public void delete() {
		try {
			creditDao.removeEventBunchType(userSessionId, activeEventBunchType);
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
		curMode = VIEW_MODE;

		activeEventBunchType = itemSelection.removeObjectFromList(activeEventBunchType);
		if (activeEventBunchType == null) {
			clearBean();
		} else {
			setBeans();
		}

	}

	public void createBunchType() {
		newBunchType = new BunchType();
		newEntryTemplatePair = new EntryTemplatePair();
		newEntryTemplatePair.setCreditBalanceImpact(1);
		newEntryTemplatePair.setDebitBalanceImpact(-1);

		newEntryTemplatePair.setEditDebit(true);
		newEntryTemplatePair.setEditCredit(true);
	}

	public void saveBunchType() {
		try {
			newBunchType = accountsDao.addComplexBunchType(userSessionId, newBunchType, newEntryTemplatePair);
			newEventBunchType.setBunchTypeId(newBunchType.getId());
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error(e.getMessage(), e);
		}

	}

	public void cancelBunchType() {
		newBunchType = null;
	}

	public void setBeans() {
		if (activeEventBunchType == null) {
			return;
		}
		loadedTabs.clear();
		loadTab(tabName);
	}

	private void loadTab(String tabName) {
		if (BUNCH_TAB.equalsIgnoreCase(tabName)) {
			MbEntryTemplates bean = (MbEntryTemplates) ManagedBeanWrapper.getManagedBean("MbEntryTemplates");
			bean.fullCleanBean();
			if (activeEventBunchType != null) {
				bean.setBunchTypeId(activeEventBunchType.getBunchTypeId());
				bean.setBunchTypeName(activeEventBunchType.getBunchTypeName());
			}
			bean.search();
		} else if (ADD_BUNCH_TAB.equalsIgnoreCase(tabName)) {
			MbEntryTemplates bean = (MbEntryTemplates) ManagedBeanWrapper.getManagedBean("MbEntryTemplates");
			bean.fullCleanBean();
			if (activeEventBunchType != null) {
				bean.setBunchTypeId(activeEventBunchType.getAddBunchTypeId());
				bean.setBunchTypeName(activeEventBunchType.getAddBunchTypeName());
			}
			bean.search();
		}
		loadedTabs.put(tabName, Boolean.TRUE);
	}

	private SimpleSelection prepareSelection() {
		if (activeEventBunchType == null && eventBunchTypesSource.getRowCount() > 0) {
			setFirstRowActive();
		} else if (activeEventBunchType != null && eventBunchTypesSource.getRowCount() > 0) {
			SimpleSelection selection = new SimpleSelection();
			selection.addKey(activeEventBunchType.getModelId());
			itemSelection.setWrappedSelection(selection);
			activeEventBunchType = itemSelection.getSingleSelection(); // ?
		}
		return itemSelection.getWrappedSelection();
	}

	private void setFirstRowActive() {
		eventBunchTypesSource.setRowIndex(0);
		SimpleSelection selection = new SimpleSelection();
		activeEventBunchType = (CreditEventBunchType) eventBunchTypesSource.getRowData();
		selection.addKey(activeEventBunchType.getModelId());
		itemSelection.setWrappedSelection(selection);
		setBeans();
	}

	public ArrayList<SelectItem> getDestAccountTypes(String entityType, boolean showCode) {
		ArrayList<SelectItem> items = new ArrayList<SelectItem>();
		try {
			if (entityType != null) {
				List<String> accTypes = accountsDao.getAccountTypesByEntityType(userSessionId,
						entityType);
				for (String accType : accTypes) {
					Dictionary accTypeDict = getDictUtils().getAllArticles().get(accType);
					String name = "";
					if (accTypeDict != null && showCode) {
						name = accType + " - " + accTypeDict.getName();
					} else {
						name = accType;
					}
					items.add(new SelectItem(accType, name));
				}
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}

		return items;
	}

	//

	public void changeDebit(ValueChangeEvent event) {
		Boolean enabled = (Boolean) event.getNewValue();
		newEntryTemplatePair.setEditDebit(enabled.booleanValue());
	}

	public void changeCredit(ValueChangeEvent event) {
		Boolean enabled = (Boolean) event.getNewValue();
		newEntryTemplatePair.setEditCredit(enabled.booleanValue());
	}

	public SelectItem[] getDestEntityTypes() {
		SelectItem[] items = new SelectItem[2];
		items[0] = new SelectItem(EntityNames.INSTITUTION, "Institution");
		items[1] = new SelectItem(EntityNames.AGENT, "Agent");
		return items;
	}

	public ArrayList<SelectItem> getPostingMethods() {
		return getDictUtils().getArticles(DictNames.POSTING_METHOD, true);
	}

	public ArrayList<SelectItem> getTransactionTypes() {
		return getDictUtils().getArticles(DictNames.TRANSACTION_TYPE, true);
	}

	public ArrayList<SelectItem> getCreditDestAccountTypes() {
		if (newEntryTemplatePair == null) {
			return new ArrayList<SelectItem>(0);
		} else {
			return getDestAccountTypes(newEntryTemplatePair.getCreditDestEntityType(), true);
		}

	}

	public ArrayList<SelectItem> getDebitDestAccountTypes() {
		if (newEntryTemplatePair == null) {
			return new ArrayList<SelectItem>(0);
		} else {
			return getDestAccountTypes(newEntryTemplatePair.getDebitDestEntityType(), true);
		}
	}

	public HashMap<String, EntityType> getEntityTypes() {
		try {
			if (entityTypes == null)
				entityTypes = commonDao.getEntityTypeObjects(userSessionId);
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		} finally {
			if (entityTypes == null)
				entityTypes = new HashMap<String, EntityType>();
		}
		return entityTypes;
	}

	public List<SelectItem> getAmountTypes() {
		return getDictUtils().getLov(LovConstants.AMOUNT_TYPES);
	}

	public List<SelectItem> getAccountPurposes() {
		return getDictUtils().getLov(LovConstants.ACCOUNT_PURPOSES);
	}

	public List<SelectItem> getDatePurposes() {
		return getDictUtils().getLov(LovConstants.DATE_PURPOSES);
	}

	public List<SelectItem> getBunchTypes() {
		List<SelectItem> bunchTypes = getDictUtils().getLov(LovConstants.BUNCH_TYPES);
		return bunchTypes;
	}

	public List<SelectItem> getCreditEventsTypes() {
		List<SelectItem> creditEvents = getDictUtils().getLov(LovConstants.CREDIT_EVENT_TYPES);
		return creditEvents;
	}

	public ArrayList<SelectItem> getInstitutions() {
		if (institutions == null) {
			institutions = (ArrayList<SelectItem>) getDictUtils().getLov(LovConstants.INSTITUTIONS_SYS);
		}
		if (institutions == null)
			institutions = new ArrayList<SelectItem>();
		return institutions;
	}

	public ArrayList<SelectItem> getBalanceTypes() {
		return getDictUtils().getArticles(DictNames.BALANCE_TYPE, false, false);
	}

	public CreditEventBunchType getFilter() {
		return filter;
	}

	public void setFilter(CreditEventBunchType filter) {
		this.filter = filter;
	}

	public ExtendedDataModel getEventBunchTypes() {
		return eventBunchTypesSource;
	}

	public SimpleSelection getItemSelection() {
		SimpleSelection selection = null;
		try {
			selection = prepareSelection();
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
		return selection;
	}

	public void setItemSelection(SimpleSelection selection) {
		itemSelection.setWrappedSelection(selection);
		activeEventBunchType = itemSelection.getSingleSelection();
		setBeans();
	}

	public String getTabName() {
		return tabName;
	}

	public void setTabName(String tabName) {
		this.tabName = tabName;
		loadTab(tabName);
	}

	public CreditEventBunchType getNewEventBunchType() {
		return newEventBunchType;
	}

	public CreditEventBunchType getActiveEventBunchType() {
		return activeEventBunchType;
	}

	public BunchType getNewBunchType() {
		return newBunchType;
	}

	public EntryTemplatePair getNewEntryTemplatePair() {
		return newEntryTemplatePair;
	}

	public String getComponentId() {
		return COMPONENT_ID;
	}

	public Logger getLogger() {
		return logger;
	}
}
