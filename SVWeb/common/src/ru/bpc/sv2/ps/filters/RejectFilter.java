package ru.bpc.sv2.ps.filters;

import java.io.Serializable;
import java.util.Date;

public class RejectFilter implements Serializable {
	private String type;
	private String status;
	private String resolution;
	private String code;
	private Date processDate;
	private Date resolutionDate;
	private Integer origNetwork;
	private Integer dstNetwork;
	private String operType;
	private String pan;
	private Long id;
	private String arn;
	private String assigned;
	private String scheme;

	public Long getId() {
		return id;
	}

	public void setId(Long id) {
		this.id = id;
	}

	public String getArn() {
		return arn;
	}

	public void setArn(String arn) {
		this.arn = arn;
	}

	public String getAssigned() {
		return assigned;
	}

	public void setAssigned(String assigned) {
		this.assigned = assigned;
	}

	public String getScheme() {
		return scheme;
	}

	public void setScheme(String scheme) {
		this.scheme = scheme;
	}

	public String getType() {
		return type;
	}

	public void setType(String type) {
		this.type = type;
	}

	public String getStatus() {
		return status;
	}

	public void setStatus(String status) {
		this.status = status;
	}

	public String getResolution() {
		return resolution;
	}

	public void setResolution(String resolution) {
		this.resolution = resolution;
	}

	public String getCode() {
		return code;
	}

	public void setCode(String code) {
		this.code = code;
	}

	public Date getProcessDate() {
		return processDate;
	}

	public void setProcessDate(Date processDate) {
		this.processDate = processDate;
	}

	public Date getResolutionDate() {
		return resolutionDate;
	}

	public void setResolutionDate(Date resolutionDate) {
		this.resolutionDate = resolutionDate;
	}

	public Integer getOrigNetwork() {
		return origNetwork;
	}

	public void setOrigNetwork(Integer origNetwork) {
		this.origNetwork = origNetwork;
	}

	public Integer getDstNetwork() {
		return dstNetwork;
	}

	public void setDstNetwork(Integer dstNetwork) {
		this.dstNetwork = dstNetwork;
	}

	public String getOperType() {
		return operType;
	}

	public void setOperType(String operType) {
		this.operType = operType;
	}

	public String getPan() {
		return pan;
	}

	public void setPan(String pan) {
		this.pan = pan;
	}
}
