package ru.bpc.sv2.ui.products;

import org.apache.commons.lang3.StringUtils;
import org.apache.log4j.Logger;
import org.openfaces.component.table.TreePath;
import org.openfaces.util.Faces;
import ru.bpc.sv2.application.Application;
import ru.bpc.sv2.common.FlexFieldData;
import ru.bpc.sv2.constants.DictNames;
import ru.bpc.sv2.constants.EntityNames;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.constants.SectionIdConstants;
import ru.bpc.sv2.constants.application.ApplicationConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.Filter.Operator;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.CommonDao;
import ru.bpc.sv2.logic.ProductsDao;
import ru.bpc.sv2.notes.ObjectNoteFilter;
import ru.bpc.sv2.products.Product;
import ru.bpc.sv2.products.ProductAccountType;
import ru.bpc.sv2.products.ProductConstants;
import ru.bpc.sv2.ui.acm.MbContextMenu;
import ru.bpc.sv2.ui.application.MbApplicationCreate;
import ru.bpc.sv2.ui.aup.MbAupSchemeObjects;
import ru.bpc.sv2.ui.common.flexible.MbFlexFieldsDataSearch;
import ru.bpc.sv2.ui.context.ContextType;
import ru.bpc.sv2.ui.context.ContextTypeFactory;
import ru.bpc.sv2.ui.issuing.MbProductCardTypesSearch;
import ru.bpc.sv2.ui.navigation.Menu;
import ru.bpc.sv2.ui.notes.MbNotesSearch;
import ru.bpc.sv2.ui.orgstruct.InstitutionConstants;
import ru.bpc.sv2.ui.utils.AbstractTreeBean;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.FilterFactory;
import util.auxil.ManagedBeanWrapper;

import javax.annotation.PostConstruct;

import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.event.ValueChangeEvent;
import javax.faces.model.SelectItem;
import java.util.*;

@ViewScoped
@ManagedBean (name = "MbProducts")
public class MbProducts extends AbstractTreeBean<Product> {
	private static final long serialVersionUID = 1L;

	private static final Logger logger = Logger.getLogger("PRODUCTS");

	private ProductsDao _productsDao = new ProductsDao();
	private CommonDao _commonDao = new CommonDao();

	private Product newNode;
	private Product detailNode;

	protected String productType;

	private ArrayList<SelectItem> institutions;

	protected String tabName;

	protected final String ACQUIRING = "acquiring";
	protected final String ISSUING = "issuing";
	protected final String INSTITUTION = "institution";
	private final String ACC_TYPE_TAB = "accountTypesTab";

	private Product filter;
	protected MbProductsSess productsSession;
	private boolean modalMode;

	protected HashMap<String, Boolean> loadedTabs = new HashMap<String, Boolean>();
	protected String needRerender;
	private List<String> rerenderList;
	private MbProductAccountType mbAccType;

	private HashMap<Long, Product> productsMap;
	private String oldLang;
	
	private ContextType ctxType;
	private String ctxItemEntityType;
	
	private String isspageLink = "issuing|products";
	private String acqpageLink = "acquiring|products";
	private String instpageLink = "orgStruct|products";
	
	private Long parentId;
	private List<SelectItem> parentList;
	
	public MbProducts() {
		tabName = "detailsTab";
		productType = getProductTypeFromRequest(null);

		productsSession = (MbProductsSess) ManagedBeanWrapper.getManagedBean("MbProductsSess");
		Menu menu = (Menu) ManagedBeanWrapper.getManagedBean("menu");

		// restore state
		if (menu.isKeepState()) {
			nodePath = productsSession.getProductNodePath();
			filter = productsSession.getProductFilter();
			tabName = productsSession.getProductTabName();
			if (nodePath != null) {
				currentNode = (Product) nodePath.getValue(); //productsSession.getProductCurrentNode();
				if (currentNode != null) {
					try {
						detailNode = (Product) currentNode.clone();
					} catch (CloneNotSupportedException e) {
						FacesUtils.addMessageError(e);
						logger.error("", e);
					}
				}
				productType = currentNode.getProductType();
				setInfo(true);
			}
			searching = true;

			// reset keep state flag
			menu.setKeepState(false);
		} else {
//			productType = FacesUtils.getRequestParameter("productType");
//			if (productType == null || productType.length() == 0) {
//				// if no product type defined set it to issuing products
//				productType = DictNames.ISSUING_PRODUCT;
//			}
			searching = false;

		}

		modalMode = true;
	}

    @PostConstruct
    public void initProductType() {
        if (isIssuingType()) {
            this.productType = ProductConstants.ISSUING_PRODUCT;
            thisBackLink = "issuing|products";
        } else if (isAcquiringType()) {
            this.productType = ProductConstants.ACQUIRING_PRODUCT;
            thisBackLink = "acquiring|products";
        } else {
            // it doesn't mean that inst products don't need type
            // it means that if type isn't set then we show inst
            // products
            this.productType = ProductConstants.INSTITUTION_PRODUCT;
            thisBackLink = "orgStruct|products";
            getFilter().setInstId(InstitutionConstants.UNDEFINED_INSTITUTION);
        }
    }

	public Product getNode() {
		if (currentNode == null) {
			currentNode = new Product();
		}
		return currentNode;
	}

	public void setNode(Product node) {
		try {
			curLang = userLang;
			if (node == null)
				return;
	
			boolean changeSelect = false;
			if (!node.getId().equals(getNode().getId())) {
				changeSelect = true;
			}
			
			this.currentNode = node;
			setInfo(false);
			storeParams();
			
			if (changeSelect) {
				detailNode = (Product) currentNode.clone();
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	/**
	 * Saves parameters in session to restore it when needed
	 */
	private void storeParams() {
		productsSession.setProductFilter(filter);
		productsSession.setProductTabName(tabName);
	}

	public TreePath getNodePath() {
		return nodePath;
	}

	public void setNodePath(TreePath nodePath) {
		this.nodePath = nodePath;
		productsSession.setProductNodePath(nodePath);
	}

	private Product getProduct() {
		return (Product) Faces.var("prod");
	}

	protected void loadTree() {
		try {
			coreItems = new ArrayList<Product>();
			if (searching) {
				setFilters(true);
				SelectionParams params = new SelectionParams(filters);
				params.setStartWith(getParentId());
				Product[] prods = _productsDao.getProducts(userSessionId, params);
				if (prods != null && prods.length > 0) {
					addNodes(0, coreItems, prods);
					if (nodePath == null) {
						if (currentNode == null) {
							currentNode = coreItems.get(0);
							detailNode = (Product) currentNode.clone();
							setNodePath(new TreePath(currentNode, null));
						} else {
							if (currentNode.getParentId() != null) {
								setNodePath(formNodePath(prods));
							} else {
								setNodePath(new TreePath(currentNode, null));
							}
						}
					}
					setInfo(false);
				}
				treeLoaded = true;
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public List<Product> getNodeChildren() {
		Product prod = getProduct();
		if (prod == null) {
			if (!treeLoaded || coreItems == null) {
				loadTree();
			}
			return coreItems;
		} else {
			return prod.getChildren();
		}
	}

	/**
	 * Sets filters for product search. If <code>applyAllFilters</code> set to
	 * true then all filters from search block will be applied along with
	 * language filter. Otherwise only language and institution filters will be
	 * used (this can be useful when one need to show list of all products on
	 * the same page where product filtering is used).
	 * 
	 * @param applyAllFilters
	 */
	public void setFilters(boolean applyAllFilters) {
		filters = new ArrayList<Filter>();
		filters.add(Filter.create("lang", userLang));

		if (getFilter().getId() != null) {
			filters.add(Filter.create("id", getFilter().getId()));
		}
		if (getFilter().getInstId() != null) {
			filters.add(Filter.create("instId", getFilter().getInstId()));
		}
		if (getFilter().getContractType() != null) {
			filters.add(Filter.create("contractType", getFilter().getContractType()));
		}
		if (productType != null) {
			filters.add(Filter.create("productType", productType));
		}

		if (applyAllFilters) {
			if (StringUtils.isNotBlank(getFilter().getName())) {
				filters.add(Filter.create("name", Operator.like, Filter.mask(filter.getName())));
			}
			if (StringUtils.isNotBlank(getFilter().getStatus())) {
				filters.add(Filter.create("status", getFilter().getStatus()));
			}
			if (StringUtils.isNotBlank(getFilter().getProductNumber())) {
				filters.add(Filter.create("productNumber", Operator.like, Filter.mask(filter.getProductNumber())));
			}
		}
	}

	private void setInfo(boolean restoreState) {
		loadedTabs.clear();
		loadTab(getTabName(), restoreState);
	}

	public boolean getNodeHasChildren() {
		return getProduct() != null && getProduct().isHasChildren();
	}

	public ArrayList<SelectItem> getInstitutions() {
		if (institutions == null) {
			institutions = (ArrayList<SelectItem>) getDictUtils().getLov(LovConstants.INSTITUTIONS);
		}
		if (institutions == null)
			institutions = new ArrayList<SelectItem>();
		return institutions;
	}

	public void addApplication() {
		Application newApplication = new Application();
		if ("issuing|products".equals(thisBackLink)) {
			newApplication.setAppType(ApplicationConstants.TYPE_ISS_PRODUCT);
		} else if ("acquiring|products".equals(thisBackLink)) {
			newApplication.setAppType(ApplicationConstants.TYPE_ACQ_PRODUCT);
		} else {
			newApplication.setAppType(ApplicationConstants.TYPE_PRODUCT);
		}
		newApplication.setInstId(userInstId);
		MbApplicationCreate appCreate = ManagedBeanWrapper.getManagedBean("MbApplicationCreate");
		appCreate.clear();
		appCreate.setThisBackLink(thisBackLink);
		appCreate.setAppType(newApplication.getAppType());
		appCreate.setNewApplication(newApplication);
		appCreate.onInstitutionChanged();
		appCreate.setNewContract(true);
		appCreate.setDisableContractType(false);
		appCreate.updateContractTypes();
	}

	public void addProduct() {
		curMode = NEW_MODE;
		newNode = new Product();
		if (filter.getInstId() != null) {
			newNode.setInstId(filter.getInstId());
		}
		newNode.setLang(userLang);
		curLang = newNode.getLang();
		newNode.setProductType(productType);
		if (currentNode != null){
			newNode.setParentId(currentNode.getId());
			newNode.setContractType(currentNode.getContractType());
			newNode.setInstId(currentNode.getInstId());
		}
	}

	public void editProduct() {
		curMode = EDIT_MODE;
		newNode = new Product();
		copyProduct(detailNode, newNode);
	}

	/**
	 * Copies properties that are changed during product edit
	 * 
	 * @param from
	 *            - product which properties are copied
	 * @param to
	 *            - product where properties are copied to
	 */
	private void copyProduct(Product from, Product to) {
		to.setId(from.getId());
		to.setInstId(from.getInstId());
		to.setParentId(from.getParentId());
		to.setProductType(from.getProductType());
		to.setName(from.getName());
		to.setDescription(from.getDescription());
		to.setLang(from.getLang());
		to.setSeqNum(from.getSeqNum());
		to.setStatus(from.getStatus());
		to.setContractType(from.getContractType());
        to.setProductNumber(from.getProductNumber());
//    	to.setChildren(from.getChildren());
//    	to.setIsLeaf(from.getIsLeaf());
//    	to.setLevel(from.getLevel());
	}

	public void save() {
		try {
			if (isNewMode()) {
				newNode = _productsDao.addProduct(userSessionId, newNode);
				detailNode = (Product) newNode.clone();
				addElementToTree(newNode);
			} else {
				newNode = _productsDao.modifyProduct(userSessionId, newNode);
				detailNode = (Product) newNode.clone();
				if (!userLang.equals(newNode.getLang())) {
					newNode = getNodeByLang(currentNode.getId(), userLang);
				}
				replaceCurrentNode(newNode);
			}
			setInfo(false);
			curMode = VIEW_MODE;
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void cancel() {
		curMode = VIEW_MODE;
	}

	public void deleteProduct() {
		try {
			_productsDao.removeProduct(userSessionId, currentNode);
			curMode = VIEW_MODE;
			FacesUtils
					.addMessageInfo("Product (id = " + currentNode.getId() + " has been deleted!");
			deleteNodeFromTree(currentNode, coreItems);
			currentNode = null;
			clearBeansStates();
			if (coreItems.size() > 0) {
				currentNode = coreItems.get(0);
				detailNode = (Product) currentNode.clone();
				setNodePath(new TreePath(currentNode, null));
				setInfo(false);
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void search() {
		curMode = VIEW_MODE;
		nodePath = null;
		currentNode = null;
		searching = true;
		clearBeansStates();
		loadTree();
	}

	public void clearFilter() {
		curMode = VIEW_MODE;
		currentNode = null;
		detailNode = null;
		nodePath = null;
		treeLoaded = false;
		searching = false;
		filter = null;
		
		clearBeansStates();
	}

	public List<SelectItem> getProducts() {
		try {
			Map<String, Object> paramMap = new HashMap<String, Object>();
			if (getNewNode().getInstId()!=null) {
				paramMap.put("INSTITUTION_ID", getNewNode().getInstId().toString());
			}
			if (isIssuingType()){
				return getDictUtils().getLov(LovConstants.ISSUING_PRODUCTS, paramMap);
			}else if(isAcquiringType()){
				return getDictUtils().getLov(LovConstants.ACQUIRING_PRODUCTS, paramMap);
			}else{
				return getDictUtils().getLov(LovConstants.INSTITUTION_PRODUCTS, paramMap);
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
		return new ArrayList<SelectItem>();
	}
	
	public void updateParentList(){
			try {
				Map<String, Object> paramMap = new HashMap<String, Object>();
				if (getFilter().getInstId() != null) {
					paramMap.put("INSTITUTION_ID", getFilter().getInstId());
				}
				if (isIssuingType()){
					parentList = getDictUtils().getLov(LovConstants.ISSUING_PRODUCTS, paramMap);
				}else if(isAcquiringType()){
					parentList = getDictUtils().getLov(LovConstants.ACQUIRING_PRODUCTS, paramMap);
				}else{
					parentList = getDictUtils().getLov(LovConstants.INSTITUTION_PRODUCTS, paramMap);
				}
			} catch (Exception e) {
				FacesUtils.addMessageError(e);
				logger.error("", e);
			}
	}
	
	public List<SelectItem> getProductsFilter() {
			if (parentList==null){
				updateParentList();
			}
			return parentList;
	}
	
	public Product getNewNode() {
		if (newNode == null) {
			newNode = new Product();
		}
		return newNode;
	}

	public void setNewNode(Product newNode) {
		this.newNode = newNode;
	}

	public void clearBeansStates() {
		MbObjectAttributes attrs = (MbObjectAttributes) ManagedBeanWrapper
				.getManagedBean("MbObjectAttributes");
		attrs.fullCleanBean();

		MbNotesSearch notesSearch = (MbNotesSearch) ManagedBeanWrapper
				.getManagedBean("MbNotesSearch");
		notesSearch.clearFilter();

		MbProductCardTypesSearch cardTypesSearch = (MbProductCardTypesSearch) ManagedBeanWrapper
				.getManagedBean("MbProductCardTypesSearch");
		cardTypesSearch.clearState();
		cardTypesSearch.setFilter(null);
		cardTypesSearch.setSearching(false);

		MbAupSchemeObjects schemeBean = (MbAupSchemeObjects) ManagedBeanWrapper
				.getManagedBean("MbAupSchemeObjects");
		schemeBean.fullCleanBean();

		MbProductServices pServices = (MbProductServices) ManagedBeanWrapper
				.getManagedBean("MbProductServices");
		pServices.fullCleanBean();
		mbAccType = (MbProductAccountType) 
				ManagedBeanWrapper.getManagedBean("MbProductAccountType");
		mbAccType.clearFilter();
		clearLoadedTabs();
		
		MbFlexFieldsDataSearch flexible = (MbFlexFieldsDataSearch) ManagedBeanWrapper
				.getManagedBean("MbFlexFieldsDataSearch");
		flexible.clearFilter();
	}

	public Product getRefreshedProduct() {
		List<Filter> filtersList = new ArrayList<Filter>();

		Filter paramFilter = new Filter();
		paramFilter.setElement("id");
		paramFilter.setOp(Operator.eq);
		paramFilter.setValue(currentNode.getId().toString());
		filtersList.add(paramFilter);

		paramFilter = new Filter();
		paramFilter.setElement("lang");
		paramFilter.setOp(Operator.eq);
		paramFilter.setValue(curLang);
		filtersList.add(paramFilter);

		filters = filtersList;
		SelectionParams params = new SelectionParams();
		params.setFilters(filters.toArray(new Filter[filters.size()]));
		try {
			Product[] products = _productsDao.getProductsList(userSessionId, params);
			if (products != null && products.length > 0) {
				return products[0];
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
		return new Product();
	}

	public void changeLanguage(ValueChangeEvent event) {
		curLang = (String) event.getNewValue();
		detailNode = getNodeByLang(detailNode.getId(), curLang);
	}
	
	public Product getNodeByLang(Long id, String lang) {
		List<Filter> filtersList = new ArrayList<Filter>();

		Filter paramFilter = new Filter();
		paramFilter.setElement("id");
		paramFilter.setOp(Operator.eq);
		paramFilter.setValue(id.toString());
		filtersList.add(paramFilter);

		paramFilter = new Filter();
		paramFilter.setElement("lang");
		paramFilter.setOp(Operator.eq);
		paramFilter.setValue(lang);
		filtersList.add(paramFilter);

		filters = filtersList;
		SelectionParams params = new SelectionParams();
		params.setFilters(filters.toArray(new Filter[filters.size()]));
		try {
			Product[] products = _productsDao.getProductsList(userSessionId, params);
			if (products != null && products.length > 0) {
				return products[0];
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
		return null;
	}

	public ArrayList<SelectItem> getProductStatuses() {
		return getDictUtils().getArticles(DictNames.PRODUCT_STATUSES, false, false);
	}

	public Product getFilter() {
		if (Boolean.TRUE.equals(FacesUtils.getSessionMapValue("initFromContext"))) {
			initFilterFromContext();
			FacesUtils.setSessionMapValue("initFromContext", null);
			search();
		}
		if (filter == null) {
			filter = new Product();
			filter.setInstId(userInstId);
		}
		return filter;
	}
	
	private void initFilterFromContext() {
		filter = new Product();

		if (FacesUtils.getSessionMapValue("id") != null) {
			filter.setId(((Integer) FacesUtils.getSessionMapValue("id")).longValue());
			FacesUtils.setSessionMapValue("id", null);
		}
		if (FacesUtils.getSessionMapValue("instId") != null) {
			filter.setInstId((Integer) FacesUtils.getSessionMapValue("instId"));
			FacesUtils.setSessionMapValue("instId", null);
		}
		if (FacesUtils.getSessionMapValue("contractType") != null) {
			filter.setContractType((String) FacesUtils.getSessionMapValue("contractType"));
			FacesUtils.setSessionMapValue("contractType", null);
		}
		if (FacesUtils.getSessionMapValue("objectType") != null) {
			productType = (String) FacesUtils.getSessionMapValue("objectType");
			filter.setProductType((String) FacesUtils.getSessionMapValue("objectType"));
			FacesUtils.setSessionMapValue("objectType", null);
		}
		if (FacesUtils.getSessionMapValue("productName") != null) {
			filter.setName((String) FacesUtils.getSessionMapValue("productName"));
			FacesUtils.setSessionMapValue("productName", null);
		}
		if (FacesUtils.getSessionMapValue("productNumber") != null) {
			filter.setProductNumber((String) FacesUtils.getSessionMapValue("productNumber"));
			FacesUtils.setSessionMapValue("productNumber", null);
		}
	}

	public boolean isModalMode() {
		return modalMode;
	}

	public void setModalMode(boolean modalMode) {
		this.modalMode = modalMode;
	}

	public String getProductType() {
		return productType;
	}

	/**
	 * <p>Gets and sets (if needed) actual product type if user moved from one 
	 * product form to another because there are possible situations when user
	 * changed form (e.g. moved from acquiring products to issuing) but the 
	 * bean wasn't destroyed and product type remained the same. One needs to 
	 * read this parameter from form by placing hidden input on its top.</p>   
	 * @return
	 */
	public String getProductTypeHidden() {
		Menu menu = (Menu) ManagedBeanWrapper.getManagedBean("menu");
		if (this.productType == null || menu.isClicked()) {
			String productType = getProductTypeFromRequest(null);
			if (!productType.equals(this.productType)) {
				// if it's another product form then we need to clear all form's data
				clearFilter();
			}
			this.productType = productType;
		}
		return productType;
	}
	
	private String getProductTypeFromRequest(String type) {
		if (StringUtils.isBlank(type)) {
			type = FacesUtils.getRequestParameter("productType");
		}
		if (ISSUING.equals(type) || ProductConstants.ISSUING_PRODUCT.equals(type)) {
			thisBackLink = "issuing|products";
			return ProductConstants.ISSUING_PRODUCT;
		} else if (ACQUIRING.equals(type) || ProductConstants.ACQUIRING_PRODUCT.equals(type)) {
			thisBackLink = "acquiring|products";
			return ProductConstants.ACQUIRING_PRODUCT;
		} else {
			if (FacesUtils.getSessionMapValue("productType") != null) {
				String newType = (String)FacesUtils.getSessionMapValue("productType");
				FacesUtils.setSessionMapValue("productType", null);
				return getProductTypeFromRequest(newType);
			} else {
				thisBackLink = "orgStruct|products";
				return ProductConstants.INSTITUTION_PRODUCT;
			}
		}
	}

	public void setProductType(String productType) {
        this.productType = productType;
	}

	public String getPageName() {
		if (isIssuingType()) {
			pageName = FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Rul", "issuing_products");
		} else if (isAcquiringType()) {
			pageName = FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Rul", "acquiring_products");
		} else {
			pageName = FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Prd", "products");
		}
		return pageName;
	}

	public boolean isIssuingType() {
		return ProductConstants.ISSUING_PRODUCT.equals(productType);
	}

	public boolean isAcquiringType() {
		return ProductConstants.ACQUIRING_PRODUCT.equals(productType);
	}

	public boolean isInstitutionType() {
		return ProductConstants.INSTITUTION_PRODUCT.equals(productType);
	}

	public Comparator<Object> getNameComparator() {
		return new Comparator<Object>() {
			@Override
			public int compare(Object o10, Object o20) {
			  if (o10 instanceof String && o20 instanceof String){
				String o1=(String)o10;
				String o2=(String)o20;
				if (o1 == null || o1.equals(""))
					return -1;
				if (o2 == null || o2.equals(""))
					return 1;
				return o1.toUpperCase().compareTo(o2.toUpperCase());
			  }
			  if (o10 instanceof Long && o20 instanceof Long){
					Long o1=(Long)o10;
					Long o2=(Long)o20;
					if (o1 == null)
						return -1;
					if (o2 == null)
						return 1;
					return o1.compareTo(o2);
				  }
			return 0;
			}
		};
	}

	public String getTabName() {
		return tabName;
	}

	public void setTabName(String tabName) {
		needRerender = null;
		productsSession.setProductTabName(tabName);
		this.tabName = tabName;

		Boolean isLoadedCurrentTab = loadedTabs.get(tabName);

		if (isLoadedCurrentTab == null) {
			isLoadedCurrentTab = Boolean.FALSE;
		}

		if (isLoadedCurrentTab.equals(Boolean.TRUE)) {
			return;
		}

		loadTab(tabName, false);
		
		if (tabName.equalsIgnoreCase("attributesTab")) {
			MbAttributeValues attrValueBean = (MbAttributeValues) ManagedBeanWrapper
					.getManagedBean("MbAttributeValues");
			attrValueBean.setTabName(tabName);
			attrValueBean.setParentSectionId(getSectionId());
			attrValueBean.setTableState(getSateFromDB(attrValueBean.getComponentId()));
		} else if (tabName.equalsIgnoreCase("cardTypesTab")) {
			MbProductCardTypesSearch bean = (MbProductCardTypesSearch) ManagedBeanWrapper
					.getManagedBean("MbProductCardTypesSearch");
			bean.setTabName(tabName);
			bean.setParentSectionId(getSectionId());
			bean.setTableState(getSateFromDB(bean.getComponentId()));
		} else if (tabName.equalsIgnoreCase("notesTab")) {
			MbNotesSearch bean = (MbNotesSearch) ManagedBeanWrapper
					.getManagedBean("MbNotesSearch");
			bean.setTabName(tabName);
			bean.setParentSectionId(getSectionId());
			bean.setTableState(getSateFromDB(bean.getComponentId()));
		} else if (tabName.equalsIgnoreCase("schemesTab")) {
			MbAupSchemeObjects bean = (MbAupSchemeObjects) ManagedBeanWrapper
					.getManagedBean("MbAupSchemeObjects");
			bean.setTabName(tabName);
			bean.setParentSectionId(getSectionId());
			bean.setTableState(getSateFromDB(bean.getComponentId()));
		} else if (tabName.equalsIgnoreCase("accountTypesTab")) {
			MbProductAccountType bean = (MbProductAccountType) ManagedBeanWrapper
					.getManagedBean("MbProductAccountType");
			bean.setTabName(tabName);
			bean.setParentSectionId(getSectionId());
			bean.setTableState(getSateFromDB(bean.getComponentId()));
		} else if (tabName.equalsIgnoreCase("flexibleFieldsTab")) {
			MbFlexFieldsDataSearch bean = (MbFlexFieldsDataSearch) ManagedBeanWrapper
					.getManagedBean("MbFlexFieldsDataSearch");
			bean.setTabName(tabName);
			bean.setParentSectionId(getSectionId());
			bean.setTableState(getSateFromDB(bean.getComponentId()));
			
		}
	}
	
	public String getSectionId() {
		String productType = FacesUtils.getRequestParameter("productType");
		if (ISSUING.equals(productType)) {
			return SectionIdConstants.ISSUING_CONFIG_PRODUCT;
		} else {
			return SectionIdConstants.ACQUIRING_CONFIG_PRODUCT;
		}
	}

	private void loadTab(String tab, boolean restoreState) {
		if (tab == null)
			return;
		if (currentNode == null || currentNode.getId() == null)
			return;

		if (tab.equalsIgnoreCase("ATTRIBUTESTAB")) {
			MbObjectAttributes attrs = (MbObjectAttributes) ManagedBeanWrapper
					.getManagedBean("MbObjectAttributes");
			attrs.fullCleanBean();
			//attrs.setObjectId(currentNode.getId().longValue());		// TODO: don't need it anymore
			attrs.setProductId(currentNode.getId().intValue()); // Product's ID is actually an integer
			attrs.setEntityType(EntityNames.PRODUCT);
			attrs.setProductType(currentNode.getProductType());
			attrs.setInstId(currentNode.getInstId());
			attrs.setProductsBackLink(thisBackLink);
			attrs.setProductsModule(isAcquiringType() ? ACQUIRING : (isIssuingType() ? ISSUING
					: (isInstitutionType() ? INSTITUTION : "")));
			if (restoreState) {
				attrs.restoreBean();
			}
		} else if (tab.equalsIgnoreCase("servicesTab")) {
			MbProductServices pServices = (MbProductServices) ManagedBeanWrapper
					.getManagedBean("MbProductServices");
			pServices.fullCleanBean();
			pServices.setProductType(currentNode.getProductType());
			pServices.setInstId(currentNode.getInstId());
			pServices.setChild(currentNode.getParentId() != null);
			pServices.getFilter().setProductId(currentNode.getId().intValue());  // Product's ID is actually an integer
			pServices.getFilter().setProductName(currentNode.getName());
			pServices.search();
		} else if (tab.equalsIgnoreCase("NOTESTAB")) {
			MbNotesSearch notesSearch = (MbNotesSearch) ManagedBeanWrapper
					.getManagedBean("MbNotesSearch");
			ObjectNoteFilter filterNote = new ObjectNoteFilter();
			filterNote.setEntityType(EntityNames.PRODUCT);
			filterNote.setObjectId(currentNode.getId().longValue());
			notesSearch.setFilter(filterNote);
			notesSearch.search();
		} else if (tab.equalsIgnoreCase("CARDTYPESTAB")) {
			MbProductCardTypesSearch cardTypesSearch = (MbProductCardTypesSearch) ManagedBeanWrapper
					.getManagedBean("MbProductCardTypesSearch");
			cardTypesSearch.fullCleanBean();
			cardTypesSearch.getFilter().setProductId(currentNode.getId().intValue());  // Product's ID is actually an integer
			cardTypesSearch.setInstId(currentNode.getInstId());
			cardTypesSearch.search();
		} else if (tab.equalsIgnoreCase("SCHEMESTAB")) {
			MbAupSchemeObjects schemeBean = (MbAupSchemeObjects) ManagedBeanWrapper
					.getManagedBean("MbAupSchemeObjects");
			schemeBean.setObjectId(currentNode.getId().longValue());
			schemeBean.setInstId(currentNode.getInstId());
			schemeBean.setDefaultEntityType(EntityNames.PRODUCT);
			schemeBean.search();
		} else if (tab.equals(ACC_TYPE_TAB)){
			mbAccType = (MbProductAccountType) 
					ManagedBeanWrapper.getManagedBean("MbProductAccountType");
			ProductAccountType accType = new ProductAccountType();
			accType.setProductId(currentNode.getId().intValue());  // Product's ID is actually an integer
			
			if (productType.equalsIgnoreCase(ProductConstants.ACQUIRING_PRODUCT)){
				mbAccType.setProductType(0);
			}else if(productType.equalsIgnoreCase(ProductConstants.ISSUING_PRODUCT)){
				mbAccType.setProductType(1);
			}else{
				mbAccType.setProductType(2);
			}
			mbAccType.setFilter(accType);
			mbAccType.setProductId(currentNode.getId().intValue());  // Product's ID is actually an integer
			mbAccType.setProdName(currentNode.getName());
			
			mbAccType.search();
			
		} else if (tab.equalsIgnoreCase("FLEXIBLEFIELDSTAB")) {
			// get flexible data for this institution
			MbFlexFieldsDataSearch flexible = (MbFlexFieldsDataSearch) ManagedBeanWrapper
					.getManagedBean("MbFlexFieldsDataSearch");
			FlexFieldData filterFlex = new FlexFieldData();
			filterFlex.setInstId(currentNode.getInstId());
			filterFlex.setEntityType(EntityNames.PRODUCT);
			filterFlex.setObjectId(currentNode.getId().longValue());
			flexible.setFilter(filterFlex);
			flexible.search();
		}
		needRerender = tab;
		loadedTabs.put(tab, Boolean.TRUE);
	}

	public List<String> getRerenderList() {
		rerenderList = new ArrayList<String>();
		rerenderList.clear();
		if (needRerender != null) {
			rerenderList.add(needRerender);
		}
		rerenderList.add("err_ajax");
		return rerenderList;
	}

	public HashMap<String, Boolean> getLoadedTabs() {
		return loadedTabs;
	}

	public void clearLoadedTabs() {
		loadedTabs.clear();
	}

	public List<SelectItem> getContractTypes() {
		Map<String, Object> paramMap = new HashMap<String, Object>();
		if (isAcquiringType()) {
			paramMap.put("PRODUCT_TYPE", ProductConstants.ACQUIRING_PRODUCT);
		} else if (isIssuingType()) {
			paramMap.put("PRODUCT_TYPE", ProductConstants.ISSUING_PRODUCT);
		} else if (isInstitutionType()) {
			paramMap.put("PRODUCT_TYPE", ProductConstants.INSTITUTION_PRODUCT);
		} else {
			return new ArrayList<SelectItem>(0);
		}

		return getDictUtils().getLov(LovConstants.PRODUCT_CONTRACT_TYPES, paramMap);
	}

	public void changeParentProduct(ValueChangeEvent event) {
		Long newParentId = (Long) event.getNewValue();
		if (newParentId != null) {
            Product product = getProductById(newParentId.intValue());
            if (product != null)
			    newNode.setContractType(product.getContractType());
		}
	}

    private Product getProductById(Integer id){
        Product product = null;
        try {
            product = _productsDao.getProductById(userSessionId, id, getUserLang());
        } catch (Exception e) {
            FacesUtils.addMessageError(e);
            logger.error("", e);
        }
        return product;
    }

	public void editLanguage(ValueChangeEvent event) {
		oldLang = (String) event.getOldValue();
	}

	public void confirmEditLanguage() {
		curLang = newNode.getLang();
		Product tmp = getNodeByLang(newNode.getId(), newNode.getLang());
		if (tmp != null) {
			newNode.setName(tmp.getName());
			newNode.setDescription(tmp.getDescription());
		}
	}

	public void cancelEditLanguage() {
		newNode.setLang(oldLang);
	}

	public Product getDetailNode() {
		return detailNode;
	}

	public void setDetailNode(Product detailNode) {
		this.detailNode = detailNode;
	}
	
	public String getCtxItemEntityType() {
		return ctxItemEntityType;
	}

	public void setCtxItemEntityType() {
		MbContextMenu ctxBean = (MbContextMenu) ManagedBeanWrapper.getManagedBean("MbContextMenu");
		String ctx = ctxBean.getEntityType();
		if (ctxType == null || !ctx.equals(this.ctxItemEntityType)){
			ctxType = ContextTypeFactory.getInstance(ctx);
		}
		this.ctxItemEntityType = ctx;
	}
	
	public ContextType getCtxType(){
		if (ctxType == null) return null;
		Map <String, Object> map = new HashMap<String, Object>();
		List<String> urls = new ArrayList<String>();
		urls.add("acquiring|products");
		urls.add("orgStruct|products");
		urls.add("issuing|products");
		
		map.put("selfUrl", urls);
		
		if (EntityNames.INSTITUTION.equals(ctxItemEntityType)) {
			 if (currentNode != null) {
				 map.put("id", currentNode.getInstId());
				 map.put("instId", currentNode.getInstId());
				 
			 }
		}
		
		if (EntityNames.PRODUCT.equals(ctxItemEntityType)) {
			 if (currentNode != null) {
				map.put("id", currentNode.getId().intValue());
				map.put("instId", currentNode.getInstId());
				map.put("objectType", currentNode.getProductType());
				map.put("productType", currentNode.getProductType());
				map.put("productName", currentNode.getName());
				map.put("productNumber", currentNode.getProductNumber());
			 }
		}
		
		ctxType.setParams(map);
		return ctxType;
	}
	
	public boolean isForward(){
		return !ctxItemEntityType.equals(EntityNames.PRODUCT);
	}

	public Long getParentId() {
		return parentId;
	}

	public void setParentId(Long parentId) {
		this.parentId = parentId;
	}

	@Override
	protected void applySectionFilter(Integer filterId) {
		try {
			FilterFactory factory = (FilterFactory) ManagedBeanWrapper
					.getManagedBean("filterFactory");
			Map<String, String> filterRec = factory.getSectionFilterRecs(filterId);
			sectionFilter = factory.getUserSectionFiltersObjects().get(filterId);
			if (filterRec != null) {
				filter = new Product();
				if (filterRec.get("instId") != null) {
					filter.setInstId(Integer.parseInt(filterRec.get("instId")));
				}
				if (filterRec.get("status") != null) {
					filter.setStatus(filterRec.get("status"));
				}
				if (filterRec.get("name") != null) {
					filter.setName(filterRec.get("name"));
				}
				if (filterRec.get("contractType") != null) {
					filter.setContractType(filterRec.get("contractType"));
				}
				if (filterRec.get("parentId") != null) {
					setParentId(Long.parseLong(filterRec.get("parentId")));
				}
				if (filterRec.get("productNumber") != null) {
					filter.setProductNumber(filterRec.get("productNumber"));
				}
			}
			if (searchAutomatically) {
				search();
			}
			sectionFilterModeEdit = true;
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	@Override
	public void saveSectionFilter() {
		try {
			FilterFactory factory = (FilterFactory) ManagedBeanWrapper
					.getManagedBean("filterFactory");

			Map<String, String> filterRec = new HashMap<String, String>();
			filter = getFilter();
			if (filter.getInstId() != null) {
				filterRec.put("instId", filter.getInstId().toString());
			}
			if (filter.getName() != null) {
				filterRec.put("status", filter.getStatus());
			}
			if (filter.getName() != null) {
				filterRec.put("name", filter.getName());
			}
			if (filter.getContractType() != null) {
				filterRec.put("contractType", filter.getContractType());
			}
			if (getParentId() != null) {
				filterRec.put("parentId", getParentId().toString());
			}
			if (filter.getProductNumber() != null) {
				filterRec.put("productNumber", filter.getProductNumber());
			}
			sectionFilter = getSectionFilter();
			sectionFilter.setRecs(filterRec);

			factory.saveSectionFilter(sectionFilter, sectionFilterModeEdit);
			selectedSectionFilter = sectionFilter.getId();
			sectionFilterModeEdit = true;
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}
}
