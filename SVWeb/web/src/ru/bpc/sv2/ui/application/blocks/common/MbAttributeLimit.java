package ru.bpc.sv2.ui.application.blocks.common;

import org.apache.log4j.Logger;
import ru.bpc.sv2.application.ApplicationElement;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.fcl.limits.Limit;
import ru.bpc.sv2.ui.utils.DictUtils;
import ru.bpc.sv2.ui.utils.SimpleAppBlock;
import ru.bpc.sv2.utils.KeyLabelItem;
import util.auxil.ManagedBeanWrapper;

import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.model.SelectItem;
import java.math.BigDecimal;
import java.util.*;

@ViewScoped
@ManagedBean (name = "mbAttributeLimit")
public class MbAttributeLimit extends SimpleAppBlock {
    private static final Logger logger = Logger.getLogger("APPLICATIONS");

    private static final String LIMIT_COUNT_VALUE = "LIMIT_COUNT_VALUE";
    private static final String LIMIT_SUM_VALUE = "LIMIT_SUM_VALUE";
    private static final String CURRENCY = "CURRENCY";
    private static final String START_DATE = "START_DATE";
    private static final String END_DATE = "END_DATE";
    private static final String MOD_ID = "MOD_ID";
    private static final String MOD_CONDITION = "MOD_CONDITION";
    private static final String MOD_NAME = "MOD_NAME";
    private static final String LIMIT_CHECK_TYPE = "LIMIT_CHECK_TYPE";
    private static final String COUNTER_ALGORITHM = "COUNTER_ALGORITHM";

    private DictUtils dictUtils;
    private Limit limit;
    private Map<String, ApplicationElement> objectAttrs;
    private List<SelectItem> currencies;
    private List<SelectItem> modifiers;
    private List<SelectItem> types;
    private List<SelectItem> algorithms;

    @Override
    public void parseAppBlock() {
        limit = new Limit();
        objectAttrs = new HashMap<String, ApplicationElement>();
        dictUtils = (DictUtils) ManagedBeanWrapper.getManagedBean("DictUtils");

        for (ApplicationElement element : getLocalRootEl().getChildren()) {
            if (element.getInnerId() == 0 && element.getContent()) {
                continue;
            } else if (LIMIT_COUNT_VALUE.equals(element.getName())) {
                limit.setCountLimit(element.getValueN() != null ? element.getValueN().longValue() : null);
                objectAttrs.put(LIMIT_COUNT_VALUE, element);
            } else if (LIMIT_SUM_VALUE.equals(element.getName())) {
                limit.setSumLimit(element.getValueN());
                objectAttrs.put(LIMIT_SUM_VALUE, element);
            } else if (CURRENCY.equals(element.getName())) {
                limit.setCurrency(element.getValueV());
                currencies = getList(element);
                objectAttrs.put(CURRENCY, element);
            } else if (START_DATE.equals(element.getName())) {
                limit.setStartDate(element.getValueD());
                objectAttrs.put(START_DATE, element);
            } else if (END_DATE.equals(element.getName())) {
                limit.setEndDate(element.getValueD());
                objectAttrs.put(END_DATE, element);
            } else if (MOD_ID.equals(element.getName())) {
                limit.setModifierId(element.getValueN() != null ? element.getValueN().longValue() : null);
                modifiers = getList(element);
                objectAttrs.put(MOD_ID, element);
            } else if (MOD_CONDITION.equals(element.getName())) {
                limit.setModifierCondition(element.getValueV());
                objectAttrs.put(MOD_CONDITION, element);
            } else if (MOD_NAME.equals(element.getName())) {
                limit.setModifierName(element.getValueV());
                objectAttrs.put(MOD_NAME, element);
            } else if (LIMIT_CHECK_TYPE.equals(element.getName())) {
                limit.setCheckType(element.getValueV());
                types = getList(element);
                objectAttrs.put(LIMIT_CHECK_TYPE, element);
            } else if (COUNTER_ALGORITHM.equals(element.getName())) {
                limit.setCounterAlgorithm(element.getValueV());
                algorithms = getList(element);
                objectAttrs.put(COUNTER_ALGORITHM, element);
            }
        }
    }
    @Override
    public void formatObject(ApplicationElement element) {
        if (limit != null && getSourceRootEl() != null) {
            if (element.getChildByName(LIMIT_COUNT_VALUE, 1) != null) {
                element.getChildByName(LIMIT_COUNT_VALUE, 1).setValueN(limit.getCountLimit());
            }
            if (element.getChildByName(LIMIT_SUM_VALUE, 1) != null) {
                element.getChildByName(LIMIT_SUM_VALUE, 1).setValueN(limit.getSumLimit());
            }
            if (element.getChildByName(CURRENCY, 1) != null) {
                element.getChildByName(CURRENCY, 1).setValueV(limit.getCurrency());
            }
            if (element.getChildByName(START_DATE, 1) != null) {
                element.getChildByName(START_DATE, 1).setValueD(limit.getStartDate());
            }
            if (element.getChildByName(END_DATE, 1) != null) {
                element.getChildByName(END_DATE, 1).setValueD(limit.getEndDate());
            }
            if (element.getChildByName(MOD_ID, 1) != null) {
                element.getChildByName(MOD_ID, 1).setValueN(limit.getModifierId());
            }
            if (element.getChildByName(MOD_CONDITION, 1) != null) {
                element.getChildByName(MOD_CONDITION, 1).setValueV(limit.getModifierCondition());
            }
            if (element.getChildByName(MOD_NAME, 1) != null) {
                element.getChildByName(MOD_NAME, 1).setValueV(limit.getModifierName());
            }
            if (element.getChildByName(LIMIT_CHECK_TYPE, 1) != null) {
                element.getChildByName(LIMIT_CHECK_TYPE, 1).setValueV(limit.getCheckType());
            }
            if (element.getChildByName(COUNTER_ALGORITHM, 1) != null) {
                element.getChildByName(COUNTER_ALGORITHM, 1).setValueV(limit.getCounterAlgorithm());
            }
        }
    }
    @Override
    protected Logger getLogger() {
        return logger;
    }
    @Override
    public Map<String, ApplicationElement> getObjectAttrs() {
        return objectAttrs;
    }

    public Limit getLimit() {
        return limit;
    }
    public void setLimit(Limit limit) {
        this.limit = limit;
    }

    public List<SelectItem> getCurrencies() {
        return currencies;
    }
    public void setCurrencies(List<SelectItem> currencies) {
        this.currencies = currencies;
    }

    public List<SelectItem> getModifiers() {
        return modifiers;
    }
    public void setModifiers(List<SelectItem> modifiers) {
        this.modifiers = modifiers;
    }

    public List<SelectItem> getTypes() {
        return types;
    }
    public void setTypes(List<SelectItem> types) {
        this.types = types;
    }

    public List<SelectItem> getAlgorithms() {
        return algorithms;
    }
    public void setAlgorithms(List<SelectItem> algorithms) {
        this.algorithms = algorithms;
    }

    private List<SelectItem> getList(ApplicationElement element) {
        if (element.getLov() != null) {
            List<SelectItem> list = new ArrayList<SelectItem>(element.getLov().length);
            for (KeyLabelItem item : element.getLov()) {
                list.add(new SelectItem(item.getValue(), item.getLabel(), item.getStyle()));
            }
            return list;
        } else {
            return dictUtils.getLov(element.getLovId());
        }
    }
}
