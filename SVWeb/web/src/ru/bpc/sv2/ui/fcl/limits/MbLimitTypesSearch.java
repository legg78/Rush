package ru.bpc.sv2.ui.fcl.limits;

import java.util.ArrayList;
import java.util.List;


import ru.bpc.sv2.logic.utility.db.DataAccessException;
import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.event.ValueChangeEvent;
import javax.faces.model.SelectItem;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;

import ru.bpc.sv2.constants.DictNames;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.fcl.limits.LimitType;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.Filter.Operator;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.LimitsDao;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.TableRowSelection;
import util.auxil.ManagedBeanWrapper;

@ViewScoped
@ManagedBean (name = "MbLimitTypesSearch")
public class MbLimitTypesSearch extends AbstractBean {
	private static final Logger logger = Logger.getLogger("FCL");

	private static String COMPONENT_ID = "1055:mainTable";

	private LimitsDao _limitsDao = new LimitsDao();

	private LimitType _activeLimitType;
	private LimitType newLimitType;
	private LimitType filter;

	
	private String backLink;
	private boolean selectMode;

	private final DaoDataModel<LimitType> _limitTypesSource;

	private final TableRowSelection<LimitType> _itemSelection;

	private boolean _managingNew;

	public MbLimitTypesSearch() {
		pageLink = "fcl|limits|list_limit_types";
		_limitTypesSource = new DaoDataModel<LimitType>() {
			@Override
			protected LimitType[] loadDaoData(SelectionParams params) {
				if (!searching) {
					return new LimitType[0];
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _limitsDao.getLimitTypes(userSessionId, params);
				} catch (Exception e) {
					setDataSize(0);
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return new LimitType[0];
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (!searching) {
					return 0;
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _limitsDao.getLimitTypesCount(userSessionId, params);
				} catch (Exception e) {
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return 0;
			}
		};

		_itemSelection = new TableRowSelection<LimitType>(null, _limitTypesSource);
	}

	public DaoDataModel<LimitType> getLimitTypes() {
		return _limitTypesSource;
	}

	public LimitType getActiveLimitType() {
		return _activeLimitType;
	}

	public void setActiveLimitType(LimitType activeLimitType) {
		_activeLimitType = activeLimitType;
	}

	public SimpleSelection getItemSelection() {
		if (_activeLimitType == null && _limitTypesSource.getRowCount() > 0) {
			setFirstRowActive();
		} else if (_activeLimitType != null && _limitTypesSource.getRowCount() > 0) {
			SimpleSelection selection = new SimpleSelection();
			selection.addKey(_activeLimitType.getModelId());
			_itemSelection.setWrappedSelection(selection);
			_activeLimitType = _itemSelection.getSingleSelection();
		}
		return _itemSelection.getWrappedSelection();
	}

	public void setItemSelection(SimpleSelection selection) {
		_itemSelection.setWrappedSelection(selection);
		_activeLimitType = _itemSelection.getSingleSelection();
	}

	public void setFirstRowActive() {
		_limitTypesSource.setRowIndex(0);
		SimpleSelection selection = new SimpleSelection();
		_activeLimitType = (LimitType) _limitTypesSource.getRowData();
		selection.addKey(_activeLimitType.getModelId());
		_itemSelection.setWrappedSelection(selection);
		if (_activeLimitType != null) {

		}
	}

	public void save() {
		try {
			if (isNewMode()) {
				newLimitType.setLimitType("LMTP" + newLimitType.getLimitType());
				newLimitType = _limitsDao.createLimitType(userSessionId, newLimitType);
				_itemSelection.addNewObjectToList(newLimitType);
			} else if (isEditMode()) {
				newLimitType = _limitsDao.updateLimitType(userSessionId, newLimitType);
				_limitTypesSource.replaceObject(_activeLimitType, newLimitType);
			}
			getDictUtils().flush();
			_activeLimitType = newLimitType;
			curMode = VIEW_MODE;
		} catch (Exception ee) {
			FacesUtils.addMessageError(ee);
			logger.error("", ee);
		}
	}

	public void createLimitType() {
		newLimitType = new LimitType();
		newLimitType.setLang(userLang);
		curMode = NEW_MODE;
	}

	public void editLimitType() {
		try {
			newLimitType = _activeLimitType.clone();
		} catch (CloneNotSupportedException e) {
			logger.error("", e);
			newLimitType = new LimitType();
		}
		curMode = EDIT_MODE;
	}

	public void deleteLimitType() {
		try {
			_limitsDao.deleteLimitType(userSessionId, _activeLimitType);
			_activeLimitType = _itemSelection.removeObjectFromList(_activeLimitType);

			if (_activeLimitType == null) {
				clearBean();
			}
			curMode = VIEW_MODE;
		} catch (DataAccessException ee) {
			FacesUtils.addMessageError(ee);
			logger.error("", ee);
		}
	}

	public void clearFilter() {
		filter = new LimitType();
		clearBean();
		searching = false;
	}

	public void search() {
		clearBean();
		searching = true;
	}

	public void setFilters() {
		filters = new ArrayList<Filter>();
		Filter paramFilter = null;
		if (getFilter().getLimitType() != null && !getFilter().getLimitType().equals("")) {
			paramFilter = new Filter();
			paramFilter.setElement("limitType");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(getFilter().getLimitType());
			filters.add(paramFilter);
		}
		if (getFilter().getEntityType() != null && !getFilter().getEntityType().equals("")) {
			paramFilter = new Filter();
			paramFilter.setElement("entityType");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(getFilter().getEntityType());
			filters.add(paramFilter);
		}
		if (getFilter().getCycleType() != null && !getFilter().getCycleType().equals("")) {
			paramFilter = new Filter();
			paramFilter.setElement("cycleType");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(getFilter().getCycleType());
			filters.add(paramFilter);
		}

		paramFilter = new Filter();
		paramFilter.setElement("lang");
		paramFilter.setOp(Operator.eq);
		paramFilter.setValue(userLang);
		filters.add(paramFilter);
	}

	public void clearBean() {
		if (_activeLimitType != null) {
			if (_itemSelection != null) {
				_itemSelection.unselect(_activeLimitType);
			}
			_activeLimitType = null;
		}
		_limitTypesSource.flushCache();
	}

	public boolean isManagingNew() {
		return _managingNew;
	}

	public void setManagingNew(boolean managingNew) {
		_managingNew = managingNew;
	}

	public ArrayList<SelectItem> getLimitTypesDict() {
		return getDictUtils().getArticles(DictNames.LIMIT_TYPES, true, false);
	}

	public ArrayList<SelectItem> getCycleTypes() {
		return getDictUtils().getArticles(DictNames.CYCLE_TYPES, true, false);
	}

	public List<SelectItem> getEntityTypes() {
		return getDictUtils().getLov(LovConstants.ENTITY_TYPES);
	}

	public String cancel() {
		_activeLimitType = null;
		return "cancel";
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

	public LimitType getFilter() {
		if (filter == null)
			filter = new LimitType();
		return filter;
	}

	public void setFilter(LimitType filter) {
		this.filter = filter;
	}

	public String select() {
		MbLimitTypes limitTypesBean = (MbLimitTypes) ManagedBeanWrapper
				.getManagedBean("MbLimitTypes");
		limitTypesBean.setActiveLimitType(_activeLimitType);
		return backLink;
	}

	public String cancelSelect() {
		MbLimitTypes limitTypesBean = (MbLimitTypes) ManagedBeanWrapper
				.getManagedBean("MbLimitTypes");
		limitTypesBean.setActiveLimitType(null);
		return backLink;
	}

	public ArrayList<SelectItem> getLimitTypeItems() {
		return getDictUtils().getArticles(DictNames.LIMIT_TYPES, true, true);
	}

	public LimitType getNewLimitType() {
		return newLimitType;
	}

	public void setNewLimitType(LimitType newLimitType) {
		this.newLimitType = newLimitType;
	}

	public void close() {

	}

	public void changeLanguage(ValueChangeEvent event) {
		curLang = (String) event.getNewValue();

		List<Filter> filtersList = new ArrayList<Filter>();

		Filter paramFilter = new Filter();
		paramFilter.setElement("id");
		paramFilter.setValue(_activeLimitType.getId().toString());
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
			LimitType[] types = _limitsDao.getLimitTypes(userSessionId, params);
			if (types != null && types.length > 0) {
				_activeLimitType = types[0];
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

}
