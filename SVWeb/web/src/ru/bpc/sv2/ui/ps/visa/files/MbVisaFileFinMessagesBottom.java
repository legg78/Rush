package ru.bpc.sv2.ui.ps.visa.files;


import org.ajax4jsf.model.ExtendedDataModel;
import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.VisaDao;
import ru.bpc.sv2.ps.visa.VisaFinMessage;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.TableRowSelection;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import java.util.ArrayList;

@ViewScoped
@ManagedBean(name = "MbVisaFileFinMessagesBottom")
public class MbVisaFileFinMessagesBottom extends AbstractBean {

    private static final Logger logger = Logger.getLogger("VIS");

    private VisaDao visaDao = new VisaDao();

    private VisaFinMessage filter;
    private final DaoDataModel<VisaFinMessage> source;
    private final TableRowSelection<VisaFinMessage> _itemSelection;

    private static String COMPONENT_ID = "fileFinMessageTable";
    private String tabName;
    private String parentSectionId;

    private VisaFinMessage _activeItem;


    public MbVisaFileFinMessagesBottom() {
        source = new DaoDataModel<VisaFinMessage>() {
            @Override
            protected VisaFinMessage[] loadDaoData(SelectionParams params) {
                if (!searching)
                    return new VisaFinMessage[0];
                try {
                    setFilters();
                    params.setFilters(filters.toArray(new Filter[filters.size()]));
                    return visaDao.getVisaFileFinMessages(userSessionId, params);
                } catch (Exception e) {
                    setDataSize(0);
                    FacesUtils.addMessageError(e);
                    logger.error("", e);
                }
                return new VisaFinMessage[0];
            }

            @Override
            protected int loadDaoDataSize(SelectionParams params) {
                if (!searching)
                    return 0;
                try {
                    setFilters();
                    params.setFilters(filters.toArray(new Filter[filters.size()]));
                    return visaDao.getVisaFileFinMessagesCount(userSessionId, params);
                } catch (Exception e) {
                    setDataSize(0);
                    FacesUtils.addMessageError(e);
                    logger.error("", e);
                }
                return 0;
            }
        };
        _itemSelection = new TableRowSelection<VisaFinMessage>(null, source);
    }

    public DaoDataModel<VisaFinMessage> getOperations() {
        return source;
    }

    public VisaFinMessage getActiveItem() {
        return _activeItem;
    }

    public void setActiveItem(VisaFinMessage activeItem) {
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
            _activeItem = (VisaFinMessage) source.getRowData();
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
        filter = new VisaFinMessage();
        source.flushCache();
    }

    public ExtendedDataModel getItems(){
        return source;
    }
    public void setFilter(VisaFinMessage filter){
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
