package ru.bpc.sv2.ui.application;

import java.util.ArrayList;
import java.util.List;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;

import ru.bpc.sv2.application.ApplicationLinkedObjects;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.ApplicationDao;
import ru.bpc.sv2.ui.utils.*;

@ViewScoped
@ManagedBean (name = "MbApplicationLinkedObjects")
public class MbApplicationLinkedObjects extends AbstractBean {
    private static final Logger logger = Logger.getLogger("APPLICATION");

    private ApplicationDao applicationDao = new ApplicationDao();

    private final DaoDataListModel<ApplicationLinkedObjects> dataModel;
    private final TableRowSelection<ApplicationLinkedObjects> tableRowSelection;

    private ApplicationLinkedObjects filter;
    private ApplicationLinkedObjects activeItem;

    private static String COMPONENT_ID = "ApplicationLinkedObjectsTable";
    private String tabName;
    private String parentSectionId;

    public MbApplicationLinkedObjects(){
        dataModel = new DaoDataListModel<ApplicationLinkedObjects>(logger){
            @Override
            protected List<ApplicationLinkedObjects> loadDaoListData(SelectionParams params) {
                if (isSearching() && getFilter().getApplId() != null) {
                    setFilters();
                    params.setFilters(filters);
                    return applicationDao.getApplicationLinkedObjects(userSessionId, params);
                }
                return new ArrayList<ApplicationLinkedObjects>();
            }

            @Override
            protected int loadDaoDataSize(SelectionParams params) {
                if (isSearching() && getFilter().getApplId() != null) {
                    setFilters();
                    params.setFilters(filters);
                    return applicationDao.getApplicationLinkedObjectsCount(userSessionId, params);
                }
                return 0;
            }
        };
        tableRowSelection = new TableRowSelection<ApplicationLinkedObjects>(null, dataModel);
    }

    public DaoDataListModel<ApplicationLinkedObjects> getDataModel(){
        return dataModel;
    }

    private void setFilters() {
        filters = new ArrayList<Filter>();
        filters.add(Filter.create("lang", curLang));

        if (getFilter().getApplId() != null){
            filters.add(Filter.create("applId", getFilter().getApplId()));
        }
    }

    public void search() {
        clearState();
        searching = true;
    }

    public void clearState() {
        tableRowSelection.clearSelection();
        activeItem = null;
        dataModel.flushCache();
        curLang = userLang;
    }

    @Override
    public void clearFilter() {
        setFilter(null);
        clearState();
        searching = false;
    }

    public void prepareItemSelection(){
        dataModel.setRowIndex(0);
        SimpleSelection selection = new SimpleSelection();
        activeItem = (ApplicationLinkedObjects)dataModel.getRowData();
        selection.addKey(activeItem.getModelId());
        tableRowSelection.setWrappedSelection(selection);
    }

    public SimpleSelection getItemSelection() {
        if (activeItem == null && dataModel.getRowCount() > 0){
            prepareItemSelection();
        }
        return tableRowSelection.getWrappedSelection();
    }
    public void setItemSelection(SimpleSelection selection) {
        tableRowSelection.setWrappedSelection(selection);
        activeItem = tableRowSelection.getSingleSelection();
    }

    public ApplicationLinkedObjects getFilter() {
        if (filter == null) {
            filter = new ApplicationLinkedObjects();
        }
        return filter;
    }
    public void setFilter(ApplicationLinkedObjects filter) {
        this.filter = filter;
    }

    public ApplicationLinkedObjects getActiveItem(){
        return activeItem;
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
