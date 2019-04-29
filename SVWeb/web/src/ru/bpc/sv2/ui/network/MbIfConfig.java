package ru.bpc.sv2.ui.network;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;


import ru.bpc.sv2.logic.CommunicationDao;
import ru.bpc.sv2.logic.utility.db.DataAccessException;
import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.model.SelectItem;

import org.apache.log4j.Logger;
import org.openfaces.component.table.TreePath;
import org.openfaces.util.Faces;

import ru.bpc.sv2.cmn.ObjectStandardVersion;
import ru.bpc.sv2.constants.EntityNames;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.ui.cmn.MbCmnParamValues;
import ru.bpc.sv2.ui.utils.AbstractTreeBean;
import ru.bpc.sv2.ui.utils.FacesUtils;
import util.auxil.ManagedBeanWrapper;

@ViewScoped
@ManagedBean (name = "MbIfConfig")
public class MbIfConfig extends AbstractTreeBean<ObjectStandardVersion> {
	private static final Logger logger = Logger.getLogger("COMMUNICATION");

	private CommunicationDao _cmnDao = new CommunicationDao();

	

	private ObjectStandardVersion standardFilter;
	private ObjectStandardVersion newNode;

	private Long paramObjectId;
	private Long valuesObjectId;
	private Integer standardId;
	private String paramEntityType;
	private String valuesEntityType;
	private String pageTitle;
	private boolean hideVersions;
	
	private String backLink;
	
	public MbIfConfig(){
		restoreFilter();
	}

	private void restoreFilter(){
		HashMap<String,Object> queueFilter = getQueueFilter("MbIfConfig");

		if (queueFilter==null)
			return;
		
		fullCleanBean();
		
		curMode = VIEW_MODE;
		setSearching(true);
		
		if (queueFilter.containsKey("backLink")){
			setBackLink((String)queueFilter.get("backLink"));
		}
		if (queueFilter.containsKey("valuesObjectId")){
			setValuesObjectId((Long)queueFilter.get("valuesObjectId"));
		}
		if (queueFilter.containsKey("valuesEntityType")){
			setValuesEntityType((String)queueFilter.get("valuesEntityType"));
		}
		if (queueFilter.containsKey("standardId")){
			setStandardId((Integer)queueFilter.get("standardId"));
		}
		if (queueFilter.containsKey("paramObjectId")){
			setParamObjectId((Long)queueFilter.get("paramObjectId"));
		}
		if (queueFilter.containsKey("paramEntityType")){
			setParamEntityType((String)queueFilter.get("paramEntityType"));
		}
		if (queueFilter.containsKey("pageTitle")){
			setPageTitle((String)queueFilter.get("pageTitle"));
		}
		if (queueFilter.containsKey("directAccess")){
			setDirectAccess(((String)queueFilter.get("directAccess")).equals("true"));
		}
		if (queueFilter.containsKey("hideVersions")){
			setHideVersions(((String)queueFilter.get("hideVersions")).equals("true"));
		}
	}

	public ObjectStandardVersion getNode() {
		return currentNode;
	}

	public void setNode(ObjectStandardVersion node) {
		if (node == null)
			return;

		this.currentNode = node;
		setBeans();
	}

	public void search() {
		curMode = VIEW_MODE;
		setSearching(true);
		clearBean();
		loadTree();
	}

	public void clearFilter() {
		clearBean();
		standardFilter = new ObjectStandardVersion();
		searching = false;
	}

	public void clearBean() {
		currentNode = null;
		nodePath = null;
		coreItems = null;
		treeLoaded = false;
		curLang = userLang;

		clearBeansStates();
	}

	public void fullCleanBean() {
		paramObjectId = null;
		valuesObjectId = null;
		standardId = null;
		paramEntityType = null;
		valuesEntityType = null;
		clearFilter();
	}

	public void setFilters() {
		standardFilter = getFilter();

		filters = new ArrayList<Filter>();

		Filter paramFilter = new Filter();
		paramFilter.setElement("lang");
		paramFilter.setValue(userLang);
		filters.add(paramFilter);

		paramFilter = new Filter();
		paramFilter.setElement("entityType");
		paramFilter.setValue(paramEntityType);
		filters.add(paramFilter);

		paramFilter = new Filter();
		paramFilter.setElement("objectId");
		paramFilter.setValue(paramObjectId);
		filters.add(paramFilter);

		if (standardId != null) {
			paramFilter = new Filter();
			paramFilter.setElement("standardId");
			paramFilter.setValue(standardId);
			filters.add(paramFilter);
		}
	}

	protected void loadTree() {
		try {
			coreItems = new ArrayList<ObjectStandardVersion>();
			if (!searching)
				return;

			setFilters();
			SelectionParams params = new SelectionParams();
			params.setFilters(filters.toArray(new Filter[filters.size()]));
			ObjectStandardVersion[] items = _cmnDao.getObjectStandardVersionsTree(userSessionId,
					params);
			if (items != null && items.length > 0) {
				addNodes(0, coreItems, items);
				if (nodePath == null) {
					if (currentNode == null) {
						currentNode = coreItems.get(0);
						setNodePath(new TreePath(currentNode, null));
					} else {
						if (currentNode.getParentId() != null) {
							setNodePath(formNodePath(items));
						} else {
							setNodePath(new TreePath(currentNode, null));
						}
					}
					setBeans();
				}
			}
			if (currentNode != null && !coreItems.contains(currentNode)) {
				// when bean state was restored in constructor and selected node 
				// doesn't correspond to filter conditions we should add it to 
				// list manually 
				coreItems.add(currentNode);
			}
			if (hideVersions) {
				for (ObjectStandardVersion item: coreItems) {
					item.setChildren(null);
				}
			}
			treeLoaded = true;
		} catch (DataAccessException ee) {
			FacesUtils.addMessageError(ee);
			logger.error("", ee);
		}
	}

	public List<ObjectStandardVersion> getNodeChildren() {
		ObjectStandardVersion node = getStandard();
		if (node == null) {
			if (!treeLoaded || coreItems == null) {
				loadTree();
			}
			return coreItems;
		} else {
			return node.getChildren();
		}
	}

	private ObjectStandardVersion getStandard() {
		return (ObjectStandardVersion) Faces.var("stdVer");
	}

	public boolean getNodeHasChildren() {
		ObjectStandardVersion node = getStandard();
		return (node != null) && node.isHasChildren();
	}

	public TreePath getNodePath() {
		return nodePath;
	}

	public void setNodePath(TreePath nodePath) {
		this.nodePath = nodePath;
	}

	public ObjectStandardVersion getNewNode() {
		if (newNode == null) {
			newNode = new ObjectStandardVersion();
		}
		return newNode;
	}

	public void setNewNode(ObjectStandardVersion newNode) {
		this.newNode = newNode;
	}

	public void add() {
		newNode = new ObjectStandardVersion();
		newNode.setEntityType(paramEntityType);
		newNode.setObjectId(paramObjectId);
		newNode.setLang(userLang);
		curMode = NEW_MODE;
	}

	public void edit() {
		try {
			newNode = (ObjectStandardVersion) currentNode.clone();
		} catch (CloneNotSupportedException e) {
			newNode = currentNode;
		}
		curMode = EDIT_MODE;
	}

	public void delete() {
		try {
			_cmnDao.deleteObjectStandardVersion(userSessionId, currentNode.getId());

			deleteNodeFromTree(currentNode, coreItems);
			currentNode = null;
			clearBeansStates();
			if (coreItems.size() > 0) {
				currentNode = coreItems.get(0);
				setNodePath(new TreePath(currentNode, null));
				setBeans();
			}
		} catch (Exception e) {
			logger.error(e.getMessage(), e);
			FacesUtils.addMessageError(e);
		}
	}

	public void save() {
		try {
			if (isNewMode()) {
				newNode = _cmnDao.addObjectStandardVersion(userSessionId, newNode);
				addElementToTree(newNode);
			} else {
				newNode = _cmnDao.editObjectStandardVersion(userSessionId, newNode);
				replaceCurrentNode(newNode);
			}

			setBeans();
			curMode = VIEW_MODE;
		} catch (Exception e) {
			logger.error(e.getMessage(), e);
			FacesUtils.addMessageError(e);
		}
	}

	public void cancel() {
		curMode = VIEW_MODE;
	}

	/**
	 * Sets data for backing beans used by dependent pages
	 */
	public void setBeans() {
		MbCmnParamValues values = (MbCmnParamValues) ManagedBeanWrapper
				.getManagedBean("MbCmnParamValues");
		values.fullCleanBean();
		
		if (currentNode == null) {
			return;
		}
		if (currentNode.getVersionId() == null) {
			values.setParamLevel(EntityNames.STANDARD);
		} else {
			values.setParamLevel(EntityNames.STANDARD_VERSION);
			values.setVersionId(currentNode.getVersionId());
		}
		values.setStandardId(currentNode.getStandardId());
		values.setValuesEntityType(valuesEntityType);
		values.setParamEntityType(paramEntityType);
		values.setObjectId(valuesObjectId);
		values.search();
	}

	public ObjectStandardVersion getFilter() {
		if (standardFilter == null) {
			standardFilter = new ObjectStandardVersion();
		}
		return standardFilter;
	}

	public void setFilter(ObjectStandardVersion standardFilter) {
		this.standardFilter = standardFilter;
	}

	public String goBack() {
		FacesUtils.setSessionMapValue(backLink, Boolean.TRUE);

		MbHosts hosts = (MbHosts) ManagedBeanWrapper.getManagedBean("MbHosts");

		// if there's smth left in bread crumbs then previous page wasn't accessed directly
		if (removeLastPageFromRoute() > 0) {
			hosts.setDirectAccess(false);
		}

		return backLink;
	}

	private void clearBeansStates() {
	}

	public List<SelectItem> getVersions() {
		if (currentNode == null || currentNode.getStandardId() == null) {
			return new ArrayList<SelectItem>(0);
		}
		Map<String, Object> params = new HashMap<String, Object>(1);
		params.put("STANDARD_ID", currentNode.getStandardId());

		return getDictUtils().getLov(LovConstants.STANDARD_VERSIONS, params);
	}

	public Long getParamObjectId() {
		return paramObjectId;
	}

	public void setParamObjectId(Long paramObjectId) {
		this.paramObjectId = paramObjectId;
	}

	public Long getValuesObjectId() {
		return valuesObjectId;
	}

	public void setValuesObjectId(Long valuesObjectId) {
		this.valuesObjectId = valuesObjectId;
	}

	public Integer getStandardId() {
		return standardId;
	}

	public void setStandardId(Integer standardId) {
		this.standardId = standardId;
	}

	public String getParamEntityType() {
		return paramEntityType;
	}

	public void setParamEntityType(String paramEntityType) {
		this.paramEntityType = paramEntityType;
	}

	public String getValuesEntityType() {
		return valuesEntityType;
	}

	public void setValuesEntityType(String valuesEntityType) {
		this.valuesEntityType = valuesEntityType;
	}

	public String getPageTitle() {
		return pageTitle;
	}

	public void setPageTitle(String pageTitle) {
		this.pageTitle = pageTitle;
	}

	public String getBackLink() {
		return backLink;
	}

	public void setBackLink(String backLink) {
		this.backLink = backLink;
	}

	public boolean isHideVersions() {
		return hideVersions;
	}

	public void setHideVersions(boolean hideVersions) {
		this.hideVersions = hideVersions;
	}

//	public List<SelectItem> getVersions() {
//		if (currentNode != null && currentNode.getStandardId() != null) {
//			Filter[] filters = new Filter[2];
//			filters[0] = new Filter();
//			filters[0].setElement("lang");
//			filters[0].setValue(curLang);
//			filters[1] = new Filter();
//			filters[1].setElement("standardId");
//			filters[1].setValue(currentNode.getStandardId());
//			
//			SelectionParams params = new SelectionParams();
//			params.setFilters(filters);
//			params.setRowIndexEnd(Integer.MAX_VALUE);
//			try {
//				CmnVersion[] versions = _cmnDao.getCmnVersions(userSessionId, params);
//				ArrayList<SelectItem> items = new ArrayList<SelectItem>(versions.length);
//				for (CmnVersion version: versions) {
//					items.add(new SelectItem(version.getId(), version.getVersionNumber()));
//				}
//				return items;
//			} catch (Exception e) {
//				logger.error("", e);
//				FacesUtils.addMessageError(e);
//			}
//		}
//		return new ArrayList<SelectItem>(0);
//	}
	
	public String gotoInterfacesConfig() {
		
		HashMap<String,Object> queueFilter = new HashMap<String,Object>();		
		queueFilter.put("standardId", currentNode.getStandardId());
		queueFilter.put("paramObjectId", currentNode.getObjectId());
		queueFilter.put("paramEntityType", currentNode.getEntityType());
		queueFilter.put("backLink", backLink);
		queueFilter.put("valuesEntityType", valuesEntityType);
		queueFilter.put("valuesObjectId", valuesObjectId);
		addFilterToQueue("MbIfConfig", queueFilter);
		
		return "ifConfig";
	}
}
