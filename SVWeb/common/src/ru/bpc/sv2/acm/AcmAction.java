package ru.bpc.sv2.acm;

import java.io.Serializable;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import ru.bpc.sv2.invocation.IAuditableObject;
import ru.bpc.sv2.invocation.ModelIdentifiable;

public class AcmAction implements Serializable, ModelIdentifiable, IAuditableObject, Cloneable {
	private static final long serialVersionUID = 1L;

	public final static String MODAL_ITEM = "CACM0001";
	public final static String ACTION_ITEM = "CACM0002";
	public final static String RUNNABLE_ITEM = "CACM0003";
	
	private Integer id;
	private Integer seqNum;
	private String callMode;
	private String entityType;
	private Integer sectionId;
	private Integer privId;
	private Integer privObjectId;
	private Integer instId;
	private String label;
	private String description;
	private String lang;
	private String sectionName;
	private String action;
	private String privName;
	private String instName;
	private Integer groupId;
	private String groupName;
	private Boolean isDefault;
	private boolean isGroup;
	private String objectType;
	private Integer objectTypeLovId;
	
	private List<AcmAction> children;
	private List<AcmActionValue> actionValues;
	
	public Object getModelId() {
		return getId();
	}

	public Integer getId() {
		return id;
	}

	public void setId(Integer id) {
		this.id = id;
	}

	public Integer getSeqNum() {
		return seqNum;
	}

	public void setSeqNum(Integer seqNum) {
		this.seqNum = seqNum;
	}

	public String getCallMode() {
		return callMode;
	}

	public void setCallMode(String callMode) {
		this.callMode = callMode;
	}

	public String getEntityType() {
		return entityType;
	}

	public void setEntityType(String entityType) {
		this.entityType = entityType;
	}

	public Integer getSectionId() {
		return sectionId;
	}

	public void setSectionId(Integer sectionId) {
		this.sectionId = sectionId;
	}

	public Integer getPrivId() {
		return privId;
	}

	public void setPrivId(Integer privId) {
		this.privId = privId;
	}

	public Integer getPrivObjectId() {
		return privObjectId;
	}

	public void setPrivObjectId(Integer privObjectId) {
		this.privObjectId = privObjectId;
	}

	public Integer getInstId() {
		return instId;
	}

	public String getLabel() {
		return label;
	}

	public void setLabel(String label) {
		this.label = label;
	}

	public void setInstId(Integer instId) {
		this.instId = instId;
	}

	public String getDescription() {
		return description;
	}

	public void setDescription(String description) {
		this.description = description;
	}

	public String getSectionName() {
		return sectionName;
	}

	public void setSectionName(String sectionName) {
		this.sectionName = sectionName;
	}

	public String getAction() {
		return action;
	}

	public void setAction(String action) {
		this.action = action;
	}

	public String getLang() {
		return lang;
	}

	public void setLang(String lang) {
		this.lang = lang;
	}

	public String getPrivName() {
		return privName;
	}

	public void setPrivName(String privName) {
		this.privName = privName;
	}

	public String getInstName() {
		return instName;
	}

	public void setInstName(String instName) {
		this.instName = instName;
	}

	public Integer getGroupId() {
		return groupId;
	}

	public void setGroupId(Integer groupId) {
		this.groupId = groupId;
	}

	public String getGroupName() {
		return groupName;
	}

	public void setGroupName(String groupName) {
		this.groupName = groupName;
	}

	public List<AcmActionValue> getActionValues() {
		return actionValues;
	}

	public void setActionValues(List<AcmActionValue> actionValues) {
		this.actionValues = actionValues;
	}

	// to be used with rich:menuItem's "action" atribute
	public String doAction() {
		return action;
	}
	
	@Override
	public Object clone() throws CloneNotSupportedException {
		return super.clone();
	}
	
	public boolean isModalItem() {
		return MODAL_ITEM.equals(callMode);
	}

	public boolean isActionItem() {
		return ACTION_ITEM.equals(callMode);
	}

	public boolean isRunnableItem() {
		return RUNNABLE_ITEM.equals(callMode);
	}

	public Boolean getIsDefault() {
		return isDefault;
	}

	public void setIsDefault(Boolean isDefault) {
		this.isDefault = isDefault;
	}

	public boolean isGroup() {
		return isGroup;
	}

	public void setGroup(boolean isGroup) {
		this.isGroup = isGroup;
	}

	public List<AcmAction> getChildren() {
		return children;
	}

	public void setChildren(List<AcmAction> children) {
		this.children = children;
	}

	public String getObjectType() {
		return objectType;
	}

	public void setObjectType(String objectType) {
		this.objectType = objectType;
	}
	
	public String getEntityKey() {
		return entityType + (objectType == null ? "" : objectType);
	}
	
	public Integer getObjectTypeLovId() {
		return objectTypeLovId;
	}

	public void setObjectTypeLovId(Integer objectTypeLovId) {
		this.objectTypeLovId = objectTypeLovId;
	}

	@Override
	public Map<String, Object> getAuditParameters() {
		Map<String, Object> result = new HashMap<String, Object>();
		result.put("instId", this.getInstId());
		result.put("groupId", this.getGroupId());
		result.put("entityType", this.getEntityType());
		result.put("objectType", this.getObjectType());
		result.put("callMode", this.getCallMode());
		result.put("sectionId", this.getSectionId());
		result.put("privId", this.getPrivId());
		result.put("privObjectId", this.getPrivObjectId());
		result.put("isDefault", this.getIsDefault());
		result.put("lang", this.getLang());
		result.put("label", this.getLabel());
		result.put("description", this.getDescription());
		result.put("objectTypeLovId", this.getObjectTypeLovId());
		
		return result;
	}
}
