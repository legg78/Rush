package ru.bpc.sv2.ui.operations;

import java.util.ArrayList;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.model.SelectItem;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;

import ru.bpc.sv2.constants.SystemConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.invocation.Filter.Operator;
import ru.bpc.sv2.logic.OperationDao;
import ru.bpc.sv2.operations.MatchCondition;
import ru.bpc.sv2.operations.MatchLevelCondition;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.TableRowSelection;

@ViewScoped
@ManagedBean(name = "MbMatchLevelConditions")
public class MbMatchLevelConditions extends AbstractBean{
	private static final long serialVersionUID = 9048717055567215610L;

	private static final Logger logger = Logger.getLogger("OPER_PROCESSING");
	
	private OperationDao _operationsDao = new OperationDao();
	
    private MatchLevelCondition filter;
	private MatchLevelCondition newMatchLevelCondition;
	private Integer levelId;
	private Integer instId;
    
    private final DaoDataModel<MatchLevelCondition> _connsSource;
	private final TableRowSelection<MatchLevelCondition> _itemSelection;
	private MatchLevelCondition _activeMatchLevelCondition;
	
	private static String COMPONENT_ID = "mlcTable";
	private String tabName;
	private String parentSectionId;

	public MbMatchLevelConditions() {
		_connsSource = new DaoDataModel<MatchLevelCondition>() {
			private static final long serialVersionUID = -6488816717493439713L;

			@Override
			protected MatchLevelCondition[] loadDaoData(SelectionParams params) {
				if (levelId == null) {
					return new MatchLevelCondition[0];
				}
				try {
					setFilters(params);
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _operationsDao.getMatchLevelConditions( userSessionId, params);
				} catch (Exception e) {
					setDataSize(0);
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return new MatchLevelCondition[0];
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (levelId == null) {
					return 0;
				}
				try {
					setFilters(params);
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _operationsDao.getMatchLevelConditionsCount( userSessionId, params);
				} catch (Exception e) {
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return 0;
			}
		};

		_itemSelection = new TableRowSelection<MatchLevelCondition>(null, _connsSource);
	}

	public DaoDataModel<MatchLevelCondition> getMatchLevelConditions() {
		return _connsSource;
	}

	public MatchLevelCondition getActiveMatchLevelCondition() {
		return _activeMatchLevelCondition;
	}

	public void setActiveMatchLevelCondition(MatchLevelCondition activeMatchLevelCondition) {
		_activeMatchLevelCondition = activeMatchLevelCondition;
	}

	public SimpleSelection getItemSelection() {
		return _itemSelection.getWrappedSelection();
	}

	public void setItemSelection(SimpleSelection selection) {
		_itemSelection.setWrappedSelection(selection);
		_activeMatchLevelCondition = _itemSelection.getSingleSelection();
	}
	
	public void search() {
		clearBean();
	}

	public void clearFilter() {
		curLang = userLang;
		filter = new MatchLevelCondition();
	}

	public void setFilters(SelectionParams params) {
		filter = getFilter();

		filters = new ArrayList<Filter>();
		
		Filter paramFilter = new Filter();
		paramFilter.setElement("levelId");
		paramFilter.setOp(Operator.eq);
		paramFilter.setValue(levelId.toString());
		filters.add(paramFilter);

		paramFilter = new Filter();
		paramFilter.setElement("lang");
		paramFilter.setOp(Operator.eq);
		paramFilter.setValue(curLang);
		filters.add(paramFilter);
	}

	public void add() {
		newMatchLevelCondition =  new MatchLevelCondition();
		newMatchLevelCondition.setLevelId(levelId);
		newMatchLevelCondition.setLang(userLang);
		curMode = NEW_MODE;
	}
	
	public void save() {
		try {
			_operationsDao.includeConditionInLevel( userSessionId, newMatchLevelCondition);

			_connsSource.flushCache();
			curMode = VIEW_MODE;
			FacesUtils.addMessageInfo(
					FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Opr", "level_condition_added",
							"(ID = " + newMatchLevelCondition.getConditionId() + ")",
							"(ID = " + levelId + ")"));
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("",e);
		}
	}
	
	public void delete() {
		try {
			_operationsDao.removeConditionFromLevel( userSessionId, _activeMatchLevelCondition);
			_connsSource.flushCache();
			
			String msg = FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Opr", "level_condition_removed",
					"(ID = " + _activeMatchLevelCondition.getConditionId() + ")", 
					"(ID = " + _activeMatchLevelCondition.getLevelId() + ")");
			
			if (_itemSelection != null) {
				_itemSelection.unselect(_activeMatchLevelCondition);
			}
			_activeMatchLevelCondition = null;
			
			FacesUtils.addMessageInfo(msg);
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("",e);
		}
	}

	public void cancel() {
		curMode = VIEW_MODE;
	}
	
	public MatchLevelCondition getFilter() {
		if (filter == null) {
			filter = new MatchLevelCondition();
		}
		return filter;
	}

	public void setFilter(MatchLevelCondition filter) {
		this.filter = filter;
	}

	public MatchLevelCondition getNewMatchLevelCondition() {
		if (newMatchLevelCondition == null) {
			newMatchLevelCondition = new MatchLevelCondition();
		}
		return newMatchLevelCondition;
	}

	public void setNewMatchLevelCondition(MatchLevelCondition newMatchLevelCondition) {
		this.newMatchLevelCondition = newMatchLevelCondition;
	}
	
	public void clearBean() {
		_connsSource.flushCache();
		_itemSelection.clearSelection();
		_activeMatchLevelCondition = null;
	}

	public Integer getLevelId() {
		return levelId;
	}

	public void setLevelId(Integer levelId) {
		this.levelId = levelId;
	}
	
	public Integer getInstId() {
		return instId;
	}

	public void setInstId(Integer instId) {
		this.instId = instId;
	}

	public ArrayList<SelectItem> getConditions() {
		ArrayList<SelectItem> items = null;
		if (instId != null) {
			SelectionParams params = new SelectionParams();
			
			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("instId");
			filters[0].setOp(Operator.eq);
			filters[0].setValue(instId.toString());
			
			filters[1] = new Filter();
			filters[1].setElement("lang");
			filters[1].setOp(Operator.eq);
			filters[1].setValue(userLang);
			
			params.setFilters(filters);
			params.setRowIndexEnd(-1);
			
			try {
				MatchCondition[] conditions = _operationsDao.getMatchConditions( userSessionId, params);
				items = new ArrayList<SelectItem>(conditions.length);
				
				for (MatchCondition cond: conditions) {
					items.add(new SelectItem(cond.getId(), cond.getName()));
				}
			} catch (Exception e) {
				logger.error(e.getMessage(), e);
				if (e.getMessage().indexOf(SystemConstants.INSUFFICIENT_PRIVILEGES_ERROR) < 0) {
					FacesUtils.addMessageError(e);
				}
				items = new ArrayList<SelectItem>(0);
			}
		} else {
			items = new ArrayList<SelectItem>(0);
		}
		return items;
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
