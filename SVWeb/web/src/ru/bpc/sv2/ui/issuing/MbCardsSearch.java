package ru.bpc.sv2.ui.issuing;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;
import ru.bpc.sv2.acm.AcmAction;
import ru.bpc.sv2.common.CommonWizardStepInfo;
import ru.bpc.sv2.common.FlexFieldData;
import ru.bpc.sv2.constants.EntityNames;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.constants.SectionIdConstants;
import ru.bpc.sv2.constants.SystemConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.Filter.Operator;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.issuing.Card;
import ru.bpc.sv2.issuing.CardInstance;
import ru.bpc.sv2.issuing.Cardholder;
import ru.bpc.sv2.logic.*;
import ru.bpc.sv2.net.Network;
import ru.bpc.sv2.notes.ObjectNoteFilter;
import ru.bpc.sv2.operations.Participant;
import ru.bpc.sv2.products.Customer;
import ru.bpc.sv2.products.ProductConstants;
import ru.bpc.sv2.reports.RptDocument;
import ru.bpc.sv2.security.QuestionWord;
import ru.bpc.sv2.ui.accounts.MbAccountsSearch;
import ru.bpc.sv2.ui.accounts.MbObjectDocuments;
import ru.bpc.sv2.ui.acm.MbContextMenu;
import ru.bpc.sv2.ui.application.MbApplicationsSearch;
import ru.bpc.sv2.ui.application.MbObjectApplicationsSearch;
import ru.bpc.sv2.ui.aup.MbAupSchemeObjects;
import ru.bpc.sv2.ui.common.MbAddressesSearch;
import ru.bpc.sv2.ui.common.flexible.MbFlexFieldsDataSearch;
import ru.bpc.sv2.ui.common.wizard.MbCommonWizard;
import ru.bpc.sv2.ui.common.wizard.callcenter.MbOperTypeSelectionStep;
import ru.bpc.sv2.ui.context.ContextType;
import ru.bpc.sv2.ui.context.ContextTypeFactory;
import ru.bpc.sv2.ui.events.MbStatusLogs;
import ru.bpc.sv2.ui.fcl.cycles.MbCardCycleCounters;
import ru.bpc.sv2.ui.fcl.cycles.MbCycleCounters;
import ru.bpc.sv2.ui.fcl.limits.MbLimitCounters;
import ru.bpc.sv2.ui.fraud.MbFraudObjects;
import ru.bpc.sv2.ui.navigation.Menu;
import ru.bpc.sv2.ui.notes.MbNotesSearch;
import ru.bpc.sv2.ui.notifications.MbNtfEventBottom;
import ru.bpc.sv2.ui.operations.MbOperationsBottom;
import ru.bpc.sv2.ui.products.MbAttributeValues;
import ru.bpc.sv2.ui.products.MbCustomerSearchModal;
import ru.bpc.sv2.ui.products.MbCustomersDependent;
import ru.bpc.sv2.ui.products.MbObjectAttributes;
import ru.bpc.sv2.ui.reports.MbEntityObjectInfoBottom;
import ru.bpc.sv2.ui.reports.MbReportsBottom;
import ru.bpc.sv2.ui.scoring.MbScoringCalculation;
import ru.bpc.sv2.ui.utils.*;
import util.auxil.ManagedBeanWrapper;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.event.ValueChangeEvent;
import javax.faces.model.SelectItem;
import javax.servlet.http.HttpServletRequest;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

@ViewScoped
@ManagedBean (name = "MbCardsSearch")
public class MbCardsSearch extends AbstractBean {
    private static final long serialVersionUID = 1L;

    private static final Logger logger = Logger.getLogger("ISSUING");
    private static Logger classLogger = Logger.getLogger(MbCardsSearch.class);

    private static String COMPONENT_ID = "1012:cardsTable";
    private static Integer DEFAULT_INST = 9999;

    private IssuingDao _issuingDao = new IssuingDao();
    private NetworkDao _networkDao = new NetworkDao();
    private SecurityDao _securityDao = new SecurityDao();
    private ProductsDao _productsDao = new ProductsDao();
    private EventsDao _eventsDao = new EventsDao();

    private Menu mbMenu;

    private boolean secWordCorrect;
    private QuestionWord secWord;
    private String secWordEntity;
    private Long secWordObjectId;

    private Card filter;
    private Card _activeCard;
    private Card newCard;

    private ArrayList<SelectItem> institutions;
    private ArrayList<SelectItem> networks;
    private ArrayList<SelectItem> cardTypes;

    protected String tabName;
    private String backLink;

    private final DaoDataModel<Card> _cardsSource;
    private final TableRowSelection<Card> _itemSelection;

    protected HashMap<String, Boolean> loadedTabs = new HashMap<String, Boolean>();
    protected String needRerender;
    private List<String> rerenderList;

    private boolean searchByHolder;
    private AcmAction selectedCtxItem;

    private MbCards sessBean;
    private boolean saveAfterSearch;

    private String ctxItemEntityType;
    private ContextType ctxType;
    private Map<String, Object> paramMaps;
    private String module;

    private String contractType;
    private List<SelectItem> contractTypes;

    public MbCardsSearch() {
        pageLink = "issuing|cards";
        mbMenu = (Menu) ManagedBeanWrapper.getManagedBean("menu");
        tabName = "detailsTab";
        beanEntityType = EntityNames.CARD;
        thisBackLink = "issuing|cards";
        sessBean = (MbCards) ManagedBeanWrapper.getManagedBean("MbCards");

        _cardsSource = new DaoDataModel<Card>(true) {
            private static final long serialVersionUID = 1L;

            @Override
            protected Card[] loadDaoData(SelectionParams params) {
                if (!searching) {
                    return new Card[0];
                }
                try {
                    setFilters();
                    params.setFilters(filters.toArray(new Filter[filters.size()]));
                    getParamMaps().put("param_tab", filters.toArray(new Filter[filters.size()]));
                    paramMaps.put("tab_name", "CARD");
                    params.setModule(getModule());

                    return _issuingDao.getCardsCur(userSessionId, params, paramMaps);
                } catch (Exception e) {
                    FacesUtils.addMessageError(e);
                    setDataSize(0);
                    logger.error("", e);
                }
                return new Card[0];
            }

            @Override
            protected int loadDaoDataSize(SelectionParams params) {
                if (!searching) {
                    return 0;
                }
                int count = 0;
                int threshold = 1000;
                try {
                    setFilters();
                    params.setFilters(filters.toArray(new Filter[filters.size()]));
                    params.setThreshold(threshold);
                    getParamMaps().put("param_tab", filters.toArray(new Filter[filters.size()]));
                    paramMaps.put("tab_name", "CARD");
                    params.setModule(getModule());
                    count = _issuingDao.getCardsCurCount(userSessionId, params, paramMaps);
                } catch (Exception e) {
                    FacesUtils.addMessageError(e);
                    logger.error("", e);
                }
                return count;
            }
        };

        restoreBean = (Boolean) FacesUtils.getSessionMapValue(thisBackLink);
        if (restoreBean == null || !restoreBean) {
            restoreBean = Boolean.FALSE; // just to be sure it's not NULL
        } else {
            restoreBean();
        }

        _itemSelection = new TableRowSelection<Card>(null, _cardsSource);

        HttpServletRequest req = RequestContextHolder.getRequest();
        String sectionId = req.getParameter("sectionId");
        String filterId = req.getParameter("filterId");

        if (sectionId != null && filterId != null && sectionId.equals("1012")) {
            selectedSectionFilter = Integer.parseInt(filterId);
            applySectionFilter(selectedSectionFilter);
        }
        restoreFilter();
    }

    public void onSortablePreRenderTable() {
        onSortablePreRenderTable(_cardsSource);
    }

    private void restoreFilter() {
        HashMap<String, Object> queueFilter = getQueueFilter("MbCardsSearch");
        if (queueFilter != null) {
            if (queueFilter.containsKey("instId")) {
                getFilter().setInstId((Integer) queueFilter.get("instId"));
            }

            if (queueFilter.containsKey("agentId")) {
                getFilter().setInstId((Integer) queueFilter.get("agentId"));
            }

            if (queueFilter.containsKey("cardNumber")) {
                getFilter().setCardNumber((String) queueFilter.get("cardNumber"));
            }

            if (queueFilter.containsKey("contractType")) {
                getFilter().setCardNumber((String) queueFilter.get("contractType"));
            }

            if (queueFilter.containsKey("backLink")) {
                backLink = (String) queueFilter.get("backLink");
            }
            addFilterToQueue("MbFraudAlerts", queueFilter);
            search();
        }
    }

    public void setupOperTypeSelection() {
        classLogger.trace("setupOperTypeSelection...");
        CommonWizardStepInfo step = new CommonWizardStepInfo();
        step.setOrder(0);
        step.setSource(MbOperTypeSelectionStep.class.getSimpleName());
        step.setName(FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Opr", "select_oper_type"));
        List<CommonWizardStepInfo> stepsList = new ArrayList<CommonWizardStepInfo>();
        stepsList.add(step);
        Map<String, Object> context = new HashMap<String, Object>();
        context.put(MbCommonWizard.STEPS, stepsList);
        context.put(MbOperTypeSelectionStep.ENTITY_TYPE, EntityNames.CARD);
        context.put(MbOperTypeSelectionStep.OBJECT_ID, _activeCard.getId());
	    context.put(MbOperTypeSelectionStep.ENTITY_OBJECT_TYPE, _activeCard.getCategory());

        context.put("INST_ID", _activeCard.getInstId());
        context.put(MbOperTypeSelectionStep.OBJECT_TYPE, Participant.ISS_PARTICIPANT);
        MbCommonWizard wizard = ManagedBeanWrapper.getManagedBean(MbCommonWizard.class);
        wizard.init(context);
    }

    public void updateInstances() {
        classLogger.trace("updateInstances...");
        MbCardInstancesSearch instancesSearch = ManagedBeanWrapper
                .getManagedBean(MbCardInstancesSearch.class);
        instancesSearch.search();
    }

    public DaoDataModel<Card> getCards() {
        return _cardsSource;
    }

    public Card getActiveCard() {
        return _activeCard;
    }

    public void setActiveCard(Card activeCard) {
        _activeCard = activeCard;
        setInfo();
    }

    public Card loadCard() {
        _activeCard = null;
        setFilters();
        SelectionParams params = new SelectionParams();
        params.setFilters((Filter[]) filters.toArray(new Filter[filters.size()]));
        getParamMaps().put("param_tab", filters.toArray(new Filter[filters.size()]));
        paramMaps.put("tab_name", "CARD");
        try {
            Card[] cards = _issuingDao.getCardsCur(userSessionId, params, paramMaps);
            if (cards != null && cards.length > 0) {
                _activeCard = cards[0];
            }
        } catch (Exception e) {
            logger.error("", e);
            FacesUtils.addMessageError(e);
        }
        return _activeCard;
    }

    public SimpleSelection getItemSelection() {
        try {
            if (_activeCard == null && _cardsSource.getRowCount() > 0) {
                setFirstRowActive();
            } else if (_activeCard != null && _cardsSource.getRowCount() > 0) {
                SimpleSelection selection = new SimpleSelection();
                selection.addKey(_activeCard.getModelId());
                _itemSelection.setWrappedSelection(selection);
                _activeCard = _itemSelection.getSingleSelection();
            }
            if (_activeCard != null) {
                saveBean();
                if (saveAfterSearch) {
                    FacesUtils.setSessionMapValue(thisBackLink, Boolean.TRUE);
                }
            }
        } catch (Exception e) {
            logger.error("", e);
            FacesUtils.addMessageError(e);
        }
        return _itemSelection.getWrappedSelection();
    }

    public void setFirstRowActive() {
        _cardsSource.setRowIndex(0);
        SimpleSelection selection = new SimpleSelection();
        _activeCard = (Card) _cardsSource.getRowData();
        selection.addKey(_activeCard.getModelId());
        _itemSelection.setWrappedSelection(selection);
        if (_activeCard != null) {
            setInfo();
        }
    }

    public void setItemSelection(SimpleSelection selection) {
        _itemSelection.setWrappedSelection(selection);
        _activeCard = _itemSelection.getSingleSelection();
        if (_activeCard != null) {
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
        sectionFilterModeEdit = true;
        sectionFilter = null;
        selectedSectionFilter = null;

        filter = null;
        clearState();
        searching = false;
    }

    public Card getFilter() {
        // load it here because it's always called before other important
        // fields, moreover it's called always when page is loaded even
        // if bean was already initialized and hence constructor wasn't called.
        restoreBean = (Boolean) FacesUtils.getSessionMapValue(thisBackLink);
        if (restoreBean != null && restoreBean) {
            restoreBean();
        }
        if (Boolean.TRUE.equals(FacesUtils.getSessionMapValue("initFromContext"))) {
            FacesUtils.setSessionMapValue("initFromContext", null);
            initFilterFromContext();
            backLink = (String) FacesUtils.getSessionMapValue("backLink");
            search();
        }

        if (filter == null) {
            filter = new Card();
            filter.setInstId(userInstId);
        }
        return filter;
    }

    public void setFilter(Card filter) {
        this.filter = filter;
    }

    private String prepare(Object raw) {
        if (raw != null) {
            if (raw instanceof String) {
                return ((String) raw).trim().replaceAll("[*]", "%").replaceAll("[?]", "_").toUpperCase();
            }
            return raw.toString();
        }
        return null;
    }

    private void addFilter(String name, Object value) {
        addFilter(name, Operator.eq, value);
    }
    private void addFilter(String name, Operator action, Object value) {
        if (value != null) {
            Filter parameter = new Filter();
            parameter.setElement(name);
            parameter.setOp(action);
            if (Operator.like.equals(action)) {
                parameter.setCondition("like");
            }
            parameter.setValue(value);
            filters.add(parameter);
        }
    }

    private void setFilters() {
        filter = getFilter();
        filters = new ArrayList<Filter>();

        addFilter("CARD_ID", filter.getId());
        addFilter("cardholderId", prepare(filter.getCardholderId()));
        addFilter("CUSTOMER_ID", filter.getCustomerId());
        addFilter("LANG", curLang);
        addFilter("INST_ID", filter.getInstId());
        addFilter("CARD_TYPE_ID", filter.getCardTypeId());
        addFilter("ACCOUNT_ID", filter.getAccountId());
        addFilter("EXPIR_DATE", filter.getExpDate());
        addFilter("CARD_STATE", filter.getCardStateDescr());
        addFilter("CARD_STATUS", filter.getCardStatusDescr());
        addFilter("CONTRACT_TYPE", filter.getContractType() != null && filter.getContractType().trim().length() > 0 ?
                                    filter.getContractType() : contractType);

        if (filter.getCardholderName() != null && filter.getCardholderName().trim().length() > 0) {
            addFilter("CARDHOLDER_NAME", Operator.like, prepare(filter.getCardholderName()));
        }
        if (filter.getCardNumber() != null && filter.getCardNumber().trim().length() > 0) {
            addFilter("CARD_NUMBER", Operator.like, prepare(filter.getCardNumber()));
        }
        if (filter.getCardUid() != null && filter.getCardUid().trim().length() > 0) {
            addFilter("CARD_UID", Operator.like, prepare(filter.getCardUid()));
        }
        if (filter.getCustomerNumber() != null && filter.getCustomerNumber().trim().length() > 0) {
            addFilter("CUSTOMER_NUMBER", filter.getCustomerNumber().replaceAll("[*]", "%").replaceAll("[?]", "_"));
        }
        if (getFilter().getContractNumber() != null && !getFilter().getContractNumber().trim().isEmpty()) {
            addFilter("CONTRACT_NUMBER", prepare(filter.getContractNumber()));
        }
        if (filter.getFirstName() != null && filter.getFirstName().trim().length() > 0) {
            addFilter("FIRST_NAME", Operator.like, prepare(filter.getFirstName()));
        }
        if (filter.getSurname() != null && filter.getSurname().trim().length() > 0) {
            addFilter("SURNAME", Operator.like, prepare(filter.getSurname()));
        }
    }

    public void add() {
        newCard = new Card();
        curMode = NEW_MODE;
    }

    public void edit() {
        try {
            newCard = (Card) _activeCard.clone();
        } catch (CloneNotSupportedException e) {
            logger.error("", e);
            newCard = _activeCard;
        }
        curMode = EDIT_MODE;
    }

    public void view() {

    }

    public void close() {
        curMode = VIEW_MODE;
    }

    public Card getNewCard() {
        if (newCard == null) {
            newCard = new Card();
        }
        return newCard;
    }

    public void setNewCard(Card newCard) {
        this.newCard = newCard;
    }

    public void clearState() {
        _itemSelection.clearSelection();
        _activeCard = null;
        _cardsSource.flushCache();
        curLang = userLang;
        loadedTabs.clear();
        getParamMaps().clear();

        clearBeansStates();
    }

    public void clearBeansStates() {

        MbAddressesSearch addressesSearch = (MbAddressesSearch) ManagedBeanWrapper
                .getManagedBean("MbAddressesSearch");
        addressesSearch.clearState();
        addressesSearch.setFilter(null);
        addressesSearch.setSearching(false);


        MbCardInstancesSearch instancesSearch = (MbCardInstancesSearch) ManagedBeanWrapper
                .getManagedBean("MbCardInstancesSearch");
        instancesSearch.clearState();
        instancesSearch.setFilter(null);
        instancesSearch.setSearching(false);

        MbOperationsBottom operationsBean = (MbOperationsBottom) ManagedBeanWrapper
                .getManagedBean("MbOperationsBottom");
        operationsBean.clearState();
        operationsBean.setFilter(null);
        operationsBean.setSearching(false);

        if (!searchByHolder) {
            MbCardholdersSearch cardholdersBean = (MbCardholdersSearch) ManagedBeanWrapper
                    .getManagedBean("MbCardholdersSearch");
            cardholdersBean.clearState();
            cardholdersBean.setFilter(null);
            cardholdersBean.setSearching(false);
        }

        MbStatusLogs statusLogs = (MbStatusLogs) ManagedBeanWrapper.getManagedBean("MbStatusLogs");
        statusLogs.clearFilter();

        MbAupSchemeObjects schemeBean = (MbAupSchemeObjects) ManagedBeanWrapper
                .getManagedBean("MbAupSchemeObjects");
        schemeBean.fullCleanBean();

        MbLimitCounters limitCountersBean = (MbLimitCounters) ManagedBeanWrapper
                .getManagedBean("MbLimitCounters");
        limitCountersBean.clearFilter();

        MbCycleCounters cycleCountersBean = (MbCycleCounters) ManagedBeanWrapper
                .getManagedBean("MbCycleCounters");
        cycleCountersBean.clearFilter();

        MbObjectDocuments mbObjectDocuments = (MbObjectDocuments) ManagedBeanWrapper
                .getManagedBean("MbObjectDocuments");
        mbObjectDocuments.clearFilter();

        MbFlexFieldsDataSearch flexible = (MbFlexFieldsDataSearch) ManagedBeanWrapper
                .getManagedBean("MbFlexFieldsDataSearch");
        flexible.clearFilter();

        MbObjectApplicationsSearch mbAppObjects = (MbObjectApplicationsSearch) ManagedBeanWrapper
                .getManagedBean(MbObjectApplicationsSearch.class);
        mbAppObjects.clearFilter();

        MbFraudObjects suiteObjectBean = (MbFraudObjects) ManagedBeanWrapper.getManagedBean("MbFraudObjects");
        suiteObjectBean.fullCleanBean();

        MbReportsBottom reportBean = (MbReportsBottom) ManagedBeanWrapper.getManagedBean("MbReportsBottom");
        reportBean.clearFilter();

        MbEntityObjectInfoBottom info = (MbEntityObjectInfoBottom) ManagedBeanWrapper.getManagedBean("MbEntityObjectInfoBottom");
        info.clearFilter();

        MbAccountsSearch accountsBean = (MbAccountsSearch) ManagedBeanWrapper.getManagedBean("MbAccountsSearch");
        accountsBean.clearFilter();


    }

    public void changeLanguage(ValueChangeEvent event) {
        curLang = (String) event.getNewValue();

        List<Filter> filtersList = new ArrayList<Filter>();

        Filter paramFilter = new Filter();
        paramFilter.setElement("id");
        paramFilter.setOp(Operator.eq);
        paramFilter.setValue(_activeCard.getId().toString());
        filtersList.add(paramFilter);

        paramFilter = new Filter();
        paramFilter.setElement("lang");
        paramFilter.setOp(Operator.eq);
        paramFilter.setValue(curLang);
        filtersList.add(paramFilter);

        filters = filtersList;
        SelectionParams params = new SelectionParams();
        params.setFilters(filters.toArray(new Filter[filters.size()]));
        try {
            Card[] cards = _issuingDao.getCards(userSessionId, params);
            if (cards != null && cards.length > 0) {
                _activeCard = cards[0];
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

                Network[] nets = _networkDao.getNetworks(userSessionId, params);
                for (Network net : nets) {
                    items.add(new SelectItem(net.getId(), net.getName(), net.getDescription()));
                }
                networks = items;
            } catch (Exception e) {
                logger.error("", e);
                if (e.getMessage().indexOf(SystemConstants.INSUFFICIENT_PRIVILEGES_ERROR) < 0) {
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
        if (cardTypes == null) {
            cardTypes = (ArrayList<SelectItem>) getDictUtils().getLov(LovConstants.CARD_TYPES);
        }
        if (cardTypes == null)
            cardTypes = new ArrayList<SelectItem>();
        return cardTypes;
    }

    public String getTabName() {
        return tabName;
    }

    public void setTabName(String tabName) {
        needRerender = null;
        this.tabName = tabName;
        if (tabName.equalsIgnoreCase("addressesTab")) {
            MbAddressesSearch bean = (MbAddressesSearch) ManagedBeanWrapper.getManagedBean("MbAddressesSearch");
            bean.setTabName(tabName);
            bean.setParentSectionId(getSectionId());
            bean.setTableState(getSateFromDB(bean.getComponentId()));
        } else if (tabName.equalsIgnoreCase("flexibleFieldsTab")) {
            MbFlexFieldsDataSearch bean = (MbFlexFieldsDataSearch) ManagedBeanWrapper.getManagedBean("MbFlexFieldsDataSearch");
            bean.setTabName(tabName);
            bean.setParentSectionId(getSectionId());
            bean.setTableState(getSateFromDB(bean.getComponentId()));
        } else if (tabName.equalsIgnoreCase("instancesTab")) {
            MbCardInstancesSearch bean = (MbCardInstancesSearch) ManagedBeanWrapper.getManagedBean("MbCardInstancesSearch");
            bean.setTabName(tabName);
            bean.setParentSectionId(getSectionId());
            bean.setTableState(getSateFromDB(bean.getComponentId()));
        } else if (tabName.equalsIgnoreCase("ACCOUNTSTAB")) {
            MbAccountsSearch accountsBean = (MbAccountsSearch) ManagedBeanWrapper.getManagedBean("MbAccountsSearch");
            accountsBean.setTabName(tabName);
            accountsBean.setParentSectionId(getSectionId());
            accountsBean.setTableState(getSateFromDB(accountsBean.getComponentId()));
        } else if (tabName.equalsIgnoreCase("operationsTab")) {
            MbOperationsBottom bean = (MbOperationsBottom) ManagedBeanWrapper.getManagedBean("MbOperationsBottom");
            bean.setTabName(tabName);
            bean.setParentSectionId(getSectionId());
            bean.setTableState(getSateFromDB(bean.getComponentId()));
        } else if (tabName.equalsIgnoreCase("attributesTab")) {
            MbAttributeValues bean = (MbAttributeValues) ManagedBeanWrapper.getManagedBean("MbAttributeValues");
            bean.setTabName(tabName);
            bean.setParentSectionId(getSectionId());
            bean.setTableState(getSateFromDB(bean.getComponentId()));
        } else if (tabName.equalsIgnoreCase("limitCountersTab")) {
            MbLimitCounters bean = (MbLimitCounters) ManagedBeanWrapper.getManagedBean("MbLimitCounters");
            bean.setTabName(tabName);
            bean.setParentSectionId(getSectionId());
            bean.setTableState(getSateFromDB(bean.getComponentId()));
        } else if (tabName.equalsIgnoreCase("cycleCountersTab")) {
            MbCycleCounters bean = (MbCycleCounters) ManagedBeanWrapper.getManagedBean("MbCycleCounters");
            bean.setTabName(tabName);
            bean.setParentSectionId(getSectionId());
            bean.setTableState(getSateFromDB(bean.getComponentId()));
        } else if (tabName.equalsIgnoreCase("statusLogsTab")) {
            MbStatusLogs bean = (MbStatusLogs) ManagedBeanWrapper.getManagedBean("MbStatusLogs");
            bean.setTabName(tabName);
            bean.setParentSectionId(getSectionId());
            bean.setTableState(getSateFromDB(bean.getComponentId()));
        } else if (tabName.equalsIgnoreCase("schemesTab")) {
            MbAupSchemeObjects bean = (MbAupSchemeObjects) ManagedBeanWrapper.getManagedBean("MbAupSchemeObjects");
            bean.setTabName(tabName);
            bean.setParentSectionId(getSectionId());
            bean.setTableState(getSateFromDB(bean.getComponentId()));
        } else if (tabName.equalsIgnoreCase("documentsTab")) {
            MbObjectDocuments bean = (MbObjectDocuments) ManagedBeanWrapper.getManagedBean("MbObjectDocuments");
            bean.setTabName(tabName);
            bean.setParentSectionId(getSectionId());
            bean.setTableState(getSateFromDB(bean.getComponentId()));
        } else if (tabName.equalsIgnoreCase("applicationsTab")) {
            MbObjectApplicationsSearch bean = (MbObjectApplicationsSearch) ManagedBeanWrapper.getManagedBean(MbObjectApplicationsSearch.class);
            bean.setTabName(tabName);
            bean.setParentSectionId(getSectionId());
            bean.setTableState(getSateFromDB(bean.getComponentId()));
        } else if (tabName.equalsIgnoreCase("suitesTab")) {
            MbFraudObjects bean = (MbFraudObjects) ManagedBeanWrapper.getManagedBean("MbFraudObjects");
            bean.setTabName(tabName);
            bean.setParentSectionId(getSectionId());
            bean.setTableState(getSateFromDB(bean.getComponentId()));
        } else if (tabName.equalsIgnoreCase("tokensTab")) {
            MbTokensSearch bean = (MbTokensSearch) ManagedBeanWrapper.getManagedBean("MbTokensSearch");
            bean.setTabName(tabName);
            bean.setCurMode(curMode);
            bean.setCurLang(curLang);
            bean.getFilter().setCardId((getActiveCard() != null) ? getActiveCard().getId() : null);
        } else if (tabName.equalsIgnoreCase("ntfEventTab")) {
	        MbNtfEventBottom ntf = (MbNtfEventBottom) ManagedBeanWrapper.getManagedBean("MbNtfEventBottom");
	        ntf.setTabName(tabName);
	        ntf.setParentSectionId(getSectionId());
	        ntf.setTableState(getSateFromDB(ntf.getComponentId()));
        }
    }

    public void loadCurrentTab() {
        loadTab(tabName);
    }

    private void loadTab(String tab) {
        if (tab == null || _activeCard == null) {
            return;
        }
        try {
            if (tab.equalsIgnoreCase("detailsTab")) {
            	if (_activeCard.getCardInstanceId() != null) {
		            String reason = _eventsDao.getStatusReason(userSessionId, _activeCard.getCardInstanceId(), EntityNames.CARD_INSTANCE);
		            _activeCard.setStatusReason(reason);
	            }
            } else if (tab.equalsIgnoreCase("ADDRESSESTAB")) {
                MbAddressesSearch addr = (MbAddressesSearch) ManagedBeanWrapper.getManagedBean("MbAddressesSearch");
                addr.fullCleanBean();
                addr.getFilter().setTypeIdPairs("(\'" + EntityNames.CARDHOLDER + "\', " + _activeCard.getCardholderId() + "), " +
                                                        "(\'" + EntityNames.CUSTOMER + "\', " + _activeCard.getCustomerId() + ")");
                addr.getFilter().setLang(curLang);
                addr.getFilter().setEntityType(EntityNames.CUSTOMER);
                addr.getFilter().setObjectId(_activeCard.getCustomerId());
                addr.search();
            } else if (tab.equalsIgnoreCase("INSTANCESTAB")) {
                MbCardInstancesSearch instancesSearch = (MbCardInstancesSearch) ManagedBeanWrapper.getManagedBean("MbCardInstancesSearch");
                CardInstance instanceFilter = new CardInstance();
                instanceFilter.setCardId(_activeCard.getId());
                instancesSearch.setFilter(instanceFilter);
                instancesSearch.search();
            } else if (tab.equalsIgnoreCase("ACCOUNTSTAB")) {
                MbAccountsSearch accountsBean = (MbAccountsSearch) ManagedBeanWrapper.getManagedBean("MbAccountsSearch");
                accountsBean.clearFilter();
                accountsBean.getFilter().setEntityType(EntityNames.CARD);
                accountsBean.getFilter().setObjectId(_activeCard.getId().longValue());
                accountsBean.getFilter().setInstId(_activeCard.getInstId());
                accountsBean.getFilter().setSplitHash(_activeCard.getSplitHash());
                accountsBean.setSearchByObject(true);
                accountsBean.setBackLink(thisBackLink);
                accountsBean.search();
            } else if (tab.equalsIgnoreCase("OPERATIONSTAB")) {
                MbOperationsBottom operationsBean = (MbOperationsBottom) ManagedBeanWrapper.getManagedBean("MbOperationsBottom");
                operationsBean.clearFilter();
                operationsBean.setSearchTabName("CARD");
                operationsBean.getParticipantFilter().setParticipantType("PRTYISS");
                operationsBean.getParticipantFilter().setCardId(_activeCard.getId());
                operationsBean.searchByParticipant();
            } else if (tab.equalsIgnoreCase("CARDHOLDERSTAB")) {
                MbCardholdersSearch cardholdersBean = (MbCardholdersSearch) ManagedBeanWrapper.getManagedBean("MbCardholdersSearch");
                Cardholder filterCardholder = new Cardholder();
                filterCardholder.setId(_activeCard.getCardholderId());
                cardholdersBean.setFilter(filterCardholder);
                cardholdersBean.setSearchByCard(true);
                cardholdersBean.search();
                cardholdersBean.getCardholder();
            } else if (tab.equalsIgnoreCase("CUSTOMERSTAB")) {
                MbCustomersDependent customersBean = (MbCustomersDependent) ManagedBeanWrapper.getManagedBean("MbCustomersDependent");
                customersBean.getCustomer(_activeCard.getCustomerId(), _activeCard.getCustomerType());
            } else if (tab.equalsIgnoreCase("attributesTab")) {
                MbObjectAttributes attrs = (MbObjectAttributes) ManagedBeanWrapper.getManagedBean("MbObjectAttributes");
                attrs.fullCleanBean();
                attrs.setObjectId(_activeCard.getId());
                attrs.setProductId(_activeCard.getProductId());
                attrs.setEntityType(EntityNames.CARD);
                attrs.setInstId(_activeCard.getInstId());
                attrs.setProductType(_activeCard.getProductType());
            } else if (tab.equalsIgnoreCase("limitCountersTab")) {
                MbLimitCounters limitCounters = (MbLimitCounters) ManagedBeanWrapper.getManagedBean("MbLimitCounters");
                limitCounters.setFilter(null);
                limitCounters.getFilter().setObjectId(_activeCard.getId());
                limitCounters.getFilter().setInstId(_activeCard.getInstId());
                limitCounters.getFilter().setEntityType(EntityNames.CARD);
                limitCounters.search();
            } else if (tab.equalsIgnoreCase("cycleCountersTab")) {
                MbCardCycleCounters cycleCounters = (MbCardCycleCounters) ManagedBeanWrapper.getManagedBean("MbCardCycleCounters");
                cycleCounters.setFilter(null);
                cycleCounters.getFilter().setObjectId(_activeCard.getId());
                cycleCounters.getFilter().setInstId(_activeCard.getInstId());
                cycleCounters.getFilter().setEntityType(EntityNames.CARD);
                cycleCounters.search();
            } else if (tab.equalsIgnoreCase("statusLogsTab")) {
                MbStatusLogs statusLogs = (MbStatusLogs) ManagedBeanWrapper.getManagedBean("MbStatusLogs");
                statusLogs.clearFilter();
                statusLogs.getFilter().setObjectId(_activeCard.getId());
                statusLogs.getFilter().setEntityType(EntityNames.CARD_INSTANCE);
                statusLogs.search();
            } else if (tab.equalsIgnoreCase("SCHEMESTAB")) {
                MbAupSchemeObjects schemeBean = (MbAupSchemeObjects) ManagedBeanWrapper.getManagedBean("MbAupSchemeObjects");
                schemeBean.setObjectId(_activeCard.getId().longValue());
                schemeBean.setDefaultEntityType(EntityNames.CARD);
                schemeBean.setInstId(_activeCard.getInstId());
                schemeBean.search();
            } else if (tab.equalsIgnoreCase("documentsTab")) {
                MbObjectDocuments mbObjectDocuments = (MbObjectDocuments) ManagedBeanWrapper.getManagedBean("MbObjectDocuments");
                RptDocument filter = mbObjectDocuments.getFilter();
                filter.setObjectId(_activeCard.getId().longValue());
                filter.setEntityType(EntityNames.CARD);
                mbObjectDocuments.setFilter(filter);
                mbObjectDocuments.search();
            } else if (tab.equalsIgnoreCase("FLEXIBLEFIELDSTAB")) {
                MbFlexFieldsDataSearch flexible = (MbFlexFieldsDataSearch) ManagedBeanWrapper.getManagedBean("MbFlexFieldsDataSearch");
                FlexFieldData filterFlex = new FlexFieldData();
                filterFlex.setInstId(_activeCard.getInstId());
                filterFlex.setEntityType(EntityNames.CARD);
                filterFlex.setObjectId(_activeCard.getId().longValue());
                flexible.setFilter(filterFlex);
                flexible.search();
            } else if (tab.equalsIgnoreCase("applicationsTab")) {
                MbObjectApplicationsSearch mbAppObjects = (MbObjectApplicationsSearch) ManagedBeanWrapper.getManagedBean(MbObjectApplicationsSearch.class);
                mbAppObjects.setObjectId(_activeCard.getId().longValue());
                mbAppObjects.setEntityType(EntityNames.CARD);
                mbAppObjects.search();
            } else if (tab.equalsIgnoreCase("suitesTab")) {
                MbFraudObjects fraudObjectsBean = (MbFraudObjects) ManagedBeanWrapper.getManagedBean("MbFraudObjects");
                fraudObjectsBean.setObjectId(_activeCard.getId().longValue());
                fraudObjectsBean.setEntityType(EntityNames.CARD);
                fraudObjectsBean.search();
            } else if (tab.equalsIgnoreCase("reportTab")) {
                MbReportsBottom reportsBean = (MbReportsBottom) ManagedBeanWrapper.getManagedBean("MbReportsBottom");
                reportsBean.setEntityType(EntityNames.CARD);
                reportsBean.setObjectType(_activeCard.getCardTypeId().toString());
                reportsBean.setObjectId(_activeCard.getId());
                reportsBean.search();
            } else if (tab.equalsIgnoreCase("info")) {
                MbEntityObjectInfoBottom infoBean = (MbEntityObjectInfoBottom) ManagedBeanWrapper.getManagedBean("MbEntityObjectInfoBottom");
                infoBean.setEntityType(EntityNames.CARD);
                infoBean.setObjectType(_activeCard.getCardTypeId().toString());
                infoBean.setObjectId(_activeCard.getId());
                infoBean.search();
            } else if (tabName.equals("notes")) {
                MbNotesSearch notesSearch = ManagedBeanWrapper.getManagedBean("MbNotesSearch");
                ObjectNoteFilter filterNote = new ObjectNoteFilter();
                filterNote.setEntityType(EntityNames.CARD);
                filterNote.setObjectId(_activeCard.getId());
                notesSearch.setFilter(filterNote);
                notesSearch.search();
            } else if (tabName.equalsIgnoreCase("tokensTab")) {
                MbTokensSearch bean = (MbTokensSearch) ManagedBeanWrapper.getManagedBean("MbTokensSearch");
                bean.setTabName(tabName);
                bean.setCurMode(curMode);
                bean.setCurLang(curLang);
                bean.getFilter().setCardId(getActiveCard().getId());
                bean.search();
            } else if (tabName.equalsIgnoreCase("ntfEventTab")) {
	            MbNtfEventBottom ntf = (MbNtfEventBottom) ManagedBeanWrapper.getManagedBean("MbNtfEventBottom");
	            ntf.setEntityType(EntityNames.CARD);
	            ntf.setObjectId(_activeCard.getId());
	            ntf.search();
            }

            needRerender = tab;
            loadedTabs.put(tab, Boolean.TRUE);
        } catch (Exception e) {
            logger.error("", e);
            FacesUtils.addMessageError(e);
        }
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

    public ArrayList<SelectItem> getSecurityQuestions() {
        if (_activeCard == null || _activeCard.getCardholderId() == null) {
            return new ArrayList<SelectItem>(0);
        }
        try {
            QuestionWord[] questions = _securityDao.getQuestions(userSessionId, _activeCard
                    .getCardholderId(), _activeCard.getId(), _activeCard.getCustomerId());
            ArrayList<SelectItem> items = new ArrayList<SelectItem>(questions.length);
            for (QuestionWord q : questions) {
                items.add(new SelectItem(q.getQuestion(), getDictUtils().getAllArticlesDesc().get(
                        q.getQuestion())));
            }
            if (questions.length > 0) {
                secWordEntity = questions[0].getEntityType();
                secWordObjectId = questions[0].getObjectId();
            }
            return items;
        } catch (Exception e) {
            logger.error("", e);
            if (e.getMessage().indexOf(SystemConstants.INSUFFICIENT_PRIVILEGES_ERROR) < 0) {
                FacesUtils.addMessageError(e);
            }
            return new ArrayList<SelectItem>(0);
        }
    }

    public void prepareCheckWord() {
        curMode = VIEW_MODE;
        if (secWord != null) {
            secWord.setWord(null);
        }
    }

    public void checkWord() {
        secWord.setObjectId(secWordObjectId);
        secWord.setEntityType(secWordEntity);
        try {
            secWordCorrect = _securityDao.checkSecurityWord(userSessionId, secWord);
        } catch (Exception e) {
            logger.error("", e);
            FacesUtils.addMessageError(e);
        }
    }

    public boolean isSecWordCorrect() {
        return secWordCorrect;
    }

    public void setSecWordCorrect(boolean secWordCorrect) {
        this.secWordCorrect = secWordCorrect;
    }

    public QuestionWord getSecWord() {
        if (secWord == null) {
            secWord = new QuestionWord();
        }
        return secWord;
    }

    public void setSecWord(QuestionWord secWord) {
        this.secWord = secWord;
    }

    public void checkSecWord() {
        secWord = new QuestionWord();
    }

    public boolean isSearchByHolder() {
        return searchByHolder;
    }

    public void setSearchByHolder(boolean searchByHolder) {
        this.searchByHolder = searchByHolder;
    }

    public String toApplications() {
        try {

            HashMap<String, Object> queueFilter = new HashMap<String, Object>();
            queueFilter.put("cardNumber", _activeCard.getMask());
            queueFilter.put("instId", _activeCard.getInstId());
            queueFilter.put("objectId", _activeCard.getId());
            queueFilter.put("entityType", beanEntityType);
            queueFilter.put("appType", MbApplicationsSearch.ISSUING);
            queueFilter.put("backLink", thisBackLink);

            addFilterToQueue("MbApplicationsSearch", queueFilter);

            Menu mbMenu = (Menu) ManagedBeanWrapper.getManagedBean("menu");
            mbMenu.externalSelect("applications|list_iss_apps");

            return "acquiring|applications|list_apps";
        } catch (Exception e) {
            FacesUtils.addMessageError(e);
            logger.error("", e);
        }
        return "";
    }

    @Override
    protected void applySectionFilter(Integer filterId) {
        try {
            FilterFactory factory = (FilterFactory) ManagedBeanWrapper
                    .getManagedBean("filterFactory");
            Map<String, String> filterRec = factory.getSectionFilterRecs(filterId);
            sectionFilter = factory.getUserSectionFiltersObjects().get(filterId);
            if (filterRec != null) {
                filter = new Card();
                if (filterRec.get("instId") != null) {
                    filter.setInstId(Integer.parseInt(filterRec.get("instId")));
                }
                if (filterRec.get("cardType") != null) {
                    filter.setCardTypeId(Integer.parseInt(filterRec.get("cardType")));
                }
                if (filterRec.get("cardNumber") != null) {
                    filter.setCardNumber(filterRec.get("cardNumber"));
                }
                if (filterRec.get("mask") != null) {
                    filter.setMask(filterRec.get("mask"));
                }
                if (filterRec.get("cardholderName") != null) {
                    filter.setCardholderName(filterRec.get("cardholderName"));
                }
                if (filterRec.get("customerNumber") != null) {
                    filter.setCustomerNumber(filterRec.get("customerNumber"));
                }
                if (filterRec.get("custInfo") != null) {
                    filter.setCustInfo(filterRec.get("custInfo"));
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
            if (filter.getInstId() != null) {
                filterRec.put("instId", filter.getInstId().toString());
            }
            if (filter.getCardTypeId() != null) {
                filterRec.put("cardType", filter.getCardTypeId().toString());
            }
            if (filter.getCardNumber() != null && !filter.getCardNumber().trim().equals("")) {
                filterRec.put("cardNumber", filter.getCardNumber());
            }
            if (filter.getMask() != null && !filter.getMask().trim().equals("")) {
                filterRec.put("mask", filter.getMask());
            }
            if (filter.getCardholderName() != null && !filter.getCardholderName().trim().equals("")) {
                filterRec.put("cardholderName", filter.getCardholderName());
            }
            if (filter.getCustomerNumber() != null && !filter.getCustomerNumber().trim().equals("")) {
                filterRec.put("customerNumber", filter.getCustomerNumber());
            }
            if (filter.getCustInfo() != null && !filter.getCustInfo().trim().equals("")) {
                filterRec.put("custInfo", filter.getCustInfo());
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

    private void saveBean() {
        sessBean.setActiveCard(_activeCard);
        sessBean.setFilter(filter);
        sessBean.setPageNumber(pageNumber);
        sessBean.setRowsNum(rowsNum);
        sessBean.setTabName(tabName);
        sessBean.setBackLink(backLink);
    }

    private void restoreBean() {
        _activeCard = sessBean.getActiveCard();
        filter = sessBean.getFilter();
        tabName = sessBean.getTabName();
        pageNumber = sessBean.getPageNumber();
        rowsNum = sessBean.getRowsNum();
        backLink = sessBean.getBackLink();
        searching = true;

        FacesUtils.setSessionMapValue(thisBackLink, Boolean.FALSE);
        setInfo();
    }

    public AcmAction getSelectedCtxItem() {
        return selectedCtxItem;
    }

    public void setSelectedCtxItem(AcmAction selectedCtxItem) {
        this.selectedCtxItem = selectedCtxItem;
    }

    public String getComponentId() {
        return COMPONENT_ID;
    }

    public Logger getLogger() {
        return logger;
    }

    public void showCustomers() {
        MbCustomerSearchModal custBean = (MbCustomerSearchModal) ManagedBeanWrapper
                .getManagedBean("MbCustomerSearchModal");
        custBean.clearFilter();
        custBean.setDefaultInstId(getFilter().getInstId());
        if ((getFilter().getInstId() != null) && (!getFilter().getInstId().equals(DEFAULT_INST))) {
            custBean.setBlockInstId(true);
        } else {
            custBean.setBlockInstId(false);
        }
    }

    public void selectCustomer() {
        MbCustomerSearchModal custBean = (MbCustomerSearchModal) ManagedBeanWrapper
                .getManagedBean("MbCustomerSearchModal");
        Customer selected = custBean.getActiveCustomer();
        if (selected != null) {
            getFilter().setCustomerNumber(selected.getCustomerNumber());
            getFilter().setCustomerId(selected.getId());
            getFilter().setCustInfo(selected.getName());
            getFilter().setInstId(custBean.getFilter().getInstId());
        }
    }

    /**
     * Initializes bean's filter if bean has been accessed by context menu.
     */
    private void initFilterFromContext() {
        filter = new Card();

        if (FacesUtils.getSessionMapValue("instId") != null) {
            filter.setInstId((Integer) FacesUtils.getSessionMapValue("instId"));
            FacesUtils.setSessionMapValue("instId", null);
        }
        if (FacesUtils.getSessionMapValue("cardNumber") != null) {
//			filter.setCardNumber((String) FacesUtils.getSessionMapValue("cardNumber"));
            FacesUtils.setSessionMapValue("cardNumber", null);
        }
        if (FacesUtils.getSessionMapValue("mask") != null) {
            filter.setCardNumber((String) FacesUtils.getSessionMapValue("mask"));
            FacesUtils.setSessionMapValue("mask", null);
        }

        if (FacesUtils.getSessionMapValue("customerNumber") != null) {
            filter.setCustomerNumber((String) FacesUtils.getSessionMapValue("customerNumber"));
            filter.setCustInfo((String) FacesUtils.getSessionMapValue("customerNumber"));
            displayCustInfo();
            FacesUtils.setSessionMapValue("customerNumber", null);
        }
    }

    public String back() {
        FacesUtils.setSessionMapValue(backLink, Boolean.TRUE);
        mbMenu.externalSelect(backLink);
        return backLink;
    }

    public boolean isShowBackBtn() {
        return backLink == null ? false : (backLink.trim().length() > 0 ? true : false);
    }

    public void displayCustInfo() {

        if (getFilter().getCustInfo() == null || "".equals(getFilter().getCustInfo())) {
            getFilter().setCustomerNumber(null);
            getFilter().setCustomerId(null);
            return;
        }

        // process wildcard
        Pattern p = Pattern.compile("\\*|%|\\?");
        Matcher m = p.matcher(getFilter().getCustInfo());
        if (m.find() || getFilter().getInstId() == null) {
            getFilter().setCustomerNumber(getFilter().getCustInfo());
            return;
        }

        // search and redisplay
        Filter[] filters = new Filter[3];
        filters[0] = new Filter("LANG", curLang);
        filters[1] = new Filter("INST_ID", getFilter().getInstId());
        filters[2] = new Filter("CUSTOMER_NUMBER", getFilter().getCustInfo());

        SelectionParams params = new SelectionParams();
        params.setFilters(filters);
        try {
            Customer[] cust = _productsDao.getCombinedCustomersProc(userSessionId, params,
                                                                    "CUSTOMER");
            if (cust != null && cust.length > 0) {
                getFilter().setCustInfo(cust[0].getName());
                getFilter().setCustomerNumber(cust[0].getCustomerNumber());
                getFilter().setCustomerId(cust[0].getId());
            } else {
                getFilter().setCustomerNumber(getFilter().getCustInfo());
                getFilter().setCustomerId(null);
            }
        } catch (Exception e) {
            FacesUtils.addMessageError(e);
            logger.error("", e);
        }
    }

    public boolean isSaveAfterSearch() {
        return saveAfterSearch;
    }

    public void setSaveAfterSearch(boolean saveAfterSearch) {
        this.saveAfterSearch = saveAfterSearch;
    }

    public String getBackLink() {
        return backLink;
    }

    public void setBackLink(String backLink) {
        this.backLink = backLink;
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
        if (ctxType == null) {
            return null;
        }
        Map<String, Object> map = new HashMap<String, Object>();
        if (_activeCard != null) {
            if (EntityNames.CARDHOLDER.equals(ctxItemEntityType)) {
                map.put("id", _activeCard.getCardholderId());
                map.put("instId", _activeCard.getInstId());
                map.put("cardholderNumber", _activeCard.getCardholderNumber());
            }
            if (EntityNames.INSTITUTION.equals(ctxItemEntityType)) {
                map.put("id", _activeCard.getInstId());
                map.put("instId", _activeCard.getInstId());
            }
            if (EntityNames.PRODUCT.equals(ctxItemEntityType)) {
                map.put("id", _activeCard.getProductId());
                map.put("instId", _activeCard.getInstId());
                map.put("objectType", _activeCard.getProductType());
                map.put("productType", _activeCard.getProductType());
                map.put("productName", _activeCard.getProductName());
                map.put("productNumber", _activeCard.getProductNumber());
            }
            if (EntityNames.CARD.equals(ctxItemEntityType)) {
                map.put("id", _activeCard.getId());
            }
        }
        ctxType.setParams(map);
        return ctxType;
    }

    public boolean isForward() {
        return !ctxItemEntityType.equals(EntityNames.CARD);
    }

    public void viewCardNumber() {
        try {
            // just for audit
            _issuingDao.viewCardNumber(userSessionId, _activeCard.getId());
        } catch (Exception e) {
            logger.error("", e);
            FacesUtils.addMessageError(e);
        }
    }

    public String getSectionId() {
        return SectionIdConstants.ISSUING_CARD;
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

    public List<SelectItem> getCardStates() {
        List<SelectItem> result = getDictUtils().getLov(LovConstants.CARD_STATES);
        return result;
    }

    public List<SelectItem> getCardStatuses() {
        return getDictUtils().getLov(LovConstants.CARD_TYPES_ONLINE_STATUSES);
    }

    public String getContractType() {
        return contractType;
    }

    public void setContractType(String contractType) {
        this.contractType = contractType;
    }

    public List<SelectItem> getContractTypes() {
        if(contractTypes == null) {
            Map<String, Object> paramMap = new HashMap<String, Object>();
            paramMap.put("PRODUCT_TYPE", ProductConstants.ISSUING_PRODUCT);
            contractTypes = getDictUtils().getLov(LovConstants.PRODUCT_CONTRACT_TYPES, paramMap);
        }
        return contractTypes;
    }

    public void setContractTypes(List<SelectItem> contractTypes) {
        this.contractTypes = contractTypes;
    }

    public String getModule() {
        return module;
    }
    public void setModule(String module) {
        this.module = module;
    }

    public void scoring() {
        MbScoringCalculation bean = ManagedBeanWrapper.getManagedBean(MbScoringCalculation.class);
        if (bean != null) {
            bean.clearFilter();
            bean.setUserLang(userLang);
            bean.loadEvaluations();
        }
    }
}
