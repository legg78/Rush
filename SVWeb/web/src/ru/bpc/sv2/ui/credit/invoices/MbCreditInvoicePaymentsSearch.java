package ru.bpc.sv2.ui.credit.invoices;

import java.text.SimpleDateFormat;

import java.util.ArrayList;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;

import ru.bpc.sv2.credit.CreditInvoicePayment;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.invocation.Filter.Operator;
import ru.bpc.sv2.logic.CreditDao;
import ru.bpc.sv2.ui.utils.*;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import util.auxil.ManagedBeanWrapper;

@ViewScoped
@ManagedBean (name = "MbCreditInvoicePaymentsSearch")
public class MbCreditInvoicePaymentsSearch extends AbstractBean {
	private static final long serialVersionUID = 1L;

	private static final Logger logger = Logger.getLogger("CREDIT");
	
	private CreditDao _creditDao = new CreditDao();
	
	private CountryUtils countryUtils;
	
	private CreditInvoicePayment invoiceFilter;
	private CreditInvoicePayment newInvoicePayment;

    private final DaoDataModel<CreditInvoicePayment> _paymentSource;
	private final TableRowSelection<CreditInvoicePayment> _itemSelection;
	private CreditInvoicePayment _activeInvoicePayment;
	
	private static String COMPONENT_ID = "mainTable";
	private String tabName;
	private String parentSectionId;

	public MbCreditInvoicePaymentsSearch() {
		countryUtils = (CountryUtils) ManagedBeanWrapper.getManagedBean("CountryUtils");
		
		_paymentSource = new DaoDataModel<CreditInvoicePayment>() {
			private static final long serialVersionUID = 1L;

			@Override
			protected CreditInvoicePayment[] loadDaoData(SelectionParams params) {
				if (!searching || getFilter().getInvoiceId() == null)
					return new CreditInvoicePayment[0];
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _creditDao.getInvoicePayments( userSessionId, params);
				} catch (Exception e) {
					setDataSize(0);
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return new CreditInvoicePayment[0];
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (!searching || getFilter().getInvoiceId() == null)
					return 0;
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _creditDao.getInvoicePaymentsCount( userSessionId, params);
				} catch (Exception e) {
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return 0;
			}
		};

		_itemSelection = new TableRowSelection<CreditInvoicePayment>(null, _paymentSource);
	}

	public DaoDataModel<CreditInvoicePayment> getPayments() {
		return _paymentSource;
	}

	public CreditInvoicePayment getActiveInvoicePayment() {
		return _activeInvoicePayment;
	}

	public void setActiveInvoicePayment(CreditInvoicePayment activeInvoicePayment) {
		_activeInvoicePayment = activeInvoicePayment;
	}

	public SimpleSelection getItemSelection() {
		if (_activeInvoicePayment == null && _paymentSource.getRowCount() > 0) {
			setFirstRowActive();
		}
		else if (_activeInvoicePayment != null && _paymentSource.getRowCount() > 0)
		{
			SimpleSelection selection = new SimpleSelection();
			selection.addKey(_activeInvoicePayment.getModelId());
			_itemSelection.setWrappedSelection(selection);
			_activeInvoicePayment = _itemSelection.getSingleSelection();			
		}
		return _itemSelection.getWrappedSelection();
	}

	public void setFirstRowActive() {
		_paymentSource.setRowIndex(0);
		SimpleSelection selection = new SimpleSelection();
		_activeInvoicePayment = (CreditInvoicePayment) _paymentSource.getRowData();
		selection.addKey(_activeInvoicePayment.getModelId());
		_itemSelection.setWrappedSelection(selection);
		if (_activeInvoicePayment != null) {
			setInfo();
		}
	}
	
	public void setItemSelection(SimpleSelection selection) {
		_itemSelection.setWrappedSelection( selection );
		_activeInvoicePayment = _itemSelection.getSingleSelection();
		if (_activeInvoicePayment != null) {
			setInfo();
		}
	}
	
	public void search() {
		setSearching(true);
		clearBean();
		clearBeansStates();
	}

	public void clearFilter() {
		invoiceFilter = new CreditInvoicePayment();
		clearBean();		
	}

	public void setInfo() {
		
	}
	
	public void setFilters() {
		invoiceFilter = getFilter();

		filters = new ArrayList<Filter>();

		Filter paramFilter = null;
		
		if (invoiceFilter.getId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("id");
			paramFilter.setOp(Operator.like);
			paramFilter.setValue(invoiceFilter.getId().toString());
			filters.add(paramFilter);
		}
		if (invoiceFilter.getInvoiceId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("invoiceId");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(invoiceFilter.getInvoiceId().toString());
			filters.add(paramFilter);
		}
		
		if (invoiceFilter.getOperType() != null
				&& invoiceFilter.getOperType().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("operType");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(invoiceFilter.getOperType());
			filters.add(paramFilter);
		}
		
		String dbDateFormat = "dd.MM.yyyy";
		SimpleDateFormat df = new SimpleDateFormat(dbDateFormat);
		if (invoiceFilter.getOperDateFrom() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("operDateFrom");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(df.format(getFilter().getOperDateFrom()));
			filters.add(paramFilter);
		}
		if (invoiceFilter.getOperDateTo() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("operDateTo");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(df.format(getFilter().getOperDateTo()));
			filters.add(paramFilter);
		}
		
		paramFilter = new Filter();
		paramFilter.setElement("lang");
		paramFilter.setOp(Operator.eq);
		paramFilter.setValue(userLang);
		filters.add(paramFilter);
	}

	public void add() {
		newInvoicePayment = new CreditInvoicePayment();
		curMode = NEW_MODE;
	}
	
	public void edit() {
		try {
			newInvoicePayment = (CreditInvoicePayment) _activeInvoicePayment.clone();
		} catch (CloneNotSupportedException e) {
			logger.error("",e);
			newInvoicePayment = _activeInvoicePayment;
		}
		curMode = EDIT_MODE;
	}
	
	
	public void cancel() {
		curMode = VIEW_MODE;
	}
	
	public CreditInvoicePayment getFilter() {
		if (invoiceFilter == null) {
			invoiceFilter = new CreditInvoicePayment();
		}
		return invoiceFilter;
	}

	public void setFilter(CreditInvoicePayment invoiceFilter) {
		this.invoiceFilter = invoiceFilter;
	}

	public CreditInvoicePayment getNewInvoicePayment() {
		if (newInvoicePayment == null) {
			newInvoicePayment = new CreditInvoicePayment();
		}
		return newInvoicePayment;
	}

	public void setNewInvoicePayment(CreditInvoicePayment newInvoicePayment) {
		this.newInvoicePayment = newInvoicePayment;
	}
	
	public void clearBean() {
		// search using new criteria
		_paymentSource.flushCache();
		// reset selection
		_itemSelection.clearSelection();
		_activeInvoicePayment = null;		
	}

	public void clearBeansStates() {
		
	}
	
	public String getMerchantLocation() {
		if (_activeInvoicePayment != null) {
			StringBuilder fullAddress = new StringBuilder();
			String countryName = null;
			countryName = countryUtils.getCountryNamesMap().get(_activeInvoicePayment.getMerchantCountry());
			if (countryName != null && countryName.length() > 0) {
				fullAddress.append(countryName);
			}

			if (_activeInvoicePayment.getMerchantCity() != null
					&& _activeInvoicePayment.getMerchantCity().length() > 0) {
				if (fullAddress.length() > 0) {
					fullAddress.append(", ");
				}
				fullAddress.append(_activeInvoicePayment.getMerchantCity());
			}
			if (_activeInvoicePayment.getMerchantStreet() != null
					&& _activeInvoicePayment.getMerchantStreet().length() > 0) {
				if (fullAddress.length() > 0) {
					fullAddress.append(", ");
				}
				fullAddress.append(_activeInvoicePayment.getMerchantStreet());
			}

			return fullAddress.toString();
		}
		return "";
	}
	
	public void view(){
		
	}
	
	public void close(){
		
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
