package ru.bpc.sv2.logic;

import com.ibatis.sqlmap.client.SqlMapSession;
import org.apache.log4j.Logger;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.controller.CommonController;
import ru.bpc.sv2.logic.utility.db.IbatisAware;
import ru.bpc.sv2.logic.utility.db.IbatisSessionCallback;
import ru.bpc.sv2.survey.Questionary;
import ru.bpc.sv2.survey.SurveyQstnParameterValue;
import ru.bpc.sv2.survey.SurveyPrivConstants;
import ru.bpc.sv2.survey.configuration.Survey;
import ru.bpc.sv2.survey.configuration.SurveyParameter;
import ru.bpc.sv2.survey.configuration.SurveyParameterEntity;
import ru.bpc.sv2.survey.configuration.SurveyParameterRelation;
import ru.bpc.sv2.utils.AuditParamUtil;

import java.util.List;

public class SurveysDao extends IbatisAware {
	private static final Logger logger = Logger.getLogger(SurveysDao.class);

	public Questionary getQuestionaryById(Long userSessionId, String lang, Long id) {
		SelectionParams params = SelectionParams.build("lang", lang, "id", id);
		params.setRowIndexStart(0);
		params.setRowIndexEnd(1);

		List<Questionary> list = getQuestionaries(userSessionId, params);
		if (list.isEmpty()) {
			return null;
		}
		return list.get(0);
	}

	public List<Questionary> getQuestionaries(Long userSessionId, final SelectionParams params) {
		return executeWithSession(userSessionId,
				SurveyPrivConstants.VIEW_SURVEY_QUESTIONARIES,
				params,
				logger,
				new IbatisSessionCallback<List<Questionary>>() {
					@Override
					public List<Questionary> doInSession(SqlMapSession ssn) throws Exception {
						String limitation = CommonController.getLimitationByPriv(ssn, SurveyPrivConstants.VIEW_SURVEY_QUESTIONARIES);
						return ssn.queryForList("survey.get-survey-questionaries", convertQueryParams(params, limitation));
					}
				});
	}

	public int getQuestionariesCount(Long userSessionId, final SelectionParams params) {
		return executeWithSession(userSessionId,
				SurveyPrivConstants.VIEW_SURVEY_QUESTIONARIES,
				params,
				logger,
				new IbatisSessionCallback<Integer>() {
					@Override
					public Integer doInSession(SqlMapSession ssn) throws Exception {
						String limitation = CommonController.getLimitationByPriv(ssn, SurveyPrivConstants.VIEW_SURVEY_QUESTIONARIES);
						return (Integer) ssn.queryForObject("survey.get-survey-questionaries-count", convertQueryParams(params, limitation));
					}
				});
	}


	public List<SurveyQstnParameterValue> getQstnParameterValues(Long userSessionId, final SelectionParams params) {
		return executeWithSession(userSessionId,
				SurveyPrivConstants.VIEW_SURVEY_QUESTIONARIES,
				params,
				logger,
				new IbatisSessionCallback<List<SurveyQstnParameterValue>>() {
					@Override
					public List<SurveyQstnParameterValue> doInSession(SqlMapSession ssn) throws Exception {
						String limitation = CommonController.getLimitationByPriv(ssn, SurveyPrivConstants.VIEW_SURVEY_QUESTIONARIES);
						return ssn.queryForList("survey.get-survey-qstn-parameter-values", convertQueryParams(params, limitation));
					}
				});
	}

	public int getQstnParameterValuesCount(Long userSessionId, final SelectionParams params) {
		return executeWithSession(userSessionId,
				SurveyPrivConstants.VIEW_SURVEY_QUESTIONARIES,
				params,
				logger,
				new IbatisSessionCallback<Integer>() {
					@Override
					public Integer doInSession(SqlMapSession ssn) throws Exception {
						String limitation = CommonController.getLimitationByPriv(ssn, SurveyPrivConstants.VIEW_SURVEY_QUESTIONARIES);
						return (Integer) ssn.queryForObject("survey.get-survey-qstn-parameter-values-count", convertQueryParams(params, limitation));
					}
				});
	}


	public SurveyParameter getParameterById(Long userSessionId, String lang, Long id) {
		SelectionParams params = SelectionParams.build("lang", lang, "id", id);
		params.setRowIndexStart(0);
		params.setRowIndexEnd(1);

		List<SurveyParameter> list = getParameters(userSessionId, params);
		if (list.isEmpty()) {
			return null;
		}
		return list.get(0);
	}

	public List<SurveyParameter> getParameters(Long userSessionId, final SelectionParams params) {
		return executeWithSession(userSessionId,
				SurveyPrivConstants.VIEW_SURVEY_PARAMETERS,
				params,
				logger,
				new IbatisSessionCallback<List<SurveyParameter>>() {
					@Override
					public List<SurveyParameter> doInSession(SqlMapSession ssn) throws Exception {
						String limitation = CommonController.getLimitationByPriv(ssn, SurveyPrivConstants.VIEW_SURVEY_PARAMETERS);
						return ssn.queryForList("survey.get-survey-parameters", convertQueryParams(params, limitation));
					}
				});
	}

	public int getParametersCount(Long userSessionId, final SelectionParams params) {
		return executeWithSession(userSessionId,
				SurveyPrivConstants.VIEW_SURVEY_PARAMETERS,
				params,
				logger,
				new IbatisSessionCallback<Integer>() {
					@Override
					public Integer doInSession(SqlMapSession ssn) throws Exception {
						String limitation = CommonController.getLimitationByPriv(ssn, SurveyPrivConstants.VIEW_SURVEY_PARAMETERS);
						return (Integer) ssn.queryForObject("survey.get-survey-parameters-count", convertQueryParams(params, limitation));
					}
				});
	}



	public SurveyParameter addParameter(final Long userSessionId, final SurveyParameter item) {
		return executeWithSession(userSessionId,
				SurveyPrivConstants.ADD_SURVEY_PARAMETERS,
				AuditParamUtil.getCommonParamRec(item.getAuditParameters()),
				logger,
				new IbatisSessionCallback<SurveyParameter>() {
					@Override
					public SurveyParameter doInSession(SqlMapSession ssn) throws Exception {
						ssn.update("survey.add-survey-parameter", item);
						return getParameterById(userSessionId, item.getLang(), item.getId());
					}
				});

	}

	public SurveyParameter modifyParameter(final Long userSessionId, final SurveyParameter item) {
		return executeWithSession(userSessionId,
				SurveyPrivConstants.MODIFY_SURVEY_PARAMETERS,
				AuditParamUtil.getCommonParamRec(item.getAuditParameters()),
				logger,
				new IbatisSessionCallback<SurveyParameter>() {
					@Override
					public SurveyParameter doInSession(SqlMapSession ssn) throws Exception {
						ssn.update("survey.modify-survey-parameter", item);
						return getParameterById(userSessionId, item.getLang(), item.getId());
					}
				});
	}


	public void removeParameter(Long userSessionId, final SurveyParameter item) {
		executeWithSession(userSessionId,
				SurveyPrivConstants.REMOVE_SURVEY_PARAMETERS,
				AuditParamUtil.getCommonParamRec(item.getAuditParameters()),
				logger,
				new IbatisSessionCallback<Void>() {
					@Override
					public Void doInSession(SqlMapSession ssn) throws Exception {
						ssn.update("survey.remove-survey-parameter", item);
						return null;
					}
				});
	}


	public Survey getSurveyById(Long userSessionId, String lang, Long id) {
		SelectionParams params = SelectionParams.build("lang", lang, "id", id);
		params.setRowIndexStart(0);
		params.setRowIndexEnd(1);

		List<Survey> list = getSurveys(userSessionId, params);
		if (list.isEmpty()) {
			return null;
		}
		return list.get(0);
	}

	public List<Survey> getSurveys(Long userSessionId, final SelectionParams params) {
		return executeWithSession(userSessionId,
				SurveyPrivConstants.VIEW_SURVEYS,
				params,
				logger,
				new IbatisSessionCallback<List<Survey>>() {
					@Override
					public List<Survey> doInSession(SqlMapSession ssn) throws Exception {
						String limitation = CommonController.getLimitationByPriv(ssn, SurveyPrivConstants.VIEW_SURVEYS);
						return ssn.queryForList("survey.get-surveys", convertQueryParams(params, limitation));
					}
				});
	}

	public int getSurveysCount(Long userSessionId, final SelectionParams params) {
		return executeWithSession(userSessionId,
				SurveyPrivConstants.VIEW_SURVEYS,
				params,
				logger,
				new IbatisSessionCallback<Integer>() {
					@Override
					public Integer doInSession(SqlMapSession ssn) throws Exception {
						String limitation = CommonController.getLimitationByPriv(ssn, SurveyPrivConstants.VIEW_SURVEYS);
						return (Integer) ssn.queryForObject("survey.get-surveys-count", convertQueryParams(params, limitation));
					}
				});
	}


	public Survey addSurvey(final Long userSessionId, final Survey item) {
		return executeWithSession(userSessionId,
				SurveyPrivConstants.ADD_SURVEYS,
				AuditParamUtil.getCommonParamRec(item.getAuditParameters()),
				logger,
				new IbatisSessionCallback<Survey>() {
					@Override
					public Survey doInSession(SqlMapSession ssn) throws Exception {
						ssn.update("survey.add-survey", item);
						return getSurveyById(userSessionId, item.getLang(), item.getId());
					}
				});

	}

	public Survey modifySurvey(final Long userSessionId, final Survey item) {
		return executeWithSession(userSessionId,
				SurveyPrivConstants.MODIFY_SURVEYS,
				AuditParamUtil.getCommonParamRec(item.getAuditParameters()),
				logger,
				new IbatisSessionCallback<Survey>() {
					@Override
					public Survey doInSession(SqlMapSession ssn) throws Exception {
						ssn.update("survey.modify-survey", item);
						return getSurveyById(userSessionId, item.getLang(), item.getId());
					}
				});
	}


	public void removeSurvey(Long userSessionId, final Survey item) {
		executeWithSession(userSessionId,
				SurveyPrivConstants.REMOVE_SURVEYS,
				AuditParamUtil.getCommonParamRec(item.getAuditParameters()),
				logger,
				new IbatisSessionCallback<Void>() {
					@Override
					public Void doInSession(SqlMapSession ssn) throws Exception {
						ssn.update("survey.remove-survey", item);
						return null;
					}
				});
	}




	public SurveyParameterRelation getSurveyParameterRelationById(Long userSessionId, String lang, Long id) {
		SelectionParams params = SelectionParams.build("lang", lang, "id", id);
		params.setRowIndexStart(0);
		params.setRowIndexEnd(1);

		List<SurveyParameterRelation> list = getSurveyParameterRelations(userSessionId, params);
		if (list.isEmpty()) {
			return null;
		}
		return list.get(0);
	}


	public List<SurveyParameterRelation> getSurveyParameterRelations(Long userSessionId, final SelectionParams params) {
		return executeWithSession(userSessionId,
				SurveyPrivConstants.VIEW_SURVEYS,
				params,
				logger,
				new IbatisSessionCallback<List<SurveyParameterRelation>>() {
					@Override
					public List<SurveyParameterRelation> doInSession(SqlMapSession ssn) throws Exception {
						String limitation = CommonController.getLimitationByPriv(ssn, SurveyPrivConstants.VIEW_SURVEYS);
						return ssn.queryForList("survey.get-survey-parameter-relations", convertQueryParams(params, limitation));
					}
				});
	}


	public int getSurveyParameterRelationsCount(Long userSessionId, final SelectionParams params) {
		return executeWithSession(userSessionId,
				SurveyPrivConstants.VIEW_SURVEYS,
				params,
				logger,
				new IbatisSessionCallback<Integer>() {
					@Override
					public Integer doInSession(SqlMapSession ssn) throws Exception {
						String limitation = CommonController.getLimitationByPriv(ssn, SurveyPrivConstants.VIEW_SURVEYS);
						return (Integer) ssn.queryForObject("survey.get-survey-parameter-relations-count", convertQueryParams(params, limitation));
					}
				});
	}


	public SurveyParameterRelation addSurveyParameterRelation(final Long userSessionId, final SurveyParameterRelation item) {
		return executeWithSession(userSessionId,
				SurveyPrivConstants.MODIFY_SURVEYS,
				AuditParamUtil.getCommonParamRec(item.getAuditParameters()),
				logger,
				new IbatisSessionCallback<SurveyParameterRelation>() {
					@Override
					public SurveyParameterRelation doInSession(SqlMapSession ssn) throws Exception {
						ssn.update("survey.add-survey-parameter-relation", item);
						return getSurveyParameterRelationById(userSessionId, item.getLang(), item.getId());
					}
				});
	}

	public void removeSurveyParameterRelation(Long userSessionId, final SurveyParameterRelation item) {
		executeWithSession(userSessionId,
				SurveyPrivConstants.MODIFY_SURVEYS,
				AuditParamUtil.getCommonParamRec(item.getAuditParameters()),
				logger,
				new IbatisSessionCallback<Void>() {
					@Override
					public Void doInSession(SqlMapSession ssn) throws Exception {
						ssn.update("survey.remove-survey-parameter-relation", item);
						return null;
					}
				});
	}



	public SurveyParameterEntity getParameterEntityById(Long userSessionId, String lang, Long id) {
		SelectionParams params = SelectionParams.build("lang", lang, "id", id);
		params.setRowIndexStart(0);
		params.setRowIndexEnd(1);

		List<SurveyParameterEntity> list = getParameterEntities(userSessionId, params);
		if (list.isEmpty()) {
			return null;
		}
		return list.get(0);
	}


	public List<SurveyParameterEntity> getParameterEntities(Long userSessionId, final SelectionParams params) {
		return executeWithSession(userSessionId,
				SurveyPrivConstants.VIEW_SURVEY_PARAMETERS,
				params,
				logger,
				new IbatisSessionCallback<List<SurveyParameterEntity>>() {
					@Override
					public List<SurveyParameterEntity> doInSession(SqlMapSession ssn) throws Exception {
						String limitation = CommonController.getLimitationByPriv(ssn, SurveyPrivConstants.VIEW_SURVEY_PARAMETERS);
						return ssn.queryForList("survey.get-survey-parameter-entities", convertQueryParams(params, limitation));
					}
				});
	}

	public int getParameterEntitiesCount(Long userSessionId, final SelectionParams params) {
		return executeWithSession(userSessionId,
				SurveyPrivConstants.VIEW_SURVEY_PARAMETERS,
				params,
				logger,
				new IbatisSessionCallback<Integer>() {
					@Override
					public Integer doInSession(SqlMapSession ssn) throws Exception {
						String limitation = CommonController.getLimitationByPriv(ssn, SurveyPrivConstants.VIEW_SURVEY_PARAMETERS);
						return (Integer) ssn.queryForObject("survey.get-survey-parameter-entities-count", convertQueryParams(params, limitation));
					}
				});
	}

	public SurveyParameterEntity addParameterEntity(final Long userSessionId, final SurveyParameterEntity item) {
		return executeWithSession(userSessionId,
				SurveyPrivConstants.MODIFY_SURVEY_PARAMETERS,
				AuditParamUtil.getCommonParamRec(item.getAuditParameters()),
				logger,
				new IbatisSessionCallback<SurveyParameterEntity>() {
					@Override
					public SurveyParameterEntity doInSession(SqlMapSession ssn) throws Exception {
						ssn.update("survey.add-survey-parameter-entity", item);

						return getParameterEntityById(userSessionId, item.getLang(), item.getId());
					}
				});

	}

	public void removeParameterEntity(Long userSessionId, final SurveyParameterEntity item) {
		executeWithSession(userSessionId,
				SurveyPrivConstants.MODIFY_SURVEY_PARAMETERS,
				AuditParamUtil.getCommonParamRec(item.getAuditParameters()),
				logger,
				new IbatisSessionCallback<Void>() {
					@Override
					public Void doInSession(SqlMapSession ssn) throws Exception {
						ssn.update("survey.remove-survey-parameter-entity", item);
						return null;
					}
				});
	}
}
