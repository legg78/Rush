package ru.bpc.sv2.ui.common.wizard.operations;

import org.apache.log4j.Logger;
import ru.bpc.sv2.common.WizardConstants;
import ru.bpc.sv2.logic.OperationDao;
import ru.bpc.sv2.ui.common.wizard.AbstractWizardStep;
import ru.bpc.sv2.ui.common.wizard.MbCommonWizard;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import java.util.Map;

@ViewScoped
@ManagedBean(name = "MbChangeOperationsStatusRS")
public class MbChangeOperationsStatusRS extends AbstractWizardStep {

    private static final Logger classLogger = Logger.getLogger(MbChangeOperationsStatusRS.class);
    private static final String PAGE = "/pages/common/wizard/callcenter/operation/changeOperationsStatusRS.jspx";
    private static final String ENTITY_TYPE = "ENTITY_TYPE";

    private OperationDao operationDao = new OperationDao();

    private String entityType;
    private Long objectId;
    private String currentStatus;
    private String operStatus;

    @Override
    public void init(Map<String, Object> context) {
        super.init(context, PAGE);
        classLogger.trace("init...");
        context.put(MbCommonWizard.DISABLE_BACK, Boolean.TRUE);
        if (!context.containsKey(ENTITY_TYPE)) {
            throw new IllegalStateException(ENTITY_TYPE + " is not defined in wizard context");
        }
        entityType = (String) context.get(ENTITY_TYPE);
        operStatus = (String) context.get(WizardConstants.OPER_STATUS);
    }

    @Override
    public Map<String, Object> release(Direction direction) {
        classLogger.trace("release...");
        return getContext();
    }

    @Override
    public boolean validate() {
        classLogger.trace("validate...");
        throw new UnsupportedOperationException("validate");
    }

    public String getOperStatus() {
        return operStatus;
    }

    public void setOperStatus(String operStatus) {
        this.operStatus = operStatus;
    }
}
