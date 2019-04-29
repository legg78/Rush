package ru.bpc.sv2.ui.application.wizard;

import org.apache.commons.lang3.StringUtils;
import ru.bpc.sv2.application.Application;
import ru.bpc.sv2.application.ApplicationElement;
import ru.bpc.sv2.application.ApplicationFlowFilter;
import ru.bpc.sv2.common.application.AppFlowStep;
import ru.bpc.sv2.constants.application.AppElements;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.invocation.SortElement;
import ru.bpc.sv2.logic.ApplicationDao;
import ru.bpc.sv2.application.DspApplication;
import ru.bpc.sv2.ui.common.application.ApplicationWizardContext;
import ru.bpc.sv2.ui.common.application.MbAppWizardFirstPage;
import ru.bpc.sv2.ui.common.application.MbWizard;
import ru.bpc.sv2.ui.utils.FacesUtils;
import util.auxil.ManagedBeanWrapper;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import java.math.BigDecimal;
import java.util.*;

@ViewScoped
@ManagedBean(name = "MbAppWizDspFlow")
public class MbAppWizDspFlow extends MbAppWizardFirstPage {
    public static final Integer DISPUTE_FLOW_ID = 1501;
    public static final Integer CM_ISS_FLOW_ID = 1502;
    public static final Integer CM_ACQ_FLOW_ID = 1504;

    public static final Integer DISPUTE_FLOW_FIRST_STEP = 1028;

    private Integer userId;
    private String userName;
    private String messageType;
    private BigDecimal writeOffAmount;
    private String writeOffCurrency;
    private String module;

    ApplicationDao _applicationDao = new ApplicationDao();

    public void create() {
        Application application = new Application();
        application.setInstId(instId);
        application.setAgentId(agentId);
        application.setUserId(userId);
        application.setUserName(userName);
        application.setFlowId(super.getFlowId());
        application.setAppType(getApplicationType());
        application.setAppSubType(getModule());
        application.setStatus(_applicationDao.getAppInitialStatus(userSessionId, super.getFlowId()));

        Map<Integer, ApplicationFlowFilter> applicationFilters = new HashMap<Integer, ApplicationFlowFilter>();
        ApplicationElement applicationRoot = _applicationDao.getApplicationStructure(userSessionId, application, applicationFilters);
        ApplicationElement aeFlowId = applicationRoot.getChildByName(AppElements.APPLICATION_FLOW_ID, 1);
        aeFlowId.setValueN(super.getFlowId());
        ApplicationElement aeAppStatus = applicationRoot.getChildByName(AppElements.APPLICATION_STATUS, 1);
        aeAppStatus.setValueV(application.getStatus());
        ApplicationElement aeAppType = applicationRoot.getChildByName(AppElements.APPLICATION_TYPE, 1);
        aeAppType.setValueV(getApplicationType());

        SelectionParams sp = new SelectionParams(new Filter("flowId", super.getFlowId()),
                                                 new Filter("lang", super.getCurLang()),
                                                 new Filter("appStatus", application.getStatus()));
        sp.setSortElement(new SortElement("displayOrder", SortElement.Direction.ASC));

        AppFlowStep[] appFlowStepsArr = _applicationDao.getAppFlowSteps(userSessionId, sp);
        appFlowSteps = Arrays.asList(appFlowStepsArr);
        if (appFlowSteps == null || appFlowSteps.isEmpty()){
            FacesUtils.addMessageError("There is no wizard steps for flow " + super.getFlowId()
                                       + " and status " + application.getStatus()
                                       + " has been found");
            return;
        }

        appFlowSteps.get(0).setKeyStep(true);
        MbWizard mbWizard = ManagedBeanWrapper.getManagedBean(MbDspWizard.class);
        ApplicationWizardContext ctx = new ApplicationWizardContext();
        ctx.setSteps(appFlowSteps);
        ctx.setApplicationFilters(applicationFilters);
        ctx.setApplicationRoot(applicationRoot);
        ctx.set("application", application);
        ctx.set("curMode", curMode);
        ctx.set("curLang", super.getCurLang());
        ctx.set("curType", getModule());

        mbWizard.init(ctx);
    }

    public void edit(DspApplication dspApplication) {
        Application application = dspApplication.toApplication();
        Map<Integer, ApplicationFlowFilter> applicationFilters = new HashMap<Integer, ApplicationFlowFilter>();
        ApplicationElement applicationStruct = _applicationDao.getApplicationStructure(userSessionId, application, applicationFilters);
        ApplicationElement rootAppEdit = _applicationDao.getApplicationForEdit(userSessionId, application);
        _applicationDao.mergeApplication(userSessionId, applicationStruct, rootAppEdit);

        if (rootAppEdit.getChildByName(AppElements.MESSAGE_TYPE, 1) != null) {
            if (rootAppEdit.getChildByName(AppElements.MESSAGE_TYPE, 1).getValueV() == null && messageType != null) {
                rootAppEdit.getChildByName(AppElements.MESSAGE_TYPE, 1).setValueV(messageType);
            }
        }
        if (rootAppEdit.getChildByName(AppElements.WRITE_OFF_AMOUNT, 1) != null) {
            if (rootAppEdit.getChildByName(AppElements.WRITE_OFF_AMOUNT, 1).getValueN() == null && writeOffAmount != null) {
                rootAppEdit.getChildByName(AppElements.WRITE_OFF_AMOUNT, 1).setValueN(writeOffAmount);
            }
        }
        if (rootAppEdit.getChildByName(AppElements.WRITE_OFF_CURRENCY, 1) != null) {
            if (rootAppEdit.getChildByName(AppElements.WRITE_OFF_CURRENCY, 1).getValueV() == null && writeOffCurrency != null) {
                rootAppEdit.getChildByName(AppElements.WRITE_OFF_CURRENCY, 1).setValueV(writeOffCurrency);
            }
        }
        if (dspApplication.getId() != null) {
            rootAppEdit.getChildByName(AppElements.APPLICATION_ID, 1).setValueN(BigDecimal.valueOf(dspApplication.getId()));
        }
        if (dspApplication.getType() != null) {
            rootAppEdit.getChildByName(AppElements.APPLICATION_TYPE, 1).setValueV(dspApplication.getType());
        }
        if (dspApplication.getFlowId() != null) {
            rootAppEdit.getChildByName(AppElements.APPLICATION_FLOW_ID, 1).setValueN(dspApplication.getFlowId());
        }
        if (dspApplication.getStatus() != null) {
            rootAppEdit.getChildByName(AppElements.APPLICATION_STATUS, 1).setValueV(dspApplication.getStatus());
        }
        if (dspApplication.getNewStatus() != null) {
            rootAppEdit.getChildByName(AppElements.APPLICATION_STATUS, 1).setValueV(dspApplication.getNewStatus());
        }
        if (dspApplication.getCustomerId() != null) {
            if (rootAppEdit.getChildByName(AppElements.CUSTOMER_ID, 1) != null) {
                rootAppEdit.getChildByName(AppElements.CUSTOMER_ID, 1).setValueN(BigDecimal.valueOf(dspApplication.getCustomerId()));
            }
        }
        if (dspApplication.getCustomerNumber() != null) {
            rootAppEdit.getChildByName(AppElements.CUSTOMER_NUMBER, 1).setValueV(dspApplication.getCustomerNumber());
        }
        if (StringUtils.isNotEmpty(dspApplication.getCardNumber())) {
            if (rootAppEdit.getChildByName(AppElements.CARD_NUMBER, 1) != null) {
                rootAppEdit.getChildByName(AppElements.CARD_NUMBER, 1).setValueV(dspApplication.getCardNumber());
                if (StringUtils.isNotEmpty(dspApplication.getCardMask())) {
                    rootAppEdit.getChildByName(AppElements.CARD_NUMBER, 1).setMask(dspApplication.getCardMask());
                }
            }
        }
        if (dspApplication.getAccountNumber() != null) {
            if (rootAppEdit.getChildByName(AppElements.ACCOUNT_NUMBER, 1) != null) {
                rootAppEdit.getChildByName(AppElements.ACCOUNT_NUMBER, 1).setValueV(dspApplication.getAccountNumber());
            }
        }
        if (dspApplication.getDisputeId() != null) {
            if (rootAppEdit.getChildByName(AppElements.DISPUTE_ID, 1) != null) {
                rootAppEdit.getChildByName(AppElements.DISPUTE_ID, 1).setValueN(BigDecimal.valueOf(dspApplication.getDisputeId()));
            }
        }
        if (dspApplication.getRejectCode() != null) {
            if (rootAppEdit.getChildByName(AppElements.DISPUTE_REASON, 1) != null) {
                rootAppEdit.getChildByName(AppElements.DISPUTE_REASON, 1).setValueV(dspApplication.getRejectCode());
            }
        }
        if (dspApplication.getOperId() != null) {
            if (rootAppEdit.getChildByName(AppElements.OPER_ID, 1) != null) {
                rootAppEdit.getChildByName(AppElements.OPER_ID, 1).setValueN(BigDecimal.valueOf(dspApplication.getOperId()));
            }
        }
        if (dspApplication.getTransactionDate() != null) {
            if (rootAppEdit.getChildByName(AppElements.OPER_DATE, 1) != null) {
                rootAppEdit.getChildByName(AppElements.OPER_DATE, 1).setValueD(dspApplication.getTransactionDate());
            }
        }
        if (dspApplication.getAmount() != null) {
            if (rootAppEdit.getChildByName(AppElements.OPER_AMOUNT, 1) != null) {
                rootAppEdit.getChildByName(AppElements.OPER_AMOUNT, 1).setValueN(dspApplication.getAmount());
            }
        }
        if (dspApplication.getCurrency() != null) {
            if (rootAppEdit.getChildByName(AppElements.OPER_CURRENCY, 1) != null) {
                rootAppEdit.getChildByName(AppElements.OPER_CURRENCY, 1).setValueV(dspApplication.getCurrency());
            }
        }
        if (dspApplication.getDisputedAmount() != null) {
            if (rootAppEdit.getChildByName(AppElements.DISPUTED_AMOUNT, 1) != null) {
                rootAppEdit.getChildByName(AppElements.DISPUTED_AMOUNT, 1).setValueN(dspApplication.getDisputedAmount());
            }
        }
        if (dspApplication.getDisputedCurrency() != null) {
            if (rootAppEdit.getChildByName(AppElements.DISPUTED_CURRENCY, 1) != null) {
                rootAppEdit.getChildByName(AppElements.DISPUTED_CURRENCY, 1).setValueV(dspApplication.getDisputedCurrency());
            }
        }
        if (dspApplication.getMerchantName() != null) {
            if (rootAppEdit.getChildByName(AppElements.MERCHANT_NAME, 1) != null) {
                rootAppEdit.getChildByName(AppElements.MERCHANT_NAME, 1).setValueV(dspApplication.getMerchantName());
            }
        }
        if (dspApplication.getAgentId() != null) {
            if (rootAppEdit.getChildByName(AppElements.AGENT_ID, 1) != null) {
                rootAppEdit.getChildByName(AppElements.AGENT_ID, 1).setValueN(BigDecimal.valueOf(dspApplication.getAgentId()));
            }
        }
        if (dspApplication.getInstId() != null) {
            if (rootAppEdit.getChildByName(AppElements.INSTITUTION_ID, 1) != null) {
                rootAppEdit.getChildByName(AppElements.INSTITUTION_ID, 1).setValueN(BigDecimal.valueOf(dspApplication.getInstId()));
            }
        }
        if (dspApplication.getUserId() != null) {
            if (rootAppEdit.getChildByName(AppElements.USER_ID, 1) != null) {
                rootAppEdit.getChildByName(AppElements.USER_ID, 1).setValueN(BigDecimal.valueOf(dspApplication.getUserId()));
            }
        }
        if (dspApplication.getUserName() != null) {
            if (rootAppEdit.getChildByName(AppElements.USER_NAME, 1) != null) {
                rootAppEdit.getChildByName(AppElements.USER_NAME, 1).setValueV(dspApplication.getUserName());
            }
        }
        if (dspApplication.getCreated() != null) {
            if (rootAppEdit.getChildByName(AppElements.APPLICATION_DATE, 1) != null) {
                rootAppEdit.getChildByName(AppElements.APPLICATION_DATE, 1).setValueD(dspApplication.getCreated());
            }
        } else {
            dspApplication.setCreated(new Date());
            application.setCreated(dspApplication.getCreated());
            if (rootAppEdit.getChildByName(AppElements.APPLICATION_DATE, 1) != null) {
                rootAppEdit.getChildByName(AppElements.APPLICATION_DATE, 1).setValueD(dspApplication.getCreated());
            }
        }
        if (dspApplication.getMessageType() != null) {
            if (rootAppEdit.getChildByName(AppElements.MESSAGE_TYPE, 1) != null) {
                rootAppEdit.getChildByName(AppElements.MESSAGE_TYPE, 1).setValueV(dspApplication.getMessageType());
            }
        }
        if (dspApplication.getWriteOffAmount() != null) {
            if (rootAppEdit.getChildByName(AppElements.WRITE_OFF_AMOUNT, 1) != null) {
                rootAppEdit.getChildByName(AppElements.WRITE_OFF_AMOUNT, 1).setValueN(dspApplication.getWriteOffAmount());
            }
        }
        if (dspApplication.getDisputeReason() != null) {
            if (rootAppEdit.getChildByName(AppElements.DISPUTE_REASON, 1) != null) {
                rootAppEdit.getChildByName(AppElements.DISPUTE_REASON, 1).setValueV(dspApplication.getDisputeReason());
            }
        }

        SelectionParams sp = new SelectionParams(new Filter("flowId", super.getFlowId()),
                                                 new Filter("lang", super.getCurLang()),
                                                 new Filter("appStatus", application.getStatus()));
        sp.setSortElement( new SortElement("displayOrder", SortElement.Direction.ASC));

        AppFlowStep[] appFlowStepsArr = _applicationDao.getAppFlowSteps(userSessionId, sp);
        appFlowSteps = Arrays.asList(appFlowStepsArr);
        if (appFlowSteps == null || appFlowSteps.isEmpty()){
            FacesUtils.addMessageError("There is no wizard flow has been found");
            return ;
        }
        appFlowSteps.get(0).setKeyStep(true);

        MbWizard mbWizard = ManagedBeanWrapper.getManagedBean(MbDspWizard.class);
        ApplicationWizardContext ctx = new ApplicationWizardContext();
        ctx.setSteps(appFlowSteps);
        ctx.setApplicationFilters(applicationFilters);
        ctx.setApplicationRoot(rootAppEdit);
        ctx.set("application", application);
        ctx.set("dspApp", dspApplication);
        ctx.set("curMode", curMode);
        ctx.set("curLang", super.getCurLang());
        ctx.set("curType", getModule());

        mbWizard.init(ctx);
    }

    public void edit(Application application){
        Map<Integer, ApplicationFlowFilter> applicationFilters = new HashMap<Integer, ApplicationFlowFilter>();
        ApplicationElement applicationStruct = _applicationDao.getApplicationStructure(userSessionId, application, applicationFilters);
        ApplicationElement rootAppEdit = _applicationDao.getApplicationForEdit(userSessionId, application);
        _applicationDao.mergeApplication(userSessionId, applicationStruct, rootAppEdit);

        if (rootAppEdit.getChildByName(AppElements.MESSAGE_TYPE, 1) != null) {
            if (rootAppEdit.getChildByName(AppElements.MESSAGE_TYPE, 1).getValueV() == null && messageType != null) {
                rootAppEdit.getChildByName(AppElements.MESSAGE_TYPE, 1).setValueV(messageType);
            }
        }
        if (rootAppEdit.getChildByName(AppElements.WRITE_OFF_AMOUNT, 1) != null) {
            if (rootAppEdit.getChildByName(AppElements.WRITE_OFF_AMOUNT, 1).getValueN() == null && writeOffAmount != null) {
                rootAppEdit.getChildByName(AppElements.WRITE_OFF_AMOUNT, 1).setValueN(writeOffAmount);
            }
        }
        if (rootAppEdit.getChildByName(AppElements.WRITE_OFF_CURRENCY, 1) != null) {
            if (rootAppEdit.getChildByName(AppElements.WRITE_OFF_CURRENCY, 1).getValueV() == null && writeOffCurrency != null) {
                rootAppEdit.getChildByName(AppElements.WRITE_OFF_CURRENCY, 1).setValueV(writeOffCurrency);
            }
        }

        SelectionParams sp = new SelectionParams(new Filter("flowId", super.getFlowId()),
                                                 new Filter("lang", super.getCurLang()),
                                                 new Filter("appStatus", application.getStatus()));
        sp.setSortElement( new SortElement("displayOrder", SortElement.Direction.ASC));

        AppFlowStep[] appFlowStepsArr = _applicationDao.getAppFlowSteps(userSessionId, sp);
        appFlowSteps = Arrays.asList(appFlowStepsArr);
        if (appFlowSteps == null || appFlowSteps.isEmpty()){
            FacesUtils.addMessageError("There is no wizard flow has been found");
            return ;
        }
        appFlowSteps.get(0).setKeyStep(true);

        MbWizard mbWizard = ManagedBeanWrapper.getManagedBean(MbDspWizard.class);
        ApplicationWizardContext ctx = new ApplicationWizardContext();
        ctx.setSteps(appFlowSteps);
        ctx.setApplicationFilters(applicationFilters);
        ctx.setApplicationRoot(rootAppEdit);
        ctx.set("application", application);
        ctx.set("curMode", curMode);
        ctx.set("curLang", super.getCurLang());
        ctx.set("curType", getModule());

        mbWizard.init(ctx);
    }

    public Integer getUserId() {
        return userId;
    }
    public void setUserId(Integer userId) {
        this.userId = userId;
    }

    public String getUserName() {
        return userName;
    }
    public void setUserName(String userName) {
        this.userName = userName;
    }

    public String getMessageType() {
        return messageType;
    }
    public void setMessageType(String messageType) {
        this.messageType = messageType;
    }

    public BigDecimal getWriteOffAmount() {
        return writeOffAmount;
    }
    public void setWriteOffAmount(BigDecimal writeOffAmount) {
        this.writeOffAmount = writeOffAmount;
    }

    public String getWriteOffCurrency() {
        return writeOffCurrency;
    }
    public void setWriteOffCurrency(String writeOffCurrency) {
        this.writeOffCurrency = writeOffCurrency;
    }

    public String getModule() {
        return module;
    }
    public void setModule(String module) {
        this.module = module;
    }
}
