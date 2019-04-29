package ru.bpc.sv2.ui.ps.amex.files;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.AmexDao;
import ru.bpc.sv2.ps.amex.AmexReject;
import ru.bpc.sv2.ui.utils.*;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import java.util.ArrayList;
import java.util.List;

@ViewScoped
@ManagedBean (name = "MbAmexRejectSearchBottom")
public class MbAmexRejectSearchBottom extends AbstractBean {
    private static final long serialVersionUID = 1562402854449134601L;
    private static final Logger logger = Logger.getLogger("AMEX");
    private static final String COMPONENT_ID = "mirRejectTable";
    private String parentSectionId;

    private AmexDao amexDao = new AmexDao();

    private AmexReject filter;
    private String tabName;

    private AmexReject activeItem;

    private transient final DaoDataModel<AmexReject> dataModel;
    private final TableRowSelection<AmexReject> tableRowSelection;

    public MbAmexRejectSearchBottom() {
        dataModel = new DaoDataListModel<AmexReject>(logger) {
            @Override
            protected List<AmexReject> loadDaoListData(SelectionParams params) {
                if (searching) {
                    setFilters();
                    params.setFilters(filters);
                    return amexDao.getRejects(userSessionId, params);
                }
                return new ArrayList<AmexReject>();
            }

            @Override
            protected int loadDaoDataSize(SelectionParams params) {
                if (searching) {
                    setFilters();
                    params.setFilters(filters);
                    return amexDao.getRejectsCount(userSessionId, params);
                }
                return 0;
            }
        };
        tableRowSelection = new TableRowSelection<AmexReject>(null, dataModel);
    }

    private void setFilters() {
        filters = new ArrayList<Filter>();
        filters.add(Filter.create("lang", userLang));

        if (params != null) {
            if (params.get("finMessageId") != null) {
                filters.add(Filter.create("finMessageId", (Long)params.get("finMessageId")));
            }
            if (params.get("rejectId") != null) {
                filters.add(Filter.create("id", (Long)params.get("rejectId")));
            }
            return;
        }
        if (getFilter().getId() != null) {
            filters.add(Filter.create("id", getFilter().getId()));
        }
        if (getFilter().getFileId() != null) {
            filters.add(Filter.create("fileId", getFilter().getFileId()));
        }
    }

    public void search() {
        clearState();
        clearBeansStates();
        searching = true;
    }

    public void clearState() {
        tableRowSelection.clearSelection();
        activeItem = null;
        dataModel.flushCache();
        curLang = userLang;
    }

    public void prepareItemSelection() {
        dataModel.setRowIndex(0);
        SimpleSelection selection = new SimpleSelection();
        activeItem = (AmexReject) dataModel.getRowData();
        selection.addKey(activeItem.getModelId());
        tableRowSelection.setWrappedSelection(selection);
    }

    public void setFilter(AmexReject filter) {
        this.filter = filter;
    }
    public AmexReject getFilter() {
        if (filter == null) {
            filter = new AmexReject();
        }
        return filter;
    }

    public SimpleSelection getItemSelection() {
        if (activeItem == null && dataModel.getRowCount() > 0) {
            prepareItemSelection();
        }
        return tableRowSelection.getWrappedSelection();
    }
    public void setItemSelection(SimpleSelection selection) {
        tableRowSelection.setWrappedSelection(selection);
        activeItem = tableRowSelection.getSingleSelection();
    }

    public DaoDataModel<AmexReject> getRejects() {
        return dataModel;
    }

    public AmexReject getActiveItem() {
        return activeItem;
    }

    public void loadReject(Long id) {
        try {
            activeItem = null;
            List<AmexReject> rejects = amexDao.getRejects(userSessionId, new SelectionParams(Filter.create("id", id)));
            if (rejects.size() > 0) {
                activeItem = rejects.get(0);
            }
        } catch (Exception e) {
            logger.error("", e);
            FacesUtils.addMessageError(e);
        }
    }

    public void setParentSectionId(String parentSectionId) {
        this.parentSectionId = parentSectionId;
    }

    public void setTabName(String tabName) {
        this.tabName = tabName;
    }

    public void view() {}

    public void close() {}

    public void clearBeansStates() {}

    @Override
    public void clearFilter() {
        filter = null;
        clearState();
        clearBeansStates();
        searching = false;
    }
    @Override
    public String getComponentId() {
        return parentSectionId + ":" + tabName + ":" + COMPONENT_ID;
    }

}
