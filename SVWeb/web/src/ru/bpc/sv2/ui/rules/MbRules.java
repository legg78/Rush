package ru.bpc.sv2.ui.rules;

import java.util.ArrayList;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.model.SelectItem;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;

import ru.bpc.sv2.constants.DictNames;
import ru.bpc.sv2.constants.SystemConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.invocation.Filter.Operator;
import ru.bpc.sv2.logic.RulesDao;
import ru.bpc.sv2.rules.Rule;
import ru.bpc.sv2.rules.RuleParam;
import ru.bpc.sv2.rules.Procedure;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.TableRowSelection;
import util.auxil.ManagedBeanWrapper;

@ViewScoped
@ManagedBean (name = "MbRules")
public class MbRules extends AbstractBean {
	private static final long serialVersionUID = 8440373615615675149L;

	private static final Logger logger = Logger.getLogger("RULES");

	private RulesDao _rulesDao = new RulesDao();

	private Rule filter;
	private String ruleSetName;
	private String msgType;

	private Rule newRule;
	protected MbRuleParams paramsBean;

	private final DaoDataModel<Rule> _rulesSource;
	private final TableRowSelection<Rule> _itemSelection;
	private Rule _activeRule;
	
	private static String COMPONENT_ID = "rulesTable";
	private String tabName;
	private String parentSectionId;

	public MbRules() {
		paramsBean = (MbRuleParams) ManagedBeanWrapper.getManagedBean("MbRuleParams");

		_rulesSource = new DaoDataModel<Rule>() {
			private static final long serialVersionUID = 1496999767768414839L;

			@Override
			protected Rule[] loadDaoData(SelectionParams params) {
				if (getFilter().getRuleSetId() == null) {
					return new Rule[0];
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _rulesDao.getRules(userSessionId, params);
				} catch (Exception e) {
					setDataSize(0);
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return new Rule[0];
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (getFilter().getRuleSetId() == null) {
					return 0;
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _rulesDao.getRulesCount(userSessionId, params);
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
			setBeans();
		}
	}

	public void setFirstRowActive() {
		_rulesSource.setRowIndex(0);
		SimpleSelection selection = new SimpleSelection();
		_activeRule = (Rule) _rulesSource.getRowData();
		selection.addKey(_activeRule.getModelId());
		_itemSelection.setWrappedSelection(selection);
		if (_activeRule != null) {
			setBeans();
		}
	}

	public void setBeans() {
		RuleParam filter = new RuleParam();
		filter.setRuleId(_activeRule.getId());
		paramsBean.setFilter(filter);
		paramsBean.search();
	}

	public String search() {

		// search using new criteria
		_rulesSource.flushCache();

		// reset selection
		if (_activeRule != null) {
			_itemSelection.unselect(_activeRule);
			_activeRule = null;
		}
		paramsBean.clearBean();
		// reset dependent bean

		return "";
	}

	public void clearFilter() {
		curLang = userLang;
		filter = null;
		clearBean();
	}

	public void setFilters() {
		filter = getFilter();

		filters = new ArrayList<Filter>();

		Filter paramFilter = new Filter();
		paramFilter.setElement("lang");
		paramFilter.setOp(Operator.eq);
		paramFilter.setValue(curLang);
		filters.add(paramFilter);

		if (filter.getId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("id");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(filter.getId().toString());
			filters.add(paramFilter);
		}

		if (filter.getRuleSetId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("ruleSetId");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(filter.getRuleSetId().toString());
			filters.add(paramFilter);
		}

	}

	public Rule getFilter() {
		if (filter == null) {
			filter = new Rule();
		}
		return filter;
	}

	public void setFilter(Rule filter) {
		this.filter = filter;
	}

	public void add() {
		newRule = new Rule();
		newRule.setRuleSetId(getFilter().getRuleSetId());
		curMode = NEW_MODE;
	}

	public void edit() {
		newRule = new Rule();
		newRule.setId(_activeRule.getId());
		newRule.setProcedureId(_activeRule.getProcedureId());
		newRule.setRuleSetId(_activeRule.getRuleSetId());
		newRule.setExecOrder(_activeRule.getExecOrder());
		newRule.setSeqNum(_activeRule.getSeqNum());
		curMode = EDIT_MODE;
	}

	public void save() {
		try {
			StringBuilder sb = new StringBuilder("");
			if (!checkOrder(sb)) {
				FacesUtils.addMessageError(new Exception(sb.toString()));
				return;
			}

			if (isNewMode()) {
				newRule = _rulesDao.addRule(userSessionId, newRule, curLang);
				_itemSelection.addNewObjectToList(newRule);
			} else {
				newRule = _rulesDao.modifyRule(userSessionId, newRule, curLang);
				_rulesSource.replaceObject(_activeRule, newRule);
			}
			_activeRule = newRule;
			setBeans();
			curMode = VIEW_MODE;

			FacesUtils.addMessageInfo(FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Rul",
					"rule_saved"));
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void delete() {
		try {
			_rulesDao.deleteRule(userSessionId, _activeRule);
			curMode = VIEW_MODE;

			_activeRule = _itemSelection.removeObjectFromList(_activeRule);
			if (_activeRule == null) {
				clearBean();
			} else {
				setBeans();
			}
			FacesUtils.addMessageInfo(FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Rul",
					"rule_deleted"));

		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	private boolean checkOrder(StringBuilder sb) {
		SelectionParams params = new SelectionParams();
		params.setRowIndexEnd(-1);
		setFilters();
		params.setFilters(filters.toArray(new Filter[filters.size()]));
		Rule[] actions = _rulesDao.getRules(userSessionId, params);
		for (Rule action : actions) {
			if (action.getExecOrder().equals(newRule.getExecOrder()) &&
					!action.getId().equals(newRule.getId())) {
				sb.append(FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Rul",
						"rule_exec_order_exists"));
				return false;
			}
		}
		return true;
	}

	public void close() {
		curMode = VIEW_MODE;
	}

	public ArrayList<SelectItem> getAllAccountTypes() {
		return getDictUtils().getArticles(DictNames.ACCOUNT_TYPE, true, false);
	}

	public String getRuleSetName() {
		return ruleSetName;
	}

	public void setRuleSetName(String ruleSetName) {
		this.ruleSetName = ruleSetName;
	}

	public Rule getNewRule() {
		return newRule;
	}

	public void setNewRule(Rule newRule) {
		this.newRule = newRule;
	}

	public ArrayList<SelectItem> getProcedures() {
		if (getFilter().getCategory() != null || getFilter().getRuleSetId() != null) {
			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("lang");
			filters[0].setValue(userLang);

			if (filter.getCategory() != null) {
				filters[1] = new Filter();
				filters[1].setElement("category");
				filters[1].setValue(filter.getCategory());
			} else {
				// if (RuleMessageType.PREAUTHORIZATION.equals(msgType)
				// || RuleMessageType.AUTHORIZATION.equals(msgType)
				// || RuleMessageType.COMPLETION.equals(msgType)) {
				// category = RulesCategory.AUTHORIZATION;
				// } else {
				// category = RulesCategory.OPERATION;
				// }
				filters[1] = new Filter();
				filters[1].setElement("ruleSetId");
				filters[1].setValue(filter.getRuleSetId());
			}

			SelectionParams params = new SelectionParams();
			params.setRowIndexEnd(-1);
			params.setFilters(filters);

			try {
				Procedure[] procs = _rulesDao.getProcedures(userSessionId, params);
				ArrayList<SelectItem> items = new ArrayList<SelectItem>(procs.length);
				for (Procedure proc : procs) {
					items.add(new SelectItem(proc.getId(), proc.getName()));
				}
				return items;
			} catch (Exception e) {
				logger.error("", e);
				if (e.getMessage().indexOf(SystemConstants.INSUFFICIENT_PRIVILEGES_ERROR) < 0) {
					FacesUtils.addMessageError(e);
				}
			}
		}
		return new ArrayList<SelectItem>(0);
	}

	public void clearBean() {
		_itemSelection.clearSelection();
		_activeRule = null;
		_rulesSource.flushCache();
		if (paramsBean != null) {
			paramsBean.clearBean();
		}
	}

	public void fullCleanBean() {
		clearFilter();
		msgType = null;
		ruleSetName = null;
	}

	public String getMsgType() {
		return msgType;
	}

	public void setMsgType(String msgType) {
		this.msgType = msgType;
	}
	
	public String getComponentId() {
		return parentSectionId + ":" + tabName + ":" + COMPONENT_ID;
	}

	public void setTabName(String tabName) {
		this.tabName = tabName;
	}

	public String getTabName() {
		return tabName;
	}

	public void setParentSectionId(String parentSectionId) {
		this.parentSectionId = parentSectionId;
	}
}
