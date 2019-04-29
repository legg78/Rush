package ru.bpc.sv2.ui.common.rates;

import java.util.ArrayList;
import java.util.List;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.model.SelectItem;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;

import ru.bpc.sv2.common.rates.RatePair;
import ru.bpc.sv2.common.rates.RateType;
import ru.bpc.sv2.constants.DictNames;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.constants.SectionIdConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.Filter.Operator;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.CommonDao;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.TableRowSelection;
import util.auxil.ManagedBeanWrapper;

@ViewScoped
@ManagedBean (name = "MbRateTypes")
public class MbRateTypes extends AbstractBean {
	private static final long serialVersionUID = 1L;

	private static final Logger logger = Logger.getLogger("COMMON");

	private static String COMPONENT_ID = "1132:rateTypesTable";

	private CommonDao _commonDao = new CommonDao();

	private RateType filter;
	private RateType newRateType;
	private ArrayList<SelectItem> institutions;

	private final DaoDataModel<RateType> _rateTypesSource;
	private final TableRowSelection<RateType> _itemSelection;
	private RateType _activeRateType;
	
	private String tabName;

	public MbRateTypes() {
		pageLink = "common|rateTypes";
		_rateTypesSource = new DaoDataModel<RateType>() {
			private static final long serialVersionUID = 1L;

			@Override
			protected RateType[] loadDaoData(SelectionParams params) {
				if (!searching) {
					return new RateType[0];
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _commonDao.getRateTypes(userSessionId, params);
				} catch (Exception e) {
					setDataSize(0);
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return new RateType[0];
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (!searching) {
					return 0;
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _commonDao.getRateTypesCount(userSessionId, params);
				} catch (Exception e) {
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return 0;
			}
		};

		_itemSelection = new TableRowSelection<RateType>(null, _rateTypesSource);
	}

	public DaoDataModel<RateType> getRateTypes() {
		return _rateTypesSource;
	}

	public RateType getActiveRateType() {
		return _activeRateType;
	}

	public void setActiveRateType(RateType activeRateType) {
		_activeRateType = activeRateType;
	}

	public SimpleSelection getItemSelection() {
		if (_activeRateType == null && _rateTypesSource.getRowCount() > 0) {
			setFirstRowActive();
		} else if (_activeRateType != null && _rateTypesSource.getRowCount() > 0) {
			SimpleSelection selection = new SimpleSelection();
			selection.addKey(_activeRateType.getModelId());
			_itemSelection.setWrappedSelection(selection);
			_activeRateType = _itemSelection.getSingleSelection();
		}
		return _itemSelection.getWrappedSelection();
	}

	public void setItemSelection(SimpleSelection selection) {
		_itemSelection.setWrappedSelection(selection);
		_activeRateType = _itemSelection.getSingleSelection();

		if (_activeRateType != null) {
			setBeans();
		}
	}

	public void setFirstRowActive() {
		_rateTypesSource.setRowIndex(0);
		SimpleSelection selection = new SimpleSelection();
		_activeRateType = (RateType) _rateTypesSource.getRowData();
		selection.addKey(_activeRateType.getModelId());
		_itemSelection.setWrappedSelection(selection);

		if (_activeRateType != null) {
			setBeans();
		}
	}

	public void setBeans() {
		MbRatePairs pairsBean = (MbRatePairs) ManagedBeanWrapper.getManagedBean("MbRatePairs");
		pairsBean.clearBean();
		RatePair filter = new RatePair();
		filter.setRateType(_activeRateType.getRateType());
		filter.setBaseRateType(_activeRateType.getRateType());
		filter.setInstId(_activeRateType.getInstId());
		pairsBean.setFilter(filter);
		pairsBean.search();
	}

	public void search() {
		clearBean();
		searching = true;
	}

	public void clearFilter() {
		clearBean();
		filter = null;
		curLang = userLang;

		searching = false;
	}

	public void setFilters() {
		filter = getFilter();
		List<Filter> filtersList = new ArrayList<Filter>();
		Filter paramFilter;
		if (filter.getRateType() != null && !filter.getRateType().equals("")) {
			paramFilter = new Filter();
			paramFilter.setElement("rateType");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(filter.getRateType());
			filtersList.add(paramFilter);
		}
		if (filter.getInstId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("instId");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(filter.getInstId().toString());
			filtersList.add(paramFilter);
		}
		if (filter.getBaseCurrency() != null
				&& !filter.getBaseCurrency().equals("")) {
			paramFilter = new Filter();
			paramFilter.setElement("baseCurrency");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(filter.getBaseCurrency());
			filtersList.add(paramFilter);
		}
		filters = filtersList;
	}

	public void add() {
		newRateType = new RateType();
		newRateType.setInstId(getFilter().getInstId());
		curMode = NEW_MODE;
	}

	public void edit() {
		try {
			newRateType = (RateType) _activeRateType.clone();
		} catch (CloneNotSupportedException e) {
			newRateType = _activeRateType;
			logger.error("", e);
		}
		curMode = EDIT_MODE;
	}

	public void delete() {
		try {
			_commonDao.deleteRateType(userSessionId, _activeRateType);
			String msg = FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Common", "rate_type_deleted",
					"(id = " + _activeRateType.getId() + ")");

			_activeRateType = _itemSelection.removeObjectFromList(_activeRateType);
			if (_activeRateType == null) {
				clearBean();
			} else {
				setBeans();
			}

			FacesUtils.addMessageInfo(msg);
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void save() {
		try {
			if (!newRateType.isUseBaseRate() && !newRateType.isUseCrossRate()) {
				throw new Exception(FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Msg",
						"base_or_cross"));
			}
			if (!newRateType.isUseBaseRate()) {
				newRateType.setBaseCurrency(null);
			}
			if (isNewMode()) {
				newRateType = _commonDao.addRateType(userSessionId, newRateType);
				_itemSelection.addNewObjectToList(newRateType);
			} else {
				newRateType = _commonDao.editRateType(userSessionId, newRateType);
				_rateTypesSource.replaceObject(_activeRateType, newRateType);
			}
			_activeRateType = newRateType;
			setBeans();
			curMode = VIEW_MODE;

			FacesUtils.addMessageInfo(FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Common",
					"rate_type_saved"));
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void cancel() {
		curMode = VIEW_MODE;
	}

	public RateType getFilter() {
		if (filter == null) {
			filter = new RateType();
			filter.setInstId(userInstId);
		}
		return filter;
	}

	public void setFilter(RateType typeFiilter) {
		this.filter = typeFiilter;
	}

	public RateType getNewRateType() {
		if (newRateType == null) {
			newRateType = new RateType();
		}
		return newRateType;
	}

	public void setNewRateType(RateType newRateType) {
		this.newRateType = newRateType;
	}

	public void clearBean() {
		_rateTypesSource.flushCache();
		_itemSelection.clearSelection();
		_activeRateType = null;

		MbRatePairs pairsBean = (MbRatePairs) ManagedBeanWrapper.getManagedBean("MbRatePairs");
		pairsBean.clearFilter();
	}

	public ArrayList<SelectItem> getInstitutions() {
		if (institutions == null) {
			institutions = (ArrayList<SelectItem>) getDictUtils().getLov(LovConstants.INSTITUTIONS);
		}
		if (institutions == null)
			institutions = new ArrayList<SelectItem>();
		return institutions;
	}

	public ArrayList<SelectItem> getRateTypesArticles() {
		return getDictUtils()
				.getArticles(DictNames.RATE_TYPE, true, false, getNewRateType().getInstId());
	}

	public ArrayList<SelectItem> getFilterRateTypes() {
		return getDictUtils().getArticles(DictNames.RATE_TYPE, true, false);
	}
	
	public String getRateTypeType() {
		return DictNames.RATE_TYPE;
	}

	public String getComponentId() {
		return COMPONENT_ID;
	}

	public Logger getLogger() {
		return logger;
	}

	public String getTabName() {
		return tabName;
	}

	public void setTabName(String tabName) {
		this.tabName = tabName;
		
		if (tabName.equalsIgnoreCase("pairsTab")) {
			MbRatePairs bean = (MbRatePairs) ManagedBeanWrapper
					.getManagedBean("MbRatePairs");
			bean.setTabName(tabName);
			bean.setParentSectionId(getSectionId());
			bean.setTableState(getSateFromDB(bean.getComponentId()));
		}
	}

	public String getSectionId() {
		return SectionIdConstants.CONFIGURATION_RATE_TYPE;
	}
}
