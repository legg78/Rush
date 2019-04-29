package ru.bpc.sv2.ui.common.arrays;

import java.util.ArrayList;
import java.util.List;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.RequestScoped;
import javax.faces.model.SelectItem;

import org.apache.log4j.Logger;
import org.openfaces.util.Faces;
import org.richfaces.model.selection.SimpleSelection;

import org.ajax4jsf.model.KeepAlive;
import ru.bpc.sv2.common.arrays.ArrayConvElement;
import ru.bpc.sv2.common.arrays.ArrayConversion;
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
@ManagedBean (name = "MbArrayConvElems")
public class MbArrayConvElems extends AbstractBean {

	private static final Logger logger = Logger.getLogger("COMMON");

	private CommonDao _commonDao = new CommonDao();

	

	private ArrayConvElement filter;
	private final DaoDataModel<ArrayConvElement> _elementSource;
	private final TableRowSelection<ArrayConvElement> _itemSelection;
	private ArrayConvElement _activeElement;
	private ArrayConvElement newElement;

	private ArrayConversion conversion;
	
	private static String COMPONENT_ID = "elementsTable";
	private String tabName;
	private String parentSectionId;

	public MbArrayConvElems() {
		
		_elementSource = new DaoDataModel<ArrayConvElement>() {
			@Override
			protected ArrayConvElement[] loadDaoData(SelectionParams params) {
				if (conversion == null || !searching) {
					return new ArrayConvElement[0];
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _commonDao.getArrayConvElems(userSessionId, params);
				} catch (Exception e) {
					setDataSize(0);
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return new ArrayConvElement[0];
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (conversion == null || !searching) {
					return 0;
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _commonDao.getArrayConvElemsCount(userSessionId, params);
				} catch (Exception e) {
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return 0;
			}
		};

		_itemSelection = new TableRowSelection<ArrayConvElement>(null, _elementSource);
	}

	public DaoDataModel<ArrayConvElement> getElements() {
		return _elementSource;
	}

	public ArrayConvElement getActiveElement() {
		return _activeElement;
	}

	public void setActiveElement(ArrayConvElement activeElement) {
		_activeElement = activeElement;
	}

	public SimpleSelection getItemSelection() {
		try {
			if (_activeElement == null && _elementSource.getRowCount() > 0) {
				setFirstRowActive();
			} else if (_activeElement != null && _elementSource.getRowCount() > 0) {
				SimpleSelection selection = new SimpleSelection();
				selection.addKey(_activeElement.getModelId());
				_itemSelection.setWrappedSelection(selection);
				_activeElement = _itemSelection.getSingleSelection();
			}
		} catch (Exception e) {
			logger.error("", e);
			FacesUtils.addMessageError(e);
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
		_activeElement = (ArrayConvElement) _elementSource.getRowData();
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

	public ArrayConvElement getFilter() {
		if (filter == null) {
			filter = new ArrayConvElement();
		}
		return filter;
	}

	public void setFilter(ArrayConvElement filter) {
		this.filter = filter;
	}

	public void setFilters() {
		filter = getFilter();

		filters = new ArrayList<Filter>();

		Filter paramFilter;

		paramFilter = new Filter();
		paramFilter.setElement("lang");
		paramFilter.setOp(Operator.eq);
		paramFilter.setValue(curLang);
		filters.add(paramFilter);
		
		if (conversion.getId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("convId");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(conversion.getId());
			filters.add(paramFilter);
		}
		if (filter.getId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("id");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(filter.getId().toString());
			filters.add(paramFilter);
		}
		
		if (filter.getInElementValue() != null && filter.getInElementValue().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("inElementValue");
			paramFilter.setOp(Operator.like);
			paramFilter.setValue(filter.getInElementValue().trim().toUpperCase().replaceAll("[*]",
					"%").replaceAll("[?]", "_"));
			filters.add(paramFilter);
		}
		if (filter.getOutElementValue() != null && filter.getOutElementValue().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("outElementValue");
			paramFilter.setOp(Operator.like);
			paramFilter.setValue(filter.getOutElementValue().trim().toUpperCase().replaceAll("[*]",
					"%").replaceAll("[?]", "_"));
			filters.add(paramFilter);
		}
	}

	public void add() {
		newElement = new ArrayConvElement();
		newElement.setConvId(conversion.getId());
		curMode = NEW_MODE;
	}

	public void edit() {
		try {
			newElement = (ArrayConvElement) _activeElement.clone();
		} catch (CloneNotSupportedException e) {
			logger.error("", e);
			newElement = _activeElement;
		}
		curMode = EDIT_MODE;
	}

	public void delete() {
		try {
			_commonDao.deleteArrayConvElem(userSessionId, _activeElement);

			String msg = FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Common",
					"array_element_deleted", "(id = " + _activeElement.getId() + ")");

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
				newElement = _commonDao.addArrayConvElem(userSessionId, newElement, curLang);
				_itemSelection.addNewObjectToList(newElement);
			} else {
				newElement = _commonDao.editArrayConvElem(userSessionId, newElement, curLang);
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

	public ArrayConvElement getNewElement() {
		if (newElement == null) {
			newElement = new ArrayConvElement();
		}
		return newElement;
	}

	public void setNewElement(ArrayConvElement newElement) {
		this.newElement = newElement;
	}

	public ArrayConversion getConversion() {
		return conversion;
	}

	public void setConversion(ArrayConversion conversion) {
		this.conversion = conversion;
	}

	public void clearBean() {
		_elementSource.flushCache();
		_itemSelection.clearSelection();
		_activeElement = null;
	}

	public void fullCleanBean() {
		clearBean();
		conversion = null;
	}

	public List<SelectItem> getInLov() {
		if (conversion == null || conversion.getInLovId() == null) {
			return new ArrayList<SelectItem>(0);
		}
		return getDictUtils().getLov(conversion.getInLovId());
	}

	public List<SelectItem> getOutLov() {
		if (conversion == null || conversion.getOutLovId() == null) {
			return new ArrayList<SelectItem>(0);
		}
		return getDictUtils().getLov(conversion.getOutLovId());
	}

	private List<SelectItem> getArrayElements(Integer arrayId) {
		Filter[] filters = new Filter[2];
		filters[0] = new Filter();
		filters[0].setElement("lang");
		filters[0].setValue(userLang);
		filters[1] = new Filter();
		filters[1].setElement("arrayId");
		filters[1].setValue(arrayId);

		SelectionParams params = new SelectionParams();
		params.setFilters(filters);
		params.setRowIndexEnd(Integer.MAX_VALUE);
		try {
			ArrayElement[] elems = _commonDao.getArrayElements(userSessionId, params);
			ArrayList<SelectItem> items = new ArrayList<SelectItem>(elems.length);
			for (ArrayElement elem: elems) {
				items.add(new SelectItem(elem.getValue(), elem.getValue() + " - "
						+ elem.getName()));
			}
			return items;
		} catch (Exception e) {
			logger.error("", e);
			FacesUtils.addMessageError(e);
		}
		return new ArrayList<SelectItem>(0);
	}

	public List<SelectItem> getInArray() {
		if (conversion == null || conversion.getInArrayId() == null) {
			return new ArrayList<SelectItem>(0);
		}
		return getArrayElements(conversion.getInArrayId());
	}

	public List<SelectItem> getOutArray() {
		if (conversion == null || conversion.getOutArrayId() == null) {
			return new ArrayList<SelectItem>(0);
		}
		return getArrayElements(conversion.getOutArrayId());
	}
	
	private ArrayConvElement getCurrentItem() {
		return (ArrayConvElement) Faces.var("item");
	}

	public String getInLovValue() {
		ArrayConvElement currentItem = getCurrentItem();

		if ((currentItem != null) && currentItem.getInElementValue() != null) {
			try {
				List<SelectItem> lovs = getDictUtils().getLov(conversion.getInLovId());
				for (SelectItem lov: lovs) {
					// lov.getValue() != null is redundant, i think, but
					// during development such situations are possible, unfortunately.
					if (lov.getValue() != null) {
						if (lov.getValue().equals(currentItem.getInElementValue())) {
							return lov.getLabel();
						}
					}
				}
			} catch (Exception e) {
				logger.error("", e);
			}
		}
		return currentItem.getInElementValue();
	}

	public String getOutLovValue() {
		ArrayConvElement currentItem = getCurrentItem();

		if (currentItem.getOutElementValue() != null) {
			try {
				List<SelectItem> lovs = getDictUtils().getLov(conversion.getOutLovId());
				for (SelectItem lov: lovs) {
					// lov.getValue() != null is redundant, i think, but
					// during development such situations are possible, unfortunately.
					if (lov.getValue() != null) {
						if (lov.getValue().equals(currentItem.getOutElementValue())) {
							return lov.getLabel();
						}
					}
				}
			} catch (Exception e) {
				logger.error("", e);
			}
		}
		return currentItem.getOutElementValue();
	}

	public String getInArrayValue() {
		ArrayConvElement currentItem = getCurrentItem();

		if (currentItem.getInElementValue() != null) {
			try {
				List<SelectItem> elems = getArrayElements(conversion.getInArrayId());
				for (SelectItem elem: elems) {
					if (elem.getValue() != null) {
						if (elem.getValue().equals(currentItem.getInElementValue())) {
							return elem.getLabel();
						}
					}
				}
			} catch (Exception e) {
				logger.error("", e);
			}
		}
		return currentItem.getInElementValue();
	}

	public String getOutArrayValue() {
		ArrayConvElement currentItem = getCurrentItem();

		if (currentItem.getOutElementValue() != null) {
			try {
				List<SelectItem> elems = getArrayElements(conversion.getOutArrayId());
				for (SelectItem elem: elems) {
					if (elem.getValue() != null) {
						if (elem.getValue().equals(currentItem.getOutElementValue())) {
							return elem.getLabel();
						}
					}
				}
			} catch (Exception e) {
				logger.error("", e);
			}
		}
		return currentItem.getOutElementValue();
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
