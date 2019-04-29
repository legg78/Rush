package ru.bpc.sv2.ui.credit.debts;

import java.util.ArrayList;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;

import org.ajax4jsf.model.ExtendedDataModel;
import org.apache.log4j.Logger;

import ru.bpc.sv2.credit.CreditDebtPayment;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.CreditDao;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;

@ViewScoped
@ManagedBean (name = "MbCreditDebtsPayments")
public class MbCreditDebtsPayments extends AbstractBean{
	private static final Logger logger = Logger.getLogger("CREDIT");

	private CreditDao creditDao = new CreditDao();

	private CreditDebtPayment filter;
	private final DaoDataModel<CreditDebtPayment> paymentsSource;
	
	private static String COMPONENT_ID = "paymentsTable";
	private String tabName;
	private String parentSectionId;
	
	public MbCreditDebtsPayments(){
		paymentsSource = new DaoDataModel<CreditDebtPayment>(){
			@Override
			protected CreditDebtPayment[] loadDaoData(SelectionParams params) {
				if (!searching)
					return new CreditDebtPayment[0];
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return creditDao.getDebtPayments( userSessionId, params);
				} catch (Exception e) {
					setDataSize(0);
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return new CreditDebtPayment[0];
			}
			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (!searching)
					return 0;
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return creditDao.getDebtPaymentsCount( userSessionId, params);
				} catch (Exception e){
					setDataSize(0);
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return 0;
			}
		};
		filters = new ArrayList<Filter>();
	}

	private void setFilters(){
		Filter paramFilter = null;
		filters = new ArrayList<Filter>();
		if (filter.getDebtId()!=null){
			paramFilter = new Filter();
			paramFilter.setElement("debtId");
			paramFilter.setValue(filter.getDebtId().toString());
			filters.add(paramFilter);
		}
		paramFilter = new Filter();
		paramFilter.setElement("lang");
		paramFilter.setValue(userLang);
		filters.add(paramFilter);
	}

	public void search(){
		searching = true;
		clearBean();
	}

	private void clearBean(){
		paymentsSource.flushCache();
	}

	public void clearFilter(){
		searching = false;
		filter = new CreditDebtPayment();
		paymentsSource.flushCache();
	}

	public ExtendedDataModel getPayments(){
		return paymentsSource;
	}
	public CreditDebtPayment getFilter(){
		if (filter == null){
			filter = new CreditDebtPayment();
		}
		return filter;
	}
	public void setFilter(CreditDebtPayment filter){
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
