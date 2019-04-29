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
@ManagedBean(name = "MbMatchOperationRS")
public class MbMatchOperationRS extends AbstractWizardStep {

    private static final Logger classLogger = Logger.getLogger(MbMatchOperationRS.class);
    private static final String PAGE = "/pages/common/wizard/callcenter/operation/matchOperationRS.jspx";
    private static final String ENTITY_TYPE = "ENTITY_TYPE";
    private static final String OBJECT_ID = "OBJECT_ID";
    private static final String ORIG_MATCH_STATUS = "ORIG_MATCH_STATUS";
    private static final String PRES_MATCH_STATUS = "PRES_MATCH_STATUS";
    private static final String ORIG_OPER_ID = "ORIG_OPER_ID";
    private static final String PRES_OPER_ID = "PRES_OPER_ID";

    private OperationDao operationDao = new OperationDao();

    private String entityType;
    private Long objectId;
    private String operStatus;
    private String origMatchStatus;
    private String presMatchStatus;
    private Long origOperId;
    private Long presOperId;

    @Override
    public void init(Map<String, Object> context) {
        super.init(context, PAGE);
        classLogger.trace("init...");

        context.put(MbCommonWizard.DISABLE_BACK, Boolean.TRUE);
        if (!context.containsKey(ENTITY_TYPE)) {
            throw new IllegalStateException(ENTITY_TYPE + " is not defined in wizard context");
        }
        entityType = (String) context.get(ENTITY_TYPE);
        if (!context.containsKey(OBJECT_ID)) {
            throw new IllegalStateException(OBJECT_ID + " is not defined in wizard context");
        }
        objectId = (Long) context.get(OBJECT_ID);
        origOperId = (Long) context.get(ORIG_OPER_ID);
        presOperId = (Long) context.get(PRES_OPER_ID);
        origMatchStatus = (String) context.get(ORIG_MATCH_STATUS);
        presMatchStatus = (String) context.get(PRES_MATCH_STATUS);
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
