package ru.bpc.sv2.ui.common.wizard.callcenter;

import org.apache.log4j.Logger;
import ru.bpc.sv2.common.Contact;
import ru.bpc.sv2.common.ContactData;
import ru.bpc.sv2.common.PersonId;
import ru.bpc.sv2.constants.EntityNames;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.invocation.SortElement;
import ru.bpc.sv2.issuing.Card;
import ru.bpc.sv2.logic.CommonDao;
import ru.bpc.sv2.logic.IssuingDao;
import ru.bpc.sv2.logic.ProductsDao;
import ru.bpc.sv2.products.Contract;
import ru.bpc.sv2.products.Customer;
import util.auxil.SessionWrapper;

import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import java.util.HashMap;
import java.util.Map;

@ViewScoped
@ManagedBean (name = "MbWzCardDetails")
public class MbWzCardDetails {
	private static final Logger classLogger = Logger.getLogger(MbWzCardDetails.class);
	
	private IssuingDao issuingDao = new IssuingDao();
	
	private ProductsDao productsDao = new ProductsDao();

	private CommonDao commonDao = new CommonDao();
	
	private Long objectId;
	private Card card;
	private Customer customer;
	private long userSessionId;
	private String curLang;
	
	public void init(Long cardId){
		classLogger.trace("init...");
		userSessionId = SessionWrapper.getRequiredUserSessionId();
		curLang = SessionWrapper.getField("language");		
		this.objectId = cardId;
		card = retriveCard(cardId);
		customer = retriveCustomer(card);
	}
	
	private Card retriveCard(Long cardId){
		classLogger.trace("retriveCard...");
		Card result;
		SelectionParams sp = SelectionParams.build("CARD_ID", cardId);
		Map<String, Object> paramMap = new HashMap<String, Object>();
		paramMap.put("tab_name", "CARD");
		paramMap.put("param_tab", sp.getFilters());
		Card[] cards = issuingDao.getCardsCur(userSessionId, sp, paramMap);
		if (cards.length > 0){
			result = cards[0];
		} else {
			throw new IllegalStateException("Card with ID:" + cardId + " is not found!");
		}
		return result;
	}
	
	private Customer retriveCustomer(Card card){
		classLogger.trace("retriveCustomer...");
		Customer result;
		SelectionParams sp = SelectionParams.build("CARD_ID", card.getId(), "LANG", curLang, "INST_ID", card.getInstId());
		sp.setSortElement(new SortElement[0]);
		Customer[] customers = productsDao.getCombinedCustomersProc(userSessionId, sp, "CARD");
		if (customers.length > 0){
			result = customers[0];
		} else {
			throw new IllegalStateException("Customer with number:" + card.getCustomerNumber() + " is not found!");
		}
		
		sp = SelectionParams.build("objectId", result.getId(), "entityType", EntityNames.CUSTOMER);
		Contact contact = null;
		Contact[] contacts = commonDao.getContacts(userSessionId, sp, curLang);
		if (contacts.length > 0){
			contact = contacts[0];
			sp = SelectionParams.build("contactId", contact.getId(),
					"activeOnly", contact.getInstId());
			ContactData[] contactDatas = commonDao.getContactDatas(userSessionId, sp);
			if (contactDatas.length > 0){
				for (ContactData data : contactDatas){
					if ("CMNM0001".equals(data.getType())){
						contact.setMobile(data.getAddress());
					}
				}
			}
			result.setContact(contact);
		}
		sp = SelectionParams.build("objectId", result.getObjectId(), "entityType", result.getEntityType(), "idType", "IDTP0001");
		PersonId personId = null;
		PersonId[] documents = commonDao.getObjectIds(userSessionId, sp);
		if (documents.length > 0){
			personId = documents[0];
			result.setDocument(personId);
		}
		sp = SelectionParams.build("CONTRACT_ID", card.getContractId(), "LANG", curLang);
		Contract contract = null;
		Map<String, Object> paramsMap = new HashMap<String, Object>();
		paramsMap.put("param_tab", sp.getFilters());
		paramsMap.put("tab_name", "CONTRACT");
		Contract[] contracts = productsDao.getContractsCur(userSessionId, sp, paramsMap);
		if (contracts.length > 0){
			contract = contracts[0];
			result.setContract(contract);
		} else {
			throw new IllegalStateException("Contract with number:" + card.getCustomerNumber() + " is not found!");
		}
		return result;
	}

	public Card getCard() {
		return card;
	}

	public Customer getCustomer() {
		return customer;
	}
}
