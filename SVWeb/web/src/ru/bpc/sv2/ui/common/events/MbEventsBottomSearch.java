package ru.bpc.sv2.ui.common.events;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;
import ru.bpc.sv2.common.events.Event;
import ru.bpc.sv2.constants.SectionIdConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.EventsDao;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.TableRowSelection;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import java.util.ArrayList;

/**
 * Created by Gasanov on 22.12.2015.
 */
@ViewScoped
@ManagedBean(name = "MbEventsBottomSearch")
public class MbEventsBottomSearch extends AbstractBean {
    private static final long serialVersionUID = 3597367353047865386L;

    private static final Logger logger = Logger.getLogger("EVENTS");

    private static String COMPONENT_ID = "1070:eventsTypeBottomTable";

    private EventsDao _eventsDao = new EventsDao();

    private Event filter;
    private Event _activeEvent;

    private final DaoDataModel<Event> _eventsSource;

    private final TableRowSelection<Event> _itemSelection;

    private Integer instId;
    private String procedureName;
    private String tabName;
    private String parentSectionId;

    public MbEventsBottomSearch() {
        pageLink = "common|events|events";
        _eventsSource = new DaoDataModel<Event>() {
            private static final long serialVersionUID = 5607939169014333981L;

            @Override
            protected Event[] loadDaoData(SelectionParams params) {
//				log("Data");
                if (!searching) {
                    return new Event[0];
                }
                try {
                    setFilters();
                    params.setFilters(filters.toArray(new Filter[filters.size()]));
                    return _eventsDao.getEvents(userSessionId, params);
                } catch (Exception e) {
                    setDataSize(0);
                    FacesUtils.addMessageError(e);
                    logger.error("", e);
                }
                return new Event[0];
            }

            @Override
            protected int loadDaoDataSize(SelectionParams params) {
//				log("Data size");
                if (!searching) {
                    return 0;
                }
                try {
                    setFilters();
                    params.setFilters(filters.toArray(new Filter[filters.size()]));
                    return _eventsDao.getEventsCount(userSessionId, params);
                } catch (Exception e) {
                    FacesUtils.addMessageError(e);
                    logger.error("", e);
                }
                return 0;
            }
        };

        _itemSelection = new TableRowSelection<Event>(null, _eventsSource);
    }

    public DaoDataModel<Event> getEvents() {
        return _eventsSource;
    }

    public Event getActiveEvent() {
        return _activeEvent;
    }

    public void setActiveEvent(Event activeEvent) {
        _activeEvent = activeEvent;
    }

    public SimpleSelection getItemSelection() {
        if (_activeEvent == null && _eventsSource.getRowCount() > 0) {
            setFirstRowActive();
        } else if (_activeEvent != null && _eventsSource.getRowCount() > 0) {
            SimpleSelection selection = new SimpleSelection();
            selection.addKey(_activeEvent.getModelId());
            _itemSelection.setWrappedSelection(selection);
            _activeEvent = _itemSelection.getSingleSelection();
        }
        return _itemSelection.getWrappedSelection();
    }

    public void setFirstRowActive() {
        _eventsSource.setRowIndex(0);
        SimpleSelection selection = new SimpleSelection();
        _activeEvent = (Event) _eventsSource.getRowData();
        selection.addKey(_activeEvent.getModelId());
        _itemSelection.setWrappedSelection(selection);
    }

    public void setItemSelection(SimpleSelection selection) {
        _itemSelection.setWrappedSelection(selection);
        _activeEvent = _itemSelection.getSingleSelection();
    }

    public void search() {
        clearState();
        searching = true;
    }

    public void clearFilter() {
        filter = null;

        clearState();
        searching = false;
    }

    public Event getFilter() {
        if (filter == null) {
            filter = new Event();
        }
        return filter;
    }

    public void setFilter(Event filter) {
        this.filter = filter;
    }

    private void setFilters() {
        filter = getFilter();
        filters = new ArrayList<Filter>();

        Filter paramFilter;

        paramFilter = new Filter();
        paramFilter.setElement("lang");
        paramFilter.setOp(Filter.Operator.eq);
        paramFilter.setValue(userLang);
        filters.add(paramFilter);

        if (getInstId() != null) {
            paramFilter = new Filter();
            paramFilter.setElement("instId");
            paramFilter.setOp(Filter.Operator.eq);
            paramFilter.setValue(getInstId().toString());
            filters.add(paramFilter);
        }

        if (getProcedureName() != null) {
            paramFilter = new Filter();
            paramFilter.setElement("procedureName");
            paramFilter.setOp(Filter.Operator.eq);
            paramFilter.setValue(getProcedureName());
            filters.add(paramFilter);
        }
    }

    public void clearState() {
        _itemSelection.clearSelection();
        _activeEvent = null;
        _eventsSource.flushCache();
    }

    public String getComponentId() {
        return COMPONENT_ID;
    }

    public Logger getLogger() {
        return logger;
    }

    public String getSectionId() {
        return SectionIdConstants.OPERATION_EVENT_EVENT;
    }

    public Integer getInstId() {
        return instId;
    }

    public void setInstId(Integer instId) {
        this.instId = instId;
    }

    public String getProcedureName() {
        return procedureName;
    }

    public void setProcedureName(String procedureName) {
        this.procedureName = procedureName;
    }

    public void setTabName(String tabName) {
        this.tabName = tabName;
    }

    public void setParentSectionId(String parentSectionId) {
        this.parentSectionId = parentSectionId;
    }
}
