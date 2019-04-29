package ru.bpc.sv2.ps;

import ru.bpc.sv2.invocation.ModelIdentifiable;
import ru.bpc.sv2.utils.PanUtils;

import java.io.Serializable;
import java.util.Date;

public class RejectOperation implements Serializable, ModelIdentifiable {
	private Long id;
	private Long origId;
	private String type;
	private Date processDate;
	private String origNetwork;
	private String dstNetwork;
	private String scheme;
	private String code;
	private String operType;
	private String assignedUserId;
	private String pan;
	private String arn;
	private String resolution;
	private Date resolutionDate;
	private String status;

	public Long getId() {
		return id;
	}

	public void setId(Long id) {
		this.id = id;
	}

	public Long getOrigId() {
		return origId;
	}

	public void setOrigId(Long origId) {
		this.origId = origId;
	}

	public String getType() {
		return type;
	}

	public void setType(String type) {
		this.type = type;
	}

	public Date getProcessDate() {
		return processDate;
	}

	public void setProcessDate(Date processDate) {
		this.processDate = processDate;
	}

	public String getOrigNetwork() {
		return origNetwork;
	}

	public void setOrigNetwork(String origNetwork) {
		this.origNetwork = origNetwork;
	}

	public String getDstNetwork() {
		return dstNetwork;
	}

	public void setDstNetwork(String dstNetwork) {
		this.dstNetwork = dstNetwork;
	}

	public String getScheme() {
		return scheme;
	}

	public void setScheme(String scheme) {
		this.scheme = scheme;
	}

	public String getCode() {
		return code;
	}

	public void setCode(String code) {
		this.code = code;
	}

	public String getOperType() {
		return operType;
	}

	public void setOperType(String operType) {
		this.operType = operType;
	}

	public String getAssignedUserId() {
		return assignedUserId;
	}

	public void setAssignedUserId(String assignedUserId) {
		this.assignedUserId = assignedUserId;
	}

	public String getPan() {
		return pan;
	}

	public void setPan(String pan) {
		this.pan = pan;
	}

	public String getArn() {
		return arn;
	}

	public void setArn(String arn) {
		this.arn = arn;
	}

	public String getResolution() {
		return resolution;
	}

	public void setResolution(String resolution) {
		this.resolution = resolution;
	}

	public Date getResolutionDate() {
		return resolutionDate;
	}

	public void setResolutionDate(Date resolutionDate) {
		this.resolutionDate = resolutionDate;
	}

	public String getStatus() {
		return status;
	}

	public void setStatus(String status) {
		this.status = status;
	}

	public String getPanMask() {
		return PanUtils.mask(pan);
	}

	@Override
	public String toString() {
		return "RejectOperation{" +
				"id=" + id +
				", origId=" + origId +
				", type=" + type +
				", processDate=" + processDate +
				", origNetwork=" + origNetwork +
				", dstNetwork=" + dstNetwork +
				", scheme='" + scheme + '\'' +
				", code='" + code + '\'' +
				", operType='" + operType + '\'' +
				", assignedUserId='" + assignedUserId + '\'' +
				", pan='" + pan + '\'' +
				", arn='" + arn + '\'' +
				", resolution='" + resolution + '\'' +
				", resolutionDate=" + resolutionDate +
				", status='" + status + '\'' +
				'}';
	}

	@Override
	public Object getModelId() {
		return id;
	}
}
