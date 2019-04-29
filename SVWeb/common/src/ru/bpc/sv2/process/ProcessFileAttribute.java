package ru.bpc.sv2.process;

import ru.bpc.sv2.constants.schedule.ProcessConstants;
import ru.bpc.sv2.invocation.IAuditableObject;
import ru.bpc.sv2.invocation.ModelIdentifiable;
import ru.bpc.sv2.process.file.LineSeparator;

import java.io.Serializable;
import java.util.HashMap;
import java.util.Map;

public class ProcessFileAttribute implements ModelIdentifiable, Serializable, Cloneable, IAuditableObject {
	private static final long serialVersionUID = 1L;

	private Long id;
	private String name;
	private Integer instId;
	private String instName;
	private Integer fileId;
	private String fileName;
	private String fileType;

	private String type;
	private String format;
	private String characterSet;
	private String fileNameMask;
	private Boolean uploadEmptyFile;
	private String location;
	private Long locationId;

	private Integer containerId;
	private Integer processId;
	private String processName;
	private Integer containerBindId;

	private String xsltSource;
	private String xmlSource;
	private String xsdSource;

	private String fileNature;

	private String converterClass;
	private String saverClass;
	private String postSaverClass;
	private Integer nameFormatId;
	private String nameFormatLabel;
	private String purpose;

	private Long recordCount;
	private Long sessionId;

	private long fileContentLength;
	private long fileBContentLength;

	private Boolean isTar;
	private Boolean isZip;
	private String processFileName;

	private Integer reportId;
	private Integer reportTemplateId;
	private String reportName;
	private String reportTemplateName;
	private Long processSessionId;

	private Integer loadPriority;
	private String signatureType;
	private String encryptionPlugin;
	private String fileEncryptionKey;
	private Boolean fileEncryptionKeyExists;
	private boolean modifyEncryptionKey;

	private boolean ignoreFileErrors;
	private Long fileAttributeId;
	private String status;
	private Integer parallelDegree;

	private Boolean isFileNameUnique;
	private Boolean isFileRequired;
	private Boolean isCleanupData;

	private String queueIdentifier;
	private Integer timeWait;

	private Integer threadNumber;
	private LineSeparator lineSeparator;

	private Boolean isPasswordProtect;
	private String password;

	private String mergeFileMode;

	public ProcessFileAttribute() {}

	public ProcessFileAttribute(ProcessFileAttribute file){
		id = file.getId();
		name = file.getName();
		instId = file.getInstId();
		fileId = file.getFileId();
		type = file.getType();
		format = file.getFormat();
		characterSet = file.getCharacterSet();
		fileNameMask = file.getFileNameMask();
		uploadEmptyFile = file.getUploadEmptyFile();
		location = file.getLocation();
		processId = file.getProcessId();
		xsltSource = file.getXsltSource();
		xmlSource = file.getXmlSource();
		fileNature = file.fileNature;
		xsdSource = file.getXsdSource();
		converterClass = file.getConverterClass();
		saverClass = file.getSaverClass();
		postSaverClass = file.getPostSaverClass();
		isTar = file.getIsTar();
		isZip = file.getIsZip();
		reportId = file.getReportId();
		reportTemplateId = file.getReportTemplateId();
		reportName = file.getReportName();
		reportTemplateName = file.getReportTemplateName();
		isFileNameUnique = file.getIsFileNameUnique();
		isFileRequired = file.getIsFileRequired();
		isCleanupData = file.getIsCleanupData();
		lineSeparator = file.getLineSeparator();
		isPasswordProtect = file.getIsPasswordProtect();
		mergeFileMode = file.getMergeFileMode();
	}

	public Long getId() {
		return id;
	}
	public void setId(Long id) {
		this.id = id;
	}

	public String getName() {
		return name;
	}
	public void setName(String name) {
		this.name = name;
	}

	public Integer getInstId() {
		return instId;
	}
	public void setInstId(Integer instId) {
		this.instId = instId;
	}

	public String getFormat() {
		return format;
	}
	public void setFormat(String format) {
		this.format = format;
	}

	public String getCharacterSet() {
		return characterSet;
	}
	public void setCharacterSet(String characterSet) {
		this.characterSet = characterSet;
	}

	public String getFileNameMask() {
		return fileNameMask;
	}
	public void setFileNameMask(String fileNameMask) {
		this.fileNameMask = fileNameMask;
	}

	public Boolean getUploadEmptyFile() {
		if (uploadEmptyFile == null) uploadEmptyFile = Boolean.FALSE;
		return uploadEmptyFile;
	}
	public void setUploadEmptyFile(Boolean uploadEmptyFile) {
		this.uploadEmptyFile = uploadEmptyFile;
	}

	public String getLocation() {
		return location;
	}
	public void setLocation(String location) {
		this.location = location;
	}

	public Integer getFileId() {
		return fileId;
	}
	public void setFileId(Integer fileId) {
		this.fileId = fileId;
	}

	public Integer getProcessId() {
		return processId;
	}
	public void setProcessId(Integer processId) {
		this.processId = processId;
	}

	public String getXsltSource() {
		return xsltSource;
	}
	public void setXsltSource(String xsltSource) {
		this.xsltSource = xsltSource;
	}

	public String getXmlSource() {
		return xmlSource;
	}
	public void setXmlSource(String xmlSource) {
		this.xmlSource = xmlSource;
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

	public String getConverterClass() {
		return converterClass;
	}
	public void setConverterClass(String converterClass) {
		this.converterClass = converterClass;
	}

	public String getSaverClass() {
		return saverClass;
	}
	public void setSaverClass(String saverClass) {
		this.saverClass = saverClass;
	}

	public String getPostSaverClass() {
		return postSaverClass;
	}
	public void setPostSaverClass(String postSaverClass) {
		this.postSaverClass = postSaverClass;
	}

	public String getXsdSource() {
		return xsdSource;
	}
	public void setXsdSource(String xsdSource) {
		this.xsdSource = xsdSource;
	}

	public String getNameFormatLabel() {
		return nameFormatLabel;
	}
	public void setNameFormatLabel(String nameFormatLabel) {
		this.nameFormatLabel = nameFormatLabel;
	}

	public String getInstName() {
		return instName;
	}
	public void setInstName(String instName) {
		this.instName = instName;
	}

	public String getPurpose() {
		return purpose;
	}
	public void setPurpose(String purpose) {
		this.purpose = purpose;
	}

	public Integer getContainerBindId() {
		return containerBindId;
	}
	public void setContainerBindId(Integer containerBindId) {
		this.containerBindId = containerBindId;
	}

	public String getFileName() {
		return fileName;
	}
	public void setFileName(String fileName) {
		this.fileName = fileName;
	}

	public String getProcessName() {
		return processName;
	}
	public void setProcessName(String processName) {
		this.processName = processName;
	}

	public Integer getContainerId() {
		return containerId;
	}
	public void setContainerId(Integer containerId) {
		this.containerId = containerId;
	}

	public boolean isIncoming() {
		return (ProcessConstants.FILE_PURPOSE_INCOMING.equals(purpose));
	}

	public boolean isOutgoing() {
		return (ProcessConstants.FILE_PURPOSE_OUTGOING.equals(purpose));
	}

	public Integer getNameFormatId() {
		return nameFormatId;
	}
	public void setNameFormatId(Integer nameFormatId) {
		this.nameFormatId = nameFormatId;
	}

	public Long getRecordCount() {
		return recordCount;
	}
	public void setRecordCount(Long recordCount) {
		this.recordCount = recordCount;
	}

	public Long getSessionId() {
		return sessionId;
	}
	public void setSessionId(Long sessionId) {
		this.sessionId = sessionId;
	}

	public String getFileType() {
		return fileType;
	}
	public void setFileType(String fileType) {
		this.fileType = fileType;
	}

	public boolean isXml() {
		return ProcessConstants.FILE_NATURE_XML.equals(fileNature);
	}

	public boolean isLob() {
		return ProcessConstants.FILE_NATURE_LOB.equals(fileNature);
	}
	
	public boolean isBlob() {
		return ProcessConstants.FILE_NATURE_BLOB.equals(fileNature);
	}

	public boolean isPlain() {
		return ProcessConstants.FILE_NATURE_PLAIN.equals(fileNature);
	}
	
	public boolean isReport() {
		return ProcessConstants.FILE_NATURE_REPORT.equals(fileNature);
	}

	public Boolean getIsTar() {
		if (isTar == null) isTar = Boolean.FALSE;
		return isTar;
	}
	public void setIsTar(Boolean isTar) {
		this.isTar = isTar;
	}

	public Boolean getIsZip() {
		if (isZip == null) isZip = Boolean.FALSE;
		return isZip;
	}
	public void setIsZip(Boolean isZip) {
		this.isZip = isZip;
	}

	public String getProcessFileName() {
		return processFileName;
	}
	public void setProcessFileName(String processFileName) {
		this.processFileName = processFileName;
	}

	public Integer getReportId() {
		return reportId;
	}
	public void setReportId(Integer reportId) {
		this.reportId = reportId;
	}

	public Integer getReportTemplateId() {
		return reportTemplateId;
	}
	public void setReportTemplateId(Integer reportTemplateId) {
		this.reportTemplateId = reportTemplateId;
	}

	public String getReportName() {
		return reportName;
	}
	public void setReportName(String reportName) {
		this.reportName = reportName;
	}

	public String getReportTemplateName() {
		return reportTemplateName;
	}
	public void setReportTemplateName(String reportTemplateName) {
		this.reportTemplateName = reportTemplateName;
	}

	public Long getProcessSessionId() {
		return processSessionId;
	}
	public void setProcessSessionId(Long processSessionId) {
		this.processSessionId = processSessionId;
	}

	public Integer getLoadPriority() {
		return loadPriority;
	}
	public void setLoadPriority(Integer loadPriority) {
		this.loadPriority = loadPriority;
	}

	public String getSignatureType() {
		return signatureType;
	}
	public void setSignatureType(String signatureType) {
		this.signatureType = signatureType;
	}

	public String getEncryptionPlugin() {
		return encryptionPlugin;
	}
	public void setEncryptionPlugin(String encryptionPlugin) {
		this.encryptionPlugin = encryptionPlugin;
	}
	
	public boolean isSigned() {
		return signatureType != null && !signatureType.trim().isEmpty()
				&& !ProcessConstants.NO_FILE_SIGNATURE.equals(signatureType);
	}

	public String getFileEncryptionKey() {
		return fileEncryptionKey;
	}
	public void setFileEncryptionKey(String fileEncryptionKey) {
		this.fileEncryptionKey = fileEncryptionKey;
	}

	public Boolean getFileEncryptionKeyExists() {
		return fileEncryptionKeyExists;
	}
	public void setFileEncryptionKeyExists(Boolean fileEncryptionKeyExists) {
		this.fileEncryptionKeyExists = fileEncryptionKeyExists;
	}

	public boolean isModifyEncryptionKey() {
		return modifyEncryptionKey;
	}
	public void setModifyEncryptionKey(boolean modifyEncryptionKey) {
		this.modifyEncryptionKey = modifyEncryptionKey;
	}

	public boolean isIgnoreFileErrors() {
		return ignoreFileErrors;
	}
	public void setIgnoreFileErrors(boolean ignoreFileErrors) {
		this.ignoreFileErrors = ignoreFileErrors;
	}

	public Long getFileAttributeId() {
		return fileAttributeId;
	}
	public void setFileAttributeId(Long fileAttributeId) {
		this.fileAttributeId = fileAttributeId;
	}

	public String getStatus() {
		return status;
	}
	public void setStatus(String status) {
		this.status = status;
	}

	public Long getLocationId() {
		return locationId;
	}
	public void setLocationId(Long locationId) {
		this.locationId = locationId;
		if (this.locationId == null) {
			setLocation(null);
		}
	}

	public Integer getParallelDegree() {
		return parallelDegree;
	}
	public void setParallelDegree(Integer parallelDegree) {
		this.parallelDegree = parallelDegree;
	}
	
	public Boolean getIsFileNameUnique() {
		if (isFileNameUnique == null) isFileNameUnique = Boolean.TRUE;
		return isFileNameUnique;
	}
	public void setIsFileNameUnique(Boolean isFileNameUnique) {
		this.isFileNameUnique = isFileNameUnique;
	}

	public Boolean getIsFileRequired() {
        return isFileRequired == null ? Boolean.FALSE : isFileRequired;
    }
    public void setIsFileRequired(Boolean isFileRequired) {
        this.isFileRequired = isFileRequired;
    }

    public long getFileContentLength() {
        return fileContentLength;
    }
    public void setFileContentLength(Long fileContentLength) {
        this.fileContentLength = fileContentLength != null ? fileContentLength : 0L;
    }

    public long getFileBContentLength() {
        return fileBContentLength;
    }
    public void setFileBContentLength(Long fileBContentLength) {
        this.fileBContentLength = fileBContentLength != null ? fileBContentLength : 0L;
    }

	public String getQueueIdentifier() {
		return queueIdentifier;
	}
	public void setQueueIdentifier(String queueIdentifier) {
		this.queueIdentifier = queueIdentifier;
	}

	public Integer getTimeWait() {
		return timeWait;
	}
	public void setTimeWait(Integer timeWait) {
		this.timeWait = timeWait;
	}

	public Integer getThreadNumber() {
		return threadNumber;
	}
	public void setThreadNumber(Integer threadNumber) {
		this.threadNumber = threadNumber;
	}

	public Boolean getIsCleanupData() {
		return isCleanupData == null ? Boolean.FALSE : isCleanupData;
	}
	public void setIsCleanupData(Boolean isCleanupData) {
		this.isCleanupData = isCleanupData;
	}

	public boolean isEmpty() {
		return getFileContentLength() == 0L && getFileBContentLength() == 0L;
	}

	public LineSeparator getLineSeparator() {
		return lineSeparator;
	}
	public void setLineSeparator(LineSeparator lineSeparator) {
		this.lineSeparator = lineSeparator;
	}

	public boolean isReportSet() {
		return (reportId != null) ? true : false;
	}

	public Boolean getIsPasswordProtect() {
		if (isPasswordProtect == null) {
			isPasswordProtect = Boolean.FALSE;
		}
		return isPasswordProtect;
	}
	public void setIsPasswordProtect(Boolean isPasswordProtect) {
		this.isPasswordProtect = isPasswordProtect;
	}

	public String getPassword() {
		return password;
	}
	public void setPassword(String password) {
		this.password = password;
	}

	public String getMergeFileMode() {
		return mergeFileMode;
	}
	public void setMergeFileMode(String mergeFileMode) {
		this.mergeFileMode = mergeFileMode;
	}

	@Override
	public Map<String, Object> getAuditParameters() {
		Map<String, Object> result = new HashMap<String, Object>();
		result.put("id", getId());
		result.put("fileId", getFileId());
		result.put("containerBindId", getContainerBindId());
		result.put("characterSet", getCharacterSet());
		result.put("fileNameMask", getFileNameMask());
		result.put("nameFormatId", getNameFormatId());
		result.put("uploadEmptyFile", getUploadEmptyFile());
		result.put("location", getLocation());
		result.put("converterClass", getConverterClass());
		result.put("saverClass", getSaverClass());
		result.put("postSaverClass", getPostSaverClass());
		result.put("isTar", getIsTar());
		result.put("isZip", getIsZip());
		result.put("instId", getInstId());
		result.put("reportId", getReportId());
		result.put("reportTemplateId", getReportTemplateId());
		result.put("loadPriority", getLoadPriority());
		result.put("signatureType", getSignatureType());
		result.put("encryptionPlugin", getEncryptionPlugin());
		result.put("ignoreFileErrors", isIgnoreFileErrors());
		result.put("parallelDegree", getParallelDegree());
		result.put("lineSeparator", getLineSeparator());
		result.put("isPasswordProtect", getIsPasswordProtect());
		result.put("mergeFileMode", getMergeFileMode());
		return result;
	}
	@Override
	public ProcessFileAttribute clone() throws CloneNotSupportedException {
		return (ProcessFileAttribute)super.clone();
	}
	@Override
	public Object getModelId() {
		return getId() + "_" + getFileId() +  "_" + getContainerBindId();
	}
}
