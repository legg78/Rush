package ru.bpc.sv2.ui.fraud;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.RequestScoped;
import javax.faces.model.SelectItem;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;

import org.ajax4jsf.model.KeepAlive;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.fraud.MatrixValue;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.FraudDao;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.TableRowSelection;

@RequestScoped
@KeepAlive
@ManagedBean (name = "MbMatrixValues")
public class MbMatrixValues extends AbstractBean {
	private static final long serialVersionUID = -542570954241978746L;

	private static final Logger logger = Logger.getLogger("FRAUD_PREVENTION");

	private FraudDao _fraudDao = new FraudDao();

	private MatrixValue filter;
	private MatrixValue _activeMatrixValue;
	private MatrixValue newMatrixValue;
	private String xScale;
	private String yScale;

	private final DaoDataModel<MatrixValue> _matrixValuesSource;
	private final TableRowSelection<MatrixValue> _itemSelection;

	private ArrayList<String> columnNames;
	private HashMap<String, Integer> columnNamesToIndices;
	private HashMap<Integer, String> columnIndicesToNames;
	private ArrayList<ArrayList<MatrixValue>> matrixCells;
	private ArrayList<ArrayList<MatrixValue>> editMatrixCells;
	private Integer columnsNumber;
	private Integer rowsNumber;
	
	public MbMatrixValues() {
		_matrixValuesSource = new DaoDataModel<MatrixValue>() {
			private static final long serialVersionUID = -557414638257134776L;

			@Override
			protected MatrixValue[] loadDaoData(SelectionParams params) {
				if (!searching) {
					return new MatrixValue[0];
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _fraudDao.getMatrixValues(userSessionId, params);
				} catch (Exception e) {
					setDataSize(0);
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return new MatrixValue[0];
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (!searching) {
					return 0;
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _fraudDao.getMatrixValuesCount(userSessionId, params);
				} catch (Exception e) {
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return 0;
			}
		};

		_itemSelection = new TableRowSelection<MatrixValue>(null, _matrixValuesSource);
	}

	public DaoDataModel<MatrixValue> getMatrixValues() {
		return _matrixValuesSource;
	}

	public MatrixValue getActiveMatrixValue() {
		return _activeMatrixValue;
	}

	public void setActiveMatrixValue(MatrixValue activeMatrixValue) {
		_activeMatrixValue = activeMatrixValue;
	}

	public SimpleSelection getItemSelection() {
		try {
			if (_activeMatrixValue == null && _matrixValuesSource.getRowCount() > 0) {
				setFirstRowActive();
			} else if (_activeMatrixValue != null && _matrixValuesSource.getRowCount() > 0) {
				SimpleSelection selection = new SimpleSelection();
				selection.addKey(_activeMatrixValue.getModelId());
				_itemSelection.setWrappedSelection(selection);
				_activeMatrixValue = _itemSelection.getSingleSelection();
			}
		} catch (Exception e) {
			logger.error("", e);
			FacesUtils.addMessageError(e);
		}
		return _itemSelection.getWrappedSelection();
	}

	public void setFirstRowActive() {
		_matrixValuesSource.setRowIndex(0);
		SimpleSelection selection = new SimpleSelection();
		_activeMatrixValue = (MatrixValue) _matrixValuesSource.getRowData();
		selection.addKey(_activeMatrixValue.getModelId());
		_itemSelection.setWrappedSelection(selection);

		setBeans();
	}

	public void setItemSelection(SimpleSelection selection) {
		_itemSelection.setWrappedSelection(selection);
		_activeMatrixValue = _itemSelection.getSingleSelection();
		if (_activeMatrixValue != null) {
			setBeans();
		}
	}

	public void search() {
		clearState();
		searching = true;
		getValues();
	}

	public void setBeans() {

	}

	public void clearBeansStates() {

	}

	public void fullCleanBean() {
		clearFilter();
	}

	public void clearFilter() {
		filter = null;

		clearState();
		searching = false;
	}

	public MatrixValue getFilter() {
		if (filter == null) {
			filter = new MatrixValue();
		}
		return filter;
	}

	public void setFilter(MatrixValue filter) {
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
		if (filter.getMatrixId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("matrixId");
			paramFilter.setValue(filter.getMatrixId());
			filters.add(paramFilter);
		}
		if (filter.getxValue() != null && filter.getxValue().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("xValue");
			paramFilter.setValue(filter.getxValue().trim().toUpperCase().replaceAll("[*]", "%")
					.replaceAll("[?]", "_"));
			filters.add(paramFilter);
		}
		if (filter.getyValue() != null && filter.getyValue().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("yValue");
			paramFilter.setValue(filter.getyValue().trim().toUpperCase().replaceAll("[*]", "%")
					.replaceAll("[?]", "_"));
			filters.add(paramFilter);
		}
		if (filter.getMatrixValue() != null && filter.getMatrixValue().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("matrixValue");
			paramFilter.setValue(filter.getMatrixValue().trim().toUpperCase()
					.replaceAll("[*]", "%").replaceAll("[?]", "_"));
			filters.add(paramFilter);
		}
	}

	public void add() {
		newMatrixValue = new MatrixValue();
		newMatrixValue.setMatrixId(getFilter().getMatrixId());
		curMode = NEW_MODE;
	}

	public void edit() {
		try {
			newMatrixValue = (MatrixValue) _activeMatrixValue.clone();
		} catch (CloneNotSupportedException e) {
			logger.error("", e);
			newMatrixValue = _activeMatrixValue;
		}
		curMode = EDIT_MODE;
	}

	public void save() {
		try {
			if (isNewMode()) {
				newMatrixValue = _fraudDao.addMatrixValue(userSessionId, newMatrixValue);
				_itemSelection.addNewObjectToList(newMatrixValue);
			} else if (isEditMode()) {
				newMatrixValue = _fraudDao.modifyMatrixValue(userSessionId, newMatrixValue);
				_matrixValuesSource.replaceObject(_activeMatrixValue, newMatrixValue);
			}
			_activeMatrixValue = newMatrixValue;
			setBeans();
			curMode = VIEW_MODE;
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void delete() {
		try {
			_fraudDao.removeMatrixValue(userSessionId, _activeMatrixValue);
			_activeMatrixValue = _itemSelection.removeObjectFromList(_activeMatrixValue);

			if (_activeMatrixValue == null) {
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

	public MatrixValue getNewMatrixValue() {
		if (newMatrixValue == null) {
			newMatrixValue = new MatrixValue();
		}
		return newMatrixValue;
	}

	public void setNewMatrixValue(MatrixValue newMatrixValue) {
		this.newMatrixValue = newMatrixValue;
	}

	public void clearState() {
		_itemSelection.clearSelection();
		_activeMatrixValue = null;
		_matrixValuesSource.flushCache();

		columnNames = null;
		matrixCells = null;
		editMatrixCells = null;
		columnsNumber = null;
		rowsNumber = null;
		xScale = null;
		yScale = null;

		clearBeansStates();
	}

	public List<SelectItem> getEventTypes() {
		return getDictUtils().getLov(LovConstants.FRAUD_EVENT_TYPES);
	}


	public void getValues() {
		if (getFilter().getMatrixId() == null) return;
		
		MatrixValue[] values = null;
		try {
			setFilters();
			SelectionParams params = new SelectionParams();
			params.setFilters(filters.toArray(new Filter[filters.size()]));
			params.setRowIndexEnd(Integer.MAX_VALUE);
			values = _fraudDao.getMatrixValues(userSessionId, params);
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
			return;
		}
		
		try {
			columnNames = new ArrayList<String>();
			columnNamesToIndices = new HashMap<String, Integer>();
			columnIndicesToNames = new HashMap<Integer, String>();
			ArrayList<String> rowsList = new ArrayList<String>();
	
			// form list of column names (xValue of MatrixValue)
			for (MatrixValue value: values) {
				if (columnNamesToIndices.get(value.getxValue()) == null) {
	//				Column newCol = new Column(value.getxValue());
	//				columns.add(newCol);
					columnNames.add(value.getxValue());
					columnNamesToIndices.put(value.getxValue(), columnNames.indexOf(value.getxValue()));
				}
				if (rowsList.indexOf(value.getyValue()) < 0) {
					rowsList.add(value.getyValue());
				}
			}
	
			columnsNumber = columnNames.size();
			rowsNumber = rowsList.size();
			
			// sort columns 
			for (int i = 0; i < columnNames.size(); i++) {
				for (int j = i + 1; j < columnNames.size(); j++) {
					if (columnNames.get(i).compareTo(columnNames.get(j)) > 0) {
						String tmp = columnNames.remove(i);
						columnNames.add(i, columnNames.remove(j - 1));
						columnNames.add(j, tmp);
					}
				}
			}
	
			// put new sorted column names into map; increase index by 1 
			// because first column will be column with row name
			for (int i = 0; i < columnNames.size(); i++) {
				columnNamesToIndices.put(columnNames.get(i), i + 1);
				columnIndicesToNames.put(i + 1, columnNames.get(i));
			}
	
			matrixCells = new ArrayList<ArrayList<MatrixValue>>(rowsList.size());
	
			// initialize matrixCells to get random access to any of it's
			// elements an so that the system don't fall with 
			// NullPointerException when user tries to save edited matrix 
			for (int i = 0; i < rowsList.size(); i++) {
				ArrayList<MatrixValue> newMatrixRow = new ArrayList<MatrixValue>(columnNames.size() + 1);
				for (int j = 0; j < columnNames.size() + 1; j++) {
					newMatrixRow.add(new MatrixValue(filter.getMatrixId()));
				}
				matrixCells.add(newMatrixRow);
			}
	
			int i = -1;
			String rowName = "";
			
			// insert real values, this works correctly only if values are sorted by yValue
			for (MatrixValue value: values) {
				if (!value.getyValue().equals(rowName)) {
					i++;
					
					// first value of each array is row name (yValue of MatrixValue)
					rowName = value.getyValue();
					MatrixValue firstCell = new MatrixValue();
					firstCell.setMatrixValue(rowName);
					matrixCells.get(i).remove(0);	// remove preinitialized value
					matrixCells.get(i).add(0, firstCell);	// add new value
				}
				matrixCells.get(i).remove(columnNamesToIndices.get(value.getxValue()).intValue());
				matrixCells.get(i).add(columnNamesToIndices.get(value.getxValue()), value);
			}
		} catch (Exception e){
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}

//		System.out.print(" \t");
//		for (String col: columnNames) {
//			System.out.print(col + "\t");
//		}
//		System.out.println();
//		for (ArrayList<MatrixValue> x: matrixCells) {
//			for (MatrixValue y: x) {
//				System.out.print(y.getMatrixValue() + "\t");
//			}
//			System.out.println();
//		}
	}

	public void editCell() {
		curMode = EDIT_MODE;
	}

	public void saveCell() {
		if (newMatrixValue == null) {
			curMode = VIEW_MODE;
			return;
		}
		
		try {
			if (newMatrixValue.getId() == null) {
				_fraudDao.addMatrixValue(userSessionId, newMatrixValue);
			} else {
				if (newMatrixValue.getMatrixValue() == null || newMatrixValue.getMatrixValue().trim().length() == 0) {
					_fraudDao.removeMatrixValue(userSessionId, newMatrixValue);
				} else {
					_fraudDao.modifyMatrixValue(userSessionId, newMatrixValue);
				}
			}

			getValues();
			curMode = VIEW_MODE;
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void clearCell() {
		if (newMatrixValue.getId() == null) {
			return;
		}
		
		try {
			_fraudDao.removeMatrixValue(userSessionId, newMatrixValue);

			clearState();
			getValues();

			curMode = VIEW_MODE;
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}
	
	public void editMatrix() {
		editMatrixCells = new ArrayList<ArrayList<MatrixValue>>(matrixCells.size());
		for (ArrayList<MatrixValue> row: matrixCells) {
			ArrayList<MatrixValue> newRow = new ArrayList<MatrixValue>(row.size());
			for (MatrixValue cell: row) {
				if (cell != null) {
					try {
						newRow.add((MatrixValue) cell.clone());
					} catch (CloneNotSupportedException e) {
						newRow.add(cell);
					}
				} else {
					newRow.add(null);
				}
			}
			editMatrixCells.add(newRow);
		}

		curMode = EDIT_MODE;
	}

	public void saveNewMatrixValue() {
		try {
			_fraudDao.addMatrixValue(userSessionId, newMatrixValue);

			_matrixValuesSource.flushCache();

			getValues();
			curMode = VIEW_MODE;
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void saveMatrix() {
		ArrayList<MatrixValue> editedValues = new ArrayList<MatrixValue>();
		ArrayList<MatrixValue> newValues = new ArrayList<MatrixValue>();
		ArrayList<MatrixValue> deletedValues = new ArrayList<MatrixValue>();
		for (int i = 0; i < editMatrixCells.size(); i++) {
			for (int j = 1; j < editMatrixCells.get(i).size(); j++) {
				if (matrixCells.get(i).get(j).getId() == null
						&& editMatrixCells.get(i).get(j).getMatrixValue() != null
						&& editMatrixCells.get(i).get(j).getMatrixValue().trim().length() > 0) {
					MatrixValue newValue = editMatrixCells.get(i).get(j);
					newValue.setxValue(columnIndicesToNames.get(j));
					newValue.setyValue(matrixCells.get(i).get(0).getMatrixValue());
					newValue.setMatrixId(getFilter().getMatrixId());
					newValues.add(newValue);
				} else if (matrixCells.get(i).get(j).getId() != null) {
					if (editMatrixCells.get(i).get(j).getMatrixValue() == null
							|| editMatrixCells.get(i).get(j).getMatrixValue().trim().length() == 0) {
						deletedValues.add(editMatrixCells.get(i).get(j));
					} else if (!editMatrixCells.get(i).get(j).getMatrixValue().equals(
								matrixCells.get(i).get(j).getMatrixValue())) {
						editedValues.add(editMatrixCells.get(i).get(j));
					}
				}
			}
		}
		
		try {
			_fraudDao.saveMatrixValues(userSessionId, newValues, editedValues, deletedValues);
			
			getValues();
		} catch (Exception e) {
			logger.error("", e);
			FacesUtils.addMessageError(e);
		}
	}

	public ArrayList<String> getColumnNames() {
		if (columnNames == null) {
			columnNames = new ArrayList<String>(0);
		}
		return columnNames;
	}

	public void setColumnNames(ArrayList<String> columnNames) {
		this.columnNames = columnNames;
	}

	public ArrayList<ArrayList<MatrixValue>> getMatrixCells() {
		return matrixCells;
	}

	public void setMatrixCells(ArrayList<ArrayList<MatrixValue>> matrixCells) {
		this.matrixCells = matrixCells;
	}

	public ArrayList<ArrayList<MatrixValue>> getEditMatrixCells() {
		return editMatrixCells;
	}

	public void setEditMatrixCells(ArrayList<ArrayList<MatrixValue>> editMatrixCells) {
		this.editMatrixCells = editMatrixCells;
	}

	public Integer getColumnsNumber() {
		return columnsNumber;
	}

	public void setColumnsNumber(Integer columnsNumber) {
		this.columnsNumber = columnsNumber;
	}

	public Integer getRowsNumber() {
		return rowsNumber;
	}

	public void setRowsNumber(Integer rowsNumber) {
		this.rowsNumber = rowsNumber;
	}

	public String getxScale() {
		return xScale;
	}

	public void setxScale(String xScale) {
		this.xScale = xScale;
	}

	public String getyScale() {
		return yScale;
	}

	public void setyScale(String yScale) {
		this.yScale = yScale;
	}
	
	

}
