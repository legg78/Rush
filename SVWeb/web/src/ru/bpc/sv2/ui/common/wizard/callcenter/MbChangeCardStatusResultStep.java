package ru.bpc.sv2.ui.common.wizard.callcenter;

import org.apache.log4j.Logger;
import ru.bpc.sv2.common.WizardConstants;
import ru.bpc.sv2.issuing.CardInstance;
import ru.bpc.sv2.ui.common.wizard.AbstractWizardStep;
import ru.bpc.sv2.ui.common.wizard.MbCommonWizard;

import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import java.util.Map;

@ViewScoped
@ManagedBean(name = "MbChangeCardStatusResultStep")
public class MbChangeCardStatusResultStep extends AbstractWizardStep {

    private static final Logger logger = Logger.getLogger(MbChangeCardStatusResultStep.class);
    private static final String PAGE = "/pages/common/wizard/callcenter/changeCardStatusResultStep.jspx";
    private static final String INSTANCE = "INSTANCE";

    private CardInstance cardInstance;
    private String operStatus;

    @Override
    public void init(Map<String, Object> context) {
        logger.trace("init...");

        super.init(context, PAGE);

        if (context.containsKey(INSTANCE)) {
            setCardInstance((CardInstance) context.get(INSTANCE));
        } else if (!isMaker()) {
            throw new IllegalStateException("INSTANCE is not defined in wizard context");
        }
        if (context.containsKey(WizardConstants.OPER_STATUS)) {
            setOperStatus((String) context.get(WizardConstants.OPER_STATUS));
        } else {
            throw new IllegalStateException("OPER_STATUS is not defined in wizard context");
        }
        context.put(MbCommonWizard.DISABLE_BACK, Boolean.TRUE);
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

    public CardInstance getCardInstance() {
        return cardInstance;
    }

    public void setCardInstance(CardInstance cardInstance) {
        this.cardInstance = cardInstance;
    }

    public String getOperStatus() {
        return operStatus;
    }

    public void setOperStatus(String operStatus) {
        this.operStatus = operStatus;
    }

}
