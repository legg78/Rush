package ru.bpc.sv2.ui.common.wizard.operations;

import org.apache.log4j.Logger;
import ru.bpc.sv2.ui.common.wizard.CommonWizardStep;
import ru.bpc.sv2.ui.common.wizard.MbCommonWizard;

import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import java.util.Map;

@ViewScoped
@ManagedBean(name = "MbManualSendSmsRS")
public class MbManualSendSmsRS  implements CommonWizardStep {
    private static final Logger logger = Logger.getLogger(MbManualSendSmsRS.class);
    private static final String PAGE = "/pages/common/wizard/callcenter/operation/manualSendSmsRS.jspx";
    private static final String EVENT_TYPE = "EVENT_TYPE";

    private Map<String, Object> context;
    private String eventType;

    @Override
    public void init(Map<String, Object> context) {
        logger.trace("init...");
        this.context = context;
        context.put(MbCommonWizard.PAGE, PAGE);
        if (context.containsKey(EVENT_TYPE)){
            eventType = (String) context.get(EVENT_TYPE);
        } else {
            throw new IllegalStateException(EVENT_TYPE + " is not defined in wizard context");
        }
        context.put(MbCommonWizard.DISABLE_BACK, Boolean.TRUE);
    }

    @Override
    public Map<String, Object> release(Direction direction) {
        return context;
    }

    @Override
    public boolean validate() {
        logger.trace("validate...");
        throw new UnsupportedOperationException("validate");
    }

    public String getEventType() {
        return eventType;
    }

    public void setEventType(String eventType) {
        this.eventType = eventType;
    }
}