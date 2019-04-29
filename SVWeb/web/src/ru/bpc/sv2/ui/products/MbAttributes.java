package ru.bpc.sv2.ui.products;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.event.ValueChangeEvent;
import javax.faces.model.SelectItem;

import org.apache.log4j.Logger;
import org.openfaces.component.table.TreePath;
import org.openfaces.util.Faces;

import ru.bpc.sv2.constants.DataTypes;
import ru.bpc.sv2.constants.DictNames;
import ru.bpc.sv2.constants.EntityNames;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.constants.SectionIdConstants;
import ru.bpc.sv2.constants.SystemConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.Filter.Operator;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.ProductsDao;
import ru.bpc.sv2.products.Attribute;
import ru.bpc.sv2.products.ServiceType;
import ru.bpc.sv2.ui.fcl.fees.MbFeeRates;
import ru.bpc.sv2.ui.fcl.limits.MbLimitRates;
import ru.bpc.sv2.ui.utils.AbstractTreeBean;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.FilterFactory;
import util.auxil.ManagedBeanWrapper;

@ViewScoped
@ManagedBean(name = "MbAttributes")
public class MbAttributes extends AbstractTreeBean<Attribute> {
	private static final long serialVersionUID = 7357517063212923059L;
	private static final Logger logger = Logger.getLogger("PRODUCTS");

	private ProductsDao _productsDao = new ProductsDao();

	private Attribute newNode;
	private Attribute detailNode;
	private Attribute filter;

	private String productsBackLink;
	private String tabName;
	private String serviceEntityType;

	private List<SelectItem> institutions;
	private List<SelectItem> serviceType = null;
	private List<SelectItem> postingMethods;
	private List<SelectItem> counterAlgorithms;
	private List<SelectItem> moduleCodes;
	private List<SelectItem> dataTypes;
    private List<SelectItem> limitUsages;

	private boolean disableServiceType = false;
	private boolean disableBottom = true;
	private boolean bottomMode = false;

	public MbAttributes() {
		pageLink = "services|attributes";
		coreItems = new ArrayList<Attribute>();
	}

	public Attribute getNode() {
		return currentNode;
	}

	public void setNode(Attribute node) {
		try {
			if (node == null)
				return;
	
			boolean changeSelect = false;
			if (!node.getId().equals(currentNode.getId())) {
				changeSelect = true;
			}
			
			this.currentNode = node;
			if (!bottomMode) {
				setBeans();
			}
			
			if (changeSelect) {
				detailNode = (Attribute) currentNode.clone();
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public TreePath getNodePath() {
		return nodePath;
	}

	public void setNodePath(TreePath nodePath) {
		this.nodePath = nodePath;
	}

	private Attribute getAttribute() {
		return (Attribute) Faces.var("prodAttr");
	}

	protected void loadTree() {
		if (!searching)
			return;

		try {
			setFilters();
			SelectionParams params = new SelectionParams(filters);
			coreItems = new ArrayList<Attribute>();
			List<Attribute> attrs = _productsDao.getAttributesHier(userSessionId, params);

			if (attrs != null && !attrs.isEmpty()) {
				Attribute[] attributes = attrs.toArray(new Attribute[attrs.size()]);
				addNodes(0, coreItems, attributes);
				if (currentNode == null) {
					currentNode = coreItems.get(0);
					detailNode = (Attribute) currentNode.clone();
					setNodePath(new TreePath(currentNode, null));
				} else {
					if (currentNode.getParentId() != null) {
						setNodePath(formNodePath(attributes));
					} else {
						setNodePath(new TreePath(currentNode, null));
					}
				}
				setBeans();
			}
			treeLoaded = true;
		} catch (Exception ee) {
			FacesUtils.addMessageError(ee);
			logger.error("", ee);
		}
	}

	public void setFilters() {
		filters = new ArrayList<Filter>();
		filters.add(Filter.create("lang", userLang));

		if (getFilter().getId() != null) {
			filters.add(Filter.create("id", filter.getId().toString()));
		}
		if (serviceEntityType != null) {
			filters.add(Filter.create("serviceEntityType", serviceEntityType));
		}
		if (filter.getServiceTypeId() != null) {
			filters.add(Filter.create("serviceTypeId", filter.getServiceTypeId().toString()));
		}
		if (filter.getEntityType() != null) {
			if (filter.getEntityType().startsWith(DictNames.DATA_TYPE)) {
				filters.add(Filter.create("dataType", filter.getEntityType()));
				filters.add(Filter.create("entityType", null));
			} else {
				filters.add(Filter.create("entityType", filter.getEntityType()));
			}
		}
		if (filter.getDefinitionLevel() != null) {
			filters.add(Filter.create("defLevel", filter.getDefinitionLevel()));
		}
	}

	public List<Attribute> getNodeChildren() {
		Attribute attr = getAttribute();
		if (attr == null) {
			if (!treeLoaded || coreItems == null) {
				loadTree();
			}
			return coreItems;
		} else {
			return attr.getChildren();
		}
	}

	private void setBeans() {
		MbAttrScales attrScales = (MbAttrScales) ManagedBeanWrapper.getManagedBean("MbAttrScales");
		attrScales.fullCleanBean();
		attrScales.setAttrId(currentNode.getId().intValue());	// attribute's id is actually Integer
		attrScales.setAttrName(currentNode.getAttributeName());

		MbFeeRates feeRates = (MbFeeRates) ManagedBeanWrapper.getManagedBean("MbFeeRates");
		feeRates.fullCleanBean();
		if (EntityNames.FEE.equals(currentNode.getEntityType())) {
			feeRates.setFeeType(currentNode.getObjectType());
			feeRates.search();
		}

		MbLimitRates limitRates = (MbLimitRates) ManagedBeanWrapper.getManagedBean("MbLimitRates");
		limitRates.fullCleanBean();
		if (EntityNames.LIMIT.equals(currentNode.getEntityType())) {
			limitRates.setLimitType(currentNode.getObjectType());
			limitRates.search();
		}
	}

	public boolean getNodeHasChildren() {
		return getAttribute() != null && getAttribute().isHasChildren();
	}

	/**
	 * Clears bean's attributes and loads new tree
	 */
	public void search() {
		curMode = VIEW_MODE;
		clearBean();
		loadTree();
		searching = true;
	}

	public void clearFilter() {
		curMode = VIEW_MODE;
		clearBean();
		filter = null;
		searching = false;

		MbAttrScales attrScales = (MbAttrScales) ManagedBeanWrapper.getManagedBean("MbAttrScales");
		attrScales.clearBean();
	}

	public void add() {
		newNode = new Attribute();
		newNode.setLang(userLang);
		curLang = newNode.getLang();

		if (currentNode != null) {
			if (EntityNames.ATTRIBUTE_GROUP.equals(currentNode.getEntityType())) {
				newNode.setParentId(currentNode.getId());
			} else {
				newNode.setParentId(currentNode.getParentId());
			}
			newNode.setServiceTypeId(currentNode.getServiceTypeId());
		} else if (getFilter().getServiceTypeId() != null) {
			newNode.setServiceTypeId(filter.getServiceTypeId());
		}
		curMode = NEW_MODE;
	}

	public void edit() {
		if (isServiceType()) {
			FacesUtils.addMessageError(new Exception(FacesUtils.getMessage(
					"ru.bpc.sv2.ui.bundles.Prd", "service_term_is_immutable")));
			return;
		}
		try {
			newNode = (Attribute) detailNode.clone();
		} catch (CloneNotSupportedException e) {
			logger.error("", e);
			newNode = currentNode;
		}

		if (newNode.getEntityType() == null) {
			newNode.setEntityType(currentNode.getDataType());
		}
		curMode = EDIT_MODE;
	}

	public void save() {
		if (newNode.getEntityType().startsWith(DictNames.DATA_TYPE)) {
			newNode.setDataType(newNode.getEntityType());
			newNode.setEntityType(null);
		}
		if (EntityNames.ATTRIBUTE_GROUP.equals(newNode.getEntityType())) {
			newNode.setDefinitionLevel(null);
		}
		try {
			if (isNewMode()) {
				newNode = _productsDao.addAttribute(userSessionId, newNode);
				detailNode = (Attribute) newNode.clone();
				addElementToTree(newNode);
			} else {
				newNode = _productsDao.modifyAttribute(userSessionId, newNode);
				detailNode = (Attribute) newNode.clone();
				if (!userLang.equals(newNode.getLang())) {
					newNode = getNodeByLang(currentNode.getId(), userLang);
				}
				replaceCurrentNode(newNode);
			}
			if (newNode.getEntityType() != null) {
				getDictUtils().flush();
			}
			setBeans();
			curMode = VIEW_MODE;
			FacesUtils.addMessageInfo(FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Rul", "attr_saved"));
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void delete() {
		if (isServiceType()) {
			FacesUtils.addMessageError(new Exception(FacesUtils.getMessage(
					"ru.bpc.sv2.ui.bundles.Prd", "service_term_is_immutable")));
			return;
		}
		try {
			_productsDao.removeAttribute(userSessionId, currentNode.getId());
			FacesUtils.addMessageInfo(FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Rul",
					"attr_deleted", "(id = " + currentNode.getId() + ")"));
			deleteNodeFromTree(currentNode, coreItems);
			currentNode = null;
			detailNode = null;
			if (coreItems.size() > 0) {
				currentNode = coreItems.get(0);
				setNodePath(new TreePath(currentNode, null));
				setBeans();
				detailNode = (Attribute) currentNode.clone();
			}
			curMode = VIEW_MODE;
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void cancel() {
		curMode = VIEW_MODE;
	}

	public Attribute getNewNode() {
		return newNode;
	}

	public void setNewNode(Attribute newNode) {
		this.newNode = newNode;
	}

	public void clearBean() {
		currentNode = null;
		detailNode = null;
		nodePath = null;
		coreItems = null;
		treeLoaded = false;
		curLang = userLang;
		serviceType = null;
	}

	public void setFilter(Attribute filter) {
		this.filter = filter;
	}

	public Attribute getFilter() {
		if (filter == null) {
			filter = new Attribute();
		}
		return filter;
	}

	public void restoreBean() {
//		currentNode = productsSession.getAttributeCurrentNode();
//		nodePath = productsSession.getAttributeNodePath();

		setBeans();
	}

	public String getProductsBackLink() {
		return productsBackLink;
	}

	public void setProductsBackLink(String productsBackLink) {
		this.productsBackLink = productsBackLink;
	}

//	public ArrayList<SelectItem> getAttributeItems() {
//		ArrayList<SelectItem>  items;
//		try {
//    		setFilters();
//    		
//    		SelectionParams params = new SelectionParams();
//    		params.setFilters(filters.toArray(new Filter[filters.size()]));
//        	Attribute[] attrs = _productsDao.getAttributesHier( userSessionId, params);
//        	
//			items = new ArrayList<SelectItem>(attrs.length + 1);
//			items.add(new SelectItem(""));
//			for (Attribute attr: attrs) {
//				String dashes = "";
//				for (int i = 0; i < (attr.getLevel() - 1) * 3; i++) {
//					dashes += "-";
//				}
//				items.add(new SelectItem(attr.getId().toString(), dashes + attr.getShortDesc()));
//			}
//		} catch (Exception e) {
//			FacesUtils.addMessageError(e);
//			logger.error("",e);
//			items = new ArrayList<SelectItem> (0); 
//		}
//		
//		return items;
//	}

	public List<SelectItem> getDataTypes() {
		if (dataTypes == null) {
			dataTypes = (List<SelectItem>) getDictUtils().getLov(LovConstants.DATA_TYPES);
			if (dataTypes == null) {
				dataTypes = new ArrayList<SelectItem>();
			}
		}
		return dataTypes;
	}

	public List<SelectItem> getLovs() {
		if (getNewNode().getEntityType() == null 
				|| !getNewNode().getEntityType().startsWith(DictNames.DATA_TYPE)) {
			return new ArrayList<SelectItem>(0);
		}

		Map<String, Object> params = new HashMap<String, Object>(1);
		params.put("DATA_TYPE", getNewNode().getEntityType());
		
		return getDictUtils().getLov(LovConstants.LOVS_LOV, params);
	}

	public List<SelectItem> getAttributeTypes() {
		List<SelectItem> types = getDictUtils().getLov(LovConstants.ATTRIBUTE_TYPES);
		ArrayList<SelectItem> simpleTypes = new ArrayList<SelectItem>();
		ArrayList<SelectItem> complexTypes = new ArrayList<SelectItem>();
		for (SelectItem type: types) {
			if (type.getValue() instanceof String
					&& ((String) type.getValue()).startsWith(DictNames.DATA_TYPE)) {
				simpleTypes.add(type);
			} else {
				complexTypes.add(type);
			}
		}

		ArrayList<SelectItem> result = new ArrayList<SelectItem>();
		result.add(new SelectItem("", "-- " + FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Common", "simple_types"),
				"", true));
		result.addAll(simpleTypes);
		result.add(new SelectItem("", "-- " + FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Common", "complex_types"),
				"", true));
		result.addAll(complexTypes);

		return result;
	}
	
	public List<SelectItem> getServices() {
		if (serviceType == null){
			 serviceType = getDictUtils().getLov(LovConstants.SERVICE_TYPE);
		}
		
		return serviceType;
	}

	public ArrayList<SelectItem> getAttributeGroups() {
		ArrayList<SelectItem> items = null;
		try {
			ArrayList<Filter> filters = new ArrayList<Filter>();
			Filter paramFilter = new Filter();
			paramFilter.setElement("lang");
			paramFilter.setValue(curLang);
			filters.add(paramFilter);
			if (serviceEntityType != null) {
				paramFilter = new Filter();
				paramFilter.setElement("serviceEntityType");
				paramFilter.setValue(serviceEntityType);
				filters.add(paramFilter);
			} else if (getFilter().getServiceTypeId() != null) {
				paramFilter = new Filter();
				paramFilter.setElement("serviceTypeId");
				paramFilter.setValue(filter.getServiceTypeId().toString());
				filters.add(paramFilter);
			} else if (newNode != null && newNode.getServiceTypeId() != null) {
				paramFilter = new Filter();
				paramFilter.setElement("serviceTypeId");
				paramFilter.setValue(newNode.getServiceTypeId().toString());
				filters.add(paramFilter);
			}
			SelectionParams params = new SelectionParams();
			params.setFilters((Filter[]) filters.toArray(new Filter[filters.size()]));
			params.setRowIndexEnd(Integer.MAX_VALUE);

			Attribute[] groups = _productsDao.getAttrGroups(userSessionId, params);
			items = new ArrayList<SelectItem>();
			ArrayList<Long> excludeNodeIds = new ArrayList<Long>();
			if (isEditMode()) {
				excludeNodeIds.add(currentNode.getId());
			}
			for (Attribute group: groups) {
				if (isEditMode()) {
					boolean excludeNode = false;
					for (Long excludeNodeId: excludeNodeIds) {
						if (excludeNodeId.equals(group.getId())
								|| excludeNodeId.equals(group.getParentId())) {
							excludeNodeIds.add(group.getId());
							excludeNode = true; // exclude group (if it's the same as current) from list of parents to avoid loops
							break;
						}
					}
					if (excludeNode)
						continue;
				}
				items.add(new SelectItem(group.getId(), group.getLabel()));
			}
		} catch (Exception e) {
			logger.error("", e);
			if (e.getMessage().indexOf(SystemConstants.INSUFFICIENT_PRIVILEGES_ERROR) < 0) {
				FacesUtils.addMessageError(e);
			}
			items = new ArrayList<SelectItem>(0);
		}
		return items;
	}

	public List<SelectItem> getInstitutions() {
		if (institutions == null) {
			institutions = (List<SelectItem>) getDictUtils().getLov(LovConstants.INSTITUTIONS_SYS);
			if (institutions == null) {
				institutions = new ArrayList<SelectItem>();
			}
		}
		return institutions;
	}

    public List<SelectItem> getLimitUsages() {
        if (limitUsages == null){
            limitUsages = getDictUtils().getLov(LovConstants.LIMIT_USAGES);
        }
        return limitUsages;
    }

	public void changeLanguage(ValueChangeEvent event) {
		curLang = (String) event.getNewValue();
		detailNode = getNodeByLang(detailNode.getId(), curLang);
	}
	
	public Attribute getNodeByLang(Long id, String lang) {
		Filter[] filters = new Filter[2];
		filters[0] = new Filter();
		filters[0].setElement("id");
		filters[0].setValue(id + "");
		filters[1] = new Filter();
		filters[1].setElement("lang");
		filters[1].setValue(lang);
		SelectionParams params = new SelectionParams();
		params.setFilters(filters);
		try {
			Attribute[] attrs = _productsDao.getAttributes(userSessionId, params);
			if (attrs != null && attrs.length > 0) {
				return attrs[0];
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		} 
		return null;
	}

	public boolean isNewFee() {
		return newNode != null ? EntityNames.FEE.equals(newNode.getEntityType()) : false;
	}

	public boolean isNewLimit() {
		return newNode != null ? EntityNames.LIMIT.equals(newNode.getEntityType()) : false;
	}

	public boolean isNewCycle() {
		return newNode != null ? EntityNames.CYCLE.equals(newNode.getEntityType()) : false;
	}
	
	public boolean isLovAppliable() {
		return newNode != null && newNode.getEntityType() != null ? (newNode.getEntityType()
				.startsWith(DictNames.DATA_TYPE) && !newNode.getEntityType().equals(DataTypes.DATE))
				: false;
	}

	public boolean isCurrentFee() {
		return currentNode != null ? EntityNames.FEE.equals(currentNode.getEntityType()) : false;
	}

	public boolean isCurrentLimit() {
		return currentNode != null ? EntityNames.LIMIT.equals(currentNode.getEntityType()) : false;
	}

	public boolean isCurrentAttrGroup() {
		return currentNode != null ? EntityNames.ATTRIBUTE_GROUP
				.equals(currentNode.getEntityType()) : false;
	}

	public String getTabName() {
		return tabName;
	}

	public void setTabName(String tabName) {
		this.tabName = tabName;
		
		if (tabName.equalsIgnoreCase("attrScalesTab")) {
			MbAttrScales bean = (MbAttrScales) ManagedBeanWrapper
					.getManagedBean("MbAttrScales");
			bean.setTabName(tabName);
			bean.setParentSectionId(getSectionId());
			bean.setTableState(getSateFromDB(bean.getComponentId()));
		} else if (tabName.equalsIgnoreCase("feeRatesTab")) {
			MbFeeRates bean = (MbFeeRates) ManagedBeanWrapper
					.getManagedBean("MbFeeRates");
			bean.setTabName(tabName);
			bean.setParentSectionId(getSectionId());
			bean.setTableState(getSateFromDB(bean.getComponentId()));
		} else if (tabName.equalsIgnoreCase("limitRatesTab")) {
			MbLimitRates bean = (MbLimitRates) ManagedBeanWrapper
					.getManagedBean("MbLimitRates");
			bean.setTabName(tabName);
			bean.setParentSectionId(getSectionId());
			bean.setTableState(getSateFromDB(bean.getComponentId()));
		}
	}
	
	public String getSectionId() {
		return SectionIdConstants.CONFIGURATION_SERVICING_TERM;
	}

	public ArrayList<SelectItem> getDefLevels() {
		return getDictUtils().getArticles(DictNames.DEFINITION_LEVEL, false);
	}

	public ArrayList<SelectItem> getServiceTypes() {
		ArrayList<SelectItem> result = null;

		Filter[] filters = new Filter[1];
		filters[0] = new Filter();
		filters[0].setElement("lang");
		filters[0].setValue(curLang);

		SelectionParams params = new SelectionParams();
		params.setFilters(filters);
		params.setRowIndexEnd(Integer.MAX_VALUE);
		try {
			ServiceType[] types = _productsDao.getServiceTypes(userSessionId, params);
			result = new ArrayList<SelectItem>(types.length);
			for (ServiceType type: types) {
				result.add(new SelectItem(type.getId(), type.getLabel()));
			}
		} catch (Exception e) {
			logger.error(e);
			if (e.getMessage().indexOf(SystemConstants.INSUFFICIENT_PRIVILEGES_ERROR) < 0) {
				FacesUtils.addMessageError(e);
			}
			result = new ArrayList<SelectItem>(0);
		}

		return result;
	}

	public boolean isDisableServiceType() {
		return disableServiceType;
	}

	public void setDisableServiceType(boolean disableServiceType) {
		this.disableServiceType = disableServiceType;
	}

	public boolean isDisableBottom() {
		return disableBottom;
	}

	public void setDisableBottom(boolean disableBottom) {
		this.disableBottom = disableBottom;
	}

	public String getServiceEntityType() {
		return serviceEntityType;
	}

	public void setServiceEntityType(String serviceEntityType) {
		this.serviceEntityType = serviceEntityType;
	}

	public boolean isServiceType() {
		return currentNode != null ? EntityNames.SERVICE_TYPE.equals(currentNode.getEntityType())
				: false;
	}

	public boolean isNewAttrGroup() {
		return newNode != null ? EntityNames.ATTRIBUTE_GROUP.equals(newNode.getEntityType())
				: false;
	}

	public boolean isBottomMode() {
		return bottomMode;
	}

	public void setBottomMode(boolean bottomMode) {
		this.bottomMode = bottomMode;
	}

	public void changeUseLimit(ValueChangeEvent event) {
		boolean useLimit = (Boolean) event.getNewValue();
		if (!useLimit) {
			newNode.setCyclicLimit(false);
		}
	}

	public void confirmEditLanguage() {
		curLang = newNode.getLang();
		Attribute tmp = getNodeByLang(newNode.getId(), newNode.getLang());
		if (tmp != null) {
			newNode.setLabel(tmp.getLabel());
			newNode.setDescription(tmp.getDescription());
		}
	}

	public Attribute getDetailNode() {
		return detailNode;
	}

	public void setDetailNode(Attribute detailNode) {
		this.detailNode = detailNode;
	}
	
	public List<SelectItem> getCycleCalcDateTypes() {
		return getDictUtils().getLov(LovConstants.CYCLE_CALC_DATE_TYPES);
	}
	
	public List<SelectItem> getCycleCalcStartDates() {
		return getDictUtils().getLov(LovConstants.CYCLE_CALC_START_DATES);
	}
	
	public List<SelectItem> getPostMethods() {
		if (postingMethods == null) {
			postingMethods = getDictUtils().getLov(LovConstants.POSTING_METHODS);
		}
		return postingMethods;
	}
	
	public List<SelectItem> getCounterAlgorithms(){
		if (counterAlgorithms == null){
			counterAlgorithms = getDictUtils().getLov(LovConstants.COUNTER_ALGORITHM);
		}
		return counterAlgorithms;
	}

	@Override
	protected void applySectionFilter(Integer filterId) {
		try {
			FilterFactory factory = (FilterFactory) ManagedBeanWrapper
					.getManagedBean("filterFactory");
			Map<String, String> filterRec = factory.getSectionFilterRecs(filterId);
			sectionFilter = factory.getUserSectionFiltersObjects().get(filterId);
			if (filterRec != null) {
				filter = new Attribute();
				if (filterRec.get("entityType") != null) {
					filter.setEntityType(filterRec.get("entityType"));
				}
				if (filterRec.get("definitionLevel") != null) {
					filter.setDefinitionLevel(filterRec.get("definitionLevel"));
				}
				if (filterRec.get("serviceTypeId") != null) {
					filter.setServiceTypeId(Integer.parseInt(filterRec.get("serviceTypeId")));
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
			if (filter.getEntityType() != null) {
				filterRec.put("entityType", filter.getEntityType());
			}
			if (filter.getDefinitionLevel() != null) {
				filterRec.put("definitionLevel", filter.getDefinitionLevel());
			}
			if (filter.getServiceTypeId() != null) {
				filterRec.put("serviceTypeId", filter.getServiceTypeId().toString());
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

	public List<SelectItem> getModuleCodes() {
		if (moduleCodes == null) {
			moduleCodes = (ArrayList<SelectItem>) getDictUtils().getLov(LovConstants.MODULE_CODE);
			if (moduleCodes == null) {
				moduleCodes = new ArrayList<SelectItem>();
			}
		}
		return moduleCodes;
	}
}
