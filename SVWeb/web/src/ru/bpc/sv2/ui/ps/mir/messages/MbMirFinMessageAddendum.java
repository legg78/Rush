package ru.bpc.sv2.ui.ps.mir.messages;

import org.ajax4jsf.model.ExtendedDataModel;
import org.apache.log4j.Logger;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.MirDao;
import ru.bpc.sv2.ps.mir.MirFinMessageAddendum;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataListModel;
import ru.bpc.sv2.ui.utils.DaoDataModel;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import java.util.ArrayList;
import java.util.List;

@ViewScoped
@ManagedBean(name = "MbMirFinMessageAddendum")
public class MbMirFinMessageAddendum extends AbstractBean {
    private static final Logger logger = Logger.getLogger("MIR");

    private MirDao mirDao = new MirDao();

    private MirFinMessageAddendum filter;
    private final DaoDataModel<MirFinMessageAddendum> addendumSource;

    private static final String COMPONENT_ID = "addendumTable";
    private String tabName;
    private String parentSectionId;

    public MbMirFinMessageAddendum() {
        addendumSource = new DaoDataListModel<MirFinMessageAddendum>(logger) {
            @Override
            protected List<MirFinMessageAddendum> loadDaoListData(SelectionParams params) {
                if (searching) {
                    setFilters();
                    params.setFilters(filters.toArray(new Filter[filters.size()]));
                    return mirDao.getMirFinMessageAddendum(userSessionId, params);
                }
                return new ArrayList<MirFinMessageAddendum>();
            }

            @Override
            protected int loadDaoDataSize(SelectionParams params) {
                if (searching) {
                    setFilters();
                    params.setFilters(filters.toArray(new Filter[filters.size()]));
                    return mirDao.getMirFinMessageAddendumCount(userSessionId, params);
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

    public void clearFilter() {
        searching = false;
        filter = new MirFinMessageAddendum();
        addendumSource.flushCache();
    }

    public ExtendedDataModel getItems() {
        return addendumSource;
    }

    public void setFilter(MirFinMessageAddendum filter) {
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
