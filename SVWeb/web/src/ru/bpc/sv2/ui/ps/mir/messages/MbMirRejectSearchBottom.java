package ru.bpc.sv2.ui.ps.mir.messages;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.MirDao;
import ru.bpc.sv2.ps.mir.MirReject;
import ru.bpc.sv2.ui.utils.*;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import java.util.ArrayList;
import java.util.List;

@ViewScoped
@ManagedBean(name = "MbMirRejectSearchBottom")
public class MbMirRejectSearchBottom extends AbstractBean {
    private static final Logger logger = Logger.getLogger("MIR");
    private static final String COMPONENT_ID = "mirRejectTable";
    private String parentSectionId;

    private MirDao mirDao = new MirDao();

    private MirReject filter;
    private String tabName;

    private MirReject activeItem;

    private transient final DaoDataModel<MirReject> dataModel;
    private final TableRowSelection<MirReject> tableRowSelection;

    public MbMirRejectSearchBottom() {
        dataModel = new DaoDataListModel<MirReject>(logger) {
            @Override
            protected List<MirReject> loadDaoListData(SelectionParams params) {
                if (searching) {
                    setFilters();
                    params.setFilters(filters.toArray(new Filter[filters.size()]));
                    return mirDao.getMirRejects(userSessionId, params);
                }
                return new ArrayList<MirReject>();
            }

            @Override
            protected int loadDaoDataSize(SelectionParams params) {
                if (searching) {
                    setFilters();
                    params.setFilters(filters.toArray(new Filter[filters.size()]));
                    return mirDao.getMirRejectsCount(userSessionId, params);
                }
                return 0;
            }
        };
        tableRowSelection = new TableRowSelection<MirReject>(null, dataModel);
    }

    private void setFilters() {
        filters = new ArrayList<Filter>();
        filters.add(new Filter("lang", userLang));

        if (params != null) {
            setFiltersFromMap();
            return;
        }
        if (getFilter().getId() != null) {
            filters.add(new Filter("id", getFilter().getId()));
        }
        if (getFilter().getFileId() != null) {
            filters.add(new Filter("fileId", getFilter().getFileId()));
        }
    }

    private void setFiltersFromMap() {
        filters.add(new Filter("lang", userLang));
        Long param = (Long) params.get("finMessageId");
        if (param != null) {
            filters.add(new Filter("finMessageId", param));
        }
        param = (Long) params.get("rejectId");
        if (param != null) {
            filters.add(new Filter("id", param));
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

    public void clearBeansStates() {

    }

    public void clearFilter() {
        filter = null;
        clearState();
        clearBeansStates();
        searching = false;
    }

    public void setFilter(MirReject filter) {
        this.filter = filter;
    }

    public SimpleSelection getItemSelection() {
        if (activeItem == null && dataModel.getRowCount() > 0) {
            prepareItemSelection();
        }
        return tableRowSelection.getWrappedSelection();
    }

    public void prepareItemSelection() {
        dataModel.setRowIndex(0);
        SimpleSelection selection = new SimpleSelection();
        activeItem = (MirReject) dataModel.getRowData();
        selection.addKey(activeItem.getModelId());
        tableRowSelection.setWrappedSelection(selection);
        if (activeItem != null) {
            setBeansState();
        }
    }

    public void setItemSelection(SimpleSelection selection) {
        tableRowSelection.setWrappedSelection(selection);
        activeItem = tableRowSelection.getSingleSelection();
        if (activeItem != null) {
            setBeansState();
        }
    }

    private void setBeansState() {

    }

    public MirReject getFilter() {
        if (filter == null) {
            filter = new MirReject();
        }
        return filter;
    }

    public DaoDataModel<MirReject> getRejects() {
        return dataModel;
    }

    public MirReject getActiveItem() {
        return activeItem;
    }

    public void loadReject(Long id) {
        try {
            activeItem = null;
            SelectionParams sp = new SelectionParams(new Filter("id", id));
            List<MirReject> rejects = mirDao.getMirRejects(userSessionId, sp);
            if (rejects.size() > 0) {
                activeItem = rejects.get(0);
            }
        } catch (Exception e) {
            logger.error("", e);
            FacesUtils.addMessageError(e);
        }
    }

    public String getComponentId() {
        return parentSectionId + ":" + tabName + ":" + COMPONENT_ID;
    }

    public void setParentSectionId(String parentSectionId) {
        this.parentSectionId = parentSectionId;
    }

    public void setTabName(String tabName) {
        this.tabName = tabName;
    }

    public void view() {

    }

    public void close() {

    }
}
