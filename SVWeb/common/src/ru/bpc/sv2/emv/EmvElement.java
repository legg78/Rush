package ru.bpc.sv2.emv;

import java.io.Serializable;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import ru.bpc.sv2.invocation.IAuditableObject;
import ru.bpc.sv2.invocation.TreeIdentifiable;

public class EmvElement implements Serializable, TreeIdentifiable<EmvElement>, Cloneable, IAuditableObject {

	private static final long serialVersionUID = 1L;

	private Long id;
	private Integer seqnum;
	private Long parentId;
	private String entityType;
	private Integer objectId;
	private Integer elementOrder;
	private String code;
	private String tag;
	private String value;
	private Boolean isOptional;
	private Boolean addLength;
	private Integer startPosition;
	private Integer length;	
	private String profile;
	
	private List<EmvElement> children;
	private int level;
	
	
	public String getProfile() {
		return profile;
	}

	public void setProfile(String profile) {
		this.profile = profile;
	}

	public Object getModelId() {
		return getId();
	}
	
	public Long getId(){
		return this.id;
	}
	
	public void setId(Long id){
		this.id = id;
	}
	
	public Integer getSeqnum(){
		return this.seqnum;
	}
	
	public void setSeqnum(Integer seqnum){
		this.seqnum = seqnum;
	}
	
	public Long getParentId(){
		return this.parentId;
	}
	
	public void setParentId(Long parentId){
		this.parentId = parentId;
	}
	
	public String getEntityType(){
		return this.entityType;
	}
	
	public void setEntityType(String entityType){
		this.entityType = entityType;
	}
	
	public Integer getObjectId(){
		return this.objectId;
	}
	
	public void setObjectId(Integer objectId){
		this.objectId = objectId;
	}
	
	public Integer getElementOrder(){
		return this.elementOrder;
	}
	
	public void setElementOrder(Integer elementOrder){
		this.elementOrder = elementOrder;
	}
	
	public String getCode(){
		return this.code;
	}
	
	public void setCode(String code){
		this.code = code;
	}
	
	public String getTag(){
		return this.tag;
	}
	
	public void setTag(String tag){
		this.tag = tag;
	}
	
	public String getValue(){
		return this.value;
	}
	
	public void setValue(String value){
		this.value = value;
	}
	
	public Boolean getIsOptional(){
		return this.isOptional;
	}
	
	public void setIsOptional(Boolean isOptional){
		this.isOptional = isOptional;
	}
	
	public Boolean getAddLength(){
		return this.addLength;
	}
	
	public void setAddLength(Boolean addLength){
		this.addLength = addLength;
	}
	
	public Integer getStartPosition(){
		return this.startPosition;
	}
	
	public void setStartPosition(Integer startPosition){
		this.startPosition = startPosition;
	}
	
	public Integer getLength(){
		return this.length;
	}
	
	public void setLength(Integer length){
		this.length = length;
	}

	public List<EmvElement> getChildren() {
		return children;
	}

	public void setChildren(List<EmvElement> children) {
		this.children = children;
	}

	public int getLevel() {
		return this.level;
	}
	
	public void setLevel(int level){
		this.level = level;
	}

	public boolean isHasChildren() {
		boolean result = false;
		if (children != null){
			result = children.size() > 0;
		}
		return result;
	}
	
	public Object clone(){
		Object result = null;
		try {
			result = super.clone();
		} catch (CloneNotSupportedException e) {
			e.printStackTrace();
		}
		return result;
	}

	@Override
	public Map<String, Object> getAuditParameters() {
		Map<String, Object> result = new HashMap<String, Object>();
		result.put("parentId", this.getParentId());
		result.put("code", this.getCode());
		result.put("tag", this.getTag());
		result.put("value", this.getValue());
		result.put("isOptional", this.getIsOptional());
		result.put("addLength", this.getAddLength());
		result.put("startPosition", this.getStartPosition());
		result.put("length", this.getLength());
		result.put("elementOrder", this.getElementOrder());
		
		return result;
	}
	
}