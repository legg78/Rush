package ru.bpc.sv2.ui.application.wizard;

import org.apache.commons.io.IOUtils;
import ru.bpc.sv2.application.Application;
import ru.bpc.sv2.application.DspApplication;
import ru.bpc.sv2.application.ManualCaseCreation;
import ru.bpc.sv2.common.events.EventConstants;
import ru.bpc.sv2.constants.application.AppElements;
import ru.bpc.sv2.logic.ApplicationDao;
import ru.bpc.sv2.logic.DisputesDao;
import ru.bpc.sv2.rules.DspApplicationFile;
import ru.bpc.sv2.ui.common.application.ApplicationWizardContext;
import ru.bpc.sv2.ui.common.application.MbWizard;
import ru.bpc.sv2.ui.rules.MbDspApplications;
import ru.bpc.sv2.ui.session.UserSession;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.FacesUtils;
import util.auxil.ManagedBeanWrapper;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.SessionScoped;
import java.io.*;
import java.math.BigDecimal;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@SessionScoped
@ManagedBean(name = "MbDspWizard")
public class MbDspWizard extends MbWizard {
    private int curMode = AbstractBean.VIEW_MODE;
    private String curLang = null;
    private Application application = null;
    private static final String CASE_ACTION_ATTACH = "CASE_ACTION_ATTACH";

    private ApplicationDao applicationDao = new ApplicationDao();
    private DisputesDao disputesDao = new DisputesDao();

    @Override
    public void init(ApplicationWizardContext ctx) {
        super.init(ctx);
        curMode = (Integer)context.get("curMode");
        curLang = (String)context.get("curLang");
        application = (Application)context.get("application");
    }
    @Override
    public boolean isdisplayFinish() {
        return super.isdisplayFinish() && (Integer)context.get("curMode") != AbstractBean.VIEW_MODE;
    }

    public String finish() {
        logger.trace("MbDspWizard::finish...");
        releaseCurrentStep();
        Long applId = saveApplication();
        if(applId != null){
            if(context.get("attachFiles") != null){
                saveFiles(applId, application.getStatus(), application.getRejectCode());
            }
            MbDspApplications dspApplications = (MbDspApplications) ManagedBeanWrapper.getManagedBean("MbDspApplications");
            dspApplications.update(applId, (Integer)context.get("curMode"));
        }
        return null;
    }

    protected void saveFiles(Long applId, String status, String rejectCode){
        List<DspApplicationFile> files = (List<DspApplicationFile>)context.get("attachFiles");
        Map<String, Object> params = new HashMap<String, Object>();
        try {
            for(DspApplicationFile file : files) {
                if(!file.isNewFile()){
                    continue;
                }
                params.put("applId", applId);
                params.put("documentType", file.getType());
                params.put("fileName", file.getName());
                applicationDao.saveDspDocument(userSessionId, params);
                copyFile((String)params.get("savePath"), file.getBytes());
                params.clear();
                params.put("applId", applId);
                params.put("action", CASE_ACTION_ATTACH);
                params.put("newStatus", status);
                params.put("oldStatus", status);
                params.put("newRejectCode", rejectCode);
                params.put("oldRejectCode", rejectCode);
                params.put("param", file.getType());
                applicationDao.addDisputeHistory(userSessionId, params);
            }
        } catch (Exception e) {
            FacesUtils.addErrorExceptionMessage(e);
            logger.error(e);
        }
    }

    protected void saveFiles(Long[] applIds){
        List<DspApplicationFile> files = (List<DspApplicationFile>)context.get("attachFiles");
        Map<String, Object> params = new HashMap<String, Object>();
        try {
            for(DspApplicationFile file : files) {
                if(!file.isNewFile()){
                    continue;
                }
                params.put("applIds", applIds);
                params.put("documentType", file.getType());
                params.put("fileName", file.getName());
                applicationDao.saveDspDocument(userSessionId, params);
                copyFile((String)params.get("savePath"), file.getBytes());
            }
        } catch (Exception e) {
            FacesUtils.addErrorExceptionMessage(e);
            logger.error(e);
        }
    }

    private void copyFile(String fileName, byte[] bytes) throws IOException {
        File file = new File(fileName);// + "/" + (String)params.get("fileNameOut")
        file.createNewFile();
        FileOutputStream fos = new FileOutputStream(file);
        InputStream is = new ByteArrayInputStream(bytes);
        try {
            IOUtils.copy(is, fos);
        }finally {
            if(fos != null){
                fos.close();
            }
        }
    }

    private void initiateDispute() throws Exception {
        Map<String, Object> params = new HashMap<String, Object>(1);
        if (applicationRoot.getChildByName(AppElements.OPER_ID, 1) != null) {
            params.put("operId", Long.valueOf(applicationRoot.getChildByName(AppElements.OPER_ID, 1).getValueN().toString()));
            if (application.getOperId() == null) {
                application.setOperId((Long)params.get("operId"));
            }
        } else {
            params.put("operId", application.getOperId());
        }
        Long disputeId = applicationDao.initiateDispute(userSessionId, params);
        if (applicationRoot.getChildByName(AppElements.DISPUTE_ID, 1) != null) {
            applicationRoot.getChildByName(AppElements.DISPUTE_ID, 1).setValueN(BigDecimal.valueOf(disputeId));
        }
        insertDataId(applicationRoot, applicationRoot.getChildren().size());
    }

    private void determineUser() throws Exception {
        Integer userId = null;
        UserSession userSession = (UserSession)ManagedBeanWrapper.getManagedBean("usession");
        if (userSession != null && userSession.getUser() != null) {
            userId = userSession.getUser().getId();
            if (userId == null) {
                Map<String, Object> params = new HashMap<String, Object>();
                params.put("applId", application.getId());
                userId = applicationDao.refuseDspApplication(userSessionId, params);
            }
        }
        if (userId != null) {
            application.setUserId(userId);
        }
    }


    private String getAppValueV(String name) {
        return (getAppElementValue(name) != null) ? (String)getAppElementValue(name) : null;
    }
    private Date getAppValueD(String name) {
        return (getAppElementValue(name) != null) ? (Date)getAppElementValue(name) : null;
    }
    private BigDecimal getAppValueN(String name) {
        return (getAppElementValue(name) != null) ? (BigDecimal)getAppElementValue(name) : null;
    }
    private Long getAppValueL(String name) {
        return (getAppElementValue(name) != null) ? ((BigDecimal)getAppElementValue(name)).longValueExact() : null;
    }
    private Integer getAppValueI(String name) {
        return (getAppElementValue(name) != null) ? ((BigDecimal)getAppElementValue(name)).intValueExact() : null;
    }
    private Object getAppElementValue(String name) {
        if (applicationRoot.getChildByName(name, 1) != null) {
            if (applicationRoot.getChildByName(name, 1).getValueV() != null) {
                return applicationRoot.getChildByName(name, 1).getValueV();
            } else if (applicationRoot.getChildByName(name, 1).getValueN() != null) {
                return applicationRoot.getChildByName(name, 1).getValueN();
            } else if (applicationRoot.getChildByName(name, 1).getValueD() != null) {
                return applicationRoot.getChildByName(name, 1).getValueD();
            } else if (applicationRoot.getChildByName(name, 1).getValue() != null) {
                return applicationRoot.getChildByName(name, 1).getValue();
            }
        }
        return null;
    }

    private ManualCaseCreation createCase() throws Exception {
        ManualCaseCreation claim = new ManualCaseCreation();
        if (context.get("dspApp") != null) {
            claim.fromDspApplication((DspApplication)context.get("dspApp"));
        } else {
            claim.setApplId(application.getId());
            claim.setCaseId(application.getId());
            claim.setSeqnum(application.getSeqNum());
            claim.setInstId(application.getInstId().longValue());
            claim.setCustomerNumber(application.getCustomerNumber());
            claim.setCreatedDate(application.getCreated());
            claim.setCreatedByUserId(application.getUserId().longValue());
            claim.setCardNumber(application.getCardNumber());
            claim.setFlowId(application.getFlowId().longValue());
            claim.setApplication(application.getApplNumber());
            claim.setTerminalNumber(application.getTerminalNumber());
            claim.setMerchantNumber(application.getMerchantNumber());
            claim.setFlow(application.getFlowName());
            claim.setAgentId(application.getAgentId());
            claim.setReasonCode(application.getRejectCode());

            claim.setMerchantName(getAppValueV(AppElements.MERCHANT_NAME));
            claim.setOperDate((Date) getAppElementValue(AppElements.OPER_DATE));
            claim.setOperAmount(getAppValueN(AppElements.OPER_AMOUNT));
            claim.setOperCurrency(getAppValueV(AppElements.OPER_CURRENCY));
            claim.setDisputeId((getAppValueL(AppElements.DISPUTE_ID)));
            claim.setDisputeProgress(getAppValueV(AppElements.DISPUTE_PROGRESS));
            claim.setWriteOffAmount(getAppValueN(AppElements.WRITE_OFF_AMOUNT));
            claim.setWriteOffCurrency(getAppValueV(AppElements.WRITE_OFF_CURRENCY));
            claim.setCaseResolution(getAppValueV(AppElements.STATUS_REASON));
            claim.setDisputeReason(getAppValueV(AppElements.DISPUTE_REASON));
            claim.setDisputedAmount(getAppValueN(AppElements.DISPUTED_AMOUNT));
            claim.setDisputedCurrency(getAppValueV(AppElements.DISPUTED_CURRENCY));
            claim.setCaseProgress(getAppValueV(AppElements.DISPUTE_PROGRESS));
            claim.setAcquirerInstBin(getAppValueV(AppElements.ACQUIRER_INST_BIN));
            claim.setCaseSource(getAppValueV(AppElements.STATUS_REASON));
            claim.setSttlAmount(getAppValueN(AppElements.STTL_AMOUNT));
            claim.setSttlCurrency(getAppValueV(AppElements.STTL_CURRENCY));
            claim.setBaseAmount(getAppValueN(AppElements.AMOUNT));
            claim.setBaseCurrency(getAppValueV(AppElements.CURRENCY));
            claim.setOwner(getAppValueV(AppElements.USER));
            claim.setCaseStatus(getAppValueV(AppElements.APPLICATION_STATUS));
            claim.setForwardingInstBin(getAppValueV(AppElements.FORW_INST_BIN));
            claim.setRrn(getAppValueV(AppElements.NETWORK_REFNUM));
            claim.setMcc(getAppValueV(AppElements.MCC));
            claim.setMerchantCountryCode(getAppValueV(AppElements.MERCHANT_COUNTRY));
            claim.setMerchantLocation(getAppValueV(AppElements.MERCHANT_REGION) + " " +
                                              getAppValueV(AppElements.MERCHANT_CITY) + " " +
                                              getAppValueV(AppElements.MERCHANT_STREET));
        }
        return claim;
    }

    private Long saveApplication() {
        logger.trace("MbDspWizard::saveApplication...");
        try {
            application = (Application)context.get("application");
            application.setNewStatus(application.getStatus());
            application.setEventType(EventConstants.DISPUTE_CASE_REGISTERED);

            if(isNewMode()) {
                initiateDispute();
                ManualCaseCreation claim = disputesDao.createManualApplication(userSessionId, createCase());
                application.setId(claim.getApplId());
            } else {
                disputesDao.modifyCase(userSessionId, createCase());
            }
            determineUser();
            createLinks();
            return application.getId();
        } catch (Exception e) {
            FacesUtils.addErrorExceptionMessage(e);
            logger.error(e);
        } finally {
            releaseApplications();
        }
        return null;
    }

    public void accept(){}
    public void reject(){}

    public int getCurMode() {
        return curMode;
    }
    public void setCurMode(int curMode) {
        this.curMode = curMode;
    }

    public String getCurLang() {
        return curLang;
    }
    public void setCurLang(String curLang) {
        this.curLang = curLang;
    }

    public boolean isViewMode() {
        return (AbstractBean.VIEW_MODE == curMode);
    }
    public boolean isNewMode() {
        return (AbstractBean.NEW_MODE == curMode);
    }
    public boolean isEditMode() {
        return (AbstractBean.EDIT_MODE == curMode);
    }

    public String getStepLabel() {
        if (application != null) {
            if (MbAppWizDspFlow.DISPUTE_FLOW_ID.equals(application.getFlowId())) {
                if (getCurrentStep() != null) {
                    if (MbAppWizDspFlow.DISPUTE_FLOW_FIRST_STEP.equals(getCurrentStep().getId())) {
                        switch (curMode) {
                            case AbstractBean.VIEW_MODE:
                                return FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Msg", "view_claim");
                            case AbstractBean.NEW_MODE:
                                return FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Msg", "create_new_claim");
                            case AbstractBean.EDIT_MODE:
                                return FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Msg", "edit_claim");
                        }
                    }
                }
            }
        }
        return (getCurrentStep() != null) ? getCurrentStep().getStepLabel() : null;
    }
}
