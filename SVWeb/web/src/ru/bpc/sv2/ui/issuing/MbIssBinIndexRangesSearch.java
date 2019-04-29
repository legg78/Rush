package ru.bpc.sv2.ui.issuing;

import java.util.ArrayList;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.RequestScoped;
import javax.faces.event.ValueChangeEvent;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;

import org.ajax4jsf.model.KeepAlive;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.invocation.Filter.Operator;
import ru.bpc.sv2.issuing.IssuerBinIndexRange;
import ru.bpc.sv2.logic.IssuingDao;
import ru.bpc.sv2.ui.rules.naming.MbNameIndexRangesSearch;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.TableRowSelection;
import util.auxil.ManagedBeanWrapper;

@RequestScoped
@KeepAlive
@ManagedBean(name = "MbIssBinIndexRangesSearch")
public class MbIssBinIndexRangesSearch extends AbstractBean {
	private static final Logger logger = Logger.getLogger("ISSUING");

	private IssuingDao _issuingDao = new IssuingDao();

	

	private Integer instId;
	private String entityType;

	private IssuerBinIndexRange filter;
	private IssuerBinIndexRange _activeBinIndexRange;
	private IssuerBinIndexRange newBinIndexRange;
	private boolean alg;

	private final DaoDataModel<IssuerBinIndexRange> _binIndexRangesSource;
	private final TableRowSelection<IssuerBinIndexRange> _itemSelection;

	private static String COMPONENT_ID = "mainTable";
	private String tabName;
	private String parentSectionId;
	
	public MbIssBinIndexRangesSearch() {
		

		_binIndexRangesSource = new DaoDataModel<IssuerBinIndexRange>() {
			@Override
			protected IssuerBinIndexRange[] loadDaoData(SelectionParams params) {
				if (!searching) {
					return new IssuerBinIndexRange[0];
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _issuingDao.getIssBinIndexRanges(userSessionId, params);
				} catch (Exception e) {
					setDataSize(0);
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return new IssuerBinIndexRange[0];
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (!searching) {
					return 0;
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _issuingDao.getIssBinIndexRangesCount(userSessionId, params);
				} catch (Exception e) {
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return 0;
			}
		};

		_itemSelection = new TableRowSelection<IssuerBinIndexRange>(null, _binIndexRangesSource);
	}

	public DaoDataModel<IssuerBinIndexRange> getRanges() {
		return _binIndexRangesSource;
	}

	public IssuerBinIndexRange getActiveBinIndexRange() {
		return _activeBinIndexRange;
	}

	public void setActiveBinIndexRange(IssuerBinIndexRange activeBinIndexRange) {
		_activeBinIndexRange = activeBinIndexRange;
	}

	public SimpleSelection getItemSelection() {
		if (_activeBinIndexRange == null && _binIndexRangesSource.getRowCount() > 0) {
			setFirstRowActive();
		} else if (_activeBinIndexRange != null && _binIndexRangesSource.getRowCount() > 0) {
			SimpleSelection selection = new SimpleSelection();
			selection.addKey(_activeBinIndexRange.getModelId());
			_itemSelection.setWrappedSelection(selection);
			_activeBinIndexRange = _itemSelection.getSingleSelection();
		}
		return _itemSelection.getWrappedSelection();
	}

	public void setFirstRowActive() {
		_binIndexRangesSource.setRowIndex(0);
		SimpleSelection selection = new SimpleSelection();
		_activeBinIndexRange = (IssuerBinIndexRange) _binIndexRangesSource.getRowData();
		selection.addKey(_activeBinIndexRange.getModelId());
		_itemSelection.setWrappedSelection(selection);
		if (_activeBinIndexRange != null) {
			setInfo();
		}
	}

	public void setItemSelection(SimpleSelection selection) {
		_itemSelection.setWrappedSelection(selection);
		_activeBinIndexRange = _itemSelection.getSingleSelection();
		if (_activeBinIndexRange != null) {
			setInfo();
		}
	}

	public void setInfo() {
//		MbNameComponentsSearch compSearch = (MbNameComponentsSearch)ManagedBeanWrapper.getManagedBean("MbNameComponentsSearch");
//		NameComponent componentFilter = new NameComponent();
//		componentFilter.setFormatId(_activeFormat.getId());
//		compSearch.setFilter(componentFilter);
//		
//		NameBaseParam baseParamFilter = new NameBaseParam();
//		baseParamFilter.setEntityType(_activeFormat.getEntityType());
//		compSearch.setBaseParamFilter(baseParamFilter);
//		compSearch.setBaseValues(null);
//		compSearch.search();
	}

	public void search() {
		clearState();
		searching = true;
	}

	public void clearFilter() {
		filter = new IssuerBinIndexRange();
		clearState();
		searching = false;
	}

	public IssuerBinIndexRange getFilter() {
		if (filter == null)
			filter = new IssuerBinIndexRange();
		return filter;
	}

	public void setFilter(IssuerBinIndexRange filter) {
		this.filter = filter;
	}

	private void setFilters() {
		filter = getFilter();
		filters = new ArrayList<Filter>();

		Filter paramFilter = new Filter();
		paramFilter.setElement("lang");
		paramFilter.setOp(Operator.eq);
		paramFilter.setValue(curLang);
		filters.add(paramFilter);

		if (filter.getId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("id");
			paramFilter.setOp(Operator.like);
			paramFilter.setValue(filter.getId() + "%");
			filters.add(paramFilter);
		}

		if (filter.getBinId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("binId");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(filter.getBinId());
			filters.add(paramFilter);
		}

		if (filter.getBinIndexRangeId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("binIndexRangeId");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(filter.getBinIndexRangeId());
			filters.add(paramFilter);
		}
	}

	public void add() {
		newBinIndexRange = new IssuerBinIndexRange();
		newBinIndexRange.setBinId(getFilter().getBinId());
		newBinIndexRange.setLang(userLang);

		MbNameIndexRangesSearch rangesBean = (MbNameIndexRangesSearch) ManagedBeanWrapper
				.getManagedBean("MbNameIndexRangesSearch");
		rangesBean.add();
		rangesBean.getNewIndexRange().setEntityType(entityType);
		rangesBean.getNewIndexRange().setInstId(instId);
		
		curMode = NEW_MODE;
	}

	public void edit() {
		try {
			newBinIndexRange = (IssuerBinIndexRange) _activeBinIndexRange.clone();
		} catch (CloneNotSupportedException e) {
			logger.error("", e);
			newBinIndexRange = _activeBinIndexRange;
		}
		MbNameIndexRangesSearch rangesBean = (MbNameIndexRangesSearch) ManagedBeanWrapper
				.getManagedBean("MbNameIndexRangesSearch");
		rangesBean.setActiveIndexRange(_activeBinIndexRange.getNameIndexRange());
		rangesBean.edit();
		curMode = EDIT_MODE;
	}

	public void view() {

	}

	public String saveRange() {
		try {
			alg = true;
			MbNameIndexRangesSearch rangesBean = (MbNameIndexRangesSearch) ManagedBeanWrapper
					.getManagedBean("MbNameIndexRangesSearch");
			rangesBean.checkValues();
			if(rangesBean.isRandom() || rangesBean.isSequential()){
				alg = false;
				return "";
			}
			newBinIndexRange.setNameIndexRange(rangesBean.getNewIndexRange());

			if (isNewMode()) {
				newBinIndexRange = _issuingDao.addIssBinIndexRange(userSessionId, newBinIndexRange,
						userLang);
				_itemSelection.addNewObjectToList(newBinIndexRange);
			} else if (isEditMode()) {
				newBinIndexRange = _issuingDao.modifyIssBinIndexRange(userSessionId,
						newBinIndexRange, userLang);
				_binIndexRangesSource.replaceObject(_activeBinIndexRange, newBinIndexRange);
			}
			_activeBinIndexRange = newBinIndexRange;
			curMode = VIEW_MODE;
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
		return null;
	}
	
	public String saveRangeFromMes() {
		try {
			MbNameIndexRangesSearch rangesBean = (MbNameIndexRangesSearch) ManagedBeanWrapper
					.getManagedBean("MbNameIndexRangesSearch");			
			newBinIndexRange.setNameIndexRange(rangesBean.getNewIndexRange());

			if (isNewMode()) {
				newBinIndexRange = _issuingDao.addIssBinIndexRange(userSessionId, newBinIndexRange,
						userLang);
				_itemSelection.addNewObjectToList(newBinIndexRange);
			} else if (isEditMode()) {
				newBinIndexRange = _issuingDao.modifyIssBinIndexRange(userSessionId,
						newBinIndexRange, userLang);
				_binIndexRangesSource.replaceObject(_activeBinIndexRange, newBinIndexRange);
			}
			_activeBinIndexRange = newBinIndexRange;
			curMode = VIEW_MODE;
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
		return null;
	}

	public void delete() {
		try {
			_issuingDao.deleteIssBinIndexRange(userSessionId, _activeBinIndexRange);

			_activeBinIndexRange = _itemSelection.removeObjectFromList(_activeBinIndexRange);
			if (_activeBinIndexRange == null) {
				clearState();
			} else {
				setInfo();
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

	public void cancelRange() {
		curMode = VIEW_MODE;
	}

	public IssuerBinIndexRange getNewBinIndexRange() {
		if (newBinIndexRange == null) {
			newBinIndexRange = new IssuerBinIndexRange();
		}
		return newBinIndexRange;
	}

	public void setNewBinIndexRange(IssuerBinIndexRange newBinIndexRange) {
		this.newBinIndexRange = newBinIndexRange;
	}

	public void clearState() {
		_itemSelection.clearSelection();
		_activeBinIndexRange = null;
		_binIndexRangesSource.flushCache();
		curLang = userLang;
	}

	public void fullCleanBean() {
		instId = null;
		entityType = null;
		clearFilter();
	}

	public void changeLanguage(ValueChangeEvent event) {
		curLang = (String) event.getNewValue();

		Filter[] filters = new Filter[2];
		filters[0] = new Filter();
		filters[0].setElement("id");
		filters[0].setValue(_activeBinIndexRange.getId().toString());
		filters[1] = new Filter();
		filters[1].setElement("lang");
		filters[1].setValue(curLang);

		SelectionParams params = new SelectionParams();
		params.setFilters(filters);
		try {
			IssuerBinIndexRange[] binIndexRanges = _issuingDao.getIssBinIndexRanges(userSessionId,
					params);
			if (binIndexRanges != null && binIndexRanges.length > 0) {
				_activeBinIndexRange = binIndexRanges[0];
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public Integer getInstId() {
		return instId;
	}

	public void setInstId(Integer instId) {
		this.instId = instId;
	}

	public String getEntityType() {
		return entityType;
	}

	public void setEntityType(String entityType) {
		this.entityType = entityType;
	}
	
	public boolean getAlg(){
		return alg;
	}
	
	public void setAlg(boolean alg){
		this.alg = alg;
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
