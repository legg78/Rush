package ru.bpc.sv2.reports;

import java.io.File;
import java.io.Serializable;

public class ReportResult implements Serializable {
	private Long runId;
	private boolean deterministic;
	private boolean alreadySaved;
	private String fileName;
	private String savePath;
	private File xmlFile;
	private QueryResult sqlData;
	private String processor;

	public Long getRunId() {
		return runId;
	}

	public void setRunId(Long runId) {
		this.runId = runId;
	}

	public boolean isDeterministic() {
		return deterministic;
	}

	public void setDeterministic(boolean deterministic) {
		this.deterministic = deterministic;
	}

	public boolean isAlreadySaved() {
		return alreadySaved;
	}

	public void setAlreadySaved(boolean alreadySaved) {
		this.alreadySaved = alreadySaved;
	}

	public String getFileName() {
		return fileName;
	}

	public void setFileName(String fileName) {
		this.fileName = fileName;
	}

	public String getSavePath() {
		return savePath;
	}

	public void setSavePath(String savePath) {
		this.savePath = savePath;
	}

	public File getXmlFile() {
		return xmlFile;
	}

	public void setXmlFile(File xmlFile) {
		this.xmlFile = xmlFile;
	}

	public QueryResult getSqlData() {
		return sqlData;
	}

	public void setSqlData(QueryResult sqlData) {
		this.sqlData = sqlData;
	}

	public String getProcessor() {
		return processor;
	}

	public void setProcessor(String processor) {
		this.processor = processor;
	}
}
