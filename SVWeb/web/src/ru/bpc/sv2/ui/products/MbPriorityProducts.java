package ru.bpc.sv2.ui.products;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.ProductsDao;
import ru.bpc.sv2.products.PriorityProduct;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.TableRowSelection;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import java.util.ArrayList;

@ViewScoped
@ManagedBean (name = "MbPriorityProducts")
public class MbPriorityProducts extends AbstractBean {
    private static final Logger logger = Logger.getLogger("PRODUCT");

    private static String COMPONENT_ID = "2452:priorityProductsTable";

    private ProductsDao _productsDao = new ProductsDao();

    private PriorityProduct filter;


    private final DaoDataModel<PriorityProduct> _priorityProductsSource;
    private final TableRowSelection<PriorityProduct> _itemSelection;
    private PriorityProduct _activeSelection;

    public MbPriorityProducts() {

        pageLink = "monitoring|priorityProducts";
        _priorityProductsSource = new DaoDataModel<PriorityProduct>() {
            @Override
            protected PriorityProduct[] loadDaoData(SelectionParams params) {
                if (!searching) {
                    return new PriorityProduct[0];
                }
                try {
                    setFilters();
                    params.setFilters(filters.toArray(new Filter[filters.size()]));
                    return _productsDao.getPriorityProducts(userSessionId, params);
                } catch (Exception e) {
                    setDataSize(0);
                    logger.error("", e);
                    FacesUtils.addMessageError(e);
                    return new PriorityProduct[0];
                }
            }

            @Override
            protected int loadDaoDataSize(SelectionParams params) {
                if (!searching) {
                    return 0;
                }
                try {
                    setFilters();
                    params.setFilters(filters.toArray(new Filter[filters.size()]));
                    return _productsDao.getPriorityProductsCount(userSessionId, params);
                } catch (Exception e) {
                    logger.error("", e);
                    FacesUtils.addMessageError(e);
                    return 0;
                }
            }
        };

        _itemSelection = new TableRowSelection<PriorityProduct>(null, _priorityProductsSource);
    }

    public DaoDataModel<PriorityProduct> getPriorityProducts() {
        return _priorityProductsSource;
    }

    public PriorityProduct getActiveSelection() {
        return _activeSelection;
    }

    public void setActiveSelection(PriorityProduct activeSelection) {
        _activeSelection = activeSelection;
    }

    public SimpleSelection getItemSelection() {
        try {
            if (_activeSelection == null && _priorityProductsSource.getRowCount() > 0) {
                setFirstRowActive();
            } else if (_activeSelection != null && _priorityProductsSource.getRowCount() > 0) {
                SimpleSelection selection = new SimpleSelection();
                selection.addKey(_activeSelection.getModelId());
                _itemSelection.setWrappedSelection(selection);
                _activeSelection = _itemSelection.getSingleSelection();
            }
        } catch (Exception e) {
            logger.error("", e);
            FacesUtils.addMessageError(e);
        }
        return _itemSelection.getWrappedSelection();
    }

    public void setItemSelection(SimpleSelection selection) {
        _itemSelection.setWrappedSelection(selection);
        _activeSelection = _itemSelection.getSingleSelection();

        if (_activeSelection != null) {
            setBeans();
        }
    }

    public void setFirstRowActive() {
        _priorityProductsSource.setRowIndex(0);
        SimpleSelection selection = new SimpleSelection();
        _activeSelection = (PriorityProduct) _priorityProductsSource.getRowData();
        selection.addKey(_activeSelection.getModelId());
        _itemSelection.setWrappedSelection(selection);

        setBeans();
    }

    /**
     * Sets data for backing beans used by dependent pages
     */
    public void setBeans() {
    }

    public void setFilters() {
        getFilter();
        filters = new ArrayList<Filter>();

        if (filter.getId() != null) {
            filters.add(new Filter("id", filter.getId()));
        }
        if (filter.getDateFrom() != null) {
            filters.add(new Filter("creationDateFrom", filter.getDateFrom()));
        }
        if (filter.getDateTo() != null) {
            filters.add(new Filter("creationDateTo", filter.getDateTo()));
        }
        if (filter.getProductNumber() != null && !filter.getProductNumber().trim().isEmpty()) {
            filters.add(new Filter("productNumber", Filter.mask(filter.getProductNumber())));
        }
        if (filter.getProductCategory() != null && !filter.getProductCategory().trim().isEmpty()) {
            filters.add(new Filter("productCategory", filter.getProductCategory()));
        }
        if (filter.getProductSubcategory() != null && !filter.getProductSubcategory().trim().isEmpty()) {
            filters.add(new Filter("productSubcategory", filter.getProductCategory()));
        }
    }

    public PriorityProduct getFilter() {
        if (filter == null) {
            filter = new PriorityProduct();
        }
        return filter;
    }

    public void setFilter(PriorityProduct filter) {
        this.filter = filter;
    }

    public void clearFilter() {
        filter = null;
        clearBean();

        searching = false;
    }

    public void search() {
        curMode = VIEW_MODE;
        clearBean();
        searching = true;
    }

    public void clearBean() {
        curLang = userLang;
        _priorityProductsSource.flushCache();
        _itemSelection.clearSelection();
        _activeSelection = null;

        clearBeans();
    }

    private void clearBeans() {

    }

    public String getComponentId() {
        return COMPONENT_ID;
    }

    public Logger getLogger() {
        return logger;
    }

}
