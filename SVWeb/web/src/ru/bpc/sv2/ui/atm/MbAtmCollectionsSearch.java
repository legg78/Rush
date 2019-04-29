package ru.bpc.sv2.ui.atm;

import java.util.ArrayList;
import java.util.List;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;

import ru.bpc.sv2.atm.AtmCollection;
import ru.bpc.sv2.atm.AtmCollectionDispenser;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.Filter.Operator;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.AtmDao;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.TableRowSelection;

/**
 * Manage Bean for List ATM collections bottom tab.
 */
@ViewScoped
@ManagedBean(name = "MbAtmCollectionsSearch")
public class MbAtmCollectionsSearch extends AbstractBean {
	private static final Logger logger = Logger.getLogger("ATM");

	private AtmDao _atmDao = new AtmDao();

	private AtmCollection _activeCollection;
	private AtmCollectionDispenser _activeCollectionDispenser;
	private AtmCollection newCollection;

	
	private AtmCollection collectionFilter;
	private AtmCollectionDispenser collectionDispenserFilter;
	
	private List<Filter> filtersDispenser = null;
	
	private boolean searchingDispenser;
	
	private boolean selectMode;

	private final DaoDataModel<AtmCollection> _collectionsSource;

	private final TableRowSelection<AtmCollection> _collectionSelection;
	
	private final DaoDataModel<AtmCollectionDispenser> _collectionDispensersSource;

	private final TableRowSelection<AtmCollectionDispenser> _collectionDispenserSelection;
	
	private static String COMPONENT_ID = "collectionsTable";
	private String tabName;
	private String parentSectionId;

	public MbAtmCollectionsSearch() {
		

		_collectionsSource = new DaoDataModel<AtmCollection>() {
			@Override
			protected AtmCollection[] loadDaoData(SelectionParams params) {
				if (!isSearching())
					return new AtmCollection[0];
				try {
					setCollectionsFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _atmDao.getAtmCollections(userSessionId, params);
				} catch (Exception e) {
					setDataSize(0);
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return new AtmCollection[0];
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (!isSearching())
					return 0;
				try {
					setCollectionsFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _atmDao.getAtmCollectionsCount(userSessionId, params);
				} catch (Exception e) {
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return 0;
			}
		};
		_collectionSelection = new TableRowSelection<AtmCollection>(null, _collectionsSource);
		
		_collectionDispensersSource = new DaoDataModel<AtmCollectionDispenser>() {
			@Override
			protected AtmCollectionDispenser[] loadDaoData(SelectionParams params) {
				if (!searchingDispenser)
					return new AtmCollectionDispenser[0];
				try {
					setCollectionDispensersFilters();
					params.setFilters(filtersDispenser.toArray(new Filter[filtersDispenser.size()]));
					return _atmDao.getAtmCollectionDispensers(userSessionId, params);
				} catch (Exception e) {
					setDataSize(0);
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return new AtmCollectionDispenser[0];
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (!searchingDispenser)
					return 0;
				try {
					setCollectionDispensersFilters();
					params.setFilters(filtersDispenser.toArray(new Filter[filtersDispenser.size()]));
					return _atmDao.getAtmCollectionDispensersCount(userSessionId, params);
				} catch (Exception e) {
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return 0;
			}
		};
		_collectionDispenserSelection = new TableRowSelection<AtmCollectionDispenser>(null, _collectionDispensersSource);
	}

	public DaoDataModel<AtmCollection> getCollections() {
		return _collectionsSource;
	}

	public AtmCollection getActiveCollection() {
		return _activeCollection;
	}

	public void setActiveCollection(AtmCollection activeCollection) {
		this._activeCollection = activeCollection;
	}

	public SimpleSelection getCollectionSelection() {
		if (_activeCollection == null && _collectionsSource.getRowCount() > 0) {
			setFirstRowActive();
		}
		else if (_activeCollection != null && _collectionsSource.getRowCount() > 0)
		{
			SimpleSelection selection = new SimpleSelection();
			selection.addKey(_activeCollection.getModelId());
			_collectionSelection.setWrappedSelection(selection);
			_activeCollection = _collectionSelection.getSingleSelection();			
		}
		return _collectionSelection.getWrappedSelection();
	}
	
	public void setFirstRowActive() {
		_collectionsSource.setRowIndex(0);
		SimpleSelection selection = new SimpleSelection();
		_activeCollection = (AtmCollection) _collectionsSource.getRowData();
		selection.addKey(_activeCollection.getModelId());
		_collectionSelection.setWrappedSelection(selection);
		if (_activeCollection != null) {
			setBeans();
		}
	}
	
	public void setBeans() {
		AtmCollectionDispenser collectionDispenserFilter = new AtmCollectionDispenser();
		collectionDispenserFilter.setCollectionId(_activeCollection.getId());
		setCollectionDispenserFilter(collectionDispenserFilter);
		searchCollectionDispensers();
	}

	public void setCollectionSelection(SimpleSelection selection) {
		_collectionSelection.setWrappedSelection(selection);
		_activeCollection = _collectionSelection.getSingleSelection();
		if (_activeCollection != null) {
			setBeans();
		}
	}

	public void search() {
		clearBean();
		searching = true;
	}
	

	public void clearFilter() {
		collectionFilter = null;
		clearBean();
	}

	public void clearBean() {
		searching = false;
		curLang = userLang;
		_collectionsSource.flushCache();
		if (_collectionSelection != null) {
			_collectionSelection.clearSelection();
		}
		_activeCollection = null;
		clearFilterDispenser();
	}

	public void setCollectionsFilters() {
		List<Filter> filtersList = new ArrayList<Filter>();
		
		if (getCollectionFilter().getId() != null) {
			Filter paramFilter = new Filter();
			paramFilter.setElement("id");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(getCollectionFilter().getId());
			filtersList.add(paramFilter);
		}
		
		if (getCollectionFilter().getTerminalId() != null) {
			Filter paramFilter = new Filter();
			paramFilter.setElement("terminalId");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(getCollectionFilter().getTerminalId());
			filtersList.add(paramFilter);
		}
		
		if (getCollectionFilter().getStartDate() != null){
			Filter f = new Filter();
			f.setElement("startDate");
			f.setValue(getCollectionFilter().getStartDate());
			filtersList.add(f);
		}
		
		if (getCollectionFilter().getEndDate() != null){
			Filter f = new Filter();
			f.setElement("endDate");
			f.setValue(getCollectionFilter().getEndDate());
			filtersList.add(f);
		}
		
		Filter paramFilter = new Filter();
		paramFilter.setElement("lang");
		paramFilter.setOp(Operator.eq);
		paramFilter.setValue(curLang);
		filtersList.add(paramFilter);
		filters = filtersList;
	}

	public AtmCollection getCollectionFilter() {
		if (collectionFilter == null)
			collectionFilter = new AtmCollection();
		return collectionFilter;
	}

	public void setCollectionFilter(AtmCollection collectionFilter) {
		this.collectionFilter = collectionFilter;
	}

	public boolean isSelectMode() {
		return selectMode;
	}

	public void setSelectMode(boolean selectMode) {
		this.selectMode = selectMode;
	}

	public AtmCollection getNewCollection() {
		return newCollection;
	}

	public void setNewCollection(AtmCollection newCollection) {
		this.newCollection = newCollection;
	}
	
	public void add() {
		newCollection = new AtmCollection();
		newCollection.setTerminalId(getCollectionFilter().getTerminalId());
		curMode = NEW_MODE;
	}
	
	public void edit() {
		try {
			newCollection = (AtmCollection) _activeCollection.clone();
		} catch (CloneNotSupportedException e) {
			logger.error("", e);
			newCollection = _activeCollection;
		}
		curMode = EDIT_MODE;
	}

	public void save() {
		try {			
			if (isEditMode()) {				
			} else {				
			}			
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);

		}
	}

	public void delete() {
		try {			
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void cancel() {
		
	}
	
	public DaoDataModel<AtmCollectionDispenser> getCollectionDispensers() {
		return _collectionDispensersSource;
	}

	public AtmCollectionDispenser getActiveCollectionDispenser() {
		return _activeCollectionDispenser;
	}

	public void setActiveCollectionDispenser(AtmCollectionDispenser activeCollectionDispenser) {
		this._activeCollectionDispenser = activeCollectionDispenser;
	}

	public SimpleSelection getCollectionDispenserSelection() {
		if (_activeCollectionDispenser == null && _collectionDispensersSource.getRowCount() > 0) {
			setFirstRowActiveDispenser();
		}
		else if (_activeCollectionDispenser != null && _collectionDispensersSource.getRowCount() > 0)
		{
			SimpleSelection selection = new SimpleSelection();
			selection.addKey(_activeCollectionDispenser.getModelId());
			_collectionDispenserSelection.setWrappedSelection(selection);
			_activeCollectionDispenser = _collectionDispenserSelection.getSingleSelection();			
		}
		return _collectionDispenserSelection.getWrappedSelection();
	}
	
	public void setFirstRowActiveDispenser() {
		_collectionDispensersSource.setRowIndex(0);
		SimpleSelection selection = new SimpleSelection();
		_activeCollectionDispenser = (AtmCollectionDispenser) _collectionDispensersSource.getRowData();
		selection.addKey(_activeCollectionDispenser.getModelId());
		_collectionDispenserSelection.setWrappedSelection(selection);
		if (_activeCollectionDispenser != null) {
			
		}
	}
	
	public void setCollectionDispenserSelection(SimpleSelection selection) {
		_collectionDispenserSelection.setWrappedSelection(selection);
		_activeCollectionDispenser = _collectionDispenserSelection.getSingleSelection();
		if (_activeCollectionDispenser != null) {
			
		}
	}

	public void searchCollectionDispensers() {
		clearBeanDispenser();
		searchingDispenser = true;
	}
	

	public void clearFilterDispenser() {
		collectionDispenserFilter = null;
		clearBeanDispenser();
	}

	public void clearBeanDispenser() {
		searchingDispenser = false;
		_collectionDispensersSource.flushCache();
		if (_collectionDispenserSelection != null) {
			_collectionDispenserSelection.clearSelection();
		}
		_activeCollectionDispenser = null;
	}

	public void setCollectionDispensersFilters() {
		List<Filter> filtersList = new ArrayList<Filter>();
		
		if (getCollectionDispenserFilter().getId() != null) {
			Filter paramFilter = new Filter();
			paramFilter.setElement("id");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(getCollectionDispenserFilter().getId());
			filtersList.add(paramFilter);
		}
		
		if (getCollectionDispenserFilter().getCollectionId() != null) {
			Filter paramFilter = new Filter();
			paramFilter.setElement("collectionId");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(getCollectionDispenserFilter().getCollectionId());
			filtersList.add(paramFilter);
		}
		
		Filter paramFilter = new Filter();
		paramFilter.setElement("lang");
		paramFilter.setOp(Operator.eq);
		paramFilter.setValue(curLang);
		filtersList.add(paramFilter);
		filtersDispenser = filtersList;
	}

	public AtmCollectionDispenser getCollectionDispenserFilter() {
		if (collectionDispenserFilter == null)
			collectionDispenserFilter = new AtmCollectionDispenser();
		return collectionDispenserFilter;
	}

	public void setCollectionDispenserFilter(AtmCollectionDispenser collectionDispenserFilter) {
		this.collectionDispenserFilter = collectionDispenserFilter;
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
