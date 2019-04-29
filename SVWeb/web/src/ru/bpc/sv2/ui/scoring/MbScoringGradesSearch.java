package ru.bpc.sv2.ui.scoring;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.ScoringDao;
import ru.bpc.sv2.scoring.ScoringGrade;
import ru.bpc.sv2.ui.utils.*;
import ru.bpc.sv2.utils.UserException;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import java.util.ArrayList;
import java.util.List;

@ViewScoped
@ManagedBean (name = "MbScoringGradesSearch")
public class MbScoringGradesSearch extends AbstractBean {
    private static final long serialVersionUID = 1562402854449134601L;
    private static final Logger logger = Logger.getLogger("SCORING");

    private final DaoDataModel<ScoringGrade> source;
    private final TableRowSelection<ScoringGrade> selection;

    private ScoringGrade filter;
    private ScoringGrade activeItem;

    private ScoringDao scoringDao = new ScoringDao();

    public MbScoringGradesSearch() {
        source = new DaoDataListModel<ScoringGrade>(logger) {
            @Override
            protected List<ScoringGrade> loadDaoListData(SelectionParams params) {
                if (searching) {
                    setFilters();
                    params.setFilters(filters);
                    return scoringDao.getScoringGrades(userSessionId, params);
                }
                return new ArrayList<ScoringGrade>();
            }

            @Override
            protected int loadDaoDataSize(SelectionParams params) {
                if (searching) {
                    setFilters();
                    params.setFilters(filters);
                    return scoringDao.getScoringGradesCount(userSessionId, params);
                }
                return 0;
            }
        };
        selection = new TableRowSelection<ScoringGrade>(null, source);
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

    public DaoDataModel<ScoringGrade> getItems() {
        return source;
    }
    public ScoringGrade getActiveItem() {
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
        activeItem = (ScoringGrade) source.getRowData();
        newSelection.addKey(activeItem.getModelId());
        selection.setWrappedSelection(newSelection);
        if (activeItem != null) {
            loadValues();
        }
    }

    public ScoringGrade getFilter() {
        if (filter == null) {
            filter = new ScoringGrade();
        }
        return filter;
    }
    public void setFilter(ScoringGrade filter) {
        this.filter = filter;
    }

    private void loadValues() {
        /* TODO */
    }

    @Override
    public void clearFilter() {
        filter = null;
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
        activeItem = new ScoringGrade();
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
                    checkDuplicates();
                    activeItem = scoringDao.addScoringGrade(userSessionId, activeItem);
                    break;
                case EDIT_MODE:
                    checkDuplicates();
                    activeItem = scoringDao.modifyScoringGrade(userSessionId, activeItem);
                    break;
                case REMOVE_MODE:
                    scoringDao.removeScoringGrade(userSessionId, activeItem);
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

    private void checkDuplicates() throws UserException {
        for (ScoringGrade exist : source.getActivePage()) {
            if (activeItem.getTotalScore().equals(exist.getTotalScore())) {
                if (!exist.getId().equals(activeItem.getId())) {
                    throw new UserException(FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Scr",
                                                                  "duplicated_total_score"));
                }
            }
        }
    }
}
