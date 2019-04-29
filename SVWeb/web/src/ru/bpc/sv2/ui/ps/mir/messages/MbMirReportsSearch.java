package ru.bpc.sv2.ui.ps.mir.messages;

import org.apache.commons.lang3.StringUtils;
import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;
import ru.bpc.sv2.constants.DatePatterns;
import ru.bpc.sv2.constants.DictNames;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.MirDao;
import ru.bpc.sv2.ps.mir.MirReport;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataListModel;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.TableRowSelection;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.model.SelectItem;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.List;

@ViewScoped
@ManagedBean (name = "MbMirReportsSearch")
public class MbMirReportsSearch extends AbstractBean {
    private static final long serialVersionUID = 9180917082872879256L;
    private static Logger logger = Logger.getLogger("MIR");

    private static String DETAILS_TAB = "detailsTab";

    private MirDao mirDao = new MirDao();

    private MirReport filter;
    private MirReport activeItem;

    private String tabName;

    private final DaoDataModel<MirReport> messageSource;
    private final TableRowSelection<MirReport> itemSelection;

    public MbMirReportsSearch() {
        pageLink = "mir|reports";
        messageSource = new DaoDataListModel<MirReport>(logger) {
            private static final long serialVersionUID = 6886825197574225937L;

            @Override
            protected List<MirReport> loadDaoListData(SelectionParams params) {
                if (searching) {
                    setFilters();
                    params.setFilters(filters);
                    return mirDao.getMirReports(userSessionId, params);
                }
                return new ArrayList<MirReport>();
            }

            @Override
            protected int loadDaoDataSize(SelectionParams params) {
                if (searching) {
                    setFilters();
                    params.setFilters(filters);
                    return mirDao.getMirReportsCount(userSessionId, params);
                }
                return 0;
            }
        };
        itemSelection = new TableRowSelection<MirReport>(null, messageSource);
        tabName = DETAILS_TAB;
    }

    public DaoDataModel<MirReport> getItems() {
        return messageSource;
    }

    private void setFilters() {
        filters = new ArrayList<Filter>();
        filters.add(Filter.create("lang", userLang));
        if (getFilter().getId() != null) {
            filters.add(Filter.create("id", getFilter().getId()));
        }
        if (getFilter().getSessionId() != null) {
            filters.add(Filter.create("sessionId", getFilter().getSessionId()));
        }
        if (StringUtils.isNotBlank(getFilter().getFileName())) {
            filters.add(Filter.create("fileName", Filter.mask(getFilter().getFileName())));
        }
        if (StringUtils.isNotBlank(getFilter().getRrn())) {
            filters.add(Filter.create("rrn", Filter.mask(getFilter().getRrn(), true)));
        }
        if (getFilter().getDateFrom() != null) {
            SimpleDateFormat df = new SimpleDateFormat(DatePatterns.DATE_PATTERN);
            filters.add(Filter.create("dateFrom", df.format(getFilter().getDateFrom())));
        }
        if (getFilter().getDateTo() != null) {
            SimpleDateFormat df = new SimpleDateFormat(DatePatterns.DATE_PATTERN);
            filters.add(Filter.create("dateFrom", df.format(getFilter().getDateTo())));
        }
        if (StringUtils.isNotBlank(getFilter().getReportType())) {
            filters.add(Filter.create("reportType", getFilter().getReportType().replaceAll(DictNames.MIR_TRANSACTION_REPORT_TYPES, "")));
        }
    }

    public SimpleSelection getItemSelection() {
        if (activeItem == null && messageSource.getRowCount() > 0) {
            setFirstRowActive();
        } else if (activeItem != null && messageSource.getRowCount() > 0) {
            SimpleSelection selection = new SimpleSelection();
            selection.addKey(activeItem.getModelId());
            itemSelection.setWrappedSelection(selection);
            activeItem = itemSelection.getSingleSelection();
        }
        return itemSelection.getWrappedSelection();
    }

    public void setItemSelection(SimpleSelection selection) {
        itemSelection.setWrappedSelection(selection);
        activeItem = itemSelection.getSingleSelection();
    }

    private void setFirstRowActive() {
        messageSource.setRowIndex(0);
        SimpleSelection selection = new SimpleSelection();
        activeItem = (MirReport) messageSource.getRowData();
        selection.addKey(activeItem.getModelId());
        itemSelection.setWrappedSelection(selection);
    }

    public MirReport getFilter() {
        if (filter == null) {
            filter = new MirReport();
        }
        return filter;
    }
    public void setFilter(MirReport filter) {
        this.filter = filter;
    }

    public void search() {
        clearBean();
        setSearching(true);
    }

    public MirReport getActiveItem() {
        return activeItem;
    }
    public void setActiveItem(MirReport activeItem) {
        this.activeItem = activeItem;
    }

    private void clearBean() {
        messageSource.flushCache();
        itemSelection.clearSelection();
        activeItem = null;
    }

    @Override
    public void clearFilter() {
        filter = null;
        clearBean();
        setSearching(false);
    }

    public String getTabName() {
        if (tabName == null) {
            setTabName(DETAILS_TAB);
        }
        return tabName;
    }
    public void setTabName(String tabName) {
        this.tabName = tabName;
        loadTab(this.tabName);
    }

    private void loadTab(String tabName) {
        if (StringUtils.isNotBlank(tabName) && activeItem != null) {
            /**
             * TODO: implement data loading of tabs except 'Details'
             */
        }
    }

    public List<SelectItem> getReportTypes() {
       return getDictUtils().getArticles(DictNames.MIR_TRANSACTION_REPORT_TYPES);
    }
}
