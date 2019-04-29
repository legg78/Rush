package ru.bpc.sv2.ui.ps.mastercard.messages;

import org.ajax4jsf.model.ExtendedDataModel;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.MastercardDao;
import ru.bpc.sv2.ps.mastercard.MasterFinMessageAddendum;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataListModel;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import java.util.ArrayList;
import java.util.List;

import org.apache.log4j.Logger;

@ViewScoped
@ManagedBean(name = "MbMasterFinMessageAddendum")
public class MbMasterFinMessageAddendum  extends AbstractBean {
    private static final Logger logger = Logger.getLogger("CREDIT");

    private MastercardDao mastercardDao = new MastercardDao();

    private MasterFinMessageAddendum filter;
    private final DaoDataModel<MasterFinMessageAddendum> addendumSource;

    private static String COMPONENT_ID = "addendumTable";
    private String tabName;
    private String parentSectionId;

    public MbMasterFinMessageAddendum() {
        addendumSource = new DaoDataListModel<MasterFinMessageAddendum>(logger) {
            @Override
            protected List<MasterFinMessageAddendum> loadDaoListData(SelectionParams params) {
                if (isSearching()) {
                    setFilters();
                    params.setFilters(filters);
                    return mastercardDao.getMasterFinMessageAddendum(userSessionId, params);
                }
                return new ArrayList<MasterFinMessageAddendum>();
            }

            @Override
            protected int loadDaoDataSize(SelectionParams params) {
                if (isSearching()) {
                    setFilters();
                    params.setFilters(filters);
                    return mastercardDao.getMasterFinMessageAddendumCount(userSessionId, params);
                }
                return 0;
            }
        };
    }

    private void setFilters(){
        filters = new ArrayList<Filter>();
        filters.add(new Filter("lang", userLang));
        if (filter.getFinId()!=null)
            filters.add(new Filter("finId", filter.getFinId().toString()));
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
        filter = new MasterFinMessageAddendum();
        addendumSource.flushCache();
    }

    public ExtendedDataModel getItems(){
        return addendumSource;
    }
    public void setFilter(MasterFinMessageAddendum filter){
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
