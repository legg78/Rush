package ru.bpc.sv2.ui.ps.visa.messages;


import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.VisaDao;
import ru.bpc.sv2.ps.visa.VisaReturn;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.TableRowSelection;


import ru.bpc.sv2.logic.utility.db.DataAccessException;
import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import java.util.ArrayList;

@ViewScoped
@ManagedBean(name = "MbVisaReturnSearchBottom")
public class MbVisaReturnSearchBottom extends AbstractBean {

    private static final Logger logger = Logger.getLogger("VIS");
    private static String COMPONENT_ID = "visaFileReturnsTable";
    private String parentSectionId;

    private VisaDao visaDao = new VisaDao();

    private VisaReturn filter;
    private String tabName;


    private VisaReturn activeItem;

    private transient final DaoDataModel<VisaReturn> dataModel;
    private final TableRowSelection<VisaReturn> tableRowSelection;

    public MbVisaReturnSearchBottom(){
        dataModel = new DaoDataModel<VisaReturn>(){
            @Override
            protected VisaReturn[] loadDaoData(SelectionParams params) {
                VisaReturn[] result = null;
                if (searching) {
                    setFilters();
                    params.setFilters(filters.toArray(new Filter[filters.size()]));
                    try{
                        result = visaDao.getVisaReturns(userSessionId, params);
                    }catch (DataAccessException e){
                        FacesUtils.addMessageError(e);
                        logger.error("", e);
                    }
                } else {
                    result = new VisaReturn[0];
                }
                return result;
            }

            @Override
            protected int loadDaoDataSize(SelectionParams params) {
                int result = 0;
                if (searching){
                    setFilters();
                    params.setFilters(filters.toArray(new Filter[filters.size()]));
                    try{
                        result = visaDao.getVisaReturnsCount(userSessionId, params);
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
        tableRowSelection = new TableRowSelection<VisaReturn>(null, dataModel);
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
        if(getFilter().getFileId() != null) {
            filters.add(new Filter("fileId", getFilter().getFileId()));
        }
    }

    private void setFiltersFromMap() {
        filters.add(new Filter("lang", userLang));
        Long param = (Long)params.get("finMessageId");
        if (param != null) {
            filters.add(new Filter("finMessageId", param));
        }
        param = (Long)params.get("returnId");
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

    public void clearBeansStates(){

    }

    public void clearFilter() {
        filter = null;
        clearState();
        clearBeansStates();
        searching = false;
    }

    public void setFilter(VisaReturn filter){
        this.filter = filter;
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
        activeItem = (VisaReturn)dataModel.getRowData();
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

    public VisaReturn getFilter() {
        if (filter == null) {
            filter = new VisaReturn();
        }
        return filter;
    }

    public DaoDataModel<VisaReturn> getReturns(){
        return dataModel;
    }

    public VisaReturn getActiveItem(){
        return activeItem;
    }

//    public void loadReject(Long id) {
//        try {
//            activeItem = null;
//            SelectionParams sp = new SelectionParams(new Filter("id", id));
//            VisaReturn[] rejects = visaDao.getVisaReturns(userSessionId, sp);
//            if (rejects.length > 0) {
//                activeItem = rejects[0];
//            }
//        } catch (Exception e) {
//            logger.error("", e);
//            FacesUtils.addMessageError(e);
//        }
//    }

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
