package ru.bpc.sv2.ui.credit.invoices;


import org.ajax4jsf.model.ExtendedDataModel;
import org.apache.log4j.Logger;
import ru.bpc.sv2.credit.CreditDebtBalance;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.CreditDao;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;

import java.util.ArrayList;

@ViewScoped
@ManagedBean(name = "MbInvoiceDebtsBalances")
public class MbInvoiceDebtsBalances extends AbstractBean {
    private static final Logger logger = Logger.getLogger("CREDIT");

    private CreditDao creditDao = new CreditDao();

    private CreditDebtBalance filter;
    private final DaoDataModel<CreditDebtBalance> balancesSource;

    private static String COMPONENT_ID = "balancesTable";
    private String tabName;
    private String parentSectionId;

    public MbInvoiceDebtsBalances(){
        balancesSource = new DaoDataModel<CreditDebtBalance>(){
            @Override
            protected CreditDebtBalance[] loadDaoData(SelectionParams params) {
                if (!searching)
                    return new CreditDebtBalance[0];
                try {
                    setFilters();
                    params.setFilters(filters.toArray(new Filter[filters.size()]));
                    return creditDao.getMadDebtBalances(userSessionId, params);
                } catch (Exception e) {
                    setDataSize(0);
                    FacesUtils.addMessageError(e);
                    logger.error("", e);
                }
                return new CreditDebtBalance[0];
            }
            @Override
            protected int loadDaoDataSize(SelectionParams params) {
                if (!searching)
                    return 0;
                try {
                    setFilters();
                    params.setFilters(filters.toArray(new Filter[filters.size()]));
                    return creditDao.getMadDebtBalancesCount(userSessionId, params);
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
       
        if (filter.getAccountId()!=null){
            paramFilter = new Filter("accountId", getFilter().getAccountId());
            filters.add(paramFilter);
        }
		
		if (filter.getInvoiceId() != null){
            paramFilter = new Filter("invoiceId", getFilter().getInvoiceId());
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
        balancesSource.flushCache();
    }

    public void clearFilter(){
        searching = false;
        filter = new CreditDebtBalance();
        balancesSource.flushCache();
    }

    public ExtendedDataModel getBalances(){
        return balancesSource;
    }
    public CreditDebtBalance getFilter(){
        if (filter == null){
            filter = new CreditDebtBalance();
        }
        return filter;
    }
    public void setFilter(CreditDebtBalance filter){
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
