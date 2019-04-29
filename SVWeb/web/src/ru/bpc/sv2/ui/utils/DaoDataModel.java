/**
 * 
 */
package ru.bpc.sv2.ui.utils;

import org.ajax4jsf.model.DataVisitor;
import org.ajax4jsf.model.ExtendedDataModel;
import org.ajax4jsf.model.Range;
import org.ajax4jsf.model.SequenceRange;
import org.apache.log4j.Logger;
import org.richfaces.model.*;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.ModelIdentifiable;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.invocation.SortElement;
import ru.bpc.sv2.invocation.SortElement.Direction;
import ru.bpc.sv2.settings.constants.SettingsConstants;
import ru.bpc.sv2.ui.utils.cache.SettingsCache;

import javax.el.Expression;
import javax.el.ValueExpression;
import javax.faces.FacesException;
import javax.faces.context.FacesContext;
import java.io.Serializable;
import java.util.*;

public abstract class DaoDataModel<T extends ModelIdentifiable> extends
		ExtendedDataModel implements Modifiable, Serializable {
	private static final Logger logger = Logger.getLogger("SYSTEM");
	/**
	 * 
	 */
	private static final long serialVersionUID = -2774057026346865894L;
	
	private ModelIdentifiable _activeItem;
	private List<T> _activePage;
	private SequenceRange _lastRange;
	private final SelectionParams _params;

	private Object _rowKey;
	private int _rowIndex;
	private int _dataSize;
	private boolean noFlush;
	private boolean clearSortElement;
	private boolean excludeSortElements;

	public DaoDataModel() {
        _params = new SelectionParams();
		init(false);
	}

    public DaoDataModel(boolean clearSortElement) {
        _params = new SelectionParams();
        init(clearSortElement);
    }

	private void init(boolean clearSortable) {
        _dataSize = -1;
        this.clearSortElement = clearSortable;
        this.excludeSortElements = false;
        _params.setSortElement(new SortElement[0]);
    }

	@Override
	public void setRowKey(Object key) {
		_rowKey = key;
		_rowIndex = -1;
		_activeItem = null;
	}

	@Override
	public void setRowIndex(int index) {
		_rowIndex = index;
		_rowKey = null;
		_activeItem = null;
	}

	@Override
	public Object getRowKey() {
		return (_activeItem != null ? _activeItem.getModelId() : null);
	}

	@Override
	public void walk(FacesContext context, DataVisitor visitor, Range range,
			Object argument) {		
		SequenceRange nativeRange = (SequenceRange) range;
		if (_activePage == null || rangeChanged(nativeRange)) {
			_lastRange = nativeRange;
			_params.setRowIndexStart(nativeRange.getFirstRow());
			_params.setRowIndexEnd(nativeRange.getFirstRow()
					+ nativeRange.getRows() - 1);

			_activePage = loadData(_params);
		}
		try{
			for (ModelIdentifiable item : _activePage) {
				visitor.process(context, item.getModelId(), argument);
			}
		}catch(Exception exc){
			logger.error(exc.getMessage(), exc);
			FacesUtils.addMessageError(exc);
		}

	}

	public List<T> loadData(SelectionParams params) {
		try {
			if (getRowCount() < 1) return new ArrayList<T>(0);
			T[] dataArray = loadDaoData(params);
			List<T> dataList = new ArrayList<T>(dataArray.length);
			for (T dataItem : dataArray) {
				dataList.add(dataItem);
			}

			return dataList;
		} catch (Exception exc) {
			logger.error(exc.getMessage(), exc);
			FacesUtils.addMessageError(exc);
			return Collections.emptyList();
		}
	}

	protected abstract T[] loadDaoData(SelectionParams params);

	@Override
	public int getRowCount() {
		if (_dataSize == -1) {
			_dataSize = loadDaoDataSize(_params);
			_params.setRowCount(_dataSize);
			clearSortElement();
		}
		return _dataSize;
	}

	protected abstract int loadDaoDataSize(SelectionParams params);

	@Override
	public Object getRowData() {
		try {
			if (_activeItem == null) {
				if (_activePage != null) {
					if (_rowKey != null) {
						for (ModelIdentifiable item : _activePage) {
							if (_rowKey != null && _rowKey.equals(item.getModelId())) {
								_activeItem = item;
								break;
							} else if (_rowIndex != -1) {
								if (_rowIndex <= _lastRange.getRows()) {
									_activeItem = _activePage.get(_rowIndex);
									break;
								}
							}
						}
					} else if (_rowIndex != -1) {
						if (_rowIndex <= _lastRange.getRows()) {
							if (_rowIndex < _activePage.size()) {
								_activeItem = _activePage.get(_rowIndex);
							}
						}
					}
				}
			}
		} catch (RuntimeException e) {
			logger.error(e.getMessage(), e);
			printClassState();
			throw e;
		}
		return _activeItem;
	}

	@Override
	public int getRowIndex() {
		return _rowIndex;
	}

	@Override
	public boolean isRowAvailable() {
			try {
				if (_lastRange == null) {
					return false;
				}
	
				if (_rowIndex == -1 && _rowKey == null) {
					return false;
				} else if (_rowIndex != -1) {
					if (_rowIndex >= 0 && _rowIndex <= (_activePage.size() - 1)) {
						return true;
					} else {
						return false;
					}
				} else if (_rowKey != null) {
					if (_activePage != null){ // CRUTCH: If progressBar component is used in ExtendedDataTable this method is executed after flushCash and before walk. As a result we have _activePage=null and nullPointerException in for-statement
						for (ModelIdentifiable item : _activePage) {
							if (_rowKey != null && _rowKey.equals(item.getModelId())) {
								return true;
							}
						}
					}
					return false;
				}
	
				} catch (RuntimeException e){
					logger.error(e.getMessage(), e);
					printClassState();
					throw e;
				}
			return false;			
	}

	@Override
	public void modify(List<FilterField> filterFields,
			List<SortField2> sortFields) {
		boolean equals = true;
		// if (noFlush) {
		// noFlush = false;
		// return;
		// }
		ArrayList<SortElement> nativeSorting = new ArrayList<SortElement>(
				sortFields.size());
		ArrayList<Filter> nativeFiltering = new ArrayList<Filter>(
				filterFields.size());
		for (SortField2 field : sortFields) {
			if (field.getOrdering() == Ordering.UNSORTED) {
				continue;
			}

			String colName = getPropertyName(field.getExpression());

			SortElement.Direction colDir;
			switch (field.getOrdering()) {
			case ASCENDING:
				colDir = Direction.ASC;
				break;

			default:
				colDir = Direction.DESC;
				break;
			}

			nativeSorting.add(new SortElement(colName, colDir));
		}

		SortElement[] nativeSortingArr = nativeSorting
				.toArray(new SortElement[nativeSorting.size()]);
		equals = Arrays.equals(_params.getSortElement(), nativeSortingArr);
		_params.setSortElement(nativeSortingArr);

		for (FilterField field : filterFields) {
			String colName = getPropertyName(field.getExpression());

			String filterValue = ((ExtendedFilterField) field).getFilterValue();
			if (filterValue != null) {
				nativeFiltering.add(new Filter(colName, filterValue));
			}
		}
		Filter[] nativeFilteringArr = nativeFiltering
				.toArray(new Filter[nativeFiltering.size()]);
		equals = equals && (nativeFilteringArr.length == 0);
		_params.setFilters(nativeFilteringArr);

		if (!equals) {
			flushCache();
		}
	}

	private String getPropertyName(Expression expr) {
		try {
			return (String) ((ValueExpression) expr).getValue(FacesContext
					.getCurrentInstance().getELContext());
		} catch (Throwable thr) {
			throw new FacesException(thr);
		}
	}

	private boolean rangeChanged(SequenceRange newRange) {
		if (newRange == null || _lastRange == null) {
			if (newRange == null && _lastRange == null) {
				return false;
			} else {
				return true;
			}
		} else if (newRange.getFirstRow() == _lastRange.getFirstRow()
				&& newRange.getRows() == _lastRange.getRows()) {
			return false;
		}
		return true;
	}

	@Override
	public Object getWrappedData() {
		throw new UnsupportedOperationException(
				"Nothing can be wrapped by this model. DAO is the only possible data source");
	}

	@Override
	public void setWrappedData(Object data) {
		throw new UnsupportedOperationException(
				"Only DAO can expose data through this model");
	}

	public int getDataSize() {
		return _dataSize;
	}

	public void setDataSize(int dataSize) {
		_dataSize = dataSize;
	}

	public void flushCache() {
		_activePage = null;
		_activeItem = null;
		_rowKey = null;
		_dataSize = -1;
		_rowIndex = -1;
	}

	public List<T> getActivePage() {
		return _activePage;
	}

	public boolean isNoFlush() {
		return noFlush;
	}
	public void setNoFlush(boolean noFlush) {
		this.noFlush = noFlush;
	}

	/**
	 * <p>
	 * Adds new object to <code>_activePage</code>. Don't use it directly, use
	 * <code>TableRowSelection</code>'s method with same name.
	 * </p>
	 * 
	 * @param newObject
	 * @param comparator
	 */
	public void addNewObjectToList(T newObject, Comparator<T> comparator) {
		if (_activePage == null || _activePage.isEmpty()) {
			_activePage = new ArrayList<T>();
		}
		for (T object : _activePage) {
			if (object.getModelId().equals(newObject.getModelId())) {
				try {
					replaceObject(object, newObject);
				} catch (Exception e) {
					// this should never happen if you call this method
					// correctly
					// (i.e. from TableRowSelection's same method)
				}
				return;
			}
		}
		// add newly created object to current page collection and select it
		_activePage.add(0, newObject);

		if (_dataSize <= 0) {
			_dataSize = 1; // just to get rid of no-data-found label
		} else {
			_dataSize++;
		}

		if (comparator != null) {
			Collections.sort(_activePage, comparator);
		}
		noFlush = true;
		// Actually it's useless as in most cases it's reset by setRowKey()
		// (needs to be fixed)
		_activeItem = newObject;
		_rowIndex = 0;
		_rowKey = _activeItem.getModelId();
	}

	/**
	 * <p>
	 * Replaces <code>oldObject</code> with <code>newObject</code>. If
	 * <code>oldObject</code> is <code>null</code> replaces currently active
	 * item with <code>newObject</code>.
	 * </p>
	 * 
	 * @param oldObject
	 * @param newObject
	 */
	public void replaceObject(T oldObject, T newObject) throws Exception {
		if (newObject == null) {
			throw new IllegalArgumentException("New object is NULL.");
		}

		// replace old object with edited one inside current page collection
		boolean elementFound = false;
		/**
		 * When there's ordering on the page, _activePage is reloaded sometimes
		 * this can cause calling <code>_activePage.indexOf(oldObject)</code> to
		 * return <code>-1</code> even if the needed object is in list.
		 */
		int index = 0;
		for (index = 0; index < _activePage.size(); index++) {
			if (_activePage.get(index).getModelId()
					.equals(oldObject.getModelId())) {
				elementFound = true;
				break;
			}
		}

		if (elementFound) {
			_activePage.remove(index);
			_activePage.add(index, newObject);

			// another useless block (maybe it'll be useful sometime)
			_activeItem = newObject;
			_rowKey = _activeItem.getModelId();
			_rowIndex = index;
		}
	}

	/**
	 * <p>
	 * <b>Don't use it directly!</b>
	 * </p>
	 * <p>
	 * Use <code>removeObjectFromList(T object)</code> method of
	 * <code>ru.bpc.sv2.ui.utils.TableRowSelection</code> instead
	 * </p>
	 * 
	 * @param object
	 *            - object to delete.
	 * @return next object in list.
	 */
	public T removeObjectFromList(T object) {
		T newObject = null;

		int index = -1;
		/**
		 * When there's ordering on the page, _activePage is reloaded sometimes
		 * this can cause calling <code>_activePage.indexOf(object)</code> to
		 * return <code>-1</code> even if the needed object is in list.
		 */
		for (index = 0; index < _activePage.size(); index++) {
			if (_activePage.get(index).getModelId().equals(object.getModelId())) {
				break;
			}
		}
		_activePage.remove(index);

		_dataSize--;

		// if something's left on the page, get item of the same index
		if (_activePage.size() > 0) {
			if (_activePage.size() > index) {
				_rowIndex = index;
			} else {
				_rowIndex = index - 1;
			}
			newObject = _activePage.get(_rowIndex);
			_activeItem = newObject;
			_rowKey = _activeItem.getModelId();
		} else {
			_activeItem = null;
			_rowKey = null;
			_rowIndex = -1;
			// _dataSize = 0;
		}

		return newObject;
	}
	
	//TODO: For debugging only. If SVTWO-9369 and SVTWO-8797 are closed, delete it.
	private void printClassState(){
		if (_activeItem == null){
			logger.debug("_activeItem == null");
		} else {
			logger.debug("_activeItem != null; _activeItem.id: " + _activeItem.getModelId());
		}
		if (_activePage == null){
			logger.debug("_activePage == null");
		} else {
			logger.debug("_activePage != null; _activePage.size: " + _activePage.size());
		}
		if (_lastRange == null){
			logger.debug("_lastRange == null");
		} else {
			logger.debug("_lastRange != null");
		}
		if (_params == null){
			logger.debug("_params == null");
		} else {
			logger.debug("_params !	= null");
			Filter[] filters = _params.getFilters();
			if (filters != null && filters.length > 0){
				logger.debug("_params.filters:");
				for (Filter filter : filters){
					logger.debug("_params.filters.filter:");
					if (filter.getValue() != null){logger.debug("filter.value:" + filter.getValue());}
					if (filter.getElement() != null){logger.debug("filter.element:" + filter.getElement());}
				}
			}
			logger.debug("_params.rowIndexStart:" + _params.getRowIndexStart());
			logger.debug("_params.rowIndexEnd:" + _params.getRowIndexEnd());
		}
		if (_rowKey == null){
			logger.debug("_rowKey == null");
		} else {
			logger.debug("_rowKey != null; _rowKey:" + _rowKey.toString());
		}
		logger.debug("_rowIndex:" + _rowIndex);
		logger.debug("_dataSize:" + _dataSize);
	}

	public boolean isNeedClearSortElement() {
	    return (_dataSize > getSortableMaxRowCount() && isClearSortElement() && !isExcludeSortElements());
    }

    private void clearSortElement() {
        if (isNeedClearSortElement()) {
            _params.setSortElement(new SortElement[0]);
        }
    }

    public static int getSortableMaxRowCount() {
        Number maxRowCount = SettingsCache.getInstance().getParameterNumberValue(SettingsConstants.MAX_COUNT_WHEN_FORM_USES_SORTING);
        if (maxRowCount == null || maxRowCount.intValue() == 0) maxRowCount = 1000;
        return maxRowCount.intValue();
    }

    public void setClearSortElement(boolean clearSortElement) {
        this.clearSortElement = clearSortElement;
    }

    public boolean isClearSortElement() {
	    return this.clearSortElement;
    }

	public boolean isExcludeSortElements() {
		return excludeSortElements;
	}

	public void setExcludeSortElements(boolean excludeSortElements) {
		this.excludeSortElements = excludeSortElements;
	}
}
