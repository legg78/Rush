package ru.bpc.sv2.process;

import java.io.Serializable;
import java.util.HashMap;
import java.util.Map;

import ru.bpc.sv2.constants.schedule.ProcessConstants;
import ru.bpc.sv2.invocation.IAuditableObject;
import ru.bpc.sv2.invocation.ModelIdentifiable;

public class ProcessFile implements ModelIdentifiable, Serializable, Cloneable, IAuditableObject {

	private static final long serialVersionUID = 1L;

	private Integer id;
	private Integer processId;
	private String purpose;
	private String type;
	private String lang;
	private String shortDesc;
	private String fullDesc;
	private String saverClass;
	private String saverName;
	private String fileNature;
	private String xsdSource;
	private Integer saverId;
	
	public Integer getId() {
		return id;
	}

	public void setId(Integer id) {
		this.id = id;
	}

	public Integer getProcessId() {
		return processId;
	}

	public void setProcessId(Integer processId) {
		this.processId = processId;
	}

	public String getPurpose() {
		return purpose;
	}

	public void setPurpose(String purpose) {
		this.purpose = purpose;
	}

	public String getLang() {
		return lang;
	}

	public void setLang(String lang) {
		this.lang = lang;
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

	public Object getModelId() {
		return getId();
	}

	public String getSaverClass() {
		return saverClass;
	}

	public void setSaverClass(String saverClass) {
		this.saverClass = saverClass;
	}
	
	public String getFileNature() {
		return fileNature;
	}

	public void setFileNature(String fileNature) {
		this.fileNature = fileNature;
	}

	public String getType() {
		return type;
	}

	public void setType(String type) {
		this.type = type;
	}

	@Override
	public ProcessFile clone() throws CloneNotSupportedException {
		return (ProcessFile)super.clone();
	}

	public String getXsdSource() {
		return xsdSource;
	}

	public void setXsdSource(String xsdSource) {
		this.xsdSource = xsdSource;
	}
	
	public boolean isIncoming() {
		return (ProcessConstants.FILE_PURPOSE_INCOMING.equals(purpose));
	}
	
	public boolean isOutgoing() {
		return (ProcessConstants.FILE_PURPOSE_OUTGOING.equals(purpose));
	}

	public boolean isXml() {
		return ProcessConstants.FILE_NATURE_XML.equals(fileNature);
	}

	public boolean isLob() {
		return ProcessConstants.FILE_NATURE_LOB.equals(fileNature);
	}

	public boolean isPlain() {
		return ProcessConstants.FILE_NATURE_PLAIN.equals(fileNature);
	}

	public Integer getSaverId() {
		return saverId;
	}

	public void setSaverId(Integer saverId) {
		this.saverId = saverId;
	}

	public String getSaverName() {
		return saverName;
	}

	public void setSaverName(String saverName) {
		this.saverName = saverName;
	}

	@Override
	public Map<String, Object> getAuditParameters() {
		Map<String, Object> result = new HashMap<String, Object>();
		result.put("id", getId());
		result.put("processId", getProcessId());
		result.put("purpose", getPurpose());
		result.put("saverId", getSaverId());
		result.put("fileNature", getFileNature());
//		result.put("xsdSource", getXsdSource());
		result.put("type", getType());
		result.put("shortDesc", getShortDesc());
		result.put("fullDesc", getFullDesc());
		result.put("lang", getLang());
		return result;
	}

}
