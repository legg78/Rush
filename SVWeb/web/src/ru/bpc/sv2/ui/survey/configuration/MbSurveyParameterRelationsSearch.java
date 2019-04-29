package ru.bpc.sv2.ui.survey.configuration;

import org.apache.log4j.Logger;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.FilterBuilder;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.SurveysDao;
import ru.bpc.sv2.survey.configuration.Survey;
import ru.bpc.sv2.survey.configuration.SurveyParameterRelation;
import ru.bpc.sv2.ui.utils.AbstractSearchAllBean;
import ru.bpc.sv2.ui.utils.FacesUtils;

import javax.faces.bean.ManagedBean;
import javax.faces.bean.ManagedProperty;
import javax.faces.bean.ViewScoped;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@ViewScoped
@ManagedBean(name = "MbSurveyParameterRelationsSearch")
public class MbSurveyParameterRelationsSearch extends AbstractSearchAllBean<SurveyParameterRelation, SurveyParameterRelation> {
	private static final Logger logger = Logger.getLogger(MbSurveyParameterRelationsSearch.class);

	private SurveysDao surveysDao = new SurveysDao();
	private SurveyParameterRelation newItem;

	private Survey survey;

	@ManagedProperty("#{MbSurveyParametersModalSearch}")
	private MbSurveyParametersModalSearch parametersModalSearch;


	@Override
	protected SurveyParameterRelation createFilter() {
		return new SurveyParameterRelation();
	}

	@Override
	protected Logger getLogger() {
		return logger;
	}

	@Override
	protected SurveyParameterRelation addItem(SurveyParameterRelation item) {
		return null;
	}

	@Override
	protected SurveyParameterRelation editItem(SurveyParameterRelation item) {
		return null;
	}

	@Override
	protected void deleteItem(SurveyParameterRelation item) {

	}

	@Override
	protected void initFilters(SurveyParameterRelation filter, List<Filter> filters) {
		Map<String, Object> map = new HashMap<>();
		map.put("lang", curLang);

		filter.setSurveyId(survey.getId());
		map.putAll(FilterBuilder.createMapFromBean(filter));

		filters.addAll(FilterBuilder.createFiltersFromMap(map, FilterBuilder.FilterMode.ALL_TO_STRING));
	}

	@Override
	protected List<SurveyParameterRelation> getObjectList(Long userSessionId, SelectionParams params) {
		return surveysDao.getSurveyParameterRelations(userSessionId, params);
	}

	@Override
	public void clearFilter() {
		super.clearFilter();
		survey = null;
	}


	public void prepareSearchParameters() {
		parametersModalSearch.clear();
		parametersModalSearch.setEntityType(getSurvey().getEntityType());
	}

	public void addItem() {
		try {
			if (parametersModalSearch.getActiveItem() == null || survey == null) {
				return;
			}

			SurveyParameterRelation newItem = new SurveyParameterRelation();
			newItem.setParamId(parametersModalSearch.getActiveItem().getId());
			newItem.setSurveyId(survey.getId());
			newItem.setLang(curLang);
			activeItem = surveysDao.addSurveyParameterRelation(userSessionId, newItem);
			tableRowSelection.addNewObjectToList(activeItem);
		} catch (Exception ee) {
			FacesUtils.addMessageError(ee);
			logger.error("", ee);
		}
	}

	public boolean isAddItemDisabled() {
		if (parametersModalSearch.getActiveItem() == null || getSurvey() == null) {
			return true;
		}

		SurveyParameterRelation filter = new SurveyParameterRelation();
		filter.setParamId(parametersModalSearch.getActiveItem().getId());
		filter.setSurveyId(getSurvey().getId());
		filter.setLang(userLang);

		List<Filter> filters = FilterBuilder.createFilters(filter, FilterBuilder.FilterMode.ALL_TO_STRING);
		SelectionParams params = new SelectionParams(0, 1, filters);
		return surveysDao.getSurveyParameterRelationsCount(userSessionId, params) > 0;
	}

	public void removeItem() {
		try {
			if (activeItem == null) {
				return;
			}
			surveysDao.removeSurveyParameterRelation(userSessionId, activeItem);
			dataModel.removeObjectFromList(activeItem);
			activeItem = null;
		} catch (Exception ee) {
			FacesUtils.addMessageError(ee);
			logger.error("", ee);
		}
	}

	public SurveyParameterRelation getNewItem() {
		if (newItem == null) {
			newItem = new SurveyParameterRelation();
		}
		return newItem;
	}

	public void setNewItem(SurveyParameterRelation newItem) {
		this.newItem = newItem;
	}

	public Survey getSurvey() {
		return survey;
	}

	public void setSurvey(Survey survey) {
		this.survey = survey;
	}


	public void setParametersModalSearch(MbSurveyParametersModalSearch parametersModalSearch) {
		this.parametersModalSearch = parametersModalSearch;
	}
}
