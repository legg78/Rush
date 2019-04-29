package ru.bpc.sv2.ui.application.wizard;

import org.apache.commons.io.IOUtils;
import org.apache.commons.lang3.StringUtils;
import org.apache.log4j.Logger;
import org.richfaces.event.UploadEvent;
import org.richfaces.model.UploadItem;
import org.richfaces.model.selection.SimpleSelection;
import ru.bpc.sv2.application.Application;
import ru.bpc.sv2.application.ApplicationElement;
import ru.bpc.sv2.application.DspApplication;
import ru.bpc.sv2.common.application.AppIssRejectCodes;
import ru.bpc.sv2.common.application.ApplicationStatuses;
import ru.bpc.sv2.constants.DictNames;
import ru.bpc.sv2.constants.EntityNames;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.constants.ModuleNames;
import ru.bpc.sv2.constants.application.AppElements;
import ru.bpc.sv2.constants.application.ApplicationConstants;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.issuing.Card;
import ru.bpc.sv2.logic.ApplicationDao;
import ru.bpc.sv2.logic.IssuingDao;
import ru.bpc.sv2.logic.ReportsDao;
import ru.bpc.sv2.logic.RolesDao;
import ru.bpc.sv2.operations.Operation;
import ru.bpc.sv2.products.Customer;
import ru.bpc.sv2.reports.RptDocument;
import ru.bpc.sv2.rules.DspApplicationFile;
import ru.bpc.sv2.ui.common.application.AppWizStep;
import ru.bpc.sv2.ui.common.application.ApplicationWizardContext;
import ru.bpc.sv2.ui.issuing.MbCardSearchModal;
import ru.bpc.sv2.ui.issuing.MbCardsSearch;
import ru.bpc.sv2.ui.operations.MbOperationSearchModal;
import ru.bpc.sv2.ui.products.MbCustomerSearchModal;
import ru.bpc.sv2.ui.rules.MbDspApplications;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.RequestContextHolder;
import ru.bpc.sv2.ui.utils.cache.DictCache;
import ru.bpc.sv2.utils.SystemUtils;
import util.auxil.ManagedBeanWrapper;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.context.FacesContext;
import javax.faces.model.SelectItem;
import javax.servlet.http.HttpServletResponse;
import java.io.*;
import java.math.BigDecimal;
import java.net.URLEncoder;
import java.util.*;

import static ru.bpc.sv2.utils.AppStructureUtils.instance;
import static ru.bpc.sv2.utils.AppStructureUtils.retrive;

@ViewScoped
@ManagedBean(name = "MbAppWizDspNew")
public class MbAppWizDspNew extends AbstractBean implements AppWizStep, Serializable {
    private static final Logger logger = Logger.getLogger(MbAppWizDspNew.class);
    private String appPage = "/pages/acquiring/applications/wizard/appWizDspNew.jspx";
    private String cmPage = "/pages/acquiring/applications/wizard/appWizCaseManagementNew.jspx";

    public final static String IDENT_TYPE_UNDEFINED = "CITPUNKN";
    public final static String IDENT_TYPE_NONE = "CITPNONE";
    public final static String IDENT_TYPE_CARD = "CITPCARD";
    public final static String IDENT_TYPE_ACCOUNT = "CITPACCT";
    public final static String IDENT_TYPE_PHONE = "CITPMBPH";
    public final static String IDENT_TYPE_EMAIL = "CITPEMAI";
    public final static String IDENT_TYPE_CUSTOMER = "CITPCUST";
    public final static String IDENT_TYPE_CONTRACT = "CITPCNTR";

    private ApplicationWizardContext appWizCtx;
    private ApplicationElement applicationRoot;
    private DspApplicationFile selectedDspApplicationFile;

    private DspApplication newDspApplication;
    private SimpleSelection fileItemSelection;
    private List<SelectItem> institutions;
    private List<SelectItem> flows;
    private List<SelectItem> statuses;

    private Integer instId;
    private Integer agentId;
    private Integer flowId;
    private String module;
    private boolean fileExists;

    private DspApplicationFile newDspApplicationFile;

    protected int curMode;
    protected int curModeFile;

    private RolesDao _rolesDao = new RolesDao();

    private ApplicationDao applicationDao = new ApplicationDao();

    private ReportsDao reportsDao = new ReportsDao();

    private IssuingDao issuingDao = new IssuingDao();

    @Override
    public void clearFilter() {

    }

    @Override
    public ApplicationWizardContext release() {
        appWizCtx.setApplicationRoot(applicationRoot);
        Application app = (Application)appWizCtx.get("application");
        if (newDspApplication.getId() != null) {
            applicationRoot.getChildByName(AppElements.APPLICATION_ID, 1).setValueN(BigDecimal.valueOf(newDspApplication.getId()));
            app.setId(newDspApplication.getId());
        }
        if (newDspApplication.getType() != null) {
            applicationRoot.getChildByName(AppElements.APPLICATION_TYPE, 1).setValueV(newDspApplication.getType());
            app.setAppType(newDspApplication.getType());
        }
        if (newDspApplication.getSubType() != null) {
            app.setAppSubType(newDspApplication.getSubType());
        }
        if (newDspApplication.getFlowId() != null) {
            applicationRoot.getChildByName(AppElements.APPLICATION_FLOW_ID, 1).setValueN(newDspApplication.getFlowId());
            app.setFlowId(newDspApplication.getFlowId());
        }
        if (newDspApplication.getStatus() != null) {
            applicationRoot.getChildByName(AppElements.APPLICATION_STATUS, 1).setValueV(newDspApplication.getStatus());
            app.setStatus(newDspApplication.getStatus());
        }
        if (newDspApplication.getNewStatus() != null) {
            applicationRoot.getChildByName(AppElements.APPLICATION_STATUS, 1).setValueV(newDspApplication.getNewStatus());
            app.setStatus(newDspApplication.getNewStatus());
        }
        if (newDspApplication.getCustomerId() != null) {
            if (applicationRoot.getChildByName(AppElements.CUSTOMER_ID, 1) != null) {
                applicationRoot.getChildByName(AppElements.CUSTOMER_ID, 1).setValueN(BigDecimal.valueOf(newDspApplication.getCustomerId()));
            }
            app.setCustomerId(newDspApplication.getCustomerId());
        }
        if (newDspApplication.getCustomerNumber() != null) {
            if (applicationRoot.getChildByName(AppElements.CUSTOMER_NUMBER, 1) != null) {
                applicationRoot.getChildByName(AppElements.CUSTOMER_NUMBER, 1).setValueV(newDspApplication.getCustomerNumber());
            }
            app.setCustomerNumber(newDspApplication.getCustomerNumber());
        }
        if (StringUtils.isNotEmpty(newDspApplication.getCardNumber())) {
            if (applicationRoot.getChildByName(AppElements.CARD_NUMBER, 1) != null) {
                applicationRoot.getChildByName(AppElements.CARD_NUMBER, 1).setValueV(newDspApplication.getCardNumber());
                if (StringUtils.isNotEmpty(newDspApplication.getCardMask())) {
                    applicationRoot.getChildByName(AppElements.CARD_NUMBER, 1).setMask(newDspApplication.getCardMask());
                }
            }
            app.setCardNumber(newDspApplication.getCardNumber());
        }
        if (newDspApplication.getAccountNumber() != null) {
            if (applicationRoot.getChildByName(AppElements.ACCOUNT_NUMBER, 1) != null) {
                applicationRoot.getChildByName(AppElements.ACCOUNT_NUMBER, 1).setValueV(newDspApplication.getAccountNumber());
            }
            app.setAccountNumber(newDspApplication.getAccountNumber());
        }
        if (newDspApplication.getDisputeId() != null) {
            if (applicationRoot.getChildByName(AppElements.DISPUTE_ID, 1) != null) {
                applicationRoot.getChildByName(AppElements.DISPUTE_ID, 1).setValueN(BigDecimal.valueOf(newDspApplication.getDisputeId()));
            }
        }
        if (newDspApplication.getRejectCode() != null) {
            if (applicationRoot.getChildByName(AppElements.DISPUTE_REASON, 1) != null) {
                applicationRoot.getChildByName(AppElements.DISPUTE_REASON, 1).setValueV(newDspApplication.getRejectCode());
            }
            app.setRejectCode(newDspApplication.getRejectCode());
        }
        if (newDspApplication.getOperId() != null) {
            if (applicationRoot.getChildByName(AppElements.OPER_ID, 1) != null) {
                applicationRoot.getChildByName(AppElements.OPER_ID, 1).setValueN(BigDecimal.valueOf(newDspApplication.getOperId()));
            }
            app.setOperId(newDspApplication.getOperId());
        }
        if (newDspApplication.getTransactionDate() != null) {
            if (applicationRoot.getChildByName(AppElements.OPER_DATE, 1) != null) {
                applicationRoot.getChildByName(AppElements.OPER_DATE, 1).setValueD(newDspApplication.getTransactionDate());
            }
        }
        if (newDspApplication.getAmount() != null) {
            if (applicationRoot.getChildByName(AppElements.OPER_AMOUNT, 1) != null) {
                applicationRoot.getChildByName(AppElements.OPER_AMOUNT, 1).setValueN(newDspApplication.getAmount());
            }
        }
        if (newDspApplication.getCurrency() != null) {
            if (applicationRoot.getChildByName(AppElements.OPER_CURRENCY, 1) != null) {
                applicationRoot.getChildByName(AppElements.OPER_CURRENCY, 1).setValueV(newDspApplication.getCurrency());
            }
        }
        if (newDspApplication.getDisputedAmount() != null) {
            if (applicationRoot.getChildByName(AppElements.DISPUTED_AMOUNT, 1) != null) {
                applicationRoot.getChildByName(AppElements.DISPUTED_AMOUNT, 1).setValueN(newDspApplication.getDisputedAmount());
            }
        }
        if (newDspApplication.getDisputedCurrency() != null) {
            if (applicationRoot.getChildByName(AppElements.DISPUTED_CURRENCY, 1) != null) {
                applicationRoot.getChildByName(AppElements.DISPUTED_CURRENCY, 1).setValueV(newDspApplication.getDisputedCurrency());
            }
        }
        if (newDspApplication.getMerchantName() != null) {
            if (applicationRoot.getChildByName(AppElements.MERCHANT_NAME, 1) != null) {
                applicationRoot.getChildByName(AppElements.MERCHANT_NAME, 1).setValueV(newDspApplication.getMerchantName());
            }
        }
        if (newDspApplication.getAgentId() != null) {
            if (applicationRoot.getChildByName(AppElements.AGENT_ID, 1) != null) {
                applicationRoot.getChildByName(AppElements.AGENT_ID, 1).setValueN(BigDecimal.valueOf(newDspApplication.getAgentId()));
            }
            app.setAgentId(newDspApplication.getAgentId());
        }
        if (newDspApplication.getInstId() != null) {
            if (applicationRoot.getChildByName(AppElements.INSTITUTION_ID, 1) != null) {
                applicationRoot.getChildByName(AppElements.INSTITUTION_ID, 1).setValueN(BigDecimal.valueOf(newDspApplication.getInstId()));
            }
            app.setInstId(newDspApplication.getInstId());
        }
        if (newDspApplication.getUserId() != null) {
            if (applicationRoot.getChildByName(AppElements.USER_ID, 1) != null) {
                applicationRoot.getChildByName(AppElements.USER_ID, 1).setValueN(BigDecimal.valueOf(newDspApplication.getUserId()));
            }
            app.setUserId(newDspApplication.getUserId());
        }
        if (newDspApplication.getUserName() != null) {
            if (applicationRoot.getChildByName(AppElements.USER_NAME, 1) != null) {
                applicationRoot.getChildByName(AppElements.USER_NAME, 1).setValueV(newDspApplication.getUserName());
            }
            app.setUserName(newDspApplication.getUserName());
        }
        if (newDspApplication.getCreated() != null) {
            app.setCreated(newDspApplication.getCreated());
            if (applicationRoot.getChildByName(AppElements.APPLICATION_DATE, 1) != null) {
                applicationRoot.getChildByName(AppElements.APPLICATION_DATE, 1).setValueD(newDspApplication.getCreated());
            }
        } else {
            newDspApplication.setCreated(new Date());
            app.setCreated(newDspApplication.getCreated());
            if (applicationRoot.getChildByName(AppElements.APPLICATION_DATE, 1) != null) {
                applicationRoot.getChildByName(AppElements.APPLICATION_DATE, 1).setValueD(newDspApplication.getCreated());
            }
        }
        if (newDspApplication.getEventType() != null) {
            app.setEventType(newDspApplication.getEventType());
        }
        if (newDspApplication.getComment() != null) {
            app.setComment(newDspApplication.getComment());
        }
        if (newDspApplication.getMessageType() != null) {
            if (applicationRoot.getChildByName(AppElements.MESSAGE_TYPE, 1) != null) {
                applicationRoot.getChildByName(AppElements.MESSAGE_TYPE, 1).setValueV(newDspApplication.getMessageType());
            }
        }
        if (newDspApplication.getWriteOffAmount() != null) {
            if (applicationRoot.getChildByName(AppElements.WRITE_OFF_AMOUNT, 1) != null) {
                applicationRoot.getChildByName(AppElements.WRITE_OFF_AMOUNT, 1).setValueN(newDspApplication.getWriteOffAmount());
            }
        }
        if (newDspApplication.getDisputeReason() != null) {
            if (applicationRoot.getChildByName(AppElements.DISPUTE_REASON, 1) != null) {
                applicationRoot.getChildByName(AppElements.DISPUTE_REASON, 1).setValueV(newDspApplication.getDisputeReason());
            }
        }
        if (app.getStatus() == null || app.getStatus().isEmpty()) {
            newDspApplication.setStatus(applicationDao.getAppInitialStatus(userSessionId, newDspApplication.getFlowId()));
            applicationRoot.getChildByName(AppElements.APPLICATION_STATUS, 1).setValueV(newDspApplication.getStatus());
            app.setStatus(newDspApplication.getStatus());
        }
        if (app.getRejectCode() == null || app.getRejectCode().isEmpty()) {
            List<SelectItem> codes = getActualRejectCodes();
            if (codes.size() > 0 && codes.get(0).getValue() != null) {
                newDspApplication.setRejectCode(codes.get(0).getValue().toString());
                applicationRoot.getChildByName(AppElements.DISPUTE_REASON, 1).setValueV(newDspApplication.getRejectCode());
                app.setRejectCode(newDspApplication.getRejectCode());
            }
        }
        appWizCtx.setApplicationRoot(applicationRoot);
        appWizCtx.set("attachFiles", newDspApplication.getFiles());
        appWizCtx.set("application", app);
        appWizCtx.set("dspApp", newDspApplication);
        applicationRoot = null;
        return appWizCtx;
    }

    @Override
    public void init(ApplicationWizardContext ctx) {
        logger.trace("MbAppWizDspNew::init(ApplicationWizardContext)...");

        newDspApplication = new DspApplication();
        appWizCtx = ctx;
        applicationRoot = ctx.getApplicationRoot();
        setCurMode((Integer)ctx.get("curMode"));
        setCurMode((Integer)ctx.get("curMode"));
        DspApplication dspApp = null;
        if (ctx.get("dspApp") != null) {
            dspApp = (DspApplication)ctx.get("dspApp");
        }
        if (!isNewMode()) {
            if (applicationRoot.getChildByName(AppElements.OPER_DATE, 1) != null) {
                newDspApplication.setTransactionDate(applicationRoot.getChildByName(AppElements.OPER_DATE, 1).getValueD());
            }
            if (applicationRoot.getChildByName(AppElements.OPER_AMOUNT, 1) != null) {
                if (applicationRoot.getChildByName(AppElements.OPER_AMOUNT, 1).getValueN() != null) {
                    newDspApplication.setAmount(applicationRoot.getChildByName(AppElements.OPER_AMOUNT, 1).getValueN());
                }
            }
            if (applicationRoot.getChildByName(AppElements.DISPUTED_AMOUNT, 1) != null) {
                if (applicationRoot.getChildByName(AppElements.DISPUTED_AMOUNT, 1).getValueN() != null) {
                    newDspApplication.setDisputedAmount(applicationRoot.getChildByName(AppElements.DISPUTED_AMOUNT, 1).getValueN());
                }
            }
            if (applicationRoot.getChildByName(AppElements.DISPUTED_CURRENCY, 1) != null) {
                newDspApplication.setDisputedCurrency(applicationRoot.getChildByName(AppElements.DISPUTED_CURRENCY, 1).getValueV());
            }
            /*
            if (applicationRoot.getChildByName(AppElements.WRITE_OFF_AMOUNT, 1) != null) {
                if (applicationRoot.getChildByName(AppElements.WRITE_OFF_AMOUNT, 1).getValueN() != null) {
                    newDspApplication.setDisputedAmount(applicationRoot.getChildByName(AppElements.WRITE_OFF_AMOUNT, 1).getValueN());
                }
            }
            if (applicationRoot.getChildByName(AppElements.WRITE_OFF_CURRENCY, 1) != null) {
                newDspApplication.setDisputedCurrency(applicationRoot.getChildByName(AppElements.WRITE_OFF_CURRENCY, 1).getValueV());
            }
            */
            if (applicationRoot.getChildByName(AppElements.MERCHANT_NAME, 1) != null) {
                newDspApplication.setMerchantName(applicationRoot.getChildByName(AppElements.MERCHANT_NAME, 1).getValueV());
            }
            if (applicationRoot.getChildByName(AppElements.OPER_CURRENCY, 1) != null) {
                newDspApplication.setCurrency(applicationRoot.getChildByName(AppElements.OPER_CURRENCY, 1).getValueV());
            }
            if (applicationRoot.getChildByName(AppElements.AGENT_ID, 1) != null) {
                newDspApplication.setAgentId(Integer.valueOf(applicationRoot.getChildByName(AppElements.AGENT_ID, 1).getValueN().toString()));
            }
            if (applicationRoot.getChildByName(AppElements.AGENT_ID, 1) != null) {
                newDspApplication.setAgentName(applicationRoot.getChildByName(AppElements.AGENT_ID, 1).getLovValue());
            }
            if (applicationRoot.getChildByName(AppElements.INSTITUTION_ID, 1) != null) {
                newDspApplication.setInstId(Integer.valueOf(applicationRoot.getChildByName(AppElements.INSTITUTION_ID, 1).getValueN().toString()));
                newDspApplication.setInstName(applicationRoot.getChildByName(AppElements.INSTITUTION_ID, 1).getLovValue());
            }
            if (applicationRoot.getChildByName(AppElements.DISPUTE_REASON, 1) != null) {
                newDspApplication.setRejectCode(applicationRoot.getChildByName(AppElements.DISPUTE_REASON, 1).getValueV());
                newDspApplication.setDisputeReason(applicationRoot.getChildByName(AppElements.DISPUTE_REASON, 1).getValueV());
            }
            if (applicationRoot.getChildByName(AppElements.CUSTOMER_NUMBER, 1) != null) {
                newDspApplication.setCustomerNumber(applicationRoot.getChildByName(AppElements.CUSTOMER_NUMBER, 1).getValueV());
            }
            if (applicationRoot.getChildByName(AppElements.CARD_NUMBER, 1) != null) {
                newDspApplication.setCardNumber(applicationRoot.getChildByName(AppElements.CARD_NUMBER, 1).getValueV());
                newDspApplication.setCardMask(applicationRoot.getChildByName(AppElements.CARD_NUMBER, 1).getMask());
                newDspApplication.setOperCardMask(applicationRoot.getChildByName(AppElements.CARD_NUMBER, 1).getValueV());
            }
            if (applicationRoot.getChildByName(AppElements.OPER_ID, 1) != null) {
                newDspApplication.setOperId(Long.valueOf(applicationRoot.getChildByName(AppElements.OPER_ID, 1).getValueN().toString()));
            }
            if (applicationRoot.getChildByName(AppElements.DISPUTE_ID, 1) != null) {
                if (applicationRoot.getChildByName(AppElements.DISPUTE_ID, 1).getValueN() != null) {
                    newDspApplication.setDisputeId(Long.valueOf(applicationRoot.getChildByName(AppElements.DISPUTE_ID, 1).getValueN().toString()));
                }
            }
            if (applicationRoot.getChildByName(AppElements.ACCOUNT_NUMBER, 1) != null) {
                newDspApplication.setAccountNumber(applicationRoot.getChildByName(AppElements.ACCOUNT_NUMBER, 1).getValueV());
            }
            if (applicationRoot.getChildByName(AppElements.MESSAGE_TYPE, 1) != null) {
                newDspApplication.setMessageType(applicationRoot.getChildByName(AppElements.MESSAGE_TYPE, 1).getValueV());
            }

            List<DspApplicationFile> files = new ArrayList<DspApplicationFile>();
            newDspApplication.setFiles(files);
            if (ctx.get("application") != null) {
                Application app = (Application)ctx.get("application");
                addFiles(app.getId(), files);
                if (app.getId() != null) {
                    newDspApplication.setId(app.getId());
                }
                if (app.getApplNumber() != null) {
                    newDspApplication.setApplicationNumber(app.getApplNumber());
                }
                if (app.getInstId() != null) {
                    newDspApplication.setInstId(app.getInstId());
                }
                if (app.getAgentId() != null) {
                    newDspApplication.setAgentId(app.getAgentId());
                }
                if (app.getFlowId() != null) {
                    newDspApplication.setFlowId(app.getFlowId());
                }
                if (app.getAppType() != null) {
                    newDspApplication.setType(app.getAppType());
                }
                if (app.getStatus() != null) {
                    newDspApplication.setStatus(app.getStatus());
                }
                if (app.getMerchantNumber() != null) {
                    newDspApplication.setMerchantNumber(app.getMerchantNumber());
                }
                if (app.getAccountNumber() != null) {
                    newDspApplication.setAccountNumber(app.getAccountNumber());
                }
                if (app.getCustomerId() != null) {
                    newDspApplication.setCustomerId(app.getCustomerId());
                }
                if (app.getCustomerNumber() != null) {
                    newDspApplication.setCustomerNumber(app.getCustomerNumber());
                }
                if (app.getCreated() != null) {
                    newDspApplication.setApplicationDate(app.getCreated());
                }
                if (app.getRejectCode() != null) {
                    newDspApplication.setRejectCode(app.getRejectCode());
                }
                if (app.getUserId() != null) {
                    newDspApplication.setUserId(app.getUserId());
                }
                if (app.getUserName() != null) {
                    newDspApplication.setUserName(app.getUserName());
                }
                if (app.getEventType() != null) {
                    newDspApplication.setEventType(app.getEventType());
                }
                if (app.getOperId() != null) {
                    newDspApplication.setOperId(app.getOperId());
                }
            }

            if (newDspApplication.getCustomerId() == null && newDspApplication.getCustomerNumber() != null) {
                try {
                    Map<String, Object> param = new HashMap<String, Object>();
                    param.put("customerNumber", newDspApplication.getCustomerNumber());
                    param.put("userLang", userLang);
                    Map<String, Object> info = applicationDao.getCustomerInfo(userSessionId, param);
                    newDspApplication.setCustomerId(Long.valueOf(info.get("customerId").toString()));
                    newDspApplication.setCustomerInfo(info.get("customerName").toString());
                } catch (Exception e) {
                    logger.trace("", e);
                }
            }

            if (dspApp != null) {
                try {
                    newDspApplication = (DspApplication) dspApp.clone();
                } catch (CloneNotSupportedException e) {
                    e.printStackTrace();
                }
            }
        } else if (ctx.get("application") != null) {
            Application app = (Application)ctx.get("application");
            if (app.getUserId() != null) {
                newDspApplication.setUserId(app.getUserId());
            }
            if (app.getUserName() != null) {
                newDspApplication.setUserName(app.getUserName());
            }
            if (app.getAppSubType() != null) {
                newDspApplication.setSubType(app.getAppSubType());
            }
            if (app.getFlowId() != null) {
                if (newDspApplication.getSubType()!= null && newDspApplication.getSubType().equals(ApplicationConstants.TYPE_DISPUTES)) {
                    newDspApplication.setFlowId(app.getFlowId());
                }
            }
            if (app.getFlowId() != null) {
                newDspApplication.setUserName(app.getUserName());
            }
        }

        if (newDspApplication.getType() == null) {
            newDspApplication.setType(ApplicationConstants.TYPE_DISPUTES);
        }

        newDspApplication.setTypeDesc(getDictUtils().getArticlesMap(DictNames.AP_TYPES).get(ApplicationConstants.TYPE_DISPUTES));
        instId = ((Application)appWizCtx.get("application")).getInstId();
        agentId = ((Application)appWizCtx.get("application")).getAgentId();
        module = ((Application)appWizCtx.get("application")).getAppSubType();
        newDspApplication.setSubType(((Application)appWizCtx.get("application")).getAppSubType());
        if (ctx.get("curType") != null && !ctx.get("curType").equals(ApplicationConstants.TYPE_DISPUTES)) {
            ctx.setStepPage(cmPage);
        } else {
            ctx.setStepPage(appPage);
        }
    }

    public void addFiles(Long objectId, List<DspApplicationFile> files){
        RptDocument[] documents = reportsDao.getDocumentContents(userSessionId, SelectionParams.build("lang", curLang, "objectId", objectId, "entityType", EntityNames.APPLICATION));
        DspApplicationFile dspDocument;
        for(RptDocument document : documents){
            dspDocument = new DspApplicationFile();
            dspDocument.setName(document.getFileName());
            dspDocument.setType(document.getDocumentType());
            dspDocument.setNewFile(false);
            dspDocument.setSavePath(document.getSavePath());
            files.add(dspDocument);
        }
    }

    @Override
    public boolean validate() {
        return true;
    }

    @Override
    public boolean checkKeyModifications() {
        return false;
    }

    @Override
    public boolean getLock() {
        return true;
    }

    private ApplicationElement createElement(ApplicationElement parent, String elementName, String command){
        ApplicationElement result = null;
        try{
            Integer intId = retrive(applicationRoot, AppElements.INSTITUTION_ID).getValueN().intValue();
            Application appStub = new Application();
            appStub.setInstId(intId);
            appStub.setFlowId(((Application)appWizCtx.get("application")).getFlowId());

            result = instance(parent, elementName);
            applicationDao.fillRootChilds(userSessionId, intId, result, appWizCtx.getApplicationFilters());

            if(command != null) {
                retrive(result, AppElements.COMMAND).setValueV(command);
            }
            applicationDao.applyDependencesWhenAdd(userSessionId, appStub, result, appWizCtx.getApplicationFilters());
        }catch(Exception e){
            FacesUtils.addMessageError(e);
            logger.error("", e);
        }
        return result;
    }

    public DspApplication getNewDspApplication() {
        if (newDspApplication == null) {
            newDspApplication = new DspApplication();
        }
        return newDspApplication;
    }

    public SimpleSelection getFileItemSelection() {
        return fileItemSelection;
    }

    public void setFileItemSelection(SimpleSelection fileItemSelection) {
        this.fileItemSelection = fileItemSelection;
        if (getDspApplicationFiles() == null || getDspApplicationFiles().size() == 0) return;
        selectedDspApplicationFile = getDspApplicationFiles().get(selectedIdx());
    }

    public DspApplicationFile getSelectedDspApplicationFile(){
        return selectedDspApplicationFile;
    }

    private Integer selectedIdx(){
        Iterator<Object> keys = fileItemSelection.getKeys();
        if (!keys.hasNext()) return 0;
        Integer index = (Integer) keys.next();
        return index;
    }

    public List<DspApplicationFile> getDspApplicationFiles() {
        if(newDspApplication == null || newDspApplication.getFiles() == null){
            return new ArrayList<DspApplicationFile>();
        }
        return newDspApplication.getFiles();
    }

    public DspApplicationFile getNewDspApplicationFile(){
        if (newDspApplicationFile == null) {
            newDspApplicationFile = new DspApplicationFile();
        }
        return newDspApplicationFile;
    }

    public void addFile() {
        newDspApplicationFile = new DspApplicationFile();
        curModeFile = NEW_MODE;
    }

    public void editFile() {
        try {
            newDspApplicationFile = (DspApplicationFile) selectedDspApplicationFile.clone();
        } catch (CloneNotSupportedException e) {
            FacesUtils.addMessageError(e);
            logger.error("", e);
        }
        curModeFile = EDIT_MODE;
    }

    public void viewFile() {
        try {
            newDspApplicationFile = (DspApplicationFile) selectedDspApplicationFile.clone();
        } catch (CloneNotSupportedException e) {
            FacesUtils.addMessageError(e);
            logger.error("", e);
        }
        curModeFile = VIEW_MODE;
    }

    public void saveFile(){
        if(curModeFile == NEW_MODE || curModeFile == UNKNOWN_MODE) {
            if (newDspApplication.getFiles() == null) {
                newDspApplication.setFiles(new ArrayList<DspApplicationFile>());
            }
            newDspApplication.getFiles().add(newDspApplicationFile);
        } else if(curModeFile == EDIT_MODE){
            newDspApplication.getFiles().set(selectedIdx(), newDspApplicationFile);
        }
        selectedDspApplicationFile = newDspApplicationFile;
    }

    //TODO Add function for adding save file in existing application

    public void saveFilesInExistingAppl() {
        ApplicationWizardContext wizardContext = new ApplicationWizardContext();
        if (curModeFile == NEW_MODE || curModeFile == UNKNOWN_MODE) {
            List<DspApplicationFile> files = new ArrayList<DspApplicationFile>();
            files.add(newDspApplicationFile);
            wizardContext.set("attachFiles", files);
        }
            try {
                MbDspWizard mbDspWizard = (MbDspWizard) ManagedBeanWrapper.getManagedBean("MbDspWizard");
                mbDspWizard.setContext(wizardContext);
                MbDspApplications mbDspApplications = (MbDspApplications) ManagedBeanWrapper.getManagedBean("MbDspApplications");
                DspApplication curDspAppl = mbDspApplications.getActiveDspApplication();
                if (curDspAppl != null) {
                    mbDspWizard.saveFiles(curDspAppl.getId(), curDspAppl.getStatus(), curDspAppl.getRejectCode());
                }
                else if (mbDspApplications.getActiveDspApplications() != null) {
                    List<DspApplication> curDspAppls = mbDspApplications.getActiveDspApplications();
                    Long[] applIds = new Long[curDspAppls.size()];
                    for (int i = 0; i < applIds.length; ++i) {
                        applIds[i] = curDspAppls.get(i).getId();
                    }
                    mbDspWizard.saveFiles(applIds);

                }
                mbDspApplications.loadTab(mbDspApplications.TAB_ATTACHMENT);
            } catch (Exception e) {
                FacesUtils.addMessageError(e);
                logger.error("", e);
            }
    }
    
    public void closeAttFile() {
        curModeFile = VIEW_MODE;
    }

    public void deleteFile() {
        try {
            curModeFile = VIEW_MODE;
            newDspApplication.getFiles().remove(selectedIdx().intValue());
        } catch (Exception e) {
            FacesUtils.addMessageError(e);
            logger.error("", e);
        }
    }

    public boolean isEditFileMode() {
        return curModeFile == EDIT_MODE;
    }

    public boolean isNewFileMode() {
        return curModeFile == NEW_MODE;
    }

    public boolean isViewFileMode(){
        return curModeFile == VIEW_MODE;
    }

    public void fileUploadListener(UploadEvent event) throws Exception {
        UploadItem item = event.getUploadItem();
        if (!checkMaximumFileSize(item.getFileSize())) {
            FacesUtils.addMessageError("File size is too big");
            logger.error("File size is too big");
        }
        try {
            FileInputStream fis = new FileInputStream(item.getFile());
            int len;
            ByteArrayOutputStream baos = new ByteArrayOutputStream();
            byte[] buf = new byte[1024];
            while ((len = fis.read(buf)) > 0) {
                baos.write(buf, 0, len);
            }
            baos.flush();
            getNewDspApplicationFile().setBytes(baos.toByteArray());
            getNewDspApplicationFile().setName(item.getFileName());
            getNewDspApplicationFile().setNewFile(true);
            getNewDspApplicationFile().setSavePath(item.getFile().getPath());
        } catch (Exception e) {
            FacesUtils.addMessageError(e);
            logger.error("", e);
        }
    }

    public void checkFile(){
        if(selectedDspApplicationFile.isNewFile()){
            fileExists = true;
            return;
        }
        File file = new File(selectedDspApplicationFile.getSavePath());
        if(file.exists()){
            fileExists = true;
        }else{
            fileExists = false;
        }
    }

    public void download() throws IOException {
        HttpServletResponse res = RequestContextHolder.getResponse();
        res.setContentType("application/x-download");
        String URLEncodedFileName = URLEncoder.encode(selectedDspApplicationFile.getName(), "UTF-8");
        res.setHeader("Content-Disposition", "attachment; filename=\"" + URLEncodedFileName + "\"");

        if(!selectedDspApplicationFile.isNewFile()) {
            File file = new File(selectedDspApplicationFile.getSavePath());
            SystemUtils.copy(file, res.getOutputStream());
        }else{
            IOUtils.copy(new ByteArrayInputStream(selectedDspApplicationFile.getBytes()), res.getOutputStream());
        }
        FacesContext.getCurrentInstance().responseComplete();
    }

    public List<SelectItem> getAgents() {
        Map<String, Object> paramMap = new HashMap<String, Object>();
        if (getNewDspApplication().getInstId() != null) {
            paramMap.put("INSTITUTION_ID", getNewDspApplication().getInstId());
        }
        return getDictUtils().getLov(LovConstants.AGENTS, paramMap);
    }

    public List<SelectItem> getInstitutions() {
        if (institutions == null) {
            institutions = getDictUtils().getLov(LovConstants.INSTITUTIONS);
        }
        return institutions;
    }

    public List<SelectItem> getFlows() {
        Map<String, Object> paramMap = new HashMap<String, Object>();
        paramMap.put("appl_type", ApplicationConstants.TYPE_DISPUTES);
        paramMap.put("appl_subtype", module);
        return getDictUtils().getLov(LovConstants.EXTENDED_APPLICATION_FLOWS, paramMap);
    }

    public SelectItem getFlow() {
        if (getNewDspApplication().getFlowId() != null) {
            Map<String, Object> paramMap = new HashMap<String, Object>();
            paramMap.put("appl_type", ApplicationConstants.TYPE_DISPUTES);
            paramMap.put("appl_subtype", module);
            List<SelectItem>tmp = getDictUtils().getLov(LovConstants.EXTENDED_APPLICATION_FLOWS, paramMap);
            for (SelectItem flow : tmp) {
                if (Integer.valueOf(flow.getValue().toString()).equals(getNewDspApplication().getFlowId())) {
                    return new SelectItem(flow.getValue(), flow.getLabel(), flow.getDescription());
                }
            }
        }
        return null;
    }
    public String getFlowLabel() {
        SelectItem flow = getFlow();
        if (flow != null) {
            return new String(flow.getLabel());
        }
        return "";
    }

    private List<SelectItem> getActualRejectCodes() {
        Map<String, Object> paramMap = new HashMap<String, Object>();
        if (getNewDspApplication().getFlowId() != null) {
            paramMap.put("flow_id", getNewDspApplication().getFlowId());
        }
        if (getNewDspApplication().getStatus() != null ) {
            paramMap.put("appl_status", getNewDspApplication().getStatus());
        }
        return getDictUtils().getLov(LovConstants.DISPUTE_REJECT_CODES, paramMap);
    }

    public List<SelectItem> getRejectCodes() {
        List<SelectItem> codes = getActualRejectCodes();
        for (Iterator<SelectItem> iterator = codes.iterator(); iterator.hasNext(); ) {
            SelectItem code = (SelectItem)iterator.next();
            if (code.getValue() == null) {
                iterator.remove();
            }
        }
        return codes;
    }

    public List<SelectItem> getStatuses() {
        Map<String, Object> paramMap = new HashMap<String, Object>();
        if (getNewDspApplication().getFlowId() != null) {
            paramMap.put("flow_id", getNewDspApplication().getFlowId());
        }
        List<SelectItem> statuses = getDictUtils().getLov(LovConstants.DISPUTE_APPLICATION_STATUSES, paramMap);
        if (isNewMode()) {
            for (Iterator<SelectItem> iterator = statuses.iterator(); iterator.hasNext(); ) {
                SelectItem status = iterator.next();
                if (status.getValue().toString().equals(ApplicationStatuses.ACCEPTED) || status.getValue().toString().equals(ApplicationStatuses.REJECTED)) {
                    iterator.remove();
                }
            }
        }
        return statuses;
    }

    public SelectItem getStatus() {
        if (getNewDspApplication().getStatus() != null) {
            Map<String, Object> paramMap = new HashMap<String, Object>();
            List<SelectItem>tmp = getDictUtils().getLov(LovConstants.DISPUTE_APPLICATION_STATUSES, paramMap);
            for (SelectItem status : tmp) {
                if (status.getValue().toString().equals(getNewDspApplication().getStatus())) {
                    return new SelectItem(status.getValue(), status.getLabel(), status.getDescription());
                }
            }
        }
        return null;
    }

    public SelectItem getRejectCode() {
        if (getNewDspApplication().getRejectCode() != null) {
            Map<String, Object> paramMap = new HashMap<String, Object>();
            List<SelectItem>tmp = getDictUtils().getLov(LovConstants.DISPUTE_REJECT_CODES, paramMap);
            for (SelectItem code : tmp) {
                if (code.getValue().toString().equals(getNewDspApplication().getRejectCode())) {
                    return new SelectItem(code.getValue(), code.getLabel(), code.getDescription());
                }
            }
        }
        return null;
    }

    public SelectItem getMessageType() {
        if (getNewDspApplication().getMessageType() != null) {
            List<SelectItem>tmp = getMessageTypes();
            for (SelectItem type : tmp) {
                if (type.getValue().toString().equals(getNewDspApplication().getMessageType())) {
                    return new SelectItem(type.getValue(), type.getLabel(), type.getDescription());
                }
            }
        }
        return null;
    }

    public String voidMethod() {
        System.out.println("=========== calling voidMethod");
        return null;
    }

    public List<SelectItem> getMessageTypes() {
        return getDictUtils().getLov(LovConstants.DISPUTE_MESSAGE_TYPES);
    }

    public List<SelectItem> getDocumentTypes() {
        return getDictUtils().getLov(LovConstants.DISPUTE_DOCUMENT_TYPES, null, null, DictCache.NAME);
    }

    public boolean isDisableInstitute() {
        return (instId != null);
    }

    public boolean isDisableAgent() {
        return (agentId != null);
    }

    public boolean isDisableFlow() {
        return (flowId != null);
    }

    public boolean isFileExists() {
        return fileExists;
    }

    public void showCustomers() {
        MbCustomerSearchModal bean = (MbCustomerSearchModal)ManagedBeanWrapper.getManagedBean("MbCustomerSearchModal");
        bean.clearFilter();
        if (instId != null) {
            bean.setBlockInstId(true);
            bean.setDefaultInstId(instId);
        } else {
            bean.setBlockInstId(false);
        }
    }

    public void selectCustomer() {
        MbCustomerSearchModal bean = (MbCustomerSearchModal)ManagedBeanWrapper.getManagedBean("MbCustomerSearchModal");
        bean.setModule(ModuleNames.CASE_MANAGEMENT);
        Customer selected = bean.getActiveCustomer();
        if (selected != null) {
            getNewDspApplication().setCustomerId(selected.getId());
            getNewDspApplication().setCustomerNumber(selected.getCustomerNumber());
            getNewDspApplication().setCustomerInfo(selected.getName());
            getNewDspApplication().setInstId(selected.getInstId());
            getNewDspApplication().setInstName(selected.getInstName());
            getNewDspApplication().setAgentNumber(selected.getAgentNumber());
            getNewDspApplication().setAgentName(selected.getAgentName());
        }
    }

    public List<SelectItem> getApplReasons() {
        List<SelectItem> out = getDictUtils().getLov(LovConstants.APPLICATION_HISTORY_MESSAGES);
        for (SelectItem reason : out) {
            reason.setValue(reason.getLabel());
        }
        return out;
    }

    public void displayCustInfo() {
        return;
    }

    public void showOperations() {
        MbOperationSearchModal bean = (MbOperationSearchModal)ManagedBeanWrapper.getManagedBean("MbOperationSearchModal");
        bean.clearFilter();
        bean.getDisputeFilter().setFlowId(getNewDspApplication().getFlowId());
        bean.getDisputeFilter().setCustomerId(getNewDspApplication().getCustomerId());
        bean.getDisputeFilter().setCustomerNumber(getNewDspApplication().getCustomerNumber());
        bean.getDisputeFilter().setSubType(getNewDspApplication().getSubType());
    }

    public void selectOperation() {
        MbOperationSearchModal bean = (MbOperationSearchModal)ManagedBeanWrapper.getManagedBean("MbOperationSearchModal");
        Operation selected = bean.getActiveOperation();
        if (selected != null) {
            getNewDspApplication().setOperId(selected.getId());
            getNewDspApplication().setOperDate(selected.getOperDate());
            getNewDspApplication().setAmount(selected.getOperAmount());
            getNewDspApplication().setCurrency(selected.getOperCurrency());
            getNewDspApplication().setReferenceNumber(selected.getNetworkRefnum());
            getNewDspApplication().setMerchantNumber(selected.getMerchantNumber());
            getNewDspApplication().setMerchantName(selected.getMerchantName());
            getNewDspApplication().setTerminalNumber(selected.getTerminalNumber());
            if (selected.getIssInstId() != null) {
                getNewDspApplication().setInstId(selected.getIssInstId());
                getNewDspApplication().setInstName(selected.getIssInstName());
            } else {
                getNewDspApplication().setInstId(selected.getAcqInstId());
                getNewDspApplication().setInstName(selected.getAcqInstName());
            }
            if (selected.getCardMask() == null && selected.getAccountNumber() == null) {
                if (selected.getClientIdType() != null && selected.getClientIdValue() != null) {
                    if (selected.getClientIdType().equals(IDENT_TYPE_CARD)) {
                        getNewDspApplication().setCardMask(selected.getClientIdValue());
                    } else if (selected.getClientIdType().equals(IDENT_TYPE_ACCOUNT)) {
                        getNewDspApplication().setAccountNumber(selected.getClientIdValue());
                    }
                }
            } else {
                getNewDspApplication().setCardMask(selected.getCardMask());
                getNewDspApplication().setCardNumber(selected.getCardNumber());
                getNewDspApplication().setAccountNumber(selected.getAccountNumber());
            }
            if (StringUtils.isEmpty(getNewDspApplication().getCardMask()) ||
                StringUtils.isEmpty(getNewDspApplication().getAccountNumber())) {
                MbCardsSearch cardDetails = (MbCardsSearch)ManagedBeanWrapper.getManagedBean("MbCardsSearch");
                cardDetails.setCurLang(curLang);
                cardDetails.setCurMode(curMode);
                cardDetails.getFilter().setInstId(getNewDspApplication().getInstId());
                cardDetails.getFilter().setCardNumber(getNewDspApplication().getCardMask());
                cardDetails.getFilter().setCustomerNumber(getNewDspApplication().getCustomerNumber());
                cardDetails.getFilter().setCustomerId(getNewDspApplication().getCustomerId());
                cardDetails.search();
                cardDetails.loadCard();
                if (cardDetails.getActiveCard() != null) {
                    getNewDspApplication().setCardNumber(cardDetails.getActiveCard().getCardNumber());
                    getNewDspApplication().setCardId(cardDetails.getActiveCard().getId());
                    getNewDspApplication().setCardType(cardDetails.getActiveCard().getCardTypeName());
                    getNewDspApplication().setCardExpDate(cardDetails.getActiveCard().getExpDate());
                }
            }
        }
    }

    public void showCards() {
        MbCardSearchModal bean = (MbCardSearchModal)ManagedBeanWrapper.getManagedBean("MbCardSearchModal");
        bean.clearFilter();
        bean.getFilter().setCustomerId(getNewDspApplication().getCustomerId());
        bean.getFilter().setCustomerNumber(getNewDspApplication().getCustomerNumber());
        bean.setModule(ModuleNames.CASE_MANAGEMENT);
    }

    public void selectCard() {
        MbCardSearchModal bean = (MbCardSearchModal)ManagedBeanWrapper.getManagedBean("MbCardSearchModal");
        Card selected = bean.getActiveCard();
        if (selected != null) {
            getNewDspApplication().setCardMask(selected.getMask());
            getNewDspApplication().setCardNumber(selected.getCardNumber());
            getNewDspApplication().setCardId(selected.getId());
            getNewDspApplication().setCardExpDate(selected.getExpDate());
            getNewDspApplication().setCardType(selected.getCardTypeName());
            if (selected.getInstId() != null) {
                getNewDspApplication().setInstId(selected.getInstId());
                getNewDspApplication().setInstName(selected.getInstName());
            }
        }
    }

    public void displayOperInfo() {
        return;
    }

    public int getCurMode() {
        return curMode;
    }

    public boolean isCustomerEditable() {
        if (isNewMode() && (newDspApplication.getFlowId() != null)) {
            return true;
        }
        return false;
    }
    public boolean isOperationEditable() {
        if (isCustomerEditable() && (newDspApplication.getCustomerNumber() != null)) {
            return true;
        }
        return false;
    }
    public boolean isCardEditable() {
        if (isCustomerEditable() && (newDspApplication.getCustomerNumber() != null)) {
            return true;
        }
        return false;
    }

    public boolean isShowWriteOffTags() {
        if (isEditMode() || isViewMode()) {
            if (newDspApplication.getRejectCode() != null) {
                if (newDspApplication.getRejectCode().equals(AppIssRejectCodes.CREDIT_TO_CARDHOLDER) ||
                    newDspApplication.getRejectCode().equals(AppIssRejectCodes.ACCEPTED)) {
                    return true;
                }
            }
        }
        return false;
    }

    @Override
    public void setCurMode(int curMode) {
        this.curMode = curMode;
    }
    @Override
    public boolean isViewMode() {
        return (curMode == VIEW_MODE);
    }
    @Override
    public boolean isEditMode() {
        return (curMode == EDIT_MODE);
    }
    @Override
    public boolean isNewMode() {
        return (curMode == NEW_MODE);
    }
    @Override
    public boolean isTranslMode() {
        return (curMode == TRANSL_MODE);
    }
    @Override
    public boolean isCreateAddMode() {
        return (curMode == CREATE_ADD_MODE);
    }
}
