package ru.bpc.sv2.ui.contextsearch;


import ru.bpc.sv2.constants.EntityNames;
import ru.bpc.sv2.ui.products.MbAttributeValues;
import ru.bpc.sv2.ui.products.MbObjectAttributes;
import util.auxil.ManagedBeanWrapper;

import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;

@ViewScoped
@ManagedBean(name = "MbObjectAttributesContext")
public class MbObjectAttributesContext extends MbObjectAttributes {
	@Override
	protected void setInfo(boolean restoreState) {
		MbAttributeValues attrValues = (MbAttributeValues) ManagedBeanWrapper.getManagedBean("MbAttributeValuesContext");
		attrValues.fullCleanBean();
		
		// set attribute only if current node is not null, is not attribute group or service 
		// (services don't have names)
		if (currentNode != null && !EntityNames.ATTRIBUTE_GROUP.equals(currentNode.getAttrEntityType())
				//&& !EntityNames.SERVICE.equals(currentNode.getAttrEntityType())) {
				&& currentNode.getSystemName() != null) {
			attrValues.setAttribute(currentNode);
    		attrValues.setProductId(productId);
    		attrValues.setObjectId(
    				objectId == null ? (productId == null ? serviceId : productId) : objectId);
    		attrValues.setEntityType(entityType);
    		attrValues.setInstId(instId);
    		attrValues.setProductType(productType);
    		attrValues.getAttributeValues().flushCache();
    		if (restoreState) {
    			attrValues.restoreBean();
    		}
    	}
    }
	
	public void clearBean() {
		currentNode = null;
		nodePath = null;
		coreItems = null;
		treeLoaded = false;
		curLang = userLang;
		
		// clear dependent bean 
		MbAttributeValues attrValues = (MbAttributeValues) ManagedBeanWrapper.getManagedBean("MbAttributeValuesContext");
		attrValues.fullCleanBean();
	}
}
