package ru.bpc.sv2.ui.common.application;

import org.apache.log4j.Logger;
import ru.bpc.sv2.administrative.users.User;
import ru.bpc.sv2.application.Application;
import ru.bpc.sv2.application.ApplicationElement;
import ru.bpc.sv2.application.ApplicationFlow;
import ru.bpc.sv2.application.ApplicationFlowFilter;
import ru.bpc.sv2.common.application.AppFlowStep;
import ru.bpc.sv2.common.application.ApplicationStatuses;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.constants.application.AppElements;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.invocation.SortElement;
import ru.bpc.sv2.logic.ApplicationDao;
import ru.bpc.sv2.logic.UsersDao;
import ru.bpc.sv2.orgstruct.Agent;
import ru.bpc.sv2.ui.session.UserSession;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DictUtils;
import ru.bpc.sv2.ui.utils.FacesUtils;
import util.auxil.ManagedBeanWrapper;
import util.auxil.SessionWrapper;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.model.SelectItem;
import java.io.Serializable;
import java.util.*;

@ViewScoped
@ManagedBean (name = "MbAppWizardFirstPage")
public class MbAppWizardFirstPage extends AbstractBean implements Serializable {
	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;

	private static final Logger logger = Logger.getLogger("APPLICATIONS");
	
	private String page = "/pages/common/application/appWizardFirstPage.jspx";
	protected Integer instId;
	protected Integer agentId;
	private Integer flowId;
	private Integer userInstId;
	private Integer userAgentId;
	private String applicationType;
	protected String userLang;
	private boolean chooseContract = false;
	private boolean oldContract = true;
	private boolean oldCustomer = true;
	
	private UsersDao daoUsers = new UsersDao();
	
	private ApplicationDao daoApplication = new ApplicationDao();
	
	protected long userSessionId;
	private DictUtils dictUtils;
	private List<SelectItem> institutions;
	private List<SelectItem> agents = new ArrayList<SelectItem>();
	private List<SelectItem> appFlows = new ArrayList<SelectItem>();
	protected List<AppFlowStep> appFlowSteps = null;

	public MbAppWizardFirstPage() {
		init();
	}
	
	public String getPage(){
		return page;
	}

	public Integer getInstId() {
		return instId;
	}

	public void setInstId(Integer instId) {
		this.instId = instId;
	}

	public Integer getAgentId() {
		return agentId;
	}

	public void setAgentId(Integer agentId) {
		this.agentId = agentId;
	}

	public Integer getFlowId() {
		return flowId;
	}

	public void setFlowId(Integer flowId) {
		this.flowId = flowId;
	}
	
	public void onInstitutionChanged() {
		logger.trace("onInstitutionChanged()..");
		agentId = null;
		if (userInstId.equals(instId)){
			agentId = userAgentId;
		} else {
			UserSession userSessionBean = (UserSession) ManagedBeanWrapper.getManagedBean("usession");
			User currentUser = userSessionBean.getUser();
			Integer userId = currentUser.getId();
			SelectionParams sp = new SelectionParams(
				new Filter[]{
					new Filter("userId", userId),
					new Filter("instId", instId),
					new Filter("isDefault", true)
			});
			Agent[] agents = daoUsers.getAgentsForUser(userSessionId, sp);
			if (agents.length != 0){
				agentId = agents[0].getId().intValue();
			}
		}
		prepareAgents();
		prepareAppFlows();
		onAgentChanged();
	}
	
	public void onAgentChanged() {
		logger.trace("onAgentChanged()..");
		prepareAppFlows();
	}
	
	public List<SelectItem> getInstitutions() {
		if (institutions == null) {
			prepareInstitutions();
		}
		return institutions;
	}
	
	public List<SelectItem> getAgents() {
		if (agents == null){
			prepareAgents();
		}
		return agents;
	}
	
	public List<SelectItem> getAppFlows(){
		if (appFlows == null){
			prepareAppFlows();
		}
		return appFlows;
	}
	
	private void prepareInstitutions(){
		logger.trace("prepareInstitutions()..");
		institutions = dictUtils.getLov(LovConstants.INSTITUTIONS);
		if (institutions == null)
			institutions = new ArrayList<SelectItem>();
	}
	
	private void prepareAgents(){
		logger.trace("prepareAgents()..");
		Map<String, Object> paramMap = new HashMap<String, Object>();
		paramMap.put("INSTITUTION_ID", instId);
		agents = dictUtils.getLov(LovConstants.AGENTS, paramMap);
		if (agents == null){
			agents = new ArrayList<SelectItem>();
		}
	}
	
	private void prepareAppFlows(){
		logger.trace("prepareAppFlows()..");
		Map<String, Object> paramMap = new HashMap<String, Object>();
		paramMap.put("INSTITUTION_ID", instId);
		paramMap.put("APPL_TYPE", applicationType);
		appFlows = dictUtils.getLov(LovConstants.APP_FLOWS, paramMap);
		if (appFlows == null)
			appFlows = new ArrayList<SelectItem>();
	}

	public void init() {
		MbWizard appWiz = (MbWizard) ManagedBeanWrapper.getManagedBean(MbWizard.class);
		applicationType = appWiz.getAppType();
		userSessionId = SessionWrapper.getRequiredUserSessionId();
		userInstId = (Integer) SessionWrapper.getObjectField("defaultInst");
		userAgentId = (Integer) SessionWrapper.getObjectField("defaultAgent");
		userLang = SessionWrapper.getField("language");
		flowId = null;
		chooseContract = false;
		oldContract = true;
		oldCustomer = true;
		dictUtils = ManagedBeanWrapper.getManagedBean(DictUtils.class);
		instId = userInstId;
		onInstitutionChanged();
	}
	
	public void changeFlow(){
		SelectionParams sp = new SelectionParams(
				new Filter("flowId", flowId),
				new Filter("lang", userLang),
				new Filter("appStatus", ApplicationStatuses.JUST_CREATED)
				);
		sp.setSortElement(
				new SortElement("displayOrder", SortElement.Direction.ASC)
				);
		
		AppFlowStep[] appFlowStepsArr = daoApplication.getAppFlowSteps(userSessionId, sp);
		appFlowSteps = Arrays.asList(appFlowStepsArr);
		if (appFlowSteps == null || appFlowSteps.isEmpty()){
			FacesUtils.addMessageError("There is no wizard flow has been found");
			return;
		}
		if (appFlowSteps.get(0).getStepLabel().
				equalsIgnoreCase(appFlowSteps.get(1).getStepLabel())){
			setChooseContract(true);
		}else{
			setChooseContract(false);
		}
	}
	
	public String next() {
		changeAppType();
		Application application = new Application();
		application.setInstId(instId);
		application.setAgentId(agentId);
		application.setFlowId(flowId);
		application.setAppType(applicationType);
		application.setStatus(ApplicationStatuses.JUST_CREATED);
		
		// Obtain blank application by flowId and fill it
		Map<Integer, ApplicationFlowFilter> applicationFilters = new HashMap<Integer, ApplicationFlowFilter>();;
		ApplicationElement applicationRoot = daoApplication.getApplicationStructure(userSessionId, application, applicationFilters);
		ApplicationElement aeInstId = applicationRoot.getChildByName(AppElements.INSTITUTION_ID, 1);
		aeInstId.setValueN(instId);
		ApplicationElement aeAgentId = applicationRoot.getChildByName(AppElements.AGENT_ID, 1);
		aeAgentId.setValueN(agentId);
		ApplicationElement aeFlowId = applicationRoot.getChildByName(AppElements.APPLICATION_FLOW_ID, 1);
		aeFlowId.setValueN(flowId);
		ApplicationElement aeAppStatus = applicationRoot.getChildByName(AppElements.APPLICATION_STATUS, 1);
		aeAppStatus.setValueV(ApplicationStatuses.JUST_CREATED);
		ApplicationElement aeAppType = applicationRoot.getChildByName(AppElements.APPLICATION_TYPE, 1);
		aeAppType.setValueV(applicationType);
		
		SelectionParams sp = new SelectionParams(
				new Filter("flowId", flowId),
				new Filter("lang", userLang),
				new Filter("appStatus", ApplicationStatuses.JUST_CREATED)
				);
		sp.setSortElement(
				new SortElement("displayOrder", SortElement.Direction.ASC)
				);
		
		AppFlowStep[] appFlowStepsArr = daoApplication.getAppFlowSteps(userSessionId, sp);
		appFlowSteps = Arrays.asList(appFlowStepsArr);
		if (appFlowSteps == null || appFlowSteps.isEmpty()){
			FacesUtils.addMessageError("There is no wizard flow has been found");
			return "";
		}
		if (isChooseContract()){
			if (isOldContract()){
				if (appFlowSteps.get(0).getStepSource().contains("New")){
					remove(0, appFlowStepsArr);
				}else{
					remove(1, appFlowStepsArr);
				}
			}else{
				if (appFlowSteps.get(0).getStepSource().contains("Old")){
					remove(0, appFlowStepsArr);
				}else{
					remove(1, appFlowStepsArr);
				}
			}
		}
		appFlowSteps.get(0).setKeyStep(true); // "Customer and Contact" step is always "Reset Step"
		MbWizard mbWizard = ManagedBeanWrapper.getManagedBean(MbWizard.class);
		ApplicationWizardContext ctx = new ApplicationWizardContext();
		ctx.setSteps(appFlowSteps);
		ctx.setOldContract(oldContract);
		ctx.setOldCustomer(oldCustomer);
		ctx.setApplicationFilters(applicationFilters);
		ctx.setApplicationRoot(applicationRoot);
		mbWizard.init(ctx);
		return "application|wizard";
	}
	
	private void remove(int id, AppFlowStep[] appFlowStepsArr ){
		appFlowSteps = new ArrayList<AppFlowStep>(
				appFlowStepsArr.length - 1);
		for (int i = 0; i < appFlowStepsArr.length; i++){
			if (id != i){
				appFlowSteps.add(appFlowStepsArr[i]);
			}
		}
	}
	
	public String cancel(){
		FacesUtils.setSessionMapValue("APP_TYPE", applicationType);
		String backLing = (String) 
				FacesUtils.getSessionMapValue("backLink");
		if (backLing != null){
			return backLing;
		}else{
			return "blankPage";
		}
	}
	
	private void changeAppType(){
		List<Filter> filters = new ArrayList<Filter>();
		filters.add(new Filter ("id", flowId));
		filters.add(new Filter ("lang", userLang));
		SelectionParams params = new SelectionParams();
		params.setRowIndexEnd(-1);
		params.setFilters(filters.toArray(new Filter[filters.size()]));
		ApplicationFlow[] flow = daoApplication.getApplicationFlows(userSessionId, params);
		if (flow.length > 0){
			applicationType =  flow[flow.length - 1].getAppType();
		}
	}

	public String getApplicationType() {
		return applicationType;
	}

	public void setApplicationType(String applicationType) {
		this.applicationType = applicationType;
	}

	public boolean isChooseContract() {
		return chooseContract;
	}

	public void setChooseContract(boolean chooseContract) {
		this.chooseContract = chooseContract;
	}

	public boolean isOldContract() {
		return oldContract;
	}

	public void setOldContract(boolean oldContract) {
		this.oldContract = oldContract;
	}
	
		@Override
	public void clearFilter() {
		// TODO Auto-generated method stub
	}

	public boolean isOldCustomer() {
		return oldCustomer;
	}

	public void setOldCustomer(boolean oldCustomer) {
		this.oldCustomer = oldCustomer;
	}

	public void changeCustomer(){
		if (!isOldCustomer()){
			setOldContract(false);
		}
	}
}
