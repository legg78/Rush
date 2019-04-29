package ru.bpc.sv2.ui.network;

import java.util.ArrayList;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;

import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.Filter.Operator;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.NetworkDao;
import ru.bpc.sv2.net.BinRange;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.TableRowSelection;

@ViewScoped
@ManagedBean (name = "MbBinRanges")
public class MbBinRanges extends AbstractBean {
	
	private static final Logger logger = Logger.getLogger("NETWORKS");
	
	private static String COMPONENT_ID = "1233:binRangesTable";

	private NetworkDao _networksDao = new NetworkDao();
	
    private BinRange binRangeFilter;
    private BinRange _activeBinRange;
    private BinRange newBinRange;
    private String binNumber;
    
	private final DaoDataModel<BinRange> _binRangeSource;

	private final TableRowSelection<BinRange> _itemSelection;

	public MbBinRanges() {
		
		pageLink = "net|binranges";
		_binRangeSource = new DaoDataModel<BinRange>()
		{
			@Override
			protected BinRange[] loadDaoData(SelectionParams params) {
				if (!searching) {
					return new BinRange[0];
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _networksDao.getBinRanges( userSessionId, params);
				} catch (Exception e) {
					setDataSize(0);
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return new BinRange[0];
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (!searching) {
					return 0;
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _networksDao.getBinRangesCount( userSessionId, params);
				} catch (Exception e) {
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return 0;
			}
		};

		_itemSelection = new TableRowSelection<BinRange>( null, _binRangeSource);
    }

    public DaoDataModel<BinRange> getBinRanges() {
		return _binRangeSource;
	}

	public BinRange getActiveBinRange() {
		return _activeBinRange;
	}

	public void setActiveBinRange(BinRange activeBinRange) {
		_activeBinRange = activeBinRange;
	}

	public SimpleSelection getItemSelection() {
		if (_activeBinRange == null && _binRangeSource.getRowCount() > 0) {
			setFirstRowActive();
		}
		return _itemSelection.getWrappedSelection();
	}

	public void setItemSelection(SimpleSelection selection) {
		_itemSelection.setWrappedSelection( selection );
		_activeBinRange = _itemSelection.getSingleSelection();

		// set entry templates
		if (_activeBinRange != null) {
			setBeans();
		}
	}

	public void setFirstRowActive() {
		_binRangeSource.setRowIndex(0);
		SimpleSelection selection = new SimpleSelection();
		_activeBinRange = (BinRange) _binRangeSource.getRowData();
		selection.addKey(_activeBinRange.getModelId());
		_itemSelection.setWrappedSelection(selection);
		if (_activeBinRange != null) {
			setBeans();
		}
	}

	/**
	 * Sets data for backing beans used by dependent pages
	 */
	public void setBeans() {
	}
	
	public void clearFilter() {
		binRangeFilter = new BinRange();
		curLang = userLang;
		binNumber = null;
		
		clearBean();
		
		searching = false;
	}

	public String search() {
		curMode = VIEW_MODE;
		
		clearBean();
		searching = true;

		return "";
	}

	private void setFilters() {
		binRangeFilter = getFilter();
		filters = new ArrayList<Filter>();

		Filter paramFilter;
		if (binNumber != null && binNumber.trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("bin");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(binNumber);
			filters.add(paramFilter);
		}

	}

	public BinRange getFilter() {
		if (binRangeFilter == null)
			binRangeFilter = new BinRange();
		return binRangeFilter;
	}

	public void setFilter(BinRange filter) {
		this.binRangeFilter = filter;
	}

	public void add() {
		newBinRange = new BinRange();
		newBinRange.setLang(userLang);
		curMode = NEW_MODE;
	}

	public void edit() {
		curMode = EDIT_MODE;
	}

	public void save() {
		try {
			if (isEditMode()) {
//				_networksDao.editBinRange( userSessionId, newBinRange);
			} else {
//				_networksDao.addBinRange( userSessionId, newBinRange);
			}
			curMode = VIEW_MODE;
			_binRangeSource.flushCache();
			
			//TODO: i18n
			FacesUtils.addMessageInfo("Bin range has been saved.");
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("",e);
		}
	}

	public void delete() {
		try {
//			_networksDao.removeBinRange( userSessionId, _activeBinRange);
			curMode = VIEW_MODE;
			_activeBinRange = null;
			_binRangeSource.flushCache();

		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("",e);
		}
	}

	public void close() {
		curMode = VIEW_MODE;

	}

	public BinRange getNewBinRange() {
		if (newBinRange == null) {
			newBinRange = new BinRange();
		}
		return newBinRange;
	}

	public void setNewBinRange(BinRange newBinRange) {
		this.newBinRange = newBinRange;
	}

	public void clearBean() {
		if (_activeBinRange != null) {
			if (_itemSelection != null) {
				_itemSelection.unselect(_activeBinRange);
			}
			_activeBinRange = null;
		}
		_binRangeSource.flushCache();
	}

	public String getBinNumber() {
		return binNumber;
	}

	public void setBinNumber(String binNumber) {
		this.binNumber = binNumber;
	}

	public String getComponentId() {
		return COMPONENT_ID;
	}

	public Logger getLogger() {
		return logger;
	}

}
