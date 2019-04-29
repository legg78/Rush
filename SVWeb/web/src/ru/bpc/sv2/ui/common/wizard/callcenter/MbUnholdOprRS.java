package ru.bpc.sv2.ui.common.wizard.callcenter;

import org.apache.log4j.Logger;
import ru.bpc.sv2.common.WizardConstants;
import ru.bpc.sv2.operations.Operation;
import ru.bpc.sv2.ui.common.wizard.AbstractWizardStep;
import ru.bpc.sv2.ui.common.wizard.MbCommonWizard;

import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import java.util.Map;

@ViewScoped
@ManagedBean(name = "MbUnholdOprRS")
public class MbUnholdOprRS extends AbstractWizardStep {
    private static final Logger logger = Logger.getLogger(MbUnholdOprRS.class);
    private static final String PAGE = "/pages/common/wizard/callcenter/unholdOprRS.jspx";
    private static final String OPERATION = "OPERATION";

    private String operStatus;
    private Operation operation;

    @Override
    public void init(Map<String, Object> context) {
        reset();
        super.init(context, PAGE);

        putContext(MbCommonWizard.DISABLE_BACK, Boolean.TRUE);
        operStatus = getContextRequired(WizardConstants.OPER_STATUS);
        operation = getContextRequired(OPERATION);
    }

    private void reset() {
        logger.trace("reset...");
        operStatus = null;
        operation = null;
    }

    @Override
    public Map<String, Object> release(Direction direction) {
        logger.trace("release...");
        return getContext();
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
