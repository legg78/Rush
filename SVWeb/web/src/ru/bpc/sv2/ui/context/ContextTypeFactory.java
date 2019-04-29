package ru.bpc.sv2.ui.context;

import ru.bpc.sv2.constants.EntityNames;

public class ContextTypeFactory {
	
	public static ContextType getInstance(String type)
	{
/*		
		if (EntityNames.CARD.equals(type)) {
			return new ContextTypeCards();
		}

		if (EntityNames.CUSTOMER.equals(type)) {
			return new ContextTypeCust();
		}
*/
/*		
		if (EntityNames.INSTITUTION.equals(type)) {
			return new ContextTypeInst();
		}
*/		
/*		
		if (EntityNames.PRODUCT.equals(type)) {
			return new ContextTypeProduct();
		}

		if (EntityNames.ACCOUNT.equals(type)) {
			return new ContextTypeAccount();
		}
		
		if (EntityNames.CONTRACT.equals(type)) {
			return new ContextTypeContract();
		}

		if (EntityNames.MERCHANT.equals(type)) {
			return new ContextTypeMerchant();
		}

		if (EntityNames.TERMINAL.equals(type)) {
			return new ContextTypeTerminal();
		}

		if (EntityNames.RULE_SET.equals(type)) {
			return new ContextTypeRuleSet();
		}
		if (EntityNames.CARDHOLDER.equals(type)) {
			return new ContextTypeCardholder();
		}
		if (EntityNames.SERVICE.equals(type)) {
			return new ContextTypeService();
		}

		if (EntityNames.AGENT.equals(type)) {
			return new ContextTypeAgent();
		}

		if (EntityNames.APPLICATION.equals(type)) {
			return new ContextTypeApplication();
		}

		if (EntityNames.USER.equals(type)) {
			return new ContextTypeUser();
		}

		if (EntityNames.PAYMENT_ORDER.equals(type)) {
			return new ContextTypePaymentOrder();
		}

		if (EntityNames.OPERATION.equals(type)) {
			return new ContextTypeOperation();
		}
*/
		return new ContextTypeEntities(type);
	}

}
