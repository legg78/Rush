package ru.bpc.sv2.ui.common.wizard.callcenter.account;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;
import ru.bpc.sv2.accounts.Account;
import ru.bpc.sv2.accounts.AccountConstants;
import ru.bpc.sv2.accounts.AccountPrivConstants;
import ru.bpc.sv2.acquiring.Merchant;
import ru.bpc.sv2.common.WizardConstants;
import ru.bpc.sv2.constants.EntityNames;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.*;
import ru.bpc.sv2.loyalty.LoyaltyBonus;
import ru.bpc.sv2.operations.Participant;
import ru.bpc.sv2.operations.constants.OperationsConstants;
import ru.bpc.sv2.operations.incoming.Operation;
import ru.bpc.sv2.orgstruct.Institution;
import ru.bpc.sv2.products.Customer;
import ru.bpc.sv2.ui.common.wizard.AbstractWizardStep;
import ru.bpc.sv2.ui.common.wizard.application.ApplicationBuilder;
import ru.bpc.sv2.ui.common.wizard.callcenter.MbOperTypeSelectionStep;
import ru.bpc.sv2.ui.products.MbCustomersDependent;
import ru.bpc.sv2.ui.utils.DictUtils;
import ru.bpc.sv2.ui.utils.FacesUtils;
import util.auxil.ManagedBeanWrapper;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.model.SelectItem;
import java.math.BigDecimal;
import java.util.*;

@ViewScoped
@ManagedBean(name = "MbAccountFundsTransferDS")
public class MbAccountFundsTransferDS extends AbstractWizardStep {
    private static final Logger logger = Logger.getLogger(MbAccountFundsTransferDS.class);
    private static final String PAGE = "/pages/common/wizard/callcenter/account/accountFundsTransferDS.jspx";
    private static final String SOURCE_ACCOUNT = "SOURCE_ACCOUNT";
    private static final String DEST_ACCOUNT = "DEST_ACCOUNT";
    private static final String OPERATION = "OPERATION";
    private static final String OPERATION_TYPE = "OPTP0040";
    private static final String US_ON_US = "STTT0010";
    private static final Integer THRESHOLD = 300;
    private static final String BUNDLE = "ru.bpc.sv2.ui.bundles.Acc";

    private List<SelectItem> operReasons;
    private List<Filter> filters;
    private Map<String, Object> paramMap;
    private Long objectId;

    private Account sourceAccount;
    private Operation operation;
    private Account destAccount;

    private Customer customer;
    private List<Account> destAccounts;
    private Map<String, String> participantTypes;
    private SimpleSelection itemSelection;
    private Integer rowsNum;

    private AccountsDao accountsDao = new AccountsDao();
    private OperationDao operationDao = new OperationDao();
    private OrgStructDao structureDao = new OrgStructDao();
    private AcquiringDao acquiringDao = new AcquiringDao();
    private LoyaltyDao loyaltyDao = new LoyaltyDao();
    private ApplicationDao applicationDao = new ApplicationDao();

    @Override
    public void init(Map<String, Object> context) throws IllegalStateException {
        super.init(context, PAGE, true);
        logger.trace("init...");
        reset();

        if (!((String) context.get(MbOperTypeSelectionStep.ENTITY_TYPE)).equalsIgnoreCase(EntityNames.ACCOUNT)) {
            throw new IllegalStateException(FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Common", "account_error"));
        }
        if (context.containsKey(MbOperTypeSelectionStep.OBJECT_ID)) {
            objectId = (Long) context.get(MbOperTypeSelectionStep.OBJECT_ID);
            sourceAccount = accountById(objectId);
        } else {
            throw new IllegalStateException(MbOperTypeSelectionStep.OBJECT_ID + " is not defined in wizard step context");
        }

        participantTypes = new HashMap<String, String>();
        participantTypes.put(Participant.ACQ_PARTICIPANT, "ACQ");
        participantTypes.put(Participant.ISS_PARTICIPANT, "ISS");
        participantTypes.put(Participant.DESTINATION_PARTICIPANT, "DST");
        participantTypes.put(Participant.PAYMENT_AGGREGATOR_PARTICIPANT, "AGR");

        initAccountsSource();
        initAccountsCustomer();
        initOperation();
    }

    @Override
    public Map<String, Object> release(Direction direction) {
        logger.trace("release...");
        if (direction == Direction.FORWARD) {
            transferFunds();
            getContext().put(MbOperTypeSelectionStep.ENTITY_TYPE, EntityNames.ACCOUNT);
            getContext().put(SOURCE_ACCOUNT, sourceAccount);
            getContext().put(DEST_ACCOUNT, destAccount);
            getContext().put(OPERATION, operation);
        } else {
            reset();
        }
        return getContext();
    }

    @Override
    public boolean validate() {
        logger.trace("validate...");
        String key = null;

        if (!AccountConstants.ACCOUNT_STATUS_ACTIVE.equals(sourceAccount.getStatus())) {
            FacesUtils.addMessageInfo(FacesUtils.getMessage(BUNDLE, "scr_acc_not_active"));
        } else if (destAccount != null) {
            if (AccountConstants.ACCOUNT_STATUS_ACTIVE.equals(destAccount.getStatus())) {
                if (operation.getOperationAmount().compareTo(sourceAccount.getBalance()) <= 0) {
                    if (AccountConstants.ACCOUNT_TYPE_LOYALTY.equals(sourceAccount.getAccountType())) {
                        BigDecimal amount = getActiveLoyaltyTotalAmount();
                        if (amount.compareTo(operation.getOperationAmount()) < 0) {
                            key = "active_loyal_amt_not_enough";
                        } else {
                            return true;
                        }
                    } else {
                        return true;
                    }
                } else {
                    key = "transfer_amt_ckeck";
                }
            } else {
                key = "dest_acc_not_active";
            }
        } else {
            key = "dest_acc_not_selected";
        }

        if (key != null) {
            FacesUtils.addMessageError(FacesUtils.getMessage(BUNDLE, key));
        }
        return false;
    }

    private void reset() {
        sourceAccount = null;
        destAccount = null;
        destAccounts = null;
        itemSelection = null;
        operation = null;
        paramMap = null;
        operReasons = null;
        rowsNum = 20;
    }

    private Account accountById(Long id) {
        logger.trace("Get account by object id [" + id + "]");
        SelectionParams sp = SelectionParams.build("id", id);
        Account[] accounts = accountsDao.getAccounts(userSessionId, sp);
        return accounts.length != 0 ? accounts[0] : null;
    }

    private void setFilter(String element, Object value) {
        setFilter(element, value, null);
    }

    private void setFilter(String element, Object value, Filter.Operator operator) {
        Filter filter = new Filter();
        filter.setElement(element);
        if (operator != null) {
            filter.setOp(operator);
        }
        filter.setValue(value);
        filters.add(filter);
    }

    private void setFilters() {
        filters = new ArrayList<Filter>();
        setFilter("LANG", curLang);
	    setFilter("STATUS", AccountConstants.ACCOUNT_STATUS_ACTIVE
			    + "," + AccountConstants.ACCOUNT_STATUS_CREDITS_ONLY, Filter.Operator.eq);

        if (participantTypes.get(getContext().get(MbOperTypeSelectionStep.OBJECT_TYPE)) != null) {
            setFilter("PARTICIPANT_MODE", participantTypes.get(getContext().get(MbOperTypeSelectionStep.OBJECT_TYPE)));
        } else {
            setFilter("PARTICIPANT_MODE", participantTypes.get(getContext().get(Participant.ISS_PARTICIPANT)));
        }
        if (sourceAccount.getCustomerNumber() != null && sourceAccount.getCustomerNumber().trim().length() > 0) {
            setFilter("CUSTOMER_NUMBER", sourceAccount.getCustomerNumber().trim().toUpperCase().replaceAll("[*]", "%").replaceAll("[?]", "_"));
        }
        if (sourceAccount.getCustomerId() != null) {
            setFilter("CUSTOMER_ID", sourceAccount.getCustomerId());
        }
        if (getParamMap().get("param_tab") != null) {
            getParamMap().remove("param_tab");
        }
        if (getParamMap().get("tab_name") != null) {
            getParamMap().remove("tab_name");
        }
        getParamMap().put("param_tab", filters.toArray(new Filter[filters.size()]));
        getParamMap().put("tab_name", "ACCOUNT");
    }

    private void initAccountsSource() {
        setFilters();
        if (accountsDao.getAccountsCountCur(userSessionId, getParamMap()) > 0) {
            setFilters();
            SelectionParams params = new SelectionParams();
            params.setFilters(filters.toArray(new Filter[filters.size()]));
            params.setThreshold(THRESHOLD);
            params.setRowIndexEnd(getRowsNum());
            Account[] accounts = accountsDao.getAccountsCur(userSessionId, params, getParamMap());
            destAccounts = new ArrayList<Account>(Arrays.asList(accounts));
            for (Iterator<Account> iterator = destAccounts.iterator(); iterator.hasNext(); ) {
                Account account = iterator.next();
                if (sourceAccount.getId().equals(account.getId())) {
                    iterator.remove();
                }
            }
        }
    }

    private void initAccountsCustomer() {
        MbCustomersDependent bean = (MbCustomersDependent) ManagedBeanWrapper.getManagedBean("MbCustomersDependent");
        bean.getParams().setPrivilege(AccountPrivConstants.VIEW_ACCOUNT);
        customer = bean.getCustomer(sourceAccount.getCustomerId());
        sourceAccount.setCustomerNumber(customer.getCustomerNumber());
        sourceAccount.setCustInfo(customer.getPerson().getFullName());
    }

    private void initOperation() {
        operation = new Operation();
        operation.setOperType(OPERATION_TYPE);
        operation.setMsgType(OperationsConstants.MESSAGE_TYPE_AUTHORIZATION);
        operation.setStatus(OperationsConstants.OPERATION_STATUS_PROCESS_READY);
        operation.setSttlType(US_ON_US);
        operation.setOperationAmount(sourceAccount.getBalance());
        operation.setOperationCurrency(sourceAccount.getCurrency());
        operation.setOperationDate(new Date());
        operation.setSourceHostDate(new Date());
        operation.setOperationCurrency(sourceAccount.getCurrency());
    }

    private Integer getInstitutionNetwork(Integer instId) {
        logger.trace("Get institution network...");
        Integer result = null;
        SelectionParams sp = SelectionParams.build("instId", instId);
        try {
            Institution[] insts = structureDao.getInstitutions(userSessionId, sp, curLang, false);
            if (insts != null) {
                for (int i = 0; i < insts.length; i++) {
                    if (insts[i].getNetworkId() != null) {
                        result = insts[i].getNetworkId();
                        break;
                    }
                }
            }
        } catch (Exception e) {
            logger.error("", e);
        }
        return result;
    }

    private void setMerchantForOperation(Account account) {
        Map<String, Object> accountParamsMap = new HashMap<String, Object>();
        accountParamsMap.put("accountId", account.getId());
        accountParamsMap.put("entityType", EntityNames.MERCHANT);
        Long merchantId = null;
        try {
            merchantId = acquiringDao.getAccountObjectId(userSessionId, accountParamsMap);
        } catch (Exception e) {
        }

        if (merchantId != null) {
            operation.setMerchantId(merchantId.intValue());
            List<Filter> filters = new ArrayList<Filter>();
            filters.add(new Filter("INST_ID", account.getInstId()));
            filters.add(new Filter("CONTRACT_ID", account.getContractId()));
            filters.add(new Filter("MERCHANT_ID", merchantId));
            filters.add(new Filter("LANG", curLang));
            SelectionParams params = new SelectionParams();
            params.setRowIndexEnd(Integer.MAX_VALUE);
            params.setFilters((Filter[]) filters.toArray(new Filter[filters.size()]));
            Map<String, Object> paramsMap = new HashMap<String, Object>();
            paramsMap.put("param_tab", (Filter[]) filters.toArray(new Filter[filters.size()]));
            paramsMap.put("tab_name", "CONTRACT");
            Merchant[] merchants = null;

            try {
                merchants = acquiringDao.getMerchantsCur(userSessionId, params, paramsMap);
            } catch (Exception e) {
            }

            if (merchants != null) {
                for (int i = 0; i < merchants.length; i++) {
                    if (merchantId.equals(merchants[i].getId())) {
                        operation.setMerchantNumber(merchants[i].getMerchantNumber());
                        operation.setMerchantName(merchants[i].getMerchantName());
                        break;
                    }
                }
            }
        }
    }

    private void setSourceParticipant() {
        operation.setParticipantType(getContext().get(MbOperTypeSelectionStep.OBJECT_TYPE).toString());
        operation.setAccountId(sourceAccount.getId());
        operation.setAccountNumber(sourceAccount.getAccountNumber());
        operation.setAccountType(sourceAccount.getAccountType());
        operation.setClientIdValue(sourceAccount.getAccountNumber());
        operation.setAccountCurrency(sourceAccount.getCurrency());
        operation.setIssInstId(sourceAccount.getInstId());
        operation.setIssNetworkId(getInstitutionNetwork(sourceAccount.getInstId()));
        operation.setCardNetworkId(operation.getIssNetworkId());
        operation.setSplitHash(sourceAccount.getSplitHash());
        if (Participant.ISS_PARTICIPANT.equals(getContext().get(MbOperTypeSelectionStep.OBJECT_TYPE).toString())) {
            operation.setSplitHashIss(sourceAccount.getSplitHash());
        } else if (Participant.ACQ_PARTICIPANT.equals(getContext().get(MbOperTypeSelectionStep.OBJECT_TYPE).toString())) {
            operation.setSplitHashAcq(sourceAccount.getSplitHash());
        }
        operation.setAccountAmount(sourceAccount.getBalance());
        operation.setAccountCurrency(sourceAccount.getCurrency());
        operation.setCustomerId(sourceAccount.getCustomerId());
        setMerchantForOperation(sourceAccount);
    }

    private void setDestParticipant() {
        operation.setParticipantType(Participant.DESTINATION_PARTICIPANT);
        operation.setAccountId(destAccount.getId());
        operation.setAccountNumber(destAccount.getAccountNumber());
        operation.setAccountType(destAccount.getAccountType());
        operation.setClientIdValue(destAccount.getAccountNumber());
        operation.setAccountCurrency(destAccount.getCurrency());
        operation.setIssInstId(destAccount.getInstId());
        operation.setIssNetworkId(getInstitutionNetwork(destAccount.getInstId()));
        operation.setCardNetworkId(operation.getIssNetworkId());
        operation.setSplitHash(destAccount.getSplitHash());
        if (Participant.ISS_PARTICIPANT.equals(getContext().get(MbOperTypeSelectionStep.OBJECT_TYPE).toString())) {
            operation.setSplitHashIss(destAccount.getSplitHash());
        } else if (Participant.ACQ_PARTICIPANT.equals(getContext().get(MbOperTypeSelectionStep.OBJECT_TYPE).toString())) {
            operation.setSplitHashAcq(destAccount.getSplitHash());
        }
        operation.setAccountAmount(destAccount.getBalance());
        operation.setAccountCurrency(destAccount.getCurrency());
        operation.setCustomerId(destAccount.getCustomerId());
        setMerchantForOperation(destAccount);
    }

    private void transferFunds() {
        logger.trace("Transfer account funds...");
        try {
            if (isMaker()) {
                setSourceParticipant();
                ApplicationBuilder builder = new ApplicationBuilder(applicationDao, userSessionId, sourceAccount.getInstId(), getFlowId());
                builder.buildFromOperation(operation, true);
                setDestParticipant();
                builder.addParticipant(operation);
                builder.createApplicationInDB();
                builder.addApplicationObject(sourceAccount);
                getContext().put(WizardConstants.OPER_STATUS, builder.getApplication().getStatus());
            } else {
                setSourceParticipant();
                operationDao.addAdjusment(userSessionId, operation);
                setDestParticipant();
                operationDao.addParticipant(userSessionId, operation);
                operationDao.processOperation(userSessionId, operation.getId());
                Long id = sourceAccount.getId();
                sourceAccount = accountById(id);
                id = destAccount.getId();
                destAccount = accountById(id);
                initAccountsCustomer();
                getDestAccount().setCustomerNumber(customer.getCustomerNumber());
                getDestAccount().setCustInfo(customer.getPerson().getFullName());
            }
        } catch (Exception e) {
            throw new IllegalStateException(e);
        }
    }

    private BigDecimal getActiveLoyaltyTotalAmount() {
        BigDecimal total = new BigDecimal(0);
        try {
            List<Filter> filters = new ArrayList<Filter>(2);
            SelectionParams params = new SelectionParams();

            filters.add(Filter.create("accountId", sourceAccount.getId()));
            filters.add(Filter.create("lang", curLang));
            params.setFilters(filters);
            params.setRowIndexEnd(Integer.MAX_VALUE);

            LoyaltyBonus[] bonuses = loyaltyDao.getLoyaltyBonuses(userSessionId, params);

            if (bonuses != null) {
                Double amount = 0.0;
                Double spent = 0.0;
                for (LoyaltyBonus bonus : bonuses) {
                    if (AccountConstants.LOYALTY_POINTS_ACTIVE.equals(bonus.getStatus())) {
                        amount = (bonus.getAmount() != null) ? bonus.getAmount() : 0.0;
                        spent = (bonus.getSpentAmount() != null) ? bonus.getSpentAmount() : 0.0;
                        total = total.add(BigDecimal.valueOf(amount - spent));
                    }
                }
            }
        } catch (Exception e) {
            logger.debug("", e);
        }
        return total;
    }

    public List<Account> getDestAccounts() {
        return destAccounts;
    }

    public int getRowsNum() {
        return rowsNum;
    }

    public void setRowsNum(int rowsNum) {
        this.rowsNum = rowsNum;
    }

    public SimpleSelection getItemSelection() {
        return itemSelection;
    }

    public void setItemSelection(SimpleSelection selection) {
        logger.trace("setItemSelection...");
        itemSelection = selection;
        if (itemSelection != null && getDestAccounts() != null && getDestAccounts().size() > 0) {
            Iterator<Object> keys = itemSelection.getKeys();
            if (keys.hasNext()) {
                setDestAccount(getDestAccounts().get((Integer) keys.next()));
                getDestAccount().setCustomerNumber(customer.getCustomerNumber());
                getDestAccount().setCustInfo(customer.getPerson().getFullName());
            }
        }
    }

    public Account getSourceAccount() {
        return sourceAccount;
    }

    public void setSourceAccount(Account sourceAccount) {
        this.sourceAccount = sourceAccount;
    }

    public Account getDestAccount() {
        return destAccount;
    }

    public void setDestAccount(Account destAccount) {
        this.destAccount = destAccount;
    }

    public Customer getCustomer() {
        return customer;
    }

    public void setCustomer(Customer customer) {
        this.customer = customer;
    }

    public Map<String, Object> getParamMap() {
        if (paramMap == null) {
            paramMap = new HashMap<String, Object>();
        }
        return paramMap;
    }

    public void setParamMap(Map<String, Object> paramMap) {
        this.paramMap = paramMap;
    }

    public Operation getOperation() {
        return operation;
    }

    public void setOperation(Operation operation) {
        this.operation = operation;
    }

    public List<Object> getEmptyTable() {
        List<Object> emptyTable = new ArrayList<Object>(1);
        emptyTable.add(new Object());
        return emptyTable;
    }

    public List<SelectItem> getOperReasons() {
        if (operReasons == null) {
            DictUtils dictUtils = (DictUtils) ManagedBeanWrapper.getManagedBean("DictUtils");
            if (dictUtils != null) {
                operReasons = dictUtils.getLov(LovConstants.OPER_REASON);
            } else {
                operReasons = new ArrayList<SelectItem>();
            }
        }
        return operReasons;
    }
}
