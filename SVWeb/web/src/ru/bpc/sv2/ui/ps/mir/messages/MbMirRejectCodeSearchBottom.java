package ru.bpc.sv2.ui.ps.mir.messages;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.MirDao;
import ru.bpc.sv2.ps.mir.MirRejectCode;
import ru.bpc.sv2.ui.utils.*;


import ru.bpc.sv2.logic.utility.db.DataAccessException;
import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import java.util.ArrayList;
import java.util.List;

@ViewScoped
@ManagedBean(name = "MbMirRejectCodeSearchBottom")
public class MbMirRejectCodeSearchBottom extends AbstractBean {
    private static final Logger logger = Logger.getLogger("MIR");

    private MirDao mirDao = new MirDao();

    private MirRejectCode filter;

    private MirRejectCode activeItem;
    private String tabName;
    private String parentSectionId;
    private static final String COMPONENT_ID = "rejectCodeTable";

    private transient final DaoDataModel<MirRejectCode> dataModel;
    private final TableRowSelection<MirRejectCode> tableRowSelection;

    public MbMirRejectCodeSearchBottom(){
        dataModel = new DaoDataListModel<MirRejectCode>(logger){
            @Override
            protected List<MirRejectCode> loadDaoListData(SelectionParams params) {
                if (isSearching()) {
                    setFilters();
                    params.setFilters(filters.toArray(new Filter[filters.size()]));
                    return mirDao.getMirRejectCodes(userSessionId, params);
                }
                return new ArrayList<MirRejectCode>();
            }

            @Override
            protected int loadDaoDataSize(SelectionParams params) {
                int result = 0;
                if (isSearching()){
                    setFilters();
                    params.setFilters(filters.toArray(new Filter[filters.size()]));
                    try{
                        result = mirDao.getMirRejectCodesCount(userSessionId, params);
                    }catch (DataAccessException e){
                        FacesUtils.addMessageError(e);
                        logger.error("", e);
                    }
                } else {
                    result = 0;
                }
                return result;
            }
        };
        tableRowSelection = new TableRowSelection<MirRejectCode>(null, dataModel);
    }

    public boolean isSearching() {
        return searching && (getFilter().getRejectId() != null ||
                (params != null && params.containsKey("rejectId")));
    }

    private void setFilters() {
        filters = new ArrayList<Filter>();
        filters.add(new Filter("lang",userLang));

        if (params != null) {
            setFiltersFromMap();
            return;
        }
        if (getFilter().getRejectId() != null) {
            filters.add(new Filter("rejectId", getFilter().getRejectId()));
        }
    }

    private void setFiltersFromMap() {
        filters.add(new Filter("lang", userLang));
        Long param = (Long)params.get("rejectId");
        if (param != null) {
            filters.add(new Filter("rejectId", param));
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

    public void clearBeansStates(){

    }

    public void clearFilter() {
        filter = null;
        clearState();
        clearBeansStates();
        searching = false;
    }

    public SimpleSelection getItemSelection() {
        if (activeItem == null && dataModel.getRowCount() > 0){
            prepareItemSelection();
        }
        return tableRowSelection.getWrappedSelection();
    }

    public void prepareItemSelection(){
        dataModel.setRowIndex(0);
        SimpleSelection selection = new SimpleSelection();
        activeItem = (MirRejectCode)dataModel.getRowData();
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

    private void setBeansState(){

    }

    public MirRejectCode getFilter() {
        if (filter == null) {
            filter = new MirRejectCode();
        }
        return filter;
    }

    public DaoDataModel<MirRejectCode> getRejectCodes(){
        return dataModel;
    }

    public MirRejectCode getActiveItem(){
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
