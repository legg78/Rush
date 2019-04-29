package ru.bpc.sv2.common;

import java.io.Serializable;

public class ParticipantTableColumn extends TableColumn implements Serializable{
	private String partType;

	public String getPartType() {
		return partType;
	}

	public void setPartType(String partType) {
		this.partType = partType;
	}
}
