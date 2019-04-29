package ru.bpc.sv2.ui.aggregation;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;
import ru.bpc.sv2.aggregation.AggrParam;
import ru.bpc.sv2.aggregation.AggrRule;
import ru.bpc.sv2.aggregation.AggrType;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.aggregation.IntAggregationDao;
import ru.bpc.sv2.settings.constants.SettingsConstants;
import ru.bpc.sv2.ui.utils.*;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.cache.SettingsCache;
import util.auxil.ManagedBeanWrapper;

import javax.annotation.PostConstruct;

import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.model.SelectItem;
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
@ManagedBean(name = "MbIntAggregation")
public class MbIntAggregation extends AbstractBean {
	private static final long serialVersionUID = 9180117082872879356L;
	private static Logger logger = Logger.getLogger("OPER_RPOCESSING");

	private IntAggregationDao aggregationDao = new IntAggregationDao();

	private AggrType filter;
	private final DaoDataModel<AggrType> typeSource;

	private AggrType activeItem;
	private final TableRowSelection<AggrType> itemSelection;
	private int networkId = -1;
	private List<AggrRule> rules;
	private AggrRule activeRule;
	private List<SelectItem> paramsSel;
	private List<SelectItem> paramsExprSel;
	private Map<Long, String> paramsMap;
	private String parameter;
	private String operator;
	private Long ruleId;
	private List<AggrParam> params;
	private String[] operators = {"=", "<>", ">", "<", ">=", "<=", "BETWEEN", "LIKE", "IN"};
	private Map<String, String> dictionaries;
	private Map<String, String> dataTypes;
	private Set<String> countryParams;
	private Set<String> currencyParams;
	private boolean rulesAreValid = true;
	private Map<String, String> colsMap;
	private List<Map<String, Object>> results;
	private long lastId;
	private String module;

	public Map<String, String> getColsMap() {
		return colsMap;
	}

	public MbIntAggregation() {
		typeSource = new DaoDataModel<AggrType>() {
			private static final long serialVersionUID = 6886825197574225938L;

			@Override
			protected AggrType[] loadDaoData(SelectionParams params) {
				if (!searching) {
					return new AggrType[0];
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return aggregationDao.getAggrTypes(networkId, params);
				} catch (Exception e) {
					setDataSize(0);
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return new AggrType[0];
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (!searching) {
					return 0;
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return (int) aggregationDao.getAggrTypesCount(networkId, params);
				} catch (Exception e) {
					setDataSize(0);
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return 0;
			}
		};
		itemSelection = new TableRowSelection<AggrType>(null, typeSource);
	}

	public Long getRuleId() {
		return ruleId;
	}

	public void setRuleId(Long ruleId) {
		this.ruleId = ruleId;
		for (AggrRule r : rules) {
			if (r.getId().equals(ruleId)) {
				activeRule = r;
				return;
			}
		}
	}

	public String getOperator() {
		return operator;
	}

	public void setOperator(String operator) {
		this.operator = operator;
	}

	public void resetParameter() {
		parameter = null;
		operator = null;
	}

	public AggrRule getActiveRule() {
		return activeRule;
	}

	public List<AggrRule> getRules() {
		try {
			if (activeItem != null && activeItem.getId() != null) {
				rules = aggregationDao.getAggrRules(activeItem.getId());
				return rules;
			}
		} catch (Exception ex) {
			logger.error("Error on loading type rules", ex);
			FacesUtils.addErrorExceptionMessage(ex);
		}
		return null;
	}

	public void prepareAdd() {
		activeItem = new AggrType();
		if (paramsExprSel != null && !paramsExprSel.isEmpty()) {
			parameter = paramsExprSel.get(0).getValue().toString();
		}
		operator = operators[0];
	}

	public void prepareRuleAdd() {
		activeRule = new AggrRule();
	}

	public void deleteType() {
		if (activeItem == null || activeItem.getId() == null) {
			return;
		}
		try {
			aggregationDao.deleteAggrType(activeItem.getId());
			clearBean();
		} catch (Exception ex) {
			logger.error("Error on deleting type", ex);
			FacesUtils.addErrorExceptionMessage(ex);
		}
	}

	public void saveType() {
		try {
			boolean update = true;
			if (activeItem.getId() == null) {
				activeItem.setId(aggregationDao.getNewTypeId());
				update = false;
			}
			aggregationDao.saveAggrType(networkId, activeItem, update);
			clearBean();
		} catch (Exception ex) {
			logger.error("Error on saving type", ex);
			FacesUtils.addErrorExceptionMessage(ex);
		}
	}

	public void saveRule() {
		try {
			boolean update = true;
			if (activeRule.getId() == null) {
				activeRule.setId(aggregationDao.getNewRuleId());
				update = false;
			}
			activeRule.setAggrTypeId(activeItem.getId());
			aggregationDao.saveAggrRule(activeRule, update);
		} catch (Exception ex) {
			logger.error("Error on saving type rule", ex);
			FacesUtils.addErrorExceptionMessage(ex);
		}
	}

	public void deleteRule() {
		if (activeRule == null || activeRule.getId() == null) {
			return;
		}
		try {
			aggregationDao.deleteAggrRule(activeRule.getId());
			activeRule = null;
		} catch (Exception ex) {
			logger.error("Error on deleting criteria", ex);
			FacesUtils.addErrorExceptionMessage(ex);
		}
	}

	private void loadParameters(String paramsBundle) {
		ResourceBundle rb = ResourceBundle.getBundle(paramsBundle);
		dictionaries = new HashMap<String, String>();
		dataTypes = new HashMap<String, String>();
		countryParams = new HashSet<String>();
		currencyParams = new HashSet<String>();
		SortedSet<String> keySet = new TreeSet<String>(rb.keySet());
		for (String key : keySet) {
			String[] value = rb.getString(key).split(":");
			dataTypes.put(key, value[0]);
			if (value.length > 1) {
				String dict = value[1];
				if (dict.equalsIgnoreCase("COUNTRY")) {
					countryParams.add(key);
				} else if (dict.equalsIgnoreCase("CURRENCY")) {
					currencyParams.add(key);
				} else {
					dictionaries.put(key, dict);
				}
			}
		}
		for (AggrParam p : params) {
			String key = p.getTable() + '.' + p.getField();
			if (dataTypes.get(key) == null) {
				dataTypes.put(key, p.getType().toUpperCase());
			}
		}
	}

	public void setModule(String module) {
		this.module = module;
		int id = SettingsCache.getInstance().getParameterNumberValue(
				module.equalsIgnoreCase("MC") ? SettingsConstants.MC_NETWORK_ID : SettingsConstants.VISA_NETWORK_ID)
				.intValue();
		if (this.networkId == -1 || this.networkId != id) {
			this.networkId = id;
			try {
				params = aggregationDao.getAggrParams(networkId);
				if (params != null) {
					for (AggrParam p : params) {
						p.setField(p.getField().toLowerCase());
						p.setTable(p.getTable().toLowerCase());
					}
				}
			} catch (Exception ex) {
				ex.printStackTrace();
			}
		}
	}

	public void setParamsBundle(String paramsBundle) {
		loadParameters(paramsBundle);
		try {
			paramsMap = new HashMap<Long, String>();
			for (AggrParam p : params) {
				paramsMap.put(p.getId(), p.getName() + " (" + p.getTable() + '.' + p.getField() + ')');
			}
		} catch (Exception ex) {
			ex.printStackTrace();
		}
		paramsSel = new ArrayList<SelectItem>();
		for (Map.Entry<Long, String> en : paramsMap.entrySet()) {
			paramsSel.add(new SelectItem(en.getKey(), en.getValue()));
		}
		paramsExprSel = new ArrayList<SelectItem>();
		for (AggrParam p : params) {
			paramsExprSel.add(
					new SelectItem(p.getTable() + '.' + p.getField(),
							p.getName() + " (" + p.getTable() + '.' + p.getField() + ')'));
		}
	}

	public void validateRules() {
		rulesAreValid = aggregationDao.isRulesValid(activeItem.getId());
	}

	public boolean isRulesAreValid() {
		return rulesAreValid;
	}

	public Map<String, String> getDictionaries() {
		return dictionaries;
	}

	public Map<String, String> getDataTypes() {
		return dataTypes;
	}

	public Set<String> getCountryParams() {
		return countryParams;
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

	public List<SelectItem> getParamDict() {
		DictUtils utils = (DictUtils) ManagedBeanWrapper.getManagedBean("DictUtils");
		return utils.getArticles(dictionaries.get(parameter));
	}

	public Set<String> getCurrencyParams() {
		return currencyParams;
	}

	@PostConstruct
	public void init() {
		setDefaultValues();
	}

	private void setFilters() {
		AggrType typeFilter = getFilter();
		filters = new ArrayList<Filter>();
		if (typeFilter.getId() != null) {
			filters.add(new Filter("id", typeFilter.getId()));
		}
		if (typeFilter.getName() != null && !typeFilter.getName().trim().isEmpty()) {
			filters.add(new Filter("name", typeFilter.getName()));
		}
		if (typeFilter.getDescription() != null && !typeFilter.getDescription().trim().isEmpty()) {
			filters.add(new Filter("description", typeFilter.getDescription()));
		}
	}

	public SimpleSelection getItemSelection() {
		if (activeItem != null && typeSource.getRowCount() > 0) {
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

	public void search() {
		setSearching(true);
		activeRule = null;
		clearBean();
	}

	public List<SelectItem> getParameters() throws Exception {
		return paramsSel;
	}

	public List<SelectItem> getParamExp() throws Exception {
		return paramsExprSel;
	}

	public Map<Long, String> getParamsMap() {
		return paramsMap;
	}

	private List<AggrParam> getParams() {
		return params;
	}

	public String[] getOperators() {
		return operators;
	}

	public String getParameter() {
		return parameter;
	}

	public void setParameter(String parameter) {
		this.parameter = parameter;
	}

	private void clearBean() {
		typeSource.flushCache();
		itemSelection.clearSelection();
		activeItem = null;
	}

	public List<String> getResultColumns() {
		if (activeItem != null && activeItem.getId() != null) {
			List<String> columns = aggregationDao.getResultColumns(activeItem.getId());
			List<String> list = new ArrayList<String>();
			for (String s : columns) {
				list.add(s);
			}
			colsMap = aggregationDao.getResultColumnsMap(activeItem.getId());
			return list;
		}
		return null;
	}

	public List<Map<String, Object>> getResults() {
		if (activeItem != null && activeItem.getId() != null) {
			try {
				if (results == null || !activeItem.getId().equals(lastId)) {
					results = aggregationDao.getAggregationResults(activeItem.getId());
					lastId = activeItem.getId();
				}
				return results;
			} catch (Exception ex) {
				ex.printStackTrace();
			}
		}
		return null;
	}

	public void clearFilter() {
		filter = null;
		setSearching(false);
		clearBean();
		setDefaultValues();
	}

	public boolean getSearching() {
		return searching;
	}

	public AggrType getFilter() {
		if (filter == null) {
			filter = new AggrType();
		}
		return filter;
	}

	public DaoDataModel<AggrType> getItems() {
		return typeSource;
	}

	public AggrType getActiveItem() {
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

	private void setDefaultValues() {
		filter = new AggrType();
	}
}
