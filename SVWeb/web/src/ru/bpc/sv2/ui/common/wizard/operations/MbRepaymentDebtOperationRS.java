package ru.bpc.sv2.ui.common.wizard.operations;

import ru.bpc.sv2.logic.OperationDao;
import ru.bpc.sv2.operations.OperationUnpaidDebt;
import ru.bpc.sv2.ui.common.wizard.CommonWizardStep;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import java.util.Map;
import org.apache.log4j.*;
import ru.bpc.sv2.ui.common.wizard.MbCommonWizard;
import util.auxil.SessionWrapper;

/**
 * BPC GROUP 2016 (c) All Rights Reserved
 */

@ViewScoped
@ManagedBean(name = "MbRepaymentDebtOperationRS")
public class MbRepaymentDebtOperationRS implements CommonWizardStep {

    private static final Logger logger = Logger.getLogger(MbRepaymentDebtOperationRS.class);
    private static final String PAGE = "/pages/common/wizard/callcenter/operation/MbRepaymentDebtOperationRS.jspx";
    private static final String UNPAID_DEBT_OPERATION = "UNPAID_DEBT_OPERATION";
    private Map<String, Object> context;
    private long userSessionId;
    private OperationUnpaidDebt resultUnpaidDebt;

    private OperationDao _operationDao = new OperationDao();

    @Override
    public void init(Map<String, Object> context) {
        reset();
        logger.trace("init...");
        this.context = context;
        userSessionId = SessionWrapper.getRequiredUserSessionId();
        context.put(MbCommonWizard.PAGE, PAGE);

        if (!context.containsKey(UNPAID_DEBT_OPERATION)){
            throw new IllegalStateException(UNPAID_DEBT_OPERATION + " is not defined in wizard context");
        } else
            resultUnpaidDebt = (OperationUnpaidDebt)context.get(UNPAID_DEBT_OPERATION);
    }

    private void reset() {
        context = null;
        resultUnpaidDebt = null;
    }

    @Override
    public Map<String, Object> release(Direction direction) {
        if (direction == Direction.FORWARD) {
            if (resultUnpaidDebt != null) {
                performOperation(resultUnpaidDebt);
            }
        }
        return context;
    }

    private void performOperation(OperationUnpaidDebt resultUnpaidDebt) {
        _operationDao.performRepaymentDebtOperation(userSessionId, resultUnpaidDebt);
    }

    @Override
    public boolean validate() {
        throw new UnsupportedOperationException("validate");
    }

    public OperationUnpaidDebt getResultUnpaidDebt() {
        return resultUnpaidDebt;
    }

    public void setResultUnpaidDebt(OperationUnpaidDebt resultUnpaidDebt) {
        this.resultUnpaidDebt = resultUnpaidDebt;
    }
}
