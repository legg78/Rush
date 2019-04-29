package ru.bpc.sv2.ui.common.wizard.dispute;

import org.apache.log4j.Logger;
import ru.bpc.sv2.common.CommonWizardStepInfo;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.invocation.SortElement;
import ru.bpc.sv2.logic.CommonDao;
import ru.bpc.sv2.logic.DisputesDao;
import ru.bpc.sv2.ui.common.wizard.CommonWizardStep;
import ru.bpc.sv2.ui.common.wizard.MbCommonWizard;
import ru.bpc.sv2.ui.common.wizard.callcenter.MbOperTypeSelectionStep;
import ru.bpc.sv2.ui.utils.DictUtils;
import util.auxil.ManagedBeanWrapper;
import util.auxil.SessionWrapper;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.model.SelectItem;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.Map;

@ViewScoped
@ManagedBean (name = "MbStopListTypeSelectionStep")
public class MbStopListTypeSelectionStep implements CommonWizardStep {
    private static final Logger logger = Logger.getLogger(MbOperTypeSelectionStep.class);
    private static final String PAGE = "/pages/common/wizard/disputes/stopListTypeSelectionStep.jspx";
    private static final String ENTITY_TYPE = "ENTITY_TYPE";
    private static final String OBJECT_ID = "OBJECT_ID";
    private static final String CARD_MASK = "CARD_MASK";
    private static final String CARD_NUMBER = "CARD_NUMBER";
    private static final String STOP_LIST_TYPE = "STOP_LIST_TYPE";
    private static final Long WIZARD_ID = 1040L;

    private List<SelectItem> stopListTypes;
    private Map<String, Object> context;
    private long userSessionId;
    private String curLang;
    private String entityType;
    private Long disputeId;
    private String stopListType;

    private DisputesDao disputesDao = new DisputesDao();
    private CommonDao commonDao = new CommonDao();

    @Override
    public void init(Map<String, Object> context) {
        logger.trace("MbStopListTypeSelectionStep::init");
        resetSteps(context);
        userSessionId = SessionWrapper.getRequiredUserSessionId();
        curLang = SessionWrapper.getField("language");
        if (context.containsKey(ENTITY_TYPE)) {
            entityType = (String) context.get(ENTITY_TYPE);
        } else {
            //throw new IllegalStateException(ENTITY_TYPE + " is not defined in wizard context");
        }
        if (context.containsKey(STOP_LIST_TYPE)) {
            stopListType = (String) context.get(STOP_LIST_TYPE);
        } else {
            stopListType = null;
        }
        if (context.containsKey(OBJECT_ID)){
            disputeId = (Long)context.get(OBJECT_ID);
            if (disputeId == null) {
                //throw new IllegalStateException(OBJECT_ID + " is defined in wizard but NULL");
            }
        } else {
            //throw new IllegalStateException(OBJECT_ID + " is not defined in wizard context");
        }
        updateStopListTypes();
        context.put(MbCommonWizard.PAGE, PAGE);
        context.put(MbCommonWizard.DISABLE_BACK, Boolean.TRUE);
        context.put(MbCommonWizard.VALIDATED_STEP, Boolean.TRUE);
        context.put(MbCommonWizard.FORCE_NEXT, Boolean.TRUE);
        this.context = context;
    }

    @Override
    public Map<String, Object> release(Direction direction) {
        logger.trace("MbStopListTypeSelectionStep::release");
        List<CommonWizardStepInfo> newSteps = prepareSteps(WIZARD_ID);
        if (newSteps.size() > 1) {
            ((List<CommonWizardStepInfo>) context.get(MbCommonWizard.STEPS)).clear();
            ((List<CommonWizardStepInfo>) context.get(MbCommonWizard.STEPS)).addAll(newSteps);
            context.put(MbCommonWizard.STEPS_CHANGED, Boolean.TRUE);
            context.remove(PAGE);
        }
        context.put(STOP_LIST_TYPE, stopListType);
        return context;
    }

    @Override
    public boolean validate() {
        logger.trace("MbStopListTypeSelectionStep::validate");
        if (stopListType != null && !stopListType.isEmpty()) {
            return true;
        }
        return false;
    }

    private List<CommonWizardStepInfo> prepareSteps(Long wizardId){
        logger.trace("MbStopListTypeSelectionStep::prepareSteps");
        Filter[] filters = new Filter[]{new Filter("wizardId", wizardId), new Filter("lang", curLang)};
        SelectionParams params = new SelectionParams();
        params.setFilters(filters);
        params.setSortElement(new SortElement("stepOrder", SortElement.Direction.ASC));
        params.setRowIndexEnd(999);
        return Arrays.asList(commonDao.getWizardSteps(userSessionId, params));
    }
    private void resetSteps(Map<String, Object> context){
        logger.trace("MbStopListTypeSelectionStep::resetSteps");
        ArrayList<CommonWizardStepInfo> steps = ((ArrayList<CommonWizardStepInfo>)context.get(MbCommonWizard.STEPS));
        CommonWizardStepInfo step = steps.get(0);
        steps.clear();
        steps.add(step);
    }
    private void updateStopListTypes(){
        logger.trace("MbStopListTypeSelectionStep::updateStopListTypes");
        stopListTypes = new ArrayList<SelectItem>();
        Integer lovId = disputesDao.getStopListTypeLovId(userSessionId, disputeId);
        if (lovId != null) {
            stopListTypes = ((DictUtils)ManagedBeanWrapper.getManagedBean("DictUtils")).getLov(lovId);
        }
    }

    public List<SelectItem> getStopListTypes() {
        return stopListTypes;
    }
    public void setStopListTypes(List<SelectItem> stopListTypes) {
        this.stopListTypes = stopListTypes;
    }

    public String getStopListType() {
        return stopListType;
    }
    public void setStopListType(String stopListType) {
        this.stopListType = stopListType;
    }
}
