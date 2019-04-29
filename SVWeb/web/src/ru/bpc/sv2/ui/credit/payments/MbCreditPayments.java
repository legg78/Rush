package ru.bpc.sv2.ui.credit.payments;

import java.text.SimpleDateFormat;
import java.util.*;

import javax.annotation.PostConstruct;

import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.model.SelectItem;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;

import ru.bpc.sv2.constants.DictNames;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.constants.SectionIdConstants;
import ru.bpc.sv2.constants.application.ApplicationConstants;
import ru.bpc.sv2.credit.CreditPayment;
import ru.bpc.sv2.credit.CreditPaymentExpenditure;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.Filter.Operator;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.CreditDao;
import ru.bpc.sv2.ui.issuing.MbIssSelectObject;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.TableRowSelection;
import util.auxil.ManagedBeanWrapper;

@ViewScoped
@ManagedBean (name = "MbCreditPayments")
public class MbCreditPayments extends AbstractBean {
	private static final long serialVersionUID = -6945376029413872787L;

	private static final Logger logger = Logger.getLogger("CREDIT");

	private static final String DETAILS_TAB = "detailsTab";
	private static final String EXPENDITURE_TAB = "expenditureTab";

	private static String COMPONENT_ID = "2082:paymentsTable";

	private CreditDao creditDao = new CreditDao();

	private final DaoDataModel<CreditPayment> paymentSource;
	private ArrayList<SelectItem> institutions;
	private CreditPayment filter;
	private String tabName;
	private final TableRowSelection<CreditPayment> itemSelection;
	private CreditPayment activeCreditPayment;
	private HashMap<String, Boolean> loadedTabs = new HashMap<String, Boolean>();
	private String needRerender;
	private List<String> rerenderList;

	public MbCreditPayments() {
		pageLink = "credit|payments";
		tabName = DETAILS_TAB;
		paymentSource = new DaoDataModel<CreditPayment>() {
			private static final long serialVersionUID = -2565785025215867243L;

			@Override
			protected CreditPayment[] loadDaoData(SelectionParams params) {
				if (!searching)
					return new CreditPayment[0];
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return creditDao.getPayments(userSessionId, params);
				} catch (Exception e) {
					setDataSize(0);
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return new CreditPayment[0];
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (!searching)
					return 0;
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return creditDao.getPaymentsCount(userSessionId, params);
				} catch (Exception e) {
					setDataSize(0);
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return 0;
			}
		};
		itemSelection = new TableRowSelection<CreditPayment>(null, paymentSource);
		
	}

	@PostConstruct
	public void init() {
		setDefaultValues();
	}
	
	private void setFilters() {
		CreditPayment paymentFilter = getFilter();
		filters = new ArrayList<Filter>();
		Filter paramFilter = null;

		if (paymentFilter.getInstId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("instId");
			paramFilter.setValue(paymentFilter.getInstId());
			filters.add(paramFilter);
			paramFilter = new Filter();
			paramFilter.setElement("accountInstId");
			paramFilter.setValue(paymentFilter.getInstId());
			filters.add(paramFilter);
		}
        if (filter.getAccountId() != null) {
            paramFilter = new Filter("accountId", filter.getAccountId());
            filters.add(paramFilter);
        } else if (paymentFilter.getAccountNumber() != null && paymentFilter.getAccountNumber().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("accountNumber");
			paramFilter.setCondition("=");
			paramFilter.setValue(paymentFilter.getAccountNumber().trim().replaceAll("[*]", "%")
					.replaceAll("[?]", "_"));
			if (((String)paramFilter.getValue()).indexOf("%") != -1 || paymentFilter.getAccountNumber().indexOf("?") != -1) {
				paramFilter.setCondition("like");
			}
			filters.add(paramFilter);
		}
        if (filter.getCardId() != null) {
            paramFilter = new Filter("cardId", filter.getCardId());
            filters.add(paramFilter);
        } else if (paymentFilter.getCardNumber() != null && paymentFilter.getCardNumber().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("cardNumber");
			paramFilter.setValue(paymentFilter.getCardNumber().trim().toUpperCase().replaceAll(
					"[*]", "%").replaceAll("[?]", "_"));
			filters.add(paramFilter);
		}
		String dbDateFormat = "dd.MM.yyyy";
		SimpleDateFormat df = new SimpleDateFormat(dbDateFormat);
		if (paymentFilter.getDateFrom() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("dateFrom");
			paramFilter.setValue(df.format(paymentFilter.getDateFrom()));
			filters.add(paramFilter);
		}
		if (paymentFilter.getDateTo() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("dateTo");
			paramFilter.setValue(df.format(paymentFilter.getDateTo()));
			filters.add(paramFilter);
		}
		if (paymentFilter.getStatus() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("status");
			paramFilter.setValue(paymentFilter.getStatus());
			filters.add(paramFilter);
		}

		paramFilter = new Filter();
		paramFilter.setElement("lang");
		paramFilter.setOp(Operator.eq);
		paramFilter.setValue(userLang);
		filters.add(paramFilter);
	}


    public void search() {
        search(true);
    }

    public void search(boolean selectObject) {
        if (selectObject) {
            clearBean();
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
		searching = false;
		filter = null;
		clearBean();
		setDefaultValues();
	}

	private void clearBean() {
		paymentSource.flushCache();
		itemSelection.clearSelection();
		activeCreditPayment = null;
		clearDependencies();
        rerenderList = null;
	}

	private void clearDependencies() {
		MbCreditPaymentsExpenditures mbExpenditures = (MbCreditPaymentsExpenditures) ManagedBeanWrapper
				.getManagedBean("MbCreditPaymentsExpenditures");
		mbExpenditures.clearFilter();
	}

	private SimpleSelection prepareSelection() {
		if (activeCreditPayment == null && paymentSource.getRowCount() > 0) {
			setFirstRowActive();
		} else if (activeCreditPayment != null && paymentSource.getRowCount() > 0) {
			SimpleSelection selection = new SimpleSelection();
			selection.addKey(activeCreditPayment.getModelId());
			itemSelection.setWrappedSelection(selection);
			activeCreditPayment = itemSelection.getSingleSelection(); // ?
		}
		return itemSelection.getWrappedSelection();
	}

	private void setFirstRowActive() {
		paymentSource.setRowIndex(0);
		SimpleSelection selection = new SimpleSelection();
		activeCreditPayment = (CreditPayment) paymentSource.getRowData();
		selection.addKey(activeCreditPayment.getModelId());
		itemSelection.setWrappedSelection(selection);
		if (activeCreditPayment != null) {
			setInfo();
		}
	}

	private void setInfo() {
		loadedTabs.clear();
		loadTab(tabName);
	}

	private void loadTab(String tabName) {
		if (tabName == null) {
			return;
		}
		if (activeCreditPayment == null) {
			return;
		}
		if (tabName.equalsIgnoreCase(EXPENDITURE_TAB)) {
			MbCreditPaymentsExpenditures mbExpenditures = (MbCreditPaymentsExpenditures) ManagedBeanWrapper
					.getManagedBean("MbCreditPaymentsExpenditures");
			CreditPaymentExpenditure expendituresFilter = new CreditPaymentExpenditure();
			expendituresFilter.setPayId(activeCreditPayment.getId());
			mbExpenditures.setFilter(expendituresFilter);
			mbExpenditures.search();
		}
		needRerender = tabName;
		loadedTabs.put(tabName, Boolean.TRUE);
	}

	public ArrayList<SelectItem> getInstitutions() {
		if (institutions == null) {
			institutions = (ArrayList<SelectItem>) getDictUtils().getLov(LovConstants.INSTITUTIONS_SYS);
		}
		if (institutions == null)
			institutions = new ArrayList<SelectItem>();
		return institutions;
	}

	public List<SelectItem> getPaymentStatuses() {
		return getDictUtils().getArticles(DictNames.PAYMENT_STATUS, false, false);
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
		
		if (tabName.equalsIgnoreCase("expenditureTab")) {
			MbCreditPaymentsExpenditures bean = (MbCreditPaymentsExpenditures) ManagedBeanWrapper
					.getManagedBean("MbCreditPaymentsExpenditures");
			bean.setTabName(tabName);
			bean.setParentSectionId(getSectionId());
			bean.setTableState(getSateFromDB(bean.getComponentId()));
		}
	}
	
	public String getSectionId() {
		return SectionIdConstants.ISSUING_CREDIT_PAYMENT;
	}

	public DaoDataModel<CreditPayment> getPayments() {
		return paymentSource;
	}

	public SimpleSelection getItemSelection() {
		return prepareSelection();
	}

	public void setItemSelection(SimpleSelection selection) {
		itemSelection.setWrappedSelection(selection);
		activeCreditPayment = itemSelection.getSingleSelection();
		if (activeCreditPayment != null) {
			setInfo();
		}
	}

	public String getNeedRerender() {
		return this.needRerender;
	}

	public CreditPayment getActiveCreditPayment() {
		return activeCreditPayment;
	}

	public void setActiveCreditPayment(CreditPayment activeCreditPayment) {
		this.activeCreditPayment = activeCreditPayment;
	}

	/**
	 * @return <code>filter</code>, if it's null then this method creates new
	 *         filter with default values and returns it.
	 */
	public CreditPayment getFilter() {
		if (filter == null) {
			filter = new CreditPayment();
		}
		return filter;
	}

	public List<String> getRerenderList() {
        if (rerenderList == null) {
            rerenderList = new ArrayList<String>(Arrays.asList("paymentsTable", "dspayments", "pagesNum", getTabName()));
        }
        return rerenderList;
	}

    public List<String> getStoreTabRerenderList() {
        List<String> rerenderList = new ArrayList<String>();
        if (needRerender != null) {
            rerenderList.add(needRerender);
        }
        rerenderList.add("err_ajax");
        rerenderList.add(tabName);
        return rerenderList;
    }

	public String getComponentId() {
		return COMPONENT_ID;
	}

	public Logger getLogger() {
		return logger;
	}

	private void setDefaultValues() {
		if (sectionFilterModeEdit) return;
		
		Integer defaultInstId = null;
		List<SelectItem> instList = getInstitutions();
		if (userInstId == ApplicationConstants.DEFAULT_INSTITUTION && !instList.isEmpty()) {
			// instId from LOV is for some reason String 
			defaultInstId = Integer.valueOf((String) getInstitutions().get(0).getValue());
		} else {
			defaultInstId = userInstId;
		}
		
		filter = new CreditPayment();
		Calendar today = Calendar.getInstance();
		today.set(Calendar.HOUR, 0);
		today.set(Calendar.MINUTE, 0);
		today.set(Calendar.SECOND, 0);
		filter.setDateFrom(today.getTime());
		filter.setInstId(defaultInstId);
	}
}
