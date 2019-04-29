package ru.bpc.sv2.ui.scoring;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.ScoringDao;
import ru.bpc.sv2.scoring.ScoringCriteria;
import ru.bpc.sv2.ui.utils.*;
import ru.bpc.sv2.utils.UserException;
import util.auxil.ManagedBeanWrapper;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@ViewScoped
@ManagedBean (name = "MbScoringCriteriaSearch")
public class MbScoringCriteriaSearch extends AbstractBean {
    private static final long serialVersionUID = 1562402854449134601L;
    private static final Logger logger = Logger.getLogger("SCORING");

    private final DaoDataModel<ScoringCriteria> source;
    private final TableRowSelection<ScoringCriteria> selection;

    private ScoringCriteria filter;
    private ScoringCriteria activeItem;

    private ScoringDao scoringDao = new ScoringDao();

    public MbScoringCriteriaSearch() {
        source = new DaoDataListModel<ScoringCriteria>(logger) {
            @Override
            protected List<ScoringCriteria> loadDaoListData(SelectionParams params) {
                if (searching) {
                    setFilters();
                    params.setFilters(filters);
                    return scoringDao.getScoringCriterias(userSessionId, params);
                }
                return new ArrayList<ScoringCriteria>();
            }

            @Override
            protected int loadDaoDataSize(SelectionParams params) {
                if (searching) {
                    setFilters();
                    params.setFilters(filters);
                    return scoringDao.getScoringCriteriasCount(userSessionId, params);
                }
                return 0;
            }
        };
        selection = new TableRowSelection<ScoringCriteria>(null, source);
        curMode = VIEW_MODE;
    }

    private void setFilters() {
        filters = new ArrayList<Filter>();
        filters.add(Filter.create("lang", userLang));

        if (getFilter().getId() != null) {
            filters.add(Filter.create("id", getFilter().getId()));
        }
        if (getFilter().getEvaluationId() != null) {
            filters.add(Filter.create("schemeId", getFilter().getEvaluationId()));
        }
        if (getFilter().getName() != null && getFilter().getName().trim().length() > 0) {
            filters.add(Filter.create("name", Filter.Operator.like, Filter.mask(getFilter().getName())));
        }
    }

    public DaoDataModel<ScoringCriteria> getItems() {
        return source;
    }
    public ScoringCriteria getActiveItem() {
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
        } else if (activeItem == null && source.getRowCount() == 0) {
            MbCriteriaValueSearch bean = ManagedBeanWrapper.getManagedBean(MbCriteriaValueSearch.class);
            if (bean != null) {
                bean.clearFilter();
            }
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
        activeItem = (ScoringCriteria) source.getRowData();
        newSelection.addKey(activeItem.getModelId());
        selection.setWrappedSelection(newSelection);
        if (activeItem != null) {
            loadValues();
        }
    }

    public ScoringCriteria getFilter() {
        if (filter == null) {
            filter = new ScoringCriteria();
        }
        return filter;
    }
    public void setFilter(ScoringCriteria filter) {
        this.filter = filter;
    }

    private void loadValues() {
        MbCriteriaValueSearch bean = ManagedBeanWrapper.getManagedBean(MbCriteriaValueSearch.class);
        if (bean != null) {
            bean.getFilter().setLang(userLang);
            bean.getFilter().setCriteriaId(activeItem.getId());
            bean.search();
        }
    }

    @Override
    public void clearFilter() {
        filter = null;
        setForceDelete(false);
        setSearching(false);
        clearBean();
    }
    private void clearBean() {
        source.flushCache();
        selection.clearSelection();
        activeItem = null;
    }
    public void search() {
        setSearching(true);
        clearBean();
    }

    public void add() {
        curMode = NEW_MODE;
        activeItem = new ScoringCriteria();
        activeItem.setLang(curLang);
        activeItem.setEvaluationId(getFilter().getEvaluationId());
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
                    activeItem = scoringDao.addScoringCriteria(userSessionId, activeItem);
                    break;
                case EDIT_MODE:
                    activeItem = scoringDao.modifyScoringCriteria(userSessionId, activeItem);
                    break;
                case REMOVE_MODE:
                    Map<String, Object> map = new HashMap<String, Object>(2);
                    map.put("id", activeItem.getId());
                    map.put("force", isForceDelete());
                    scoringDao.removeScoringCriteria(userSessionId, map);
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
