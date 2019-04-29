package ru.bpc.sv2.ui.common.wizard.operations;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.OperationDao;
import ru.bpc.sv2.operations.Operation;
import ru.bpc.sv2.operations.OperationUnpaidDebt;
import ru.bpc.sv2.ui.accounts.MbAccountsAllSearch;
import ru.bpc.sv2.ui.common.wizard.CommonWizardStep;
import ru.bpc.sv2.ui.common.wizard.MbCommonWizard;
import ru.bpc.sv2.ui.operations.MbOperations;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.TableRowSelection;
import util.auxil.ManagedBeanWrapper;
import util.auxil.SessionWrapper;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.model.SelectItem;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * BPC GROUP 2016 (c) All Rights Reserved
 */

@ViewScoped
@ManagedBean(name = "MbRepaymentDebtOperationDS")
public class MbRepaymentDebtOperationDS extends AbstractBean implements CommonWizardStep {

    private static final Logger logger = Logger.getLogger(MbRepaymentDebtOperationDS.class);
    private static final String UNPAID_DEBT_OPERATION = "UNPAID_DEBT_OPERATION";
    private static final String PAGE = "/pages/common/wizard/callcenter/operation/MbRepaymentDebtOperationDS.jspx";

    private Map<String, Object> context;
    private long userSessionId;

    private final DaoDataModel<OperationUnpaidDebt> _operationSource;
    private final TableRowSelection<OperationUnpaidDebt> _itemSelection;
    private OperationUnpaidDebt activeOperation;
    private OperationUnpaidDebt newOperation;

    private Long accId;

    private MbAccountsAllSearch mbAccountsAllSearch = null;

    private OperationDao _operationDao = new OperationDao();

    public MbRepaymentDebtOperationDS() {
        userSessionId = SessionWrapper.getRequiredUserSessionId();
        mbAccountsAllSearch = (MbAccountsAllSearch) ManagedBeanWrapper.getManagedBean("MbAccountsAllSearch");
        accId = mbAccountsAllSearch.getActiveAccount().getId();
        final Integer count = null;
        final Map<String, Object> map = new HashMap<String, Object>();
        final Map<String, Object> paramMap = new HashMap<String, Object>() {{ put("count", count); put("account_id", accId); put("param_tab", map); }};

        _operationSource = new DaoDataModel<OperationUnpaidDebt>() {

            @Override
            protected OperationUnpaidDebt[] loadDaoData(SelectionParams params) {
                try {
                    return _operationDao.getUnpaidDebtOperations(userSessionId, paramMap);
                } catch (Exception e) {
                    FacesUtils.addMessageError(e);
                    setDataSize(0);
                    logger.error("", e);
                }
                return new OperationUnpaidDebt[0];
            }

            @Override
            protected int loadDaoDataSize(SelectionParams params) {
                int count = 0;
                try {
                    count =_operationDao.getUnpaidDebtOperationsCount(userSessionId, paramMap);
                } catch (Exception e) {
                    FacesUtils.addMessageError(e);
                    logger.error("", e);
                }
                return count;
            }
        };
        _itemSelection = new TableRowSelection<OperationUnpaidDebt>(null, _operationSource);
    }

    public void setFirstRowActive() {
        _operationSource.setRowIndex(0);
        SimpleSelection selection = new SimpleSelection();
        activeOperation = (OperationUnpaidDebt) _operationSource.getRowData();
        selection.addKey(activeOperation.getId());
        _itemSelection.setWrappedSelection(selection);
    }

    public void setItemSelection(SimpleSelection selection) {
        _itemSelection.setWrappedSelection(selection);
        activeOperation = _itemSelection.getSingleSelection();
    }

    public SimpleSelection getItemSelection() {
        try {
            if (activeOperation == null && _operationSource.getRowCount() > 0) {
                setFirstRowActive();
            } else if (activeOperation != null && _operationSource.getRowCount() > 0) {
                SimpleSelection selection = new SimpleSelection();
                selection.addKey(activeOperation.getModelId());
                _itemSelection.setWrappedSelection(selection);
                activeOperation = _itemSelection.getSingleSelection();
                curLang = userLang;
            }
        } catch (Exception e) {
            logger.error("", e);
            FacesUtils.addErrorExceptionMessage(e);
        }
        return _itemSelection.getWrappedSelection();
    }

    public void selectDebtOperation() {
        newOperation = activeOperation;

        MbOperations operations = (MbOperations) ManagedBeanWrapper.getManagedBean("MbOperations");
        if (operations.getActiveOperation() == null) {
            Operation operation = new Operation();
            operation.setId(newOperation.getOperId());
            operation.setOperType(newOperation.getOperType());
            operation.setOperReason(newOperation.getOperReason());
            operation.setMsgType(newOperation.getMsgType());
            operation.setStatus(newOperation.getOperStatus());
            operations.setActiveOperation(operation);
        } else {
            Operation operation = operations.getActiveOperation();
            operation.setId(newOperation.getOperId());
            operation.setOperType(newOperation.getOperType());
            operation.setOperReason(newOperation.getOperReason());
            operation.setMsgType(newOperation.getMsgType());
            operation.setStatus(newOperation.getOperStatus());
        }

    }

    public boolean checkAgingIndebtedness() {
        Map<String, Object> params = new HashMap<String, Object>();
        params.put("result", new Boolean(false));
        params.put("account_id", accId);
        Boolean result = _operationDao.checkAgingDebts(userSessionId, params);
        return result.booleanValue();
    }

    public List<SelectItem> getAccelerationTypes() {
        return getDictUtils().getLov(LovConstants.DEFFERED_PLAN_ACCELERATION_TYPE);
    }

    @Override
    public void clearFilter() {
    }

    @Override
    public void init(Map<String, Object> context) {
        logger.trace("init...");
        reset();
        accId = mbAccountsAllSearch.getActiveAccount().getId();
        newOperation = new OperationUnpaidDebt();
        this.context = context;
        context.put(MbCommonWizard.VALIDATED_STEP, Boolean.TRUE);
        context.put(MbCommonWizard.PAGE, PAGE);
    }

    @Override
    public Map<String, Object> release(Direction direction) {
        logger.trace("release...");
        if (direction == Direction.FORWARD) {
            context.put(UNPAID_DEBT_OPERATION, newOperation);
        }
        return context;
    }

    @Override
    public boolean validate() {
        logger.trace("validate...");
        return checkConditions();
    }

    private boolean checkConditions() {
        if (_operationSource.getDataSize() == 0) { FacesUtils.addMessageError("List of debt operations is empty!"); return false; }
        if (newOperation.getInstallmentNumber() == null) { FacesUtils.addMessageError("The installment number is empty!"); return false; }
        if (newOperation.getDppId() == null) { FacesUtils.addMessageError("Dpp Id is empty!"); return false; }
        if (newOperation.getAccelerationType() == null || newOperation.getAccelerationType().isEmpty()) { FacesUtils.addMessageError("Acceleration type is empty!"); return false;}
        if (newOperation.getRepaymentAmount() == null) { FacesUtils.addMessageError("Repayment amount is empty!"); return false; }
        if (checkAgingIndebtedness()) { return true; }
        else { FacesUtils.addMessageError("Verification error"); return false; }
    }

    public DaoDataModel<OperationUnpaidDebt> getOperations() {
        return _operationSource;
    }

    private void reset() {
        context = null;
        newOperation = null;
        activeOperation = null;
        MbOperations operations = (MbOperations) ManagedBeanWrapper.getManagedBean("MbOperations");
        operations.setActiveOperation(null);
        clearState();
    }

    private void clearState() {
        _itemSelection.clearSelection();
        _operationSource.flushCache();
    }

    public OperationUnpaidDebt getActiveOperation() {
        return activeOperation;
    }

    public void setActiveOperation(OperationUnpaidDebt activeOperation) {
        this.activeOperation = activeOperation;
    }

    public OperationUnpaidDebt getNewOperation() {
        return newOperation;
    }

    public void setNewOperation(OperationUnpaidDebt newOperation) {
        this.newOperation = newOperation;
    }

    public Long getAccId() {
        return accId;
    }

    public void setAccId(Long accId) {
        this.accId = accId;
    }
}
