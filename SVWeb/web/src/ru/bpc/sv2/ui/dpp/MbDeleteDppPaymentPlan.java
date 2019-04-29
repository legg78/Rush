package ru.bpc.sv2.ui.dpp;

import org.apache.log4j.Logger;
import ru.bpc.sv2.common.application.ApplicationFlows;
import ru.bpc.sv2.dpp.DefferedPaymentPlan;
import ru.bpc.sv2.dpp.DppPrivConstants;
import ru.bpc.sv2.logic.ApplicationDao;
import ru.bpc.sv2.logic.DppDao;
import ru.bpc.sv2.logic.OperationDao;
import ru.bpc.sv2.logic.utility.db.DataAccessException;
import ru.bpc.sv2.operations.Participant;
import ru.bpc.sv2.operations.constants.OperationsConstants;
import ru.bpc.sv2.operations.incoming.Operation;
import ru.bpc.sv2.ui.common.wizard.application.ApplicationBuilder;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.MakerCheckerAction;
import ru.bpc.sv2.wizard.WizardPrivConstants;

import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import java.util.List;

@ViewScoped
@ManagedBean (name = "MbDeleteDppPaymentPlan")
public class MbDeleteDppPaymentPlan extends AbstractBean {
	private static final long serialVersionUID = 1L;

    private static final Logger logger = Logger.getLogger("DPP");

    private DppDao dppDao = new DppDao();
    private ApplicationDao appDao = new ApplicationDao();
    private OperationDao operDao = new OperationDao();

    private DefferedPaymentPlan dpp;

    private MakerCheckerAction makerCheckerAction;


    private Operation createOperationFromDpp() {
        Operation operation = new Operation();

        operation.setReversal(Boolean.FALSE);
        operation.setOriginalId(getDpp().getRegOperId());
        operation.setOperType("OPTP1504");
        operation.setMsgType(OperationsConstants.MESSAGE_TYPE_PRESENTMENT);
        operation.setStatus(OperationsConstants.OPERATION_STATUS_PROCESS_READY);
        operation.setSttlType(OperationsConstants.SETTLEMENT_INTERNAL_INTRAINST);

        List<Participant> participants = operDao.getParticipantsByOperId(userSessionId, getDpp().getOperId());
        for (Participant participant : participants) {
            if (participant.isIssuer()) {
                participant.setAccountId(getDpp().getAccountId());
                operation.fillParticipant(participant);
            }
        }

        return operation;
    }

    public void deleteDpp() {
        try {
            dppDao.deleteDefferedPaymentPlan(userSessionId, dpp);
        } catch (DataAccessException e) {
            FacesUtils.addMessageError(e);
            logger.error("", e);
        }
    }

    public void deleteDppApplication() {
        try {
            ApplicationBuilder builder = new ApplicationBuilder(appDao, userSessionId,
                    (getDpp().getInstId() != null) ? getDpp().getInstId() : userInstId,
                    ApplicationFlows.FRQ_COMMON_OPERATION);
            Operation operation = createOperationFromDpp();
            builder.buildFromOperation(operation, true);
            builder.createApplicationInDB();
            builder.addApplicationObject(operation);
        } catch (Exception e) {
            FacesUtils.addMessageError(e);
            logger.error("", e);
        }
    }

    public void deleteDppOperation() {
        try {
            Operation operation = createOperationFromDpp();
            operDao.addAdjusment(userSessionId, operation);
            operDao.processOperation(userSessionId, operation.getId());
        } catch (Exception e) {
            FacesUtils.addMessageError(e);
            logger.error("", e);
        }
    }

    public boolean isDisableDeleteDpp() {
        if (dpp == null)
            return true;

		return !getMakerCheckerAction().hasActiveAction();
    }

    public DefferedPaymentPlan getDpp() {
        return dpp;
    }
    public void setDpp(DefferedPaymentPlan dpp) {
        this.dpp = dpp;
    }


    @Override
    public void clearFilter() {}

    public MakerCheckerAction getMakerCheckerAction() {
		if (makerCheckerAction == null) {
			makerCheckerAction = new MakerCheckerAction(
					WizardPrivConstants.REMOVE_INSTALMENT_PLAN_MAKER,
					WizardPrivConstants.REMOVE_INSTALMENT_PLAN_CHECKER,
					DppPrivConstants.REMOVE_PAYMENT_PLAN) {

				@Override
				public void makerAction() {
					deleteDppApplication();
				}
				@Override
				public void makerCheckerAction() {
					deleteDppOperation();
				}
				@Override
				public void defaultAction() {
					deleteDpp();
				}
			};
		}
		return makerCheckerAction;
    }
}
