package ru.bpc.sv2.cmn;

import java.io.Serializable;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import ru.bpc.sv2.invocation.IAuditableObject;
import ru.bpc.sv2.invocation.TreeIdentifiable;

/**
 * <p>Represents binding between version of communication standard and an object.</p>
 * @author Alexeev
 *
 */
public class ObjectStandardVersion implements Serializable,
		TreeIdentifiable<ObjectStandardVersion>, Cloneable, IAuditableObject {
	private static final long serialVersionUID = 1L;

	private Long id;
	private String entityType;
	private Long objectId;
	private Integer versionId;
	private Date startDate;
	private String objectName;
	private Long parentId;
	private Integer standardId;
	private String versionNumber;
	private String lang;
	private int level;
	private boolean isLeaf;
	private List<ObjectStandardVersion> children;
	
	public Long getId() {
		return id;
	}

	public void setId(Long id) {
		this.id = id;
	}

	public Object getModelId() {
		return getId() + "-" + getStandardId();
	}

	public String getEntityType() {
		return entityType;
	}

	public void setEntityType(String entityType) {
		this.entityType = entityType;
	}

	public Long getObjectId() {
		return objectId;
	}

	public void setObjectId(Long objectId) {
		this.objectId = objectId;
	}

	public Integer getVersionId() {
		return versionId;
	}

	public void setVersionId(Integer versionId) {
		this.versionId = versionId;
	}

	public Date getStartDate() {
		return startDate;
	}

	public void setStartDate(Date startDate) {
		this.startDate = startDate;
	}

	public String getObjectName() {
		return objectName;
	}

	public void setObjectName(String objectName) {
		this.objectName = objectName;
	}

	public Integer getStandardId() {
		return standardId;
	}

	public void setStandardId(Integer standardId) {
		this.standardId = standardId;
	}

	public Long getParentId() {
		return parentId;
	}

	public void setParentId(Long parentId) {
		this.parentId = parentId;
	}

	public String getLang() {
		return lang;
	}

	public void setLang(String lang) {
		this.lang = lang;
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

	public List<ObjectStandardVersion> getChildren() {
		return children;
	}

	public void setChildren(List<ObjectStandardVersion> children) {
		this.children = children;
	}

	public boolean isHasChildren() {
		return children == null ? false : !children.isEmpty();
	}

	public String getVersionNumber() {
		return versionNumber;
	}

	public void setVersionNumber(String versionNumber) {
		this.versionNumber = versionNumber;
	}

	@Override
	public Object clone() throws CloneNotSupportedException {
		ObjectStandardVersion clone = (ObjectStandardVersion) super.clone();
		if (startDate != null) {
			clone.setStartDate(new Date(startDate.getTime()));
		}
		return clone;
	}

	@Override
	public Map<String, Object> getAuditParameters() {
		Map<String, Object> result = new HashMap<String, Object>();
		result.put("versionId", this.getVersionId());
		result.put("startDate", this.getStartDate());
		
		return result;
	}

}
