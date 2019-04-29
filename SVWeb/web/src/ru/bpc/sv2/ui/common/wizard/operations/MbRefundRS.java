package ru.bpc.sv2.ui.common.wizard.operations;

import org.apache.log4j.Logger;
import ru.bpc.sv2.constants.EntityNames;
import ru.bpc.sv2.logic.OperationDao;
import ru.bpc.sv2.operations.incoming.Operation;
import ru.bpc.sv2.ui.common.wizard.CommonWizardStep;
import ru.bpc.sv2.ui.common.wizard.MbCommonWizard;
import ru.bpc.sv2.ui.utils.FacesUtils;
import util.auxil.SessionWrapper;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import java.util.Map;

@ViewScoped
@ManagedBean (name = "MbRefundRS")
public class MbRefundRS implements CommonWizardStep {
    private static final Logger logger = Logger.getLogger(MbRefundRS.class);
    private static final String PAGE = "/pages/common/wizard/callcenter/operation/refundRS.jspx";
    private static final String ENTITY_TYPE = "ENTITY_TYPE";
    private static final String OPERATION = "OPERATION";
    private static final String SRC_OPERATION = "SRC_OPERATION";

    protected Map<String, Object> context;
    protected long userSessionId;
    private String curLang;

    private Operation operation;

    protected OperationDao operationDao = new OperationDao();

    @Override
    public void init(Map<String, Object> context) {
        logger.trace("init...");
        this.context = context;
        context.put(MbCommonWizard.PAGE, PAGE);
        context.put(MbCommonWizard.VALIDATED_STEP, Boolean.TRUE);
        userSessionId = SessionWrapper.getRequiredUserSessionId();
        curLang = SessionWrapper.getField("language");

        if (!((String)context.get(ENTITY_TYPE)).equalsIgnoreCase(EntityNames.OPERATION)) {
            throw new IllegalStateException(FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Common", "operation_error"));
        }
        if (context.containsKey(OPERATION)) {
            operation = (Operation) context.get(OPERATION);
        } else {
            throw new IllegalStateException(OPERATION + " is not defined in wizard step context");
        }
    }

    @Override
    public Map<String, Object> release(Direction direction) {
        logger.trace("release...");
        return context;
    }

    @Override
    public boolean validate() {
        return true;
    }

    public Operation getOperation() {
        return operation;
    }
    public void setOperation(Operation operation) {
        this.operation = operation;
    }

    public String getCurLang() {
        return curLang;
    }
    public void setCurLang(String curLang) {
        this.curLang = curLang;
    }
}
