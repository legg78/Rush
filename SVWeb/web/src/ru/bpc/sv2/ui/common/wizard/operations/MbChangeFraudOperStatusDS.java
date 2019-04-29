package ru.bpc.sv2.ui.common.wizard.operations;

import org.apache.log4j.Logger;
import ru.bpc.sv2.common.WizardConstants;
import ru.bpc.sv2.constants.EntityNames;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.logic.ApplicationDao;
import ru.bpc.sv2.logic.OperationDao;
import ru.bpc.sv2.operations.Operation;
import ru.bpc.sv2.ui.common.wizard.AbstractWizardStep;
import ru.bpc.sv2.ui.common.wizard.application.ApplicationBuilder;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.model.SelectItem;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@ViewScoped
@ManagedBean(name = "MbChangeFraudOperStatusDS")
public class MbChangeFraudOperStatusDS extends AbstractWizardStep {
    private static final Logger logger = Logger.getLogger(MbChangeFraudOperStatusDS.class);
    private static final String PAGE = "/pages/common/wizard/callcenter/operation/changeFraudOperStatusDS.jspx";
    private static final String ENTITY_TYPE = "ENTITY_TYPE";
    private static final String COMMAND = "COMMAND";
    private static final String OPERATION = "OPERATION";

    private Operation operation;
    private String command;
    private List<SelectItem> commands;

    private OperationDao operationDao = new OperationDao();
    private ApplicationDao applicationDao = new ApplicationDao();

    @Override
    public void init(Map<String, Object> context) {
        super.init(context, PAGE);
        logger.trace("init...");
        reset();

        if (!context.containsKey(ENTITY_TYPE)) {
            throw new IllegalStateException(ENTITY_TYPE + " is not defined in wizard context");
        } else if (!EntityNames.OPERATION.equals((String) context.get(ENTITY_TYPE))) {
            throw new IllegalStateException((String) context.get(ENTITY_TYPE) + " is not supported entity type");
        }
        if (!context.containsKey(OPERATION)) {
            throw new IllegalStateException(OPERATION + " is not defined in wizard context");
        } else {
            operation = (Operation) context.get(OPERATION);
        }
    }

    @Override
    public Map<String, Object> release(Direction direction) {
        logger.trace("release...");
        if (direction == Direction.FORWARD) {
            setOperationStage();
            getContext().put(OPERATION, operation);
            getContext().put(COMMAND, command);
        }
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

    public List<SelectItem> getCommands() {
        if (commands == null) {
            commands = getLov(LovConstants.CONTROL_COMMANDS);
        }
        return commands;
    }


    private void reset() {
        commands = null;
        operation = null;
        userSessionId = null;
        command = null;
    }

    private void setOperationStage() {
        logger.trace("setOperationStage...");

        if (isMaker()) {
            Operation oper = new Operation();
            oper.setId(operation.getId());
            oper.setExternalAuthId(operation.getExternalAuthId().trim());
            oper.setIsReversal(Boolean.TRUE.equals(operation.getIsReversal()));
            oper.setCommand(command);

            ApplicationBuilder builder = new ApplicationBuilder(
                    applicationDao,
                    userSessionId,
                    operation.getIssInstId() == null ? operation.getAcqInstId() : operation.getIssInstId(),
                    getFlowId()
            );

            builder.buildFromOperation(oper, false);
            builder.createApplicationInDB();
            builder.addApplicationObject(operation);
            putContext(WizardConstants.OPER_STATUS, builder.getApplication().getStatus());
        } else {
            Map<String, Object> params = new HashMap<String, Object>();
            if (operation.getId() != null) {
                params.put("operId", operation.getId());
            }
            if (operation.getExternalAuthId() != null && !operation.getExternalAuthId().trim().isEmpty()) {
                params.put("externalAuthId", operation.getExternalAuthId().trim());
            }
            if (operation.getIsReversal() != null) {
                params.put("isReversal", Boolean.TRUE.equals(operation.getIsReversal()) ? 1 : 0);
            }
            if (command != null) {
                params.put("command", command.trim());
            }
            try {
                operationDao.setOperStage(userSessionId, null, params);
            } catch (Exception e) {
                logger.error(null, e);
            }
        }
    }
}
