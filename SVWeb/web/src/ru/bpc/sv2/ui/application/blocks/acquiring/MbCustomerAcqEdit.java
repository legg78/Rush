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
import ru.bpc.sv2.products.Customer;
import ru.bpc.sv2.ui.utils.SimpleAppBlock;

@ViewScoped
@ManagedBean (name = "mbCustomerAcqEdit")
public class MbCustomerAcqEdit extends SimpleAppBlock {
	private static final Logger logger = Logger.getLogger("APPLICATIONS");

	private Customer _activeCustomer;
	private Map<String, ApplicationElement> objectAttrs;

	private String command;
	private String customerNumber;
	private String category;
	private String relation;
	private String nationality;
	private boolean resident;
	private Integer accountScheme;
	private String creditRating;
	private String moneyLaundryRisk;
	private String moneyLaundryReason;

	public MbCustomerAcqEdit() {
	}

	public Customer getActiveCustomer() {
		return _activeCustomer;
	}

	public void parseAppBlock() {
		// implement hardcode here
		_activeCustomer = new Customer();
		objectAttrs = new HashMap<String, ApplicationElement>();
		try {
			for (ApplicationElement el : getLocalRootEl().getChildren()) {
				if (el.isComplex()) {
					continue;
				}

				if (el.getContent()) {
					// implement some logic if needed
				}
				String name = el.getName();
				if (name.equals("CUSTOMER_NUMBER")) {
					customerNumber = el.getValueV();
					getObjectAttrs().put("CUSTOMER_NUMBER", el);

				} else if (name.equals("CUSTOMER_CATEGORY")) {
					category = el.getValueV();
					getObjectAttrs().put("CUSTOMER_CATEGORY", el);

				} else if (name.equals("ACCOUNT_SCHEME")) {
					if (el.getValueN() == null) {
						accountScheme = null;
					} else {
						accountScheme = el.getValueN().intValue();
					}
					getObjectAttrs().put("ACCOUNT_SCHEME", el);

				} else if (name.equals("CUSTOMER_RELATION")) {
					relation = el.getValueV();
					getObjectAttrs().put("CUSTOMER_RELATION", el);

				} else if (name.equals("RESIDENT")) {
					if (el.getValueN() == null) {
						resident = false;
					} else {
						resident = el.getValueN().longValue() > 0 ? true : false;
					}
					getObjectAttrs().put("RESIDENT", el);

				} else if (name.equals("NATIONALITY")) {
					nationality = el.getValueV();
					getObjectAttrs().put("NATIONALITY", el);

				} else if (name.equals("COMMAND")) {
					command = el.getValueV();
					getObjectAttrs().put("COMMAND", el);

				} else if (name.equals("CREDIT_RATING")){
					creditRating = el.getValueV();
					getObjectAttrs().put("CREDIT_RATING", el);
				} else if (name.equals("MONEY_LAUNDRY_RISK")){
					moneyLaundryRisk = el.getValueV();
					getObjectAttrs().put("MONEY_LAUNDRY_RISK", el);
				} else if (name.equals("MONEY_LAUNDRY_REASON")){
					moneyLaundryReason = el.getValueV();
					getObjectAttrs().put("MONEY_LAUNDRY_REASON", el);
				}
			}
		} catch (Exception e) {
			logger.error("", e);
		}
	}

	@Override
	public void formatObject(ApplicationElement root) {
		// implement hardcode here
		if (getSourceRootEl() == null) {
			return;
		}
		ApplicationElement el = null;
		el = root.getChildByName("CUSTOMER_NUMBER", 1);
		el.setValueV(customerNumber);

		el = root.getChildByName("ACCOUNT_SCHEME", 1);
		if (accountScheme == null) {
			el.setValueN((BigDecimal)null);
		} else {
			el.setValueN(new BigDecimal(accountScheme));
		}

		el = root.getChildByName("CUSTOMER_CATEGORY", 1);
		el.setValueV(category);

		el = root.getChildByName("CUSTOMER_RELATION", 1);
		el.setValueV(relation);

		el = root.getChildByName("RESIDENT", 1);
		if (resident) {
			el.setValueN(BigDecimal.valueOf(1L));
		} else {
			el.setValueN(BigDecimal.valueOf(0L));
		}

		el = root.getChildByName("NATIONALITY", 1);
		el.setValueV(nationality);

		el = root.getChildByName("COMMAND", 1);
		el.setValueV(command);

		
		el = root.getChildByName("CREDIT_RATING", 1);
		el.setValueV(creditRating);

		el = root.getChildByName("MONEY_LAUNDRY_RISK", 1);
		el.setValueV(moneyLaundryRisk);
		
		el = root.getChildByName("MONEY_LAUNDRY_REASON", 1);
		el.setValueV(moneyLaundryReason);
	}

	@Override
	public void clear() {
		super.clear();
		_activeCustomer = null;
	}

	public List<SelectItem> getCustomerCategories() {
		return getLov(getObjectAttrs().get("CUSTOMER_CATEGORY"));
	}

	public List<SelectItem> getCustomerRelations() {
		return getLov(getObjectAttrs().get("CUSTOMER_RELATION"));
	}

	public List<SelectItem> getInsiders() {
		return getLov(getObjectAttrs().get("INSIDER"));
	}

	public List<SelectItem> getResidents() {
		return getLov(getObjectAttrs().get("RESIDENT"));
	}

	public List<SelectItem> getNationalities() {
		return getLov(getObjectAttrs().get("NATIONALITY"));
	}

	public List<SelectItem> getCommandsList() {
		return getLov(getObjectAttrs().get("COMMAND"));
	}

	public List<SelectItem> getAccountSchemes() {
		return getLov(getObjectAttrs().get("ACCOUNT_SCHEME"));
	}

	public List<SelectItem> getCreditRatings() {
		return getLov(getObjectAttrs().get("CREDIT_RATING"));
	}
	
	public List<SelectItem> getMoneyLaundryRisks() {
		return getLov(getObjectAttrs().get("MONEY_LAUNDRY_RISK"));
	}	

	public List<SelectItem> getMoneyLaundryReasons() {
		return getLov(getObjectAttrs().get("MONEY_LAUNDRY_REASON"));
	}	
	
	public String getCommand() {
		return command;
	}

	public void setCommand(String command) {
		this.command = command;
	}

	public String getCustomerNumber() {
		return customerNumber;
	}

	public void setCustomerNumber(String customerNumber) {
		this.customerNumber = customerNumber;
	}

	public String getCategory() {
		return category;
	}

	public void setCategory(String category) {
		this.category = category;
	}

	public String getRelation() {
		return relation;
	}

	public void setRelation(String relation) {
		this.relation = relation;
	}

	public String getNationality() {
		return nationality;
	}

	public void setNationality(String nationality) {
		this.nationality = nationality;
	}

	public boolean getResident() {
		return resident;
	}

	public void setResident(boolean resident) {
		this.resident = resident;
	}

	public Integer getAccountScheme() {
		return accountScheme;
	}

	public void setAccountScheme(Integer accountScheme) {
		this.accountScheme = accountScheme;
	}

	protected Logger getLogger() {
		return logger;
	}

	@Override
	public Map<String, ApplicationElement> getObjectAttrs() {
		return objectAttrs;
	}

	public String getCreditRating() {
		return creditRating;
	}

	public void setCreditRating(String creditRating) {
		this.creditRating = creditRating;
	}

	public String getMoneyLaundryRisk() {
		return moneyLaundryRisk;
	}

	public void setMoneyLaundryRisk(String moneyLaundryRisk) {
		this.moneyLaundryRisk = moneyLaundryRisk;
	}

	public String getMoneyLaundryReason() {
		return moneyLaundryReason;
	}

	public void setMoneyLaundryReason(String moneyLaundryReason) {
		this.moneyLaundryReason = moneyLaundryReason;
	}
}
