package ru.bpc.sv2.ui.ps.visa.messages;

import org.ajax4jsf.model.ExtendedDataModel;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.VisaDao;
import ru.bpc.sv2.ps.visa.VisaFee;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import java.util.ArrayList;
import java.util.Map;

import org.apache.log4j.Logger;

@ViewScoped
@ManagedBean(name = "MbVisaFeesSearchBottom")
public class MbVisaFeesSearchBottom  extends AbstractBean {
    private static final Logger logger = Logger.getLogger("CREDIT");

    private VisaDao visaDao = new VisaDao();

    private VisaFee filter;
    private final DaoDataModel<VisaFee> feeSource;
    private VisaFee activeItem;

    private static String COMPONENT_ID = "feeTable";
    private String tabName;
    private String parentSectionId;
    private Map<String, Object> params;
    
    public MbVisaFeesSearchBottom() {
        feeSource = new DaoDataModel<VisaFee>() {
            @Override
            protected VisaFee[] loadDaoData(SelectionParams params) {
                if (!searching)
                    return new VisaFee[0];
                try {
                    setFilters();
                    params.setFilters(filters.toArray(new Filter[filters.size()]));
                    return visaDao.getVisaFees(userSessionId, params);
                } catch (Exception e) {
                    setDataSize(0);
                    FacesUtils.addMessageError(e);
                    logger.error("", e);
                }
                return new VisaFee[0];
            }

            @Override
            protected int loadDaoDataSize(SelectionParams params) {
                if (!searching)
                    return 0;
                try {
                    setFilters();
                    params.setFilters(filters.toArray(new Filter[filters.size()]));
                    return visaDao.getVisaFeesCount(userSessionId, params);
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
        filters = new ArrayList<Filter>();
        if (params == null) return; 
        filters.add(new Filter("lang", userLang));
        Long param = (Long)params.get("finMessageId");
        if (param != null) {
        	filters.add(new Filter("id", param));
        }       
    }

    public void search(){
        searching = true;
        clearBean();
    }

    private void clearBean(){
        feeSource.flushCache();
        activeItem = null;
    }

    public void clearFilter(){
        searching = false;
        filter = new VisaFee();
        feeSource.flushCache();
        activeItem = null;
        params = null;
    }

    public ExtendedDataModel getItems(){
        return feeSource;
    }
    public void setFilter(VisaFee filter){
    	this.filter = filter;
    }

    public void setFilter(Map<String, Object> params) {
		this.params = params;
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

    public void loadFee(Long finMessageId) {
    	try {
    		activeItem = null;
    		SelectionParams sp = new SelectionParams(new Filter("id", finMessageId));
			VisaFee[] fees = visaDao.getVisaFees(userSessionId, sp);
			if (fees.length > 0) {
				activeItem = fees[0];
			}
		} catch (Exception e) {
			logger.error("", e);
			FacesUtils.addMessageError(e);
		}
    }

	public VisaFee getActiveItem() {
		return activeItem;
	}

	public void setActiveItem(VisaFee activeItem) {
		this.activeItem = activeItem;
	}
    
}
