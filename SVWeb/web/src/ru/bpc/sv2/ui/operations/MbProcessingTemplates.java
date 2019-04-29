package ru.bpc.sv2.ui.operations;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;
import ru.bpc.sv2.constants.*;
import ru.bpc.sv2.constants.scale.ScaleConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.Filter.Operator;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.OperationDao;
import ru.bpc.sv2.logic.RulesDao;
import ru.bpc.sv2.operations.Rule;
import ru.bpc.sv2.rules.Modifier;
import ru.bpc.sv2.rules.RuleSet;
import ru.bpc.sv2.rules.RulesCategory;
import ru.bpc.sv2.ui.acm.MbContextMenu;
import ru.bpc.sv2.ui.context.ContextType;
import ru.bpc.sv2.ui.context.ContextTypeFactory;
import ru.bpc.sv2.ui.rules.MbRuleParams;
import ru.bpc.sv2.ui.rules.MbRuleSets;
import ru.bpc.sv2.ui.rules.MbRules;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.TableRowSelection;
import util.auxil.ManagedBeanWrapper;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.event.ValueChangeEvent;
import javax.faces.model.SelectItem;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@ViewScoped
@ManagedBean (name = "MbProcessingTemplates")
public class MbProcessingTemplates extends AbstractBean{
	private static final long serialVersionUID = -7045851240929905639L;

	private static final String COMPONENT_ID = "1047:rulesTable";

	private OperationDao _operationDao = new OperationDao();

	private RulesDao _rulesDao = new RulesDao();

	private Rule ruleFilter;
	private String defaultLang;

	private final DaoDataModel<Rule> _rulesSource;
	private final TableRowSelection<Rule> _itemSelection;
	private Rule _activeRule;
	private Rule newRule;
	private String tabName;
	private ArrayList<SelectItem> institutions;
	private ArrayList<SelectItem> ruleSets;
	private ArrayList<SelectItem> modifiers;
	private MbRules actionBean;
	private List<SelectItem> cachedYesNoList;
	private Map<String, String> yesNoMap;
	private int ruleSetMode = 1;
	
	private static final Logger logger = Logger.getLogger("RULES");
	
	private ContextType ctxType;
	private String ctxItemEntityType;

	public MbProcessingTemplates() {
		pageLink = "operations|rules";
		tabName = "detTab";
		_rulesSource = new DaoDataModel<Rule>() {
			private static final long serialVersionUID = -8950021912248335371L;

			@Override
			protected Rule[] loadDaoData(SelectionParams params) {
				if (!searching) {
					return new Rule[0];
				}
				try {
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _operationDao.getRules(userSessionId, params);
				} catch (Exception e) {
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return new Rule[0];
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (!searching) {
					return 0;
				}
				try {
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _operationDao.getRulesCount(userSessionId, params);
				} catch (Exception e) {
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return 0;
			}
		};

		_itemSelection = new TableRowSelection<Rule>(null, _rulesSource);
	}

	public DaoDataModel<Rule> getRules() {
		return _rulesSource;
	}

	public Rule getActiveRule() {
		return _activeRule;
	}

	public void setActiveRule(Rule activeRule) {
		_activeRule = activeRule;
	}

	public SimpleSelection getItemSelection() {
		if (_activeRule == null && _rulesSource.getRowCount() > 0) {
			setFirstRowActive();
		} else if (_activeRule != null && _rulesSource.getRowCount() > 0) {
			SimpleSelection selection = new SimpleSelection();
			selection.addKey(_activeRule.getModelId());
			_itemSelection.setWrappedSelection(selection);
			_activeRule = _itemSelection.getSingleSelection();
		}
		return _itemSelection.getWrappedSelection();
	}

	public void setItemSelection(SimpleSelection selection) {
		_itemSelection.setWrappedSelection(selection);
		_activeRule = _itemSelection.getSingleSelection();
		if (_activeRule != null) {
			setInfo();
		}
	}

	public void setFirstRowActive() {
		_rulesSource.setRowIndex(0);
		SimpleSelection selection = new SimpleSelection();
		_activeRule = (Rule) _rulesSource.getRowData();
		selection.addKey(_activeRule.getModelId());
		_itemSelection.setWrappedSelection(selection);
		if (_activeRule != null) {
			setInfo();
		}
	}

	public void setInfo() {
		actionBean = (MbRules) ManagedBeanWrapper.getManagedBean("MbRules");
		actionBean.fullCleanBean();
		actionBean.getFilter().setRuleSetId(_activeRule.getRuleSetId());
		actionBean.setRuleSetName(_activeRule.getRuleSetName());
		actionBean.search();
	}

	public void clearBeans() {
		actionBean = (MbRules) ManagedBeanWrapper.getManagedBean("MbRules");
		actionBean.clearBean();
		actionBean.clearFilter();
	}

	public void search() {

		setFilters();
		searching = true;
		_rulesSource.flushCache();
		_itemSelection.clearSelection();
		_activeRule = null;
		operReasons = null;
		clearBeans();

		// reset dependent bean
		// resetBalanceType();
	}

	public void clearFilter() {
		curLang = defaultLang;
		ruleFilter = new Rule();
		searching = false;

		clearBean();
	}

	public void clearBean() {
		_itemSelection.clearSelection();
		_activeRule = null;
		_rulesSource.flushCache();

		clearBeans();
	}

	public void setFilters() {
		getFilter();

		filters = new ArrayList<Filter>();

		Filter paramFilter;

		paramFilter = new Filter();
		paramFilter.setElement("lang");
		paramFilter.setOp(Operator.eq);
		paramFilter.setValue(userLang);
		filters.add(paramFilter);

		if (ruleFilter.getOperType() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("operType");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(ruleFilter.getOperType());
			filters.add(paramFilter);
		}
		if (ruleFilter.getMsgType() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("msgType");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(ruleFilter.getMsgType());
			filters.add(paramFilter);
		}
		if (ruleFilter.getProcStage() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("procStage");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(ruleFilter.getProcStage());
			filters.add(paramFilter);
		}
		if (ruleFilter.getSttlType() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("sttlType");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(ruleFilter.getSttlType());
			filters.add(paramFilter);
		}
		if (ruleFilter.getReversal() != null && !"".equals(ruleFilter.getReversal())) {
			paramFilter = new Filter();
			paramFilter.setElement("reversal");
			paramFilter.setValue(ruleFilter.getReversal());
			filters.add(paramFilter);
		}
		if (ruleFilter.getRuleSetId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("rule_set_id");
			paramFilter.setValue(ruleFilter.getRuleSetId());
			filters.add(paramFilter);
		}
		if (ruleFilter.getIssInstId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("issInstId");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(ruleFilter.getIssInstId());
			filters.add(paramFilter);
		}
		if (ruleFilter.getAcqInstId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("acqInstId");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(ruleFilter.getAcqInstId ());
			filters.add(paramFilter);
		}
	}

	public void resetBean() {
	}

	public Rule getFilter() {
		if (ruleFilter == null) {
			ruleFilter = new Rule();
		}
		return ruleFilter;
	}

	public void setFilter(Rule ruleFilter) {
		this.ruleFilter = ruleFilter;
	}

	public void add() {
		curMode = NEW_MODE;
		newRule = new Rule();
	}

	public void edit() {
		curMode = EDIT_MODE;
		try {
			newRule = _activeRule.clone();
		} catch (CloneNotSupportedException e) {
			newRule = new Rule();
		}
		updateOperReasons();
	}

	public void save() {
		try {
			if (isNewMode()) {
				newRule = _operationDao.addRule(userSessionId, newRule, userLang);
				_itemSelection.addNewObjectToList(newRule);
			} else {
				newRule = _operationDao.modifyRule(userSessionId, newRule, userLang);
				_rulesSource.replaceObject(_activeRule, newRule);
			}

			_activeRule = newRule;
			setInfo();
			ruleSetMode = 1;  
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
		}
	}

	public void delete() {
		try {
			_operationDao.deleteRule(userSessionId, _activeRule);
			_activeRule = _itemSelection.removeObjectFromList(_activeRule);

			if (_activeRule == null) {
				clearBean();
			} else {
				setInfo();
			}

		} catch (Exception e) {
			FacesUtils.addMessageError(e);
		}
	}

	public void close() {
		curMode = VIEW_MODE;
	}

	public ArrayList<SelectItem> getAllAccountTypes() {
		return getDictUtils().getArticles(DictNames.ACCOUNT_TYPE, true, false);
	}

	public List<SelectItem> getOperTypes() {
		return getDictUtils().getLov(LovConstants.OPERATION_TYPE);
	}

	private List<SelectItem> operReasons;
	
	public List<SelectItem> getOperReasons() {
		if (operReasons == null){
			updateOperReasons();
		}
		return operReasons;
	}

	public void updateOperReasons(){
		Map<String, Object> params = new HashMap<String, Object>();
		params.put("oper_type", getNewRule().getOperType());
		operReasons = getDictUtils().getLov(LovConstants.OPER_REASON, params);
	}
	
	public ArrayList<SelectItem> getMsgTypes() {
		return getDictUtils().getArticles(DictNames.MSG_TYPE, false, true);
	}

	public ArrayList<SelectItem> getSttlTypes() {
		return getDictUtils().getArticles(DictNames.STTL_TYPE, false, true);
	}

	public ArrayList<SelectItem> getTermTypes() {
		return getDictUtils().getArticles(DictNames.TERMINAL_TYPE, false, true);
	}

	public ArrayList<SelectItem> getProcStages() {
		return getDictUtils().getArticles(DictNames.PROC_STAGE, false, true);
	}

	public ArrayList<SelectItem> getIssInsts() {
		ArrayList<SelectItem> issInsts = (ArrayList<SelectItem>) getDictUtils().getLov(LovConstants.INSTITUTIONS_SYS);
		issInsts.add(0, new SelectItem("%", "Any"));
		return issInsts;
	}

	public ArrayList<SelectItem> getAcqInsts() {
		ArrayList<SelectItem> acqInsts = (ArrayList<SelectItem>) getDictUtils().getLov(LovConstants.INSTITUTIONS_SYS);
		acqInsts.add(0, new SelectItem("%", "Any"));
		return acqInsts;
	}

	public ArrayList<SelectItem> getMsgTypesNoEmpty() {
		return getDictUtils().getArticles(DictNames.MSG_TYPE, false, true);
	}

	public ArrayList<SelectItem> getSttlTypesNoEmpty() {
		return getDictUtils().getArticles(DictNames.STTL_TYPE, false, true);
	}

	public ArrayList<SelectItem> getTermTypesNoEmpty() {
		return getDictUtils().getArticles(DictNames.TERMINAL_TYPE, false, true);
	}

	public ArrayList<SelectItem> getIssInstsNoEmpty() {
		ArrayList<SelectItem> issInsts = (ArrayList<SelectItem>) getDictUtils().getLov(LovConstants.INSTITUTIONS_SYS);
		issInsts.add(0, new SelectItem("%", "Any"));
		return issInsts;
	}

	public ArrayList<SelectItem> getgetAcqInstsNoEmpty() {
		ArrayList<SelectItem> acqInsts = (ArrayList<SelectItem>) getDictUtils().getLov(LovConstants.INSTITUTIONS_SYS);
		acqInsts.add(0, new SelectItem("%", "Any"));
		return acqInsts;
	}

	public String getTabName() {
		return tabName;
	}

	public void setTabName(String tabName) {
		this.tabName = tabName;
		
		if (tabName.equalsIgnoreCase("rulesTab")) {
			MbRules bean = (MbRules) ManagedBeanWrapper
					.getManagedBean("MbRules");
			bean.setTabName(tabName);
			bean.setParentSectionId(getSectionId());
			bean.setTableState(getSateFromDB(bean.getComponentId()));
			
			MbRuleParams bean1 = (MbRuleParams) ManagedBeanWrapper
					.getManagedBean("MbRuleParams");
			bean1.setTabName(tabName);
			bean1.setParentSectionId(getSectionId());
			bean1.setTableState(getSateFromDB(bean1.getComponentId()));
		}	
	}
	
	public String getSectionId() {
		return SectionIdConstants.OPERATION_PROCESSING_TEMPLATE;
	}

	public ArrayList<SelectItem> getInstitutions() {
		if (institutions == null) {
			institutions = (ArrayList<SelectItem>) getDictUtils().getLov(LovConstants.INSTITUTIONS_SYS);
		}
		if (institutions == null)
			institutions = new ArrayList<SelectItem>();
		return institutions;
	}

	public ArrayList<SelectItem> getRuleSets() {
		if (ruleSets != null) {
			return ruleSets;
		}
		ArrayList<SelectItem> items = new ArrayList<SelectItem>();
		try {
			SelectionParams params = new SelectionParams();
			params.setRowIndexEnd(-1);

			List<Filter> filtersList = new ArrayList<Filter>();
			Filter paramFilter = new Filter();
			paramFilter.setElement("lang");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(userLang);
			filtersList.add(paramFilter);

			String category;
//			if (getNewRule().getMsgType() != null
//					&& (RuleMessageType.PREAUTHORIZATION.equals(getNewRule().getMsgType())
//							|| RuleMessageType.AUTHORIZATION.equals(getNewRule().getMsgType()) 
//							|| RuleMessageType.COMPLETION.equals(getNewRule().getMsgType())
//							|| RuleMessageType.AUTH_VALIDATION.equals(getNewRule().getMsgType()))) {
//				category = RulesCategory.AUTHORIZATION;
//			} else {
				category = RulesCategory.OPERATION;
//			}
			paramFilter = new Filter();
			paramFilter.setElement("category");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(category);
			filtersList.add(paramFilter);

			params.setFilters(filtersList.toArray(new Filter[filtersList.size()]));
			RuleSet[] ruleSetsTmp = _rulesDao.getRuleSets(userSessionId, params);
			for (RuleSet set : ruleSetsTmp) {
				items.add(new SelectItem(set.getId(), set.getId() + " - " + set.getName()));
			}
			ruleSets = items;
		} catch (Exception e) {
			logger.error("", e);
			if (!e.getMessage().contains(SystemConstants.INSUFFICIENT_PRIVILEGES_ERROR)) {
				FacesUtils.addMessageError(e);
			}
		} finally {
			if (ruleSets == null)
				ruleSets = new ArrayList<SelectItem>();
		}
		return ruleSets;
	}

	public ArrayList<SelectItem> getModifiers() {
		if (modifiers == null) {
			ArrayList<SelectItem> items = new ArrayList<SelectItem>();
			try {
				SelectionParams params = new SelectionParams();
				params.setRowIndexEnd(-1);

				List<Filter> filtersList = new ArrayList<Filter>();
				Filter paramFilter = new Filter();
				paramFilter.setElement("lang");
				paramFilter.setOp(Operator.eq);
				paramFilter.setValue(userLang);
				filtersList.add(paramFilter);

				paramFilter = new Filter();
				paramFilter.setElement("scaleType");
				paramFilter.setOp(Operator.eq);
				paramFilter.setValue(ScaleConstants.SCALE_FOR_RULES);
				filtersList.add(paramFilter);

				params.setFilters(filtersList.toArray(new Filter[filtersList.size()]));
				Modifier[] modsTmp = _rulesDao.getModifiers(userSessionId, params);
				for (Modifier mod : modsTmp) {
					items.add(new SelectItem(mod.getId(), mod.getId() + " - " + mod.getName()));
				}
				modifiers = items;
			} catch (Exception e) {
				logger.error("", e);
				if (!e.getMessage().contains(SystemConstants.INSUFFICIENT_PRIVILEGES_ERROR)) {
					FacesUtils.addMessageError(e);
				}
			} finally {
				if (modifiers == null)
					modifiers = new ArrayList<SelectItem>();
			}
		}
		return modifiers;
	}

	public void cancel() {
		ruleSetMode = 1;
	}

	public Rule getNewRule() {
		if (newRule == null) {
			newRule = new Rule();
		}
		return newRule;
	}

	public void setNewRule(Rule newRule) {
		this.newRule = newRule;
	}

	public String getComponentId() {
		return COMPONENT_ID;
	}

	public Logger getLogger() {
		return logger;
	}

	public List<SelectItem> getYesNoList(){
		if (cachedYesNoList == null){
			cachedYesNoList = getDictUtils().getLov(LovConstants.YES_NO_LIST);
		}
		return cachedYesNoList;
	}
	
	public Map<String, String> getYesNoMap(){
		if (yesNoMap == null){
			yesNoMap = getDictUtils().getLovMap(LovConstants.YES_NO_LIST);
			yesNoMap.put("", "");
			yesNoMap.put("%", "%");
		}
		return yesNoMap;
	}

	public int getRuleSetMode() {
		return ruleSetMode;
	}

	public void setRuleSetMode(int ruleSetMode) {
		this.ruleSetMode = ruleSetMode;
		if (ruleSetMode == 1){
			newRule.setRuleSetId(null);
			newRule.setRuleSetName(null);
		}
	}

	public void saveNewRuleSet(){
		MbRuleSets mbRuleSets = (MbRuleSets) ManagedBeanWrapper.getManagedBean("MbRuleSets");
		mbRuleSets.save();
		newRule.setRuleSetId(mbRuleSets.getNewRuleSet().getId());
		newRule.setRuleSetName(mbRuleSets.getNewRuleSet().getName());
		addRuleToList(newRule);

	}

	private void addRuleToList(Rule rule){
		getRuleSets().add(new SelectItem(newRule.getRuleSetId(), newRule.getRuleSetId()
				+ " - " + newRule.getRuleSetName()));
	}
	
	public void addNewRuleSet(){
		MbRuleSets mbRuleSets = (MbRuleSets) ManagedBeanWrapper.getManagedBean("MbRuleSets");
		mbRuleSets.setCategoryRestriction(RulesCategory.OPERATION);
		mbRuleSets.add();
	}
	
	public void createCloneRuleSet(){
		MbRuleSets mbRuleSets = (MbRuleSets) ManagedBeanWrapper.getManagedBean("MbRuleSets");
		mbRuleSets.setCategoryRestriction(RulesCategory.OPERATION);
		mbRuleSets.createClone();
	}
	
	public void saveNewCloneRuleSet(){
		MbRuleSets mbRuleSets = (MbRuleSets) ManagedBeanWrapper.getManagedBean("MbRuleSets");
		mbRuleSets.saveClone();
		newRule.setRuleSetId(mbRuleSets.getNewRuleSet().getId());
		newRule.setRuleSetName(mbRuleSets.getNewRuleSet().getName());
		addRuleToList(newRule);
	}
	
	public void changeRuleSetMode(ValueChangeEvent event) {
		newRule.setRuleSetId(null);
		newRule.setRuleSetName(null);
	}
	
	
	public String getCtxItemEntityType() {
		return ctxItemEntityType;
	}

	public void setCtxItemEntityType() {
		MbContextMenu ctxBean = (MbContextMenu) ManagedBeanWrapper.getManagedBean("MbContextMenu");
		String ctx = ctxBean.getEntityType();
		if (ctx == null || !ctx.equals(this.ctxItemEntityType)){
			ctxType = ContextTypeFactory.getInstance(ctx);
		}
		this.ctxItemEntityType = ctx;
	}
	
	public ContextType getCtxType(){
		if (ctxType == null) return null;
		Map <String, Object> map = new HashMap<String, Object>();

		if (EntityNames.RULE_SET.equals(ctxItemEntityType)) {
			map.put("id", _activeRule.getRuleSetId());
			map.put("name", _activeRule.getRuleSetName());
			ctxType.setParams(map);
		}

		ctxType.setParams(map);
		return ctxType;
	}
	
	public boolean isForward(){
		return true;
	}

	public void clearState() {
		_itemSelection.clearSelection();
		_activeRule = null;
		_rulesSource.flushCache();
		curLang = userLang;
	}
	
}
