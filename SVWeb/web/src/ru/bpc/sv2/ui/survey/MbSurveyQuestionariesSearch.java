package ru.bpc.sv2.ui.survey;

import org.apache.log4j.Logger;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.FilterBuilder;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.SurveysDao;
import ru.bpc.sv2.survey.Questionary;
import ru.bpc.sv2.ui.utils.AbstractSearchTabbedBean;

import javax.annotation.PostConstruct;
import javax.faces.bean.ManagedBean;
import javax.faces.bean.ManagedProperty;
import javax.faces.bean.ViewScoped;
import javax.faces.model.SelectItem;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@ViewScoped
@ManagedBean(name = "MbSurveyQuestionariesSearch")
public class MbSurveyQuestionariesSearch extends AbstractSearchTabbedBean<Questionary, Questionary> {
	private static final long serialVersionUID = 1L;

	private static final Logger logger = Logger.getLogger(MbSurveyQuestionariesSearch.class);
	private static final List<String> MASKED_FILTERS = Arrays.asList("surveyNumber", "questionaryNumber");
	private static final String PARAMS_TAB = "paramsTab";

	private SurveysDao surveysDao = new SurveysDao();

	@ManagedProperty("#{MbSurveyQstnParameterValuesSearch}")
	private MbSurveyQstnParameterValuesSearch parameterValuesSearch;

	@Override
	@PostConstruct
	public void init() {
		super.init();
		pageLink = "survey|questionary";
	}


	@Override
	protected void onLoadTab(String tabName) {
		if (PARAMS_TAB.equals(tabName)) {
			parameterValuesSearch.clearFilter();
			parameterValuesSearch.setQuestionary(getActiveItem());
			parameterValuesSearch.search();
		}
	}

	@Override
	protected Questionary createFilter() {
		return new Questionary();
	}

	@Override
	protected Logger getLogger() {
		return logger;
	}

	@Override
	protected Questionary addItem(Questionary item) {
		return null;
	}

	@Override
	protected Questionary editItem(Questionary item) {
		return null;
	}

	@Override
	protected void deleteItem(Questionary item) {

	}

	@Override
	protected void initFilters(Questionary filter, List<Filter> filters) {
		Map<String, Object> map = new HashMap<>();
		map.put("lang", curLang);

		map.putAll(FilterBuilder.createMapFromBean(filter));

		for (String key: MASKED_FILTERS) {
			if (map.containsKey(key)) {
				Object value = map.get(key);
				map.put(key, Filter.mask((String) value));
			}
		}

		filters.addAll(FilterBuilder.createFiltersFromMap(map, FilterBuilder.FilterMode.ALL_TO_STRING));
	}

	@Override
	protected List<Questionary> getObjectList(Long userSessionId, SelectionParams params) {
		return surveysDao.getQuestionaries(userSessionId, params);
	}

	@Override
	protected int getObjectCount(Long userSessionId, SelectionParams params) {
		return surveysDao.getQuestionariesCount(userSessionId, params);
	}

	@Override
	public void clearState() {
		super.clearState();
		parameterValuesSearch.clearFilter();
	}


	public List<SelectItem> getStatuses() {
		return getDictUtils().getLov(LovConstants.QUESTIONARY_STATUS);
	}


	public void setParameterValuesSearch(MbSurveyQstnParameterValuesSearch parameterValuesSearch) {
		this.parameterValuesSearch = parameterValuesSearch;
	}
}
