package ru.bpc.sv2.ui.scoring;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.ScoringDao;
import ru.bpc.sv2.scoring.ScoringScheme;
import ru.bpc.sv2.ui.utils.*;
import ru.bpc.sv2.utils.UserException;
import util.auxil.ManagedBeanWrapper;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.model.SelectItem;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@ViewScoped
@ManagedBean (name = "MbScoringSchemesSearch")
public class MbScoringSchemesSearch extends AbstractBean {
    private static final long serialVersionUID = 1562402854449134601L;
    private static final Logger logger = Logger.getLogger("SCORING");
    private static final String CRITERIA_TAB = "criteriaTab";
    private static final String GRADE_TAB = "gradeTab";

    private ScoringScheme filter;
    private ScoringScheme activeItem;
    private String tabName;

    private final DaoDataModel<ScoringScheme> source;
    private final TableRowSelection<ScoringScheme> selection;

    private ScoringDao scoringDao = new ScoringDao();

    public MbScoringSchemesSearch() {
        pageLink = "scr|list_schemes";
        tabName = CRITERIA_TAB;
        source = new DaoDataListModel<ScoringScheme>(logger) {
            @Override
            protected List<ScoringScheme> loadDaoListData(SelectionParams params) {
                if (searching) {
                    setFilters();
                    params.setFilters(filters);
                    return scoringDao.getScoringSchemes(userSessionId, params);
                }
                return new ArrayList<ScoringScheme>();
            }

            @Override
            protected int loadDaoDataSize(SelectionParams params) {
                if (searching) {
                    setFilters();
                    params.setFilters(filters);
                    return scoringDao.getScoringSchemesCount(userSessionId, params);
                }
                return 0;
            }
        };
        selection = new TableRowSelection<ScoringScheme>(null, source);
        curMode = VIEW_MODE;
    }

    private void setFilters() {
        filters = new ArrayList<Filter>();
        filters.add(Filter.create("lang", userLang));

        if (getFilter().getId() != null) {
            filters.add(Filter.create("id", getFilter().getId()));
        }
        if (getFilter().getInstId() != null) {
            filters.add(Filter.create("instId", getFilter().getInstId()));
        }
        if (getFilter().getName() != null && getFilter().getName().trim().length() > 0) {
            filters.add(Filter.create("name", Filter.Operator.like, Filter.mask(getFilter().getName())));
        }
    }

    public DaoDataModel<ScoringScheme> getItems() {
        return source;
    }
    public ScoringScheme getActiveItem() {
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
            activeItem = (ScoringScheme) source.getRowData();
            newSelection.addKey(activeItem.getModelId());
            selection.setWrappedSelection(newSelection);
            if (activeItem != null) {
                loadTab(getTabName());
            }
        }
    }

    public ScoringScheme getFilter() {
        if (filter == null) {
            filter = new ScoringScheme();
        }
        return filter;
    }
    public void setFilter(ScoringScheme filter) {
        this.filter = filter;
    }

    public String getTabName() {
        if (tabName == null) {
            tabName = CRITERIA_TAB;
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
            if (CRITERIA_TAB.equalsIgnoreCase(tabName)) {
                MbScoringCriteriaSearch bean = ManagedBeanWrapper.getManagedBean(MbScoringCriteriaSearch.class);
                if (bean != null) {
                    bean.getFilter().setLang(userLang);
                    bean.getFilter().setEvaluationId(activeItem.getId());
                    bean.search();
                }
            } else if (GRADE_TAB.equalsIgnoreCase(tabName)) {
                MbScoringGradesSearch bean = ManagedBeanWrapper.getManagedBean(MbScoringGradesSearch.class);
                if (bean != null) {
                    bean.getFilter().setLang(userLang);
                    bean.getFilter().setEvaluationId(activeItem.getId());
                    bean.search();
                }
            }
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

    public List<SelectItem> getInstitutions() {
        return getDictUtils().getLov(LovConstants.INSTITUTIONS);
    }

    public void add() {
        curMode = NEW_MODE;
        activeItem = new ScoringScheme();
        activeItem.setLang(curLang);
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
                    activeItem = scoringDao.addScoringScheme(userSessionId, activeItem);
                    break;
                case EDIT_MODE:
                    activeItem = scoringDao.modifyScoringScheme(userSessionId, activeItem);
                    break;
                case REMOVE_MODE:
                    Map<String, Object> map = new HashMap<String, Object>(2);
                    map.put("id", activeItem.getId());
                    map.put("force", isForceDelete());
                    scoringDao.removeScoringScheme(userSessionId, map);
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
