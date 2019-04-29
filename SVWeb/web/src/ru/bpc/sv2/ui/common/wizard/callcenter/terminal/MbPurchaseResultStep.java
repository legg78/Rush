package ru.bpc.sv2.ui.common.wizard.callcenter.terminal;

import org.apache.log4j.Logger;
import org.ifxforum.xsd._1.AthAddRsType;
import ru.bpc.sv2.acquiring.Merchant;
import ru.bpc.sv2.acquiring.Terminal;
import ru.bpc.sv2.common.WizardConstants;
import ru.bpc.sv2.products.Customer;
import ru.bpc.sv2.ui.common.wizard.CommonWizardStep;
import ru.bpc.sv2.ui.common.wizard.MbCommonWizard;

import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import java.math.BigDecimal;
import java.util.Map;

@ViewScoped
@ManagedBean(name = "MbPurchaseResultStep")
public class MbPurchaseResultStep implements CommonWizardStep{

	private static final Logger logger = Logger.getLogger(MbPurchaseResultStep.class);
	private static final String PAGE = "/pages/common/wizard/callcenter/terminal/purchaseRS.jspx";
	
	private Map<String, Object> context;
	private Long objectId;
	private Terminal terminal;
	private Merchant merchant;
	private Customer customer;
	private long userSessionId;
	private String curLang;
	private String currency;
	private String cardNumber;
	private BigDecimal amount;
	
	private String operId;
	private Integer status;
	private String authResponse;
	private String authCode;
	private String authApprovalIdent;
	private String faultString;
		
	@Override
	public void init(Map<String, Object> context) {
		logger.trace("init...");
		this.context = context;
		context.put(MbCommonWizard.PAGE, PAGE);
		
		if (context.containsKey(MbPurchaseStep.FAULT_STRING)){
			faultString=(String) context.get(MbPurchaseStep.FAULT_STRING);
		}else{
			if (context.containsKey(WizardConstants.OPER_STATUS)){
				setOperResult((AthAddRsType)context.get(WizardConstants.OPER_STATUS));
			} else {
				throw new IllegalStateException("OPER_STATUS is not defined in wizard context");
			}
		}	
		if (context.containsKey(MbPurchaseStep.TERMINAL)){
			terminal = (Terminal) context.get(MbPurchaseStep.TERMINAL);
		} else {
			throw new IllegalStateException("TERMINAL is not defined in wizard context");
		}
		if (context.containsKey(MbPurchaseStep.MERCHANT)){
			merchant = (Merchant) context.get(MbPurchaseStep.MERCHANT);
		} else {
			throw new IllegalStateException("MERCHANT is not defined in wizard context");
		}
		if (context.containsKey(MbPurchaseStep.CUSTOMER)){
			customer = (Customer) context.get(MbPurchaseStep.CUSTOMER);
		} else {
			throw new IllegalStateException("CUSTOMER is not defined in wizard context");
		}
		context.put(MbCommonWizard.DISABLE_BACK, Boolean.TRUE);
	}

	@Override
	public Map<String, Object> release(Direction direction) {
		logger.trace("release...");	
		return context;
	}

	@Override
	public boolean validate() {
		logger.trace("validate...");
		return false;
	}

	public Terminal getTerminal() {
		return terminal;
	}

	public void setTerminal(Terminal terminal) {
		this.terminal = terminal;
	}

	public Merchant getMerchant() {
		return merchant;
	}

	public void setMerchant(Merchant merchant) {
		this.merchant = merchant;
	}

	public Customer getCustomer() {
		return customer;
	}

	public void setCustomer(Customer customer) {
		this.customer = customer;
	}

	public String getCurrency() {
		return currency;
	}

	public void setCurrency(String currency) {
		this.currency = currency;
	}

	public String getCardNumber() {
		return cardNumber;
	}

	public void setCardNumber(String cardNumber) {
		this.cardNumber = cardNumber;
	}

	public BigDecimal getAmount() {
		return amount;
	}

	public void setAmount(BigDecimal amount) {
		this.amount = amount;
	}

	private void setOperResult(AthAddRsType athAddRs) {
		status = athAddRs.getStatus().getStatusCode();
		operId = athAddRs.getAthStatusRec().getAthId();
		authCode = athAddRs.getAthStatusRec().getAthStatus().getAthStatusCode();
		authResponse = athAddRs.getAthStatusRec().getAthStatus().getAthResponse();
		authApprovalIdent = athAddRs.getAthStatusRec().getAthStatus().getApprovalIdent();
	}

	public String getOperId() {
		return operId;
	}

	public void setOperId(String operId) {
		this.operId = operId;
	}

	public Integer getStatus() {
		return status;
	}

	public void setStatus(Integer status) {
		this.status = status;
	}

	public String getAuthResponse() {
		return authResponse;
	}

	public void setAuthResponse(String authResponse) {
		this.authResponse = authResponse;
	}

	public String getAuthCode() {
		return authCode;
	}

	public void setAuthCode(String authCode) {
		this.authCode = authCode;
	}

	public String getAuthApprovalIdent() {
		return authApprovalIdent;
	}

	public void setAuthApprovalIdent(String authApprovalIdent) {
		this.authApprovalIdent = authApprovalIdent;
	}

	public String getFaultString() {
		return faultString;
	}

	public void setFaultString(String faultString) {
		this.faultString = faultString;
	}
	
}
