package ru.bpc.sv2.ui.credit.invoices;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;
import ru.bpc.sv2.acm.AcmAction;
import ru.bpc.sv2.common.FlexFieldData;
import ru.bpc.sv2.constants.DataTypes;
import ru.bpc.sv2.constants.EntityNames;
import ru.bpc.sv2.constants.SectionIdConstants;
import ru.bpc.sv2.credit.*;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.Filter.Operator;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.CreditDao;
import ru.bpc.sv2.reports.ReportParameter;
import ru.bpc.sv2.ui.acm.MbContextMenu;
import ru.bpc.sv2.ui.common.flexible.MbFlexFieldsDataSearch;
import ru.bpc.sv2.ui.credit.debts.MbCreditDebtsInterests;
import ru.bpc.sv2.ui.issuing.MbIssSelectObject;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.TableRowSelection;
import util.auxil.ManagedBeanWrapper;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import java.math.BigDecimal;
import java.text.SimpleDateFormat;
import java.util.*;

@ViewScoped
@ManagedBean (name = "MbCreditInvoicesSearch")
public class MbCreditInvoicesSearch extends AbstractBean{
	private static final long serialVersionUID = 1L;

	private static final Logger logger = Logger.getLogger("CREDIT");
	private static final String INTERESTS_TAB = "INTERESTSTAB";
	private static final String MAD_TAB = "MADTAB";
	
	private static String COMPONENT_ID = "1698:invoicesTable";

	private CreditDao _creditDao = new CreditDao();
	
    private CreditInvoice invoiceFilter;
	private CreditInvoice newCreditInvoice;
	
    private String tabName;
    
    private final DaoDataModel<CreditInvoice> _invoiceSource;
	private final TableRowSelection<CreditInvoice> _itemSelection;
	private CreditInvoice _activeCreditInvoice;

	private HashMap<String, Boolean> loadedTabs = new HashMap<String, Boolean>();
	private String needRerender;
	private List<String> rerenderList;
	
	private AcmAction selectedCtxItem;
	private String ctxItemEntityType;
	
	public MbCreditInvoicesSearch() {
		pageLink = "credit|invoices";
		tabName = "detailsTab";
		
		_invoiceSource = new DaoDataModel<CreditInvoice>() {
			private static final long serialVersionUID = 1L;

			@Override
			protected CreditInvoice[] loadDaoData(SelectionParams params) {
				if (!searching)
					return new CreditInvoice[0];
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _creditDao.getInvoices( userSessionId, params);
				} catch (Exception e) {
					setDataSize(0);
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return new CreditInvoice[0];
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (!searching)
					return 0;
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _creditDao.getInvoicesCount( userSessionId, params);
				} catch (Exception e) {
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return 0;
			}
		};

		_itemSelection = new TableRowSelection<CreditInvoice>(null, _invoiceSource);
	}

	public DaoDataModel<CreditInvoice> getInvoices() {
		return _invoiceSource;
	}

	public CreditInvoice getActiveCreditInvoice() {
		return _activeCreditInvoice;
	}

	public void setActiveCreditInvoice(CreditInvoice activeCreditInvoice) {
		_activeCreditInvoice = activeCreditInvoice;
	}

	public SimpleSelection getItemSelection() {
		if (_activeCreditInvoice == null && _invoiceSource.getRowCount() > 0) {
			setFirstRowActive();
		}
		else if (_activeCreditInvoice != null && _invoiceSource.getRowCount() > 0)
		{
			SimpleSelection selection = new SimpleSelection();
			selection.addKey(_activeCreditInvoice.getModelId());
			_itemSelection.setWrappedSelection(selection);
			_activeCreditInvoice = _itemSelection.getSingleSelection();			
		}
		return _itemSelection.getWrappedSelection();
	}

	public void setFirstRowActive() {
		_invoiceSource.setRowIndex(0);
		SimpleSelection selection = new SimpleSelection();
		_activeCreditInvoice = (CreditInvoice) _invoiceSource.getRowData();
		selection.addKey(_activeCreditInvoice.getModelId());
		_itemSelection.setWrappedSelection(selection);
		if (_activeCreditInvoice != null) {
			setInfo();
		}
	}
	
	public void setItemSelection(SimpleSelection selection) {
		_itemSelection.setWrappedSelection( selection );
		_activeCreditInvoice = _itemSelection.getSingleSelection();
		if (_activeCreditInvoice != null) {
			setInfo();
		}
	}
	
	public void search() {
		search(true);
	}

    public void search(boolean selectObject) {
        if (selectObject) {
            clearBean();
            clearBeansStates();
            searching = false;
            MbIssSelectObject bean = ManagedBeanWrapper.getManagedBean(MbIssSelectObject.class);
            int size = bean.load(this);
            if (size > 1) {
                getRerenderList().clear();
                getRerenderList().add("searchBtn"); // need for open dialog
                getRerenderList().add(MbIssSelectObject.MODAL_ID);
            } else if(size == 0) {
                searching = true;
            }
        } else {
            searching = true;
        }
    }

    public boolean isNeedOpenSelectObjectDialog() {
        return getRerenderList().contains(MbIssSelectObject.MODAL_ID);
    }

	public void clearFilter() {
		invoiceFilter = new CreditInvoice();
		searching = false;
		clearBean();		
	}

	public void setInfo() {
		loadedTabs.clear();
		loadTab(getTabName());
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
		if (invoiceFilter.getAccountId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("accountId");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(invoiceFilter.getAccountId().toString());
			filters.add(paramFilter);
		} else if (invoiceFilter.getAccountNumber() != null && invoiceFilter.getAccountNumber().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("accountNumber");
			paramFilter.setCondition("=");
			paramFilter.setValue(invoiceFilter.getAccountNumber().trim().replaceAll("[*]", "%")
					.replaceAll("[?]", "_"));
			if (((String)paramFilter.getValue()).indexOf("%") != -1 || invoiceFilter.getAccountNumber().indexOf("?") != -1) {
				paramFilter.setCondition("like");
			}
			filters.add(paramFilter);
		}
		
		String dbDateFormat = "dd.MM.yyyy";
		SimpleDateFormat df = new SimpleDateFormat(dbDateFormat);
		if (invoiceFilter.getInvoiceDateFrom() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("invoiceDateFrom");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(df.format(getFilter().getInvoiceDateFrom()));
			filters.add(paramFilter);
		}
		if (invoiceFilter.getInvoiceDateTo() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("invoiceDateTo");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(df.format(getFilter().getInvoiceDateTo()));
			filters.add(paramFilter);
		}
		
		paramFilter = new Filter();
		paramFilter.setElement("lang");
		paramFilter.setOp(Operator.eq);
		paramFilter.setValue(userLang);
		filters.add(paramFilter);
	}

	public void add() {
		newCreditInvoice = new CreditInvoice();
		curMode = NEW_MODE;
	}
	
	public void edit() {
		try {
			newCreditInvoice = (CreditInvoice) _activeCreditInvoice.clone();
		} catch (CloneNotSupportedException e) {
			logger.error("",e);
			newCreditInvoice = _activeCreditInvoice;
		}
		curMode = EDIT_MODE;
	}
	
	
	public void cancel() {
		curMode = VIEW_MODE;
	}
	
	public CreditInvoice getFilter() {
		if (invoiceFilter == null) {
			invoiceFilter = new CreditInvoice();
		}
		return invoiceFilter;
	}

	public void setFilter(CreditInvoice invoiceFilter) {
		this.invoiceFilter = invoiceFilter;
	}

	public CreditInvoice getNewCreditInvoice() {
		if (newCreditInvoice == null) {
			newCreditInvoice = new CreditInvoice();
		}
		return newCreditInvoice;
	}

	public void setNewCreditInvoice(CreditInvoice newCreditInvoice) {
		this.newCreditInvoice = newCreditInvoice;
	}
	
	public void clearBean() {
		// search using new criteria
		_invoiceSource.flushCache();
		// reset selection
		_itemSelection.clearSelection();
		_activeCreditInvoice = null;
		clearBeansStates();
        rerenderList = null;
	}

	public void clearBeansStates() {

		MbFlexFieldsDataSearch flexible = (MbFlexFieldsDataSearch) ManagedBeanWrapper
				.getManagedBean("MbFlexFieldsDataSearch");
				flexible.clearFilter();

		MbCreditInvoiceDebtsSearch mbDebts = (MbCreditInvoiceDebtsSearch) ManagedBeanWrapper
				.getManagedBean("MbCreditInvoiceDebtsSearch");
				mbDebts.clearFilter();
				
		MbCreditInvoicePaymentsSearch mnPayments = (MbCreditInvoicePaymentsSearch) ManagedBeanWrapper
				.getManagedBean("MbCreditInvoicePaymentsSearch");
				mnPayments.clearFilter();
						
		MbCreditDebtsInterests mbInterests = (MbCreditDebtsInterests) ManagedBeanWrapper
				.getManagedBean("MbCreditDebtsInterests");
				mbInterests.clearFilter();
		
		MbInvoiceDebtsBalances mbInvoiceMad = (MbInvoiceDebtsBalances) ManagedBeanWrapper
				.getManagedBean("MbInvoiceDebtsBalances");
				mbInvoiceMad.clearFilter();
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

		if (tabName.equalsIgnoreCase("flexibleFieldsTab")) {
			MbFlexFieldsDataSearch bean = (MbFlexFieldsDataSearch) ManagedBeanWrapper.getManagedBean("MbFlexFieldsDataSearch");
			bean.setTabName(tabName);
			bean.setParentSectionId(getSectionId());
			bean.setTableState(getSateFromDB(bean.getComponentId()));
		} else if (tabName.equalsIgnoreCase("debtsTab")) {
			MbCreditInvoiceDebtsSearch bean = (MbCreditInvoiceDebtsSearch) ManagedBeanWrapper
					.getManagedBean("MbCreditInvoiceDebtsSearch");
			bean.setTabName(tabName);
			bean.setParentSectionId(getSectionId());
			bean.setTableState(getSateFromDB(bean.getComponentId()));
		} else if (tabName.equalsIgnoreCase("paymentsTab")) {
			MbCreditInvoicePaymentsSearch bean = (MbCreditInvoicePaymentsSearch) ManagedBeanWrapper
					.getManagedBean("MbCreditInvoicePaymentsSearch");
			bean.setTabName(tabName);
			bean.setParentSectionId(getSectionId());
			bean.setTableState(getSateFromDB(bean.getComponentId()));
		} else if (tabName.equalsIgnoreCase("AGINGSTAB")) {
			MbCreditAgingsSearch bean = (MbCreditAgingsSearch) ManagedBeanWrapper
					.getManagedBean("MbCreditAgingsSearch");
			bean.setTabName(tabName);
			bean.setParentSectionId(getSectionId());
			bean.setTableState(getSateFromDB(bean.getComponentId()));
		}
	}
	
	public String getSectionId() {
		return SectionIdConstants.ISSUING_CREDIT_INVOICE;
	}
	
	private void loadTab(String tab) {
		if (tab == null)
			return;
		if (_activeCreditInvoice == null)
			return;

		if (tab.equalsIgnoreCase("FLEXIBLEFIELDSTAB")) {
			MbFlexFieldsDataSearch flexible = (MbFlexFieldsDataSearch) ManagedBeanWrapper.getManagedBean("MbFlexFieldsDataSearch");
			FlexFieldData filterFlex = new FlexFieldData();
			filterFlex.setInstId(_activeCreditInvoice.getInstId());
			filterFlex.setEntityType(EntityNames.CREDIT_INVOICE);
			filterFlex.setObjectId(_activeCreditInvoice.getId());
			flexible.setFilter(filterFlex);
			flexible.search();
		} else if (tab.equalsIgnoreCase("DEBTSTAB")) {
			MbCreditInvoiceDebtsSearch debtsSearch = (MbCreditInvoiceDebtsSearch) ManagedBeanWrapper
					.getManagedBean("MbCreditInvoiceDebtsSearch");
			CreditInvoiceDebt debtFilter = new CreditInvoiceDebt();
			debtFilter.setInvoiceId(_activeCreditInvoice.getId());
			debtsSearch.setFilter(debtFilter);
			debtsSearch.search();
		} else if (tab.equalsIgnoreCase("PAYMENTSTAB")) {
			MbCreditInvoicePaymentsSearch debtsSearch = (MbCreditInvoicePaymentsSearch) ManagedBeanWrapper
					.getManagedBean("MbCreditInvoicePaymentsSearch");
			CreditInvoicePayment paymentFilter = new CreditInvoicePayment();
			paymentFilter.setInvoiceId(_activeCreditInvoice.getId());
			debtsSearch.setFilter(paymentFilter);
			debtsSearch.search();
		} else if (tab.equalsIgnoreCase("AGINGSTAB")) {
			MbCreditAgingsSearch agingsSearch = (MbCreditAgingsSearch) ManagedBeanWrapper
					.getManagedBean("MbCreditAgingsSearch");
			Aging filter = new Aging();
			filter.setInvoiceId(_activeCreditInvoice.getId());
			agingsSearch.setFilter(filter);
			agingsSearch.search();
		} else if (tabName.equalsIgnoreCase(INTERESTS_TAB)) {
			MbCreditDebtsInterests mbInterests = (MbCreditDebtsInterests) ManagedBeanWrapper
					.getManagedBean("MbCreditDebtsInterests");
			CreditDebtInterest interestsFilter = new CreditDebtInterest();
			interestsFilter.setAccountId(_activeCreditInvoice.getAccountId());
			interestsFilter.setInvoiceId(_activeCreditInvoice.getId());
			mbInterests.setFilter(interestsFilter);
			mbInterests.search();
		} else if (tabName.equalsIgnoreCase(MAD_TAB)) {
			MbInvoiceDebtsBalances mbBalances = (MbInvoiceDebtsBalances) ManagedBeanWrapper
					.getManagedBean("MbInvoiceDebtsBalances");
			CreditDebtBalance balancesFilter = new CreditDebtBalance();
			balancesFilter.setInvoiceId(_activeCreditInvoice.getId());
			mbBalances.setFilter(balancesFilter);
			mbBalances.search();
		}
		needRerender = tab;
		loadedTabs.put(tab, Boolean.TRUE);
	}

    public List<String> getRerenderList() {
        if (rerenderList == null) {
            rerenderList = new ArrayList<String>(Arrays.asList("invoicesTable", "dsinvoices", "pagesNum", getTabName()));
        }
        return rerenderList;
    }
	

	public List<String> getStoreTabRerenderList() {
        List<String> rerenderList = new ArrayList<String>();
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

	public String getComponentId() {
		return COMPONENT_ID;
	}

	public Logger getLogger() {
		return logger;
	}

	public void initCtxParams() {
		MbContextMenu ctxBean = (MbContextMenu) ManagedBeanWrapper.getManagedBean("MbContextMenu");
		selectedCtxItem = ctxBean.getSelectedCtxItem();
		ctxBean.initCtxParams(EntityNames.CREDIT_INVOICE, _activeCreditInvoice.getId());

		FacesUtils.setSessionMapValue("entityType", EntityNames.CREDIT_INVOICE);
		
		Map<String, ReportParameter> params = new HashMap<String, ReportParameter>();
		params.put("I_INVOICE_ID", new ReportParameter("I_INVOICE_ID", DataTypes.NUMBER,
				new BigDecimal(_activeCreditInvoice.getId())));

		FacesUtils.setSessionMapValue("reportParams", params);
	}

	public String ctxPageForward() {
		initCtxParams();
		FacesUtils.setSessionMapValue("initFromContext", Boolean.TRUE);
		FacesUtils.setSessionMapValue("backLink", thisBackLink);

		return selectedCtxItem.getAction();
	}

	public String getCtxItemEntityType() {
		return ctxItemEntityType;
	}

	public void setCtxItemEntityType(String ctxItemEntityType) {
		this.ctxItemEntityType = ctxItemEntityType;
	}
	
	public String doDefaultAction() {
		MbContextMenu ctx = (MbContextMenu) ManagedBeanWrapper.getManagedBean("MbContextMenu");
		AcmAction action = ctx.getDefaultAction(_activeCreditInvoice.getInstId());
		
		if (action != null) {
			selectedCtxItem = action;
			return ctxPageForward();
		}
		return "";
	}

	public void initCtxMenu() {
		if (_activeCreditInvoice == null) {
			return;
		}
		MbContextMenu ctxBean = (MbContextMenu) ManagedBeanWrapper.getManagedBean("MbContextMenu");
		ctxBean.setEntityType(EntityNames.CREDIT_INVOICE);
		ctxBean.setObjectType(null);
	}
}
