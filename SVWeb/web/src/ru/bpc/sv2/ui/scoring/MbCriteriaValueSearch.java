package ru.bpc.sv2.ui.scoring;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.ScoringDao;
import ru.bpc.sv2.scoring.ScoringValue;
import ru.bpc.sv2.ui.utils.*;
import ru.bpc.sv2.utils.UserException;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import java.util.ArrayList;
import java.util.List;

@ViewScoped
@ManagedBean (name = "MbCriteriaValueSearch")
public class MbCriteriaValueSearch extends AbstractBean {
    private static final long serialVersionUID = 1562402854449134601L;
    private static final Logger logger = Logger.getLogger("SCORING");

    private final DaoDataModel<ScoringValue> source;
    private final TableRowSelection<ScoringValue> selection;

    private ScoringValue filter;
    private ScoringValue activeItem;

    private ScoringDao scoringDao = new ScoringDao();

    public MbCriteriaValueSearch() {
        source = new DaoDataListModel<ScoringValue>(logger) {
            @Override
            protected List<ScoringValue> loadDaoListData(SelectionParams params) {
                if (searching) {
                    setFilters();
                    params.setFilters(filters);
                    return scoringDao.getValues(userSessionId, params);
                }
                return new ArrayList<ScoringValue>();
            }

            @Override
            protected int loadDaoDataSize(SelectionParams params) {
                if (searching) {
                    setFilters();
                    params.setFilters(filters);
                    return scoringDao.getValuesCount(userSessionId, params);
                }
                return 0;
            }
        };
        selection = new TableRowSelection<ScoringValue>(null, source);
        curMode = VIEW_MODE;
    }

    private void setFilters() {
        filters = new ArrayList<Filter>();
        filters.add(Filter.create("lang", userLang));

        if (getFilter().getId() != null) {
            filters.add(Filter.create("id", getFilter().getId()));
        }
        if (getFilter().getCriteriaId() != null) {
            filters.add(Filter.create("criteriaId", getFilter().getCriteriaId()));
        }
        if (getFilter().getName() != null && getFilter().getName().trim().length() > 0) {
            filters.add(Filter.create("name", Filter.Operator.like, Filter.mask(getFilter().getName())));
        }
    }

    public DaoDataModel<ScoringValue> getItems() {
        return source;
    }
    public ScoringValue getActiveItem() {
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
            loadValues();
        }
    }
    private void setFirstRowActive() {
        source.setRowIndex(0);
        SimpleSelection newSelection = new SimpleSelection();
        activeItem = (ScoringValue) source.getRowData();
        newSelection.addKey(activeItem.getModelId());
        selection.setWrappedSelection(newSelection);
        if (activeItem != null) {
            loadValues();
        }
    }

    public ScoringValue getFilter() {
        if (filter == null) {
            filter = new ScoringValue();
        }
        return filter;
    }
    public void setFilter(ScoringValue filter) {
        this.filter = filter;
    }

    private void loadValues() {
        /* TODO */
    }

    @Override
    public void clearFilter() {
        filter = null;
        setSearching(false);
        clearBean();
    }
    private void clearBean() {
        source.flushCache();
        selection.clearSelection();
        activeItem = null;
    }
    public void search() {
        clearBean();
        setSearching(true);
    }

    public void add() {
        curMode = NEW_MODE;
        activeItem = new ScoringValue();
        activeItem.setLang(curLang);
        activeItem.setCriteriaId(getFilter().getCriteriaId());
    }
    public void edit() {
        curMode = EDIT_MODE;
    }
    public void remove() {
        curMode = REMOVE_MODE;
    }

    public void save() {
        try {
            switch (curMode) {
                case NEW_MODE:
                    activeItem = scoringDao.addCriteriaValue(userSessionId, activeItem);
                    break;
                case EDIT_MODE:
                    activeItem = scoringDao.modifyCriteriaValue(userSessionId, activeItem);
                    break;
                case REMOVE_MODE:
                    scoringDao.removeCriteriaValue(userSessionId, activeItem);
                    break;
                default:
                    throw new UserException("Unknown action");
            }
            search();
            curMode = VIEW_MODE;
        } catch (Exception e) {
            FacesUtils.addMessageError(e);
            logger.error("", e);
        }
    }
    public void cancel() {}
}
