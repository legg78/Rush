package ru.bpc.sv2.ui.utils;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.ModelIdentifiable;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.utils.UserException;

import javax.annotation.PostConstruct;
import java.util.ArrayList;
import java.util.List;

/**
 * Abstract mbean for pages with search form
 *
 * @param <F> Search filter type
 * @param <R> Table row type
 */
public abstract class AbstractSearchBean<F, R extends ModelIdentifiable> extends AbstractBean {
	static final long serialVersionUID = 1L;

	public static final String DETAILS_TAB = "detailsTab";

	protected static final String LANGUAGE = "lang";
	protected String tabName = AbstractSearchBean.DETAILS_TAB;
	protected F filter;
	protected TableRowSelection<R> tableRowSelection;
	protected R activeItem;
	protected List<R> activeItems;
	protected R newItem;
	protected DaoDataModel<R> dataModel;

	@PostConstruct
	public void init() {
		searching = false;
		filter = createFilter();
		dataModel = new DaoDataListModel<R>(getLogger()) {
			private static final long serialVersionUID = 1L;

			@Override
			protected List<R> loadDaoListData(SelectionParams params) {
				filters = new ArrayList<Filter>();
				initFilters(getFilter(), filters);
				params.setFilters(filters);
				return getObjectList(userSessionId, params);
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (searching) {
					filters = new ArrayList<Filter>();
					initFilters(getFilter(), filters);
					params.setFilters(filters);
					return getObjectCount(userSessionId, params);
				}
				return 0;
			}
		};
		tableRowSelection = new TableRowSelection<R>(null, dataModel);
	}

	protected abstract F createFilter();

	protected abstract Logger getLogger();

	protected abstract R addItem(R item) throws UserException;

	protected abstract R editItem(R item) throws UserException;

	protected abstract void deleteItem(R item);

	protected abstract void initFilters(F filter, List<Filter> filters);

	protected abstract List<R> getObjectList(Long userSessionId, SelectionParams params);

	protected abstract int getObjectCount(Long userSessionId, SelectionParams params);

	@SuppressWarnings("UnusedParameters")
	protected void onItemSelected(R activeItem) {}

	public void search() {
		curMode = VIEW_MODE;
		clearState();
		searching = true;
	}

	@Override
	public void clearFilter() {
		filter = createFilter();
		searching = false;
		clearState();
	}

	public void clearState() {
		tableRowSelection.clearSelection();
		activeItem = null;
		activeItems = null;
		dataModel.flushCache();
		curLang = userLang;
	}

	public SimpleSelection getItemSelection() {
		try {
			if (activeItem == null && dataModel.getRowCount() > 0) {
				prepareItemSelection();
			} else if (activeItem != null && dataModel.getRowCount() > 0) {
				SimpleSelection selection = new SimpleSelection();
				selection.addKey(activeItem.getModelId());
				tableRowSelection.setWrappedSelection(selection);
				activeItem = tableRowSelection.getSingleSelection();
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			getLogger().error(e.getMessage(), e);
		}
		return tableRowSelection.getWrappedSelection();
	}

	public void prepareItemSelection() throws CloneNotSupportedException {
		dataModel.setRowIndex(0);
		SimpleSelection selection = new SimpleSelection();
		//noinspection unchecked
		activeItem = (R) dataModel.getRowData();
		selection.addKey(activeItem.getModelId());
		tableRowSelection.setWrappedSelection(selection);
		if (activeItem != null) {
			onItemSelected(activeItem);
		}
	}

	public void setItemSelection(SimpleSelection selection) {
		try {
			tableRowSelection.setWrappedSelection(selection);
			R singleSelection = null;
			if (!tableRowSelection.isSingleSelection()) {
				activeItems = tableRowSelection.getMultiSelection();
				singleSelection = activeItems.get(0);
			} else {
				singleSelection = tableRowSelection.getSingleSelection();
			}
			boolean changeSelect = singleSelection != null && !singleSelection.getModelId().equals(activeItem.getModelId());
			activeItem = singleSelection;
			if (activeItem != null && changeSelect) {
				onItemSelected(activeItem);
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			getLogger().error(e.getMessage(), e);
		}
	}

	public String getTabName() {
		return tabName;
	}

	public void setTabName(String tabName) {
		this.tabName = tabName;
	}

	public F getFilter() {
		if (filter == null) {
			filter = createFilter();
		}
		return filter;
	}

	public void add() {
		curMode = NEW_MODE;
	}

	public void edit() {
		newItem = activeItem;
		curMode = EDIT_MODE;
	}

	public void delete() {
		curMode = REMOVE_MODE;
	}

	public void save() {
		try {
			if (isEditMode()) {
				newItem = editItem(newItem);
				dataModel.replaceObject(activeItem, newItem);
			} else {
				newItem = addItem(newItem);
				tableRowSelection.addNewObjectToList(newItem);
			}
			activeItem = newItem;
			curMode = VIEW_MODE;
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			getLogger().error("", e);
		}
	}

	public void cancel() {
		curMode = VIEW_MODE;
	}

	public void remove() {
		try {
			deleteItem(activeItem);
			activeItem = tableRowSelection.removeObjectFromList(activeItem);

			if (activeItem == null) {
				clearState();
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			getLogger().error("", e);
		} finally {
			curMode = VIEW_MODE;
		}
	}

	public TableRowSelection<R> getTableRowSelection() {
		return tableRowSelection;
	}

	public R getActiveItem() {
		return activeItem;
	}

	public void setActiveItem(R activeItem) {
		this.activeItem = activeItem;
	}

	public List<R> getActiveItems() {
		return activeItems;
	}

	public void setActiveItems(List<R> activeItems) {
		this.activeItems = activeItems;
	}

	public R getNewItem() {
		return newItem;
	}

	public void setNewItem(R newItem) {
		this.newItem = newItem;
	}

	public DaoDataModel<R> getDataModel() {
		return dataModel;
	}
}
