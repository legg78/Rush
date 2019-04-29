package ru.bpc.sv2.ui.survey;

import org.apache.log4j.Logger;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.FilterBuilder;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.SurveysDao;
import ru.bpc.sv2.survey.Questionary;
import ru.bpc.sv2.survey.SurveyQstnParameterValue;
import ru.bpc.sv2.ui.survey.configuration.MbSurveyParameterEntitiesSearch;
import ru.bpc.sv2.ui.utils.AbstractSearchAllBean;

import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@ViewScoped
@ManagedBean(name = "MbSurveyQstnParameterValuesSearch")
public class MbSurveyQstnParameterValuesSearch extends AbstractSearchAllBean<SurveyQstnParameterValue, SurveyQstnParameterValue> {
	private static final Logger logger = Logger.getLogger(MbSurveyParameterEntitiesSearch.class);

	private SurveysDao surveysDao = new SurveysDao();

	private Questionary questionary;


	@Override
	protected SurveyQstnParameterValue createFilter() {
		return new SurveyQstnParameterValue();
	}

	@Override
	protected Logger getLogger() {
		return logger;
	}

	@Override
	protected SurveyQstnParameterValue addItem(SurveyQstnParameterValue item) {
		return null;
	}

	@Override
	protected SurveyQstnParameterValue editItem(SurveyQstnParameterValue item) {
		return null;
	}

	@Override
	protected void deleteItem(SurveyQstnParameterValue item) {

	}

	@Override
	protected void initFilters(SurveyQstnParameterValue filter, List<Filter> filters) {
		Map<String, Object> map = new HashMap<>();
		map.put("lang", curLang);

		filter.setQuestionaryId(questionary.getId());
		map.putAll(FilterBuilder.createMapFromBean(filter));

		filters.addAll(FilterBuilder.createFiltersFromMap(map, FilterBuilder.FilterMode.ALL_TO_STRING));
	}

	@Override
	protected List<SurveyQstnParameterValue> getObjectList(Long userSessionId, SelectionParams params) {
		return surveysDao.getQstnParameterValues(userSessionId, params);
	}

	@Override
	public void clearFilter() {
		super.clearFilter();
		questionary = null;
	}

	public Questionary getQuestionary() {
		return questionary;
	}

	public void setQuestionary(Questionary questionary) {
		this.questionary = questionary;
	}
}
