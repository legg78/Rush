package ru.bpc.sv2.ui.common.wizard.dual;

import org.apache.log4j.Logger;
import ru.bpc.sv2.common.WizardConstants;
import ru.bpc.sv2.common.application.ApplicationFlows;
import ru.bpc.sv2.common.events.EventConstants;
import ru.bpc.sv2.constants.EntityNames;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.ApplicationDao;
import ru.bpc.sv2.logic.CreditDao;
import ru.bpc.sv2.logic.OperationDao;
import ru.bpc.sv2.operations.Participant;
import ru.bpc.sv2.operations.constants.OperationsConstants;
import ru.bpc.sv2.operations.incoming.Operation;
import ru.bpc.sv2.ui.common.wizard.AbstractWizardStep;
import ru.bpc.sv2.ui.common.wizard.application.ApplicationBuilder;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.wizard.WizardPrivConstants;

import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import java.math.BigDecimal;
import java.util.Arrays;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;

@ViewScoped
@ManagedBean(name = "MbDualCreditBalanceTransferDS")
public class MbDualCreditBalanceTransferDS extends AbstractWizardStep {
	protected static final Logger logger = Logger.getLogger("COMMON");

	protected static final String ENTITY_TYPE = "ENTITY_TYPE";
	protected static final String OPERATION = "OPERATION";
	protected static final String OPTP_CREDIT_BALANCE_TRANSFER = "OPTP1035";

	protected static final String PAGE = "/pages/common/wizard/callcenter/dualCreditBalanceTransferDS.jspx";

	private BigDecimal amount;
	private BigDecimal cachedAmount;
	private String currency;

	private CreditDao creditDao = new CreditDao();
	private OperationDao operationDao = new OperationDao();
	private ApplicationDao applicationDao = new ApplicationDao();
	protected ru.bpc.sv2.operations.Operation sourceOperation = null;

	public MbDualCreditBalanceTransferDS() {
		setFlowId(ApplicationFlows.FRQ_COMMON_OPERATION);
		setMakerCheckerMode(WizardPrivConstants.OPERATION_CREDIT_BALANCE_TRANSFER_MAKER, WizardPrivConstants.OPERATION_CREDIT_BALANCE_TRANSFER_CHECKER);
	}

	@Override
	public void init(Map<String, Object> context) {
		super.init(context, PAGE, true);

		if (!((String)context.get(ENTITY_TYPE)).equalsIgnoreCase(EntityNames.OPERATION)) {
			throw new IllegalStateException(FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Common", "operation_error"));
		}
		if (context.containsKey(OPERATION)) {
			sourceOperation = (ru.bpc.sv2.operations.Operation) context.get(OPERATION);
			Map<String, Object> map = new HashMap<String, Object>();
			map.put("id", getSourceOperationId());
			creditDao.getOperationDebt(userSessionId, map);
			amount = (BigDecimal) map.get("amount");
			cachedAmount = amount;
			currency = (String) map.get("currency");
			loadParticipantsForOperation();
			if (!validate()) {
				throw new IllegalStateException(getEmptyAmountMessage());
			}
		} else {
			throw new IllegalStateException(OPERATION + " is not defined in wizard step context");
		}
	}

	@Override
	public Map<String, Object> release(Direction direction) {
		logger.trace("MbDualCreditBalanceTransferDS release...");
		if (direction == Direction.FORWARD) {
			String operStatus = creditBalanceTransfer();
			getContext().put(WizardConstants.OPER_STATUS, operStatus);
		}
		return getContext();
	}

	public void loadParticipantsForOperation() {
		if (sourceOperation.getParticipants() != null) {
			return;
		}
		Filter[] filters = new Filter[2];
		filters[0] = new Filter("lang", curLang);
		filters[1] = new Filter("operId", sourceOperation.getId());

		SelectionParams params = new SelectionParams(filters);
		params.setRowIndexEnd(Integer.MAX_VALUE);
		try {
			Participant[] result = operationDao.getParticipants(userSessionId, params);
			if (result.length > 0) {
				sourceOperation.setParticipants(Arrays.asList(result));
			}
		} catch (Exception e) {
			logger.error("", e);
			FacesUtils.addMessageError(e);
		}
	}

	private String creditBalanceTransfer() {
		String operStatus = null;
		Operation operation = createOperation(sourceOperation, amount, currency);
		if (isMaker()) {
			ApplicationBuilder builder = new ApplicationBuilder(
					applicationDao,
					userSessionId,
					operation.getIssInstId() == null ? operation.getAcqInstId() : operation.getIssInstId(),
					getFlowId()
			);

			builder.buildFromOperation(operation, true);
			builder.createApplicationInDB();
			builder.addApplicationObject(operation);
			return builder.getApplication().getStatus();
		} else {
			try {
				operationDao.addAdjusment(userSessionId, operation);
				operStatus = operationDao.processOperation(userSessionId, operation.getId());
			} catch (Exception e) {
				logger.error("Error when process operation. ", e);
				FacesUtils.addMessageError(e);
			}
			return operStatus == null ? operation.getStatus() : operStatus;
		}
	}

	@Override
	public boolean validate() {
		if (amount == null) return false;
		if (amount.compareTo(BigDecimal.ZERO) == 0) return false;
		return true;
	}

	private Operation createOperation(ru.bpc.sv2.operations.Operation sourceOperation, BigDecimal amount, String currency) {
		Operation operation = new Operation();

		operation.setOperType(getOperationType());
		operation.setMsgType(OperationsConstants.MESSAGE_TYPE_PRESENTMENT);
		operation.setSttlType(OperationsConstants.SETTLEMENT_INTERNAL_INTRAINST);
		operation.setOperationAmount(amount);
		operation.setOperationCurrency(currency);
		operation.setOriginalId(sourceOperation.getId());
		operation.setStatus(OperationsConstants.OPERATION_STATUS_PROCESS_READY);
		operation.setOperationDate(new Date());
		operation.setSourceHostDate(operation.getOperationDate());
		operation.setOperReason(getOperationReason());
		operation.setIssInstId(sourceOperation.getIssInstId());
		operation.setAcqInstId(sourceOperation.getAcqInstId());

		sourceOperation.copyParticipantToIncomingOperation(operation, Participant.ISS_PARTICIPANT);

		return operation;
	}

	protected String getOperationType() {
		return OPTP_CREDIT_BALANCE_TRANSFER;
	}

	protected String getOperationReason() {
		return EventConstants.CREDIT_BALANCE_TRANSFER;
	}

	protected Long getSourceOperationId() {
		return sourceOperation.getId();
	}

	protected String getEmptyAmountMessage() {
		return FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Crd", "msg_debt_amount_transfer_empty");
	}


	public BigDecimal getAmount() {
		return amount;
	}

	public void setAmount(BigDecimal amount) {
		this.amount = amount;
	}

	public BigDecimal getCachedAmount() {
		return cachedAmount;
	}

	public void setCachedAmount(BigDecimal cachedAmount) {
		this.cachedAmount = cachedAmount;
	}

	public String getCurrency() {
		return currency;
	}

	public void setCurrency(String currency) {
		this.currency = currency;
	}
}
