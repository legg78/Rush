package ru.bpc.sv2.dpp;

import ru.bpc.sv2.common.Parameter;
import ru.bpc.sv2.invocation.ModelIdentifiable;
import ru.bpc.sv2.invocation.TreeIdentifiable;

import java.io.Serializable;
import java.util.List;

public class DppAttributeValue extends Parameter implements Serializable, TreeIdentifiable<DppAttributeValue>, ModelIdentifiable, Cloneable{

	private static final long serialVersionUID = 1L;

	private Integer attrId;
	private Long parentId;
	private String attrName;
	private Long dppId;
	private Integer modId;
	private String value;
	private Long accountId;
	private Long cardId;
	private String valueDesc;
	private String attrEntityType;
	private int level;
	private boolean isLeaf;
	private List<DppAttributeValue> children;
	
	public Object getModelId() {
		return getAttrId();
	}
	
	public Long getId() {
		return getAttrId().longValue();
	}
	
	public Integer getAttrId(){
		return this.attrId;
	}
	
	public void setAttrId(Integer attrId){
		this.attrId = attrId;
	}
	
	public Long getParentId(){
		return this.parentId;
	}
	
	public void setParentId(Long parentId){
		this.parentId = parentId;
	}
	
	public String getAttrName(){
		return this.attrName;
	}
	
	public void setAttrName(String attrName){
		this.attrName = attrName;
	}
	
	public Long getDppId(){
		return this.dppId;
	}
	
	public void setDppId(Long dppId){
		this.dppId = dppId;
	}
	
	public Integer getModId(){
		return this.modId;
	}
	
	public void setModId(Integer modId){
		this.modId = modId;
	}
	
	public String getValue(){
		return this.value;
	}
	
	public void setValue(String value){
		this.value = value;
	}
	
	public Long getAccountId(){
		return this.accountId;
	}
	
	public void setAccountId(Long accountId){
		this.accountId = accountId;
	}
	
	public Long getCardId(){
		return this.cardId;
	}
	
	public void setCardId(Long cardId){
		this.cardId = cardId;
	}

	public String getValueDesc() {
		return valueDesc;
	}

	public void setValueDesc(String valueDesc) {
		this.valueDesc = valueDesc;
	}

	public int getLevel() {
		return level;
	}

	public void setLevel(int level) {
		this.level = level;
	}

	public boolean isLeaf() {
		return isLeaf;
	}

	public void setLeaf(boolean isLeaf) {
		this.isLeaf = isLeaf;
	}

	public String getAttrEntityType() {
		return attrEntityType;
	}

	public void setAttrEntityType(String attrEntityType) {
		this.attrEntityType = attrEntityType;
	}

	public List<DppAttributeValue> getChildren() {
		return children;
	}

	public void setChildren(List<DppAttributeValue> children) {
		this.children = children;
	}

	public boolean isHasChildren() {
		return children != null ? children.size() > 0 : false;
	}
}