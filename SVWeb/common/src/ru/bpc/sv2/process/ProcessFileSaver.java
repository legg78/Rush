package ru.bpc.sv2.process;

import ru.bpc.sv2.invocation.IAuditableObject;
import ru.bpc.sv2.invocation.ModelIdentifiable;

import java.io.Serializable;
import java.util.HashMap;
import java.util.Map;

public class ProcessFileSaver implements ModelIdentifiable, Serializable, Cloneable, IAuditableObject {
	private static final long serialVersionUID = 1L;

	private Integer id;
	private Integer seqnum;
	private String baseSource;
	private String postSource;
	private Boolean parallel;
	private String lang;
	private String name;

	public Integer getId() {
		return id;
	}
	public void setId(Integer id) {
		this.id = id;
	}

	public Integer getSeqnum() {
		return seqnum;
	}
	public void setSeqnum(int seqnum) {
		this.seqnum = seqnum;
	}

	public String getBaseSource() {
		return baseSource;
	}
	public void setBaseSource(String baseSource) {
		this.baseSource = baseSource;
	}

	public String getPostSource() {
		return postSource;
	}
	public void setPostSource(String postSource) {
		this.postSource = postSource;
	}

	public Boolean isParallel() {
		return parallel;
	}
	public Boolean getParallel() {
		return parallel;
	}
	public void setParallel(Boolean parallel) {
		this.parallel = parallel;
	}

	public String getName() {
		return name;
	}
	public void setName(String name) {
		this.name = name;
	}

	public String getLang() {
		return lang;
	}
	public void setLang(String lang) {
		this.lang = lang;
	}

	@Override
	public Object getModelId() {
		return getId();
	}
	@Override
	public ProcessFileSaver clone() throws CloneNotSupportedException {
		return (ProcessFileSaver)super.clone();
	}
	@Override
	public Map<String, Object> getAuditParameters() {
		Map<String, Object> result = new HashMap<String, Object>();
		result.put("id", getId());
		result.put("seqnum", getSeqnum());
		result.put("baseSource", getBaseSource());
		result.put("postSource", getPostSource());
		result.put("parallel", isParallel());
		result.put("name", getName());
		result.put("lang", getLang());
		return result;
	}
}
