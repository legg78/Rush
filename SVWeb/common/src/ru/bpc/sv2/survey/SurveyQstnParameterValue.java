package ru.bpc.sv2.survey;

import ru.bpc.sv2.invocation.IAuditableObject;
import ru.bpc.sv2.invocation.ModelIdentifiable;

import java.io.Serializable;
import java.util.HashMap;
import java.util.Map;

public class SurveyQstnParameterValue implements Serializable, ModelIdentifiable, Cloneable, IAuditableObject {
	private static final long serialVersionUID = 1L;


	private Long id;
	private Integer seqnum;
	private Long questionaryId;
	private Long paramId;
	private String paramName;
	private String paramNameText;
	private String paramValue;
	private Integer seqNumber;
	private String lang;


	@Override
	public Map<String, Object> getAuditParameters() {
		Map<String, Object> result = new HashMap<String, Object>();
		result.put("id", getId());
		result.put("seqnum", getSeqnum());
		result.put("questionaryId", getQuestionaryId());
		result.put("paramId", getParamId());
		result.put("paramName", getParamName());
		result.put("paramNameText", getParamNameText());
		result.put("paramValue", getParamValue());
		result.put("seqNumber", getSeqNumber());
		result.put("lang", getLang());
		return result;
	}

	@Override
	public Object getModelId() {
		return getId();
	}

	@Override
	public SurveyQstnParameterValue clone() throws CloneNotSupportedException {
		return (SurveyQstnParameterValue) super.clone();
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

	public Long getQuestionaryId() {
		return questionaryId;
	}

	public void setQuestionaryId(Long questionaryId) {
		this.questionaryId = questionaryId;
	}

	public Long getParamId() {
		return paramId;
	}

	public void setParamId(Long paramId) {
		this.paramId = paramId;
	}

	public String getParamName() {
		return paramName;
	}

	public void setParamName(String paramName) {
		this.paramName = paramName;
	}

	public String getParamNameText() {
		return paramNameText;
	}

	public void setParamNameText(String paramNameText) {
		this.paramNameText = paramNameText;
	}

	public String getParamValue() {
		return paramValue;
	}

	public void setParamValue(String paramValue) {
		this.paramValue = paramValue;
	}

	public Integer getSeqNumber() {
		return seqNumber;
	}

	public void setSeqNumber(Integer seqNumber) {
		this.seqNumber = seqNumber;
	}

	public String getLang() {
		return lang;
	}

	public void setLang(String lang) {
		this.lang = lang;
	}
}
