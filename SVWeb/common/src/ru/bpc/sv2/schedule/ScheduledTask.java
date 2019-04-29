package ru.bpc.sv2.schedule;

import java.io.Serializable;
import java.util.HashMap;
import java.util.Map;

import ru.bpc.sv2.invocation.IAuditableObject;
import ru.bpc.sv2.invocation.ModelIdentifiable;
import ru.bpc.sv2.utils.UserException;

public class ScheduledTask implements Serializable, ModelIdentifiable, Cloneable, IAuditableObject {
	private static final long serialVersionUID = 1L;

	protected CronFormatter _cronFormatter = null;

	private Integer id;
	private Integer prcId;
	private String prcType;
	private String cronString;
	private boolean active;
	private boolean stopOnFatal;
	private Integer groupId;
	private Integer containerId;
	private String shortDesc;
	private String fullDesc;
	private String lang;
	private String alias;
	private boolean skipHolidays;

	private Long timePeriod; //need for SimpleTrigger in errorMode. Repeat period for re-executing task in minutes 
	private Long timeActive; //need for SimpleTrigger in errorMode. Active period for errorMode in minutes

	public ScheduledTask() {}

	public String getFormedCronString() throws CronFormatException {
		if (_cronFormatter == null) {
			throw new CronFormatException("Cron formatter is not defined");
		}
		return _cronFormatter.formCronString();
	}

	public void setFormedCronString(String formedCronString) throws UserException {
		try {
			this._cronFormatter = CronFormatter.createCronFormatter(formedCronString);
		} catch (CronFormatException e) {
			String msg = e.getMessage();
			Integer containerId = prcId;
			UserException exception = new UserException(msg);
			exception.setDetails(containerId);
			throw exception;
		}
	}

	public CronFormatter getCronFormatter() {
		if (_cronFormatter == null) {
			_cronFormatter = new CronFormatter();
		}
		return _cronFormatter;
	}
	public void setCronFormatter(CronFormatter cronFormatter) {
		this._cronFormatter = cronFormatter;
	}

	public Integer getId() {
		return id;
	}
	public void setId(Integer id) {
		this.id = id;
	}

	public Integer getPrcId() {
		return prcId;
	}
	public void setPrcId(Integer prcId) {
		this.prcId = prcId;
	}

	public String getPrcType() {
		return prcType;
	}
	public void setPrcType(String prcType) {
		this.prcType = prcType;
	}

	public String getCronString() {
		return cronString;
	}
	public void setCronString(String cronString) {
		this.cronString = cronString;
	}

	public boolean isActive() {
		return active;
	}
	public void setActive(boolean active) {
		this.active = active;
	}

	public boolean isStopOnFatal() {
		return stopOnFatal;
	}
	public void setStopOnFatal(boolean stopOnFatal) {
		this.stopOnFatal = stopOnFatal;
	}

	public Integer getGroupId() {
		return groupId;
	}
	public void setGroupId(Integer groupId) {
		this.groupId = groupId;
	}

	public Integer getContainerId() {
		return containerId;
	}
	public void setContainerId(Integer containerId) {
		this.containerId = containerId;
	}

	public String getShortDesc() {
		return shortDesc;
	}
	public void setShortDesc(String shortDesc) {
		this.shortDesc = shortDesc;
	}

	public String getFullDesc() {
		return fullDesc;
	}
	public void setFullDesc(String fullDesc) {
		this.fullDesc = fullDesc;
	}

	public String getAlias() {
		alias = "process_" + getPrcId()+"_id_" + getId();
		return alias;
	}
	public void setAlias(String alias) {
		this.alias = alias;
	}

	public String getLang() {
		return lang;
	}
	public void setLang(String lang) {
		this.lang = lang;
	}

	public Long getTimePeriod() {
		return timePeriod;
	}
	public void setTimePeriod(Long timePeriod) {
		this.timePeriod = timePeriod;
	}

	public Long getTimeActive() {
		return timeActive;
	}
	public void setTimeActive(Long timeActive) {
		this.timeActive = timeActive;
	}

	public boolean isSkipHolidays() {
		return skipHolidays;
	}
	public void setSkipHolidays(Boolean skipHolidays) {
		this.skipHolidays = (skipHolidays == null) ? false : skipHolidays.booleanValue();
	}

	@Override
	public Object getModelId() {
		return getId();
	}
	@Override
	public ScheduledTask clone() throws CloneNotSupportedException {
		return (ScheduledTask)super.clone();
	}
	@Override
	public Map<String, Object> getAuditParameters() {
		Map<String, Object> result = new HashMap<String, Object>();
		result.put("id", getId());
		result.put("prcId", getPrcId());
		result.put("cronString", getCronString());
		result.put("active", isActive());
		result.put("timeActive", getTimeActive());
		result.put("timePeriod", getTimePeriod());
		result.put("shortDesc", getShortDesc());
		result.put("fullDesc", getFullDesc());
		result.put("skipHolidays", isSkipHolidays());
		result.put("lang", getLang());
		return result;
	}
}
