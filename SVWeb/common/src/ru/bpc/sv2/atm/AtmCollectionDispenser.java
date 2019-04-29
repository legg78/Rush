package ru.bpc.sv2.atm;

import java.io.Serializable;

import ru.bpc.sv2.invocation.ModelIdentifiable;

public class AtmCollectionDispenser extends AtmDispenser implements Serializable, ModelIdentifiable {

	private static final long serialVersionUID = 1L;

	private Long collectionId;

	public Long getCollectionId() {
		return collectionId;
	}

	public void setCollectionId(Long collectionId) {
		this.collectionId = collectionId;
	}

	public Object getModelId() {
		return getCollectionId() + "_" + getDispNumber();
	}
}
