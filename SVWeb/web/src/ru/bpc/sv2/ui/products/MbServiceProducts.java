package ru.bpc.sv2.ui.products;

import java.util.ArrayList;
import java.util.List;


import ru.bpc.sv2.logic.ProductsDao;
import ru.bpc.sv2.logic.utility.db.DataAccessException;
import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.model.SelectItem;

import org.apache.log4j.Logger;
import org.openfaces.component.table.TreePath;
import org.openfaces.util.Faces;

import ru.bpc.sv2.constants.DictNames;
import ru.bpc.sv2.constants.SystemConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.invocation.SortElement;
import ru.bpc.sv2.invocation.SortElement.Direction;
import ru.bpc.sv2.products.Product;
import ru.bpc.sv2.products.ProductService;
import ru.bpc.sv2.ui.utils.AbstractTreeBean;
import ru.bpc.sv2.ui.utils.FacesUtils;

@ViewScoped
@ManagedBean (name = "MbServiceProducts")
public class MbServiceProducts extends AbstractTreeBean<ProductService> {
	private static final long serialVersionUID = 2510308907051938909L;

	private static final Logger logger = Logger.getLogger("PRODUCTS");

	private ProductsDao _productsDao = new ProductsDao();

	private ProductService filter;
	private ProductService newNode;

	private final String SERVICE_STATUS_INACTIVE;

	private Integer serviceTypeId;
	private String serviceStatus;
	private String productType;
	private Integer instId;
	private boolean serviceInitiating;
	
	public MbServiceProducts() {
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

		SortElement[] sorts = new SortElement[1];
		sorts[0] = new SortElement("productName", Direction.ASC);
		
		SelectionParams params = new SelectionParams();
		params.setFilters(filters.toArray(new Filter[filters.size()]));
		params.setSortElement(sorts);
		try {
			ProductService[] services = _productsDao.getServiceProductsHier(userSessionId, params);
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

	/**
	 * Sets data for backing beans used by dependent pages
	 */
	public void setBeans() {

	}

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
			paramFilter.setValue(filter.getServiceId());
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
		serviceTypeId = null;
		serviceStatus = null;
		serviceInitiating = false;
		productType = null;
	}

	public void add() {
		newNode = new ProductService();
		newNode.setServiceId(filter.getServiceId());
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
				// don't add it to list, better to refresh whole table to see 
				// all products to which this service has been applied
				currentNode = newNode;
				loadTree();
			} else {
				newNode = _productsDao.editProductService(userSessionId,
						newNode, curLang);
				replaceNode(currentNode, newNode, coreItems);
				currentNode = newNode;
				setBeans();
			}
			curMode = VIEW_MODE;

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

	public ArrayList<SelectItem> getProducts() {
		ArrayList<SelectItem> result = null;

		if (instId == null || serviceTypeId == null) {
			return new ArrayList<SelectItem>(0);
		}

		Filter[] filters = new Filter[4];
		filters[0] = new Filter();
		filters[0].setElement("lang");
		filters[0].setValue(curLang);
		filters[1] = new Filter();
		filters[1].setElement("instId");
		filters[1].setValue(instId);
		filters[2] = new Filter();
		filters[2].setElement("serviceTypeId");
		filters[2].setValue(serviceTypeId);
		filters[3] = new Filter();
		filters[3].setElement("parentIsNull");
		filters[3].setValue(1);

		SelectionParams params = new SelectionParams();
		params.setRowIndexEnd(Integer.MAX_VALUE);
		params.setFilters(filters);
		try {
			Product[] products = _productsDao.getProductsList(userSessionId, params);
			result = new ArrayList<SelectItem>(products.length);
			for (Product service : products) {
				String name = service.getName(); 
    			for (int i = 1; i < service.getLevel();i++) {
    				name = " -- " + name;
    			}
				result.add(new SelectItem(service.getId(), service.getId() + " - " + name));
			}
		} catch (Exception e) {
			logger.error("", e);
			if (e.getMessage().indexOf(SystemConstants.INSUFFICIENT_PRIVILEGES_ERROR) < 0) {
				FacesUtils.addMessageError(e);
			}
			result = new ArrayList<SelectItem>(0);
		}

		return result;
	}

	public ArrayList<SelectItem> getParentServices() {
		if (getNewNode().getProductId() != null) {
			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("lang");
			filters[0].setValue(curLang);
			filters[1] = new Filter();
			filters[1].setElement("productId");
			filters[1].setValue(newNode.getProductId());
			
			SelectionParams params = new SelectionParams();
			params.setRowIndexEnd(Integer.MAX_VALUE);
			params.setFilters(filters);
			try {
				ProductService[] services = _productsDao.getProductServices(userSessionId, params);
				ArrayList<SelectItem> result = new ArrayList<SelectItem>(services.length);
				for (ProductService service : services) {
					result.add(new SelectItem(service.getId(), service.getServiceName()));
				}
				return result;
			} catch (Exception e) {
				logger.error("", e);
				if (e.getMessage().indexOf(SystemConstants.INSUFFICIENT_PRIVILEGES_ERROR) < 0) {
					FacesUtils.addMessageError(e);
				}
			}
		}
		return new ArrayList<SelectItem>(0);
	}

	public Integer getServiceTypeId() {
		return serviceTypeId;
	}

	public void setServiceTypeId(Integer serviceTypeId) {
		this.serviceTypeId = serviceTypeId;
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

	public boolean isServiceInitiating() {
		return serviceInitiating;
	}

	public void setServiceInitiating(boolean serviceInitiating) {
		this.serviceInitiating = serviceInitiating;
	}
}
