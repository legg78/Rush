package ru.bpc.sv2.ui.operations;

import java.util.ArrayList;
import java.util.List;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.event.ValueChangeEvent;
import javax.faces.model.SelectItem;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;

import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.Filter.Operator;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.OperationDao;
import ru.bpc.sv2.operations.MatchCondition;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.TableRowSelection;

@ViewScoped
@ManagedBean (name = "MbMatchConditions")
public class MbMatchConditions extends AbstractBean {
	private static final Logger logger = Logger.getLogger("OPER_PROCESSING");

	private static String COMPONENT_ID = "1435:matchConditionsTable";

	private OperationDao _operationsDao = new OperationDao();

	

	private MatchCondition filter;
	private MatchCondition newMatchCondition;
	private MatchCondition detailMatchCondition;
	private ArrayList<SelectItem> institutions;

	private final DaoDataModel<MatchCondition> _matchConditionsSource;
	private final TableRowSelection<MatchCondition> _itemSelection;
	private MatchCondition _activeMatchCondition;

	public MbMatchConditions() {
		
		pageLink = "operations|match|conditions";
		_matchConditionsSource = new DaoDataModel<MatchCondition>() {
			@Override
			protected MatchCondition[] loadDaoData(SelectionParams params) {
				if (!searching) {
					return new MatchCondition[0];
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _operationsDao.getMatchConditions(userSessionId, params);
				} catch (Exception e) {
					setDataSize(0);
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return new MatchCondition[0];
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (!searching) {
					return 0;
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _operationsDao.getMatchConditionsCount(userSessionId, params);
				} catch (Exception e) {
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return 0;
			}
		};

		_itemSelection = new TableRowSelection<MatchCondition>(null, _matchConditionsSource);
	}

	public DaoDataModel<MatchCondition> getMatchConditions() {
		return _matchConditionsSource;
	}

	public MatchCondition getActiveMatchCondition() {
		return _activeMatchCondition;
	}

	public void setActiveMatchCondition(MatchCondition activeMatchCondition) {
		_activeMatchCondition = activeMatchCondition;
	}

	public SimpleSelection getItemSelection() {
		try {
			if (_activeMatchCondition == null && _matchConditionsSource.getRowCount() > 0) {
				setFirstRowActive();
			} else if (_activeMatchCondition != null && _matchConditionsSource.getRowCount() > 0) {
				SimpleSelection selection = new SimpleSelection();
				selection.addKey(_activeMatchCondition.getModelId());
				_itemSelection.setWrappedSelection(selection);
				_activeMatchCondition = _itemSelection.getSingleSelection();
				setBeans();
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}	
		return _itemSelection.getWrappedSelection();
	}

	public void setItemSelection(SimpleSelection selection) {
		try {
			_itemSelection.setWrappedSelection(selection);
			boolean changeSelect = false;
			if (_itemSelection.getSingleSelection() != null 
					&& !_itemSelection.getSingleSelection().getId().equals(_activeMatchCondition.getId())) {
				changeSelect = true;
			}
			_activeMatchCondition = _itemSelection.getSingleSelection();
	
			if (_activeMatchCondition != null) {
				setBeans();
				if (changeSelect) {
					detailMatchCondition = (MatchCondition) _activeMatchCondition.clone();
				}
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void setFirstRowActive() throws CloneNotSupportedException {
		_matchConditionsSource.setRowIndex(0);
		SimpleSelection selection = new SimpleSelection();
		_activeMatchCondition = (MatchCondition) _matchConditionsSource.getRowData();
		detailMatchCondition = (MatchCondition) _activeMatchCondition.clone();
		selection.addKey(_activeMatchCondition.getModelId());
		_itemSelection.setWrappedSelection(selection);

		setBeans();
	}

	/**
	 * Sets data for backing beans used by dependent pages
	 */
	public void setBeans() {
//		connectivityBean = (MbConnectivity) ManagedBeanWrapper.getManagedBean("MbConnectivity");
//		connectivityBean.setMatchCondition(_activeMatchCondition);		
//		connectivityBean.getConnections().flushCache();
	}

	public void search() {
		clearBean();
		searching = true;
	}

	public void clearFilter() {
		clearBean();
		curLang = userLang;
		filter = null;
		searching = false;
	}

	public void setFilters() {
		filter = getFilter();

		filters = new ArrayList<Filter>();

		Filter paramFilter;
		paramFilter = new Filter();
		paramFilter.setElement("lang");
		paramFilter.setOp(Operator.eq);
		paramFilter.setValue(userLang);
		filters.add(paramFilter);

		if (filter.getId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("id");
			paramFilter.setOp(Operator.like);
			paramFilter.setValue(filter.getId() + "%");
			filters.add(paramFilter);
		}
		if (filter.getInstId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("instId");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(filter.getInstId().toString());
			filters.add(paramFilter);
		}
		if (filter.getName() != null && !filter.getName().trim().isEmpty()){
			paramFilter = new Filter(
					"name",
					filter.getName().trim().replaceAll("[*]", "%")
					.replaceAll("[?]", "_").toUpperCase()
					);
			filters.add(paramFilter);
		}
	}

	public void add() {
		newMatchCondition = new MatchCondition();
		newMatchCondition.setLang(userLang);
		curLang = newMatchCondition.getLang();
		curMode = NEW_MODE;
	}

	public void edit() {
		try {
			newMatchCondition = (MatchCondition) detailMatchCondition.clone();
		} catch (CloneNotSupportedException e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
			newMatchCondition = _activeMatchCondition;
		}
		curMode = EDIT_MODE;
	}

	public void delete() {
		try {
			_operationsDao.removeMatchCondition(userSessionId, _activeMatchCondition);
			String msg = FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Opr",
					"match_condition_deleted", "(id = " + _activeMatchCondition.getId() + ")");

			_activeMatchCondition = _itemSelection.removeObjectFromList(_activeMatchCondition);
			if (_activeMatchCondition == null) {
				clearBean();
			} else {
				setBeans();
				detailMatchCondition = (MatchCondition) _activeMatchCondition.clone();
			}

			FacesUtils.addMessageInfo(msg);
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void save() {
		try {
			if (isNewMode()) {
				newMatchCondition = _operationsDao.addMatchCondition(userSessionId,
						newMatchCondition);
				detailMatchCondition = (MatchCondition) newMatchCondition.clone();
				_itemSelection.addNewObjectToList(newMatchCondition);
			} else {
				newMatchCondition = _operationsDao.modifyMatchCondition(userSessionId,
						newMatchCondition);
				detailMatchCondition = (MatchCondition) newMatchCondition.clone();
				if (!userLang.equals(newMatchCondition.getLang())) {
					newMatchCondition = getNodeByLang(_activeMatchCondition.getId(), userLang);
				}
				_matchConditionsSource.replaceObject(_activeMatchCondition, newMatchCondition);
			}
			_activeMatchCondition = newMatchCondition;
			setBeans();
			curMode = VIEW_MODE;

			FacesUtils.addMessageInfo(FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Opr",
					"match_condition_saved"));
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void cancel() {
		curMode = VIEW_MODE;
	}

	public MatchCondition getFilter() {
		if (filter == null) {
			filter = new MatchCondition();
			filter.setInstId(userInstId);
		}
		return filter;
	}

	public void setFilter(MatchCondition filter) {
		this.filter = filter;
	}

	public MatchCondition getNewMatchCondition() {
		if (newMatchCondition == null) {
			newMatchCondition = new MatchCondition();
		}
		return newMatchCondition;
	}

	public void setNewMatchCondition(MatchCondition newMatchCondition) {
		this.newMatchCondition = newMatchCondition;
	}

	public void clearBean() {
		_matchConditionsSource.flushCache();
		_itemSelection.clearSelection();
		_activeMatchCondition = null;
		detailMatchCondition = null;
		// clear dependent bean 
//		connectivityBean = (MbConnectivity) ManagedBeanWrapper.getManagedBean("MbConnectivity");
//		connectivityBean.clearBean();
	}

	public void changeLanguage(ValueChangeEvent event) {
		if (_activeMatchCondition != null) {
			curLang = (String) event.getNewValue();
			detailMatchCondition = getNodeByLang(detailMatchCondition.getId(), curLang);
		}
	}

	public MatchCondition getNodeByLang(Integer id, String lang) {
		List<Filter> filtersList = new ArrayList<Filter>();

		Filter paramFilter = new Filter();
		paramFilter.setElement("id");
		paramFilter.setOp(Operator.eq);
		paramFilter.setValue(id.toString());
		filtersList.add(paramFilter);

		paramFilter = new Filter();
		paramFilter.setElement("lang");
		paramFilter.setOp(Operator.eq);
		paramFilter.setValue(lang);
		filtersList.add(paramFilter);

		filters = filtersList;
		SelectionParams params = new SelectionParams();
		params.setFilters(filters.toArray(new Filter[filters.size()]));
		try {
			MatchCondition[] items = _operationsDao.getMatchConditions(userSessionId, params);
			if (items != null && items.length > 0) {
				return items[0];
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
		return null;
	}
	
	public ArrayList<SelectItem> getInstitutions() {
		if (institutions == null) {
			institutions = (ArrayList<SelectItem>) getDictUtils().getLov(LovConstants.INSTITUTIONS_SYS);
		}
		if (institutions == null)
			institutions = new ArrayList<SelectItem>();
		return institutions;
	}
	
	public void confirmEditLanguage() {
		curLang = newMatchCondition.getLang();
		MatchCondition tmp = getNodeByLang(newMatchCondition.getId(), newMatchCondition.getLang());
		if (tmp != null) {
			newMatchCondition.setName(tmp.getName());
		}
	}

	public String getComponentId() {
		return COMPONENT_ID;
	}

	public Logger getLogger() {
		return logger;
	}

	public MatchCondition getDetailMatchCondition() {
		return detailMatchCondition;
	}

	public void setDetailMatchCondition(MatchCondition detailMatchCondition) {
		this.detailMatchCondition = detailMatchCondition;
	}

}
