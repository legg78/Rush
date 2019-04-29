package ru.bpc.sv2.ui.common.arrays;

import java.util.ArrayList;
import java.util.List;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.RequestScoped;
import javax.faces.event.ValueChangeEvent;
import javax.faces.model.SelectItem;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;

import org.ajax4jsf.model.KeepAlive;
import ru.bpc.sv2.common.arrays.Array;
import ru.bpc.sv2.common.arrays.ArrayElement;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.Filter.Operator;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.CommonDao;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.TableRowSelection;

@RequestScoped
@KeepAlive
@ManagedBean (name = "MbArrayElements")
public class MbArrayElements extends AbstractBean {

	private static final Logger logger = Logger.getLogger("COMMON");

	private CommonDao _commonDao = new CommonDao();

	

	private List<Filter> filters;

	private ArrayElement filter;
	private DaoDataModel<ArrayElement> _elementSource;   //was final
	private TableRowSelection<ArrayElement> _itemSelection;    //was final
	private ArrayElement _activeElement;
	private ArrayElement newElement;

	private Array array;
	private String oldLang;
	
	private static String COMPONENT_ID = "elementsTable";
	private String tabName;
	private String parentSectionId;

//--------- my changes ----------


    public TableRowSelection<ArrayElement> get_itemSelection() {
        return _itemSelection;
    }

    public void set_itemSelection(TableRowSelection<ArrayElement> _itemSelection) {
        this._itemSelection = _itemSelection;
    }

    public CommonDao get_commonDao() {
        return _commonDao;
    }

    public void set_commonDao(CommonDao _commonDao) {
        this._commonDao = _commonDao;
    }

    public List<Filter> getFilters() {
        return filters;
    }

    public void setFilters(List<Filter> filters) {
        this.filters = filters;
    }

    public DaoDataModel<ArrayElement> get_elementSource() {
        return _elementSource;
    }

    public void set_elementSource(DaoDataModel<ArrayElement> _elementSource) {
        this._elementSource = _elementSource;
    }

//--------- end my changes ----------


    public MbArrayElements() {

		_elementSource = new DaoDataModel<ArrayElement>() {
			@Override
			protected ArrayElement[] loadDaoData(SelectionParams params) {
				if (array == null || !searching) {
					return new ArrayElement[0];
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _commonDao.getArrayElements(userSessionId, params);
				} catch (Exception e) {
					setDataSize(0);
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return new ArrayElement[0];
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (array == null || !searching) {
					return 0;
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _commonDao.getArrayElementsCount(userSessionId, params);
				} catch (Exception e) {
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return 0;
			}
		};

		_itemSelection = new TableRowSelection<ArrayElement>(null, _elementSource);
	}

	public DaoDataModel<ArrayElement> getElements() {
		return _elementSource;
	}

	public ArrayElement getActiveElement() {
		return _activeElement;
	}

	public void setActiveElement(ArrayElement activeElement) {
		_activeElement = activeElement;
	}

	public SimpleSelection getItemSelection() {
		if (_activeElement == null && _elementSource.getRowCount() > 0) {
			setFirstRowActive();
		} else if (_activeElement != null && _elementSource.getRowCount() > 0) {
			SimpleSelection selection = new SimpleSelection();
			selection.addKey(_activeElement.getModelId());
			_itemSelection.setWrappedSelection(selection);
			_activeElement = _itemSelection.getSingleSelection();
		}
		return _itemSelection.getWrappedSelection();
	}

	public void setItemSelection(SimpleSelection selection) {
		_itemSelection.setWrappedSelection(selection);
		_activeElement = _itemSelection.getSingleSelection();
	}

	public void setFirstRowActive() {
		_elementSource.setRowIndex(0);
		SimpleSelection selection = new SimpleSelection();
		_activeElement = (ArrayElement) _elementSource.getRowData();
		selection.addKey(_activeElement.getModelId());
		_itemSelection.setWrappedSelection(selection);
	}

	public void search() {
		clearBean();
		setSearching(true);
	}

	public void clearFilter() {
		curLang = userLang;
		filter = null;
		searching = false;
		clearBean();
	}

	public ArrayElement getFilter() {
		if (filter == null) {
			filter = new ArrayElement();
		}
		return filter;
	}

	public void setFilter(ArrayElement filter) {
		this.filter = filter;
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

		if (array.getId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("arrayId");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(array.getId());
			filters.add(paramFilter);
		}
		if (filter.getId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("id");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(filter.getId().toString());
			filters.add(paramFilter);
		}
		
		if (filter.getElementNumber() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("elementNumber");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(filter.getElementNumber().toString());
			filters.add(paramFilter);
		}
		if (filter.getName() != null && filter.getName().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("name");
			paramFilter.setOp(Operator.like);
			paramFilter.setValue(filter.getName().trim().toUpperCase()
			        .replaceAll("[*]", "%").replaceAll("[?]", "_"));
			filters.add(paramFilter);
		}
		if (filter.getDescription() != null && filter.getDescription().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("description");
			paramFilter.setOp(Operator.like);
			paramFilter.setValue(filter.getDescription().trim().toUpperCase()
			        .replaceAll("[*]", "%").replaceAll("[?]", "_"));
			filters.add(paramFilter);
		}
	}

	public void add() {
		newElement = new ArrayElement();
		newElement.setLang(userLang);
		newElement.setArrayId(array.getId());
		newElement.setLovId(array.getLovId());
		newElement.setDataType(array.getDataType());
		curMode = NEW_MODE;
	}

	public void edit() {
		try {
			newElement = (ArrayElement) _activeElement.clone();
		} catch (CloneNotSupportedException e) {
			logger.error("", e);
			newElement = _activeElement;
		}
		curMode = EDIT_MODE;
	}

	public void delete() {
		try {
			_commonDao.deleteArrayElement(userSessionId, _activeElement);

			String msg = FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Common", "array_element_deleted",
			        "(id = " + _activeElement.getId() + ")");

			_activeElement = _itemSelection.removeObjectFromList(_activeElement);
			if (_activeElement == null) {
				clearBean();
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
				newElement = _commonDao.addArrayElement(userSessionId, newElement);
				_itemSelection.addNewObjectToList(newElement);
			} else {
				newElement = _commonDao.editArrayElement(userSessionId, newElement);
				_elementSource.replaceObject(_activeElement, newElement);
			}
			_activeElement = newElement;
			curMode = VIEW_MODE;

			FacesUtils.addMessageInfo(FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Common",
			        "array_element_saved"));

		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void close() {
		curMode = VIEW_MODE;
	}

	public void view() {
		curMode = VIEW_MODE;
	}

	public ArrayElement getNewElement() {
		if (newElement == null) {
			newElement = new ArrayElement();
		}
		return newElement;
	}

	public void setNewElement(ArrayElement newElement) {
		this.newElement = newElement;
	}

	public Array getArray() {
		return array;
	}

	public void setArray(Array array) {
		this.array = array;
	}

	public void clearBean() {
		_elementSource.flushCache();
		_itemSelection.clearSelection();
		_activeElement = null;
	}

	public void fullCleanBean() {
		clearBean();
		array = null;
	}

	public void changeLanguage(ValueChangeEvent event) {
		if (_activeElement != null) {
			curLang = (String) event.getNewValue();
			List<Filter> filtersList = new ArrayList<Filter>();

			Filter paramFilter = new Filter();
			paramFilter.setElement("id");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(_activeElement.getId().toString());
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
				ArrayElement[] arrayElements = _commonDao.getArrayElements(userSessionId, params);
				if (arrayElements != null && arrayElements.length > 0) {
					_activeElement = arrayElements[0];
				}
			} catch (Exception e) {
				FacesUtils.addMessageError(e);
				logger.error("", e);
			}
		}
	}

	public void editLanguage(ValueChangeEvent event) {
		oldLang = (String) event.getOldValue();
	}

	public void confirmEditLanguage() {
		Filter[] filters = new Filter[2];
		filters[0] = new Filter();
		filters[0].setElement("id");
		filters[0].setValue(newElement.getId());
		filters[1] = new Filter();
		filters[1].setElement("lang");
		filters[1].setValue(newElement.getLang());

		SelectionParams params = new SelectionParams();
		params.setFilters(filters);
		try {
			ArrayElement[] items = _commonDao.getArrayElements(userSessionId, params);
			if (items != null && items.length > 0) {
				newElement.setName(items[0].getName());
				newElement.setDescription(items[0].getDescription());
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void cancelEditLanguage() {
		newElement.setLang(oldLang);
	}

	public List<SelectItem> getValuesFromLov() {
		return getDictUtils().getLov(newElement.getLovId());
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
