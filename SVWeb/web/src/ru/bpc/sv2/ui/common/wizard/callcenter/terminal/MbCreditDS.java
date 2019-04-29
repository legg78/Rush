package ru.bpc.sv2.ui.common.wizard.callcenter.terminal;

import java.math.BigDecimal;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Iterator;
import java.util.List;
import java.util.Map;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.model.SelectItem;

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
import ru.bpc.sv2.logic.OperationDao;
import ru.bpc.sv2.operations.incoming.Operation;
import ru.bpc.sv2.ui.common.wizard.MbCommonWizard;
import ru.bpc.sv2.ui.utils.CurrencyCache;

@ViewScoped
@ManagedBean(name = "MbCreditDS")
public class MbCreditDS extends AbstractIFX {
	private static final Logger logger = Logger.getLogger(MbCreditDS.class);
	private static final String PAGE = "/pages/common/wizard/callcenter/terminal/creditDS.jspx";

	private String currency;
	private String cardNumber;
	private BigDecimal amount;
	private SimpleSelection operationSelection;
	private boolean invalidOperation;
	private Operation selectedOperation;
	
	private OperationDao operationDao = new OperationDao();
	
	private Operation[] operations;

	@Override
	protected Logger getLogger() {
		return logger;
	}

	@Override
	public void init(Map<String, Object> context) {
		super.init(context);
		operations = operationsByTerminalId(getTerminal().getId().longValue());
		context.put(MbCommonWizard.PAGE, PAGE);
		context.put(MbCommonWizard.VALIDATED_STEP, Boolean.TRUE); // Check that the operation is selected
	}
	
	private Operation[] operationsByTerminalId(Long termId){
		logger.trace("operationsByTerminal...");
		Operation[] result;
		SimpleDateFormat sdf = new SimpleDateFormat("dd.MM.yyyy");
	    String sDate = sdf.format(new Date());
		
		SelectionParams sp = SelectionParams.build(
				"terminalId", termId,
				"oper_type", "OPTP0000",
				"oper_date", sDate);
		sp.setRowIndexEnd(-1);
		result = operationDao.getOperationsByTerminal(userSessionId, sp);
		return result;
	}

	@Override
	protected void reset() {
		super.reset();
		currency = null;
		cardNumber = null;
		amount = null;
		operationSelection = null;
		selectedOperation = null;
		invalidOperation = false;
	}

	@Override
	protected AthInfoType prepareAuthInfo() {
		logger.trace("prepareAuthInfo...");
		AthInfoType athInfo = new AthInfoType();
		athInfo.setAthType("CreditVoucher");
		CompositeCurAmtType compositeCurAmtType = new CompositeCurAmtType();
		compositeCurAmtType.setCompositeCurAmtType("Credit");
		CurAmtType curAmtType = new CurAmtType();
		curAmtType.setAmt(amount);
		CurCodeType curCode = new CurCodeType();
		String currencyShort = CurrencyCache.getInstance().getCurrencyShortNamesMap().get(currency);
		curCode.setCurCodeValue(currencyShort);
		curAmtType.setCurCode(curCode);
		compositeCurAmtType.setCurAmt(curAmtType);
		athInfo.getCompositeCurAmt().add(compositeCurAmtType);
		CardKeysType cardKeys = new CardKeysType();
		cardKeys.setCardNum(cardNumber);
		AcctKeysType acctKeys = new AcctKeysType();
		acctKeys.setCardKeys(cardKeys);
		athInfo.setAcctKeys(acctKeys);
		athInfo.setDebitCredit("Credit");
		athInfo.setPreAthInd("0");
		
		RefDataType refData = new RefDataType();
		refData.setRefType("OrigOperId");
		if (selectedOperation.getOriginalId() != null){
			refData.setRefIdent(selectedOperation.getId().toString());
		}
		athInfo.getRefData().add(refData);
		
		return athInfo;
	}

	public String getCurrency() {
		return currency;
	}

	public void setCurrency(String currency) {
		this.currency = currency;
	}

	public BigDecimal getAmount() {
		return amount;
	}

	public void setAmount(BigDecimal amount) {
		this.amount = amount;
	}

	public String getCardNumber() {
		return cardNumber;
	}

	public void setCardNumber(String cardNumber) {
		this.cardNumber = cardNumber;
	}

	public List<SelectItem> getCurrencies() {
		return CurrencyCache.getInstance().getAllCurrencies(curLang);
	}
	
	public Operation[] getOperations(){
		return operations;
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
			amount = selectedOperation.getOperationAmount();
			currency = selectedOperation.getOperationCurrency();
			cardNumber = selectedOperation.getCardNumber();
		}
	}
	
	public SimpleSelection getOperationSelection(){
		return operationSelection;
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
	
	public boolean isInvalidOperation(){
		return invalidOperation;
	}
	
	public Operation getSelectedOperation(){
		return selectedOperation;
	}
}
