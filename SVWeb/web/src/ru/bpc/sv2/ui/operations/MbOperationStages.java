package ru.bpc.sv2.ui.operations;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.OperationDao;
import ru.bpc.sv2.operations.Stage;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.TableRowSelection;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import java.util.ArrayList;

@ViewScoped
@ManagedBean(name = "MbOperationStages")
public class MbOperationStages extends AbstractBean {
    private static final Logger logger = Logger.getLogger("OPER_PROCESSING");

    private OperationDao _operationDao = new OperationDao();



    private Stage filter;

    private final DaoDataModel<Stage> _stageSource;
    private final TableRowSelection<Stage> _itemSelection;
    private Stage _activeStage;

    private static String COMPONENT_ID = "operationStagesTable";
    private String tabName;
    private String parentSectionId;

    public MbOperationStages() {


        _stageSource = new DaoDataModel<Stage>() {
            @Override
            protected Stage[] loadDaoData(SelectionParams params) {
                if (!searching) {
                    return new Stage[0];
                }
                try {
                    setFilters();
                    params.setFilters(filters.toArray(new Filter[filters.size()]));
                    return _operationDao.getOperationStages(userSessionId, params);
                } catch (Exception e) {
                    setDataSize(0);
                    FacesUtils.addMessageError(e);
                    logger.error("", e);
                }
                return new Stage[0];
            }

            @Override
            protected int loadDaoDataSize(SelectionParams params) {
                if (!searching) {
                    return 0;
                }
                try {
                    setFilters();
                    params.setFilters(filters.toArray(new Filter[filters.size()]));
                    return _operationDao.getOperationStagesCount(userSessionId, params);
                } catch (Exception e) {
                    FacesUtils.addMessageError(e);
                    logger.error("", e);
                }
                return 0;
            }
        };

        _itemSelection = new TableRowSelection<Stage>(null, _stageSource);
    }

    public DaoDataModel<Stage> getOperationStages() {
        return _stageSource;
    }

    public Stage getActiveStage() {
        return _activeStage;
    }

    public void setActiveStage(Stage activeStage) {
        _activeStage = activeStage;
    }

    public SimpleSelection getItemSelection() {
        if (_activeStage == null && _stageSource.getRowCount() > 0) {
            setFirstRowActive();
        } else if (_activeStage != null && _stageSource.getRowCount() > 0) {
            SimpleSelection selection = new SimpleSelection();
            selection.addKey(_activeStage.getModelId());
            _itemSelection.setWrappedSelection(selection);
            _activeStage = _itemSelection.getSingleSelection();
        }
        return _itemSelection.getWrappedSelection();
    }

    public void setItemSelection(SimpleSelection selection) {
        _itemSelection.setWrappedSelection(selection);
        _activeStage = _itemSelection.getSingleSelection();

        if (_activeStage != null) {
            setBeans();
        }
    }

    public void setFirstRowActive() {
        _stageSource.setRowIndex(0);
        SimpleSelection selection = new SimpleSelection();
        _activeStage = (Stage) _stageSource.getRowData();
        selection.addKey(_activeStage.getModelId());
        _itemSelection.setWrappedSelection(selection);

        if (_activeStage != null) {
            setBeans();
        }
    }

    public void setBeans() {

    }

    public void search() {
        clearBean();
        searching = true;
    }

    public void clearFilter() {
        filter = new Stage();
        clearBean();
        searching = false;
    }

    public void setFilters() {
        filter = getFilter();

        filters = new ArrayList<Filter>();

        Filter paramFilter;

        paramFilter = new Filter("lang", userLang);
        filters.add(paramFilter);

        if (filter.getOperId() != null) {
            paramFilter = new Filter("operId", filter.getOperId());
            filters.add(paramFilter);
        }
    }

    public Stage getFilter() {
        if (filter == null) {
            filter = new Stage();
        }
        return filter;
    }

    public void setFilter(Stage filter) {
        this.filter = filter;
    }


    public void clearBean() {
        _stageSource.flushCache();
        _itemSelection.clearSelection();
        _activeStage = null;
    }

    public Logger getLogger() {
        return logger;
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
}
