package ru.bpc.sv2.ui.fcl.limits;

import java.util.ArrayList;


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
import ru.bpc.sv2.fcl.limits.LimitRate;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.CommonDao;
import ru.bpc.sv2.logic.LimitsDao;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.TableRowSelection;

@RequestScoped
@KeepAlive
@ManagedBean (name = "MbLimitRates")
public class MbLimitRates extends AbstractBean{
	private static final long serialVersionUID = -9077437208844543816L;

	private static final Logger logger = Logger.getLogger("FCL");

	private LimitsDao _limitsDao = new LimitsDao();

	private CommonDao _commonDao = new CommonDao();

	private final DaoDataModel<LimitRate> _limitRatesSource;
	private final TableRowSelection<LimitRate> _limitRateSelection;

	private LimitRate _activeLimitRate;

	private String limitType;

	private LimitRate newLimitRate;
	
	private ArrayList<SelectItem> institutions;
	
	private static String COMPONENT_ID = "limitRatesTable";
	private String tabName;
	private String parentSectionId;
	
	public MbLimitRates() {
		_limitRatesSource = new DaoDataModel<LimitRate>() {
			private static final long serialVersionUID = -7973671485829363574L;

			@Override
			protected LimitRate[] loadDaoData(SelectionParams params) {
				if (!searching) {
					return new LimitRate[0];
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));

					return _limitsDao.getLimitRates(userSessionId, params);
				} catch (Exception e) {
					setDataSize(0);
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return new LimitRate[0];
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (!searching) {
					return 0;
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _limitsDao.getLimitRatesCount(userSessionId, params);
				} catch (Exception e) {
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return 0;
			}
		};

		_limitRateSelection = new TableRowSelection<LimitRate>(null, _limitRatesSource);
	}

	public DaoDataModel<LimitRate> getLimitRates() {
		return _limitRatesSource;
	}

	public LimitRate getActiveLimitRate() {
		return _activeLimitRate;
	}

	public void setActiveLimitRate(LimitRate activeLimitRate) {
		_activeLimitRate = activeLimitRate;
	}

	public SimpleSelection getLimitRateSelection() {
		return _limitRateSelection.getWrappedSelection();
	}

	public void setLimitRateSelection(SimpleSelection selection) {
		_limitRateSelection.setWrappedSelection(selection);
		_activeLimitRate = _limitRateSelection.getSingleSelection();
	}

	public void setFilters() {
		filters = new ArrayList<Filter>(2);

		Filter paramFilter = new Filter();
		paramFilter.setElement("lang");
		paramFilter.setValue(userLang);
		filters.add(paramFilter);

		if (limitType != null) {
			paramFilter = new Filter();
			paramFilter.setElement("limitType");
			paramFilter.setValue(limitType);
			filters.add(paramFilter);
		}
	}

	public void search() {
		clearBean();
		searching = true;
	}

	public void add() {
		newLimitRate = new LimitRate();

		newLimitRate.setLimitType(limitType);
		curMode = NEW_MODE;
	}

	public void edit() {
		curMode = EDIT_MODE;
		try {
			newLimitRate = _activeLimitRate.clone();
		} catch (CloneNotSupportedException e) {
			logger.error(e.getMessage(), e);
			newLimitRate = _activeLimitRate;
		}
	}

	public void save() {
		try {
			if (isNewMode()) {
				newLimitRate = _limitsDao.createLimitRate(userSessionId, newLimitRate, userLang);
				_limitRateSelection.addNewObjectToList(newLimitRate);
			} else {
				newLimitRate = _limitsDao.editLimitRate(userSessionId, newLimitRate);
				_limitRatesSource.replaceObject(_activeLimitRate, newLimitRate);
			}

			_activeLimitRate = newLimitRate;
			FacesUtils.addMessageInfo(FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Fcl",
					"limit_rate_saved"));
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void delete() {
		try {
			_limitsDao.deleteLimitRate(userSessionId, _activeLimitRate);
			FacesUtils.addMessageInfo(FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Fcl",
					"limit_rate_deleted", "(ID = " + _activeLimitRate.getId() + ")"));

			_activeLimitRate = _limitRateSelection.removeObjectFromList(_activeLimitRate);
			if (_activeLimitRate == null) {
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

	public LimitRate getNewLimitRate() {
		return newLimitRate;
	}

	public void setNewLimitRate(LimitRate newLimitRate) {
		this.newLimitRate = newLimitRate;
	}

	public ArrayList<SelectItem> getLengthTypes() {
		return getDictUtils().getArticles(DictNames.LENGTH_TYPES, true, false);
	}

	public void clearBean() {
		if (_activeLimitRate != null) {
			if (_limitRateSelection != null) {
				_limitRateSelection.unselect(_activeLimitRate);
			}
			_activeLimitRate = null;
		}
		_limitRatesSource.flushCache();
	}

	public void fullCleanBean() {
		limitType = null;
		searching = false;
		clearBean();
	}

	public String getLimitType() {
		return limitType;
	}

	public void setLimitType(String limitType) {
		this.limitType = limitType;
	}

	public ArrayList<SelectItem> getLimitTypes() {
		return getDictUtils().getArticles(DictNames.LIMIT_TYPES, false, true);
	}

	public ArrayList<SelectItem> getRateTypes() {
		if (newLimitRate == null || newLimitRate.getInstId() == null) {
			return new ArrayList<SelectItem>(0);
		}

		Filter[] filters = new Filter[1];
		filters[0] = new Filter();
		filters[0].setElement("instId");
		filters[0].setValue(newLimitRate.getInstId().toString());

		SelectionParams params = new SelectionParams();
		params.setFilters(filters);
		params.setRowIndexEnd(Integer.MAX_VALUE);

		try {
			RateType[] types = _commonDao.getRateTypes(userSessionId, params);
			ArrayList<SelectItem> result = new ArrayList<SelectItem>(types.length);
			for (RateType type : types) {
				result.add(new SelectItem(type.getRateType(), getDictUtils().getAllArticlesDesc().get(
						type.getRateType())));
			}
			return result;
		} catch (Exception e) {
			logger.error("", e);
			if (e.getMessage().indexOf(SystemConstants.INSUFFICIENT_PRIVILEGES_ERROR) < 0) {
				FacesUtils.addMessageError(e);
			}
			return new ArrayList<SelectItem>(0);
		}
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
