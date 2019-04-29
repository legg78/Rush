package ru.bpc.sv2.ui.reconciliation;

import org.apache.commons.lang3.StringUtils;
import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;
import ru.bpc.sv2.common.CommonWizardStepInfo;
import ru.bpc.sv2.constants.DatePatterns;
import ru.bpc.sv2.constants.EntityNames;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.constants.ModuleNames;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.issuing.Card;
import ru.bpc.sv2.issuing.IssuingPrivConstants;
import ru.bpc.sv2.logic.ReconciliationDao;
import ru.bpc.sv2.operations.Participant;
import ru.bpc.sv2.orgstruct.Institution;
import ru.bpc.sv2.reconciliation.RcnConstants;
import ru.bpc.sv2.reconciliation.RcnMessage;
import ru.bpc.sv2.reconciliation.RcnParameter;
import ru.bpc.sv2.ui.common.wizard.MbCommonWizard;
import ru.bpc.sv2.ui.common.wizard.callcenter.MbOperTypeSelectionStep;
import ru.bpc.sv2.ui.navigation.Menu;
import ru.bpc.sv2.ui.operations.MbOperations;
import ru.bpc.sv2.ui.session.UserSession;
import ru.bpc.sv2.ui.utils.*;
import util.auxil.ManagedBeanWrapper;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.event.ValueChangeEvent;
import javax.faces.model.SelectItem;
import java.text.SimpleDateFormat;
import java.util.*;

@ViewScoped
@ManagedBean (name = "MbRcnMessages")
public class MbRcnMessages extends AbstractBean {
    private static final Logger logger = Logger.getLogger("OPER_PROCESSING");
    private static final String OPERATIONS_LINK = "acquiring|operations";
    private static final String DETAILS_TAB = "detailsTab";
    private static final String PARAMS_TAB = "paramsTab";
    private static final String PAGE = "page";
    private static final String VIEW_CARD_BTN = "viewCardNumberBtn";
    private static final String EXPORT_BTN = "exportBtn";
    private static final String REQUIRE_RCN_BTN = "reqRecBtn";
    private static final String DONT_RCN_BTN = "notReqRecBtn";
    private static final String PARAMS = "parameters";
	private static final String ACTIONS_BTN = "actionsBtn";

    private ReconciliationDao reconciliationDao = new ReconciliationDao();

    private String module;
    private final DaoDataListModel<RcnMessage> messagesSource;
    private final TableRowSelection<RcnMessage> itemSelection;

    private RcnMessage activeMessage;
    private RcnMessage filter;
    private Card activeCard;
    private RcnExport export;
    private String tabName;

    private List<SelectItem> institutions;
    private List<SelectItem> messageSources;
    private List<SelectItem> statuses;
    private List<SelectItem> messageTypes;
    private List<SelectItem> operationTypes;

    public MbRcnMessages() {
        tabName = DETAILS_TAB;
        messagesSource = new DaoDataListModel<RcnMessage>(logger) {
            @Override
            protected List<RcnMessage> loadDaoListData(SelectionParams params) {
                if (searching) {
                    setFilters();
                    params.setFilters(filters);
                    params.setModule(getModule());
                    return reconciliationDao.getMessages(userSessionId, params);
                }
                return new ArrayList<RcnMessage>();
            }

            @Override
            protected int loadDaoDataSize(SelectionParams params) {
                if (searching) {
                    setFilters();
                    params.setModule(getModule());
                    params.setFilters(filters.toArray(new Filter[filters.size()]));
                    return reconciliationDao.getMessagesCount(userSessionId, params);
                }
                return 0;
            }
        };
        itemSelection = new TableRowSelection<RcnMessage>(null, messagesSource);
    }

    public String getModule() {
        return module;
    }
    public void setModule(String module) {
        this.module = module;
    }

    public DaoDataListModel<RcnMessage> getMessages() {
        return messagesSource;
    }

    public RcnMessage getActiveMessage() {
        return activeMessage;
    }
    public void setActiveMessage(RcnMessage activeMessage) {
        this.activeMessage = activeMessage;
    }

    public SimpleSelection getItemSelection() {
        try {
            if (activeMessage == null && messagesSource.getRowCount() > 0) {
                setFirstRowActive();
            } else if (activeMessage != null && messagesSource.getRowCount() > 0) {
                SimpleSelection selection = new SimpleSelection();
                selection.addKey(activeMessage.getModelId());
                itemSelection.setWrappedSelection(selection);
                activeMessage = itemSelection.getSingleSelection();
            }
        } catch (Exception e) {
            FacesUtils.addMessageError(e);
            logger.error("", e);
        }
        return itemSelection.getWrappedSelection();
    }
    public void setItemSelection(SimpleSelection selection) {
        try {
            itemSelection.setWrappedSelection(selection);
            boolean changeSelect = false;
            if (itemSelection.getSingleSelection() != null) {
                if (!itemSelection.getSingleSelection().getId().equals(activeMessage.getId())) {
                    changeSelect = true;
                }
            }
            activeMessage = itemSelection.getSingleSelection();
        } catch (Exception e) {
            FacesUtils.addMessageError(e);
            logger.error("", e);
        }
    }

    public RcnMessage getFilter() {
        if (filter == null) {
            filter = new RcnMessage();
            filter.setModule(getModule());
            filter.setReconInstId(userInstId);
            filter.setReconStatus(RcnConstants.RECONCILIATION_FAILED);
            switch (getModule()) {
                case RcnConstants.MODULE_CBS:
                    filter.setMsgSource(RcnConstants.MSG_SRC_CBS_RECONCILIATION);
                    break;
                case RcnConstants.MODULE_ATM:
                    filter.setMsgSource(RcnConstants.MSG_SRC_SVFE_ATM_EJOURNAL);
                    break;
                case RcnConstants.MODULE_HOST:
                    filter.setMsgSource(RcnConstants.MSG_SRC_HOST_RECONCILIATION);
                    break;
                case RcnConstants.MODULE_SP:
                    filter.setMsgSource(RcnConstants.MSG_SRC_SRVP_RECONCILIATION);
                    break;
                default:
                    filter.setMsgSource(RcnConstants.MSG_SRC_PROCESSING_IN_SV);
                    break;
            }
        }
        return filter;
    }
    public void setFilter(RcnMessage filter) {
        this.filter = filter;
    }

    public Card getActiveCard() {
        if (activeCard == null) {
            setActiveCard(new Card());
        }
        return activeCard;
    }
    public void setActiveCard(Card activeCard) {
        this.activeCard = activeCard;
    }

    public RcnExport getExport() {
        if (export == null) {
            setExport(new RcnExport());
        }
        return export;
    }
    public void setExport(RcnExport export) {
        this.export = export;
    }

    public void setFirstRowActive() throws CloneNotSupportedException {
        messagesSource.setRowIndex(0);
        SimpleSelection selection = new SimpleSelection();
        activeMessage = (RcnMessage) messagesSource.getRowData();
        selection.addKey(activeMessage.getModelId());
        itemSelection.setWrappedSelection(selection);
    }

    public void search() {
        clearBean();
        searching = true;
    }

    public void clearBean() {
        messagesSource.flushCache();
        itemSelection.clearSelection();
        activeMessage = null;
    }
    @Override
    public void clearFilter() {
        clearBean();
        curLang = userLang;
        filter = null;
        searching = false;
    }

    public void setFilters() {
        filters = new ArrayList<Filter>();
        SimpleDateFormat df = new SimpleDateFormat(DatePatterns.FULL_DATE_PATTERN);

        filters.add(Filter.create("lang", curLang));
        if (getFilter().getId() != null) {
            filters.add(Filter.create("id", getFilter().getId()));
        }
        if (getFilter().getReconInstId() != null && !getFilter().getReconInstId().equals(Institution.DEFAULT_INSTITUTION)) {
            filters.add(Filter.create("instId", getFilter().getReconInstId()));
        }
        if (getFilter().getReconStatus() != null){
            filters.add(Filter.create("reconStatus", getFilter().getReconStatus()));
        }
        if (getFilter().getMsgType() != null){
            filters.add(Filter.create("msgType", getFilter().getMsgType()));
        }
        if (getFilter().getOperType() != null){
            filters.add(Filter.create("operType", getFilter().getOperType()));
        }
        if (getFilter().getMsgDateFrom() != null){
            filters.add(Filter.create("dateFrom", df.format(getFilter().getMsgDateFrom())));
        }
        if (getFilter().getMsgDateTo() != null){
            filters.add(Filter.create("dateTo", df.format(getFilter().getMsgDateTo())));
        }
        if (getFilter().getMsgSource() != null) {
            filters.add(Filter.create("msgSrc", getFilter().getMsgSource()));
        } else if (getMessageSources().size() == 1) {
            filters.add(Filter.create("msgSrc", getMessageSources().get(0).getValue()));
        } else {
            filters.add(Filter.create("msgSources", getMessageSourcesFilterValue()));
        }
    }

    public List<SelectItem> getInstitutions() {
        return getDictUtils().getLovUI(LovConstants.INSTITUTIONS_SYS, institutions);
    }
    public List<SelectItem> getMessageSources() {
        Map<String, Object> params = new HashMap<String, Object>();
        params.put("type", getModule());
        return getDictUtils().getLovUI(LovConstants.MESSAGE_SOURCES, params, messageSources);
    }

    public List<SelectItem> getStatuses() {
        return getDictUtils().getLovUI(LovConstants.RECONCILIATION_STATUSES, statuses);
    }

    public List<SelectItem> getOperationTypes() {
        return getDictUtils().getLovUI(LovConstants.OPERATION_TYPE, operationTypes);
    }

    public List<SelectItem> getMessageTypes() {
        return getDictUtils().getLovUI(LovConstants.MESSAGE_TYPES, messageTypes);
    }

    public void viewCardNumber() {
        getActiveCard().setCardNumber(activeMessage.getCardNumber());
        getActiveCard().setMask(activeMessage.getCardMask());
        getActiveCard().setExpDate(activeMessage.getCardExpirDate());
    }

    public void changeLanguage(ValueChangeEvent event) {
        curLang = (String) event.getNewValue();

        List<Filter> filters = new ArrayList<Filter>();
        filters.add(Filter.create("id", activeMessage.getId()));
        filters.add(Filter.create("lang", curLang));
        SelectionParams params = new SelectionParams(filters);

        try {
            List<RcnMessage> recs = reconciliationDao.getMessages(userSessionId, params);
            if (recs != null && recs.size() > 0) {
                activeMessage = recs.get(0);
            }
        } catch (Exception e) {
            FacesUtils.addMessageError(e);
            logger.error("", e);
        }
    }

    public boolean enableButton(String component) {
        if (activeMessage != null) {
            String status = activeMessage.getReconStatus();

            if (RcnConstants.NOT_RECONCILED.equalsIgnoreCase(status)) {
	            if (ACTIONS_BTN.equalsIgnoreCase(component)) {
		            return true;
	            }
            } else if (RcnConstants.RECONCILIATION_FAILED.equalsIgnoreCase(status)) {
                if (REQUIRE_RCN_BTN.equalsIgnoreCase(component)) {
                    return true;
                } else if (ACTIONS_BTN.equalsIgnoreCase(component)) {
		            return true;
	            }
            } else if (RcnConstants.RECONCILIATION_NOT_REQUIRED.equalsIgnoreCase(status)) {
	            if (ACTIONS_BTN.equalsIgnoreCase(component)) {
		            return true;
	            }
                return true;
            } else if (RcnConstants.RECONCILIATION_EXPIRED.equalsIgnoreCase(status)) {
                if (REQUIRE_RCN_BTN.equalsIgnoreCase(component)) {
                    return true;
                }
            } else if (RcnConstants.MATCHED_WITH_ERRORS.equalsIgnoreCase(status)) {
                return true;
            } else if (RcnConstants.MATCHED_WITH_DUPLICATES.equalsIgnoreCase(status)) {
                return true;
            }
        }
        return false;
    }

    public boolean isRendered(String component) {
        if (StringUtils.isNotEmpty(component)) {
            Map<String, Boolean> role = ((UserSession) ManagedBeanWrapper.getManagedBean("usession")).getInRole();
            switch (component) {
                case PAGE:
                    switch (getModule()) {
                        case RcnConstants.MODULE_CBS:
                            return role.get(RcnConstants.VIEW_CBS_MESSAGES);
                        case RcnConstants.MODULE_ATM:
                            return role.get(RcnConstants.VIEW_ATM_MESSAGES);
                        case RcnConstants.MODULE_HOST:
                            return role.get(RcnConstants.VIEW_HOST_MESSAGES);
                        case RcnConstants.MODULE_SP:
                            return role.get(RcnConstants.VIEW_SP_MESSAGES);
                    }
                    break;
                case VIEW_CARD_BTN:
                    return role.get(IssuingPrivConstants.VIEW_CARD_NUMBER);
                case EXPORT_BTN:
                case REQUIRE_RCN_BTN:
                case DONT_RCN_BTN:
                    switch (getModule()) {
                        case RcnConstants.MODULE_CBS:
                            return role.get(RcnConstants.MODIFY_CBS_MESSAGES);
                        case RcnConstants.MODULE_ATM:
                            return role.get(RcnConstants.MODIFY_ATM_MESSAGES);
                        case RcnConstants.MODULE_HOST:
                            return role.get(RcnConstants.MODIFY_HOST_MESSAGES);
                        case RcnConstants.MODULE_SP:
                            return role.get(RcnConstants.MODIFY_SP_MESSAGES);
                    }
                    break;
                case PARAMS:
                    switch (getModule()) {
                        case RcnConstants.MODULE_SP:
                            return role.get(RcnConstants.VIEW_SP_PARAMETERS);
                    }
                    break;
	            case ACTIONS_BTN:
		            switch (getModule()) {
			            case RcnConstants.MODULE_HOST:
				            return true;
		            }
		            break;
            }
        }
        return false;
    }

    public void changeStatus(String component) {
        if (activeMessage != null) {
            if (REQUIRE_RCN_BTN.equalsIgnoreCase(component)) {
                activeMessage.setReconStatus(RcnConstants.RECONCILIATION_REQUIRED);
            } else if (DONT_RCN_BTN.equalsIgnoreCase(component)) {
                activeMessage.setReconStatus(RcnConstants.RECONCILIATION_NOT_REQUIRED);
            }
            try {
                reconciliationDao.modifyMessage(userSessionId, activeMessage);
            } catch (Exception e) {
                FacesUtils.addMessageError(e);
                logger.error("", e);
            }
        }
    }

    public String getTabName() {
        return tabName;
    }
    public void setTabName(String tabName) {
        this.tabName = tabName;
    }

    public void loadCurrentTab() {
        loadTab(tabName, false);
    }
    private void loadTab(String tab, boolean restoreBean) {
        if (tab != null && activeMessage != null) {
            if (tab.equalsIgnoreCase(DETAILS_TAB)) {
                /** No action is needed */
            } else if (tab.equalsIgnoreCase(PARAMS_TAB)) {
                MbRcnParameters bean = ManagedBeanWrapper.getManagedBean(MbRcnParameters.class);
                if (bean != null) {
                    List<Filter> paramFilters = new ArrayList<>(2);
                    paramFilters.add(Filter.create("msgId", activeMessage.getId()));
                    paramFilters.add(Filter.create("lang", activeMessage.getLang()));
                    try {
                        List<RcnParameter> data = reconciliationDao.getMessageParameters(userSessionId, new SelectionParams(paramFilters));
                        bean.setDataSource(data);
                        bean.setModule(getModule());
                        bean.searchByDataSource();
                    } catch (Exception e) {
                        logger.error("", e);
                    }
                }
            }
        }
    }

    public String getDetailsPage(String module) {
        if (StringUtils.isNotEmpty(module)) {
            setModule(module);
        }
        return "/pages/reconciliation/" + getModule().toLowerCase() + "/message_details.jspx";
    }

    public void prepareExport() {
        setExport(new RcnExport());
        getExport().setUserSessionId(userSessionId);
        getExport().setLang(curLang);

        switch (getModule()) {
            case RcnConstants.MODULE_CBS:
                getExport().setPrefix(RcnConstants.EXPORT_PREFIX_CBS);
                break;
            case RcnConstants.MODULE_ATM:
                getExport().setPrefix(RcnConstants.EXPORT_PREFIX_ATM);
                break;
            case RcnConstants.MODULE_HOST:
                getExport().setPrefix(RcnConstants.EXPORT_PREFIX_HOST);
                break;
            case RcnConstants.MODULE_SP:
                getExport().setPrefix(RcnConstants.EXPORT_PREFIX_SP);
                break;
            default:
                getExport().setPrefix(RcnConstants.EXPORT_PREFIX_DEFAULT);
                break;
        }

        SelectionParams params = new SelectionParams();
        params.setModule(getModule());
        params.setRowIndexEnd(-1);
        setFilters();
        params.setFilters(filters);
        if (reconciliationDao.getMessagesCount(userSessionId, params) > 0) {
            List<RcnMessage> recs = reconciliationDao.getMessages(userSessionId, params);
            getExport().setOperations(recs);
        }
    }

    private String getMessageSourcesFilterValue() {
        StringBuilder value = new StringBuilder();
        for (SelectItem source : getMessageSources()) {
            if (value.length() == 0) {
                value.append("'");
            } else {
                value.append(", '");
            }
            value.append(source.getValue().toString());
            value.append("'");
        }
        return value.toString();
    }

    public String linkOperation() {
        if (activeMessage != null) {
            HashMap<String, Object> queueFilter = new HashMap<String, Object>();
            queueFilter.put("id", activeMessage.getOperationId());
            queueFilter.put("operType", ModuleNames.ACQUIRING);
            queueFilter.put("backLink", thisBackLink);

            addFilterToQueue(MbOperations.class.getName(), queueFilter);
            Menu mbMenu = ManagedBeanWrapper.getManagedBean(Menu.class);
            mbMenu.externalSelect(OPERATIONS_LINK);
        }
        return OPERATIONS_LINK;
    }

    // not only for HOST
	public void setupOperTypeSelection() {
		CommonWizardStepInfo step = new CommonWizardStepInfo();
		step.setOrder(0);
		step.setSource(MbOperTypeSelectionStep.class.getSimpleName());
		step.setName(FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Opr", "select_oper_type"));
		List<CommonWizardStepInfo> stepsList = new ArrayList<CommonWizardStepInfo>();
		stepsList.add(step);
		Map<String, Object> context = new HashMap<String, Object>();
		context.put(MbCommonWizard.STEPS, stepsList);

		context.put(MbOperTypeSelectionStep.MODULE, getModule());
		context.put(MbOperTypeSelectionStep.OBJECT_ID, activeMessage.getId());
		context.put(MbOperTypeSelectionStep.ENTITY_TYPE, EntityNames.HOST_RECONCILIATION);

		MbCommonWizard wizard = ManagedBeanWrapper.getManagedBean(MbCommonWizard.class);
		wizard.init(context);
	}
}
