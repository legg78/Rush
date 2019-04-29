package ru.bpc.sv2.ui.pmo;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;

import ru.bpc.sv2.constants.EntityNames;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.PaymentOrdersDao;
import ru.bpc.sv2.pmo.PmoPaymentOrder;
import ru.bpc.sv2.pmo.PmoPaymentOrderParameter;
import ru.bpc.sv2.ui.acm.MbContextMenu;
import ru.bpc.sv2.ui.context.ContextType;
import ru.bpc.sv2.ui.context.ContextTypeFactory;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.TableRowSelection;
import util.auxil.ManagedBeanWrapper;

/**
 * Manage Bean for List Payment Orders tab.
 */
@ViewScoped
@ManagedBean(name = "MbPmoPaymentOrders")
public class MbPmoPaymentOrders extends AbstractBean {
	private static final Logger logger = Logger.getLogger("PAYMENT_ORDERS");

	private PaymentOrdersDao _paymentOrdersDao = new PaymentOrdersDao();

	private PmoPaymentOrder _activePaymentOrder;
	private PmoPaymentOrder newPaymentOrder;

	
	private PmoPaymentOrder paymentOrderFilter;
	private List<Filter> paymentOrderFilters;

	private boolean selectMode;

	private final DaoDataModel<PmoPaymentOrder> _paymentOrdersSource;

	private final TableRowSelection<PmoPaymentOrder> _paymentOrderSelection;
	
	private static String COMPONENT_ID = "paymentOrdersTable";
	private String tabName;
	private String parentSectionId;
	private String ctxItemEntityType;
	private ContextType ctxType;

	public MbPmoPaymentOrders() {
		

		_paymentOrdersSource = new DaoDataModel<PmoPaymentOrder>() {
			@Override
			protected PmoPaymentOrder[] loadDaoData(SelectionParams params) {
				if (!isSearching())
					return new PmoPaymentOrder[0];
				try {
					setPaymentOrdersFilters();
					params.setFilters(paymentOrderFilters.toArray(new Filter[paymentOrderFilters.size()]));
					return _paymentOrdersDao.getPaymentOrders(userSessionId, params);
				} catch (Exception e) {
					setDataSize(0);
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return new PmoPaymentOrder[0];
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (!isSearching())
					return 0;
				try {
					setPaymentOrdersFilters();
					params.setFilters(paymentOrderFilters.toArray(new Filter[paymentOrderFilters.size()]));
					return _paymentOrdersDao.getPaymentOrdersCount(userSessionId, params);
				} catch (Exception e) {
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return 0;
			}
		};
		_paymentOrderSelection = new TableRowSelection<PmoPaymentOrder>(null, _paymentOrdersSource);
	}

	public DaoDataModel<PmoPaymentOrder> getPaymentOrders() {
		return _paymentOrdersSource;
	}

	public PmoPaymentOrder getActivePaymentOrder() {
		return _activePaymentOrder;
	}

	public void setActivePaymentOrder(PmoPaymentOrder activePaymentOrder) {
		this._activePaymentOrder = activePaymentOrder;
	}

	public SimpleSelection getPaymentOrderSelection() {
		if (_activePaymentOrder == null && _paymentOrdersSource.getRowCount() > 0) {
			_paymentOrdersSource.setRowIndex(0);
			SimpleSelection selection = new SimpleSelection();
			_activePaymentOrder = (PmoPaymentOrder) _paymentOrdersSource.getRowData();
			selection.addKey(_activePaymentOrder.getModelId());
			_paymentOrderSelection.setWrappedSelection(selection);
		}
		return _paymentOrderSelection.getWrappedSelection();
	}

	public void setPaymentOrderSelection(SimpleSelection selection) {
		_paymentOrderSelection.setWrappedSelection(selection);
		_activePaymentOrder = _paymentOrderSelection.getSingleSelection();
	}

	public void search() {
		clearBean();
		boolean found = false;
		if (getPaymentOrderFilter().getCustomerId() != null) {
			found = true;
		}
		// if no selected customers found then we must not search for payment orders at all
		if (found) {
			searching = true;
		}
	}

	public void clearFilter() {
		paymentOrderFilter = null;
		clearBean();
	}

	public void clearBean() {
		searching = false;
		curLang = userLang;
		_paymentOrdersSource.flushCache();
		if (_paymentOrderSelection != null) {
			_paymentOrderSelection.clearSelection();
		}
		_activePaymentOrder = null;
	}

	public void setPaymentOrdersFilters() {
		List<Filter> filtersList = new ArrayList<Filter>();
		Filter paramFilter = null;
		
		if (getPaymentOrderFilter().getCustomerId() != null) {
			paramFilter = new Filter("customerId", getPaymentOrderFilter().getCustomerId());
			filtersList.add(paramFilter);
		}
		
		paramFilter = new Filter("lang", curLang);
		filtersList.add(paramFilter);
		paymentOrderFilters = filtersList;
	}

	public PmoPaymentOrder getPaymentOrderFilter() {
		if (paymentOrderFilter == null)
			paymentOrderFilter = new PmoPaymentOrder();
		return paymentOrderFilter;
	}

	public void setPaymentOrderFilter(PmoPaymentOrder paymentOrderFilter) {
		this.paymentOrderFilter = paymentOrderFilter;
	}

	public List<Filter> getPaymentOrderFilters() {
		return paymentOrderFilters;
	}

	public void setPaymentOrderFilters(List<Filter> paymentOrderFilters) {
		this.paymentOrderFilters = paymentOrderFilters;
	}

	public boolean isSelectMode() {
		return selectMode;
	}

	public void setSelectMode(boolean selectMode) {
		this.selectMode = selectMode;
	}

	public PmoPaymentOrder getNewPaymentOrder() {
		return newPaymentOrder;
	}

	public void setNewPaymentOrder(PmoPaymentOrder newPaymentOrder) {
		this.newPaymentOrder = newPaymentOrder;
	}
	
	public void viewPaymentOrder() {
		MbPmoOrderParameters beanSearch = (MbPmoOrderParameters) ManagedBeanWrapper
				.getManagedBean("MbPmoOrderParameters");
		PmoPaymentOrderParameter paramFilter = new PmoPaymentOrderParameter();
		paramFilter.setOrderId(_activePaymentOrder.getId());
		beanSearch.setFilter(paramFilter);
		beanSearch.setCurrentPaymentOrder(_activePaymentOrder);
		beanSearch.search();
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
		if (_activePaymentOrder != null){
			if (EntityNames.PAYMENT_ORDER.equals(ctxItemEntityType)) {
				map.put("id", _activePaymentOrder.getId());
			}
		}

		ctxType.setParams(map);
		return ctxType;
	}
	
	public boolean isForward(){
		return !ctxItemEntityType.equals(EntityNames.PAYMENT_ORDER);
	}
}
