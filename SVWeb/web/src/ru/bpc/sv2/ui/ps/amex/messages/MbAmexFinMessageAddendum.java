package ru.bpc.sv2.ui.ps.mir.messages;

import org.ajax4jsf.model.ExtendedDataModel;
import org.apache.log4j.Logger;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.AmexDao;
import ru.bpc.sv2.ps.amex.AmexFinMessageAddendum;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataListModel;
import ru.bpc.sv2.ui.utils.DaoDataModel;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import java.util.ArrayList;
import java.util.List;

@ViewScoped
@ManagedBean(name = "MbAmexFinMessageAddendum")
public class MbAmexFinMessageAddendum extends AbstractBean {
    private static final Logger logger = Logger.getLogger("AMEX");

    private AmexDao amexDao = new AmexDao();

    private AmexFinMessageAddendum filter;
    private final DaoDataModel<AmexFinMessageAddendum> addendumSource;

    private static final String COMPONENT_ID = "addendumTable";
    private String tabName;
    private String parentSectionId;

    public MbAmexFinMessageAddendum() {
        addendumSource = new DaoDataListModel<AmexFinMessageAddendum>(logger) {
            @Override
            protected List<AmexFinMessageAddendum> loadDaoListData(SelectionParams params) {
                if (searching) {
                    setFilters();
                    params.setFilters(filters);
                    return amexDao.getFinMessageAddendum(userSessionId, params);
                }
                return new ArrayList<AmexFinMessageAddendum>();
            }

            @Override
            protected int loadDaoDataSize(SelectionParams params) {
                if (searching) {
                    setFilters();
                    params.setFilters(filters);
                    return amexDao.getFinMessageAddendumCount(userSessionId, params);
                }
                return 0;
            }
        };
    }

    private void setFilters() {
        filters = new ArrayList<Filter>();
        filters.add(new Filter("lang", userLang));
        if (filter.getFinId() != null)
            filters.add(new Filter("finId", filter.getFinId().toString()));
    }

    public void search() {
        searching = true;
        clearBean();
    }

    private void clearBean() {
        addendumSource.flushCache();
    }

    public ExtendedDataModel getItems() {
        return addendumSource;
    }

    public void setFilter(AmexFinMessageAddendum filter) {
        this.filter = filter;
    }

    public void setTabName(String tabName) {
        this.tabName = tabName;
    }

    public void setParentSectionId(String parentSectionId) {
        this.parentSectionId = parentSectionId;
    }

    @Override
    public void clearFilter() {
        searching = false;
        filter = new AmexFinMessageAddendum();
        addendumSource.flushCache();
    }
    @Override
    public String getComponentId() {
        return parentSectionId + ":" + tabName + ":" + COMPONENT_ID;
    }
}
