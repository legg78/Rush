package ru.bpc.sv2.process;

import java.io.Serializable;
import java.util.Date;

import ru.bpc.sv2.invocation.ModelIdentifiable;

public class SessionFile implements ModelIdentifiable, Serializable {

	private static final long serialVersionUID = 1L;

	private Long id;
	private String fileName;
	private Long sessionId;
	private Long fileAttrId;
	private Integer recordCount;	
	private String xmlSource;
	private String status;
	private String fileContents;
	private byte[] blobContent;
	private String fileType;
	private Date fileDate;
	private String crcValue;
	private String location;
	private String filePurpose;
	private Integer instId;
	
	public Object getModelId() {
		return getId();
	}

	public Long getId() {
		return id;
	}

	public void setId(Long id) {
		this.id = id;
	}

	public String getFileName() {
		return fileName;
	}

	public void setFileName(String fileName) {
		this.fileName = fileName;
	}

	public Long getSessionId() {
		return sessionId;
	}

	public void setSessionId(Long sessionId) {
		this.sessionId = sessionId;
	}

	public Long getFileAttrId() {
		return fileAttrId;
	}

	public void setFileAttrId(Long fileAttrId) {
		this.fileAttrId = fileAttrId;
	}

	public Integer getRecordCount() {
		return recordCount;
	}

	public void setRecordCount(Integer recordCount) {
		this.recordCount = recordCount;
	}

	public String getXmlSource() {
		return xmlSource;
	}

	public void setXmlSource(String xmlSource) {
		this.xmlSource = xmlSource;
	}

	public String getStatus() {
		return status;
	}

	public void setStatus(String status) {
		this.status = status;
	}

	public String getFileContents() {
		return fileContents;
	}

	public void setFileContents(String fileContents) {
		this.fileContents = fileContents;
	}

	public byte[] getBlobContent() {
		return blobContent;
	}

	public void setBlobContent(byte[] blobContent) {
		this.blobContent = blobContent;
	}

	public String getFileType() {
		return fileType;
	}

	public void setFileType(String fileType) {
		this.fileType = fileType;
	}

	public Date getFileDate() {
		return fileDate;
	}

	public void setFileDate(Date fileDate) {
		this.fileDate = fileDate;
	}

	public String getCrcValue() {
		return crcValue;
	}

	public void setCrcValue(String crcValue) {
		this.crcValue = crcValue;
	}

	public String getLocation() {
		return location;
	}

	public void setLocation(String location) {
		this.location = location;
	}

	public String getFilePurpose() {
		return filePurpose;
	}

	public void setFilePurpose(String filePurpose) {
		this.filePurpose = filePurpose;
	}

    public Integer getInstId() {
        return instId;
    }

    public void setInstId(Integer instId) {
        this.instId = instId;
    }
}
