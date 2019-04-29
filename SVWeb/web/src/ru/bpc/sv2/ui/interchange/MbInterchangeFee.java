package ru.bpc.sv2.ui.interchange;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;
import ru.bpc.sv2.interchange.FeeCriteria;
import ru.bpc.sv2.interchange.Fee;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.interchange.InterchangeDao;
import ru.bpc.sv2.ui.utils.*;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import util.auxil.ManagedBeanWrapper;

import javax.annotation.PostConstruct;

import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.context.FacesContext;
import javax.faces.model.SelectItem;
import javax.faces.view.facelets.FaceletContext;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.ResourceBundle;
import java.util.Set;
import java.util.SortedSet;
import java.util.TreeSet;

@ViewScoped
@ManagedBean(name = "MbInterchangeFee")
public class MbInterchangeFee extends AbstractBean {
	private static final long serialVersionUID = 9180117082872879356L;
	private static Logger logger = Logger.getLogger("OPER_RPOCESSING");

	private InterchangeDao interchangeDao = new InterchangeDao();

	private Fee filter;
	private final DaoDataModel<Fee> feesSource;

	private Fee activeItem;
	private FeeCriteria activeCriteria;
	private final TableRowSelection<Fee> itemSelection;
	private Map<String, Object> paramMap;
	private String criteriaId;
	private List<SelectItem> parameters;
	private String[] operators = {"==", "!=", ">", "<", ">=", "<=", "IN"};
	private String operator;
	private Map<String, String> dictionaries;
	private Map<String, String> dataTypes;
	private String parameter;
	private Map<String, String> regionsMap;
	private List<SelectItem> mcRegions;
	private String module;
	private Set<String> countryParams;
	private Set<String> currencyParams;

	public String getCriteriaId() {
		return criteriaId;
	}

	public List<SelectItem> getParameters() {
		if (parameters != null) {
			parameter = parameters.get(0).getValue().toString();
			return parameters;
		}
		return null;
	}

	public String getOperator() {
		return operator;
	}

	public void setOperator(String operator) {
		this.operator = operator;
	}

	private void loadParameters(String paramsBundle) {
		ResourceBundle rb = ResourceBundle.getBundle(paramsBundle);
		parameters = new ArrayList<SelectItem>();
		dictionaries = new HashMap<String, String>();
		dataTypes = new HashMap<String, String>();
		countryParams = new HashSet<String>();
		currencyParams = new HashSet<String>();
		SortedSet<String> keySet = new TreeSet<String>(rb.keySet());
		for (String key : keySet) {
			SelectItem si = new SelectItem();
			String[] value = rb.getString(key).split(":");
			si.setValue(key);
			si.setLabel(key + " - " + value[0]);
			dataTypes.put(key, value[1]);
			if (value.length > 2) {
				String dict = value[2];
				if (dict.equalsIgnoreCase("COUNTRY")) {
					countryParams.add(key);
				} else if (dict.equalsIgnoreCase("CURRENCY")) {
					currencyParams.add(key);
				} else {
					dictionaries.put(key, dict);
				}
			}
			parameters.add(si);
		}
	}

	public Set<String> getCurrencyParams() {
		return currencyParams;
	}

	public boolean isCountryParam() {
		if (countryParams == null || parameter == null) {
			return false;
		}
		return countryParams.contains(parameter);
	}

	public boolean isCurrencyParam() {
		if (currencyParams == null || parameter == null) {
			return false;
		}
		return currencyParams.contains(parameter);
	}

	public Set<String> getCountryParams() {
		return countryParams;
	}

	public void resetParameter() {
		parameter = null;
	}

	private void loadRegions(String regionsBundle) {
		if (regionsBundle == null || regionsBundle.trim().isEmpty()) {
			return;
		}
		ResourceBundle rb = ResourceBundle.getBundle(regionsBundle);
		mcRegions = new ArrayList<SelectItem>();
		regionsMap = new HashMap<String, String>();
		SortedSet<String> keySet = new TreeSet<String>(rb.keySet());
		for (String key : keySet) {
			String value = key + " - " + rb.getString(key);
			mcRegions.add(new SelectItem(key, value));
			regionsMap.put(key, value);
		}
	}

	public String getParameter() {
		return parameter;
	}

	public void setParameter(String parameter) {
		this.parameter = parameter;
	}

	public Map<String, String> getDictionaries() {
		return dictionaries;
	}

	public List<SelectItem> getParamDict() {
		DictUtils utils = (DictUtils) ManagedBeanWrapper.getManagedBean("DictUtils");
		return utils.getArticles(dictionaries.get(parameter));
	}

	public Map<String, String> getDataTypes() {
		return dataTypes;
	}

	public String[] getOperators() {
		return operators;
	}

	public void setCriteriaId(String criteriaId) {
		this.criteriaId = criteriaId;
		Long longId = Long.valueOf(criteriaId);
		for (FeeCriteria fc : criterias) {
			if (fc.getId().equals(longId)) {
				this.activeCriteria = fc;
				return;
			}
		}
	}

	public MbInterchangeFee() {
		feesSource = new DaoDataModel<Fee>() {
			private static final long serialVersionUID = 6886825197574225938L;

			@Override
			protected Fee[] loadDaoData(SelectionParams params) {
				if (!searching) {
					return new Fee[0];
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return interchangeDao.getFees(module, params);
				} catch (Exception e) {
					setDataSize(0);
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return new Fee[0];
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (!searching) {
					return 0;
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return (int) interchangeDao.getFeesCount(module, params);
				} catch (Exception e) {
					setDataSize(0);
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return 0;
			}
		};
		itemSelection = new TableRowSelection<Fee>(null, feesSource);
	}

	public Map<String, String> getRegionsMap() {
		return regionsMap;
	}

	public List<SelectItem> getMcRegions() {
		return mcRegions;
	}

	public boolean isRegionsEmpty() {
		if (mcRegions == null) {
			return false;
		}
		return mcRegions.isEmpty();
	}

	public FeeCriteria getActiveCriteria() {
		return activeCriteria;
	}

	private List<FeeCriteria> criterias;

	public List<FeeCriteria> getFeeCriterias() {
		try {
			if (activeItem != null && activeItem.getId() != null) {
				criterias = interchangeDao.getFeeCriterias(module, activeItem.getId());
				return criterias;
			}
		} catch (Exception ex) {
			logger.error("Error on loading fee criterias", ex);
			FacesUtils.addErrorExceptionMessage(ex);
		}
		return null;
	}

	public void prepareAdd() {
		activeItem = new Fee();
		activeItem.setType(0);
	}

	public void prepareCriteriaAdd() {
		activeCriteria = new FeeCriteria();
	}

	public void deleteFee() {
		if (activeItem == null || activeItem.getId() == null) {
			return;
		}
		try {
			interchangeDao.deleteFee(module, activeItem.getId());
			clearBean();
		} catch (Exception ex) {
			logger.error("Error on deleting fee", ex);
			FacesUtils.addErrorExceptionMessage(ex);
		}
	}

	public void saveFee() {
		try {
			boolean update = true;
			if (activeItem.getId() == null) {
				update = false;
			}
			if (activeItem.getType() == 0) {
				activeItem.setPercent(null);
			} else if (activeItem.getType() == 1) {
				activeItem.setAmount(null);
			}
			interchangeDao.saveFee(module, activeItem, update);
			clearBean();
		} catch (Exception ex) {
			logger.error("Error on saving fee", ex);
			FacesUtils.addErrorExceptionMessage(ex);
		}
	}

	public void saveCriteria() {
		try {
			boolean update = true;
			if (activeCriteria.getId() == null) {
				activeCriteria.setFeeId(activeItem.getId());
				update = false;
			}
			interchangeDao.saveFeeCriteria(module, activeCriteria, update);
		} catch (Exception ex) {
			logger.error("Error on saving fee criteria", ex);
			FacesUtils.addErrorExceptionMessage(ex);
		}
	}

	public void deleteCriteria() {
		if (activeCriteria == null || activeCriteria.getId() == null) {
			return;
		}
		try {
			interchangeDao.deleteFeeCriteria(module, activeCriteria.getId());
			activeCriteria = null;
		} catch (Exception ex) {
			logger.error("Error on deleting criteria", ex);
			FacesUtils.addErrorExceptionMessage(ex);
		}
	}

	@PostConstruct
	public void init() {
		filter = new Fee();
		String id = FacesContext.getCurrentInstance().getExternalContext().getRequestParameterMap().get("id");
		if (id != null) {
			module = FacesContext.getCurrentInstance().getExternalContext().getRequestParameterMap().get("module");
			filter.setId(Long.valueOf(id));
			setSearching(true);
			feesSource.flushCache();
		}
	}

	public void setModule(String module) {
		this.module = module;
	}

	public void setParamsBundle(String paramsBundle) {
		loadParameters(paramsBundle);
	}

	public void setRegionsBundle(String regionsBundle) {
		loadRegions(regionsBundle);
	}

	public String getModule() {
		return module;
	}

	private void setFilters() {
		Fee feeFilter = getFilter();
		filters = new ArrayList<Filter>();
		if (feeFilter.getId() != null) {
			filters.add(new Filter("id", feeFilter.getId()));
		}
		if (feeFilter.getType() != null) {
			filters.add(new Filter("type", feeFilter.getType()));
		}
		if (feeFilter.getCurrency() != null && !feeFilter.getCurrency().trim().isEmpty()) {
			filters.add(new Filter("currency", feeFilter.getCurrency()));
		}
		if (feeFilter.getDestinationCurrency() != null && !feeFilter.getDestinationCurrency().trim().isEmpty()) {
			filters.add(new Filter("destinationCurrency", feeFilter.getDestinationCurrency()));
		}
	}

	public SimpleSelection getItemSelection() {
		if (activeItem != null && feesSource.getRowCount() > 0) {
			SimpleSelection selection = new SimpleSelection();
			selection.addKey(activeItem.getModelId());
			itemSelection.setWrappedSelection(selection);
			if (activeItem.getId() != null) {
				activeItem = itemSelection.getSingleSelection();
			}
		}
		return itemSelection.getWrappedSelection();
	}

	public void setItemSelection(SimpleSelection selection) {
		itemSelection.setWrappedSelection(selection);
		activeItem = itemSelection.getSingleSelection();
	}

	private String getContextValue(String id) {
		FaceletContext faceletContext = (FaceletContext) FacesContext.getCurrentInstance().getAttributes()
				.get(FaceletContext.FACELET_CONTEXT_KEY);
		return (String) faceletContext.getAttribute(id);
	}


	public void search() {
		setSearching(true);
		clearBean();
		paramMap = new HashMap<String, Object>();
	}

	private void clearBean() {
		feesSource.flushCache();
		itemSelection.clearSelection();
		activeItem = null;
	}

	public void clearFilter() {
		filter = null;
		setSearching(false);
		clearBean();
		filter = new Fee();
	}

	public boolean getSearching() {
		return searching;
	}

	public void setFilter(Fee filter) {
		this.filter = filter;
	}

	public Fee getFilter() {
		if (filter == null) {
			filter = new Fee();
		}
		return filter;
	}

	public DaoDataModel<Fee> getItems() {
		return feesSource;
	}

	public Fee getActiveItem() {
		return activeItem;
	}

	public void setRowsNum(int rowsNum) {
		this.rowsNum = rowsNum;
	}

	public int getRowsNum() {
		return rowsNum;
	}

	public String getComponentId() {
		return "";
	}

	public Logger getLogger() {
		return logger;
	}

	public Map<String, Object> getParamMap() {
		if (paramMap == null) {
			paramMap = new HashMap<String, Object>();
		}
		return paramMap;
	}

	public void setParamMap(Map<String, Object> paramMap) {
		this.paramMap = paramMap;
	}
}
