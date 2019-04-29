package ru.bpc.sv2.ui.pmo;

import java.util.ArrayList;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;

import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.Filter.Operator;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.PaymentOrdersDao;
import ru.bpc.sv2.pmo.PmoPaymentOrder;
import ru.bpc.sv2.pmo.PmoPaymentOrderParameter;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.TableRowSelection;

@ViewScoped
@ManagedBean (name = "MbPmoOrderParameters")
public class MbPmoOrderParameters extends AbstractBean {
	private static final Logger logger = Logger.getLogger("COMMON");
	
	
	private PmoPaymentOrderParameter filter;
	private final DaoDataModel<PmoPaymentOrderParameter> _paymentOrderParameterSource;
	private final TableRowSelection<PmoPaymentOrderParameter> _itemSelection;
	private PmoPaymentOrderParameter _activePaymentOrderParameter;
	private PmoPaymentOrder currentPaymentOrder; 
	
	private PaymentOrdersDao _paymentOrderDao = new PaymentOrdersDao();
	
	public MbPmoOrderParameters() {
				
		
		_paymentOrderParameterSource = new DaoDataModel<PmoPaymentOrderParameter>() {
			@Override
			protected PmoPaymentOrderParameter[] loadDaoData(SelectionParams params) {
				if (!searching) {
					return new PmoPaymentOrderParameter[0];
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _paymentOrderDao.getPaymentOrderParameters(userSessionId, params);
				} catch (Exception e) {
					FacesUtils.addMessageError(e);
					setDataSize(0);
					logger.error("", e);
				}
				return new PmoPaymentOrderParameter[0];
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (!searching) {
					return 0;
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _paymentOrderDao.getPaymentOrderParametersCount(userSessionId, params);
				} catch (Exception e) {
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return 0;
			}
		};

		_itemSelection = new TableRowSelection<PmoPaymentOrderParameter>(null, _paymentOrderParameterSource);
	}
	
	public SimpleSelection getItemSelection() {
		if (_activePaymentOrderParameter == null && _paymentOrderParameterSource.getRowCount() > 0) {
			setFirstRowActive();
		} else if (_activePaymentOrderParameter != null && _paymentOrderParameterSource.getRowCount() > 0) {
			SimpleSelection selection = new SimpleSelection();
			selection.addKey(_activePaymentOrderParameter.getModelId());
			_itemSelection.setWrappedSelection(selection);
			_activePaymentOrderParameter = _itemSelection.getSingleSelection();
		}
		return _itemSelection.getWrappedSelection();
	}

	public void setFirstRowActive() {
		_paymentOrderParameterSource.setRowIndex(0);
		SimpleSelection selection = new SimpleSelection();
		_activePaymentOrderParameter = (PmoPaymentOrderParameter) _paymentOrderParameterSource.getRowData();
		selection.addKey(_activePaymentOrderParameter.getModelId());
		_itemSelection.setWrappedSelection(selection);
//		if (_activeTranslation != null) {
//			setInfo();
//		}
	}

	public void setItemSelection(SimpleSelection selection) {
		_itemSelection.setWrappedSelection(selection);
		_activePaymentOrderParameter = _itemSelection.getSingleSelection();
//		if (_activeCard != null) {
//			setInfo();
//		}
	}
	
	public void clearState() {
		_itemSelection.clearSelection();
		_activePaymentOrderParameter = null;
		_paymentOrderParameterSource.flushCache();
		curLang = userLang;
//		loadedTabs.clear();

//		clearBeansStates();
	}
	
	public PmoPaymentOrderParameter getFilter() {
		if (filter == null) {
			filter = new PmoPaymentOrderParameter();
//			filter.setInstId(userInstId);
		}
		return filter;
	}
	
	public void setFilter(PmoPaymentOrderParameter filter) {
		this.filter = filter;
	}
	
	private void setFilters() {
		filter = getFilter();
		filters = new ArrayList<Filter>();

		Filter paramFilter;
		if (filter.getOrderId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("orderId");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(filter.getOrderId());
			filters.add(paramFilter);
		}
		if (filter.getId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("id");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(filter.getId());
			filters.add(paramFilter);
		}

		paramFilter = new Filter();
		paramFilter.setElement("lang");
		paramFilter.setOp(Operator.eq);
		paramFilter.setValue(curLang);
		filters.add(paramFilter);
	}
	
	public void search() {
		clearState();
//		clearBeansStates();
		searching = true;
	}
	
	public void cancel() {
		
	}
	
	public DaoDataModel<PmoPaymentOrderParameter> getPaymentOrderParameters() {
		return _paymentOrderParameterSource;
	}
	
	public PmoPaymentOrderParameter getActivePaymentOrderParameter() {
		return _activePaymentOrderParameter;
	}

	public void setActivePaymentOrderParameter(PmoPaymentOrderParameter activePaymentOrderParameter) {
		_activePaymentOrderParameter = activePaymentOrderParameter;
	}

	public PmoPaymentOrder getCurrentPaymentOrder() {
		return currentPaymentOrder;
	}

	public void setCurrentPaymentOrder(PmoPaymentOrder currentPaymentOrder) {
		this.currentPaymentOrder = currentPaymentOrder;
	}

	@Override
	public void clearFilter() {
		filter = new PmoPaymentOrderParameter();
		searching = false;
		clearState();
		
	}
	
}
