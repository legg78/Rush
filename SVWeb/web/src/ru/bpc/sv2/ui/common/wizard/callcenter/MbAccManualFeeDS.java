package ru.bpc.sv2.ui.common.wizard.callcenter;

import org.apache.log4j.Logger;
import ru.bpc.sv2.accounts.Account;
import ru.bpc.sv2.common.WizardConstants;
import ru.bpc.sv2.constants.EntityNames;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.*;
import ru.bpc.sv2.operations.incoming.Operation;
import ru.bpc.sv2.orgstruct.Institution;
import ru.bpc.sv2.products.ProductAttribute;
import ru.bpc.sv2.ui.common.wizard.AbstractWizardStep;
import ru.bpc.sv2.ui.common.wizard.MbCommonWizard;
import ru.bpc.sv2.ui.common.wizard.application.ApplicationBuilder;
import ru.bpc.sv2.ui.utils.CurrencyCache;
import ru.bpc.sv2.ui.utils.DictUtils;
import util.auxil.ManagedBeanWrapper;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.model.SelectItem;
import java.math.BigDecimal;
import java.util.Date;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;

/**
 * "Data input" step for operation "Manual fee" for account entity
 */
@ViewScoped
@ManagedBean(name = "MbAccManualFeeDS")
public class MbAccManualFeeDS extends AbstractWizardStep {
    private static final Logger classLogger = Logger.getLogger(MbAccManualFeeDS.class);
    private static final String PAGE = "/pages/common/wizard/callcenter/accManualFeeDS.jspx";
    private static final String FEE_TYPE = "FEE_TYPE";
    private static final String FEE_AMOUNT = "FEE_AMOUNT";
    private static final String CURRENCY = "CURRENCY";
    private static final String OBJECT_ID = "OBJECT_ID";

    private OrgStructDao orgStructureDao = new OrgStructDao();

    private OperationDao operationDao = new OperationDao();

    private ProductsDao productsDao = new ProductsDao();

    private AccountsDao accountsDao = new AccountsDao();

    private ApplicationDao applicationDao = new ApplicationDao();

    private DictUtils dictUtils;
    private Account account;
    private List<SelectItem> feeTypes;
    private String feeType;
    private Double feeAmount;
    private String currency;
    private Long objectId;
    private String operType;

    public MbAccManualFeeDS() {
        dictUtils = ManagedBeanWrapper.getManagedBean(DictUtils.class);
    }

    @Override
    public void init(Map<String, Object> context) {
        super.init(context, PAGE, true);

        reset();
        classLogger.trace("init...");

        if (context.containsKey(OBJECT_ID)) {
            objectId = (Long) context.get(OBJECT_ID);
        } else {
            throw new IllegalStateException(OBJECT_ID + " is not defined in wizard context");
        }
        operType = (String) this.getContext().get(MbCommonWizard.OPER_TYPE);
        account = accountById(objectId);
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
        classLogger.trace("reset...");
        feeTypes = null;
        feeType = null;
        feeAmount = null;
        account = null;
    }

    @Override
    public Map<String, Object> release(Direction direction) {
        classLogger.trace("release...");
        if (direction == Direction.FORWARD) {
            String operStatus = manualFee();
            getContext().put(WizardConstants.OPER_STATUS, operStatus);
            getContext().put(FEE_TYPE, feeType);
            getContext().put(FEE_AMOUNT, feeAmount);
            getContext().put(CURRENCY, currency);
        }
        return getContext();
    }

    private String manualFee() {
        classLogger.trace("manualFee...");
        Operation operation = new Operation();
        operation.setOperType((operType == null ? "OPTP0119" : operType));
        operation.setOperReason(feeType);
        operation.setMsgType("MSGTPRES");
        operation.setStatus("OPST0100");
        operation.setSttlType("STTT0010");
        operation.setOperCount(1L);
        operation.setOperationDate(new Date());
        operation.setSourceHostDate(new Date());
        operation.setOperationAmount(new BigDecimal(feeAmount));
        operation.setParticipantType("PRTYISS");
        operation.setAccountCurrency(account.getCurrency());
        operation.setAccountId(account.getId());
        operation.setAccountNumber(account.getAccountNumber());
        operation.setAccountType(account.getAccountType());
        operation.setCustomerId(account.getCustomerId());
        operation.setClientIdType("CITPACCT");
        operation.setClientIdValue(account.getAccountNumber());
        operation.setOperationCurrency(currency);
        operation.setIssInstId(account.getInstId());

        Integer networkId = institutionNetwork(account.getInstId());

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
            String operStatus = operationDao.processOperation(userSessionId, operation.getId());
            return operStatus;
        }
    }

    private Integer institutionNetwork(Integer instId) {
        classLogger.trace("institutionNetwork...");
        Integer result = null;
        SelectionParams sp = SelectionParams.build("instId", instId);
        Institution[] insts = orgStructureDao.getInstitutions(userSessionId, sp, curLang, false);
        if (insts.length != 0) {
            result = insts[0].getNetworkId();
        }
        return result;
    }

    @Override
    public boolean validate() {
        classLogger.trace("validate...");
        return true;
    }

    private void prepareFeeTypes() {
        classLogger.trace("prepareFeeTypes...");
        SelectionParams sp = SelectionParams.build("lang", curLang,
                "objectId", account.getId(), "attrEntityType", EntityNames.FEE);
        ProductAttribute[] fees = productsDao.getFlatObjectAttributes(userSessionId, sp);
        feeTypes = new LinkedList<SelectItem>();
        for (ProductAttribute fee : fees) {
            SelectItem si = new SelectItem(fee.getAttrObjectType(), fee.getAttrObjectType() + " - " + fee.getLabel());
            feeTypes.add(si);
        }
    }

    public List<SelectItem> getCurrencies() {
        return CurrencyCache.getInstance().getAllCurrencies(curLang);
    }

    public List<SelectItem> getFeeTypes() {
        if (feeTypes == null) {
            prepareFeeTypes();
        }
        return feeTypes;
    }

    public Account getAccount() {
        return account;
    }

    public void setAccount(Account account) {
        this.account = account;
    }

    public String getFeeType() {
        return feeType;
    }

    public void setFeeType(String feeType) {
        this.feeType = feeType;
    }

    public Double getFeeAmount() {
        return feeAmount;
    }

    public void setFeeAmount(Double feeAmount) {
        this.feeAmount = feeAmount;
    }

    public String getCurrency() {
        return currency;
    }

    public void setCurrency(String currency) {
        this.currency = currency;
    }

}
