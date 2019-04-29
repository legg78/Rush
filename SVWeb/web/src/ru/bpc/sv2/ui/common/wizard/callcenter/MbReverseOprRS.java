package ru.bpc.sv2.ui.common.wizard.callcenter;

import org.apache.log4j.Logger;
import ru.bpc.sv2.common.WizardConstants;
import ru.bpc.sv2.constants.EntityNames;
import ru.bpc.sv2.operations.Operation;
import ru.bpc.sv2.ui.common.wizard.CommonWizardStep;
import ru.bpc.sv2.ui.common.wizard.MbCommonWizard;

import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import java.util.Map;

@ViewScoped
@ManagedBean(name = "MbReverseOprRS")
public class MbReverseOprRS implements CommonWizardStep {
    private static final Logger logger = Logger.getLogger(MbReverseOprRS.class);
    private static final String PAGE = "/pages/common/wizard/callcenter/reverseOprRS.jspx";
    private static final String PAGE_TERM = "/pages/common/wizard/callcenter/terminal/termReversalRS.jspx";
    private static final String OPERATION = "OPERATION";
    private static final String ENTITY_TYPE = "ENTITY_TYPE";

    private Map<String, Object> context;
    private String operStatus;
    private Operation operation;
    private String entityType;

    @Override
    public void init(Map<String, Object> context) {
        logger.trace("init...");
        reset();

        this.context = context;
        if (!context.containsKey(WizardConstants.OPER_STATUS)) {
            throw new IllegalStateException(WizardConstants.OPER_STATUS + " is not defined in wizard context");
        }
        operStatus = (String) context.get(WizardConstants.OPER_STATUS);
        if (!context.containsKey(OPERATION)) {
            throw new IllegalStateException(OPERATION + " is not defined in wizard context");
        }
        operation = (Operation) context.get(OPERATION);
        if (!context.containsKey(ENTITY_TYPE)) {
            throw new IllegalStateException(ENTITY_TYPE + " is not defined in wizard context");
        }
        entityType = (String) context.get(ENTITY_TYPE);

        if (EntityNames.TERMINAL.equals(entityType)) {
            context.put(MbCommonWizard.PAGE, PAGE_TERM);
        } else {
            context.put(MbCommonWizard.PAGE, PAGE);
        }
        context.put(MbCommonWizard.DISABLE_BACK, Boolean.TRUE);
    }

    private void reset() {
        logger.trace("reset...");
        operStatus = null;
        operation = null;
    }

    @Override
    public Map<String, Object> release(Direction direction) {
        logger.trace("release...");
        return context;
    }

    @Override
    public boolean validate() {
        throw new UnsupportedOperationException("validation");
    }

    public Operation getOperation() {
        return operation;
    }

    public void setOperation(Operation operation) {
        this.operation = operation;
    }

    public String getOperStatus() {
        return operStatus;
    }

    public void setOperStatus(String operStatus) {
        this.operStatus = operStatus;
    }

}
