package ru.bpc.sv2.ui.issuing;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;
import ru.bpc.sv2.common.FlexFieldData;
import ru.bpc.sv2.constants.EntityNames;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.constants.SectionIdConstants;
import ru.bpc.sv2.constants.SystemConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.Filter.Operator;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.issuing.Card;
import ru.bpc.sv2.issuing.Cardholder;
import ru.bpc.sv2.logic.IssuingDao;
import ru.bpc.sv2.logic.NetworkDao;
import ru.bpc.sv2.logic.ProductsDao;
import ru.bpc.sv2.net.CardType;
import ru.bpc.sv2.net.Network;
import ru.bpc.sv2.notes.ObjectNoteFilter;
import ru.bpc.sv2.products.Customer;
import ru.bpc.sv2.ui.acm.MbContextMenu;
import ru.bpc.sv2.ui.application.MbObjectApplicationsSearch;
import ru.bpc.sv2.ui.common.MbAddressesSearch;
import ru.bpc.sv2.ui.common.MbContactDataSearch;
import ru.bpc.sv2.ui.common.MbContactSearch;
import ru.bpc.sv2.ui.common.MbPersonId;
import ru.bpc.sv2.ui.common.flexible.MbFlexFieldsDataSearch;
import ru.bpc.sv2.ui.context.ContextType;
import ru.bpc.sv2.ui.context.ContextTypeFactory;
import ru.bpc.sv2.ui.navigation.Menu;
import ru.bpc.sv2.ui.notes.MbNotesSearch;
import ru.bpc.sv2.ui.notifications.MbNtfEventBottom;
import ru.bpc.sv2.ui.products.MbCustomerSearchModal;
import ru.bpc.sv2.ui.utils.*;
import util.auxil.ManagedBeanWrapper;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.event.ValueChangeEvent;
import javax.faces.model.SelectItem;
import javax.servlet.http.HttpServletRequest;
import java.text.ParseException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

@ViewScoped
@ManagedBean(name = "MbCardholdersSearch")
public class MbCardholdersSearch extends AbstractBean {
	private static final long serialVersionUID = 2820323296251584373L;

	private static final Logger logger = Logger.getLogger("ISSUING");

	private static final String COMPONENT_ID = "1013:cardholdersTable";

	private IssuingDao issuingDao = new IssuingDao();
	private NetworkDao networkDao = new NetworkDao();
	private ProductsDao productsDao = new ProductsDao();

	private Cardholder filter;
	private SelectionParams params;
	private String filterCardNumber;
	private String filterCardUid;
	private Long filterCustomerId;
	private String filterCustomerNumber;
	private String customerInfo;
	private String filterContractNumber;
	private String filterIdType;
	private String filterIdNumber;

	private Cardholder activeCardholder;
	private Cardholder newCardholder;

	private ArrayList<SelectItem> institutions;
	private ArrayList<SelectItem> networks;
	private ArrayList<SelectItem> cardholderTypes;
	private ArrayList<SelectItem> idTypes;

    private Map<String, Object> paramMaps;

	protected String tabName;

	private final DaoDataModel<Cardholder> cardholdersSource;
	private final TableRowSelection<Cardholder> itemSelection;

	private boolean searchByCard;

	private String backLink;

	private ContextType ctxType;
	private String ctxItemEntityType;

	public MbCardholdersSearch() {
		pageLink = "issuing|cardholders";
		tabName = "detailsTab";
		Menu menu = (Menu) ManagedBeanWrapper.getManagedBean("menu");

		cardholdersSource = new DaoDataModel<Cardholder>(true) {
			private static final long serialVersionUID = -1054383192513412955L;

			@Override
			protected Cardholder[] loadDaoData(SelectionParams params) {
				if (!searching) {
					return new Cardholder[0];
				}
				try {
                    setFilters();
                    params.setFilters(filters.toArray(new Filter[filters.size()]));
                    getParamMaps().put("param_tab", filters.toArray(new Filter[filters.size()]));
                    getParamMaps().put("tab_name", "CARDHOLDER");
					return issuingDao.getCardholdersCur(userSessionId, params, getParamMaps());
				} catch (Exception e) {
					FacesUtils.addMessageError(e);
					logger.error("", e);
					setDataSize(0);
				}
				return new Cardholder[0];
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (!searching) {
					return 0;
				}
				try {
                    setFilters();
                    params.setFilters(filters.toArray(new Filter[filters.size()]));
                    getParamMaps().put("param_tab", filters.toArray(new Filter[filters.size()]));
                    getParamMaps().put("tab_name", "CARDHOLDER");
					return issuingDao.getCardholdersCurCount(userSessionId, params, getParamMaps());
				} catch (Exception e) {
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return 0;
			}
		};

		itemSelection = new TableRowSelection<Cardholder>(null, cardholdersSource);

		if (!menu.isKeepState()) {
			// if user came here from menu, we don't need to select previously
			// selected tab
			clearFilter();
		}

		HttpServletRequest req = RequestContextHolder.getRequest();
		String sectionId = req.getParameter("sectionId");
		String filterId = req.getParameter("filterId");

		if (sectionId != null && filterId != null) {
			selectedSectionFilter = Integer.parseInt(filterId);
			applySectionFilter(selectedSectionFilter);
		}
	}

	public DaoDataModel<Cardholder> getCardholders() {
		return cardholdersSource;
	}

	public Cardholder getActiveCardholder() {
		return activeCardholder;
	}

	public void setActiveCardholder(Cardholder activeCardholder) {
		this.activeCardholder = activeCardholder;
	}

	public SimpleSelection getItemSelection() {
		try {
			if (activeCardholder == null && cardholdersSource.getRowCount() > 0) {
				setFirstRowActive();
			} else if (activeCardholder != null && cardholdersSource.getRowCount() > 0) {
				SimpleSelection selection = new SimpleSelection();
				selection.addKey(activeCardholder.getModelId());
				itemSelection.setWrappedSelection(selection);
				activeCardholder = itemSelection.getSingleSelection();
			}
		} catch (Exception e) {
			logger.error("", e);
			FacesUtils.addMessageError(e);
		}
		return itemSelection.getWrappedSelection();
	}

	public void setFirstRowActive() {
		cardholdersSource.setRowIndex(0);
		SimpleSelection selection = new SimpleSelection();
		activeCardholder = (Cardholder) cardholdersSource.getRowData();
		selection.addKey(activeCardholder.getModelId());
		itemSelection.setWrappedSelection(selection);
		if (activeCardholder != null) {
			setInfo();
		}
	}

	public void setItemSelection(SimpleSelection selection) {
		itemSelection.setWrappedSelection(selection);
		activeCardholder = itemSelection.getSingleSelection();
		if (activeCardholder != null) {
			setInfo();
		}
	}

	public void setInfo() {
		loadedTabs.clear();
		loadTab(getTabName());
	}

	public void search() {
		clearState();
		clearBeansStates();
		searching = true;
	}

	public void clearFilter() {
		filter = null;
		filterCardNumber = null;
		filterCardUid = null;
		filterCustomerId = null;
		filterCustomerNumber = null;
		clearState();
		searching = false;
	}

	public Cardholder getFilter() {
		if (Boolean.TRUE.equals(FacesUtils.getSessionMapValue("initFromContext"))) {
			initFilterFromContext();
			backLink = (String) FacesUtils.getSessionMapValue("backLink");
			search();
			FacesUtils.setSessionMapValue("initFromContext", null);
		}
		if (filter == null) {
			filter = new Cardholder();
			filter.setInstId(userInstId);
		}
		return filter;
	}

	public void setFilter(Cardholder filter) {
		this.filter = filter;
	}

	public SelectionParams getParams() {
		if (params == null) params = new SelectionParams();
		return params;
	}

	private void setFilters() {
		filter = getFilter();
		filters = new ArrayList<Filter>();

		Filter paramFilter;
		if (filter.getId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("CARDHOLDER_ID");
			paramFilter.setOp(Operator.like);
			paramFilter.setValue(filter.getId().toString());
			filters.add(paramFilter);
		}

		paramFilter = new Filter();
		paramFilter.setElement("LANG");
		paramFilter.setOp(Operator.eq);
		paramFilter.setValue(curLang);
		filters.add(paramFilter);

		if (filter.getInstId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("INST_ID");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(filter.getInstId());
			filters.add(paramFilter);
		}

		if (filter.getCardholderName() != null
				&& filter.getCardholderName().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("CARDHOLDER_NAME");
			paramFilter.setOp(Operator.like);
			paramFilter.setValue(filter.getCardholderName().trim().replaceAll("[*]", "%")
					.replaceAll("[?]", "_").toUpperCase());
			filters.add(paramFilter);
		}

		if (filter.getCardholderNumber() != null
				&& filter.getCardholderNumber().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("CARDHOLDER_NUMBER");
			paramFilter.setOp(Operator.like);
			paramFilter.setValue(filter.getCardholderNumber().trim().replaceAll("[*]",
					"%").replaceAll("[?]", "_").toUpperCase());
			filters.add(paramFilter);
		}

		if (filter.getPerson().getFirstName() != null
				&& filter.getPerson().getFirstName().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("FIRST_NAME");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(filter.getPerson().getFirstName().trim().replaceAll(
					"[*]", "%").replaceAll("[?]", "_").toUpperCase());
			filters.add(paramFilter);
		}
		if (filter.getPerson().getSurname() != null
				&& filter.getPerson().getSurname().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("SURNAME");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(filter.getPerson().getSurname().trim().replaceAll("[*]",
					"%").replaceAll("[?]", "_").toUpperCase());
			filters.add(paramFilter);
		}
		if (getFilterCardNumber() != null && !getFilterCardNumber().trim().isEmpty()) {
			Filter filter;
			if (getFilterCardNumber().contains("*")) {
				String mask = getFilterCardNumber().trim().replaceAll("[*]", "%");
				filter = new Filter("CARD_MASK", mask);
			} else {
				filter = new Filter("CARD_NUMBER", getFilterCardNumber());
			}
			filters.add(filter);
		}
		if (getFilterCardUid() != null && !getFilterCardUid().trim().isEmpty()) {
			filters.add(new Filter("CARD_UID", getFilterCardUid()));
		}
		if (getFilterCustomerNumber() != null && !getFilterCustomerNumber().trim().isEmpty()) {
			filters.add(new Filter("CUSTOMER_NUMBER", getFilterCustomerNumber()));
		}
		if (getFilterCustomerId() != null) {
			filters.add(new Filter("CUSTOMER_ID", getFilterCustomerId()));
		}
		if (getFilterContractNumber() != null && !getFilterContractNumber().trim().isEmpty()) {
			paramFilter = new Filter();
			paramFilter.setElement("CONTRACT_NUMBER");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(getFilterContractNumber().trim().replaceAll(
					"[*]", "%").replaceAll("[?]", "_").toUpperCase());
			filters.add(paramFilter);
		}
		if (getFilterIdNumber() != null && !getFilterIdNumber().trim().isEmpty()) {
			Filter filter = new Filter("ID_NUMBER", getFilterIdNumber().trim().replaceAll(
					"[*]", "%").replaceAll("[?]", "_").toUpperCase());
			filters.add(filter);
			//Only if idNumber is filled add filter by idType
			if (getFilterIdType() != null && !getFilterIdType().trim().isEmpty()) {
				filters.add(new Filter("ID_TYPE", getFilterIdType()));
			}
		}
	}

	public void add() {
		newCardholder = new Cardholder();
		curMode = NEW_MODE;
	}

	public void edit() {
		try {
			newCardholder = activeCardholder.clone();
		} catch (CloneNotSupportedException e) {
			logger.error("", e);
			newCardholder = activeCardholder;
		}
		curMode = EDIT_MODE;
	}

	public void view() {

	}

	public void close() {
		curMode = VIEW_MODE;
	}

	@SuppressWarnings("UnusedDeclaration")
	public Cardholder getNewCardholder() {
		if (newCardholder == null) {
			newCardholder = new Cardholder();
		}
		return newCardholder;
	}

	@SuppressWarnings("UnusedDeclaration")
	public void setNewCardholder(Cardholder newCardholder) {
		this.newCardholder = newCardholder;
	}

	public void clearState() {
		itemSelection.clearSelection();
		activeCardholder = null;
		cardholdersSource.flushCache();
		curLang = userLang;
		loadedTabs.clear();
	}

	public void clearBeansStates() {

		if (!searchByCard) {
			MbCardsBottomSearch cardsSearch = (MbCardsBottomSearch) ManagedBeanWrapper
					.getManagedBean("MbCardsBottomSearch");
			cardsSearch.setFilter(null);
			cardsSearch.setSearching(false);
			cardsSearch.setSearchByHolder(true);    // so that MbCardsBottomSearch don't clear this bean's filter
			cardsSearch.clearState();
		}
		MbPersonId doc = (MbPersonId) ManagedBeanWrapper.getManagedBean("MbPersonId");
		doc.setIdOfPerson(null);
		doc.search();

		MbContactSearch contSearch = (MbContactSearch) ManagedBeanWrapper.getManagedBean("MbContactSearch");
		contSearch.fullCleanBean();

		MbNtfEventBottom ntf = (MbNtfEventBottom) ManagedBeanWrapper.getManagedBean("MbNtfEventBottom");
		ntf.clearFilter();
	}

	public void changeLanguage(ValueChangeEvent event) {
		curLang = (String) event.getNewValue();

		List<Filter> filtersList = new ArrayList<Filter>();

		Filter paramFilter = new Filter();
		paramFilter.setElement("CARDHOLDER_ID");
		paramFilter.setOp(Operator.eq);
		paramFilter.setValue(activeCardholder.getId().toString());
		filtersList.add(paramFilter);

		paramFilter = new Filter();
		paramFilter.setElement("LANG");
		paramFilter.setOp(Operator.eq);
		paramFilter.setValue(curLang);
		filtersList.add(paramFilter);

		filters = filtersList;
		SelectionParams params = new SelectionParams();
		params.setFilters(filters.toArray(new Filter[filters.size()]));
        getParamMaps().put("param_tab", filters.toArray(new Filter[filters.size()]));
        getParamMaps().put("tab_name", "CARDHOLDER");
		try {
			Cardholder[] cardholders = issuingDao.getCardholdersCur(userSessionId, params, getParamMaps());
			if (cardholders != null && cardholders.length > 0) {
				activeCardholder = cardholders[0];
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public ArrayList<SelectItem> getInstitutions() {
		if (institutions == null) {
			institutions = (ArrayList<SelectItem>) getDictUtils().getLov(LovConstants.INSTITUTIONS);
		}
		if (institutions == null)
			institutions = new ArrayList<SelectItem>();
		return institutions;
	}

	public ArrayList<SelectItem> getIdTypes() {
		if (idTypes == null) {
			Map<String, Object> params = new HashMap<String, Object>();
			idTypes = (ArrayList<SelectItem>) getDictUtils().getLov(LovConstants.ID_TYPES_WITHOUT_CUSTOMER, params);
		}
		return idTypes;
	}


	public ArrayList<SelectItem> getNetworks() {
		if (networks == null) {
			ArrayList<SelectItem> items = new ArrayList<SelectItem>();
			try {
				SelectionParams params = new SelectionParams();
				params.setRowIndexEnd(-1);

				List<Filter> filtersList = new ArrayList<Filter>();
				Filter paramFilter = new Filter();
				paramFilter.setElement("lang");
				paramFilter.setOp(Operator.eq);
				paramFilter.setValue(userLang);
				filtersList.add(paramFilter);

				params.setFilters(filtersList.toArray(new Filter[filtersList.size()]));

				Network[] nets = networkDao.getNetworks(userSessionId, params);
				for (Network net : nets) {
					items.add(new SelectItem(net.getId(), net.getName(), net
							.getDescription()));
				}
				networks = items;
			} catch (Exception e) {
				logger.error("", e);
				if (!e.getMessage().contains(SystemConstants.INSUFFICIENT_PRIVILEGES_ERROR)) {
					FacesUtils.addMessageError(e);
				}
			} finally {
				if (networks == null)
					networks = new ArrayList<SelectItem>();
			}
		}
		return networks;
	}

	public ArrayList<SelectItem> getCardTypes() {
		if (cardholderTypes == null) {
			ArrayList<SelectItem> items = new ArrayList<SelectItem>();
			try {
				SelectionParams params = new SelectionParams();
				params.setRowIndexEnd(-1);

				List<Filter> filtersList = new ArrayList<Filter>();
				Filter paramFilter = new Filter();
				paramFilter.setElement("lang");
				paramFilter.setOp(Operator.eq);
				paramFilter.setValue(userLang);
				filtersList.add(paramFilter);

				params.setFilters(filtersList.toArray(new Filter[filtersList.size()]));

				CardType[] types = networkDao.getCardTypes(userSessionId, params);
				for (CardType type : types) {
					String name = type.getName();
					for (int i = 1; i < type.getLevel(); i++) {
						name = " -- " + name;
					}
					items.add(new SelectItem(type.getId(), name));
				}
				cardholderTypes = items;
			} catch (Exception e) {
				logger.error("", e);
				if (!e.getMessage().contains(SystemConstants.INSUFFICIENT_PRIVILEGES_ERROR)) {
					FacesUtils.addMessageError(e);
				}
			} finally {
				if (cardholderTypes == null)
					cardholderTypes = new ArrayList<SelectItem>();
			}
		}
		return cardholderTypes;
	}

	public boolean isSearchByCard() {
		return searchByCard;
	}

	public void setSearchByCard(boolean searchByCard) {
		this.searchByCard = searchByCard;
	}

	protected HashMap<String, Boolean> loadedTabs = new HashMap<String, Boolean>();
	private String needRerender;
	List<String> rerenderList;

	public String getTabName() {
		return tabName;
	}

	public void setTabName(String tabName) {
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

		if (tabName.equalsIgnoreCase("personIdsTab")) {
			MbPersonId bean = (MbPersonId) ManagedBeanWrapper.getManagedBean("MbPersonId");
			bean.setTabName(tabName);
			bean.setParentSectionId(getSectionId());
			bean.setTableState(getSateFromDB(bean.getComponentId()));
		} else if (tabName.equalsIgnoreCase("cardsTab")) {
			MbCardsBottomSearch bean = (MbCardsBottomSearch) ManagedBeanWrapper.getManagedBean("MbCardsBottomSearch");
			bean.setTabNameParam(tabName);
			bean.setParentSectionId(getSectionId());
			bean.setTableState(getSateFromDB(bean.getComponentId()));
		} else if (tabName.equalsIgnoreCase("flexibleFieldsTab")) {
			MbFlexFieldsDataSearch bean = (MbFlexFieldsDataSearch) ManagedBeanWrapper.getManagedBean("MbFlexFieldsDataSearch");
			bean.setTabName(tabName);
			bean.setParentSectionId(getSectionId());
			bean.setTableState(getSateFromDB(bean.getComponentId()));
		} else if (tabName.equalsIgnoreCase("contactsTab")) {
			MbContactSearch bean = (MbContactSearch) ManagedBeanWrapper.getManagedBean("MbContactSearch");
			bean.setTabName(tabName);
			bean.setParentSectionId(getSectionId());
			bean.setTableState(getSateFromDB(bean.getComponentId()));
			MbContactDataSearch dataBean = (MbContactDataSearch) ManagedBeanWrapper.getManagedBean("MbContactDataSearch");
			dataBean.setTabName(tabName);
			dataBean.setParentSectionId(getSectionId());
			dataBean.setTableState(getSateFromDB(dataBean.getComponentId()));
		} else if (tabName.equalsIgnoreCase("ADDRESSESTAB")) {
			MbAddressesSearch addr = (MbAddressesSearch) ManagedBeanWrapper.getManagedBean("MbAddressesSearch");
			addr.setTabName(tabName);
			addr.setParentSectionId(getSectionId());
			addr.setTableState(getSateFromDB(addr.getComponentId()));
		} else if (tabName.equalsIgnoreCase("ntfEventTab")) {
			MbNtfEventBottom ntf = (MbNtfEventBottom) ManagedBeanWrapper.getManagedBean("MbNtfEventBottom");
			ntf.setTabName(tabName);
			ntf.setParentSectionId(getSectionId());
			ntf.setTableState(getSateFromDB(ntf.getComponentId()));
		} else if (tabName.equalsIgnoreCase("applicationsTab")) {
			MbObjectApplicationsSearch app = (MbObjectApplicationsSearch) ManagedBeanWrapper.getManagedBean(MbObjectApplicationsSearch.class);
			app.setTabName(tabName);
			app.setParentSectionId(getSectionId());
			app.setTableState(getSateFromDB(app.getComponentId()));
		} else if (tabName.equalsIgnoreCase("notesTab")) {
            MbNotesSearch bean = ManagedBeanWrapper
                    .getManagedBean("MbNotesSearch");
            bean.setTabName(tabName);
            bean.setParentSectionId(getSectionId());
            bean.setTableState(getSateFromDB(bean.getComponentId()));
        }
	}

	public String getSectionId() {
		return SectionIdConstants.ISSUING_CARDHOLDER;
	}

	private void loadTab(String tab) {
		if (tab == null)
			return;
		if (activeCardholder == null)
			return;

		if (tab.equalsIgnoreCase("cardsTab")) {
			MbCardsBottomSearch cardsSearch = (MbCardsBottomSearch) ManagedBeanWrapper.getManagedBean("MbCardsBottomSearch");
			Card cardFilter = new Card();
			cardFilter.setCardholderId(activeCardholder.getId());
			cardsSearch.setFilter(cardFilter);
			cardsSearch.setSearchByHolder(true);
			cardsSearch.setSearchTabName("CARDHOLDER");
			cardsSearch.search();
		} else if (tab.equalsIgnoreCase("personIdsTab")) {
			// TODO change MbPersonId loadDaoData()
			MbPersonId doc = (MbPersonId) ManagedBeanWrapper.getManagedBean("MbPersonId");
			doc.setIdOfPerson(activeCardholder.getPersonId());
			doc.search();
		} else if (tab.equalsIgnoreCase("flexibleFieldsTab")) {
			// get flexible data for this institution
			MbFlexFieldsDataSearch flexible = (MbFlexFieldsDataSearch) ManagedBeanWrapper.getManagedBean("MbFlexFieldsDataSearch");
			FlexFieldData filterFlex = new FlexFieldData();
			filterFlex.setInstId(activeCardholder.getInstId());
			filterFlex.setEntityType(EntityNames.CARDHOLDER);
			filterFlex.setObjectId(activeCardholder.getId());
			flexible.setFilter(filterFlex);
			flexible.search();
		} else if (tab.equalsIgnoreCase("CONTACTSTAB")) {
			// get contacts for this institution
			MbContactSearch cont = (MbContactSearch) ManagedBeanWrapper.getManagedBean("MbContactSearch");
			cont.setBackLink(thisBackLink);
			cont.setObjectId(activeCardholder.getId());
			cont.setEntityType(EntityNames.CARDHOLDER);
			cont.search();
		} else if (tab.equalsIgnoreCase("ADDRESSESTAB")) {
			// get addresses for this institution
			MbAddressesSearch addr = (MbAddressesSearch) ManagedBeanWrapper.getManagedBean("MbAddressesSearch");
			addr.fullCleanBean();
			addr.getFilter().setEntityType(EntityNames.CARDHOLDER);
			addr.getFilter().setObjectId(activeCardholder.getId());
			addr.setCurLang(userLang);
			addr.search();
		} else if (tab.equalsIgnoreCase("ntfEventTab")) {
			MbNtfEventBottom ntf = (MbNtfEventBottom) ManagedBeanWrapper.getManagedBean("MbNtfEventBottom");
			ntf.setEntityType(EntityNames.CARDHOLDER);
			ntf.setObjectId(activeCardholder.getId());
			ntf.search();
		} else if (tab.equalsIgnoreCase("applicationsTab")) {
			MbObjectApplicationsSearch app = (MbObjectApplicationsSearch) ManagedBeanWrapper.getManagedBean(MbObjectApplicationsSearch.class);
			app.setEntityType(EntityNames.CARDHOLDER);
			app.setObjectId(activeCardholder.getId());
			app.search();
		} else if(tabName.equals("notesTab")){
            MbNotesSearch notesSearch = ManagedBeanWrapper
                    .getManagedBean("MbNotesSearch");
            ObjectNoteFilter filterNote = new ObjectNoteFilter();
            filterNote.setEntityType(EntityNames.CARDHOLDER);
            filterNote.setObjectId(activeCardholder.getId());
            notesSearch.setFilter(filterNote);
            notesSearch.search();
        }

		needRerender = tab;
		loadedTabs.put(tab, Boolean.TRUE);
	}

	public List<String> getRerenderList() {
		rerenderList = new ArrayList<String>();
		rerenderList.clear();
		if (needRerender != null) {
			rerenderList.add(needRerender);
		}
		rerenderList.add("err_ajax");
		return rerenderList;
	}

	public HashMap<String, Boolean> getLoadedTabs() {
		return loadedTabs;
	}

	public Cardholder getCardholder() {
		if (getFilter().getId() != null) {
			try {
				SelectionParams params = new SelectionParams();
				setFilters();
				params.setFilters(filters.toArray(new Filter[filters.size()]));
                getParamMaps().put("param_tab", filters.toArray(new Filter[filters.size()]));
                getParamMaps().put("tab_name", "CARDHOLDER");
				Cardholder[] cardholders = issuingDao.getCardholdersCur(userSessionId, params, getParamMaps());
				if (cardholders != null && cardholders.length > 0) {
					activeCardholder = cardholders[0];
				}
				return activeCardholder;
			} catch (Exception e) {
				FacesUtils.addMessageError(e);
				logger.error("", e);
			}
		}
		return null;
	}

	/**
	 * Initializes bean's filter if bean has been accessed by context menu.
	 */
	private void initFilterFromContext() {
		filter = new Cardholder();
		if (FacesUtils.getSessionMapValue("cardholderName") != null) {
			filter.setCardholderName((String) FacesUtils.getSessionMapValue("cardholderName"));
			FacesUtils.setSessionMapValue("cardholderName", null);
		}
		if (FacesUtils.getSessionMapValue("cardholderNumber") != null) {
			filter.setCardholderNumber((String) FacesUtils.getSessionMapValue("cardholderNumber"));
			FacesUtils.setSessionMapValue("cardholderNumber", null);
		}
		if (FacesUtils.getSessionMapValue("instId") != null) {
			filter.setInstId((Integer) FacesUtils.getSessionMapValue("instId"));
			FacesUtils.setSessionMapValue("instId", null);
		}
	}

	public String back() {
		FacesUtils.setSessionMapValue(backLink, Boolean.TRUE);
		return backLink;
	}

	public boolean isShowBackBtn() {
		return backLink != null && (backLink.trim().length() > 0);
	}

	public String getComponentId() {
		return COMPONENT_ID;
	}

	public Logger getLogger() {
		return logger;
	}

	public String getCtxItemEntityType() {
		return ctxItemEntityType;
	}

	public void setCtxItemEntityType() {
		MbContextMenu ctxBean = (MbContextMenu) ManagedBeanWrapper.getManagedBean("MbContextMenu");
		String ctx = ctxBean.getEntityType();
		if (ctx == null || !ctx.equals(this.ctxItemEntityType)) {
			ctxType = ContextTypeFactory.getInstance(ctx);
		}
		this.ctxItemEntityType = ctx;
	}

	public ContextType getCtxType() {
		if (ctxType == null) return null;
		Map<String, Object> map = new HashMap<String, Object>();

		if (EntityNames.INSTITUTION.equals(ctxItemEntityType)) {
			if (activeCardholder != null) {
				map.put("id", activeCardholder.getInstId());
				map.put("instId", activeCardholder.getInstId());
			}
		} else if (EntityNames.CARDHOLDER.equals(ctxItemEntityType)) {
			map.put("id", activeCardholder.getId());
		}

		ctxType.setParams(map);
		return ctxType;
	}

	public boolean isForward() {
		return !ctxItemEntityType.equals(EntityNames.CARDHOLDER);
	}

	public String getFilterCardNumber() {
		return filterCardNumber;
	}

	public void setFilterCardNumber(String filterCardNumber) {
		this.filterCardNumber = filterCardNumber;
	}

	public String getFilterCardUid() {
		return filterCardUid;
	}

	public void setFilterCardUid(String filterCardUid) {
		this.filterCardUid = filterCardUid;
	}

	public String getFilterCustomerNumber() {
		return filterCustomerNumber;
	}

	public void setFilterCustomerNumber(String filterCustomerNumber) {
		this.filterCustomerNumber = filterCustomerNumber;
	}

	public Long getFilterCustomerId() {
		return filterCustomerId;
	}

	public void setFilterCustomerId(Long filterCustomerId) {
		this.filterCustomerId = filterCustomerId;
	}

	public String getCustomerInfo() {
		return customerInfo;
	}

	public void setCustomerInfo(String customerInfo) {
		this.customerInfo = customerInfo;
	}

	public void showCustomers() {
		MbCustomerSearchModal custBean = ManagedBeanWrapper.getManagedBean(MbCustomerSearchModal.class);
		custBean.clearFilter();
		if (getFilter().getInstId() != null) {
			custBean.setDefaultInstId(getFilter().getInstId());
		}
		custBean.setBlockInstId(false);
	}

	public void selectCustomer() {
		MbCustomerSearchModal custBean = ManagedBeanWrapper.getManagedBean(MbCustomerSearchModal.class);
		Customer selected = custBean.getActiveCustomer();
		if (selected != null) {
			filterCustomerId = selected.getId();
			filterCustomerNumber = selected.getCustomerNumber();
			customerInfo = selected.getName();
		}
	}

	public void displayCustInfo() {
		if (getCustomerInfo() == null || getCustomerInfo().isEmpty()) {
			setFilterCustomerNumber(null);
			setFilterCustomerId(null);
			return;
		}

		// process wildcard
		Pattern p = Pattern.compile("\\*|%|\\?");
		Matcher m = p.matcher(getCustomerInfo());
		if (m.find() || getFilter().getInstId() == null) {
			setFilterCustomerNumber(getCustomerInfo());
			return;
		}

		// search and redisplay
		Filter[] filters = new Filter[3];
		filters[0] = new Filter("LANG", curLang);
		filters[1] = new Filter("INST_ID", getFilter().getInstId());
		filters[2] = new Filter("CUSTOMER_NUMBER", getCustomerInfo());

		SelectionParams params = new SelectionParams();
		params.setFilters(filters);
		try {
			Customer[] cust = productsDao.getCombinedCustomersProc(userSessionId, params, "CUSTOMER");
			if (cust != null && cust.length > 0) {
				setCustomerInfo(cust[0].getName());
				setFilterCustomerNumber(cust[0].getCustomerNumber());
				setFilterCustomerId(cust[0].getId());
			} else {
				setFilterCustomerNumber(getCustomerInfo());
				setFilterCustomerId(null);
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public String getFilterContractNumber() {
		return filterContractNumber;
	}

	public void setFilterContractNumber(String filterContractNumber) {
		this.filterContractNumber = filterContractNumber;
	}

	@Override
	protected void applySectionFilter(Integer filterId) {
		try {
			FilterFactory factory = (FilterFactory) ManagedBeanWrapper.getManagedBean("filterFactory");
			Map<String, String> filterRec = factory.getSectionFilterRecs(filterId);
			sectionFilter = factory.getUserSectionFiltersObjects().get(filterId);
			if (filterRec != null) {
				filter = new Cardholder();
				setFilterForm(filterRec);
				if (searchAutomatically)
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
			FilterFactory factory = (FilterFactory) ManagedBeanWrapper.getManagedBean("filterFactory");

			Map<String, String> filterRec = new HashMap<String, String>();
			filter = getFilter();
			setFilterRec(filterRec);

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

	private void setFilterForm(Map<String, String> filterRec) throws ParseException {
		getFilter();
		filters = new ArrayList<Filter>();
		if (filterRec.get("instId") != null) {
			filter.setInstId(Integer.parseInt(filterRec.get("instId")));
		}
		if (filterRec.get("cardholderName") != null) {
			filter.setCardholderName(filterRec.get("cardholderName"));
		}
		if (filterRec.get("cardholderNumber") != null) {
			filter.setCardholderNumber(filterRec.get("cardholderNumber"));
		}
		if (filterRec.get("personFirstName") != null) {
			filter.getPerson().setFirstName(filterRec.get("personFirstName"));
		}
		if (filterRec.get("personSurname") != null) {
			filter.getPerson().setSurname(filterRec.get("personSurname"));
		}
		if (filterRec.get("cardNumber") != null) {
			setFilterCardNumber(filterRec.get("cardNumber"));
		}
		if (filterRec.get("cardUid") != null) {
			setFilterCardUid(filterRec.get("cardUid"));
		}
		if (filterRec.get("customerNumber") != null) {
			setFilterCustomerNumber(filterRec.get("customerNumber"));
		}
		if (filterRec.get("customerId") != null) {
			setFilterCustomerId(Long.valueOf(filterRec.get("customerId")));
		}
		if (filterRec.get("contractNumber") != null) {
			setFilterContractNumber(filterRec.get("contractNumber"));
		}
		if (filterRec.get("idType") != null) {
			setFilterIdType(filterRec.get("idType"));
		}
		if (filterRec.get("idNumber") != null) {
			setFilterIdNumber(filterRec.get("idNumber"));
		}
	}

	private void setFilterRec(Map<String, String> filterRec) {
		if (filter.getInstId() != null) {
			filterRec.put("instId", filter.getInstId().toString());
		}
		if (filter.getCardholderName() != null) {
			filterRec.put("cardholderName", filter.getCardholderName());
		}
		if (filter.getCardholderNumber() != null) {
			filterRec.put("cardholderNumber", filter.getCardholderNumber());
		}
		if (filter.getPerson().getFirstName() != null) {
			filterRec.put("personFirstName", filter.getPerson().getFirstName());
		}
		if (filter.getPerson().getSurname() != null) {
			filterRec.put("personSurname", filter.getPerson().getSurname());
		}
		if (getFilterCardNumber() != null) {
			filterRec.put("cardNumber", getFilterCardNumber());
		}
		if (getFilterCardUid() != null) {
			filterRec.put("cardUid", getFilterCardUid());
		}
		if (getFilterCustomerNumber() != null) {
			filterRec.put("customerNumber", getFilterCustomerNumber());
		}
		if (getFilterCustomerId() != null) {
			filterRec.put("customerId", getFilterCustomerId().toString());
		}
		if (getFilterContractNumber() != null) {
			filterRec.put("contractNumber", getFilterContractNumber());
		}
		if (getFilterIdType() != null) {
			filterRec.put("idType", getFilterIdType());
		}
		if (getFilterIdNumber() != null) {
			filterRec.put("idNumber", getFilterIdNumber());
		}
	}

	public String getFilterIdType() {
		return filterIdType;
	}

	public void setFilterIdType(String filterIdType) {
		this.filterIdType = filterIdType;
	}

	public String getFilterIdNumber() {
		return filterIdNumber;
	}

	public void setFilterIdNumber(String filterIdNumber) {
		this.filterIdNumber = filterIdNumber;
	}

    public void onSortablePreRenderTable() {
        onSortablePreRenderTable(cardholdersSource);
    }

    public Map<String, Object> getParamMaps() {
        if (paramMaps == null) {
            paramMaps = new HashMap<String, Object>();
        }
        return paramMaps;
    }

    public void setParamMaps(Map<String, Object> paramMaps) {
        this.paramMaps = paramMaps;
    }
}
