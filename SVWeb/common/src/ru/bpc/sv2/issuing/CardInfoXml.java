package ru.bpc.sv2.issuing;

import java.io.Serializable;

public class CardInfoXml implements Serializable {
	private Long batchId;
	private String xml;

	public Long getBatchId() {
		return batchId;
	}

	public void setBatchId(Long batchId) {
		this.batchId = batchId;
	}

	public String getXml() {
		return xml;
	}

	public void setXml(String xml) {
		this.xml = xml;
	}
}
