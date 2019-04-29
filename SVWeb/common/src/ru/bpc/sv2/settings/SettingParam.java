package ru.bpc.sv2.settings;

import java.io.Serializable;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;

import ru.bpc.sv2.common.Parameter;
import ru.bpc.sv2.invocation.IAuditableObject;
import ru.bpc.sv2.invocation.ModelIdentifiable;

public class SettingParam extends Parameter implements ModelIdentifiable, Serializable, IAuditableObject {
	private static final long serialVersionUID = -4991241886310869900L;

	private Integer id;
	private String moduleCode;
	private String lowestLevel;
	private String defaultValue;
	private Integer parentId;
	private ArrayList<SettingParam> children;
	private int level;
	private boolean isLeaf;
	private String levelValue;
	private String paramLevel;
	private boolean isEncrypted;

	public Integer getId() {
		return id;
	}
	public void setId(Integer id) {
		this.id = id;
	}

	public Object getModelId()
	{
		return getId();
	}

	public String getModuleCode() {
		return moduleCode;
	}
	public void setModuleCode(String moduleCode) {
		this.moduleCode = moduleCode;
	}

	public String getLowestLevel() {
		return lowestLevel;
	}
	public void setLowestLevel(String lowestLevel) {
		this.lowestLevel = lowestLevel;
	}

	public String getDefaultValue() {
		return defaultValue;
	}
	public void setDefaultValue(String defaultValue) {
		this.defaultValue = defaultValue;
	}

	public Integer getParentId() {
		return parentId;
	}
	public void setParentId(Integer parentId) {
		this.parentId = parentId;
	}

	public ArrayList<SettingParam> getChildren() {
		return children;
	}
	public void setChildren(ArrayList<SettingParam> children) {
		this.children = children;
	}
	public boolean hasChildren() {
		return children != null ? children.size() > 0 : false;
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

	public String getLevelValue() {
		return levelValue;
	}
	public void setLevelValue(String levelValue) {
		this.levelValue = levelValue;
	}

	public String getParamLevel() {
		return paramLevel;
	}
	public void setParamLevel(String paramLevel) {
		this.paramLevel = paramLevel;
	}

	public boolean isEncrypted() {
		return isEncrypted;
	}
	public void setEncrypted(boolean isEncrypted) {
		this.isEncrypted = isEncrypted;
	}

	@Override
	public boolean equals(Object obj) {
		if ( obj instanceof SettingParam )
		{
			return getId() == ( (SettingParam)obj ).getId();
		}
		return false;
	}
	@Override
	public int hashCode() {
		final int prime = 31;
		int result = 1;
		result = prime * result + ((id == null) ? 0 : id.hashCode());
		result = prime * result
				+ ((parentId == null) ? 0 : parentId.hashCode());
		result = prime * result;
		return result;
	}
	@Override
	public Object clone() throws CloneNotSupportedException {
		SettingParam clone = (SettingParam) super.clone();
		if (this.children != null) {
			clone.setChildren(new ArrayList<SettingParam>(this.children.size()));
			for (SettingParam child : this.children) {
				clone.getChildren().add((SettingParam) child.clone());
			}
		}
		
		return clone; 
	}
	@Override
	public Map<String, Object> getAuditParameters() {
		Map<String, Object> result = new HashMap<String, Object>();
		result.put("id", getId());
		result.put("systemName", getSystemName());
		result.put("levelValue", getLevelValue());
		result.put("lowestLevel", getLowestLevel());
		result.put("valueV", getValueV());
		result.put("valueN", getValueN());
		result.put("valueD", getValueD());
		result.put("levelValue", getLevelValue());
		result.put("value", getValue());
		return result;
	}
}
