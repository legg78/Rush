package ru.bpc.sv2.ui.common.wizard.dual;

import org.apache.log4j.Logger;
import ru.bpc.sv2.common.application.ApplicationFlows;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.logic.ApplicationDao;
import ru.bpc.sv2.logic.OperationDao;
import ru.bpc.sv2.logic.ReconciliationDao;
import ru.bpc.sv2.operations.constants.OperationsConstants;
import ru.bpc.sv2.operations.incoming.Operation;
import ru.bpc.sv2.reconciliation.RcnMessage;
import ru.bpc.sv2.ui.common.wizard.AbstractWizardStep;
import ru.bpc.sv2.ui.common.wizard.application.ApplicationBuilder;
import ru.bpc.sv2.ui.common.wizard.callcenter.MbOperTypeSelectionStep;
import ru.bpc.sv2.ui.common.wizard.callcenter.MbWzRcnDetails;
import ru.bpc.sv2.wizard.WizardPrivConstants;
import util.auxil.ManagedBeanWrapper;

import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.model.SelectItem;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

@ViewScoped
@ManagedBean(name = "MbDualCreateOperForNotRcnMsgDS")
public class MbDualCreateOperForNotRcnMsgDS extends AbstractWizardStep {
	private static final Logger classLogger = Logger.getLogger(MbDualCreateOperForNotRcnMsgDS.class);

	private static final String PAGE = "/pages/common/wizard/callcenter/reconciliation/createOperForNotRcnMsgDS.jspx";
	private String entityType;
	private List<SelectItem> statuses = null;
	private List<SelectItem> allStatuses = null;
	private RcnMessage message;
	private String newStatus;

	private ApplicationDao applicationDao = new ApplicationDao();
	private ReconciliationDao reconciliationDao = new ReconciliationDao();
	private OperationDao operationDao = new OperationDao();

	public MbDualCreateOperForNotRcnMsgDS() {
		setFlowId(ApplicationFlows.FRQ_COMMON_OPERATION);
		setMakerCheckerMode(WizardPrivConstants.MESSAGE_OPER_FOR_NOT_RCN_MSG_MAKER, WizardPrivConstants.MESSAGE_OPER_FOR_NOT_RCN_MSG_CHECKER);
	}

	@Override
	public void init(Map<String, Object> context) {
		super.init(context, PAGE);

		classLogger.trace("init...");

		if (!context.containsKey(MbOperTypeSelectionStep.ENTITY_TYPE)) {
			throw new IllegalStateException(MbOperTypeSelectionStep.ENTITY_TYPE + " is not defined in wizard context");
		}

		message = ManagedBeanWrapper.getManagedBean(MbWzRcnDetails.class).getMessage();
		if (message == null) {
			throw new IllegalStateException("Message is not defined in wizard");
		}
		entityType = (String) context.get(MbOperTypeSelectionStep.ENTITY_TYPE);

		statuses = new ArrayList<SelectItem>();
		for (SelectItem item: getAllStatuses()) {
			if (!item.getValue().equals(message.getReconStatus())) {
				statuses.add(item);
			}
		}

		newStatus = null;
	}

	@Override
	public Map<String, Object> release(Direction direction) {
		classLogger.trace("release...");
		if (direction == Direction.FORWARD) {
			getContext().put("OPER_ID", changeStatus());
			getContext().put("FREQ", isMaker());
		}
		return getContext();
	}

	@Override
	public boolean validate() {
		return false;
	}


	private Long changeStatus() {
		classLogger.trace("changeStatus...");

		if (newStatus == null || newStatus.trim().length() == 0) return null;
		Operation oper = this.message.toIncomingOperation();

		oper.setStatus(OperationsConstants.OPERATION_STATUS_PROCESS_READY);
		if (isMaker()) {
			oper.setNewOperStatus(newStatus);

			ApplicationBuilder builder = new ApplicationBuilder(
					applicationDao,
					userSessionId,
					message.getReconInstId() != null ? message.getReconInstId() : message.getAcqInstId(),
					getFlowId()
			);

			builder.buildFromOperation(oper, true);
			builder.createApplicationInDB();
			builder.addApplicationObject(message.getId(), entityType);
			return builder.getApplication().getId();
		} else {

			operationDao.addAdjusment(userSessionId, oper);
			if (newStatus != null && newStatus.trim().length() > 0) {
				message.setReconStatus(newStatus);
				message = reconciliationDao.modifyStatus(userSessionId, message);
			}

			return oper.getId();
		}
	}

	public List<SelectItem> getAllStatuses() {
		if (allStatuses == null) {
			allStatuses = getDictUtils().getLov(LovConstants.RECONCILIATION_STATUSES);
		}
		return allStatuses;
	}

	public List<SelectItem> getStatuses() {
		return statuses;
	}

	public String getNewStatus() {
		return newStatus;
	}

	public void setNewStatus(String newStatus) {
		this.newStatus = newStatus;
	}
}
