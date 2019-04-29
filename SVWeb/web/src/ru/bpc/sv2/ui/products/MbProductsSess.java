package ru.bpc.sv2.ui.products;

import java.io.Serializable;

import ru.bpc.sv2.products.AttributeValue;
import ru.bpc.sv2.products.Product;
import ru.bpc.sv2.products.ProductAttribute;
import ru.bpc.sv2.ui.utils.TableRowSelection;

import org.openfaces.component.table.TreePath;

import javax.faces.bean.ManagedBean;
import javax.faces.bean.SessionScoped;

@SessionScoped
@ManagedBean(name ="MbProductsSess")
public class MbProductsSess implements Serializable {
	private static final long serialVersionUID = 1L;

	private boolean keepState;
	
	/* MbProductAttrValues parameters */
	private TableRowSelection<AttributeValue> attributeValueSelection;
	private AttributeValue activeAttributeValue;
	/* MbProductAttrValues parameters END*/
	
	/* MbProductAttributes parameters */
	private ProductAttribute productAttributeCurrentNode;
	private TreePath productAttributeNodePath;
	/* MbProductAttributes parameters END */
	
	/* MbProducts parameters */
	private Product productFilter;
	private TreePath productNodePath;
	private String productTabName;
	private Integer productInstId;
	/* MbProducts parameters END */
	
	public AttributeValue getActiveAttributeValue() {
		return activeAttributeValue;
	}
	
	public void setActiveAttributeValue(AttributeValue activeAttributeValue) {
		this.activeAttributeValue = activeAttributeValue;
	}

	public TableRowSelection<AttributeValue> getAttributeValueSelection() {
		return attributeValueSelection;
	}

	public void setAttributeValueSelection(
			TableRowSelection<AttributeValue> attributeValueSelection) {
		this.attributeValueSelection = attributeValueSelection;
	}

	public ProductAttribute getProductAttributeCurrentNode() {
		return productAttributeCurrentNode;
	}

	public void setProductAttributeCurrentNode(
			ProductAttribute productAttributeCurrentNode) {
		this.productAttributeCurrentNode = productAttributeCurrentNode;
	}

	public TreePath getProductAttributeNodePath() {
		return productAttributeNodePath;
	}

	public void setProductAttributeNodePath(TreePath productAttributeNodePath) {
		this.productAttributeNodePath = productAttributeNodePath;
	}

	public Product getProductFilter() {
		return productFilter;
	}

	public void setProductFilter(Product productFilter) {
		this.productFilter = productFilter;
	}

	public TreePath getProductNodePath() {
		return productNodePath;
	}

	public void setProductNodePath(TreePath productNodePath) {
		this.productNodePath = productNodePath;
	}

	public String getProductTabName() {
		return productTabName;
	}

	public void setProductTabName(String productTabName) {
		this.productTabName = productTabName;
	}

	public Integer getProductInstId() {
		return productInstId;
	}

	public void setProductInstId(Integer productInstId) {
		this.productInstId = productInstId;
	}

	public void clearAllParams() {
		// MbProductAttrValues parameters
		attributeValueSelection = null;
		activeAttributeValue = null;
		
		// MbProductAttributes parameters
		productAttributeCurrentNode = null;
		productAttributeNodePath = null;
		
		// MbProducts parameters
		productFilter = null;
		productNodePath = null;
		productTabName = null;
		productInstId = null;
	}

	public boolean isKeepState() {
		return keepState;
	}

	public void setKeepState(boolean keepState) {
		this.keepState = keepState;
	}

}
