package ru.bpc.sv2.scheduler.process.jcb.plain;

public class StopDataHeader {
	private String dateOfIssue;
	private String fileName;

	public String getDateOfIssue() {
		return dateOfIssue;
	}

	public void setDateOfIssue(String dateOfIssue) {
		this.dateOfIssue = dateOfIssue;
	}

	public String getFileName() {
		return fileName;
	}

	public void setFileName(String fileName) {
		this.fileName = fileName;
	}
}
