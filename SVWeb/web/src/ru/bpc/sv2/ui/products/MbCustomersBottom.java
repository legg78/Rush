package ru.bpc.sv2.ui.products;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;


import org.apache.commons.lang3.StringUtils;
import ru.bpc.sv2.constants.SystemConstants;
import ru.bpc.sv2.logic.utility.db.DataAccessException;
import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;

import ru.bpc.sv2.constants.EntityNames;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.ProductsDao;
import ru.bpc.sv2.products.Customer;
import ru.bpc.sv2.ui.acm.MbContextMenu;
import ru.bpc.sv2.ui.context.ContextType;
import ru.bpc.sv2.ui.context.ContextTypeFactory;
import ru.bpc.sv2.ui.utils.*;
import util.auxil.ManagedBeanWrapper;

@ViewScoped
@ManagedBean(name = "MbCustomersBottom")
public class MbCustomersBottom extends AbstractBean {
	private static final long serialVersionUID = -7372985491520189931L;
	private static final Logger logger = Logger.getLogger("PRD");

	private ProductsDao productsDao = new ProductsDao();

	private Customer filter;
	private Customer activeItem;

	private final DaoDataModel<Customer> dataModel;
	private final TableRowSelection<Customer> tableRowSelection;

	private ContextType ctxType;
	private String ctxItemEntityType;
	private static String COMPONENT_ID = "customerTable";
	private String tabName;
	private String parentSectionId;
	private boolean ctxAction = false;
	private String privilege;

	public MbCustomersBottom() {
		dataModel = new DaoDataListModel<Customer>(logger) {
			private static final long serialVersionUID = -4570677003201834000L;

			@Override
			protected List<Customer> loadDaoListData(SelectionParams params) {
				if (isSearching()) {
					setFilters();
					params.setPrivilege(privilege);
					params.setFilters(filters);
					return productsDao.getCustomers(userSessionId, params, userLang);
				}
				return new ArrayList<Customer>();
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (isSearching()) {
					setFilters();
					params.setPrivilege(privilege);
					params.setFilters(filters);
					return productsDao.getCustomersCount(userSessionId, params, userLang);
				}
				return 0;
			}
		};
		tableRowSelection = new TableRowSelection<Customer>(null, dataModel);
	}

	private void setFilters() {
		filters = new ArrayList<Filter>();

		if (StringUtils.isNotBlank(filter.getExtEntityType())) {
			filters.add(Filter.create("extEntityType", filter.getExtEntityType()));
		}
		if (filter.getExtObjectId() != null) {
			filters.add(Filter.create("extObjectId", filter.getExtObjectId()));
		}
	}

	public void search() {
		setCtxAction(false);
		clearState();
		clearBeansStates();
		searching = true;
	}

	public void clearState() {
		tableRowSelection.clearSelection();
		activeItem = null;
		dataModel.flushCache();
		curLang = userLang;
	}

	public void clearBeansStates() {

	}

	public void clearFilter() {
		filter = null;
		clearState();
		clearBeansStates();
		searching = false;
	}

	public SimpleSelection getItemSelection() {
		if (activeItem == null && dataModel.getRowCount() > 0) {
			prepareItemSelection();
		}
		return tableRowSelection.getWrappedSelection();
	}

	public void prepareItemSelection() {
		dataModel.setRowIndex(0);
		SimpleSelection selection = new SimpleSelection();
		activeItem = (Customer) dataModel.getRowData();
		selection.addKey(activeItem.getModelId());
		tableRowSelection.setWrappedSelection(selection);
		if (activeItem != null) {
			setBeansState();
		}
	}

	public void setItemSelection(SimpleSelection selection) {
		tableRowSelection.setWrappedSelection(selection);
		activeItem = tableRowSelection.getSingleSelection();
		if (activeItem != null) {
			setBeansState();
		}
	}

	public void setActiveCustomer(Customer activeCustomer) {
		this.activeItem = activeCustomer;
	}
	
	private void setBeansState() {

	}

	public Customer getFilter() {
		if (filter == null) {
			filter = new Customer();
		}
		return filter;
	}

	public DaoDataModel<Customer> getDataModel() {
		return dataModel;
	}

	public Customer getActiveItem() {
		return activeItem;
	}
	
	public void setActiveItem(Customer activeItem) {
		this.activeItem = activeItem;
	}

	public void associate(){
		MbCustomerSearchModal bean = ManagedBeanWrapper.getManagedBean(MbCustomerSearchModal.class);
		if (bean != null) {
			Customer selectedCustomer = bean.getActiveCustomer();
			if (selectedCustomer == null) {
				return;
			}

			if (!selectedCustomer.isCompanyCustomer()) {
				String error = FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Prd", "customer_must_be_company");
				FacesUtils.addMessageError(error);
				return;
			}

			selectedCustomer.setExtEntityType(filter.getExtEntityType());
			selectedCustomer.setExtObjectId(filter.getExtObjectId());

			Customer updatedCustomer = null;
			try {
				productsDao.associateCustomer(userSessionId, selectedCustomer);
				Filter filter = Filter.create("id", selectedCustomer.getId().longValue());
				SelectionParams params = new SelectionParams(filter);
				List<Customer> customers = productsDao.getCustomers(userSessionId, params, userLang);
				if (customers != null && !customers.isEmpty()) {
					dataModel.addNewObjectToList(customers.get(0), null);
				}
				activeItem = null;
			} catch (DataAccessException e) {
				logger.error(e);
				FacesUtils.addMessageError(e);
			}
		}
	}

	public void unbind(){
		try {
			productsDao.clearCustomerExtFields(userSessionId, activeItem);
		} catch (DataAccessException e){
			logger.error(e);
			FacesUtils.addMessageError(e);
		}
		dataModel.removeObjectFromList(activeItem);
		activeItem = null;
	}

	public String gotoCustomers() {
		MbCustomersNew customers = (MbCustomersNew) ManagedBeanWrapper.getManagedBean("MbCustomersNew");
		customers.clearFilter();
		customers.getFilter().setCustomerNumber(activeItem.getCustomerNumber());
		customers.getFilter().setInstId(activeItem.getInstId());
		customers.setRenderTabs(true);
		customers.setBeanRestored(true);	// to show tabs
		customers.searchByCustomer();
		return "products|customers";
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
		if (activeItem != null){
			setCtxAction(true);
			if (EntityNames.CUSTOMER.equals(ctxItemEntityType)) {
				map.put("id", activeItem.getId());
				map.put("instId", activeItem.getInstId());
				map.put("customerNumber", activeItem.getCustomerNumber());
				map.put("agentId", activeItem.getAgentId());
				map.put("contractNumber", activeItem.getContractNumber());
				
				ctxType.setParams(map);
			}
			if (EntityNames.INSTITUTION.equals(ctxItemEntityType)) {
				map.put("id", activeItem.getInstId());
				map.put("instId", activeItem.getInstId());
				ctxType.setParams(map);
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

	public boolean isCtxAction() {
		return ctxAction;
	}

	public void setCtxAction(boolean ctxAction) {
		this.ctxAction = ctxAction;
	}
	
	public boolean isEnableAssocBtn(){
		boolean result = false;
		
		if (dataModel.getDataSize() < 1){
			return true;
		}
		
		return result;
	}

	public void setPrivilege(String privilege) {
		this.privilege = privilege;
	}

	public void setAccociateFilter() {
		MbCustomerSearchModal bean = ManagedBeanWrapper.getManagedBean(MbCustomerSearchModal.class);
		if (bean != null) {
			bean.clearFilter();
			bean.getFilter().setInstId(getFilter().getInstId());
		}
	}
}
