package ru.bpc.sv2.process;

import ru.bpc.sv2.invocation.ModelIdentifiable;

import java.io.Serializable;
import java.util.Date;

public class ProcessSchedule implements ModelIdentifiable, Serializable, Cloneable {
    private static final long serialVersionUID = 1L;

    private Long id;
    private String name;
    private Integer instId;
    private Long sessionId;
    private String instName;
    private boolean holidaySkipped;
    private boolean active;
    private Date plannedTime;
    private Date startTime;
    private Date endTime;
    private String status;
    private String statusDesc;
    private String description;

    public Long getId() {
        return id;
    }
    public void setId(Long id) {
        this.id = id;
    }

    public String getName() {
        return name;
    }
    public void setName(String name) {
        this.name = name;
    }

    public Integer getInstId() {
        return instId;
    }
    public void setInstId(Integer instId) {
        this.instId = instId;
    }

    public Long getSessionId() {
        return sessionId;
    }
    public void setSessionId(Long sessionId) {
        this.sessionId = sessionId;
    }

    public String getInstName() {
        return instName;
    }
    public void setInstName(String instName) {
        this.instName = instName;
    }

    public boolean isHolidaySkipped() {
        return holidaySkipped;
    }
    public void setHolidaySkipped(boolean holidaySkipped) {
        this.holidaySkipped = holidaySkipped;
    }

    public boolean isActive() {
        return active;
    }
    public void setActive(boolean active) {
        this.active = active;
    }

    public Date getPlannedTime() {
        return plannedTime;
    }
    public void setPlannedTime(Date plannedTime) {
        this.plannedTime = plannedTime;
    }

    public Date getStartTime() {
        return startTime;
    }
    public void setStartTime(Date startTime) {
        this.startTime = startTime;
    }

    public Date getEndTime() {
        return endTime;
    }
    public void setEndTime(Date endTime) {
        this.endTime = endTime;
    }

    public String getStatus() {
        return status;
    }
    public void setStatus(String status) {
        this.status = status;
    }

    public String getStatusDesc() {
        return statusDesc;
    }
    public void setStatusDesc(String statusDesc) {
        this.statusDesc = statusDesc;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    @Override
    public Object getModelId() {
        return id + "_" + instId + "_" + plannedTime;
    }
    @Override
    public Object clone() throws CloneNotSupportedException {
        return super.clone();
    }
}
