package ru.bpc.sv2.ui.common.wizard.callcenter.terminal;

import java.math.BigDecimal;
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

import ru.bpc.sv2.ui.common.wizard.MbCommonWizard;
import ru.bpc.sv2.ui.utils.CurrencyCache;

@ViewScoped
@ManagedBean (name = "MbCasheDS")
public class MbCasheDS extends AbstractIFX{

	private static final Logger logger = Logger.getLogger(MbCreditDS.class);
	private static final String PAGE = "/pages/common/wizard/callcenter/terminal/casheDS.jspx";

	private String currency;
	private String cardNumber;
	private BigDecimal amount;

	@Override
	protected Logger getLogger() {
		return logger;
	}

	@Override
	public void init(Map<String, Object> context) {
		super.init(context);
		context.put(MbCommonWizard.PAGE, PAGE);
	}

	@Override
	protected void reset() {
		super.reset();
		currency = null;
		cardNumber = null;
		amount = null;
	}

	@Override
	protected AthInfoType prepareAuthInfo() {
		logger.trace("prepareAuthInfo...");
		AthInfoType athInfo = new AthInfoType();
		athInfo.setAthType("Cash");
		CompositeCurAmtType compositeCurAmtType = new CompositeCurAmtType();
		compositeCurAmtType.setCompositeCurAmtType("Debit");
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
		athInfo.setDebitCredit("Debit");
		athInfo.setPreAthInd("0");
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

}
