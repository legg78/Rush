package ru.bpc.sv2.ui.orgstruct;

import org.apache.commons.lang3.StringUtils;
import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;
import ru.bpc.sv2.constants.DictNames;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.OrgStructDao;
import ru.bpc.sv2.orgstruct.ForbiddenAction;
import ru.bpc.sv2.ui.utils.*;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.model.SelectItem;
import java.util.ArrayList;
import java.util.List;

@ViewScoped
@ManagedBean (name = "MbOrgStructActions")
public class MbOrgStructActions extends AbstractBean {
    private static final Logger logger = Logger.getLogger("ORG_STRUCTURE");

    private ForbiddenAction filter;
    private ForbiddenAction activeAction;
    private ForbiddenAction editAction;

    private String tabName;
    private final DaoDataModel<ForbiddenAction> source;
    private final TableRowSelection<ForbiddenAction> itemSelection;
    
    private OrgStructDao orgStructDao = new OrgStructDao();

    public MbOrgStructActions() {
        pageLink = "orgStruct|actions";
        tabName = "detailsTab";

        source = new DaoDataListModel<ForbiddenAction>(logger) {
            private static final long serialVersionUID = 1L;

            @Override
            protected List<ForbiddenAction> loadDaoListData(SelectionParams params) {
                if (searching) {
                    setFilters();
                    params.setFilters(filters);
                    return orgStructDao.getForbiddenActions(userSessionId, params);
                }
                return new ArrayList<ForbiddenAction>();
            }

            @Override
            protected int loadDaoDataSize(SelectionParams params) {
                if (searching) {
                    setFilters();
                    params.setFilters(filters);
                    return orgStructDao.getForbiddenActionsCount(userSessionId, params);
                }
                return 0;
            }
        };

        itemSelection = new TableRowSelection<ForbiddenAction>( null, source);
    }

    public DaoDataModel<ForbiddenAction> getActions() {
        return source;
    }

    public ForbiddenAction getActiveAction() {
        return activeAction;
    }
    public void setActiveAction(ForbiddenAction activeAction) {
        this.activeAction = activeAction;
    }

    public ForbiddenAction getEditAction() {
        if (editAction == null) {
            editAction = new ForbiddenAction();
        }
        return editAction;
    }
    public void setEditAction(ForbiddenAction editAction) {
        this.editAction = editAction;
    }

    public SimpleSelection getItemSelection() {
        if (activeAction == null && source.getRowCount() > 0) {
            setFirstRowActive();
        }
        return itemSelection.getWrappedSelection();
    }
    public void setItemSelection(SimpleSelection selection) {
        itemSelection.setWrappedSelection( selection );
        activeAction = itemSelection.getSingleSelection();
    }

    public ForbiddenAction getFilter() {
        if (filter == null) {
            filter = new ForbiddenAction();
        }
        return filter;
    }
    public void setFilter(ForbiddenAction filter) {
        this.filter = filter;
    }

    public String getTabName() {
        return tabName;
    }
    public void setTabName(String tabName) {
        this.tabName = tabName;
        loadTab(tabName);
    }

    public void setFirstRowActive() {
        source.setRowIndex(0);
        SimpleSelection selection = new SimpleSelection();
        activeAction = (ForbiddenAction) source.getRowData();
        selection.addKey(activeAction.getModelId());
        itemSelection.setWrappedSelection(selection);
    }

    private void loadTab(String tab) {
        if (tab == null || activeAction == null) {
            return;
        }
        if (tab.equalsIgnoreCase("detailsTab")) {
            /* nothing to do */
        }
    }

    private void clearBean() {
        source.flushCache();
        itemSelection.clearSelection();
        activeAction = null;
        editAction = null;
        curMode = VIEW_MODE;
    }

    private void setFilters() {
        filters = new ArrayList<Filter>();
        filters.add(Filter.create("lang", userLang));

        if (StringUtils.isNotBlank(getFilter().getInstStatus())) {
            filters.add(Filter.create("instStatus", getFilter().getInstStatus()));
        }
        if (StringUtils.isNotBlank(getFilter().getDataAction())) {
            filters.add(Filter.create("dataAction", getFilter().getDataAction()));
        }
    }

    public void search() {
        clearBean();
        searching = true;
    }

    @Override
    public void clearFilter() {
        clearBean();
        filter = null;
        searching = false;
    }

    public void add() {
        editAction = new ForbiddenAction();
        editAction.setLang(curLang);
        curMode = NEW_MODE;
    }
    public void remove() {
        curMode = REMOVE_MODE;
    }

    public void save() {
        try {
            activeAction = orgStructDao.addForbiddenAction(userSessionId, editAction);
            itemSelection.addNewObjectToList(activeAction);
            editAction = null;
        } catch (Exception e) {
            FacesUtils.addMessageError(e);
            logger.error("",e);
        }
        curMode = VIEW_MODE;
    }

    public void delete() {
        try {
            orgStructDao.removeForbiddenAction(userSessionId, activeAction);
            itemSelection.removeObjectFromList(activeAction);
            activeAction = null;
        } catch (Exception e) {
            FacesUtils.addMessageError(e);
            logger.error("",e);
        }
        curMode = VIEW_MODE;
    }

    public void cancel() {
        curMode = VIEW_MODE;
    }

    public List<SelectItem> getInstStatuses() {
        return getDictUtils().getArticles(DictNames.INSTITUTE_STATUSES);
    }

    public List<SelectItem> getDataActions() {
        return getDictUtils().getArticles(DictNames.DATA_ACTIONS);
    }
}
