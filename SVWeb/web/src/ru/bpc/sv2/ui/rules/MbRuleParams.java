package ru.bpc.sv2.ui.rules;

import java.util.ArrayList;

import java.util.List;


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
import ru.bpc.sv2.rules.RuleParam;
import ru.bpc.sv2.rules.ProcedureParam;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.TableRowSelection;

@ViewScoped
@ManagedBean (name = "MbRuleParams")
public class MbRuleParams extends AbstractBean {
	private static final long serialVersionUID = 1L;
	
	private static final Logger logger = Logger.getLogger("RULES");
	
	private RulesDao _rulesDao = new RulesDao();
	
    private RuleParam filter;
	private RuleParam newRuleParam;
	
    private final DaoDataModel<RuleParam> _ruleParamSource;
	private final TableRowSelection<RuleParam> _itemSelection;
	private RuleParam _activeRuleParam;
	
	private static String COMPONENT_ID = "ruleParamsTable";
	private String tabName;
	private String parentSectionId;

	public MbRuleParams() {
		_ruleParamSource = new DaoDataModel<RuleParam>() {
			private static final long serialVersionUID = 1L;
			
			@Override
			protected RuleParam[] loadDaoData(SelectionParams params) {
				
				if (getFilter().getRuleId() == null)
					return new RuleParam[0];
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _rulesDao.getRuleParams( userSessionId, params);
				} catch (Exception e) {
					setDataSize(0);
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return new RuleParam[0];
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				
				if (getFilter().getRuleId() == null)
					return 0;
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _rulesDao.getRuleParamsCount( userSessionId, params);
				} catch (Exception e) {
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return 0;
			}
		};

		_itemSelection = new TableRowSelection<RuleParam>(null, _ruleParamSource);
	}
	
	public DaoDataModel<RuleParam> getRuleParams() {
		return _ruleParamSource;
	}

	public RuleParam getActiveRuleParam() {
		return _activeRuleParam;
	}

	public void setActiveRuleParam(RuleParam activeRuleParam) {
		_activeRuleParam = activeRuleParam;
	}

	public SimpleSelection getItemSelection() {
		if (_activeRuleParam == null && _ruleParamSource.getRowCount() > 0) {
			setFirstRowActive();
		}
		else if (_activeRuleParam != null && _ruleParamSource.getRowCount() > 0)
		{
			SimpleSelection selection = new SimpleSelection();
			selection.addKey(_activeRuleParam.getModelId());
			_itemSelection.setWrappedSelection(selection);
			_activeRuleParam = _itemSelection.getSingleSelection();			
		}
		return _itemSelection.getWrappedSelection();
	}

	public void setItemSelection(SimpleSelection selection) {
		_itemSelection.setWrappedSelection(selection);
		_activeRuleParam = _itemSelection.getSingleSelection();
	}

	public void setFirstRowActive() {
		_ruleParamSource.setRowIndex(0);
		SimpleSelection selection = new SimpleSelection();
		_activeRuleParam = (RuleParam) _ruleParamSource.getRowData();
		selection.addKey(_activeRuleParam.getModelId());
		_itemSelection.setWrappedSelection(selection);
		if (_activeRuleParam != null) {
			
		}
	}
	
	public void search() {		
		_ruleParamSource.flushCache();
		_itemSelection.clearSelection();
		_activeRuleParam = null;		
	}

	public void clearFilter() {
		curLang = userLang;
		filter = new RuleParam();		
	}
	
	public void setFilters() {
		filter = getFilter();

		filters = new ArrayList<Filter>();
		Filter paramFilter = new Filter();
		if (filter.getRuleId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("actionId");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(filter.getRuleId().toString());
			filters.add(paramFilter);			
		}
		
		paramFilter = new Filter();
		paramFilter.setElement("lang");
		paramFilter.setOp(Operator.eq);
		paramFilter.setValue(curLang);
		filters.add(paramFilter);			
	}
	
	public void resetBean() {
	}
	
	public RuleParam getFilter() {
		if (filter == null) {
			filter = new RuleParam();
		}
		return filter;
	}

	public void setFilter(RuleParam filter) {
		this.filter = filter;
	}

	public void add() {
		newRuleParam = new RuleParam();
		newRuleParam.setRuleId(getFilter().getRuleId());
		newRuleParam.setLang(userLang);
		curMode = NEW_MODE;
	}
	
	public void edit() {
		try {
			newRuleParam = _activeRuleParam.clone();
		} catch (CloneNotSupportedException e) {
			logger.error("",e);
			newRuleParam = new RuleParam();
		}		
		curMode = EDIT_MODE;
	}
	
	public void save() {
		try {
			_rulesDao.setRuleParam( userSessionId, newRuleParam);
			curMode = VIEW_MODE;
			
			_ruleParamSource.flushCache();
			FacesUtils.addMessageInfo("Parameter has been saved.");
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("",e);
		}
	}
	
	public void remove() {
		try {
			_rulesDao.removeRuleParam( userSessionId, _activeRuleParam);
			curMode = VIEW_MODE;			
			_ruleParamSource.flushCache();
			
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("",e);
		}
	}

	public void close() {
		curMode = VIEW_MODE;
	}
	
	public ArrayList<SelectItem> getAllAccountTypes() {
		return getDictUtils().getArticles(DictNames.ACCOUNT_TYPE, true, false);
	}

	public RuleParam getNewRuleParam() {
		if (newRuleParam == null) {
			newRuleParam = new RuleParam();
		}
		return newRuleParam;
	}

	public void setNewRuleParam(RuleParam newRuleParam) {
		this.newRuleParam = newRuleParam;
	}

	public void clearBean() {	
		setFilter(null);
		_itemSelection.clearSelection();
		_activeRuleParam = null;
		_ruleParamSource.flushCache();
	}
	
	public ArrayList<SelectItem> getProcParams() {
		ArrayList<SelectItem> items = new ArrayList<SelectItem>();
		try {
			ProcedureParam[] params = _rulesDao.getProcedureParams( userSessionId, null);
			for (ProcedureParam param: params) {
				items.add(new SelectItem(param.getId(), param.getSystemName()));
			}
		} catch (Exception e) {
			logger.error("",e);
			if (e.getMessage().indexOf(SystemConstants.INSUFFICIENT_PRIVILEGES_ERROR) < 0) {
				FacesUtils.addMessageError(e);
			}
		}
		return items;
	}
	
	public List<SelectItem> getListValues() {
		if (newRuleParam != null && newRuleParam.getLovId() != null) {
			return getDictUtils().getLov(newRuleParam.getLovId());
		}
		return new ArrayList<SelectItem>(0);
	}
	
	public String getComponentId() {
		return parentSectionId + ":" + tabName + ":" + COMPONENT_ID;
	}

	public void setTabName(String tabName) {
		this.tabName = tabName;
	}

	public void setParentSectionId(String parentSectionId) {
		this.parentSectionId = parentSectionId;
	}
}
