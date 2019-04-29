package ru.bpc.sv2.ui.application;

import java.util.ArrayList;


import ru.bpc.sv2.application.ApplicationPriorityProduct;
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
@ManagedBean (name = "MbApplicationPriorityProducts")
public class MbApplicationPriorityProducts extends AbstractBean {
    private static final Logger logger = Logger.getLogger("APPLICATIONS");

    private ApplicationDao applicationDao = new ApplicationDao();

    private Long applicationId;
    private ApplicationPriorityProduct activePriorityProduct;

    private String tabName;

    private static String COMPONENT_ID = "applicationPriorityProductTable";
    private String parentSectionId;

    private final DaoDataModel<ApplicationPriorityProduct> priorityProductSource;

    private final TableRowSelection<ApplicationPriorityProduct> itemSelection;

    public MbApplicationPriorityProducts() {

        priorityProductSource = new DaoDataModel<ApplicationPriorityProduct>() {
            @Override
            protected ApplicationPriorityProduct[] loadDaoData(SelectionParams params) {
                if (!searching)
                    return new ApplicationPriorityProduct[0];
                try {
                    return applicationDao.getPriorityProducts(userSessionId, applicationId);
                } catch (Exception e) {
                    setDataSize(0);
                    logger.error("", e);
                    FacesUtils.addMessageError(e);
                }
                return new ApplicationPriorityProduct[0];
            }

            @Override
            protected int loadDaoDataSize(SelectionParams params) {
                if (!searching)
                    return 0;
                try {
                    return applicationDao.getPriorityProductsCount(userSessionId, applicationId);
                } catch (Exception e) {
                    logger.error("", e);
                    FacesUtils.addMessageError(e);
                }
                return 0;
            }
        };

        itemSelection = new TableRowSelection<ApplicationPriorityProduct>(null, priorityProductSource);
    }

    public DaoDataModel<ApplicationPriorityProduct> getPriorityProducts() {
        return priorityProductSource;
    }

    public ApplicationPriorityProduct getActivePriorityProduct() {
        return activePriorityProduct;
    }

    public void setActivePriorityProduct(ApplicationPriorityProduct priorityProduct) {
        activePriorityProduct = priorityProduct;
    }

    public SimpleSelection getItemSelection() {
        if (activePriorityProduct == null && priorityProductSource.getRowCount() > 0) {
            setFirstRowActive();
        } else if (activePriorityProduct != null && priorityProductSource.getRowCount() > 0) {
            SimpleSelection selection = new SimpleSelection();
            selection.addKey(activePriorityProduct.getModelId());
            itemSelection.setWrappedSelection(selection);
            activePriorityProduct = itemSelection.getSingleSelection();
        }
        return itemSelection.getWrappedSelection();
    }

    public void setFirstRowActive() {
        priorityProductSource.setRowIndex(0);
        SimpleSelection selection = new SimpleSelection();
        activePriorityProduct = (ApplicationPriorityProduct) priorityProductSource.getRowData();
        selection.addKey(activePriorityProduct.getModelId());
        itemSelection.setWrappedSelection(selection);
    }

    public void setItemSelection(SimpleSelection selection) {
        itemSelection.setWrappedSelection(selection);
        activePriorityProduct = itemSelection.getSingleSelection();
    }

    public void search() {
        setSearching(true);
        itemSelection.clearSelection();
        activePriorityProduct = null;
        priorityProductSource.flushCache();
    }

    public boolean isSearching() {
        return searching;
    }

    public void setSearching(boolean searching) {
        this.searching = searching;
    }

    public void clearBean() {
        activePriorityProduct = null;
        itemSelection.clearSelection();
        priorityProductSource.flushCache();
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
