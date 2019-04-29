package ru.bpc.sv2.ui.common.application;

import org.ajax4jsf.model.KeepAlive;
import org.apache.log4j.Logger;
import org.openfaces.component.table.TreePath;
import org.openfaces.util.Faces;
import ru.bpc.sv2.application.Application;
import ru.bpc.sv2.application.ApplicationElement;
import ru.bpc.sv2.common.*;
import ru.bpc.sv2.constants.EntityNames;
import ru.bpc.sv2.constants.SystemConstants;
import ru.bpc.sv2.constants.application.AppElements;
import ru.bpc.sv2.constants.application.ApplicationConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.ApplicationDao;
import ru.bpc.sv2.logic.CommonDao;
import ru.bpc.sv2.logic.ProductsDao;
import ru.bpc.sv2.products.Customer;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DictUtils;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.utils.UserException;
import util.auxil.ManagedBeanWrapper;
import util.auxil.SessionWrapper;

import javax.faces.bean.ManagedBean;
import javax.faces.bean.RequestScoped;
import javax.faces.model.SelectItem;
import java.io.Serializable;
import java.math.BigDecimal;
import java.util.*;

import static ru.bpc.sv2.utils.AppStructureUtils.*;

@RequestScoped
@KeepAlive
@ManagedBean (name = "MbAppWizCustomer")
public class MbAppWizCustomer extends AbstractBean implements AppWizStep, Serializable{
	
	private static final long serialVersionUID = 1L;
	private static final Logger logger = Logger.getLogger("APPLICATIONS");
	private String page = "/pages/common/application/person/appWizCustomer.jspx";

	ProductsDao productsDao = new ProductsDao();
	ApplicationDao applicationDao = new ApplicationDao();
	CommonDao commonDao = new CommonDao();
	
	private ApplicationElement applicationRoot;
	private ApplicationElement customerElement;
	private MenuTreeItem node;
	private TreePath nodePath;
	private DictUtils dictUtils;
	
	private static final String ENTITIES = "PERSONS";
	private static final String ENTTCOMP = "ENTTCOMP";
	private static final String ENTITY = "ENTITY";
	private static final String DOCUMENTS = "DOCUMENTS";
	private static final String DOCUMENT = "DOCUMENT";
	private static final String ADD_DOCUMENT = "ADD_DOCUMENT";
	private static final String CONTACTS = "CONTACTS";
	private static final String CONTACT = "CONTACT";
	private static final String ADD_CONTACT = "ADD_CONTACT";
	private static final String ADDRESSES = "ADDRESSES";
	private static final String ADDRESS = "ADDRESS";
	private static final String ADD_ADDRESS = "ADD_ADDRESS";
	
	private MbWizard mbWizard;
	private List<String> selectedTypes;
	private Boolean addressTypeLocked = false;
	private ApplicationWizardContext appWizCtx;
	private String language;
	private String userLanguage;
	private Long userSessionId;
	private String customerType;
	private Map<String, Boolean>visibleMap;
	private ApplicationElement customerEntity; // CUSTOMER element can contain PERSON or COMPANY elements. This variable represents one of them.
	private boolean lock = true;
	private boolean newCustomer;
	
	@Override
	public ApplicationWizardContext release() {
		logger.trace("MbAppWizCustomer::release()...");
		releaseContacts();
		customerElement = null;
		node = null;
		nodePath = null;
		dictUtils = null;
		appWizCtx.setApplicationRoot(applicationRoot);
		applicationRoot = null;
		return appWizCtx;
	}
	
	private void init(){
		logger.trace("MbAppWizCustomer::init()...");
		dictUtils = ManagedBeanWrapper.getManagedBean(DictUtils.class);
		mbWizard = ManagedBeanWrapper.getManagedBean(MbWizard.class);
		language = userLanguage = SessionWrapper.getField("language");
		selectedTypes = new ArrayList<String>();
		userSessionId = SessionWrapper.getRequiredUserSessionId();
	}
	
	@Override
	public void init(ApplicationWizardContext ctx) {
		newCustomer = !ctx.isOldCustomer();
		logger.trace("MbAppWizCustomer::init(ApplicationWizardContext)...");
		init();
		appWizCtx = ctx;
		visibleMap = new HashMap<String, Boolean>();
		this.applicationRoot = ctx.getApplicationRoot();
		ctx.setStepPage(page);
		customerType = applicationRoot.retrive(AppElements.CUSTOMER_TYPE).getValueV();
		customerElement = tryRetrive(applicationRoot, AppElements.CUSTOMER);
		if (customerElement == null){
			createElement(applicationRoot, AppElements.CUSTOMER);
		}
		BigDecimal flow = new BigDecimal(1004);
		boolean isChangeCustomer = false;
		if (flow.compareTo(applicationRoot.getChildByName
				(AppElements.APPLICATION_FLOW_ID, 1)
					.getValueN()) == 0){
			isChangeCustomer = true;
		}
		if (!checkEntityDataPresence() || isChangeCustomer){
			retriveEntityDataFromDB();
		}
		if (!checkEntityDataPresence()){
			createPersonData();
		}
		if (lock){
			if (isEntityPerson()){
				customerEntity = customerElement.retrive(AppElements.PERSON);
			} else {
				customerEntity = customerElement.retrive(AppElements.COMPANY);
			}
			completeContacts();
			completeAddress();
			buildLeftMenuTree();
			prepareDetailsFields();
			updateLabels();
		}	
	}

	/**
	 * Check whether the personal data (PERSON, CONTACT, ADDRESS) is presented. 
	 * We suppose that the personal data is presented if PERSON element is presented. 
	 */
	private boolean checkEntityDataPresence(){
		ApplicationElement entity = null;
		if (isEntityPerson()){
			entity = customerElement.tryRetrive(AppElements.PERSON);
		} else {
			entity = customerElement.tryRetrive(AppElements.COMPANY);
		}
		return (entity != null);
	}
	
	private void createPersonData(){
		if (isEntityPerson()){
			createElement(customerElement, AppElements.PERSON);
		} else {
			createElement(customerElement, AppElements.COMPANY);
		}
		ApplicationElement contact = tryRetrive(customerElement, AppElements.CONTACT);
		if (contact == null){
			createElement(customerElement, AppElements.CONTACT);
		}
		ApplicationElement address = tryRetrive(customerElement, AppElements.CONTACT);
		if (address == null){
			createElement(customerElement, ADDRESS);
		}
	}
	
	private void retriveEntityDataFromDB(){
		String customerNumber = customerElement.retrive(AppElements.CUSTOMER_NUMBER).getValueV();
		if (customerNumber == null || customerNumber.isEmpty()){
			logger.debug("CUSTOMER_NUMBER element has not been found...");
			return;			
		}
		logger.debug("CUSTOMER_NUMBER has been founded [customerNumber: " + customerNumber + "]...");
		BigDecimal flow = new BigDecimal(1004);
		if (flow.compareTo(applicationRoot.getChildByName
				(AppElements.APPLICATION_FLOW_ID, 1)
					.getValueN()) != 0){
			newCustomer = false;
		}
		
		SelectionParams sp = new SelectionParams();
		ArrayList<Filter> filters = new ArrayList<Filter>();
		filters.add(new Filter("customerNumber", customerNumber));
		sp.setFilters(filters.toArray(new Filter[filters.size()]));
		sp.setRowIndexStart(0);
		sp.setRowIndexEnd(Integer.MAX_VALUE);
		Customer[] customers = productsDao.getCombinedCustomers(userSessionId, sp, userLanguage);
		if (customers.length == 0){
			logger.debug("Customer object has not been founded...");
			return;
		}
		Customer customer = customers[0];
		logger.debug("Customer object has been founded [customerId: " + customer.getId() + "]...");
		
		
		ApplicationElement entityEl = null;
		
		if (isEntityPerson()){
			Person person = customer.getPerson();
			entityEl = customerElement.tryRetrive(AppElements.PERSON);
			if (entityEl == null){
				entityEl = createElement(customerElement, AppElements.PERSON);
			}

			entityEl.retrive(AppElements.PERSON_TITLE).setValueV(person.getTitle());
			entityEl.retrive(AppElements.SUFFIX).set(person.getSuffix());
			entityEl.retrive(AppElements.BIRTHDAY).set(person.getBirthday());
			entityEl.retrive(AppElements.PLACE_OF_BIRTH).set(person.getPlaceOfBirth());
			entityEl.retrive(AppElements.GENDER).set(person.getGender());
			
			ApplicationElement personName = retrive(entityEl, AppElements.PERSON_NAME);
			
			personName.retrive(AppElements.SURNAME).set(person.getSurname());
			personName.retrive(AppElements.FIRST_NAME).set(person.getFirstName());
			personName.retrive(AppElements.SECOND_NAME).set(person.getSecondName());
		} else {
			Company company = customer.getCompany();
			entityEl = createElement(customerElement, AppElements.COMPANY);
			if (appWizCtx.getApplicationType().equalsIgnoreCase(
					ApplicationConstants.TYPE_ISSUING)){
				entityEl.retrive(AppElements.EMBOSSED_NAME).set(company.getEmbossedName());
			}
			ApplicationElement companyName = retrive(entityEl, AppElements.COMPANY_NAME);
			
			companyName.retrive(AppElements.COMPANY_SHORT_NAME).set(company.getLabel());
			companyName.retrive(AppElements.COMPANY_FULL_NAME).set(company.getDescription());
		}
		
		Long objectId = isEntityPerson() ? customer.getPerson().getPersonId() : customer.getCompany().getId().longValue();
		sp = SelectionParams.build(
				"objectId", objectId,
				"entityType", customer.getEntityType(),
				"lang", language
				);
		sp.setRowIndexStart(0);
		sp.setRowIndexEnd(Integer.MAX_VALUE);
		PersonId[] objectIds = commonDao.getObjectIds(userSessionId, sp);
		logger.debug("Identity cards found by customer: " + objectIds.length + "...");
		
		for (int i=0; i < objectIds.length; i++){
			PersonId personId = objectIds[i];
			ApplicationElement identityCard = tryRetrive(entityEl, AppElements.IDENTITY_CARD, i + 1);
			if (identityCard == null){
				identityCard = createElement(entityEl, AppElements.IDENTITY_CARD);
			}
			
			identityCard.retrive(AppElements.ID_TYPE).set(personId.getIdType());
			identityCard.retrive(AppElements.ID_SERIES).set(personId.getIdSeries());
			identityCard.retrive(AppElements.ID_NUMBER).set(personId.getIdNumber());
			identityCard.retrive(AppElements.ID_ISSUE_DATE).set(personId.getIssueDate());
			identityCard.retrive(AppElements.ID_EXPIRE_DATE).set(personId.getExpireDate());
			identityCard.retrive(AppElements.ID_DESC).set(personId.getDescription());
		}
		sp = SelectionParams.build(
				"objectId", customer.getId(),
				"entityType", EntityNames.CUSTOMER
				);		
		Contact[] contacts = commonDao.getContacts(userSessionId, sp, userLanguage);
		logger.debug("Contacts found by customer: " + contacts.length + "...");
		
		for (int i=0; i < contacts.length; i++){
			Contact contact = contacts[i];
			ApplicationElement contactEl = customerElement.tryRetrive(CONTACT, i + 1);
			if (contactEl == null){
				contactEl = createElement(customerElement, CONTACT);
			}
			
			contactEl.retrive(AppElements.CONTACT_TYPE).set(contact.getContactType());
			contactEl.retrive(AppElements.PREFERRED_LANG).set(contact.getPreferredLang());
			
			sp = SelectionParams.build("contactId", contact.getId());
			ContactData[] contactDatas = commonDao.getContactDatas(userSessionId, sp);
			for (int j=0; j < contactDatas.length; j++){
				ContactData contactData = contactDatas[j];
				ApplicationElement contactDataEl = contactEl.tryRetrive(AppElements.CONTACT_DATA, i + 1);
				if (contactDataEl == null){
					contactDataEl = createElement(contactEl, AppElements.CONTACT_DATA);
				}
				
				contactDataEl.retrive(AppElements.COMMUN_METHOD).set(contactData.getType());
				contactDataEl.retrive(AppElements.COMMUN_ADDRESS).set(contactData.getAddress());
			}
		}
		
		sp = SelectionParams.build(
				"entityType", EntityNames.CUSTOMER,
				"objectId", customer.getId()
				);
		Address[] addresses = commonDao.getAddresses(userSessionId, sp, userLanguage);
		logger.debug("Addresses found by customer: " + addresses.length + "...");
		
		for (int i=0; i < addresses.length; i++){
			Address address = addresses[i];
			ApplicationElement addressEl = customerElement.tryRetrive(ADDRESS, i + 1);
			if (addressEl == null){
				addressEl = createElement(customerElement, ADDRESS);
			}
			
			addressEl.retrive(AppElements.ADDRESS_TYPE).set(address.getAddressType());
			addressEl.retrive(AppElements.COUNTRY).set(address.getCountry());
			addressEl.retrive(AppElements.HOUSE).set(address.getHouse());
			addressEl.retrive(AppElements.APARTMENT).set(address.getApartment());
			addressEl.retrive(AppElements.POSTAL_CODE).set(address.getPostalCode());
			if (address.getLatitude() != null){
				addressEl.retrive(AppElements.LATITUDE).set(address.getLatitude());
			}
			if (address.getLongitude() != null){
				addressEl.retrive(AppElements.LONGITUDE).set(address.getLongitude());
			}
			ApplicationElement addressName = addressEl.tryRetrive(AppElements.ADDRESS_NAME, 1);
			if (addressName == null){
				addressName = createElement(addressEl, AppElements.ADDRESS_NAME);
			}
			
			addressName.setLang(userLanguage);
			addressName.retrive(AppElements.REGION).set(address.getRegion());
			addressName.retrive(AppElements.CITY).set(address.getCity());
			addressName.retrive(AppElements.STREET).set(address.getStreet());
		}
	}
	
	private ApplicationElement createElement(ApplicationElement parent, String elementName){
		
		ApplicationElement result = null;
		try{
			Integer intId = retrive(applicationRoot, AppElements.INSTITUTION_ID).getValueN().intValue();
			Application appStub = new Application();
			appStub.setInstId(intId);
	
			result = instance(parent, elementName);
			applicationDao.fillRootChilds(userSessionId, intId, result, appWizCtx.getApplicationFilters());
			BigDecimal flow = new BigDecimal(1004);
			if (isNewCustomer()){
				retrive(result, AppElements.COMMAND).setValueV(ApplicationConstants.COMMAND_CREATE_OR_EXCEPT);
			}else{
				retrive(result, AppElements.COMMAND).setValueV(ApplicationConstants.COMMAND_EXCEPT_OR_PROCEED);
			}
			applicationDao.applyDependencesWhenAdd(userSessionId, appStub, result, appWizCtx.getApplicationFilters());
		}catch(Exception e){
			FacesUtils.addMessageError(e);
			logger.error("", e);
			lock = false;
		}
		return result;
	}
	
	private List<MenuTreeItem> leftMenu = null; 
	
	MenuTreeItem entitiesGroup;
	MenuTreeItem entityItem;
	MenuTreeItem documentsGroup;
	MenuTreeItem contactsGroup;
	MenuTreeItem addressesGroup;
	
	private void buildLeftMenuTree(){
		leftMenu = new ArrayList<MenuTreeItem>();
		
		//Entity
		entitiesGroup = new MenuTreeItem(customerEntity.getShortDesc(), ENTITIES);
		entityItem = new MenuTreeItem("!Person name", ENTITY);		
		leftMenu.add(entitiesGroup);
		entitiesGroup.getItems().add(entityItem);
		
		//Document
		
		ApplicationElement identityCardElement = retrive(customerEntity, AppElements.IDENTITY_CARD, 0);
		documentsGroup = new MenuTreeItem(identityCardElement.getShortDesc(), DOCUMENTS);
		leftMenu.add(documentsGroup);
		List<ApplicationElement> documents = customerEntity.getChildrenByName(AppElements.IDENTITY_CARD);
		for (int i = 0; i < documents.size(); i++){
			ApplicationElement document = documents.get(i);
			MenuTreeItem documentItem = new MenuTreeItem("!Document name", DOCUMENT, document.getInnerId());
			documentsGroup.getItems().add(documentItem);
		}
		if (newCustomer){
			MenuTreeItem addDocumentItem = new MenuTreeItem("Add new document", ADD_DOCUMENT);
			documentsGroup.getItems().add(addDocumentItem);
		}	
		
		//Contact
		ApplicationElement contactForDesc = retrive(customerElement, CONTACT, 0);
		contactsGroup = new MenuTreeItem(contactForDesc.getShortDesc(), CONTACTS);
		leftMenu.add(contactsGroup);
		List<ApplicationElement> contacts = customerElement.getChildrenByName(CONTACT);
		for (int i = 0; i < contacts.size(); i++){
			ApplicationElement contact = contacts.get(i);
			MenuTreeItem contactItem = new MenuTreeItem(CONTACT, contact.getInnerId());
			contactsGroup.getItems().add(contactItem);
		}
		if (newCustomer){
			MenuTreeItem addContactItem = new MenuTreeItem("Add new contact", ADD_CONTACT);
			contactsGroup.getItems().add(addContactItem);
		}
		
		// Address
		ApplicationElement addressElement = retrive(customerElement, ADDRESS, 0);
		addressesGroup = new MenuTreeItem(addressElement.getShortDesc(), ADDRESSES);
		leftMenu.add(addressesGroup);
		List<ApplicationElement> addresses = customerElement.getChildrenByName(ADDRESS);
		for (int i=0; i< addresses.size(); i++){
			ApplicationElement address = addresses.get(i);
			MenuTreeItem addressItem = new MenuTreeItem(ADDRESS, address.getInnerId());
			addressesGroup.getItems().add(addressItem);
		}
		if (newCustomer){
			MenuTreeItem addAddressItem = new MenuTreeItem("Add new address", ADD_ADDRESS);
			addressesGroup.getItems().add(addAddressItem);
		}
		
		// Person element is selected by default
		node = entityItem;
		TreePath personsPath = new TreePath(entitiesGroup, null);
		TreePath personPath = new TreePath(entityItem, personsPath);
		nodePath = personPath;		
	}
	
	public List<MenuTreeItem> getNodeChildren(){
		logger.trace("MbAppWizCustomer getNodeChildren()...");
		MenuTreeItem treeNode = treeNode();
		if (treeNode == null){
			return leftMenu;
		} else {
			return treeNode.getItems();
		}
	}
	
	public boolean getNodeHasChildren(){
		MenuTreeItem treeNode = treeNode();
		return !treeNode.getItems().isEmpty();
	}
	
	public MenuTreeItem treeNode(){
		return (MenuTreeItem) Faces.var("item");
	}
	
	public MenuTreeItem getElement(){
		return node;
	}
	
	public void setElement(MenuTreeItem node){
		this.node = node;
	}
	
	public void setNodePath(TreePath nodePath) {
		this.nodePath = nodePath;
	}
	
	public TreePath getNodePath(){
		return nodePath;
	}
	
	public MenuTreeItem getNode(){
		return node;
	}
	
	public void setNode(MenuTreeItem node){
		logger.trace("MbAppWizCustomer::setNode()...");
		this.node = node;
	}
	
	public void prepareDetailsFields(){
		if (node == null) return;
		prepareFieldMap();
		prepareListMap();		
	}
	
	private Map<String, ApplicationElement> fieldMap;
	private Map<String, List<SelectItem>> listMap;
	
	private void prepareFieldMap(){
		logger.trace("MbAppWizCustomer::prepareFieldMap()...");
		fieldMap = new HashMap<String, ApplicationElement>();
		if (ENTITY.equals(node.getName())){
			if (isEntityPerson()){
				logger.debug("Preparing fields for PERSON element...");
				putToFields(customerEntity, AppElements.PERSON_TITLE);
				putToFields(customerEntity, AppElements.SUFFIX);
				putToFields(customerEntity, AppElements.BIRTHDAY);
				putToFields(customerEntity, AppElements.PLACE_OF_BIRTH);
				putToFields(customerEntity, AppElements.GENDER);
				ApplicationElement personName = customerEntity.retrive(AppElements.PERSON_NAME);
				putToFields(personName, AppElements.SURNAME);
				putToFields(personName, AppElements.FIRST_NAME);
				putToFields(personName, AppElements.SECOND_NAME);
			} else {
				logger.debug("Preparing fields for COMPANY element...");
				if (appWizCtx.getApplicationType().equalsIgnoreCase(
						ApplicationConstants.TYPE_ISSUING)){
					putToFields(customerEntity, AppElements.EMBOSSED_NAME);
				}
				ApplicationElement companyName = customerEntity.retrive(AppElements.COMPANY_NAME);
				putToFields(companyName, AppElements.COMPANY_SHORT_NAME);
				putToFields(companyName, AppElements.COMPANY_FULL_NAME);
			}
		} else if (DOCUMENT.equals(node.getName())){
			logger.debug("Preparing fields for DOCUMENT element...");
			ApplicationElement idtCard = retrive(customerEntity, AppElements.IDENTITY_CARD, node.getInnerId());
			putToFields(idtCard, AppElements.ID_TYPE);
			putToFields(idtCard, AppElements.ID_SERIES);
			putToFields(idtCard, AppElements.ID_NUMBER);
			putToFields(idtCard, AppElements.ID_ISSUER);
			putToFields(idtCard, AppElements.ID_ISSUE_DATE);
			putToFields(idtCard, AppElements.ID_EXPIRE_DATE);
			putToFields(idtCard, AppElements.ID_DESC);
		} else if (CONTACT.equals(node.getName())){
			logger.debug("Preparing fields for CONTACT element...");
			ApplicationElement contact = retrive(customerElement, CONTACT, node.getInnerId());
			putToFields(contact, AppElements.CONTACT_TYPE);
			putToFields(contact, AppElements.PREFERRED_LANG);
			for (int i=1; i < 5; i++){
				ApplicationElement contactData = retrive(contact, AppElements.CONTACT_DATA, i);
				ApplicationElement communMethod = retrive(contactData, AppElements.COMMUN_METHOD);
				String desc = dictUtils.getAllArticlesDesc().get(communMethod.getValueV());
				ApplicationElement communAddress = retrive(contactData, AppElements.COMMUN_ADDRESS);
				communAddress.setShortDesc(desc);
				String key = null;
				switch (i){
				case 1:
					key = "MOBILE_PHONE";
					break;
				case 2:
					key = "E_MAIL";
					break;
				case 3:
					key = "FAX";
					break;
				case 4:
					key = "SKYPE";
					break;
				}
				fieldMap.put(key, communAddress);
			}
		} else if (ADDRESS.equals(node.getName())){
			logger.debug("Preparing fields for ADDRESS element...");
			ApplicationElement address = retrive(customerElement, ADDRESS, node.getInnerId());
			putToFields(address, AppElements.ADDRESS_TYPE);
			putToFields(address, AppElements.COUNTRY);
			putToFields(address, AppElements.HOUSE);
			putToFields(address, AppElements.APARTMENT);
			putToFields(address, AppElements.POSTAL_CODE);
			putToFields(address, AppElements.LATITUDE);
			putToFields(address, AppElements.LONGITUDE);
			language = userLanguage;
			prepareAddressName();
		}
	}
	
	private void putToFields(ApplicationElement parent, String fieldName){
		ApplicationElement idType = parent.retrive(fieldName);
		fieldMap.put(fieldName, idType);
		if (visibleMap.get(fieldName) == null){
			visibleMap.put(fieldName, true);
		}
	}
	
	public Map<String, Boolean> getVisibleMap(){
		return visibleMap;
	}
	
	private void prepareListMap(){
		logger.trace("MbAppWizCustomer prepareListMap()...");
		listMap = new HashMap<String, List<SelectItem>>();
		for (ApplicationElement element : fieldMap.values()){
			if (element.getLovId() != null){
				if (!AppElements.ID_TYPE.equalsIgnoreCase(element.getName())){
					List<SelectItem> lov = dictUtils.getLov(element.getLovId());
					listMap.put(element.getName(), lov);
				}else{
					Map<String, Object> map = new HashMap<String, Object>();
					map.put("institution_id", 
							applicationRoot.getChildByName(AppElements.INSTITUTION_ID, 1)
								.getValueN());
					map.put("customer_type", customerType);
					List<SelectItem> lov = dictUtils.getLov(element.getLovId(), map);
					fixLov(element, lov);
					listMap.put(element.getName(), lov);
				}
			}
		}
	}
	
	private void fixLov(ApplicationElement element, List<SelectItem> lov){
		List <SelectItem>removedItems = new ArrayList<SelectItem>();
		for (SelectItem item: lov){
			if (selectedTypes.contains(item.getValue())
					&& (!item.getValue().equals(element.getValue()))){
				removedItems.add(item);
			}
		}
		lov.removeAll(removedItems);
		
	}
	
	public String getDetailsPage(){
		logger.trace("MbAppWizCustomer::getDetailsPage()...");
		String result = SystemConstants.EMPTY_PAGE; 
		if (node != null){
			if (ENTITY.equals(node.getName())){
				if (isEntityPerson()){
					result = "/pages/common/application/person/personDetails.jspx";
				} else {
					result = "/pages/common/application/person/companyDetails.jspx";
				}
				
			} else if (DOCUMENT.equals(node.getName())){
				result = "/pages/common/application/person/documentDetails.jspx";
			} else if (CONTACT.equals(node.getName())){
				result = "/pages/common/application/person/contactDetails.jspx";
			} else if (ADDRESS.equals(node.getName())){
				result = "/pages/common/application/person/addressDetails.jspx";
			}
		}
		logger.debug("MbAppWizCustomer [detailsPage:\"" + result + "\"]");
		return result;
	}
	
	public Map<String, ApplicationElement> getFieldMap(){
		//logger.trace("MbAppWizCustomer getFieldMap()...");
		return fieldMap;
	}
	
	public Map<String, List<SelectItem>> getLovMap(){
		logger.trace("MbAppWizCustomer getLovMap()...");
		return listMap;
	}
	
	@Override
	public boolean validate(){
		logger.trace("MbAppWizCustomer::validation...");
		boolean valid = true;
		/* Person */
		boolean personValid = true;
		for (ApplicationElement child : customerEntity.getChildren()){
			if (AppElements.IDENTITY_CARD.equals(child.getName()))
				continue;
			if (child.isRequired()){
				personValid &= child.validate();
			}	
		}
		entitiesGroup.setValid(personValid);
		entityItem.setValid(personValid);
		
		/*Identity cards*/
		boolean documentsValid = true;
		
		List<MenuTreeItem> documents = documentsGroup.getItems();
		for (MenuTreeItem document : documents){
			boolean documentValid = true;
			Integer innerId = document.getInnerId();
			ApplicationElement idtCard = retrive(customerEntity, AppElements.IDENTITY_CARD, innerId);
			documentValid = idtCard.validate();
			document.setValid(documentValid);
			documentsValid &= documentValid;
		}
		documentsGroup.setValid(documentsValid);
				
		
		/* Contacts */
		boolean contactsValid = true;
		List<MenuTreeItem> contacts = contactsGroup.getItems();
		for (MenuTreeItem contact : contacts){
			if (!CONTACT.equals(contact.getName())) continue;
			boolean contactValid = true;
			Integer innerId = contact.getInnerId();
			ApplicationElement contactEl = retrive(customerElement, CONTACT, innerId);
			for (ApplicationElement contactChild :contactEl.getChildren()){
				boolean contactElValid = true;
				if (contactChild.isRequired()){
					contactElValid = contactChild.validate();
				}	
				/*boolean contactDataPresented = false;
				List<ApplicationElement> contactDatas = contactEl.getChildrenByName(CONTACT_DATA);
				for (ApplicationElement contactData : contactDatas){
					String value = retrive(contactData, COMMUN_ADDRESS).getValueV();
					contactDataPresented = (value != null) && (!value.isEmpty());
					if (contactDataPresented) break;
				}
				if (!contactDataPresented){
					for (ApplicationElement contactData : contactDatas){
						retrive(contactData, COMMUN_ADDRESS).setValid(false);
					}
				}*/
				//contactValid = contactValid;// && contactDataPresented;
				contactValid &= contactElValid;
			}
			contactEl.setValid(contactValid);
			contact.setValid(contactValid);
			contactsValid &= contactValid;
			
		}
		contactsGroup.setValid(contactsValid);
		
		boolean addressesValid = true;
		List<MenuTreeItem> addresses = addressesGroup.getItems();
		for(MenuTreeItem address: addresses){
			if (ADDRESS.equals(address.getName())){
				boolean addressValid = true;
				Integer innerId = address.getInnerId();
				ApplicationElement addressEl = customerElement.getChildByName(ADDRESS, innerId);
				for(ApplicationElement addressNameEl:addressEl.getChildren()){
					if (addressNameEl.isRequired()){
						boolean addressNameValid = addressNameEl.validate();
						addressValid &= addressNameValid;
					}	
				}
				address.setValid(addressValid);
				addressesValid &= addressValid;
			}
		}
		addressesGroup.setValid(addressesValid);
		
		valid = documentsValid && personValid && contactsValid;
		logger.debug("MbAppWizCustomer valid=" + valid);
		return valid;
	}	
	
	public void updateEntityLabel(){
		logger.trace("MbAppWizCustomer::updateEntityLabel()...");
		String label = "";
		if (isEntityPerson()){
			ApplicationElement personNameEl = customerEntity.retrive(AppElements.PERSON_NAME);
			ApplicationElement nameEl = personNameEl.retrive(AppElements.FIRST_NAME);
			ApplicationElement surnameEl = personNameEl.retrive(AppElements.SURNAME);
			
			String name = nameEl.getValueV();
			String surname = surnameEl.getValueV();
			
			if ((name == null && surname == null) || ("".equals(name) && "".equals(name))){
				label = customerEntity.getShortDesc();
			} else if (name == null || name.isEmpty()){
				label = surname;
			} else if (surname == null || surname.isEmpty()){
				label = name;
			} else {
				label = String.format("%s %s", surname, name);
			}			
		} else {
			ApplicationElement companyName = customerEntity.retrive(AppElements.COMPANY_NAME);
			label = companyName.retrive(AppElements.COMPANY_SHORT_NAME).getValueV();
			if (label == null || label.isEmpty()){
				label = customerEntity.getShortDesc();
			}
		}

		entityItem.setLabel(label);
	}
	
	public void addNewDocument(){
		logger.trace("MbAppWizCustomer::addNewDocument()...");
		ApplicationElement idtCard = customerEntity.tryRetrive(AppElements.IDENTITY_CARD, 0);
		if (checkMaxLimit(idtCard)) return;
		ApplicationElement newDocument = createNewDocument();
		MenuTreeItem document = new MenuTreeItem(newDocument.getShortDesc(), DOCUMENT, newDocument.getInnerId());
		documentsGroup.getItems().add(documentsGroup.getItems().size() - 1, document);
		node = document;
		TreePath documentsPath = new TreePath(documentsGroup, null);
		TreePath documentPath = new TreePath(document, documentsPath);
		nodePath = documentPath;
		prepareDetailsFields();
	}
	
	private ApplicationElement createNewDocument(){
		ApplicationElement identityCard = null;
		try {
			identityCard = mbWizard.addElement(customerEntity, AppElements.IDENTITY_CARD);
			if (isNewCustomer()){
				identityCard.retrive(AppElements.COMMAND).setValueV(ApplicationConstants.COMMAND_CREATE_OR_EXCEPT);
			}else{
				identityCard.retrive(AppElements.COMMAND).setValueV(ApplicationConstants.COMMAND_EXCEPT_OR_PROCEED);
			}
		} catch (UserException e) {
			FacesUtils.addErrorExceptionMessage(e);
		}
		return identityCard;
	}
	
	public void updateDocumentLabel(){
		logger.trace("MbAppWizCustomer::updateDocumentLabel()...");
		udpateDocumentLabel(node);
	}
	
	public void updateDocumentLabelIdType(){
		logger.trace("MbAppWizCustomer::updateDocumentLabel()...");
		udpateDocumentLabel(node);
		setSelectedTypes();
	}
	
	private void setSelectedTypes(){
		List<ApplicationElement>identityCards = customerEntity.getChildrenByName(AppElements.IDENTITY_CARD);
		selectedTypes = new ArrayList<String>(identityCards.size());
		for (ApplicationElement identityCard : identityCards){
			String idTypeValue = identityCard.getChildByName(AppElements.ID_TYPE, 1).getValueV();
			selectedTypes.add(idTypeValue);
		}
	}
	
	public void udpateDocumentLabel(MenuTreeItem document){
		logger.trace("MbAppWizCustomer::updateDocumentLabel(MenuTreeItem)...");
		ApplicationElement idtCard = retrive(customerEntity, AppElements.IDENTITY_CARD, document.getInnerId());
		String idType = retrive(idtCard, AppElements.ID_TYPE).getValueV();
		String idTypeDesc = null;
		if (idType == null || idType.isEmpty()){
			idTypeDesc = idtCard.getShortDesc();
		} else {
			idTypeDesc = dictUtils.getAllArticlesDesc().get(idType);
		}
			String series = retrive(idtCard, AppElements.ID_SERIES).getValueV();
			String number = retrive(idtCard, AppElements.ID_NUMBER).getValueV();
			
			idTypeDesc = String.format("%s %s %S", idTypeDesc, 
					series != null ? series : "" , 
					number != null ? number : "");
		document.setLabel(idTypeDesc);
	}
	
	public void addNewContact(){
		logger.trace("MbAppWizCustomer::addNewContact()...");
		ApplicationElement contractEl = customerElement.tryRetrive(CONTACT, 0);
		if (checkMaxLimit(contractEl)) return;
		ApplicationElement newContact = createNewContact();
		completeContact(newContact);
		
		MenuTreeItem contact = new MenuTreeItem(newContact.getShortDesc(), CONTACT, newContact.getInnerId());
		contactsGroup.getItems().add(contactsGroup.getItems().size() - 1, contact);
		node = contact;
		TreePath contactsPath = new TreePath(contactsGroup, null);
		TreePath contactPath = new TreePath(contact, contactsPath);
		nodePath = contactPath;
		prepareDetailsFields();
	}
	
	private ApplicationElement createNewContact(){
		logger.trace("MbAppWizCustomer::createNewContact()...");
		ApplicationElement contact = null;
		try {
			contact = mbWizard.addElement(customerElement, CONTACT);
		} catch (UserException e) {
			FacesUtils.addErrorExceptionMessage(e);
		}
		return contact;
	}
	
	private void completeContact(ApplicationElement contact){
		logger.trace("MbAppWizCustomer::completeContact()...");
		
		List<ApplicationElement> contactItems = contact.getChildrenByName(AppElements.CONTACT_DATA);
		HashSet<String> presentedMethods = new HashSet<String>();		
		for (ApplicationElement contactData : contactItems){
			retrive(contactData, AppElements.COMMUN_ADDRESS);
			String communMethodValue = retrive(contactData, AppElements.COMMUN_METHOD).getValueV();
			if (communMethodValue != null && !communMethodValue.isEmpty()){
				presentedMethods.add(communMethodValue);
			}
		}
		String[] methods = { "CMNM0001", "CMNM0002", "CMNM0004", "CMNM0005" };
		for (int i = 0; i < methods.length; i++) {
			if (presentedMethods.contains(methods[i]))
				continue;
			
			ApplicationElement emptyContactData = null;
			for (ApplicationElement contactData : contactItems) {
				ApplicationElement communMethod = retrive(contactData, AppElements.COMMUN_METHOD);
				if (communMethod.getValueV() == null) {
					emptyContactData = communMethod;
					break;
				}
			}
			if (emptyContactData != null) {
				emptyContactData.setValueV(methods[i]);
				continue;
			} else {
				try {
					ApplicationElement newContactData = mbWizard.addElement(contact, AppElements.CONTACT_DATA);
					retrive(newContactData, AppElements.COMMUN_ADDRESS)
					.setRequired(false);
					retrive(newContactData, AppElements.COMMUN_METHOD)
							.setValueV(methods[i]);
				} catch (UserException e) {
					FacesUtils.addErrorExceptionMessage(e);
				}
			}

		}
	}
	
	public void updateContactLabel(){
		logger.trace("MbAppWizCustomer::updateContactLabel()...");
		updateContactLabel(node);
	}
	
	private void updateContactLabel(MenuTreeItem targetNode){
		logger.trace("MbAppWizCustomer::updateContactLabel(MenuTreeItem)...");
		ApplicationElement contact = retrive(customerElement, CONTACT, targetNode.getInnerId());
		ApplicationElement contactTypeEl = retrive(contact, AppElements.CONTACT_TYPE);
		String contactType = contactTypeEl.getValueV();
		String label = null;
		if (contactType != null && !contactType.isEmpty()){
			label = dictUtils.getAllArticlesDesc().get(contactType);
		} else {
			label = contact.getShortDesc();
		}
		targetNode.setLabel(label);
	}
	
	private void updateLabels(){
		logger.trace("MbAppWizCustomer::updateLabels()...");
		updateEntityLabel();
		
		
		for (MenuTreeItem document : documentsGroup.getItems()){
			if (!DOCUMENT.equals(document.getName())) continue;
			udpateDocumentLabel(document);
		}
		
		
		for (MenuTreeItem contact : contactsGroup.getItems()){
			if (!CONTACT.equals(contact.getName())) continue;
			updateContactLabel(contact);
		}
		
		for (MenuTreeItem address : addressesGroup.getItems()){
			if (!ADDRESS.equals(address.getName())) continue;
			updateAddressLabel(address);
		}
	}
	
	private void completeContacts(){
		logger.trace("MbAppWizCustomer::completeContacts()...");
		List<ApplicationElement> contacts = customerElement.getChildrenByName(CONTACT);
		for (ApplicationElement contact : contacts){
			completeContact(contact);
		}
	}
	
	public void addNewAddress(){
		logger.trace("MbAppWizCustomer::addNewAddress()...");
		ApplicationElement addressEl = customerElement.tryRetrive(ADDRESS, 0);
		if (checkMaxLimit(addressEl)) return;
		ApplicationElement newAddress = createNewAddress();
		
		MenuTreeItem address = new MenuTreeItem(newAddress.getShortDesc(), ADDRESS, newAddress.getInnerId());
		addressesGroup.getItems().add(addressesGroup.getItems().size() - 1, address);
		node = address;
		TreePath addressesPath = new TreePath(addressesGroup, null);
		TreePath addressPath = new TreePath(address, addressesPath);
		nodePath = addressPath;
		prepareDetailsFields();
	}
	
	private ApplicationElement createNewAddress(){
		logger.trace("MbAppWizCustomer::createNewAddress()...");
		ApplicationElement address = null;
		try {
			address = mbWizard.addElement(customerElement, ADDRESS);
		} catch (UserException e) {
			FacesUtils.addErrorExceptionMessage(e);
		}
		search(address, AppElements.ADDRESS_NAME).setLang(userLanguage);
		return address;
	}
	
	public void updateAddressLabel(){
		updateAddressLabel(node);
	}
	
	public void updateAddressLabel(MenuTreeItem targetNode){
		logger.trace("MbAppWizCustomer::updateAddressLabel(MenuTreeItem)...");
		ApplicationElement address = retrive(customerElement, ADDRESS, targetNode.getInnerId());
		ApplicationElement addressTypeEl = retrive(address, AppElements.ADDRESS_TYPE);
		String addressType = addressTypeEl.getValueV();
		String label = null;
		if (addressType != null && !addressType.isEmpty()){
			label = dictUtils.getAllArticlesDesc().get(addressType);
		} else {
			label = address.getShortDesc();
		}
		targetNode.setLabel(label);
	}

	public String getLanguage() {
		return language;
	}

	public void setLanguage(String language) {
		this.language = language;
	}
	
	private ApplicationElement selectAddressNameByLanguage(){
		logger.trace("MbAppWizCustomer::selectAddressNameByLanguage()...");
		ApplicationElement address = retrive(customerElement, ADDRESS, node.getInnerId());
		List<ApplicationElement> addressNames = address.getChildrenByName(AppElements.ADDRESS_NAME);
		ApplicationElement selectedAddressName = null;
		for (ApplicationElement addressName : addressNames){
			if (getLanguage().equals(addressName.getLang())){
				selectedAddressName = addressName;
				break;
			}
		}
		return selectedAddressName;
	}
	
	private void prepareAddressName(){
		logger.trace("MbAppWizCustomer::prepareAddressName()...");
		ApplicationElement selectedAddressName = selectAddressNameByLanguage();
		if (selectedAddressName == null){
			throw new IllegalStateException("Element ADDRESS must have proper ADDRESS_NAME element before prepareAddressName() is called");
		}
		putAddressName(selectedAddressName);
	}
	
	private void putAddressName(ApplicationElement addressName){
		logger.trace("MbAppWizCustomer::putAddressName()...");
		putToFields(addressName, AppElements.REGION);
		putToFields(addressName, AppElements.CITY);
		putToFields(addressName, AppElements.STREET);
	}
	
	public void switchAddressName(){
		logger.trace("MbAppWizCustomer::switchAddressName()...");
		ApplicationElement selectedAddressName = selectAddressNameByLanguage();
		if (selectedAddressName == null){
			ApplicationElement address = retrive(customerElement, ADDRESS, node.getInnerId());
			ApplicationElement addressName = null;
			try {
				addressName = mbWizard.addElement(address, AppElements.ADDRESS_NAME);
			} catch (UserException e) {
				FacesUtils.addErrorExceptionMessage(e);
			}
			addressName.setLang(language);
			selectedAddressName = addressName;
		}
		putAddressName(selectedAddressName);
	}
	
	private void completeAddress(){
		logger.trace("MbAppWizCustomer::completeAddress()...");
		List<ApplicationElement> addresses = customerElement.getChildrenByName(ADDRESS);
		for (ApplicationElement address : addresses){
			completeAddress(address);
		}
	}
	
	private void completeAddress(ApplicationElement address){
		logger.trace("MbAppWizCustomer::completeAddress(ApplicationElement)...");
		ApplicationElement addressName = retrive(address, AppElements.ADDRESS_NAME);
		if (addressName.getLang() == null){
			addressName.setLang(language);
		}
	}
	
	private void removeItemFromTree(MenuTreeItem treeParent, ApplicationElement appParent, String targetName) {
		logger.trace("MbAppWizCustomer::removeItemFromTree()...");
		int deletedElementPosition = treeParent.getItems().indexOf(node);
		treeParent.getItems().remove(node);
		
		for (int i=deletedElementPosition; i < treeParent.getItems().size() - 1; i++){
			MenuTreeItem item = treeParent.getItems().get(i);
			int innerId = item.getInnerId();
			ApplicationElement nextAddress = retrive(appParent, targetName, innerId);
			innerId--;
			item.setInnerId(innerId);
			nextAddress.setInnerId(innerId);
		}
	}
	
	private void removeElementFromApp(ApplicationElement parent, String targetName){
		logger.trace("MbAppWizCustomer::removeElementFromApp()...");
		ApplicationElement elementToDelete = retrive(parent, targetName, node.getInnerId());
		delete(elementToDelete, parent);
	}
	
	private void resetSelection(MenuTreeItem targetParen){
		logger.trace("MbAppWizCustomer::resetSelection()...");
		TreePath addressesPath = new TreePath(targetParen, null);
		if (targetParen.getItems().size() > 1){
			MenuTreeItem nextItem = targetParen.getItems().get(0);
			TreePath addressPath = new TreePath(nextItem, addressesPath);
			nodePath = addressPath;
			node = nextItem;
		} else {
			nodePath = addressesPath;
			node = addressesGroup;
		}
	}
	
	private boolean checkMinLimit(ApplicationElement element){
		boolean result = minLimit(element);
		if (result){
			FacesUtils.addMessageError("Cannot delete an element. The minimum limit is reached.");
		}
		return result;
	}
	
	private boolean checkMaxLimit(ApplicationElement element){
		boolean result = maxLimit(element);
		if (result){
			FacesUtils.addMessageError("Cannot add an element. The maximum limit is reached.");
		}
		return result;
	}
	
	public void deleteAddress(){
		logger.trace("MbAppWizCustomer::deleteAddress()...");
		if (checkMinLimit(customerElement.retrive(ADDRESS))) return;
		removeElementFromApp(customerElement, ADDRESS);
		removeItemFromTree(addressesGroup, customerElement, ADDRESS);
		resetSelection(addressesGroup);
		prepareDetailsFields();
	}
	
	public void deleteDocument(){
		logger.trace("MbAppWizCustomer::deleteDocument()...");
		if (checkMinLimit(customerEntity.retrive(AppElements.IDENTITY_CARD))) return;
		removeElementFromApp(customerEntity, AppElements.IDENTITY_CARD);
		removeItemFromTree(documentsGroup, customerEntity, AppElements.IDENTITY_CARD);
		resetSelection(documentsGroup);
		prepareDetailsFields();
	}

	public void deleteContact(){
		logger.trace("MbAppWizCustomer::deleteContact()...");
		if (checkMinLimit(customerElement.retrive(CONTACT))) return;
		removeElementFromApp(customerElement, CONTACT);
		removeItemFromTree(contactsGroup, customerElement, CONTACT);
		resetSelection(contactsGroup);
		prepareDetailsFields();
	}
	
	public void releaseContacts(){
		logger.trace("MbAppWizCustomer::releaseContacts()...");
		List<ApplicationElement> contacts = customerElement.getChildrenByName(CONTACT);
		for (ApplicationElement contact : contacts){
			List<ApplicationElement> contactDatas = contact.getChildrenByName(AppElements.CONTACT_DATA);
			for (ApplicationElement contactData : contactDatas){
				ApplicationElement communAddress = retrive(contactData, AppElements.COMMUN_ADDRESS);
				String communAddressValue = communAddress.getValueV();
				if (communAddressValue == null || communAddressValue.isEmpty()){
					if (!minLimit(contactData)){
						delete(contactData, contact);
						communAddress.setRequired(true);
					}
				}
			}
			reorderInnerId(contact, AppElements.CONTACT_DATA);
		}
	}

	private boolean isEntityPerson(){
		return EntityNames.PERSON.equals(customerType);
	}
	
	@Override
	public boolean checkKeyModifications() {
		return false;
	}

	public Boolean getAddressTypeLocked() {
		return addressTypeLocked;
	}

	public void setAddressTypeLocked(Boolean addressTypeLocked) {
		this.addressTypeLocked = addressTypeLocked;
	}
	
	@Override
	public boolean getLock(){
		return lock;
	}
	
	public boolean isNewCustomer(){
		return newCustomer;
	}
	
	@Override
	public void clearFilter() {
		// TODO Auto-generated method stub
		
	}
}
