package ru.bpc.sv2.process;

import java.io.Serializable;
import java.util.HashMap;
import java.util.Map;

import ru.bpc.sv2.invocation.IAuditableObject;
import ru.bpc.sv2.invocation.ModelIdentifiable;

public class ProcessFileDirectory implements Serializable, Cloneable, ModelIdentifiable, IAuditableObject {
	private Long id;
	private int seqnum;
	private String lang;
	private String name;
	private String directoryPath;
	private String encryptionTypeDesc;
	private String encryptionType;

	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;

	@Override
	public Object getModelId() {
		return getId();
	}

	public Long getId() {
		return id;
	}

	public void setId(Long id) {
		this.id = id;
	}

	public String getLang() {
		return lang;
	}

	public void setLang(String lang) {
		this.lang = lang;
	}

	public String getName() {
		return name;
	}

	public void setName(String name) {
		this.name = name;
	}

	public String getDirectoryPath() {
		return directoryPath;
	}

	public void setDirectoryPath(String directoryPath) {
		this.directoryPath = directoryPath;
	}

	public String getEncryptionTypeDesc() {
		return encryptionTypeDesc;
	}

	public void setEncryptionTypeDesc(String encriptionTypeDesc) {
		this.encryptionTypeDesc = encriptionTypeDesc;
	}

	public String getEncryptionType() {
		return encryptionType;
	}

	public void setEncryptionType(String encriptionType) {
		this.encryptionType = encriptionType;
	}

	public int getSeqnum() {
		return seqnum;
	}

	public void setSeqnum(int seqnum) {
		this.seqnum = seqnum;
	}

	@Override
	public Map<String, Object> getAuditParameters() {
		Map<String, Object> result = new HashMap<String, Object>();
		result.put("id", getId());
		result.put("name", getName());
		result.put("directoryPath", getDirectoryPath());
		result.put("encryptionType", getEncryptionType());		
		return result;
	}
}
