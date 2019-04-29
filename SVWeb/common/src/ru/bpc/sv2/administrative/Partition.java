package ru.bpc.sv2.administrative;

import java.io.Serializable;
import java.util.Date;

import ru.bpc.sv2.invocation.ModelIdentifiable;

/**
 * Model Bean for List PMO Purposes page.
 */
public class Partition implements ModelIdentifiable, Serializable, Cloneable
{
	/**
	 * 
	 */
	private static final long	serialVersionUID	= 549943522920261631L;
	
	private Integer	id;
	private String	tableName;
	private String	partitionName;
	private Date	startDate;
	private Date	endDate;
	private Date	dropDate;
	
	public Partition()
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

	public String getTableName() {
		return tableName;
	}

	public void setTableName(String tableName) {
		this.tableName = tableName;
	}

	public String getPartitionName() {
		return partitionName;
	}

	public void setPartitionName(String partitionName) {
		this.partitionName = partitionName;
	}

	public Date getStartDate() {
		return startDate;
	}

	public void setStartDate(Date startDate) {
		this.startDate = startDate;
	}

	public Date getEndDate() {
		return endDate;
	}

	public void setEndDate(Date endDate) {
		this.endDate = endDate;
	}

	public Date getDropDate() {
		return dropDate;
	}

	public void setDropDate(Date dropDate) {
		this.dropDate = dropDate;
	}

	@Override
	public Object clone() throws CloneNotSupportedException {
		return super.clone();
	}

}