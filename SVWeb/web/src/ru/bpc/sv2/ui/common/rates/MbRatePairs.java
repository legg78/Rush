package ru.bpc.sv2.ui.common.rates;

import java.util.ArrayList;

import java.util.HashMap;
import java.util.List;
import java.util.Map;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.RequestScoped;
import javax.faces.event.ValueChangeEvent;
import javax.faces.model.SelectItem;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;

import org.ajax4jsf.model.KeepAlive;
import ru.bpc.sv2.common.rates.RatePair;
import ru.bpc.sv2.constants.DictNames;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.invocation.Filter.Operator;
import ru.bpc.sv2.logic.CommonDao;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.TableRowSelection;

@RequestScoped
@KeepAlive
@ManagedBean (name = "MbRatePairs")
public class MbRatePairs extends AbstractBean{
	private static final long serialVersionUID = 1L;

	private static final Logger logger = Logger.getLogger("COMMON");
	
	private CommonDao _commonDao = new CommonDao();

	private RatePair ratePairFilter;
	private RatePair newRatePair;
	private ArrayList<SelectItem> institutions;
	private ArrayList<SelectItem> inputModes;
    
    private final DaoDataModel<RatePair> _ratePairsSource;
	private final TableRowSelection<RatePair> _itemSelection;
	private RatePair _activeRatePair;

	private static String COMPONENT_ID = "ratePairsTable";
	private String tabName;
	private String parentSectionId;
	
	public MbRatePairs() {
		_ratePairsSource = new DaoDataModel<RatePair>() {
			private static final long serialVersionUID = 1L;

			@Override
			protected RatePair[] loadDaoData(SelectionParams params) {
				if (!searching) {
					return new RatePair[0];
				}
				try {
					setFilters();				
					params.setFilters(filters.toArray(new Filter[filters.size()]));				
					return _commonDao.getRatePairs( userSessionId, params);
				} catch (Exception e) {
					setDataSize(0);
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return new RatePair[0];
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (!searching) {
					return 0;
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _commonDao.getRatePairsCount( userSessionId, params);
				} catch (Exception e) {
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return 0;
			}
		};

		_itemSelection = new TableRowSelection<RatePair>(null, _ratePairsSource);

//		_ratePairsRevSource = new DaoDataModel<RatePair>()
//		{
//			@Override
//			protected RatePair[] loadDaoData(SelectionParams params) {
//				if (!searching) {
//					return new RatePair[0];
//				}
//				setFilters();
//				if (baseRateType != null) {
//					Filter paramFilter = new Filter();
//					paramFilter.setElement("baseRateType");
//					paramFilter.setOp(Operator.eq);
//					paramFilter.setValue(baseRateType);
//					filters.add(paramFilter);
//				}
//				params.setFilters(filters.toArray(new Filter[filters.size()]));
//				params.setRowIndexEnd(-1);	// to get all results
//				return _commonDao.getRatePairs( userSessionId, params);
//			}
//
//			@Override
//			protected int loadDaoDataSize(SelectionParams params) {
//				if (!searching) {
//					return 0;
//				}
//				setFilters();
//				if (baseRateType != null) {
//					Filter paramFilter = new Filter();
//					paramFilter.setElement("baseRateType");
//					paramFilter.setOp(Operator.eq);
//					paramFilter.setValue(baseRateType);
//					filters.add(paramFilter);
//				}
//				params.setFilters(filters.toArray(new Filter[filters.size()]));
//				return _commonDao.getRatePairsCount( userSessionId, params);
//			}
//		};
//
//		_revItemSelection = new TableRowSelection<RatePair>(null, _ratePairsRevSource);
	}

	public DaoDataModel<RatePair> getRatePairs() {
		return _ratePairsSource;
	}

	public RatePair getActiveRatePair() {
		return _activeRatePair;
	}

	public void setActiveRatePair(RatePair activeRatePair) {
		_activeRatePair = activeRatePair;
	}

	public SimpleSelection getItemSelection() {
		return _itemSelection.getWrappedSelection();
	}

	public void setItemSelection(SimpleSelection selection) {
		_itemSelection.setWrappedSelection(selection);
		_activeRatePair = _itemSelection.getSingleSelection();
	}
	
//	public DaoDataModel<RatePair> getRevRatePairs() {
//		return _ratePairsRevSource;
//	}
//
//	public RatePair getRevActiveRatePair() {
//		return _revActiveRatePair;
//	}
//
//	public void setRevActiveRatePair(RatePair revActiveRatePair) {
//		_revActiveRatePair = revActiveRatePair;
//	}
//
//	public SimpleSelection getRevItemSelection() {
//		return _revItemSelection.getWrappedSelection();
//	}
//
//	public void setRevItemSelection(SimpleSelection selection) {
//		_revItemSelection.setWrappedSelection(selection);
//		_revActiveRatePair = _revItemSelection.getSingleSelection();
//	}

	public void search() {
		clearBean();
		searching = true;
	}

	public void clearFilter() {
		ratePairFilter = new RatePair();
		clearBean();
		curLang = userLang;
		
		searching = false;
	}

	public void setFilters() {
		ratePairFilter = getFilter();

		List<Filter> filtersList = new ArrayList<Filter>();
		if (ratePairFilter.getRateType() != null && !ratePairFilter.getRateType().equals("")) {
			Filter paramFilter = new Filter();
			paramFilter.setElement("rateType");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(ratePairFilter.getRateType());
			filtersList.add(paramFilter);
		}
		if (ratePairFilter.getInstId() != null) {
			Filter paramFilter = new Filter();
			paramFilter = new Filter();
			paramFilter.setElement("instId");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(ratePairFilter.getInstId().toString());
			filtersList.add(paramFilter);
		}
		if (ratePairFilter.getSrcCurrency() != null && !ratePairFilter.getSrcCurrency().equals("")) {
			Filter paramFilter = new Filter();
			paramFilter = new Filter();
			paramFilter.setElement("srcCurrency");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(ratePairFilter.getSrcCurrency());
			filtersList.add(paramFilter);
		}
		if (ratePairFilter.getDstCurrency() != null && !ratePairFilter.getDstCurrency().equals("")) {
			Filter paramFilter = new Filter();
			paramFilter = new Filter();
			paramFilter.setElement("dstCurrency");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(ratePairFilter.getDstCurrency());
			filtersList.add(paramFilter);
		}
		filters = filtersList;
	}

	public void add() {
		newRatePair =  new RatePair();
		newRatePair.setRateType(getFilter().getRateType());
		newRatePair.setInstId(getFilter().getInstId());
		curMode = NEW_MODE;
	}
	
	public void addRev() {
		newRatePair =  new RatePair();
		newRatePair.setRateType(getFilter().getRateType());
		newRatePair.setInstId(getFilter().getInstId());
		curMode = NEW_MODE;
	}

	public void edit() {
		try {
			newRatePair = (RatePair) _activeRatePair.clone();
		} catch (CloneNotSupportedException e) {
			newRatePair = _activeRatePair;
			logger.error("",e);
		}
		curMode = EDIT_MODE;
	}
	
//	public void editRev() {
//		try {
//			newRatePair = (RatePair) _revActiveRatePair.clone();
//		} catch (CloneNotSupportedException e) {
//			newRatePair = _revActiveRatePair;
//		}
//		curMode = EDIT_MODE;
//	}

	public void delete() {
		try {
			_commonDao.deleteRatePair( userSessionId, _activeRatePair);
			String msg = FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Common", "rate_pair_deleted",
					"(id = " + _activeRatePair.getId() + ")");
			
			_activeRatePair = _itemSelection.removeObjectFromList(_activeRatePair);
			if (_activeRatePair == null) {
				clearBean();
			}
//			_ratePairsRevSource.flushCache();
			
//			if (_revActiveRatePair != null) {
//				_revItemSelection.unselect(_revActiveRatePair);
//				_revActiveRatePair = null;
//			}
			FacesUtils.addMessageInfo(msg);
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("",e);
		}
	}
	
//	public void deleteRev() {
//		try {
//			_commonDao.deleteRatePair( userSessionId, _revActiveRatePair);
//			_ratePairsRevSource.flushCache();
//			_ratePairsSource.flushCache();
//			
//			String msg = FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Common", "rate_pair_deleted",
//					"(id = " + _revActiveRatePair.getId() + ")");
//			
//			_revItemSelection.unselect(_revActiveRatePair);
//			_revActiveRatePair = null;
//			if (_activeRatePair != null) {
//				_itemSelection.unselect(_activeRatePair);
//				_activeRatePair = null;
//			}
//			FacesUtils.addMessageInfo(msg);
//		} catch (Exception e) {
//			FacesUtils.addMessageError(e);
//		}
//	}

	public void save() {
		try {
			newRatePair.setLang(curLang);
			if (newRatePair.getSrcCurrency().equals(newRatePair.getDstCurrency())) {
				throw new Exception(FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Common",
						"source_currency_equals_dst_currency"));
			}
			
			if (isNewMode()) {
				newRatePair = _commonDao.addRatePair( userSessionId, newRatePair);
				_itemSelection.addNewObjectToList(newRatePair);
			} else {
				_commonDao.editRatePair( userSessionId, newRatePair);
				_ratePairsSource.replaceObject(_activeRatePair, newRatePair);
			}
			
			_activeRatePair = newRatePair;
			curMode = VIEW_MODE;
			
			FacesUtils.addMessageInfo(
					FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Common", "rate_pair_saved"));
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("",e);
		}
	}
	
	public void cancel() {
		curMode = VIEW_MODE;
	}
	
	public RatePair getFilter() {
		if (ratePairFilter == null) {
			ratePairFilter = new RatePair();
		}
		return ratePairFilter;
	}

	public void setFilter(RatePair ratePairFilter) {
		this.ratePairFilter = ratePairFilter;
	}

	public RatePair getNewRatePair() {
		if (newRatePair == null) {
			newRatePair = new RatePair();
		}
		return newRatePair;
	}

	public void setNewRatePair(RatePair newRatePair) {
		this.newRatePair = newRatePair;
	}
	
	public void clearBean() {
		_ratePairsSource.flushCache();
		_itemSelection.clearSelection();
		_activeRatePair = null;

//		_ratePairsRevSource.flushCache();
//		
//		if (_revActiveRatePair != null) {
//			if (_revItemSelection != null) {
//				_revItemSelection.unselect(_revActiveRatePair);
//			}
//			_revActiveRatePair = null;
//		}
	}

	public ArrayList<SelectItem> getInstitutions() {
		if (institutions == null) {
			institutions = (ArrayList<SelectItem>) getDictUtils().getLov(LovConstants.INSTITUTIONS_SYS);
		}
		if (institutions == null)
			institutions = new ArrayList<SelectItem>();
		return institutions;
	}
	
	public ArrayList<SelectItem> getInputModes() {
		if (inputModes == null) {
			inputModes = (ArrayList<SelectItem>) getDictUtils().getLov(LovConstants.RATE_INPUT_MODES);
		}
		if (inputModes == null)
			inputModes = new ArrayList<SelectItem>();
		return inputModes;
	}

	public ArrayList<SelectItem> getRateTypes() {
		return getDictUtils().getArticles(DictNames.RATE_TYPE, true, false);
	}

	public List<SelectItem> getRateTypesForInst() {
		List<SelectItem> items;
		if (getNewRatePair().getInstId() != null) {
			Map<String, Object> paramMap = new HashMap<String, Object>();
			paramMap.put("INSTITUTION_ID", getNewRatePair().getInstId());
		
			try {
				List<SelectItem> tmp = getDictUtils().getLov(LovConstants.RATE_TYPES, paramMap);
				items = new ArrayList<SelectItem>();
				String rateType = getNewRatePair().getRateType();
				for (SelectItem si : tmp) {
					if (si.getValue() != null && rateType.equals(si.getValue())) {
						continue;
					}
					items.add(si);
				}
			} catch (Exception e) {
				FacesUtils.addMessageError(e);
				logger.error("",e);
				items = new ArrayList<SelectItem>(0);
			}
		} else {
			items = new ArrayList<SelectItem>(0);
		}
		return items;
	}
	
	public void changeBaseRateType(ValueChangeEvent event) {
		RatePair pair = getNewRatePair();
		String newValue = (String)event.getNewValue();
		String oldValue = (String)event.getOldValue();
		if (newValue != null) {
			if (pair.getBaseRateFormula() == null || pair.getBaseRateFormula().equals("")){
				pair.setBaseRateFormula(":" + newValue); 
			} else {
				if (oldValue != null && !oldValue.equals("")){
					pair.setBaseRateFormula(pair.getBaseRateFormula().replaceAll(oldValue, newValue));
				}
			}
		}
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
