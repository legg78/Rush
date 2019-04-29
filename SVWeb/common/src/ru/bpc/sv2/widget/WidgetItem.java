package ru.bpc.sv2.widget;

import java.io.Serializable;
import java.util.HashMap;
import java.util.Map;

import ru.bpc.sv2.invocation.IAuditableObject;
import ru.bpc.sv2.invocation.ModelIdentifiable;

public class WidgetItem implements ModelIdentifiable, Serializable, Cloneable, IAuditableObject {

	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;
	private Integer id;
	private Integer seqnum;
	private String name;
	private String description;
	private String path;
	private String cssName;
	private Boolean external;
	private String paramsPath;
	private String lang;
	private Integer privId;
	private String privName;
	private Integer width;
	private Integer height;

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
	public String getPath() {
		return path;
	}
	public void setPath(String path) {
		this.path = path;
	}
	public String getCssName() {
		return cssName;
	}
	public void setCssName(String cssName) {
		this.cssName = cssName;
	}
	
	public Object getModelId() {
		return id;
	}
	@Override
	public Object clone() throws CloneNotSupportedException {
		return super.clone();
	}
	
	public String getDescription() {
		return description;
	}
	public void setDescription(String description) {
		this.description = description;
	}
	public Boolean getExternal() {
		return external;
	}
	public void setExternal(Boolean external) {
		this.external = external;
	}
	public String getLang() {
		return lang;
	}
	public void setLang(String lang) {
		this.lang = lang;
	}
	
	public String getParamsPath() {
		return paramsPath;
	}
	public void setParamsPath(String paramsPath) {
		this.paramsPath = paramsPath;
	}
	public Integer getPrivId() {
		return privId;
	}
	public void setPrivId(Integer privId) {
		this.privId = privId;
	}
	
	public Integer getSeqnum() {
		return seqnum;
	}
	public void setSeqnum(Integer seqnum) {
		this.seqnum = seqnum;
	}
	public String getPrivName() {
		return privName;
	}
	public void setPrivName(String privName) {
		this.privName = privName;
	}
	public Integer getWidth() {
		return width;
	}
	public void setWidth(Integer width) {
		this.width = width;
	}
	public Integer getHeight() {
		return height;
	}
	public void setHeight(Integer height) {
		this.height = height;
	}
	@Override
	public Map<String, Object> getAuditParameters() {
		Map<String, Object> result = new HashMap<String, Object>();
		result.put("id", getId());
		result.put("path", getPath());
		result.put("cssName", getCssName());
		result.put("external", getExternal());
		result.put("width", getWidth());
		result.put("height", getHeight());
		result.put("privId", getPrivId());
		result.put("paramsPath", getParamsPath());
		result.put("lang", getLang());
		result.put("name", getName());
		result.put("description", getDescription());
		return result;
	}
	
}
