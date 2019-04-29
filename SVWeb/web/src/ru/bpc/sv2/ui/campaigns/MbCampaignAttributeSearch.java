package ru.bpc.sv2.ui.campaigns;

import org.apache.log4j.Logger;
import org.openfaces.component.table.TreePath;
import org.openfaces.util.Faces;
import ru.bpc.sv2.campaign.CampaignAttribute;
import ru.bpc.sv2.campaign.CampaignAttributeValue;
import ru.bpc.sv2.campaign.CampaignProduct;
import ru.bpc.sv2.campaign.CampaignService;
import ru.bpc.sv2.constants.EntityNames;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.FilterBuilder;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.CampaignDao;
import ru.bpc.sv2.logic.ProductsDao;
import ru.bpc.sv2.logic.utility.db.DataAccessException;
import ru.bpc.sv2.products.Attribute;
import ru.bpc.sv2.products.ProductAttribute;
import ru.bpc.sv2.ui.products.MbAttributeValues;
import ru.bpc.sv2.ui.utils.AbstractSearchBean;
import ru.bpc.sv2.ui.utils.AbstractTreeBean;
import ru.bpc.sv2.ui.utils.FacesUtils;
import util.auxil.ManagedBeanWrapper;

import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

@ViewScoped
@ManagedBean (name = "MbCampaignAttributeSearch")
public class MbCampaignAttributeSearch extends AbstractSearchBean<CampaignAttribute, CampaignAttribute> {
    private static final Logger logger = Logger.getLogger("CPN");

    private static final int LEVEL_PRODUCT = 0;
    private static final int LEVEL_SERVICE = 1;
    private static final int LEVEL_ATTR_MIN = 2;

    private CampaignDao campaignDao = new CampaignDao();
    private ProductsDao productsDao = new ProductsDao();

    private CampaignAttribute currentNode;
    private List<CampaignAttribute> coreItems;
    private boolean treeLoaded = true;
    private TreePath nodePath;

    @Override
    protected CampaignAttribute createFilter() {
        return new CampaignAttribute();
    }

    @Override
    protected Logger getLogger() {
        return logger;
    }

    @Override
    public void search() {
        curMode = VIEW_MODE;
        clearState();
        loadTree();
    }

    @Override
    public void clearState() {
        if (tableRowSelection != null) {
            tableRowSelection.clearSelection();
        }
        if (dataModel != null) {
            dataModel.flushCache();
        }
        activeItem = null;
        activeItems = null;
        treeLoaded = true;
        coreItems = null;
        currentNode = null;
        curLang = userLang;
    }

    private void save(List<ProductAttribute> list, ProductAttribute selection,
                      CampaignAttribute filter,
                      boolean forward, boolean skipInitial) {
        if (selection != null && filter != null) {
            if (!skipInitial) {
                CampaignAttribute attribute = new CampaignAttribute();
                attribute.setCampaignId(getFilter().getCampaignId());
                attribute.setProductId(filter.getProductId());
                attribute.setServiceId(filter.getServiceId());
                attribute.setAttributeId(selection.getId().longValue());
                attribute.setLang(selection.getLang());

                setNewItem(attribute);
                super.save();
            }

            if (forward) {
                if (selection.getChildren() != null) {
                    for (ProductAttribute child : selection.getChildren()) {
                        this.save(list, child, filter, forward, false);
                    }
                }
            } else if (selection.getLevel() > 2 && list != null) {
                for (ProductAttribute parent : list) {
                    if (parent.getId().equals(selection.getParentId())) {
                        boolean isNewNode = true;
                        if (activeItems != null) {
                            for (CampaignAttribute attr : activeItems) {
                                if (parent.getId().equals(attr.getId())) {
                                    isNewNode = false;
                                    break;
                                }
                            }
                        }
                        if (isNewNode) {
                            this.save(list, parent, filter, forward, false);
                        }
                    }
                }
            }
        }
    }

    @Override
    public void save() {
        MbCampaignAttributeModalSearch bean = ManagedBeanWrapper.getManagedBean(MbCampaignAttributeModalSearch.class);
        if (bean != null) {
            if (bean.isNodeExists()) {
                this.save(bean.getNodeList(), bean.getNode(), bean.getModalFilter(), true, false);
                this.save(bean.getNodeList(), bean.getNode(), bean.getModalFilter(), false, true);
            }
        }
    }

    @Override
    public void add() {
        super.add();
        MbCampaignAttributeModalSearch bean = ManagedBeanWrapper.getManagedBean(MbCampaignAttributeModalSearch.class);
        if (bean != null) {
            bean.fullCleanBean();
            bean.getModalFilter().setCampaignId(getFilter().getCampaignId());
            bean.getModalFilter().setInstId(getFilter().getInstId());
            bean.getModalFilter().setLang(userLang);
            bean.initCampaignProducts();
            bean.initCampaignServices();
        }
    }

    @Override
    protected CampaignAttribute addItem(CampaignAttribute item) {
        return campaignDao.addAttribute(userSessionId, item);
    }

    @Override
    protected CampaignAttribute editItem(CampaignAttribute item) {
        return item;
    }

    @Override
    protected void deleteItem(CampaignAttribute item) {
        if (currentNode.getChildren() != null) {
            for (CampaignAttribute node : currentNode.getChildren()) {
                deleteItem(node);
            }
        }
        campaignDao.removeAttribute(userSessionId, currentNode);
    }

    @Override
    protected void onItemSelected(CampaignAttribute activeItem) {
        MbAttributeValues bean = ManagedBeanWrapper.getManagedBean(MbAttributeValues.class);

        if (bean != null && activeItem != null) {
            bean.fullCleanBean();
            bean.setCampaignId(getFilter().getCampaignId());

            List<Filter> attrFilters = new ArrayList<Filter>();
            attrFilters.add(Filter.create("productId", activeItem.getProductId()));
            attrFilters.add(Filter.create("serviceId", activeItem.getServiceId()));
            attrFilters.add(Filter.create("lang", userLang));
            SelectionParams sp = new SelectionParams(attrFilters);
            ProductAttribute[] attrs = productsDao.getProductAttributes(userSessionId, sp);
            if (attrs != null && attrs.length > 0) {
                for (ProductAttribute attr : attrs) {
                    if (attr.getId().longValue() == activeItem.getAttributeId().longValue()) {
                        bean.setAttribute(attr);
                        break;
                    }
                }
            }

            bean.setCaching(false);
            bean.setProductId(activeItem.getProductId().intValue());
            bean.setObjectId(activeItem.getProductId());
            bean.setEntityType(EntityNames.PRODUCT);
            if (bean.getAttribute() != null) {
                bean.getAttribute().setDefLevel(ProductAttribute.DEF_LEVEL_PRODUCT);
            }
            bean.setInstId(getFilter().getInstId());

            List<Filter> productFilters = new ArrayList<Filter>();
            if (getFilter().getCampaignId() != null) {
                productFilters.add(Filter.create("campaignId", getFilter().getCampaignId()));
            }
            productFilters.add(Filter.create("productId", activeItem.getProductId()));
            productFilters.add(Filter.create("lang", userLang));
            SelectionParams params = new SelectionParams(productFilters);
            params.setRowIndexStart(0);
            params.setRowIndexEnd(9999);
            List<CampaignProduct> products = campaignDao.getProducts(userSessionId, params);
            if (products != null && !products.isEmpty()) {
                bean.setProductType(products.get(0).getProductType());
            }
            bean.getAttributeValues().flushCache();
        }
    }

    @Override
    protected void initFilters(CampaignAttribute filter, List<Filter> filters) {
        filters.addAll(FilterBuilder.createFiltersDatesAsString(filter));
        filters.add(Filter.create(LANGUAGE, userLang));
    }

    @Override
    protected List<CampaignAttribute> getObjectList(Long userSessionId, SelectionParams params) {
        return campaignDao.getAttributes(userSessionId, params);
    }

    @Override
    protected int getObjectCount(Long userSessionId, SelectionParams params) {
        return campaignDao.getAttributesCount(userSessionId, params);
    }

    @Override
    public void remove() {
        try {
            deleteItem(currentNode);
            treeLoaded = false;
            currentNode = null;
            loadTree();
            if (currentNode == null) {
                clearState();
            }
        } catch (Exception e) {
            FacesUtils.addMessageError(e);
            getLogger().error("", e);
        } finally {
            curMode = VIEW_MODE;
        }
    }

    public boolean isActive() {
        if (currentNode != null) {
            MbCampaignsSearch bean = ManagedBeanWrapper.getManagedBean(MbCampaignsSearch.class);
            if (bean != null) {
                return !bean.isActive();
            }
        }
        return false;
    }

    private void addNode(CampaignAttribute node, List<CampaignAttribute> tree, List<CampaignAttribute> raw) {
        if (node.getChildren() == null) {
            node.setChildren(new ArrayList<CampaignAttribute>());
        }
        buildTree(node, node.getChildren(), raw);
        tree.add(node);
    }

    private void buildTree(CampaignAttribute parent, List<CampaignAttribute> tree, List<CampaignAttribute> raw) {
        for (CampaignAttribute node : raw) {
            if (parent == null && node.getParentId() == null) {
                addNode(node, tree, raw);
            } else if (parent != null && parent.getAttributeId() == null) {
                if (parent.getId().equals(node.getParentId())) {
                    if (node.getProductId().equals(parent.getProductId())) {
                        addNode(node, tree, raw);
                    }
                }
            } else if (parent != null && parent.getAttributeId() != null) {
                if (parent.getAttributeId().equals(node.getParentId())) {
                    if (node.getServiceId().equals(parent.getServiceId())) {
                        if (node.getProductId().equals(parent.getProductId())) {
                            addNode(node, tree, raw);
                        }
                    }
                }
            }
        }
    }

    public List<CampaignAttribute> getNodeChildren() {
        if (getFilter().getCampaignId() != null) {
            CampaignAttribute prod = getProductAttribute();
            if (prod == null) {
                if (!treeLoaded || coreItems == null) {
                    loadTree();
                }
                return coreItems;
            } else {
                return prod.getChildren();
            }
        } else {
            clearState();
            return null;
        }
    }

    public CampaignAttribute getNode() {
        if (currentNode == null) {
            currentNode = new CampaignAttribute();
        }
        return currentNode;
    }
    public void setNode(CampaignAttribute node) {
        if (node != null) {
            this.currentNode = node;
            onItemSelected(this.currentNode);
        }
    }

    public TreePath getNodePath() {
        return nodePath;
    }
    public void setNodePath(TreePath nodePath) {
        this.nodePath = nodePath;
    }

    public boolean getNodeHasChildren() {
        return (getProductAttribute() != null) && getProductAttribute().hasChildren();
    }

    private CampaignAttribute getProductAttribute() {
        return (CampaignAttribute) Faces.var("attr");
    }

    private void loadTree() {
        try {
            filters = new ArrayList<Filter>();
            activeItems = null;
            initFilters(getFilter(), filters);
            SelectionParams params = new SelectionParams(filters);
            activeItems = campaignDao.getAttributes(userSessionId, params);
            coreItems = new ArrayList<CampaignAttribute>();

            if (activeItems != null && activeItems.size() > 0) {
                buildTree(null, coreItems, activeItems);
                if (nodePath == null || currentNode == null) {
                    currentNode = coreItems.get(0);
                    setNodePath(new TreePath(currentNode, null));
                }
            }
            onItemSelected(currentNode);
            treeLoaded = true;
        } catch (DataAccessException ee) {
            FacesUtils.addMessageError( ee );
            logger.error("",ee);
        }
    }
}
