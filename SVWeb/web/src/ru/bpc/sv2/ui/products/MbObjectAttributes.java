package ru.bpc.sv2.ui.products;

import org.apache.log4j.Logger;
import org.openfaces.component.table.TreePath;
import org.openfaces.util.Faces;
import ru.bpc.sv2.constants.EntityNames;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.ProductsDao;
import ru.bpc.sv2.products.ProductAttribute;
import ru.bpc.sv2.products.ProductService;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.FacesUtils;
import util.auxil.ManagedBeanWrapper;


import ru.bpc.sv2.logic.utility.db.DataAccessException;
import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import java.util.ArrayList;
import java.util.List;

@ViewScoped
@ManagedBean (name = "MbObjectAttributes")
public class MbObjectAttributes extends AbstractBean {
	private static final Logger logger = Logger.getLogger("PRODUCTS");

	private ProductsDao _productsDao = new ProductsDao();

	protected ProductAttribute currentNode;
	private ProductAttribute newNode;
	protected Integer instId;

	protected Integer serviceId;
	protected Integer productId;
	protected Long objectId;
	protected String entityType;
	protected String productType;

	protected ArrayList<ProductAttribute> coreItems;
	protected boolean treeLoaded;
	protected TreePath nodePath;
	private ProductAttribute filter;
	private MbProductsSess productsSession;
	private String productsBackLink;
	private String productsModule;

	private List<ProductService> services = null;
	private boolean caching = false;

	public MbObjectAttributes() {
		productsSession = (MbProductsSess) ManagedBeanWrapper.getManagedBean("MbProductsSess");
    }

    private int addNodes(int startIndex, ArrayList<ProductAttribute> branches, ProductAttribute[] attrs) {
//      int counter = 1;
    	int i;
  		int level = attrs[startIndex].getLevel();

  		for (i = startIndex; i < attrs.length; i++) {
          	if (attrs[i].getLevel() != level) {
        	  break;
          	}
      		branches.add(attrs[i]);
          	if ((i + 1) != attrs.length && attrs[i + 1].getLevel() > level) {
        	  	attrs[i].setChildren(new ArrayList<ProductAttribute>());
	            i = addNodes(i + 1, attrs[i].getChildren(), attrs);
          	}
//          counter++;
      	}
      	return i - 1;
    }

	public boolean isNodeExists() {
		return (currentNode != null);
	}

    public ProductAttribute getNode() {
    	if (currentNode == null) {
    		currentNode = new ProductAttribute();
    	}
        return currentNode;
    }

    public void setNode(ProductAttribute node) {
    	if (node == null) return;

    	this.currentNode = node;
        setInfo(false);
        storeParams();
    }

    /**
     * Saves parameters in session to restore it when needed
     */
    public void storeParams() {
    	productsSession.setProductAttributeCurrentNode(currentNode);
    	//productsSession.setProductAttributeNodePath(nodePath);
    }
    
    public TreePath getNodePath() {
		return nodePath;
	}

	public void setNodePath(TreePath nodePath) {
		this.nodePath = nodePath;
		productsSession.setProductAttributeNodePath(nodePath);
	}

    private ProductAttribute getProductAttribute() {
        return (ProductAttribute) Faces.var("prodAttr");
    }

	private void loadTree() {
		if ((productId != null || serviceId != null || EntityNames.INSTITUTION.equals(entityType)) && instId != null && !caching) {
			try {
				setFilters();
				SelectionParams params = new SelectionParams(filters);
				ProductAttribute[] attrs = null;

				if (EntityNames.PRODUCT.equals(entityType)) {
					attrs = _productsDao.getProductAttributes(userSessionId, params);
				} else if (EntityNames.SERVICE.equals(entityType)) {
					attrs = _productsDao.getServiceAttributes(userSessionId, params);
				} else if (EntityNames.CONTRACT.equals(entityType)) {
					attrs = _productsDao.getContractAttributes(userSessionId, objectId, productId, instId, productType, curLang);
				} else {
					attrs = _productsDao.getObjectAttributes(userSessionId, params);
				}
				coreItems = new ArrayList<ProductAttribute>();

				if (attrs != null && attrs.length > 0) {
					addNodes(0, coreItems, attrs);
					if (nodePath == null) {
						currentNode = coreItems.get(0);
						setNodePath(new TreePath(currentNode, null));
					}
				}
				setInfo(false);
				treeLoaded = true;
			} catch (DataAccessException ee) {
				FacesUtils.addMessageError( ee );
				logger.error("",ee);
			}
		} else {
			treeLoaded = true;
		}
	}
    
	public void setServiceAttribute(){
		if (currentNode==null) {
			return;
		}
		try {
			currentNode.setVisible(!currentNode.isVisible());
			if (services == null) {
				_productsDao.setServiceAttribute(userSessionId, currentNode);
			} else {
				caching = true;
			}
		} catch (DataAccessException ee) {
			FacesUtils.addMessageError( ee );
			logger.error("",ee);
		}
	}

    public void setFilters() {
		filters = new ArrayList<Filter>();
		filters.add(Filter.create("instId", instId.toString()));
		filters.add(Filter.create("lang", curLang));

		if (!EntityNames.SERVICE.equals(entityType)) {
			if (EntityNames.PRODUCT.equals(entityType)) {
				filters.add(Filter.create("entityType", productType));
			} else {
				filters.add(Filter.create("entityType", entityType));
			}
		}
		if (productId != null) {
			filters.add(Filter.create("productId", productId.toString()));
		}
		if (serviceId != null) {
			filters.add(Filter.create("serviceId", serviceId.toString()));
		} else if (services != null) {
			List<String> serviceIds = new ArrayList<String>();
			for (ProductService serv : services) {
				serviceIds.add(serv.getServiceId().toString());
			}
			filters.add(Filter.create("serviceIds", serviceIds));
		}
		if (objectId != null) {
			filters.add(Filter.create("objectId", objectId.toString()));
		}
	}

	public ArrayList<ProductAttribute> getNodeChildren() {
		ProductAttribute prod = getProductAttribute();
		if (prod == null) {
			if (!treeLoaded || coreItems == null) {
				loadTree();
			}
			return coreItems;
		} else {
			return prod.getChildren();
		}
	}

	protected void setInfo(boolean restoreState) {
		MbAttributeValues attrValues = (MbAttributeValues) ManagedBeanWrapper.getManagedBean("MbAttributeValues");
		attrValues.fullCleanBean();

		if (currentNode != null) {
			attrValues.setCaching((services == null) ? false : true);
			attrValues.setAttribute(currentNode);
			attrValues.setProductId(productId);
			attrValues.setObjectId(objectId == null ? (productId == null ? serviceId : productId) : objectId);
			attrValues.setEntityType(entityType);
			attrValues.setInstId(instId);
			attrValues.setProductType(productType);
			attrValues.getAttributeValues().flushCache();
			if (restoreState) {
				attrValues.restoreBean();
			}
		}
	}

    public boolean getNodeHasChildren() {
    	return getProductAttribute() != null && getProductAttribute().hasChildren();
    }

    public Integer getInstId() {
		return instId;
	}

	public void setInstId(Integer instId) {
		this.instId = instId;
	}

	public void search() {
		curMode = VIEW_MODE;
		clearBean();
		loadTree();
	}

	public void clearFilter() {
		curMode = VIEW_MODE;
		curLang = userLang;
		currentNode = null;
		instId = null;
	}

    public void cancel() {
    	curMode = VIEW_MODE;
    }
    
    public ProductAttribute getNewNode() {
		return newNode;
	}

	public void setNewNode(ProductAttribute newNode) {
		this.newNode = newNode;
	}

	public void clearBean() {
		currentNode = null;
		nodePath = null;
		coreItems = null;
		treeLoaded = false;
		curLang = userLang;
		
		// clear dependent bean 
		MbAttributeValues attrValues = (MbAttributeValues) ManagedBeanWrapper.getManagedBean("MbAttributeValues");
		attrValues.fullCleanBean();
	}

	public void fullCleanBean() {
		productId = null;
		objectId = null;
		entityType = null;
		productType = null;
		instId = null;
		serviceId = null;
		clearBean();
	}
	
	public ProductAttribute getFilter() {
		if (filter == null) {
			filter = new ProductAttribute();
		}
		return filter;
	}

	public Integer getProductId() {
		return productId;
	}

	public void setProductId(Integer productId) {
		this.productId = productId;
	}

	public String getEntityType() {
		return entityType;
	}

	public void setEntityType(String entityType) {
		this.entityType = entityType;
	}

	public void restoreBean() {
		currentNode = productsSession.getProductAttributeCurrentNode();
		nodePath = productsSession.getProductAttributeNodePath();
		
		setInfo(true);
	}

	public String getProductsBackLink() {
		return productsBackLink;
	}

	public void setProductsBackLink(String productsBackLink) {
		this.productsBackLink = productsBackLink;
	}
	
	public Long getObjectId() {
		return objectId;
	}

	public void setObjectId(Long objectId) {
		this.objectId = objectId;
	}

	public Integer getServiceId() {
		return serviceId;
	}

	public void setServiceId(Integer serviceId) {
		this.serviceId = serviceId;
	}

	public String getProductType() {
		return productType;
	}

	public void setProductType(String productType) {
		this.productType = productType;
	}

	public boolean isProduct() {
		return EntityNames.PRODUCT.equals(entityType);
	}

	public boolean isService() {
		return EntityNames.SERVICE.equals(entityType);
	}

	public boolean isContract() {
		return EntityNames.CONTRACT.equals(entityType);
	}
	
	public boolean isObject() {
		return !EntityNames.PRODUCT.equals(entityType) && !EntityNames.SERVICE.equals(entityType)
				&& !EntityNames.CONTRACT.equals(entityType);
	}
	
	public String getAttrLevelMsg() {
		String msg = FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Prd", "attr_level_msg");
		if (getProductAttribute().isDefLevelObject()) {
			return FacesUtils.formatMessage(msg, FacesUtils.getMessage(
					"ru.bpc.sv2.ui.bundles.Common", "objects"));
		} else if (getProductAttribute().isDefLevelProduct()) {
			return FacesUtils.formatMessage(msg, FacesUtils.getMessage(
					"ru.bpc.sv2.ui.bundles.Prd", "products"));
		} else if (getProductAttribute().isDefLevelService()) {
			return FacesUtils.formatMessage(msg, FacesUtils.getMessage(
					"ru.bpc.sv2.ui.bundles.Prd", "services"));
		}
		return "";
	}

	public String getProductsModule() {
		return productsModule;
	}

	public void setProductsModule(String productsModule) {
		this.productsModule = productsModule;
	}

	public boolean isCurrentNodeContract() {
		ProductAttribute attr = getProductAttribute();
		return EntityNames.CONTRACT.equals(attr.getEntityType());
	}

	public List<ProductService> getServices() {
		return services;
	}
	public void setServices(List<ProductService> services) {
		this.services = services;
	}

	public boolean isCaching() {
		return caching;
	}
	public void setCaching(boolean caching) {
		this.caching = caching;
	}

	public List<ProductAttribute> getNodeList() {
		return coreItems;
	}
}
