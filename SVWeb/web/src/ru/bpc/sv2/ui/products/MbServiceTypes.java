package ru.bpc.sv2.ui.products;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;
import ru.bpc.sv2.constants.EntityNames;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.constants.SectionIdConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.ProductsDao;
import ru.bpc.sv2.products.ProductConstants;
import ru.bpc.sv2.products.ServiceType;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.TableRowSelection;
import util.auxil.ManagedBeanWrapper;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.event.ValueChangeEvent;
import javax.faces.model.SelectItem;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

@ViewScoped
@ManagedBean(name = "MbServiceTypes")
public class MbServiceTypes extends AbstractBean {
	private static final Logger logger = Logger.getLogger("PRODUCTS");

	private static String COMPONENT_ID = "1658:serviceTypesTable";

	private ProductsDao _productsDao = new ProductsDao();

	private ServiceType filter;
	private ServiceType newServiceType;
	private ServiceType detailServiceType;
	

	private final DaoDataModel<ServiceType> _serviceTypesSource;
	private final TableRowSelection<ServiceType> _itemSelection;
	private ServiceType _activeServiceType;

	private String tabName;

	private HashMap<String, Boolean> loadedTabs = new HashMap<String, Boolean>();
	private String needRerender;
	private List<String> rerenderList;

	public MbServiceTypes() {
		pageLink = "services|serviceTypes";
		tabName = "detailsTab";
		
		_serviceTypesSource = new DaoDataModel<ServiceType>() {
			@Override
			protected ServiceType[] loadDaoData(SelectionParams params) {
				if (!searching) {
					return new ServiceType[0];
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _productsDao.getServiceTypes(userSessionId, params);
				} catch (Exception e) {
					setDataSize(0);
					logger.error("", e);
					FacesUtils.addMessageError(e);
					return new ServiceType[0];
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
					return _productsDao.getServiceTypesCount(userSessionId, params);
				} catch (Exception e) {
					logger.error("", e);
					FacesUtils.addMessageError(e);
					return 0;
				}
			}
		};

		_itemSelection = new TableRowSelection<ServiceType>(null, _serviceTypesSource);
	}

	public DaoDataModel<ServiceType> getServiceTypes() {
		return _serviceTypesSource;
	}

	public ServiceType getActiveServiceType() {
		return _activeServiceType;
	}

	public void setActiveServiceType(ServiceType activeServiceType) {
		_activeServiceType = activeServiceType;
	}

	public SimpleSelection getItemSelection() {
		try {
			if (_activeServiceType == null && _serviceTypesSource.getRowCount() > 0) {
				setFirstRowActive();
			} else if (_activeServiceType != null && _serviceTypesSource.getRowCount() > 0) {
				SimpleSelection selection = new SimpleSelection();
				selection.addKey(_activeServiceType.getModelId());
				_itemSelection.setWrappedSelection(selection);
				_activeServiceType = _itemSelection.getSingleSelection();
			}
		} catch (Exception e) {
			logger.error("", e);
			FacesUtils.addMessageError(e);
		}
		return _itemSelection.getWrappedSelection();
	}

	public void setItemSelection(SimpleSelection selection) {
		try {
			_itemSelection.setWrappedSelection(selection);
			boolean changeSelect = false;
			if (_itemSelection.getSingleSelection() != null 
					&& !_itemSelection.getSingleSelection().getId().equals(_activeServiceType.getId())) {
				changeSelect = true;
			}
			_activeServiceType = _itemSelection.getSingleSelection();
	
			if (_activeServiceType != null) {
				setBeans();
				if (changeSelect) {
					detailServiceType = (ServiceType) _activeServiceType.clone();
				}
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void setFirstRowActive() throws CloneNotSupportedException {
		_serviceTypesSource.setRowIndex(0);
		SimpleSelection selection = new SimpleSelection();
		_activeServiceType = (ServiceType) _serviceTypesSource.getRowData();
		detailServiceType = (ServiceType) _activeServiceType.clone();
		selection.addKey(_activeServiceType.getModelId());
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
			paramFilter.setElement("description");
			paramFilter.setValue(filter.getDescription().trim().toUpperCase()
					.replaceAll("[*]", "%").replaceAll("[?]", "_"));
			filters.add(paramFilter);
		}

		if (filter.getProductEntityType() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("productType");
			paramFilter.setValue(filter.getProductEntityType());
			filters.add(paramFilter);
		}

		if (filter.getEntityType() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("entityType");
			paramFilter.setValue(filter.getEntityType());
			filters.add(paramFilter);
		}
		
		if (filter.getExternalCode() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("externalCode");
			paramFilter.setValue(filter.getExternalCode());
			filters.add(paramFilter);
		}
	}

	public ServiceType getFilter() {
		if (filter == null) {
			filter = new ServiceType();
		}
		return filter;
	}

	public void setFilter(ServiceType filter) {
		this.filter = filter;
	}

	public void clearFilter() {
		filter = new ServiceType();
		clearBean();

		searching = false;
	}

	public void search() {
		curMode = VIEW_MODE;
		clearBean();
		searching = true;
	}

	public void add() {
		newServiceType = new ServiceType();
		newServiceType.setLang(userLang);
		curLang = newServiceType.getLang();
		curMode = NEW_MODE;
	}

	public void edit() {
		try {
			newServiceType = (ServiceType) detailServiceType.clone();
		} catch (CloneNotSupportedException e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
			newServiceType = _activeServiceType;
		}
		curMode = EDIT_MODE;
	}

	public void delete() {
		try {
			_productsDao.removeServiceType(userSessionId, _activeServiceType);
			String msg = FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Prd", "service_type_deleted",
					"(id = " + _activeServiceType.getId() + ")");

			_activeServiceType = _itemSelection.removeObjectFromList(_activeServiceType);
			if (_activeServiceType == null) {
				clearBean();
			} else {
				setBeans();
				detailServiceType = (ServiceType) _activeServiceType.clone();
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
				newServiceType = _productsDao.addServiceType(userSessionId, newServiceType);
				detailServiceType = (ServiceType) newServiceType.clone();
				_itemSelection.addNewObjectToList(newServiceType);
			} else {
				newServiceType = _productsDao.editServiceType(userSessionId, newServiceType);
				detailServiceType = (ServiceType) newServiceType.clone();
				if (!userLang.equals(newServiceType.getLang())) {
					newServiceType = getNodeByLang(_activeServiceType.getId(), userLang);
				}
				_serviceTypesSource.replaceObject(_activeServiceType, newServiceType);
			}
			_activeServiceType = newServiceType;
			curMode = VIEW_MODE;
			setBeans();

			FacesUtils.addMessageInfo(FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Prd",
					"service_type_saved"));
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void cancel() {
		curMode = VIEW_MODE;
	}

	public ServiceType getNewServiceType() {
		if (newServiceType == null) {
			newServiceType = new ServiceType();
		}
		return newServiceType;
	}

	public void setNewServiceType(ServiceType newServiceType) {
		this.newServiceType = newServiceType;
	}

	public void clearBean() {
		curLang = userLang;
		_serviceTypesSource.flushCache();
		_itemSelection.clearSelection();
		_activeServiceType = null;
		detailServiceType = null;
		clearBeansStates();
	}

	public void clearBeansStates() {
		MbServices services = (MbServices) ManagedBeanWrapper.getManagedBean("MbServices");
		services.clearFilter();

		MbAttributes attrs = (MbAttributes) ManagedBeanWrapper.getManagedBean("MbAttributes");
		attrs.setDisableBottom(true);
		attrs.clearFilter();
	}

	public void changeLanguage(ValueChangeEvent event) {
		curLang = (String) event.getNewValue();
		detailServiceType = getNodeByLang(detailServiceType.getId(), curLang);
	}
	
	public ServiceType getNodeByLang(Integer id, String lang) {
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
			ServiceType[] types = _productsDao.getServiceTypes(userSessionId, params);
			if (types != null && types.length > 0) {
				return types[0];
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
		return null;
	}

	public String getTabName() {
		return tabName;
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
		
		if (tabName.equalsIgnoreCase("servicesTab")) {
			MbServices bean = (MbServices) ManagedBeanWrapper
					.getManagedBean("MbServices");
			bean.keepTabName(tabName);
			bean.setParentSectionId(getSectionId());
			bean.setTableState(getSateFromDB(bean.getComponentId()));
		}
	}
	
	public String getSectionId() {
		return SectionIdConstants.CONFIGURATION_SERVICING_TYPE;
	}

	private void loadTab(String tab) {
		if (tab == null)
			return;
		if (_activeServiceType == null || _activeServiceType.getId() == null)
			return;

		if (tab.equalsIgnoreCase("attributesTab")) {
			MbAttributes attrs = (MbAttributes) ManagedBeanWrapper.getManagedBean("MbAttributes");
			attrs.setFilter(null);
			attrs.getFilter().setServiceTypeId(_activeServiceType.getId());
			attrs.setDisableServiceType(true);
			attrs.setDisableBottom(false);
			attrs.setBottomMode(true);
			attrs.search();
		}
		if (tab.equalsIgnoreCase("servicesTab")) {
			MbServices services = (MbServices) ManagedBeanWrapper.getManagedBean("MbServices");
			services.getFilter().setInstId(null);
			services.getFilter().setServiceTypeId(_activeServiceType.getId());
			services.search();
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

	public List<SelectItem> getProductTypes() {
		return getDictUtils().getLov(LovConstants.PRODUCT_TYPES);
	}

	public List<SelectItem> getProductEntities() {
		if (ProductConstants.ISSUING_PRODUCT.equals(newServiceType.getProductEntityType())) {
			return getDictUtils().getLov(LovConstants.ISSUING_PRODUCT_ENTITIES);
		} else if (ProductConstants.ACQUIRING_PRODUCT.equals(newServiceType.getProductEntityType())) {
			return getDictUtils().getLov(LovConstants.ACQUIRING_PRODUCT_ENTITIES);
		} else if (ProductConstants.INSTITUTION_PRODUCT.equals(newServiceType.getProductEntityType())) {
			return getDictUtils().getLov(LovConstants.INSTITUTION_PRODUCT_ENTITIES);
		}
		return new ArrayList<SelectItem>(0);
	}

	public List<SelectItem> getProductEntitiesFilter() {
		if (ProductConstants.ISSUING_PRODUCT.equals(getFilter().getProductEntityType())) {
			return getDictUtils().getLov(LovConstants.ISSUING_PRODUCT_ENTITIES);
		} else if (ProductConstants.ACQUIRING_PRODUCT.equals(getFilter().getProductEntityType())) {
			return getDictUtils().getLov(LovConstants.ACQUIRING_PRODUCT_ENTITIES);
		} else if (ProductConstants.INSTITUTION_PRODUCT.equals(getFilter().getProductEntityType())) {
			return getDictUtils().getLov(LovConstants.INSTITUTION_PRODUCT_ENTITIES);
		}
		return getDictUtils().getLov(LovConstants.PRODUCT_ENTITIES);
	}

	public List<SelectItem> getEventTypes() {
		List<SelectItem> result = getDictUtils().getLov(LovConstants.EVENT_TYPES_DICT);
		return result;
	}
	
	public void confirmEditLanguage() {
		curLang = newServiceType.getLang();
		ServiceType tmp = getNodeByLang(newServiceType.getId(), newServiceType.getLang());
		if (tmp != null) {
			newServiceType.setLabel(tmp.getLabel());
			newServiceType.setDescription(tmp.getDescription());
		}
	}

	public String getComponentId() {
		return COMPONENT_ID;
	}

	public Logger getLogger() {
		return logger;
	}

	public ServiceType getDetailServiceType() {
		return detailServiceType;
	}

	public void setDetailServiceType(ServiceType detailServiceType) {
		this.detailServiceType = detailServiceType;
	}
}
