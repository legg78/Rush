package ru.bpc.sv2.ui.common.rates;

import org.apache.commons.lang3.StringUtils;
import org.apache.commons.lang3.time.DateUtils;
import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;
import ru.bpc.sv2.common.FlexFieldData;
import ru.bpc.sv2.common.rates.Rate;
import ru.bpc.sv2.common.rates.RateConstants;
import ru.bpc.sv2.common.rates.RateType;
import ru.bpc.sv2.constants.*;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.Filter.Operator;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.CommonDao;
import ru.bpc.sv2.ui.common.flexible.MbFlexFieldsDataSearch;
import ru.bpc.sv2.ui.utils.*;
import util.auxil.ManagedBeanWrapper;


import javax.faces.application.FacesMessage;
import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.component.UIComponent;
import javax.faces.component.UIInput;
import javax.faces.context.FacesContext;
import javax.faces.event.ValueChangeEvent;
import javax.faces.model.SelectItem;
import javax.servlet.http.HttpServletRequest;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@ViewScoped
@ManagedBean (name = "MbRates")
public class MbRates extends AbstractBean {
	private static final long serialVersionUID = -6317806007853317536L;
	private static final Logger logger = Logger.getLogger("COMMON");

	private static String COMPONENT_ID = "1133:ratesTable";

	private final String INVALID_RATE = "RTSTINVL";
	private final String VALID_RATE = "RTSTVALD";
	
	private CommonDao _commonDao = new CommonDao();

	private Rate filter;
	private Rate newRate;
	private ArrayList<SelectItem> institutions;
	private ArrayList<SelectItem> inputModes;

	private final DaoDataModel<Rate> _ratesSource;
	private final TableRowSelection<Rate> _itemSelection;
	private final DaoDataModel<Rate> _dependenceRatesSource;
	private Rate _activeRate;

	private Rate[] ratesToAdd;
	
	private boolean valid = true;
	private String validatorMessage;
	private Map<String, RateType> rateTypesMap;
	
	private List<Rate> addedRates;
	private List<Rate> ratesToInvalidate;
	private boolean selectAll;
	
	private String tabName;
	private String needRerender;
	private List<String> rerenderList;
	private int rateSetMode = RateConstants.SET_RATE_SIMPLE;

	public MbRates() {
		pageLink = "common|rates";
		_ratesSource = new DaoDataModel<Rate>() {
			private static final long serialVersionUID = -538782259806311130L;

			@Override
			protected Rate[] loadDaoData(SelectionParams params) {
				if (!searching) {
					return new Rate[0];
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _commonDao.getRates(userSessionId, params);
				} catch (Exception e) {
					setDataSize(0);
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return new Rate[0];
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (!searching) {
					return 0;
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _commonDao.getRatesCount(userSessionId, params);
				} catch (Exception e) {
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return 0;
			}
		};
		
		_dependenceRatesSource = new DaoDataModel<Rate>() {
			private static final long serialVersionUID = 688302701175675889L;

			@Override
			protected Rate[] loadDaoData(SelectionParams params) {
				if (newRate == null || newRate.getCount()==null || newRate.getCount() <= 1) {
					return new Rate[0];
				}
				try {
					params.setRowIndexEnd(-1);
					Filter[] dependenceFilter = new Filter[1];
					dependenceFilter[0].setElement("initiateId");
					dependenceFilter[0].setOp(Operator.eq);
					dependenceFilter[0].setValue(newRate.getId());
					params.setFilters(dependenceFilter);
					return _commonDao.getRates(userSessionId, params);
				} catch (Exception e) {
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return new Rate[0];
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (newRate == null || newRate.getCount()==null || newRate.getCount() <= 1) {
					return 0;
				}
				try {
					params.setRowIndexEnd(-1);
					Filter[] dependenceFilter = new Filter[1];
					dependenceFilter[0].setElement("initiateId");
					dependenceFilter[0].setOp(Operator.eq);
					dependenceFilter[0].setValue(newRate.getId());
					params.setFilters(dependenceFilter);
					return _commonDao.getRatesCount(userSessionId, params);
				} catch (Exception e) {
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return 0;
			}
		};

		_itemSelection = new TableRowSelection<Rate>(null, _ratesSource);

		HttpServletRequest req = RequestContextHolder.getRequest();
		String sectionId = req.getParameter("sectionId");
		String filterId = req.getParameter("filterId");

		if (sectionId != null && filterId != null && sectionId.equals(getSectionId())) {
			selectedSectionFilter = Integer.parseInt(filterId);
			applySectionFilter(selectedSectionFilter);
		}
	}

	public DaoDataModel<Rate> getRates() {
		return _ratesSource;
	}
	
	public DaoDataModel<Rate> getDependenceRates() {
		return _dependenceRatesSource;
	}

	public Rate getActiveRate() {
		return _activeRate;
	}

	public void setActiveRate(Rate activeRate) {
		_activeRate = activeRate;
	}

	public SimpleSelection getItemSelection() {
		try {
			if (_activeRate == null && _ratesSource.getRowCount() > 0) {
				setFirstRowActive();
			} else if (_activeRate != null && _ratesSource.getRowCount() > 0) {
				SimpleSelection selection = new SimpleSelection();
				selection.addKey(_activeRate.getModelId());
				_itemSelection.setWrappedSelection(selection);
				_activeRate = _itemSelection.getSingleSelection();
			}
		} catch (Exception e) {
			logger.error("", e);
			FacesUtils.addMessageError(e);
		}
		return _itemSelection.getWrappedSelection();
	}

	public void setItemSelection(SimpleSelection selection) {
		_itemSelection.setWrappedSelection(selection);
		_activeRate = _itemSelection.getSingleSelection();

		if (_activeRate != null) {
			setBeans();
			loadCurrentTab();
		}
	}

	public void setFirstRowActive() {
		_ratesSource.setRowIndex(0);
		SimpleSelection selection = new SimpleSelection();
		_activeRate = (Rate) _ratesSource.getRowData();
		selection.addKey(_activeRate.getModelId());
		_itemSelection.setWrappedSelection(selection);

		if (_activeRate != null) {
			setBeans();
		}
	}

	public void setBeans() {
	}

	public void search() {
		clearBean();
		searching = true;
	}

	public void clearFilter() {
		filter = null;
		curLang = userLang;
		clearBean();
		searching = false;
		clearSectionFilter();
	}

	public void setFilters() {
		filter = getFilter();
		filters = new ArrayList<Filter>();
		if (StringUtils.isNotEmpty(filter.getRateType())) {
			filters.add(new Filter("rateType", filter.getRateType()));
		}
		if (filter.getInstId() != null) {
			filters.add(new Filter("instId", filter.getInstId().toString()));
		}
		if (StringUtils.isNotEmpty(filter.getStatus())) {
			filters.add(new Filter("status", filter.getStatus()));
		}
		if (filter.getEffDate() != null) {
			filters.add(new Filter("effDate",new SimpleDateFormat("dd.MM.yyyy HH:mm:ss").format(filter.getEffDate())));
		}
		if (StringUtils.isNotEmpty(filter.getSrcCurrency())) {
			filters.add(new Filter("srcCurrency", filter.getSrcCurrency()));
		}
		if (StringUtils.isNotEmpty(filter.getDstCurrency())) {
			filters.add(new Filter("dstCurrency", filter.getDstCurrency()));
		}
	}

	public void add() {
		getRateTypesMap().clear();
		newRate = new Rate();
		newRate.setInstId(getFilter().getInstId());
		newRate.setSrcScale(1d);
		newRate.setDstScale(1d);		
		Calendar cal = Calendar.getInstance();
        cal.setTime(new Date(System.currentTimeMillis()));
        cal.set(Calendar.HOUR_OF_DAY, 0);
        cal.set(Calendar.MINUTE, 0);
        cal.set(Calendar.SECOND, 0);
        cal.set(Calendar.MILLISECOND,0);
        newRate.setEffDate(cal.getTime());
        addedRates = null;
		curMode = NEW_MODE;
		rateSetMode = RateConstants.SET_RATE_SIMPLE;
		ratesToAdd = new Rate[0];
	}

	public void invalidate() {
		ratesToInvalidate = null;
		selectAll = true;
		
		Filter[] filters = new Filter[2];
		filters[0] = new Filter();
		filters[0].setElement("initiateId");
		filters[0].setValue(_activeRate.getInitiateId());
		filters[1] = new Filter();
		filters[1].setElement("status");
		filters[1].setValue(VALID_RATE);

		SelectionParams params = new SelectionParams();
		params.setFilters(filters);
		params.setRowIndexEnd(Integer.MAX_VALUE);
		
		try {
			Rate[] rates = _commonDao.getRates(userSessionId, params);
			if (rates.length == 1) {
				doInvalidate();
			} else if (rates.length > 1) {
				ratesToInvalidate = new ArrayList<Rate>(rates.length);
				for (Rate rate: rates) {
					rate.setInvalidate(true);
					ratesToInvalidate.add(rate);
				}
			}
		} catch (Exception e) {
			logger.error("", e);
			FacesUtils.addMessageError(e);
		}
	}
	
	public void doInvalidate() {
		try {
			if (ratesToInvalidate == null) {
				Rate rate = _commonDao.invalidateRate(userSessionId, _activeRate);
				_ratesSource.replaceObject(_activeRate, rate);
	
				_activeRate = rate;
			} else {
				for (Rate rate : ratesToInvalidate) {
					if (rate.isInvalidate()) {
						Rate invalidatedRate = _commonDao.invalidateRate(userSessionId, rate);
						_ratesSource.replaceObject(rate, invalidatedRate);
					}
				}
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
		
		ratesToInvalidate = null;
	}

	public void checkRate() {
		if (!validateExpDate()) {
			return;
		}
		boolean validated = true;
		if (isAdvancedMode()) {
			//Check only 1 rate
			validated = checkRate(newRate);
		} else {
			//Check all rates that were input
			for (Rate rate : ratesToAdd) {
				if (!rate.isNeedSave()) {
					continue;
				}
				rate.setEffDate(newRate.getEffDate());
				rate.setExpDate(newRate.getExpDate());
				validated = validated && checkRate(rate);
				if (!validated) {
					break;
				}
			}
		}
		if (validated) {
			save();
		}
	}
	
	public boolean checkRate(Rate rate) {
		
		try {
			if (rate.getSrcCurrency().equals(rate.getDstCurrency())) {
				throw new Exception(FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Common",
						"source_currency_equals_dst_currency"));
			}
			logger.trace("validating rate type");
			rate = _commonDao.checkRate(userSessionId, rate);

			if (rate.isValidated()) {
				logger.trace("validation passed");
				valid = true;				
			} else {
				validatorMessage = rate.getMessage();
				valid = false;
				logger.trace("validation not passed. " + rate.getMessage());
			}			
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
		return valid;
	}

	public void save() {
		if (isAdvancedMode()) {
			saveAdvancedMode();
		} else {
			saveSimpleMode();
		}
	}
	
	public void saveAdvancedMode() {
		try {
			valid = true;
			
			List<Rate> newRates = _commonDao.setRate(userSessionId, newRate);
			
			if (newRates.size() > 1) {
				addedRates = newRates;
			} else {
				addedRates = null;
			}
			
			for (Rate rate: newRates) {
				_itemSelection.addNewObjectToList(rate);
			}
			
			_activeRate = _itemSelection.getSingleSelection();
			curMode = VIEW_MODE;

			FacesUtils.addMessageInfo(FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Common",
					"rate_saved"));
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}
	
	public void saveSimpleMode() {
		try {
            if(ratesToAdd == null || ratesToAdd.length == 0) throw new Exception("No templates for the selected rate. Please select the \"Advanced mode\". ");
			valid = true;
			List<Rate> filteredRatesToAdd = new ArrayList<Rate>();
			for (Rate rate : ratesToAdd) {
				if (rate.isNeedSave()) {
					filteredRatesToAdd.add(rate);
				}
			}
			List<Rate> newRates = _commonDao.setRates(userSessionId, filteredRatesToAdd.toArray(new Rate[filteredRatesToAdd.size()]));
			
			if (newRates != null && newRates.size() > 0) {
				addedRates = newRates;
                for (Rate rate: newRates) {
                    _itemSelection.addNewObjectToList(rate);
                }
			} else {
				addedRates = null;
			}

            if (addedRates != null)
			    _activeRate = _itemSelection.getSingleSelection();
			curMode = VIEW_MODE;

			FacesUtils.addMessageInfo(FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Common",
					"rate_saved"));
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		} finally {
			
		}
	}

	public void back() {
		valid = true;
	}

	public void cancel() {
		curMode = VIEW_MODE;
		valid = true;
	}

	public Rate getFilter() {
		if (filter == null) {
			filter = new Rate();
			filter.setInstId(userInstId);
			filter.setEffDate(DateUtils.addDays(DateUtils.truncate(new Date(), Calendar.DATE), 1));
		}
		return filter;
	}

	public void setFilter(Rate typeFiilter) {
		this.filter = typeFiilter;
	}

	public Rate getNewRate() {
		if (newRate == null) {
			newRate = new Rate();
		}
		return newRate;
	}

	public void setNewRate(Rate newRate) {
		this.newRate = newRate;
	}

	public void clearBean() {
		_ratesSource.flushCache();
		_itemSelection.clearSelection();
		_activeRate = null;
	}

	public ArrayList<SelectItem> getInstitutions() {
		if (institutions == null) {
			institutions = (ArrayList<SelectItem>) getDictUtils().getLov(LovConstants.INSTITUTIONS);
		}
		if (institutions == null)
			institutions = new ArrayList<SelectItem>();
		return institutions;
	}

	public ArrayList<SelectItem> getRateTypesAll() {
		return getDictUtils().getArticles(DictNames.RATE_TYPE, true, false);
	}

	public ArrayList<SelectItem> getRateTypes() {
		ArrayList<SelectItem> items = new ArrayList<SelectItem>();
		try {
			SelectionParams params = new SelectionParams();
			newRate = getNewRate();

			String instId = null;
			if (getNewRate().getInstId() == null) {
				instId = "9999";
			} else {
				instId = getNewRate().getInstId().toString();
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
			rateTypesMap = getRateTypesMap();
			for (RateType type : rateTypes) {
				rateTypesMap.put(type.getRateType(), type);
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

	public ArrayList<SelectItem> getStatuses() {
		return getDictUtils().getArticles(DictNames.RATE_STATUS, false, false);
	}

	public boolean isValid() {
		return valid;
	}

	public void setValid(boolean valid) {
		this.valid = valid;
	}

	public String getValidatorMessage() {
		return validatorMessage;
	}

	public void setValidatorMessage(String validatorMessage) {
		this.validatorMessage = validatorMessage; 	
	}

	public void changeRateType(ValueChangeEvent event) {
		String rateType = (String) event.getNewValue();
		newRate = getNewRate();
		rateTypesMap = getRateTypesMap();
		if (rateType == null || rateType.equals("") || newRate.getEffDate() == null) {
			return;
		}
		try {
			if (rateTypesMap.get(rateType) == null || rateTypesMap.get(rateType).getExpPeriod() == null) {
				newRate.setExpDate(null);
				return;
			}
			Calendar c1 = Calendar.getInstance();
			c1.setTime(newRate.getEffDate());
			c1.add(Calendar.DATE, rateTypesMap.get(rateType).getExpPeriod());
			c1.set(Calendar.HOUR_OF_DAY, 23);	        
			c1.set(Calendar.MINUTE, 59);
			c1.set(Calendar.SECOND, 59);
	        newRate.setExpDate(c1.getTime());
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void changeEffDate(ValueChangeEvent event) {
		Date newEffDate = (Date) event.getNewValue();
		newRate = getNewRate();
		rateTypesMap = getRateTypesMap();
		if (newRate.getRateType() == null || newRate.getRateType().equals("")
				|| newRate.getEffDate() == null || rateTypesMap.get(newRate.getRateType()).getExpPeriod() == null) {
			newRate.setExpDate(null);
			return;			
		}
		try {
			Calendar c1 = Calendar.getInstance();
			c1.setTime(newEffDate);			
			c1.add(Calendar.DATE, rateTypesMap.get(newRate.getRateType()).getExpPeriod());
			c1.set(Calendar.HOUR_OF_DAY, 23);	        
			c1.set(Calendar.MINUTE, 59);
			c1.set(Calendar.SECOND, 59);
			newRate.setExpDate(c1.getTime());
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void changeInstitution(ValueChangeEvent event) {
		newRate = getNewRate();
		newRate.setRateType(null);
		newRate.setExpDate(null);
		getRateTypesMap().clear();
	}

	public Map<String, RateType> getRateTypesMap() {
		if (rateTypesMap == null)
			rateTypesMap = new HashMap<String, RateType>();
		return rateTypesMap;
	}

	public void setRateTypesMap(Map<String, RateType> rateTypesMap) {
		this.rateTypesMap = rateTypesMap;
	}

	public boolean validateExpDate() {
		if (newRate.getEffDate() == null || newRate.getExpDate() == null) return true;
		
		if (newRate.getExpDate().before(newRate.getEffDate())) {
			valid = true;	// to not to show warning window
			
			String msg = FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Common",
					"exp_date_lt_eff_date");
			FacesMessage message = new FacesMessage(FacesMessage.SEVERITY_ERROR, msg, msg);
			FacesContext.getCurrentInstance().addMessage("rateModalForm:expDate", message);
			return false;
		} else {
			return true;
		}
		
	}

	public void validateScale(FacesContext context, UIComponent toValidate, Object value) {
		Double newValue = (Double) value;
		
		if (newValue.doubleValue() <= 0.0) {
			((UIInput) toValidate).setValid(false);
			valid = true;	// to not to show warning window

			String msg = FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Msg", "pos_number",
					toValidate.getAttributes().get("label"));
			FacesMessage message = new FacesMessage(FacesMessage.SEVERITY_ERROR, msg, msg);
			context.addMessage(toValidate.getClientId(context), message);
		}
	}

	public List<Rate> getAddedRates() {
		if (addedRates == null) {
			return new ArrayList<Rate>(0);
		}
		return addedRates;
	}

	public List<Rate> getRatesToInvalidate() {
		if (ratesToInvalidate == null) {
			return new ArrayList<Rate>(0);
		}
		return ratesToInvalidate;
	}

	public boolean isSelectAll() {
		return selectAll;
	}

	public void setSelectAll(boolean selectAll) {
		this.selectAll = selectAll;
	}

	public boolean isInvalidRate() {
		if (_activeRate != null) {
			return INVALID_RATE.equals(_activeRate.getStatus());
		}
		return false;
	}

	public String getTabName() {
		return tabName;
	}

	public void setTabName(String tabName) {
		needRerender = null;
		this.tabName = tabName;
		loadTab(tabName);
	}

	public void loadCurrentTab() {
		loadTab(tabName);
	}

	private void loadTab(String tab) {
		if (tab != null) {
			try {
				if (tab.equalsIgnoreCase("flexFieldsTab")) {
					MbFlexFieldsDataSearch bean = ManagedBeanWrapper.getManagedBean(MbFlexFieldsDataSearch.class);
					bean.clearFilter();
					bean.setTabName(tab);
					bean.setParentSectionId(getSectionId());
					bean.setTableState(getSateFromDB(bean.getComponentId()));

					if (_activeRate != null) {
						FlexFieldData filter = new FlexFieldData();
						filter.setInstId(_activeRate.getInstId());
						filter.setEntityType(EntityNames.CURRENCY_RATE);
						filter.setObjectId(_activeRate.getId().longValue());

						bean.setFilter(filter);
						bean.search();
					}
				}
			} catch (Exception e) {
				logger.error("", e);
				FacesUtils.addMessageError(e);
			}
		}
		needRerender = tab;
	}

	public String getSectionId() {
		return SectionIdConstants.CONFIGURATION_RATE_RATE;
	}

	public List<String> getRerenderList() {
		rerenderList = new ArrayList<String>();
		rerenderList.clear();
		if (needRerender != null) {
			rerenderList.add(needRerender);
		}
		rerenderList.add("err_ajax");
		return rerenderList;
	}

	@Override
	protected void applySectionFilter(Integer filterId) {
		try {
			FilterFactory factory = (FilterFactory) ManagedBeanWrapper.getManagedBean("filterFactory");
			Map<String, String> filterRec = factory.getSectionFilterRecs(filterId);
			sectionFilter = factory.getUserSectionFiltersObjects().get(filterId);
			if (filterRec != null) {
				filter = new Rate();
				setFilterForm(filterRec);
				if (searchAutomatically)
					search();
			}
			sectionFilterModeEdit = true;
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	@Override
	public void saveSectionFilter() {
		try {
			FilterFactory factory = (FilterFactory) ManagedBeanWrapper.getManagedBean("filterFactory");

			Map<String, String> filterRec = new HashMap<String, String>();
			filter = getFilter();
			setFilterRec(filterRec);

			sectionFilter = getSectionFilter();
			sectionFilter.setRecs(filterRec);

			factory.saveSectionFilter(sectionFilter, sectionFilterModeEdit);
			selectedSectionFilter = sectionFilter.getId();
			sectionFilterModeEdit = true;
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	private void setFilterForm(Map<String, String> filterRec) throws ParseException {
		getFilter();
		filters = new ArrayList<Filter>();
		if (filterRec.get("instId") != null) {
			filter.setInstId(Integer.valueOf(filterRec.get("instId")));
		}
		if (filterRec.get("status") != null) {
			filter.setStatus(filterRec.get("status"));
		}
		if (filterRec.get("rateType") != null) {
			filter.setRateType(filterRec.get("rateType"));
		}
		if (filterRec.get("effDate") != null) {
			SimpleDateFormat df = new SimpleDateFormat(DatePatterns.DATE_PATTERN);
			filter.setEffDate(df.parse(filterRec.get("effDate")));
		}
	}

	private void setFilterRec(Map<String, String> filterRec) {
		if (filter.getInstId() != null) {
			filterRec.put("instId", filter.getInstId().toString());
		}
		if (filter.getStatus() != null) {
			filterRec.put("status", filter.getStatus());
		}
		if (filter.getRateType() != null) {
			filterRec.put("rateType", filter.getRateType());
		}
		if (filter.getEffDate() != null) {
			SimpleDateFormat df = new SimpleDateFormat(DatePatterns.DATE_PATTERN);
			filterRec.put("effDate", df.format(filter.getEffDate()));
		}
	}

	public String getComponentId() {
		return COMPONENT_ID;
	}

	public Logger getLogger() {
		return logger;
	}
	
	public void initRatesToAdd() {
		try {
			if (isAdvancedMode() || newRate.getInstId() == null || newRate.getRateType() == null) {
				ratesToAdd = new Rate[0];
				return;
			}
			SelectionParams params = new SelectionParams(
				  new Filter("instId", newRate.getInstId())
				, new Filter("rateType", newRate.getRateType())
				, new Filter("inputMode", RateConstants.INPUT_MODE_OPERATOR));
			
			ratesToAdd = _commonDao.getRatePairsToAdd(userSessionId, params);
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
			ratesToAdd = new Rate[0];
		}
	}
	
	public Rate[] getRatesToAdd() {
		return ratesToAdd;
	}
	
    public Integer getRatesToAddLength(){
        return ratesToAdd != null ? ratesToAdd.length : 0;
    }

	public ArrayList<SelectItem> getInputModes() {
		if (inputModes == null) {
			inputModes = (ArrayList<SelectItem>) getDictUtils().getLov(LovConstants.RATE_INPUT_MODES);
		}
		if (inputModes == null)
			inputModes = new ArrayList<SelectItem>();
		return inputModes;
	}

	public boolean isSimpleMode() {
		return rateSetMode == RateConstants.SET_RATE_SIMPLE;
	}
	
	public boolean isAdvancedMode() {
		return rateSetMode == RateConstants.SET_RATE_ADVANCED;
	}

	public int getRateSetMode() {
		return rateSetMode;
	}

	public void setRateSetMode(int rateSetMode) {
		this.rateSetMode = rateSetMode;
	}
	
}
