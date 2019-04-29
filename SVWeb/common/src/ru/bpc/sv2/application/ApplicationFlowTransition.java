package ru.bpc.sv2.application;

import java.io.Serializable;
import java.util.HashMap;
import java.util.Map;

import org.apache.commons.lang3.StringUtils;
import ru.bpc.sv2.invocation.IAuditableObject;
import ru.bpc.sv2.invocation.ModelIdentifiable;

public class ApplicationFlowTransition implements ModelIdentifiable, Serializable, Cloneable, IAuditableObject {
	private static final long serialVersionUID = 1L;

	private Long id;
	private Integer flowId;
	private String preStatus;
	private String appStatus;
	private String preStatusName;
	private String appStatusName;
	private Integer seqnum;
	private Integer stageId;
	private Integer transitionStageId;
	private String stageResult;
	private String eventType;
	private String eventTypeName;
	private String reasonCode;

    private String appRejectCode;
    private String appRejectName;
    private String preRejectCode;
    private String preRejectName;

	public Long getId() {
		return id;
	}
	public void setId(Long id) {
		this.id = id;
	}

	public Integer getFlowId() {
		return flowId;
	}
	public void setFlowId(Integer flowId) {
		this.flowId = flowId;
	}

	public String getPreStatus() {
		return preStatus;
	}
	public void setPreStatus(String preStatus) {
		this.preStatus = preStatus;
	}

	public String getAppStatus() {
		return appStatus;
	}
	public void setAppStatus(String appStatus) {
		this.appStatus = appStatus;
	}

	public String getPreStatusName() {
		return preStatusName;
	}
	public void setPreStatusName(String preStatusName) {
		this.preStatusName = preStatusName;
	}

	public String getAppStatusName() {
		return appStatusName;
	}
	public void setAppStatusName(String appStatusName) {
		this.appStatusName = appStatusName;
	}

	public Integer getSeqnum() {
		return seqnum;
	}
	public void setSeqnum(Integer seqnum) {
		this.seqnum = seqnum;
	}

	public Integer getStageId() {
		return stageId;
	}
	public void setStageId(Integer stageId) {
		this.stageId = stageId;
	}

	public Integer getTransitionStageId() {
		return transitionStageId;
	}
	public void setTransitionStageId(Integer transitionStageId) {
		this.transitionStageId = transitionStageId;
	}

	public String getStageResult() {
		return stageResult;
	}
	public void setStageResult(String stageResult) {
		this.stageResult = stageResult;
	}

	public String getEventType() {
		return eventType;
	}
	public void setEventType(String eventType) {
		this.eventType = eventType;
	}

	public String getEventTypeName() {
		return eventTypeName;
	}
	public void setEventTypeName(String eventTypeName) {
		this.eventTypeName = eventTypeName;
	}

	public String getReasonCode() {
		return reasonCode;
	}
	public void setReasonCode(String reasonCode) {
		this.reasonCode = reasonCode;
	}

	@Override
	public Object getModelId() {
		return getId();
	}
	@Override
	public ApplicationFlowTransition clone() throws CloneNotSupportedException {
		return (ApplicationFlowTransition) super.clone();
	}
	@Override
	public Map<String, Object> getAuditParameters() {
		Map<String, Object> result = new HashMap<String, Object>();
		result.put("stageId", this.getStageId());
		result.put("transitionStageId", this.getTransitionStageId());
		result.put("stageResult", this.getStageResult());
		
		return result;
	}

    public String getAppRejectCode() {
        return appRejectCode;
    }

    public void setAppRejectCode(String appRejectCode) {
        this.appRejectCode = appRejectCode;
    }

    public String getAppRejectName() {
        return appRejectName;
    }

    public void setAppRejectName(String appRejectName) {
        this.appRejectName = appRejectName;
    }

    public String getPreRejectCode() {
        return preRejectCode;
    }

    public void setPreRejectCode(String preRejectCode) {
        this.preRejectCode = preRejectCode;
    }

    public String getPreRejectName() {
        return preRejectName;
    }

    public void setPreRejectName(String preRejectName) {
        this.preRejectName = preRejectName;
    }

    public String getPreStatusRejectLabel() {
	    String statusLabel = getKeyValueLabel(getPreStatus(), getPreStatusName());
        String rejectLabel = getKeyValueLabel(getPreRejectCode(), getPreRejectName());
        return getStatusLabel(statusLabel, rejectLabel);
    }


    public String getAppStatusRejectLabel() {
        String statusLabel = getKeyValueLabel(getAppStatus(), getAppStatusName());
        String rejectLabel = getKeyValueLabel(getAppRejectCode(), getAppRejectName());
        return getStatusLabel(statusLabel, rejectLabel);
    }

	public String getAppStatusRejectCode() {
		String status = getAppStatus();
		if (StringUtils.isNotEmpty(status) && StringUtils.isNotEmpty(getAppRejectCode())) {
			status += getAppRejectCode();
		}
		return status;
	}

    private String getStatusLabel(String statusLabel, String rejectLabel) {
        if (StringUtils.isAllEmpty(statusLabel, rejectLabel)) {
            return null;
        } else if (StringUtils.isEmpty(statusLabel)) {
            return rejectLabel;
        } else if (StringUtils.isEmpty(rejectLabel)) {
            return statusLabel;
        }
        return statusLabel + " (" + rejectLabel + ")";
    }

    private String getKeyValueLabel(String key, String value) {
        if (StringUtils.isEmpty(key)) {
            return null;
        }
        return key + " - " + value;
    }

	public static ApplicationFlowTransition createByStatusReject(String status, String rejectCode, Map<String, String> descriptions) {
		ApplicationFlowTransition transition = new ApplicationFlowTransition();

		transition.setAppStatus(status);
		if (descriptions != null && StringUtils.isNotEmpty(status)) {
			transition.setAppStatusName(descriptions.get(status));
		}

		transition.setAppRejectCode(rejectCode);
		if (descriptions != null && StringUtils.isNotEmpty(rejectCode)) {
			transition.setAppRejectName(descriptions.get(rejectCode));
		}

		return transition;
	}
}
