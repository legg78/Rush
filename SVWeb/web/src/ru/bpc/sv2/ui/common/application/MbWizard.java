package ru.bpc.sv2.ui.common.application;

import org.apache.commons.lang3.StringUtils;
import org.apache.log4j.Logger;
import ru.bpc.sv2.application.Application;
import ru.bpc.sv2.application.ApplicationElement;
import ru.bpc.sv2.application.ApplicationFlowFilter;
import ru.bpc.sv2.application.ApplicationFlowTransition;
import ru.bpc.sv2.common.application.AppFlowStep;
import ru.bpc.sv2.common.application.ApplicationStatuses;
import ru.bpc.sv2.constants.SystemConstants;
import ru.bpc.sv2.constants.application.AppElements;
import ru.bpc.sv2.constants.application.ApplicationConstants;
import ru.bpc.sv2.logic.ApplicationDao;
import ru.bpc.sv2.ui.navigation.Menu;
import ru.bpc.sv2.ui.utils.DictUtils;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.utils.UserException;
import util.auxil.ManagedBeanWrapper;
import util.auxil.SessionWrapper;


import ru.bpc.sv2.logic.utility.db.DataAccessException;
import javax.faces.bean.ManagedBean;
import javax.faces.bean.SessionScoped;
import javax.faces.model.SelectItem;
import java.io.Serializable;
import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import static ru.bpc.sv2.utils.AppStructureUtils.*;

@SessionScoped
@ManagedBean (name = "MbWizard")
public class MbWizard implements Serializable {
	
	private static final long serialVersionUID = 1L;
	public static final String ACQUIRING = "acquiring";
	public static final String ISSUING = "issuing";
	public static final String PAYMENT_ORDERS = "pmo";
	protected static final Logger logger = Logger.getLogger("APPLICATIONS");

	private String stepPage = SystemConstants.EMPTY_PAGE;
	private boolean displayNext;
	private boolean displayBack;
	protected ApplicationElement applicationRoot;
	private Map<Integer, ApplicationFlowFilter> applicationFilters;
	private List<AppFlowStep>passedSteps;
	private List<AppFlowStep> steps;
	private String currentStepBeanName;
	private int currentPosition = 0;
	private AppWizStep currentStepBean;
	protected long userSessionId;
	private ApplicationWizardContext previousStepState = null;
	private boolean valid;
	private String appStatus = ApplicationStatuses.JUST_CREATED;
	private String appRejectCode = null;
	private String appStatusDescription;
	private DictUtils dictUtils;
	private AppFlowStep currentStep;
	protected ApplicationWizardContext context;
	private Application activeApp = null;
	private boolean keepState;
	private boolean searching;
	private Application filter;
	private int pageNumber;
	private int rowsNum;
	private int mod;
	protected String backLink;
	private String appType;
	private Long applicationId;
	private Map <ApplicationElement, List<ApplicationElement>> linkedMap;
	
	private ApplicationDao daoApplication = new ApplicationDao();

	public MbWizard() {
		userSessionId = SessionWrapper.getRequiredUserSessionId();
		dictUtils = ManagedBeanWrapper.getManagedBean(DictUtils.class);
		linkedMap = new HashMap<ApplicationElement, List<ApplicationElement>>();
		passedSteps = new ArrayList<AppFlowStep>();
	}

	private ApplicationWizardContext cloneCurrentStepState() {
		logger.trace("MbWizard::storeStepData...");
		// Filters
		Map<Integer, ApplicationFlowFilter> applicationFiltersCopy = new HashMap<Integer, ApplicationFlowFilter>();
		for (Integer key : applicationFilters.keySet()) {
			ApplicationFlowFilter filter = applicationFilters.get(key);
			try {
				ApplicationFlowFilter filterCopy = (ApplicationFlowFilter) filter
						.clone();
				applicationFiltersCopy.put(key, filterCopy);
			} catch (CloneNotSupportedException e) {
				e.printStackTrace();
			}
		}

		// Application
		ApplicationElement applicationRootCopy = null;
		try {
			applicationRootCopy = applicationRoot.clone();
		} catch (CloneNotSupportedException e) {
			e.printStackTrace();
		}

		// Steps
		List<AppFlowStep> stepsCopy = new ArrayList<AppFlowStep>();
		for (AppFlowStep step : steps) {
			AppFlowStep stepCopy = (AppFlowStep) step.clone();
			stepsCopy.add(stepCopy);
		}

		ApplicationWizardContext ctx = new ApplicationWizardContext();
		ctx.setApplicationFilters(applicationFiltersCopy);
		ctx.setApplicationRoot(applicationRootCopy);
		ctx.setSteps(stepsCopy);

		return ctx;
	}

	private void initCurrentStep() {
		logger.trace("MbWizard::initCurrentStep...");
		ApplicationWizardContext ctx = context.silentClone();
		ctx.setApplicationFilters(applicationFilters);
		ctx.setApplicationRoot(applicationRoot);
		ctx.setLinkedMap(linkedMap);
		ctx.setSteps(steps);
		ctx.setApplicationType(applicationRoot.getAppType());
		currentStepBean = (AppWizStep) ManagedBeanWrapper
				.getManagedBean(currentStepBeanName);
		currentStepBean.init(ctx);
		stepPage = ctx.getStepPage();
		
		if (stepPage == null || stepPage.isEmpty()){
			throw new IllegalStateException(String.format("Step \'%s\' has not set \'stepPage\' field of the wizard context", currentStepBeanName));
		}
	}

	protected void releaseCurrentStep() {
		logger.trace("MbWizard::releaseCurrentStep...");
		currentStepBean = (AppWizStep) ManagedBeanWrapper.getManagedBean(currentStepBeanName);
		ApplicationWizardContext ctx = currentStepBean.release();
		applicationRoot = ctx.getApplicationRoot();
		applicationFilters = ctx.getApplicationFilters();
		linkedMap = ctx.getLinkedMap();
		context = ctx.silentClone();
		List<AppFlowStep> newSteps = ctx.getSteps();
		if (stepsChanged(newSteps)){
			steps = newSteps;
			prepareNavigatorItems();
		}
	}

	private void storeCurrentStepState() {
		logger.trace("MbWizard::storePreviousStepState...");
		ApplicationWizardContext ctx = cloneCurrentStepState();
		previousStepState = ctx;
	}

	@Deprecated
	public ApplicationElement addElement(ApplicationElement parent,
			ApplicationElement element) throws UserException {
		logger.trace("MbWizard::addElement...");
		Integer instId = retrive(applicationRoot, AppElements.INSTITUTION_ID).getValueN()
				.intValue();
		Application appStub = new Application();
		appStub.setInstId(instId);
		daoApplication.fillRootChilds(userSessionId, instId, element, applicationFilters);
		daoApplication.applyDependencesWhenAdd(userSessionId, appStub, element,
				applicationFilters);
		return element;
	}

	@Deprecated
	public ApplicationElement addElement(ApplicationElement parent,
			String elementName) throws UserException {
		logger.trace("MbWizard::addElement...");
		ApplicationElement element = null;
		try {
			element = instance(parent, elementName);
		} catch (IllegalArgumentException e) {
			throw new UserException(e);
		}
		Integer instId = retrive(applicationRoot, AppElements.INSTITUTION_ID).getValueN()
				.intValue();
		Application appStub = new Application();
		appStub.setInstId(instId);
		daoApplication.fillRootChilds(userSessionId, instId, element, applicationFilters);
		daoApplication.applyDependencesWhenAdd(userSessionId, appStub, element,
				applicationFilters);
		return element;
	}

	public String finish() {
		logger.trace("MbWizard::finish...");
		releaseCurrentStep();
		boolean saved = saveApplication();
		if (saved){
			FacesUtils.setSessionMapValue("APP_TYPE", appType);
			Menu menu = (Menu) ManagedBeanWrapper.getManagedBean("menu");
			menu.setKeepState(true);
			setKeepState(true);
			if (backLink != null){
				return backLink;
			}else{
				return "blankPage";
			}
		} else {
			return "";
		}
	}

	private boolean saveApplication() {
		logger.trace("MbWizard::saveApplication...");
		Application application = new Application();
		application.setFlowId(applicationRoot.getChildByName(AppElements.APPLICATION_FLOW_ID, 1).getValueN().intValue());
		application.setStatus(appStatus);
		application.setRejectCode(appRejectCode);
		application.setNewStatus(appStatus);
		application.setAppType(applicationRoot.getAppType());
		application.setInstId(applicationRoot.getChildByName(AppElements.INSTITUTION_ID, 1).getValueN().intValue());
		int productId = applicationRoot.getChildByName(AppElements.CUSTOMER, 1)
				.getChildByName(AppElements.CONTRACT, 1)
				.getChildByName(AppElements.PRODUCT_ID, 1)
				.getValueN().intValue();
		application.setProductId(productId);
		application.setComment(appStatusDescription);
		activeApp = application;
		
		boolean result = false;
		
		try {
			application = daoApplication.createApplication(userSessionId, application);
			ApplicationElement applicationRootTmp = daoApplication
					.getApplicationForEdit(userSessionId, application);
			applicationRoot.setDataId(applicationRootTmp.getDataId());
			applicationId = application.getId();
			insertDataId(applicationRoot, applicationRoot.getChildren().size());
			createLinks();
			daoApplication.saveApplication(userSessionId, applicationRoot, application, 1);
			releaseApplications();
			result = true;
		} catch (DataAccessException e){
			FacesUtils.addErrorExceptionMessage(e);
			logger.error(e);
		} catch (Exception e) {
			FacesUtils.addErrorExceptionMessage(e);
			logger.error(e);
		}
		
		return result;
	}
	
	protected void insertDataId(ApplicationElement appEl, int size) throws Exception {
		for (int i = 0; i < size; i++){
			appEl.getChildren().get(i).setDataId(getDataId());
			if (appEl.getChildren().get(i).isHasChildren()){
				ApplicationElement el = appEl.getChildren().get(i);
				insertDataId(el, el.getChildren().size());
			}
		}
		return;
	}
	
	protected void createLinks(){
		for (ApplicationElement key: linkedMap.keySet()){
			List<ApplicationElement> value = linkedMap.get(key);
			for (ApplicationElement el: value){
				if (el.getChildByName(AppElements.SERVICE_OBJECT,1 ) != null) {
					el.getChildByName(AppElements.SERVICE_OBJECT,1 ).setValueN(new BigDecimal(key.getDataId()));
				}
			}	
		}
		}
	
	private void resetCount() throws DataAccessException, Exception {
		step = ApplicationConstants.DATA_SEQUENCE_STEP;
		if (step == 0) {
			throw new Exception("Invalid data sequence step");
		}
		currVal = daoApplication.getNextDataId(userSessionId,
				applicationId);
		currVal = currVal - step;
		count = 0;
	}

	private long getDataId() throws Exception {
		if (count >= step) {
			// need more dataIds from sequence
			resetCount();
		}
		count++;
		return currVal + count;
	}

	private long currVal = 0;
	private int step = 0;
	private int count = 0;
	
	public void releaseApplications(){
		ApplicationElement app = previousStepState.getApplicationRoot();
		clearChildren(app);
		clearChildren(applicationRoot);
		init();
	}

	public Map<Integer, ApplicationFlowFilter> getApplicationFilters() {
		return applicationFilters;
	}

	public String getStepPage() {
		return stepPage;
	}

	public List<AppFlowStep> getSteps() {
		return steps;
	}
	
	private void init(){
		currVal = 0;
		step = 0;
		count = 0;
		previousStepState = null;
		passedSteps = new ArrayList<AppFlowStep>();
		navStepBeanName = null;
		linkedMap = new HashMap<ApplicationElement, List<ApplicationElement>>();
		currentStep = null;
		currentStepBean = null;
		currentPosition = 0;
	}

	public void init(ApplicationWizardContext ctx) {
		logger.trace("MbWizard::init...");
		if(backLink == null && ctx.get("backlink") != null){
			backLink = (String) ctx.get("backlink");
		}
		init();
		context = ctx.silentClone();
		steps = ctx.getSteps();
		applicationFilters = ctx.getApplicationFilters();
		applicationRoot = ctx.getApplicationRoot();
		storeCurrentStepState();
		move();
		prepareNavigatorItems();
	}

	public boolean isDisplayBack() {
		return displayBack;
	}

	public boolean isDisplayNext() {
		if(currentStepBean == null){
			return false;
		}
		return (displayNext & currentStepBean.getLock());
	}
	
	public boolean isdisplayFinish() {
		if(currentStepBean == null){
			return false;
		}
		return (currentStepBean.getLock() &&
				steps.indexOf(currentStep) == (steps.size() -1));
	}

	public void move() {
		logger.trace("MbWizard::move...");
		displayBack = currentPosition != 0;
		displayNext = currentPosition != (steps.size() - 1);
		currentStep = steps.get(currentPosition);
		currentStepBeanName = currentStep.getStepSource();
		if (!passedSteps.contains(steps.get(currentPosition))){
			passedSteps.add(steps.get(currentPosition));
		}
		updateNavigatorSteps();
		initCurrentStep();
	}

	public void next() {
		logger.trace("MbWizard::next...");
		if (isKeyStep()){
			if (!validate()) return;
		}
		releaseCurrentStep();
		storeCurrentStepState();
		if (steps == null || steps.isEmpty())
			return;
		currentPosition++;
		move();
	}

	public void back() {
		logger.trace("MbWizard::back...");
		if (isKeyStep()){
			if (!validate()) return;
		}
		releaseCurrentStep();
		currentPosition--;
		move();
	}
	
	public void jump(){
		logger.trace("MbWizard::jump...");
		// Find the position to move
		int newPosition = -1;
		for (int i = 0; i < steps.size(); i++){
			AppFlowStep step = steps.get(i);
			if (navStepBeanName.equals(step.getStepSource())){
				newPosition = i;
				break;
			}
		}
		if (newPosition < 0) return;
		if (isKeyStep()){
			if (!validate()) return;
		}		
		releaseCurrentStep();
		storeCurrentStepState();
		currentPosition = newPosition;
		move();
	}	
	
	private void restoreCurrentStepState(ApplicationWizardContext ctx) {
		logger.trace("MbWizard::restoreCurrentStepState...");
		// Filters
		Map<Integer, ApplicationFlowFilter> applicationFiltersCopy = ctx
				.getApplicationFilters();
		applicationFilters = new HashMap<Integer, ApplicationFlowFilter>();
		for (Integer key : applicationFiltersCopy.keySet()) {
			ApplicationFlowFilter filterCopy = applicationFiltersCopy.get(key);
			try {
				ApplicationFlowFilter filter = (ApplicationFlowFilter) filterCopy
						.clone();
				applicationFilters.put(key, filter);
			} catch (CloneNotSupportedException e) {
				e.printStackTrace();
			}
		}

		// Application
		clearChildren(applicationRoot);
		ApplicationElement applicationRootCopy = ctx.getApplicationRoot();
		try {
			applicationRoot = applicationRootCopy.clone();
		} catch (CloneNotSupportedException e) {
			e.printStackTrace();
		}

		// Steps
		List<AppFlowStep> stepsCopy = ctx.getSteps();
		steps = new ArrayList<AppFlowStep>();
		for (AppFlowStep stepCopy : stepsCopy) {
			AppFlowStep step = (AppFlowStep) stepCopy.clone();
			steps.add(step);
		}
	}

	public void setApplicationFilters(
			Map<Integer, ApplicationFlowFilter> applicationFilters) {
		this.applicationFilters = applicationFilters;
	}

	public void setDisplayBack(boolean displayBack) {
		this.displayBack = displayBack;
	}

	public void setDisplayNext(boolean displayNext) {
		this.displayNext = displayNext;
	}

	public void setStepPage(String stepPage) {
		this.stepPage = stepPage;
	}

	public void setSteps(List<AppFlowStep> steps) {
		this.steps = steps;
	}

	public boolean validate() {
		logger.trace("MbWizard::validate...");
		currentStepBean = (AppWizStep) ManagedBeanWrapper
				.getManagedBean(currentStepBeanName);
		boolean result = valid = currentStepBean.validate();
		return result;
	}
	
	public void validateForWeb(){
		logger.trace("MbWizard::validateForWeb...");
		currentStepBean = (AppWizStep) ManagedBeanWrapper
				.getManagedBean(currentStepBeanName);
		valid = currentStepBean.validate();
	}

	public void reset() {
		restoreCurrentStepState(previousStepState);
		initCurrentStep();
	}

	public boolean isValid() {
		return valid;
	}

	public void setValid(boolean valid) {
		this.valid = valid;
	}

	public String getAppStatus() {
		return appStatus;
	}

	public void setAppStatus(String appStatus) {
		this.appStatus = appStatus;
	}


	public String getAppRejectCode() {
		return appRejectCode;
	}

	public void setAppRejectCode(String appRejectCode) {
		this.appRejectCode = appRejectCode;
	}


	public String getAppStatusDescription() {
		return appStatusDescription;
	}

	public void setAppStatusDescription(String appStatusDescription) {
		this.appStatusDescription = appStatusDescription;
	}

	public String getAppStatusRejectCode() {
		String result = getAppStatus();
		if (StringUtils.isNotEmpty(result) && StringUtils.isNotEmpty(getAppRejectCode())) {
			result += getAppRejectCode();
		}
		return result;
	}

	public void setAppStatusRejectCode(String value) {
		if (StringUtils.isEmpty(value)) {
			setAppStatus(value);
			setAppRejectCode(value);
			return;
		}

		if (value.length() > 8) {
			setAppStatus(value.substring(0, 8));
			setAppRejectCode(value.substring(8));
		} else {
			setAppStatus(value);
			setAppRejectCode(null);
		}
	}


	private List<SelectItem> applicationStatuses; 
	
	public List<SelectItem> getApplicationStatuses() {
		if (applicationStatuses == null){
			applicationStatuses = new ArrayList<SelectItem>();
			Application filter = new Application();
			String currentStatus = applicationRoot.getChildByName(AppElements.APPLICATION_STATUS, 1).getValueV();

			String currentRejectCode = null;
			ApplicationElement rejectCode = applicationRoot.getChildByName(AppElements.APPLICATION_REJECT_CODE, 1);
			if (rejectCode != null) {
				currentRejectCode = rejectCode.getValueV();
			}

			filter.setStatus(currentStatus);
			filter.setRejectCode(currentRejectCode);
			filter.setFlowId(applicationRoot.getChildByName(AppElements.APPLICATION_FLOW_ID, 1).getValueN().intValue());
			List<ApplicationFlowTransition> statuses = daoApplication.getTransitionApplicationStatuses(userSessionId, filter);

			ApplicationFlowTransition activeStatus =
					ApplicationFlowTransition.createByStatusReject(currentStatus, currentRejectCode, dictUtils.getAllArticlesDesc());

			applicationStatuses.add(new SelectItem(activeStatus.getAppStatusRejectCode(), activeStatus.getAppStatusRejectLabel()));

			for (ApplicationFlowTransition status : statuses){
				if (!status.getAppStatusRejectCode().equals(activeStatus.getAppStatusRejectCode())){
					applicationStatuses.add(new SelectItem(status.getAppStatusRejectCode(), status.getAppStatusRejectLabel()));
				}
			}
		}
		return applicationStatuses;
	}
	
	private List<NavigatorItem> navigatorItems;
	private String navStepBeanName;
	
	private void prepareNavigatorItems(){
		logger.trace("MbWizard::prepareNavigatorItems...");
		navigatorItems = new ArrayList<NavigatorItem>();
		for (AppFlowStep step : steps){
			NavigatorItem navigatorItem = new NavigatorItem();
			navigatorItem.setLabel(step.getStepLabel());
			navigatorItem.setStepBeanName(step.getStepSource());
			if (currentStepBeanName.equals(step.getStepSource())){
				navigatorItem.setSelected(true);
			}
			navigatorItems.add(navigatorItem);
		}
	}
	
	private void updateNavigatorSteps(){
		if (navigatorItems == null) return;
		for (NavigatorItem navigatorItem : navigatorItems){
			if (currentStepBeanName.equals(navigatorItem.getStepBeanName())){
				navigatorItem.setSelected(true);
			} else {
				navigatorItem.setSelected(false);
			}
		}
	}
	
	private boolean stepsChanged(List<AppFlowStep> newSteps){
		logger.trace("MbWizard::stepsChanged...");
		int size = steps.size();
		if (size != newSteps.size()) return true;
		for (int i = 0; i < size; i++) {
			AppFlowStep step = steps.get(i);
			AppFlowStep newStep = steps.get(i);
			if (!step.equals(newStep)) return true;
		}
		return false;
	}

	public static class NavigatorItem {
		private String label;
		private String stepBeanName;
		private boolean selected;
		
		public String getLabel() {
			return label;
		}
		public void setLabel(String label) {
			this.label = label;
		}
		public String getStepBeanName() {
			return stepBeanName;
		}
		public void setStepBeanName(String step) {
			this.stepBeanName = step;
		}
		public boolean isSelected() {
			return selected;
		}
		public void setSelected(boolean selected) {
			this.selected = selected;
		}
	}
	
	public List<NavigatorItem> getNavigatorItems(){
		return navigatorItems;
	}

	
	public String getNavStepBeanName() {
		return navStepBeanName;
	}
	

	public void setNavStepBeanName(String navStepBeanName) {
		this.navStepBeanName = navStepBeanName;
	}

	public void checkKeyStep(){
		if (currentStep.isKeyStep()){
			stepHasKeyModifications = currentStepBean.checkKeyModifications();
		} else {
			stepHasKeyModifications = false;
		}
	}
	
	private boolean stepHasKeyModifications;
	
	public boolean isStepHasKeyModifications(){
		return stepHasKeyModifications;
	}
	
	public boolean isKeyStep(){
		return currentStep.isKeyStep();
	}

	public Map <ApplicationElement, List<ApplicationElement>> getLinkedMap() {
		return linkedMap;
	}

	public void setLinkedMap(Map <ApplicationElement, List<ApplicationElement>> linkedMap) {
		this.linkedMap = linkedMap;
	}
	
	public String cancel(){
		FacesUtils.setSessionMapValue("APP_TYPE", appType);
		if (backLink != null){
			return backLink;
		}else{
			return "blankPage";
		}
	}

	public boolean isKeepState() {
		return keepState;
	}

	public void setKeepState(boolean keepState) {
		this.keepState = keepState;
	}
	
	public Application getActiveApp(){
		return activeApp;
	}
	
	public void setActiveApp(Application app){
		this.activeApp = app;
	}

	public boolean isSearching() {
		return searching;
	}

	public void setSearching(boolean searching) {
		this.searching = searching;
	}

	public Application getFilter() {
		return filter;
	}

	public void setFilter(Application filter) {
		this.filter = filter;
	}

	public int getPageNumber() {
		return pageNumber;
	}

	public void setPageNumber(int pageNumber) {
		this.pageNumber = pageNumber;
	}

	public int getRowsNum() {
		return rowsNum;
	}

	public void setRowsNum(int rowNum) {
		this.rowsNum = rowNum;
	}

	public String getBackLink() {
		return backLink;
	}

	public void setBackLink(String backLink) {
		this.backLink = backLink;
	}

	public String getAppType() {
		return appType;
	}

	public void setAppType(String appType) {
		this.appType = appType;
	}

	public boolean idNewMod() {
		return mod == 4;
	}

	public void setMod(int mod) {
		this.mod = mod;
	}

	public AppFlowStep getCurrentStep(){
		return currentStep;
	}

	public void setContext(ApplicationWizardContext context) {
		this.context = context;
	}
}
