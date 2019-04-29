package ru.bpc.sv2.ui.operations;

import java.math.BigDecimal;
import java.text.DateFormat;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Date;
import java.util.GregorianCalendar;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.TimeZone;
import java.util.Arrays;

import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.event.ValueChangeEvent;
import javax.faces.model.SelectItem;
import org.apache.commons.lang3.StringUtils;
import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;
import ru.bpc.sv2.common.CommonWizardStepInfo;
import ru.bpc.sv2.common.FlexFieldData;
import ru.bpc.sv2.constants.DatePatterns;
import ru.bpc.sv2.constants.DictNames;
import ru.bpc.sv2.constants.EntityNames;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.constants.ModuleNames;
import ru.bpc.sv2.constants.SectionIdConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.Filter.Operator;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.DisputesDao;
import ru.bpc.sv2.logic.LoyaltyDao;
import ru.bpc.sv2.logic.OperationDao;
import ru.bpc.sv2.loyalty.LoyaltyOperation;
import ru.bpc.sv2.loyalty.LoyaltyOperationRequest;
import ru.bpc.sv2.notes.ObjectNoteFilter;
import ru.bpc.sv2.operations.Operation;
import ru.bpc.sv2.operations.OperationPrivConstants;
import ru.bpc.sv2.operations.Participant;
import ru.bpc.sv2.operations.constants.OperationsConstants;
import ru.bpc.sv2.pmo.PmoPaymentOrder;
import ru.bpc.sv2.process.ProcessTrace;
import ru.bpc.sv2.products.Customer;
import ru.bpc.sv2.reports.RptDocument;
import ru.bpc.sv2.tags.Tag;
import ru.bpc.sv2.ui.acm.MbContextMenu;
import ru.bpc.sv2.ui.amounts.MbAdditionalAmounts;
import ru.bpc.sv2.ui.aup.MbTagValues;
import ru.bpc.sv2.ui.aut.MbAuthorizations;
import ru.bpc.sv2.ui.common.flexible.MbFlexFieldsDataSearch;
import ru.bpc.sv2.ui.common.wizard.MbCommonWizard;
import ru.bpc.sv2.ui.common.wizard.callcenter.MbOperTypeSelectionStep;
import ru.bpc.sv2.ui.context.ContextType;
import ru.bpc.sv2.ui.context.ContextTypeFactory;
import ru.bpc.sv2.ui.dsp.MbAssociatedOperations;
import ru.bpc.sv2.ui.events.MbStatusLogs;
import ru.bpc.sv2.ui.issuing.MbIssSelectObject;
import ru.bpc.sv2.ui.navigation.Menu;
import ru.bpc.sv2.ui.notes.MbNotesSearch;
import ru.bpc.sv2.ui.pmo.MbPmoPaymentOrdersDependent;
import ru.bpc.sv2.ui.products.MbCustomerSearchModal;
import ru.bpc.sv2.ui.trace.logging.MbTrace;
import ru.bpc.sv2.ui.utils.*;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.utils.UserException;
import util.auxil.ManagedBeanWrapper;

@ViewScoped
@ManagedBean (name = "MbOperations")
public class MbOperations extends AbstractBean {
    private static final long serialVersionUID = 1L;
    private static String COMPONENT_ID = "rulesTable";

    private OperationDao _operationDao = new OperationDao();
    private DisputesDao _disputesLocalDao = new DisputesDao();
    private LoyaltyDao loyaltyDao = new LoyaltyDao();

    private CountryUtils countryUtils;

    private Operation operationFilter;
    private RptDocument documentFilter;
    private Participant participantFilter;
    private PmoPaymentOrder pmoFilter;
    private Tag tagFilter;
    private Customer customerFilter;
    private ru.bpc.sv2.operations.incoming.Operation adjusmentFilter;
    private List<SelectItem> statusReasons;
    private Date hostDateFrom;
    private Date hostDateTo;
    private Date operDateFrom;
    private Date operDateTo;

    protected String tabName;
    private String authCode;
    private String rrn;
    private String arn;
    private Integer reversal;
    private boolean onlyUpdate;

    private MbEntriesForOperation entryBean;
	private List<SelectItem> operStatuses;
	private List<SelectItem> participantTypes;
	private List<SelectItem> pmoPurposes;
	private List<SelectItem> pmoStatuses;
	private List<SelectItem> documentTypes;
	private List<SelectItem> operTypes;
	private List<SelectItem> messageTypes;
	private List<SelectItem> settlementTypes;
	private List<SelectItem> acqSttlTypes;
	private List<SelectItem> issSttlTypes;
	private List<SelectItem> tagTypes;
	private List<SelectItem> yesNoLov;
	private List<SelectItem> mcc;
	private List<SelectItem> terminalType;

    private final DaoDataModel<Operation> _operationSource;
    private final TableRowSelection<Operation> _itemSelection;
    private Operation _activeOperation;
    private String timeZone;
    private String displayFormat;
    private String entryId;

    private final String ACQUIRING_BACKLINK = "acquiring|operations";
    private final String ISSUING_BACKLINK = "issuing|operations";
    private final String ROUTING_BACKLINK = "routing|operations";

    public static final String SEARCH_TAB_OPERATION = "operationsTab";
    public static final String SEARCH_TAB_DOCUMENT = "documentsTab";
    public static final String SEARCH_TAB_PARTICIPANT = "participantTab";
    public static final String SEARCH_TAB_PMO = "pmoSearchTab";
    public static final String SEARCH_TAB_CUSTOMER = "customerTab";
    public static final String SEARCH_TAB_TAG = "tag";
    public static final String SEARCH_TAB_DISPUTE = "disputeTab";

    private ru.bpc.sv2.operations.incoming.Operation newAdjusment;

    private String backLink;

    private String clientIdType;
    private String clientIdValue;
    private List<SelectItem> clientIdTypes;
    private List<SelectItem> acqInstBins;

    private static final Logger logger = Logger.getLogger("OPER_PROCESSING");

    private Long participantCustomerId;
    private String participantCustomerNumber;
    private String participantCustomerInfo;

    private String filterCustomerNumber;
    private String filterCustomerInfo;
    private String filterRecieverCustomerNumber;
    private String filterRecieverCustomerInfo;

    private ContextType ctxType;
    private String ctxItemEntityType;
    private String isspageLink = "issuing|operations";
    private String acqpageLink = "acquiring|operations";
    private boolean initHostDate;

    private String beanName;
    private String methodName;
    protected String rerenderList = "";

    protected String searchType;
    protected Map<String, Object> paramMap;
    protected MbOperationsSess sessBean;
    protected String operType;
    protected String searchTabName;

    private BigDecimal[] idTab;

    private boolean issuingType;
    private boolean acquiringType;
    private boolean h2hType;
    private LoyaltyOperation[] loyaltyOperations;

    private String searchButtonId;

    protected Long accountId;
    protected Integer accountSplitHash;
    protected String accountNumber;

    public MbOperations() {
        initHostDate = true;
        countryUtils = (CountryUtils) ManagedBeanWrapper.getManagedBean("CountryUtils");
        sessBean = (MbOperationsSess) ManagedBeanWrapper.getManagedBean("MbOperationsSess");
        displayFormat = "MMMM dd, yyyy";
        operationFilter = new Operation();
        rowsNum = 30;

        // set time zone for proper date output
        DateFormat df = DateFormat.getInstance();
        df.setCalendar(Calendar.getInstance());
        timeZone = df.getTimeZone().getID();

        _operationSource = new DaoDataListModel<Operation>(logger) {
            private static final long serialVersionUID = 1L;

            @Override
            protected List<Operation> loadDaoListData(SelectionParams params) {
                if (searching) {
                    try {
                        setFilters();
                        params.setFilters(filters.toArray(new Filter[filters.size()]));
                        paramMap.put("force_search", forceSearch);
                        paramMap.put("param_tab", filters.toArray(new Filter[filters.size()]));
                        paramMap.put("oper_id_tab", idTab);
                        return _operationDao.getOperationCursor(userSessionId, params, paramMap, getPrivName());
                    } catch (Exception e) {
                        setDataSize(0);
                        FacesUtils.addMessageError(e);
                        logger.error("", e);
                    } finally {
                        clearSearchSign();
                    }
                }
                return new ArrayList<Operation>();
            }

            @Override
            protected int loadDaoDataSize(SelectionParams params) {
                if (searching) {
                    int count = 0;
                    int threshold = 300;
                    try {
                        setFilters();
                        params.setFilters(filters.toArray(new Filter[filters.size()]));
                        paramMap.put("force_search", forceSearch);
                        paramMap.put("param_tab", filters.toArray(new Filter[filters.size()]));
                        params.setThreshold(threshold);
                        count = _operationDao.getOperationCursorCount(userSessionId, paramMap, getPrivName());
                        idTab  = (BigDecimal[])paramMap.get("oper_id_tab");
                    } catch (Exception e) {
                        FacesUtils.addMessageError(e);
                        logger.error("", e);
                    }
                    return count;
                }
                return 0;
            }
        };

        setSearchTabName(SEARCH_TAB_PARTICIPANT);
        setTabName("detailsTab");

        restoreBean = (Boolean) FacesUtils.getSessionMapValue(ACQUIRING_BACKLINK);
        if (restoreBean == null) {
            restoreBean = (Boolean) FacesUtils.getSessionMapValue(ISSUING_BACKLINK);
        }
        if (restoreBean == null) {
            restoreBean = (Boolean) FacesUtils.getSessionMapValue(ROUTING_BACKLINK);
        }

        if (restoreBean == null || !restoreBean) {
            clearBeans();
            restoreBean = Boolean.FALSE;
        } else {
            _activeOperation = sessBean.getActiveOperation();
            operType = sessBean.getOperType();
            operationFilter = sessBean.getFilter();
            pageNumber = sessBean.getPageNumber();
            rowsNum = sessBean.getRowsNum();
            tabName = sessBean.getTabName();
            hostDateFrom = sessBean.getHostDateFrom();
            hostDateTo = sessBean.getHostDateTo();
            entryId = sessBean.getEntryId();
            searching = true;

            FacesUtils.setSessionMapValue(ACQUIRING_BACKLINK, null);
            FacesUtils.setSessionMapValue(ISSUING_BACKLINK, null);
            FacesUtils.setSessionMapValue(ROUTING_BACKLINK, null);

            setBeans(true);
        }

        if (operType == null) {
            setOperType(getOperTypeFromRequest());
        }

        _itemSelection = new TableRowSelection<Operation>(null, _operationSource);
        restoreFilter();
    }

    private void clearSearchSign() {
        forceSearch = 0;
    }

    private void restoreFilter() {
        long start_time = System.currentTimeMillis();
        HashMap<String, Object> queueFilter = getQueueFilter("MbOperations");
        clearFilter();

        if (queueFilter == null) {
            return;
        }
        initHostDate = false;
        if (queueFilter.containsKey("id")) {
            getFilter().setId((Long) queueFilter.get("id"));
        }
        if (queueFilter.containsKey("terminalNumber")) {
            getFilter().setTerminalNumber((String) queueFilter.get("terminalNumber"));
        }
        if (queueFilter.containsKey("merchantNumber")) {
            getFilter().setMerchantNumber((String) queueFilter.get("merchantNumber"));
        }
        if (queueFilter.containsKey("merchantName")) {
            getFilter().setMerchantName((String) queueFilter.get("merchantName"));
        }
        if (queueFilter.containsKey("acqInstBin")) {
            getFilter().setAcqInstBin((String) queueFilter.get("acqInstBin"));
        }
        if (queueFilter.containsKey("instId")) {
            getParticipantFilter().setInstId((Integer) queueFilter.get("instId"));
        }
        if (queueFilter.containsKey("hostDateFrom")) {
            setHostDateFrom((Date) queueFilter.get("hostDateFrom"));
        }
        if (queueFilter.containsKey("operType")) {
            getFilter().setOperType((String) queueFilter.get("operType"));
        }
        if (queueFilter.containsKey("msgType")) {
            getFilter().setMsgType((String) queueFilter.get("msgType"));
        }
        if (queueFilter.containsKey("sttlType")) {
            getFilter().setSttlType((String) queueFilter.get("sttlType"));
        }
        if (queueFilter.containsKey("status")) {
            getFilter().setStatus((String) queueFilter.get("status"));
        }
        if (queueFilter.containsKey("reversal")) {
            reversal = (Boolean) queueFilter.get("reversal") ? 1 : 0;
        }
        if (queueFilter.containsKey("sessionId")) {
            getFilter().setSessionId((Long) queueFilter.get("sessionId"));
        }
        if (queueFilter.containsKey("backLink")) {
            backLink = (String) queueFilter.get("backLink");
        }
        searchByParticipant();
    }

    public DaoDataModel<Operation> getOperations() {
        return _operationSource;
    }

    public Operation getActiveOperation() {
        return _activeOperation;
    }

    public void setActiveOperation(Operation activeOperation) {
        _activeOperation = activeOperation;
    }

    public SimpleSelection getItemSelection() {
        try {
            if (_activeOperation == null && _operationSource.getRowCount() > 0) {
                setFirstRowActive();
            } else if (_activeOperation != null && _operationSource.getRowCount() > 0) {
                SimpleSelection selection = new SimpleSelection();
                selection.addKey(_activeOperation.getModelId());
                _itemSelection.setWrappedSelection(selection);
                _activeOperation = _itemSelection.getSingleSelection();
                curLang = userLang;
            }
        } catch (Exception e) {
            logger.error("", e);
            FacesUtils.addErrorExceptionMessage(e);
        }
        return _itemSelection.getWrappedSelection();
    }

    public void setItemSelection(SimpleSelection selection) {
        _itemSelection.setWrappedSelection(selection);
        _activeOperation = _itemSelection.getSingleSelection();
        if (_activeOperation != null) {
            curLang = userLang;
            setBeans(false);
        }

    }

    public void setFirstRowActive() {
        if (_activeOperation == null && _operationSource.getRowCount() > 0) {
            _operationSource.setRowIndex(0);
            SimpleSelection selection = new SimpleSelection();
            _activeOperation = (Operation) _operationSource.getRowData();
            selection.addKey(_activeOperation.getModelId());
            _itemSelection.setWrappedSelection(selection);
            if (_activeOperation != null) {
                curLang = userLang;
                setBeans(false);
            }
        }
    }

    /**
     * Sets data for backing beans used by dependent pages
     */
    public void setBeans(boolean restoreState) {
        if (!restoreState) {
            sessBean.setActiveOperation(_activeOperation);
            sessBean.setOperType(operType);
            sessBean.setFilter(operationFilter);
            sessBean.setPageNumber(pageNumber);
            sessBean.setRowsNum(rowsNum);
            sessBean.setTabName(tabName);
            sessBean.setHostDateFrom(hostDateFrom);
            sessBean.setHostDateTo(hostDateTo);
            sessBean.setEntryId(entryId);
        }

        loadOperTabs(restoreState);
    }

    public void loadOperTabs() {
        loadOperTabs(false);
    }

    public void loadOperTabs(boolean restoreState) {
        if (_activeOperation != null) {
            if ("accTab".equals(tabName)) {
                entryBean = ManagedBeanWrapper
                        .getManagedBean(MbEntriesForOperation.class);
                entryBean.clearFilter();
                entryBean.setOperationId(_activeOperation.getId());
                entryBean.setEntityType(EntityNames.OPERATION);
                entryBean.setBackLink(thisBackLink);
                entryBean.search();
                if (restoreState) {
                    entryBean.restoreState();
                }
            } else if ("paymentOrdersTab".equals(tabName)) {
                MbPmoPaymentOrdersDependent orderBean = ManagedBeanWrapper
                        .getManagedBean(MbPmoPaymentOrdersDependent.class);
                orderBean.getOrder(_activeOperation.getPaymentOrderId());
            } else if ("traceTab".equals(tabName)) {
                MbTrace traceBean = ManagedBeanWrapper.getManagedBean(MbTrace.class);
                traceBean.clearBean();
                ProcessTrace filterTrace = new ProcessTrace();
                filterTrace.setEntityType(EntityNames.OPERATION);
                filterTrace.setObjectId(_activeOperation.getId());
                traceBean.setFilter(filterTrace);
                traceBean.search();
            } else if ("tagsTab".equals(tabName)) {
                MbTagValues tagValues = ManagedBeanWrapper.getManagedBean(MbTagValues.class);
                tagValues.clearFilter();
                tagValues.getFilter().setAuthId(_activeOperation.getId());
                tagValues.search();
            } else if ("authTab".equals(tabName)) {
                MbAuthorizations authBean = ManagedBeanWrapper
                        .getManagedBean(MbAuthorizations.class);
                authBean.loadAuthorization(_activeOperation.getId());
            } else if ("partTab".equals(tabName)) {
                MbParticipants partBean = ManagedBeanWrapper
                        .getManagedBean(MbParticipants.class);
                partBean.loadParticipantsForOperation(_activeOperation.getId());
            } else if ("messagesTab".equals(tabName)) {
                MbTechnicalMessages techMessages =
                        (MbTechnicalMessages) ManagedBeanWrapper.getManagedBean("mbTechnicalMessages");
                techMessages.clearFilter();
                techMessages.getFilter().setOperId(_activeOperation.getId());
                techMessages.search();
            } else if ("disputesTab".equals(tabName)) {
                MbAssociatedOperations assOperBean = (MbAssociatedOperations) ManagedBeanWrapper
                        .getManagedBean("mbAssociatedOperations");
                assOperBean.clearFilter();
                assOperBean.setOperId(_activeOperation.getId());
                assOperBean.setDisputeId(_activeOperation.getDisputeId());
                assOperBean.setCardMask(_activeOperation.getCardMask());
                assOperBean.setCardNumber(_activeOperation.getCardNumber());
                assOperBean.search();
            } else if ("additionalAmountsTab".equals(tabName)) {
                MbAdditionalAmounts amountBean = ManagedBeanWrapper
                        .getManagedBean(MbAdditionalAmounts.class);
                amountBean.loadAmounts(_activeOperation.getId());
            } else if ("flexibleFieldsTab".equals(tabName)) {
                MbFlexFieldsDataSearch flexible = (MbFlexFieldsDataSearch) ManagedBeanWrapper
                        .getManagedBean("MbFlexFieldsDataSearch");
                FlexFieldData filterFlex = new FlexFieldData();
                filterFlex.setInstId(isIssOperation() ? _activeOperation.getIssInstId() : _activeOperation.getAcqInstId());
                filterFlex.setEntityType(EntityNames.OPERATION);
                filterFlex.setObjectId(_activeOperation.getId());
                flexible.setFilter(filterFlex);
                flexible.search();
            } else if ("notesTab".equals(tabName)) {
                MbNotesSearch notesSearch = (MbNotesSearch) ManagedBeanWrapper
                        .getManagedBean("MbNotesSearch");
                ObjectNoteFilter filterNote = new ObjectNoteFilter();
                filterNote.setEntityType(EntityNames.OPERATION);
                filterNote.setObjectId(_activeOperation.getId());
                notesSearch.setFilter(filterNote);
                notesSearch.search();
            } else if ("statusLogsTab".equalsIgnoreCase(tabName)) {
                MbStatusLogs statusLogs = (MbStatusLogs) ManagedBeanWrapper
                        .getManagedBean("MbStatusLogs");
                statusLogs.clearFilter();
                statusLogs.getFilter().setObjectId(_activeOperation.getId());
                statusLogs.getFilter().setEntityType(EntityNames.OPERATION);
                statusLogs.search();
            } else if ("posBatchTab".equals(tabName)) {
                MbPosBatchBottomSearch posBatch = ManagedBeanWrapper
                        .getManagedBean(MbPosBatchBottomSearch.class);
                posBatch.getOrder(_activeOperation.getId());
            } else if ("operationStagesTab".equals(tabName)) {
                MbOperationStages operationStages = ManagedBeanWrapper
                        .getManagedBean(MbOperationStages.class);
                operationStages.clearFilter();
                operationStages.getFilter().setOperId(_activeOperation.getId());
                operationStages.search();
            }
        }
    }

    public void clearBeans() {
        entryBean = (MbEntriesForOperation) ManagedBeanWrapper
                .getManagedBean("MbEntriesForOperation");
        entryBean.clearFilter();

        MbTrace traceBean = (MbTrace) ManagedBeanWrapper.getManagedBean("MbTrace");
        traceBean.clearFilter();

        MbPmoPaymentOrdersDependent orderBean = (MbPmoPaymentOrdersDependent) ManagedBeanWrapper
                .getManagedBean("MbPmoPaymentOrdersDependent");
        orderBean.clearFilter();

        MbTagValues tagValues = (MbTagValues) ManagedBeanWrapper.getManagedBean("MbTagValues");
        tagValues.clearFilter();

        MbAuthorizations authBean = (MbAuthorizations) ManagedBeanWrapper
                .getManagedBean("MbAuthorizations");
        authBean.clearFilter();

        MbParticipants partBean = (MbParticipants) ManagedBeanWrapper
                .getManagedBean("MbParticipants");
        partBean.clearFilter();

        MbTechnicalMessages techMessages =
                (MbTechnicalMessages) ManagedBeanWrapper.getManagedBean("mbTechnicalMessages");
        techMessages.clearFilter();

        MbAssociatedOperations associateOper = (MbAssociatedOperations) ManagedBeanWrapper
                .getManagedBean("mbAssociatedOperations");
        associateOper.clearFilter();

        MbAdditionalAmounts amountBean = (MbAdditionalAmounts) ManagedBeanWrapper
                .getManagedBean("MbAdditionalAmounts");
        amountBean.clearFilter();

        MbNotesSearch notesBean = (MbNotesSearch) ManagedBeanWrapper
                .getManagedBean("MbNotesSearch");
        notesBean.clearFilter();

        MbOperationStages stagesBean = (MbOperationStages) ManagedBeanWrapper
                .getManagedBean("MbOperationStages");
        stagesBean.clearFilter();

    }

    /**
     * By default makes search using <code>operationFilter</code> and
     * <code>participantFilter</code>, but if <code>searchType</code> was set
     * before then search will be done according to it.
     */

    protected void toSetForceSearch() {
        forceSearch = 1;
    }

    public void clearFilter() {
        curLang = userLang;
        operationFilter = new Operation();
        hostDateFrom = null;
        hostDateTo = null;
        operDateFrom = null;
        operDateTo = null;
        documentFilter = new RptDocument();
        participantFilter = new Participant();
        pmoFilter = new PmoPaymentOrder();
        tagFilter = new Tag();
        customerFilter = new Customer();
        participantCustomerId = null;
        participantCustomerInfo = null;
        participantCustomerNumber = null;
        filterCustomerNumber = null;
        filterCustomerInfo = null;
        filterRecieverCustomerNumber = null;
        filterRecieverCustomerInfo = null;
        rrn = null;
        arn = null;
        authCode = null;
        reversal = null;

        clearState();
    }

    public void clearState() {
        if (_itemSelection != null) {
            _itemSelection.clearSelection();
        }
        _activeOperation = null;
        _operationSource.flushCache();
        searching = false;
        clearBeans();
    }

    public void resetBean() {
    }

    public Operation getFilter() {
        if (Boolean.TRUE.equals(FacesUtils.getSessionMapValue("initFromContext"))) {
            initFilterFromContext();
            backLink = (String) FacesUtils.getSessionMapValue("backLink");

	        if (FacesUtils.getSessionMapValue("operType") != null) {
		        setOperType((String) FacesUtils.extractSessionMapValue("operType"));
	        }

            search();
            FacesUtils.setSessionMapValue("initFromContext", null);
        }

        if (operationFilter == null) {
            operationFilter = new Operation();
        }
        return operationFilter;
    }

    public void setFilter(Operation operationFilter) {
        this.operationFilter = operationFilter;
    }

    public RptDocument getDocumentFilter() {
        if (documentFilter == null) {
            documentFilter = new RptDocument();
        }
        return documentFilter;
    }

    public void setDocumentFilter(RptDocument documentFilter) {
        this.documentFilter = documentFilter;
    }

    public Participant getParticipantFilter() {
        if (participantFilter == null) {
            participantFilter = new Participant();
        }
        return participantFilter;
    }

    public void setParticipantFilter(Participant participantFilter) {
        this.participantFilter = participantFilter;
    }

    public PmoPaymentOrder getPmoFilter() {
        if (pmoFilter == null) {
            pmoFilter = new PmoPaymentOrder();
        }
        return pmoFilter;
    }

    public void setPmoFilter(PmoPaymentOrder pmoFilter) {
        this.pmoFilter = pmoFilter;
    }

    public Tag getTagFilter() {
        if (tagFilter == null) {
            tagFilter = new Tag();
        }
        return tagFilter;
    }

    public void setTagFilter(Tag tagFilter) {
        this.tagFilter = tagFilter;
    }

    public Customer getCustomerFilter() {
        if (customerFilter == null) {
            customerFilter = new Customer();
        }
        return customerFilter;
    }

    public void setCustomerFilter(Customer customerFilter) {
        this.customerFilter = customerFilter;
    }

    public void add() {
    }

    public void edit() {
    }

    public void save() {
    }

    public void delete() {
    }

    public void close() {

    }

    public ArrayList<SelectItem> getAllAccountTypes() {
        return getDictUtils().getArticles(DictNames.ACCOUNT_TYPE, true, false);
    }

    public String getTimeZone() {
        return timeZone;
    }

    public void setTimeZone(String timeZone) {
        this.timeZone = timeZone;
    }

    public Date getHostDateFrom() {
        if (hostDateFrom == null && initHostDate) {
            Calendar calendar = new GregorianCalendar();
            calendar.set(Calendar.HOUR_OF_DAY, 0);
            calendar.set(Calendar.MINUTE, 0);
            calendar.set(Calendar.SECOND, 0);
            calendar.set(Calendar.MILLISECOND, 0);
            hostDateFrom = new Date(calendar.getTimeInMillis());
        }
        return hostDateFrom;
    }

    public void setHostDateFrom(Date hostDateFrom) {
        this.hostDateFrom = hostDateFrom;
    }

    public Date getHostDateTo() {
        return hostDateTo;
    }

    public void setHostDateTo(Date hostDateTo) {
        this.hostDateTo = hostDateTo;
    }

    public Date getOperDateFrom() {
        return operDateFrom;
    }

    public void setOperDateFrom(Date operDateFrom) {
        this.operDateFrom = operDateFrom;
    }

    public Date getOperDateTo() {
        return operDateTo;
    }

    public void setOperDateTo(Date operDateTo) {
        this.operDateTo = operDateTo;
    }

    public String getDisplayFormat() {
        return displayFormat;
    }

    public void setDisplayFormat(String displayFormat) {
        this.displayFormat = displayFormat;
    }

    public String getMerchantLocation() {
        if (_activeOperation != null) {
            StringBuilder fullAddress = new StringBuilder();
            String countryName = null;
            countryName = countryUtils.getCountryNamesMap().get(_activeOperation.getMerchantCountry());
            if (countryName != null && countryName.length() > 0) {
                fullAddress.append(countryName);
            }
            if (_activeOperation.getMerchantPostCode() != null && _activeOperation.getMerchantPostCode().length() > 0) {
                if (fullAddress.length() > 0) {
                    fullAddress.append(", ");
                }
                fullAddress.append(_activeOperation.getMerchantPostCode());
            }
            if (_activeOperation.getMerchantRegion() != null && _activeOperation.getMerchantRegion().length() > 0) {
                if (fullAddress.length() > 0) {
                    fullAddress.append(", ");
                }
                fullAddress.append(_activeOperation.getMerchantRegion());
            }
            if (_activeOperation.getMerchantCity() != null && _activeOperation.getMerchantCity().length() > 0) {
                if (fullAddress.length() > 0) {
                    fullAddress.append(", ");
                }
                fullAddress.append(_activeOperation.getMerchantCity());
            }
            if (_activeOperation.getMerchantStreet() != null && _activeOperation.getMerchantStreet().length() > 0) {
                if (fullAddress.length() > 0) {
                    fullAddress.append(", ");
                }
                fullAddress.append(_activeOperation.getMerchantStreet());
            }
            return fullAddress.toString();
        }
        return "";
    }

    public String getCountry() {
        if (_activeOperation != null) {
            return countryUtils.getCountryNamesMap().get(
                    _activeOperation.getMerchantCountry());
        } else {
            return null;
        }
    }

    public void addAdjusment() {
        ru.bpc.sv2.operations.incoming.Operation filter = getAdjusmentFilter();
        newAdjusment = new ru.bpc.sv2.operations.incoming.Operation();
        newAdjusment.setMsgType(OperationsConstants.MESSAGE_TYPE_PRESENTMENT);
        newAdjusment.setOperationDate(new Date());
        newAdjusment.setSourceHostDate(new Date());
        newAdjusment.setAccountNumber(filter.getAccountNumber());
        newAdjusment.setAcqInstId(filter.getAcqInstId());
        newAdjusment.setIssInstId(filter.getAcqInstId());
        newAdjusment.setSplitHash(filter.getSplitHash());
        newAdjusment.setOperationCurrency(filter.getOperationCurrency());

        newAdjusment.setSessionId(userSessionId);
        newAdjusment.setStatus(OperationsConstants.OPERATION_STATUS_PROCESS_READY);
        newAdjusment.setSttlType(OperationsConstants.SETTLEMENT_INTERNAL_INTRAINST);
        curMode = NEW_MODE;
    }

    public void saveAdjusment() {
        try {
            if (isNewMode()) {
                _operationDao.addAdjusment(userSessionId, newAdjusment);
            }
            _operationSource.flushCache();
            curMode = VIEW_MODE;
        } catch (Exception e) {
            FacesUtils.addMessageError(e);
            logger.error("", e);
        }
    }

    public void cancelAdjusment() {
        curMode = VIEW_MODE;
    }

    public ru.bpc.sv2.operations.incoming.Operation getNewAdjusment() {
        if (newAdjusment == null) {
            newAdjusment = new ru.bpc.sv2.operations.incoming.Operation();
        }
        return newAdjusment;
    }

    public void setNewAdjusment(ru.bpc.sv2.operations.incoming.Operation newAdjusment) {
        this.newAdjusment = newAdjusment;
    }

    public List<SelectItem> getOperationTypesAdjusment() {
        return getDictUtils().getLov(LovConstants.OPERATION_TYPES_ADJUSMENT);
    }

    public ru.bpc.sv2.operations.incoming.Operation getAdjusmentFilter() {
        if (adjusmentFilter == null) {
            adjusmentFilter = new ru.bpc.sv2.operations.incoming.Operation();
        }
        return adjusmentFilter;
    }

    public void setAdjusmentFilter(ru.bpc.sv2.operations.incoming.Operation adjusmentFilter) {
        this.adjusmentFilter = adjusmentFilter;
    }

    public String gotoCards() {
        return "";
    }

    public ArrayList<SelectItem> getInstitutions() {
        List<SelectItem> institutions = getDictUtils().getLov(LovConstants.INSTITUTIONS);

        if (institutions == null) {
            institutions = new ArrayList<SelectItem>();
        }
        return (ArrayList<SelectItem>) institutions;
    }

    public String getTabName() {
        return tabName;
    }

    public void setTabName(String tabName) {
        this.tabName = tabName;
        sessBean.setTabName(tabName);

        if (tabName.equalsIgnoreCase("accTab")) {
            MbEntriesForOperation bean = (MbEntriesForOperation) ManagedBeanWrapper
                    .getManagedBean("MbEntriesForOperation");
            bean.setTabName(tabName);
            bean.setParentSectionId(getSectionId());
            bean.setTableState(getSateFromDB(bean.getComponentId()));
        } else if (tabName.equalsIgnoreCase("traceTab")) {
            MbTrace bean = (MbTrace) ManagedBeanWrapper
                    .getManagedBean("MbTrace");
            bean.setTabName(tabName);
            bean.setParentSectionId(getSectionId());
            bean.setTableState(getSateFromDB(bean.getComponentId()));
        } else if (tabName.equalsIgnoreCase("tagsTab")) {
            MbTagValues bean = (MbTagValues) ManagedBeanWrapper
                    .getManagedBean("MbTagValues");
            bean.setTabName(tabName);
            bean.setParentSectionId(getSectionId());
            bean.setTableState(getSateFromDB(bean.getComponentId()));
        } else if (tabName.equalsIgnoreCase("messagesTab")) {
            MbTechnicalMessageDetails bean = (MbTechnicalMessageDetails) ManagedBeanWrapper
                    .getManagedBean("mbTechnicalMessageDetails");
            bean.setTabName(tabName);
            bean.setParentSectionId(getSectionId());
            bean.setTableState(getSateFromDB(bean.getComponentId()));
        } else if (tabName.equalsIgnoreCase("additionalAmountsTab")) {
            MbAdditionalAmounts bean = (MbAdditionalAmounts) ManagedBeanWrapper
                    .getManagedBean("MbAdditionalAmounts");
            bean.setTabName(tabName);
            bean.setParentSectionId(getSectionId());
            bean.setTableState(getSateFromDB(bean.getComponentId()));

        } else if (tabName.equalsIgnoreCase("notesTab")) {
            MbNotesSearch bean = (MbNotesSearch) ManagedBeanWrapper
                    .getManagedBean("MbNotesSearch");
            bean.setTabName(tabName);
            bean.setParentSectionId(getSectionId());
            bean.setTableState(getSateFromDB(bean.getComponentId()));
        } else if (tabName.equalsIgnoreCase("statusLogsTab")) {
            MbStatusLogs search = (MbStatusLogs) ManagedBeanWrapper
                    .getManagedBean("MbStatusLogs");
            search.setTabName(tabName);
            search.setParentSectionId(getSectionId());
            search.setTableState(getSateFromDB(search.getComponentId()));
        } else if (tabName.equalsIgnoreCase("operationStagesTab")) {
            MbOperationStages search = (MbOperationStages) ManagedBeanWrapper
                    .getManagedBean("MbOperationStages");
            search.setTabName(tabName);
            search.setParentSectionId(getSectionId());
            search.setTableState(getSateFromDB(search.getComponentId()));
        }
    }

    public String getSectionId() {
        if (ModuleNames.ACQUIRING.equals(operType)) {
            return SectionIdConstants.ACQUIRING_OPERATION;
        } else if (ModuleNames.ISSUING.equals(operType)) {
            return SectionIdConstants.ISSUING_OPERATION;
        } else {
            return SectionIdConstants.ROUTING_OPERATION;
        }
    }

    public String getComponentId() {
        if (ModuleNames.ACQUIRING.equals(operType)) {
            return "1018:" + COMPONENT_ID;
        } else if (ModuleNames.ISSUING.equals(operType)) {
            return "1008:" + COMPONENT_ID;
        } else if (ModuleNames.HOST_TO_HOST.equals(operType)) {
            return "2448:" + COMPONENT_ID;
        }
        return COMPONENT_ID;
    }

    @Override
    protected void applySectionFilter(Integer filterId) {
        try {
            FilterFactory factory = (FilterFactory) ManagedBeanWrapper.getManagedBean("filterFactory");
            Map<String, String> filterRec = factory.getSectionFilterRecs(filterId);
            sectionFilter = factory.getUserSectionFiltersObjects().get(filterId);
            if (filterRec != null) {
                operationFilter = new Operation();
                setFilterForm(filterRec);
                if (searchAutomatically) {
                    search();
                }
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
            operationFilter = getFilter();
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

	private void setFilterSttlType() {
		if (getSettlementTypes() != null && !getSettlementTypes().isEmpty()) {
			StringBuilder sb = new StringBuilder();
			for (int i = 0; i < getSettlementTypes().size() - 1; i++) {
				sb.append(getSettlementTypes().get(i).getValue().toString() + "','");
			}
			sb.append(getSettlementTypes().get(getSettlementTypes().size() - 1).getValue().toString());
			filters.add(new Filter("STTL_TYPES", sb.toString()));
		}
	}

    private void setFilterForm(Map<String, String> filterRec) throws ParseException {
        getFilter();
        filters = new ArrayList<Filter>();
        if (filterRec.get("hostDateFrom") != null) {
            SimpleDateFormat df = new SimpleDateFormat(DatePatterns.DATE_PATTERN);
            setHostDateFrom(df.parse(filterRec.get("hostDateFrom")));
        }
        if (filterRec.get("hostDateTo") != null) {
            SimpleDateFormat df = new SimpleDateFormat(DatePatterns.DATE_PATTERN);
            setHostDateTo(df.parse(filterRec.get("hostDateTo")));
        }
        if (filterRec.get("operId") != null) {
            operationFilter.setId(Long.valueOf(filterRec.get("operId")));
        }
        if (filterRec.get("terminalNumber") != null) {
            operationFilter.setTerminalNumber(filterRec.get("terminalNumber"));
        }
        if (filterRec.get("merchantNumber") != null) {
            operationFilter.setMerchantNumber(filterRec.get("merchantNumber"));
        }
        if (filterRec.get("merchantName") != null) {
            operationFilter.setMerchantName(filterRec.get("merchantName"));
        }
        if (filterRec.get("acqInstBin") != null) {
            operationFilter.setAcqInstBin(filterRec.get("acqInstBin"));
        }
        if (filterRec.get("status") != null) {
            operationFilter.setStatus(filterRec.get("status"));
        }
        if (filterRec.get("operType") != null) {
            operationFilter.setOperType(filterRec.get("operType"));
        }
        if (filterRec.get("statusReason") != null) {
            operationFilter.setStatusReason(filterRec.get("statusReason"));
        }
        if (filterRec.get("sessionId") != null) {
            operationFilter.setSessionId(Long.valueOf(filterRec.get("sessionId")));
        }
        if (filterRec.get("msgType") != null) {
            operationFilter.setMsgType(filterRec.get("msgType"));
        }
        if (filterRec.get("rrn") != null) {
            setRrn(filterRec.get("rrn"));
        }
        if (filterRec.get("arn") != null) {
            setArn(filterRec.get("arn"));
        }
        if (filterRec.get("sttlType") != null) {
            operationFilter.setSttlType(filterRec.get("sttlType"));
        }
        if (filterRec.get("authCode") != null) {
            setAuthCode(filterRec.get("authCode"));
        }
        if (filterRec.get("operDateFrom") != null) {
            SimpleDateFormat df = new SimpleDateFormat(DatePatterns.DATE_PATTERN);
            setOperDateFrom(df.parse(filterRec.get("operDateFrom")));
        }
        if (filterRec.get("operDateTo") != null) {
            SimpleDateFormat df = new SimpleDateFormat(DatePatterns.DATE_PATTERN);
            setOperDateTo(df.parse(filterRec.get("operDateTo")));
        }
    }

    private void setFilterRec(Map<String, String> filterRec) {
        if (getHostDateFrom() != null) {
            SimpleDateFormat df = new SimpleDateFormat(DatePatterns.DATE_PATTERN);
            filterRec.put("hostDateFrom", df.format(getHostDateFrom()));
        }
        if (getHostDateTo() != null) {
            SimpleDateFormat df = new SimpleDateFormat(DatePatterns.DATE_PATTERN);
            filterRec.put("hostDateTo", df.format(getHostDateTo()));
        }
        if (operationFilter.getId() != null) {
            filterRec.put("operId", operationFilter.getId().toString());
        }
        if (operationFilter.getTerminalNumber() != null) {
            filterRec.put("terminalNumber", operationFilter.getTerminalNumber());
        }
        if (operationFilter.getMerchantNumber() != null) {
            filterRec.put("merchantNumber", operationFilter.getMerchantNumber());
        }
        if (operationFilter.getMerchantName() != null) {
            filterRec.put("merchantName", operationFilter.getMerchantName());
        }
        if (operationFilter.getAcqInstBin() != null) {
            filterRec.put("acqInstBin", operationFilter.getAcqInstBin());
        }
        if (operationFilter.getStatus() != null) {
            filterRec.put("status", operationFilter.getStatus());
        }
        if (operationFilter.getOperType() != null) {
            filterRec.put("operType", operationFilter.getOperType());
        }
        if (operationFilter.getStatusReason() != null) {
            filterRec.put("statusReason", operationFilter.getStatusReason());
        }
        if (operationFilter.getSessionId() != null) {
            filterRec.put("sessionId", operationFilter.getSessionId().toString());
        }
        if (operationFilter.getMsgType() != null) {
            filterRec.put("msgType", operationFilter.getMsgType());
        }
        if (getRrn() != null) {
            filterRec.put("rrn", getRrn());
        }
        if (getArn() != null) {
            filterRec.put("arn", getArn());
        }
        if (operationFilter.getSttlType() != null) {
            filterRec.put("sttlType", operationFilter.getSttlType());
        }
        if (getAuthCode() != null) {
            filterRec.put("authCode", getAuthCode());
        }
        if (getOperDateFrom() != null) {
            SimpleDateFormat df = new SimpleDateFormat(DatePatterns.DATE_PATTERN);
            filterRec.put("operDateFrom", df.format(getOperDateFrom()));
        }
        if (getOperDateTo() != null) {
            SimpleDateFormat df = new SimpleDateFormat(DatePatterns.DATE_PATTERN);
            filterRec.put("operDateTo", df.format(getOperDateTo()));
        }
    }

    public Logger getLogger() {
        return logger;
    }

    public Operation loadOperation() {
        _activeOperation = null;

        setFilters();
        SelectionParams params = new SelectionParams();
        params.setFilters((Filter[]) filters.toArray(new Filter[filters.size()]));

        try {
            List<Operation> opers = _operationDao.getOperations(userSessionId, params, curLang);
            if (opers.size() > 0) {
                _activeOperation = opers.get(0);
            }
        } catch (Exception e) {
            logger.error("", e);
            FacesUtils.addMessageError(e);
        }
        return _activeOperation;
    }

    public String getEntryId() {
        return entryId;
    }

    public void setEntryId(String entryId) {
        this.entryId = entryId;
    }

    /**
     * <p>
     * Gets and sets (if needed) actual operation type if user moved from one operation form to
     * another because there are possible situations when user changed form (e.g. moved from
     * acquiring operations to issuing) but the bean wasn't destroyed and operation type remained
     * the same. One needs to read this parameter from form by placing hidden input on its top.
     * </p>
     *
     * @return
     */
    public String getOperTypeHidden() {
        Menu menu = (Menu) ManagedBeanWrapper.getManagedBean("menu");
        if (this.operType == null || menu.isClicked()) {
            String operType = getOperTypeFromRequest();
            if (operType != null && !operType.equals(this.operType)) {
                // if it's another operations form then we need to clear all form's data
                clearFilter();
            }
            this.operType = operType;
        }
        return operType;
    }

    private String getOperTypeFromRequest() {
        return FacesUtils.getRequestParameter("operType");
    }

    public String back() {
        FacesUtils.setSessionMapValue(backLink, Boolean.TRUE);
        return backLink;
    }

    public boolean isShowBackBtn() {
        return backLink == null ? false : (backLink.trim().length() > 0 ? true : false);
    }

    public String getBackLink() {
        return backLink;
    }

    public void setBackLink(String backLink) {
        this.backLink = backLink;
    }

    /**
     * Initializes bean's filter if bean has been accessed by context menu.
     */
    private void initFilterFromContext() {
        operationFilter = new Operation();
        if (FacesUtils.getSessionMapValue("terminalNumber") != null) {
            operationFilter.setTerminalNumber((String) FacesUtils.getSessionMapValue("terminalNumber"));
            FacesUtils.setSessionMapValue("terminalNumber", null);
        }
        if (FacesUtils.getSessionMapValue("merchantNumber") != null) {
            operationFilter.setMerchantNumber((String) FacesUtils.getSessionMapValue("merchantNumber"));
            FacesUtils.setSessionMapValue("merchantNumber", null);
        }
        if (FacesUtils.getSessionMapValue("merchantName") != null) {
            operationFilter.setMerchantName((String) FacesUtils.getSessionMapValue("merchantName"));
            FacesUtils.setSessionMapValue("merchantName", null);
        }
        if (FacesUtils.getSessionMapValue("acqInstBin") != null) {
            operationFilter.setAcqInstBin((String) FacesUtils.getSessionMapValue("acqInstBin"));
            FacesUtils.setSessionMapValue("acqInstBin", null);
        }
        if (FacesUtils.getSessionMapValue("id") != null) {
            operationFilter.setId((Long) FacesUtils.getSessionMapValue("id"));
            FacesUtils.setSessionMapValue("id", null);
        }
        searchType = EntityNames.OPERATION;
    }

    public boolean isAcqOperation() {
        return ModuleNames.ACQUIRING.equals(operType);
    }

    public boolean isIssOperation() {
        return ModuleNames.ISSUING.equals(operType);
    }

    public boolean isH2hOperation() {
        return ModuleNames.HOST_TO_HOST.equals(operType);
    }

    public String getPrivName() {
        if (isIssOperation()) {
            return OperationPrivConstants.VIEW_ISSUING_OPERATIONS;
        } else if (isAcqOperation()) {
            return OperationPrivConstants.VIEW_ACQUIRING_OPERATIONS;
        } else if (isH2hOperation()) {
            return OperationPrivConstants.VIEW_HOST_TO_HOST_OPERATIONS;
        } else {
            return OperationPrivConstants.VIEW_OPERATION;
        }
    }

    public String getSearchTabName() {
        return searchTabName;
    }

    public void setSearchTabName(String searchTabName) {
        this.searchTabName = searchTabName;
        // sessBean.setSearchTabName(searchTabName);
    }

    public void switchTab() {
        sectionFilterModeEdit = false;
        selectedSectionFilter = null;
        sectionFilter = null;
    }

    /**
     * Search using only <code>operationFilter</code>.
     */
    public void searchByOperation() {
        searchType = EntityNames.OPERATION;
        search();
    }

    /**
     * Search using only <code>operationFilter</code>.
     */
    public void searchByTag() {
        searchType = EntityNames.TAG;
        search();
        toSetForceSearch();
    }

    /**
     * Search using only <code>documentFilter</code>.
     */
    public void searchByDocument() {
        searchType = EntityNames.REPORT_DOCUMENT;
        search();
        toSetForceSearch();
    }

    /**
     * Search using only <code>participantFilter</code>.
     */
    public void searchByParticipant() {
        searchType = EntityNames.PARTICIPANT;
        search();
        toSetForceSearch();
    }

    /**
     * Search using only <code>pmoFilter</code>.
     */
    public void searchByPaymentOrder() {
        searchType = EntityNames.PAYMENT_ORDER;
        search();
        toSetForceSearch();
    }

    /**
     * Search using only <code>customerFilter</code>.
     */
    public void searchByCustomer() {
        searchType = EntityNames.CUSTOMER;
        search();
        toSetForceSearch();
    }

    public void searchFromCaseApplication() {
        filters = new ArrayList<Filter>();
        searchType = EntityNames.CASE_APPLICATIONS;
        search();
        toSetForceSearch();
    }

    protected boolean isSearchByDocument() {
        return EntityNames.REPORT_DOCUMENT.equals(searchType);
    }
    protected boolean isSearchByParticipant() {
        return EntityNames.PARTICIPANT.equals(searchType);
    }
    protected boolean isSearchByPaymentOrder() {
        return EntityNames.PAYMENT_ORDER.equals(searchType);
    }
    protected boolean isSearchByTag() {
        return EntityNames.TAG.equals(searchType);
    }
    protected boolean isSearchByCustomer() {
        return EntityNames.CUSTOMER.equals(searchType);
    }
    protected boolean isSearchFromCaseApplication() { return  EntityNames.CASE_APPLICATIONS.equals(searchType);}

    public void search() {
        search(SEARCH_TAB_PARTICIPANT.equals(searchTabName) || SEARCH_TAB_DISPUTE.equals(searchTabName));
    }

    public void search(boolean selectObject) {
        if (selectObject) {
            clearState();
            searching = false;
            MbIssSelectObject bean = ManagedBeanWrapper.getManagedBean(MbIssSelectObject.class);
            int size = bean.load(this);
            if (size > 1) {
                rerenderList = "";
                rerenderList += searchButtonId; // need for open dialog
                rerenderList += "," + MbIssSelectObject.MODAL_ID;
            } else if(size == 0) {
                searching = true;
            }
        } else {
            searching = true;
        }
    }

    public boolean isNeedOpenSelectObjectDialog() {
        return getRerenderList().contains(MbIssSelectObject.MODAL_ID);
    }


    public void setFilters() {
        paramMap = new HashMap<String, Object>();

        if (isSearchByDocument()) {
            setFiltersOperation(false);
            setFiltersDocument(false);
            paramMap.put("tab_name", "DOCUMENT");
        } else if (isSearchByPaymentOrder()) {
            setFiltersOperation(false);
            setFiltersPmo(false);
            paramMap.put("tab_name", "PAYMENT_ORDER");
        } else if (isSearchByParticipant()) {
            setFiltersOperation(false);
            setFiltersParticipant(false);
            paramMap.put("tab_name", "PARTICIPANT");
        } else if (isSearchByTag()) {
            setFiltersOperation(false);
            setFiltersTag(false);
            paramMap.put("tab_name", "TAG");
        } else if (isSearchByCustomer()) {
            setFiltersOperation(false);
            setFiltersCustomer(false);
            paramMap.put("tab_name", "PARTICIPANT"); // use participant table because it has link to customer
        } else if (isSearchFromCaseApplication()) {
            paramMap.put("tab_name", "ORIGINAL_CASE_OPERATIONS");
        } else {
            setFiltersOperation(true);
        }
        if (ModuleNames.ACQUIRING.equalsIgnoreCase(operType)) {
            filters.add(new Filter("PARTICIPANT_MODE", "PRTYACQ"));
        } else if (ModuleNames.ISSUING.equalsIgnoreCase(operType)) {
            filters.add(new Filter("PARTICIPANT_MODE", "PRTYISS"));
        } else if (ModuleNames.HOST_TO_HOST.equalsIgnoreCase(operType)) {
            filters.add(new Filter("IS_H2H_OPERATIONS", 1));
        }
        setFilterSttlType();
    }

    protected void setFiltersOperation(boolean addParticipantFilters) {
        operationFilter = getFilter();

        String dbDateFormat = "dd.MM.yyyy";
        SimpleDateFormat df = new SimpleDateFormat(dbDateFormat);
        df.setTimeZone(TimeZone.getTimeZone(timeZone));

        filters = new ArrayList<Filter>();

        Filter paramFilter = new Filter("lang", userLang);

	    filters.add(new Filter("OPER_ID", operationFilter.getId())); // always add OPER_ID for filter limitation (CORE-19397)

        if (operationFilter.getSessionId() != null) {
            filters.add(new Filter("SESSION_ID", operationFilter.getSessionId()));
        }
        if (reversal != null) {
            filters.add(new Filter("IS_REVERSAL", reversal));
        }
        if (operationFilter.getMccCode() != null && operationFilter.getMccCode().trim().length() > 0) {
            filters.add(new Filter("MCC", operationFilter.getMccCode()));
        }
        if (operationFilter.getTerminalType() != null && operationFilter.getTerminalType().trim().length() > 0) {
            filters.add(new Filter("TERMINAL_TYPE", operationFilter.getTerminalType()));
        }
        if (operationFilter.getTerminalNumber() != null &&
                operationFilter.getTerminalNumber().trim().length() > 0) {
            paramFilter = new Filter();
            paramFilter.setElement("TERMINAL_NUMBER");
            paramFilter.setValue(operationFilter.getTerminalNumber().trim().replaceAll("[*]", "%").replaceAll("[?]", "_"));
            filters.add(paramFilter);
        }
        if (operationFilter.getMerchantNumber() != null &&
                operationFilter.getMerchantNumber().trim().length() > 0) {
            paramFilter = new Filter();
            paramFilter.setElement("MERCHANT_NUMBER");
            paramFilter.setValue(operationFilter.getMerchantNumber().trim().replaceAll("[*]", "%").replaceAll("[?]", "_"));
            filters.add(paramFilter);
        }
        if (operationFilter.getMerchantName() != null &&
                operationFilter.getMerchantName().trim().length() > 0) {
            paramFilter = new Filter();
            paramFilter.setElement("MERCHANT_NAME");
            paramFilter.setValue(operationFilter.getMerchantName().trim().replaceAll("[*]", "%").replaceAll("[?]", "_"));
            filters.add(paramFilter);
        }
        if (operationFilter.getAcqInstBin() != null &&
                operationFilter.getAcqInstBin().trim().length() > 0) {
            paramFilter = new Filter();
            paramFilter.setElement("ACQ_INST_BIN");
            paramFilter.setValue(operationFilter.getAcqInstBin().trim().replaceAll("[*]", "%").replaceAll("[?]", "_"));
            filters.add(paramFilter);
        }

        if (operationFilter.getCardMask() != null &&
                operationFilter.getCardMask().trim().length() > 0) {
            paramFilter = new Filter();
            paramFilter.setElement("CARD_MASK");
            paramFilter.setValue(operationFilter.getCardMask().trim().replaceAll("[*]", "%").replaceAll("[?]", "_"));
            filters.add(paramFilter);
        }

        if (hostDateFrom != null) {
            paramFilter = new Filter();
            paramFilter.setElement("HOST_DATE_FROM");
            paramFilter.setValue(hostDateFrom);
            filters.add(paramFilter);
        }
        if (hostDateTo != null) {
            paramFilter = new Filter();
            paramFilter.setElement("HOST_DATE_TILL");
            paramFilter.setValue(hostDateTo);
            filters.add(paramFilter);
        }
        if (operDateFrom != null) {
            paramFilter = new Filter();
            paramFilter.setElement("OPER_DATE_FROM");
            paramFilter.setValue(operDateFrom);
            filters.add(paramFilter);
        }
        if (operDateTo != null) {
            paramFilter = new Filter();
            paramFilter.setElement("OPER_DATE_TILL");
            paramFilter.setValue(operDateTo);
            filters.add(paramFilter);
        }
        if (entryId != null && entryId.trim().length() > 0) {
            paramFilter = new Filter();
            paramFilter.setElement("transactionId");
            paramFilter.setValue(entryId.trim().replaceAll("[*]", "%").replaceAll("[?]", "_"));
            filters.add(paramFilter);
        }
        if (operationFilter.getAuthId() != null) {
            paramFilter = new Filter();
            paramFilter.setElement("authId");
            paramFilter.setValue(operationFilter.getAuthId());
            filters.add(paramFilter);
        }
        if (operationFilter.getStatus() != null) {
            paramFilter = new Filter();
            paramFilter.setElement("STATUS");
            paramFilter.setValue(operationFilter.getStatus());
            filters.add(paramFilter);
        }
        if (operationFilter.getOperType() != null) {
            paramFilter = new Filter();
            paramFilter.setElement("OPER_TYPE");
            paramFilter.setValue(operationFilter.getOperType());
            filters.add(paramFilter);
        }
        if (addParticipantFilters) {
            setFiltersParticipant(false);
        }
        if (operationFilter.getStatusReason() != null && operationFilter.getStatusReason().trim().length() > 0) {
            paramFilter = new Filter("STATUS_REASON", operationFilter.getStatusReason());
            filters.add(paramFilter);
        }
        if (operationFilter.getMsgType() != null && operationFilter.getMsgType().trim().length() > 0) {
            paramFilter = new Filter();
            paramFilter.setElement("MSG_TYPE");
            paramFilter.setValue(operationFilter.getMsgType());
            filters.add(paramFilter);
        }
        if (operationFilter.getSttlType() != null && operationFilter.getSttlType().trim().length() > 0) {
            filters.add(new Filter("STTL_TYPE", operationFilter.getSttlType()));
        }
        if (authCode != null && authCode.trim().length() > 0) {
            paramFilter = new Filter();
            paramFilter.setElement("AUTH_CODE");
            paramFilter.setValue(authCode);
            filters.add(paramFilter);
        }
        if (rrn != null && rrn.trim().length() > 0) {
            paramFilter = new Filter();
            paramFilter.setElement("ORIGINATOR_REFNUM");
            paramFilter.setValue(rrn);
            filters.add(paramFilter);
        }
        if (arn != null && arn.trim().length() > 0) {
            paramFilter = new Filter();
            paramFilter.setElement("NETWORK_REFNUM");
            paramFilter.setValue(arn);
            filters.add(paramFilter);
        }
        if (operationFilter.getExternalAuthId() != null && operationFilter.getExternalAuthId().trim().length() > 0) {
            paramFilter = new Filter();
            paramFilter.setElement("FE_UTRNNO");
            paramFilter.setValue(operationFilter.getExternalAuthId().trim().replaceAll("[*]", "%").replaceAll("[?]", "_"));
            filters.add(paramFilter);
        }
    }
    protected void setFiltersDocument(boolean clearFilter) {
        getDocumentFilter();
        if (clearFilter) {
            filters = new ArrayList<Filter>();
        }
        Filter paramFilter = new Filter("lang", userLang);
        //filters.add(paramFilter);

        if (documentFilter.getDocumentNumber() != null &&
                documentFilter.getDocumentNumber().trim().length() > 0) {
            paramFilter = new Filter();
            paramFilter.setElement("DOCUMENT_NUMBER");
            paramFilter.setValue(documentFilter.getDocumentNumber().trim().replaceAll("[*]", "%")
                                         .replaceAll("[?]", "_"));
            filters.add(paramFilter);
        }

        if (documentFilter.getDocumentDate() != null) {
            paramFilter = new Filter();
            paramFilter.setElement("DOCUMENT_DATE");
            paramFilter.setOp(Operator.eq);
            paramFilter.setValue(documentFilter.getDocumentDate());
            filters.add(paramFilter);
        }

        if (documentFilter.getDocumentType() != null) {
            paramFilter = new Filter();
            paramFilter.setElement("DOCUMENT_TYPE");
            paramFilter.setOp(Operator.eq);
            paramFilter.setValue(documentFilter.getDocumentType());
            filters.add(paramFilter);
        }
    }
    protected void setFiltersTag(boolean clearFilter) {
        getTagFilter();
        if (clearFilter) {
            filters = new ArrayList<Filter>();
        }
        Filter paramFilter = new Filter("lang", userLang);

        if (tagFilter.getTagValue() != null &&
                tagFilter.getTagValue().trim().length() > 0) {
            paramFilter = new Filter();
            paramFilter.setElement("TAG_VALUE");
            paramFilter.setValue(tagFilter.getTagValue().trim().replaceAll("[*]", "%")
                                         .replaceAll("[?]", "_"));
            filters.add(paramFilter);
        }

        if (tagFilter.getTagType() != null) {
            paramFilter = new Filter();
            paramFilter.setElement("TAG_ID");
            paramFilter.setValue(Integer.parseInt(
                    tagFilter.getTagType()));
            filters.add(paramFilter);
        }

    }
    protected void setFiltersCustomer(boolean clearFilters) {
        getCustomerFilter();
        if (clearFilters) {
            filters = new ArrayList<Filter>();
        }
        Filter paramFilter = new Filter("lang", userLang);

        if (customerFilter.getCustomerNumber() != null && !customerFilter.getCustomerNumber().trim().isEmpty()) {
            paramFilter = new Filter();
            paramFilter.setValue(customerFilter.getCustomerNumber().trim().replaceAll("[*]", "%").replaceAll("[?]", "_"));
            paramFilter.setElement("CUSTOMER_NUMBER");
            paramFilter.setCondition("like");
            filters.add(paramFilter);
        }
        if (customerFilter.getId() != null) {
            filters.add(new Filter("CUSTOMER_ID", customerFilter.getId()));
        }
    }
    protected void setFiltersParticipant(boolean clearFilters) {
        getParticipantFilter();
        Filter paramFilter;
        if (clearFilters) {
            filters = new ArrayList<Filter>();
            paramFilter = new Filter("lang", userLang);
        }

        if (participantFilter.getCardMask() != null &&
                participantFilter.getCardMask().trim().length() > 0) {
            paramFilter = new Filter();
            paramFilter.setValue(participantFilter.getCardMask().trim().replaceAll("[*]", "%")
                                         .replaceAll("[?]", "_"));
            paramFilter.setElement("CARD_MASK");
            paramFilter.setCondition("like");

            filters.add(paramFilter);
        }
        if (participantFilter.getCardId() != null) {
            paramFilter = new Filter();
            paramFilter.setElement("CARD_ID");
            paramFilter.setValue(participantFilter.getCardId());
            filters.add(paramFilter);
        }
        if (accountId != null) {
            paramFilter = new Filter("ACCOUNT_ID", accountId);
            filters.add(paramFilter);
        } else if (accountNumber != null &&
                   accountNumber.trim().length() > 0) {
            paramFilter = new Filter();
            paramFilter.setElement("ACCOUNT_NUMBER");
            paramFilter.setCondition("=");
            paramFilter.setValue(accountNumber.trim()
                                         .replaceAll("[*]", "%").replaceAll("[?]", "_"));
            if (((String) paramFilter.getValue()).indexOf("%") != -1 ||
                    accountNumber.indexOf("?") != -1) {
                paramFilter.setCondition("like");
            }
            filters.add(paramFilter);
        }
        if (accountSplitHash != null) {
            filters.add(new Filter("SPLIT_HASH", accountSplitHash));
        }
        if (participantFilter.getParticipantType() != null) {
            paramFilter = new Filter();
            paramFilter.setElement("PARTICIPANT_TYPE");
            paramFilter.setValue(participantFilter.getParticipantType());
            filters.add(paramFilter);
        }
        if (participantFilter.getInstId() != null) {
            paramFilter = new Filter();
            paramFilter.setElement("INST_ID");
            paramFilter.setValue(participantFilter.getInstId());
            filters.add(paramFilter);
        }
        if (participantFilter.getTerminalId() != null) {
            paramFilter = new Filter();
            paramFilter.setElement("terminalId");
            paramFilter.setValue(participantFilter.getTerminalId());
            filters.add(paramFilter);
        }
        if (clientIdType != null) {
            paramFilter = new Filter("CLIENT_ID_TYPE", clientIdType);
            filters.add(paramFilter);
        }
        if (clientIdValue != null && !clientIdValue.trim().isEmpty()) {
            paramFilter = new Filter("CLIENT_ID_VALUE", clientIdValue);
            filters.add(paramFilter);
        }

        if (participantCustomerNumber != null && !participantCustomerNumber.trim().isEmpty()) {
            filters.add(new Filter("CUSTOMER_NUMBER", participantCustomerNumber));
        }
        if (participantFilter.getCardToken() != null && participantFilter.getCardToken().trim().length() > 0) {
            filters.add(Filter.create("CARD_TOKEN", Operator.like, Filter.mask(participantFilter.getCardToken(), true)));
        }
    }
    protected void setFiltersPmo(boolean clearFilter) {
        getPmoFilter();
        if (clearFilter) {
            filters = new ArrayList<Filter>();
        }
        Filter paramFilter;

        if (pmoFilter.getId() != null) {
            paramFilter = new Filter("id", pmoFilter.getId());
            filters.add(paramFilter);
        }

        if (pmoFilter.getPurposeId() != null) {
            paramFilter = new Filter("PURPOSE_ID", pmoFilter.getPurposeId());
            filters.add(paramFilter);
        }

        if (pmoFilter.getStatus() != null) {
            paramFilter = new Filter("ORDER_STATUS", pmoFilter.getStatus());
            filters.add(paramFilter);
        }
        if (filterCustomerNumber != null && !filterCustomerNumber.trim().isEmpty()) {
            filters.add(new Filter("CUSTOMER_NUMBER", filterCustomerNumber));
        }
        if (filterRecieverCustomerNumber != null && !filterRecieverCustomerNumber.trim().isEmpty()) {
            filters.add(new Filter("RECIEVER_CUSTOMER_NUMBER", filterRecieverCustomerNumber));
        }
    }

    public void changeLanguage(ValueChangeEvent event) {
        curLang = (String) event.getNewValue();

        List<Filter> filtersList = new ArrayList<Filter>();

        Filter paramFilter = new Filter();
        paramFilter.setElement("operId");
        paramFilter.setValue(_activeOperation.getId());
        filtersList.add(paramFilter);

        paramFilter = new Filter();
        paramFilter.setElement("lang");
        paramFilter.setValue(curLang);
        filtersList.add(paramFilter);

        filters = filtersList;
        SelectionParams params = new SelectionParams();
        params.setFilters(filters.toArray(new Filter[filters.size()]));
        try {
            List<Operation> opers = null;
            opers = _operationDao.getOperations(userSessionId, params, curLang);
            if (opers != null && opers.size() > 0) {
                _activeOperation = opers.get(0);
            }
        } catch (Exception e) {
            FacesUtils.addMessageError(e);
            logger.error("", e);
        }
    }

    public String getOperType() {
        return operType;
    }

    public void setOperType(String operType) {
        this.operType = operType;
        if (ModuleNames.ACQUIRING.equals(operType)) {
            thisBackLink = ACQUIRING_BACKLINK;
        } else if (ModuleNames.ISSUING.equals(operType)) {
            thisBackLink = ISSUING_BACKLINK;
        } else if (ModuleNames.HOST_TO_HOST.equals(operType)) {
            thisBackLink = ROUTING_BACKLINK;
        }
    }

    public List<SelectItem> getStatuses() {
        if (operStatuses == null) {
            operStatuses = getDictUtils().getLov(LovConstants.OPERATION_STATUSES);
        }
        return operStatuses;
    }

    public List<SelectItem> getParticipantTypes() {
        if (participantTypes == null) {
            participantTypes = getDictUtils().getLov(LovConstants.PARTICIPANT_TYPES);
        }
        return participantTypes;
    }

    public List<SelectItem> getPmoPurposes() {
        if (pmoPurposes == null) {
            pmoPurposes = getDictUtils().getLov(LovConstants.PAYMENT_PURPOSE);
        }
        return pmoPurposes;
    }

    public List<SelectItem> getPmoStatuses() {
        if (pmoStatuses == null) {
            pmoStatuses = getDictUtils().getLov(LovConstants.PMO_STATUSES);
        }
        return pmoStatuses;
    }

    public List<SelectItem> getDocumentTypes() {
        if (documentTypes == null) {
            documentTypes = getDictUtils().getLov(LovConstants.DOCUMENT_TYPES);
        }
        return documentTypes;
    }

    public List<SelectItem> getTagTypes() {
        if (tagTypes == null) {
            tagTypes = getDictUtils().getLov(LovConstants.TAG_TYPES);
        }
        return tagTypes;
    }

    public List<SelectItem> getOperTypes() {
        if (operTypes == null) {
            operTypes = getDictUtils().getLov(LovConstants.OPERATION_TYPE);
        }
        return operTypes;
    }

    public List<SelectItem> getMessageTypes() {
        if (messageTypes == null) {
            messageTypes = getDictUtils().getLov(LovConstants.MESSAGE_TYPES);
        }
        return messageTypes;
    }

    public List<SelectItem> getSettlementTypes() {
   		if (isIssOperation()) {
   			if (issSttlTypes == null) {
   			    issSttlTypes = getDictUtils().getLov(LovConstants.ISS_STTL_TYPES);
   			}
   			return (issSttlTypes);
   		}
   		else if (isAcqOperation()) {
   			if (acqSttlTypes == null) {
   			    acqSttlTypes = getDictUtils().getLov(LovConstants.ACQ_STTL_TYPES);
   			}
   			return (acqSttlTypes);
   		}
   		else {
   			if (settlementTypes == null) {
   				settlementTypes = getDictUtils().getLov(LovConstants.SETTLEMENT_TYPES);
   			}
   			return settlementTypes;
   		}
   	}

    public List<SelectItem> getStatusReasons() {
        if (statusReasons == null) {
            statusReasons = getDictUtils().getLov(LovConstants.STATUS_REASONS);
        }
        return statusReasons;
    }

    public List<SelectItem> getYesNoLov() {
        if (yesNoLov == null) {
            yesNoLov = getDictUtils().getLov(LovConstants.BOOLEAN);
        }
        return yesNoLov;
    }

    public String getClientIdType() {
        return clientIdType;
    }

    public void setClientIdType(String clientIdType) {
        this.clientIdType = clientIdType;
    }

    public List<SelectItem> getClientIdTypes() {
        if (clientIdTypes == null) {
            clientIdTypes = getDictUtils().getLov(LovConstants.CLIENT_ID_TYPES);
        }
        return clientIdTypes;
    }

    public String getClientIdValue() {
        return clientIdValue;
    }

    public void setClientIdValue(String clientIdValue) {
        this.clientIdValue = clientIdValue;
    }

    public List<SelectItem> getAcqInstBins() {
        if (acqInstBins == null) {
            acqInstBins = getDictUtils().getLov(LovConstants.ACQUIRING_BINS);
        }
        return acqInstBins;
    }

    public void showCustomers() {
        MbCustomerSearchModal custBean = ManagedBeanWrapper.getManagedBean(MbCustomerSearchModal.class);
        custBean.clearFilter();
        custBean.setBlockInstId(false);
    }

    public void selectCustomer() {
        MbCustomerSearchModal custBean = ManagedBeanWrapper.getManagedBean(MbCustomerSearchModal.class);
        Customer selected = custBean.getActiveCustomer();
        if (selected != null) {
            if (searchTabName.equals(SEARCH_TAB_PARTICIPANT)) {
                participantCustomerNumber = selected.getCustomerNumber();
                participantCustomerInfo = selected.getName();
                participantCustomerId = selected.getId();
            } else {
                filterCustomerNumber = selected.getCustomerNumber();
                filterCustomerInfo = selected.getName();
            }
        }
    }

    public void selectRecieverCustomer() {
        MbCustomerSearchModal custBean = ManagedBeanWrapper.getManagedBean(MbCustomerSearchModal.class);
        Customer selected = custBean.getActiveCustomer();
        if (selected != null) {
            filterRecieverCustomerNumber = selected.getCustomerNumber();
            filterRecieverCustomerInfo = selected.getName();
        }
    }

    public void displayCustInfo() {
        /*
		filterCustomerNumber = null;
		filterCustomerInfo = null;
		filterRecieverCustomerNumber = null;
		filterRecieverCustomerInfo = null;
		*/
    }

    public String getFilterCustomerNumber() {
        return filterCustomerNumber;
    }

    public void setFilterCustomerNumber(String filterCustomerNumber) {
        this.filterCustomerNumber = filterCustomerNumber;
        if (searchTabName.equals(SEARCH_TAB_CUSTOMER)) {
            if (StringUtils.isEmpty(this.filterCustomerNumber) && StringUtils.isNotEmpty(this.filterCustomerInfo)) {
                this.filterCustomerNumber = this.filterCustomerInfo; // if we fill it manually
            }
            else if (StringUtils.isNotEmpty(this.filterCustomerNumber) && StringUtils.isEmpty(this.filterCustomerInfo)) {
                this.filterCustomerNumber = ""; // if we clean up it after loupe
            }
            else if (StringUtils.isNotEmpty(this.filterCustomerNumber) && StringUtils.isNotEmpty(this.filterCustomerInfo)
                    && !this.filterCustomerInfo.contains(this.filterCustomerNumber)) {
                this.filterCustomerNumber = this.filterCustomerInfo; // if we fill it manually after loupe
            }
            getCustomerFilter().setCustomerNumber(this.filterCustomerNumber);
        }
    }

    public String getFilterCustomerInfo() {
        return filterCustomerInfo;
    }

    public void setFilterCustomerInfo(String filterCustomerInfo) {
        this.filterCustomerInfo = filterCustomerInfo;
    }

    public String getFilterRecieverCustomerNumber() {
        return filterRecieverCustomerNumber;
    }

    public void setFilterRecieverCustomerNumber(String filterRecieverCustomerNumber) {
        this.filterRecieverCustomerNumber = filterRecieverCustomerNumber;
    }

    public String getFilterRecieverCustomerInfo() {
        return filterRecieverCustomerInfo;
    }

    public void setFilterRecieverCustomerInfo(String filterRecieverCustomerInfo) {
        this.filterRecieverCustomerInfo = filterRecieverCustomerInfo;
    }

    public void updateOperations() {
        if (onlyUpdate) {
            search();
        } else {
            Operation updatedAccount = null;

            List<Filter> flt = new ArrayList<Filter>();
            HashMap<String, Object> map = new HashMap<String, Object>();
            flt.add(new Filter("OPER_ID", _activeOperation.getId()));

            if (ModuleNames.ACQUIRING.equalsIgnoreCase(operType)) {
                flt.add(new Filter("PARTICIPANT_MODE", "PRTYACQ"));
            } else if (ModuleNames.ISSUING.equalsIgnoreCase(operType)) {
                flt.add(new Filter("PARTICIPANT_MODE", "PRTYISS"));
            } else if (ModuleNames.HOST_TO_HOST.equalsIgnoreCase(operType)) {
                flt.add(new Filter("IS_H2H_OPERATIONS", 1));
            }

            if (isSearchByDocument()) {
                map.put("tab_name", "DOCUMENT");
            } else if (isSearchByParticipant()) {
                map.put("tab_name", "PARTICIPANT");
            } else if (isSearchByPaymentOrder()) {
                map.put("tab_name", "PAYMENT_ORDER");
            } else if (isSearchByTag()) {
                map.put("tab_name", "TAG");
            }

            SelectionParams params = new SelectionParams();
            params.setFilters(flt.toArray(new Filter[flt.size()]));
            map.put("param_tab", flt.toArray(new Filter[flt.size()]));
            map.put("one_step_search", 1);
            map.put("oper_id_tab", new BigDecimal[0]);
            List<Operation> opers = _operationDao.getOperationCursor(userSessionId, params, map, getPrivName());

            if (opers.size() != 0) {
                updatedAccount = opers.get(0);
                operationFilter = updatedAccount;
                search();
            }
        }
    }

    public void setupOperTypeSelection() {
        CommonWizardStepInfo step = new CommonWizardStepInfo();
        step.setOrder(0);
        step.setSource(MbOperTypeSelectionStep.class.getSimpleName());
        step.setName(FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Opr", "select_oper_type"));
        List<CommonWizardStepInfo> stepsList = new ArrayList<CommonWizardStepInfo>();
        stepsList.add(step);
        Map<String, Object> context = new HashMap<String, Object>();
        context.put(MbCommonWizard.STEPS, stepsList);
        context.put(MbOperTypeSelectionStep.ENTITY_TYPE, EntityNames.OPERATION);

        if (_activeOperation != null) {
            context.put(MbOperTypeSelectionStep.OBJECT_ID, _activeOperation.getId());
            context.put(MbOperTypeSelectionStep.OPERATION, _activeOperation);
	        context.put(MbOperTypeSelectionStep.ENTITY_OBJECT_TYPE, _activeOperation.getOperType());

            if (ModuleNames.ACQUIRING.equalsIgnoreCase(operType)) {
                context.put("INST_ID", _activeOperation.getAcqInstId());
                context.put(MbOperTypeSelectionStep.OBJECT_TYPE, Participant.ACQ_PARTICIPANT);
            } else {
                context.put("INST_ID", _activeOperation.getIssInstId());
                context.put(MbOperTypeSelectionStep.OBJECT_TYPE, Participant.ISS_PARTICIPANT);
            }
            context.put("OPER_STATUS", _activeOperation.getStatus());
        } else {
            context.put(MbOperTypeSelectionStep.OBJECT_ID_NEED, false);
            if (ModuleNames.ACQUIRING.equalsIgnoreCase(operType)) {
                context.put(MbOperTypeSelectionStep.OBJECT_TYPE, Participant.ACQ_PARTICIPANT);
            } else {
                context.put(MbOperTypeSelectionStep.OBJECT_TYPE, Participant.ISS_PARTICIPANT);
            }
        }

        MbCommonWizard wizard = ManagedBeanWrapper.getManagedBean(MbCommonWizard.class);
        wizard.init(context);
    }

    public String createDspCaseFromOperation() {
        Map<String, Object> params = new HashMap<String, Object>();
        params.put("operId", getActiveOperation().getId());
        if (ModuleNames.ACQUIRING.equalsIgnoreCase(operType)) {
            params.put("participantType", "PRTYACQ");
        } else {
            params.put("participantType", "PRTYISS");
        }
        try {
            _disputesLocalDao.createCaseDisputeByOperation(userSessionId, params);
        } catch (UserException e) {
            throw new IllegalStateException(e);
        }
        return null;
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

        if (_activeOperation != null) {
            if (EntityNames.OPERATION.equals(ctxItemEntityType)) {
                map.put("id", _activeOperation.getId());
                if (ModuleNames.ACQUIRING.equalsIgnoreCase(operType)) {
                    map.put("objectType", "PRTYACQ");
                } else if (ModuleNames.ISSUING.equalsIgnoreCase(operType)) {
                    map.put("objectType", "PRTYISS");
                }
            }
        }

        ctxType.setParams(map);
        return ctxType;
    }

    public boolean isForward() {
        return true; //!ctxItemEntityType.equals(EntityNames.OPERATION);
    }

    public String getAuthCode() {
        return authCode;
    }

    public void setAuthCode(String authCode) {
        this.authCode = authCode;
    }

    public String getRrn() {
        return rrn;
    }

    public void setRrn(String rrn) {
        this.rrn = rrn;
    }

    public String getArn() {
        return arn;
    }

    public void setArn(String arn) {
        this.arn = arn;
    }

    public Integer getReversal() {
        return reversal;
    }

    public void setReversal(Integer reversal) {
        this.reversal = reversal;
    }

    public List<SelectItem> getMcc() {
        if (mcc == null) {
            mcc = getDictUtils().getLov(LovConstants.MCC);
        }
        return mcc;
    }

    public void setMcc(List<SelectItem> mcc) {
        this.mcc = mcc;
    }

    public List<SelectItem> getTerminalType() {
        if (terminalType == null) {
            terminalType = getDictUtils().getLov(LovConstants.TERMINAL_TYPES);
        }
        return terminalType;
    }

    public void setTerminalType(List<SelectItem> terminalType) {
        this.terminalType = terminalType;
    }

    public void setParticipantCustomerId(Long participantCustomerId) {
        this.participantCustomerId = participantCustomerId;
    }

    public Long getParticipantCustomerId() {
        return participantCustomerId;
    }

    public void setParticipantCustomerNumber(String participantCustomerNumber) {
        this.participantCustomerNumber = participantCustomerNumber;
    }

    public String getParticipantCustomerNumber() {
        return participantCustomerNumber;
    }

    public void setParticipantCustomerInfo(String participantCustomerInfo) {
        this.participantCustomerInfo = participantCustomerInfo;
    }

    public String getParticipantCustomerInfo() {
        return participantCustomerInfo;
    }

    public Map<String, Object> getParamMap() {
        return paramMap;
    }

    public String getBeanName() {
        return beanName;
    }
    public void setBeanName(String beanName) {
        this.beanName = beanName;
    }

    public String getMethodName() {
        return methodName;
    }
    public void setMethodName(String methodName) {
        this.methodName = methodName;
    }

    public String getRerenderList() {
        return rerenderList;
    }
    public void setRerenderList(String rerenderList) {
        this.rerenderList = rerenderList;
    }

    private Participant[] loadParticipantsForOperation(Long operId) {
        Participant[] participants = null;
        Filter[] filters = new Filter[2];
        filters[0] = new Filter("lang", curLang);
        filters[1] = new Filter("operId", operId);

        SelectionParams params = new SelectionParams(filters);
        params.setRowIndexEnd(Integer.MAX_VALUE);
        try {
            participants = _operationDao.getParticipants(userSessionId, params);
        } catch (Exception e) {
            logger.error("", e);
            FacesUtils.addMessageError(e);
        }
        return participants;
    }

    public LoyaltyOperation[] getLoyaltyOperations() {
        loyaltyOperations = null;
        if (_activeOperation != null) {
            LoyaltyOperationRequest filter  = new LoyaltyOperationRequest();
            filter.setInstId(_activeOperation.getAcqInstId());
            filter.setStatus("RLTS0200");
            if (null == _activeOperation.getParticipants()) {
                _activeOperation.setParticipants(
                        new ArrayList<Participant>(Arrays.asList(loadParticipantsForOperation(_activeOperation.getId()))));
            }
            if (null != _activeOperation.getParticipants()) {
                for (Participant participant : _activeOperation.getParticipants()) {
                    if (Participant.ACQ_PARTICIPANT.equals(participant.getParticipantType()))
                        filter.setMerchantId(participant.getMerchantId().longValue());
                    if (Participant.ISS_PARTICIPANT.equals(participant.getParticipantType()))
                        filter.setCardNumber(participant.getCardNumber());
                }
            }
            filter.setSpentOperationId(_activeOperation.getId());
            loyaltyOperations = loyaltyDao.getLoyaltyOperations(userSessionId, filter);
        }
        return loyaltyOperations;
    }


    public boolean isIssuingType() {
        issuingType = ISSUING_BACKLINK.equals(thisBackLink);
        return issuingType;
    }

    public boolean isAcquiringType() {
        acquiringType = ACQUIRING_BACKLINK.equals(thisBackLink);
        return acquiringType;
    }

    public boolean isH2hType() {
        h2hType = ROUTING_BACKLINK.equals(thisBackLink);
        return h2hType;
    }

    public boolean isOnlyUpdate() {
        return onlyUpdate;
    }

    public void setOnlyUpdate(boolean onlyUpdate) {
        this.onlyUpdate = onlyUpdate;
    }

    public String getSearchButtonId() {
        return searchButtonId;
    }

    public void setSearchButtonId(String searchButtonId) {
        this.searchButtonId = searchButtonId;
    }

    public Long getAccountId() {
        return accountId;
    }

    public void setAccountId(Long accountId) {
        this.accountId = accountId;
    }

    public Integer getAccountSplitHash() {
        return accountSplitHash;
    }

    public void setAccountSplitHash(Integer accountSplitHash) {
        this.accountSplitHash = accountSplitHash;
    }

    public String getAccountNumber() {
        return accountNumber;
    }

    public void setAccountNumber(String accountNumber) {
        this.accountNumber = accountNumber;
    }

}
