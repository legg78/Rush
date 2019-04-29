package ru.bpc.sv2.ui.common.wizard.operations;

import org.apache.log4j.Logger;
import ru.bpc.sv2.common.WizardConstants;
import ru.bpc.sv2.operations.Operation;
import ru.bpc.sv2.ui.common.wizard.AbstractWizardStep;

import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import java.util.Map;

@ViewScoped
@ManagedBean(name = "MbChangeFraudOperStatusRS")
public class MbChangeFraudOperStatusRS extends AbstractWizardStep {
    private static final Logger logger = Logger.getLogger(MbChangeFraudOperStatusDS.class);
    private static final String PAGE = "/pages/common/wizard/callcenter/operation/changeFraudOperStatusRS.jspx";
    private static final String OPERATION = "OPERATION";
    private static final String COMMAND = "COMMAND";

    private Operation operation;
    private String command;
    private String operStatus;

    @Override
    public void init(Map<String, Object> context) {
        super.init(context, PAGE);
        logger.trace("init...");

        if (!context.containsKey(OPERATION)) {
            throw new IllegalStateException(OPERATION + " is not defined in wizard context");
        } else {
            operation = (Operation) context.get(OPERATION);
        }
        if (!context.containsKey(COMMAND)) {
            throw new IllegalStateException(COMMAND + " is not defined in wizard context");
        } else {
            command = (String) context.get(COMMAND);
        }

        operStatus = (String) context.get(WizardConstants.OPER_STATUS);
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

    public Operation getOperation() {
        return operation;
    }

    public void setOperation(Operation operation) {
        this.operation = operation;
    }

    public String getCommand() {
        return command;
    }

    public void setCommand(String command) {
        this.command = command;
    }

    public String getOperStatus() {
        return operStatus;
    }

    public void setOperStatus(String operStatus) {
        this.operStatus = operStatus;
    }
}
