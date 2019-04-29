package ru.bpc.sv2.logic;

import com.ibatis.sqlmap.client.SqlMapSession;
import in.bpc.sv.svxp.*;
import in.bpc.sv.svxp.Transactions;
import org.w3c.dom.Document;
import org.w3c.dom.Node;
import ru.bpc.sv.instagentws.*;
import ru.bpc.sv.svxp.pmo.Parameter;
import ru.bpc.sv.svxp.pmo.PaymentOrder;
import ru.bpc.sv2.accounts.AccountPrivConstants;
import ru.bpc.sv2.accounts.Transaction;
import ru.bpc.sv2.accounts.TransactionSvXp;
import ru.bpc.sv2.application.ContractObject;
import ru.bpc.sv2.aup.AuthSchemeObject;
import ru.bpc.sv2.common.*;
import ru.bpc.sv2.common.Company;
import ru.bpc.sv2.common.Person;
import ru.bpc.sv2.common.rates.RateSvXp;
import ru.bpc.sv2.constants.EntityNames;
import ru.bpc.sv2.credit.CreditInvoice;
import ru.bpc.sv2.credit.CreditInvoiceAggregation;
import ru.bpc.sv2.credit.CreditInvoiceOperation;
import ru.bpc.sv2.credit.CreditPrivConstants;
import ru.bpc.sv2.fraud.McwFraud;
import ru.bpc.sv2.instagent.Agent;
import ru.bpc.sv2.instagent.ContactObject;
import ru.bpc.sv2.instagent.Institute;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.issuing.CardInstance;
import ru.bpc.sv2.issuing.IssuingPrivConstants;
import ru.bpc.sv2.logic.controller.CommonController;
import ru.bpc.sv2.logic.utility.db.IbatisAware;
import ru.bpc.sv2.logic.utility.db.IbatisSessionCallback;
import ru.bpc.sv2.logic.utility.db.QueryParams;
import ru.bpc.sv2.operations.Operation;
import ru.bpc.sv2.operations.OperationPrivConstants;
import ru.bpc.sv2.operations.Participant;
import ru.bpc.sv2.products.Customer;
import ru.bpc.sv2.products.Product;
import ru.bpc.sv2.products.ProductPrivConstants;
import ru.bpc.sv2.utils.AuditParamUtil;
import ru.bpc.sv2.utils.UserException;
import ru.bpc.svxp.*;
import ru.bpc.svxp.Address;
import ru.bpc.svxp.Contact;
import ru.bpc.svxp.integration.GeneratePinBlockRequest;

import ru.bpc.sv2.logic.utility.db.DataAccessException;

import javax.xml.bind.JAXBContext;
import javax.xml.bind.JAXBElement;
import javax.xml.bind.Unmarshaller;
import javax.xml.datatype.DatatypeConfigurationException;
import javax.xml.datatype.DatatypeFactory;
import javax.xml.datatype.XMLGregorianCalendar;
import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import java.io.ByteArrayInputStream;
import java.math.BigDecimal;
import java.sql.SQLException;
import java.util.*;

import static ru.bpc.sv2.logic.ModuleDao.logger;

@SuppressWarnings ({"ConstantConditions", "unchecked", "SameParameterValue"})
public class IntegrationDao extends IbatisAware {

    public Map<String, Object> auth(final Map<String, Object> map) {
        return executeWithSession(logger, new IbatisSessionCallback<Map<String, Object>>() {
            @Override
            public Map<String, Object> doInSession(SqlMapSession ssn) throws Exception {
                Map<String, Object> temp = new HashMap<String, Object>(map);
                ssn.queryForObject("integ.auth", temp);
                return temp;
            }
        });
    }


    public Map<String, Object> getCustomerInfo(long userSessionId, final Map<String, Object> map) {
        return executeWithSession(userSessionId,
                                  logger,
                                  new IbatisSessionCallback<Map<String, Object>>() {
            @Override
            public Map<String, Object> doInSession(SqlMapSession ssn) throws Exception {
                Map<String, Object> temp = new HashMap<String, Object>(map);
                ssn.queryForObject("integ.get-customer-info", temp);
                return temp;
            }
        });
    }

    @SuppressWarnings ("unchecked")
    public ru.bpc.svxp.Operation[] getOperations(Long userSessionId,
                                                 Map<String, Object> map) throws UserException {
        SqlMapSession ssn = null;
        try {
            List<ru.bpc.svxp.Operation> operationList = new ArrayList<ru.bpc.svxp.Operation>();
            ssn = getIbatisSessionNoContext();
            ssn.queryForList("integ.get-operations-cursor", map);
            List<Operation> opers = (List<Operation>) map.get("ref_cursor");

            for (Operation oper : opers) {
                ru.bpc.svxp.Operation operation = new ru.bpc.svxp.Operation();
                if (oper.getOriginalId() != null) {
                    operation.setOriginalId(String.valueOf(oper.getOriginalId()));
                }
                operation.setAccountNumber(oper.getAccountNumber());
                operation.setBalance(oper.getBalance());
                operation.setCardMask(oper.getCardMask());
                operation.setCardSeqNumber(oper.getCardSeqNumber());
                operation.setCurrency(oper.getCurrency());
                operation.setCurrencyName(oper.getCurrencyName());
                operation.setId(oper.getId());
                operation.setIsReversal(oper.getIsReversal());
                operation.setMcc(oper.getMccName());
                operation.setMerchantAddress(oper.getMerchantStreet());
                operation.setMerchantName(oper.getMerchantName());
                operation.setOperAmount(oper.getOperationAmount());
                if (oper.getOperationCurrency() != null &&
                        !oper.getOperationCurrency().equalsIgnoreCase("000")) {
                    operation.setOperCurrency(oper.getOperationCurrency());
                }
                if (oper.getOperDate() != null) {
                    GregorianCalendar cal = new GregorianCalendar();
                    cal.setTime(oper.getOperDate());
                    operation.setOperDate(DatatypeFactory.newInstance().newXMLGregorianCalendar(cal));
                } else {
                    operation.setOperDate(null);
                }
                operation.setOperType(oper.getOperationType());
                operation.setOperTypeName(oper.getOperationTypeName());
                operation.setStatus(oper.getStatus());
                operation.setStatusName(oper.getStatusName());
                operation.setAccountAmount(oper.getAccountAmount());
                if (oper.getAccountCurrency() != null &&
                        !oper.getAccountCurrency().equalsIgnoreCase("000")) {
                    operation.setAccountCurrency(oper.getAccountCurrency());
                }
                operation.setMerchantNumber(oper.getMerchantNumber());
                if (oper.getHostDate() != null) {
                    GregorianCalendar cal = new GregorianCalendar();
                    cal.setTime(oper.getHostDate());
                    operation.setHostDate(DatatypeFactory.newInstance().newXMLGregorianCalendar(cal));
                } else {
                    operation.setHostDate(null);
                }
                operation.setOriginatorRefnum(oper.getOriginatorRefnum());
                operation.setExternalAuthId(oper.getExternalAuthId());

	            operation.setRespCode(oper.getRespCode());
	            operation.setIsAdvice(Boolean.TRUE.equals(oper.getIsAdvice()) ? 1 : 0);
	            operation.setCatLevel(oper.getCatLevel());
	            operation.setCardDataInputCap(oper.getCardDataInputCap());
	            operation.setCrdhAuthCap(oper.getCrdhAuthCap());
	            operation.setCardCaptureCap(oper.getCardCaptureCap());
	            operation.setTerminalOperatingEnv(oper.getTerminalOperatingEnv());
	            operation.setCrdhPresence(oper.getCrdhPresence());
	            operation.setCardPresence(oper.getCardPresence());
	            operation.setCardDataInputMode(oper.getCardDataInputMode());
	            operation.setCrdhAuthMethod(oper.getCrdhAuthMethod());
	            operation.setCrdhAuthEntity(oper.getCrdhAuthEntity());
	            operation.setCardDataOutputCap(oper.getCardDataOutputCap());
	            operation.setTerminalOutputCap(oper.getTerminalOutputCap());
	            operation.setPinCaptureCap(oper.getPinCaptureCap());
	            operation.setPinPresence(oper.getPinPresence());
	            operation.setTerminalNumber(oper.getTerminalNumber());
	            operation.setAuthCode(oper.getAuthCode());

                operationList.add(operation);
            }
            return operationList.toArray(new ru.bpc.svxp.Operation[operationList.size()]);
        } catch (SQLException e) {
            if (e.getErrorCode() >= 20000 && e.getErrorCode() <= 20999) {
                throw new UserException(e.getCause().getMessage());
            } else {
                throw createDaoException(e);
            }
        } catch (Exception e) {
            throw new DataAccessException(e);
        } finally {
            close(ssn);
        }
    }


    public Integer getOperationsCount(Long userSessionId, SelectionParams params) {
        SqlMapSession ssn = null;
        try {
            CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
            ssn = getIbatisSession(userSessionId, null, OperationPrivConstants.VIEW_OPERATION, paramArr);
            String limitation = CommonController.getLimitationByPriv(ssn,
                                                                     OperationPrivConstants.VIEW_OPERATION);
            return (Integer) ssn.queryForObject(
                    "operations.get-operations-count",
                    convertQueryParams(params, limitation));
        } catch (SQLException e) {
            if (e.getCause() == null) {
                throw new DataAccessException(e.getMessage());
            } else {
                throw createDaoException(e);
            }
        } finally {
            close(ssn);
        }
    }

    @SuppressWarnings ("unchecked")

    public Transaction[] getEntries(Long userSessionId, SelectionParams params) {
        SqlMapSession ssn = null;
        try {

            CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
            ssn = getIbatisSession(userSessionId, null, AccountPrivConstants.VIEW_TRANSACTION, paramArr);

            List<Transaction> entries = ssn.queryForList(
                    "operations.get-transactions-by-oper",
                    convertQueryParams(params));
            return entries.toArray(new Transaction[entries.size()]);
        } catch (SQLException e) {
            if (e.getCause() == null) {
                throw new DataAccessException(e.getMessage());
            } else {
                throw createDaoException(e);
            }
        } finally {
            close(ssn);
        }
    }

    @SuppressWarnings ("unchecked")

    public Transaction[] getEntriesForOperation(Long userSessionId,
                                                SelectionParams params) {
        SqlMapSession ssn = null;
        try {

            CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
            ssn = getIbatisSession(userSessionId, null, AccountPrivConstants.VIEW_TRANSACTION, paramArr);

            List<Transaction> entries = ssn.queryForList(
                    "operations.get-transactions-by-oper",
                    convertQueryParams(params));
            return entries.toArray(new Transaction[entries.size()]);
        } catch (SQLException e) {
            throw new DataAccessException(e);
        } finally {
            close(ssn);
        }
    }


    public Integer getEntriesCount(Long userSessionId, SelectionParams params) {
        SqlMapSession ssn = null;
        try {
            CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
            ssn = getIbatisSession(userSessionId, null, AccountPrivConstants.VIEW_TRANSACTION, paramArr);

            return (Integer) ssn.queryForObject(
                    "operations.get-transactions-count-by-oper",
                    convertQueryParams(params));
        } catch (SQLException e) {
            if (e.getCause() == null) {
                throw new DataAccessException(e.getMessage());
            } else {
                throw createDaoException(e);
            }
        } finally {
            close(ssn);
        }
    }

    public void addAdjusment(Long userSessionId,
                             ru.bpc.sv2.operations.incoming.Operation operation) {
        SqlMapSession ssn = null;

        try {
            CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(operation.getAuditParameters());
            ssn = getIbatisSession(userSessionId, null, OperationPrivConstants.ADD_ADJUSTMENT, paramArr);

            ssn.update("operations.add-adjusment", operation);
            ssn.update("operations.add-participant", operation);
        } catch (SQLException e) {
            if (e.getCause() == null) {
                throw new DataAccessException(e.getMessage());
            } else {
                throw createDaoException(e);
            }
        } finally {
            close(ssn);
        }
    }

    @SuppressWarnings ("unchecked")

    public Participant[] getParticipants(Long userSessionId,
                                         SelectionParams params) {
        SqlMapSession ssn = null;
        try {

            ssn = getIbatisSessionNoContext();
            List<Participant> items = ssn.queryForList(
                    "operations.get-participants", convertQueryParams(params));

            return items.toArray(new Participant[items.size()]);
        } catch (SQLException e) {
            if (e.getCause() == null) {
                throw new DataAccessException(e.getMessage());
            } else {
                throw createDaoException(e);
            }
        } finally {
            close(ssn);
        }
    }

    @SuppressWarnings ("unchecked")
    public Card getCard(Long userSessionId, String cardNumber, String lang) throws UserException {
        SqlMapSession ssn = null;
        List<Filter> filters;
        try {
            Card cardXP = new Card();

            SelectionParams params = new SelectionParams();
            params.setRowIndexEnd(-1);
            filters = new ArrayList<Filter>();
            filters.add(new Filter("cardNumber", cardNumber));
            filters.add(new Filter("lang", lang));
            params.setFilters(filters.toArray(new Filter[filters.size()]));
            CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
            ssn = getIbatisSession(userSessionId, null, IssuingPrivConstants.VIEW_CARDS, paramArr);
            ru.bpc.sv2.issuing.Card card = (ru.bpc.sv2.issuing.Card) ssn.queryForObject("integ.get-cards", convertQueryParams(params));
            if (card == null) {
                return null;
            }
            List<CardInstance> cardInstances = ssn.queryForList("integ.get-card-instances", card.getId());
            CardInstance cardInstance = cardInstances.get(0);

			/*cardXP.setCardNumber(card.getCardNumber());
			cardXP.setCardType(card.getCardTypeId());
			cardXP.setCategory(card.getCategory());
			GregorianCalendar cal = new GregorianCalendar();
			cal.setTime(cardInstance.getExpirDate());
			cardXP.setExpiryDate(DatatypeFactory.newInstance().newXMLGregorianCalendar(cal));

			cardXP.setStatus(cardInstance.getStatus());
			cardXP.setState(cardInstance.getState());

			cardXP.setCustomerNumber(card.getCustomerNumber());
			cardXP.setProductId(card.getProductId());
			cardXP.setProductName(card.getProductName());

			cardXP.setInstitutionId(card.getInstId());
			cardXP.setAgentId(cardInstance.getAgentId());

			cardXP.setCardholderName(cardInstance.getCardholderName());
			cal.setTime(card.getRegDate());
			cardXP.setCreationDate(DatatypeFactory.newInstance().newXMLGregorianCalendar(cal));
			cardXP.setBlankId(cardInstance.getBlankId());
			//List<Account> accounts = ssn.queryForList("integ.get-accounts", cardNumber);

			filters = new ArrayList<Filter>();
			filters.add(new Filter("entityType", EntityNames.CARD));
			filters.add(new Filter("objectId", card.getId()));
			filters.add(new Filter("lang", lang));
			params.setFilters(filters.toArray(new Filter[filters.size()]));
			List<FlexFieldData> flexParameters = ssn.queryForList("common.get-flex-fields-data", convertQueryParams(params));
			filters = new ArrayList<Filter>();
			filters.add(new Filter("entityType", EntityNames.CARDHOLDER));
			filters.add(new Filter("objectId", card.getCardholderId()));
			filters.add(new Filter("lang", lang));
			params.setFilters(filters.toArray(new Filter[filters.size()]));
			List<FlexFieldData> flexParametersCardholder = ssn.queryForList("common.get-flex-fields-data", convertQueryParams(params));
			flexParameters.addAll(flexParametersCardholder);
			FlexibleParameters parameters = formFlexibleParams(flexParameters);
			cardXP.setParameters(parameters);

			JAXBContext jc = JAXBContext.newInstance("ru.bpc.svxp");
			Unmarshaller unmarshaller = jc.createUnmarshaller();

			ServiceTerms serviceTerms = getServiceTerms(ssn, unmarshaller, EntityNames.CARD, card.getId());
			cardXP.setServiceTerms(serviceTerms);
			*/
            filters = new ArrayList<Filter>();
            filters.add(new Filter("entityType", EntityNames.CARD));
            filters.add(new Filter("objectId", card.getId()));
            filters.add(new Filter("lang", lang));
            params.setFilters(filters.toArray(new Filter[filters.size()]));
            List<ru.bpc.sv2.accounts.Account> accounts = ssn.queryForList("integ.get-object-accounts", convertQueryParams(params));
            Accounts accountsXP = new Accounts();
            for (ru.bpc.sv2.accounts.Account account : accounts) {
                Account accountXP = new Account();
                accountXP.setAccountNumber(account.getAccountNumber());
                //accountXP.setAccountStatus(account.getStatus());
                accountXP.setAccountType(account.getAccountType());
                accountXP.setCurrency(account.getCurrency());
                Balance avalBal = new Balance();
                avalBal.setBalanceType("AMPR0011");
                avalBal.setCurrency(account.getCurrency());
                avalBal.setAmount(account.getBalance());
                //accountXP.getBalance().add(avalBal);

                ru.bpc.sv2.accounts.Balance balanceFilter = new ru.bpc.sv2.accounts.Balance();
                balanceFilter.setAccountId(account.getId());
                balanceFilter.setBalanceType("BLTP0002");
                List<ru.bpc.sv2.accounts.Balance> balances = ssn.queryForList("integ.get-balances", balanceFilter);
                for (ru.bpc.sv2.accounts.Balance bal : balances) {
                    Balance balance = new Balance();
                    balance.setAmount(bal.getBalance());
                    balance.setBalanceType(bal.getBalanceType());
                    balance.setCurrency(bal.getCurrency());
                    //accountXP.getBalance().add(balance);
                }
                filters = new ArrayList<Filter>();
                filters.add(new Filter("entityType", EntityNames.ACCOUNT));
                filters.add(new Filter("objectId", account.getId()));
                filters.add(new Filter("lang", lang));
                params.setFilters(filters.toArray(new Filter[filters.size()]));
                //flexParameters = ssn.queryForList("common.get-flex-fields-data", convertQueryParams(params));
                //parameters = formFlexibleParams(flexParameters);
                //accountXP.setParameters(parameters);

                //serviceTerms = getServiceTerms(ssn, unmarshaller, EntityNames.ACCOUNT, account.getId());
                //accountXP.setServiceTerms(serviceTerms);

                accountsXP.getAccount().add(accountXP);
            }
            //cardXP.setAccounts(accountsXP);
            return cardXP;
        } catch (SQLException e) {
            if (e.getErrorCode() >= 20000 && e.getErrorCode() <= 20999) {
                throw new UserException(e.getCause().getMessage());
            } else {
                throw createDaoException(e);
            }
        } catch (Exception e) {
            throw new DataAccessException(e);
        } finally {
            close(ssn);
        }
    }

    private ServiceTerms getServiceTerms(SqlMapSession ssn, Unmarshaller unmarshaller, String entityType, Long objectId)
            throws Exception {
        Map<String, Object> map = new HashMap<String, Object>();
        map.put("entityType", entityType);
        map.put("objectId", objectId);
        ssn.update("common.get-service-terms", map);
        String serviceTermsXml = (String) map.get("serviceTerms");
        serviceTermsXml = serviceTermsXml.replaceAll("<service_terms>", "<service_terms xmlns:=\"http://bpc.ru/SVXP\">");
        DocumentBuilderFactory dbf = DocumentBuilderFactory.newInstance();
        dbf.setNamespaceAware(true);
        DocumentBuilder db = dbf.newDocumentBuilder();
        Document doc = db.parse(new ByteArrayInputStream(serviceTermsXml.getBytes()));
        Node fooSubtree = doc.getFirstChild();
        JAXBElement<ServiceTerms> jaxbElement = unmarshaller
                .unmarshal(fooSubtree, ServiceTerms.class);
        return jaxbElement.getValue();
    }

    private FlexibleParameters formFlexibleParams(List<FlexFieldData> flexParameters) throws Exception {
        if (flexParameters == null || flexParameters.isEmpty()) {
            return null;
        }
        GregorianCalendar cal = new GregorianCalendar();
        FlexibleParameters params = new FlexibleParameters();
        for (FlexFieldData flexFieldData : flexParameters) {
            FlexibleParameter flexParam = new FlexibleParameter();
            flexParam.setName(flexFieldData.getSystemName());
            flexParam.setValueChar(flexFieldData.getValueV());
            flexParam.setValueNumber(flexFieldData.getValueN());
            flexParam.setDataType(DataType.valueOf(flexFieldData.getDataType()));
            if (flexFieldData.getValueD() != null) {
                cal.setTime(flexFieldData.getValueD());
                flexParam.setValueDate(DatatypeFactory.newInstance().newXMLGregorianCalendar(cal));
            }
            params.getFlexibleParameter().add(flexParam);
        }
        return params;
    }

    @SuppressWarnings ("unchecked")

    public List<Card> getCards(Long userSessionId, final Map<String, Object> map) throws UserException {
        return executeWithSession(userSessionId, logger, new IbatisSessionCallback<List<Card>>() {
	        @Override
            public List<Card> doInSession(SqlMapSession ssn) throws Exception {
                ssn.update("integ.get-card-cursor", map);
                return (List<Card>) map.get("ref_cursor");
            }
        });
    }

    public String getPINblock(Long userSessionId, GeneratePinBlockRequest pinRequest) throws UserException {
        SqlMapSession ssn = null;
        try {
            Map<String, Object> map = new HashMap<String, Object>();
            map.put("cardNumber", pinRequest.getCardNumber());
            map.put("pin", pinRequest.getPin());
            map.put("key", pinRequest.getKey());
            map.put("format", pinRequest.getFormat());
            ssn = getIbatisSession(userSessionId);
            ssn.update("integ.get-pinblock", map);
            return (String) map.get("pinBlock");
        } catch (SQLException e) {
            if (e.getErrorCode() >= 20000 && e.getErrorCode() <= 20999) {
                throw new UserException(e.getCause().getMessage());
            } else {
                throw createDaoException(e);
            }
        } catch (Exception e) {
            if (e.getCause() == null) {
                throw new DataAccessException(e.getMessage());
            } else {
                throw createDaoException(e);
            }
        } finally {
            close(ssn);
        }
    }

    @SuppressWarnings ("unchecked")

    public CreditInvoice getInvoice(Long userSessionId, Map<String, Object> map) throws UserException {
        SqlMapSession ssn = null;
        try {
            ssn = getIbatisSessionNoContext();
            ssn.update("integ.get-invoice-data", map);
            ArrayList<CreditInvoice> result = (ArrayList<CreditInvoice>) map.get("ref_cursor");
            if (result.size() > 0) {
                return result.get(0);
            } else {
                return null;
            }
        } catch (SQLException e) {
            if (e.getErrorCode() >= 20000 && e.getErrorCode() <= 20999) {
                String result = null;
                try {
                    result = (String) ssn.queryForObject("common.get-last-error");
                } catch (SQLException ignored) {}
                throw new UserException(e.getCause().getMessage(), result, null);
            } else {
                throw createDaoException(e);
            }
        } catch (Exception e) {
            if (e.getCause() == null) {
                throw new DataAccessException(e.getMessage());
            } else {
                throw createDaoException(e);
            }
        } finally {
            close(ssn);
        }
    }

    public String getAccountNumber(Long userSessionId, Long customerId, String accountType) throws UserException {
        SqlMapSession ssn = null;
        try {
            Map<String, Object> map = new HashMap<String, Object>();
            map.put("customerId", customerId);
            map.put("accountType", accountType);
            CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(map);
            ssn = getIbatisSession(userSessionId, null, AccountPrivConstants.VIEW_ACCOUNT, paramArr);
            ssn.update("integ.get-account", map);
            return (String) map.get("accountNumber");
        } catch (SQLException e) {
            if (e.getErrorCode() >= 20000 && e.getErrorCode() <= 20999) {
                String result = null;
                try {
                    result = (String) ssn.queryForObject("common.get-last-error");
                } catch (SQLException ignored) {}
                throw new UserException(e.getCause().getMessage(), result, null);
            } else {
                throw createDaoException(e);
            }
        } catch (Exception e) {
            if (e.getCause() == null) {
                throw new DataAccessException(e.getMessage());
            } else {
                throw createDaoException(e);
            }
        } finally {
            close(ssn);
        }
    }

    public Long getCustomer(Long userSessionId, String entityType, String entityNumber) throws UserException {
        SqlMapSession ssn = null;
        Long customerId = null;
        try {
            Map<String, Object> params = new HashMap<String, Object>();
            params.put("entityNumber", entityNumber);
            CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params);
            ssn = getIbatisSession(userSessionId, null, ProductPrivConstants.VIEW_CUSTOMERS, paramArr);
            if (EntityNames.CARD.equals(entityType)) {
                customerId = (Long) ssn.queryForObject("integ.get-customer-id-by-card", entityNumber);
            } else if (EntityNames.ACCOUNT.equals(entityType)) {
                customerId = (Long) ssn.queryForObject("integ.get-customer-id-by-account", entityNumber);
            }

            return customerId;
        } catch (SQLException e) {
            if (e.getErrorCode() >= 20000 && e.getErrorCode() <= 20999) {
                String result = null;
                try {
                    result = (String) ssn.queryForObject("common.get-last-error");
                } catch (SQLException ignored) {}
                throw new UserException(e.getCause().getMessage(), result, null);
            } else {
                throw createDaoException(e);
            }
        } catch (Exception e) {
            if (e.getCause() == null) {
                throw new DataAccessException(e.getMessage());
            } else {
                throw createDaoException(e);
            }
        } finally {
            close(ssn);
        }
    }

    public Map<String, Object> getMilleniumInvoice(Long userSessionId, String accountNumber) throws UserException {
        SqlMapSession ssn = null;
        try {
            Map<String, Object> params = new HashMap<String, Object>();
            params.put("accountNumber", accountNumber);
            CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params);
            ssn = getIbatisSession(userSessionId, null, CreditPrivConstants.VIEW_CREDIT_INVOICE, paramArr);
            Long accountId = (Long) ssn.queryForObject("integ.get-account-id", accountNumber);
            if (accountId == null) {
                throw new UserException("ACCOUNT_NOT_FOUND");
            }
            Map<String, Object> map = new HashMap<String, Object>();
            map.put("accountId", accountId);
            ssn.update("integ.get-millenium-invoice-data", map);
            return map;
        } catch (SQLException e) {
            if (e.getErrorCode() >= 20000 && e.getErrorCode() <= 20999) {
                String result = null;
                try {
                    result = (String) ssn.queryForObject("common.get-last-error");
                } catch (SQLException ignored) {}
                throw new UserException(e.getCause().getMessage(), result, null);
            } else {
                throw createDaoException(e);
            }
        } catch (Exception e) {
            if (e.getCause() == null) {
                throw new DataAccessException(e.getMessage());
            } else {
                throw createDaoException(e);
            }
        } finally {
            close(ssn);
        }
    }

    @SuppressWarnings ("unchecked")

    public Account getAccount(Long userSessionId,
                              String accountNumber, String lang) throws UserException {
        ru.bpc.sv2.accounts.Account acc;
        Account accSpx = new Account();
        SqlMapSession ssn = null;
        List<Filter> filters;

        SelectionParams params = new SelectionParams();
        params.setRowIndexEnd(-1);
        filters = new ArrayList<Filter>();
        filters.add(new Filter("accountNumber", accountNumber));
        //filters.add(new Filter("lang", lang));
        params.setFilters(filters.toArray(new Filter[filters.size()]));
        CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
        try {
            //ssn = getIbatisSession(userSessionId, null, null, AccountPrivConstants.VIEW_ACCOUNT, paramArr);
            ssn = getIbatisSessionNoContext();
            acc = (ru.bpc.sv2.accounts.Account) ssn.queryForObject("integ.get-accounts", convertQueryParams(params));
            if (acc != null) {
                accSpx.setAccountNumber(acc.getAccountNumber());
                //accSpx.setAccountStatus(acc.getStatus());
                accSpx.setAccountType(acc.getAccountType());
                accSpx.setCurrency(acc.getCurrency());
                Balance avalBal = new Balance();
                avalBal.setBalanceType("AMPR0011");
                avalBal.setCurrency(acc.getCurrency());
                avalBal.setAmount(acc.getBalance());
                //accSpx.getBalance().add(avalBal);

                ru.bpc.sv2.accounts.Balance balanceFilter = new ru.bpc.sv2.accounts.Balance();
                balanceFilter.setAccountId(acc.getId());
                balanceFilter.setBalanceType("BLTP0002");
                List<ru.bpc.sv2.accounts.Balance> balances = ssn.queryForList("common.get-balances", balanceFilter);
                for (ru.bpc.sv2.accounts.Balance bal : balances) {
                    Balance balance = new Balance();
                    balance.setAmount(bal.getBalance());
                    balance.setBalanceType(bal.getBalanceType());
                    balance.setCurrency(bal.getCurrency());
                    //accSpx.getBalance().add(balance);
                }
                filters = new ArrayList<Filter>();
                filters.add(new Filter("entityType", EntityNames.ACCOUNT));
                filters.add(new Filter("objectId", acc.getId()));
                filters.add(new Filter("lang", lang));
                params.setFilters(filters.toArray(new Filter[filters.size()]));
                List<FlexFieldData> flexParameters;
                flexParameters = ssn.queryForList("common.get-flex-fields-data", convertQueryParams(params));
                FlexibleParameters parameters;
                parameters = formFlexibleParams(flexParameters);
                //accSpx.setParameters(parameters);
                JAXBContext jc = JAXBContext.newInstance("ru.bpc.svxp");
                Unmarshaller unmarshaller = jc.createUnmarshaller();
                ServiceTerms serviceTerms;
                serviceTerms = getServiceTerms(ssn, unmarshaller, EntityNames.ACCOUNT, acc.getId());
                //accSpx.setServiceTerms(serviceTerms);
            }
        } catch (SQLException e) {
            if (e.getErrorCode() >= 20000 && e.getErrorCode() <= 20999) {
                throw new UserException(e.getCause().getMessage());
            } else {
                throw createDaoException(e);
            }
        } catch (Exception e) {
            throw new DataAccessException(e);
        } finally {
            close(ssn);
        }
        return accSpx;
    }

    @SuppressWarnings ("unchecked")

    public ru.bpc.svxp.Customer getCustomerSpx(Long userSessionId, SelectionParams params, String lang) throws UserException {
        SqlMapSession ssn;
        ru.bpc.svxp.Customer customerSpx = new ru.bpc.svxp.Customer();
        try {
            ssn = getIbatisSessionNoContext();
            Long customerId = (Long) ssn.queryForObject("common.get-customer-id", convertQueryParams(params));
            List<Filter> filters = new ArrayList<Filter>();
            filters.add(new Filter("customerId", customerId));
            //filters.add(new Filter("lang", lang));
            params.setRowIndexEnd(-1);
            params.setFilters(filters.toArray(new Filter[filters.size()]));
            Customer customer = (Customer) ssn.queryForObject(
                    "common.get-customer", convertQueryParams(params));
            filters = new ArrayList<Filter>();
            filters.add(new Filter("customerId", customer.getId()));
            filters.add(new Filter("lang", lang));
            params.setFilters(filters.toArray(new Filter[filters.size()]));
            Person person = (Person) ssn.queryForObject(
                    "common.get-customer-person", convertQueryParams(params));
            filters = new ArrayList<Filter>();
            filters.add(new Filter("objectId", customer.getObjectId()));
            filters.add(new Filter("lang", lang));
            params.setFilters(filters.toArray(new Filter[filters.size()]));
            List<Company> companies = ssn.queryForList("common.get-customer-company",
                                                       convertQueryParams(params));
            filters = new ArrayList<Filter>();
            filters.add(new Filter("entityType", "ENTTCUST"));
            filters.add(new Filter("objectId", customer.getId()));
            filters.add(new Filter("lang", lang));
            params.setFilters(filters.toArray(new Filter[filters.size()]));
            //Address []addresses = getAddresses(userSessionId, params);
            //Contact []contacts = getContacts(userSessionId, params);
            filters = new ArrayList<Filter>();
            filters.add(new Filter("entityType", "ENTTPERS"));
            filters.add(new Filter("objectId", customer.getObjectId()));
            filters.add(new Filter("lang", lang));
            params.setFilters(filters.toArray(new Filter[filters.size()]));
            //CustomerDocument []documents = getCustomerDocuments(userSessionId, params);

            customerSpx.setId(customer.getId());
            customerSpx.setCustomerNumber(customer.getCustomerNumber());
            customerSpx.setCustomerName(customer.getCustomerName());
            customerSpx.setEntityType(customer.getEntityType());
            customerSpx.setInstId(customer.getInstId());
            customerSpx.setInstName(customer.getInstName());
            customerSpx.setStatus(customer.getStatus());
            customerSpx.setNationality(customer.getNationality());
            ru.bpc.svxp.Person personSpx = new ru.bpc.svxp.Person();
            if (person != null) {
                personSpx.setFirstName(person.getFirstName());
                personSpx.setGender(person.getGender());
                personSpx.setPersonId(person.getPersonId());
                personSpx.setSecondName(person.getSecondName());
                personSpx.setSuffix(person.getSuffix());
                personSpx.setSurname(person.getSurname());
                personSpx.setTitle(person.getTitle());
                GregorianCalendar cal = new GregorianCalendar();
                if (person.getBirthday() != null) {
                    cal.setTime(person.getBirthday());
                    personSpx.setBirthday(
                            DatatypeFactory.newInstance().newXMLGregorianCalendar(cal));
                }
                customerSpx.setPerson(personSpx);
            }
            for (Company company : companies) {
                ru.bpc.svxp.Company companySpx = new ru.bpc.svxp.Company();
                companySpx.setDescription(company.getDescription());
                companySpx.setEmbossedName(company.getEmbossedName());
                companySpx.setLabel(company.getLabel());
                companySpx.setId(company.getId());
                customerSpx.getCompany().add(companySpx);
            }
			/*for (Address add: addresses){
				customerSpx.getAddress().add(add);
			}*/
			/*for (Contact contact:contacts){
				customerSpx.getContact().add(contact);
			}*/
			/*for (CustomerDocument document: documents){
				customerSpx.getDocument().add(document);
			}*/

        } catch (SQLException e) {
            if (e.getErrorCode() >= 20000 && e.getErrorCode() <= 20999) {
                throw new UserException(e.getCause().getMessage());
            } else {
                throw createDaoException(e);
            }
        } catch (DatatypeConfigurationException e) {
            throw createDaoException(e);
        }

        return customerSpx;
    }

    @SuppressWarnings ("unchecked")

    public Account[] getAccounts(Long userSessionId, Map<String, Object> map) throws UserException {
        SqlMapSession ssn = null;
        //CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
        List<Account> accounts = new ArrayList<Account>();
        try {
            //ssn = getIbatisSession(userSessionId, null, null,
            //		AccountPrivConstants.VIEW_ACCOUNT, paramArr);
            ssn = getIbatisSessionNoContext();
            ssn.queryForList("integ.get-accounts-cursor", map);

            List<ru.bpc.sv2.accounts.Account> accountsSpx;
            accountsSpx = (List<ru.bpc.sv2.accounts.Account>) map.get("ref_cursor");
            for (ru.bpc.sv2.accounts.Account acc : accountsSpx) {
                Account account = new Account();
                account.setAccountNumber(acc.getAccountNumber());
                account.setAccountType(acc.getAccountType());
                account.setAccountTypeName(acc.getAccountTypeName());
                account.setAgentId(acc.getAgentId());
                account.setAgentName(acc.getAgentName());
                account.setAvalBalance(acc.getAvalBalance());
                GregorianCalendar cal = new GregorianCalendar();
                if (acc.getCloseDate() != null) {
                    cal.setTime(acc.getCloseDate());
                    account.setCloseDate(DatatypeFactory.newInstance().
                            newXMLGregorianCalendar(cal));
                } else {
                    account.setCloseDate(null);
                }
                account.setCurrency(acc.getCurrency());
                account.setCurrencyName(acc.getCurrencyName());
                account.setHoldBalance(acc.getHoldBalance());
                account.setAccountId(acc.getId());
                if (map.get("balance_type") != null &&
                        ((String) map.get("balance_type")).trim().length() > 0) {
                    account.setRequestBalance(acc.getBalance());
                } else {
                    account.setRequestBalance(null);
                }
                cal.setTime(acc.getOpenDate());
                account.setOpenDate(DatatypeFactory.newInstance().
                        newXMLGregorianCalendar(cal));
                account.setOwnerName(acc.getOwnerName());
                account.setStatus(acc.getStatus());
                account.setStatusName(acc.getStatusName());
                accounts.add(account);
            }

        } catch (SQLException e) {
            if (e.getErrorCode() >= 20000 && e.getErrorCode() <= 20999) {
                throw new UserException(e.getCause().getMessage());
            } else {
                throw createDaoException(e);
            }
        } catch (Exception e) {
            throw new DataAccessException(e);
        } finally {
            close(ssn);
        }
        return accounts.toArray(new Account[accounts.size()]);
    }

    @SuppressWarnings ("unchecked")

    public Address[] getAddresses(Long userSessionId, Map<String, Object> map)
            throws UserException {
        SqlMapSession ssn = null;
        List<Address> addresses;
        try {
            ssn = getIbatisSessionNoContext();
            ssn.queryForList("integ.get-address-cursor", map);
            addresses = (List<Address>) map.get("ref_cursor");

        } catch (SQLException e) {
            if (e.getErrorCode() >= 20000 && e.getErrorCode() <= 20999) {
                String result = null;
                try {
                    result = (String) ssn.queryForObject("common.get-last-error");
                } catch (SQLException ignored) {}
                throw new UserException(e.getCause().getMessage(), result, null);
            } else {
                throw createDaoException(e);
            }
        } catch (Exception e) {
            if (e.getCause() == null) {
                throw new DataAccessException(e.getMessage());
            } else {
                throw createDaoException(e);
            }
        } finally {
            close(ssn);
        }
        return addresses.toArray(new Address[addresses.size()]);
    }

    @SuppressWarnings ("unchecked")

    public Contact[] getContacts(Long userSessionId, Map<String, Object> map)
            throws UserException {
        SqlMapSession ssn = null;
        List<Contact> contacts;
        try {
            //ssn = getIbatisSession(userSessionId, null,
            //		null, CommonPrivConstants.VIEW_CONTACT, paramArr);
            ssn = getIbatisSessionNoContext();
            ssn.queryForList("integ.get-contact-cursor", map);
            contacts = (List<Contact>) map.get("ref_cursor");
        } catch (SQLException e) {
            if (e.getErrorCode() >= 20000 && e.getErrorCode() <= 20999) {
                String result = null;
                try {
                    result = (String) ssn.queryForObject("common.get-last-error");
                } catch (SQLException ignored) {}
                throw new UserException(e.getCause().getMessage(), result, null);
            } else {
                throw createDaoException(e);
            }
        } catch (Exception e) {
            if (e.getCause() == null) {
                throw new DataAccessException(e.getMessage());
            } else {
                throw createDaoException(e);
            }
        } finally {
            close(ssn);
        }
        return contacts.toArray(new Contact[contacts.size()]);
    }

    @SuppressWarnings ("unchecked")

    public CustomerDocument[] getCustomerDocuments(Long userSessionId,
                                                   Map<String, Object> map) throws UserException {
        SqlMapSession ssn = null;
        List<CustomerDocument> documentsSpx = new ArrayList<CustomerDocument>();
        try {
            //ssn = getIbatisSession(userSessionId, null, null, CommonPrivConstants.VIEW_CONTACT, paramArr);
            ssn = getIbatisSessionNoContext();
            ssn.queryForList("integ.get-document-cursor", map);
            List<PersonId> documents = (List<PersonId>) map.get("ref_cursor");
            for (PersonId doc : documents) {
                CustomerDocument cusDoc = new CustomerDocument();
                cusDoc.setComments(doc.getDescription());
                cusDoc.setIdIssuer(doc.getIdIssuer());
                cusDoc.setIdNumber(doc.getIdNumber());
                cusDoc.setIdSeries(doc.getIdSeries());
                cusDoc.setIdType(doc.getIdType());
                cusDoc.setIdTypeName(doc.getIdTypeName());
                GregorianCalendar cal = new GregorianCalendar();
                if (doc.getExpireDate() != null) {
                    cal.setTime(doc.getExpireDate());
                    cusDoc.setIdExpireDate(DatatypeFactory.newInstance().
                            newXMLGregorianCalendar(cal));
                } else {
                    cusDoc.setIdExpireDate(null);
                }
                if (doc.getIssueDate() != null) {
                    cal.setTime(doc.getIssueDate());
                    cusDoc.setIdIssueDate(DatatypeFactory.newInstance().
                            newXMLGregorianCalendar(cal));
                } else {
                    cusDoc.setIdIssueDate(null);
                }
                cusDoc.setIdCountry(doc.getIdCountry());
                documentsSpx.add(cusDoc);
            }

        } catch (SQLException e) {
            if (e.getErrorCode() >= 20000 && e.getErrorCode() <= 20999) {
                String result = null;
                try {
                    result = (String) ssn.queryForObject("common.get-last-error");
                } catch (SQLException ignored) {}
                throw new UserException(e.getCause().getMessage(), result, null);
            } else {
                throw createDaoException(e);
            }
        } catch (Exception e) {
            if (e.getCause() == null) {
                throw new DataAccessException(e.getMessage());
            } else {
                throw createDaoException(e);
            }
        } finally {
            close(ssn);
        }
        return documentsSpx.toArray(new CustomerDocument[documentsSpx.size()]);
    }

    @SuppressWarnings ("unchecked")

    public ru.bpc.svxp.FlexField[] getFlexField(Long userSessionId, Map<String, Object> map)
            throws UserException {
        SqlMapSession ssn = null;
        List<ru.bpc.svxp.FlexField> flexFieldsSpx = new ArrayList<ru.bpc.svxp.FlexField>();
        try {
            ssn = getIbatisSessionNoContext();
            List<FlexFieldData> flexParameters;
            ssn.update("integ.get-flex-fields-data", map);
            flexParameters = (List<FlexFieldData>) map.get("ref_cursor");
            for (FlexFieldData flexField : flexParameters) {
                ru.bpc.svxp.FlexField flexFieldSpx = new ru.bpc.svxp.FlexField();
                flexFieldSpx.setDefaultCharValue(flexField.getDefaultCharValue());
                GregorianCalendar cal = new GregorianCalendar();
                if (flexField.getDefaultDateValue() != null) {
                    cal.setTime(flexField.getDefaultDateValue());
                    flexFieldSpx.setDefaultDateValue(DatatypeFactory.newInstance().newXMLGregorianCalendar(cal));
                } else {
                    flexFieldSpx.setDefaultDateValue(null);
                }
                flexFieldSpx.setDefaultLovValue(flexField.getDefaultLovValue());
                flexFieldSpx.setDefaultNumberValue(flexField.getDefaultNumberValue());
                flexFieldSpx.setEntityType(flexField.getEntityType());
                if (flexField.getId() != null) {
                    flexFieldSpx.setId(flexField.getId());
                }
                flexFieldSpx.setInstId(flexField.getInstId());
                flexFieldSpx.setInstName(flexField.getInstName());
                flexFieldSpx.setObjectType(flexField.getObjectType());
                flexFieldSpx.setUserDefined(flexField.isUserDefined());
                flexFieldsSpx.add(flexFieldSpx);
            }
        } catch (SQLException e) {
            if (e.getErrorCode() >= 20000 && e.getErrorCode() <= 20999) {
                String result = null;
                try {
                    result = (String) ssn.queryForObject("common.get-last-error");
                } catch (SQLException ignored) {}
                throw new UserException(e.getCause().getMessage(), result, null);
            } else {
                throw createDaoException(e);
            }
        } catch (Exception e) {
            if (e.getCause() == null) {
                throw new DataAccessException(e.getMessage());
            } else {
                throw createDaoException(e);
            }
        } finally {
            close(ssn);
        }
        return flexFieldsSpx.toArray(new ru.bpc.svxp.FlexField[flexFieldsSpx.size()]);
    }

    @SuppressWarnings ("unchecked")

    public Statement getStatement(Long userSessionId, Map<String, Object> map) throws UserException {
        SqlMapSession ssn = null;
        try {
            ssn = getIbatisSessionNoContext();
            ssn.update("integ.get-credit-statement", map);

            String xml = (String) map.get("xml");
            System.out.println("statement: " + xml);
            xml = xml.replaceFirst("<report>", "<report xmlns:=\"http://bpc.ru/SVXP\">");

            DocumentBuilderFactory dbf = DocumentBuilderFactory.newInstance();
            dbf.setNamespaceAware(true);
            DocumentBuilder db = dbf.newDocumentBuilder();
            Document doc = db.parse(new ByteArrayInputStream(xml.getBytes("UTF-8")));

            JAXBContext context = JAXBContext.newInstance("ru.bpc.svxp");
            Unmarshaller unmarshaller = context.createUnmarshaller();
            JAXBElement<Statement> jaxbElement = (JAXBElement<Statement>) unmarshaller.unmarshal(doc);

            return jaxbElement.getValue();
        } catch (SQLException e) {
            if (e.getErrorCode() >= 20000 && e.getErrorCode() <= 20999) {
                String result = null;
                try {
                    result = (String) ssn.queryForObject("common.get-last-error");
                } catch (SQLException ignored) {}
                throw new UserException(e.getCause().getMessage(), result, null);
            } else {
                throw createDaoException(e);
            }
        } catch (Exception e) {
            if (e.getCause() == null) {
                throw new DataAccessException(e.getMessage());
            } else {
                throw createDaoException(e);
            }
        } finally {
            close(ssn);
        }
    }


    public AccountPaymentDetails getAccountPaymentDetails(Long userSessionId,
                                                          Map<String, Object> map) throws UserException {
        SqlMapSession ssn = null;
        AccountPaymentDetails acc = new AccountPaymentDetails();
        try {
            ssn = getIbatisSessionNoContext();
            ssn.queryForObject("integ.get-account-payment-details", map);
            acc.setAccountNumber((String) map.get("accountNumber"));
            acc.setBankAddress((String) map.get("bankAddress"));
            acc.setBankName((String) map.get("bankName"));
            acc.setBic((String) map.get("bic"));
            acc.setCorrAccount((String) map.get("corrAccount"));
            acc.setRecipientName((String) map.get("recipientName"));
            acc.setTin((String) map.get("tin"));
        } catch (SQLException e) {
            if (e.getErrorCode() >= 20000 && e.getErrorCode() <= 20999) {
                String result = null;
                try {
                    result = (String) ssn.queryForObject("common.get-last-error");
                } catch (SQLException ignored) {}
                throw new UserException(e.getCause().getMessage(), result, null);
            } else {
                throw createDaoException(e);
            }
        } catch (Exception e) {
            if (e.getCause() == null) {
                throw new DataAccessException(e.getMessage());
            } else {
                throw createDaoException(e);
            }
        } finally {
            close(ssn);
        }
        return acc;
    }


    public BigDecimal getRateForInst(Long userSessionId, Map<String, Object> map)
            throws UserException {
        SqlMapSession ssn = null;
        BigDecimal rate;
        try {
            ssn = getIbatisSessionNoContext();
            ssn.queryForObject("integ.get-rate", map);
            rate = (BigDecimal) map.get("rate");
        } catch (SQLException e) {
            if (e.getErrorCode() >= 20000 && e.getErrorCode() <= 20999) {
                String result = null;
                try {
                    result = (String) ssn.queryForObject("common.get-last-error");
                } catch (SQLException ignored) {}
                throw new UserException(e.getCause().getMessage(), result, null);
            } else {
                throw createDaoException(e);
            }
        } catch (Exception e) {
            if (e.getCause() == null) {
                throw new DataAccessException(e.getMessage());
            } else {
                throw createDaoException(e);
            }
        } finally {
            close(ssn);
        }
        return rate;
    }

    @SuppressWarnings ("unchecked")

    public CardDetails getCardDetails(Long userSessionId, Map<String, Object> map) throws UserException {
        SqlMapSession ssn = null;
        CardDetails cd = null;
        try {
            ssn = getIbatisSessionNoContext();
            ssn.update("integ.get-card-details", map);
            ArrayList<CardDetails> list = (ArrayList<CardDetails>) map.get("ref_cursor");
            if (!list.isEmpty()) {
                cd = list.get(0);
            }
        } catch (SQLException e) {
            if (e.getErrorCode() >= 20000 && e.getErrorCode() <= 20999) {
                String result = null;
                try {
                    result = (String) ssn.queryForObject("common.get-last-error");
                } catch (SQLException ignored) {}
                throw new UserException(e.getCause().getMessage(), result, null);
            } else {
                throw createDaoException(e);
            }
        } catch (Exception e) {
            if (e.getCause() == null) {
                throw new DataAccessException(e.getMessage());
            } else {
                throw createDaoException(e);
            }
        } finally {
            close(ssn);
        }
        if (cd != null && cd.getPersonName() == null) {
            cd.setPersonName(" ");
        }
        return cd;
    }


    public CustomerDetails getCustomerDetails(Long userSessionId,
                                              Map<String, Object> map) throws UserException {
        CustomerDetails customerDetails = new CustomerDetails();
        SqlMapSession ssn = null;
        try {
            ssn = getIbatisSessionNoContext();
            ssn.update("integ.get-customer-details", map);
            if (map.get("birthday") != null) {
                GregorianCalendar cal = new GregorianCalendar();
                cal.setTime((Date) map.get("birthday"));
                customerDetails.setBirthday(DatatypeFactory.
                        newInstance().newXMLGregorianCalendar(cal));
            } else {
                customerDetails.setBirthday(null);
            }
            customerDetails.setCategory((String) map.get("category"));
            customerDetails.setCategoryName(
                    (String) map.get("category_name"));
            customerDetails.setCountryCode(
                    (String) map.get("country_code"));
            customerDetails.setCountryName(
                    (String) map.get("country_name"));
            customerDetails.setCreditRating(
                    (String) map.get("credit_rating"));
            customerDetails.setCreditRatingName(
                    (String) map.get("credit_rating_name"));
            customerDetails.setCustomerId(((BigDecimal)
                    map.get("customer_id")).longValue());
            customerDetails.setCustomerNumber(
                    (String) map.get("customer_number"));
            customerDetails.setEntityType(
                    (String) map.get("entity_type"));
            customerDetails.setEntityTypeName(
                    (String) map.get("entity_type_name"));
            customerDetails.setFullName(
                    (String) map.get("full_name"));
            customerDetails.setGender((String) map.get("gender"));
            customerDetails.setIncorpForm(
                    (String) map.get("incorp_form"));
            customerDetails.setIncorpFormName(
                    (String) map.get("incorp_form_name"));
            customerDetails.setNationality(
                    (String) map.get("nationality"));
            customerDetails.setPlaceBirth(
                    (String) map.get("place_birth"));
            customerDetails.setRelation((String) map.get("relation"));
            customerDetails.setRelationName((String) map.get("relation_name"));
            if (map.get("resident") != null) {
                customerDetails.setResident((Boolean) map.get("resident"));
            }
            customerDetails.setSecondName(
                    (String) map.get("second_name"));
            customerDetails.setShortName(
                    (String) map.get("short_name"));
            customerDetails.setSurname(
                    (String) map.get("surname"));
            customerDetails.setMoneyLaundryRisk(
                    (String) map.get("money_laundry_risk"));
            customerDetails.setPersonTitle(
                    (String) map.get("person_title"));
            customerDetails.setPersonSuffix(
                    (String) map.get("person_suffix"));
            customerDetails.setMaritalStatus(
                    (String) map.get("marital_status"));
            if (map.get("marital_status_date") != null) {
                GregorianCalendar cal = new GregorianCalendar();
                cal.setTime((Date) map.get("marital_status_date"));
                customerDetails.setMaritalStatusDate(DatatypeFactory.
                        newInstance().newXMLGregorianCalendar(cal));
            } else {
                customerDetails.setMaritalStatusDate(null);
            }
            customerDetails.setChildrenNumber(
                    (String) map.get("children_number"));
            customerDetails.setEmploymentStatus(
                    (String) map.get("employment_status"));
            customerDetails.setEmploymentPeriod(
                    (String) map.get("employment_period"));
            customerDetails.setResidenceType(
                    (String) map.get("residence_type"));
            customerDetails.setIncomeRange(
                    (String) map.get("income_range"));
        } catch (SQLException e) {
            if (e.getErrorCode() >= 20000 && e.getErrorCode() <= 20999) {
                String result = null;
                try {
                    result = (String) ssn.queryForObject("common.get-last-error");
                } catch (SQLException ignored) {}
                throw new UserException(e.getCause().getMessage(), result, null);
            } else {
                throw createDaoException(e);
            }
        } catch (Exception e) {
            if (e.getCause() == null) {
                throw new DataAccessException(e.getMessage());
            } else {
                throw createDaoException(e);
            }
        } finally {
            close(ssn);
        }
        return customerDetails;
    }

    @SuppressWarnings ("unchecked")

    public CustomerNtfSettings[] getCustomerNtfSettings(Long userSessionId,
                                                        Map<String, Object> map) throws UserException {
        List<CustomerNtfSettings> result;
        SqlMapSession ssn = null;
        try {
            ssn = getIbatisSessionNoContext();
            ssn.update("integ.get-customer-ntf-settings-cursor", map);
            result = (ArrayList<CustomerNtfSettings>) map.get("ref_cursor");
        } catch (SQLException e) {
            if (e.getErrorCode() >= 20000 && e.getErrorCode() <= 20999) {
                String result2 = null;
                try {
                    result2 = (String) ssn.queryForObject("common.get-last-error");
                } catch (SQLException ignored) {}
                throw new UserException(e.getCause().getMessage(), result2, null);
            } else {
                throw createDaoException(e);
            }
        } catch (Exception e) {
            if (e.getCause() == null) {
                throw new DataAccessException(e.getMessage());
            } else {
                throw createDaoException(e);
            }
        } finally {
            close(ssn);
        }

        return result.toArray(new CustomerNtfSettings[result.size()]);
    }

    @SuppressWarnings ("unchecked")

    public Insts getInsts(Map<String, Object> map) throws UserException {
        Insts result = new Insts();
        SqlMapSession ssn = null;
        try {
            ssn = getIbatisSessionNoContext();
            ssn.update("integ.get-insts-list", map);
            List<Inst> instList = (ArrayList<Inst>) map.get("ref_cursor");
            result.getInst().addAll(instList);
        } catch (SQLException e) {
            if (e.getErrorCode() >= 20000 && e.getErrorCode() <= 20999) {
                String result2 = null;
                try {
                    result2 = (String) ssn.queryForObject("common.get-last-error");
                } catch (SQLException ignored) {}
                throw new UserException(e.getCause().getMessage(), result2, null);
            } else {
                throw createDaoException(e);
            }
        } catch (Exception e) {
            if (e.getCause() == null) {
                throw new DataAccessException(e.getMessage());
            } else {
                throw createDaoException(e);
            }
        } finally {
            close(ssn);
        }
        return result;
    }

    @SuppressWarnings ("unchecked")

    public Atms getAtms(Long userSessionId) throws UserException {
        Atms result = new Atms();
        SqlMapSession ssn = null;
        Map<String, Object> map = new HashMap<String, Object>();
        try {
            ssn = getIbatisSessionNoContext();
            ssn.update("integ.get-atms-list", map);
            List<Atm> atmList = (ArrayList<Atm>) map.get("ref_cursor");
            result.getAtm().addAll(atmList);
        } catch (SQLException e) {
            if (e.getErrorCode() >= 20000 && e.getErrorCode() <= 20999) {
                String result2 = null;
                try {
                    result2 = (String) ssn.queryForObject("common.get-last-error");
                } catch (SQLException ignored) {}
                throw new UserException(e.getCause().getMessage(), result2, null);
            } else {
                throw createDaoException(e);
            }
        } catch (Exception e) {
            if (e.getCause() == null) {
                throw new DataAccessException(e.getMessage());
            } else {
                throw createDaoException(e);
            }
        } finally {
            close(ssn);
        }
        return result;
    }

    @SuppressWarnings ("unchecked")

    public Transactions getAtmTrans(Map<String, Object> map) throws UserException {
        Transactions result = new Transactions();
        List<Atm> atmList = getAtms(null).getAtm();
        List<Integer> list = new ArrayList<Integer>(atmList.size());
        for (Atm anAtmList : atmList) {
            list.add(anAtmList.getTerminalId());
        }
        Integer[] mas = list.toArray(new Integer[list.size()]);
        map.put("atmIdList", mas);
        SqlMapSession ssn = null;
        try {
            ssn = getIbatisSessionNoContext();
            ssn.update("integ.get-atm-transactions", map);
            List<TransactionSvXp> transList = (List<TransactionSvXp>) map.get("ref_cursor");
            for (TransactionSvXp transSvXp : transList) {
                in.bpc.sv.svxp.Transaction trans = new in.bpc.sv.svxp.Transaction();
                trans.setAmount(transSvXp.getAmount());
                if (transSvXp.getDateTime() != null) {
                    GregorianCalendar cal = new GregorianCalendar();
                    cal.setTime(transSvXp.getDateTime());
                    trans.setDatetime(
                            DatatypeFactory.newInstance().
                                    newXMLGregorianCalendar(cal));
                } else {
                    trans.setDatetime(null);
                }
                trans.setNoteCashIn(transSvXp.getNoteCashIn());
                trans.setNoteRejected(transSvXp.getNoteRejected());
                trans.setNoteRetracted(transSvXp.getNoteRetracted());
                trans.setOperId(transSvXp.getOperId());
                trans.setOperType(transSvXp.getOperType());
                trans.setTerminalId(transSvXp.getTerminalId());

                Dispensers disps = new Dispensers();
                Dispenser disp = new Dispenser();
                if (transSvXp.getFace1() != null) {
                    disp.setCurrency(transSvXp.getCurrency1());
                    disp.setDispNumber(transSvXp.getDispNumber1());
                    disp.setFace(transSvXp.getFace1());
                    disp.setNoteDispensed(transSvXp.getNoteDispensed());
                    disp.setNoteRemained(transSvXp.getNoteRemained());
                    disps.getDispenser().add(disp);
                }
                if (transSvXp.getFace2() != null) {
                    disp = new Dispenser();
                    disp.setCurrency(transSvXp.getCurrency2());
                    disp.setDispNumber(transSvXp.getDispNumber2());
                    disp.setFace(transSvXp.getFace2());
                    disp.setNoteDispensed(transSvXp.getNoteDispensed());
                    disp.setNoteRemained(transSvXp.getNoteRemained());
                    disps.getDispenser().add(disp);
                }
                if (transSvXp.getFace3() != null) {
                    disp = new Dispenser();
                    disp.setCurrency(transSvXp.getCurrency3());
                    disp.setDispNumber(transSvXp.getDispNumber3());
                    disp.setFace(transSvXp.getFace3());
                    disp.setNoteDispensed(transSvXp.getNoteDispensed());
                    disp.setNoteRemained(transSvXp.getNoteRemained());
                    disps.getDispenser().add(disp);
                }
                if (transSvXp.getFace4() != null) {
                    disp = new Dispenser();
                    disp.setCurrency(transSvXp.getCurrency4());
                    disp.setDispNumber(transSvXp.getDispNumber4());
                    disp.setFace(transSvXp.getFace4());
                    disp.setNoteDispensed(transSvXp.getNoteDispensed());
                    disp.setNoteRemained(transSvXp.getNoteRemained());
                    disps.getDispenser().add(disp);
                }
                if (transSvXp.getFace5() != null) {
                    disp = new Dispenser();
                    disp.setCurrency(transSvXp.getCurrency5());
                    disp.setDispNumber(transSvXp.getDispNumber5());
                    disp.setFace(transSvXp.getFace5());
                    disp.setNoteDispensed(transSvXp.getNoteDispensed());
                    disp.setNoteRemained(transSvXp.getNoteRemained());
                    disps.getDispenser().add(disp);
                }
                if (transSvXp.getFace6() != null) {
                    disp = new Dispenser();
                    disp.setCurrency(transSvXp.getCurrency6());
                    disp.setDispNumber(transSvXp.getDispNumber6());
                    disp.setFace(transSvXp.getFace6());
                    disp.setNoteDispensed(transSvXp.getNoteDispensed());
                    disp.setNoteRemained(transSvXp.getNoteRemained());
                    disps.getDispenser().add(disp);
                }
                if (transSvXp.getFace7() != null) {
                    disp = new Dispenser();
                    disp.setCurrency(transSvXp.getCurrency7());
                    disp.setDispNumber(transSvXp.getDispNumber7());
                    disp.setFace(transSvXp.getFace7());
                    disp.setNoteDispensed(transSvXp.getNoteDispensed());
                    disp.setNoteRemained(transSvXp.getNoteRemained());
                    disps.getDispenser().add(disp);
                }
                if (transSvXp.getFace8() != null) {
                    disp = new Dispenser();
                    disp.setCurrency(transSvXp.getCurrency8());
                    disp.setDispNumber(transSvXp.getDispNumber8());
                    disp.setFace(transSvXp.getFace8());
                    disp.setNoteDispensed(transSvXp.getNoteDispensed());
                    disp.setNoteRemained(transSvXp.getNoteRemained());
                    disps.getDispenser().add(disp);
                }
                trans.setDispensers(disps);

                result.getTransaction().add(trans);
            }

        } catch (SQLException e) {
            if (e.getErrorCode() >= 20000 && e.getErrorCode() <= 20999) {
                String result2 = null;
                try {
                    result2 = (String) ssn.queryForObject("common.get-last-error");
                } catch (SQLException ignored) {}
                throw new UserException(e.getCause().getMessage(), result2, null);
            } else {
                throw createDaoException(e);
            }
        } catch (Exception e) {
            if (e.getCause() == null) {
                throw new DataAccessException(e.getMessage());
            } else {
                throw createDaoException(e);
            }
        } finally {
            close(ssn);
        }
        return result;
    }

    @SuppressWarnings ("unchecked")

    public Downtimes getAtmDowntimes(Map<String, Object> map)
            throws UserException {
        Downtimes result = new Downtimes();
        List<Atm> atmList = getAtms(null).getAtm();
        SqlMapSession ssn = null;
        try {
            ssn = getIbatisSessionNoContext();
            for (Atm atm : atmList) {
                map.put("terminal_id", atm.getTerminalId());
                ssn.update("integ.get-atm-downtimes", map);
                List<ru.bpc.sv2.accounts.Downtime> downtimeList =
                        (List<ru.bpc.sv2.accounts.Downtime>) map.get("ref_cursor");
                for (ru.bpc.sv2.accounts.Downtime downtime : downtimeList) {
                    Downtime _downtime = new Downtime();
                    _downtime.setDowntimeType(downtime.getDowntimeType());
                    _downtime.setTerminalId(downtime.getDowntimeType());
                    GregorianCalendar cal = new GregorianCalendar();
                    if (downtime.getDateFrom() != null) {
                        cal.setTime(downtime.getDateFrom());
                        _downtime.setDateform(
                                DatatypeFactory.newInstance().
                                        newXMLGregorianCalendar(cal));
                    } else {
                        _downtime.setDateform(null);
                    }

                    if (downtime.getDateTo() != null) {
                        cal.setTime(downtime.getDateTo());
                        _downtime.setDateto(
                                DatatypeFactory.newInstance().
                                        newXMLGregorianCalendar(cal));
                    } else {
                        _downtime.setDateto(null);
                    }
                    result.getDowntime().add(_downtime);
                }
            }
        } catch (SQLException e) {
            if (e.getErrorCode() >= 20000 && e.getErrorCode() <= 20999) {
                String result2 = null;
                try {
                    result2 = (String) ssn.queryForObject("common.get-last-error");
                } catch (SQLException ignored) {}
                throw new UserException(e.getCause().getMessage(), result2, null);
            } else {
                throw createDaoException(e);
            }
        } catch (Exception e) {
            if (e.getCause() == null) {
                throw new DataAccessException(e.getMessage());
            } else {
                throw createDaoException(e);
            }
        } finally {
            close(ssn);
        }
        return result;
    }

    @SuppressWarnings ("unchecked")

    public CurrencyRates getCurrencyRates(Map<String, Object> map)
            throws UserException {
        CurrencyRates result = new CurrencyRates();
        SqlMapSession ssn = null;
        try {
            ssn = getIbatisSessionNoContext();
            ssn.update("integ.get-currency-rates", map);
            List<RateSvXp> currencyRateList = (List<RateSvXp>) map.get("ref_cursor");
            for (RateSvXp rateSvXp : currencyRateList) {
                CurrencyRate rate = new CurrencyRate();
                rate.setDstCurrency(rateSvXp.getDstCurrency());
                GregorianCalendar cal = new GregorianCalendar();
                if (rateSvXp.getEffectiveDate() != null) {
                    cal.setTime(rateSvXp.getEffectiveDate());
                    rate.setEffectiveDate(
                            DatatypeFactory.newInstance().
                                    newXMLGregorianCalendar(cal));
                } else {
                    rate.setEffectiveDate(null);
                }

                if (rateSvXp.getExpirationDate() != null) {
                    cal.setTime(rateSvXp.getExpirationDate());
                    rate.setExpirationDate(
                            DatatypeFactory.newInstance().
                                    newXMLGregorianCalendar(cal));
                } else {
                    rate.setExpirationDate(null);
                }
                rate.setInstId(rateSvXp.getInstId());
                rate.setInverted(rateSvXp.getInverted());
                rate.setRate(rateSvXp.getRate());
                rate.setRateType(rateSvXp.getRateType());
                rate.setSrcCurrency(rateSvXp.getSrcCurrency());
                result.getCurrencyRate().add(rate);
            }
        } catch (SQLException e) {
            if (e.getErrorCode() >= 20000 && e.getErrorCode() <= 20999) {
                String result2 = null;
                try {
                    result2 = (String) ssn.queryForObject("common.get-last-error");
                } catch (SQLException ignored) {}
                throw new UserException(e.getCause().getMessage(), result2, null);
            } else {
                throw createDaoException(e);
            }
        } catch (Exception e) {
            if (e.getCause() == null) {
                throw new DataAccessException(e.getMessage());
            } else {
                throw createDaoException(e);
            }
        } finally {
            close(ssn);
        }
        return result;
    }

    @SuppressWarnings ("unchecked")

    public ObjectsLimits getObjectLimits(Map<String, Object> map)
            throws UserException {
        ObjectsLimits result = new ObjectsLimits();
        SqlMapSession ssn = null;
        try {
            List<ru.bpc.sv2.fcl.limits.ObjectLimits> listObject;
            ssn = getIbatisSessionNoContext();
            ssn.update("integ.get-object-limits", map);
            listObject = (ArrayList<ru.bpc.sv2.fcl.limits.ObjectLimits>) map.get("ref_cursor");
            for (ru.bpc.sv2.fcl.limits.ObjectLimits object : listObject) {
                ObjectLimits svObject = new ObjectLimits();
                svObject.setCountLimit(object.getCountLimit());
                svObject.setCountValue(object.getCountValue());
                svObject.setEntityType(object.getEntityType());
                svObject.setLimitType(object.getLimitType());
                svObject.setLimitCurrency(object.getLimitCurrency());
                svObject.setLimitName(object.getLimitName());
                svObject.setObjectId(object.getObjectId());
                svObject.setSumLimit(object.getSumLimit());
                svObject.setSumValue(object.getSumValue());
                GregorianCalendar cal = new GregorianCalendar();
                if (object.getLastResetDate() != null) {
                    cal.setTime(object.getLastResetDate());
                    svObject.setLastResetDate(
                            DatatypeFactory.newInstance().
                                    newXMLGregorianCalendar(cal));
                } else {
                    svObject.setLastResetDate(null);
                }
                if (object.getNextDate() != null) {
                    cal.setTime(object.getNextDate());
                    svObject.setNextDate(
                            DatatypeFactory.newInstance()
                                    .newXMLGregorianCalendar(cal));
                } else {
                    svObject.setNextDate(null);
                }
                result.getObjectLimits().add(svObject);
            }
        } catch (SQLException e) {
            if (e.getErrorCode() >= 20000 && e.getErrorCode() <= 20999) {
                String result2 = null;
                try {
                    result2 = (String) ssn.queryForObject("common.get-last-error");
                } catch (SQLException ignored) {}
                throw new UserException(e.getCause().getMessage(), result2, null);
            } else {
                throw createDaoException(e);
            }
        } catch (Exception e) {
            if (e.getCause() == null) {
                throw new DataAccessException(e.getMessage());
            } else {
                throw createDaoException(e);
            }
        } finally {
            close(ssn);
        }
        return result;
    }


    public String generateCaav(Map<String, Object> map) throws UserException {
        String result;
        SqlMapSession ssn = null;
        try {
            ssn = getIbatisSessionNoContext();
            ssn.update("integ.generate-caav", map);
            result = (String) map.get("o_caav");
        } catch (SQLException e) {
            if (e.getErrorCode() >= 20000 && e.getErrorCode() <= 20999) {
                String result2 = null;
                try {
                    result2 = (String) ssn.queryForObject("common.get-last-error");
                } catch (SQLException ignored) {}
                throw new UserException(e.getCause().getMessage(), result2, null);
            } else {
                throw createDaoException(e);
            }
        } catch (Exception e) {
            if (e.getCause() == null) {
                throw new DataAccessException(e.getMessage());
            } else {
                throw createDaoException(e);
            }
        } finally {
            close(ssn);
        }
        return result;
    }


    public int isCardInvolved(Map<String, Object> map) throws UserException {
        int result;
        SqlMapSession ssn = null;
        try {
            ssn = getIbatisSessionNoContext();
            result = (Integer) ssn.queryForObject("integ.is-card-involved", map);
        } catch (SQLException e) {
            if (e.getErrorCode() >= 20000 && e.getErrorCode() <= 20999) {
                String result2 = null;
                try {
                    result2 = (String) ssn.queryForObject("common.get-last-error");
                } catch (SQLException ignored) {}
                throw new UserException(e.getCause().getMessage(), result2, null);
            } else {
                throw createDaoException(e);
            }
        } catch (Exception e) {
            if (e.getCause() == null) {
                throw new DataAccessException(e.getMessage());
            } else {
                throw createDaoException(e);
            }
        } finally {
            close(ssn);
        }
        return result;
    }


    public String getTelNumber(Map<String, Object> map) throws UserException {
        String result;
        SqlMapSession ssn = null;
        try {
            ssn = getIbatisSessionNoContext();
            ssn.queryForObject("integ.get-tel-number", map);
            result = (String) map.get("delivery_address");
        } catch (SQLException e) {
            if (e.getErrorCode() >= 20000 && e.getErrorCode() <= 20999) {
                String result2 = null;
                try {
                    result2 = (String) ssn.queryForObject("common.get-last-error");
                } catch (SQLException ignored) {}
                throw new UserException(e.getCause().getMessage(), result2, null);
            } else {
                throw createDaoException(e);
            }
        } catch (Exception e) {
            if (e.getCause() == null) {
                throw new DataAccessException(e.getMessage());
            } else {
                throw createDaoException(e);
            }
        } finally {
            close(ssn);
        }
        return result;
    }


    public void setAuthScheme(Map<String, Object> map) throws UserException {
        SqlMapSession ssn = null;
        try {
            ssn = getIbatisSessionNoContext();
            ssn.queryForObject("integ.set-auth-scheme", map);
        } catch (SQLException e) {
            if (e.getErrorCode() >= 20000 && e.getErrorCode() <= 20999) {
                String result = null;
                try {
                    result = (String) ssn.queryForObject("common.get-last-error");
                } catch (SQLException ignored) {}
                throw new UserException(e.getCause().getMessage(), result, null);
            } else {
                throw createDaoException(e);
            }
        } catch (Exception e) {
            if (e.getCause() == null) {
                throw new DataAccessException(e.getMessage());
            } else {
                throw createDaoException(e);
            }
        } finally {
            close(ssn);
        }
    }

    @SuppressWarnings ("unchecked")

    public CardAuthSchemes getCardAuthSchemes(Map<String, Object> map)
            throws UserException {
        SqlMapSession ssn = null;
        CardAuthSchemes result = new CardAuthSchemes();
        try {
            ssn = getIbatisSessionNoContext();
            ssn.update("integ.get-card-auth-schemes", map);
            List<AuthSchemeObject> schemList = (ArrayList<AuthSchemeObject>) map.get("ref_cursor");
            for (AuthSchemeObject schem : schemList) {
                CardAuthScheme scheme = new CardAuthScheme();
                scheme.setSchemeName(schem.getSchemeName());
                GregorianCalendar cal = new GregorianCalendar();
                if (schem.getStartDate() != null) {
                    cal.setTime(schem.getStartDate());
                    scheme.setStartDate(DatatypeFactory.newInstance().newXMLGregorianCalendar(cal));
                } else {
                    scheme.setStartDate(null);
                }
                if (schem.getEndDate() != null) {
                    cal.setTime(schem.getEndDate());
                    scheme.setEndDate(DatatypeFactory.newInstance().newXMLGregorianCalendar(cal));
                } else {
                    scheme.setEndDate(null);
                }
                scheme.setIsActive(schem.getActive());
                scheme.setAuthSchemeCode(schem.getObjectName());
                result.getCardAuthSchemes().add(scheme);
            }

        } catch (SQLException e) {
            if (e.getErrorCode() >= 20000 && e.getErrorCode() <= 20999) {
                String result2 = null;
                try {
                    result2 = (String) ssn.queryForObject("common.get-last-error");
                } catch (SQLException ignored) {}
                throw new UserException(e.getCause().getMessage(), result2, null);
            } else {
                throw createDaoException(e);
            }
        } catch (Exception e) {
            if (e.getCause() == null) {
                throw new DataAccessException(e.getMessage());
            } else {
                throw createDaoException(e);
            }
        } finally {
            close(ssn);
        }
        return result;
    }


    public Cardholder getCardholder(Long userSessionId,
                                    Map<String, Object> map) throws UserException {
        Cardholder cardholder = new Cardholder();
        SqlMapSession ssn = null;
        try {
            ssn = getIbatisSessionNoContext();
            ssn.update("integ.get-cardholder", map);
            fillCardholder(cardholder, map);
	        if (map.get("document_cursor") != null) {
		        List<PersonId> personIds = (List<PersonId>) map.get("document_cursor");
		        for (PersonId personId : personIds) {
			        CardholderDocument doc = new CardholderDocument();
			        doc.setType(personId.getIdType());
			        doc.setTypeName(personId.getIdTypeName());
			        doc.setSeries(personId.getIdSeries());
			        doc.setNumber(personId.getIdNumber());
			        doc.setIssuer(personId.getIdIssuer());
			        if (personId.getIssueDate() != null) {
				        GregorianCalendar cal = new GregorianCalendar();
				        cal.setTime(personId.getIssueDate());
				        doc.setIssueDate(DatatypeFactory.newInstance().newXMLGregorianCalendar(cal));
			        } else {
				        doc.setIssueDate(null);
			        }
			        if (personId.getExpireDate() != null) {
				        GregorianCalendar cal = new GregorianCalendar();
				        cal.setTime(personId.getExpireDate());
				        doc.setExpireDate(DatatypeFactory.newInstance().newXMLGregorianCalendar(cal));
			        } else {
				        doc.setExpireDate(null);
			        }
			        cardholder.getDocument().add(doc);
		        }
	        }
        } catch (SQLException e) {
            if (e.getErrorCode() >= 20000 && e.getErrorCode() <= 20999) {
                String result = null;
                try {
                    result = (String) ssn.queryForObject("common.get-last-error");
                } catch (SQLException ignored) {}
                throw new UserException(e.getCause().getMessage(), result, null);
            } else {
                throw createDaoException(e);
            }
        } catch (Exception e) {
            if (e.getCause() == null) {
                throw new DataAccessException(e.getMessage());
            } else {
                throw createDaoException(e);
            }
        } finally {
            close(ssn);
        }
        return cardholder;
    }

    @SuppressWarnings ("unchecked")

    public ServiceProviders getServiceProviders(Map<String, Object> map)
            throws UserException {
        ServiceProviders result = new ServiceProviders();
        SqlMapSession ssn = null;
        try {
            ssn = getIbatisSessionNoContext();
            ssn.update("integ.get-service-providers", map);
            ArrayList<ServiceProvider> list = (ArrayList<ServiceProvider>) map.get("ref_cursor");
            result.getServiceProviders().addAll(list);
        } catch (SQLException e) {
            if (e.getErrorCode() >= 20000 && e.getErrorCode() <= 20999) {
                String result2 = null;
                try {
                    result2 = (String) ssn.queryForObject("common.get-last-error");
                } catch (SQLException ignored) {}
                throw new UserException(e.getCause().getMessage(), result2, null);
            } else {
                throw createDaoException(e);
            }
        } catch (Exception e) {
            if (e.getCause() == null) {
                throw new DataAccessException(e.getMessage());
            } else {
                throw createDaoException(e);
            }
        } finally {
            close(ssn);
        }
        return result;
    }

    @SuppressWarnings ("unchecked")

    public Transaction[] getTransactions(Long userSessionId,
                                         SelectionParams params) throws UserException {
        SqlMapSession ssn = null;
        try {
            ssn = getIbatisSessionNoContext();
            List<Transaction> trans = ssn.queryForList(
                    "integ.get-transactions", convertQueryParams(params));
            return trans.toArray(new Transaction[trans.size()]);
        } catch (SQLException e) {
            if (e.getErrorCode() >= 20000 && e.getErrorCode() <= 20999) {
                String result = null;
                try {
                    result = (String) ssn.queryForObject("common.get-last-error");
                } catch (SQLException ignored) {}
                throw new UserException(e.getCause().getMessage(), result, null);
            } else {
                throw new DataAccessException(e.getMessage());
            }
        } catch (Exception e) {
            if (e.getCause() == null) {
                throw new DataAccessException(e.getMessage());
            } else {
                throw createDaoException(e);
            }
        } finally {
            close(ssn);
        }
    }


    @SuppressWarnings ("unchecked")
    public ObjectCycles getObjectCycles(Map<String, Object> map)
            throws UserException {
        ObjectCycles result = new ObjectCycles();
        SqlMapSession ssn = null;
        try {
            ssn = getIbatisSessionNoContext();
            ssn.update("integ.get-object-cycles", map);
            ArrayList<ObjectCycle> list = (ArrayList<ObjectCycle>) map.get("ref_cursor");
            result.getObjectCycles().addAll(list);
        } catch (SQLException e) {
            if (e.getErrorCode() >= 20000 && e.getErrorCode() <= 20999) {
                String result2 = null;
                try {
                    result2 = (String) ssn.queryForObject("common.get-last-error");
                } catch (SQLException ignored) {}
                throw new UserException(e.getCause().getMessage(), result2, null);
            } else {
                throw createDaoException(e);
            }
        } catch (Exception e) {
            if (e.getCause() == null) {
                throw new DataAccessException(e.getMessage());
            } else {
                throw createDaoException(e);
            }
        } finally {
            close(ssn);
        }
        return result;
    }

    @SuppressWarnings ("unchecked")

    public AccountDetails getAccountDetails(Map<String, Object> map)
            throws UserException {
        AccountDetails result = new AccountDetails();
        SqlMapSession ssn = null;
        try {
            ssn = getIbatisSessionNoContext();
            ssn.update("integ.get-account-details", map);
            ArrayList<AccountDetail> list = (ArrayList<AccountDetail>) map.get("ref_cursor");
            result.getAccountDetails().addAll(list);
        } catch (SQLException e) {
            if (e.getErrorCode() >= 20000 && e.getErrorCode() <= 20999) {
                String result2 = null;
                try {
                    result2 = (String) ssn.queryForObject("common.get-last-error");
                } catch (SQLException ignored) {}
                throw new UserException(e.getCause().getMessage(), result2, null);
            } else {
                throw createDaoException(e);
            }
        } catch (Exception e) {
            if (e.getCause() == null) {
                throw new DataAccessException(e.getMessage());
            } else {
                throw createDaoException(e);
            }
        } finally {
            close(ssn);
        }
        return result;
    }

    @SuppressWarnings ("unchecked")

    public AccountBalances getAccountBalances(Map<String, Object> map)
            throws UserException {
        AccountBalances result = new AccountBalances();
        SqlMapSession ssn = null;
        try {
            ssn = getIbatisSessionNoContext();
            ssn.update("integ.get-account-balances", map);
            ArrayList<AccountBalance> list = (ArrayList<AccountBalance>) map.get("ref_cursor");
            result.getAccountBalances().addAll(list);
        } catch (SQLException e) {
            if (e.getErrorCode() >= 20000 && e.getErrorCode() <= 20999) {
                String result2 = null;
                try {
                    result2 = (String) ssn.queryForObject("common.get-last-error");
                } catch (SQLException ignored) {}
                throw new UserException(e.getCause().getMessage(), result2, null);
            } else {
                throw createDaoException(e);
            }
        } catch (Exception e) {
            if (e.getCause() == null) {
                throw new DataAccessException(e.getMessage());
            } else {
                throw createDaoException(e);
            }
        } finally {
            close(ssn);
        }
        return result;
    }

    @SuppressWarnings ("unchecked")

    public CardFeatures getCardFeatures(Map<String, Object> map)
            throws UserException {
        CardFeatures result = new CardFeatures();
        SqlMapSession ssn = null;
        try {
            ssn = getIbatisSessionNoContext();
            ssn.update("integ.get-card-features", map);
            ArrayList<CardFeature> list = (ArrayList<CardFeature>) map.get("ref_cursor");
            result.getCardFeatures().addAll(list);
        } catch (SQLException e) {
            if (e.getErrorCode() >= 20000 && e.getErrorCode() <= 20999) {
                String result2 = null;
                try {
                    result2 = (String) ssn.queryForObject("common.get-last-error");
                } catch (SQLException ignored) {}
                throw new UserException(e.getCause().getMessage(), result2, null);
            } else {
                throw createDaoException(e);
            }
        } catch (Exception e) {
            if (e.getCause() == null) {
                throw new DataAccessException(e.getMessage());
            } else {
                throw createDaoException(e);
            }
        } finally {
            close(ssn);
        }
        return result;
    }


    public CreditAccount getCreditAccount(Map<String, Object> map) throws UserException {
        CreditAccount result = new CreditAccount();
        SqlMapSession ssn = null;
        GregorianCalendar cal = new GregorianCalendar();
        try {
            ssn = getIbatisSessionNoContext();
            ssn.update("integ.get-credit-account-data", map);
            if (map.containsKey("accountNumber")) {result.setRepaymentAccountNumber((String) map.get("accountNumber"));}
            if (map.containsKey("closingDate") && map.get("closingDate") != null) {
                cal.setTime((Date) map.get("closingDate"));
                result.setClosingDate(DatatypeFactory.newInstance().newXMLGregorianCalendar(cal));
            }
            if (map.containsKey("totalAmountDue") && map.get("totalAmountDue") != null) {
                result.setFullLoanDebtAmount((String) map.get("totalAmountDue"));
            }
            if (map.containsKey("exceedLimit") && map.get("exceedLimit") != null) {
                result.setCreditAmount((String) map.get("exceedLimit"));
            }
            if (map.containsKey("interestRate") && map.get("interestRate") != null) {
                result.setInterestRate((String) map.get("interestRate"));
            }
            if (map.containsKey("interestAmount") && map.get("interestAmount") != null) {
                result.setInterestAmount((String) map.get("interestAmount"));
            }
            if (map.containsKey("overdueRate") && map.get("overdueRate") != null) {
                result.setSurchargeRate((String) map.get("overdueRate"));
            }
            if (map.containsKey("overdueAmount") && map.get("overdueAmount") != null) {
                result.setSurchargeAmount((String) map.get("overdueAmount"));
            }
            if (map.containsKey("totalIncome") && map.get("totalIncome") != null) {
                result.setFullRepaymentAmount((String) map.get("totalIncome"));
            }
            if (map.containsKey("repayAmount") && map.get("repayAmount") != null) {
                result.setCreditRepaymentAmount((String) map.get("repayAmount"));
            }
            if (map.containsKey("repayInterest") && map.get("repayInterest") != null) {
                result.setInterestRepaymentAmount((String) map.get("repayInterest"));
            }
            if (map.containsKey("repayOverdue") && map.get("repayOverdue") != null) {
                result.setSurchargeRepaymentAmount((String) map.get("repayOverdue"));
            }
            if (map.containsKey("remainderDebt") && map.get("remainderDebt") != null) {
                result.setFullRemainingAmount((String) map.get("remainderDebt"));
            }
            if (map.containsKey("overdraftBalance") && map.get("overdraftBalance") != null) {
                result.setCreditRemainingAmount((String) map.get("overdraftBalance"));
            }
            if (map.containsKey("interestBalance") && map.get("interestBalance") != null) {
                result.setInterestRemainingAmount((String) map.get("interestBalance"));
            }
            if (map.containsKey("overdueBalance") && map.get("overdueBalance") != null) {
                result.setSurchargeRemainingAmount((String) map.get("overdueBalance"));
            }
            if (map.containsKey("dueDate") && map.get("dueDate") != null) {
                cal.setTime((Date) map.get("dueDate"));
                result.setNextDueDate(DatatypeFactory.newInstance().newXMLGregorianCalendar(cal));
            }
            if (map.containsKey("minAmountDue") && map.get("minAmountDue") != null) {
                result.setNextDueAmount((String) map.get("minAmountDue"));
            }

        } catch (SQLException e) {
            if (e.getErrorCode() >= 20000 && e.getErrorCode() <= 20999) {
                String result2 = null;
                try {
                    result2 = (String) ssn.queryForObject("common.get-last-error");
                } catch (SQLException ignored) {}
                throw new UserException(e.getCause().getMessage(), result2, null);
            } else {
                throw createDaoException(e);
            }
        } catch (Exception e) {
            if (e.getCause() == null) {
                throw new DataAccessException(e.getMessage());
            } else {
                throw createDaoException(e);
            }
        } finally {
            close(ssn);
        }
        return result;
    }


    public List<Long> getCustomerByPersonData(Map<String, Object> map)
            throws UserException {
        SqlMapSession ssn = null;
        List<Long> result = Collections.EMPTY_LIST;
        try {
            ssn = getIbatisSessionNoContext();
            ssn.update("integ.get-customer-by-person-data", map);
            BigDecimal[] tmp = (BigDecimal[]) map.get("result");
            if (tmp != null) {
                result = new ArrayList<>(tmp.length);
                for (int i = 0; i < tmp.length; ++i) {
                    result.add(tmp[i].longValue());
                }
            }
        } catch (SQLException e) {
            if (e.getErrorCode() >= 20000 && e.getErrorCode() <= 20999) {
                String result2 = null;
                try {
                    result2 = (String) ssn.queryForObject("common.get-last-error");
                } catch (SQLException ignored) {}
                throw new UserException(e.getCause().getMessage(), result2, null);
            } else {
                throw createDaoException(e);
            }
        } catch (Exception e) {
            if (e.getCause() == null) {
                throw new DataAccessException(e.getMessage());
            } else {
                throw createDaoException(e);
            }
        } finally {
            close(ssn);
        }
        return result;
    }


    public String getCardNumberByPhone(Map<String, Object> map) throws UserException {
        SqlMapSession ssn = null;
        String result;
        try {
            ssn = getIbatisSessionNoContext();
            ssn.update("integ.get-card-number-by-phone", map);
            if (map.containsKey("mask") && map.get("mask") != null) {
                result = (String) map.get("mask");
            } else {
                result = (String) map.get("number");
            }
        } catch (SQLException e) {
            if (e.getErrorCode() >= 20000 && e.getErrorCode() <= 20999) {
                String result2 = null;
                try {
                    result2 = (String) ssn.queryForObject("common.get-last-error");
                } catch (SQLException ignored) {}
                throw new UserException(e.getCause().getMessage(), result2, null);
            } else {
                throw createDaoException(e);
            }
        } catch (Exception e) {
            if (e.getCause() == null) {
                throw new DataAccessException(e.getMessage());
            } else {
                throw createDaoException(e);
            }
        } finally {
            close(ssn);
        }
        return result;
    }


    public List<ContractItem> getContractList(Map<String, Object> map) throws UserException {
        SqlMapSession ssn = null;
        ArrayList<ContractItem> result = new ArrayList<ContractItem>();
        try {
            ssn = getIbatisSessionNoContext();
            ssn.queryForList("integ.get-contract-list", map);
            ArrayList<ContractObject> contracts = (ArrayList<ContractObject>) map.get("ref_cursor");
            for (ContractObject contract : contracts) {
                ContractItem item = new ContractItem();
                if (contract.getContractNumber() != null) {
                    item.setContractNumber(contract.getContractNumber());
                }
                if (contract.getContractType() != null) {
                    item.setContractType(contract.getContractType());
                }
                if (contract.getProduct() != null) {
                    item.setProduct(contract.getProduct());
                }
                if (contract.getStartDate() != null) {
                    GregorianCalendar cal = new GregorianCalendar();
                    cal.setTime(contract.getStartDate());
                    item.setStartDate(DatatypeFactory.newInstance().newXMLGregorianCalendar(cal));
                }
                if (contract.getEndDate() != null) {
                    GregorianCalendar cal = new GregorianCalendar();
                    cal.setTime(contract.getEndDate());
                    item.setEndDate(DatatypeFactory.newInstance().newXMLGregorianCalendar(cal));
                }
                result.add(item);
            }
        } catch (SQLException e) {
            if (e.getErrorCode() >= 20000 && e.getErrorCode() <= 20999) {
                String result2 = null;
                try {
                    result2 = (String) ssn.queryForObject("common.get-last-error");
                } catch (SQLException ignored) {}
                throw new UserException(e.getCause().getMessage(), result2, null);
            } else {
                throw createDaoException(e);
            }
        } catch (Exception e) {
            if (e.getCause() == null) {
                throw new DataAccessException(e.getMessage());
            } else {
                throw createDaoException(e);
            }
        } finally {
            close(ssn);
        }
        return result;
    }


    public boolean getRemoteBankingActivity(Map<String, Object> map) throws UserException {
        SqlMapSession ssn = null;
        Boolean result;
        try {
            ssn = getIbatisSessionNoContext();
            ssn.update("integ.get-remote-banking-activity", map);
            result = (Boolean) map.get("banking_activity");
        } catch (SQLException e) {
            if (e.getErrorCode() >= 20000 && e.getErrorCode() <= 20999) {
                String result2 = null;
                try {
                    result2 = (String) ssn.queryForObject("common.get-last-error");
                } catch (SQLException ignored) {}
                throw new UserException(e.getCause().getMessage(), result2, null);
            } else {
                throw createDaoException(e);
            }
        } catch (Exception e) {
            if (e.getCause() == null) {
                throw new DataAccessException(e.getMessage());
            } else {
                throw createDaoException(e);
            }
        } finally {
            close(ssn);
        }
        return result;
    }


    @SuppressWarnings ("unchecked")
    public CreditInvoice getSpecifiedInvoice(Long userSessionId, Map<String, Object> map) throws UserException {
        SqlMapSession ssn = null;
        try {
            ssn = getIbatisSessionNoContext();
            ssn.update("integ.get-specified-invoice", map);
            ArrayList<CreditInvoice> result = (ArrayList<CreditInvoice>) map.get("ref_cursor");
            return (result.size() > 0) ? result.get(0) : null;
        } catch (SQLException e) {
            if (e.getErrorCode() >= 20000 && e.getErrorCode() <= 20999) {
                String result = null;
                try {
                    result = (String) ssn.queryForObject("common.get-last-error");
                } catch (SQLException ignored) {}
                throw new UserException(e.getCause().getMessage(), result, null);
            } else {
                throw createDaoException(e);
            }
        } catch (Exception e) {
            if (e.getCause() == null) {
                throw new DataAccessException(e.getMessage());
            } else {
                throw createDaoException(e);
            }
        } finally {
            close(ssn);
        }
    }


    @SuppressWarnings ("unchecked")
    public List<CreditInvoiceOperation> getInvoiceOperations(Long userSessionId, Map<String, Object> map) throws UserException {
        SqlMapSession ssn = null;
        try {
            ssn = getIbatisSessionNoContext();
            ssn.update("integ.get-invoice-oper-list-data", map);
            return (ArrayList<CreditInvoiceOperation>) map.get("ref_cursor");
        } catch (SQLException e) {
            if (e.getErrorCode() >= 20000 && e.getErrorCode() <= 20999) {
                String result = null;
                try {
                    result = (String) ssn.queryForObject("common.get-last-error");
                } catch (SQLException ignored) {}
                throw new UserException(e.getCause().getMessage(), result, null);
            } else {
                throw createDaoException(e);
            }
        } catch (Exception e) {
            if (e.getCause() == null) {
                throw new DataAccessException(e.getMessage());
            } else {
                throw createDaoException(e);
            }
        } finally {
            close(ssn);
        }
    }


    @SuppressWarnings ("unchecked")
    public List<CreditInvoiceAggregation> getInvoiceAggregation(Long userSessionId, Map<String, Object> map) throws UserException {
        SqlMapSession ssn = null;
        try {
            ssn = getIbatisSessionNoContext();
            ssn.update("integ.get-invoice-oper-aggr-data", map);
            return (ArrayList<CreditInvoiceAggregation>) map.get("ref_cursor");
        } catch (SQLException e) {
            if (e.getErrorCode() >= 20000 && e.getErrorCode() <= 20999) {
                String result = null;
                try {
                    result = (String) ssn.queryForObject("common.get-last-error");
                } catch (SQLException ignored) {}
                throw new UserException(e.getCause().getMessage(), result, null);
            } else {
                throw createDaoException(e);
            }
        } catch (Exception e) {
            if (e.getCause() == null) {
                throw new DataAccessException(e.getMessage());
            } else {
                throw createDaoException(e);
            }
        } finally {
            close(ssn);
        }
    }


    @SuppressWarnings ("unchecked")
    public Date getInvoiceDate(Long userSessionId, String entityType, Long objectId) throws UserException {
        SqlMapSession ssn = null;
        try {
            if (userSessionId != null) {
                ssn = getIbatisSession(userSessionId);
            } else {
                ssn = getIbatisSessionNoContext();
            }
            Map<String, Object> map = new HashMap<String, Object>(4);
            map.put("entityType", entityType);
            map.put("objectId", objectId);
            map.put("maskError", Boolean.TRUE);
            ssn.update("integ.get-last-invoice-date", map);
            return (map.get("date") != null) ? (Date) map.get("date") : null;
        } catch (SQLException e) {
            throw new UserException("", e);
        } finally {
            close(ssn);
        }
    }


    @SuppressWarnings ("unchecked")
    public MerchantStatResponse getMerchantStat(Long userSessionId, Map<String, Object> map) throws UserException {
        SqlMapSession ssn = null;
        String statXML = "";
        try {
            ssn = getIbatisSessionNoContext();
            ssn.update("integ.get-merchant-stat", map);
            if (map.containsKey("merchantStat")) {
                statXML = (String) map.get("merchantStat");
            }

            statXML = statXML.replaceAll("<xml>", "<xml xmlns:=\"http://bpc.ru/SVXP\">");
            DocumentBuilderFactory dbf = DocumentBuilderFactory.newInstance();
            dbf.setNamespaceAware(true);
            DocumentBuilder db = dbf.newDocumentBuilder();
            Document doc = db.parse(new ByteArrayInputStream(statXML.getBytes()));
            Node firstChild = doc.getFirstChild();
            JAXBContext jc = JAXBContext.newInstance(MerchantStatResponse.class);
            Unmarshaller unmarshaller = jc.createUnmarshaller();

            JAXBElement<MerchantStatResponse> jaxbElement = unmarshaller.unmarshal(firstChild, MerchantStatResponse.class);
            return jaxbElement.getValue();
        } catch (SQLException e) {
            if (e.getErrorCode() >= 20000 && e.getErrorCode() <= 20999) {
                String result = null;
                try {
                    result = (String) ssn.queryForObject("common.get-last-error");
                } catch (SQLException ignored) {}
                throw new UserException(e.getCause().getMessage(), result, null);
            } else {
                throw createDaoException(e);
            }
        } catch (Exception e) {
            if (e.getCause() == null) {
                throw new DataAccessException(e.getMessage());
            } else {
                throw createDaoException(e);
            }
        } finally {
            close(ssn);
        }
    }


    public List<InstitutionType> getInstitutions(Map<String, Object> map) throws UserException {
        SqlMapSession ssn = null;
        List<InstitutionType> instTypes = new ArrayList<InstitutionType>();
        List<Institute> institutes;
        String lang = (String) map.get("lang");

        try {
            ssn = getIbatisSessionNoContext();
            institutes = ssn.queryForList("integ.get-institutes-lists");

            for (Institute institute : institutes) {
                List<NetworkType> networkTypes = ssn.queryForList("integ.get-network", Integer.valueOf(institute.getId()));

                // get list names for ost_institute
                changeStateParamMap(map, institute.getId(), "OST_INSTITUTION", "NAME", lang);
                List<LangNameType> instNames = ssn.queryForList("integ.get-inst-lang-name-type", map);

                // get list descriptions for ost_institute
                changeStateParamMap(map, institute.getId(), "OST_INSTITUTION", "DESCRIPTION", lang);
                List<LangNameType> instDescriptions = ssn.queryForList("integ.get-inst-lang-name-type", map);

                // get list names for net_network
                for (NetworkType networkType : networkTypes) {
                    changeStateParamMap(map, networkType.getId(), "NET_NETWORK", "NAME", lang);
                    List<LangNameType> networkNames = ssn.queryForList("integ.get-inst-lang-name-type", map);
                    networkType.getName().addAll(networkNames);
                }
                //get list names for instTypes
                List<LangNameType> instTypesNames = null;
                if (institute.getInstType() != null && !institute.getInstType().isEmpty()) {
                    changeStateParamMap(map, "COM_DICTIONARY", "NAME", institute.getInstType().substring(0, 4), institute.getInstType().substring(4), lang);
                    instTypesNames = ssn.queryForList("integ.get-inst-type-lang-name", map);
                    checkLangNameType(instTypesNames, institute.getId(), lang);
                }

                InstitutionType instType = generateInstObject(institute, networkTypes, instNames, instDescriptions, instTypesNames);
                instTypes.add(instType);
                clearStateParamMap(map);
            }
        } catch (Exception e) {
            throw new UserException("", e);
        } finally {
            close(ssn);
        }
        return instTypes;
    }

    private void checkLangNameType(List<LangNameType> typesNames, String id, String lang) throws Exception {
        if (lang == null || lang.isEmpty()) return;
        if (typesNames == null || typesNames.isEmpty()) {
            throw new Exception("Error: language = " + lang + " for id = " + id + " is absent");
        }
    }


    public List<AgentType> getAgents(Map<String, Object> map) throws UserException {
        SqlMapSession ssn = null;
        List<AgentType> agentTypes = new ArrayList<AgentType>();
        List<Agent> agents;
        String lang = (String) map.get("lang");

        try {
            ssn = getIbatisSessionNoContext();
            // get list agent
            agents = ssn.queryForList("integ.get-agents-list");

            for (Agent item : agents) {
                AgentType agent = new AgentType();
                agent.setId(item.getId());
                agent.setInstId(item.getInstId());
                agent.setSeqnum(item.getSeqnum());
                agent.setParentId(item.getParentId());
                agent.setIsDefault(Boolean.parseBoolean(item.getBydefault()));
                agent.setAgentNumber(item.getAgentNumber());
                // --- get list names for agent ---
                changeStateParamMap(map, item.getId(), "OST_AGENT", "NAME", lang);
                List<LangNameType> agentNames = ssn.queryForList("integ.get-inst-lang-name-type", map);
                agent.getName().addAll(agentNames);
                clearStateParamMap(map);
                //---------------------------------

                // --- get list names for agentType ---
                DictEntryType agentType = new DictEntryType();
                agentType.setCode(item.getAgentType());
                List<LangNameType> agentTypeNames = null;
                if (item.getAgentType() != null && !item.getAgentType().isEmpty()) {
                    changeStateParamMap(map, "COM_DICTIONARY", "NAME", item.getAgentType().substring(0, 4), item.getAgentType().substring(4), lang);
                    agentTypeNames = ssn.queryForList("integ.get-inst-type-lang-name", map);
                }

                checkLangNameType(agentTypeNames, item.getId(), lang);

                agentType.getName().addAll(agentTypeNames);
                agent.setAgentType(agentType);
                clearStateParamMap(map);
                // ------------------------------------

                // --- get contact list ---
                changeStateParamMap(map, "ENTTAGNT", item.getId());
                List<ContactObject> listContactObject = ssn.queryForList("integ.get-contact-list", map);
                clearStateParamMap(map);
                // ------------------------

                // --- get contactData list ---
                List<ContactType> contactTypes = new ArrayList<ContactType>();
                for (ContactObject contactObject : listContactObject) {
                    ContactType contactType = new ContactType();
                    contactType.setContactType(contactObject.getContactType());
                    changeStateParamMap(map, contactObject.getContactId());
                    List<ContactDataType> contactDataList = ssn.queryForList("integ.get-contact-data-list", map);
                    contactType.getContactData().addAll(contactDataList);
                    contactTypes.add(contactType);
                    clearStateParamMap(map);
                }
                agent.getContact().addAll(contactTypes);
                clearStateParamMap(map);
                // ----------------------------

                agentTypes.add(agent);
            }
        } catch (Exception e) {
            throw new UserException("", e);
        } finally {
            close(ssn);
        }
        return agentTypes;
    }


    public String getInstallmentPlan(Map<String, Object> params) throws UserException {
        SqlMapSession ssn = null;
        String result;
        try {
            ssn = getIbatisSessionNoContext();
            ssn.update("integ.get-installment-plan", params);
            result = (String) params.get("oInstallmentPlan");
        } catch (SQLException e) {
            throw new UserException("", e);
        } finally {
            close(ssn);
        }
        return result;
    }


    public List<Product> getProducts(Long userSessionId, final Map<String, Object> params) throws UserException {
        return executeWithSession(userSessionId, logger, new IbatisSessionCallback<List<Product>>() {
	        @Override
            public List<Product> doInSession(SqlMapSession ssn) throws Exception {
                ssn.update("integ.get-products-hierarchy", params);
                return (List<Product>) params.get("cursor");
            }
        });
    }


    public List<Operation> getTransactions(Long userSessionId, final Map<String, Object> params) throws UserException {
        return executeWithSession(userSessionId, logger, new IbatisSessionCallback<List<Operation>>() {
	        @Override
            public List<Operation> doInSession(SqlMapSession ssn) throws Exception {
                ssn.queryForObject("integ.get-transactions-by-customer-and-inst", params);
                return (List<Operation>) params.get("cursor");
            }
        });
    }


    public CustomerByCard getCustomerByCard(Long userSessionId, final Map<String, Object> map) throws UserException {
        return executeWithSession(userSessionId, logger, new IbatisSessionCallback<CustomerByCard>() {
	        @Override
            public CustomerByCard doInSession(SqlMapSession ssn) throws Exception {
                CustomerByCard result;
                ssn.queryForObject("integ.get-customer-by-card", map);
                result = new CustomerByCard();
                result.setCustomer(new CustomerItem());
                if (map.get("customer_id") != null) {
                    result.getCustomer().setCustomerId((Long) map.get("customer_id"));
                }
                if (map.get("customer_number") != null) {
                    result.getCustomer().setCustomerNumber((String) map.get("customer_number"));
                }
                if (map.get("inst_id") != null) {
                    result.setInstId((Integer) map.get("inst_id"));
                }
                return result;
            }
        });
    }


    public FinOverview getFinancialOverview(final Long userSessionId, final Map<String, Object> map) throws UserException {
        return executeWithSession(userSessionId, logger, new IbatisSessionCallback<FinOverview>() {
	        @Override
            public FinOverview doInSession(SqlMapSession ssn) throws Exception {
                FinOverview out = new FinOverview();
                ssn.queryForObject("integ.get-financial-overview", map);
                if (map.get("cardholderNumber") != null) {
                    out.setCardholderNumber(map.get("cardholderNumber").toString());
                }
                if (map.get("cardholderName") != null) {
                    out.setCardholderName(map.get("cardholderName").toString());
                }
                if (map.get("cursor") != null && ((List) map.get("cursor")).size() > 0) {
                    out.setAccounts(new FinOverviewAccounts());
                    Map<String, Object> params = new HashMap<String, Object>();
                    for (FinOverviewAccount account : (List<FinOverviewAccount>) map.get("cursor")) {
                        params.put("accountId", account.getAccountId());
                        account.setFees(getFinancialOverviewFees(userSessionId, params));
                        account.setAccountId(null);
                        out.getAccounts().getAccount().add(account);
                    }
                }
                return out;
            }
        });
    }


    public CreditCardPayments getCreditCardPayments(final Long userSessionId, final Map<String, Object> map) throws UserException {
        return executeWithSession(userSessionId, logger, new IbatisSessionCallback<CreditCardPayments>() {
	        @Override
            public CreditCardPayments doInSession(SqlMapSession ssn) throws Exception {
                CreditCardPayments out = new CreditCardPayments();
                ssn.queryForObject("integ.get-credit-card-payments", map);
                if (map.get("cursor") != null && ((List) map.get("cursor")).size() > 0) {
                    Map<String, Object> params = new HashMap<String, Object>();
                    for (CrdPmntAccount account : (List<CrdPmntAccount>) map.get("cursor")) {
                        params.put("accountId", account.getAccountId());
                        account.setPayments(getCreditCardPaymentsValues(userSessionId, params));
                        account.setAccountId(null);
                        out.getAccount().add(account);
                    }
                }
                return out;
            }
        });
    }


    public CustomerInfoByCard getCustomerInfoByCard(Long userSessionId, final Map<String, Object> map) throws UserException {
        return executeWithSession(userSessionId, logger, new IbatisSessionCallback<CustomerInfoByCard>() {
	        @Override
            public CustomerInfoByCard doInSession(SqlMapSession ssn) throws Exception {
                ssn.queryForObject("integ.get-customer-info-by-card", map);
                CustomerInfoByCard out = new CustomerInfoByCard();
                out.setCard(fillCustomerInfoCardBlock(map));
                out.setCustomer(fillCustomerInfoCustomerBlock(map));
                out.setAccounts(fillCustomerInfoAccountsBlock(map));
                return out;
            }
        });
    }



    public void repaymentDebtOperation(Long userSessionId, final Map<String, Object> map) throws UserException {
        SqlMapSession ssn = null;
        try {
            ssn = getIbatisSession(userSessionId);
            ssn.update("integ.repayment-debt-operation", map);
        } catch (SQLException e) {
            throw new UserException("", e);
        } finally {
            close(ssn);
        }
    }


    public PaymentInformationResponse getPaymentInformation(Long userSessionId, final Map<String, Object> map) throws UserException {
        return executeWithSession(userSessionId, logger, new IbatisSessionCallback<PaymentInformationResponse>() {
	        @Override
            public PaymentInformationResponse doInSession(SqlMapSession ssn) throws Exception {
                PaymentInformationResponse response = new PaymentInformationResponse();
                ssn.queryForObject("integ.get-payment-information", map);
                if (map.get("customer_id") != null) {
                    response.setCustomerId(map.get("customer_id").toString());
                }
                if (map.get("cardholder_name") != null) {
                    response.setCardholderName((String) map.get("cardholder_name"));
                }
                if (map.get("account_number") != null) {
                    response.setAccountNumber((String) map.get("account_number"));
                }
                if (map.get("currency") != null) {
                    response.setCurrency((String) map.get("currency"));
                }
                if (map.get("tad") != null) {
                    response.setTad((BigDecimal) map.get("tad"));
                }
                if (map.get("last_payment_flag") != null) {
                    response.setLastPaymentFlag((Integer) map.get("last_payment_flag"));
                }
                if (map.get("due_date") != null) {
                    response.setDueDate((XMLGregorianCalendar) map.get("due_date"));
                }
                if (map.get("daily_mad") != null) {
                    response.setDailyMad((BigDecimal) map.get("daily_mad"));
                }
                if (map.get("short_card_mask") != null) {
                    response.setShortCardMask((String) map.get("short_card_mask"));
                }
                if (map.get("id_number") != null) {
                    response.setNumberId((String) map.get("id_number"));
                }
                return response;
            }
        });
    }


    public PaymentInformationResponse getPaymentInformationAccount(Long userSessionId, final Map<String, Object> map)
            throws UserException {
        return executeWithSession(userSessionId, logger, new IbatisSessionCallback<PaymentInformationResponse>() {
	        @Override
            public PaymentInformationResponse doInSession(SqlMapSession ssn) throws Exception {
                PaymentInformationResponse response = new PaymentInformationResponse();
                ssn.queryForObject("integ.get-payment-information-account", map);
                if (map.get("customer_id") != null) {
                    response.setCustomerId(map.get("customer_id").toString());
                }
                if (map.get("customer_name") != null) {
                    response.setCardholderName((String) map.get("customer_name"));
                }
                if (map.get("account_number") != null) {
                    response.setAccountNumber((String) map.get("account_number"));
                }
                if (map.get("currency") != null) {
                    response.setCurrency((String) map.get("currency"));
                }
                if (map.get("tad") != null) {
                    response.setTad((BigDecimal) map.get("tad"));
                }
                if (map.get("last_payment_flag") != null) {
                    response.setLastPaymentFlag((Integer) map.get("last_payment_flag"));
                }
                if (map.get("due_date") != null) {
                    response.setDueDate((XMLGregorianCalendar) map.get("due_date"));
                }
                if (map.get("daily_mad") != null) {
                    response.setDailyMad((BigDecimal) map.get("daily_mad"));
                }
                if (map.get("short_card_mask") != null) {
                    response.setShortCardMask((String) map.get("short_card_mask"));
                }
                if (map.get("id_number") != null) {
                    response.setNumberId((String) map.get("id_number"));
                }
                return response;
            }
        });
    }


    public DppInstallmentsResponse getDppInstallments(Long userSessionId, final Map<String, Object> map)
            throws UserException {
        return executeWithSession(userSessionId, logger, new IbatisSessionCallback<DppInstallmentsResponse>() {
	        @Override
            public DppInstallmentsResponse doInSession(SqlMapSession ssn) throws Exception {
                DppInstallmentsResponse out = new DppInstallmentsResponse();
                ssn.update("integ.get-dpp-installments", map);
                if (map.get("interestRate") != null || map.get("installmentCount") != null || map.get("installmentAmount") != null) {
                    if (out.getDpp() == null) {
                        out.setDpp(new DppProgram());
                    }
                    if (out.getDpp().getInstallmentPlan() == null) {
                        out.getDpp().setInstallmentPlan(new InstallmentPlan());
                    }
                    if (map.get("interestRate") != null) {
                        out.getDpp().getInstallmentPlan().setInterestRate((BigDecimal) map.get("interestRate"));
                    }
                    if (map.get("installmentCount") != null) {
                        out.getDpp().getInstallmentPlan().setInstallmentCount((Integer) map.get("installmentCount"));
                    }
                    if (map.get("installmentAmount") != null) {
                        out.getDpp().getInstallmentPlan().setInstallmentAmount((BigDecimal) map.get("installmentAmount"));
                    }
                }
                if (map.get("calcAlgorithm") != null) {
                    if (out.getDpp() == null) {
                        out.setDpp(new DppProgram());
                    }
                    if (out.getDpp().getAlgorithms() == null) {
                        out.getDpp().setAlgorithms(new Algorithms());
                    }
                    out.getDpp().getAlgorithms().setCalculationAlgorithm((String) map.get("calcAlgorithm"));
                }
                if (map.get("installments") != null && ((List) map.get("installments")).size() > 0) {
                    out.setInstallments(new Installments());
                    out.getInstallments().getInstallment().addAll((List) map.get("installments"));
                }
                return out;
            }
        });
    }


    public List<CardType> getCardTypes(Map<String, Object> map) throws UserException  {
        SqlMapSession ssn = null;
        List<CardType> roots = new ArrayList<CardType>();
        String lang = (String) map.get("lang");
        Map<String, CardType> tree = new HashMap<String, CardType>();
        try {
            ssn = getIbatisSessionNoContext();

            List<CardType> list = ssn.queryForList("integ.get-card-types-list");
            for (CardType type: list) {
                changeStateParamMap(map, type.getId(), "NET_CARD_TYPE", "NAME", lang);
                List<LangNameType> names = ssn.queryForList("integ.get-inst-lang-name-type", map);
                type.getName().addAll(names);
                clearStateParamMap(map);

                tree.put(type.getId(), type);
            }

            for (CardType type: list) {
                String parentId = type.getParentId();
                if (parentId == null || "".equals(parentId)) {
                    roots.add(type);
                } else {
                    CardType parent = tree.get(parentId);
                    parent.getCardType().add(type);
                }
            }

        } catch (Exception e) {
            throw new UserException("", e);
        } finally {
            close(ssn);
        }
        return roots;
    }


    public List<ServiceType> getServiceTypes(Map<String, Object> map) throws UserException {
        SqlMapSession ssn = null;
        List<ServiceType> types = new ArrayList<ServiceType>();
        String lang = (String) map.get("lang");

        try {
            ssn = getIbatisSessionNoContext();

            types = ssn.queryForList("integ.get-service-types-list");
            for (ServiceType type : types) {
                changeStateParamMap(map, type.getId(), "PRD_SERVICE_TYPE", "LABEL", lang);
                List<LangNameType> names = ssn.queryForList("integ.get-inst-lang-name-type", map);
                type.getName().addAll(names);
                clearStateParamMap(map);
            }
        } catch (Exception e) {
            throw new UserException("", e);
        } finally {
            close(ssn);
        }
        return types;
    }


    public String getOmniProductsXml(Map<String, Object> map) throws UserException {
        SqlMapSession ssn = null;

        try {
            ssn = getIbatisSessionNoContext();

            ssn.update("integ.get-omni-products", map);

            return (String) map.get("xml");
        } catch (Exception e) {
            throw createDaoException(e);
        } finally {
            close(ssn);
        }
    }


    public String getDictDictionariesXml(Map<String, Object> map) throws UserException {
        SqlMapSession ssn = null;

        try {
            ssn = getIbatisSessionNoContext();

            ssn.update("integ.get-dict-dictionaries", map);

            return (String) map.get("xml");
        } catch (Exception e) {
            throw createDaoException(e);
        } finally {
            close(ssn);
        }
    }


    public String getDictMccXml(Map<String, Object> map) throws UserException {
        SqlMapSession ssn = null;

        try {
            ssn = getIbatisSessionNoContext();

            ssn.update("integ.get-dict-mcc", map);

            return (String) map.get("xml");
        } catch (Exception e) {
            throw createDaoException(e);
        } finally {
            close(ssn);
        }
    }


	public String registerDpps(Map<String, Object> map) throws UserException {
		SqlMapSession ssn = null;

		try {
			ssn = getIbatisSessionNoContext();

			ssn.update("integ.register-dpps", map);

			return (String) map.get("o_result");
		} catch (Exception e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


    public String getDictCurrencyRatesXml(Map<String, Object> map) throws UserException {
        SqlMapSession ssn = null;

        try {
            ssn = getIbatisSessionNoContext();

            ssn.update("integ.get-dict-currency-rates", map);

            return (String) map.get("xml");
        } catch (Exception e) {
            throw createDaoException(e);
        } finally {
            close(ssn);
        }
    }


	public CardholderExt getCardholderExt(Long userSessionId, Map<String, Object> map) throws UserException {
		CardholderExt cardholder = new CardholderExt();
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSession(userSessionId);
			ssn.update("integ.get-cardholder-ext", map);
			fillCardholder(cardholder, map);
			if (map.containsKey("document_cursor") && map.get("document_cursor") != null) {
				cardholder.getDocument().addAll((Collection<CardholderDocument>) map.get("document_cursor"));
			}

			if (map.containsKey("address_cursor") && map.get("address_cursor") != null) {
				cardholder.getAddress().addAll((Collection<Address>) map.get("address_cursor"));
			}

			if (map.containsKey("contact_cursor") && map.get("contact_cursor") != null) {
				cardholder.getContact().addAll((Collection<Contact>) map.get("contact_cursor"));
			}
		} catch (SQLException e) {
			if (e.getErrorCode() >= 20000 && e.getErrorCode() <= 20999) {
				String result = null;
				try {
					result = (String) ssn.queryForObject("common.get-last-error");
				} catch (SQLException ignored) {}
				throw new UserException(e.getCause().getMessage(), result, null);
			} else {
				throw createDaoException(e);
			}
		} catch (Exception e) {
			if (e.getCause() == null) {
				throw new DataAccessException(e.getMessage());
			} else {
				throw createDaoException(e);
			}
		} finally {
			close(ssn);
		}
		return cardholder;
	}

    public List<UnbilledDebt> getUnbilledDebts(Long userSessionId, final Map<String, Object> map) throws UserException {
        return executeWithSession(userSessionId, logger, new IbatisSessionCallback<List<UnbilledDebt>>() {
	        @Override
            public List<UnbilledDebt> doInSession(SqlMapSession ssn) throws Exception {
                ssn.queryForList("integ.get-unbilled-debts", map);
                if (map.get("cursor") != null && ((List) map.get("cursor")).size() > 0) {
                    return (List<UnbilledDebt>) map.get("cursor");
                }
                return null;
            }
        });
    }


	public List<PaymentOrder> getPaymentOrders(final Map<String, Object> map) throws UserException {
    	return executeWithSession(logger, new IbatisSessionCallback<List<PaymentOrder>>() {
		    @Override
		    public List<PaymentOrder> doInSession(SqlMapSession ssn) throws Exception {
			    ssn.update("integ.export-pmo", map);

			    if (map.get("cursor") == null) {
				    return null;
			    }

			    List<PaymentOrder> orders = (List<PaymentOrder>) map.get("cursor");
				Map<String, Object> params = new HashMap<String, Object>();
			    for(PaymentOrder order: orders) {
			    	params.clear();
			    	params.put("orderId", order.getOrderId());
				    ssn.update("integ.export-pmo-data", params);

				    if (params.get("cursor") == null) {
					    continue;
				    }

				    order.getParameter().addAll((List<Parameter>) params.get("cursor"));
			    }

			    return orders;
		    }
	    });
	}

	public void importPaymentOrderResponses(final Map<String, Object> map) throws UserException {
		executeWithSession(logger, new IbatisSessionCallback<Void>() {
			@Override
			public Void doInSession(SqlMapSession ssn) throws Exception {
				ssn.update("integ.import-pmo-responses", map);
				return null;
			}
		});
	}

	public List<McwFraud> getMcwFrauds(Long userSessionId, final SelectionParams params) throws UserException {
		return executeWithSession(userSessionId, null, params, logger, new IbatisSessionCallback<List<McwFraud>>() {
			@Override
			public List<McwFraud> doInSession(SqlMapSession ssn) throws Exception {
				return ssn.queryForList("integ.get-mcw-frauds", convertQueryParams(params));
			}
		});
	}

	public Integer getMcwFraudsCount(Long userSessionId, final SelectionParams params) throws UserException {
		return executeWithSession(userSessionId, null, params, logger, new IbatisSessionCallback<Integer>() {
			@Override
			public Integer doInSession(SqlMapSession ssn) throws Exception {
				return (Integer) ssn.queryForObject("integ.get-mcw-frauds-count", convertQueryParams(params));
			}
		});
	}

	public void createMcwFraud(Long userSessionId, final McwFraud fraud) throws UserException {
		executeWithSession(userSessionId,logger, new IbatisSessionCallback<Void>() {
			@Override
			public Void doInSession(SqlMapSession ssn) throws Exception {
				Long id = (Long) ssn.insert("integ.create-mcw-fraud", fraud);
				fraud.setId(id);
				return null;
			}
		});
	}

	public void updateMcwFraud(Long userSessionId, final McwFraud fraud) throws UserException {
		executeWithSession(userSessionId,logger, new IbatisSessionCallback<Void>() {
			@Override
			public Void doInSession(SqlMapSession ssn) throws Exception {
				ssn.update("integ.update-mcw-fraud", fraud);
				return null;
			}
		});
	}

	public void deleteMcwFraud(Long userSessionId, final Long id) throws UserException {
		executeWithSession(userSessionId,logger, new IbatisSessionCallback<Void>() {
			@Override
			public Void doInSession(SqlMapSession ssn) throws Exception {
				Map<String, Object> map = new HashMap<String, Object>();
				map.put("id", id);
				ssn.delete("integ.delete-mcw-fraud", map);
				return null;
			}
		});
	}

    private FinOverviewFees getFinancialOverviewFees(Long userSessionId, final Map<String, Object> map)
            throws UserException {
        return executeWithSession(userSessionId, logger, new IbatisSessionCallback<FinOverviewFees>() {
	        @Override
            public FinOverviewFees doInSession(SqlMapSession ssn) throws Exception {
                FinOverviewFees out = null;
                ssn.queryForObject("integ.get-financial-overview-fees", map);
                if (map.get("cursor") != null && ((List) map.get("cursor")).size() > 0) {
                    out = new FinOverviewFees();
                    out.getFee().addAll((List<FinOverviewFee>) map.get("cursor"));
                }
                return out;
            }
        });
    }

    private CrdPmntPayments getCreditCardPaymentsValues(Long userSessionId, final Map<String, Object> map) throws UserException {
        return executeWithSession(userSessionId, logger, new IbatisSessionCallback<CrdPmntPayments>() {
	        @Override
            public CrdPmntPayments doInSession(SqlMapSession ssn) throws Exception {
                CrdPmntPayments out = null;
                ssn.queryForObject("integ.get-credit-card-payment-payments", map);
                if (map.get("cursor") != null && ((List) map.get("cursor")).size() > 0) {
                    out = new CrdPmntPayments();
                    out.getPayment().addAll((List<CrdPmntPayment>) map.get("cursor"));
                }
                return out;
            }
        });
    }

    private void changeStateParamMap(Map<String, Object> map, String contactId) {
        map.put("contact_id", Long.valueOf(contactId));
    }

    private void changeStateParamMap(Map<String, Object> map, String entityType, String objectId) {
        map.put("entity_type", entityType);
        map.put("object_id", Integer.valueOf(objectId));
    }

    private void changeStateParamMap(Map<String, Object> map, String objectId, String tableName, String columnName, String lang) {
        map.put("object_id", Integer.valueOf(objectId));
        map.put("table_name", tableName);
        map.put("column_name", columnName);
        map.put("lang", lang);
    }

    private void changeStateParamMap(Map<String, Object> map, String tableName, String columnName, String dict, String code, String lang) {
        map.put("table_name", tableName);
        map.put("column_name", columnName);
        map.put("dict", dict);
        map.put("code", code);
        map.put("lang", lang);
    }

    private void clearStateParamMap(Map<String, Object> map) {
        map.clear();
    }

    private InstitutionType generateInstObject(Institute institute,
                                               List<NetworkType> networkTypes,
                                               List<LangNameType> instNames,
                                               List<LangNameType> instDescriptions,
                                               List<LangNameType> instTypesNames) {

        InstitutionType instType = new InstitutionType();
        instType.setId(institute.getId());
        instType.setSeqnum(institute.getSeqnum());
        instType.setParentId(institute.getParentId());

        instType.getName().addAll(instNames);
        instType.getDescription().addAll(instDescriptions);

        instType.getNetwork().addAll(networkTypes);

        if (institute.getInstType() != null) {
            DictEntryType dictEntryType = new DictEntryType();
            dictEntryType.setCode(institute.getInstType());
            dictEntryType.getName().addAll(instTypesNames);
            instType.setInstType(dictEntryType);
        }
        return instType;
    }

    private CustomerInfoCard fillCustomerInfoCardBlock(final Map<String, Object> map) {
        CustomerInfoCard out = new CustomerInfoCard();
        boolean dataExist = false;
        if (map.get("card_number") != null) {
            dataExist = true;
            out.setCardNumber((String) map.get("card_number"));
        }
        if (map.get("card_id") != null) {
            dataExist = true;
            out.setCardId((String) map.get("card_id"));
        }
        if (map.get("card_seq_number") != null) {
            dataExist = true;
            out.setCardSeqNumber((Integer) map.get("card_seq_number"));
        }
        if (map.get("card_expiry_date") != null) {
            dataExist = true;
            out.setCardExpiryDate((XMLGregorianCalendar) map.get("card_expiry_date"));
        }
        if (map.get("client_tariff") != null) {
            dataExist = true;
            out.setClientTariff((String) map.get("client_tariff"));
        }
        return dataExist ? out : null;
    }

    private CustomerInfoCustomer fillCustomerInfoCustomerBlock(final Map<String, Object> map) {
        CustomerInfoCustomer out = new CustomerInfoCustomer();
        boolean dataExist = false;
        if (map.get("customer_name") != null) {
            dataExist = true;
            out.setCustomerName((String) map.get("customer_name"));
        }
        if (map.get("customer_number") != null) {
            dataExist = true;
            out.setCustomerNumber((String) map.get("customer_number"));
        }
        if (map.get("customer_phone") != null) {
            dataExist = true;
            out.getCustomerPhoneNumber().add((String) map.get("customer_phone"));
        }
        if (map.get("national_id") != null) {
            dataExist = true;
            out.setNationalId((String) map.get("national_id"));
        } else if (map.get("customer_document") != null) {
            dataExist = true;
            out.setCustomerDocument((String) map.get("customer_document"));
        }
        if (map.get("branch_code") != null) {
            dataExist = true;
            out.setBranchCode((String) map.get("branch_code"));
        }
        if (map.get("address_cursor") != null && ((List<CustomerInfoAddress>) map.get("address_cursor")).size() > 0) {
            dataExist = true;
            out.setAddresses(new CustomerInfoAddresses());
            out.getAddresses().getAddress().addAll((List<CustomerInfoAddress>) map.get("address_cursor"));
        }
        return dataExist ? out : null;
    }

    private CustomerInfoAccounts fillCustomerInfoAccountsBlock(final Map<String, Object> map) {
        CustomerInfoAccounts out = null;
        if (map.get("account_cursor") != null && ((List<CustomerInfoAccount>) map.get("account_cursor")).size() > 0) {
            out = new CustomerInfoAccounts();
            out.getAccount().addAll((List<CustomerInfoAccount>) map.get("account_cursor"));
        }
        return out;
    }

    private void fillCardholder(Cardholder cardholder, Map<String, Object> map) throws DatatypeConfigurationException {
	    if (map.get("birthday") != null) {
		    GregorianCalendar cal = new GregorianCalendar();
		    cal.setTime((Date) map.get("birthday"));
		    cardholder.setBirthday(DatatypeFactory.newInstance().newXMLGregorianCalendar(cal));
	    } else {
		    cardholder.setBirthday(null);
	    }
	    cardholder.setGender((String) map.get("gender"));
	    cardholder.setSurname((String) map.get("surname"));
	    cardholder.setFirstName((String) map.get("first_name"));
	    cardholder.setSecondName((String) map.get("second_name"));
	    cardholder.setCardholderNumber((String) map.get("cardholder_number"));
	    cardholder.setCardholderName((String) map.get("cardholder_name"));
    }
}
