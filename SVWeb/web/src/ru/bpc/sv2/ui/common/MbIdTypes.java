package ru.bpc.sv2.ui.common;

import java.util.ArrayList;
import java.util.List;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.event.ValueChangeEvent;
import javax.faces.model.SelectItem;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;

import ru.bpc.sv2.common.IdType;
import ru.bpc.sv2.constants.DictNames;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.Filter.Operator;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.CommonDao;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.TableRowSelection;

@ViewScoped
@ManagedBean (name = "MbIdTypes")
public class MbIdTypes extends AbstractBean {
	private static final Logger logger = Logger.getLogger("COMMON");

	private static String COMPONENT_ID = "1781:idTypesTable";

	private CommonDao _commonDao = new CommonDao();

	

	private IdType filter;
	private IdType _activeIdType;
	private IdType newIdType;

	private ArrayList<SelectItem> institutions;

	private final DaoDataModel<IdType> _idTypesSource;

	private final TableRowSelection<IdType> _itemSelection;

	public MbIdTypes() {
		
		pageLink = "common|idTypes";
		_idTypesSource = new DaoDataModel<IdType>() {
			@Override
			protected IdType[] loadDaoData(SelectionParams params) {
				if (!searching) {
					return new IdType[0];
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _commonDao.getIdTypes(userSessionId, params);
				} catch (Exception e) {
					setDataSize(0);
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return new IdType[0];
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (!searching) {
					return 0;
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _commonDao.getIdTypesCount(userSessionId, params);
				} catch (Exception e) {
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return 0;
			}
		};

		_itemSelection = new TableRowSelection<IdType>(null, _idTypesSource);
	}

	public DaoDataModel<IdType> getIdTypes() {
		return _idTypesSource;
	}

	public IdType getActiveIdType() {
		return _activeIdType;
	}

	public void setActiveIdType(IdType activeIdType) {
		_activeIdType = activeIdType;
	}

	public SimpleSelection getItemSelection() {
		try {
			if (_activeIdType == null && _idTypesSource.getRowCount() > 0) {
				setFirstRowActive();
			} else if (_activeIdType != null && _idTypesSource.getRowCount() > 0) {
				SimpleSelection selection = new SimpleSelection();
				selection.addKey(_activeIdType.getModelId());
				_itemSelection.setWrappedSelection(selection);
				_activeIdType = _itemSelection.getSingleSelection();
				setBeans();
			}
		} catch (Exception e) {
			logger.error("", e);
			FacesUtils.addMessageError(e);
		}
		return _itemSelection.getWrappedSelection();
	}

	public void setFirstRowActive() {
		_idTypesSource.setRowIndex(0);
		SimpleSelection selection = new SimpleSelection();
		_activeIdType = (IdType) _idTypesSource.getRowData();
		selection.addKey(_activeIdType.getModelId());
		_itemSelection.setWrappedSelection(selection);

		setBeans();
	}

	public void setItemSelection(SimpleSelection selection) {
		_itemSelection.setWrappedSelection(selection);
		_activeIdType = _itemSelection.getSingleSelection();
		if (_activeIdType != null) {
			setBeans();
		}
	}

	public void search() {
		clearState();
		searching = true;
	}

	public void setBeans() {

	}

	public void clearBeansStates() {

	}

	public void clearFilter() {
		filter = null;

		clearState();
		searching = false;
	}

	public IdType getFilter() {
		if (filter == null) {
			filter = new IdType();
			filter.setInstId(userInstId);
		}
		return filter;
	}

	public void setFilter(IdType filter) {
		this.filter = filter;
	}

	private void setFilters() {
		getFilter();
		filters = new ArrayList<Filter>();

		Filter paramFilter = new Filter();
		paramFilter.setElement("lang");
		paramFilter.setValue(userLang);
		filters.add(paramFilter);

		if (filter.getId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("id");
			paramFilter.setValue(filter.getId());
			filters.add(paramFilter);
		}
		if (filter.getEntityType() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("entityType");
			paramFilter.setValue(filter.getEntityType());
			filters.add(paramFilter);
		}
		if (filter.getIdType() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("idType");
			paramFilter.setValue(filter.getIdType());
			filters.add(paramFilter);
		}
		if (filter.getInstId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("instId");
			paramFilter.setValue(filter.getInstId());
			filters.add(paramFilter);
		}
	}

	public void add() {
		newIdType = new IdType();
		newIdType.setLang(userLang);
		curMode = NEW_MODE;
	}

	public void edit() {
		try {
			newIdType = (IdType) _activeIdType.clone();
		} catch (CloneNotSupportedException e) {
			logger.error("", e);
			newIdType = _activeIdType;
		}
		curMode = EDIT_MODE;
	}

	public void save() {
		try {
			if (isNewMode()) {
				newIdType = _commonDao.addIdType(userSessionId, newIdType);
				_itemSelection.addNewObjectToList(newIdType);
			} else if (isEditMode()) {
				newIdType = _commonDao.modifyIdType(userSessionId, newIdType);
				_idTypesSource.replaceObject(_activeIdType, newIdType);
			}
			_activeIdType = newIdType;
			setBeans();
			curMode = VIEW_MODE;
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void delete() {
		try {
			_commonDao.removeIdType(userSessionId, _activeIdType);
			_activeIdType = _itemSelection.removeObjectFromList(_activeIdType);

			if (_activeIdType == null) {
				clearState();
			} else {
				setBeans();
			}

			curMode = VIEW_MODE;
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void cancel() {
		curMode = VIEW_MODE;
	}

	public IdType getNewIdType() {
		if (newIdType == null) {
			newIdType = new IdType();
		}
		return newIdType;
	}

	public void setNewIdType(IdType newIdType) {
		this.newIdType = newIdType;
	}

	public void clearState() {
		_itemSelection.clearSelection();
		_activeIdType = null;
		_idTypesSource.flushCache();

		clearBeansStates();
	}

	public void changeLanguage(ValueChangeEvent checkGroup) {
		curLang = (String) checkGroup.getNewValue();

		List<Filter> filtersList = new ArrayList<Filter>();

		Filter paramFilter = new Filter();
		paramFilter.setElement("id");
		paramFilter.setOp(Operator.eq);
		paramFilter.setValue(_activeIdType.getId().toString());
		filtersList.add(paramFilter);

		paramFilter = new Filter();
		paramFilter.setElement("lang");
		paramFilter.setOp(Operator.eq);
		paramFilter.setValue(curLang);
		filtersList.add(paramFilter);

		SelectionParams params = new SelectionParams();
		params.setFilters(filtersList.toArray(new Filter[filtersList.size()]));
		try {
			IdType[] checkGroups = _commonDao.getIdTypes(userSessionId, params);
			if (checkGroups != null && checkGroups.length > 0) {
				_activeIdType = checkGroups[0];
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

	public List<SelectItem> getEntityTypes() {
		return getDictUtils().getLov(LovConstants.CUSTOMER_TYPES);
	}

	public ArrayList<SelectItem> getIdTypesList() {
		return getDictUtils().getArticles(DictNames.ID_TYPES, true);
	}

	public String getComponentId() {
		return COMPONENT_ID;
	}

	public Logger getLogger() {
		return logger;
	}

}
