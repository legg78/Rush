package ru.bpc.sv2.ui.application;

import java.util.ArrayList;


import ru.bpc.sv2.application.PriorityCriteria;
import ru.bpc.sv2.logic.ApplicationDao;
import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;

import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.TableRowSelection;

@ViewScoped
@ManagedBean (name = "MbApplicationPriorityCriteria")
public class MbApplicationPriorityCriteria extends AbstractBean {
    private static final Logger logger = Logger.getLogger("APPLICATIONS");

    private ApplicationDao applicationDao = new ApplicationDao();

    private Long applicationId;
    private PriorityCriteria activePriorityCriteria;

    private String tabName;

    private static String COMPONENT_ID = "priorityCriteriaTable";
    private String parentSectionId;

    private final DaoDataModel<PriorityCriteria> priorityCriteriaSource;

    private final TableRowSelection<PriorityCriteria> itemSelection;

    public MbApplicationPriorityCriteria() {

        priorityCriteriaSource = new DaoDataModel<PriorityCriteria>() {
            @Override
            protected PriorityCriteria[] loadDaoData(SelectionParams params) {
                if (!searching)
                    return new PriorityCriteria[0];
                try {
                    return applicationDao.getPriorityCriteria(userSessionId, applicationId);
                } catch (Exception e) {
                    setDataSize(0);
                    logger.error("", e);
                    FacesUtils.addMessageError(e);
                }
                return new PriorityCriteria[0];
            }

            @Override
            protected int loadDaoDataSize(SelectionParams params) {
                if (!searching)
                    return 0;
                try {
                    return applicationDao.getPriorityCriteriaCount(userSessionId, applicationId);
                } catch (Exception e) {
                    logger.error("", e);
                    FacesUtils.addMessageError(e);
                }
                return 0;
            }
        };

        itemSelection = new TableRowSelection<PriorityCriteria>(null, priorityCriteriaSource);
    }

    public DaoDataModel<PriorityCriteria> getPriorityCriteria() {
        return priorityCriteriaSource;
    }

    public PriorityCriteria getActivePriorityCriteria() {
        return activePriorityCriteria;
    }

    public void setActivePriorityCriteria(PriorityCriteria priorityCriteria) {
        activePriorityCriteria = priorityCriteria;
    }

    public SimpleSelection getItemSelection() {
        if (activePriorityCriteria == null && priorityCriteriaSource.getRowCount() > 0) {
            setFirstRowActive();
        } else if (activePriorityCriteria != null && priorityCriteriaSource.getRowCount() > 0) {
            SimpleSelection selection = new SimpleSelection();
            selection.addKey(activePriorityCriteria.getModelId());
            itemSelection.setWrappedSelection(selection);
            activePriorityCriteria = itemSelection.getSingleSelection();
        }
        return itemSelection.getWrappedSelection();
    }

    public void setFirstRowActive() {
        priorityCriteriaSource.setRowIndex(0);
        SimpleSelection selection = new SimpleSelection();
        activePriorityCriteria = (PriorityCriteria) priorityCriteriaSource.getRowData();
        selection.addKey(activePriorityCriteria.getModelId());
        itemSelection.setWrappedSelection(selection);
    }

    public void setItemSelection(SimpleSelection selection) {
        itemSelection.setWrappedSelection(selection);
        activePriorityCriteria = itemSelection.getSingleSelection();
    }

    public void search() {
        setSearching(true);
        itemSelection.clearSelection();
        activePriorityCriteria = null;
        priorityCriteriaSource.flushCache();
    }

    public boolean isSearching() {
        return searching;
    }

    public void setSearching(boolean searching) {
        this.searching = searching;
    }

    public void clearBean() {
        activePriorityCriteria = null;
        itemSelection.clearSelection();
        priorityCriteriaSource.flushCache();
    }

    public void setFilters() {
        filters = new ArrayList<Filter>();
        if (applicationId != null) {
            filters.add(new Filter("applicationId", applicationId));
        }
    }

    public void clearFilter() {
        applicationId = null;
        searching = false;
        clearBean();
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

    public Long getApplicationId() {
        return applicationId;
    }

    public void setApplicationId(Long applicationId) {
        this.applicationId = applicationId;
    }

}
