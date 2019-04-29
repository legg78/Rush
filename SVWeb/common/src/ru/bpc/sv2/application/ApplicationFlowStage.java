package ru.bpc.sv2.application;

import java.io.Serializable;
import java.util.HashMap;
import java.util.Map;

import org.apache.commons.lang3.StringUtils;
import ru.bpc.sv2.invocation.IAuditableObject;
import ru.bpc.sv2.invocation.ModelIdentifiable;

public class ApplicationFlowStage implements ModelIdentifiable, Serializable, Cloneable, IAuditableObject {
	public static final String STAGE_RESULT_SUCCESS = "STRT0010";
	public static final String STAGE_RESULT_FAIL = "STRT0020";

	private static final long serialVersionUID = -4991241886310869900L;
	private Long id;
	private String appStatus;
	private Integer flowId;
	private String flowName;
	private Integer seqnum;
	private String handler;
	private String handlerType;
	private String rejectCode;
	private Integer roleId;
	private String roleName;

	public Long getId() {
		return id;
	}
	public void setId(Long id) {
		this.id = id;
	}

	public String getAppStatus() {
		return appStatus;
	}
	public void setAppStatus(String appStatus) {
		this.appStatus = appStatus;
	}

	public Integer getFlowId() {
		return flowId;
	}
	public void setFlowId(Integer flowId) {
		this.flowId = flowId;
	}

	public String getFlowName() {
		return flowName;
	}
	public void setFlowName(String flowName) {
		this.flowName = flowName;
	}

	public Integer getSeqnum() {
		return seqnum;
	}
	public void setSeqnum(Integer seqnum) {
		this.seqnum = seqnum;
	}

	public String getHandler() {
		return handler;
	}
	public void setHandler(String handler) {
		this.handler = handler;
	}

	public String getHandlerType() {
		return handlerType;
	}
	public void setHandlerType(String handlerType) {
		this.handlerType = handlerType;
	}

	public String getRejectCode() {
		return rejectCode;
	}
	public void setRejectCode(String rejectCode) {
		this.rejectCode = rejectCode;
	}

	public Integer getRoleId() {
		return roleId;
	}
	public void setRoleId(Integer roleId) {
		this.roleId = roleId;
	}

	public String getRoleName() {
		return roleName;
	}
	public void setRoleName(String roleName) {
		this.roleName = roleName;
	}

	@Override
	public Object getModelId() {
		return getId();
	}
	@Override
	public ApplicationFlowStage clone() throws CloneNotSupportedException {
		return (ApplicationFlowStage) super.clone();
	}
	@Override
	public Map<String, Object> getAuditParameters() {
		Map<String, Object> result = new HashMap<String, Object>();
		result.put("appStatus", this.getAppStatus());
		result.put("handlerType", this.getHandlerType());
		result.put("handler", this.getHandler());
		return result;
	}

	public String getStatusRejectLabel(Map<String, String> descriptions) {
		if (StringUtils.isEmpty(getAppStatus())) {
			return null;
		}
		String status = getAppStatus() + " - " + descriptions.get(getAppStatus());
		if (StringUtils.isNotEmpty(getRejectCode())) {
			status += " (" + getRejectCode() + " - " + descriptions.get(getRejectCode()) + ")";
		}
		return status;
	}
}

