package ru.bpc.sv2.administrative.roles;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;

import ru.bpc.sv2.invocation.IAuditableObject;
import ru.bpc.sv2.invocation.ModelIdentifiable;

public class ComplexRole
	implements Serializable, ModelIdentifiable, Cloneable, IAuditableObject
{
	/**
	 *
	 */
	private static final long	serialVersionUID	= 2444179232356696505L;

	private Integer id = null;
	private String name = null;
	private String shortDesc = null;
	private String fullDesc;
	private Integer bindId;		// id of a binding between role and some object
	private Integer notifSchemeId;
	private String notifSchemeName;
	private String lang;
	private int force;

	private ArrayList<ComplexRole> children;
	private int level;
	private boolean isLeaf;

	private Integer privilege; //need for filter

	public ComplexRole()
	{
	}

	public ComplexRole( String name, String desc )
	{
		this.name = name;
		this.shortDesc = desc;
	}

	public boolean hasChildren() {
		return children != null ? children.size() > 0 : false;
	}

	public Integer getId() {
		return id;
	}

	public void setId(Integer id) {
		this.id = id;
	}

	public String getName() {
		return name;
	}

	public void setName(String name) {
		this.name = name;
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

	public String getLang() {
		return lang;
	}

	public void setLang(String lang) {
		this.lang = lang;
	}
	public int getForce() {
		return force;
	}

	public void setForce(int force) {
		this.force = force;
	}

	public Object getModelId()
	{
		return getId();
	}

	public ArrayList<ComplexRole> getChildren() {
		return children;
	}

	public void setChildren(ArrayList<ComplexRole> children) {
		this.children = children;
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

	public Integer getPrivilege() {
		return privilege;
	}

	public void setPrivilege(Integer privilege) {
		this.privilege = privilege;
	}

	public Integer getBindId() {
		return bindId;
	}

	public void setBindId(Integer bindId) {
		this.bindId = bindId;
	}

	public Integer getNotifSchemeId() {
		return notifSchemeId;
	}

	public void setNotifSchemeId(Integer notifSchemeId) {
		this.notifSchemeId = notifSchemeId;
	}

	public String getNotifSchemeName() {
		return notifSchemeName;
	}

	public void setNotifSchemeName(String notifSchemeName) {
		this.notifSchemeName = notifSchemeName;
	}

	@Override
	public ComplexRole clone() throws CloneNotSupportedException {
		return (ComplexRole)super.clone();
	}

	@Override
	public int hashCode() {
		final int prime = 31;
		int result = 1;
		result = prime * result + ((bindId == null) ? 0 : bindId.hashCode());
		result = prime * result + ((id == null) ? 0 : id.hashCode());
		result = prime * result + ((name == null) ? 0 : name.hashCode());
		result = prime * result + ((notifSchemeId == null) ? 0 : notifSchemeId.hashCode());
		result = prime * result + ((privilege == null) ? 0 : privilege.hashCode());
		return result;
	}

	@Override
	public boolean equals(Object obj) {
		if (this == obj)
			return true;
		if (obj == null)
			return false;
		if (getClass() != obj.getClass())
			return false;
		ComplexRole other = (ComplexRole) obj;
		if (bindId == null) {
			if (other.bindId != null)
				return false;
		} else if (!bindId.equals(other.bindId))
			return false;
		if (id == null) {
			if (other.id != null)
				return false;
		} else if (!id.equals(other.id))
			return false;
		if (name == null) {
			if (other.name != null)
				return false;
		} else if (!name.equals(other.name))
			return false;
		if (notifSchemeId == null) {
			if (other.notifSchemeId != null)
				return false;
		} else if (!notifSchemeId.equals(other.notifSchemeId))
			return false;
		if (privilege == null) {
			if (other.privilege != null)
				return false;
		} else if (!privilege.equals(other.privilege))
			return false;
		return true;
	}

	@Override
	public Map<String, Object> getAuditParameters() {
		Map<String, Object> result = new HashMap<String, Object>();
		result.put("id", getId());
		result.put("name", getName());
		result.put("shortDesc", getShortDesc());
		result.put("fullDesc", getFullDesc());
		result.put("lang", getLang());
		result.put("notifSchemeId", getNotifSchemeId());
		return result;
	}

}
