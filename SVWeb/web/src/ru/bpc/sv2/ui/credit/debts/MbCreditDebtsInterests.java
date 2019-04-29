package ru.bpc.sv2.ui.credit.debts;

import org.ajax4jsf.model.ExtendedDataModel;
import org.apache.log4j.Logger;
import ru.bpc.sv2.credit.CreditDebtInterest;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.CreditDao;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataListModel;
import ru.bpc.sv2.ui.utils.DaoDataModel;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import java.util.ArrayList;
import java.util.List;

@ViewScoped
@ManagedBean (name = "MbCreditDebtsInterests")
public class MbCreditDebtsInterests extends AbstractBean {
	private static final Logger logger = Logger.getLogger("CREDIT");

	private CreditDao creditDao = new CreditDao();

	private CreditDebtInterest filter;
	private final DaoDataModel<CreditDebtInterest> interestsSource;
	
	private static String COMPONENT_ID = "interestsTable";
	private String tabName;
	private String parentSectionId;
	private boolean searchByDebt;
	private boolean searchByInvoice;

	public MbCreditDebtsInterests() {
		interestsSource = new DaoDataListModel<CreditDebtInterest>(logger) {
			@Override
			protected List<CreditDebtInterest> loadDaoListData(SelectionParams params) {
				if (searching) {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					if (searchByDebt && !searchByInvoice) {
						return creditDao.getDebtInterests( userSessionId, params);
					} else {
						return creditDao.getInvoiceInterests( userSessionId, params);
					}
				}
				return new ArrayList<CreditDebtInterest>();
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (searching) {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					if (searchByDebt && !searchByInvoice) {
						return creditDao.getDebtInterestsCount( userSessionId, params);
					} else {
						return creditDao.getInvoiceInterestsCount( userSessionId, params);
					}
				}
				return 0;
			}
		};
	}

	private void setFilters(){
		filters = new ArrayList<Filter>();
		filters.add(new Filter("lang", userLang));
		searchByDebt = false;
		searchByInvoice = false;
		if (filter.getAccountId() != null) {
			filters.add(new Filter("accountId", filter.getAccountId()));
		}
		if (filter.getDebtId()!=null) {
			filters.add(new Filter("debtId", filter.getDebtId()));
			searchByDebt = true;
		}
		if (filter.getInvoiceId() != null) {
			filters.add(new Filter("invoiceId", filter.getInvoiceId()));
			searchByInvoice = true;
		}
	}

	public void search(){
		searching = true;
		clearBean();
	}

	private void clearBean(){
		interestsSource.flushCache();
	}

	public void clearFilter(){
		searching = false;
		filter = new CreditDebtInterest();
		interestsSource.flushCache();
	}

	public ExtendedDataModel getInterests(){
		return interestsSource;
	}
	public void setFilter(CreditDebtInterest filter){
		this.filter = filter;
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


