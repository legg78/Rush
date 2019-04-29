package ru.bpc.sv2.ui.svng;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.svng.ModuleDao;
import ru.bpc.sv2.ps.ModuleParam;
import ru.bpc.sv2.ui.utils.*;
import util.auxil.ManagedBeanWrapper;

import javax.annotation.PostConstruct;

import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.model.SelectItem;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.ResourceBundle;

@ViewScoped
@ManagedBean(name = "MbModuleParam")
public class MbModuleParam extends AbstractBean {
	private static final long serialVersionUID = 9180117082872879356L;
	private static Logger logger = Logger.getLogger("OPER_RPOCESSING");

	private ModuleDao moduleDao = new ModuleDao();

	private ModuleParam filter;
	private final DaoDataModel<ModuleParam> paramSource;

	private ModuleParam activeItem;
	private final TableRowSelection<ModuleParam> itemSelection;
	private String module;
	private boolean update = false;

	//for country mode
	private boolean country = false;
	private Map<String, String> regionsMap;

	public void setCountry(boolean country) {
		this.country = country;
	}

	public boolean isCountry() {
		return country;
	}

	public void setRegionsBundle(String regionsBundle) {
		ResourceBundle rb = ResourceBundle.getBundle(regionsBundle);
		regionsMap = new HashMap<String, String>();
		for (String key : rb.keySet()) {
			regionsMap.put(key, rb.getString(key));
		}
	}

	public Map<String, String> getRegionsMap() {
		return regionsMap;
	}

	public List<SelectItem> getRegionsMapSel() {
		if (regionsMap == null) {
			return null;
		}
		List<SelectItem> list = new ArrayList<SelectItem>();
		for (Map.Entry<String, String> en : regionsMap.entrySet()) {
			list.add(new SelectItem(en.getKey(), en.getValue()));
		}
		return list;
	}

	public MbModuleParam() {
		paramSource = new DaoDataModel<ModuleParam>() {
			private static final long serialVersionUID = 6896825197574225938L;

			@Override
			protected ModuleParam[] loadDaoData(SelectionParams params) {
				if (!searching) {
					return new ModuleParam[0];
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					if (country) {
						return moduleDao.getCountryParams(module, params);
					} else {
						return moduleDao.getParams(module, params);
					}
				} catch (Exception e) {
					setDataSize(0);
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return new ModuleParam[0];
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (!searching) {
					return 0;
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					if (country) {
						return (int) moduleDao.getCountryParamsCount(module, params);
					} else {
						return (int) moduleDao.getParamsCount(module, params);
					}
				} catch (Exception e) {
					setDataSize(0);
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return 0;
			}
		};
		itemSelection = new TableRowSelection<ModuleParam>(null, paramSource);
	}

	public void prepareAdd() {
		if (country) {
			activeItem = new CountryParam();
		} else {
			activeItem = new ModuleParam();
		}
		update = false;
	}

	public void prepareEdit() {
		update = true;
	}

	public void deleteParam() {
		if (activeItem == null || activeItem.getName() == null) {
			return;
		}
		try {
			moduleDao.deleteParam(module, activeItem.getId());
			clearBean();
		} catch (Exception ex) {
			logger.error("Error on deleting fee", ex);
			FacesUtils.addErrorExceptionMessage(ex);
		}
	}

	public boolean isUpdate() {
		return update;
	}

	public void saveParam() {
		try {
			moduleDao.saveParam(module, activeItem, update);
			clearBean();
		} catch (Exception ex) {
			logger.error("Error on saving fee", ex);
			FacesUtils.addErrorExceptionMessage(ex);
		}
	}

	@PostConstruct
	public void init() {
		setDefaultValues();
	}

	private void setFilters() {
		ModuleParam paramFilter = getFilter();
		filters = new ArrayList<Filter>();
		if (paramFilter.getName() != null && !paramFilter.getName().trim().isEmpty()) {
			filters.add(new Filter("name",
					paramFilter.getName().trim().replaceAll("[*]", "%").replaceAll("[?]", "_").toUpperCase()));
		}
		if (paramFilter.getValue() != null && !paramFilter.getValue().trim().isEmpty()) {
			filters.add(new Filter("value", paramFilter.getValue().trim()));
		}
		if (paramFilter.getInstId() != null) {
			filters.add(new Filter("instId", paramFilter.getInstId()));
		}
		if (paramFilter.getNetworkId() != null) {
			filters.add(new Filter("networkId", paramFilter.getNetworkId()));
		}
	}

	public SimpleSelection getItemSelection() {
		if (activeItem != null && paramSource.getRowCount() > 0) {
			SimpleSelection selection = new SimpleSelection();
			selection.addKey(activeItem.getModelId());
			itemSelection.setWrappedSelection(selection);
		}
		return itemSelection.getWrappedSelection();
	}

	public void setItemSelection(SimpleSelection selection) {
		itemSelection.setWrappedSelection(selection);
		if (country) {
			activeItem = new CountryParam(itemSelection.getSingleSelection());
		} else {
			activeItem = itemSelection.getSingleSelection();
		}
	}

	public String getModule() {
		return module;
	}

	public void setModule(String module) {
		this.module = module;
	}

	public void search() {
		setSearching(true);
		clearBean();
	}

	private void clearBean() {
		paramSource.flushCache();
		itemSelection.clearSelection();
		activeItem = null;
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

	public void setFilter(ModuleParam filter) {
		this.filter = filter;
	}

	public ModuleParam getFilter() {
		if (filter == null || !(filter instanceof CountryParam) && country || filter instanceof CountryParam && !country) {
			if (country) {
				filter = new CountryParam();
			} else {
				filter = new ModuleParam();
			}
		}
		return filter;
	}

	public DaoDataModel<ModuleParam> getItems() {
		return paramSource;
	}

	public ModuleParam getActiveItem() {
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
		if (country) {
			filter = new CountryParam();
		} else {
			filter = new ModuleParam();
		}
	}

	@Override
	protected void applySectionFilter(Integer filterId) {
		try {
			FilterFactory factory = (FilterFactory) ManagedBeanWrapper
					.getManagedBean("filterFactory");
			Map<String, String> filterRec = factory.getSectionFilterRecs(filterId);
			sectionFilter = factory.getUserSectionFiltersObjects().get(filterId);
			if (filterRec != null) {
				if (country) {
					filter = new CountryParam();
				} else {
					filter = new ModuleParam();
				}
				if (filterRec.get("institution") != null) {
					filter.setInstId(filterRec.get("institution"));
				}
				if (filterRec.get("name") != null) {
					filter.setName(filterRec.get("name"));
				}
				if (filterRec.get("networkId") != null) {
					filter.setNetworkId(Integer.parseInt(filterRec.get("networkId")));
				}
			}
			if (searchAutomatically) {
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
			FilterFactory factory = (FilterFactory) ManagedBeanWrapper
					.getManagedBean("filterFactory");

			Map<String, String> filterRec = new HashMap<String, String>();
			filter = getFilter();
			if (filter.getInstId() != null) {
				filterRec.put("institution", filter.getInstId());
			}
			if (filter.getName() != null) {
				filterRec.put("name", filter.getName());
			}
			if (filter.getNetworkId() != null) {
				filterRec.put("networkId", filter.getNetworkId().toString());
			}
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
}
