package ru.bpc.sv2.ui.common.wizard.callcenter.card;

import org.apache.log4j.Logger;
import ru.bpc.sv2.common.WizardConstants;
import ru.bpc.sv2.logic.AccountsDao;
import ru.bpc.sv2.ui.common.wizard.CommonWizardStep;
import ru.bpc.sv2.ui.common.wizard.MbCommonWizard;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import java.util.Map;

@ViewScoped
@ManagedBean(name = "MbCardOperationRS")
public class MbCardOperationRS implements CommonWizardStep {
    private static final Logger classLogger = Logger.getLogger(MbCardOperationRS.class);
    private static final String PAGE = "/pages/common/wizard/callcenter/card/cardOperationRS.jspx";

    private AccountsDao accountsDao = new AccountsDao();

    private String operStatus;
    private Map<String, Object> context;

    @Override
    public void init(Map<String, Object> context) {
        classLogger.trace("init...");
        this.context = context;
        context.put(MbCommonWizard.PAGE, PAGE);
        if (!context.containsKey(WizardConstants.OPER_STATUS)) {
            throw new IllegalStateException(WizardConstants.OPER_STATUS + " is not defined in wizard context");
        }
        operStatus = (String) context.get(WizardConstants.OPER_STATUS);
    }

    @Override
    public Map<String, Object> release(Direction direction) {
        classLogger.trace("release...");
        return context;
    }

    @Override
    public boolean validate() {
        classLogger.trace("validate...");
        throw new UnsupportedOperationException("validation");
    }

    public String getOperStatus() {
        return operStatus;
    }

    public void setOperStatus(String operStatus) {
        this.operStatus = operStatus;
    }

}
