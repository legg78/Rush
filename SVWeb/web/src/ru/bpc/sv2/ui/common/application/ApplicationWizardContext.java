package ru.bpc.sv2.ui.common.application;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import ru.bpc.sv2.application.ApplicationElement;
import ru.bpc.sv2.application.ApplicationFlowFilter;
import ru.bpc.sv2.common.application.AppFlowStep;

public class ApplicationWizardContext implements Cloneable{
	private ApplicationElement applicationRoot;
	private Map<Integer, ApplicationFlowFilter> applicationFilters;
	private List<AppFlowStep> steps;
	private String stepPage;
	private String applicationType;
	private boolean oldContract;
	private boolean oldCustomer;
	private Long applicationTemplateId;
	private Map <ApplicationElement, List<ApplicationElement>> linkedMap;
	private Map<String, Object> parameters = new HashMap<String, Object>();

	public ApplicationElement getApplicationRoot() {
		return applicationRoot;
	}

	public void setApplicationRoot(ApplicationElement applicationRoot) {
		this.applicationRoot = applicationRoot;
	}

	public Map<Integer, ApplicationFlowFilter> getApplicationFilters() {
		return applicationFilters;
	}

	public void setApplicationFilters(
			Map<Integer, ApplicationFlowFilter> applicationFilters) {
		this.applicationFilters = applicationFilters;
	}

	public List<AppFlowStep> getSteps() {
		return steps;
	}

	public void setSteps(List<AppFlowStep> steps) {
		this.steps = steps;
	}

	public String getStepPage() {
		return stepPage;
	}

	public void setStepPage(String stepPage) {
		this.stepPage = stepPage;
	}

	public String getApplicationType() {
		return applicationType;
	}

	public void setApplicationType(String applicationType) {
		this.applicationType = applicationType;
	}

	public Long getApplicationTemplateId() {
		return applicationTemplateId;
	}

	public void setApplicationTemplateId(Long applicationTemplateId) {
		this.applicationTemplateId = applicationTemplateId;
	}
	
	@Override
	public ApplicationWizardContext clone() throws CloneNotSupportedException{
		return (ApplicationWizardContext) super.clone();
	}
	
	public ApplicationWizardContext silentClone(){
		ApplicationWizardContext result = null;
		try {
			result = clone();
		} catch (CloneNotSupportedException e){
			throw new Error(e);
		}
		return result;
	}
	
	public void set(String key, Object value){
		parameters.put(key, value);
	}
	
	public Object get(String key){
		return parameters.get(key);
	}

	public Map <ApplicationElement, List<ApplicationElement>> getLinkedMap() {
		return linkedMap;
	}

	public void setLinkedMap(Map <ApplicationElement, List<ApplicationElement>> linkedMap) {
		this.linkedMap = linkedMap;
	}

	public boolean isOldContract() {
		return oldContract;
	}

	public void setOldContract(boolean oldContract) {
		this.oldContract = oldContract;
	}

	public boolean isOldCustomer() {
		return oldCustomer;
	}

	public void setOldCustomer(boolean oldCustomer) {
		this.oldCustomer = oldCustomer;
	}

}
