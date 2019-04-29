package ru.bpc.sv2.ui.common.wizard.dispute;

import org.apache.commons.lang3.time.DateUtils;
import org.apache.log4j.Logger;
import ru.bpc.sv2.application.StopList;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.constants.application.CaseManagementConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.logic.DisputesDao;
import ru.bpc.sv2.ui.common.wizard.CommonWizardStep;
import ru.bpc.sv2.ui.common.wizard.MbCommonWizard;
import ru.bpc.sv2.ui.utils.DictUtils;
import ru.bpc.sv2.ui.utils.FacesUtils;
import util.auxil.ManagedBeanWrapper;
import util.auxil.SessionWrapper;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.model.SelectItem;
import java.util.*;

import static ru.bpc.sv2.ui.common.wizard.CommonWizardStep.Direction.FORWARD;

@ViewScoped
@ManagedBean (name = "MbStopListDataStepDS")
public class MbStopListDataStepDS implements CommonWizardStep {
    private static final Logger logger = Logger.getLogger(MbStopListDataStepDS.class);
    private static final String PAGE = "/pages/common/wizard/disputes/stopListDataStepDS.jspx";
    private static final String ENTITY_TYPE = "ENTITY_TYPE";
    private static final String OBJECT_ID = "OBJECT_ID";
    private static final String STOP_LIST_TYPE = "STOP_LIST_TYPE";
    private static final String CARD_MASK = "CARD_MASK";
    private static final String CARD_NUMBER = "CARD_NUMBER";
    private static final String STOP_LIST_EVENT_TYPE = "STOP_LIST_EVENT_TYPE";
    private static final String ADD_EVENT = "EVNT2001";
    private static final String UPDATE_EVENT = "EVNT2002";
    private static final String DELETE_EVENT = "EVNT2003";

    private Map<String, Object> context;
    private long userSessionId;
    private String curLang;
    private String entityType;
    private Long disputeId;
    private String stopListType;
    private StopListData data;
    private String eventType;
    private List<SelectItem> actionCodes;
    private List<SelectItem> eventTypes;
    private List<SelectItem> serviceRegions;
    private List<SelectItem> products;

    private DisputesDao disputesDao = new DisputesDao();

    @Override
    public void init(Map<String, Object> context) {
        logger.trace("MbStopListDataStepDS::init");
        userSessionId = SessionWrapper.getRequiredUserSessionId();
        curLang = SessionWrapper.getField("language");
        if (context.containsKey(ENTITY_TYPE)) {
            entityType = (String) context.get(ENTITY_TYPE);
        } else {
            throw new IllegalStateException(ENTITY_TYPE + " is not defined in wizard context");
        }
        if (context.containsKey(OBJECT_ID)){
            disputeId = (Long)context.get(OBJECT_ID);
            if (disputeId == null) {
                throw new IllegalStateException(OBJECT_ID + " is defined in wizard but NULL");
            }
        } else {
            throw new IllegalStateException(OBJECT_ID + " is not defined in wizard context");
        }
        if (context.containsKey(STOP_LIST_TYPE)){
            stopListType = (String)context.get(STOP_LIST_TYPE);
            if (stopListType == null || stopListType.isEmpty()) {
                throw new IllegalStateException(STOP_LIST_TYPE + " is defined in wizard but NULL");
            }
        } else {
            throw new IllegalStateException(STOP_LIST_TYPE + " is not defined in wizard context");
        }
        if (context.containsKey(STOP_LIST_EVENT_TYPE)){
            eventType = (String)context.get(STOP_LIST_EVENT_TYPE);
            if (eventType == null || eventType.isEmpty()) {
                throw new IllegalStateException(STOP_LIST_EVENT_TYPE + " is defined in wizard but NULL");
            }
        } else {
            throw new IllegalStateException(STOP_LIST_EVENT_TYPE + " is not defined in wizard context");
        }

        context.put(MbCommonWizard.PAGE, PAGE);
        context.put(MbCommonWizard.VALIDATED_STEP, Boolean.TRUE);
        this.context = context;
        initialize();
    }

    @Override
    public Map<String, Object> release(Direction direction) {
        logger.trace("MbStopListDataStepDS::release");
        if (direction == FORWARD) {
            data.setCardInstanceId(disputesDao.getCardInstanceIdByMask(userSessionId, data.getCardMask().trim().replaceAll("[*]", "%")));
            if (serviceRegions != null) {
                for (SelectItem region : serviceRegions) {
                    if (region.isDisabled()) {
                        if (data.getRegionList() == null || data.getRegionList().isEmpty()) {
                            data.setRegionList(region.getValue().toString());
                        } else {
                            data.setRegionList(data.getRegionList().concat("," + region.getValue().toString()));
                        }
                    }
                }
            }
            if (this.validate()) {
                Map<String, Object> params = new HashMap<String, Object>();
                params.put("cardInstanceId", data.getCardInstanceId());
                params.put("stopListType", stopListType);
                params.put("eventType", data.getEventType());
                params.put("reasonCode", data.getActionCode());
                params.put("purgeDate", data.getPurgeDate());
                params.put("regionList", data.getRegionList());
                params.put("product", data.getProduct());
                try {
                    disputesDao.putCardToStopList(userSessionId, params);
                } catch (Exception e) {
                    logger.error("Failed to put card to stop list", e);
                    FacesUtils.addMessageError(e);
                }
            } else {
                if (data.getRegionList() != null && data.getRegionList().isEmpty()) {
                    FacesUtils.addMessageError("No service region has been selected");
                } else if (!Boolean.TRUE.equals(data.getDoNotPurge()) &&
                           data.getPurgeDate() == null &&
                           data.getPurgeInDays() == null) {
                    FacesUtils.addMessageError("Purge date should be defined by period or by date");
                } else {
                    FacesUtils.addMessageError("Unexpected error in data");
                }
            }
        }
        return context;
    }

    @Override
    public boolean validate() {
        logger.trace("MbStopListDataStepDS::validate");
        if (data != null) {
            return data.validate();
        }
        return false;
    }

    private DictUtils getDict() {
        return (DictUtils)ManagedBeanWrapper.getManagedBean("DictUtils");
    }
    private void initialize() {
        data = new StopListData();
        data.setStopListType(stopListType);

        if (stopListType.equals(CaseManagementConstants.EXCEPTION_FILE)) {
            actionCodes = getDict().getLov(LovConstants.STOP_LIST_ACTION_CODES);
        } else if (stopListType.equals(CaseManagementConstants.CARD_RECOVERY_BULLETIN)) {
            actionCodes = getDict().getLov(LovConstants.STOP_LIST_ACTION_CODES);
            serviceRegions = getDict().getLov(LovConstants.STOP_LIST_VISA_REGIONS);
            data.setRegionList("");
        } else if (stopListType.equals(CaseManagementConstants.STANDIN_ACCOUNT_FILE)) {
            actionCodes = getDict().getLov(LovConstants.STOP_LIST_FILE_REASON_CODES);
        } else if (stopListType.equals(CaseManagementConstants.ELECTRONIC_WARNING_BULLETIN)) {
            actionCodes = getDict().getLov(LovConstants.STOP_LIST_BULLETIN_REASON_CODES);
            serviceRegions = getDict().getLov(LovConstants.STOP_LIST_MC_REGIONS);
            data.setRegionList("");
            products = getDict().getLov(LovConstants.MASTERCARD_PRODUCTS);
            data.setProduct("");
        }
        if (serviceRegions != null) {
            for (SelectItem region : serviceRegions) {
                String[] label = region.getLabel().split("-");
                String regionValue = region.getValue().toString().trim();
                if (label.length > 1) {
                    region.setLabel(regionValue.substring(regionValue.length() - 1) + " - " + label[1].trim());
                }
            }
        }
        if (context.containsKey(CARD_MASK)) {
            data.setCardMask((String) context.get(CARD_MASK));
        }
        if (context.containsKey(CARD_NUMBER)) {
            data.setCardNumber((String) context.get(CARD_NUMBER));
        }
        data.setEventType(eventType);
        if(eventType.equals(UPDATE_EVENT) || eventType.equals(DELETE_EVENT)) {
            fillStopListData();
        }
    }

    public void setupPurgeDateByDays() {
        if (data.getPurgeInDays() != null) {
            if (data.getPurgeDate() == null) {
                data.setPurgeDate(new Date());
            }
            data.setPurgeDate(DateUtils.addDays(data.getPurgeDate(), data.getPurgeInDays()));
        }
    }
    public void setupPurgeDateByDate() {
        if (data.getPurgeDate() != null) {
            Long purgeDate = DateUtils.getFragmentInDays(data.getPurgeDate(), Calendar.YEAR);
            Long actualDate = DateUtils.getFragmentInDays(new Date(), Calendar.YEAR);
            if (purgeDate > actualDate) {
                data.setPurgeInDays(((Long)(purgeDate - actualDate)).intValue());
            } else {
                data.setPurgeInDays(0);
            }
        }
    }
    public void setupPurgeDateByClean() {
        if(data.getDoNotPurge()) {
            data.setPurgeDate(null);
            data.setPurgeInDays(null);
        }
    }
    public boolean showRegions() {
        if (stopListType.equals(CaseManagementConstants.EXCEPTION_FILE) ||
            stopListType.equals(CaseManagementConstants.STANDIN_ACCOUNT_FILE)) {
            return false;
        }
        return true;
    }
    public boolean showActionLabel() {
        if (stopListType.equals(CaseManagementConstants.ELECTRONIC_WARNING_BULLETIN) ||
            stopListType.equals(CaseManagementConstants.STANDIN_ACCOUNT_FILE)) {
            return false;
        }
        return true;
    }

    public boolean showProducts() {
        if (stopListType.equals(CaseManagementConstants.ELECTRONIC_WARNING_BULLETIN)) {
            return true;
        }
        return false;
    }

    public boolean disableInput() {
        return eventType.equals(DELETE_EVENT);
    }

    private void fillStopListData() {
        Long cardInstainceId = disputesDao.getCardInstanceIdByMask(userSessionId, Filter.mask(data.getCardMask()));
        StopList stopList = disputesDao.getStopListData(userSessionId, cardInstainceId);
        data.setCardInstanceId(cardInstainceId);
        data.setPurgeDate(stopList.getPurgeDate());
        if (stopList.getPurgeDate() == null) {
            data.setDoNotPurge(true);
        } else {
            data.setPurgeDate(stopList.getPurgeDate());
        }
        data.setStopListType(stopList.getStopListType());
        data.setActionCode(stopList.getReasonCode());
        data.setProduct(stopList.getProduct());
        prepareReqionListForGui(stopList.getRegionList());
    }

    private void prepareReqionListForGui(String regionList) {
        String [] regions = regionList.split(",");
        for (int i = 0; i < regions.length; ++i) {
            for(SelectItem item: serviceRegions) {
                if (item.getValue().equals(regions[i])) {
                    item.setDisabled(true);
                }
            }
        }
    }

    public StopListData getData() {
        return data;
    }
    public void setData(StopListData data) {
        this.data = data;
    }

    public List<SelectItem> getActionCodes() {
        return actionCodes;
    }
    public void setActionCodes(List<SelectItem> actionCodes) {
        this.actionCodes = actionCodes;
    }

    public List<SelectItem> getEventTypes() {
        return eventTypes;
    }
    public void setEventTypes(List<SelectItem> eventTypes) {
        this.eventTypes = eventTypes;
    }

    public List<SelectItem> getServiceRegions() {
        return serviceRegions;
    }
    public void setServiceRegions(List<SelectItem> serviceRegions) {
        this.serviceRegions = serviceRegions;
    }

    public List<SelectItem> getProducts() {
        return products;
    }

    public void setProducts(List<SelectItem> products) {
        this.products = products;
    }

}
