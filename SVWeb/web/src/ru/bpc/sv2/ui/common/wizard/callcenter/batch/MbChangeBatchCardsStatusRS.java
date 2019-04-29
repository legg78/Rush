package ru.bpc.sv2.ui.common.wizard.callcenter.batch;

import org.apache.log4j.Logger;
import ru.bpc.sv2.ui.common.wizard.CommonWizardStep;
import ru.bpc.sv2.ui.common.wizard.MbCommonWizard;
import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import java.util.Map;

@ViewScoped
@ManagedBean(name = "MbChangeBatchCardsStatusRS")
public class MbChangeBatchCardsStatusRS implements CommonWizardStep {

    private static final Logger classLogger = Logger.getLogger(MbChangeBatchCardsStatusRS.class);
    private static final String PAGE = "/pages/common/wizard/callcenter/batch/changeBatchCardsStatusRS.jspx";
    public static final String RESULT = "RESULT";
    private Map<String, Object> context;

    private boolean result;

    @Override
    public void init(Map<String, Object> context) {
        this.context = context;
        context.put(MbCommonWizard.PAGE, PAGE);
        context.put(MbCommonWizard.DISABLE_BACK, Boolean.TRUE);
        result = (Boolean)context.get(RESULT);
    }

    @Override
    public Map<String, Object> release(Direction direction) {
        classLogger.trace("setBatchStatusDelivered...");
        return context;    }

    @Override
    public boolean validate() {
        classLogger.trace("validate...");
        throw new UnsupportedOperationException("validation");
    }

    public boolean isResult() {
        return result;
    }

    public void setResult(boolean result) {
        this.result = result;
    }
}