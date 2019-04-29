package ru.bpc.sv2.ui.common.wizard.dispute;

import org.apache.log4j.Logger;
import ru.bpc.sv2.common.CommonWizardStepInfo;
import ru.bpc.sv2.constants.SystemConstants;
import ru.bpc.sv2.ui.common.application.MbWizard;
import ru.bpc.sv2.ui.common.wizard.CommonWizardStep;
import ru.bpc.sv2.ui.utils.FacesUtils;
import util.auxil.ManagedBeanWrapper;

import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@ViewScoped
@ManagedBean (name = "MbStopListWizard")
public class MbStopListWizard {
    private static final Logger logger = Logger.getLogger(MbStopListWizard.class);

    public static final String STEPS = "STEPS";
    public static final String PAGE = "PAGE";
    public static final String DISABLE_BACK = "DISABLE_BACK";
    public static final String VALIDATED_STEP = "VALIDATED_STEP";
    public static final String STEPS_CHANGED = "STEPS_CHANGED";
    public static final String FORCE_NEXT = "FORCE_NEXT";
    public static final String OPER_TYPE = "OPER_TYPE";

    private String stepPage = SystemConstants.EMPTY_PAGE;

    private boolean displayNext = true;
    private boolean displayBack = true;
    private boolean disableBack = false;
    private int currentPosition;

    private Map<String, Object> context;
    private List<CommonWizardStepInfo> steps;
    private List<MbWizard.NavigatorItem> navigatorItems;
    private CommonWizardStepInfo currentStepInfo;
    private boolean validatedStep;

    public void init(Map<String, Object> context){
        logger.trace("MbStopListWizard::init...");
        reset();
        this.context = context;
        steps = readSteps(context);
        try{
            if (steps == null || steps.size() == 0){
                throw new IllegalStateException("Steps for the wizard are not defined: STEPS list is empty!");
            }
            prepareNavigatorItems();
            move();
        }catch(Exception e){
            FacesUtils.addMessageError(e);
        }
    }

    private void reset(){
        logger.trace("MbStopListWizard::reset...");
        currentPosition = 0;
        currentStepInfo = null;
        navigatorItems = null;
    }

    private void prepareNavigatorItems(){
        logger.trace("MbStopListWizard::prepareNavigatorItems...");
        navigatorItems = new ArrayList<MbWizard.NavigatorItem>();
        for (CommonWizardStepInfo step : steps){
            MbWizard.NavigatorItem navigatorItem = new MbWizard.NavigatorItem();
            navigatorItem.setLabel(step.getName());
            navigatorItem.setStepBeanName(step.getSource());
            getNavigatorItems().add(navigatorItem);
        }
    }

    private List<CommonWizardStepInfo> readSteps(Map<String, Object> context){
        logger.trace("MbStopListWizard::readSteps...");
        List<CommonWizardStepInfo> result;
        if (!context.containsKey(STEPS)){
            throw new IllegalStateException("Wizard context must contain wizard's steps");
        }
        result = (List<CommonWizardStepInfo>) context.get(STEPS);
        return result;
    }

    private String readPage(Map<String, Object> context){
        logger.trace("MbStopListWizard::readPage...");
        String result = null;
        if (!context.containsKey(PAGE)){
            throw new IllegalStateException("Wizard context must contain actual page name");
        }
        result = (String) context.get(PAGE);
        return result;
    }

    private void updateNavigatorSteps(){
        logger.trace("MbStopListWizard::updateNavigatorSteps...");
        if (navigatorItems == null) return;
        String stepSource = currentStepInfo.getSource();
        for (MbWizard.NavigatorItem navigatorItem : navigatorItems){
            if (stepSource.equals(navigatorItem.getStepBeanName())){
                navigatorItem.setSelected(true);
            } else {
                navigatorItem.setSelected(false);
            }
        }
    }

    public void move(){
        logger.trace("MbStopListWizard::move...");
        displayBack = currentPosition != 0;
        displayNext = currentPosition != (steps.size() - 1);
        currentStepInfo = steps.get(currentPosition);
        updateNavigatorSteps();
        initCurrentStep();
    }

    public void next(){
        logger.trace("MbStopListWizard::next...");
        Map<String, Object> backupcontext = backUpContext();
        if (validatedStep){
            if (!validate()) return;
        }
        try{
            releaseCurrentStep(CommonWizardStep.Direction.FORWARD);
            storeCurrentStepState();
            if (steps == null || steps.isEmpty())
                return;
            currentPosition++;
            move();
        }catch(Exception e){
            init(backupcontext);
            FacesUtils.addMessageError(e);
        }
    }

    private Map<String, Object> backUpContext(){
        Map<String, Object> backupContext = (Map<String, Object>) ((HashMap) this.context).clone();
        backupContext.put(MbStopListWizard.STEPS,((ArrayList)context.get(MbStopListWizard.STEPS)).clone());
        return backupContext;
    }

    public void back() {
        logger.trace("MbStopListWizard::back...");
        releaseCurrentStep(CommonWizardStep.Direction.BACK);
        currentPosition--;
        move();
    }

    public void finish(){
        logger.trace("MbStopListWizard::finish...");
        releaseCurrentStep(CommonWizardStep.Direction.FORWARD);
    }

    private boolean validate(){
        logger.trace("MbStopListWizard::validate...");
        String stepSource = currentStepInfo.getSource();
        CommonWizardStep step = (CommonWizardStep) ManagedBeanWrapper.getManagedBean(stepSource);
        boolean result = step.validate();
        return result;
    }

    public void releaseCurrentStep(CommonWizardStep.Direction direction){
        logger.trace("MbStopListWizard::releaseCurrentStep...");
        String stepSource = currentStepInfo.getSource();
        CommonWizardStep step = (CommonWizardStep) ManagedBeanWrapper.getManagedBean(stepSource);
        context = step.release(direction);
        if (context == null){
            throw new IllegalStateException("Wizard context is null. You probably forgot to define 'keepAlive' tag for your step bean");
        }
        if (context.containsKey(STEPS_CHANGED)){
            prepareNavigatorItems();
        }
        context.remove(STEPS_CHANGED);
        context.remove(VALIDATED_STEP);
    }

    private void storeCurrentStepState(){
        logger.trace("MbStopListWizard::releaseCurrentStep...");

    }

    private void initCurrentStep(){
        logger.trace("MbStopListWizard::initCurrentStep...");
        String stepSource = currentStepInfo.getSource();
        CommonWizardStep step = (CommonWizardStep) ManagedBeanWrapper.getManagedBean(stepSource);
        if (step == null){
            throw new IllegalStateException(String.format("Step not found: \'%s\'. You probably forgot to define it in faces-config.xml", stepSource));
        }
        step.init(context);
        stepPage = readPage(context);
        if (stepPage == null || stepPage.isEmpty()){
            throw new IllegalStateException(String.format("Step \'%s\' has not set \'stepPage\' field of the wizard context", stepSource));
        }
        logger.debug("Actual step's page: " + stepPage);
        if (context.containsKey(DISABLE_BACK)){
            setDisableBack((Boolean) context.get(DISABLE_BACK));
            context.remove(DISABLE_BACK);
        } else {
            disableBack = false;
        }
        if (context.containsKey(VALIDATED_STEP)){
            validatedStep = (Boolean) context.get(VALIDATED_STEP);
            context.remove(VALIDATED_STEP);
        } else {
            validatedStep = false;
        }
        if (context.containsKey(FORCE_NEXT)){
            displayNext = true;
            context.remove(FORCE_NEXT);
        }
    }

    public boolean isDisplayNext() {
        return displayNext;
    }
    public void setDisplayNext(boolean displayNext) {
        this.displayNext = displayNext;
    }

    public boolean isDisplayBack() {
        return displayBack;
    }
    public void setDisplayBack(boolean displayBack) {
        this.displayBack = displayBack;
    }

    public String getStepPage() {
        return stepPage;
    }
    public void setStepPage(String stepPage) {
        this.stepPage = stepPage;
    }

    public boolean isDisableBack() {
        return disableBack;
    }
    public void setDisableBack(boolean disableBack) {
        this.disableBack = disableBack;
    }

    public List<MbWizard.NavigatorItem> getNavigatorItems() {
        return navigatorItems;
    }

    public CommonWizardStep getCurrentStepInfo(){
        return (CommonWizardStep) ManagedBeanWrapper.getManagedBean(currentStepInfo.getSource());
    }
}
