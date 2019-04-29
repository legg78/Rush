package ru.bpc.sv2.ui.process.monitoring;

import org.apache.commons.lang3.StringUtils;
import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;
import ru.bpc.sv2.constants.DatePatterns;
import ru.bpc.sv2.constants.schedule.ProcessConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.invocation.SortElement;
import ru.bpc.sv2.logic.ProcessDao;
import ru.bpc.sv2.process.ProcessSchedule;
import ru.bpc.sv2.process.ProcessSession;
import ru.bpc.sv2.ui.utils.*;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.event.ValueChangeEvent;
import java.text.SimpleDateFormat;
import java.util.*;

@ViewScoped
@ManagedBean (name = "MbProcessSchedule")
public class MbProcessSchedule extends AbstractBean {
    private static final Logger logger = Logger.getLogger("PROCESSES");
    private static Logger loggerDB = Logger.getLogger("PROCESSES_DB");
    private static final String LOGS_TAB = "logsTab";

    private ProcessSchedule activeItem;
    private ProcessSchedule filter;
    private final DaoDataModel<ProcessSchedule> source;
    private final TableRowSelection<ProcessSchedule> selection;

    private ProcessSession node;
    private String tabName;

    private ProcessDao processDao = new ProcessDao();

    public MbProcessSchedule() {
        tabName = "logsTab";
        pageLink = "processes|schedule";
        source = new DaoDataListModel<ProcessSchedule>(logger) {
            @Override
            protected List<ProcessSchedule> loadDaoListData(SelectionParams params) {
                if (isSearching()) {
                    setFilters();
                    params.setFilters(filters);
                    return processDao.getScheduleList(userSessionId, params);
                }
                return new ArrayList<ProcessSchedule>();
            }

            @Override
            protected int loadDaoDataSize(SelectionParams params) {
                if (isSearching()) {
                    setFilters();
                    params.setFilters(filters);
                    return processDao.getScheduleListCount(userSessionId, params);
                }
                return 0;
            }
        };
        selection = new TableRowSelection<ProcessSchedule>(null, source);
        setDefaultValues();
    }

    public DaoDataModel<ProcessSchedule> getItems() {
        return source;
    }
    public ProcessSchedule getActiveItem() {
        return activeItem;
    }

    public SimpleSelection getSelection() {
        if (activeItem == null && source.getRowCount() > 0) {
            setFirstRowActive();
        } else if (activeItem != null && source.getRowCount() > 0) {
            SimpleSelection newSelection = new SimpleSelection();
            newSelection.addKey(activeItem.getModelId());
            selection.setWrappedSelection(newSelection);
            activeItem = selection.getSingleSelection();
        }
        return selection.getWrappedSelection();
    }
    public void setSelection(SimpleSelection selection) {
        this.selection.setWrappedSelection(selection);
        activeItem = this.selection.getSingleSelection();
        if (activeItem != null) {
            loadTab(getTabName());
        }
    }

    private void setFirstRowActive() {
        if (source != null && source.getDataSize() > 0) {
            source.setRowIndex(0);
            SimpleSelection newSelection = new SimpleSelection();
            activeItem = (ProcessSchedule) source.getRowData();
            newSelection.addKey(activeItem.getModelId());
            selection.setWrappedSelection(newSelection);
            if (activeItem != null) {
                loadTab(getTabName());
            }
        }
    }

    public void setFilters() {
        filters = new ArrayList<Filter>();
        filters.add(Filter.create("lang", userLang));

        if (getFilter().getPlannedTime() != null) {
            filters.add(Filter.create("date", getFilter().getPlannedTime()));
        }
    }

    public ProcessSchedule getFilter() {
        if (filter == null) {
            filter = new ProcessSchedule();
        }
        return filter;
    }
    public void setFilter(ProcessSchedule filter) {
        this.filter = filter;
    }

    public void search() {
        clearState();
        searching = true;
    }

    private void clearState() {
        clearFilter();
        if (selection != null) {
            selection.clearSelection();
        }
        activeItem = null;
        source.flushCache();
    }

    public String getTabName() {
        if (tabName == null) {
            tabName = LOGS_TAB;
        }
        return tabName;
    }
    public void setTabName(String tabName) {
        if (tabName != null) {
            this.tabName = tabName;
            loadTab(tabName);
        }
    }

    private void loadTab(String tabName) {
        if (tabName != null && activeItem != null) {
            if (LOGS_TAB.equalsIgnoreCase(tabName)) {
                loadProcessSession();
            }
        }
    }

    private void loadProcessSession() {
        if (activeItem != null && activeItem.getId() != null) {
            try {
                List<Filter> filters = new ArrayList<Filter>(5);

                if (activeItem.getPlannedTime() != null) {
                    SimpleDateFormat df = new SimpleDateFormat(DatePatterns.FULL_DATE_PATTERN);
                    Calendar calendar = Calendar.getInstance();
                    calendar.setTime(activeItem.getPlannedTime());
                    calendar.add(Calendar.MINUTE, 1);
                    filters.add(Filter.create("startTime", df.format(activeItem.getPlannedTime())));
                    filters.add(Filter.create("endTime", df.format(calendar.getTime())));
                }
                if (activeItem.getInstId() != null) {
                    filters.add(Filter.create("instId", activeItem.getInstId()));
                }
                filters.add(Filter.create("container", activeItem.getId()));
                filters.add(Filter.create("lang", curLang));

                List<SortElement> sorters = new ArrayList<SortElement>(1);
                sorters.add(new SortElement("sessionId", SortElement.Direction.DESC));

                SelectionParams params = new SelectionParams(filters, sorters);
                ProcessSession[] sessions = processDao.getProcessSessions(userSessionId, params);
                if (sessions != null && sessions.length > 0) {
                    setNode(sessions[0]);
                } else {
                    setNode(new ProcessSession());
                }
            } catch (Exception e) {
                FacesUtils.addMessageError(e);
                logger.error("", e);
            }
        }
    }

    public ProcessSession getNode() {
        if (node == null) {
            node = new ProcessSession();
        }
        return node;
    }
    public void setNode(ProcessSession node) {
        this.node = node;
    }

    public void changeLanguage(ValueChangeEvent event) {
        try {
            curLang = (String) event.getNewValue();
            List<Filter> filters = new ArrayList<Filter>(2);
            filters.add(Filter.create("id", getNode().getSessionId()));
            filters.add(Filter.create("lang", curLang));
            SelectionParams params = new SelectionParams(filters);

            ProcessSession[] items = processDao.getProcessSessions(userSessionId, params);
            if (items != null && items.length > 0) {
                setNode(items[0]);
            }
        } catch (Exception e) {
            FacesUtils.addMessageError(e);
            logger.error("", e);
        }
    }

    @Override
    public void clearFilter() {
        searching = false;
        setDefaultValues();
    }

    public String getStyleClass(String status) {
        if (StringUtils.isNotEmpty(status)) {
            switch (status) {
                case ProcessConstants.PROCESS_IN_PROGRESS: return "status_continue";
                case ProcessConstants.PROCESS_FINISHED: return "status_success";
                case ProcessConstants.PROCESS_FAILED: return "status_failed";
                case ProcessConstants.PROCESS_FINISHED_WITH_ERRORS: return "status_failed";
                case ProcessConstants.PROCESS_THREAD_INTERRUPT: return "status_failed";
                case ProcessConstants.PROCESS_LOCKED: return "status_locked";
            }
        }
        return "";
    }

    private void setDefaultValues() {
        Calendar today = Calendar.getInstance();
        today.set(Calendar.HOUR, 0);
        today.set(Calendar.MINUTE, 0);
        today.set(Calendar.SECOND, 0);
        getFilter().setPlannedTime(today.getTime());
    }
}

