package ru.bpc.sv2.ui.common.wizard.callcenter;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;
import ru.bpc.sv2.common.WizardConstants;
import ru.bpc.sv2.constants.EntityNames;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.issuing.Card;
import ru.bpc.sv2.logic.ApplicationDao;
import ru.bpc.sv2.logic.IssuingDao;
import ru.bpc.sv2.logic.OperationDao;
import ru.bpc.sv2.operations.Operation;
import ru.bpc.sv2.ui.common.wizard.AbstractWizardStep;
import ru.bpc.sv2.ui.common.wizard.application.ApplicationBuilder;
import ru.bpc.sv2.ui.utils.DictUtils;
import util.auxil.ManagedBeanWrapper;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.model.SelectItem;
import java.util.*;

@ViewScoped
@ManagedBean(name = "MbUnholdOprDS")
public class MbUnholdOprDS extends AbstractWizardStep {
    private static final Logger logger = Logger.getLogger(MbUnholdOprDS.class);
    private static final String PAGE = "/pages/common/wizard/callcenter/unholdOprDS.jspx";
    private static final String OBJECT_ID = "OBJECT_ID";
    private static final String ENTITY_TYPE = "ENTITY_TYPE";
    private static final String OPERATION = "OPERATION";

    private OperationDao operationDao = new OperationDao();
    private ApplicationDao applicationDao = new ApplicationDao();
    private IssuingDao issuingDao = new IssuingDao();

    private Long objectId;
    private String entityType;
    private Operation[] operations;
    private String unholdReason;
    private SimpleSelection operationSelection;
    private Operation selectedOperation;
    private boolean invalidOperation;
    private List<SelectItem> unholdReasons;
    private DictUtils dictUtils;
    private Card card;

    public MbUnholdOprDS() {
        dictUtils = ManagedBeanWrapper.getManagedBean(DictUtils.class);
    }

    @Override
    public void init(Map<String, Object> context) {
        reset();
        super.init(context, PAGE, true);

        objectId = getContextRequired(OBJECT_ID);
        entityType = getContextRequired(ENTITY_TYPE);
        if (EntityNames.CARD.equals(entityType)) {
            operations = operationsByCard(objectId);
            card = retriveCard(objectId);
        }
    }

    private Card retriveCard(Long cardId) {
        logger.trace("retriveCard...");
        Card result;
        SelectionParams sp = SelectionParams.build("CARD_ID", cardId);
        Map<String, Object> paramMap = new HashMap<String, Object>();
        paramMap.put("tab_name", "CARD");
        paramMap.put("param_tab", sp.getFilters());
        Card[] cards = issuingDao.getCardsCur(userSessionId, sp, paramMap);
        if (cards.length > 0) {
            result = cards[0];
        } else {
            throw new IllegalStateException("Card with ID:" + cardId + " is not found!");
        }
        return result;
    }

	private Operation[] operationsByCard(Long cardId) {
		logger.trace("operationsByCard...");
		Operation[] result;

		List<String> operStatuses = new ArrayList<String>();
		operStatuses.add("OPST0800");
		operStatuses.add("OPST0850");

		List<Filter> filters = new ArrayList<Filter>();
		filters.add(Filter.create("cardId", cardId));
		filters.add(Filter.create("lang", curLang));
		filters.add(new Filter("statuses", null, operStatuses));

		SelectionParams sp = new SelectionParams(filters);
		sp.setRowIndexEnd(-1);

		result = operationDao.getOperationsByParticipant(userSessionId, sp);
		return result;
	}

    private void reset() {
        logger.trace("reset...");
        objectId = null;
        entityType = null;
        operations = null;
        unholdReason = null;
    }

    @Override
    public Map<String, Object> release(Direction direction) {
        logger.trace("release...");
        if (direction == Direction.FORWARD) {
            if (EntityNames.CARD.equals(entityType)) {
                String operStatus = unholdOperationByCard();
                putContext(WizardConstants.OPER_STATUS, operStatus);
            }
            selectedOperation = updatedOperation(selectedOperation);
            putContext(OPERATION, selectedOperation);
        }
        return getContext();
    }

    private Operation updatedOperation(Operation oldOperation) {
        Operation result = null;
        SelectionParams sp = SelectionParams.build("id", oldOperation.getId());
        Operation[] operations = operationDao.getOperationsByParticipant(userSessionId, sp);
        if (operations.length > 0) {
            result = operations[0];
        }
        return result;
    }

    private String unholdOperationByCard() {
        logger.trace("unholdOperationByCard...");
        if (isMaker()) {
            selectedOperation.setOperReason(unholdReason);
            ApplicationBuilder builder = new ApplicationBuilder(applicationDao, userSessionId, card.getInstId(), getFlowId());
            builder.buildFromOperation(selectedOperation, true);
            builder.createApplicationInDB();
            builder.addApplicationObject(selectedOperation);
            return builder.getApplication().getStatus();
        } else {
            operationDao.unholdOperation(userSessionId, selectedOperation.getId(), unholdReason);

            List<Operation> operations = operationDao.getOperations(userSessionId, SelectionParams.build("id", selectedOperation.getId()), "LANGENG");
            return operations != null ? operations.get(0).getStatus() : null;
        }
    }

    @Override
    public boolean validate() {
        logger.trace("validate...");
        return checkCardInstance();
    }

    private boolean checkCardInstance() {
        return !(invalidOperation = (selectedOperation == null));
    }

    public void setOperationSelection(SimpleSelection operationSelection) {
        logger.trace("setOperationSelection...");
        this.operationSelection = operationSelection;
        if (operations == null || operations.length == 0) return;
        int index = selectedIdx();
        if (index < 0) return;
        Operation operation = operations[index];
        if (!operation.equals(selectedOperation)) {
            selectedOperation = operation;
            checkCardInstance();
        }
    }

    private Integer selectedIdx() {
        logger.trace("selectedIdx...");
        Iterator<Object> keys = operationSelection.getKeys();
        if (!keys.hasNext()) {
            return -1;
        }
        return (Integer) keys.next();
    }

    public List<SelectItem> getUnholdReasons() {
        if (unholdReasons == null) {
            unholdReasons = dictUtils.getLov(LovConstants.UNHOLD_REASONS);
        }
        return unholdReasons;
    }

    public SimpleSelection getOperationSelection() {
        return this.operationSelection;
    }

    public Operation[] getOperations() {
        return operations;
    }

    public void setOperations(Operation[] operations) {
        this.operations = operations;
    }

    public String getUnholdReason() {
        return unholdReason;
    }

    public void setUnholdReason(String unholdReason) {
        this.unholdReason = unholdReason;
    }

    public boolean isInvalidOperation() {
        return invalidOperation;
    }

    public void setInvalidOperation(boolean invalidOperation) {
        this.invalidOperation = invalidOperation;
    }

    public void setUnholdReasons(List<SelectItem> unholdReasons) {
        this.unholdReasons = unholdReasons;
    }
}
