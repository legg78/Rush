package ru.bpc.sv2.ui.ps.nbc.files;

/**
 * Created by Viktorov on 07.12.2016.
 */

import org.ajax4jsf.model.ExtendedDataModel;
import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.NbcDao;
import ru.bpc.sv2.ps.nbc.NbcFinMessage;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataListModel;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.TableRowSelection;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import java.util.ArrayList;
import java.util.List;

@ViewScoped
@ManagedBean(name = "MbNbcFileFinMessagesBottom")
public class MbNbcFileFinMessagesBottom extends AbstractBean {
    private static final Logger logger = Logger.getLogger("NBC");

    private NbcDao nbcDao = new NbcDao();

    private NbcFinMessage filter;
    private final DaoDataModel<NbcFinMessage> source;
    private final TableRowSelection<NbcFinMessage> _itemSelection;

    private static final String COMPONENT_ID = "fileFinMessageTable";
    private String tabName;
    private String parentSectionId;

    private NbcFinMessage _activeItem;

    public MbNbcFileFinMessagesBottom() {
        source = new DaoDataListModel<NbcFinMessage>(logger) {
            @Override
            protected List<NbcFinMessage> loadDaoListData(SelectionParams params) {
                if (searching) {
                    setFilters();
                    params.setFilters(filters.toArray(new Filter[filters.size()]));
                    return nbcDao.getFinancialMessages(userSessionId, params);
                }
                return new ArrayList<NbcFinMessage>();
            }

            @Override
            protected int loadDaoDataSize(SelectionParams params) {
                if (searching) {
                    setFilters();
                    params.setFilters(filters.toArray(new Filter[filters.size()]));
                    return nbcDao.getFinancialMessagesCount(userSessionId, params);
                }
                return 0;
            }
        };
        _itemSelection = new TableRowSelection<NbcFinMessage>(null, source);
    }

    public DaoDataModel<NbcFinMessage> getOperations() {
        return source;
    }

    public NbcFinMessage getActiveItem() {
        return _activeItem;
    }

    public void setActiveItem(NbcFinMessage activeItem) {
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
            _activeItem = (NbcFinMessage) source.getRowData();
            selection.addKey(_activeItem.getModelId());
            _itemSelection.setWrappedSelection(selection);
        }
    }


    private void setFilters() {
        filters = new ArrayList<Filter>();
        filters.add(new Filter("lang", userLang));
        if (filter.getFileId() != null)
            filters.add(new Filter("fileId", filter.getFileId().toString()));
    }

    public void search() {
        searching = true;
        clearBean();
    }

    private void clearBean() {
        source.flushCache();
    }

    public void clearFilter() {
        searching = false;
        filter = new NbcFinMessage();
        source.flushCache();
    }

    public ExtendedDataModel getItems() {
        return source;
    }

    public void setFilter(NbcFinMessage filter) {
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

    public void close() {

    }
}

