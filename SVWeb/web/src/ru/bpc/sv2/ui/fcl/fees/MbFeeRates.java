package ru.bpc.sv2.ui.fcl.fees;

import java.util.ArrayList;
import java.util.List;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.RequestScoped;
import javax.faces.model.SelectItem;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;

import org.ajax4jsf.model.KeepAlive;
import ru.bpc.sv2.common.rates.RateType;
import ru.bpc.sv2.constants.DictNames;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.constants.SystemConstants;
import ru.bpc.sv2.fcl.fees.FeeRate;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.invocation.Filter.Operator;
import ru.bpc.sv2.logic.CommonDao;
import ru.bpc.sv2.logic.FeesDao;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.TableRowSelection;

@RequestScoped
@KeepAlive
@ManagedBean (name = "MbFeeRates")
public class MbFeeRates extends AbstractBean{
	private static final long serialVersionUID = 6184943091036050955L;

	private static final Logger logger = Logger.getLogger("FCL");

	private FeesDao _feesDao = new FeesDao();

	private CommonDao _commonDao = new CommonDao();

	private final DaoDataModel<FeeRate> _feeRatesSource;
	private final TableRowSelection<FeeRate> _feeRateSelection;

	private ArrayList<Filter> filters;
	private FeeRate _activeFeeRate;

	private String feeType;

	private FeeRate _newFeeRate;

	private ArrayList<SelectItem> institutions;
	
	private static String COMPONENT_ID = "feeRatesTable";
	private String tabName;
	private String parentSectionId;

	public MbFeeRates() {
		_feeRatesSource = new DaoDataModel<FeeRate>() {
			private static final long serialVersionUID = -6576983993296801395L;

			@Override
			protected FeeRate[] loadDaoData(SelectionParams params) {
				if (!searching) {
					return new FeeRate[0];
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));

					return _feesDao.getFeeRates(userSessionId, params);
				} catch (Exception e) {
					setDataSize(0);
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return new FeeRate[0];
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (!searching) {
					return 0;
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _feesDao.getFeeRatesCount(userSessionId, params);
				} catch (Exception e) {
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return 0;
			}
		};

		_feeRateSelection = new TableRowSelection<FeeRate>(null, _feeRatesSource);
	}

	public DaoDataModel<FeeRate> getFeeRates() {
		return _feeRatesSource;
	}

	public FeeRate getActiveFeeRate() {
		return _activeFeeRate;
	}

	public void setActiveFeeRate(FeeRate activeFeeRate) {
		_activeFeeRate = activeFeeRate;
	}

	public SimpleSelection getFeeRateSelection() {
		return _feeRateSelection.getWrappedSelection();
	}

	public void setFeeRateSelection(SimpleSelection selection) {
		_feeRateSelection.setWrappedSelection(selection);
		_activeFeeRate = _feeRateSelection.getSingleSelection();
	}

	public void setFilters() {
		filters = new ArrayList<Filter>(2);

		Filter paramFilter = new Filter();
		paramFilter.setElement("lang");
		paramFilter.setValue(userLang);
		filters.add(paramFilter);

		if (feeType != null) {
			paramFilter = new Filter();
			paramFilter.setElement("feeType");
			paramFilter.setValue(feeType);
			filters.add(paramFilter);
		}
	}

	public void search() {
		clearBean();
		searching = true;
	}

	public void add() {
		_newFeeRate = new FeeRate();

		_newFeeRate.setFeeType(feeType);
		curMode = NEW_MODE;
	}

	public void edit() {
		curMode = EDIT_MODE;
		try {
			_newFeeRate = _activeFeeRate.clone();
		} catch (CloneNotSupportedException e) {
			logger.error(e.getMessage(), e);
			_newFeeRate = _activeFeeRate;
		}
	}

	public void save() {
		try {
			if (isNewMode()) {
				_newFeeRate = _feesDao.createFeeRate(userSessionId, _newFeeRate, userLang);
				_feeRateSelection.addNewObjectToList(_newFeeRate);
			} else {
				_newFeeRate = _feesDao.editFeeRate(userSessionId, _newFeeRate);
				_feeRatesSource.replaceObject(_activeFeeRate, _newFeeRate);
			}

			_activeFeeRate = _newFeeRate;

			FacesUtils.addMessageInfo(FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Fcl",
					"fee_rate_saved"));
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void delete() {
		try {
			_feesDao.deleteFeeRate(userSessionId, _activeFeeRate);

			FacesUtils.addMessageInfo(FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Fcl",
					"fee_rate_deleted", "(ID = " + _activeFeeRate.getId() + ")"));

			_activeFeeRate = _feeRateSelection.removeObjectFromList(_activeFeeRate);
			if (_activeFeeRate == null) {
				clearBean();
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public boolean isManagingNew() {
		return isNewMode();
	}

	public void cancel() {

	}

	public FeeRate getNewFeeRate() {
		if (_newFeeRate == null) {
			_newFeeRate = new FeeRate();
		}
		return _newFeeRate;
	}

	public void setNewFeeRate(FeeRate newFeeRate) {
		_newFeeRate = newFeeRate;
	}

	public ArrayList<SelectItem> getLengthTypes() {
		return getDictUtils().getArticles(DictNames.LENGTH_TYPES, true, false);
	}

	public void clearBean() {
		if (_activeFeeRate != null) {
			if (_feeRateSelection != null) {
				_feeRateSelection.unselect(_activeFeeRate);
			}
			_activeFeeRate = null;
		}
		_feeRatesSource.flushCache();
	}

	public void fullCleanBean() {
		feeType = null;
		searching = false;
		clearBean();
	}

	public String getFeeType() {
		return feeType;
	}

	public void setFeeType(String feeType) {
		this.feeType = feeType;
	}

	public ArrayList<SelectItem> getFeeTypes() {
		return getDictUtils().getArticles(DictNames.FEE_TYPE, false, true);
	}

	public ArrayList<SelectItem> getRateTypes() {
		ArrayList<SelectItem> items = new ArrayList<SelectItem>();
		try {
			SelectionParams params = new SelectionParams();

			String instId = null;
			if (getNewFeeRate().getInstId() == null) {
				instId = "9999";
			} else {
				instId = getNewFeeRate().getInstId().toString();
			}

			List<Filter> filtersNameFormat = new ArrayList<Filter>();

			Filter paramFilter = null;

			paramFilter = new Filter();
			paramFilter.setElement("instId");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(instId);
			filtersNameFormat.add(paramFilter);

			params.setFilters(filtersNameFormat.toArray(new Filter[filtersNameFormat.size()]));
			params.setRowIndexEnd(-1);
			RateType[] rateTypes = _commonDao.getRateTypes(userSessionId, params);
			for (RateType type : rateTypes) {
				items.add(new SelectItem(type.getRateType(), getDictUtils().getAllArticlesDesc().get(
						type.getRateType())));
			}
		} catch (Exception e) {
			logger.error("", e);
			if (e.getMessage().indexOf(SystemConstants.INSUFFICIENT_PRIVILEGES_ERROR) < 0) {
				FacesUtils.addMessageError(e);
			}
		} finally {
			if (items == null)
				items = new ArrayList<SelectItem>();
		}

		return items;
	}

	public ArrayList<SelectItem> getInstitutions() {
		if (institutions == null) {
			institutions = (ArrayList<SelectItem>) getDictUtils().getLov(LovConstants.INSTITUTIONS_SYS);
		}
		if (institutions == null)
			institutions = new ArrayList<SelectItem>();
		return institutions;
	}

	@Override
	public void clearFilter() {
		// TODO Auto-generated method stub
		
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
