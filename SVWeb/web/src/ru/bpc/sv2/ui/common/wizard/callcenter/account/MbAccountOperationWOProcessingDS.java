package ru.bpc.sv2.ui.common.wizard.callcenter.account;

import org.apache.log4j.Logger;
import ru.bpc.sv2.common.WizardConstants;
import ru.bpc.sv2.logic.ApplicationDao;
import ru.bpc.sv2.operations.incoming.Operation;
import ru.bpc.sv2.ui.common.wizard.application.ApplicationBuilder;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import java.util.Map;

@ViewScoped
@ManagedBean(name = "MbAccountOperationWOProcessingDS")
public class MbAccountOperationWOProcessingDS extends MbAccountOperationDS {

    private static final Logger classLogger = Logger.getLogger(MbAccountOperationWOProcessingDS.class);

    private ApplicationDao applicationDao = new ApplicationDao();

    @Override
    public void init(Map<String, Object> context) {
        PAGE = "/pages/common/wizard/callcenter/account/amountWOProcessDS.jspx";
        super.init(context);
    }

    @Override
    public Map<String, Object> release(Direction direction) {
        classLogger.trace("release...");
        if (direction == Direction.FORWARD) {
            String operStatus = accountOperation();
            getContext().put(WizardConstants.OPER_STATUS, operStatus);
            getContext().put(ACCOUNT, account);
        }
        return getContext();
    }

    private String accountOperation() {
        classLogger.trace("accountOperation...");
        Operation operation = new Operation();
        operation.setOperType(operType);
        operation.setOperReason(operReason);
        operation.setMsgType("MSGTPRES");
        operation.setStatus("OPST0140");
        operation.setSttlType("STTT0000");
        operation.setOperCount(1L);
        operation.setOperationDate(operDate);
        operation.setSourceHostDate(bookDate);
        operation.setOperationAmount(operAmount);
        operation.setParticipantType("PRTYISS");
        operation.setIssInstId(account.getInstId());
        operation.setCustomerId(account.getCustomerId());
        operation.setClientIdType("CITPACCT");
        operation.setClientIdValue(account.getAccountNumber());
        operation.setAccountId(account.getId());
        operation.setAccountNumber(account.getAccountNumber());
        operation.setAccountType(account.getAccountType());
        operation.setOperationCurrency(account.getCurrency());

        if (isMaker()) {
            ApplicationBuilder builder = new ApplicationBuilder(applicationDao, userSessionId, account.getInstId(), getFlowId());
            builder.buildFromOperation(operation, true);
            builder.createApplicationInDB();
            builder.addApplicationObject(account);
            return builder.getApplication().getStatus();
        } else {
            operationDao.addAdjusment(userSessionId, operation);
            return operation.getStatus();
        }
    }
}
