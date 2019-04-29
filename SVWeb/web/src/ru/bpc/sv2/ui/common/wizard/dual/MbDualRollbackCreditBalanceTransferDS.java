package ru.bpc.sv2.ui.common.wizard.dual;

import ru.bpc.sv2.common.application.ApplicationFlows;
import ru.bpc.sv2.common.events.EventConstants;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.wizard.WizardPrivConstants;

import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import java.util.Map;

@ViewScoped
@ManagedBean(name = "MbDualRollbackCreditBalanceTransferDS")
public class MbDualRollbackCreditBalanceTransferDS extends MbDualCreditBalanceTransferDS {
	private static final String OPTP_CASH_WITHDRAWN = "OPTP0412";

	public MbDualRollbackCreditBalanceTransferDS() {
		setFlowId(ApplicationFlows.FRQ_COMMON_OPERATION);
		setMakerCheckerMode(WizardPrivConstants.OPERATION_ROLLBACK_CREDIT_BALANCE_TRANSFER_MAKER, WizardPrivConstants.OPERATION_ROLLBACK_CREDIT_BALANCE_TRANSFER_CHECKER);
	}

	@Override
	public void init(Map<String, Object> context) {
		super.init(context);
		if (!MbDualCreditBalanceTransferDS.OPTP_CREDIT_BALANCE_TRANSFER.equals(sourceOperation.getOperType())) {
			String msg = FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Msg", "invalid_oper_type", MbDualCreditBalanceTransferDS.OPTP_CREDIT_BALANCE_TRANSFER);
			throw new IllegalStateException(msg);
		}
	}

	@Override
	protected String getOperationType() {
		return OPTP_CASH_WITHDRAWN;
	}

	@Override
	protected String getOperationReason() {
		return EventConstants.ROLLBACK_CREDIT_BALANCE_TRANSFER;
	}

	@Override
	protected Long getSourceOperationId() {
		return sourceOperation.getId();
	}

	@Override
	protected String getEmptyAmountMessage() {
		return FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Crd", "msg_rollback_debt_amount_transfer_empty");
	}
}
