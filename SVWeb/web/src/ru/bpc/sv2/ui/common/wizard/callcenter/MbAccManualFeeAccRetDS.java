package ru.bpc.sv2.ui.common.wizard.callcenter;

import org.apache.log4j.Logger;
import ru.bpc.jsf.format.el.Formatter;
import ru.bpc.sv2.accounts.Account;
import ru.bpc.sv2.common.WizardConstants;
import ru.bpc.sv2.constants.ClientIdentificationTypes;
import ru.bpc.sv2.constants.EntityNames;
import ru.bpc.sv2.constants.application.ApplicationConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.issuing.IssuingPrivConstants;
import ru.bpc.sv2.logic.*;
import ru.bpc.sv2.operations.Participant;
import ru.bpc.sv2.operations.incoming.Operation;
import ru.bpc.sv2.orgstruct.Institution;
import ru.bpc.sv2.products.ProductAttribute;
import ru.bpc.sv2.ui.common.wizard.CommonWizardStep;
import ru.bpc.sv2.ui.common.wizard.MbCommonWizard;
import ru.bpc.sv2.ui.operations.MbOperationSearchModal;
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
@ManagedBean(name = "MbAccManualFeeAccRetDS")
public class MbAccManualFeeAccRetDS implements CommonWizardStep {
    private static final Logger classLogger = Logger.getLogger(MbAccManualFeeAccRetDS.class);
    private static final String PAGE = "/pages/common/wizard/callcenter/accManualFeeAccRetDS.jspx";
    private static final String FEE_TYPE = "FEE_TYPE";
    private static final String FEE_AMOUNT = "FEE_AMOUNT";
    private static final String ACCOUNT = "ACCOUNT";
    private static final String CURRENCY = "CURRENCY";
    private static final String OBJECT_ID = "OBJECT_ID";
    private static final String ENTITY_TYPE = "ENTITY_TYPE";
    private static final String US_ON_US = "STTT0010";
    private static final String ISSUER_FEE = "OPTP0119";
    private static final String PROCESSED = "PROCESSED";
    public final static String IDENT_TYPE_CARD = "CITPCARD";
    public final static String IDENT_TYPE_ACCOUNT = "CITPACCT";

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
    private Integer rateCount;
    private String currency;
    private Long objectId;
    private String operType;
    private boolean showDialog = false;
    private boolean inRole = false;
    private Double operAmount;
    private Double reversalAmount;
    private Double feeAmountMax;
    private Long operationId;

    protected List<Filter> filters;

    public MbAccManualFeeAccRetDS() {
        userSessionId = SessionWrapper.getRequiredUserSessionId();
        curLang = SessionWrapper.getField("language");
        dictUtils = ManagedBeanWrapper.getManagedBean(DictUtils.class);
        usession = (UserSession) ManagedBeanWrapper.getManagedBean("usession");
        inRole = usession.getInRole().get(IssuingPrivConstants.MODIFY_FEE_AMOUNT);
    }

    public boolean isShowDialog() {
        classLogger.trace("MbAccManualFeeAccRetDS::isShowDialog...");
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
        operAmount = null;
        reversalAmount = null;
        feeAmountMax = null;
        operationId = null;
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

        if (operationId != null) {
            operation.setOriginalId(operationId);
            operation.setReversal(true);
        }

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
        else if ((this.feeAmount == null) || (this.feeAmount == 0D))
            throw new IllegalStateException("Error. The field Fee Amount should be greater than 0.");
        else if ((this.feeAmount != null) && (this.feeAmount > feeAmountMax))
            throw new IllegalStateException("Error. The field Fee Amount should be NOT greater than " + (Formatter.formatMoney(new BigDecimal(feeAmountMax), 2)));
        return true;
    }

    public void showOperations() {
        MbOperationSearchModal bean = (MbOperationSearchModal) ManagedBeanWrapper.getManagedBean("MbOperationSearchModal");
        bean.clearFilter();
        bean.getDisputeFilter().setCustomerId(account.getCustomerId());
        bean.getDisputeFilter().setCustomerNumber(account.getCustomerNumber());
        bean.getDisputeFilter().setSubType(ApplicationConstants.TYPE_ISSUING);
        //bean.getDisputeFilter().setCardMask(card.getMask());
    }

    public void displayOperInfo() {
        return;
    }

    public void selectOperation() {
        MbOperationSearchModal bean = (MbOperationSearchModal) ManagedBeanWrapper.getManagedBean("MbOperationSearchModal");
        ru.bpc.sv2.operations.Operation selected = bean.getActiveOperation();
        if (selected != null) {
            setOperationId(selected.getId());
            operAmount = selected.getOperAmount().doubleValue();
            reversalAmount = returnReversalAmount(selected.getId());
            setFeeType(selected.getOperReason());
            setCurrency(selected.getOperCurrency());

            SelectionParams sp = SelectionParams.build("operId", selected.getId()
                    , "lang", curLang
                    , "participantType", "PRTYISS");
            sp.setRowIndexEnd(1);
            Participant[] participants = operationDao.getParticipants(userSessionId, sp);
            Participant participant = null;
            if (participants.length != 0) {
                participant = participants[0];
                if (participant.getClientIdType().equals(ClientIdentificationTypes.ACCOUNT)) {
                    sp = SelectionParams.build("lang", curLang
                            , "accountNumber", participant.getAccountNumber());
                    Account[] accs = accountsDao.getAccountObjects(userSessionId, sp);
                    this.account = null;
                    if (accs.length != 0) {
                        this.account = accs[0];
                    }
                } else {
                    account = null;
                }
            }

        }
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
        classLogger.trace("MbAccManualFeeAccRetDS::next...");
        MbCommonWizard bean = (MbCommonWizard)ManagedBeanWrapper.getManagedBean("MbCommonWizard");
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
        feeAmountMax = 0D;
        if ((operAmount != null) && (reversalAmount != null))
            if ((operAmount - reversalAmount) > 0D)
                feeAmountMax = operAmount - reversalAmount;
        feeAmount = feeAmountMax;
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

    public Long getOperationId() {
        return operationId;
    }

    public void setOperationId(Long operationId) {
        this.operationId = operationId;
    }

    public Double getOperAmount() {
        return operAmount;
    }

    public void setOperAmount(Double operAmount) {
        this.operAmount = operAmount;
    }

    public Double returnReversalAmount(Long operid) {
        try {
            Map<String, Object> params = new HashMap<String, Object>();
            params.put("result", (Double) 0D);
            params.put("original_id", operid);
            return operationDao.getReversalsAmount(userSessionId, params);
        } catch (Exception e) {
            //classLogger.error(e.getMessage(), e);
            return 0D;
        }
    }

    public Double getReversalAmount() {
        return reversalAmount;
    }

    public void setReversalAmount(Double reversalAmount) {
        this.reversalAmount = reversalAmount;
    }
}
