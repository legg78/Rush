package ru.bpc.sv2.cup;

import java.io.Serializable;

public class FileContents implements Serializable {
	private String filename;
	private String content;

	public String getFilename() {
		return filename;
	}

	public void setFilename(String filename) {
		this.filename = filename;
	}

	public String getContent() {
		return content;
	}

	public void setContent(String content) {
		this.content = content;
	}
}
