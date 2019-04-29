package ru.bpc.sv2.ui.products;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;

import ru.bpc.sv2.constants.EntityNames;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.ProductsDao;
import ru.bpc.sv2.products.ServiceObject;
import ru.bpc.sv2.ui.acm.MbContextMenu;
import ru.bpc.sv2.ui.context.ContextType;
import ru.bpc.sv2.ui.context.ContextTypeFactory;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.TableRowSelection;
import util.auxil.ManagedBeanWrapper;

@ViewScoped
@ManagedBean (name = "MbServiceObjects")
public class MbServiceObjects extends AbstractBean {
	private static final Logger logger = Logger.getLogger("PRODUCTS");

	private ProductsDao _productsDao = new ProductsDao();

	private ServiceObject filter;
	private ServiceObject newServiceObject;

	private final DaoDataModel<ServiceObject> _serviceObjectsSource;
	private final TableRowSelection<ServiceObject> _itemSelection;
	private ServiceObject _activeServiceObject;
	
	private static String COMPONENT_ID = "serviceObjectsTable";
	private String tabName;
	private String parentSectionId;
	
	private String ctxItemEntityType;
	private ContextType ctxType;

	public MbServiceObjects() {
		_serviceObjectsSource = new DaoDataModel<ServiceObject>() {
			@Override
			protected ServiceObject[] loadDaoData(SelectionParams params) {
				if (!searching)
					return new ServiceObject[0];
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));

					return _productsDao.getServiceObjects(userSessionId, params);
				} catch (Exception e) {
					setDataSize(0);
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return new ServiceObject[0];
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (!searching)
					return 0;
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));

					return _productsDao.getServiceObjectsCount(userSessionId, params);
				} catch (Exception e) {
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return 0;
			}
		};

		_itemSelection = new TableRowSelection<ServiceObject>(null, _serviceObjectsSource);
	}

	public DaoDataModel<ServiceObject> getServiceObjects() {
		return _serviceObjectsSource;
	}

	public ServiceObject getActiveServiceObject() {
		return _activeServiceObject;
	}

	public void setActiveServiceObject(ServiceObject activeServiceObject) {
		_activeServiceObject = activeServiceObject;
	}

	public SimpleSelection getItemSelection() {
		if (_activeServiceObject == null && _serviceObjectsSource.getRowCount() > 0) {
			setFirstRowActive();
		} else if (_activeServiceObject != null && _serviceObjectsSource.getRowCount() > 0) {
			SimpleSelection selection = new SimpleSelection();
			selection.addKey(_activeServiceObject.getModelId());
			_itemSelection.setWrappedSelection(selection);
			_activeServiceObject = _itemSelection.getSingleSelection();
		}
		return _itemSelection.getWrappedSelection();
	}

	public void setItemSelection(SimpleSelection selection) {
		_itemSelection.setWrappedSelection(selection);
		_activeServiceObject = _itemSelection.getSingleSelection();
		if (_activeServiceObject != null){
			setBeans();
		}
	}

	public void setFirstRowActive() {
		_serviceObjectsSource.setRowIndex(0);
		SimpleSelection selection = new SimpleSelection();
		_activeServiceObject = (ServiceObject) _serviceObjectsSource.getRowData();
		selection.addKey(_activeServiceObject.getModelId());
		_itemSelection.setWrappedSelection(selection);		
		setBeans();
	}

	public void add() {
		curMode = NEW_MODE;
	}

	public void edit() {
		curMode = EDIT_MODE;
	}

	public void save() {
		curMode = VIEW_MODE;
	}

	public void delete() {
		curMode = VIEW_MODE;
	}

	public void search() {
		curMode = VIEW_MODE;
		clearBean();
		
		setSearching(true);
	}

	private void setBeans() {
/*		mbObjectDetails.setObjectId(getActiveServiceObject().getObjectId());
		mbObjectDetails.setEntityType(getActiveServiceObject().getEntityType());
		mbObjectDetails.setLanguage(userLang);*/
	}

	public ServiceObject getFilter() {
		if (Boolean.TRUE.equals(FacesUtils.getSessionMapValue("initFromContext"))) {
			initFilterFromContext();
			search();
			FacesUtils.setSessionMapValue("initFromContext", null);
		}
		if (filter == null)
			filter = new ServiceObject();
		return filter;
	}
	
	private void initFilterFromContext() {
		filter = new ServiceObject();

		if (FacesUtils.getSessionMapValue("instId") != null) {
			filter.setInstId((Integer) FacesUtils.getSessionMapValue("instId"));
			FacesUtils.setSessionMapValue("instId", null);
		}
		if (FacesUtils.getSessionMapValue("serviceName") != null) {
			filter.setServiceName((String) FacesUtils.getSessionMapValue("serviceName"));
			FacesUtils.setSessionMapValue("serviceName", null);
		}
	}

	public void setFilter(ServiceObject filter) {
		this.filter = filter;
	}

	public void setFilters() {
		filter = getFilter();

		filters = new ArrayList<Filter>();

		Filter paramFilter = new Filter();
		paramFilter.setElement("lang");
		paramFilter.setValue(curLang);
		filters.add(paramFilter);

		if (filter.getContractId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("contractId");
			paramFilter.setValue(filter.getContractId());
			filters.add(paramFilter);
		}
		if (filter.getServiceId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("serviceId");
			paramFilter.setValue(filter.getServiceId());
			filters.add(paramFilter);
		}
		if (filter.getObjectId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("objectId");
			paramFilter.setValue(filter.getObjectId());
			filters.add(paramFilter);
		}
		if (filter.getEntityType() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("entityType");
			paramFilter.setValue(filter.getEntityType());
			filters.add(paramFilter);
		}
		if (filter.getServiceStatus() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("serviceStatus");
			paramFilter.setValue(filter.getServiceStatus());
			filters.add(paramFilter);
		}
		if (filter.getServiceName() != null && !filter.getServiceName().trim().equals("")) {
			paramFilter = new Filter();
			paramFilter.setElement("serviceName");
			paramFilter.setValue(filter.getServiceName().toUpperCase().replaceAll("[*]", "%") + "%");
			filters.add(paramFilter);
		}
	}

	public ServiceObject getNewServiceObject() {
		if (newServiceObject == null) {
			newServiceObject = new ServiceObject();
		}
		return newServiceObject;
	}

	public void setNewServiceObject(ServiceObject newServiceObject) {
		this.newServiceObject = newServiceObject;
	}

	public void close() {
		curMode = VIEW_MODE;
	}

	public int getCurMode() {
		return curMode;
	}

	public void clearBean() {
		// reset selection
		_itemSelection.clearSelection();
		_activeServiceObject = null;
		_serviceObjectsSource.flushCache();
	}
	
	public void clearFilter() {
		filter = null;
		clearBean();
		searching = false;
	}
	
	public String getCtxItemEntityType() {
		return ctxItemEntityType;
	}

	public void setCtxItemEntityType() {
		MbContextMenu ctxBean = (MbContextMenu) ManagedBeanWrapper.getManagedBean("MbContextMenu");
		String ctx = ctxBean.getEntityType();
		if (ctx == null || !ctx.equals(this.ctxItemEntityType)){
			ctxType = ContextTypeFactory.getInstance(ctx);
		}
		this.ctxItemEntityType = ctx;
	}
	
	public ContextType getCtxType(){
		if (ctxType == null) return null;
		Map <String, Object> map = new HashMap<String, Object>();
		
		if (_activeServiceObject != null){
			if (EntityNames.SERVICE.equals(ctxItemEntityType)) {
				map.put("id", _activeServiceObject.getServiceId());
				map.put("instId", _activeServiceObject.getInstId());
				map.put("serviceName", _activeServiceObject.getServiceName());
			}
		}

		ctxType.setParams(map);
		return ctxType;
	}
	
	public boolean isForward(){
		return true;
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
