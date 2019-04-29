package ru.bpc.sv2.ui.common.wizard.callcenter;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;
import ru.bpc.sv2.accounts.Account;
import ru.bpc.sv2.accounts.Balance;
import ru.bpc.sv2.common.Currency;
import ru.bpc.sv2.common.WizardConstants;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.*;
import ru.bpc.sv2.operations.incoming.Operation;
import ru.bpc.sv2.ui.common.wizard.AbstractWizardStep;
import ru.bpc.sv2.ui.common.wizard.application.ApplicationBuilder;
import ru.bpc.sv2.ui.utils.CurrencyCache;
import ru.bpc.sv2.ui.utils.DictUtils;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.utils.UserException;
import util.auxil.ManagedBeanWrapper;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.model.SelectItem;
import java.math.BigDecimal;
import java.util.*;

@ViewScoped
@ManagedBean(name = "MbBalanceCorrectionDS")
public class MbBalanceCorrectionDS extends AbstractWizardStep {
    private static final Logger classLogger = Logger.getLogger(MbBalanceCorrectionDS.class);
    private static final String PAGE = "/pages/common/wizard/callcenter/balanceCorrectionDS.jspx";
    private static final String OBJECT_ID = "OBJECT_ID";
    private static final String ACCOUNT = "ACCOUNT";

    private AccountsDao accountsDao = new AccountsDao();
    private OperationDao operationDao = new OperationDao();
    private OrgStructDao orgStructDao = new OrgStructDao();
    private IntegrationDao integrationDao = new IntegrationDao();
    private ApplicationDao applicationDao = new ApplicationDao();

    private Account account;
    private Balance[] balances;
    private String operType;
    private List<SelectItem> operTypes;
    private DictUtils dictUtils;
    private Double operAmount;
    private Balance selectedBalance;
    private SimpleSelection balanceSelection;
    private boolean invalidBalance;
    protected Date operDate;
    protected Date bookDate;
    protected Date invoiceDate;

    @Override
    public void init(Map<String, Object> context) {
        classLogger.trace("init...");
        reset();
        super.init(context, PAGE, true);
        dictUtils = ManagedBeanWrapper.getManagedBean(DictUtils.class);
        Long objectId = getContextRequired(OBJECT_ID);
        account = accountById(objectId);
        balances = balancesByAccount(account);

        operDate = new Date();
        bookDate = new Date();
        try {
            invoiceDate = integrationDao.getInvoiceDate(userSessionId, "ENTTACCT", objectId);
        } catch (UserException e) {
            classLogger.warn("Cannot get last invoice date, set date as null");
            invoiceDate = null;
        }
    }

    private Account accountById(Long id) {
        classLogger.trace("accountById...");
        Account result = null;
        SelectionParams sp = SelectionParams.build("id", id);
        Account[] accounts = accountsDao.getAccounts(userSessionId, sp);
        if (accounts.length != 0) {
            result = accounts[0];
        }
        return result;
    }

    private void reset() {
        account = null;
        balances = null;
        operType = null;
        operTypes = null;
        balanceSelection = null;
        operAmount = null;
    }

    private Balance[] balancesByAccount(Account account) {
        classLogger.trace("balancesByAccount...");
        SelectionParams sp =SelectionParams.build("accountId", account.getId());
        return accountsDao.getBalances(userSessionId, sp);
    }

    @Override
    public Map<String, Object> release(Direction direction) {
        classLogger.trace("release...");
        if (direction == Direction.FORWARD) {
            String operStatus = balanceCorrection();
            putContext(WizardConstants.OPER_STATUS, operStatus);
            putContext(ACCOUNT, account);
        }
        return getContext();
    }

    private String balanceCorrection() {
        classLogger.trace("balanceCorrection...");

        Map<String, Currency> map = CurrencyCache.getInstance().getCurrencyObjectsMap();
        Currency currency = map.get(account.getCurrency());
        Integer exponent = currency.getExponent();
        BigDecimal operAmount = new BigDecimal(this.operAmount * Math.pow(10.0, exponent));

        Operation operation = new Operation();
        operation.setOperType(operType);
        operation.setOperReason(selectedBalance.getBalanceType());
        operation.setMsgType("MSGTPRES");
        operation.setStatus("OPST0100");
        operation.setSttlType("STTT0010");
        operation.setOperCount(1L);
        operation.setOperationDate(operDate);
        operation.setSourceHostDate(bookDate);
        operation.setOperationAmount(operAmount);
        operation.setParticipantType("PRTYISS");
        operation.setIssInstId(account.getInstId());
        operation.setCustomerId(account.getCustomerId());
        operation.setClientIdType("CITPACCT");
        operation.setClientIdValue(account.getAccountNumber());
        operation.setAccountId(account.getId());
        operation.setAccountNumber(account.getAccountNumber());
        operation.setAccountType(account.getAccountType());
        operation.setOperationCurrency(account.getCurrency());

        Integer networkId = orgStructDao.getNetworkIdByInstId(userSessionId, account.getInstId(), curLang);
        operation.setIssNetworkId(networkId);
        operation.setCardNetworkId(networkId);

        if (isMaker()) {
            ApplicationBuilder builder = new ApplicationBuilder(applicationDao, userSessionId, account.getInstId(), getFlowId());
            builder.buildFromOperation(operation, true);
            builder.createApplicationInDB();
            builder.addApplicationObject(account);
            return builder.getApplication().getStatus();
        } else {
            operationDao.addAdjusment(userSessionId, operation);
            return operationDao.processOperation(userSessionId, operation.getId());
        }
    }

    public boolean isOperationDateValid() {
        if (operDate != null && bookDate != null) {
            if (bookDate.getTime() >= operDate.getTime()) {
                if (invoiceDate == null) {
                    return true;
                } else if (operDate.getTime() >= invoiceDate.getTime()) {
                    return true;
                } else {
                    FacesUtils.addMessageError("Operation date cannot be less than last invoice date");
                }
            } else {
                FacesUtils.addMessageError("Operation date cannot be greater than booking date");
            }
        } else {
            FacesUtils.addMessageError("Operation date cannot be empty");
        }
        return false;
    }

    @Override
    public boolean validate() {
        classLogger.trace("validate...");
        return isOperationDateValid() && checkBalances();
    }

    public List<SelectItem> getOperTypes() {
        if (operTypes == null) {
            Map<String, String> allArticles = dictUtils.getArticles();
            operTypes = Arrays.asList(
                    new SelectItem("OPTP0422", allArticles.get("OPTP0422")),
                    new SelectItem("OPTP0402", allArticles.get("OPTP0402"))
            );
        }
        return operTypes;
    }

    private boolean checkBalances() {
        return !(invalidBalance = (selectedBalance == null));
    }

    public void setBalanceSelection(SimpleSelection balanceSelection) {
        classLogger.trace("setCardInstancesSelection...");
        this.balanceSelection = balanceSelection;
        if (balances == null || balances.length == 0)
            return;
        int index = selectedIdx();
        if (index < 0)
            return;
        Balance newBalance = balances[index];
        if (!newBalance.equals(selectedBalance)) {
            selectedBalance = newBalance;
            checkBalances();
        }
    }

    private Integer selectedIdx() {
        Iterator<Object> keys = balanceSelection.getKeys();
        if (!keys.hasNext())
            return -1;
        return (Integer) keys.next();
    }

    public SimpleSelection getBalanceSelection() {
        return this.balanceSelection;
    }

    public Balance[] getBalances() {
        return balances;
    }

    public void setBalances(Balance[] balances) {
        this.balances = balances;
    }

    public String getOperType() {
        return operType;
    }

    public void setOperType(String operType) {
        this.operType = operType;
    }

    public Double getOperAmount() {
        return operAmount;
    }

    public void setOperAmount(Double operAmount) {
        this.operAmount = operAmount;
    }

    public boolean isInvalidBalance() {
        return invalidBalance;
    }

    public void setInvalidBalance(boolean invalidBalance) {
        this.invalidBalance = invalidBalance;
    }

    public Date getOperDate() {
        return operDate;
    }

    public void setOperDate(Date operDate) {
        this.operDate = operDate;
    }

    public Date getBookDate() {
        return bookDate;
    }

    public void setBookDate(Date bookDate) {
        this.bookDate = bookDate;
    }
}
