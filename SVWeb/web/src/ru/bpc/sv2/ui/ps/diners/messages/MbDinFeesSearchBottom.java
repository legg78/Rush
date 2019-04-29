package ru.bpc.sv2.ui.ps.diners.messages;

import org.ajax4jsf.model.ExtendedDataModel;
import org.apache.log4j.Logger;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.DinersDao;
import ru.bpc.sv2.ps.diners.DinersFee;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import java.util.ArrayList;
import java.util.Map;

@ViewScoped
@ManagedBean(name = "MbDinFeesSearchBottom")
public class MbDinFeesSearchBottom  extends AbstractBean {
    private static final Logger logger = Logger.getLogger("CREDIT");
    private static String COMPONENT_ID = "feeTable";
    private final DaoDataModel<DinersFee> feeSource;
    private DinersDao dinersDao = new DinersDao();
    private DinersFee filter;
    private DinersFee activeItem;
    private String tabName;
    private String parentSectionId;
    private Map<String, Object> params;

    public MbDinFeesSearchBottom() {
        feeSource = new DaoDataModel<DinersFee>() {
            @Override
            protected DinersFee[] loadDaoData(SelectionParams params) {
                if (!searching)
                    return new DinersFee[0];
                try {
                    setFilters();
                    params.setFilters(filters.toArray(new Filter[filters.size()]));
                    return dinersDao.getDinFees(userSessionId, params);
                } catch (Exception e) {
                    setDataSize(0);
                    FacesUtils.addMessageError(e);
                    logger.error("", e);
                }
                return new DinersFee[0];
            }
            @Override
            protected int loadDaoDataSize(SelectionParams params) {
                if (!searching)
                    return 0;
                try {
                    setFilters();
                    params.setFilters(filters.toArray(new Filter[filters.size()]));
                    return dinersDao.getDinFeesCount(userSessionId, params);
                } catch (Exception e){
                    setDataSize(0);
                    FacesUtils.addMessageError(e);
                    logger.error("", e);
                }
                return 0;
            }
        };
    }

    public void search(){
        searching = true;
        feeSource.flushCache();
        activeItem = null;
    }

    public ExtendedDataModel getItems(){
        return feeSource;
    }

    public void setFilter(DinersFee filter){
        this.filter = filter;
    }
    public void setFilter(Map<String, Object> params) {
        this.params = params;
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
            DinersFee[] fees = dinersDao.getDinFees(userSessionId, sp);
            if (fees.length > 0) {
                activeItem = fees[0];
            }
        } catch (Exception e) {
            logger.error("", e);
            FacesUtils.addMessageError(e);
        }
    }

    public DinersFee getActiveItem() {
        return activeItem;
    }
    public void setActiveItem(DinersFee activeItem) {
        this.activeItem = activeItem;
    }

    @Override
    public void clearFilter(){
        searching = false;
        filter = new DinersFee();
        feeSource.flushCache();
        activeItem = null;
        params = null;
    }

    @Override
    public String getComponentId() {
        return parentSectionId + ":" + tabName + ":" + COMPONENT_ID;
    }

    private void setFilters(){
        filters = new ArrayList<Filter>();
        if (params == null) {
            filters.add(new Filter("lang", userLang));
            Long param = (Long)params.get("finMessageId");
            filters.add(new Filter("id", param));
        }
    }
}
