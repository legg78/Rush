package ru.bpc.sv2.ui.common.wizard.callcenter;

import java.util.Map;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;

import org.apache.log4j.Logger;

import ru.bpc.sv2.constants.EntityNames;
import ru.bpc.sv2.issuing.Card;
import ru.bpc.sv2.products.Customer;
import ru.bpc.sv2.ui.common.wizard.CommonWizardStep;
import ru.bpc.sv2.ui.common.wizard.MbCommonWizard;
import util.auxil.ManagedBeanWrapper;

@ViewScoped
@ManagedBean (name = "MbCardDetailsStep")
public class MbCardDetailsStep implements CommonWizardStep{

	private static final Logger logger = Logger.getLogger(MbCardDetailsStep.class);
	
	private static final String PAGE = "/pages/common/wizard/callcenter/cardDetailsStep.jspx";
	private static final String OBJECT_ID = "OBJECT_ID";
	public static final String CARD = "CARD";
	public static final String CUSTOMER = "CUSTOMER";
	public static final String ENTITY_TYPE = "ENTITY_TYPE";
	
	private Map<String, Object> context;
	
	private Long objectId;
	private MbWzCardDetails cardDetails;
	
	@Override
	public void init(Map<String, Object> context) {
		logger.trace("MbCardDetailsStep::init...");
		reset();
		this.context = context;
		
		if (context.containsKey(OBJECT_ID)){
			objectId = (Long)context.get(OBJECT_ID);
		} else {
			throw new IllegalStateException("OBJECT_ID is not defined in wizard context");
		}
		cardDetails = ManagedBeanWrapper.getManagedBean(MbWzCardDetails.class);
		cardDetails.init(objectId);
		
		context.put(MbCommonWizard.PAGE, PAGE);
	}

	private void reset(){
		cardDetails = null;
		objectId = null;
	}
	
	@Override
	public Map<String, Object> release(Direction direction) {
		logger.trace("MbCardDetailsStep::release...");
		context.put(CARD, cardDetails.getCard());
		context.put(CUSTOMER, cardDetails.getCustomer());
		context.put(ENTITY_TYPE, EntityNames.CARD);
		return context;
	}

	@Override
	public boolean validate() {
		logger.trace("MbCardDetailsStep::validate...");
		return false;
	}

	public Card getCard() {
		return cardDetails.getCard();
	}

	public Customer getCustomer() {
		return cardDetails.getCustomer();
	}
}
