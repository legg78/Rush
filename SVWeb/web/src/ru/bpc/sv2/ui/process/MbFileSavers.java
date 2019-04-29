package ru.bpc.sv2.ui.process;

import java.util.ArrayList;
import java.util.List;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.event.ValueChangeEvent;

import org.apache.commons.lang3.StringUtils;
import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;

import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.Filter.Operator;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.ProcessDao;
import ru.bpc.sv2.process.ProcessFileSaver;
import ru.bpc.sv2.ui.utils.*;

@ViewScoped
@ManagedBean (name = "MbFileSavers")
public class MbFileSavers extends AbstractBean {
	
	private static final long serialVersionUID = 1L;

	private static final Logger logger = Logger.getLogger("PROCESSES");

	private static String COMPONENT_ID = "2311:mainTable";

	private ProcessDao _processDao = new ProcessDao();

	private ProcessFileSaver filter;
	private ProcessFileSaver _activeFileSaver;
	private ProcessFileSaver newFileSaver;

	private final DaoDataModel<ProcessFileSaver> _parametersSource;

	private final TableRowSelection<ProcessFileSaver> _itemSelection;

	public MbFileSavers() {
		pageLink = "processes|file_savers";
		_parametersSource = new DaoDataListModel<ProcessFileSaver>(logger) {
			private static final long serialVersionUID = 1L;

			@Override
			protected List<ProcessFileSaver> loadDaoListData(SelectionParams params) {
				if (isSearching()) {
					setFilters();
					params.setFilters(filters);
					return _processDao.getFileSavers(userSessionId, params);
				}
				return new ArrayList<ProcessFileSaver>();
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (isSearching()) {
					setFilters();
					params.setFilters(filters);
					return _processDao.getFileSaversCount(userSessionId, params);
				}
				return 0;
			}
		};
		_itemSelection = new TableRowSelection<ProcessFileSaver>(null, _parametersSource);
	}

	public DaoDataModel<ProcessFileSaver> getFileSavers() {
		return _parametersSource;
	}

	public ProcessFileSaver getActiveFileSaver() {
		return _activeFileSaver;
	}

	public void setActiveFileSaver(ProcessFileSaver activeFileSaver) {
		_activeFileSaver = activeFileSaver;
	}

	public SimpleSelection getItemSelection() {
		try {
			if (_activeFileSaver == null && _parametersSource.getRowCount() > 0) {
				setFirstRowActive();
			} else if (_activeFileSaver != null && _parametersSource.getRowCount() > 0) {
				SimpleSelection selection = new SimpleSelection();
				selection.addKey(_activeFileSaver.getModelId());
				_itemSelection.setWrappedSelection(selection);
				_activeFileSaver = _itemSelection.getSingleSelection();
			}
		} catch (Exception e) {
			logger.error("", e);
			FacesUtils.addMessageError(e);
		}
		return _itemSelection.getWrappedSelection();
	}

	public void setFirstRowActive() {
		_parametersSource.setRowIndex(0);
		SimpleSelection selection = new SimpleSelection();
		_activeFileSaver = (ProcessFileSaver) _parametersSource.getRowData();
		selection.addKey(_activeFileSaver.getModelId());
		_itemSelection.setWrappedSelection(selection);
		if (_activeFileSaver != null) {
			// setInfo();
		}
	}

	public void setItemSelection(SimpleSelection selection) {
		_itemSelection.setWrappedSelection(selection);
		_activeFileSaver = _itemSelection.getSingleSelection();
	}

	public void search() {
		clearState();
		setSearching(true);
	}

	public void setFilters() {
		filters = new ArrayList<Filter>(1);
		filters.add(Filter.create("lang", userLang));

		if (getFilter().getId() != null) {
			filters.add(Filter.create("id", getFilter().getId().toString()));
		}
		if (getFilter().getBaseSource() != null) {
			filters.add(Filter.create("baseSource", Filter.mask(getFilter().getBaseSource())));
		}
		if (getFilter().getPostSource() != null) {
			filters.add(Filter.create("postSource", Filter.mask(getFilter().getPostSource())));
		}
		if (StringUtils.isNotBlank(filter.getName())) {
			filters.add(Filter.create("name", Filter.mask(getFilter().getName())));
		}
	}

	public void add() {
		newFileSaver = new ProcessFileSaver();
		newFileSaver.setLang(userLang);
		curMode = NEW_MODE;
	}

	public void edit() {
		try {
			newFileSaver = (ProcessFileSaver) _activeFileSaver.clone();
		} catch (CloneNotSupportedException e) {
			logger.error("", e);
			newFileSaver = _activeFileSaver;
		}
		curMode = EDIT_MODE;
	}

	public void save() {
		try {
			if (isNewMode()) {
				newFileSaver = _processDao.addFileSaver(userSessionId, newFileSaver);
				_itemSelection.addNewObjectToList(newFileSaver);
			} else if (isEditMode()) {
				newFileSaver = _processDao.modifyFileSaver(userSessionId, newFileSaver);
				_parametersSource.replaceObject(_activeFileSaver, newFileSaver);
			}

			_activeFileSaver = newFileSaver;
			curMode = VIEW_MODE;
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void delete() {
		try {
			_processDao.deleteFileSaver(userSessionId, _activeFileSaver);
			_activeFileSaver = _itemSelection.removeObjectFromList(_activeFileSaver);
			if (_activeFileSaver == null) {
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

	public ProcessFileSaver getNewFileSaver() {
		if (newFileSaver == null) {
			newFileSaver = new ProcessFileSaver();
		}
		return newFileSaver;
	}

	public void setNewFileSaver(ProcessFileSaver newFileSaver) {
		this.newFileSaver = newFileSaver;
	}

	public ProcessFileSaver getFilter() {
		if (filter == null) {
			filter = new ProcessFileSaver();
		}
		return filter;
	}

	public void setFilter(ProcessFileSaver filter) {
		this.filter = filter;
	}

	public void clearFilter() {
		filter = new ProcessFileSaver();
		clearState();
		searching = false;
	}
	
	public void clearState() {
		_parametersSource.flushCache();
		_itemSelection.clearSelection();
		_activeFileSaver = null;
	}

	private ProcessFileSaver updateByLanguage(ProcessFileSaver original, String newLang) {
		try {
			List<Filter> filters = new ArrayList<Filter>(2);
			filters.add(Filter.create("id", original.getId().toString()));
			filters.add(Filter.create("lang", newLang));

			List<ProcessFileSaver> params = _processDao.getFileSavers(userSessionId, new SelectionParams(filters));
			if (params != null && params.size() > 0) {
				original = params.get(0);
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
		return original;
	}

	public void changeLanguage(ValueChangeEvent event) {
		curLang = (String) event.getNewValue();
		_activeFileSaver = updateByLanguage(_activeFileSaver, curLang);
	}

	public void confirmEditLanguage() {
		newFileSaver = updateByLanguage(newFileSaver, newFileSaver.getLang());
	}

	public String getComponentId() {
		return COMPONENT_ID;
	}

	public Logger getLogger() {
		return logger;
	}

}
