package ru.bpc.sv2.survey.configuration;

import java.util.Map;

public class SurveyParameterRelation extends SurveyParameter {
	private static final long serialVersionUID = 1L;

	private Long surveyId;
	private Long paramId;

	@Override
	public Map<String, Object> getAuditParameters() {
		Map<String, Object> result = super.getAuditParameters();
		result.put("surveyId", getSurveyId());
		result.put("paramId", getParamId());

		return result;
	}


	public Long getSurveyId() {
		return surveyId;
	}

	public void setSurveyId(Long surveyId) {
		this.surveyId = surveyId;
	}

	public Long getParamId() {
		return paramId;
	}

	public void setParamId(Long paramId) {
		this.paramId = paramId;
	}
}
