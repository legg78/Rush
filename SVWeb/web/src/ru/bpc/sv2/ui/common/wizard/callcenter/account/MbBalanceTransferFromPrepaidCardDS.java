package ru.bpc.sv2.ui.common.wizard.callcenter.account;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;
import ru.bpc.sv2.accounts.Account;
import ru.bpc.sv2.acquiring.Merchant;
import ru.bpc.sv2.application.Application;
import ru.bpc.sv2.common.WizardConstants;
import ru.bpc.sv2.constants.EntityNames;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.constants.ModuleNames;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.issuing.Card;
import ru.bpc.sv2.logic.*;
import ru.bpc.sv2.operations.Participant;
import ru.bpc.sv2.operations.constants.OperationsConstants;
import ru.bpc.sv2.operations.incoming.Operation;
import ru.bpc.sv2.orgstruct.Institution;
import ru.bpc.sv2.ui.common.wizard.AbstractWizardStep;
import ru.bpc.sv2.ui.common.wizard.application.ApplicationBuilder;
import ru.bpc.sv2.ui.common.wizard.callcenter.MbOperTypeSelectionStep;
import ru.bpc.sv2.ui.issuing.MbCardSearchModal;
import ru.bpc.sv2.ui.utils.DictUtils;
import ru.bpc.sv2.ui.utils.FacesUtils;
import util.auxil.ManagedBeanWrapper;
import util.auxil.SessionWrapper;

import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.model.SelectItem;
import java.math.BigDecimal;
import java.util.*;

@ViewScoped
@ManagedBean (name = "MbBalanceTransferFromPrepaidCardDS")
public class MbBalanceTransferFromPrepaidCardDS extends AbstractWizardStep {
    private static final Logger logger = Logger.getLogger(MbBalanceTransferFromPrepaidCardDS.class);
    private static final String PAGE = "/pages/common/wizard/callcenter/account/balanceTransferFromPrepaidCardDS.jspx";
    private static final String PREPAID_CARD = "CNTPPRPD";

    private Account sourceAccount;
    private Account destAccount;
    private Card sourceCard;
    private BigDecimal amount;
    private String reason;
    private List<SelectItem> reasons;
    private List<Account> accounts;
    private SimpleSelection selection;
    private Integer rowsNum;
    private Application application;

    private OrgStructDao structureDao = new OrgStructDao();
    private AcquiringDao acquiringDao = new AcquiringDao();
    private OperationDao operationDao = new OperationDao();
    private AccountsDao accountsDao = new AccountsDao();
    private ApplicationDao applicationDao = new ApplicationDao();

    public MbBalanceTransferFromPrepaidCardDS() {
        setMakerCheckerMode(Mode.MAKER);
    }

    @Override
    public void init(Map<String, Object> context) {
        super.init(context, PAGE, true);
        logger.trace("init...");
        reset();
        userSessionId = Long.parseLong(SessionWrapper.getField("userSessionId"));
        curLang = SessionWrapper.getField("language");
        if (!((String)context.get(WizardConstants.ENTITY_TYPE)).equalsIgnoreCase(EntityNames.ACCOUNT)) {
            throw new IllegalStateException(FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Common", "account_error"));
        }
        if (context.containsKey(WizardConstants.OBJECT_ID)) {
            destAccount = accountById((Long)context.get(WizardConstants.OBJECT_ID));
        } else {
            throw new IllegalStateException(WizardConstants.OBJECT_ID + " is not defined in wizard step context");
        }
    }


    @Override
    public Map<String, Object> release(Direction direction) {
        logger.trace("release...");
        if (direction == Direction.FORWARD) {
            getContext().put(WizardConstants.ENTITY_TYPE, EntityNames.ACCOUNT);
            getContext().put(WizardConstants.APP_STATUS, transfer());
            getContext().put(WizardConstants.APPLICATION, application);
            getContext().put(WizardConstants.SOURCE_CARD, sourceCard);
            getContext().put(WizardConstants.SOURCE_ACCOUNT, sourceAccount);
            getContext().put(WizardConstants.DEST_ACCOUNT, destAccount);
            getContext().put(WizardConstants.AMOUNT, amount);
        }
        return getContext();
    }

    @Override
    public boolean validate() {
        if (sourceCard == null || sourceCard.getId() == null) {
            FacesUtils.addMessageError("Source card is not defined");
            return false;
        } else if (destAccount == null || destAccount.getId() == null) {
            FacesUtils.addMessageError("Destination account is not defined");
            return false;
        } else if (sourceAccount == null || sourceAccount.getId() == null) {
            FacesUtils.addMessageError("Source account is not defined");
            return false;
        } else if (amount == null) {
            FacesUtils.addMessageError("Transfer amount is not defined");
            return false;
        } else if (amount.compareTo(sourceAccount.getBalance()) > 0) {
            FacesUtils.addMessageError("Transfer amount cannot be greater than source available balance");
            return false;
        }
        return true;
    }

    public Account getSourceAccount() {
        return sourceAccount;
    }
    public void setSourceAccount(Account sourceAccount) {
        this.sourceAccount = sourceAccount;
    }

    public Account getDestAccount() {
        if (destAccount == null) {
            destAccount = new Account();
        }
        return destAccount;
    }
    public void setDestAccount(Account destAccount) {
        this.destAccount = destAccount;
    }

    public Card getSourceCard() {
        if (sourceCard == null) {
            sourceCard = new Card();
        }
        return sourceCard;
    }
    public void setSourceCard(Card sourceCard) {
        this.sourceCard = sourceCard;
    }

    public BigDecimal getAmount() {
        return amount;
    }
    public void setAmount(BigDecimal amount) {
        this.amount = amount;
    }

    public String getReason() {
        return reason;
    }
    public void setReason(String reason) {
        this.reason = reason;
    }

    public List<SelectItem> getReasons() {
        if (reasons == null) {
            DictUtils dictUtils = (DictUtils) ManagedBeanWrapper.getManagedBean("DictUtils");
            if (dictUtils != null) {
                reasons = dictUtils.getLov(LovConstants.OPER_REASON);
            } else {
                reasons = new ArrayList<SelectItem>();
            }
        }
        return reasons;
    }
    public List<Account> getAccounts() {
        if (accounts == null) {
            accounts = new ArrayList<Account>();
        }
        return accounts;
    }

    public void showCards() {
        MbCardSearchModal bean = (MbCardSearchModal)ManagedBeanWrapper.getManagedBean("MbCardSearchModal");
        bean.clearFilter();
        bean.getFilter().setContractType(PREPAID_CARD);
        bean.setModule(ModuleNames.OPERATION_PROCESSING);
    }
    public void selectCard() {
        MbCardSearchModal bean = (MbCardSearchModal)ManagedBeanWrapper.getManagedBean("MbCardSearchModal");
        sourceCard = bean.getActiveCard();
        if (sourceCard != null) {
            try {
                accounts = accountsDao.getAccountsByCardId(userSessionId, sourceCard.getId());
            } catch (Exception e) {
                logger.error(e.getMessage(), e);
                FacesUtils.addMessageError(e);
            }
        }
    }

    public int getRowsNum() {
        return rowsNum;
    }
    public void setRowsNum(int rowsNum) {
        this.rowsNum = rowsNum;
    }

    public SimpleSelection getItemSelection() {
        return selection;
    }
    public void setItemSelection(SimpleSelection selection) {
        this.selection = selection;
        if (this.selection != null && accounts != null && accounts.size() > 0) {
            Iterator<Object> key = this.selection.getKeys();
            if (key.hasNext()) {
                setSourceAccount(accounts.get((Integer)key.next()));
                if (getSourceAccount() != null) {
                    amount = getSourceAccount().getBalance();
                }
            }
        }
    }

    public List<Object> getEmptyTable() {
        List<Object> emptyTable = new ArrayList<Object>(1);
        emptyTable.add(new Object());
        return emptyTable;
    }

    private void reset() {
        sourceAccount = null;
        destAccount = null;
        sourceCard = null;
        reasons = null;
        accounts = null;
        reason = null;
        amount = null;
        rowsNum = 10;
        selection = null;
    }

    private Account accountById(Long id) throws IllegalStateException {
        logger.trace("Get account by object id [" + id + "]");
        SelectionParams sp = SelectionParams.build("id", id);
        Account[] accounts = accountsDao.getAccounts(userSessionId, sp);
        if (accounts.length <= 0) {
            throw new IllegalStateException("Failed to find account by ID [" + id + "]");
        }
        return accounts[0];
    }

    private String transfer() {
        logger.trace("transfer...");
        Operation operation = new Operation();

        operation.setOperType(OperationsConstants.OPERATION_TYPE_INTERNAL_TRANSFER);
        operation.setMsgType(OperationsConstants.MESSAGE_TYPE_AUTHORIZATION);
        operation.setStatus(OperationsConstants.OPERATION_STATUS_PROCESS_READY);
        operation.setSttlType(WizardConstants.US_ON_US);
        operation.setOperationAmount((amount != null) ? amount : sourceAccount.getBalance());
        operation.setOperationCurrency(sourceAccount.getCurrency());
        operation.setOperationDate(new Date());
        operation.setOperReason(reason);
        operation.setSourceHostDate(new Date());
        operation.setReversal(false);
        operation.setCardNumber(sourceCard.getCardNumber());

        Merchant merchant = getMerchant(sourceAccount);
        if (merchant != null) {
            operation.setMerchantId(merchant.getId().intValue());
            operation.setMerchantName(merchant.getMerchantName());
            operation.setMerchantNumber(merchant.getMerchantNumber());
        }

        fillOperationParticipant(operation, getContext().get(MbOperTypeSelectionStep.OBJECT_TYPE).toString(), sourceAccount, sourceCard);

        if (isMaker()) {
            ApplicationBuilder builder = new ApplicationBuilder(applicationDao, userSessionId, sourceAccount.getInstId(), getFlowId());
            builder.buildFromOperation(operation, true);
            fillOperationParticipant(operation, Participant.DESTINATION_PARTICIPANT, destAccount, null);
            builder.addParticipant(operation);
            builder.createApplicationInDB();
            application = builder.getApplication();
            return builder.getApplication().getStatus();
        } else {
            operationDao.addAdjusment(userSessionId, operation);
            fillOperationParticipant(operation, Participant.DESTINATION_PARTICIPANT, destAccount, null);
            operationDao.addParticipant(userSessionId, operation);
            return operationDao.processOperation(userSessionId, operation.getId());
        }
    }

    private void fillOperationParticipant(Operation operation, String type, Account account, Card card) {
        operation.setParticipantType(type);

        if (account != null) {
            operation.setAccountId(account.getId());
            operation.setAccountNumber(account.getAccountNumber());
            operation.setAccountType(account.getAccountType());
            operation.setClientIdType(OperationsConstants.IDENT_TYPE_ACCOUNT);
            operation.setClientIdValue(account.getAccountNumber());
            operation.setAccountCurrency(account.getCurrency());
            operation.setIssInstId(account.getInstId());
            operation.setCardInstId(account.getInstId());
            operation.setSplitHash(account.getSplitHash());
            operation.setAccountAmount(account.getBalance());
            operation.setCustomerId(account.getCustomerId());

            Integer network = getNetwork(account.getInstId());
            operation.setIssNetworkId(network);
            operation.setCardNetworkId(network);
        }

        if (card != null) {
            operation.setCardId(card.getId());
            operation.setCardNumber(card.getCardNumber());
            operation.setCardMask(card.getMask());
            operation.setCardTypeId(card.getCardTypeId());
            operation.setCardExpirationDate(card.getExpDate());
            operation.setCardHash(card.getCardHash());
        }
    }

    private Merchant getMerchant(Account account) {
        Map <String, Object> accountParamsMap = new HashMap<String, Object>();
        accountParamsMap.put("accountId", account.getId());
        accountParamsMap.put("entityType", EntityNames.MERCHANT);
        Long merchantId = null;
        try {
            merchantId = acquiringDao.getAccountObjectId(userSessionId, accountParamsMap);
        } catch (Exception e) {}

        if (merchantId != null) {
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
            } catch (Exception e) {}

            if (merchants != null) {
                for (int i = 0; i < merchants.length; i++) {
                    if (merchantId.equals(merchants[i].getId())) {
                        return merchants[i];
                    }
                }
                if (merchants.length > 0) {
                    return merchants[0];
                }
            }
        }

        return null;
    }

    private Integer getNetwork(Integer instId) {
        Integer result = null;
        SelectionParams sp = SelectionParams.build("instId", instId, "lang", curLang);

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
        } catch(Exception e) {
            logger.error("", e);
        }
        return result;
    }

}
