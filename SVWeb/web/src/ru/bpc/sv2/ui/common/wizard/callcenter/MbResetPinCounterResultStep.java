package ru.bpc.sv2.ui.common.wizard.callcenter;

import org.apache.log4j.Logger;
import ru.bpc.sv2.common.WizardConstants;
import ru.bpc.sv2.constants.EntityNames;
import ru.bpc.sv2.fcl.limits.LimitCounter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.issuing.CardInstance;
import ru.bpc.sv2.logic.LimitsDao;
import ru.bpc.sv2.ui.common.wizard.CommonWizardStep;
import ru.bpc.sv2.ui.common.wizard.MbCommonWizard;
import util.auxil.SessionWrapper;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import java.util.Map;

@ViewScoped
@ManagedBean(name = "MbResetPinCounterResultStep")
public class MbResetPinCounterResultStep implements CommonWizardStep {

    private static final Logger logger = Logger.getLogger(MbResetPinCounterResultStep.class);
    private static final String PAGE = "/pages/common/wizard/callcenter/resetPinCounterResultStep.jspx";
    private static final String INSTANCE = "INSTANCE";
    private static final String WRONG_PIN_LIMIT = "LMTP0101";

    private LimitsDao limitsDao = new LimitsDao();

    private Map<String, Object> context;
    private CardInstance cardInstance;
    private String operStatus;
    private Long pinCounter;
    private long userSessionId;

    public MbResetPinCounterResultStep() {
        userSessionId = SessionWrapper.getRequiredUserSessionId();
    }

    @Override
    public void init(Map<String, Object> context) {
        logger.trace("init...");
        this.context = context;
        context.put(MbCommonWizard.PAGE, PAGE);
        if (context.containsKey(INSTANCE)) {
            setCardInstance((CardInstance) context.get(INSTANCE));
        } else {
            throw new IllegalStateException("INSTANCE is not defined in wizard context");
        }
        if (context.containsKey(WizardConstants.OPER_STATUS)) {
            setOperStatus((String) context.get(WizardConstants.OPER_STATUS));
        } else {
            throw new IllegalStateException("OPER_STATUS is not defined in wizard context");
        }
        context.put(MbCommonWizard.DISABLE_BACK, Boolean.TRUE);
        pinCounter = obtainPinCounter();
    }

    private Long obtainPinCounter() {
        Long result = null;
        SelectionParams sp = SelectionParams.build("entityType", EntityNames.CARD,
                "objectId", cardInstance.getCardId(),
                "limitType", WRONG_PIN_LIMIT);
        LimitCounter[] limitCounters = limitsDao.getLimitCounters(userSessionId, sp);
        if (limitCounters.length > 0) {
            result = limitCounters[0].getCountValue();
        }
        return result;
    }

    @Override
    public Map<String, Object> release(Direction direction) {
        logger.trace("release...");
        return context;
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

    public void setPinCounter(Long pinCounter) {
        this.pinCounter = pinCounter;
    }

    public Long getPinCounter() {
        return this.pinCounter;
    }
}
