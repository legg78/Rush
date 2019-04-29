package ru.bpc.sv2.ui.products;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;
import ru.bpc.sv2.constants.DictNames;
import ru.bpc.sv2.constants.EntityNames;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.constants.SectionIdConstants;
import ru.bpc.sv2.constants.SystemConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.ProductsDao;
import ru.bpc.sv2.products.Service;
import ru.bpc.sv2.products.ServiceType;
import ru.bpc.sv2.ui.utils.*;
import util.auxil.ManagedBeanWrapper;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.event.ValueChangeEvent;
import javax.faces.model.SelectItem;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@ViewScoped
@ManagedBean (name = "MbServices")
public class MbServices extends AbstractBean {
	private static final long serialVersionUID = -2623054430618396141L;

	private static final Logger logger = Logger.getLogger("PRODUCTS");

	private static String COMPONENT_ID = "servicesTable";

	private ProductsDao _productsDao = new ProductsDao();

	private Service filter;
	private Service newService;
	private Service detailService;

	private final DaoDataModel<Service> _servicesSource;
	private final TableRowSelection<Service> _itemSelection;
	private Service _activeService;

	protected String tabName;
	private ArrayList<SelectItem> institutions;

	protected HashMap<String, Boolean> loadedTabs = new HashMap<String, Boolean>();
	private String needRerender;
	private List<String> rerenderList;

	private String oldLang;

	private String attrsTabElems; // defines which elements on attributesTab should be updated

	private String parentSectionId;
	
	public MbServices() {
		tabName = "detailsTab";
		pageLink = "services|services";
		_servicesSource = new DaoDataModel<Service>() {
			private static final long serialVersionUID = 6587662409957184757L;

			@Override
			protected Service[] loadDaoData(SelectionParams params) {
				if (!searching) {
					return new Service[0];
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _productsDao.getServices(userSessionId, params);
				} catch (Exception e) {
					setDataSize(0);
					logger.error("", e);
					FacesUtils.addMessageError(e);
					return new Service[0];
				}
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (!searching) {
					return 0;
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _productsDao.getServicesCount(userSessionId, params);
				} catch (Exception e) {
					logger.error("", e);
					FacesUtils.addMessageError(e);
					return 0;
				}
			}
		};

		_itemSelection = new TableRowSelection<Service>(null, _servicesSource);
	}

	public DaoDataModel<Service> getServices() {
		return _servicesSource;
	}

	public Service getActiveService() {
		return _activeService;
	}

	public void setActiveService(Service activeService) {
		_activeService = activeService;
	}

	public SimpleSelection getItemSelection() {
		try {
			if (_activeService == null && _servicesSource.getRowCount() > 0) {
				setFirstRowActive();
			} else if (_activeService != null && _servicesSource.getRowCount() > 0) {
				SimpleSelection selection = new SimpleSelection();
				selection.addKey(_activeService.getModelId());
				_itemSelection.setWrappedSelection(selection);
				_activeService = _itemSelection.getSingleSelection();
			}
		} catch (Exception e) {
			logger.error("", e);
			FacesUtils.addErrorExceptionMessage(e);
		}
		return _itemSelection.getWrappedSelection();
	}

	public void setItemSelection(SimpleSelection selection) {
		try {
			_itemSelection.setWrappedSelection(selection);
			boolean changeSelect = false;
			if (_itemSelection.getSingleSelection() != null 
					&& !_itemSelection.getSingleSelection().getId().equals(_activeService.getId())) {
				changeSelect = true;
			}
			_activeService = _itemSelection.getSingleSelection();
	
			if (_activeService != null) {
				setBeans();
				if (changeSelect) {
					detailService = (Service) _activeService.clone();
				}
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void setFirstRowActive() throws CloneNotSupportedException {
		_servicesSource.setRowIndex(0);
		SimpleSelection selection = new SimpleSelection();
		_activeService = (Service) _servicesSource.getRowData();
		detailService = (Service) _activeService.clone();
		selection.addKey(_activeService.getModelId());
		_itemSelection.setWrappedSelection(selection);

		setBeans();
	}

	/**
	 * Sets data for backing beans used by dependent pages
	 */
	public void setBeans() {
		loadedTabs.clear();
		loadTab(getTabName());
	}

	public void setFilters() {
		getFilter();
		filters = new ArrayList<Filter>();

		Filter paramFilter = new Filter();
		paramFilter.setElement("lang");
		paramFilter.setValue(userLang);
		filters.add(paramFilter);

		if (filter.getId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("id");
			paramFilter.setValue(filter.getId().toString());
			filters.add(paramFilter);
		}
		if (filter.getLabel() != null && filter.getLabel().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("label");
			paramFilter.setValue(filter.getLabel().trim().toUpperCase().replaceAll("[*]", "%")
					.replaceAll("[?]", "_"));
			filters.add(paramFilter);
		}
		if (filter.getDescription() != null && filter.getDescription().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("label");
			paramFilter.setValue(filter.getDescription().trim().toUpperCase()
					.replaceAll("[*]", "%").replaceAll("[?]", "_"));
			filters.add(paramFilter);
		}
		if (filter.getInstId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("instId");
			paramFilter.setValue(filter.getInstId().toString());
			filters.add(paramFilter);
		}
		if (filter.getServiceTypeId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("serviceTypeId");
			paramFilter.setValue(filter.getServiceTypeId().toString());
			filters.add(paramFilter);
		}
        if (filter.getServiceNumber() != null && filter.getServiceNumber().trim().length() > 0) {
            paramFilter = new Filter();
            paramFilter.setElement("serviceNumber");
            paramFilter.setValue(filter.getServiceNumber().trim());
            filters.add(paramFilter);
        }
	}

	public Service getFilter() {
		if (Boolean.TRUE.equals(FacesUtils.getSessionMapValue("initFromContext"))) {
			initFilterFromContext();
			search();
			FacesUtils.setSessionMapValue("initFromContext", null);
		}
		if (filter == null) {
			filter = new Service();
			filter.setInstId(userInstId);
		}
		return filter;
	}
	
	private void initFilterFromContext() {
		filter = new Service();
		if (FacesUtils.getSessionMapValue("instId") != null) {
			filter.setInstId((Integer) FacesUtils.getSessionMapValue("instId"));
			FacesUtils.setSessionMapValue("instId", null);
		}
		if (FacesUtils.getSessionMapValue("serviceName") != null) {
			filter.setLabel((String) FacesUtils.getSessionMapValue("serviceName"));
			FacesUtils.setSessionMapValue("serviceName", null);
		}
	}


	public void setFilter(Service filter) {
		this.filter = filter;
	}

	public void clearFilter() {
		filter = null;
		clearBean();

		searching = false;
	}

	public void search() {
		curMode = VIEW_MODE;
		clearBean();
		searching = true;
	}

	public void add() {
		newService = new Service();
		if (getFilter().getServiceTypeId() != null) {
			newService.setServiceTypeId(filter.getServiceTypeId());
		}
		newService.setLang(userLang);
		curLang = newService.getLang();
		curMode = NEW_MODE;
	}

	public void edit() {
		try {
			newService = (Service) detailService.clone();
		} catch (CloneNotSupportedException e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
			newService = _activeService;
		}
		curMode = EDIT_MODE;
	}

	public void delete() {
		try {
			_productsDao.removeService(userSessionId, _activeService);
			String msg = FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Prd", "service_deleted",
					"(id = " + _activeService.getId() + ")");

			_activeService = _itemSelection.removeObjectFromList(_activeService);
			if (_activeService == null) {
				clearBean();
			} else {
				setBeans();
				detailService = (Service) _activeService.clone();
			}

			FacesUtils.addMessageInfo(msg);
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void save() {
		try {
			if (isNewMode()) {
				newService = _productsDao.addService(userSessionId, newService);
				detailService = (Service) newService.clone();
				_itemSelection.addNewObjectToList(newService);
			} else {
				newService = _productsDao.editService(userSessionId, newService);
				detailService = (Service) newService.clone();
				if (!userLang.equals(newService.getLang())) {
					newService = getNodeByLang(_activeService.getId(), userLang);
				}
				_servicesSource.replaceObject(_activeService, newService);
			}
			_activeService = newService;
			curMode = VIEW_MODE;
			setBeans();

			FacesUtils.addMessageInfo(FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Prd",
					"service_saved"));
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void cancel() {
		curMode = VIEW_MODE;
	}

	public Service getNewService() {
		if (newService == null) {
			newService = new Service();
		}
		return newService;
	}

	public void setNewService(Service newService) {
		this.newService = newService;
	}

	public void clearBean() {
		curLang = userLang;
		_servicesSource.flushCache();
		_itemSelection.clearSelection();
		_activeService = null;
		detailService = null;
		clearBeans();
	}

	private void clearBeans() {
		MbObjectAttributes attrs = (MbObjectAttributes) ManagedBeanWrapper
				.getManagedBean("MbObjectAttributes");
		attrs.fullCleanBean();

		MbProductServices pServices = (MbProductServices) ManagedBeanWrapper
				.getManagedBean("MbProductServices");
		pServices.clearFilter();
	}

	public String getTabName() {
		return tabName;
	}

	public void keepTabName(String tabName) {
		this.tabName = tabName;
	}
	
	public void setTabName(String tabName) {
		needRerender = null;
		this.tabName = tabName;

		Boolean isLoadedCurrentTab = loadedTabs.get(tabName);

		if (isLoadedCurrentTab == null) {
			isLoadedCurrentTab = Boolean.FALSE;
		}

		if (isLoadedCurrentTab.equals(Boolean.TRUE)) {
			return;
		}

		loadTab(tabName);
		
		if (tabName.equalsIgnoreCase("attributesTab")) {
			MbAttributeValues bean = (MbAttributeValues) ManagedBeanWrapper
					.getManagedBean("MbAttributeValues");
			bean.setTabName(tabName);
			bean.setParentSectionId(getSectionId());
			bean.setTableState(getSateFromDB(bean.getComponentId()));
		}
	}
	
	public String getSectionId() {
		return SectionIdConstants.CONFIGURATION_SERVICING_SERVICE;
	}

	private void loadTab(String tab) {
		if (tab == null)
			return;
		if (_activeService == null || _activeService.getId() == null)
			return;

		if (tab.equalsIgnoreCase("attributesTab")) {
			MbObjectAttributes attrs = (MbObjectAttributes) ManagedBeanWrapper
					.getManagedBean("MbObjectAttributes");
			attrs.fullCleanBean();
			attrs.setServiceId(_activeService.getId());
			attrs.setEntityType(EntityNames.SERVICE);
			attrs.setInstId(_activeService.getInstId());
			attrs.setProductType(_activeService.getProductType());
		}
		if (tab.equalsIgnoreCase("productsTab")) {
			MbServiceProducts pServices = (MbServiceProducts) ManagedBeanWrapper
					.getManagedBean("MbServiceProducts");
			pServices.clearFilter();
			pServices.setServiceTypeId(_activeService.getServiceTypeId());
			pServices.setServiceStatus(_activeService.getStatus());
			pServices.setInstId(_activeService.getInstId());
			pServices.setServiceInitiating(_activeService.getIsInitiating());
			pServices.getFilter().setServiceId(_activeService.getId());
			pServices.getFilter().setServiceName(_activeService.getLabel());
			pServices.search();
		}
		if (tab.equalsIgnoreCase("contractsTab")) {
		}
		if (tab.equalsIgnoreCase("objectsTab")) {
		}
		if (tab.equalsIgnoreCase("applicationsTab")) {
		}
		needRerender = tab;
		loadedTabs.put(tab, Boolean.TRUE);
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

	public HashMap<String, Boolean> getLoadedTabs() {
		return loadedTabs;
	}

	public void changeLanguage(ValueChangeEvent event) {
		curLang = (String) event.getNewValue();
		detailService = getNodeByLang(detailService.getId(), curLang);
	}
	
	public Service getNodeByLang(Integer id, String lang) {
		Filter[] filters = new Filter[2];
		filters[0] = new Filter();
		filters[0].setElement("id");
		filters[0].setValue(id.toString());
		filters[1] = new Filter();
		filters[1].setElement("lang");
		filters[1].setValue(lang);

		SelectionParams params = new SelectionParams();
		params.setFilters(filters);
		try {
			Service[] types = _productsDao.getServices(userSessionId, params);
			if (types != null && types.length > 0) {
				return types[0];
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
		return null;
	}

	public ArrayList<SelectItem> getInstitutions() {
		if (institutions == null) {
			institutions = (ArrayList<SelectItem>) getDictUtils().getLov(LovConstants.INSTITUTIONS);
		}
		if (institutions == null)
			institutions = new ArrayList<SelectItem>();
		return institutions;
	}

	public ArrayList<SelectItem> getServiceTypes() {
		ArrayList<SelectItem> result = null;

		Filter[] filters = new Filter[1];
		filters[0] = new Filter();
		filters[0].setElement("lang");
		filters[0].setValue(curLang);

		SelectionParams params = new SelectionParams();
		params.setRowIndexEnd(Integer.MAX_VALUE);
		params.setFilters(filters);
		try {
			ServiceType[] types = _productsDao.getServiceTypes(userSessionId, params);
			result = new ArrayList<SelectItem>(types.length);
			for (ServiceType type: types) {
				result.add(new SelectItem(type.getId(), type.getLabel()));
			}
		} catch (Exception e) {
			logger.error("", e);
			if (e.getMessage().indexOf(SystemConstants.INSUFFICIENT_PRIVILEGES_ERROR) < 0) {
				FacesUtils.addMessageError(e);
			}
			result = new ArrayList<SelectItem>(0);
		}

		return result;
	}

	public ArrayList<SelectItem> getStatuses() {
		return getDictUtils().getArticles(DictNames.SERVICE_STATUS, true);
	}

	public void editLanguage(ValueChangeEvent event) {
		oldLang = (String) event.getOldValue();
	}

	public void confirmEditLanguage() {
		curLang = newService.getLang();
		Service tmp = getNodeByLang(newService.getId(), newService.getLang());
		if (tmp != null) {
			newService.setLabel(tmp.getLabel());
			newService.setDescription(tmp.getDescription());
		}
	}

	public void cancelEditLanguage() {
		newService.setLang(oldLang);
	}

	public String getAttrsTabElems() {
		return attrsTabElems;
	}

	public void setAttrsTabElems(String attrsTabElems) {
		this.attrsTabElems = attrsTabElems;
	}

	public String getElemsToUpdate() {
		if (tabName.equalsIgnoreCase("attributesTab")) {
			return attrsTabElems;
		}
		return tabName;
	}

	public String getComponentId() {
		if (parentSectionId != null && tabName != null) {
			return parentSectionId + ":" + tabName + ":" + COMPONENT_ID;
		} else {
			return "1659:servicesTable";
		}
	}

	public Logger getLogger() {
		return logger;
	}

	public Service getDetailService() {
		return detailService;
	}

	public void setDetailService(Service detailService) {
		this.detailService = detailService;
	}

	public void setParentSectionId(String parentSectionId) {
		this.parentSectionId = parentSectionId;
	}
	
	public Service getNode() {
		if (_activeService == null) {
			_activeService = new Service();
		}
		return _activeService;
	}
	
	public void setNode(Service node) {
		try {
			if (node == null)
				return;
			boolean changeSelect = false;
			if (!node.getId().equals(getNode().getId())) {
				changeSelect = true;
			}
			_activeService = node;
	
			setBeans();
			if (changeSelect) {
				detailService = (Service) _activeService.clone();
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
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
				filter = new Service();
				if (filterRec.get("instId") != null) {
					filter.setInstId(Integer.parseInt(filterRec.get("instId")));
				}
				if (filterRec.get("label") != null) {
					filter.setLabel(filterRec.get("label"));
				}
				if (filterRec.get("serviceTypeId") != null) {
					filter.setServiceTypeId(Integer.parseInt(filterRec.get("serviceTypeId")));
				}
				if (filterRec.get("serviceNumber") != null) {
					filter.setServiceNumber(filterRec.get("serviceNumber"));
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
				filterRec.put("instId", filter.getInstId().toString());
			}
			if (filter.getLabel() != null) {
				filterRec.put("label", filter.getLabel());
			}
			if (filter.getServiceTypeId() != null) {
				filterRec.put("serviceTypeId", filter.getServiceTypeId().toString());
			}
			if (filter.getServiceNumber() != null) {
				filterRec.put("serviceNumber", filter.getServiceNumber());
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
