package ru.bpc.sv2.ui.products;

import org.apache.log4j.Logger;
import org.openfaces.component.table.TreePath;
import org.openfaces.util.Faces;
import ru.bpc.sv2.constants.DictNames;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.ProductsDao;
import ru.bpc.sv2.products.ProductService;
import ru.bpc.sv2.ui.utils.AbstractTreeBean;
import ru.bpc.sv2.ui.utils.FacesUtils;
import util.auxil.ManagedBeanWrapper;


import ru.bpc.sv2.logic.utility.db.DataAccessException;
import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.model.SelectItem;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@ViewScoped
@ManagedBean(name ="MbProductAppServices")
public class MbProductAppServices extends AbstractTreeBean<ProductService> {
    private static final Logger logger = Logger.getLogger("PRODUCTS");

    private ProductsDao _productsDao = new ProductsDao();

    private ProductService filter;
    private ProductService newNode;
    private boolean searching = false;
    private boolean appMode = false;

    private final String SERVICE_STATUS_INACTIVE;

    private String serviceStatus;
    private String productType;
    private Integer instId;
    private boolean isChild;

    public MbProductAppServices() {
        SERVICE_STATUS_INACTIVE = DictNames.SERVICE_STATUS + "0002";
    }

    public ProductService getNode() {
        if (currentNode == null) {
            currentNode = new ProductService();
        }
        return currentNode;
    }

    public void setNode(ProductService node) {
        curLang = userLang;
        if (node == null)
            return;

        this.currentNode = node;
    }

    public TreePath getNodePath() {
        return nodePath;
    }
    public void setNodePath(TreePath nodePath) {
        this.nodePath = nodePath;
    }

    private ProductService getProductService() {
        return (ProductService) Faces.var("service");
    }

    protected void loadTree() {
        coreItems = new ArrayList<ProductService>();

        if (!searching)
            return;

        setFilters();

        SelectionParams params = new SelectionParams();
        params.setFilters(filters.toArray(new Filter[filters.size()]));
        try {
            ProductService[] services = _productsDao.getProductServicesHier(userSessionId, params);
            if (services != null && services.length > 0) {
                addNodes(0, coreItems, services);
                if (nodePath == null) {
                    if (currentNode == null) {
                        currentNode = coreItems.get(0);
                        setNodePath(new TreePath(currentNode, null));
                    } else {
                        if (currentNode.getParentId() != null) {
                            setNodePath(formNodePath(services));
                        } else {
                            setNodePath(new TreePath(currentNode, null));
                        }
                    }
                }
                setBeans();
            }
            treeLoaded = true;
        } catch (DataAccessException ee) {
            FacesUtils.addMessageError(ee);
            logger.error("", ee);
        }
    }

    public List<ProductService> getNodeChildren() {
        ProductService service = getProductService();
        if (service == null) {
            if (!treeLoaded || coreItems == null) {
                loadTree();
            }
            return coreItems;
        } else {
            return service.getChildren();
        }
    }

    public boolean getNodeHasChildren() {
        return getProductService() != null && getProductService().isHasChildren();
    }

    public void setBeans() {}

    public void setFilters() {
        getFilter();
        filters = new ArrayList<Filter>();

        Filter paramFilter = new Filter();
        paramFilter.setElement("lang");
        paramFilter.setValue(curLang);
        filters.add(paramFilter);

        if (filter.getServiceId() != null) {
            paramFilter = new Filter();
            paramFilter.setElement("serviceId");
            paramFilter.setValue(filter.getServiceId().toString());
            filters.add(paramFilter);
        }
        if (filter.getProductId() != null) {
            paramFilter = new Filter();
            paramFilter.setElement("productId");
            paramFilter.setValue(filter.getProductId().toString());
            filters.add(paramFilter);
        }
    }

    public ProductService getFilter() {
        if (filter == null) {
            filter = new ProductService();
        }
        return filter;
    }
    public void setFilter(ProductService filter) {
        this.filter = filter;
    }
    public void clearFilter() {
        filter = new ProductService();
        clearBean();
        searching = false;
    }

    public void search() {
        curMode = VIEW_MODE;
        clearBean();
        searching = true;
    }

    public void fullCleanBean() {
        clearFilter();
        serviceStatus = null;
        productType = null;
    }

    public void add() {
        newNode = new ProductService();
        newNode.setProductId(filter.getProductId());
        newNode.setMinCount(0);
        newNode.setMaxCount(0);
        curMode = NEW_MODE;
    }

    public void edit() {
        try {
            newNode = (ProductService) currentNode.clone();
        } catch (CloneNotSupportedException e) {
            logger.error("", e);
            newNode = currentNode;
        }
        curMode = EDIT_MODE;
    }

    public void delete() {
        try {
            newNode = _productsDao.removeProductService(userSessionId, currentNode, curLang);

            String msg = FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Prd", "prod_serv_rel_deleted");

            currentNode = newNode;
            loadTree();

            // if this bean is loaded from products form it's need to clear
            // loaded tabs to load new attributes.
            if (getFilter().getProductId() != null) {
                MbProducts prodBean = (MbProducts) ManagedBeanWrapper.getManagedBean("MbProducts");
                prodBean.clearLoadedTabs();
            }
            FacesUtils.addMessageInfo(msg);
        } catch (Exception e) {
            FacesUtils.addMessageError(e);
            logger.error("", e);
        }
    }

    public void save() {
        if (newNode.getMaxCount() < newNode.getMinCount()) {
            FacesUtils.addMessageError(new Exception(FacesUtils.getMessage(
                    "ru.bpc.sv2.ui.bundles.Prd", "min_count_gt_max_count")));
            return;
        }
        try {
            if (isNewMode()) {
                newNode = _productsDao.addProductService(userSessionId,
                                                         newNode, curLang);
                addElementToTree(newNode);
            } else {
                newNode = _productsDao.editProductService(userSessionId,
                                                          newNode, curLang);
                replaceNode(currentNode, newNode, coreItems);
            }
            currentNode = newNode;
            curMode = VIEW_MODE;
            setBeans();
            // if this bean is loaded from products form it's need to clear
            // loaded tabs to load new attributes.
            if (getFilter().getProductId() != null) {
                MbProducts prodBean = (MbProducts) ManagedBeanWrapper.getManagedBean("MbProducts");
                prodBean.clearLoadedTabs();
            }

            FacesUtils.addMessageInfo(FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Prd",
                                                            "prod_serv_rel_saved"));
        } catch (Exception e) {
            FacesUtils.addMessageError(e);
            logger.error("", e);
        }
    }

    public void cancel() {
        curMode = VIEW_MODE;
    }

    public ProductService getNewNode() {
        if (newNode == null) {
            newNode = new ProductService();
        }
        return newNode;
    }

    public void setNewNode(ProductService newNode) {
        this.newNode = newNode;
    }

    public void clearBean() {
        curLang = userLang;
        currentNode = null;
        nodePath = null;
        treeLoaded = false;
    }

    public List<SelectItem> getParentServices() {
        if (getFilter().getProductId() == null) return new ArrayList<SelectItem>();

        Map<String, Object> params = new HashMap<String, Object>();
        params.put("product_id", getFilter().getProductId());
        List<SelectItem> result = getDictUtils().getLov(LovConstants.LINKED_PRODUCT_SERVICES, params);
        return result;
    }

    public List<SelectItem> getServices() {
        if (instId == null || productType == null) {
            return new ArrayList<SelectItem>(0);
        }
        Map<String, Object> params = new HashMap<String, Object>();
        params.put("product_id", getFilter().getProductId());
        params.put("inst_id", getInstId());
        List<SelectItem> result = getDictUtils().getLov(LovConstants.NO_LINKED_PRODUCT_SERVICES, params);
        return result;
    }

    public String getServiceStatus() {
        return serviceStatus;
    }
    public void setServiceStatus(String serviceStatus) {
        this.serviceStatus = serviceStatus;
    }

    public boolean isServiceInactive() {
        return SERVICE_STATUS_INACTIVE.equals(serviceStatus);
    }

    public String getProductType() {
        return productType;
    }
    public void setProductType(String productType) {
        this.productType = productType;
    }

    public Integer getInstId() {
        return instId;
    }
    public void setInstId(Integer instId) {
        this.instId = instId;
    }

    public boolean isChild() {
        return isChild;
    }
    public void setChild(boolean isChild) {
        this.isChild = isChild;
    }

    public boolean isAppMode() {
        return appMode;
    }
    public void setAppMode(boolean appMode) {
        this.appMode = appMode;
    }
}
