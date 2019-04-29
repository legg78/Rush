package ru.bpc.sv2.ui.credit.invoices;

import java.text.SimpleDateFormat;

import java.util.ArrayList;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;

import ru.bpc.sv2.credit.CreditInvoiceDebt;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.invocation.Filter.Operator;
import ru.bpc.sv2.logic.CreditDao;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.CountryUtils;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.TableRowSelection;
import util.auxil.ManagedBeanWrapper;

@ViewScoped
@ManagedBean (name = "MbCreditInvoiceDebtsSearch")
public class MbCreditInvoiceDebtsSearch extends AbstractBean {
	private static final long serialVersionUID = 1L;

	private static final Logger logger = Logger.getLogger("CREDIT");
	
	private CreditDao _creditDao = new CreditDao();
	
	
	private CountryUtils countryUtils;
	
	private CreditInvoiceDebt invoiceFilter;
	private CreditInvoiceDebt newInvoiceDebt;
	
    private final DaoDataModel<CreditInvoiceDebt> _debtSource;
	private final TableRowSelection<CreditInvoiceDebt> _itemSelection;
	private CreditInvoiceDebt _activeInvoiceDebt;

	private static String COMPONENT_ID = "mainTable";
	private String tabName;
	private String parentSectionId;
	
	public MbCreditInvoiceDebtsSearch() {
		countryUtils = (CountryUtils) ManagedBeanWrapper.getManagedBean("CountryUtils");		
		
		_debtSource = new DaoDataModel<CreditInvoiceDebt>() {
			private static final long serialVersionUID = 1L;

			@Override
			protected CreditInvoiceDebt[] loadDaoData(SelectionParams params) {
				if (!searching || getFilter().getInvoiceId() == null)
					return new CreditInvoiceDebt[0];
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _creditDao.getInvoiceDebts( userSessionId, params);
				} catch (Exception e) {
					setDataSize(0);
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return new CreditInvoiceDebt[0];
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (!searching || getFilter().getInvoiceId() == null)
					return 0;
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _creditDao.getInvoiceDebtsCount( userSessionId, params);
				} catch (Exception e) {
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return 0;
			}
		};

		_itemSelection = new TableRowSelection<CreditInvoiceDebt>(null, _debtSource);
	}

	public DaoDataModel<CreditInvoiceDebt> getDebts() {
		return _debtSource;
	}

	public CreditInvoiceDebt getActiveInvoiceDebt() {
		return _activeInvoiceDebt;
	}

	public void setActiveInvoiceDebt(CreditInvoiceDebt activeInvoiceDebt) {
		_activeInvoiceDebt = activeInvoiceDebt;
	}

	public SimpleSelection getItemSelection() {
		if (_activeInvoiceDebt == null && _debtSource.getRowCount() > 0) {
			setFirstRowActive();
		}
		else if (_activeInvoiceDebt != null && _debtSource.getRowCount() > 0)
		{
			SimpleSelection selection = new SimpleSelection();
			selection.addKey(_activeInvoiceDebt.getModelId());
			_itemSelection.setWrappedSelection(selection);
			_activeInvoiceDebt = _itemSelection.getSingleSelection();			
		}
		return _itemSelection.getWrappedSelection();
	}

	public void setFirstRowActive() {
		_debtSource.setRowIndex(0);
		SimpleSelection selection = new SimpleSelection();
		_activeInvoiceDebt = (CreditInvoiceDebt) _debtSource.getRowData();
		selection.addKey(_activeInvoiceDebt.getModelId());
		_itemSelection.setWrappedSelection(selection);
		if (_activeInvoiceDebt != null) {
			setInfo();
		}
	}
	
	public void setItemSelection(SimpleSelection selection) {
		_itemSelection.setWrappedSelection( selection );
		_activeInvoiceDebt = _itemSelection.getSingleSelection();
		if (_activeInvoiceDebt != null) {
			setInfo();
		}
	}
	
	public void search() {
		setSearching(true);
		clearBean();
		clearBeansStates();
	}

	public void clearFilter() {
		invoiceFilter = new CreditInvoiceDebt();
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
		if (invoiceFilter.getCardNumber() != null
				&& invoiceFilter.getCardNumber().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("cardNumber");
			paramFilter.setOp(Operator.like);
			paramFilter.setValue(invoiceFilter.getCardNumber().trim()
					.toUpperCase().replaceAll("[*]", "%").replaceAll("[?]", "_"));
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
		newInvoiceDebt = new CreditInvoiceDebt();
		curMode = NEW_MODE;
	}
	
	public void edit() {
		try {
			newInvoiceDebt = (CreditInvoiceDebt) _activeInvoiceDebt.clone();
		} catch (CloneNotSupportedException e) {
			logger.error("",e);
			newInvoiceDebt = _activeInvoiceDebt;
		}
		curMode = EDIT_MODE;
	}
	
	
	public void cancel() {
		curMode = VIEW_MODE;
	}
	
	public CreditInvoiceDebt getFilter() {
		if (invoiceFilter == null) {
			invoiceFilter = new CreditInvoiceDebt();
		}
		return invoiceFilter;
	}

	public void setFilter(CreditInvoiceDebt invoiceFilter) {
		this.invoiceFilter = invoiceFilter;
	}

	public CreditInvoiceDebt getNewInvoiceDebt() {
		if (newInvoiceDebt == null) {
			newInvoiceDebt = new CreditInvoiceDebt();
		}
		return newInvoiceDebt;
	}

	public void setNewInvoiceDebt(CreditInvoiceDebt newInvoiceDebt) {
		this.newInvoiceDebt = newInvoiceDebt;
	}
	
	public boolean isViewMode() {
		return curMode == VIEW_MODE;
	}

	public boolean isEditMode() {
		return curMode == EDIT_MODE;
	}

	public boolean isNewMode() {
		return curMode == NEW_MODE;
	}
	
	public void clearBean() {
		// search using new criteria
		_debtSource.flushCache();
		// reset selection
		_itemSelection.clearSelection();
		_activeInvoiceDebt = null;		
	}

	public void clearBeansStates() {
		
	}
	
	public int getRowsNum() {
		return rowsNum;
	}

	public void setRowsNum(int rowsNum) {
		this.rowsNum = rowsNum;
	}
	
	public boolean isSearching() {
		return searching;
	}

	public void setSearching(boolean searching) {
		this.searching = searching;
	}

	public String getMerchantLocation() {
		if (_activeInvoiceDebt != null) {
			StringBuilder fullAddress = new StringBuilder();
			String countryName = null;
			countryName = countryUtils.getCountryNamesMap().get(_activeInvoiceDebt.getMerchantCountry());
			if (countryName != null && countryName.length() > 0) {
				fullAddress.append(countryName);
			}

			if (_activeInvoiceDebt.getMerchantCity() != null
					&& _activeInvoiceDebt.getMerchantCity().length() > 0) {
				if (fullAddress.length() > 0) {
					fullAddress.append(", ");
				}
				fullAddress.append(_activeInvoiceDebt.getMerchantCity());
			}
			if (_activeInvoiceDebt.getMerchantStreet() != null
					&& _activeInvoiceDebt.getMerchantStreet().length() > 0) {
				if (fullAddress.length() > 0) {
					fullAddress.append(", ");
				}
				fullAddress.append(_activeInvoiceDebt.getMerchantStreet());
			}

			return fullAddress.toString();
		}
		return "";
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
