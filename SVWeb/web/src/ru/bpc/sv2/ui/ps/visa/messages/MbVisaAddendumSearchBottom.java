package ru.bpc.sv2.ui.ps.visa.messages;

import org.ajax4jsf.model.ExtendedDataModel;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.VisaDao;
import ru.bpc.sv2.ps.visa.VisaAddendum;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import java.util.ArrayList;

import org.apache.log4j.Logger;

@ViewScoped
@ManagedBean(name = "MbVisaAddendumSearchBottom")
public class MbVisaAddendumSearchBottom  extends AbstractBean {
    private static final Logger logger = Logger.getLogger("OPER_PROCESSING");

    private VisaDao visaDao = new VisaDao();

    private VisaAddendum filter;
    private final DaoDataModel<VisaAddendum> addendumSource;

    private static String COMPONENT_ID = "addendumTable";
    private String tabName;
    private String parentSectionId;
    
    public MbVisaAddendumSearchBottom() {
        addendumSource = new DaoDataModel<VisaAddendum>() {
            @Override
            protected VisaAddendum[] loadDaoData(SelectionParams params) {
                if (!searching)
                    return new VisaAddendum[0];
                try {
                    setFilters();
                    params.setFilters(filters.toArray(new Filter[filters.size()]));
                    return visaDao.getVisaAddendums(userSessionId, params);
                } catch (Exception e) {
                    setDataSize(0);
                    FacesUtils.addMessageError(e);
                    logger.error("", e);
                }
                return new VisaAddendum[0];
            }

            @Override
            protected int loadDaoDataSize(SelectionParams params) {
                if (!searching)
                    return 0;
                try {
                    setFilters();
                    params.setFilters(filters.toArray(new Filter[filters.size()]));
                    return visaDao.getVisaAddendumsCount(userSessionId, params);
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
        	filters.add(new Filter("finMessageId", param));
        }
    }

    public void search(){
        searching = true;
        clearBean();
    }

    private void clearBean(){
        addendumSource.flushCache();
    }

    public void clearFilter(){
        searching = false;
        filter = new VisaAddendum();
        addendumSource.flushCache();
    }

    public ExtendedDataModel getItems(){
        return addendumSource;
    }
    public void setFilter(VisaAddendum filter){
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
