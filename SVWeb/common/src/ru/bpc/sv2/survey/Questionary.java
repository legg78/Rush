package ru.bpc.sv2.survey;

import ru.bpc.sv2.invocation.IAuditableObject;
import ru.bpc.sv2.invocation.ModelIdentifiable;

import java.io.Serializable;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;

public class Questionary implements Serializable, ModelIdentifiable, Cloneable, IAuditableObject {
	private static final long serialVersionUID = 1L;

	private Long id;
	private Integer seqnum;
	private Integer instId;

	private Long objectId;
	private String objectNumber;

	private Long surveyId;
	private String surveyNumber;
	private String surveyStatus;
	private String surveyStatusName;

	private String entityType;
	private String entityTypeName;

	private String questionaryNumber;
	private String questionaryStatus;
	private String questionaryStatusName;

	private Date creationDate;
	private Date closureDate;

	private String lang;

	@Override
	public Map<String, Object> getAuditParameters() {
		Map<String, Object> result = new HashMap<String, Object>();
		result.put("id", getId());
		result.put("instId", getInstId());
		result.put("objectId", getObjectId());
		result.put("objectNumber", getObjectNumber());
		result.put("surveyId", getSurveyId());
		result.put("surveyNumber", getSurveyNumber());
		result.put("surveyStatus", getSurveyStatus());
		result.put("entityType", getEntityType());
		result.put("questionaryNumber", getQuestionaryNumber());
		result.put("questionaryStatus", getQuestionaryStatus());
		result.put("lang", getLang());
		return result;
	}

	@Override
	public Object getModelId() {
		return getId();
	}

	@Override
	public Questionary clone() throws CloneNotSupportedException {
		return (Questionary) super.clone();
	}

	public Long getId() {
		return id;
	}

	public void setId(Long id) {
		this.id = id;
	}

	public Integer getSeqnum() {
		return seqnum;
	}

	public void setSeqnum(Integer seqnum) {
		this.seqnum = seqnum;
	}

	public Integer getInstId() {
		return instId;
	}

	public void setInstId(Integer instId) {
		this.instId = instId;
	}

	public Long getObjectId() {
		return objectId;
	}

	public void setObjectId(Long objectId) {
		this.objectId = objectId;
	}

	public Long getSurveyId() {
		return surveyId;
	}

	public void setSurveyId(Long surveyId) {
		this.surveyId = surveyId;
	}

	public String getSurveyNumber() {
		return surveyNumber;
	}

	public void setSurveyNumber(String surveyNumber) {
		this.surveyNumber = surveyNumber;
	}

	public String getSurveyStatus() {
		return surveyStatus;
	}

	public void setSurveyStatus(String surveyStatus) {
		this.surveyStatus = surveyStatus;
	}

	public String getSurveyStatusName() {
		return surveyStatusName;
	}

	public void setSurveyStatusName(String surveyStatusName) {
		this.surveyStatusName = surveyStatusName;
	}

	public String getEntityType() {
		return entityType;
	}

	public void setEntityType(String entityType) {
		this.entityType = entityType;
	}

	public String getEntityTypeName() {
		return entityTypeName;
	}

	public void setEntityTypeName(String entityTypeName) {
		this.entityTypeName = entityTypeName;
	}

	public String getQuestionaryNumber() {
		return questionaryNumber;
	}

	public void setQuestionaryNumber(String questionaryNumber) {
		this.questionaryNumber = questionaryNumber;
	}

	public String getQuestionaryStatus() {
		return questionaryStatus;
	}

	public void setQuestionaryStatus(String questionaryStatus) {
		this.questionaryStatus = questionaryStatus;
	}

	public String getQuestionaryStatusName() {
		return questionaryStatusName;
	}

	public void setQuestionaryStatusName(String questionaryStatusName) {
		this.questionaryStatusName = questionaryStatusName;
	}

	public Date getCreationDate() {
		return creationDate;
	}

	public void setCreationDate(Date creationDate) {
		this.creationDate = creationDate;
	}

	public Date getClosureDate() {
		return closureDate;
	}

	public void setClosureDate(Date closureDate) {
		this.closureDate = closureDate;
	}

	public String getLang() {
		return lang;
	}

	public void setLang(String lang) {
		this.lang = lang;
	}

	public String getObjectNumber() {
		return objectNumber;
	}

	public void setObjectNumber(String objectNumber) {
		this.objectNumber = objectNumber;
	}
}
