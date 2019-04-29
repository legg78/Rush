package ru.bpc.sv2.ui.common.wizard.operations;

import org.apache.log4j.Logger;
import ru.bpc.sv2.common.WizardConstants;
import ru.bpc.sv2.ui.common.wizard.AbstractWizardStep;
import ru.bpc.sv2.ui.common.wizard.MbCommonWizard;

import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import java.util.Map;

@ViewScoped
@ManagedBean(name = "MbMatchReverseOperationRS")
public class MbMatchReverseOperationRS extends AbstractWizardStep {

    private static final Logger classLogger = Logger.getLogger(MbMatchReverseOperationRS.class);
    private static final String PAGE = "/pages/common/wizard/callcenter/operation/matchReversalOperationRS.jspx";
    private static final String ENTITY_TYPE = "ENTITY_TYPE";
    private static final String OBJECT_ID = "OBJECT_ID";
    private static final String ORIG_OPER_ID = "ORIG_OPER_ID";

    private String operStatus;
    private String origMatchStatus;
    private String presMatchStatus;
    private Long origOperId;
    private Long presOperId;

    @Override
    public void init(Map<String, Object> context) {
        super.init(context, PAGE);

        classLogger.trace("init...");

        context.put(MbCommonWizard.PAGE, PAGE);
        context.put(MbCommonWizard.DISABLE_BACK, Boolean.TRUE);
        if (!context.containsKey(ENTITY_TYPE)) {
            throw new IllegalStateException(ENTITY_TYPE + " is not defined in wizard context");
        }
        if (!context.containsKey(OBJECT_ID)) {
            throw new IllegalStateException(OBJECT_ID + " is not defined in wizard context");
        }
        origOperId = (Long) context.get(ORIG_OPER_ID);
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

    public String getOrigMatchStatus() {
        return origMatchStatus;
    }

    public void setOrigMatchStatus(String origMatchStatus) {
        this.origMatchStatus = origMatchStatus;
    }

    public String getPresMatchStatus() {
        return presMatchStatus;
    }

    public void setPresMatchStatus(String presMatchStatus) {
        this.presMatchStatus = presMatchStatus;
    }

    public Long getOrigOperId() {
        return origOperId;
    }

    public void setOrigOperId(Long origOperId) {
        this.origOperId = origOperId;
    }

    public Long getPresOperId() {
        return presOperId;
    }

    public void setPresOperId(Long presOperId) {
        this.presOperId = presOperId;
    }

    public String getOperStatus() {
        return operStatus;
    }

    public void setOperStatus(String operStatus) {
        this.operStatus = operStatus;
    }
}
