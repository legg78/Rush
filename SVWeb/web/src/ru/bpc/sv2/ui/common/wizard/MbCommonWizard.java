package ru.bpc.sv2.ui.common.wizard;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.apache.log4j.Logger;

import ru.bpc.sv2.common.CommonWizardStepInfo;
import ru.bpc.sv2.constants.SystemConstants;
import ru.bpc.sv2.ui.common.application.MbWizard.NavigatorItem;
import ru.bpc.sv2.ui.common.wizard.CommonWizardStep.Direction;
import ru.bpc.sv2.ui.utils.FacesUtils;
import util.auxil.ManagedBeanWrapper;

import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.context.FacesContext;

@ViewScoped
@ManagedBean (name = "MbCommonWizard")
public class MbCommonWizard {
	private static final Logger logger = Logger.getLogger(MbCommonWizard.class);
	private static final int PADDING_FOR_VALUE = 20;
	private static final int PADDING_FOR_EMPTY = 50;

	public static final String STEPS = "STEPS";
	public static final String PAGE = "PAGE";
	public static final String DISABLE_BACK = "DISABLE_BACK";
	public static final String VALIDATED_STEP = "VALIDATED_STEP";
	public static final String STEPS_CHANGED = "STEPS_CHANGED";
	public static final String FORCE_NEXT = "FORCE_NEXT";
	public static final String OPER_TYPE = "OPER_TYPE";
	public static final String ENTITY_TYPE = "ENTITY_TYPE";
	public static final String OBJECT = "OBJECT";
	public static final String OBJECT_ID = "OBJECT_ID";
	public static final String SHOW_DIALOG = "SHOW_DIALOG";

	private String stepPage = SystemConstants.EMPTY_PAGE;

	private boolean displayNext = true;
	private boolean displayBack = true;
	private boolean disableBack = false;
	private int currentPosition;

	private Map<String, Object> context;
	private List<CommonWizardStepInfo> steps;
	private List<NavigatorItem> navigatorItems;
	private CommonWizardStepInfo currentStepInfo;
	private boolean validatedStep;
	private boolean showDialog = false;

	public boolean isShowDialog() {
		logger.trace("MbCommonWizard::isShowDialog...");
		return showDialog;
	}

	public void init(Map<String, Object> context){
		logger.trace("MbCommonWizard::init...");
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
			logger.error(e.getMessage(), e);
			FacesUtils.addMessageError(e);
		}
	}

	private void reset(){
		logger.trace("MbCommonWizard::reset...");
		currentPosition = 0;
		currentStepInfo = null;
		navigatorItems = null;
	}

	private void prepareNavigatorItems(){
		logger.trace("MbCommonWizard::prepareNavigatorItems...");
		navigatorItems = new ArrayList<NavigatorItem>();
		for (CommonWizardStepInfo step : steps) {
			NavigatorItem navigatorItem = new NavigatorItem();
			navigatorItem.setLabel(step.getName());
			navigatorItem.setStepBeanName(step.getSource());
			getNavigatorItems().add(navigatorItem);
		}
	}

	private List<CommonWizardStepInfo> readSteps(Map<String, Object> context){
		logger.trace("MbCommonWizard::readSteps...");
		List<CommonWizardStepInfo> result;
		if (!context.containsKey(STEPS)) {
			throw new IllegalStateException("Wizard context must contain wizard's steps");
		}
		//noinspection unchecked
		result = (List<CommonWizardStepInfo>) context.get(STEPS);
		return result;
	}

	private String readPage(Map<String, Object> context){
		logger.trace("MbCommonWizard::readPage...");
		String result = null;
		if (!context.containsKey(PAGE)) {
			throw new IllegalStateException("Wizard context must contain actual page name");
		}
		result = (String) context.get(PAGE);
		return result;
	}

	private void updateNavigatorSteps(){
		logger.trace("MbCommonWizard::updateNavigatorSteps...");
		if (navigatorItems == null) {
			return;
		}
		String stepSource = currentStepInfo.getSource();
		for (NavigatorItem navigatorItem : navigatorItems) {
			if (stepSource.equals(navigatorItem.getStepBeanName())) {
				navigatorItem.setSelected(true);
			} else { 
				navigatorItem.setSelected(false);
			}
		}
	}

	public void move(){
		logger.trace("MbCommonWizard::move...");
		displayBack = currentPosition != 0;
		displayNext = currentPosition != (steps.size() - 1);
		currentStepInfo = steps.get(currentPosition);
		/*currentstepSource = currentStepInfo.getSource();*/
		updateNavigatorSteps();
		initCurrentStep();
	}

	public void next(){
		logger.trace("MbCommonWizard::next...");
		Map<String, Object> backupcontext = backUpContext();
		try {
			if (validatedStep)
				if (!validate())
					return;
			try{
				releaseCurrentStep(Direction.FORWARD);
				storeCurrentStepState();
				if (steps == null || steps.isEmpty())
					return;
				currentPosition++;
				move();
			}catch(Exception e){
				logger.error(e.getMessage(), e);
				init(backupcontext);
				FacesUtils.addMessageError(e);
			}
		}catch(Exception e){
			logger.error(e.getMessage(), e);
			FacesUtils.addMessageError(e);
		}
	}

	private Map<String, Object> backUpContext(){
		//noinspection unchecked
		Map<String, Object> backupContext = (Map<String, Object>) ((HashMap) this.context).clone();
		backupContext.put(MbCommonWizard.STEPS,((ArrayList)context.get(MbCommonWizard.STEPS)).clone());
		return backupContext;
	}

	public void back() {
		logger.trace("MbCommonWizard::back...");
		releaseCurrentStep(Direction.BACK);
		currentPosition--;
		move();
	}

	public void finish(){
		logger.trace("MbCommonWizard::finish...");
		releaseCurrentStep(Direction.FORWARD);
	}

	private boolean validate(){
		logger.trace("MbCommonWizard::validate...");
		return getCurrentStepInfo().validate();
	}

	public void releaseCurrentStep(Direction direction){
		logger.trace("MbCommonWizard::releaseCurrentStep...");
		context = getCurrentStepInfo().release(direction);
		if (context == null){
			throw new IllegalStateException("Wizard context is null. You probably forgot to define 'keepAlive' tag for your step bean");
		}
		if (context.containsKey(STEPS_CHANGED)){
			prepareNavigatorItems();
		}
		context.remove(STEPS_CHANGED);
		context.remove(VALIDATED_STEP);
		context.remove(SHOW_DIALOG);
	}

	private void storeCurrentStepState(){
		logger.trace("MbCommonWizard::releaseCurrentStep...");
		
	}

	private void initCurrentStep(){
		logger.trace("MbCommonWizard::initCurrentStep...");
		String stepSource = currentStepInfo.getSource();
		CommonWizardStep step = getCurrentStepInfo();
		FacesContext.getCurrentInstance().getViewRoot().getViewMap().put("stepBean", step);
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
		if (context.containsKey(SHOW_DIALOG)){
			showDialog = (Boolean) context.get(SHOW_DIALOG);
			context.remove(SHOW_DIALOG);
		} else {
			showDialog = false;
		}
		if (context.containsKey(FORCE_NEXT)){
			displayNext = true;
			context.remove(FORCE_NEXT);
		}
	}

	public String getStepBeanName() {
		if (currentStepInfo == null) {
			return null;
		}
		return currentStepInfo.getSource();
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

	public List<NavigatorItem> getNavigatorItems() {
		return navigatorItems;
	}
	public CommonWizardStep getCurrentStepInfo(){
		return (CommonWizardStep) ManagedBeanWrapper.getManagedBean(currentStepInfo.getSource());
	}

	public String getWizardId() {
		if (currentStepInfo != null && currentStepInfo.getWizardId() != null) {
			return currentStepInfo.getWizardId().toString().trim();
		}
		return null;
	}
	public int getWizardIdPadding() {
		return (getWizardId().trim().length() > 0) ? PADDING_FOR_VALUE : PADDING_FOR_EMPTY;
	}

	public void setMaker(boolean value) {
        CommonWizardStep commonWizard = getCurrentStepInfo();
        if (!(commonWizard instanceof AbstractWizardStep)) return;

        AbstractWizardStep wizard = (AbstractWizardStep) commonWizard;
	    if (value) {
	        wizard.setMakerChecker(AbstractWizardStep.Mode.MAKER);
        } else {
            wizard.setMakerChecker(AbstractWizardStep.Mode.CHECKER);
        }
    }

    public boolean isMakerChecker() {
	    if (currentStepInfo == null) return false;

        CommonWizardStep commonWizard = getCurrentStepInfo();
        if (!(commonWizard instanceof AbstractWizardStep)) return false;

        AbstractWizardStep wizard = (AbstractWizardStep) commonWizard;
        return wizard.isMakerChecker();
    }

    public String getMakerCheckerButtonLabel() {
		if (currentStepInfo == null) return "";
		CommonWizardStep commonWizard = getCurrentStepInfo();
		if (!(commonWizard instanceof AbstractWizardStep)) return "";

		AbstractWizardStep wizard = (AbstractWizardStep) commonWizard;
		return wizard.getMakerCheckerButtonLabel();
	}
}
