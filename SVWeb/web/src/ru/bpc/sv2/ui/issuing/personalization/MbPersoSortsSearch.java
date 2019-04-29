package ru.bpc.sv2.ui.issuing.personalization;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.event.ValueChangeEvent;
import javax.faces.model.SelectItem;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;

import ru.bpc.sv2.conditions.SqlOrderingFormatter;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.Filter.Operator;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.issuing.personalization.PrsSort;
import ru.bpc.sv2.logic.PersonalizationDao;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.TableRowSelection;

@ViewScoped
@ManagedBean (name = "MbPersoSortsSearch")
public class MbPersoSortsSearch extends AbstractBean {

	private static final Logger logger = Logger.getLogger("PERSONALIZATION");

	private static String COMPONENT_ID = "2266:sortTable";

	private PersonalizationDao _personalizationDao = new PersonalizationDao();

	

	private PrsSort filter;
	private PrsSort _activeSort;
	private PrsSort newSort;

	private ArrayList<SelectItem> institutions;

	private final DaoDataModel<PrsSort> _sortsSource;

	private final TableRowSelection<PrsSort> _itemSelection;

	private String oldLang;

	private SqlOrderingFormatter conditionFormatter;
	private String selectedParam;
	private Map<String, String> paramsMap;
	private List<SelectItem> params;

	public MbPersoSortsSearch() {
		pageLink = "issuing|perso|sorting";
		_sortsSource = new DaoDataModel<PrsSort>() {
			@Override
			protected PrsSort[] loadDaoData(SelectionParams params) {
				if (!searching) {
					return new PrsSort[0];
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _personalizationDao.getSorts(userSessionId, params);
				} catch (Exception e) {
					setDataSize(0);
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return new PrsSort[0];
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (!searching) {
					return 0;
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _personalizationDao.getSortsCount(userSessionId, params);
				} catch (Exception e) {
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return 0;
			}
		};

		_itemSelection = new TableRowSelection<PrsSort>(null, _sortsSource);
	}

	public DaoDataModel<PrsSort> getSorts() {
		return _sortsSource;
	}

	public PrsSort getActiveSort() {
		return _activeSort;
	}

	public void setActiveSort(PrsSort activeSort) {
		_activeSort = activeSort;
	}

	public SimpleSelection getItemSelection() {
		try {
			if (_activeSort == null && _sortsSource.getRowCount() > 0) {
				setFirstRowActive();
			} else if (_activeSort != null && _sortsSource.getRowCount() > 0) {
				SimpleSelection selection = new SimpleSelection();
				selection.addKey(_activeSort.getModelId());
				_itemSelection.setWrappedSelection(selection);
				_activeSort = _itemSelection.getSingleSelection();
			}
		} catch (Exception e) {
			logger.error("", e);
			FacesUtils.addMessageError(e);
		}
		return _itemSelection.getWrappedSelection();
	}

	public void setFirstRowActive() {
		_sortsSource.setRowIndex(0);
		SimpleSelection selection = new SimpleSelection();
		_activeSort = (PrsSort) _sortsSource.getRowData();
		selection.addKey(_activeSort.getModelId());
		_itemSelection.setWrappedSelection(selection);
		if (_activeSort != null) {
			setInfo();
		}
	}

	public void setItemSelection(SimpleSelection selection) {
		_itemSelection.setWrappedSelection(selection);
		_activeSort = _itemSelection.getSingleSelection();
		if (_activeSort != null) {
			setInfo();
		}
	}

	public void setInfo() {

	}

	public void search() {
		clearState();
		clearBeansStates();
		searching = true;
	}

	public void clearFilter() {
		filter = null;
		clearState();
		clearSectionFilter();
		searching = false;
	}

	public PrsSort getFilter() {
		if (filter == null) {
			filter = new PrsSort();
			filter.setInstId(userInstId);
		}
		return filter;
	}

	public void setFilter(PrsSort filter) {
		this.filter = filter;
	}

	private void setFilters() {
		filter = getFilter();
		filters = new ArrayList<Filter>();

		Filter paramFilter;
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
		paramFilter.setValue(curLang);
		filters.add(paramFilter);

		if (filter.getInstId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("instId");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(filter.getInstId().toString());
			filters.add(paramFilter);
		}

		if (filter.getLabel() != null
		        && filter.getLabel().trim().length() > 0)
		{
			paramFilter = new Filter();
			paramFilter.setElement("label");
			paramFilter.setOp(Operator.like);
			paramFilter.setValue(filter.getLabel().trim().toUpperCase()
			        .replaceAll("[*]", "%").replaceAll("[?]", "_"));
			filters.add(paramFilter);
		}
		if (filter.getCondition() != null
		        && filter.getCondition().trim().length() > 0)
		{
			paramFilter = new Filter();
			paramFilter.setElement("condition");
			paramFilter.setOp(Operator.like);
			paramFilter.setValue(filter.getCondition().trim().toUpperCase()
			        .replaceAll("[*]", "%").replaceAll("[?]", "_"));
			filters.add(paramFilter);
		}
	}

	public void add() {
		newSort = new PrsSort();
		newSort.setLang(userLang);
		curMode = NEW_MODE;

		selectedParam = "";
		conditionFormatter = null;
		getConditionFormatter();
	}

	public void edit() {
		try {
			newSort = (PrsSort) _activeSort.clone();
		} catch (CloneNotSupportedException e) {
			logger.error("", e);
			newSort = _activeSort;
		}
		curMode = EDIT_MODE;
	}

	public void view() {

	}

	public void save() {
		try {
			if (isNewMode()) {
				newSort = _personalizationDao.addSort(userSessionId, newSort);
				_itemSelection.addNewObjectToList(newSort);
			} else if (isEditMode()) {
				newSort = _personalizationDao.modifySort(userSessionId, newSort);
				_sortsSource.replaceObject(_activeSort, newSort);
			}

			_activeSort = newSort;
			setInfo();
			curMode = VIEW_MODE;
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void delete() {
		try {
			_personalizationDao.deleteSort(userSessionId, _activeSort);
			_activeSort = _itemSelection.removeObjectFromList(_activeSort);
			if (_activeSort == null) {
				clearState();
			} else {
				setInfo();
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

	public PrsSort getNewSort() {
		if (newSort == null) {
			newSort = new PrsSort();
		}
		return newSort;
	}

	public void setNewSort(PrsSort newSort) {
		this.newSort = newSort;
	}

	public void clearState() {
		_itemSelection.clearSelection();
		_activeSort = null;
		_sortsSource.flushCache();
		curLang = userLang;
		clearBeansStates();
	}

	public void clearBeansStates() {
	}

	public void changeLanguage(ValueChangeEvent event) {
		curLang = (String) event.getNewValue();

		List<Filter> filtersList = new ArrayList<Filter>();

		Filter paramFilter = new Filter();
		paramFilter.setElement("id");
		paramFilter.setOp(Operator.eq);
		paramFilter.setValue(_activeSort.getId().toString());
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
			PrsSort[] sorts = _personalizationDao.getSorts(userSessionId, params);
			if (sorts != null && sorts.length > 0) {
				_activeSort = sorts[0];
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public ArrayList<SelectItem> getInstitutions() {
		if (institutions == null) {
			institutions = (ArrayList<SelectItem>) getDictUtils().getLov(LovConstants.INSTITUTIONS_SYS);
		}
		if (institutions == null)
			institutions = new ArrayList<SelectItem>();
		return institutions;
	}

	public void editLanguage(ValueChangeEvent event) {
		oldLang = (String) event.getOldValue();
	}

	public void confirmEditLanguage() {
		Filter[] filters = new Filter[2];
		filters[0] = new Filter();
		filters[0].setElement("id");
		filters[0].setValue(newSort.getId());
		filters[1] = new Filter();
		filters[1].setElement("lang");
		filters[1].setValue(newSort.getLang());

		SelectionParams params = new SelectionParams();
		params.setFilters(filters);
		try {
			PrsSort[] items = _personalizationDao.getSorts(userSessionId, params);
			if (items != null && items.length > 0) {
				newSort.setLabel(items[0].getLabel());
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void cancelEditLanguage() {
		newSort.setLang(oldLang);
	}

	public List<SelectItem> getParameters() {
		if (params == null) {
			params = getDictUtils().getLov(LovConstants.SORTING_PARAMETERS);
			paramsMap = new HashMap<String, String>(params.size());
			for (SelectItem item : params) {
				String[] s = item.getDescription().split("-");
				paramsMap.put(s[0].trim(), s[1].trim());
			}
		}
		return params;
	}

	public SqlOrderingFormatter getConditionFormatter() {
		if (conditionFormatter == null) {
			conditionFormatter = new SqlOrderingFormatter();			
		}
		return conditionFormatter;
	}

	public void setConditionFormatter(SqlOrderingFormatter conditionFormatter) {
		this.conditionFormatter = conditionFormatter;
	}

	public void applyParamToFormatter(ValueChangeEvent event) {
		String modParamId = (String) event.getNewValue();
		if (modParamId != null) {
			selectedParam = modParamId;
			conditionFormatter.setParamName(paramsMap.get(selectedParam));
		} else {
			conditionFormatter.setParamName(null);
		}
	}

	public void addToCondition() {
		if (newSort.getCondition() == null || newSort.getCondition().equals("")) {
			conditionFormatter.setPrependCondition(false);
		} else {
			conditionFormatter.setPrependCondition(true);
		}
		String cond = conditionFormatter.formCondition();
		if (cond != null && cond.length() > 0) {
			newSort.setCondition(newSort.getCondition() + cond);
		}
	}

	public String getSelectedParam() {
		return selectedParam;
	}

	public void setSelectedParam(String selectedParam) {
		this.selectedParam = selectedParam;
	}

	public String getComponentId() {
		return COMPONENT_ID;
	}

	public Logger getLogger() {
		return logger;
	}

}
