package ru.bpc.sv2.ui.common.wizard.callcenter;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;
import ru.bpc.sv.recurauth.RecurAuth;
import ru.bpc.sv.recurauth.RecurAuth_Service;
import ru.bpc.sv2.common.WizardConstants;
import ru.bpc.sv2.constants.EntityNames;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.constants.SystemConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.OperationDao;
import ru.bpc.sv2.logic.OrgStructDao;
import ru.bpc.sv2.operations.Operation;
import ru.bpc.sv2.settings.constants.SettingsConstants;
import ru.bpc.sv2.ui.common.wizard.CommonWizardStep;
import ru.bpc.sv2.ui.common.wizard.MbCommonWizard;
import ru.bpc.sv2.ui.utils.DictUtils;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.cache.SettingsCache;
import ru.bpc.sv2.utils.SystemException;
import util.auxil.ManagedBeanWrapper;
import util.auxil.SessionWrapper;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.model.SelectItem;
import javax.xml.ws.BindingProvider;
import javax.xml.ws.Holder;
import java.math.BigDecimal;
import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.*;

@ViewScoped
@ManagedBean(name = "MbReverseOprDS")
public class MbReverseOprDS implements CommonWizardStep {
    private static final Logger logger = Logger.getLogger(MbReverseOprDS.class);
    private static final String PAGE = "/pages/common/wizard/callcenter/reverseOprDS.jspx";
    private static final String PAGE_TERM = "/pages/common/wizard/callcenter/terminal/termReversalDS.jspx";
    private static final String OBJECT_ID = "OBJECT_ID";
    private static final String ENTITY_TYPE = "ENTITY_TYPE";
    private static final String OPERATION = "OPERATION";

    private OperationDao operationDao = new OperationDao();

    private OrgStructDao orgStructDao = new OrgStructDao();

    private Map<String, Object> context;
    private Long objectId;
    private String entityType;
    private Operation[] operations;
    private Long userSessionId;
    private String curLang;
    private String unholdReason;
    private SimpleSelection operationSelection;
    private Operation selectedOperation;
    private boolean invalidOperation;
    private List<SelectItem> unholdReasons;
    private DictUtils dictUtils;
    private RecurAuth servicePort;

    private Date dateFrom;
    private Date dateTo;
    protected List<Filter> filters;
    private String reversalOperId = null;

    public MbReverseOprDS() {
        userSessionId = SessionWrapper.getRequiredUserSessionId();
        curLang = SessionWrapper.getField("language");
        dictUtils = ManagedBeanWrapper.getManagedBean(DictUtils.class);
        dateFrom = new Date();
    }

    @Override
    public void init(Map<String, Object> context) {
        logger.trace("init...");
        reset();

        userSessionId = SessionWrapper.getRequiredUserSessionId();

        this.context = context;
        if (!context.containsKey(OBJECT_ID)) {
            throw new IllegalStateException(OBJECT_ID + " is not defined in wizard context");
        }
        objectId = (Long) context.get(OBJECT_ID);
        if (!context.containsKey(ENTITY_TYPE)) {
            throw new IllegalStateException(ENTITY_TYPE + " is not defined in wizard context");
        }
        entityType = (String) context.get(ENTITY_TYPE);
        if (EntityNames.CARD.equals(entityType)) {
            /*operations = operationsByCard(objectId);*/
            context.put(MbCommonWizard.PAGE, PAGE);
        } else if (EntityNames.TERMINAL.equals(entityType)) {
            /*operations = operationsByTerminal(objectId);*/
            context.put(MbCommonWizard.PAGE, PAGE_TERM);
        }

        context.put(MbCommonWizard.VALIDATED_STEP, Boolean.TRUE);
    }

    public void search() {
        if (EntityNames.CARD.equals(entityType)) {
            operations = operationsByCard(objectId);
        } else if (EntityNames.TERMINAL.equals(entityType)) {
            operations = operationsByTerminal(objectId);
        }
    }

    private Operation[] operationsByTerminal(Long termId) {
        logger.trace("operationsByTerminal...");
        String dbDateFormat = "dd.MM.yyyy";
        DateFormat df = DateFormat.getInstance();
        df.setCalendar(Calendar.getInstance());
        String timeZone = df.getTimeZone().getID();
        SimpleDateFormat sdf = new SimpleDateFormat(dbDateFormat);
        df.setTimeZone(TimeZone.getTimeZone(timeZone));
        filters = new ArrayList<Filter>();
        if (dateFrom != null) {
            filters.add(new Filter("hostDateFrom", sdf.format(dateFrom)));
        }
        if (dateTo != null) {
            filters.add(new Filter("hostDateTo", sdf.format(dateTo)));
        }
        filters.add(new Filter("terminalId", termId));
        filters.add(new Filter("lang", curLang));
        //filters.add(new Filter("id", 1310020000037632L));
        filters.add(new Filter("reversalExists", 0));
        filters.add(new Filter("reversal", 0));

        List<String> operStatuses = new ArrayList<String>();
        operStatuses.add("OPST0400");
        operStatuses.add("OPST0401");
        operStatuses.add("OPST0402");
        operStatuses.add("OPST0403");
        operStatuses.add("OPST0800");
        filters.add(new Filter("statuses", null, operStatuses));

        SelectionParams sp = new SelectionParams(filters);
        sp.setRowIndexEnd(99);

        Operation[] result = operationDao.getOperationsByParticipant(userSessionId, sp);
        return result;
    }

    private Operation[] operationsByCard(Long cardId) {
        logger.trace("operationsByCard...");
        String dbDateFormat = "dd.MM.yyyy";
        DateFormat df = DateFormat.getInstance();
        df.setCalendar(Calendar.getInstance());
        String timeZone = df.getTimeZone().getID();
        SimpleDateFormat sdf = new SimpleDateFormat(dbDateFormat);
        df.setTimeZone(TimeZone.getTimeZone(timeZone));
        filters = new ArrayList<Filter>();
        if (dateFrom != null) {
            filters.add(new Filter("hostDateFrom", sdf.format(dateFrom)));
        }
        if (dateTo != null) {
            filters.add(new Filter("hostDateTo", sdf.format(dateTo)));
        }
        filters.add(new Filter("cardId", cardId));
        filters.add(new Filter("lang", curLang));
        filters.add(new Filter("reversalExists", 0));

        List<String> operStatuses = new ArrayList<String>();
        operStatuses.add("OPST0400");
        operStatuses.add("OPST0401");
        operStatuses.add("OPST0402");
        operStatuses.add("OPST0403");
        operStatuses.add("OPST0800");
        filters.add(new Filter("statuses", null, operStatuses));

        Operation[] result;
        SelectionParams sp = new SelectionParams();
        sp.setRowIndexEnd(99);
        sp.setFilters(filters.toArray(new Filter[filters.size()]));
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
            //if (EntityNames.CARD.equals(entityType)){
            String operStatus = reverseOperationByCard();
            context.put(WizardConstants.OPER_STATUS, operStatus);
            //}
            selectedOperation = updatedOperation(reversalOperId);
            context.put(OPERATION, selectedOperation);
        }
        return context;
    }

    private Operation updatedOperation(String reversalId) {
        Operation result = null;
        SelectionParams sp = SelectionParams.build("id", reversalId);
        Operation[] operations = operationDao.getOperationsByParticipant(userSessionId, sp);
        if (operations.length > 0) {
            result = operations[0];
        }
        return result;
    }

    private String reverseOperationByCard() {
        logger.trace("reverseOperationByCard...");
        /*if (!context.containsKey(CARD)) throw new IllegalStateException(CARD + " is not defined in wizard context");*/
        try {
            initServicePort();
        } catch (SystemException e) {
            logger.trace("Cannot init RecurAuth service port.", e);
        }
        Holder<String> respCodeHolder = new Holder<String>();
        Holder<String> newAuthIdHolder = new Holder<String>();
        servicePort.disputeReversal(selectedOperation.getId().toString(), null, null, null, null, null, null, respCodeHolder, newAuthIdHolder);
        reversalOperId = newAuthIdHolder.value;
        return respCodeHolder.value;
    }

    private void initServicePort() throws SystemException {
        RecurAuth_Service service = new RecurAuth_Service();
        servicePort = service.getRecurAuthSOAP();
        BindingProvider bp = (BindingProvider) servicePort;

        SettingsCache settingParamsCache = SettingsCache.getInstance();
        String feLocation = settingParamsCache
                .getParameterStringValue(SettingsConstants.FRONT_END_LOCATION);
        if (feLocation == null || feLocation.trim().length() == 0) {
            throw new SystemException("FE location is not defined");
        }

        BigDecimal port = settingParamsCache.getParameterNumberValue(SettingsConstants.RECURAUTH_WS_PORT);
        if (port == null) {
            String msg = FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Common", "sys_param_empty",
                    SettingsConstants.RECURAUTH_WS_PORT);
            throw new SystemException(msg);
        }

        feLocation = feLocation + ":" + port.intValue();
        bp.getRequestContext().put(BindingProvider.ENDPOINT_ADDRESS_PROPERTY, feLocation);
        bp.getRequestContext().put("javax.xml.ws.client.connectionTimeout", SystemConstants.FE_TIMEOUT);
        bp.getRequestContext().put("javax.xml.ws.client.receiveTimeout", SystemConstants.FE_TIMEOUT);
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
        if (!keys.hasNext()) return -1;
        Integer index = (Integer) keys.next();
        return index;
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

    public Date getDateFrom() {
        return dateFrom;
    }

    public void setDateFrom(Date dateFrom) {
        this.dateFrom = dateFrom;
    }

    public Date getDateTo() {
        return dateTo;
    }

    public void setDateTo(Date dateTo) {
        this.dateTo = dateTo;
    }


}
