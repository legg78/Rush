package ru.bpc.sv2.pmo;

import java.io.Serializable;

import ru.bpc.sv2.invocation.ModelIdentifiable;

/**
 * Model Bean for List PMO Purposes tab.
 */
public class PmoObjectPurpose extends PmoPurpose implements ModelIdentifiable, Serializable, Cloneable
{
	/**
	 * 
	 */
	private static final long	serialVersionUID	= 549943522920261631L;
	
	/* for filter using */
	private String entityType;
	private Long objectId;
	
	public PmoObjectPurpose()
	{
	}
	
	@Override
	public Object clone() throws CloneNotSupportedException {
		return super.clone();
	}

	public String getEntityType() {
		return entityType;
	}

	public void setEntityType(String entityType) {
		this.entityType = entityType;
	}

	public Long getObjectId() {
		return objectId;
	}

	public void setObjectId(Long objectId) {
		this.objectId = objectId;
	}

}