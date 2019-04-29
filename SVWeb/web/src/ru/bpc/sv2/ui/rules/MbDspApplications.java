package ru.bpc.sv2.ui.rules;

import org.apache.commons.lang3.StringUtils;
import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;
import ru.bpc.sv2.administrative.users.User;
import ru.bpc.sv2.application.*;
import ru.bpc.sv2.common.application.ApplicationFlows;
import ru.bpc.sv2.common.application.ApplicationStatuses;
import ru.bpc.sv2.common.events.EventConstants;
import ru.bpc.sv2.constants.*;
import ru.bpc.sv2.constants.application.AppElements;
import ru.bpc.sv2.constants.application.ApplicationConstants;
import ru.bpc.sv2.dsp.CaseNetworkContext;
import ru.bpc.sv2.dsp.DisputeActionPermissions;
import ru.bpc.sv2.dsp.DisputeListCondition;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.Filter.Operator;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.issuing.Cardholder;
import ru.bpc.sv2.logic.*;
import ru.bpc.sv2.mastercom.api.MasterCom;
import ru.bpc.sv2.mastercom.api.MasterComException;
import ru.bpc.sv2.mastercom.api.types.claim.request.MasterComClaimCreate;
import ru.bpc.sv2.mastercom.api.types.transaction.request.MasterComTransactionSearch;
import ru.bpc.sv2.mastercom.api.types.transaction.response.MasterComTransactions;
import ru.bpc.sv2.operations.Operation;
import ru.bpc.sv2.operations.OperationPrivConstants;
import ru.bpc.sv2.operations.OriginalCaseFilter;
import ru.bpc.sv2.products.Customer;
import ru.bpc.sv2.reports.RptDocument;
import ru.bpc.sv2.rules.DspApplicationFile;
import ru.bpc.sv2.ui.acquiring.MbMerchant;
import ru.bpc.sv2.ui.acquiring.MbTerminal;
import ru.bpc.sv2.ui.application.MbApplicationHistory;
import ru.bpc.sv2.ui.application.wizard.MbAppWizDspFlow;
import ru.bpc.sv2.ui.audit.MbUserSearchModal;
import ru.bpc.sv2.ui.aut.MbAuthorizations;
import ru.bpc.sv2.ui.common.application.MbWizard;
import ru.bpc.sv2.ui.dsp.MbAssociatedOperations;
import ru.bpc.sv2.ui.issuing.MbCardholdersSearch;
import ru.bpc.sv2.ui.issuing.MbCardsSearch;
import ru.bpc.sv2.ui.operations.MbOperations;
import ru.bpc.sv2.ui.operations.MbParticipants;
import ru.bpc.sv2.ui.operations.MbTechnicalMessages;
import ru.bpc.sv2.ui.products.MbCustomerSearchModal;
import ru.bpc.sv2.ui.rules.disputes.*;
import ru.bpc.sv2.ui.session.UserSession;
import ru.bpc.sv2.ui.utils.*;
import ru.bpc.sv2.ui.utils.cache.DictCache;
import ru.bpc.sv2.utils.SystemException;
import ru.bpc.sv2.utils.UserException;
import util.auxil.ManagedBeanWrapper;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.model.SelectItem;
import java.math.BigDecimal;
import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.*;

@ViewScoped
@ManagedBean (name = "MbDspApplications")
public class MbDspApplications extends AbstractBean {
    private static final long serialVersionUID = 1L;
    private static final Logger logger = Logger.getLogger("RULES");

    private static final String BUNDLE = "ru.bpc.sv2.ui.bundles.Acq";
    private static final String COMPONENT_ID = "1090:dspApplicationsTable";
    private static final String DUE_DATE_NOT_DEFINED = "Due date is not defined";
    private static final String TAB_CLEARING_VW = "aut_ui_auth_msg_vw";

    public static final String TAB_ATTACHMENT = "attachmentsTab";
    private static final String TAB_OPERATION = "operationTab";
    private static final String TAB_HISTORY = "historyTab";
    private static final String TAB_AUTHORIZATION = "authorizationTab";
    private static final String TAB_ITEMS = "itemsTab";
    private static final String TAB_PARTICIPANT = "participantTab";
    private static final String TAB_DETAILS = "detailsTab";
    private static final String TAB_CLEARING = "clearingTab";
    private static final String TAB_OBJECT = "objectTab";

    private static final String CASE_MANAGEMENT_ACQ = "CSM_ACQ";
    private static final String CASE_MANAGEMENT_ISS = "CSM_ISS";
    private static final String CASE_MANAGEMENT_CLAIM = "CSM_CLAIM";
    private static final String DSP_APPLICATION = "CSM_APP";

    private static final Integer DEFAULT_FLOW_ID = 0;

    private static final String DSCS0001 = "DSCS0001";
    private static final String DSCS0003 = "DSCS0003";
    private static final String DSCS0004 = "DSCS0004";

    private static final Integer ACQUIRING_DOMESTIC_DISPUTE = 1504;
    private static final Integer ISSUING_DOMESTIC_DISPUTE = 1503;
    private static final Integer INTERNAL_DISPUTE = 1502;

    private static final Long HOURS_IN_MILLIS = 3600000L;
    private static final Long FIVE_DAYS_IN_HOURS = 120L;

    private static final String PRE_COMPLIANCE = "0001";
    private static final String COMPLIANCE = "0002";
    private static final String PRE_ARBITRATION = "0003";
    private static final String ARBITRATION = "0004";

    private static final String RFRA0004 = "RFRA0004";
    private static final String RFRA0005 = "RFRA0005";
    private static final String RFRA0006 = "RFRA0006";

    private static final String CARD_DETAIL_PAGE = "/pages/issuing/cards/card_details.jspx";
    private static final String MERCHANT_DETAIL_PAGE = "/pages/acquiring/merchantDetails.jspx";

    private ApplicationDao applicationDao = new ApplicationDao();
    private DisputesDao disputesDao = new DisputesDao();
    private OperationDao operationDao = new OperationDao();
    private ReportsDao reportsDao = new ReportsDao();
    private UsersDao usersDao = new UsersDao();

    private String module;
    private String submodule;

    private DspApplication filter;
    private List<DspApplication> activeDspApplication;
    private DspApplication newDspApplication;

    private ArrayList<SelectItem> modifiers;
    private String scaleType;
    private boolean updateModifiers;
    private List<SelectItem> statuses;
    private List<SelectItem> institutions;
    private List<SelectItem> agents;
    private List<SelectItem> disputesCaseTypes;
    private List<SelectItem> dueDateTypesOfDisputeCases;
    private String newStatus;

    private MbOperations operations;
    private MbParticipants participants;
    private MbApplicationHistory history;
    private MbAssociatedOperations associatedOperations;
    private MbTechnicalMessages technicalMessages;
    private MbObjectDspDocuments attachments;
    private MbAuthorizations authorizations;
    private MbCardsSearch cardDetails;
    private MbMerchant merchantDetails;
    private OriginalCaseFilter originalCaseFilter;
    private ManualCaseCreation manualCaseCreation;
    private DisputeActionPermissions actions;

    private final DaoDataModel<DspApplication> dspApplicationSource;
    private final TableRowSelection<DspApplication> itemSelection;

    private DaoDataModel<Operation> operationOriginalCase;
    private List<Operation> unpairedDisputeOperations;

    private Map<Integer, Integer> genRulesMap;
    private Map<Integer, String> msgTypesMap;
    private List<SelectItem> operationTypes;
    private List<SelectItem> teams;
    private List<SelectItem> caseResolutions;

    private Integer initRule;
    private String messageType;
    private String disputeReason;
    private String dueDate;
    private String typeOfCase;
    private String caseCreationPanel;
    private String operationId;
    private String unpairedId;
    private boolean matchDisplay;
    private Integer chargebackLovId;
    private String disputeAction;
    private String reasonCode;
    private BigDecimal[] idTab;

    private Date newDueDate;

    protected String tabName;

    private boolean claimBased = false;

    private String rejectReasonCode;
    private String rejectComment;

    public MbDspApplications() {
        thisBackLink = "dispute|Applications";
        tabName = "detailsTab";

        selectCurrentUser();

        dspApplicationSource = new DaoDataListModel<DspApplication>(logger) {
            private static final long serialVersionUID = 1L;

            @Override
            protected List<DspApplication> loadDaoListData(SelectionParams params) {
                if (searching) {
                    setFilters();
                    params.setTable("DISPUTE");
                    params.setFilters(filters);
                    return applicationDao.getDspApplications(userSessionId, params);
                }
                return new ArrayList<DspApplication>();
            }

            @Override
            protected int loadDaoDataSize(SelectionParams params) {
                if (searching) {
                    setFilters();
                    params.setTable("DISPUTE");
                    params.setFilters(filters);
                    return applicationDao.getDspApplicationsCount(userSessionId, params);
                }
                return 0;
            }
        };

        itemSelection = new TableRowSelection<DspApplication>(null, dspApplicationSource);
    }

    public String getModule() {
        if (module == null || module.isEmpty()) {
            module = ApplicationConstants.TYPE_DISPUTES;
        }
        return module;
    }
    public void setModule(String module) {
        if (module.equals(CASE_MANAGEMENT_ACQ)) {
            this.module = ApplicationConstants.TYPE_ACQUIRING;
        } else if (module.equals(CASE_MANAGEMENT_ISS)) {
            this.module = ApplicationConstants.TYPE_ISSUING;
        } else if (module.equals(CASE_MANAGEMENT_CLAIM)) {
            this.module = ApplicationConstants.TYPE_DISPUTES;
            this.submodule = ApplicationConstants.TYPE_ISSUING;
        } else {
            this.module = ApplicationConstants.TYPE_DISPUTES;
        }
    }

    public DaoDataModel<DspApplication> getDspApplications() {
        return dspApplicationSource;
    }

    public DspApplication getActiveDspApplication() {
        if (activeDspApplication != null && activeDspApplication.size() == 1) {
            return activeDspApplication.get(0);
        }
        return null;
    }

    public List<DspApplication> getActiveDspApplications() {
        if (activeDspApplication != null) {
            return activeDspApplication;
        }
        return null;
    }

    public void setActiveModScale(DspApplication activeDspApplication) {
        activeDspApplication = activeDspApplication;
    }

    public SimpleSelection getItemSelection() {
        try {
            if ((activeDspApplication == null || activeDspApplication.size() == 0) && dspApplicationSource.getRowCount() > 0) {
                setFirstRowActive();
            } else if (activeDspApplication != null && dspApplicationSource.getRowCount() > 0) {
                activeDspApplication = itemSelection.getMultiSelection();
            }
        } catch (Exception e) {
            FacesUtils.addMessageError(e);
            logger.error("", e);
        }
        if (activeDspApplication == null) {
            setActions(disputesDao.getActionPermissions(userSessionId, null));
        }
        return itemSelection.getWrappedSelection();
    }

    public void setItemSelection(SimpleSelection selection) {
        itemSelection.setWrappedSelection(selection);
        activeDspApplication = itemSelection.getMultiSelection();
        loadTab(getTabName());
        if (activeDspApplication == null) {
            setActions(disputesDao.getActionPermissions(userSessionId, null));
        } else if (activeDspApplication.size() == 1) {
            setActions(disputesDao.getActionPermissions(userSessionId, activeDspApplication.get(0).getId()));
        } else {
            for (DspApplication app : activeDspApplication) {
                if (getActions() == null) {
                    setActions(disputesDao.getActionPermissions(userSessionId, app.getId()));
                } else {
                    getActions().intersect(disputesDao.getActionPermissions(userSessionId, app.getId()));
                }
            }
        }
    }

    public void setFirstRowActive() throws CloneNotSupportedException {
        dspApplicationSource.setRowIndex(0);
        SimpleSelection selection = new SimpleSelection();
        activeDspApplication = new ArrayList<DspApplication>(1);
        activeDspApplication.add(0, (DspApplication) dspApplicationSource.getRowData());
        selection.addKey(activeDspApplication.get(0).getModelId());
        itemSelection.setWrappedSelection(selection);
        loadTab(getTabName());
        setActions(disputesDao.getActionPermissions(userSessionId, activeDspApplication.get(0).getId()));
    }

    @Override
    public void clearFilter() {
        filter = null;
        curLang = userLang;
        clearBean();
        searching = false;
    }

    public void search() {
        curMode = VIEW_MODE;
        clearBean();
        searching = true;
    }

    private void setFilters() {
        filter = getFilter();
        filters = new ArrayList<Filter>();

        filters.add(Filter.create("LANG", userLang));
        filters.add(Filter.create("TYPE", ApplicationConstants.TYPE_DISPUTES));
        filters.add(Filter.create("APPL_SUBTYPE", getModule()));

        if (filter.getId() != null) {
            filters.add(Filter.create("APPL_ID", filter.getId()));
        }
        if (filter.getApplicationNumber() != null && !filter.getApplicationNumber().trim().isEmpty()) {
            filters.add(Filter.create("APPL_NUMBER", filter.getApplicationNumber().trim()));
        }
        if (filter.getFlowId() != null) {
            filters.add(Filter.create("FLOW_ID", filter.getFlowId()));
        }
        if (filter.getDspAppDateFrom() != null) {
            filters.add(Filter.create("DATE_FROM", filter.getDspAppDateFrom()));
        }
        if (filter.getDspAppDateTo() != null) {
            filters.add(Filter.create("DATE_TO", filter.getDspAppDateTo()));
        }
        if (filter.getAgentId() != null) {
            filters.add(Filter.create("AGENT_ID", filter.getAgentId()));
        }
        if (filter.getCardMask() != null && !filter.getCardMask().trim().isEmpty()) {
            filters.add(Filter.create("CARD_NUMBER", Operator.like, Filter.mask(filter.getCardMask())));
        }
        if (filter.getStatus() != null && !filter.getStatus().trim().isEmpty()) {
            filters.add(Filter.create("APPL_STATUS", filter.getStatus().trim().toUpperCase()));
        }
        if (filter.getRejectCode() != null && !filter.getRejectCode().trim().isEmpty()) {
            filters.add(Filter.create("REJECT_CODE", filter.getRejectCode().trim()));
        }
        if (filter.getMerchantNumber() != null && !filter.getMerchantNumber().trim().isEmpty()) {
            filters.add(Filter.create("MERCHANT_NUMBER", filter.getMerchantNumber().trim()));
        }
        if (filter.getMerchantName() != null && !filter.getMerchantName().trim().isEmpty()) {
            filters.add(Filter.create("MERCHANT_NAME", filter.getMerchantName().trim()));
        }
        if (filter.getReferenceNumber() != null && !filter.getReferenceNumber().trim().isEmpty()) {
            filters.add(Filter.create("NETWORK_REFNUM", filter.getReferenceNumber().trim()));
        }
        if (filter.getAuthCode() != null && !filter.getAuthCode().trim().isEmpty()) {
            filters.add(Filter.create("AUTH_CODE", filter.getAuthCode().trim().toUpperCase()));
        }
        if (filter.getTerminalNumber() != null && !filter.getTerminalNumber().trim().isEmpty()) {
            filters.add(Filter.create("TERMINAL_NUMBER", filter.getTerminalNumber().trim()));
        }
        if (filter.getInstId() != null) {
            filters.add(Filter.create("INST_ID", filter.getInstId()));
        }
        if (filter.getClaimId() != null) {
            filters.add(Filter.create("CLAIM_ID", filter.getClaimId()));
        }
        if (filter.getAccountNumber() != null && !filter.getAccountNumber().trim().isEmpty()) {
            filters.add(Filter.create("ACCOUNT_NUMBER", filter.getAccountNumber().trim()));
        }
        if (filter.getCustomerNumber() != null && !filter.getCustomerNumber().trim().isEmpty()) {
            filters.add(Filter.create("CUSTOMER_NUMBER", filter.getCustomerNumber().trim()));
        }
        if (filter.getCaseState() != null) {
            filters.add(Filter.create("IS_VISIBLE", filter.getCaseState()));
        }
        if (filter.getCaseStatus() != null) {
            filters.add(Filter.create("CASE_SOURCE", filter.getCaseStatus()));
        }
        if (filter.getCaseOwner() != null) {
            filters.add(Filter.create("CASE_OWNER", filter.getCaseOwner()));
        }
        if (filter.getDisputeReason() != null) {
            filters.add(Filter.create("DISPUTE_REASON", filter.getDisputeReason()));
        }
    }

    public DspApplication getFilter() {
        if (filter == null) {
            filter = new DspApplication();
            filter.setCaseState("1");
        }
        return filter;
    }

    public void setFilter(DspApplication filter) {
        this.filter = filter;
    }

    public void createDsp() {
        newDspApplication = new DspApplication();
        curMode = NEW_MODE;
        MbWizard appWiz = ManagedBeanWrapper.getManagedBean(MbWizard.class);
        appWiz.setAppType(ApplicationConstants.TYPE_DISPUTES);
        MbAppWizDspFlow first = ManagedBeanWrapper.getManagedBean(MbAppWizDspFlow.class);
        if (getFilter().getFlowId() == null) {
            if (getModule().equals(ApplicationConstants.TYPE_ISSUING)) {
                first.setFlowId(MbAppWizDspFlow.CM_ISS_FLOW_ID);
            } else if (getModule().equals(ApplicationConstants.TYPE_ACQUIRING)) {
                first.setFlowId(MbAppWizDspFlow.CM_ACQ_FLOW_ID);
            } else {
                first.setFlowId(MbAppWizDspFlow.DISPUTE_FLOW_ID);
            }
        } else {
            first.setFlowId(getFilter().getFlowId());
        }
        first.setCurMode(NEW_MODE);
        first.setCurLang(curLang);
        first.setInstId(getFilter().getInstId());
        first.setAgentId(getFilter().getAgentId());
        first.setUserId(getFilter().getUserId());
        first.setUserName(getFilter().getUserName());
        first.setModule(getModule());
        first.create();
    }

    public void createNewCase() {
        initCaseFilter();
        clearEditApplModalPanelCache();
        clearUnpairedModalPanelCache();

        if (ApplicationConstants.TYPE_ISSUING.equals(getModule())) {
            disputesCaseTypes = getDictUtils().getLov(LovConstants.ISS_DISPUTES_CASE_TYPE);
        }
        else if (ApplicationConstants.TYPE_ACQUIRING.equals(getModule())) {
            disputesCaseTypes = getDictUtils().getLov(LovConstants.ACQ_DISPUTES_CASE_TYPE);
        }
        else if (ApplicationConstants.TYPE_DISPUTES.equals(getModule())) {
            disputesCaseTypes = getDictUtils().getLov(LovConstants.ISS_DISPUTES_CASE_TYPE);
        }
    }

    public void duplicateCase() {
        disputesCaseTypes = new ArrayList<SelectItem>();
        disputesCaseTypes.add(new SelectItem(DSCS0001, "Manual case", "Manual case"));
        try {
            manualCaseCreation = disputesDao.getManualCaseInfo(userSessionId, activeDspApplication.get(0).getId());
            manualCaseCreation.setClaimId(null);
            manualCaseCreation.setDuplicatedFromCaseId(activeDspApplication.get(0).getId());
            getDefaultManualApplication();
        }
        catch (Exception e) {
            FacesUtils.addMessageError(e);
            logger.error("", e);
        }
    }

    public List<SelectItem> getApplicationResolutions() {
        if (module.equals(ApplicationConstants.TYPE_ACQUIRING))
            return getDictUtils().getLov(LovConstants.ACQUIRING_DISPUTE_FLOW, null, null, DictCache.NAME);
        else if (module.equals(ApplicationConstants.TYPE_ISSUING))
            return getDictUtils().getLov(LovConstants.ISSUING_DISPUTE_FLOW, null, null, DictCache.NAME);
        return new ArrayList<SelectItem>();
    }

    public void initCaseFilter() {
        originalCaseFilter = new OriginalCaseFilter();
    }

    public void clearEditApplModalPanelCache() {
        typeOfCase = null;
    }

    public void clearUnpairedModalPanelCache() {
        operationId = null;
        unpairedId = null;
    }

    public void nextCaseModalPanel() {
        if (DSCS0004.equals(typeOfCase)) {
            caseCreationPanel = "originalCaseCreationMP";
            clearOriginalCaseCreationCache();
        } else if (DSCS0003.equals(typeOfCase)) {
            caseCreationPanel = "unpairedCaseCreationMP";
            initDisputeUnpairedList();
        } else if (DSCS0001.equals(typeOfCase)) {
            caseCreationPanel = "manualCaseCreationMP";
            manualCaseCreation = new ManualCaseCreation();
            getDefaultManualApplication();
        }
    }

    public void editDsp() {
        try {
            newDspApplication = (DspApplication)activeDspApplication.get(0).clone();
        } catch (CloneNotSupportedException e) {
            FacesUtils.addMessageError(e);
            logger.error("", e);
        }
        curMode = EDIT_MODE;
        MbWizard appWiz = ManagedBeanWrapper.getManagedBean(MbWizard.class);
        appWiz.setAppType(ApplicationConstants.TYPE_DISPUTES);
        MbAppWizDspFlow first = ManagedBeanWrapper.getManagedBean(MbAppWizDspFlow.class);
        first.setCurMode(EDIT_MODE);
        first.setCurLang(curLang);
        first.setModule(getModule());
        first.setMessageType(activeDspApplication.get(0).getMessageType());
        first.setWriteOffAmount(activeDspApplication.get(0).getWriteOffAmount());
        first.setWriteOffCurrency(activeDspApplication.get(0).getWriteOffCurrency());
        first.setFlowId(activeDspApplication.get(0).getFlowId());
        
        if (ApplicationConstants.TYPE_DISPUTES.equals(getModule())) {
            try {
                List<Filter> docFilters = new ArrayList<Filter>();
                docFilters.add(Filter.create("lang", curLang));
                docFilters.add(Filter.create("objectId", activeDspApplication.get(0).getId()));
                docFilters.add(Filter.create("entityType", EntityNames.APPLICATION));
                SelectionParams docParams = new SelectionParams(docFilters);
                docParams.setModule(ModuleNames.CASE_MANAGEMENT);
                RptDocument[] docs = reportsDao.getDocumentContents(userSessionId, docParams);
                if (docs != null && docs.length > 0) {
                    newDspApplication.setFiles(new ArrayList<DspApplicationFile>(docs.length));
                    for (RptDocument doc : docs) {
                        newDspApplication.getFiles().add(new DspApplicationFile(doc));
                    }
                }
            } catch (Exception e) {
                logger.error("", e);
            }
            first.edit(newDspApplication);
        } else {
            Application application = activeDspApplication.get(0).toApplication();
            application.setAppSubType(getModule());
            first.edit(application);
        }
    }

    public void edit() {
        try {
            newDspApplication = (DspApplication) activeDspApplication.get(0).clone();
        } catch (CloneNotSupportedException e) {
            FacesUtils.addMessageError(e);
            logger.error("", e);
        }
        curMode = EDIT_MODE;
    }

    public void viewDsp() {
        try {
            newDspApplication = (DspApplication)activeDspApplication.get(0).clone();
        } catch (CloneNotSupportedException e) {
            FacesUtils.addMessageError(e);
            logger.error("", e);
        }

        curMode = VIEW_MODE;
        MbWizard appWiz = ManagedBeanWrapper.getManagedBean(MbWizard.class);
        appWiz.setAppType(ApplicationConstants.TYPE_DISPUTES);
        MbAppWizDspFlow first = ManagedBeanWrapper.getManagedBean(MbAppWizDspFlow.class);
        first.setCurMode(VIEW_MODE);
        first.setCurLang(curLang);
        first.setModule(getModule());
        first.setMessageType(activeDspApplication.get(0).getMessageType());
        first.setWriteOffAmount(activeDspApplication.get(0).getWriteOffAmount());
        first.setWriteOffCurrency(activeDspApplication.get(0).getWriteOffCurrency());
        first.setFlowId(activeDspApplication.get(0).getFlowId());

        if (ApplicationConstants.TYPE_DISPUTES.equals(getModule())) {
            try {
                List<Filter> docFilters = new ArrayList<Filter>();
                docFilters.add(Filter.create("lang", curLang));
                docFilters.add(Filter.create("objectId", activeDspApplication.get(0).getId()));
                docFilters.add(Filter.create("entityType", EntityNames.APPLICATION));
                SelectionParams docParams = new SelectionParams(docFilters);
                docParams.setModule(ModuleNames.CASE_MANAGEMENT);
                RptDocument[] docs = reportsDao.getDocumentContents(userSessionId, docParams);
                if (docs != null && docs.length > 0) {
                    newDspApplication.setFiles(new ArrayList<DspApplicationFile>(docs.length));
                    for (RptDocument doc : docs) {
                        newDspApplication.getFiles().add(new DspApplicationFile(doc));
                    }
                }
            } catch (Exception e) {
                logger.error("", e);
            }
            first.edit(newDspApplication);
        } else {
            Application application = activeDspApplication.get(0).toApplication();
            application.setAppSubType(getModule());
            first.edit(application);
        }
    }

    private boolean allowUpdateApp(Long replace, Long existed) {
        if (existed != null) {
            if (replace != null) {
                if (existed.compareTo(replace) == 0) {
                    return true;
                }
            } else {
                return true;
            }
        }
        return false;
    }

    public void update(Long id, int mode) {
        boolean finishedWithoutError = true;
        boolean applicationExist = false;
        try {
            if (activeDspApplication != null && activeDspApplication.size() > 0) {
                itemSelection.clearSelection();
                for (Iterator<DspApplication> iter = activeDspApplication.iterator(); iter.hasNext();) {
                    DspApplication dspApp = iter.next();
                    if (allowUpdateApp(id, dspApp.getId())) {
                        applicationExist = true;
                        List<DspApplication> apps = applicationDao.getDspApplications(userSessionId, SelectionParams.build("APPL_ID", dspApp.getId(), "IS_VISIBLE", getFilter().getCaseState()));
                        if (apps != null && apps.size() > 0) {
                            if (mode == EDIT_MODE) {
                                dspApplicationSource.replaceObject(dspApp, (DspApplication) apps.get(0).clone());
                            }
                            itemSelection.addNewObjectToList(apps.get(0));
                        }
                        else {
                            dspApplicationSource.removeObjectFromList(dspApp);
                            iter.remove();
                        }
                    }
                    if (activeDspApplication.size() > 0 && activeDspApplication.get(0).getId() != dspApp.getId()) {
                        getActions().intersect(disputesDao.getActionPermissions(userSessionId, dspApp.getId()));
                    } else if (activeDspApplication.size() > 0){
                        setActions(disputesDao.getActionPermissions(userSessionId, activeDspApplication.get(0).getId()));
                    } else {
                        setActions(disputesDao.getActionPermissions(userSessionId, null));
                    }
                }
                if (!applicationExist) {
                    List<DspApplication> apps = applicationDao.getDspApplications(userSessionId, SelectionParams.build("APPL_ID", id, "IS_VISIBLE", getFilter().getCaseState()));
                    if (apps != null && apps.size() > 0 ) {
                        dspApplicationSource.addNewObjectToList(apps.get(0), null);
                        itemSelection.addNewObjectToList(apps.get(0));
                        setItemSelection(itemSelection.getWrappedSelection());
                    }
                }
            } else if (activeDspApplication != null && activeDspApplication.size() <= 0 && id == null) {
                setActions(disputesDao.getActionPermissions(userSessionId, null));
            } else {
                List<DspApplication> apps = applicationDao.getDspApplications(userSessionId, SelectionParams.build("APPL_ID", id, "IS_VISIBLE", getFilter().getCaseState()));
                if (apps != null && apps.size() > 0 ) {
                    dspApplicationSource.addNewObjectToList(apps.get(0), null);
                    itemSelection.addNewObjectToList(apps.get(0));
                    setActions(disputesDao.getActionPermissions(userSessionId, id));
                }
            }
            loadTab(getTabName());
        } catch (Exception e) {
            FacesUtils.addMessageError(e);
            logger.error("", e);
            finishedWithoutError = false;
        }
        curMode = VIEW_MODE;
        if (finishedWithoutError) {
            FacesUtils.addMessageInfo("DspApplication(s) has been saved");
        }
    }

    public void delete() {
        try {
            curMode = VIEW_MODE;

            if (activeDspApplication.size() == 1) {
                logger.trace("Delete application with id [" + activeDspApplication.get(0).getId() + "] because of pressing delete button!");
            } else {
                StringBuilder trace = new StringBuilder("Delete application with ids [");
                for (DspApplication app : activeDspApplication) {
                    trace.append(app.getId());
                    trace.append(", ");
                }
                trace.append("] because of pressing delete button!");
                logger.trace(trace.toString());
            }

            for (Iterator<DspApplication> iterator = activeDspApplication.iterator(); iterator.hasNext();) {
                DspApplication app = iterator.next();
                if (ApplicationConstants.TYPE_DISPUTES.equals(getModule())) {
                    disputesDao.removeClaim(userSessionId, app);
                } else {
                    applicationDao.deleteDspApplication(userSessionId, app);
                }
                dspApplicationSource.removeObjectFromList(app);
                iterator.remove();
            }

            if (activeDspApplication == null) {
                clearBean();
            } else {
                loadTab(getTabName());
            }
        } catch (Exception e) {
            FacesUtils.addMessageError(e);
            logger.error("", e);
        }
    }

    public void close() {
        curMode = VIEW_MODE;
    }

    public void clearBean() {
        itemSelection.clearSelection();
        activeDspApplication = null;
        dspApplicationSource.flushCache();
    }

    public String getSectionId() {
        return SectionIdConstants.OPERATION_MODIFIER_SCALE;
    }

    public String getComponentId() {
        return COMPONENT_ID;
    }

    private List<SelectItem> getStatuses() {
        if (statuses == null) {
            Map<String, Object> paramMap = new HashMap<String, Object>();
            if (activeDspApplication != null && activeDspApplication.size() == 1 && activeDspApplication.get(0).getFlowId() != null) {
                paramMap.put("flow_id", activeDspApplication.get(0).getFlowId());
            } else {
                paramMap.put("flow_id", DEFAULT_FLOW_ID);
            }
            statuses = getDictUtils().getLov(LovConstants.DISPUTE_APPLICATION_STATUSES, paramMap, null, DictCache.NAME);
        }
        if (statuses == null) {
            statuses = new ArrayList<SelectItem>();
        }
        return statuses;
    }

    public List<SelectItem> getCaseStatuses() {
        List<SelectItem> selectItems = null;

        selectItems = getDictUtils().getLov(LovConstants.DISPUTE_CASE_STATUSES);
        if (selectItems == null) {
            selectItems = new ArrayList<SelectItem>();
        }
        return selectItems;
    }

    public List<SelectItem> getOwnerUsers() {
        List<SelectItem> selectItems = null;

        selectItems = getDictUtils().getLov(LovConstants.USERS_IN_INSTS_BY_USERNAME);
        if (selectItems == null) {
            selectItems = new ArrayList<SelectItem>();
        }
        return selectItems;
    }

    public List<SelectItem> getCaseSources() {
        List<SelectItem> selectItems = null;

        selectItems = getDictUtils().getLov(LovConstants.DISPUTE_CASE_SOURCES);
        if (selectItems == null) {
            selectItems = new ArrayList<SelectItem>();
        }
        return selectItems;
    }

    public List<SelectItem> getFilterStatuses() {
        return getStatuses();
    }

    public List<SelectItem> getApplStatuses() {
        List<SelectItem> out = new ArrayList<SelectItem>();
        if (activeDspApplication != null) {
            try {
                Map<String, Object> paramMap = new HashMap<String, Object>();
                if (activeDspApplication.size() == 1 && activeDspApplication.get(0).getFlowId() != null) {
                    paramMap.put("flow_id", activeDspApplication.get(0).getFlowId());
                } else {
                    paramMap.put("flow_id", DEFAULT_FLOW_ID);
                }
                out = getDictUtils().getLov(LovConstants.DISPUTE_APPLICATION_STATUSES, paramMap);
                if (activeDspApplication.size() == 1) {
                    for (Iterator<SelectItem> iterator = out.iterator(); iterator.hasNext(); ) {
                        SelectItem status = iterator.next();
                        if (status.getValue().toString().equals(activeDspApplication.get(0).getStatus())) {
                            iterator.remove();
                        }
                    }
                }
            } catch (Exception ee) {
                FacesUtils.addMessageError(ee);
                logger.error("", ee);
            }
        }
        return out;
    }

    public List<SelectItem> getDspFlows() {
        Map<String, Object> paramMap = new HashMap<String, Object>();
        paramMap.put("appl_type", ApplicationConstants.TYPE_DISPUTES);
        paramMap.put("appl_subtype", getModule());
        return getDictUtils().getLov(LovConstants.EXTENDED_APPLICATION_FLOWS, paramMap, null, DictCache.NAME);
    }

    public ArrayList<SelectItem> getModifiers(){
        if(scaleType == null){
            modifiers = new ArrayList<SelectItem>();
            return modifiers;
        }
        if (modifiers == null || updateModifiers) {
            Map<String, Object> paramMap = new HashMap<String, Object>();
            paramMap.put("SCALE_TYPE", scaleType);
            modifiers =  (ArrayList<SelectItem>)getDictUtils().getLov(LovConstants.MODIFIER_LIST, paramMap);
            updateModifiers = false;
        }
        return modifiers;
    }

    public String submitForReview(){
        newStatus = ApplicationStatuses.READY_FOR_REVIEW;
        if (activeDspApplication != null) {
            for (DspApplication app : activeDspApplication) {
                app.setNewStatus(newStatus);
                app.setOldStatus(app.getStatus());
                app.setStatus(app.getNewStatus());
                update(app.getId(), EDIT_MODE);
            }
        }
        return null;
    }

    public void accept(){
        claimBased = true;
        newStatus = ApplicationStatuses.ACCEPTED;
        curMode = VIEW_MODE;
        if (activeDspApplication != null) {
            for (DspApplication app : activeDspApplication) {
                app.setNewStatus(newStatus);
                app.setOldStatus(app.getStatus());
                app.setStatus(app.getNewStatus());
                update(app.getId(), EDIT_MODE);
            }
        }
        createNewCase();
    }

    public void reject(){
        newStatus = ApplicationStatuses.REJECTED;
        curMode = VIEW_MODE;
    }

    public boolean isShowReasons(){
        return ApplicationStatuses.REJECTED.equals(newStatus);
    }

    public void changeStatus() {
        if (activeDspApplication != null) {
            try {
                for (DspApplication dspApp : activeDspApplication) {
                    if(rejectReasonCode != null && !rejectReasonCode.isEmpty()) {
                        dspApp.setRejectCode(rejectReasonCode);
                        dspApp.setComment(rejectComment);
                    }
                    dspApp.setEventType(EventConstants.ADDED_COMMENT_TO_DISPUTE);
                    dspApp.setType(ApplicationConstants.TYPE_DISPUTES);
                    dspApp.setNewStatus(newStatus);
                    dspApp.setOldStatus(dspApp.getStatus());
                    dspApp.setStatus(dspApp.getNewStatus());
                    Application app = dspApp.toApplication();
                    applicationDao.changeApplicationStatus(userSessionId, app);
                    update(dspApp.getId(), EDIT_MODE);
                }
            } catch (Exception e) {
                logger.error("", e);
                FacesUtils.addMessageError(e);
            }
            newStatus = null;
            rejectReasonCode = null;
            rejectComment = null;
        }
    }

    public void takeDisputeCase() {
        if (activeDspApplication != null) {
            try {
                for (DspApplication dspApp : activeDspApplication) {
                    dspApp.setNewStatus(dspApp.getStatus());
                    if (filter.getUserId() == null) {
                        selectCurrentUser();
                    }
                    dspApp.setUserId(filter.getUserId());
                    applicationDao.setApplicationUser(userSessionId, dspApp.toApplication());
                    update(dspApp.getId(), EDIT_MODE);
                }
            } catch (Exception e) {
                logger.error("", e);
                FacesUtils.addMessageError(e);
            }
        }
    }

    public void refuseDisputeCase() {
        if (activeDspApplication != null) {
            for (DspApplication dspApp : activeDspApplication) {
                try {
                    dspApp.setUserId(ApplicationConstants.UNDEFINED_USER);
                    applicationDao.setApplicationUser(userSessionId, dspApp.toApplication());
                    update(dspApp.getId(), EDIT_MODE);
                } catch (Exception e) {
                    logger.error("", e);
                    FacesUtils.addMessageError(e);
                }
            }
        }
    }

    public void cancelStatusChange() {
        newStatus = null;
        rejectReasonCode = null;
        rejectComment = null;
    }

    public List<DspApplicationFile> getDspApplicationFiles() {
        if(newDspApplication == null || newDspApplication.getFiles() == null){
            return new ArrayList<DspApplicationFile>();
        }
        return newDspApplication.getFiles();
    }

    public String getTabName() {
        return tabName;
    }
    public void setTabName(String tabName) {
        this.tabName = tabName;
    }

    public void loadCurrentTab() {
        loadTab(tabName);
    }

    public void loadTab(String tab) {
        if (tab == null || activeDspApplication == null) {
            return;
        }

        if (tab.equalsIgnoreCase(TAB_ATTACHMENT)) {
            attachments = (MbObjectDspDocuments)ManagedBeanWrapper.getManagedBean("MbObjectDspDocuments");
            attachments.setSelectedObjects(activeDspApplication);
            attachments.setModule(module);
            attachments.setSubmodule(submodule);
            if (activeDspApplication.size() != 1) {
                attachments.clearFilter();
            } else {
                RptDocument rptDocument = new RptDocument();
                attachments.setTabName(tabName);
                attachments.setParentSectionId(getSectionId());
                attachments.setTableState(getSateFromDB(attachments.getComponentId()));
                attachments.setCurLang(curLang);
                attachments.setCurMode(curMode);
                rptDocument.setObjectId(activeDspApplication.get(0).getId());
                rptDocument.setEntityType(EntityNames.APPLICATION);
                attachments.setFilter(rptDocument);
                attachments.search();
            }
        } else if (tab.equalsIgnoreCase(TAB_OPERATION)) {
            operations = (MbOperations)ManagedBeanWrapper.getManagedBean("MbOperations");
            if (activeDspApplication.size() != 1) {
                operations.clearFilter();
            } else {
                operations.setTabName(tabName);
                operations.setCurLang(curLang);
                operations.setCurMode(curMode);
                operations.setTableState(getSateFromDB(operations.getComponentId()));
                operations.getFilter().setCardMask(activeDspApplication.get(0).getCardMask());
                operations.getFilter().setAccountNumber(activeDspApplication.get(0).getAccountNumber());
                operations.getFilter().setCurrency(activeDspApplication.get(0).getCurrency());
                operations.getFilter().setOperAmount(activeDspApplication.get(0).getAmount());
                operations.getFilter().setId(activeDspApplication.get(0).getOperId());
                operations.getFilter().setDisputeId(activeDspApplication.get(0).getDisputeId());
                operations.search();
                operations.loadOperation();
            }
        } else if (tab.equalsIgnoreCase(TAB_PARTICIPANT)) {
            participants = (MbParticipants)ManagedBeanWrapper.getManagedBean("MbParticipants");
            if (activeDspApplication.size() != 1) {
                participants.clearFilter();
            } else {
                participants.setCurMode(curMode);
                participants.setCurLang(curLang);
                participants.getFilter().setCardMask(activeDspApplication.get(0).getCardMask());
                participants.getFilter().setOperId(activeDspApplication.get(0).getOperId());
                participants.getFilter().setAuthCode(activeDspApplication.get(0).getAuthCode());
                participants.getFilter().setInstId(activeDspApplication.get(0).getInstId());
                participants.getFilter().setAccountNumber(activeDspApplication.get(0).getAccountNumber());
                participants.getFilter().setCustomerId(activeDspApplication.get(0).getCustomerId());
                participants.getFilter().setCustomerNumber(activeDspApplication.get(0).getCustomerNumber());
                if (activeDspApplication.get(0).getMerchantId() != null) {
                    participants.getFilter().setMerchantId(Integer.valueOf(activeDspApplication.get(0).getMerchantId()));
                }
                if (activeDspApplication.get(0).getTerminalId() != null) {
                    participants.getFilter().setTerminalId(Integer.valueOf(activeDspApplication.get(0).getTerminalId()));
                }
                participants.loadParticipantsForOperation(participants.getFilter().getOperId());
            }
        } else if (tab.equalsIgnoreCase(TAB_HISTORY)) {
            history = (MbApplicationHistory)ManagedBeanWrapper.getManagedBean("MbApplicationHistory");
            if (activeDspApplication.size() != 1) {
                history.clearFilter();
            } else {
                history.setTabName(tabName);
                history.setCurMode(curMode);
                history.setCurLang(curLang);
                history.setTableState(getSateFromDB(history.getComponentId()));
                history.setParentSectionId(getSectionId());
                history.getFilter().setApplId(activeDspApplication.get(0).getId());
                history.search();
            }
        } else if (tab.equalsIgnoreCase(TAB_ITEMS)) {
            associatedOperations = (MbAssociatedOperations)ManagedBeanWrapper.getManagedBean("mbAssociatedOperations");
            if (activeDspApplication.size() != 1) {
                associatedOperations.clearFilter();
	            associatedOperations.setNeedRefreshApplications(true);
	            associatedOperations.setDisabledCreateButton(true);
            } else {
	            associatedOperations.setNeedRefreshApplications(true);
                associatedOperations.setCurLang(curLang);
                associatedOperations.setCurMode(curMode);
                associatedOperations.setOperId(activeDspApplication.get(0).getOperId());
                associatedOperations.setDisputeId(activeDspApplication.get(0).getDisputeId());
                associatedOperations.setCardMask(activeDspApplication.get(0).getCardMask());
                associatedOperations.setCardNumber(activeDspApplication.get(0).getCardNumber());
                associatedOperations.setSelectedOperationCurrency(activeDspApplication.get(0).getCurrency());
                associatedOperations.setNode(initOperation(activeDspApplication.get(0)));
                associatedOperations.setParentDispute(activeDspApplication.get(0));
                associatedOperations.setDisabledCreateButton(
                		ApplicationStatuses.CLOSED_STATUSES.contains(activeDspApplication.get(0).getStatus())
                );
                associatedOperations.search();
            }

            associatedOperations.setDisabledDocumentsButton(false);
            for(DspApplication app: activeDspApplication) {
            	boolean disabled = ApplicationStatuses.CLOSED_STATUSES.contains(app.getStatus());
            	if (disabled) {
		            associatedOperations.setDisabledDocumentsButton(true);
		            break;
	            }
            }

        } else if (tab.equalsIgnoreCase(TAB_CLEARING)) {
            technicalMessages = (MbTechnicalMessages)ManagedBeanWrapper.getManagedBean("mbTechnicalMessages");
            if (activeDspApplication.size() != 1) {
                technicalMessages.clearFilter();
            } else {
                technicalMessages.setCurLang(curLang);
                technicalMessages.setCurMode(curMode);
                technicalMessages.getFilter().setOperId(activeDspApplication.get(0).getOperId());
                technicalMessages.getFilter().setLang(curLang);
                technicalMessages.getFilter().setViewName(TAB_CLEARING_VW);
                technicalMessages.search();
            }
        } else if (tab.equalsIgnoreCase(TAB_AUTHORIZATION)) {
            authorizations = (MbAuthorizations)ManagedBeanWrapper.getManagedBean("MbAuthorizations");
            if (activeDspApplication.size() != 1) {
                authorizations.clearFilter();
            } else {
                authorizations.setCurLang(curLang);
                authorizations.setCurMode(curMode);
                authorizations.loadAuthorization(activeDspApplication.get(0).getOperId());
            }
        } else if (tab.equalsIgnoreCase(TAB_OBJECT)) {
            if (getModule().equals(ApplicationConstants.TYPE_ISSUING)) {
                cardDetails = (MbCardsSearch)ManagedBeanWrapper.getManagedBean("MbCardsSearch");

                MbCardholdersSearch cardholdersBean = (MbCardholdersSearch) ManagedBeanWrapper.getManagedBean("MbCardholdersSearch");
                cardholdersBean.clearFilter();

                if (activeDspApplication.size() != 1) {
                    cardDetails.clearFilter();
                } else {
                    cardDetails.setCurLang(curLang);
                    cardDetails.setCurMode(curMode);
                    cardDetails.getFilter().setInstId(activeDspApplication.get(0).getInstId());
                    cardDetails.getFilter().setCustomerNumber(activeDspApplication.get(0).getCustomerNumber());
                    cardDetails.getFilter().setCardNumber(activeDspApplication.get(0).getCardMask());
                    cardDetails.search();
                    cardDetails.loadCard();

                    if (cardDetails.getActiveCard() != null) {
                        Cardholder filterCardholder = new Cardholder();
                        filterCardholder.setId(cardDetails.getActiveCard().getCardholderId());
                        cardholdersBean.setFilter(filterCardholder);
                        cardholdersBean.setSearchByCard(true);
                        cardholdersBean.search();
                        cardholdersBean.getCardholder();
                    } else {
                        cardholdersBean.clearState();
                    }
                }
            } else {
                merchantDetails = (MbMerchant)ManagedBeanWrapper.getManagedBean("MbMerchant");
                MbTerminal terminalBean = (MbTerminal) ManagedBeanWrapper.getManagedBean("MbTerminal");
                terminalBean.clearFilter();

                if (activeDspApplication.size() != 1) {
                    merchantDetails.clearFilter();
                } else {
                    merchantDetails.setCurLang(curLang);
                    merchantDetails.setCurMode(curMode);
                    merchantDetails.getFilter().setInstId(activeDspApplication.get(0).getInstId());
                    merchantDetails.getFilter().setInstName(activeDspApplication.get(0).getInstName());
                    merchantDetails.getFilter().setMerchantName(activeDspApplication.get(0).getMerchantName());
                    merchantDetails.getFilter().setMerchantNumber(activeDspApplication.get(0).getMerchantNumber());
                    merchantDetails.getFilter().setAgentId(activeDspApplication.get(0).getAgentId());
                    merchantDetails.searchMerchants();

                    if (StringUtils.isNotEmpty(activeDspApplication.get(0).getTerminalNumber())) {
                        terminalBean.setCurLang(curLang);
                        terminalBean.setCurMode(curMode);
                        terminalBean.getFilter().setTerminalNumber(activeDspApplication.get(0).getTerminalNumber());
                        terminalBean.getFilter().setInstId(activeDspApplication.get(0).getInstId());
                        terminalBean.search();
                        terminalBean.getTerminal();
                    }
                }
            }
        }
    }

    private Operation initOperation(DspApplication app) {
        Operation operation = new Operation();
        operation.setId(app.getOperId());
        return operation;
    }

    public String getObjectPage() {
        if (getModule().equals(ApplicationConstants.TYPE_ISSUING)) {
            return CARD_DETAIL_PAGE;
        }
        return MERCHANT_DETAIL_PAGE;
    }

    private List<SelectItem> getRejectCodes(Map<String, Object> params) {
        if (params != null && params.size() != 0) {
            return getDictUtils().getLov(LovConstants.DISPUTE_REJECT_CODES, params);
        }
        return getDictUtils().getLov(LovConstants.DISPUTE_REJECT_CODES);
    }

    public List<SelectItem> getApplRejectCodes() {
        Map<String, Object> paramMap = new HashMap<String, Object>();
        if (activeDspApplication != null) {
            if (activeDspApplication.size() == 1 && activeDspApplication.get(0).getFlowId() != null) {
                paramMap.put("flow_id", activeDspApplication.get(0).getFlowId());
            } else {
                paramMap.put("flow_id", DEFAULT_FLOW_ID);
            }
            if (activeDspApplication.size() == 1 && activeDspApplication.get(0).getNewStatus() != null) {
                paramMap.put("appl_status", activeDspApplication.get(0).getNewStatus());
            } else if (activeDspApplication.size() == 1 && activeDspApplication.get(0).getStatus() != null) {
                paramMap.put("appl_status", activeDspApplication.get(0).getStatus());
            } else {
                paramMap.put("appl_status", ApplicationStatuses.UNDEFINED);
            }
        }
        return getRejectCodes(paramMap);
    }

    public List<SelectItem> getFilterRejectCodes() {
        Map<String, Object> paramMap = new HashMap<String, Object>();
        paramMap.put("flow_id", (getFilter().getFlowId() != null) ? getFilter().getFlowId() : DEFAULT_FLOW_ID);
        paramMap.put("appl_status", (getFilter().getStatus() != null) ? getFilter().getStatus() : ApplicationStatuses.UNDEFINED);
        return getRejectCodes(paramMap);
    }

    public List<SelectItem> getReasonsForRejectingApplications() {
        return getDictUtils().getLov(LovConstants.REASONS_REJECTING_APPL, null, null, DictCache.NAME);
    }

    public List<SelectItem> getApplReasons() {
        List<SelectItem> out = getDictUtils().getLov(LovConstants.APPLICATION_HISTORY_MESSAGES);
        for (SelectItem reason : out) {
            reason.setValue(reason.getLabel());
        }
        return out;
    }

    public List<SelectItem> getUsersLov() {
        return getDictUtils().getLov(LovConstants.USERS_IN_INSTS_BY_USER);
    }

    public List<SelectItem> getCaseProgress() {
        return getDictUtils().getLov(LovConstants.DISPUTE_CASE_PROGRESS);
    }

    public List<SelectItem> getFlows() {
        if (ApplicationConstants.TYPE_ISSUING.equals(getModule())) {
            return getDictUtils().getLov(LovConstants.DISPUTE_FLOWS_ISSUING);
        } else if (ApplicationConstants.TYPE_ACQUIRING.equals(getModule())) {
            return getDictUtils().getLov(LovConstants.DISPUTE_FLOWS_ACQUIRING);
        } else  if (ApplicationConstants.TYPE_DISPUTES.equals(getModule())) {
            return getDictUtils().getLov(LovConstants.DISPUTE_FLOWS_ISSUING);
        } else {
            return new ArrayList<SelectItem>(0);
        }
    }

    private void setUser(User user) {
        if (user != null) {
            getFilter().setUserId(user.getId());
            getFilter().setUserName(user.getName());
        }
    }

    public void selectUser() {
        MbUserSearchModal userBean = ManagedBeanWrapper.getManagedBean("MbUserSearchModal");
        if (userBean != null) {
            setUser(userBean.getActiveUser());
        }
    }

    public void selectCurrentUser() {
        UserSession userSession = (UserSession)ManagedBeanWrapper.getManagedBean("usession");
        if (userSession != null) {
            setUser(userSession.getUser());
        }
    }

    public List<SelectItem> getInstitutions() {
        if (institutions == null) {
            institutions = getDictUtils().getLov(LovConstants.INSTITUTIONS);
        }
        return institutions;
    }

    public List<SelectItem> getAgents() {
        Map<String, Object> paramMap = new HashMap<String, Object>();
        if (getFilter().getInstId() != null) {
            paramMap.put("INSTITUTION_ID", getFilter().getInstId());
        }
        return getDictUtils().getLov(LovConstants.AGENTS, paramMap);
    }

    public List<SelectItem> getCreationAgents() {
        Map<String, Object> paramMap = new HashMap<String, Object>();
        if (getManualCaseCreation() != null && getManualCaseCreation().getInstId() != null) {
            paramMap.put("INSTITUTION_ID", getManualCaseCreation().getInstId());
        }
        return getDictUtils().getLov(LovConstants.AGENTS, paramMap);
    }

    public List<SelectItem> getDisputeReasons() {
        return getDictUtils().getLov(LovConstants.DISPUTE_REASONS, null, null, DictCache.NAME);
    }

    public void initPanel() {
        logger.debug("Init search user panel for flow dispute application");
    }

    public void refuseApplication() {
        if (activeDspApplication != null) {
            for (DspApplication dspApp : activeDspApplication) {
                Integer originalUserId = dspApp.getUserId();
                try {
                    Map<String, Object> params = new HashMap<String, Object>();
                    params.put("applId", dspApp.getId());
                    Integer userId = applicationDao.refuseDspApplication(userSessionId, params);
                    dspApp.setUserChanged(Boolean.TRUE);
                    dspApp.setEventType(EventConstants.DISPUTE_ASSIGNED_TO_USER);

                    Application app = dspApp.toApplication();
                    ApplicationElement application = applicationDao.getApplicationForEdit(userSessionId, app);

                    dspApp.setUserId(userId);
                    app.setUserId(userId);
                    app.setAppType(ApplicationConstants.TYPE_DISPUTES);
                    app.setAppSubType(getModule());
                    if (application.getChildByName(AppElements.USER_ID, 1) != null) {
                        application.getChildByName(AppElements.USER_ID, 1).setValueN(app.getUserId());
                    }
                    applicationDao.saveApplication(userSessionId, application, app);
                } catch (Exception e) {
                    dspApp.setUserChanged(Boolean.FALSE);
                    FacesUtils.addMessageError(e);
                    logger.error("Failed to refuse application [" + dspApp.getId() + "], revert to previous user", e);
                } finally {
                    if (dspApp.getUserId() == null) {
                        dspApp.setUserId(originalUserId);
                    }
                }
            }
        }
    }

    public void changeVisibility() {
        if (activeDspApplication != null) {
            for (DspApplication dspApp : activeDspApplication) {
                if (dspApp.getId() != null) {
                    Map<String, Object> params = new HashMap<String, Object>();
                    params.put("id", dspApp.getId());
                    params.put("visible", !dspApp.isVisible());
                    try {
                        applicationDao.changeDspApplicationVisibility(userSessionId, params);
                        search();
                    } catch (Exception e) {
                        FacesUtils.addMessageError(e);
                        logger.error("Failed to change application visibility", e);
                    }
                }
            }
        }
    }

    public boolean isUnchangeableUser() {
        if (activeDspApplication != null) {
            UserSession userSession = (UserSession)ManagedBeanWrapper.getManagedBean("usession");
            if (userSession != null && userSession.getUser() != null && userSession.getUser().getId() != null) {
                for (DspApplication dspApp : activeDspApplication) {
                    if (dspApp.getUserId() != null) {
                        if (userSession.getUser().getId().equals(dspApp.getUserId())) {
                            return true;
                        }
                    }
                }
                return false;
            }
        }
        return true;
    }

    public MbObjectDspDocuments getAttachments() {
        return attachments;
    }
    public MbOperations getOperations() {
        return operations;
    }
    public MbParticipants getParticipants() {
        return participants;
    }
    public MbAssociatedOperations getAssociatedOperations() {
        return associatedOperations;
    }
    public MbApplicationHistory getHistory() {
        return history;
    }
    public MbTechnicalMessages getTechnicalMessages() {
        return technicalMessages;
    }
    public MbCardsSearch getCardDetails() {
        return cardDetails;
    }
    public MbMerchant getMerchantDetails() {
        return merchantDetails;
    }
    public MbAuthorizations getAuthorizations() {
        return authorizations;
    }

    public String getMessageType() {
        return messageType;
    }
    public void setMessageType(String messageType) {
        this.messageType = messageType;
    }

    public String getTypeOfCase() {
        return typeOfCase;
    }

    public void setTypeOfCase(String typeOfCase) {
        this.typeOfCase = typeOfCase;
    }

    public String getCaseCreationPanel() {
        return caseCreationPanel;
    }

    public List<SelectItem> getDisputesCaseTypes() {
        return disputesCaseTypes;
    }

    public void setDisputesCaseTypes(List<SelectItem> disputesCaseTypes) {
        this.disputesCaseTypes = disputesCaseTypes;
    }

    public String getOperationId() {
        return operationId;
    }

    public void setOperationId(String operationId) {
        this.operationId = operationId;
    }

    public ManualCaseCreation getManualCaseCreation() {
        return manualCaseCreation;
    }

    public List<Operation> getUnpairedDisputeOperations() {
        return unpairedDisputeOperations;
    }

    public void setManualCaseCreation(ManualCaseCreation manualCaseCreation) {
        this.manualCaseCreation = manualCaseCreation;
    }

    public boolean isMessageTypeChargeback() {
        if (messageType != null && messageType.equals("MSGTCHBK")) {
            return true;
        }
        return false;
    }

    public Integer getInitRule() {
        return initRule;
    }
    public void setInitRule(Integer initRule) {
        this.initRule = initRule;
        if (this.initRule != null && operationTypes != null) {
            for (SelectItem type : operationTypes) {
                if ((Integer)type.getValue() == this.initRule) {
                    messageType = type.getDescription();
                }
            }
        }
    }

    public String getDisputeReason() {
        return disputeReason;
    }
    public void setDisputeReason(String disputeReason) {
        this.disputeReason = disputeReason;
    }

    public String getDueDate() {
        return (dueDate != null) ? dueDate : "";
    }

    public String getUnpairedId() {
        return unpairedId;
    }

    public Integer getChargebackLovId() {
        return chargebackLovId;
    }

    public String getDisputeAction() {
        return disputeAction;
    }
    public void setDisputeAction(String disputeAction) {
        this.disputeAction = disputeAction;
    }

    public String getReasonCode() {
        return reasonCode;
    }
    public void setReasonCode(String reasonCode) {
        this.reasonCode = reasonCode;
    }

    public List<SelectItem> getDueDateTypesOfDisputeCases() {
        if (activeDspApplication != null && activeDspApplication.size() > 0) {
            try {
                int lovId = disputesDao.getDueDateLov(userSessionId,
                                                      activeDspApplication.get(0).getId(),
                                                      activeDspApplication.get(0).getFlowId());
                return getDictUtils().getLov(lovId);
            } catch (Exception e) {
                logger.error("", e);
                FacesUtils.addMessageError(e.getMessage());
            }
        }
        return new ArrayList<SelectItem>();
    }

    public boolean isMatchDisplay() {
        if (operationId != null && unpairedId != null) {
            matchDisplay = true;
        } else {
            matchDisplay = false;
        }
        return matchDisplay;
    }

    public void setUnpairedId(String unpairedId) {
        this.unpairedId = unpairedId;
    }

    public String getNewStatus() {
        return newStatus;
    }

    public List<SelectItem> getOperationTypes() {
        Map<String, Object> params = new HashMap<String, Object>();
        params.put("lang", userLang);
        if (activeDspApplication != null && activeDspApplication.size() == 1) {
            params.put("operId", activeDspApplication.get(0).getOperId());
        } else {
            params.put("operId", null);
        }
        try {
            List<DisputeListCondition> condList = disputesDao.getDisputesList(userSessionId, params);
            operationTypes = new ArrayList<SelectItem>(condList.size());
            for (DisputeListCondition cond : condList) {
                operationTypes.add(new SelectItem(cond.getInitRule(), cond.getType(), cond.getMsgType()));
            }
        } catch (Exception e) {
            logger.error("", e);
            operationTypes = new ArrayList<SelectItem>(0);
        }
        return operationTypes;
    }

    public void checkDueDate() {
        Map<String, Object> params = new HashMap<String, Object>();
        if (activeDspApplication != null && activeDspApplication.size() == 1) {
            params.put("caseId", activeDspApplication.get(0).getId());
        }
        params.put("msgType", disputeAction);
        params.put("reasonCode", reasonCode);
        params.put("isManual", true);
        try {
            Date date = applicationDao.getDueDate(userSessionId, params);
            if (date != null) {
                DateFormat df = new SimpleDateFormat(((UserSession)ManagedBeanWrapper.getManagedBean("usession")).getFullDatePattern());
                dueDate = df.format(date);
            } else {
                dueDate = DUE_DATE_NOT_DEFINED;
            }
        } catch (Exception e) {
            logger.error("", e);
            dueDate = DUE_DATE_NOT_DEFINED;
            FacesUtils.addMessageError(e);
        }
    }

    public void setDueDate() {
        if (activeDspApplication != null) {
            for (DspApplication dspApp : activeDspApplication) {
                Map<String, Object> params = new HashMap<String, Object>();
                params.put("applId", activeDspApplication.get(0).getId());
                params.put("dueDate", newDueDate);
                params.put("seqNum", activeDspApplication.get(0).getSeqNum());
                try {
                    CommonUtils common = (CommonUtils) ManagedBeanWrapper.getManagedBean("CommonUtils");
                    Calendar now = Calendar.getInstance(common.getTimeZone());
                    Calendar newDueDateCalendar = Calendar.getInstance(common.getTimeZone());
                    newDueDateCalendar.setTime(newDueDate);
                    if(newDueDateCalendar != null && newDueDateCalendar.before(now)) {
                       throw new Exception(FacesUtils.getMessage(
                                "ru.bpc.sv2.ui.bundles.Msg", "selected_date_passed"));
                    }
                    applicationDao.updateDueDate(userSessionId, params);
                    activeDspApplication.get(0).setDueDate(newDueDate);
                    if (params.get("seqNum") != null) {
                        activeDspApplication.get(0).setSeqNum((Integer) params.get("seqNum"));
                    }
                } catch (Exception e) {
                    FacesUtils.addMessageError(e);
                    logger.error("", e);
                }
            }
            if (activeDspApplication.size() == 1) {
                update(activeDspApplication.get(0).getId(), EDIT_MODE);
            }
        }
    }

    private String getPrivilegeName(String basicName) {
        if (getModule().equals(ApplicationConstants.TYPE_ISSUING)) {
            return basicName + "_ISS";
        } else if (getModule().equals(ApplicationConstants.TYPE_ACQUIRING)) {
            return basicName + "_ACQ";
        }
        return basicName;
    }

    public boolean isRendered(String component) {
        Map<String, Boolean> role = ((UserSession)ManagedBeanWrapper.getManagedBean("usession")).getInRole();
        if (role != null) {
            if (component.equals("addBtn")) {
                return role.get(getPrivilegeName(DspAppPrivileges.ADD_DISPUTE_APPLICATIONS));
            } else if (component.equals("editBtn")) {
                return role.get(getPrivilegeName(DspAppPrivileges.MODIFY_DISPUTE_APPLICATIONS));
            } else if (component.equals("changeStatus") || component.equals("submitForReview")) {
                return role.get(getPrivilegeName(DspAppPrivileges.MODIFY_DISPUTE_APPLICATIONS));
            } else if (component.equals("accept") || component.equals("reject")) {
                return role.get(getPrivilegeName(DspAppPrivileges.MODIFY_DISPUTE_APPLICATIONS));
            } else if (component.equals("submit_for_review")) {
                return role.get(getPrivilegeName(DspAppPrivileges.MODIFY_DISPUTE_APPLICATIONS));
            } else if (component.equals("deleteBtn")) {
                return role.get(getPrivilegeName(DspAppPrivileges.REMOVE_DISPUTE_APPLICATIONS));
            } else if (component.equals("viewBtn")) {
                return role.get(getPrivilegeName(DspAppPrivileges.VIEW_DISPUTE_APPLICATIONS));
            } else if (component.equals("refuse")) {
                return role.get(getPrivilegeName(DspAppPrivileges.CHANGE_DISPUTE_USER));
            } else if (component.equals("hide")) {
                return role.get(getPrivilegeName(DspAppPrivileges.HIDE_DISPUTE_APPLICATION));
            } else if (component.equals("unhide")) {
                return role.get(getPrivilegeName(DspAppPrivileges.UNHIDE_DISPUTE_APPLICATION));
            } else if (component.equals("createLetter")) {
                if (!getModule().equals(ApplicationConstants.TYPE_DISPUTES)) {
                    return role.get(getPrivilegeName(DspAppPrivileges.VIEW_DISPUTE_APPLICATIONS));
                }
            } else if (component.equals("caseProgress")) {
                return role.get(DspAppPrivileges.SET_CASE_PROGRESS_BTN);
            } else if (component.equals("reasonCode")) {
                return role.get(DspAppPrivileges.SET_REASON_CODE_BTN);
            } else if (component.equals("duplicate")) {
                return role.get(DspAppPrivileges.DUPLICATE_BTN_VIEW);
            } else if (component.equals("reopen")) {
                return role.get(DspAppPrivileges.REOPEN_BTN_VIEW);
            } else if (component.equals("close")) {
                return role.get(DspAppPrivileges.CLOSE_BTN_VIEW);
            }
        }
        return false;
    }

    public boolean isDisabled(String component) {
        boolean result = false;
        if ("reject".equals(component) || "accept".equals(component)) {
            if (activeDspApplication != null && activeDspApplication.size() > 0) {
                for(DspApplication app : activeDspApplication) {
                    if(!ApplicationStatuses.READY_FOR_REVIEW.equals(app.getStatus())) {
                        result = true;
                        break;
                    }
                }
            } else {
                result = true;
            }
        } else if("submit_for_review".equals(component)) {
            if (activeDspApplication != null && activeDspApplication.size() > 0) {
                for(DspApplication app : activeDspApplication) {
                    if(!ApplicationStatuses.JUST_CREATED.equals(app.getStatus())) {
                        result = true;
                        break;
                    }
                }
            } else {
                result = true;
            }
        } else if("viewBtn".equals(component)) {
            if (activeDspApplication == null || activeDspApplication.size() <= 0) {
                result = true;
            }
        }
        return result;
    }

    public boolean isTabRendered(String tab) {
        if (getModule().equals(ApplicationConstants.TYPE_DISPUTES)) {
            if (tab.equals(TAB_OPERATION)) {
                return false;
            } else if (tab.equals(TAB_AUTHORIZATION)) {
                return false;
            } else if (tab.equals(TAB_ITEMS)) {
                return false;
            } else if (tab.equals(TAB_PARTICIPANT)) {
                return false;
            } else if (tab.equals(TAB_CLEARING)) {
                return false;
            } else if (tab.equals(TAB_OBJECT)) {
                return false;
            }
        }
        return true;
    }

    public boolean isSearchRendered(String field) {
        if (getModule().equals(ApplicationConstants.TYPE_DISPUTES)) {
            if (field.equals("flowId")) {
                return false;
            } else if (field.equals("merchantNumber")) {
                return false;
            } else if (field.equals("userId")) {
                return false;
            } else if (field.equals("merchantName")) {
                return false;
            } else if (field.equals("referenceNumber")) {
                return false;
            } else if (field.equals("terminalNumber")) {
                return false;
            } else if (field.equals("authCode")) {
                return false;
            }
        }
        return true;
    }

    public void showCustomers() {
        MbCustomerSearchModal bean = (MbCustomerSearchModal)ManagedBeanWrapper.getManagedBean("MbCustomerSearchModal");
        bean.setModule(ModuleNames.CASE_MANAGEMENT);
        bean.clearFilter();
        if (getFilter().getInstId() != null) {
            bean.setBlockInstId(true);
            bean.setDefaultInstId(getFilter().getInstId());
        } else {
            bean.setBlockInstId(false);
        }
    }

    public void selectCustomer() {
        MbCustomerSearchModal bean = (MbCustomerSearchModal)ManagedBeanWrapper.getManagedBean("MbCustomerSearchModal");
        bean.setModule(ModuleNames.CASE_MANAGEMENT);
        Customer selected = bean.getActiveCustomer();
        if (selected != null) {
            getFilter().setCustomerId(selected.getId());
            getFilter().setCustomerNumber(selected.getCustomerNumber());
            getFilter().setCustomerInfo(selected.getName());
            getFilter().setInstId(selected.getInstId());
            getFilter().setInstName(selected.getInstName());
            getFilter().setAgentNumber(selected.getAgentNumber());
            getFilter().setAgentName(selected.getAgentName());
        }
    }

    public void initializeLetter() {
        MbDspLetter bean = (MbDspLetter)ManagedBeanWrapper.getManagedBean("MbDspLetter");
        if (bean != null) {
            bean.clearFilter();
            if (activeDspApplication != null) {
                if (activeDspApplication.size() == 1) {
                    bean.setApplicationId(activeDspApplication.get(0).getId());
                    bean.setApplications(null);
                } else {
                    bean.setApplicationId(null);
                    bean.setApplications(activeDspApplication);
                }
            }
            bean.setTemplateId(null);
            bean.setFileFormat(null);
            bean.setReport(null);
            bean.setModule(module);
        }
    }

    public OriginalCaseFilter getOriginalCaseFilter() {
        return originalCaseFilter;
    }

    public void setOriginalCaseFilter(OriginalCaseFilter originalCaseFilter) {
        this.originalCaseFilter = originalCaseFilter;
    }

    public void searchOperations() {
        final Integer forceSearch = new Integer(1);
        operationOriginalCase = new DaoDataListModel<Operation>(logger) {

            @Override
            protected int loadDaoDataSize(SelectionParams params) {
                int count = 0;
                int threshold = 300;

                List<Filter> filters = getFilterOperations();
                Map<String, Object> paramMap = getFilterParamMap();

                params.setFilters(filters.toArray(new Filter[filters.size()]));
                paramMap.put("force_search", forceSearch);
                paramMap.put("param_tab", filters.toArray(new Filter[filters.size()]));
                params.setThreshold(threshold);
                count = operationDao.getOperationCursorCount(userSessionId, paramMap, getPrivName());
                idTab  = (BigDecimal[])paramMap.get("oper_id_tab");
                return count;
            }

            @Override
            protected List<Operation> loadDaoListData(SelectionParams params) {
                List<Filter> filters = getFilterOperations();
                Map<String, Object> paramMap = getFilterParamMap();

                paramMap.put("force_search", forceSearch);
                paramMap.put("param_tab", filters.toArray(new Filter[filters.size()]));
                paramMap.put("oper_id_tab", idTab);
                return operationDao.getOperationCursor(userSessionId, params, paramMap, getPrivName());
            }
        };
    }

    private Map<String, Object> getFilterParamMap() {
        Map<String, Object> paramMap = new HashMap<String, Object>();
        paramMap.put("tab_name", "ORIGINAL_CASE_OPERATIONS");
        return paramMap;
    }

    private List<Filter> getFilterOperations() {
        List<Filter> filters = new ArrayList<Filter>();
        List<SelectItem> items = null;

	    filters.add(Filter.create("OPER_ID", null)); // for filter limitation (CORE-19397)

        if (ApplicationConstants.TYPE_ISSUING.equals(module) || ApplicationConstants.TYPE_ISSUING.equals(submodule)) {
            filters.add(Filter.create("PARTICIPANT_MODE", "PRTYISS"));
            items = getDictUtils().getLov(LovConstants.ISS_STTL_TYPES);
        } else if (ApplicationConstants.TYPE_ACQUIRING.equals(module)) {
            filters.add(Filter.create("PARTICIPANT_MODE", "PRTYACQ"));
            items = getDictUtils().getLov(LovConstants.ACQ_STTL_TYPES);
        }
        if (items != null && !items.isEmpty()) {
            StringBuilder sb = new StringBuilder();
            for (int i = 0; i < items.size() - 1; i++) {
                sb.append(items.get(i).getValue().toString() + "','");
            }
            sb.append(items.get(items.size()-1).getValue().toString());
            filters.add(Filter.create("STTL_TYPES", sb.toString()));
        }
        if (originalCaseFilter.getCardMask() != null && originalCaseFilter.getCardMask().trim().length() > 0) {
            filters.add(Filter.create("CARD_MASK", Filter.mask(originalCaseFilter.getCardMask(), true)));
        }
        if (originalCaseFilter.getAuthCode() != null && originalCaseFilter.getAuthCode().trim().length() > 0) {
            filters.add(Filter.create("AUTH_CODE", originalCaseFilter.getAuthCode()));
        }
        if (originalCaseFilter.getMerchantNumber() != null && originalCaseFilter.getMerchantNumber().trim().length() > 0) {
            filters.add(Filter.create("MERCHANT_NUMBER", Filter.mask(originalCaseFilter.getMerchantNumber(), true)));
        }
        if (originalCaseFilter.getOperDateFrom() != null) {
            filters.add(Filter.create("OPER_DATE_FROM", originalCaseFilter.getOperDateFrom()));
        }
        if (originalCaseFilter.getOperDateTo() != null) {
            filters.add(Filter.create("OPER_DATE_TILL", originalCaseFilter.getOperDateTo()));
        }
        if (originalCaseFilter.getMerchantName() != null && originalCaseFilter.getMerchantName().trim().length() > 0) {
            filters.add(Filter.create("MERCHANT_NAME", Filter.mask(originalCaseFilter.getMerchantName(), true)));
        }
        if (originalCaseFilter.getTerminalNumber() != null && originalCaseFilter.getTerminalNumber().trim().length() > 0) {
            filters.add(Filter.create("TERMINAL_NUMBER", Filter.mask(originalCaseFilter.getTerminalNumber(), true)));
        }
        if (originalCaseFilter.getArn() != null && originalCaseFilter.getArn().trim().length() > 0) {
            filters.add(Filter.create("NETWORK_REFNUM", originalCaseFilter.getArn()));
        }
        if (originalCaseFilter.getHostDateFrom() != null) {
            filters.add(Filter.create("HOST_DATE_FROM", originalCaseFilter.getHostDateFrom()));
        }
        if (originalCaseFilter.getHostDateTo() != null) {
            filters.add(Filter.create("HOST_DATE_TILL", originalCaseFilter.getHostDateTo()));
        }

        return filters;
    }

    private String getActualModuleType(String module) {
        if (module.equals(ApplicationConstants.TYPE_ISSUING) || module.equals(ApplicationConstants.TYPE_DISPUTES)) {
            return ModuleNames.ISSUING;
        }
        else if (module.equals(ApplicationConstants.TYPE_ACQUIRING)) {
            return ModuleNames.ACQUIRING;
        }
        return null;
    }

    private String getPrivName() {
        if (module.equals(ApplicationConstants.TYPE_ISSUING)) {
            return OperationPrivConstants.VIEW_ISSUING_OPERATIONS;
        }
        else if (module.equals(ApplicationConstants.TYPE_ACQUIRING)) {
            return OperationPrivConstants.VIEW_ACQUIRING_OPERATIONS;
        } else {
            return OperationPrivConstants.VIEW_OPERATION;
        }
    }

    public DaoDataModel<Operation> getOperationOriginalCase() {
        return operationOriginalCase;
    }

    public void createDisputeCase() {
        Map<String, Object> params = new HashMap<String, Object>();
        if (StringUtils.isNotBlank(this.operationId)) {
        	Long operationId = Long.valueOf(this.operationId);
            params.put("operId", operationId);
            boolean needMasterCom = true;
            if (getModule().equals(ApplicationConstants.TYPE_ISSUING) || getModule().equals(ApplicationConstants.TYPE_DISPUTES)) {
                params.put("participantType", "PRTYISS");
            } else if (getModule().equals(ApplicationConstants.TYPE_ACQUIRING)){
                params.put("participantType", "PRTYACQ");
            }
            if (claimBased && activeDspApplication != null && activeDspApplication.size() > 0) {
                params.put("disputeReason", activeDspApplication.get(0).getDisputeReason());
                params.put("claimId", activeDspApplication.get(0).getId());
                int flowId = activeDspApplication.get(0).getFlowId();
	            needMasterCom = flowId == ApplicationFlows.DSP_ISS_INTERNATIONAL || flowId == ApplicationFlows.DSP_ACQ_INTERNATIONAL;
            }
            try {
	            if (needMasterCom) {
		            fillMasterComParameters(params, operationId);
	            }

	            Long appId = disputesDao.createCaseDisputeByOperation(userSessionId, params);
                if (ApplicationStatuses.ACCEPTED.equals(newStatus) || ApplicationStatuses.REJECTED.equals(newStatus)) {
                    changeStatus();
                }
                DspApplication app = getDspApplicationById(appId);
                if (app != null) {
                    itemSelection.addNewObjectToList(app);
                }
                setItemSelection(itemSelection.getWrappedSelection());
            } catch (Exception e) {
                logger.error("", e);
                FacesUtils.addMessageError(e);
            }
        }
    }

    public void createDisputeUnpairedCase() {
        Map<String, Object> params = new HashMap<String, Object>();
        if (operationId != null && unpairedId != null) {

            params.put("operId", Long.valueOf(operationId));
            params.put("unpairedId", Long.valueOf(unpairedId));
            if (getModule().equals(ApplicationConstants.TYPE_ISSUING)) {
                params.put("participantType", "PRTYISS");
            } else {
                params.put("participantType", "PRTYACQ");
            }
            try {
                disputesDao.createUnpairedCaseApplication(userSessionId, params);
            } catch (UserException e) {
                throw new IllegalStateException(e);
            }
        }
    }

    public void createDisputeManualCase() {
        try {
            disputesDao.createManualApplication(userSessionId, manualCaseCreation);
            if (ApplicationStatuses.ACCEPTED.equals(newStatus) || ApplicationStatuses.REJECTED.equals(newStatus)) {
                changeStatus();
            }
            DspApplication app = getDspApplicationById(manualCaseCreation.getApplId());
            if(app != null) {
                itemSelection.addNewObjectToList(app);
            }
            setItemSelection(itemSelection.getWrappedSelection());
        } catch (Exception e) {
            logger.error("", e);
            FacesUtils.addMessageError(e);
        }
    }

    public void clearOriginalCaseCreationCache() {
        operationOriginalCase = null;
    }

    public void initDisputeUnpairedList() {
        Map<String, Object> params = new HashMap<String, Object>();
        try {
            unpairedDisputeOperations = disputesDao.getDisputeUnpairedOperations(userSessionId, params);
        } catch (UserException e) {
            throw new IllegalStateException(e);
        }
    }

    public void getDefaultManualApplication() {
        Map<String, Object> params = new HashMap<String, Object>();
        try {
            DspApplication dspApp = disputesDao.getDefaultManualApplication(userSessionId, params);
            manualCaseCreation.setApplId(dspApp.getId());
            manualCaseCreation.setCreatedDate(dspApp.getCreated());
            manualCaseCreation.setCaseId(dspApp.getCaseId());
            manualCaseCreation.setCaseSource(DSCS0001);
            manualCaseCreation.setCaseResolution(dspApp.getRejectCode());
            manualCaseCreation.setCaseStatus(dspApp.getCaseStatus());
            manualCaseCreation.setCaseState(FacesUtils.getMessage(BUNDLE, dspApp.getVisible() ? "visible" : "hidden"));
            manualCaseCreation.setTeamId(dspApp.getTeamId());

            manualCaseCreation.setCreatedByUserId(dspApp.getUserId().longValue());
            manualCaseCreation.setCreatedByUserName(dspApp.getUserName());
            if (StringUtils.isEmpty(manualCaseCreation.getCreatedByUserName())) {
                try {
                    User user = usersDao.getUserById(userSessionId, manualCaseCreation.getCreatedByUserId());
                    manualCaseCreation.setCreatedByUserName(user.getPerson().getFullName());
                } catch (Exception e) {
                    logger.debug("Unable to get user information", e);
                }
            }

            manualCaseCreation.setOwner(dspApp.getCaseOwner());
            manualCaseCreation.setOwnerName(dspApp.getCaseOwnerName());
            if (StringUtils.isEmpty(manualCaseCreation.getOwnerName())) {
                try {
                    User user = usersDao.getUserById(userSessionId, Long.valueOf(manualCaseCreation.getOwner()));
                    manualCaseCreation.setOwnerName(user.getPerson().getFullName());
                } catch (Exception e) {
                    logger.debug("Unable to get owner information", e);
                }
            }

            if (activeDspApplication != null && activeDspApplication.size() == 1) {
                if (activeDspApplication.get(0).getFlowId() == ApplicationFlows.DSP_INVESTIGATION) {
                    manualCaseCreation.setClaimId(activeDspApplication.get(0).getId());
                    manualCaseCreation.setAgentId(activeDspApplication.get(0).getAgentId());
                    manualCaseCreation.setAgentNumber(activeDspApplication.get(0).getAgentNumber());
                    manualCaseCreation.setAgentName(activeDspApplication.get(0).getAgentName());
                    manualCaseCreation.setCardNumber(activeDspApplication.get(0).getCardNumber());
                    manualCaseCreation.setInstId(activeDspApplication.get(0).getInstId().longValue());

                    manualCaseCreation.setOperAmount(activeDspApplication.get(0).getAmount());
                    manualCaseCreation.setOperCurrency(activeDspApplication.get(0).getCurrency());
                    manualCaseCreation.setOperDate(activeDspApplication.get(0).getOperDate());

                    manualCaseCreation.setDisputedAmount(activeDspApplication.get(0).getDisputedAmount());
                    manualCaseCreation.setDisputedCurrency(activeDspApplication.get(0).getDisputedCurrency());
                    manualCaseCreation.setDisputeReason(activeDspApplication.get(0).getDisputeReason());
                }
            }
        } catch (UserException e) {
            throw new IllegalStateException(e);
        }
    }

    private void clearCheckDuteDateCache() {
        disputeAction = null;
        reasonCode = null;
        dueDate = null;
    }

    public void clearSetDueDateCache() {
       newDueDate = null;
    }

    public void callChargebackLovId() {
        if (activeDspApplication != null && activeDspApplication.size() == 1) {
            try {
                clearCheckDuteDateCache();
                chargebackLovId = disputesDao.getDueDateLov(userSessionId,
                                                            activeDspApplication.get(0).getId(),
                                                            activeDspApplication.get(0).getFlowId());
            } catch (Exception e) {
                throw new IllegalStateException(e);
            }
        }
    }

    public List<SelectItem> getReasonCodes() {
        if (activeDspApplication != null && activeDspApplication.size() > 0) {
            Integer lovId = disputesDao.getReasonLovId(userSessionId, activeDspApplication.get(0));
            if (lovId != null) {
                return getDictUtils().getLov(lovId);
            }
        }
        return new ArrayList<SelectItem>();
    }

    public List<ApplicationComment> getCommentsByApplication(Long applicationId, String lang) {
        Map<String, Object> map = new HashMap<String, Object>();
        map.put("applicationId", applicationId);
        map.put("lang", lang);
        try {
            return disputesDao.getCommentsByApplication(userSessionId, map);
        } catch (Exception e) {
            throw new IllegalStateException(e);
        }
    }

    public List<ApplicationComment> getCommentsTable() {
        List<ApplicationComment> comments = new ArrayList<ApplicationComment>(0);
        if (activeDspApplication != null) {
            for (DspApplication dspApp : activeDspApplication) {
                if(dspApp.getId() != null) {
                    comments.addAll(getCommentsByApplication(dspApp.getId(), userLang));
                }
            }
        }
        return comments;
    }

    public boolean isRejectCommentAvailable() {
        if(rejectReasonCode != null && !rejectReasonCode.isEmpty()) {
            if (!RFRA0004.equals(rejectReasonCode) &&
                !RFRA0005.equals(rejectReasonCode) &&
                !RFRA0006.equals(rejectReasonCode)) {
                return false;
            }
            return true;
        }
        return false;
    }

    public BigDecimal[] getIdTab() {
        return idTab;
    }
    public void setIdTab(BigDecimal[] idTab) {
        this.idTab = idTab;
    }

    public DisputeActionPermissions getActions() {
        return actions;
    }
    public void setActions(DisputeActionPermissions actions) {
        this.actions = actions;
    }

    private boolean isDueDateAlarm(DspApplication app) {
        DateFormat df = new SimpleDateFormat(((UserSession)ManagedBeanWrapper.getManagedBean("usession")).getFullDatePattern());
        Date date = null;

        if (StringUtils.isNotEmpty(dueDate)) {
            try {
                date = df.parse(dueDate);
            } catch (Exception e) {}
        }
        if (date == null) {
            date = app.getDueDate();
        }

        return (date != null) ? !date.after(new Date()) : false;
    }

    public boolean renderAttentionMessage(String component) {
        if (activeDspApplication != null && activeDspApplication.size() == 1) {
            if ("dueDateWarning".equals(component)) {
                return isDueDateAlarm(activeDspApplication.get(0));
            } else if ("chargebackWarning".equals(component)) {
                if (MessageTypes.MESSAGE_TYPE_CHARGEBACK.equals(disputeAction)) {
                    return !isDueDateAlarm(activeDspApplication.get(0));
                }
            } else if ("fraudWarning".equals(component)) {
                if (MessageTypes.MESSAGE_TYPE_FRAUD_REPORT.equals(disputeAction)) {
                    return !isDueDateAlarm(activeDspApplication.get(0));
                }
            }
        }
        return false;
    }

    public boolean showDueDateAlarm(Date date) {
        if (date != null) {
            try {
                Date currentDate = new Date();
                if (date.before(currentDate)) {
                    return true;
                }
                Long diff = (date.getTime() - currentDate.getTime()) / HOURS_IN_MILLIS;
                return (diff <= FIVE_DAYS_IN_HOURS);
            } catch (Exception e) {
                logger.debug("", e);
            }
        }
        return false;
    }

    public void changeTeam() {
        MbDspTeam team = (MbDspTeam)ManagedBeanWrapper.getManagedBean("MbDspTeam");
        team.setApplications(activeDspApplication);
        team.setTeamId(null);
    }

    public boolean isTakeButtonDisabled() {
        if (activeDspApplication != null) {
            for (DspApplication dspApp : activeDspApplication) {
                if (StringUtils.isNotEmpty(dspApp.getCaseOwner())) {
                    return true;
                }
            }
            return false;
        }
        return true;
    }

    public boolean isRefuseButtonDisabled() {
        if (filter != null && filter.getUserId() != null && activeDspApplication != null) {
            for (DspApplication dspApp : activeDspApplication) {
                if (dspApp.getCaseOwner() == null) {
                    return true;
                } else if (!filter.getUserId().equals(Integer.valueOf(dspApp.getCaseOwner()))) {
                    return true;
                }
            }
            return false;
        }
        return true;
    }

    public boolean isEditButtonDisabled() {
        if (activeDspApplication != null) {
            for (DspApplication dspApp : activeDspApplication) {
                if (ApplicationStatuses.READY_FOR_REVIEW.equals(dspApp.getStatus()) ||
                    ApplicationStatuses.ACCEPTED.equals(dspApp.getStatus()) ||
                    ApplicationStatuses.REJECTED.equals(dspApp.getStatus())) {
                    return true;
                }
            }
            return false;
        }
        return true;
    }

    public boolean isDeleteButtonDisabled() {
        if (activeDspApplication != null) {
            for (DspApplication dspApp : activeDspApplication) {
                if (ApplicationStatuses.READY_FOR_REVIEW.equals(dspApp.getStatus()) ||
                    ApplicationStatuses.ACCEPTED.equals(dspApp.getStatus()) ||
                    ApplicationStatuses.REJECTED.equals(dspApp.getStatus())) {
                    return true;
                }
            }
            return false;
        }
        return true;
    }

    public void initializeCaseProgress() {
        MbDspCaseProgress bean = (MbDspCaseProgress)ManagedBeanWrapper.getManagedBean("MbDspCaseProgress");
        if (bean != null) {
            if (activeDspApplication != null) {
                if (activeDspApplication.size() == 1) {
                    bean.setApplication(activeDspApplication.get(0));
                } else {
                    bean.setApplications(activeDspApplication);
                }
            }
            bean.clearFilter();
            bean.setMode(MbDspCaseProgress.BTN_CASE_PROGRESS);
        }
    }

    public void initializeReasonCode() {
        MbDspCaseProgress bean = (MbDspCaseProgress)ManagedBeanWrapper.getManagedBean("MbDspCaseProgress");
        if (bean != null) {
            if (activeDspApplication != null) {
                if (activeDspApplication.size() == 1) {
                    bean.setApplication(activeDspApplication.get(0));
                } else {
                    bean.setApplications(activeDspApplication);
                }
            }
            bean.clearFilter();
            bean.setMode(MbDspCaseProgress.BTN_REASON_CODE);
        }
    }

    public void initializeReassignCase() {
        MbDspReassignUser bean = (MbDspReassignUser)ManagedBeanWrapper.getManagedBean("MbDspReassignUser");
        if (bean != null) {
            if (activeDspApplication != null) {
                if (activeDspApplication.size() == 1) {
                    bean.setApplication(activeDspApplication.get(0));
                    bean.setReassignUser(activeDspApplication.get(0).getUserId());
                } else {
                    bean.setApplications(activeDspApplication);
                }
            }
            bean.clearFilter();
        }
    }

    public void initializeCaseComment() {
        MbDspStatus bean = (MbDspStatus)ManagedBeanWrapper.getManagedBean("MbDspStatus");
        if (bean != null) {
            bean.initialize(activeDspApplication, MbDspStatus.BTN_COMMENT);
            if (activeDspApplication.size() == 1) {
                bean.setStatus(activeDspApplication.get(0).getStatus());
                bean.setResolution(activeDspApplication.get(0).getRejectCode());
                bean.setSystemComment(null);
                bean.setUserComment(null);
            }
        }
    }

    public void initializeCaseResolution() {
        MbDspStatus bean = (MbDspStatus)ManagedBeanWrapper.getManagedBean("MbDspStatus");
        if (bean != null) {
            bean.initialize(activeDspApplication, MbDspStatus.BTN_RESOLUTION);
            if (activeDspApplication.size() == 1) {
                bean.setStatus(activeDspApplication.get(0).getStatus());
                bean.setResolution(activeDspApplication.get(0).getRejectCode());
                bean.setSystemComment(null);
                bean.setUserComment(null);
            }
        }
    }

    public void initializeCaseStatus() {
        MbDspStatus bean = (MbDspStatus)ManagedBeanWrapper.getManagedBean("MbDspStatus");
        if (bean != null) {
            bean.initialize(activeDspApplication, MbDspStatus.BTN_STATUS);
            if (activeDspApplication.size() == 1) {
                bean.setStatus(activeDspApplication.get(0).getStatus());
                bean.setResolution(activeDspApplication.get(0).getRejectCode());
                bean.setSystemComment(null);
                bean.setUserComment(null);
            }
        }
    }

    public void initializeCaseClose() {
        MbDspCloseReopen bean = (MbDspCloseReopen)ManagedBeanWrapper.getManagedBean("MbDspCloseReopen");
        if (bean != null) {
            bean.initialize(activeDspApplication, MbDspCloseReopen.BTN_CLOSE);
            bean.execute();
        }
    }

    public void initializeCaseReopen() {
        MbDspCloseReopen bean = (MbDspCloseReopen)ManagedBeanWrapper.getManagedBean("MbDspCloseReopen");
        if (bean != null) {
            bean.initialize(activeDspApplication, MbDspCloseReopen.BTN_REOPEN);
            bean.execute();
        }
    }

    public void initializeHide() {
        MbDspHideUnhide bean = (MbDspHideUnhide)ManagedBeanWrapper.getManagedBean("MbDspHideUnhide");
        if (bean != null) {
            bean.clearCache();
            bean.initialize(activeDspApplication, MbDspHideUnhide.BTN_HIDE);
        }
    }

    public void initializeUnhide() {
        MbDspHideUnhide bean = (MbDspHideUnhide)ManagedBeanWrapper.getManagedBean("MbDspHideUnhide");
        if (bean != null) {
            bean.initialize(activeDspApplication, MbDspHideUnhide.BTN_UNHIDE);
            bean.execute();
        }
    }

    public List<SelectItem> getTeams() {
        if (teams == null) {
            teams = getDictUtils().getLov(LovConstants.CSM_DISPUTE_TEAMS);
            if (teams == null) {
                teams = new ArrayList<SelectItem>();
            }
        }
        return teams;
    }

    public List<SelectItem> getCaseResolutions() {
        if (caseResolutions == null) {
            caseResolutions = getDictUtils().getLov(LovConstants.DISPUTE_APPLICATION_REJECT_CODE);
            if (caseResolutions == null) {
                caseResolutions = new ArrayList<SelectItem>();
            }
        }
        return caseResolutions;
    }

    private DspApplication getDspApplicationById(Long appId) {
        Filter[] filters = new Filter[4];
        filters[0] = new Filter("LANG", userLang);
        filters[1] = new Filter("TYPE", ApplicationConstants.TYPE_DISPUTES);
        filters[2] = new Filter("APPL_SUBTYPE", getModule());
        filters[3] = new Filter("APPL_ID", appId);
        SelectionParams params = new SelectionParams();
        params.setTable("DISPUTE");
        params.setFilters(filters);
        try {
            List<DspApplication> apps = applicationDao.getDspApplications(userSessionId, params);
            if (apps != null && apps.size() > 0) {
                return apps.get(0);
            }
        } catch (Exception e) {
            FacesUtils.addMessageError(e);
            logger.error("", e);
        }
        return null;
    }

    public Date getNewDueDate() {
        return newDueDate;
    }

    public void setNewDueDate(Date newDueDate) {
        this.newDueDate = newDueDate;
    }

    public boolean isButtonsDisabled() {
        boolean disabled = false;
        if (activeDspApplication != null && activeDspApplication.size() > 0) {
            Iterator<DspApplication> iter = activeDspApplication.iterator();
            while (iter.hasNext() && !disabled) {
                DspApplication app = iter.next();
	            disabled = (app.getCaseOwner() == null || app.getCaseOwner().trim().length() <= 0);
            }
        }
        return disabled;
    }

    public String getRejectReasonCode() {
        return rejectReasonCode;
    }

    public void setRejectReasonCode(String rejectReasonCode) {
        this.rejectReasonCode = rejectReasonCode;
    }

    public String getRejectComment() {
        return rejectComment;
    }

    public void setRejectComment(String rejectComment) {
        this.rejectComment = rejectComment;
    }

    public void updateComment(){
        if (!isRejectCommentAvailable()){
            rejectComment = null;
        }
    }

    public String getMerchantLocation() {
        if (activeDspApplication != null && activeDspApplication.size() == 1) {
            StringBuilder fullAddress = new StringBuilder();
            if (activeDspApplication.get(0).getMerchantPostCode() != null && activeDspApplication.get(0).getMerchantPostCode().length() > 0) {
                fullAddress.append(activeDspApplication.get(0).getMerchantPostCode());
            }
            if (activeDspApplication.get(0).getMerchantRegion() != null && activeDspApplication.get(0).getMerchantRegion().length() > 0) {
                if (fullAddress.length() > 0) {
                    fullAddress.append(", ");
                }
                fullAddress.append(activeDspApplication.get(0).getMerchantRegion());
            }
            if (activeDspApplication.get(0).getMerchantCity() != null && activeDspApplication.get(0).getMerchantCity().length() > 0) {
                if (fullAddress.length() > 0) {
                    fullAddress.append(", ");
                }
                fullAddress.append(activeDspApplication.get(0).getMerchantCity());
            }
            if (activeDspApplication.get(0).getMerchantStreet() != null && activeDspApplication.get(0).getMerchantStreet().length() > 0) {
                if (fullAddress.length() > 0) {
                    fullAddress.append(", ");
                }
                fullAddress.append(activeDspApplication.get(0).getMerchantStreet());
            }
            return fullAddress.toString();
        }
        return "";
    }

    public void refreshActiveDspApplications() {
    	if (activeDspApplication == null) {
    		return;
	    }
	    try {
		    for (DspApplication app: activeDspApplication) {
			    List<DspApplication> apps = applicationDao.getDspApplications(userSessionId, SelectionParams.build("APPL_ID", app.getId()));
			    if (apps != null && !apps.isEmpty()) {
				    dspApplicationSource.replaceObject(app, apps.get(0));
			    }
		    }
	    } catch(Exception e) {
		    FacesUtils.addMessageError(e);
		    logger.error("", e);
	    }
    }


    private MasterComTransactions findMasterComTransactions(MasterCom mc, Operation operation) throws Exception {
	    MasterComTransactionSearch mcTransactionSearch = new MasterComTransactionSearch();
	    mcTransactionSearch.setAcquirerRefNumber(operation.getNetworkRefnum());
	    if (StringUtils.isNotBlank(operation.getCardNumber())) {
		    mcTransactionSearch.setPrimaryAccountNum(operation.getCardNumber());
	    } else {
		    mcTransactionSearch.setPrimaryAccountNum(operationDao.getCardNumber(userSessionId, operation.getId()));
	    }

	    mcTransactionSearch.setTranStartDate(operation.getOperDate());
	    mcTransactionSearch.setTranEndDate(operation.getOperDate());

	    try {
		    MasterComTransactions transactions = mc.searchForTransaction(mcTransactionSearch);
		    if (transactions.getAuthorizationSummaryCount() == 0) {
			    throw new SystemException("MasterCom can't find transactions for this operation");
		    }
		    return transactions;
	    } catch (MasterComException e) {
	    	throw new SystemException("Error when searching operations in MasterCom", e);
	    }
    }

    private String createMasterComClaim(MasterCom mc, Operation operation, String clearingTransactionId, String authTransactionId) throws SystemException {
	    MasterComClaimCreate mcClaim = new MasterComClaimCreate();
	    mcClaim.setClearingTransactionId(clearingTransactionId);
	    mcClaim.setAuthTransactionId(authTransactionId);
	    mcClaim.setDisputedCurrency(operation.getOperCurrency());
	    mcClaim.setDisputedAmount(operation.getOperAmount());
	    mcClaim.setClaimType(MasterComClaimCreate.ClaimType.Standard);

	    try {
		    return mc.createClaim(mcClaim);
	    } catch(Exception e) {
		    throw new SystemException("Error when create claim in MasterCom", e);
	    }
    }

    private void fillMasterComParameters(Map<String, Object> params, Long operationId) throws Exception {
	    CaseNetworkContext context = new CaseNetworkContext();
	    context.setOperId(operationId);

	    if (disputesDao.isMasterComEnabled(userSessionId, context)) {
		    MasterCom mc = new MasterCom();
		    mc.requireValidHealth();

		    // TODO: replace this.operationId to this.operation
		    Operation operation = null;
		    for (Operation oper: getOperationOriginalCase().getActivePage()) {
			    if (operationId.equals(oper.getId())) {
				    operation = oper;
				    break;
			    }
		    }
		    if (operation == null) {
			    throw new SystemException("Can't find operation by id: " + operationId);
		    }

		    MasterComTransactions transactions = findMasterComTransactions(mc, operation);
		    String extAuthTransactionId = transactions.getAuthorizationSummary().get(0).getTransactionId();
		    String extClearingTransactionId = transactions.getAuthorizationSummary().get(0).getClearingSummary().get(0).getTransactionId();

		    String extClaimId = createMasterComClaim(mc, operation, extClearingTransactionId, extAuthTransactionId);
		    params.put("extAuthTransactionId", extAuthTransactionId);
		    params.put("extClearingTransactionId", extClearingTransactionId);
		    params.put("extClaimId", extClaimId);
	    }
    }
}
