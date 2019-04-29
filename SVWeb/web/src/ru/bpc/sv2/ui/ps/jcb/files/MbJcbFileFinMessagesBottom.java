package ru.bpc.sv2.ui.ps.jcb.files;


import org.ajax4jsf.model.ExtendedDataModel;
import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.JcbDao;
import ru.bpc.sv2.ps.jcb.JcbFinMessage;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.TableRowSelection;

import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import java.util.ArrayList;

@ViewScoped
@ManagedBean (name = "MbJcbFileFinMessagesBottom")
public class MbJcbFileFinMessagesBottom  extends AbstractBean {
    private static final Logger logger = Logger.getLogger("DIN");
    private JcbDao jcbDao = new JcbDao();
    private JcbFinMessage filter;
    private final DaoDataModel<JcbFinMessage> source;
    private final TableRowSelection<JcbFinMessage> _itemSelection;
    private static String COMPONENT_ID = "fileFinMessageTable";
    private String tabName;
    private String parentSectionId;
    private JcbFinMessage _activeItem;

    public MbJcbFileFinMessagesBottom() {
        source = new DaoDataModel<JcbFinMessage>() {
            @Override
            protected JcbFinMessage[] loadDaoData(SelectionParams params) {
                if (!searching)
                    return new JcbFinMessage[0];
                try {
                    setFilters();
                    params.setFilters(filters.toArray(new Filter[filters.size()]));
                    return jcbDao.getJcbFileFinMessages(userSessionId, params);
                } catch (Exception e) {
                    setDataSize(0);
                    FacesUtils.addMessageError(e);
                    logger.error("", e);
                }
                return new JcbFinMessage[0];
            }

            @Override
            protected int loadDaoDataSize(SelectionParams params) {
                if (!searching)
                    return 0;
                try {
                    setFilters();
                    params.setFilters(filters.toArray(new Filter[filters.size()]));
                    return jcbDao.getJcbFileFinMessagesCount(userSessionId, params);
                } catch (Exception e) {
                    setDataSize(0);
                    FacesUtils.addMessageError(e);
                    logger.error("", e);
                }
                return 0;
            }
        };
        _itemSelection = new TableRowSelection<JcbFinMessage>(null, source);
    }

    public DaoDataModel<JcbFinMessage> getOperations() {
        return source;
    }

    public JcbFinMessage getActiveItem() {
        return _activeItem;
    }

    public void setActiveItem(JcbFinMessage activeItem) {
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
            _activeItem = (JcbFinMessage) source.getRowData();
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
        filter = new JcbFinMessage();
        source.flushCache();
    }

    public ExtendedDataModel getItems(){
        return source;
    }
    public void setFilter(JcbFinMessage filter){
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
