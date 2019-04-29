package ru.bpc.sv2.products;

import java.io.Serializable;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;

import ru.bpc.sv2.common.Address;
import ru.bpc.sv2.common.Company;
import ru.bpc.sv2.common.Contact;
import ru.bpc.sv2.common.Person;
import ru.bpc.sv2.common.PersonId;
import ru.bpc.sv2.constants.EntityNames;
import ru.bpc.sv2.invocation.IAuditableObject;
import ru.bpc.sv2.invocation.ModelIdentifiable;

public class Customer implements Serializable, ModelIdentifiable, Cloneable, IAuditableObject {
	private static final long serialVersionUID = 1L;

	private Long id;
	private Integer seqNum;
	private String entityType;
	private Long objectId;
	private String customerNumber;
	private Integer instId;
	private Integer agentId;
	private Integer splitHash;
	private String instName;
	private Long contractId;
	private String contractNumber;
	private Integer productId;
	private String contractName;

	private Person person;
	private Company company;
	private PersonId document;
	private Address address;
	private Contact contact;
	private Contract contract;

	private Integer contractsCount;
	private Integer cardsCount;
	private Integer accountsCount;
	private Integer documentsCount;
	private Integer servicesCount;
	private Integer limitsCount;
	private Integer cyclesCount;
	private Integer paymentOrdersCount;
	private Integer issProductCount;
	private Integer acqProductCount;
	private Integer salaryContractCount;
	private Integer merchantsCount;
	private Integer terminalsCount;

	private String productType;
	private String category;
	private String relation;
	private String documentString;
	private String customerName;
	private String status;
	private Boolean resident;
	private String nationality;
	private String creditRating;
	private String moneyLaundryRisk;
	private String moneyLaundryReason;
	private Date lastModifyDate;
	private Integer lastModifyUser;

	private String extEntityType;
	private Long extObjectId;
	private String extObjectName;
	private String agentNumber;
	private String agentName;

	private String employmentStatus;
	private String employmentPeriod;
	private String residenceType;
	private String maritalStatus;
	private Date maritalStatusDate;
	private String incomeRange;
	private String numberOfChildren;
	private String referralCode;

	private boolean newCustomer;
	private String statusReason;
	private Integer maxAgingPeriod;

	public Object getModelId() {
		return getId();
	}

	public Long getId() {
		return id;
	}
	public void setId(Long id) {
		this.id = id;
	}

	public Integer getSeqNum() {
		return seqNum;
	}
	public void setSeqNum(Integer seqNum) {
		this.seqNum = seqNum;
	}

	public String getEntityType() {
		return entityType;
	}
	public void setEntityType(String entityType) {
		this.entityType = entityType;
	}

	public Long getObjectId() {
		return objectId;
	}
	public void setObjectId(Long objectId) {
		this.objectId = objectId;
	}

	public String getCustomerNumber() {
		return customerNumber;
	}
	public void setCustomerNumber(String customerNumber) {
		this.customerNumber = customerNumber;
	}

	public Integer getInstId() {
		return instId;
	}
	public void setInstId(Integer instId) {
		this.instId = instId;
	}

	public Integer getSplitHash() {
		return splitHash;
	}
	public void setSplitHash(Integer splitHash) {
		this.splitHash = splitHash;
	}

	public String getInstName() {
		return instName;
	}
	public void setInstName(String instName) {
		this.instName = instName;
	}

	public Long getContractId() {
		return contractId;
	}
	public void setContractId(Long contractId) {
		this.contractId = contractId;
	}

	public Integer getProductId() {
		return productId;
	}
	public void setProductId(Integer productId) {
		this.productId = productId;
	}

	public String getContractName() {
		return contractName;
	}
	public void setContractName(String contractName) {
		this.contractName = contractName;
	}

	public Person getPerson() {
		if (person == null) {
			person = new Person();
		}
		return person;
	}
	public void setPerson(Person person) {
		this.person = person;
	}

	public Contact getContact() {
		if (contact == null) {
			contact = new Contact();
		}
		return contact;
	}
	public void setContact(Contact contact) {
		this.contact = contact;
	}

	public Company getCompany() {
		if (company == null) {
			company = new Company();
		}
		return company;
	}
	public void setCompany(Company company) {
		this.company = company;
	}

	public PersonId getDocument() {
		if (document == null) {
			document = new PersonId();
		}
		return document;
	}
	public void setDocument(PersonId document) {
		this.document = document;
	}

	public Address getAddress() {
		if (address == null) {
			address = new Address();
		}
		return address;
	}
	public void setAddress(Address address) {
		this.address = address;
	}

	public String getContractNumber() {
		return contractNumber;
	}
	public void setContractNumber(String contractNumber) {
		this.contractNumber = contractNumber;
	}

	public Integer getContractsCount() {
		return contractsCount;
	}
	public void setContractsCount(Integer contractsCount) {
		this.contractsCount = contractsCount;
	}

	public Integer getPaymentOrdersCount() {
		return paymentOrdersCount;
	}
	public void setPaymentOrdersCount(Integer paymentOrdersCount) {
		this.paymentOrdersCount = paymentOrdersCount;
	}

	public Integer getCardsCount() {
		return cardsCount;
	}
	public void setCardsCount(Integer cardsCount) {
		this.cardsCount = cardsCount;
	}

	public Integer getAccountsCount() {
		return accountsCount;
	}
	public void setAccountsCount(Integer accountsCount) {
		this.accountsCount = accountsCount;
	}

	public Integer getDocumentsCount() {
		return documentsCount;
	}
	public void setDocumentsCount(Integer documentsCount) {
		this.documentsCount = documentsCount;
	}

	public Integer getServicesCount() {
		return servicesCount;
	}
	public void setServicesCount(Integer servicesCount) {
		this.servicesCount = servicesCount;
	}

	public Integer getLimitsCount() {
		return limitsCount;
	}
	public void setLimitsCount(Integer limitsCount) {
		this.limitsCount = limitsCount;
	}

	public Integer getCyclesCount() {
		return cyclesCount;
	}
	public void setCyclesCount(Integer cyclesCount) {
		this.cyclesCount = cyclesCount;
	}

	@Override
	public Object clone() throws CloneNotSupportedException {
		Customer clone = (Customer) super.clone();
		if (person != null) {
			clone.setPerson(person.clone());
		}
		if (company != null) {
			clone.setCompany((Company) company.clone());
		}
		if (document != null) {
			clone.setDocument((PersonId) document.clone());
		}
		if (address != null) {
			clone.setAddress((Address) address.clone());
		}
		if (contact != null) {
			clone.setContact((Contact) contact.clone());
		}
		return clone;
	}

	public boolean isCompanyCustomer() {
		return EntityNames.COMPANY.equals(entityType);
	}
	public boolean isPersonCustomer() {
		return EntityNames.PERSON.equals(entityType);
	}
	public boolean isUndefinedCustomer() {
		return EntityNames.UNDEFINED.equals(entityType);
	}

	public String getName() {
				
		if (customerName != null) {
			return customerNumber + " - " + customerName;
		}
		String result = null;
		if (EntityNames.COMPANY.equals(entityType) && company != null) {
			result = company.getLabel() == null ? (company.getEmbossedName() == null ? "{ID = " +
					company.getId() + "}" : company.getEmbossedName()) : company.getLabel();
		} else if (EntityNames.PERSON.equals(entityType) && person != null) {
			result = person.getFullName() == null ? "{ID = " + person.getPersonId() + "}" : person
					.getFullName();
		} else {
			result = customerNumber + " ";
		}
		return result;
	}

	public String getProductType() {
		return productType;
	}
	public void setProductType(String productType) {
		this.productType = productType;
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

	public Integer getIssProductCount() {
		return issProductCount;
	}
	public void setIssProductCount(Integer issProductCount) {
		this.issProductCount = issProductCount;
	}

	public Integer getAcqProductCount() {
		return acqProductCount;
	}
	public void setAcqProductCount(Integer acqProductCount) {
		this.acqProductCount = acqProductCount;
	}

	public Integer getSalaryContractCount() {
		return salaryContractCount;
	}
	public void setSalaryContractCount(Integer salaryContractCount) {
		this.salaryContractCount = salaryContractCount;
	}

	public Integer getAgentId() {
		return agentId;
	}
	public void setAgentId(Integer agentId) {
		this.agentId = agentId;
	}

	public Contract getContract() {
		return contract;
	}
	public void setContract(Contract contract) {
		this.contract = contract;
	}

	public String getDocumentString() {
		return documentString;
	}
	public void setDocumentString(String documentString) {
		this.documentString = documentString;
	}

	public String getCustomerName() {
		return customerName;
	}
	public void setCustomerName(String customerName) {
		this.customerName = customerName;
	}

	public String getStatus() {
		return status;
	}
	public void setStatus(String status) {
		this.status = status;
	}

	public Boolean getResident(){
		return this.resident;
	}
	public void setResident(Boolean resident){
		this.resident = resident;
	}
	
	public String getNationality(){
		return this.nationality;
	}
	public void setNationality(String nationality){
		this.nationality = nationality;
	}
	
	public String getCreditRating(){
		return this.creditRating;
	}
	public void setCreditRating(String creditRating){
		this.creditRating = creditRating;
	}
	
	public String getMoneyLaundryRisk(){
		return this.moneyLaundryRisk;
	}
	public void setMoneyLaundryRisk(String moneyLaundryRisk){
		this.moneyLaundryRisk = moneyLaundryRisk;
	}
	
	public String getMoneyLaundryReason(){
		return this.moneyLaundryReason;
	}
	public void setMoneyLaundryReason(String moneyLaundryReason){
		this.moneyLaundryReason = moneyLaundryReason;
	}
	
	public Date getLastModifyDate(){
		return this.lastModifyDate;
	}
	public void setLastModifyDate(Date lastModifyDate){
		this.lastModifyDate = lastModifyDate;
	}
	
	public Integer getLastModifyUser(){
		return this.lastModifyUser;
	}
	public void setLastModifyUser(Integer lastModifyUser){
		this.lastModifyUser = lastModifyUser;
	}

	public String getExtEntityType() {
		return extEntityType;
	}
	public void setExtEntityType(String extEntityType) {
		this.extEntityType = extEntityType;
	}

	public Long getExtObjectId() {
		return extObjectId;
	}
	public void setExtObjectId(Long extObjectId) {
		this.extObjectId = extObjectId;
	}

	public String getExtObjectName() {
		return extObjectName;
	}
	public void setExtObjectName(String extObjectName) {
		this.extObjectName = extObjectName;
	}
	
	public Integer getMerchantsCount() {
		return merchantsCount;
	}
	public void setMerchantsCount(Integer merchantCount) {
		this.merchantsCount = merchantCount;
	}

	public Integer getTerminalsCount() {
		return terminalsCount;
	}
	public void setTerminalsCount(Integer terminalCount) {
		this.terminalsCount = terminalCount;
	}

	public String getAgentNumber() {
		return agentNumber;
	}
	public void setAgentNumber(String agentNumber) {
		this.agentNumber = agentNumber;
	}

	public String getAgentName() {
		return agentName;
	}
	public void setAgentName(String agentName) {
		this.agentName = agentName;
	}

	public String getEmploymentStatus() {
		return employmentStatus;
	}

	public void setEmploymentStatus(String employmentStatus) {
		this.employmentStatus = employmentStatus;
	}

	public String getEmploymentPeriod() {
		return employmentPeriod;
	}

	public void setEmploymentPeriod(String employmentPeriod) {
		this.employmentPeriod = employmentPeriod;
	}

	public String getResidenceType() {
		return residenceType;
	}

	public void setResidenceType(String residenceType) {
		this.residenceType = residenceType;
	}

	public Date getMaritalStatusDate() {
		return maritalStatusDate;
	}

	public void setMaritalStatusDate(Date maritalStatusDate) {
		this.maritalStatusDate = maritalStatusDate;
	}

	public String getIncomeRange() {
		return incomeRange;
	}

	public void setIncomeRange(String incomeRange) {
		this.incomeRange = incomeRange;
	}

	public String getreferralCode() {
		return referralCode;
	}

	public void setreferralCode(String referralCode) {
		this.referralCode = referralCode;
	}

	public String getNumberOfChildren() {
		return numberOfChildren;
	}

	public void setNumberOfChildren(String numberOfChildren) {
		this.numberOfChildren = numberOfChildren;
	}

	public boolean isNewCustomer() {
		return newCustomer;
	}

	public void setNewCustomer(boolean newCustomer) {
		this.newCustomer = newCustomer;
	}

	public String getMaritalStatus() {
		return maritalStatus;
	}

	public void setMaritalStatus(String maritalStatus) {
		this.maritalStatus = maritalStatus;
	}

	public Integer getMaxAgingPeriod() {
		return maxAgingPeriod;
	}

	public void setMaxAgingPeriod(Integer maxAgingPeriod) {
		this.maxAgingPeriod = maxAgingPeriod;
	}

	public String getStatusReason() {
		return statusReason;
	}

	public void setStatusReason(String statusReason) {
		this.statusReason = statusReason;
	}

	@Override
	public Map<String, Object> getAuditParameters() {
		Map<String, Object> result = new HashMap<String, Object>();
		result.put("id", getId());
		result.put("entityType", getEntityType());
		result.put("objectId", getObjectId());
		result.put("customerNumber", getCustomerNumber());
		result.put("instId", getInstId());
		result.put("maxAgingPeriod", getMaxAgingPeriod());
		return result;
	}
}
