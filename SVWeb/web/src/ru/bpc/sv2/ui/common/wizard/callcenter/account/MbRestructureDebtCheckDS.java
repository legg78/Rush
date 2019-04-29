package ru.bpc.sv2.ui.common.wizard.callcenter.account;

import org.apache.log4j.Logger;
import ru.bpc.sv2.credit.DppCalculation;
import ru.bpc.sv2.logic.AccountsDao;
import ru.bpc.sv2.ui.common.wizard.CommonWizardStep;
import ru.bpc.sv2.ui.common.wizard.MbCommonWizard;
import util.auxil.SessionWrapper;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

@ViewScoped
@ManagedBean (name = "MbRestructureDebtCheckDS")
public class MbRestructureDebtCheckDS implements CommonWizardStep {
    private static final Logger logger = Logger.getLogger(MbRestructureDebtRS.class);
    protected String PAGE = "/pages/common/wizard/callcenter/account/restructureDebtCheckDS.jspx";

    protected AccountsDao accountsDao = new AccountsDao();

    protected Map<String, Object> context;
    protected long userSessionId;
    protected String curLang;
    protected DppCalculation calculation;

    @Override
    public void init(Map<String, Object> context) {
        logger.trace("init...");
        reset();
        userSessionId = SessionWrapper.getRequiredUserSessionId();
        curLang = SessionWrapper.getField("language");
        this.context = context;

        context.put(MbCommonWizard.PAGE, PAGE);
        context.put(MbCommonWizard.DISABLE_BACK, Boolean.FALSE);
        context.put(MbCommonWizard.VALIDATED_STEP, Boolean.FALSE);

        if (context.containsKey(MbRestructureDebtInputDS.DPP_CALCULATION)) {
            calculation = (DppCalculation)context.get(MbRestructureDebtInputDS.DPP_CALCULATION);
        } else {
            throw new IllegalStateException(MbRestructureDebtInputDS.DPP_CALCULATION + " is not defined in wizard context");
        }
    }

    @Override
    public Map<String, Object> release(Direction direction) {
        if (Direction.FORWARD.equals(direction)) {
            accountsDao.restructureToDpp(userSessionId, calculation);
        }
        return context;
    }

    @Override
    public boolean validate() {
        return false;
    }

    public List<Object> getEmptyTable() {
        List<Object> arr = new ArrayList<Object>(1);
        arr.add(new Object());
        return arr;
    }

    public DppCalculation getCalculation() {
        return calculation;
    }
    public void setCalculation(DppCalculation calculation) {
        this.calculation = calculation;
    }

    private void reset() {
        curLang = null;
        calculation = null;
    }

}
