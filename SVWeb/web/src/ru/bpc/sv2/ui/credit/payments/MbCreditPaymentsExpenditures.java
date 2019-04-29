package ru.bpc.sv2.ui.credit.payments;

import java.util.ArrayList;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.RequestScoped;

import org.ajax4jsf.model.ExtendedDataModel;
import org.apache.log4j.Logger;

import org.ajax4jsf.model.KeepAlive;
import ru.bpc.sv2.credit.CreditPaymentExpenditure;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.CreditDao;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;

@RequestScoped
@KeepAlive
@ManagedBean (name = "MbCreditPaymentsExpenditures")
public class MbCreditPaymentsExpenditures extends AbstractBean{
	private static final Logger logger = Logger.getLogger("CREDIT");

	private CreditDao creditDao = new CreditDao();

	private CreditPaymentExpenditure filter;
	private final DaoDataModel<CreditPaymentExpenditure> expendituresSource;
	private boolean searching;
	
	private static String COMPONENT_ID = "expanditureTable";
	private String tabName;
	private String parentSectionId;

	public MbCreditPaymentsExpenditures(){
		expendituresSource = new DaoDataModel<CreditPaymentExpenditure>(){
			@Override
			protected CreditPaymentExpenditure[] loadDaoData(SelectionParams params) {
				if (!searching)
					return new CreditPaymentExpenditure[0];
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return creditDao.getPaymentExpenditures( userSessionId, params);
				} catch (Exception e) {
					setDataSize(0);
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return new CreditPaymentExpenditure[0];
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (!searching)
					return 0;
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return creditDao.getPaymentExpendituresCount( userSessionId, params);
				} catch (Exception e){
					setDataSize(0);
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return 0;
			}
		};
	}

	private void setFilters(){
		Filter paramFilter = null;
		filters = new ArrayList<Filter>();
		if (filter.getPayId()!= null){
			paramFilter = new Filter();
			paramFilter.setElement("payId");
			paramFilter.setValue(filter.getPayId().toString());
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
		expendituresSource.flushCache();
	}

	public void clearFilter(){
		searching = false;
		filter = new CreditPaymentExpenditure();
		expendituresSource.flushCache();
	}

	public ExtendedDataModel getExpenditures(){
		return expendituresSource;
	}
	public void setFilter(CreditPaymentExpenditure filter){
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
