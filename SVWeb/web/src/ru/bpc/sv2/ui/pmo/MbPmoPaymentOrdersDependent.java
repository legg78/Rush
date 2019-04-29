package ru.bpc.sv2.ui.pmo;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;


import ru.bpc.sv2.logic.PaymentOrdersDao;

import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;

import ru.bpc.sv2.acm.AcmAction;
import ru.bpc.sv2.constants.EntityNames;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.pmo.PmoPaymentOrder;
import ru.bpc.sv2.pmo.PmoPaymentOrderParameter;
import ru.bpc.sv2.ui.acm.MbContextMenu;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.TableRowSelection;
import util.auxil.ManagedBeanWrapper;

/**
 * Manage Bean for List Payment Orders tab.
 */
@ViewScoped
@ManagedBean (name = "MbPmoPaymentOrdersDependent")
public class MbPmoPaymentOrdersDependent extends AbstractBean {
	private static final Logger logger = Logger.getLogger("PAYMENT_ORDERS");

	private PaymentOrdersDao _paymentOrdersDao = new PaymentOrdersDao();

	private PmoPaymentOrder _activePaymentOrder;
	private PmoPaymentOrder newPaymentOrder;

	
	private PmoPaymentOrder paymentOrderFilter;
	private List<Filter> paymentOrderFilters;

	private boolean selectMode;

	private final DaoDataModel<PmoPaymentOrder> _paymentOrdersSource;

	private final TableRowSelection<PmoPaymentOrder> _paymentOrderSelection;

	public MbPmoPaymentOrdersDependent() {
		

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
	
	
	public PmoPaymentOrder getOrder(Long orderId) {
		_activePaymentOrder = null;
		if (orderId != null) {
			SelectionParams params = new SelectionParams();
			Filter[] filters = new Filter[2];
			filters[0] = new Filter("lang", curLang);
			filters[1] = new Filter("id", orderId);
			
			params.setFilters(filters);
			try {
				PmoPaymentOrder[] customers = _paymentOrdersDao.getPaymentOrders(userSessionId, params);
				if (customers != null && customers.length > 0) {
					_activePaymentOrder = customers[0];
					prepareDefaultAction();
				}
			} catch (Exception e) {
				logger.error("", e);
				FacesUtils.addMessageError(e);
				_activePaymentOrder = null;
			}
		}
		return _activePaymentOrder;
	}
	
	public List<PmoPaymentOrderParameter> getOrderParams() {
		List<PmoPaymentOrderParameter> result;
		if (_activePaymentOrder == null) {
			result = new ArrayList<PmoPaymentOrderParameter>(1);
			result.add(new PmoPaymentOrderParameter());
		} else {
			Filter[] filters = new Filter[2];
			filters[0] = new Filter("lang", curLang);
			filters[1] = new Filter("orderId", _activePaymentOrder.getId());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);
			params.setRowIndexEnd(Integer.MAX_VALUE);
			try {
				PmoPaymentOrderParameter[] orderParams = _paymentOrdersDao.getPaymentOrderParameters(userSessionId, params);
				if (orderParams.length == 0) {
					result = new ArrayList<PmoPaymentOrderParameter>(1);
					result.add(new PmoPaymentOrderParameter());
				} else {
					result = Arrays.asList(orderParams);
				}
			} catch (Exception e) {
				logger.error("", e);
				FacesUtils.addMessageError(e);

				result = new ArrayList<PmoPaymentOrderParameter>(1);
				result.add(new PmoPaymentOrderParameter());
			}
		}
		return result;
	}
	
	private AcmAction defaultAction;
	private AcmAction selectedCtxItem;
	
	private void prepareDefaultAction(){
		MbContextMenu ctx = ManagedBeanWrapper.getManagedBean(MbContextMenu.class);
		ctx.setEntityType(EntityNames.PAYMENT_ORDER);
		defaultAction = ctx.getDefaultAction(_activePaymentOrder.getInstId());
		selectedCtxItem = defaultAction;
	}
	
	public void initCtxParams() {
		MbContextMenu ctxBean = ManagedBeanWrapper.getManagedBean(MbContextMenu.class);
		ctxBean.setSelectedCtxItem(selectedCtxItem);
		ctxBean.initCtxParams(_activePaymentOrder.getEntityType(), _activePaymentOrder.getId());
		
		FacesUtils.setSessionMapValue("ENTITY_TYPE", _activePaymentOrder.getEntityType());
		FacesUtils.setSessionMapValue("OBJECT_ID", _activePaymentOrder.getId());
	}

	public String ctxPageForward() {
		initCtxParams();
		FacesUtils.setSessionMapValue("initFromContext", Boolean.TRUE);
		FacesUtils.setSessionMapValue("backLink", thisBackLink);

		return selectedCtxItem.getAction();
	}
	
	public AcmAction getDefaultAction(){
		return defaultAction;
	}
	
	public void setSelectedCtxItem(AcmAction selectedCtxItem){
		this.selectedCtxItem = selectedCtxItem;
	}
	
	public AcmAction getSelectedCtxItem(){
		return selectedCtxItem;
	}
}
