package ru.bpc.sv2.ui.emv;

import java.util.ArrayList;
import java.util.List;


import ru.bpc.sv2.logic.utility.db.DataAccessException;
import javax.faces.bean.ManagedBean;
import javax.faces.bean.RequestScoped;
import javax.faces.model.SelectItem;

import org.ajax4jsf.model.KeepAlive;
import org.apache.log4j.Logger;
import org.openfaces.component.table.TreePath;
import org.openfaces.util.Faces;

import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.emv.EmvElement;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.EmvDao;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.AbstractTreeBean;
import ru.bpc.sv2.ui.utils.FacesUtils;

@RequestScoped
@KeepAlive
@ManagedBean(name = "MbEmvElement")
public class MbEmvElement extends AbstractTreeBean<EmvElement> {

	private static final Logger logger = Logger.getLogger("EMV");
	
	private EmvDao emvDao = new EmvDao();

	

	private EmvElement activeItem;
	private Integer objectId;
	private EmvElement editingItem;
	private String entityType; 

	private Integer parentItemId;
	private List<SelectItem> topLevelItems = new ArrayList<SelectItem>();

	private List<SelectItem> profileList = null;
	
	public MbEmvElement() {
		
	}

	public List<EmvElement> getElementNodeChildren() {
		EmvElement node = getElementNode();
		if (node == null) {
			if (coreItems == null){
				loadTree();
			}
			return coreItems;
		} else {
			return node.getChildren();
		}
	}
	
	private EmvElement getElementNode() {
		return (EmvElement) Faces.var("elementNode");
	}

	public boolean getElementNodeHasChildren() {
		return (getElementNode() != null) && getElementNode().isHasChildren();
	}

	public EmvElement getActiveItem() {
		return activeItem;
	}

	public void setActiveItem(EmvElement activeItem) {
		this.activeItem = activeItem;
	}

	public void createElement() {
		setEditingItem(new EmvElement());
		getEditingItem().setEntityType(entityType);
		getEditingItem().setObjectId(objectId);
		curMode = AbstractBean.NEW_MODE;
	}

	public void editActiveElement() {
		setEditingItem((EmvElement) activeItem.clone());
		curMode = AbstractBean.EDIT_MODE;
	}

	public void saveEditingElement() {
		try {
			if (isNewMode()) {
				setEditingItem(emvDao.createElement(userSessionId, getEditingItem()));
			} else if (isEditMode()) {
				setEditingItem(emvDao.modifyElement(userSessionId, getEditingItem()));
			}
		} catch (DataAccessException e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
			resetEditingElement();
			return;
		}		
		if (isNewMode()) {
			addElement(getEditingItem());
		} else {
			replaceNode(activeItem, getEditingItem(), coreItems);
		}
		activeItem = getEditingItem();
		resetEditingElement();
		updateTopLevelItems();
	}
	
	public void addElement(EmvElement element){
		if (element.getParentId() == null){
			addElementToTree(element);
		} else {
			addElementToParent(element, coreItems, nodePath);
		}
	}

	public void resetEditingElement() {
		curMode = AbstractBean.VIEW_MODE;
		setEditingItem(null);
	}

	public void deleteActiveElement() {
		try {
			emvDao.removeElement(userSessionId, activeItem);
		} catch (DataAccessException e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
			return;
		}
		deleteNodeFromTree(activeItem, coreItems);
		updateTopLevelItems();
		setActiveItem(null);
	}
	
	public void setObjectId(Integer objectId) {
		this.objectId = objectId;
		coreItems = null;
		activeItem = null;
	}
	
	public Integer getObjectId(){
		return this.objectId;
	}
	
	

	@Override
	protected void loadTree() {
		
		if (objectId == null){
			return;
		}
		Filter[] filters = new Filter[2];
		Filter f = new Filter();
		f.setElement("objectId");
		f.setValue(objectId);
		filters[0] = f;
		f = new Filter();
		f.setElement("entityType");
		f.setValue(entityType);
		filters[1] = f;
		SelectionParams sp = new SelectionParams();
		sp.setFilters(filters);
		EmvElement[] dataList = null;
		try {
			dataList = emvDao.getElements(userSessionId, sp);
		} catch (DataAccessException e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
			return;
		}
		coreItems = new ArrayList<EmvElement>();
		if (dataList.length > 0) {
			addNodes(0, coreItems, dataList);
		}
		updateTopLevelItems();
	}	

	@Override
	public TreePath getNodePath() {
		return nodePath;
	}

	@Override
	public void setNodePath(TreePath nodePath) {
		this.nodePath = nodePath;
	}

	public List<SelectItem> getTags(){
		List<SelectItem> result = getDictUtils().getLov(LovConstants.EMV_TAGS);
		return result;
	}

	public EmvElement getEditingItem() {
		return editingItem;
	}

	public void setEditingItem(EmvElement editingItem) {
		this.editingItem = editingItem;
	}

	public String getEntityType() {
		return entityType;
	}

	public void setEntityType(String entityType) {
		this.entityType = entityType;
		coreItems = null;
	}

	public Integer getParentItemId() {
		return parentItemId;
	}

	public void setParentItemId(Integer parentItemId) {
		this.parentItemId = parentItemId;
	}

	public List<SelectItem> getTopLevelItems(){
		return topLevelItems;
	}
	
	public List<SelectItem> getProfileList(){
		if (profileList == null) {
			profileList = getDictUtils().getLov(LovConstants.EMV_APPLICATION_PROFILE);
		}		
		return profileList;
	}

	
	private void updateTopLevelItems(){
		// TODO to delete
		System.out.println("updateTopLevelItems() has been called");
		topLevelItems.clear();
		topLevelItems.add(new SelectItem("", null));
		for (EmvElement item : coreItems){
			String topliLabel =  String.format("%d - %s %s",item.getId(), item.getCode(), item.getTag());
			SelectItem topLevelItem = new SelectItem(item.getId(), topliLabel);
			topLevelItems.add(topLevelItem);
		}
	}

	@Override
	public void clearFilter() {
		// TODO Auto-generated method stub
		
	}
}
