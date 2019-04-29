package ru.bpc.sv2.ui.common.wizard.callcenter;

import org.apache.log4j.Logger;
import ru.bpc.sv2.common.WizardConstants;
import ru.bpc.sv2.constants.DatePatterns;
import ru.bpc.sv2.constants.EntityNames;
import ru.bpc.sv2.fcl.limits.Limit;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.invocation.SortElement;
import ru.bpc.sv2.logic.LimitsDao;
import ru.bpc.sv2.logic.ProductsDao;
import ru.bpc.sv2.products.AttributeValue;
import ru.bpc.sv2.products.ProductAttribute;
import ru.bpc.sv2.ui.common.wizard.AbstractWizardStep;
import ru.bpc.sv2.ui.common.wizard.MbCommonWizard;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import java.math.BigDecimal;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Map;

@ViewScoped
@ManagedBean(name = "MbChangeLimitAmountRS")
public class MbChangeLimitAmountRS extends AbstractWizardStep {
    private static final Logger logger = Logger.getLogger(MbChangeLimitAmountRS.class);
    private static final String PAGE_CARD = "/pages/common/wizard/callcenter/changeLimitAmountRS.jspx";
    private static final String PAGE_ACCOUNT = "/pages/common/wizard/callcenter/accChngLimitRS.jspx";
    private static final String LIMIT_TYPE = "LIMIT_TYPE";
    private static final String OBJECT_ID = "OBJECT_ID";
    private static final String ENTITY_TYPE = "ENTITY_TYPE";
    private static final String CURRENCY = "CURRENCY";

    private LimitsDao limitsDao = new LimitsDao();

    private ProductsDao productsDao = new ProductsDao();

    private String operStatus;
    private String limitType;
    private BigDecimal limitAmount;
    private Long objectId;
    private String entityType;
    private String currency;
    private Long limitCount;


    @Override
    public void init(Map<String, Object> context) {
        logger.trace("init...");

        String page = null;

        if (context.containsKey(ENTITY_TYPE)) {
            entityType = (String) context.get(ENTITY_TYPE);
        } else {
            throw new IllegalStateException("ENTITY_TYPE is not defined in wizard context");
        }

        if (EntityNames.CARD.equals(entityType)) {
            page = PAGE_CARD;
        } else if (EntityNames.ACCOUNT.equals(entityType)) {
            page = PAGE_ACCOUNT;
        }

        super.init(context, page);

        if (context.containsKey(WizardConstants.OPER_STATUS)) {
            operStatus = (String) context.get(WizardConstants.OPER_STATUS);
        } else {
            throw new IllegalStateException("OPER_STATUS is not defined in wizard context");
        }

        if (context.containsKey(LIMIT_TYPE)) {
            limitType = (String) context.get(LIMIT_TYPE);
        } else {
            throw new IllegalStateException("LIMIT_TYPE is not defined in wizard context");
        }
        if (context.containsKey(CURRENCY)) {
            currency = (String) context.get(CURRENCY);
        } else {
            throw new IllegalStateException("LIMIT_TYPE is not defined in wizard context");
        }
        if (context.containsKey(OBJECT_ID)) {
            objectId = (Long) context.get(OBJECT_ID);
        } else {
            throw new IllegalStateException("OBJECT_ID is not defined in wizard context");
        }


        if (!isMaker()) {
            Limit limit = obtainLimit();
            limitAmount = limit.getSumLimit();
            if (limitAmount.equals(new BigDecimal(-1))) {
                limitAmount = null;
            }
            limitCount = limit.getCountLimit();
            if (limitCount == -1) {
                limitCount = null;
            }
        }

        context.put(MbCommonWizard.DISABLE_BACK, Boolean.TRUE);
    }

    private Limit obtainLimit() {
        logger.trace("obtainLimit...");
        Limit result = null;
        SelectionParams sp = SelectionParams.build("objectId", objectId
                , "entityType", entityType
                , "attrObjectType", limitType
                , "lang", curLang
        );
        ProductAttribute[] attributes = productsDao.getFlatObjectAttributes(userSessionId, sp);
        ProductAttribute attr = null;
        if (attributes.length > 0) {
            attr = attributes[0];
        }
        if (attr == null) {
            logger.error("ProductAttribute is not found...");
            return result;
        }
        SimpleDateFormat df = new SimpleDateFormat(DatePatterns.DATE_PATTERN);
        sp = SelectionParams.build("objectId", objectId
                , "entityType", entityType
                , "effDate", df.format(new Date())
                , "attributeId", attributes[0].getId()
                , "attrObjectType", limitType);
        sp.setSortElement(new SortElement("startDate", SortElement.Direction.DESC));
        AttributeValue[] attrValues = productsDao.getMixedAttrValues(userSessionId, sp);
        AttributeValue attrValue = null;
        if (attrValues.length > 0) {
            attrValue = attrValues[0];
        }
        if (attrValue == null) {
            logger.error("AttributeValue is not found...");
            return result;
        }
        result = limitsDao.getLimitById(userSessionId, attrValue.getValueN().longValue());
        return result;
    }

    @Override
    public Map<String, Object> release(Direction direction) {
        logger.trace("release...");
        return getContext();
    }

    @Override
    public boolean validate() {
        logger.trace("validate...");
        return false;
    }

    public String getOperStatus() {
        return operStatus;
    }

    public void setOperStatus(String operStatus) {
        this.operStatus = operStatus;
    }

    public BigDecimal getLimitAmount() {
        return limitAmount;
    }

    public void setLimitAmount(BigDecimal limitAmount) {
        this.limitAmount = limitAmount;
    }

    public String getCurrency() {
        return currency;
    }

    public void setCurrency(String currency) {
        this.currency = currency;
    }

    public Long getLimitCount() {
        return limitCount;
    }

    public void setLimitCount(Long limitCount) {
        this.limitCount = limitCount;
    }

}
