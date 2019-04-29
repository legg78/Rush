package ru.bpc.sv2.ui.fcl.cycles;

import java.util.ArrayList;
import java.util.List;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.event.ValueChangeEvent;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;

import ru.bpc.sv2.common.Dictionary;
import ru.bpc.sv2.constants.DictNames;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.Filter.Operator;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.CommonDao;
import ru.bpc.sv2.logic.CyclesDao;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.TableRowSelection;

@ViewScoped
@ManagedBean(name = "MbCycleTypes")
@Deprecated
public class MbCycleTypes extends AbstractBean {
	private static final Logger logger = Logger.getLogger("FCL");

	private static String COMPONENT_ID = "1051:mainTable";

	private CyclesDao _cyclesDao = new CyclesDao();

	private CommonDao _commonDao = new CommonDao();

	private Dictionary _activeCycleType;
	private Dictionary newCycleType;
	

	private final DaoDataModel<Dictionary> _cycleTypesSource;

	private final TableRowSelection<Dictionary> _itemSelection;

	private Dictionary filter;

	private String backLink;
	private boolean selectMode;

	public MbCycleTypes() {
		pageLink = "fcl|cycles|list_cycle_types";
		_cycleTypesSource = new DaoDataModel<Dictionary>() {
			@Override
			protected Dictionary[] loadDaoData(SelectionParams params) {
				if (!searching)
					return new Dictionary[0];
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _commonDao.getArticles(userSessionId, params);
				} catch (Exception e) {
					setDataSize(0);
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return new Dictionary[0];
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (!searching)
					return 0;
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _commonDao.getArticlesCount(userSessionId, params);
				} catch (Exception e) {
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return 0;
			}
		};

		_itemSelection = new TableRowSelection<Dictionary>(null, _cycleTypesSource);
	}

	public DaoDataModel<Dictionary> getCycleTypes() {
		return _cycleTypesSource;
	}

	public Dictionary getActiveCycleType() {
		return _activeCycleType;
	}

	public void setActiveCycleType(Dictionary activeCycleType) {
		_activeCycleType = activeCycleType;
	}

	public SimpleSelection getItemSelection() {
		if (_activeCycleType == null && _cycleTypesSource.getRowCount() > 0) {
			setFirstRowActive();
		} else if (_activeCycleType != null && _cycleTypesSource.getRowCount() > 0) {
			SimpleSelection selection = new SimpleSelection();
			selection.addKey(_activeCycleType.getModelId());
			_itemSelection.setWrappedSelection(selection);
			_activeCycleType = _itemSelection.getSingleSelection();
		}
		return _itemSelection.getWrappedSelection();
	}

	public void setFirstRowActive() {
		_cycleTypesSource.setRowIndex(0);
		SimpleSelection selection = new SimpleSelection();
		_activeCycleType = (Dictionary) _cycleTypesSource.getRowData();
		selection.addKey(_activeCycleType.getModelId());
		_itemSelection.setWrappedSelection(selection);
	}

	public void setItemSelection(SimpleSelection selection) {
		_itemSelection.setWrappedSelection(selection);
		_activeCycleType = _itemSelection.getSingleSelection();
	}

	public String cancel() {
		_activeCycleType = null;
		return "cancel";
	}

	public void search() {
		clearState();
		setSearching(true);
	}

	public void setFilters() {
		filter = getFilter();
		Filter paramFilter = null;
		filters = new ArrayList<Filter>();
		if (filter.getId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("id");
			paramFilter.setOp(Operator.like);
			paramFilter.setValue(filter.getId() + "%");
			filters.add(paramFilter);
		}

		paramFilter = new Filter();
		paramFilter.setElement("lang");
		paramFilter.setOp(Operator.eq);
		paramFilter.setValue(userLang);
		filters.add(paramFilter);

		if (filter.getCode() != null && !getFilter().getCode().equals("")) {
			paramFilter = new Filter();
			paramFilter.setElement("code");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(getFilter().getCode());
			filters.add(paramFilter);
		}

		if (filter.getDescription() != null && filter.getDescription().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("description");
			paramFilter.setOp(Operator.like);
			paramFilter.setValue(filter.getDescription().trim().replaceAll("[*]", "%").replaceAll(
					"[?]", "_").toUpperCase());
			filters.add(paramFilter);
		}
		if (filter.getName() != null && filter.getName().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("name");
			paramFilter.setOp(Operator.like);
			paramFilter.setValue(filter.getName().trim().replaceAll("[*]", "%").replaceAll("[?]",
					"_").toUpperCase());
			filters.add(paramFilter);
		}

		paramFilter = new Filter();
		paramFilter.setElement("dict");
		paramFilter.setOp(Operator.eq);
		paramFilter.setValue(DictNames.CYCLE_TYPES);
		filters.add(paramFilter);
	}

	public Dictionary getFilter() {
		if (filter == null)
			filter = new Dictionary();
		return filter;
	}

	public void setFilter(Dictionary filter) {
		this.filter = filter;
	}

	public void add() {
		newCycleType = new Dictionary();
		newCycleType.setDict(DictNames.CYCLE_TYPES);
		newCycleType.setLang(userLang);
		curMode = NEW_MODE;
	}

	public void edit() {
		newCycleType = (Dictionary) _activeCycleType.clone();
		curMode = EDIT_MODE;
	}

	public void save() {
		try {
			if (isNewMode()) {
				newCycleType = _cyclesDao.createCycleType(userSessionId, newCycleType);
				_itemSelection.addNewObjectToList(newCycleType);
			} else if (isEditMode()) {
				_cyclesDao.updateCycleType(userSessionId, newCycleType);
				_cycleTypesSource.replaceObject(_activeCycleType, newCycleType);
			}
			getDictUtils().flush();
			_activeCycleType = newCycleType;
			curMode = VIEW_MODE;
			
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void delete() {
		try {
			_cyclesDao.deleteCycleType(userSessionId, _activeCycleType);
			
			_activeCycleType = _itemSelection.removeObjectFromList(_activeCycleType);
			if (_activeCycleType == null) {
				clearState();
			}
			curMode = VIEW_MODE;
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void close() {
		curMode = VIEW_MODE;
	}

	public void clearFilter() {
		filter = new Dictionary();
		searching = false;
		clearState();
	}
	
	public void clearState() {
		_itemSelection.clearSelection();
		_activeCycleType = null;
		_cycleTypesSource.flushCache();
	}

	public String getBackLink() {
		return backLink;
	}

	public void setBackLink(String backLink) {
		this.backLink = backLink;
	}

	public boolean isSelectMode() {
		return selectMode;
	}

	public void setSelectMode(boolean selectMode) {
		this.selectMode = selectMode;
	}

	public void changeLanguage(ValueChangeEvent event) {
		curLang = (String) event.getNewValue();

		List<Filter> filtersList = new ArrayList<Filter>();

		Filter paramFilter = new Filter();
		paramFilter.setElement("id");
		paramFilter.setOp(Operator.eq);
		paramFilter.setValue(_activeCycleType.getId().toString());
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
			Dictionary[] cycleTypes = _commonDao.getArticles(userSessionId, params);
			if (cycleTypes != null && cycleTypes.length > 0) {
				_activeCycleType = cycleTypes[0];
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public String select() {
		try {
			// List<ModParam> selectedParams =
			// _itemSelection.getMultiSelection();
			// for (ModParam param : selectedParams) {
			// int scaleSeqNum = _rulesDao.includeParamInScale( userSessionId,
			// param.getId(), modScale.getId(), modScale.getSeqNum());
			// }
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
		return backLink;
	}

	public String cancelSelect() {
		return backLink;
	}

	public Dictionary getNewCycleType() {
		if (newCycleType == null) {
			newCycleType = new Dictionary();
			newCycleType.setDict(DictNames.CYCLE_TYPES);
		}
		return newCycleType;
	}

	public void setNewCycleType(Dictionary newCycleType) {
		this.newCycleType = newCycleType;
	}

	public String getComponentId() {
		return COMPONENT_ID;
	}

	public Logger getLogger() {
		return logger;
	}

}
