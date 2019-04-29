package ru.bpc.sv2.ui.cmn;

import java.util.ArrayList;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.RequestScoped;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;

import org.ajax4jsf.model.KeepAlive;
import ru.bpc.sv2.cmn.ObjectStandard;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.CommunicationDao;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.TableRowSelection;

@RequestScoped
@KeepAlive
@ManagedBean (name = "MbObjectStandards")
public class MbObjectStandards extends AbstractBean {
	private static final Logger logger = Logger.getLogger("ISSUING");

	private CommunicationDao _cmnDao = new CommunicationDao();

	private ObjectStandard filter;
	private ObjectStandard _activeObjectStandard;
	private ObjectStandard newObjectStandard;

	private final DaoDataModel<ObjectStandard> _objectStandardsSource;

	private final TableRowSelection<ObjectStandard> _itemSelection;
	
	private static String COMPONENT_ID = "objectsTable";
	private String tabName;
	private String parentSectionId;

	public MbObjectStandards() {
		_objectStandardsSource = new DaoDataModel<ObjectStandard>() {
			@Override
			protected ObjectStandard[] loadDaoData(SelectionParams params) {
				if (!searching) {
					return new ObjectStandard[0];
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _cmnDao.getObjectStandards(userSessionId, params);
				} catch (Exception e) {
					setDataSize(0);
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return new ObjectStandard[0];
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (!searching) {
					return 0;
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _cmnDao.getObjectStandardsCount(userSessionId, params);
				} catch (Exception e) {
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return 0;
			}
		};

		_itemSelection = new TableRowSelection<ObjectStandard>(null, _objectStandardsSource);
	}

	public DaoDataModel<ObjectStandard> getObjectStandards() {
		return _objectStandardsSource;
	}

	public ObjectStandard getActiveObjectStandard() {
		return _activeObjectStandard;
	}

	public void setActiveObjectStandard(ObjectStandard activeObjectStandard) {
		_activeObjectStandard = activeObjectStandard;
	}

	public SimpleSelection getItemSelection() {
		try {
			if (_activeObjectStandard == null && _objectStandardsSource.getRowCount() > 0) {
				setFirstRowActive();
			} else if (_activeObjectStandard != null && _objectStandardsSource.getRowCount() > 0) {
				SimpleSelection selection = new SimpleSelection();
				selection.addKey(_activeObjectStandard.getModelId());
				_itemSelection.setWrappedSelection(selection);
				_activeObjectStandard = _itemSelection.getSingleSelection();
			}
		} catch (Exception e) {
			logger.error("", e);
			FacesUtils.addMessageError(e);
		}
		return _itemSelection.getWrappedSelection();
	}

	public void setFirstRowActive() {
		_objectStandardsSource.setRowIndex(0);
		SimpleSelection selection = new SimpleSelection();
		_activeObjectStandard = (ObjectStandard) _objectStandardsSource.getRowData();
		selection.addKey(_activeObjectStandard.getModelId());
		_itemSelection.setWrappedSelection(selection);
		if (_activeObjectStandard != null) {
			setInfo();
		}
	}

	public void setItemSelection(SimpleSelection selection) {
		_itemSelection.setWrappedSelection(selection);
		_activeObjectStandard = _itemSelection.getSingleSelection();
		if (_activeObjectStandard != null) {
			setInfo();
		}
	}

	public void setInfo() {

	}

	public void search() {
		clearState();
		searching = true;
	}

	public void clearFilter() {
		filter = new ObjectStandard();
		clearState();
		searching = false;
	}

	public ObjectStandard getFilter() {
		if (filter == null)
			filter = new ObjectStandard();
		return filter;
	}

	public void setFilter(ObjectStandard filter) {
		this.filter = filter;
	}

	private void setFilters() {
		filter = getFilter();
		filters = new ArrayList<Filter>();

		Filter paramFilter;// = new Filter();
//		paramFilter.setElement("lang");
//		paramFilter.setOp(Operator.eq);
//		paramFilter.setValue(curLang);
//		filters.add(paramFilter);

		if (filter.getId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("id");
			paramFilter.setValue(filter.getId());
			filters.add(paramFilter);
		}
		if (filter.getObjectId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("objectId");
			paramFilter.setValue(filter.getObjectId());
			filters.add(paramFilter);
		}
		if (filter.getEntityType() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("entityType");
			paramFilter.setValue(filter.getEntityType());
			filters.add(paramFilter);
		}
		if (filter.getStandardId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("standardId");
			paramFilter.setValue(filter.getStandardId());
			filters.add(paramFilter);
		}
		if (filter.getStandardType() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("standardType");
			paramFilter.setValue(filter.getStandardType());
			filters.add(paramFilter);
		}
	}

	public void add() {

	}

	public void edit() {

	}

	public void view() {

	}

	public void save() {

	}

	public void delete() {

	}

	public void close() {
		curMode = VIEW_MODE;
	}

	public ObjectStandard getNewObjectStandard() {
		if (newObjectStandard == null) {
			newObjectStandard = new ObjectStandard();
		}
		return newObjectStandard;
	}

	public void setNewObjectStandard(ObjectStandard newObjectStandard) {
		this.newObjectStandard = newObjectStandard;
	}

	public void clearState() {
		_itemSelection.clearSelection();
		_activeObjectStandard = null;
		_objectStandardsSource.flushCache();
		curLang = userLang;
	}

	public void fullCleanBean() {
		clearFilter();
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
