package ru.bpc.sv2.ui.common.wizard.callcenter.terminal;

import java.math.BigDecimal;
import java.util.Iterator;
import java.util.Map;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;

import org.apache.log4j.Logger;
import org.ifxforum.xsd._1.AcctKeysType;
import org.ifxforum.xsd._1.AthInfoType;
import org.ifxforum.xsd._1.CardKeysType;
import org.ifxforum.xsd._1.CompositeCurAmtType;
import org.ifxforum.xsd._1.CurAmtType;
import org.ifxforum.xsd._1.CurCodeType;
import org.ifxforum.xsd._1.RefDataType;
import org.richfaces.model.selection.SimpleSelection;

import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.issuing.Card;
import ru.bpc.sv2.logic.IssuingDao;
import ru.bpc.sv2.logic.OperationDao;
import ru.bpc.sv2.operations.Operation;
import ru.bpc.sv2.operations.Participant;
import ru.bpc.sv2.ui.common.wizard.MbCommonWizard;
import ru.bpc.sv2.ui.utils.CurrencyCache;

@ViewScoped
@ManagedBean(name = "MbCompletionDS")
public class MbCompletionDS extends AbstractIFX{

	private final static Logger logger = Logger.getLogger(MbPreAuthDS.class);
	private static final String PAGE = "/pages/common/wizard/callcenter/terminal/completionDS.jspx";

	private OperationDao operationDao = new OperationDao();
	
	private IssuingDao issuingDao = new IssuingDao();
	
	private BigDecimal amount;
	private Operation[] operations;
	private SimpleSelection operationSelection;
	private Operation selectedOperation;
	private boolean invalidOperation;
	private String cardNumber;
	
	@Override
	public void init(Map<String, Object> context){
		super.init(context);
		
		operations = operationsByTerminalId(getTerminal().getId().longValue());
		context.put(MbCommonWizard.PAGE, PAGE);
		context.put(MbCommonWizard.VALIDATED_STEP, Boolean.TRUE); // Check that the operation is selected
	}
	
	private Operation[] operationsByTerminalId(Long termId){
		logger.trace("operationsByTerminal...");
		Operation[] result;
		SelectionParams sp = SelectionParams.build(
				"terminalId", termId
				, "msgType", "MSGTPREU"
				,"lang", curLang);
		sp.setRowIndexEnd(-1);
		result = operationDao.getOperationsByParticipant(userSessionId, sp);
		return result;
	}	
	
	@Override
	protected void reset(){
		super.reset();
		amount = new BigDecimal(0);
		operations = null;
		operationSelection = null;
		selectedOperation = null;
		invalidOperation = false;
	}
	
	@Override
	protected AthInfoType prepareAuthInfo() {
		logger.trace("prepareAuthInfo...");
		AthInfoType athInfo = new AthInfoType();
		athInfo.setAthType("Completion");
		CompositeCurAmtType compositeCurAmtType = new CompositeCurAmtType();
		compositeCurAmtType.setCompositeCurAmtType("Debit");
		CurAmtType curAmtType = new CurAmtType();
		curAmtType.setAmt(amount);
		CurCodeType curCode = new CurCodeType();
		String currencyShort = CurrencyCache.getInstance().getCurrencyShortNamesMap().get(selectedOperation.getOperCurrency());
		curCode.setCurCodeValue(currencyShort);
		curAmtType.setCurCode(curCode);
		compositeCurAmtType.setCurAmt(curAmtType);		
		athInfo.getCompositeCurAmt().add(compositeCurAmtType);
		CardKeysType cardKeys = new CardKeysType();
		cardKeys.setCardNum(cardNumber);
		AcctKeysType acctKeys = new AcctKeysType();
		acctKeys.setCardKeys(cardKeys);
		athInfo.setAcctKeys(acctKeys);
		athInfo.setDebitCredit("Debit");
		athInfo.setPreAthInd("0");
		RefDataType refData = new RefDataType();
		refData.setRefType("OrigOperId");
		if (selectedOperation.getOriginalId() != null){
			refData.setRefIdent(selectedOperation.getId().toString());
		}
		athInfo.getRefData().add(refData);
		return athInfo;
	}

	@Override
	public Map<String, Object> release(Direction direction) {
		if (direction == Direction.FORWARD){
			SelectionParams sp = SelectionParams.build("operId", selectedOperation.getId()
					, "lang", curLang, "participantType", "PRTYISS");
			sp.setRowIndexEnd(1);
			Participant[] participants = operationDao.getParticipants(userSessionId, sp);
			Participant participant = null;
			if (participants.length != 0){
				participant = participants[0];
			}
			sp = SelectionParams.build("id", participant.getCardId(), "lang", curLang);
			sp.setRowIndexEnd(1);
			Card[] cards = issuingDao.getCards(userSessionId, sp);
			Card card = null;
			if (cards.length != 0){
				card = cards[0];
			}
			
			cardNumber = card.getCardNumber();
		}
		return super.release(direction);
	}
	
	@Override
	protected Logger getLogger() {
		return logger;
	}

	public void setOperationSelection(SimpleSelection operationSelection) {
		logger.trace("setOperationSelection...");
		this.operationSelection = operationSelection;
		if (operations == null || operations.length == 0) return;
		int index = selectedIdx();
		if (index < 0) return;
		Operation operation = operations[index];
		if (!operation.equals(selectedOperation)){
			selectedOperation = operation;
			amount = selectedOperation.getOperAmount();
		}
	}
	
	private Integer selectedIdx(){
		logger.trace("selectedIdx...");
		Iterator<Object> keys = operationSelection.getKeys();
		if (!keys.hasNext()) return -1;
		Integer index = (Integer) keys.next();
		return index;
	}	
	
	@Override
	public boolean validate(){
		logger.trace("validate...");
		return checkCardInstance();
	}
	
	private boolean checkCardInstance(){
		return !(invalidOperation = (selectedOperation == null));
	}	
	
	public SimpleSelection getOperationSelection(){
		return operationSelection;
	}
	
	public BigDecimal getAmount() {
		return amount;
	}

	public void setAmount(BigDecimal amount) {
		this.amount = amount;
	}

	public Operation[] getOperations(){
		return operations;
	}
	
	public boolean isInvalidOperation(){
		return invalidOperation;
	}
	
	public Operation getSelectedOperation(){
		return selectedOperation;
	}
	
}
