package ru.bpc.sv2.ui.common.wizard.callcenter;

import org.apache.log4j.Logger;
import ru.bpc.sv2.accounts.Account;
import ru.bpc.sv2.common.WizardConstants;
import ru.bpc.sv2.constants.DatePatterns;
import ru.bpc.sv2.constants.EntityNames;
import ru.bpc.sv2.fcl.limits.Limit;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.invocation.SortElement;
import ru.bpc.sv2.logic.*;
import ru.bpc.sv2.operations.incoming.Operation;
import ru.bpc.sv2.orgstruct.Institution;
import ru.bpc.sv2.products.AttributeValue;
import ru.bpc.sv2.products.ProductAttribute;
import ru.bpc.sv2.ui.common.wizard.AbstractWizardStep;
import ru.bpc.sv2.ui.common.wizard.application.ApplicationBuilder;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.model.SelectItem;
import java.math.BigDecimal;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;

/**
 * "Data input" step for operation "Change limit amount" for account entity.
 */
@ViewScoped
@ManagedBean(name = "MbAccChngLimitAmtDS")
public class MbAccChngLimitAmtDS extends AbstractWizardStep {
    private static final Logger classLogger = Logger.getLogger(MbAccChngLimitAmtDS.class);
    private static final String PAGE = "/pages/common/wizard/callcenter/accChngLimitAmtDS.jspx";
    private static final String LIMIT_TYPE = "LIMIT_TYPE";
    private static final String ACCOUNT = "ACCOUNT";
    private static final String OBJECT_ID = "OBJECT_ID";
    private static final String ENTITY_TYPE = "ENTITY_TYPE";
    private static final String CURRENCY = "CURRENCY";

    private ProductsDao productsDao = new ProductsDao();

    private LimitsDao limitsDao = new LimitsDao();

    private OrgStructDao orgStructureDao = new OrgStructDao();

    private OperationDao operationDao = new OperationDao();

    private AccountsDao accountsDao = new AccountsDao();

    private ApplicationDao applicationDao = new ApplicationDao();

    private Account account;
    private String limitType;
    private List<SelectItem> limitTypes;
    private BigDecimal limitAmount;
    private AttributeValue limitAttr;
    private Limit limit;
    private Long limitCount;
    private Long objectId;


    @Override
    public void init(Map<String, Object> context) {
        super.init(context, PAGE, true);

        classLogger.trace("init...");
        reset();

        if (context.containsKey(OBJECT_ID)) {
            objectId = (Long) context.get(OBJECT_ID);
        } else {
            throw new IllegalStateException(OBJECT_ID + " is not defined in wizard context");
        }
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
        limitTypes = null;
        limitType = null;
        limitAmount = null;
        account = null;
        limitAttr = null;
        limit = null;
    }

    @Override
    public Map<String, Object> release(Direction direction) {
        classLogger.trace("release...");
        if (direction == Direction.FORWARD) {
            String operStatus = changeLimitAmount();
            getContext().put(WizardConstants.OPER_STATUS, operStatus);
            getContext().put(LIMIT_TYPE, limitType);
            getContext().put(OBJECT_ID, account.getId());
            getContext().put(ENTITY_TYPE, EntityNames.ACCOUNT);
            getContext().put(CURRENCY, limit.getCurrency());
        }
        return getContext();
    }

    private String changeLimitAmount() {
        classLogger.trace("changeLimitAmount...");
        Operation operation = new Operation();
        operation.setOperType("OPTP0403");
        operation.setOperReason(limitType);
        operation.setMsgType("MSGTPRES");
        operation.setStatus("OPST0100");
        operation.setSttlType("STTT0010");
        operation.setOperCount(1L);
        operation.setOperationDate(new Date());
        operation.setSourceHostDate(new Date());
        operation.setOperationAmount(limitAmount);
        operation.setParticipantType("PRTYISS");
        operation.setAccountCurrency(account.getCurrency());
        operation.setAccountId(account.getId());
        operation.setAccountNumber(account.getAccountNumber());
        operation.setAccountType(account.getAccountType());
        operation.setCustomerId(account.getCustomerId());
        operation.setClientIdType("CITPACCT");
        operation.setClientIdValue(account.getAccountNumber());
        operation.setIssInstId(account.getInstId());
        operation.setOperationCurrency(limit.getCurrency());

        if (limitCount == null) {
            operation.setOperCount(-1L);
        } else {
            operation.setOperCount(limitCount);
        }
        if (limitAmount == null) {
            operation.setOperationAmount(new BigDecimal(-1));
        } else {
            operation.setOperationAmount(limitAmount);
        }

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

    public List<SelectItem> getLimitTypes() {
        if (limitTypes == null) {
            prepareLimitTypes();
        }
        return limitTypes;
    }

    private void prepareLimitTypes() {
        SelectionParams sp = SelectionParams.build("lang", curLang
                , "productId", account.getProductId(), "objectId", account.getId()
                , "attrEntityType", EntityNames.LIMIT);
        ProductAttribute[] definedAttrs = productsDao.getDefinedAttrs(userSessionId, sp);
        limitTypes = new LinkedList<SelectItem>();
        for (ProductAttribute definedAttr : definedAttrs) {
            SelectItem si = new SelectItem(definedAttr.getAttrObjectType(), definedAttr.getAttrObjectType() + " - " + definedAttr.getLabel());
            limitTypes.add(si);
        }
    }

    private void updateLimitAttr() {
        classLogger.trace("updateLimitAttr...");
        SelectionParams sp = SelectionParams.build("objectId", account.getId()
                , "entityType", EntityNames.ACCOUNT
                , "attrObjectType", limitType
                , "lang", curLang
        );
        ProductAttribute[] attributes = productsDao.getFlatObjectAttributes(userSessionId, sp);
        ProductAttribute attr = null;
        if (attributes.length > 0) {
            attr = attributes[0];
        }
        if (attr == null) {
            limitAttr = null;
            return;
        }
        SimpleDateFormat df = new SimpleDateFormat(DatePatterns.DATE_PATTERN);
        sp = SelectionParams.build("objectId", account.getId()
                , "entityType", EntityNames.ACCOUNT
                , "effDate", df.format(new Date())
                , "attributeId", attributes[0].getId()
                , "attrObjectType", limitType);
        sp.setSortElement(new SortElement("startDate", SortElement.Direction.DESC));
        AttributeValue[] attrValues = productsDao.getMixedAttrValues(userSessionId, sp);
        if (attrValues.length > 0) {
            limitAttr = attrValues[0];
        }
    }

    private void updateLimit() {
        classLogger.trace("updateCurrentLimitAmount...");
        if (limitAttr == null) {
            ;
            limit = null;
            return;
        }
        limit = limitsDao.getLimitById(userSessionId, limitAttr.getValueN().longValue());
        if (limit.getSumLimit().equals(new BigDecimal(-1))) {
            limit.setSumLimit(null);
        }
        if (limit.getCountLimit() == -1) {
            limit.setCountLimit(null);
        }
    }

    public String getLimitType() {
        return limitType;
    }

    public void setLimitType(String limitType) {
        classLogger.trace("setLimitType...");
        if (limitType != null && !limitType.equals(this.limitType)) {
            this.limitType = limitType;
            updateLimitAttr();
            updateLimit();
        }
    }

    public BigDecimal getLimitAmount() {
        return limitAmount;
    }

    public void setLimitAmount(BigDecimal limitAmount) {
        this.limitAmount = limitAmount;
    }

    public Account getAccount() {
        return account;
    }

    public void setAccount(Account account) {
        this.account = account;
    }

    public AttributeValue getLimitAttr() {
        return limitAttr;
    }

    public void setLimitAttr(AttributeValue limitAttr) {
        this.limitAttr = limitAttr;
    }

    public Limit getLimit() {
        return limit;
    }

    public void setLimit(Limit limit) {
        this.limit = limit;
    }

    public Long getLimitCount() {
        return limitCount;
    }

    public void setLimitCount(Long limitCount) {
        this.limitCount = limitCount;
    }
}
