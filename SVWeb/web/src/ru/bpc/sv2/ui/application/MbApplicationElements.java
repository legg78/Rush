package ru.bpc.sv2.ui.application;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.model.SelectItem;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;

import ru.bpc.sv2.application.AppElement;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.Filter.Operator;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.ApplicationDao;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.TableRowSelection;

@ViewScoped
@ManagedBean (name = "MbApplicationElements")
public class MbApplicationElements extends AbstractBean {

	private static final Logger logger = Logger.getLogger("APPLICATIONS");

	private static String COMPONENT_ID = "2222:elementsTable";

	private ApplicationDao _applicationDao = new ApplicationDao();

	

	private AppElement filter;
	private AppElement newElement;
	private final DaoDataModel<AppElement> _elementSource;
	private final TableRowSelection<AppElement> _itemSelection;
	private AppElement _activeElement;
	private List<SelectItem> dataTypes;

	public MbApplicationElements() {
		pageLink = "applications|elements";
		_elementSource = new DaoDataModel<AppElement>() {
			@Override
			protected AppElement[] loadDaoData(SelectionParams params) {
				if (!searching) {
					return new AppElement[0];
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _applicationDao.getApplicationElements(userSessionId, params);
				} catch (Exception e) {
					setDataSize(0);
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return new AppElement[0];
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (!searching) {
					return 0;
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _applicationDao.getApplicationElementsCount(userSessionId, params);
				} catch (Exception e) {
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return 0;
			}
		};

		_itemSelection = new TableRowSelection<AppElement>(null, _elementSource);
	}

	public DaoDataModel<AppElement> getElements() {
		return _elementSource;
	}

	public AppElement getActiveElement() {
		return _activeElement;
	}

	public void setActiveElementw(AppElement activeElement) {
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
			setBeans();
		}
		return _itemSelection.getWrappedSelection();
	}

	public void setItemSelection(SimpleSelection selection) {
		_itemSelection.setWrappedSelection(selection);
		_activeElement = _itemSelection.getSingleSelection();

		if (_activeElement != null) {
			setBeans();
		}
	}

	public void setFirstRowActive() {
		_elementSource.setRowIndex(0);
		SimpleSelection selection = new SimpleSelection();
		_activeElement = (AppElement) _elementSource.getRowData();
		selection.addKey(_activeElement.getModelId());
		_itemSelection.setWrappedSelection(selection);
		if (_activeElement != null) {
			setBeans();
		}
	}

	public AppElement getNewElement() {
		if (newElement == null) {
			newElement = new AppElement();
		}
		return newElement;
	}

	public void setNewElement(AppElement newElement) {
		this.newElement = newElement;
	}

	/**
	 * Sets data for backing beans used by dependent pages
	 */
	public void setBeans() {
	}

	public void clearBean() {
		_elementSource.flushCache();
		_itemSelection.clearSelection();
		_activeElement = null;
	}

	public void search() {
		clearBean();
		searching = true;
		curLang = userLang;
	}

	public AppElement getFilter() {
		if (filter == null) {
			filter = new AppElement();
		}
		return filter;
	}

	public void setFilter(AppElement filter) {
		this.filter = filter;
	}

	public void clearFilter() {
		curLang = userLang;
		filter = null;
		searching = false;
		clearBean();
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
		if (filter.getLovId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("lovId");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(filter.getLovId().toString());
			filters.add(paramFilter);
		}
		if (filter.getElementType() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("elementType");
			paramFilter.setValue(filter.getElementType());
			filters.add(paramFilter);
		}
		if (filter.getEntityType() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("entityType");
			paramFilter.setValue(filter.getEntityType());
			filters.add(paramFilter);
		}
		if (filter.getSystemName() != null && filter.getSystemName().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("name");
			paramFilter.setOp(Operator.like);
			paramFilter.setValue(filter.getSystemName().trim().toUpperCase().replaceAll(
			        "[*]", "%").replaceAll("[?]", "_"));
			filters.add(paramFilter);
		}
		if (filter.getName() != null && filter.getName().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("label");
			paramFilter.setOp(Operator.like);
			paramFilter.setValue(filter.getName().trim().toUpperCase().replaceAll(
			        "[*]", "%").replaceAll("[?]", "_"));
			filters.add(paramFilter);
		}
	}

	public void add() {
		newElement = new AppElement();
		newElement.setLang(userLang);
		curMode = NEW_MODE;
	}

	public void save() {
		try {
			newElement = _applicationDao.addApplicationElement(userSessionId, newElement);
			_itemSelection.addNewObjectToList(newElement);

			_activeElement = newElement;
			setBeans();
			curMode = VIEW_MODE;

			FacesUtils.addMessageInfo(FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.App", "element_saved"));
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void cancel() {
		curMode = VIEW_MODE;
	}

	public List<SelectItem> getLovs() {
		if (getNewElement().getDataType() == null) {
			return new ArrayList<SelectItem>(0);
		}

		Map<String, Object> params = new HashMap<String, Object>(1);
		params.put("DATA_TYPE", getNewElement().getDataType());
		return getDictUtils().getLov(LovConstants.LOVS_LOV, params);
	}

	public List<SelectItem> getElementTypes() {
		List<SelectItem> items = new ArrayList<SelectItem>();
		items.add(new SelectItem("SIMPLE", "SIMPLE"));
		items.add(new SelectItem("COMPLEX", "COMPLEX"));
		return items;
	}

	public List<SelectItem> getEntityTypes() {
		return getDictUtils().getLov(LovConstants.ENTITY_TYPES);
	}

	public String getComponentId() {
		return COMPONENT_ID;
	}

	public Logger getLogger() {
		return logger;
	}

	public List<SelectItem> getDataTypes(){
		if (dataTypes == null){
			dataTypes = (ArrayList<SelectItem>) getDictUtils().getLov(LovConstants.DATA_TYPES);
		}
		return dataTypes;
	}
	
}
