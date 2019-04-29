package ru.bpc.sv2.ui.operations;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;


import ru.bpc.sv2.logic.ScenariosDao;
import ru.bpc.sv2.logic.utility.db.DataAccessException;
import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.model.SelectItem;

import org.apache.log4j.Logger;

import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.constants.SectionIdConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.scenario.Scenario;
import ru.bpc.sv2.ui.aut.MbAutRespCode;
import ru.bpc.sv2.ui.rules.MbRuleParams;
import ru.bpc.sv2.ui.rules.MbRules;
import ru.bpc.sv2.ui.scenario.MbScenarioSelections;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DictUtils;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.FilterFactory;
import util.auxil.ManagedBeanWrapper;
import util.auxil.SessionWrapper;

@ViewScoped
@ManagedBean (name = "MbOperTypes")
public class MbOperTypes extends AbstractBean implements Serializable {
	private static final long serialVersionUID = 1L;
	
	private static final Logger logger = Logger.getLogger("OPER_PROCESSING");

	private ScenariosDao scenarioDao = new ScenariosDao();
	
	private transient DictUtils dictUtils;
	private MbCheckSelections mbCheckSelection;
	private MbScenarioSelections mbScenarioSelections;
	private MbAutRespCode mbAutRespCode;
	private MbProcessingTemplates mbProcessingTemplates;
	private MbParticipantType mbParticipantType;
	private MbReasonMapping mbReasonMapping;
	
	private List<SelectItem> operTypes;
	private String activeOperType;
	private String entityTab = "checksTab";
	private Long userSessionId;
	private String userLang;
	
	private String tabName;

	public MbOperTypes(){
		pageLink = "operations|operTypes";
		logger.trace("MbOperTypes construction...");
		userSessionId = SessionWrapper.getRequiredUserSessionId();
		userLang = SessionWrapper.getField("language");
		
		mbCheckSelection = ManagedBeanWrapper.getManagedBean(MbCheckSelections.class);	
		mbScenarioSelections = ManagedBeanWrapper.getManagedBean(MbScenarioSelections.class);
		mbAutRespCode = ManagedBeanWrapper.getManagedBean(MbAutRespCode.class);
		mbProcessingTemplates = ManagedBeanWrapper.getManagedBean(MbProcessingTemplates.class);
		mbReasonMapping = ManagedBeanWrapper.getManagedBean(MbReasonMapping.class);
		mbParticipantType = ManagedBeanWrapper.getManagedBean(MbParticipantType.class);
	}
	
	public List<SelectItem> getOperTypes(){
		if (operTypes == null){
			operTypes =  getDictUtils().getLov(LovConstants.OPERATION_TYPE);
		}
		return operTypes;
	}
	
	public String getActiveOperType() {
		return activeOperType;
	}

	public void setActiveOperType(String activeOperType) {
		logger.trace("MbOperTypes.setActiveOperType()...");
		logger.debug("activeOperType: " + activeOperType);
		this.activeOperType = activeOperType;
	}
	
	public void clearFilter(){
		logger.trace("MbOperTypes.clearFilter()...");
		clearState();
		clearBeansStates();
	}
	
	public void search(){
		logger.trace("MbOperTypes.search()...");
		clearBeansStates();
		setBeansState();
	}
	
	public void clearState(){
		logger.trace("MbOperTypes.clearState()...");
		activeOperType = null;
	}
	
	public void clearBeansStates(){
		logger.trace("MbOperTypes.clearBeansStates()...");
		mbCheckSelection.clearFilter();
		mbScenarioSelections.clearFilter();
		mbAutRespCode.clearFilter();
		mbProcessingTemplates.clearFilter();
		mbReasonMapping.clearFilter();
		mbParticipantType.clearFilter();
	}
	
	private void setBeansState(){
		logger.trace("MbOperTypes.setBeanState()...");
		loadEntityTab();
	}
	
	public void loadEntityTab(){
		logger.trace("MbOperTypes.loadEntityTab()...");
		clearBeansStates();
		if (activeOperType == null){
			
			return;
		}
		
		logger.debug("entityTab: " + entityTab);
		logger.debug("Oper type: " + activeOperType);
		if ("participantsTab".equals(entityTab)){
			mbParticipantType.clearBeansStates();
			mbParticipantType.getFilter().setOperType(activeOperType);			
			mbParticipantType.search();
		} else if ("checksTab".equals(entityTab)){
			mbCheckSelection.clearBeansStates();
			mbCheckSelection.getFilter().setOperType(activeOperType);
			mbCheckSelection.getFilter().setInstId(null);
			mbCheckSelection.search();
		} else if ("scenariosTab".equals(entityTab)){
			mbScenarioSelections.clearBean();
			mbScenarioSelections.getFilter().setOperType(activeOperType);
			mbScenarioSelections.search();
		} else if ("respCodesTab".equals(entityTab)){
			mbAutRespCode.clearState();
			mbAutRespCode.getFilter().setOperType(activeOperType);
			mbAutRespCode.search();
		} else if ("procTemplatesTab".equals(entityTab)){
			mbProcessingTemplates.clearBean();
			mbProcessingTemplates.getFilter().setOperType(activeOperType);
			mbProcessingTemplates.search();
		} else if ("reasonMappingTab".equals(entityTab)){
			mbReasonMapping.clearBean();
			mbReasonMapping.getFilter().setOperType(activeOperType);
			mbReasonMapping.search();
		}
	}
	

	public String getEntityTab() {
		return entityTab;
	}

	public void setEntityTab(String entityTab) {
		logger.trace("MbOperTypes.setEntityTab()...");
		logger.debug("entityTab: " + entityTab);
		this.entityTab = entityTab;
	}
	
	public void addCheck(){
		logger.trace("MbOperTypes.addCheck()...");
		mbCheckSelection.add();
		mbCheckSelection.getNewCheckSelection().setOperType(activeOperType);
	}
	
	private List<SelectItem> scenarios;
	
	public void addScenarioSelection(){
		logger.trace("MbOperTypes.addScenario()...");
		mbScenarioSelections.add();
		mbScenarioSelections.getNewSelection().setOperType(activeOperType);
		loadScenarios();
	}
	
	public List<SelectItem> getScenarios(){
		logger.trace("MbOperTypes.getScenarios()...");
		if (scenarios == null){
			loadScenarios();
		}
		return scenarios;
	}
	
	private void loadScenarios(){
		logger.trace("MbOperTypes.loadScenarios()...");
		SelectionParams sp = new SelectionParams(new Filter("lang", userLang));
		sp.setRowIndexEnd(Integer.MAX_VALUE);
		scenarios = new ArrayList<SelectItem>();
		Scenario[] scanariosArr = null;
		try {
			scanariosArr = scenarioDao.getScenarios(userSessionId, sp);
		} catch (DataAccessException e){
			logger.error(e);
			FacesUtils.addSystemError(e);
		}
		
		if (scanariosArr != null && scanariosArr.length > 0){
			logger.debug("Scenarios found: " + scanariosArr.length);
			for (Scenario s : scanariosArr){
				SelectItem is = new SelectItem(s.getId(), s.getDescription());
				scenarios.add(is);
			}
		}
	}
	
	public void addRespCode(){
		logger.trace("MbOperTypes.addRespCode()...");
		mbAutRespCode.createNewRespCode();
		mbAutRespCode.getEditingItem().setOperType(activeOperType);
	}
	
	public void addProcessingTemplate(){
		logger.trace("MbOperTypes.addProcessingTemplate()...");
		mbProcessingTemplates.add();
		mbProcessingTemplates.getNewRule().setOperType(activeOperType);
		mbProcessingTemplates.updateOperReasons();
	}
	
	public void addReasonMapping(){
		logger.trace("MbOperTypes.addReasonMapping()...");
		mbReasonMapping.add();
		mbReasonMapping.getNewReasonMapping().setOperType(activeOperType);
	}

	public DictUtils getDictUtils() {
		if (dictUtils == null) {
			dictUtils = (DictUtils) ManagedBeanWrapper.getManagedBean("DictUtils");
		}
		return dictUtils;
	}

	public String getTabName() {
		return tabName;
	}

	public void setTabName(String tabName) {
		this.tabName = tabName;
		if (tabName.equalsIgnoreCase("checksTab")) {
			MbChecks bean = (MbChecks) ManagedBeanWrapper
					.getManagedBean("MbChecks");
			bean.setTabName(entityTab + ":" + tabName);
			bean.setParentSectionId(getSectionId());
			bean.setTableState(getSateFromDB(bean.getComponentId()));
		} else if (tabName.equalsIgnoreCase("rulesTab")) {
			MbRules bean = (MbRules) ManagedBeanWrapper
					.getManagedBean("MbRules");
			bean.setTabName(entityTab + ":" + tabName);
			bean.setParentSectionId(getSectionId());
			bean.setTableState(getSateFromDB(bean.getComponentId()));
			
			MbRuleParams bean1 = (MbRuleParams) ManagedBeanWrapper
					.getManagedBean("MbRuleParams");
			bean1.setTabName(entityTab + ":" + tabName);
			bean1.setParentSectionId(getSectionId());
			bean1.setTableState(getSateFromDB(bean.getComponentId()));
		}
	}
	
	public String getSectionId() {
		return SectionIdConstants.OPERATION_PROCESSING_OPERTYPE;
	}

	@Override
	protected void applySectionFilter(Integer filterId) {
		try {
			FilterFactory factory = (FilterFactory) ManagedBeanWrapper
					.getManagedBean("filterFactory");
			Map<String, String> filterRec = factory.getSectionFilterRecs(filterId);
			sectionFilter = factory.getUserSectionFiltersObjects().get(filterId);
			if (filterRec != null) {
				if (filterRec.get("activeOperType") != null) {
					setActiveOperType(filterRec.get("activeOperType"));
				}
			}
			if (searchAutomatically) {
				search();
			}
			sectionFilterModeEdit = true;
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	@Override
	public void saveSectionFilter() {
		try {
			FilterFactory factory = (FilterFactory) ManagedBeanWrapper
					.getManagedBean("filterFactory");

			Map<String, String> filterRec = new HashMap<String, String>();
			if (getActiveOperType() != null) {
				filterRec.put("activeOperType", getActiveOperType());
			}
			sectionFilter = getSectionFilter();
			sectionFilter.setRecs(filterRec);

			factory.saveSectionFilter(sectionFilter, sectionFilterModeEdit);
			selectedSectionFilter = sectionFilter.getId();
			sectionFilterModeEdit = true;
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}
}
