package ru.bpc.sv2.ui.rules;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;


import ru.bpc.sv2.logic.utility.db.DataAccessException;
import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.event.ValueChangeEvent;
import javax.faces.model.SelectItem;

import org.apache.commons.lang3.StringUtils;
import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;

import ru.bpc.sv2.constants.DictNames;
import ru.bpc.sv2.constants.EntityNames;
import ru.bpc.sv2.constants.SectionIdConstants;
import ru.bpc.sv2.constants.SystemConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.Filter.Operator;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.RulesDao;
import ru.bpc.sv2.rules.Rule;
import ru.bpc.sv2.rules.RuleSet;
import ru.bpc.sv2.ui.acm.MbContextMenu;
import ru.bpc.sv2.ui.context.ContextType;
import ru.bpc.sv2.ui.context.ContextTypeFactory;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.TableRowSelection;
import util.auxil.ManagedBeanWrapper;

@ViewScoped
@ManagedBean (name = "MbRuleSets")
public class MbRuleSets extends AbstractBean {
	private static final long serialVersionUID = 1755327245966408328L;

	private static final Logger logger = Logger.getLogger("RULES");

	private static String COMPONENT_ID = "1046:ruleSetsTable";

	private RulesDao _rulesDao = new RulesDao();

	private RuleSet ruleSetFilter;
	private RuleSet newRuleSet;
	private MbRules actionBean;

	private final DaoDataModel<RuleSet> _ruleSetSource;
	private final TableRowSelection<RuleSet> _itemSelection;
	private RuleSet _activeRuleSet;

	private String tabName;

	private String ctxItemEntityType;
	private ContextType ctxType;

	public MbRuleSets() {
		pageLink = "rules|actions";
		tabName = "detailsTab";
		_ruleSetSource = new DaoDataModel<RuleSet>() {
			private static final long serialVersionUID = -2879834331251926551L;

			@Override
			protected RuleSet[] loadDaoData(SelectionParams params) {
				if (!searching) {
					return new RuleSet[0];
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _rulesDao.getRuleSets(userSessionId, params);
				} catch (Exception e) {
					setDataSize(0);
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return new RuleSet[0];
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (!searching) {
					return 0;
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _rulesDao.getRuleSetsCount(userSessionId, params);
				} catch (Exception e) {
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return 0;
			}
		};

		_itemSelection = new TableRowSelection<RuleSet>(null, _ruleSetSource);
	}

	public DaoDataModel<RuleSet> getRuleSets() {
		return _ruleSetSource;
	}

	public RuleSet getActiveRuleSet() {
		return _activeRuleSet;
	}

	public void setActiveRuleSet(RuleSet activeRuleSet) {
		_activeRuleSet = activeRuleSet;
	}

	public SimpleSelection getItemSelection() {
		if (_activeRuleSet == null && _ruleSetSource.getRowCount() > 0) {
			setFirstRowActive();
		} else if (_activeRuleSet != null && _ruleSetSource.getRowCount() > 0) {
			SimpleSelection selection = new SimpleSelection();
			selection.addKey(_activeRuleSet.getModelId());
			_itemSelection.setWrappedSelection(selection);
			_activeRuleSet = _itemSelection.getSingleSelection();
		}
		return _itemSelection.getWrappedSelection();
	}

	public void setItemSelection(SimpleSelection selection) {
		_itemSelection.setWrappedSelection(selection);
		_activeRuleSet = _itemSelection.getSingleSelection();
		if (_activeRuleSet != null) {
			setBeans();
		}
	}

	public void setFirstRowActive() {
		_ruleSetSource.setRowIndex(0);
		SimpleSelection selection = new SimpleSelection();
		_activeRuleSet = (RuleSet) _ruleSetSource.getRowData();
		selection.addKey(_activeRuleSet.getModelId());
		_itemSelection.setWrappedSelection(selection);
		if (_activeRuleSet != null) {
			setBeans();
		}
	}

	private void setBeans() {
		actionBean = (MbRules) ManagedBeanWrapper.getManagedBean("MbRules");
		actionBean.clearBean();
		Rule filter = new Rule();
		filter.setRuleSetId(_activeRuleSet.getId());
		filter.setCategory(_activeRuleSet.getCategory());
		actionBean.setRuleSetName(_activeRuleSet.getName());
		actionBean.setFilter(filter);
		actionBean.search();
	}

	public void clearBeans() {
		actionBean = (MbRules) ManagedBeanWrapper.getManagedBean("MbRules");
		actionBean.clearFilter();
	}

	public void search() {
		clearBean();
		searching = true;
		// reset dependent bean
	}

	public void clearFilter() {
		curLang = userLang;
		ruleSetFilter = new RuleSet();

		clearBean();
		searching = false;
	}

	public void setFilters() {
		ruleSetFilter = getFilter();
		filters = new ArrayList<Filter>();
		filters.add(new Filter("lang", userLang));

		if (ruleSetFilter.getId() != null) {
			filters.add(new Filter("id", ruleSetFilter.getId().toString()));
		}
		if (StringUtils.isNotEmpty(ruleSetFilter.getName())) {
			filters.add(new Filter("name", ruleSetFilter.getName().trim().toUpperCase().replaceAll("[*]", "%").replaceAll("[?]", "_")));
		}
		if (StringUtils.isNotEmpty(ruleSetFilter.getCategory())) {
			filters.add(new Filter("category", ruleSetFilter.getCategory()));
		}
		if (ruleSetFilter.getRuleId() != null) {
			filters.add(new Filter("ruleId", ruleSetFilter.getRuleId().toString()));
		}
		if (StringUtils.isNotEmpty(ruleSetFilter.getRuleName())) {
			filters.add(new Filter("ruleName", ruleSetFilter.getRuleName().trim().toUpperCase().replaceAll("[*]", "%").replaceAll("[?]", "_")));
		}
	}

	public void resetBean() {
	}

	public RuleSet getFilter() {
		if (Boolean.TRUE.equals(FacesUtils.getSessionMapValue("initFromContext"))) {
			initFilterFromContext();
			search();
			FacesUtils.setSessionMapValue("initFromContext", null);
		}

		if (ruleSetFilter == null) {
			ruleSetFilter = new RuleSet();
		}
		return ruleSetFilter;
	}

	private void initFilterFromContext() {
		ruleSetFilter = new RuleSet();
		if (FacesUtils.getSessionMapValue("name") != null) {
			ruleSetFilter.setName((String) FacesUtils.getSessionMapValue("name"));
			FacesUtils.setSessionMapValue("name", null);
		}
	}

	public void setFilter(RuleSet ruleSetFilter) {
		this.ruleSetFilter = ruleSetFilter;
	}

	public void add() {
		newRuleSet = new RuleSet();
		newRuleSet.setLang(userLang);
		if (categoryRestriction != null){
			newRuleSet.setCategory(categoryRestriction);
		}
		curMode = NEW_MODE;
	}

	public void edit() {
		try {
			newRuleSet = _activeRuleSet.clone();
		} catch (CloneNotSupportedException e) {
			newRuleSet = _activeRuleSet;
			logger.error("", e);
		}
		curMode = EDIT_MODE;
	}

	public void save() {
		try {
			if (isNewMode()) {
				_rulesDao.addRuleSet(userSessionId, newRuleSet);
				_itemSelection.addNewObjectToList(newRuleSet);
			} else {
				_rulesDao.modifyRuleSet(userSessionId, newRuleSet);

				_ruleSetSource.replaceObject(_activeRuleSet, newRuleSet);
			}
			_activeRuleSet = newRuleSet;
			setBeans();
			curMode = VIEW_MODE;

			FacesUtils.addMessageInfo("Rule set has been saved.");
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void createRuleSet() {
		try {
			_rulesDao.addRuleSet(userSessionId, newRuleSet);
			curMode = VIEW_MODE;

			FacesUtils.addMessageInfo("Rule set has been saved.");
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void delete() {
		try {
			_rulesDao.deleteRuleSet(userSessionId, _activeRuleSet);
			curMode = VIEW_MODE;

			FacesUtils.addMessageInfo("Rule set (id = " + _activeRuleSet.getId()
					+ ") has been deleted.");

			_activeRuleSet = _itemSelection.removeObjectFromList(_activeRuleSet);
			if (_activeRuleSet == null) {
				clearBean();
			} else {
				setBeans();
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void close() {
		curMode = VIEW_MODE;
	}

	public ArrayList<SelectItem> getAllAccountTypes() {
		return getDictUtils().getArticles(DictNames.ACCOUNT_TYPE, true, false);
	}

	public RuleSet getNewRuleSet() {
		if (newRuleSet == null) {
			newRuleSet = new RuleSet();
		}
		return newRuleSet;
	}

	public void setNewRuleSet(RuleSet newRuleSet) {
		this.newRuleSet = newRuleSet;
	}

	public ArrayList<SelectItem> getCategories() {
		return getDictUtils().getArticles(DictNames.RULE_CATEGORIES, true, false);
	}

	public void clearBean() {
		// reset selection
		_itemSelection.clearSelection();
		_activeRuleSet = null;
		_ruleSetSource.flushCache();

		clearBeans();
	}

	public void changeLanguage(ValueChangeEvent event) {
		curLang = (String) event.getNewValue();

		List<Filter> filtersList = new ArrayList<Filter>();

		Filter paramFilter = new Filter();
		paramFilter.setElement("id");
		paramFilter.setOp(Operator.eq);
		paramFilter.setValue(_activeRuleSet.getId().toString());
		filtersList.add(paramFilter);

		paramFilter = new Filter();
		paramFilter.setElement("lang");
		paramFilter.setOp(Operator.eq);
		paramFilter.setValue(curLang);
		filtersList.add(paramFilter);

		filters = filtersList;
		SelectionParams params = new SelectionParams();
		params.setFilters(filters.toArray(new Filter[filters.size()]));
		try {
			RuleSet[] ruleSets = _rulesDao.getRuleSets(userSessionId, params);
			if (ruleSets != null && ruleSets.length > 0) {
				_activeRuleSet = ruleSets[0];
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void confirmEditLanguage() {
		Filter[] filters = new Filter[2];
		filters[0] = new Filter();
		filters[0].setElement("id");
		filters[0].setValue(newRuleSet.getId());
		filters[1] = new Filter();
		filters[1].setElement("lang");
		filters[1].setValue(newRuleSet.getLang());

		SelectionParams params = new SelectionParams();
		params.setFilters(filters);
		try {
			RuleSet[] ruleSets = _rulesDao.getRuleSets(userSessionId, params);
			if (ruleSets != null && ruleSets.length > 0) {
				newRuleSet = ruleSets[0];
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public String getComponentId() {
		return COMPONENT_ID;
	}

	public Logger getLogger() {
		return logger;
	}

	public String getCategoryRestriction() {
		return categoryRestriction;
	}

	public void setCategoryRestriction(String categoryRestriction) {
		this.categoryRestriction = categoryRestriction;
	}

	private String categoryRestriction;
	private List<SelectItem> ruleSetList;

	public List<SelectItem> getRuleSetList(){
		if (ruleSetList == null){
			prepareRuleSetList();
		}
		return ruleSetList;
	}

	public void prepareRuleSetList(){
		ruleSetList = new ArrayList<SelectItem>();
		List<Filter> filters = new ArrayList<Filter>();
		filters.add(new Filter("lang", userLang));
		if (categoryRestriction != null){
			filters.add(new Filter("category", categoryRestriction));
		}
		SelectionParams p = new SelectionParams(filters);
		p.setRowIndexEnd(-1);
		RuleSet[] ruleSetsTmp = null;
		try {
			ruleSetsTmp = _rulesDao.getRuleSets(userSessionId, p);
		} catch (DataAccessException e){
			logger.error(e);
			if (e.getMessage().indexOf(SystemConstants.INSUFFICIENT_PRIVILEGES_ERROR) < 0) {
				FacesUtils.addSystemError(e);
			}
			return;
		}
		for (RuleSet set : ruleSetsTmp) {
			ruleSetList.add(new SelectItem(set.getId(), set.getId() + " - " + set.getName()));
		}
	}

	public void saveClone(){
		try {
			newRuleSet = _rulesDao.cloneRuleSet(userSessionId, newRuleSet);
		} catch (Exception e){
			logger.error(e);
			FacesUtils.addErrorExceptionMessage(e);
			return;
		}
		_itemSelection.addNewObjectToList(newRuleSet);
		_activeRuleSet = newRuleSet;
		setBeans();
		curMode = VIEW_MODE;
	}

	public void createClone(){
		add();
		if(_activeRuleSet != null) {
			newRuleSet.setId(_activeRuleSet.getId());
		}
		prepareRuleSetList();
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
		return SectionIdConstants.OPERATION_PROCESSING_RULE;
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
		if (_activeRuleSet != null){
			if (EntityNames.RULE_SET.equals(ctxItemEntityType)) {
				map.put("id", _activeRuleSet.getId());
				map.put("cardholderName", _activeRuleSet.getName());
			}
		}

		ctxType.setParams(map);
		return ctxType;
	}

	public boolean isForward(){
		return !ctxItemEntityType.equals(EntityNames.RULE_SET);
	}
}
