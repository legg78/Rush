package ru.bpc.sv2.ui.ps.mastercard.files;


import org.ajax4jsf.model.ExtendedDataModel;
import org.richfaces.model.selection.SimpleSelection;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.MastercardDao;
import ru.bpc.sv2.ps.mastercard.MasterFinMessage;
import ru.bpc.sv2.ui.utils.*;
import org.apache.log4j.Logger;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import java.util.ArrayList;
import java.util.List;

@ViewScoped
@ManagedBean(name = "MbFileFinMessagesBottom")
public class MbFileFinMessagesBottom  extends AbstractBean {
    private static final Logger logger = Logger.getLogger("MCW");

    private MastercardDao mastercardDao = new MastercardDao();

    private MasterFinMessage filter;
    private final DaoDataModel<MasterFinMessage> source;
    private final TableRowSelection<MasterFinMessage> _itemSelection;

    private static String COMPONENT_ID = "fileFinMessageTable";
    private String tabName;
    private String parentSectionId;

    private MasterFinMessage _activeItem;


    public MbFileFinMessagesBottom() {
        source = new DaoDataListModel<MasterFinMessage>(logger) {
            @Override
            protected List<MasterFinMessage> loadDaoListData(SelectionParams params) {
                if (isSearching()) {
                    setFilters();
                    params.setFilters(filters);
                    return mastercardDao.getMasterFileFinMessages(userSessionId, params);
                }
                return new ArrayList<MasterFinMessage>();
            }

            @Override
            protected int loadDaoDataSize(SelectionParams params) {
                if (isSearching()) {
                    setFilters();
                    params.setFilters(filters);
                    return mastercardDao.getMasterFileFinMessagesCount(userSessionId, params);
                }
                return 0;
            }
        };
        _itemSelection = new TableRowSelection<MasterFinMessage>(null, source);
    }

    public DaoDataModel<MasterFinMessage> getOperations() {
        return source;
    }

    public MasterFinMessage getActiveItem() {
        return _activeItem;
    }

    public void setActiveItem(MasterFinMessage activeItem) {
        _activeItem = activeItem;
    }

    public SimpleSelection getItemSelection() {
        setFirstRowActive();
        return _itemSelection.getWrappedSelection();
    }

    public void setItemSelection(SimpleSelection selection) {
        _itemSelection.setWrappedSelection(selection);
        _activeItem = _itemSelection.getSingleSelection();
    }

    public void setFirstRowActive() {
        if (_activeItem == null && source.getRowCount() > 0) {
            source.setRowIndex(0);
            SimpleSelection selection = new SimpleSelection();
            _activeItem = (MasterFinMessage) source.getRowData();
            selection.addKey(_activeItem.getModelId());
            _itemSelection.setWrappedSelection(selection);
        }
    }


    private void setFilters(){
        filters = new ArrayList<Filter>();
        filters.add(new Filter("lang", userLang));
        if (filter.getFileId()!=null)
            filters.add(new Filter("fileId", filter.getFileId().toString()));
    }

    public void search(){
        searching = true;
        clearBean();
    }

    private void clearBean(){
        source.flushCache();
    }

    public void clearFilter(){
        searching = false;
        filter = new MasterFinMessage();
        source.flushCache();
    }

    public ExtendedDataModel getItems(){
        return source;
    }
    public void setFilter(MasterFinMessage filter){
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


    public void view() {

    }

    public void close(){

    }



}
