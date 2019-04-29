package ru.bpc.sv2.interchange;

import ru.bpc.sv2.invocation.TreeIdentifiable;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

public class FeeCriteria extends ModuleItem
		implements TreeIdentifiable<FeeCriteria>, Cloneable, Serializable, Comparable<FeeCriteria> {
	private long id;
	private String name;
	private String feeType;
	private String modifier;
	private Long parentId;
	private Long feeId;
	private Date startDate;
	private Date endDate;
	private Integer priority;
	private Boolean status;
	private String issCountry;
	private String issRegion;
	private String acqCountry;
	private String acqRegion;
	private String operType;
	//tree support
	private int level;
	private List<FeeCriteria> children=new ArrayList<FeeCriteria>();

	public String getOperType() {
		return operType;
	}

	public void setOperType(String operType) {
		this.operType = operType;
	}

	public String getIssCountry() {
		return issCountry;
	}

	public void setIssCountry(String issCountry) {
		this.issCountry = issCountry;
	}

	public String getIssRegion() {
		return issRegion;
	}

	public void setIssRegion(String issRegion) {
		this.issRegion = issRegion;
	}

	public String getAcqCountry() {
		return acqCountry;
	}

	public void setAcqCountry(String acqCountry) {
		this.acqCountry = acqCountry;
	}

	public String getAcqRegion() {
		return acqRegion;
	}

	public void setAcqRegion(String acqRegion) {
		this.acqRegion = acqRegion;
	}

	@Override
	public Long getId() {
		return id;
	}

	public void setId(long id) {
		this.id = id;
	}

	public String getName() {
		return name;
	}

	public void setName(String name) {
		this.name = name;
	}

	public String getFeeType() {
		return feeType;
	}

	public void setFeeType(String feeType) {
		this.feeType = feeType;
	}

	public String getModifier() {
		return modifier;
	}

	public void setModifier(String modifier) {
		this.modifier = modifier;
	}

	@Override
	public int getLevel() {
		return level;
	}

	public void setLevel(int level) {
		this.level = level;
	}

	@Override
	public List<FeeCriteria> getChildren() {
		return children;
	}

	@Override
	public void setChildren(List<FeeCriteria> children) {
		this.children = children;
	}

	@Override
	public boolean isHasChildren() {
		return children != null && !children.isEmpty();
	}

	@Override
	public Long getParentId() {
		return parentId;
	}

	public void setParentId(Long parentId) {
		this.parentId = parentId;
	}

	public Long getFeeId() {
		return feeId;
	}

	public void setFeeId(Long feeId) {
		this.feeId = feeId;
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

	public Integer getPriority() {
		return priority;
	}

	public void setPriority(Integer priority) {
		this.priority = priority;
	}

	public Boolean getStatus() {
		return status;
	}

	public void setStatus(Boolean status) {
		this.status = status;
	}

	@Override
	public int compareTo(FeeCriteria o) {
		if (priority == null || priority < o.priority) {
			return 1;
		}
		if (o.priority == null || priority > o.priority) {
			return -1;
		}
		return 0;
	}

	@Override
	public Object getModelId() {
		return id;
	}
}
