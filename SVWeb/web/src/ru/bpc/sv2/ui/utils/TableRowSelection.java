package ru.bpc.sv2.ui.utils;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.Iterator;
import java.util.List;

import org.ajax4jsf.model.ExtendedDataModel;
import org.richfaces.model.selection.SimpleSelection;

import ru.bpc.sv2.invocation.ModelIdentifiable;

public class TableRowSelection<T extends ModelIdentifiable> implements Serializable {
	/**
	 * 
	 */
	private static final long serialVersionUID = -5977930284961911936L;
	
	private SimpleSelection _wrappedSelection;
	private final ExtendedDataModel _dataModel;

	public TableRowSelection(SimpleSelection selection, ExtendedDataModel dataModel) {
		_wrappedSelection = selection;
		_dataModel = dataModel;
	}

	public boolean isSingleSelection() {
		Iterator<Object> keys = _wrappedSelection.getKeys();

		if (keys.hasNext()) {
			keys.next();
			if (keys.hasNext()) {
				return false;
			}
		}
		return true;
	}

	public void addSelection(T item) {
		_wrappedSelection.addKey(item.getModelId());
	}

	public boolean isSelected(T item) {
		return _wrappedSelection.isSelected(item.getModelId());
	}

	public void unselect(T item) {
		_wrappedSelection.removeKey(item.getModelId());
	}

	@SuppressWarnings("unchecked")
	public T getSingleSelection() {
		Iterator<Object> keys = _wrappedSelection.getKeys();

		if (keys.hasNext()) {
			Object oldKey = _dataModel.getRowKey();
			try {
				_dataModel.setRowKey(keys.next());
				return (T) _dataModel.getRowData();
			} finally {
				_dataModel.setRowKey(oldKey);
			}
		}

		return null;
	}

	@SuppressWarnings("unchecked")
	public List<T> getMultiSelection() {
		if (_wrappedSelection == null){
			return new ArrayList<T>(0);
		}
		
		List<T> selected = new ArrayList<T>();
		Iterator<Object> keys = _wrappedSelection.getKeys();

		Object oldKey = _dataModel.getRowKey();
		try {
			while (keys.hasNext()) {
				_dataModel.setRowKey(keys.next());
				Object rowData = _dataModel.getRowData();
				if (rowData != null) {
					selected.add((T) rowData);
				}
			}
		} finally {
			_dataModel.setRowKey(oldKey);
		}

		return selected.size() > 0 ? selected : null;
	}

	public SimpleSelection getWrappedSelection() {
		return _wrappedSelection;
	}

	public void setWrappedSelection(SimpleSelection selection) {
		_wrappedSelection = selection;
	}

	public void clearSelection() {
		if (_wrappedSelection != null) {
			_wrappedSelection.clear();
		}
	}

	public void addNewObjectToList(T newObject) {
		addNewObjectToList(newObject, null);
	}

	@SuppressWarnings("unchecked")
	public void addNewObjectToList(T newObject, Comparator<T> comparator) {
		// TODO: maybe it's better to check it in managed bean?
		if (newObject == null) {
			return;
		}
		
		// clear current selection
		clearSelection();
		((DaoDataModel<T>) _dataModel).addNewObjectToList(newObject, comparator);
		if (_wrappedSelection == null) {
			_wrappedSelection = new SimpleSelection();
		}
		_wrappedSelection.addKey(newObject.getModelId());
	}

	/**
	 * <p>Deletes object from list.</p>
	 * @param object - object to delete
	 * @return next object in list or <code>null</code> if list is empty. 
	 */
	@SuppressWarnings("unchecked")
	public T removeObjectFromList(T object) {
		T newObject = ((DaoDataModel<T>) _dataModel).removeObjectFromList(object);
		clearSelection();

		// if something's left on the page, select it
		if (newObject != null) {
			if (_wrappedSelection == null) {
				_wrappedSelection = new SimpleSelection();
			}
			_wrappedSelection.addKey(newObject.getModelId());
		}

		return newObject;
	}
}
