package ru.bpc.sv2.fcl.cycles;

import java.io.Serializable;
import java.util.Date;

import ru.bpc.sv2.invocation.ModelIdentifiable;

public class CycleCounter implements Serializable, ModelIdentifiable, Cloneable{

	private static final long serialVersionUID = 1L;

	private Long id;
	private String entityType;
	private Long objectId;
	private String cycleType;
	private Date prevDate;
	private Date nextDate;
	private Integer periodNumber;
	private Integer splitHash;
	private Integer instId;
	
	public CycleCounter(){
		
	}
	
	public CycleCounter (CycleCounter counter) {
		this.id = counter.getId();
		this.entityType = counter.getEntityType();
		this.objectId = counter.getObjectId();
		this.cycleType = counter.getCycleType();
		this.prevDate = counter.getPrevDate();
		this.nextDate = counter.getNextDate();
		this.periodNumber = counter.getPeriodNumber();
		this.splitHash = counter.getSplitHash();
		this.instId = counter.getInstId();
	}
	
	public Object getModelId() {
		return getId();
	}

	public Long getId() {
		return id;
	}

	public void setId(Long id) {
		this.id = id;
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

	public String getCycleType() {
		return cycleType;
	}

	public void setCycleType(String cycleType) {
		this.cycleType = cycleType;
	}

	public Date getPrevDate() {
		return prevDate;
	}

	public void setPrevDate(Date prevDate) {
		this.prevDate = prevDate;
	}

	public Date getNextDate() {
		return nextDate;
	}

	public void setNextDate(Date nextDate) {
		this.nextDate = nextDate;
	}

	public Integer getPeriodNumber() {
		return periodNumber;
	}

	public void setPeriodNumber(Integer periodNumber) {
		this.periodNumber = periodNumber;
	}

	public Integer getSplitHash() {
		return splitHash;
	}

	public void setSplitHash(Integer splitHash) {
		this.splitHash = splitHash;
	}

	public Integer getInstId() {
		return instId;
	}

	public void setInstId(Integer instId) {
		this.instId = instId;
	}

	public CycleCounter clone(){
		CycleCounter result = null;
		try {
			result = (CycleCounter)super.clone();
		} catch (CloneNotSupportedException e) {
			e.printStackTrace();
		}
		return result;
	}
}
