package ru.bpc.sv2.ui.common.wizard.callcenter;

import org.apache.log4j.Logger;
import ru.bpc.sv2.accounts.Account;
import ru.bpc.sv2.common.WizardConstants;
import ru.bpc.sv2.constants.EntityNames;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.issuing.IssuingPrivConstants;
import ru.bpc.sv2.logic.*;
import ru.bpc.sv2.operations.incoming.Operation;
import ru.bpc.sv2.orgstruct.Institution;
import ru.bpc.sv2.products.ProductAttribute;
import ru.bpc.sv2.ui.common.wizard.CommonWizardStep;
import ru.bpc.sv2.ui.common.wizard.MbCommonWizard;
import ru.bpc.sv2.ui.session.UserSession;
import ru.bpc.sv2.ui.utils.CurrencyCache;
import ru.bpc.sv2.ui.utils.DictUtils;
import ru.bpc.sv2.ui.utils.FacesUtils;
import util.auxil.ManagedBeanWrapper;
import util.auxil.SessionWrapper;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.model.SelectItem;
import java.math.BigDecimal;
import java.text.SimpleDateFormat;
import java.util.*;

/**
 * "Data input" step for operation "Manual fee" for account entity
 */
@ViewScoped
@ManagedBean(name = "MbAccManualFeeAccDS")
public class MbAccManualFeeAccDS implements CommonWizardStep {
    private static final Logger classLogger = Logger.getLogger(MbAccManualFeeAccDS.class);
    private static final String PAGE = "/pages/common/wizard/callcenter/accManualFeeAccDS.jspx";
    private static final String FEE_TYPE = "FEE_TYPE";
    private static final String FEE_AMOUNT = "FEE_AMOUNT";
    private static final String CURRENCY = "CURRENCY";
    private static final String OBJECT_ID = "OBJECT_ID";

    private OrgStructDao orgStructureDao = new OrgStructDao();

    private OperationDao operationDao = new OperationDao();

    private ProductsDao productsDao = new ProductsDao();

    private AccountsDao accountsDao = new AccountsDao();

    private CommonDao _commonDao = new CommonDao();

    private UserSession usession;
    private long userSessionId;
    private String curLang;
    private DictUtils dictUtils;
    private Map<String, Object> context;
    private Account account;
    private List<SelectItem> feeTypes;
    private String feeType;
    private Integer feeTypeId = null;
    private Double feeAmount;
    private String currency;
    private Long objectId;
    private String operType;
    private Integer rateCount;
    private boolean showDialog = false;
    private boolean inRole = false;

    protected List<Filter> filters;

    public MbAccManualFeeAccDS() {
        userSessionId = SessionWrapper.getRequiredUserSessionId();
        curLang = SessionWrapper.getField("language");
        dictUtils = ManagedBeanWrapper.getManagedBean(DictUtils.class);
        usession = (UserSession) ManagedBeanWrapper.getManagedBean("usession");
        inRole = usession.getInRole().get(IssuingPrivConstants.MODIFY_FEE_AMOUNT);
    }

    public boolean isShowDialog() {
        classLogger.trace("MbAccManualFeeAccDS::isShowDialog...");
        if ((this.account != null) && (this.currency != null))
            if (this.currency.equals(account.getCurrency()))
                return false;
            else if (checkRates() != 0)
                return true;
        return false;
    }

    public void setShowDialog(boolean showDialog) {
        this.showDialog = showDialog;
    }

    @Override
    public void init(Map<String, Object> context) {
        reset();
        classLogger.trace("init...");

        this.context = context;
        context.put(MbCommonWizard.PAGE, PAGE);
        context.put(MbCommonWizard.VALIDATED_STEP, Boolean.TRUE);
        context.put(MbCommonWizard.SHOW_DIALOG, Boolean.TRUE);//check for confirmation messages
        if (context.containsKey(OBJECT_ID)) {
            objectId = (Long) context.get(OBJECT_ID);
        } else {
            throw new IllegalStateException(OBJECT_ID + " is not defined in wizard context");
        }
        operType = (String) this.context.get(MbCommonWizard.OPER_TYPE);
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
        account = null;
        showDialog = false;
        feeTypeId = null;
        currency = null;
    }

    @Override
    public Map<String, Object> release(Direction direction) {
        classLogger.trace("release...");
        if (direction == Direction.FORWARD) {
            String operStatus = manualFee();
            context.put(WizardConstants.OPER_STATUS, operStatus);
            context.put(FEE_TYPE, feeType);
            context.put(FEE_AMOUNT, feeAmount);
            context.put(CURRENCY, currency);
        }
        return context;
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

        operationDao.addAdjusment(userSessionId, operation);

        String operStatus = operationDao.processOperation(userSessionId, operation.getId());
        return operStatus;
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
        if (!this.currency.equals(account.getCurrency()) && (checkRates() == 0))
            throw new IllegalStateException("Error. Conversion rate between Fee currency and Account currency doesn’t exist.");
        return true;
    }

    private void prepareFeeTypes() {
        classLogger.trace("prepareFeeTypes...");
        SelectionParams sp = SelectionParams.build("lang", curLang,
                "objectId", account.getId(), "attrEntityType", EntityNames.FEE);
        ProductAttribute[] fees = productsDao.getObjectFeeAttrs(userSessionId, sp);
        feeTypes = new LinkedList<SelectItem>();
        for (ProductAttribute fee : fees) {
            SelectItem si = new SelectItem(fee.getAttrObjectType(), fee.getAttrObjectType() + " - " + fee.getLabel());
            feeTypes.add(si);
        }
    }

    private int checkRates() {
        rateCount = 0;
        try {
            SelectionParams params = new SelectionParams(
                    new Filter("instId", account.getInstId().toString()),
                    new Filter("effDate", new SimpleDateFormat("dd.MM.yyyy").format(new Date())),
                    new Filter("dstCurrency", account.getCurrency()),
                    new Filter("srcCurrency", this.currency));
            rateCount = _commonDao.getRatesCount(userSessionId, params);
        } catch (Exception e) {
            FacesUtils.addMessageError(e);
            classLogger.error("", e);
        }
        return rateCount;
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

    public void next() {
        classLogger.trace("MbAccManualFeeAccDS::next...");
        MbCommonWizard bean = (MbCommonWizard) ManagedBeanWrapper.getManagedBean("MbCommonWizard");
        bean.next();
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

    public String getFeeTypeName() {
        SelectionParams sp = SelectionParams.build("lang", curLang,
                "objectId", account.getId(), "attrEntityType", EntityNames.FEE);
        ProductAttribute[] fees = productsDao.getFlatObjectAttributes(userSessionId, sp);
        for (ProductAttribute fee : fees) {
            if (fee.getAttrObjectType().equals(this.feeType))
                return fee.getSystemName();
        }
        return null;
    }

    public void setFeeType(String feeType) {
        this.feeType = feeType;
        if ((feeType != null) && (account != null))
            try {
                Map<String, Object> params = new HashMap<String, Object>();
                params.put("result", (Integer) 0);
                params.put("entity_type", EntityNames.ACCOUNT);
                params.put("object_id", account.getId());
                params.put("attr_name", getFeeTypeName());
                params.put("inst_id", account.getInstId());
                params.put("use_default_value", (Integer) 1);
                params.put("default_value", (Long) 0L);
                feeTypeId = operationDao.getAttrValueNumber(userSessionId, params);

                SelectionParams sp = SelectionParams.build("lang", curLang,
                        "objectId", account.getId(), "attrEntityType", EntityNames.FEE);
                ProductAttribute[] fees = productsDao.getObjectFeeAttrs(userSessionId, sp);
                for (ProductAttribute fee : fees) {
                    if (fee.getAttrObjectType().equals(this.feeType))
                        this.currency = fee.getFeeCurrency();
                }
            } catch (Exception e) {
                //classLogger.error(e.getMessage(), e);
                feeTypeId = null;
            }
    }

    private Double DefaultFeeAmount() {
        Double result = null;
        if ((feeType != null) && (feeTypeId > 0) && (account != null) && (currency != null))
            try {
                Map<String, Object> params = new HashMap<String, Object>();
                params.put("result", (Integer) 0);
                params.put("fee_id", feeTypeId);
                params.put("base_amount", (Long) 0L);
                params.put("base_currency", currency);
                params.put("entity_type", EntityNames.ACCOUNT);
                params.put("object_id", account.getId());
                result = operationDao.getFeeAmount(userSessionId, params);
            } catch (Exception e) {
                //classLogger.error(e.getMessage(), e);
                result = null;
            }
        return result;
    }

    public Double getFeeAmount() {
        feeAmount = DefaultFeeAmount();
        return feeAmount;
    }

    public void setFeeAmount(Double feeAmount) {
        this.feeAmount = feeAmount == null ? null : Long.valueOf(Math.round(feeAmount)).doubleValue();
    }

    public String getCurrency() {
        return currency;
    }

    public void setCurrency(String currency) {
        this.currency = currency;
    }

}
