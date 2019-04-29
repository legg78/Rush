package ru.bpc.sv2.ui.common.application;

import org.apache.log4j.Logger;
import ru.bpc.sv2.accounts.Account;
import ru.bpc.sv2.application.Application;
import ru.bpc.sv2.application.ApplicationElement;
import ru.bpc.sv2.application.ApplicationFlowFilter;
import ru.bpc.sv2.application.ContractObject;
import ru.bpc.sv2.constants.EntityNames;
import ru.bpc.sv2.constants.application.AppElements;
import ru.bpc.sv2.constants.application.ApplicationConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.issuing.Card;
import ru.bpc.sv2.logic.AccountsDao;
import ru.bpc.sv2.logic.ApplicationDao;
import ru.bpc.sv2.logic.IssuingDao;
import ru.bpc.sv2.logic.ProductsDao;
import ru.bpc.sv2.products.Contract;
import ru.bpc.sv2.products.Customer;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DictUtils;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.utils.UserException;
import util.auxil.ManagedBeanWrapper;
import util.auxil.SessionWrapper;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.model.SelectItem;
import java.io.Serializable;
import java.math.BigDecimal;
import java.util.*;

import static ru.bpc.sv2.utils.AppStructureUtils.*;

@ViewScoped
@ManagedBean(name = "MbAppWizCloseService")
public class MbAppWizCloseService extends AbstractBean implements AppWizStep, Serializable {

    private static final String CUSTOMER_ID = "CUSTOMER_ID";
    private static final String LANG = "LANG";
    private static final String ELEMENT_CUSTOMER_ID = "CUSTOMER_ID";
    private static final String PARAM_TAB = "param_tab";
    private static final String TAB_NAME = "tab_name";
    private static final String PARTICIPANT_MODE = "PARTICIPANT_MODE";
    private static final String ACQ = "ACQ";
    private static final String ISS = "ISS";
    private static final String INST_ID = "INST_ID";

    private static final Logger logger = Logger.getLogger("APPLICATIONS");
    private String page = "/pages/common/application/closeService.jspx";
    private DictUtils dictUtils;
    private MbWizard mbWizard;
    private Map<Integer, ApplicationFlowFilter> applicationFilters;
    private String language;
    private String activeEntity;
    private String activeObject;
    private List<SelectItem> entityList;
    private List<SelectItem> objectList;
    private List<ContractObject> services;
    private Map<String, List<ContractObject>> servicesMap;
    private ApplicationElement applicationRoot;
    private ApplicationElement customerElement;
    private Integer instId;
    private Integer agentId;
    private ApplicationWizardContext ctx;
    private Contract contract;
    private Map<ApplicationElement, List<ApplicationElement>> linkedMap;
    private Customer customer;

    private ProductsDao productsDao = new ProductsDao();

    private AccountsDao accountsDao = new AccountsDao();

    private IssuingDao issuingDao = new IssuingDao();
    
    private ApplicationDao applicationDao = new ApplicationDao();


    @Override
    public void clearFilter() {

    }

    public MbAppWizCloseService(){
        logger.debug("MbAppWizCloseService::constructor");
    }

    @Override
    public ApplicationWizardContext release() {
        try {
            beforeChangeActiveObject();
            ApplicationElement contractEl = releaseContract();
            releaseContractObjects(contractEl);
            ctx.setLinkedMap(linkedMap);
            ctx.setApplicationRoot(applicationRoot);
            applicationRoot = null;
            return ctx;
        }
        catch(Exception e){
            FacesUtils.addMessageError(e);
            logger.error("", e);
        }

        return ctx;
    }

    /*
     *function to create elements CARD and ACCOUNT and fill SERVICES for it
     */
    private void releaseContractObjects(ApplicationElement contractEl)throws Exception{
        for (String element: servicesMap.keySet()){
            String entity = element.split("-")[1];
            if (EntityNames.CARD.equalsIgnoreCase(entity)){
                releaseElement(contractEl, element, AppElements.CARD, AppElements.CARD_NUMBER);
            } else if (EntityNames.ACCOUNT.equalsIgnoreCase(entity)){
                releaseElement(contractEl, element, AppElements.ACCOUNT, AppElements.ACCOUNT_NUMBER);
            }
        }

    }

    /*
     *function to create new element and link it with service
     * @param contractEl - element to which  will be added new element
     * @param element - entity type of element
     * @param  objectNameConst - name new element
     * @param objectNumberConst - name of new element _NUMBER
     */
    private void releaseElement(ApplicationElement contractEl, String element, String objectNameConst,
                                String objectNumberConst) throws Exception{
        String objectNumber = element.split("-")[2];
        boolean found = false;
        /*
         *Search item if it has already been added is updated end_date
         */
        List<ApplicationElement> objects = contractEl.getChildrenByName(objectNameConst);
        for (ApplicationElement object: objects){
            ApplicationElement objectNumberEl = object.getChildByName(objectNumberConst, 1);
            if (objectNumberEl != null && objectNumber.equalsIgnoreCase(objectNumberEl.getValueV())){
                found = true;
                List<ApplicationElement>servicesEl = contractEl.getChildrenByName(AppElements.SERVICE);
                for (ApplicationElement serviceEl: servicesEl){
                    ApplicationElement serviceObject = serviceEl.getChildByName(AppElements.SERVICE_OBJECT, 1);
                    if (serviceObject != null && serviceObject.getValueText().equalsIgnoreCase(object.getBlockName())){
                        for(ContractObject contractObject: servicesMap.get(element)){
                            if (contractObject.getId().equals(serviceEl.getValueN().longValue())){
                                serviceObject.getChildByName(AppElements.END_DATE, 1).setValueD(contractObject.getEndDate());
                            }
                        }
                    }
                }
            }
        }
        /*
         * if not found - needed create new element
         */
        if (!found){
            ApplicationElement objectEl = addBl(objectNameConst, contractEl);
            if (objectEl != null){
                objectEl.getChildByName(objectNumberConst, 1).setValueV(objectNumber);
                List<ApplicationElement> linkedElem = new ArrayList<ApplicationElement>();
                for (ContractObject contractObject: servicesMap.get(element)){
                    if (contractObject.getEndDate() != null) {
                        linkedElem.add(createService(contractEl, contractObject, objectEl));
                    }
                }
                linkedMap.put(objectEl, linkedElem);
            }
        }
    }

    /*
     *function to create SERVICE and SERVICE_OBJECT
     * @param parentElement - element to which it will be added to SERVICE and SERVICE_OBJECT
     * @param contractObject - service element, which is taken END_DATE
     * @param linkedElement - element is associated with the service
     * @result created service
     */
    private ApplicationElement createService(ApplicationElement parentElement, ContractObject contractObject,
                                             ApplicationElement linkedElement) throws Exception{
        ApplicationElement service = addBl(AppElements.SERVICE, parentElement);
        service.setValueN(BigDecimal.valueOf(contractObject.getId()));
        ApplicationElement serviceObject = addBl(AppElements.SERVICE_OBJECT, service);
        serviceObject.getChildByName(AppElements.END_DATE, 1).setValueD(contractObject.getEndDate());
        serviceObject.setValueText(linkedElement.getBlockName());

        return service;
    }

    /*
     *function check is element CONTRACT exist and if not - create this element
     * fill COMMAND and CONTRACT_NUMBER
     */
    private ApplicationElement releaseContract() throws Exception{
        ApplicationElement contractEl = customerElement.getChildByName(AppElements.CONTRACT, 1);
        if (contractEl == null) {
            contractEl = addBl(AppElements.CONTRACT, customerElement);
        }
        contractEl.getChildByName(AppElements.COMMAND, 1).setValueV(ApplicationConstants.COMMAND_EXCEPT_OR_PROCEED);
        ApplicationElement contractNumb =  contractEl.getChildByName(AppElements.CONTRACT_NUMBER, 1);
        if (contractNumb == null){
            contractNumb = addBl(AppElements.CONTRACT_NUMBER, contractEl);
        }
        contractNumb.setValueV(contract.getContractNumber());
        return contractEl;
    }

    @Override
    public void init(ApplicationWizardContext ctx) {
        this.ctx = ctx;
        logger.debug("MbAppWizCloseService::init...");
        mbWizard = ManagedBeanWrapper.getManagedBean(MbWizard.class);
        language = SessionWrapper.getField("language");
        userSessionId = SessionWrapper.getRequiredUserSessionId();
        this.applicationRoot = ctx.getApplicationRoot();
        servicesMap = new HashMap<String, List<ContractObject>>();
        ctx.setStepPage(page);
        customerElement = applicationRoot.getChildByName(AppElements.CUSTOMER, 1);
        logger.debug("customerElement= " + customerElement);
        instId = applicationRoot.retrive(AppElements.INSTITUTION_ID).getValueN().intValue();
        agentId = applicationRoot.retrive(AppElements.AGENT_ID).getValueN().intValue();
        applicationFilters = ctx.getApplicationFilters();
        linkedMap = ctx.getLinkedMap();
        prepareCustomer();
        prepareContract();
    }

    private void prepareCustomer(){
        Customer[]customers = getCustomers(customerElement.getChildByName(AppElements.CUSTOMER_NUMBER, 1).getValueV());
        if (customers.length > 0) {
            customer = customers[0];
        }
    }

    private void prepareContract(){

        Filter paramFilter = new Filter();
        paramFilter.setElement(CUSTOMER_ID);
        paramFilter.setValue(customer.getId());
        filters = new ArrayList<Filter>();
        filters.add(paramFilter);

        paramFilter = new Filter();
        paramFilter.setElement(LANG);
                paramFilter.setValue(curLang);
        filters.add(paramFilter);

        SelectionParams params = new SelectionParams();
        params.setRowIndexStart(0);
        params.setRowIndexEnd(Integer.MAX_VALUE);
        params.setFilters(filters.toArray(new Filter[filters.size()]));
        Map<String, Object> paramsMap = new HashMap<String, Object>();
        paramsMap.put("param_tab", filters.toArray(new Filter[filters.size()]));
        paramsMap.put("tab_name", "CONTRACT");
        Contract []contracts = productsDao.getContractsCur(userSessionId, params, paramsMap);

        if (contracts.length > 0) {
            contract = contracts[0];
        }
    }

    @Override
    public boolean validate() {
        return true;
    }

    @Override
    public boolean checkKeyModifications() {
        return false;
    }

    @Override
    public boolean getLock() {
        return true;
    }

    public List<SelectItem> getEntityList() {
        if (entityList == null || entityList.size() == 0){
            entityList = new ArrayList<SelectItem>();
            entityList.add(new SelectItem(EntityNames.CUSTOMER, getDictUtils().getArticles().get(EntityNames.CUSTOMER)));
            entityList.add(new SelectItem(EntityNames.CONTRACT, getDictUtils().getArticles().get(EntityNames.CONTRACT)));
            entityList.add(new SelectItem(EntityNames.ACCOUNT, getDictUtils().getArticles().get(EntityNames.ACCOUNT)));
            entityList.add(new SelectItem(EntityNames.CARD, getDictUtils().getArticles().get(EntityNames.CARD)));
        }
        return entityList;
    }

    private SelectItem getContract(){
        SelectItem result;
        result = new SelectItem(contract.getId().toString() + "-" + EntityNames.CONTRACT + "-"
                                + contract.getContractNumber(),
                getDictUtils().getArticles().get(EntityNames.CONTRACT) + " - " + contract.getContractNumber());

        return result;
    }


    /*
     * function to create List of cards
     * @param customer - all cards of this customer
     * struct of Item: "ID-'ENTTCARD'-CARD_NUMBER"
     */
    private List<SelectItem> getCardsList(Customer customer){
        List<SelectItem> result = new ArrayList<SelectItem>();
        Card []cards = getCards(customer);
        for (Card card : cards){
            result.add(new SelectItem(card.getId() + "-" + EntityNames.CARD + "-" + card.getCardNumber(),
                    getDictUtils().getArticles().get(EntityNames.CARD) + " - " + card.getMask()));
        }
        return result;
    }

    private Card[] getCards(Customer customer){
        Map <String, Object> paramMap = new HashMap<String, Object>();
        Filter paramFilter = new Filter();
        paramFilter.setElement(ELEMENT_CUSTOMER_ID);
        paramFilter.setValue(customer.getId());
        filters = new ArrayList<Filter>();
        filters.add(paramFilter);
        paramMap.put(PARAM_TAB, filters.toArray(new Filter[filters.size()]));
        paramMap.put(TAB_NAME, AppElements.CARD);
        SelectionParams params = new SelectionParams();
        params.setRowIndexStart(0);
        params.setRowIndexEnd(Integer.MAX_VALUE);
        params.setFilters(filters.toArray(new Filter[filters.size()]));
        return issuingDao.getCardsCur(userSessionId, params, paramMap);
    }

    /*
     * function to create List of accounts
     * @param customer - all account of this customer
     * struct of Item: "ID-'ENTTACCT'-ACCOUNT_NUMBER"
     */
    private List<SelectItem> getAccountList(Customer customer){
        List<SelectItem> result = new ArrayList<SelectItem>();
        Account []accounts = getAccounts(customer);
        for(Account acc : accounts){
            result.add(new SelectItem(acc.getId().toString() + "-" + EntityNames.ACCOUNT + "-" + acc.getAccountNumber(),
                    getDictUtils().getArticles().get(EntityNames.ACCOUNT) + " - " + acc.getAccountNumber()));
        }

        return  result;
    }

    private Account[] getAccounts(Customer customer){
        Map <String, Object> paramMap = new HashMap<String, Object>();
        Filter paramFilter = new Filter();
        paramFilter.setElement(AppElements.CUSTOMER_NUMBER);
        paramFilter.setValue(customer.getCustomerNumber().trim().toUpperCase().replaceAll("[*]",
                "%").replaceAll("[?]", "_"));
        filters = new ArrayList<Filter>();
        filters.add(paramFilter);
        filters.add(new Filter(PARTICIPANT_MODE, isAcquiringType() ? ACQ : ISS));
                paramMap.put(PARAM_TAB, filters.toArray(new Filter[filters.size()]));
        paramMap.put(TAB_NAME, AppElements.ACCOUNT);
        SelectionParams params = new SelectionParams();
        params.setRowIndexStart(0);
        params.setRowIndexEnd(Integer.MAX_VALUE);
        params.setFilters(filters.toArray(new Filter[filters.size()]));
        return accountsDao.getAccountsCur(userSessionId, params, paramMap);
    }

    private boolean isAcquiringType(){
        return EntityNames.ACQUIRING_APPLICATION.equalsIgnoreCase(
                ctx.getApplicationType());
    }

    private Customer[] getCustomers(String customerNumber){
        ArrayList <Filter>filters = new ArrayList<Filter>();
        filters.add(new Filter(AppElements.LANG, language));
        filters.add(new Filter(AppElements.CUSTOMER_NUMBER, customerNumber));
        filters.add(new Filter(INST_ID, instId));
        filters.add(new Filter(AppElements.AGENT_ID, agentId));
        SelectionParams params = new SelectionParams();
        params.setFilters(filters.toArray(new Filter[filters.size()]));
        params.setRowIndexStart(0);
        params.setRowIndexEnd(Integer.MAX_VALUE);
        Customer [] customers = productsDao.getCombinedCustomersProc(userSessionId, params, AppElements.CUSTOMER);
        return customers;
    }

    public void setEntityList(List<SelectItem> entityList) {
        this.entityList = entityList;
    }

    public String getActiveEntity() {
        return activeEntity;
    }

    public void setActiveEntity(String activeEntity) {
        this.activeEntity = activeEntity;
    }

	public List<ContractObject> getServices() {
		return services;
	}

	public void setServices(List<ContractObject> services) {
		this.services = services;
	}
	
	public void prepareServices(){
		if (activeObject != null){
            if (servicesMap.containsKey(activeObject)){
                services = servicesMap.get(activeObject);
            }else {
                ContractObject filter = new ContractObject();
                filter.setInitial(false);
                String[] splittedString = activeObject.split("-");
                filter.setEntityType(splittedString[1]);
                filter.setObjectId(splittedString[2]);
                filter.setServiceExist(1);
                if (contract != null){
                    filter.setContractNumber(contract.getContractNumber());
                }
                ContractObject[] servicesArr =
                        applicationDao.getContractServicesByEntity(userSessionId, filter);
                services = Arrays.asList(servicesArr);
            }
		}
	}

    public void beforeChangeActiveObject(){
        if (services != null && activeObject != null && !services.isEmpty()){
            servicesMap.put(activeObject, services);
        }
    }

    private ApplicationElement addBl(String name,
                                     ApplicationElement parent)throws UserException {
        ApplicationElement result;
        try {
            result = instance(parent, name);
        } catch (IllegalArgumentException e) {
            throw new UserException(e);
        }
        Integer instId = applicationRoot.retrive(AppElements.INSTITUTION_ID).getValueN()
                .intValue();
        Application appStub = new Application();
        appStub.setInstId(instId);
        applicationDao.fillRootChilds(userSessionId, instId, result, applicationFilters);
        if (name.equalsIgnoreCase(AppElements.ACCOUNT)){
            result.retrive(AppElements.COMMAND).setValueV(ApplicationConstants.COMMAND_EXCEPT_OR_PROCEED);
        }
        applicationDao.applyDependencesWhenAdd(userSessionId, appStub, result,
                applicationFilters);
        return result;
    }

    public List<SelectItem> getObjectList() {
        objectList = new ArrayList<SelectItem>();
        if (activeEntity != null){
            if (EntityNames.CUSTOMER.equalsIgnoreCase(activeEntity)) {
                objectList.add(getCustomerList());
            } else if (EntityNames.CONTRACT.equalsIgnoreCase(activeEntity)){
                objectList.add(getCustomerList());
                objectList.addAll(getAccountList(customer));
                objectList.addAll(getCardsList(customer));
            } else if (EntityNames.CARD.equalsIgnoreCase(activeEntity)){
                objectList.addAll(getCardsList(customer));
            } else if (EntityNames.ACCOUNT.equalsIgnoreCase(activeEntity)){
                objectList.addAll(getAccountList(customer));
            }
        }
        return objectList;
    }

    private SelectItem getCustomerList(){
        return new SelectItem(customer.getId().toString() + "-" +  EntityNames.CUSTOMER + "-"
                + customer.getCustomerNumber() ,
                getDictUtils().getArticles().get(EntityNames.CUSTOMER) + " - "
                        + customer.getCustomerNumber());
    }

    public void setObjectList(List<SelectItem> objectList) {
        this.objectList = objectList;
    }

    public String getActiveObject() {
        return activeObject;
    }

    public void setActiveObject(String activeObject) {
        this.activeObject = activeObject;
    }

    public DictUtils getDictUtils(){
        if (dictUtils == null){
            dictUtils = ManagedBeanWrapper.getManagedBean(DictUtils.class);
        }
        return dictUtils;
    }
}
