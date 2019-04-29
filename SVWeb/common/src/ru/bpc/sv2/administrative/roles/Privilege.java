package ru.bpc.sv2.administrative.roles;

import java.io.Serializable;
import java.util.HashMap;
import java.util.Map;

import ru.bpc.sv2.invocation.IAuditableObject;
import ru.bpc.sv2.invocation.ModelIdentifiable;

public class Privilege implements ModelIdentifiable, Cloneable, Serializable, IAuditableObject {
	/**
	 * 
	 */
	private static final long serialVersionUID = 549943522920261631L;

	private Integer _id;
	private String _name;
	private String _description;
	private String shortDesc = null;
	private String fullDesc;
	private String descId;
	private String lang;
	private String sectionId;
	private String moduleCode;
	private String moduleDesc;
	private Integer roleId;
	private String roleName;
	private Boolean isActive;
	private String roles;
	private Integer limitationId;
	private String limitationLabel;

	private Integer filterLimitationId;
	private String filterLimitationLabel;

	public Privilege() {
	}

	public String getShortDesc() {
		return shortDesc;
	}

	public void setShortDesc(String shortDesc) {
		this.shortDesc = shortDesc;
	}

	public String getFullDesc() {
		return fullDesc;
	}

	public void setFullDesc(String fullDesc) {
		this.fullDesc = fullDesc;
	}

	public String getDescId() {
		return descId;
	}

	public void setDescId(String descId) {
		this.descId = descId;
	}

	public String getLang() {
		return lang;
	}

	public void setLang(String lang) {
		this.lang = lang;
	}

	public Integer getId() {
		return _id;
	}

	public void setId(Integer id) {
		_id = id;
	}

	public String getName() {
		return _name;
	}

	public void setName(String name) {
		_name = name;
	}

	public String getDescription() {
		return _description;
	}

	public void setDescription(String description) {
		_description = description;
	}

	public String getSectionId() {
		return sectionId;
	}

	public void setSectionId(String sectionId) {
		this.sectionId = sectionId;
	}

	public String getModuleCode() {
		return moduleCode;
	}

	public void setModuleCode(String moduleCode) {
		this.moduleCode = moduleCode;
	}

	public String getModuleDesc() {
		return moduleDesc;
	}

	public void setModuleDesc(String moduleDesc) {
		this.moduleDesc = moduleDesc;
	}

	public Object getModelId() {
		return getId();
	}

	public Integer getRoleId() {
		return roleId;
	}

	public void setRoleId(Integer roleId) {
		this.roleId = roleId;
	}

	public String getRoleName() {
		return roleName;
	}

	public void setRoleName(String roleName) {
		this.roleName = roleName;
	}

	public Boolean getIsActive() {
		return isActive;
	}

	public void setIsActive(Boolean isActive) {
		this.isActive = isActive;
	}

	public String getRoles() {
		return roles;
	}

	public void setRoles(String roles) {
		this.roles = roles;
	}
	
	public String getLimitationLabel() {
		return limitationLabel;
	}

	public void setLimitationLabel(String limitationLabel) {
		this.limitationLabel = limitationLabel;
	}
	
	public Integer getLimitationId() {
		return limitationId;
	}

	public void setLimitationId(Integer limitationId) {
		this.limitationId = limitationId;
	}

	@Override
	public Map<String, Object> getAuditParameters() {
		Map<String, Object> result = new HashMap<String, Object>();
		result.put("id", getId());
		result.put("name", getName());
		result.put("shortDesc", getShortDesc());
		result.put("fullDesc", getFullDesc());
		result.put("lang", getLang());
		result.put("moduleCode", getModuleCode());
		result.put("isActive", getIsActive());
		result.put("limitationId", getLimitationId());
		result.put("limitationLabel", getLimitationLabel());
		result.put("filterLimitationId", getFilterLimitationId());
		result.put("filterLimitationLabel", getFilterLimitationLabel());
		return result;
	}

    @Override
    public Privilege clone() throws CloneNotSupportedException {
        return (Privilege)super.clone();
    }

	public Integer getFilterLimitationId() {
		return filterLimitationId;
	}

	public void setFilterLimitationId(Integer filterLimitationId) {
		this.filterLimitationId = filterLimitationId;
	}

	public String getFilterLimitationLabel() {
		return filterLimitationLabel;
	}

	public void setFilterLimitationLabel(String filterLimitationLabel) {
		this.filterLimitationLabel = filterLimitationLabel;
	}
}
