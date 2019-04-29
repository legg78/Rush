package ru.bpc.sv2.ui.common.wizard.callcenter;

import org.apache.log4j.Logger;
import ru.bpc.sv2.common.WizardConstants;
import ru.bpc.sv2.ui.common.wizard.AbstractWizardStep;
import ru.bpc.sv2.ui.common.wizard.MbCommonWizard;

import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import java.util.Map;

@ViewScoped
@ManagedBean(name = "MbSmsAttachRS")
public class MbSmsAttachRS extends AbstractWizardStep {

    private static final Logger logger =Logger.getLogger(MbSmsAttachRS.class);
    private static final String PAGE = "/pages/common/wizard/callcenter/services/smsAttachRS.jspx";
    private static final String MOBILE_PHONE = "MOBILE_PHONE";

    private String operStatus;
    private String mobilePhone;

    @Override
    public void init(Map<String, Object> context) {
        super.init(context, PAGE);
        logger.trace("init...");

        context.put(MbCommonWizard.DISABLE_BACK, Boolean.TRUE);
        if (context.containsKey(WizardConstants.OPER_STATUS)) {
            operStatus = (String) context.get(WizardConstants.OPER_STATUS);
        } else {
            throw new IllegalStateException(WizardConstants.OPER_STATUS + " is not defined in wizard context");
        }
        if (context.containsKey(MOBILE_PHONE)) {
            mobilePhone = (String) context.get(MOBILE_PHONE);
        } else {
            throw new IllegalStateException(MOBILE_PHONE + " is not defined in wizard context");
        }
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

    public String getOperStatus() {
        return operStatus;
    }

    public void setOperStatus(String operStatus) {
        this.operStatus = operStatus;
    }

    public String getMobilePhone() {
        return mobilePhone;
    }

    public void setMobilePhone(String mobilePhone) {
        this.mobilePhone = mobilePhone;
    }

}
