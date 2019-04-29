package ru.bpc.sv2.ui.dpp;

import org.apache.commons.lang3.StringUtils;
import org.apache.log4j.Logger;
import ru.bpc.sv2.common.application.ApplicationFlows;
import ru.bpc.sv2.dpp.DppPrivConstants;
import ru.bpc.sv2.logic.ApplicationDao;
import ru.bpc.sv2.logic.OperationDao;
import ru.bpc.sv2.operations.Participant;
import ru.bpc.sv2.operations.constants.OperationsConstants;
import ru.bpc.sv2.operations.Operation;
import ru.bpc.sv2.process.btrt.BTRTMapping;
import ru.bpc.sv2.svng.AupTag;
import ru.bpc.sv2.ui.common.wizard.application.ApplicationBuilder;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.MakerCheckerAction;
import ru.bpc.sv2.wizard.WizardPrivConstants;
import util.auxil.ManagedBeanWrapper;

import javax.annotation.PostConstruct;
import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;

@ViewScoped
@ManagedBean (name = "MbModifyDppPaymentPlan")
public class MbModifyDppPaymentPlan extends AbstractBean {
	private static final long serialVersionUID = 1L;

    private static final Logger logger = Logger.getLogger("DPP");

    private ApplicationDao appDao = new ApplicationDao();
    private OperationDao operDao = new OperationDao();

    private MakerCheckerAction makerCheckerAction;

	private MbDppPaymentPlan dppPaymentPlan;

	@PostConstruct
	public void init() {
		dppPaymentPlan = ManagedBeanWrapper.getManagedBean(MbDppPaymentPlan.class);
	}


    private Operation createOperationFromDpp() {
        Operation operation = new Operation();

        operation.setIsReversal(Boolean.FALSE);
        operation.setOriginalId(dppPaymentPlan.getActiveItem().getRegOperId());
        operation.setOperType("OPTP1505");
        operation.setMsgType(OperationsConstants.MESSAGE_TYPE_PRESENTMENT);
        operation.setStatus(OperationsConstants.OPERATION_STATUS_PROCESS_READY);
        operation.setSttlType(OperationsConstants.SETTLEMENT_INTERNAL_INTRAINST);
		operation.setOperCurrency(dppPaymentPlan.getActiveItem().getCurrency());

		if (dppPaymentPlan.getAmountRendered()) {
			BigDecimal bdValue = dppPaymentPlan.getAcceleratingDefferedPaymentPlan().getInstalmentAmount();
			operation.setOperAmount(bdValue);
		}

	    Integer iValue = dppPaymentPlan.getAcceleratingDefferedPaymentPlan().getInstalmentTotal();
	    operation.setOperCount(iValue != null ? iValue.longValue() : null);

        List<Participant> participants = operDao.getParticipantsByOperId(userSessionId, dppPaymentPlan.getActiveItem().getOperId());
	    for (Participant participant : participants) {
		    if (participant.isIssuer()) {
			    participant.setAccountId(dppPaymentPlan.getActiveItem().getAccountId());
			    if (operation.getParticipants() == null) {
				    operation.setParticipants(new ArrayList<Participant>());
			    }
			    operation.getParticipants().add(participant);
		    }
	    }

        return operation;
    }


    private List<AupTag> getTags(Operation operation) {
		List<AupTag> tags = new ArrayList<>();
	    String accelerationType = dppPaymentPlan.getAcceleratingDefferedPaymentPlan().getAccelerationType();
	    if (StringUtils.isNotEmpty(accelerationType)) {
		    tags.add(new AupTag(BTRTMapping.INSTALMENT_ALGORITHM.getCode(), accelerationType));
	    }

	    Integer instalmentTotal = dppPaymentPlan.getAcceleratingDefferedPaymentPlan().getInstalmentTotal();
	    if (instalmentTotal != null) {
		    tags.add(new AupTag(BTRTMapping.NUMBER_OF_INSTALMENTS.getCode(), instalmentTotal.toString()));
	    }

	    return tags;
    }

    public void modifyDppApplication() {
        try {
            ApplicationBuilder builder = new ApplicationBuilder(appDao, userSessionId,
                    dppPaymentPlan.getActiveItem().getInstId() != null ? dppPaymentPlan.getActiveItem().getInstId() : userInstId,
                    ApplicationFlows.FRQ_COMMON_OPERATION);
            Operation operation = createOperationFromDpp();
            builder.buildFromOperation(operation, true);
            builder.addAupTags(getTags(operation));
            builder.createApplicationInDB();
            builder.addApplicationObject(operation);
        } catch (Exception e) {
            FacesUtils.addMessageError(e);
            logger.error("", e);
        }
    }

    public void modifyDppOperation() {
        try {
            Operation operation = createOperationFromDpp();
            operDao.addAdjusment(userSessionId, operation);
	        operDao.addAupTags(userSessionId, getTags(operation), operation.getId());
            operDao.processOperation(userSessionId, operation.getId());
        } catch (Exception e) {
            FacesUtils.addMessageError(e);
            logger.error("", e);
        }
    }

    public boolean isActionDisabled() {
        if (dppPaymentPlan.getActiveItem() == null)
            return true;

		return !getMakerCheckerAction().hasActiveAction();
    }

    @Override
    public void clearFilter() {}

    public MakerCheckerAction getMakerCheckerAction() {
		if (makerCheckerAction == null) {
			makerCheckerAction = new MakerCheckerAction(
					WizardPrivConstants.MODIFY_INSTALMENT_PLAN_MAKER,
					WizardPrivConstants.MODIFY_INSTALMENT_PLAN_CHECKER,
					DppPrivConstants.ACCELERATE_PAYMENT_PLAN) {

				@Override
				public void makerAction() {
					modifyDppApplication();
				}
				@Override
				public void makerCheckerAction() {
					modifyDppOperation();
				}
				@Override
				public void defaultAction() {
					dppPaymentPlan.accelerateDefferedPaymentPlan();
				}
				@Override
				public void cancel() {
					dppPaymentPlan.resetAcceleratingDpp();
				}
			};
		}
		return makerCheckerAction;
    }
}
