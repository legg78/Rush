package ru.bpc.sv2.ui.application.blocks.acquiring;

import java.math.BigDecimal;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.model.SelectItem;

import org.apache.log4j.Logger;

import ru.bpc.sv2.application.ApplicationElement;
import ru.bpc.sv2.atm.TerminalATM;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.ui.utils.DictUtils;
import ru.bpc.sv2.ui.utils.SimpleAppBlock;
import util.auxil.ManagedBeanWrapper;

@ViewScoped
@ManagedBean (name = "mbAtmTerminalEdit")
public class MbAtmTerminalEdit extends SimpleAppBlock {

	private static final Logger logger = Logger.getLogger("APPLICATIONS");

	private static final String ATM_TYPE = "ATM_TYPE";
	private static final String CASSETTE_COUNT = "CASSETTE_COUNT";
	private static final String HOPPER_COUNT = "HOPPER_COUNT";
	private static final String KEY_CHANGE_ALGORITHM = "KEY_CHANGE_ALGORITHM";
	private static final String COUNTER_SYNC_COND = "COUNTER_SYNC_COND";
	private static final String REJECT_DISP_WARN = "REJECT_DISP_WARN";
	private static final String DISP_REST_WARN = "DISP_REST_WARN";
	private static final String RECEIPT_WARN = "RECEIPT_WARN";
	private static final String CARD_CAPTURE_WARN = "CARD_CAPTURE_WARN";
	private static final String NOTE_MAX_COUNT = "NOTE_MAX_COUNT";
	private static final String SCENARIO_ID = "SCENARIO_ID";
	private static final String COMMAND = "COMMAND";
	private static final String MANUAL_SYNCH = "MANUAL_SYNCH";
	private static final String ESTABL_CONN_SYNCH = "ESTABL_CONN_SYNCH";
	private static final String COUNTER_MISMATCH_SYNCH = "COUNTER_MISMATCH_SYNCH";
	private static final String ONLINE_IN_SYNCH = "ONLINE_IN_SYNCH";
	private static final String ONLINE_OUT_SYNCH = "ONLINE_OUT_SYNCH";
	private static final String SAFE_CLOSE_SYNCH = "SAFE_CLOSE_SYNCH";
	private static final String DISP_ERROR_SYNCH = "DISP_ERROR_SYNCH";
	private static final String PERIODIC_SYNCH = "PERIODIC_SYNCH";
	private static final String PERIODIC_ALL_OPER = "PERIODIC_ALL_OPER";
	private static final String PERIODIC_OPER_COUNT = "PERIODIC_OPER_COUNT";

	private TerminalATM activeItem;
	private String command;
	private Map<String, ApplicationElement> objectAttrs;

	@Override
	public void parseAppBlock() {
		setActiveItem(new TerminalATM());
		ApplicationElement childElement;
		objectAttrs = new HashMap<String, ApplicationElement>();

		childElement = getLocalRootEl().getChildByName(ATM_TYPE, 1);
		if (childElement != null) {
			getActiveItem().setAtmType(childElement.getValueV());
			objectAttrs.put(ATM_TYPE, childElement);
		}

		childElement = getLocalRootEl().getChildByName(CASSETTE_COUNT, 1);
		if (childElement != null) {
			getActiveItem()
					.setCassetteCount(
							childElement.getValueN() != null ? childElement.getValueN()
									.shortValue() : null);
			objectAttrs.put(CASSETTE_COUNT, childElement);
		}

		childElement = getLocalRootEl().getChildByName(HOPPER_COUNT, 1);
		if (childElement != null) {
			getActiveItem()
					.setHopperCount(
							childElement.getValueN() != null ? childElement.getValueN()
									.shortValue() : null);
			objectAttrs.put(HOPPER_COUNT, childElement);
		}

		childElement = getLocalRootEl().getChildByName(KEY_CHANGE_ALGORITHM, 1);
		if (childElement != null) {
			getActiveItem().setKeyChangeAlgo(childElement.getValueV());
			objectAttrs.put(KEY_CHANGE_ALGORITHM, childElement);
		}

		childElement = getLocalRootEl().getChildByName(REJECT_DISP_WARN, 1);
		if (childElement != null) {
			getActiveItem()
					.setRejectDispWarn(
							childElement.getValueN() != null ? childElement.getValueN()
									.shortValue() : null);
			objectAttrs.put(REJECT_DISP_WARN, childElement);
		}

		childElement = getLocalRootEl().getChildByName(DISP_REST_WARN, 1);
		if (childElement != null) {
			getActiveItem()
					.setDispRestWarn(
							childElement.getValueN() != null ? childElement.getValueN()
									.shortValue() : null);
			objectAttrs.put(DISP_REST_WARN, childElement);
		}

		childElement = getLocalRootEl().getChildByName(RECEIPT_WARN, 1);
		if (childElement != null) {
			getActiveItem()
					.setReceiptWarn(
							childElement.getValueN() != null ? childElement.getValueN()
									.shortValue() : null);
			objectAttrs.put(RECEIPT_WARN, childElement);
		}

		childElement = getLocalRootEl().getChildByName(CARD_CAPTURE_WARN, 1);
		if (childElement != null) {
			getActiveItem()
					.setCardCaptureWarn(
							childElement.getValueN() != null ? childElement.getValueN()
									.shortValue() : null);
			objectAttrs.put(CARD_CAPTURE_WARN, childElement);
		}

		childElement = getLocalRootEl().getChildByName(NOTE_MAX_COUNT, 1);
		if (childElement != null) {
			getActiveItem()
					.setNoteMaxCount(
							childElement.getValueN() != null ? childElement.getValueN()
									.shortValue() : null);
			objectAttrs.put(NOTE_MAX_COUNT, childElement);
		}

		childElement = getLocalRootEl().getChildByName(SCENARIO_ID, 1);
		if (childElement != null) {
			getActiveItem()
					.setScenarioId(
							childElement.getValueN() != null ? childElement.getValueN()
									.shortValue() : null);
			objectAttrs.put(SCENARIO_ID, childElement);
		}

		childElement = getLocalRootEl().getChildByName(MANUAL_SYNCH, 1);
		if (childElement != null) {
			getActiveItem().setManualSynch(childElement.getValueV());
			objectAttrs.put(MANUAL_SYNCH, childElement);
		}

		childElement = getLocalRootEl().getChildByName(ESTABL_CONN_SYNCH, 1);
		if (childElement != null) {
			getActiveItem().setEstablConnSynch(childElement.getValueV());
			objectAttrs.put(ESTABL_CONN_SYNCH, childElement);
		}

		childElement = getLocalRootEl().getChildByName(COUNTER_MISMATCH_SYNCH, 1);
		if (childElement != null) {
			getActiveItem().setCounterMismatchSynch(childElement.getValueV());
			objectAttrs.put(COUNTER_MISMATCH_SYNCH, childElement);
		}

		childElement = getLocalRootEl().getChildByName(ONLINE_IN_SYNCH, 1);
		if (childElement != null) {
			getActiveItem().setOnlineInSynch(childElement.getValueV());
			objectAttrs.put(ONLINE_IN_SYNCH, childElement);
		}

		childElement = getLocalRootEl().getChildByName(ONLINE_OUT_SYNCH, 1);
		if (childElement != null) {
			getActiveItem().setOnlineOutSynch(childElement.getValueV());
			objectAttrs.put(ONLINE_OUT_SYNCH, childElement);
		}

		childElement = getLocalRootEl().getChildByName(SAFE_CLOSE_SYNCH, 1);
		if (childElement != null) {
			getActiveItem().setSafeCloseSynch(childElement.getValueV());
			objectAttrs.put(SAFE_CLOSE_SYNCH, childElement);
		}

		childElement = getLocalRootEl().getChildByName(DISP_ERROR_SYNCH, 1);
		if (childElement != null) {
			getActiveItem().setDispErrorSynch(childElement.getValueV());
			objectAttrs.put(DISP_ERROR_SYNCH, childElement);
		}

		childElement = getLocalRootEl().getChildByName(PERIODIC_SYNCH, 1);
		if (childElement != null) {
			getActiveItem().setPeriodicSynch(childElement.getValueV());
			objectAttrs.put(PERIODIC_SYNCH, childElement);
		}

		childElement = getLocalRootEl().getChildByName(PERIODIC_ALL_OPER, 1);
		if (childElement != null) {
			getActiveItem().setPeriodicAllOper(
					childElement.getValueN() != null ? childElement.getValueN().intValue() : null);
			objectAttrs.put(PERIODIC_ALL_OPER, childElement);
		}

		childElement = getLocalRootEl().getChildByName(PERIODIC_OPER_COUNT, 1);
		if (childElement != null) {
			getActiveItem().setPeriodicOperCount(
					childElement.getValueN() != null ? childElement.getValueN().intValue() : null);
			objectAttrs.put(PERIODIC_OPER_COUNT, childElement);
		}

		childElement = getLocalRootEl().getChildByName(COMMAND, 1);
		if (childElement != null) {
			setCommand(childElement.getValueV());
			objectAttrs.put(COMMAND, childElement);
		}
	}

	protected void clear() {
		super.clear();
		command = null;
	}

	public void formatObject(ApplicationElement element) {
		if (getActiveItem() == null || getSourceRootEl() == null) {
			return;
		}
		ApplicationElement childElement;

		childElement = element.getChildByName(COMMAND, 1);
		if (childElement != null) {
			childElement.setValueV(getCommand());
		}

		childElement = element.getChildByName(ATM_TYPE, 1);
		if (childElement != null) {
			childElement.setValueV(activeItem.getAtmType());
		}

		childElement = element.getChildByName(CASSETTE_COUNT, 1);
		if (childElement != null) {
			childElement.setValueN(activeItem.getCassetteCount() != null ? new BigDecimal(
					activeItem.getCassetteCount()) : null);
		}

		childElement = element.getChildByName(HOPPER_COUNT, 1);
		if (childElement != null) {
			childElement.setValueN(activeItem.getHopperCount() != null ? new BigDecimal(activeItem
					.getHopperCount()) : null);
		}

		childElement = element.getChildByName(KEY_CHANGE_ALGORITHM, 1);
		if (childElement != null) {
			childElement.setValueV(activeItem.getKeyChangeAlgo());
		}

		childElement = element.getChildByName(REJECT_DISP_WARN, 1);
		if (childElement != null) {
			childElement.setValueN(activeItem.getRejectDispWarn() != null ? new BigDecimal(
					activeItem.getRejectDispWarn()) : null);
		}

		childElement = element.getChildByName(DISP_REST_WARN, 1);
		if (childElement != null) {
			childElement.setValueN(getActiveItem().getDispRestWarn() != null ? new BigDecimal(
					activeItem.getDispRestWarn()) : null);
		}

		childElement = element.getChildByName(RECEIPT_WARN, 1);
		if (childElement != null) {
			childElement.setValueN(getActiveItem().getReceiptWarn() != null ? new BigDecimal(
					activeItem.getReceiptWarn()) : null);
		}

		childElement = element.getChildByName(CARD_CAPTURE_WARN, 1);
		if (childElement != null) {
			childElement.setValueN(getActiveItem().getCardCaptureWarn() != null ? new BigDecimal(
					activeItem.getCardCaptureWarn()) : null);
		}

		childElement = element.getChildByName(NOTE_MAX_COUNT, 1);
		if (childElement != null) {
			childElement.setValueN(getActiveItem().getNoteMaxCount() != null ? new BigDecimal(
					activeItem.getNoteMaxCount()) : null);
		}

		childElement = element.getChildByName(SCENARIO_ID, 1);
		if (childElement != null) {
			childElement.setValueN(getActiveItem().getScenarioId() != null ? new BigDecimal(
					activeItem.getScenarioId()) : null);
		}

		childElement = element.getChildByName(MANUAL_SYNCH, 1);
		if (childElement != null) {
			childElement.setValueV(getActiveItem().getManualSynch());
		}

		childElement = element.getChildByName(ESTABL_CONN_SYNCH, 1);
		if (childElement != null) {
			childElement.setValueV(getActiveItem().getEstablConnSynch());
		}

		childElement = element.getChildByName(COUNTER_MISMATCH_SYNCH, 1);
		if (childElement != null) {
			childElement.setValueV(getActiveItem().getCounterMismatchSynch());
		}

		childElement = element.getChildByName(ONLINE_IN_SYNCH, 1);
		if (childElement != null) {
			childElement.setValueV(getActiveItem().getOnlineInSynch());
		}

		childElement = element.getChildByName(ONLINE_OUT_SYNCH, 1);
		if (childElement != null) {
			childElement.setValueV(getActiveItem().getOnlineOutSynch());
		}

		childElement = element.getChildByName(SAFE_CLOSE_SYNCH, 1);
		if (childElement != null) {
			childElement.setValueV(getActiveItem().getSafeCloseSynch());
		}

		childElement = element.getChildByName(DISP_ERROR_SYNCH, 1);
		if (childElement != null) {
			childElement.setValueV(getActiveItem().getDispErrorSynch());
		}

		childElement = element.getChildByName(PERIODIC_SYNCH, 1);
		if (childElement != null) {
			childElement.setValueV(getActiveItem().getPeriodicSynch());
		}

		childElement = element.getChildByName(PERIODIC_ALL_OPER, 1);
		if (childElement != null) {
			childElement.setValueN(getActiveItem().getPeriodicAllOper() != null ? new BigDecimal(
					activeItem.getPeriodicAllOper()) : null);
		}

		childElement = element.getChildByName(PERIODIC_OPER_COUNT, 1);
		if (childElement != null) {
			childElement.setValueN(getActiveItem().getPeriodicOperCount() != null ? new BigDecimal(
					activeItem.getPeriodicOperCount()) : null);
		}
	}

	protected Logger getLogger() {
		return logger;
	}

	public TerminalATM getActiveItem() {
		return activeItem;
	}

	public void setActiveItem(TerminalATM activeItem) {
		this.activeItem = activeItem;
	}

	public Map<String, ApplicationElement> getObjectAttrs() {
		return objectAttrs;
	}

	public List<SelectItem> getScenarios() {
		return getLov(objectAttrs.get(SCENARIO_ID));
	}

	public List<SelectItem> getKeyChangeAlgorithms() {
		return getLov(objectAttrs.get(KEY_CHANGE_ALGORITHM));
	}

	public List<SelectItem> getCounterSyncConds() {
		return getLov(objectAttrs.get(COUNTER_SYNC_COND));
	}

	public List<SelectItem> getAtmTypes() {
		return getLov(objectAttrs.get(ATM_TYPE));
	}

	public List<SelectItem> getCommands() {
		return getLov(objectAttrs.get(COMMAND));
	}

	public List<SelectItem> getSynchronizationModes() {
		return ((DictUtils) ManagedBeanWrapper.getManagedBean("DictUtils"))
				.getLov(LovConstants.SYNCHRONIZATION_MODES);
	}

	public String getCommand() {
		return command;
	}

	public void setCommand(String command) {
		this.command = command;
	}

}
