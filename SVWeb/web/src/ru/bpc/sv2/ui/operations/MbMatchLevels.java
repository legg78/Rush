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
import ru.bpc.sv2.constants.SectionIdConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.Filter.Operator;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.OperationDao;
import ru.bpc.sv2.operations.MatchLevel;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.TableRowSelection;
import util.auxil.ManagedBeanWrapper;

@ViewScoped
@ManagedBean (name = "MbMatchLevels")
public class MbMatchLevels extends AbstractBean {
	private static final Logger logger = Logger.getLogger("OPER_PROCESSING");

	private static String COMPONENT_ID = "1434:matchLevelsTable";

	private OperationDao _operationsDao = new OperationDao();

	

	private MatchLevel filter;
	private MatchLevel newMatchLevel;
	private MatchLevel detailMatchLevel;
	private ArrayList<SelectItem> institutions;
	private MbMatchLevelConditions relationBean;

	private final DaoDataModel<MatchLevel> _matchLevelsSource;
	private final TableRowSelection<MatchLevel> _itemSelection;
	private MatchLevel _activeMatchLevel;
	
	private String tabName;

	public MbMatchLevels() {
		pageLink = "operations|match|levels";
		tabName = "detailsTab";
		relationBean = (MbMatchLevelConditions) ManagedBeanWrapper
				.getManagedBean("MbMatchLevelConditions");

		_matchLevelsSource = new DaoDataModel<MatchLevel>() {
			@Override
			protected MatchLevel[] loadDaoData(SelectionParams params) {
				if (!searching) {
					return new MatchLevel[0];
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _operationsDao.getMatchLevels(userSessionId, params);
				} catch (Exception e) {
					setDataSize(0);
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return new MatchLevel[0];
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (!searching) {
					return 0;
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _operationsDao.getMatchLevelsCount(userSessionId, params);
				} catch (Exception e) {
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return 0;
			}
		};

		_itemSelection = new TableRowSelection<MatchLevel>(null, _matchLevelsSource);
	}

	public DaoDataModel<MatchLevel> getMatchLevels() {
		return _matchLevelsSource;
	}

	public MatchLevel getActiveMatchLevel() {
		return _activeMatchLevel;
	}

	public void setActiveMatchLevel(MatchLevel activeMatchLevel) {
		_activeMatchLevel = activeMatchLevel;
	}

	public SimpleSelection getItemSelection() {
		try {
			if (_activeMatchLevel == null && _matchLevelsSource.getRowCount() > 0) {
				setFirstRowActive();
			} else if (_activeMatchLevel != null && _matchLevelsSource.getRowCount() > 0) {
				SimpleSelection selection = new SimpleSelection();
				selection.addKey(_activeMatchLevel.getModelId());
				_itemSelection.setWrappedSelection(selection);
				_activeMatchLevel = _itemSelection.getSingleSelection();
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
					&& !_itemSelection.getSingleSelection().getId().equals(_activeMatchLevel.getId())) {
				changeSelect = true;
			}
			_activeMatchLevel = _itemSelection.getSingleSelection();
	
			if (_activeMatchLevel != null) {
				setBeans();
				if (changeSelect) {
					detailMatchLevel = (MatchLevel) _activeMatchLevel.clone();
				}
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void setFirstRowActive() throws CloneNotSupportedException {
		_matchLevelsSource.setRowIndex(0);
		SimpleSelection selection = new SimpleSelection();
		_activeMatchLevel = (MatchLevel) _matchLevelsSource.getRowData();
		detailMatchLevel = (MatchLevel) _activeMatchLevel.clone();
		selection.addKey(_activeMatchLevel.getModelId());
		_itemSelection.setWrappedSelection(selection);

		setBeans();
	}

	/**
	 * Sets data for backing beans used by dependent pages
	 */
	public void setBeans() {
		relationBean.setLevelId(_activeMatchLevel.getId());
		relationBean.setInstId(_activeMatchLevel.getInstId());
		relationBean.search();
	}

	/**
	 * Clears data of backing beans used by dependent pages
	 */
	public void clearBeans() {
		relationBean.setLevelId(null);
		relationBean.setInstId(null);
		relationBean.clearBean();
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
		newMatchLevel = new MatchLevel();
		newMatchLevel.setLang(userLang);
		curLang = newMatchLevel.getLang();
		newMatchLevel.setInstId(filter.getInstId());
		curMode = NEW_MODE;
	}

	public void edit() {
		try {
			newMatchLevel = (MatchLevel) detailMatchLevel.clone();
		} catch (CloneNotSupportedException e) {
			logger.error("", e);
			FacesUtils.addMessageError(e);
			newMatchLevel = _activeMatchLevel;
		}
		curMode = EDIT_MODE;
	}

	public void delete() {
		try {
			_operationsDao.removeMatchLevel(userSessionId, _activeMatchLevel);
			String msg = FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Opr", "match_level_deleted",
					"(id = " + _activeMatchLevel.getId() + ")");

			_activeMatchLevel = _itemSelection.removeObjectFromList(_activeMatchLevel);
			if (_activeMatchLevel == null) {
				clearBean();
			} else {
				setBeans();
				detailMatchLevel = (MatchLevel) _activeMatchLevel.clone();
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
				newMatchLevel = _operationsDao.addMatchLevel(userSessionId, newMatchLevel);
				detailMatchLevel = (MatchLevel) newMatchLevel.clone();
				_itemSelection.addNewObjectToList(newMatchLevel);
			} else {
				newMatchLevel = _operationsDao.modifyMatchLevel(userSessionId, newMatchLevel);
				detailMatchLevel = (MatchLevel) newMatchLevel.clone();
				if (!userLang.equals(newMatchLevel.getLang())) {
					newMatchLevel = getNodeByLang(_activeMatchLevel.getId(), userLang);
				}
				_matchLevelsSource.replaceObject(_activeMatchLevel, newMatchLevel);
			}
			_activeMatchLevel = newMatchLevel;
			setBeans();
			curMode = VIEW_MODE;

			FacesUtils.addMessageInfo(FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Opr",
					"match_level_saved"));
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void cancel() {
		curMode = VIEW_MODE;
	}

	public MatchLevel getFilter() {
		if (filter == null) {
			filter = new MatchLevel();
			filter.setInstId(userInstId);
		}
		return filter;
	}

	public void setFilter(MatchLevel filter) {
		this.filter = filter;
	}

	public MatchLevel getNewMatchLevel() {
		if (newMatchLevel == null) {
			newMatchLevel = new MatchLevel();
		}
		return newMatchLevel;
	}

	public void setNewMatchLevel(MatchLevel newMatchLevel) {
		this.newMatchLevel = newMatchLevel;
	}

	public void clearBean() {
		_matchLevelsSource.flushCache();
		_itemSelection.clearSelection();
		_activeMatchLevel = null;
		detailMatchLevel = null;
		clearBeans();
	}

	public void changeLanguage(ValueChangeEvent event) {
		if (_activeMatchLevel != null) {
			curLang = (String) event.getNewValue();
			detailMatchLevel = getNodeByLang(detailMatchLevel.getId(), curLang);
		}
	}
	
	public MatchLevel getNodeByLang(Integer id, String lang) {
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
			MatchLevel[] items = _operationsDao.getMatchLevels(userSessionId, params);
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
		curLang = newMatchLevel.getLang();
		MatchLevel tmp = getNodeByLang(newMatchLevel.getId(), newMatchLevel.getLang());
		if (tmp != null) {
			newMatchLevel.setName(tmp.getName());
		}
	}

	public String getComponentId() {
		return COMPONENT_ID;
	}

	public Logger getLogger() {
		return logger;
	}

	public MatchLevel getDetailMatchLevel() {
		return detailMatchLevel;
	}

	public void setDetailMatchLevel(MatchLevel detailMatchLevel) {
		this.detailMatchLevel = detailMatchLevel;
	}

	public String getTabName() {
		return tabName;
	}

	public void setTabName(String tabName) {
		this.tabName = tabName;
		
		if (tabName.equalsIgnoreCase("conditionTab")) {
			MbMatchLevelConditions bean = (MbMatchLevelConditions) ManagedBeanWrapper
					.getManagedBean("MbMatchLevelConditions");
			bean.setTabName(tabName);
			bean.setParentSectionId(getSectionId());
			bean.setTableState(getSateFromDB(bean.getComponentId()));
		}
	}
	
	public String getSectionId() {
		return SectionIdConstants.OPERATION_MATCHING_LEVEL;
	}
}
