package ru.bpc.sv2.ui.dpp;

import org.ajax4jsf.model.KeepAlive;
import org.apache.commons.lang3.StringUtils;
import org.apache.log4j.Logger;
import ru.bpc.sv2.common.application.ApplicationFlows;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.dpp.DefferedPaymentPlan;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.ApplicationDao;
import ru.bpc.sv2.logic.DppDao;
import ru.bpc.sv2.logic.OperationDao;
import ru.bpc.sv2.operations.Operation;
import ru.bpc.sv2.operations.Participant;
import ru.bpc.sv2.operations.constants.OperationsConstants;
import ru.bpc.sv2.process.btrt.BTRTMapping;
import ru.bpc.sv2.svng.AupTag;
import ru.bpc.sv2.ui.common.wizard.CommonWizardStep;
import ru.bpc.sv2.ui.common.wizard.application.ApplicationBuilder;
import ru.bpc.sv2.ui.session.UserSession;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.wizard.WizardPrivConstants;
import util.auxil.ManagedBeanWrapper;

import javax.faces.bean.ManagedBean;
import javax.faces.bean.RequestScoped;
import javax.faces.model.SelectItem;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RequestScoped
@KeepAlive
@ManagedBean (name = "MbRegisterDppPaymentPlan")
public class MbRegisterDppPaymentPlan extends AbstractBean {
    private static Logger logger = Logger.getLogger(MbDualDppMacros.class);
    private static String DPP_REGISTRATION_OPER_TYPE = "OPTP1501";

    private CommonWizardStep.Mode mode = CommonWizardStep.Mode.NONE;
    private DppDao dppDao = new DppDao();
    private ApplicationDao appDao = new ApplicationDao();
    private OperationDao operDao = new OperationDao();

    private DefferedPaymentPlan dpp;

    public MbRegisterDppPaymentPlan() {
        initMode(WizardPrivConstants.ADD_INSTALMENT_PLAN_MAKER, WizardPrivConstants.ADD_INSTALMENT_PLAN_CHECKER);
    }

    private boolean isPrivilegeAssigned(String privilege) {
        Map<String, Boolean> role = ((UserSession) ManagedBeanWrapper.getManagedBean("usession")).getInRole();
        if (role != null && StringUtils.isNotBlank(privilege)) {
            return role.get(privilege);
        } else {
            return false;
        }
    }

    private void initMode(String makerPrivilege, String checkerPrivilege) {
        boolean maker = isPrivilegeAssigned(makerPrivilege);
        boolean checker = isPrivilegeAssigned(checkerPrivilege);
        if (maker && checker) {
            mode = CommonWizardStep.Mode.BOTH;
        } else if (maker) {
            mode = CommonWizardStep.Mode.MAKER;
        } else if (checker) {
            mode = CommonWizardStep.Mode.CHECKER;
        } else {
            mode = CommonWizardStep.Mode.NONE;
        }
    }

    public void registerDpp() {
        try {
            Operation operation = createOperationFromDpp();
            operDao.addAdjusment(userSessionId, operation);

            List<AupTag> tags = createAupTags();
            if (!tags.isEmpty()) {
                operDao.addAupTags(userSessionId, tags, operation.getId());
            }
            operDao.processOperation(userSessionId, operation.getId());

            MbDppPaymentPlan bean = ManagedBeanWrapper.getManagedBean(MbDppPaymentPlan.class);
            if (bean != null) {
                List<Filter> dppFilters = new ArrayList<Filter>();
                dppFilters.add(Filter.create("lang", userLang));
                dppFilters.add(Filter.create("id", dpp.getOperId()));
                SelectionParams params = new SelectionParams(dppFilters);
                DefferedPaymentPlan[] plans = dppDao.getDefferedPaymentPlans(userSessionId, params);
                if (plans != null && plans.length > 0) {
                    bean.saveDefferedPaymentPlan(plans[0]);
                } else {
                    bean.search();
                }
            }
        } catch (Exception e) {
            FacesUtils.addMessageError(e);
            logger.error("", e);
        }
        reset();
    }

    private List<AupTag> createAupTags() {
        List<AupTag> tags = new ArrayList<>();
        if (getDpp().getFeeId() != null) {
            tags.add(new AupTag(BTRTMapping.FEE_ID.getCode(), getDpp().getFeeId().toString()));
        }
        if (getDpp().getInstalmentTotal() != null) {
            tags.add(new AupTag(BTRTMapping.NUMBER_OF_INSTALMENTS.getCode(), getDpp().getInstalmentTotal().toString()));
        }
        /**
         * TODO
         * There is need to fill tag 35876 within new instalment amount value,
         * but in current implementation of wizards we have no such input information.
         * That's why we're just skipping it for now.
         *
        if (getDpp().getDppAmount() != null) {
            Object currency = CurrencyCache.getInstance().getCurrencyObjectsMap().get(getDpp().getCurrency());
            if (currency != null) {
                Integer exponent = ((Currency)currency).getExponent();
                BigDecimal amount = getDpp().getDppAmount().scaleByPowerOfTen(exponent * (-1));
                amount = amount.setScale(exponent);
                tags.add(new AupTagRec(35876, amount.toPlainString(), 1));
            } else {
                tags.add(new AupTagRec(35876, getDpp().getDppAmount().toPlainString(), 1));
            }
        }
         */
        return tags;
    }

    private Operation createOperationFromDpp() {
        Operation operation = new Operation();

        operation.setOperType(DPP_REGISTRATION_OPER_TYPE);
        operation.setOperationType(DPP_REGISTRATION_OPER_TYPE);
        operation.setIsReversal(Boolean.FALSE);
        operation.setIsReversalExists(Boolean.TRUE);
        operation.setMsgType(OperationsConstants.MESSAGE_TYPE_PRESENTMENT);
        operation.setStatus(OperationsConstants.OPERATION_STATUS_PROCESS_READY);
        operation.setSttlType(OperationsConstants.SETTLEMENT_INTERNAL_INTRAINST);
        operation.setOriginalId(getDpp().getOperId());
        operation.setOperCurrency(getDpp().getCurrency());
        operation.setOperAmount(getDpp().getDppAmount());
        operation.setOperCount((getDpp().getInstalmentTotal() != null) ? getDpp().getInstalmentTotal().longValue() : null);

        List<Participant> participants = operDao.getParticipantsByOperId(userSessionId, getDpp().getOperId());
        for (Participant participant : participants) {
            if (participant.isIssuer()) {
                participant.setAccountId(getDpp().getAccountId());
                if (operation.getParticipants() == null) {
                    operation.setParticipants(new ArrayList<Participant>());
                }
                operation.getParticipants().add(participant);
            }
        }

        return operation;
    }

    public void registerApplication() {
        try {
            ApplicationBuilder builder = new ApplicationBuilder(appDao, userSessionId,
                                                                (getDpp().getInstId() != null) ? getDpp().getInstId() : userInstId,
                                                                ApplicationFlows.FRQ_COMMON_OPERATION);
            Operation operation = createOperationFromDpp();
            builder.buildFromOperation(operation, true);
            builder.addAupTags(createAupTags());
            builder.createApplicationInDB();
            builder.addApplicationObject(operation);
        } catch (Exception e) {
            FacesUtils.addMessageError(e);
            logger.error("", e);
        }
        reset();
    }

    public boolean isCheckerMode() {
        return (CommonWizardStep.Mode.CHECKER == mode);
    }
    public boolean isMakerMode() {
        return (CommonWizardStep.Mode.MAKER == mode);
    }
    public boolean isBothMode() {
        return (CommonWizardStep.Mode.BOTH == mode);
    }
    public boolean isNoneMode() {
        return (CommonWizardStep.Mode.NONE == mode);
    }

    public boolean isDisableRegisterDpp() {
        if (isNoneMode()) {
            Map<String, Boolean> role = ((UserSession) ManagedBeanWrapper.getManagedBean("usession")).getInRole();
            return (role != null) ? !role.get("ADD_PAYMENT_PLAN") : true;
        } else if (isCheckerMode()) {
            return true;
        }
        return false;
    }

    public DefferedPaymentPlan getDpp() {
        if (dpp == null) {
            dpp = new DefferedPaymentPlan();
        }
        return dpp;
    }
    public void setDpp(DefferedPaymentPlan dpp) {
        this.dpp = dpp;
    }

    public List<SelectItem> getFees() {
        Map<String, Object> parameters = new HashMap<String, Object>();
        parameters.put("account_id", getDpp().getAccountId());
        List<SelectItem> fees = getDictUtils().getLov(LovConstants.DPP_INTEREST_FEES, parameters);
        return fees;
    }

    public void reset() {
        setDpp(null);
        clearFilter();
    }

    @Override
    public void clearFilter() {}
}
