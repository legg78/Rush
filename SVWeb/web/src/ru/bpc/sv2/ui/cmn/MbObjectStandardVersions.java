package ru.bpc.sv2.ui.cmn;

import java.util.ArrayList;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.RequestScoped;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;

import org.ajax4jsf.model.KeepAlive;
import ru.bpc.sv2.cmn.ObjectStandardVersion;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.CommunicationDao;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.TableRowSelection;

@RequestScoped
@KeepAlive
@ManagedBean (name = "MbObjectStandardVersions")
public class MbObjectStandardVersions extends AbstractBean {
	private static final Logger logger = Logger.getLogger("ISSUING");

	private CommunicationDao _cmnDao = new CommunicationDao();

	private ObjectStandardVersion filter;
	private ObjectStandardVersion _activeObjectStandardVersion;
	private ObjectStandardVersion newObjectStandardVersion;

	private final DaoDataModel<ObjectStandardVersion> _objectStandardVersionsSource;

	private final TableRowSelection<ObjectStandardVersion> _itemSelection;
	
	private static String COMPONENT_ID = "objectsVersionTable";
	private String tabName;
	private String parentSectionId;

	public MbObjectStandardVersions() {
		_objectStandardVersionsSource = new DaoDataModel<ObjectStandardVersion>() {
			@Override
			protected ObjectStandardVersion[] loadDaoData(SelectionParams params) {
				if (!searching) {
					return new ObjectStandardVersion[0];
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _cmnDao.getObjectStandardVersions(userSessionId, params, curLang);
				} catch (Exception e) {
					setDataSize(0);
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return new ObjectStandardVersion[0];
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (!searching) {
					return 0;
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _cmnDao.getObjectStandardVersionsCount(userSessionId, params);
				} catch (Exception e) {
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return 0;
			}
		};

		_itemSelection = new TableRowSelection<ObjectStandardVersion>(null,
				_objectStandardVersionsSource);
	}

	public DaoDataModel<ObjectStandardVersion> getObjectStandardVersions() {
		return _objectStandardVersionsSource;
	}

	public ObjectStandardVersion getActiveObjectStandardVersion() {
		return _activeObjectStandardVersion;
	}

	public void setActiveObjectStandardVersion(ObjectStandardVersion activeObjectStandardVersion) {
		_activeObjectStandardVersion = activeObjectStandardVersion;
	}

	public SimpleSelection getItemSelection() {
		try {
			if (_activeObjectStandardVersion == null
					&& _objectStandardVersionsSource.getRowCount() > 0) {
				setFirstRowActive();
			} else if (_activeObjectStandardVersion != null
					&& _objectStandardVersionsSource.getRowCount() > 0) {
				SimpleSelection selection = new SimpleSelection();
				selection.addKey(_activeObjectStandardVersion.getModelId());
				_itemSelection.setWrappedSelection(selection);
				_activeObjectStandardVersion = _itemSelection.getSingleSelection();
			}
		} catch (Exception e) {
			logger.error("", e);
			FacesUtils.addMessageError(e);
		}
		return _itemSelection.getWrappedSelection();
	}

	public void setFirstRowActive() {
		_objectStandardVersionsSource.setRowIndex(0);
		SimpleSelection selection = new SimpleSelection();
		_activeObjectStandardVersion = (ObjectStandardVersion) _objectStandardVersionsSource
				.getRowData();
		selection.addKey(_activeObjectStandardVersion.getModelId());
		_itemSelection.setWrappedSelection(selection);
		if (_activeObjectStandardVersion != null) {
			setInfo();
		}
	}

	public void setItemSelection(SimpleSelection selection) {
		_itemSelection.setWrappedSelection(selection);
		_activeObjectStandardVersion = _itemSelection.getSingleSelection();
		if (_activeObjectStandardVersion != null) {
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
		filter = new ObjectStandardVersion();
		clearState();
		searching = false;
	}

	public ObjectStandardVersion getFilter() {
		if (filter == null)
			filter = new ObjectStandardVersion();
		return filter;
	}

	public void setFilter(ObjectStandardVersion filter) {
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
		if (filter.getVersionId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("versionId");
			paramFilter.setValue(filter.getVersionId());
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

	public ObjectStandardVersion getNewObjectStandardVersion() {
		if (newObjectStandardVersion == null) {
			newObjectStandardVersion = new ObjectStandardVersion();
		}
		return newObjectStandardVersion;
	}

	public void setNewObjectStandardVersion(ObjectStandardVersion newObjectStandardVersion) {
		this.newObjectStandardVersion = newObjectStandardVersion;
	}

	public void clearState() {
		_itemSelection.clearSelection();
		_activeObjectStandardVersion = null;
		_objectStandardVersionsSource.flushCache();
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
