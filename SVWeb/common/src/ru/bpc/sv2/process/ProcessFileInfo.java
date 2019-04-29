package ru.bpc.sv2.process;

import java.io.Serializable;

public class ProcessFileInfo implements Serializable {
	private String characterset;
	private String fileNameMask;
	private String directoryPath;
	private String fileType;
	private String filePurpose;
	private Long nameFormatId;
	private Long saverId;

	public String getCharacterset() {
		return characterset;
	}

	public void setCharacterset(String characterset) {
		this.characterset = characterset;
	}

	public String getFileNameMask() {
		return fileNameMask;
	}

	public void setFileNameMask(String fileNameMask) {
		this.fileNameMask = fileNameMask;
	}

	public String getDirectoryPath() {
		return directoryPath;
	}

	public void setDirectoryPath(String directoryPath) {
		this.directoryPath = directoryPath;
	}

	public String getFileType() {
		return fileType;
	}

	public void setFileType(String fileType) {
		this.fileType = fileType;
	}

	public String getFilePurpose() {
		return filePurpose;
	}

	public void setFilePurpose(String filePurpose) {
		this.filePurpose = filePurpose;
	}

	public Long getNameFormatId() {
		return nameFormatId;
	}

	public void setNameFormatId(Long nameFormatId) {
		this.nameFormatId = nameFormatId;
	}

	public Long getSaverId() {
		return saverId;
	}

	public void setSaverId(Long saverId) {
		this.saverId = saverId;
	}
}
