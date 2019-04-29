package ru.bpc.sv2.ui.ps.amex.files;

import org.ajax4jsf.model.ExtendedDataModel;
import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.AmexDao;
import ru.bpc.sv2.ps.amex.AmexFinMessage;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataListModel;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.TableRowSelection;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import java.util.ArrayList;
import java.util.List;

@ViewScoped
@ManagedBean (name = "MbAmexFileFinMessagesBottom")
public class MbAmexFileFinMessagesBottom extends AbstractBean {
    private static final long serialVersionUID = 1562402854449134601L;
    private static final Logger logger = Logger.getLogger("AMEX");

    private AmexDao amexDao = new AmexDao();

    private AmexFinMessage filter;
    private final DaoDataModel<AmexFinMessage> source;
    private final TableRowSelection<AmexFinMessage> itemSelection;

    private static final String COMPONENT_ID = "fileFinMessageTable";
    private String tabName;
    private String parentSectionId;

    private AmexFinMessage activeItem;

    public MbAmexFileFinMessagesBottom() {
        source = new DaoDataListModel<AmexFinMessage>(logger) {
            @Override
            protected List<AmexFinMessage> loadDaoListData(SelectionParams params) {
                if (searching) {
                    setFilters();
                    params.setFilters(filters);
                    return amexDao.getFinancialMessages(userSessionId, params);
                }
                return new ArrayList<AmexFinMessage>();
            }

            @Override
            protected int loadDaoDataSize(SelectionParams params) {
                if (searching) {
                    setFilters();
                    params.setFilters(filters);
                    return amexDao.getFinancialMessagesCount(userSessionId, params);
                }
                return 0;
            }
        };
        itemSelection = new TableRowSelection<AmexFinMessage>(null, source);
    }

    public DaoDataModel<AmexFinMessage> getOperations() {
        return source;
    }

    public void setFirstRowActive() {
        if (activeItem == null && source.getRowCount() > 0) {
            source.setRowIndex(0);
            SimpleSelection selection = new SimpleSelection();
            activeItem = (AmexFinMessage) source.getRowData();
            selection.addKey(activeItem.getModelId());
            itemSelection.setWrappedSelection(selection);
        }
    }

    public ExtendedDataModel getItems() {
        return source;
    }

    public AmexFinMessage getActiveItem() {
        return activeItem;
    }
    public void setActiveItem(AmexFinMessage activeItem) {
        this.activeItem = activeItem;
    }

    public SimpleSelection getItemSelection() {
        setFirstRowActive();
        return itemSelection.getWrappedSelection();
    }
    public void setItemSelection(SimpleSelection selection) {
        itemSelection.setWrappedSelection(selection);
        activeItem = itemSelection.getSingleSelection();
    }

    public AmexFinMessage getFilter() {
        return filter;
    }
    public void setFilter(AmexFinMessage filter) {
        this.filter = filter;
    }

    private void setFilters() {
        filters = new ArrayList<Filter>();
        filters.add(Filter.create("lang", userLang));
        if (filter.getFileId() != null) {
            filters.add(Filter.create("fileId", filter.getFileId().toString()));
        }
    }

    public void search() {
        searching = true;
        clearBean();
    }

    private void clearBean() {
        source.flushCache();
    }

    public String getTabName() {
        return tabName;
    }
    public void setTabName(String tabName) {
        this.tabName = tabName;
    }

    public String getParentSectionId() {
        return parentSectionId;
    }
    public void setParentSectionId(String parentSectionId) {
        this.parentSectionId = parentSectionId;
    }

    public void view() {}
    public void close() {}

    @Override
    public void clearFilter() {
        searching = false;
        filter = new AmexFinMessage();
        source.flushCache();
    }
    @Override
    public String getComponentId() {
        return parentSectionId + ":" + tabName + ":" + COMPONENT_ID;
    }
}
