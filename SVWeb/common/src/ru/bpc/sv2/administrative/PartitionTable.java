package ru.bpc.sv2.administrative;

import java.io.Serializable;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;

import ru.bpc.sv2.invocation.IAuditableObject;
import ru.bpc.sv2.invocation.ModelIdentifiable;

/**
 * Model Bean for List PMO Purposes page.
 */
public class PartitionTable implements ModelIdentifiable, IAuditableObject, Serializable, Cloneable
{
	/**
	 * 
	 */
	private static final long	serialVersionUID	= 549943522920261631L;
	
	private Integer	id;
	private Integer seqNum;
	private String	tableName;
	private Integer	partitionCycleId;
	private Integer	storageCycleId;
	private Date	nextPartitionDate;
	
	//need for filter
	private Date	nextPartitionDateFrom;
	private Date	nextPartitionDateTo;
	
	public PartitionTable()
	{
	}

	public Integer getId() {
		return id;
	}

	public void setId(Integer id) {
		this.id = id;
	}

	public Object getModelId() {
		return getId();
	}

	public Integer getSeqNum() {
		return seqNum;
	}

	public void setSeqNum(Integer seqNum) {
		this.seqNum = seqNum;
	}
	
	public String getTableName() {
		return tableName;
	}

	public void setTableName(String tableName) {
		this.tableName = tableName;
	}

	public Integer getPartitionCycleId() {
		return partitionCycleId;
	}

	public void setPartitionCycleId(Integer partitionCycleId) {
		this.partitionCycleId = partitionCycleId;
	}

	public Integer getStorageCycleId() {
		return storageCycleId;
	}

	public void setStorageCycleId(Integer storageCycleId) {
		this.storageCycleId = storageCycleId;
	}

	public Date getNextPartitionDate() {
		return nextPartitionDate;
	}

	public void setNextPartitionDate(Date nextPartitionDate) {
		this.nextPartitionDate = nextPartitionDate;
	}

	public Date getNextPartitionDateFrom() {
		return nextPartitionDateFrom;
	}

	public void setNextPartitionDateFrom(Date nextPartitionDateFrom) {
		this.nextPartitionDateFrom = nextPartitionDateFrom;
	}

	public Date getNextPartitionDateTo() {
		return nextPartitionDateTo;
	}

	public void setNextPartitionDateTo(Date nextPartitionDateTo) {
		this.nextPartitionDateTo = nextPartitionDateTo;
	}

	@Override
	public Object clone() throws CloneNotSupportedException {
		return super.clone();
	}

	@Override
	public Map<String, Object> getAuditParameters() {
		Map<String, Object> result = new HashMap<String, Object>();
		result.put("id", this.id);
		result.put("tableName", this.getTableName());
		result.put("partitionCycleId", this.getPartitionCycleId());
		result.put("storageCycleId", this.getStorageCycleId());
		result.put("nextPartitionDate", this.getNextPartitionDate());
		return result;
	}
	
}