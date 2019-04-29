package ru.bpc.sv2.ui.survey.configuration;

import org.apache.log4j.Logger;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.FilterBuilder;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.SurveysDao;
import ru.bpc.sv2.survey.configuration.SurveyParameter;
import ru.bpc.sv2.ui.utils.AbstractSearchBean;

import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@ViewScoped
@ManagedBean(name = "MbSurveyParametersModalSearch")
public class MbSurveyParametersModalSearch extends AbstractSearchBean<SurveyParameter, SurveyParameter> {
	private static final Logger logger = Logger.getLogger(MbSurveyParametersModalSearch.class);

	private SurveysDao surveysDao = new SurveysDao();

	private String entityType = null;


	@Override
	protected SurveyParameter createFilter() {
		return new SurveyParameter();
	}

	@Override
	protected Logger getLogger() {
		return logger;
	}

	@Override
	protected SurveyParameter addItem(SurveyParameter item) {
		return null;
	}

	@Override
	protected SurveyParameter editItem(SurveyParameter item) {
		return null;
	}

	@Override
	protected void deleteItem(SurveyParameter item) {

	}

	@Override
	protected void initFilters(SurveyParameter filter, List<Filter> filters) {
		Map<String, Object> map = new HashMap<>();
		map.put("lang", curLang);

		map.putAll(FilterBuilder.createMapFromBean(filter));

		for (String key: MbSurveyParametersSearch.MASKED_FILTERS) {
			if (map.containsKey(key)) {
				Object value = map.get(key);
				map.put(key, Filter.mask((String) value));
			}
		}

		if (entityType != null) {
			map.put("entityType", entityType);
		}

		filters.addAll(FilterBuilder.createFiltersFromMap(map, FilterBuilder.FilterMode.ALL_TO_STRING));
	}

	@Override
	protected List<SurveyParameter> getObjectList(Long userSessionId, SelectionParams params) {
		return surveysDao.getParameters(userSessionId, params);
	}

	@Override
	protected int getObjectCount(Long userSessionId, SelectionParams params) {
		return surveysDao.getParametersCount(userSessionId, params);
	}

	public void clear() {
		clearFilter();
		entityType = null;
	}

	public String getEntityType() {
		return entityType;
	}

	public void setEntityType(String entityType) {
		this.entityType = entityType;
	}



}
