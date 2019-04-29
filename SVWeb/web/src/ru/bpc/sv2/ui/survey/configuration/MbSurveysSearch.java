package ru.bpc.sv2.ui.survey.configuration;


import org.apache.log4j.Logger;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.FilterBuilder;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.SurveysDao;
import ru.bpc.sv2.survey.configuration.Survey;
import ru.bpc.sv2.ui.utils.AbstractSearchTabbedBean;
import ru.bpc.sv2.ui.utils.FacesUtils;

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
@ManagedBean(name = "MbSurveysSearch")
public class MbSurveysSearch extends AbstractSearchTabbedBean<Survey, Survey> {
	private static final Logger logger = Logger.getLogger(MbSurveysSearch.class);

	private SurveysDao surveysDao = new SurveysDao();
	private static final String PARAMS_TAB = "paramsTab";

	private static final List<String> MASKED_FILTERS = Arrays.asList("name", "surveyNumber");

	private Survey newItem;

	@ManagedProperty("#{MbSurveyParameterRelationsSearch}")
	private MbSurveyParameterRelationsSearch parameterRelationsSearch;

	@Override
	@PostConstruct
	public void init() {
		super.init();
		pageLink = "survey|configuration";
	}

	@Override
	protected void onLoadTab(String tabName) {
		if (PARAMS_TAB.equals(tabName)) {
			parameterRelationsSearch.clearFilter();
			parameterRelationsSearch.setSurvey(getActiveItem());
			parameterRelationsSearch.search();
		}
	}

	@Override
	protected Survey createFilter() {
		return new Survey();
	}

	@Override
	protected Logger getLogger() {
		return logger;
	}

	@Override
	protected Survey addItem(Survey item) {
		return null;
	}

	@Override
	protected Survey editItem(Survey item) {
		return null;
	}

	@Override
	protected void deleteItem(Survey item) {}

	@Override
	protected void initFilters(Survey filter, List<Filter> filters) {
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
	protected List<Survey> getObjectList(Long userSessionId, SelectionParams params) {
		return surveysDao.getSurveys(userSessionId, params);
	}

	@Override
	protected int getObjectCount(Long userSessionId, SelectionParams params) {
		return surveysDao.getSurveysCount(userSessionId, params);
	}

	@Override
	public void clearState() {
		super.clearState();
		parameterRelationsSearch.clearFilter();
	}


	public void createItem() {
		try {
			curMode = NEW_MODE;
			newItem = new Survey();
		} catch(Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void editItem() {
		try {
			curMode = EDIT_MODE;
			try {
				newItem = activeItem.clone();
			} catch (CloneNotSupportedException e) {
				newItem = activeItem;
				FacesUtils.addMessageError(e);
				logger.error("", e);
			}
		} catch(Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void saveItem() {
		try {
			newItem.setLang(curLang);
			if (isNewMode()) {
				activeItem = surveysDao.addSurvey(userSessionId, newItem);
				tableRowSelection.addNewObjectToList(activeItem);
			} else {
				activeItem = surveysDao.modifySurvey(userSessionId, newItem);
				dataModel.replaceObject(activeItem, activeItem);
			}
			curMode = VIEW_MODE;
		} catch (Exception ee) {
			FacesUtils.addMessageError(ee);
			logger.error("", ee);
		}
	}

	public void removeItem() {
		try {
			if (activeItem == null) {
				return;
			}
			surveysDao.removeSurvey(userSessionId, activeItem);
			dataModel.removeObjectFromList(activeItem);
			activeItem = null;
		} catch (Exception ee) {
			FacesUtils.addMessageError(ee);
			logger.error("", ee);
		}
	}

	public void cancel() {
		curMode = VIEW_MODE;
	}

	public Survey getNewItem() {
		if (newItem == null) {
			newItem = new Survey();
		}
		return newItem;
	}

	public void setNewItem(Survey newItem) {
		this.newItem = newItem;
	}

	public List<SelectItem> getStatuses() {
		return getDictUtils().getLov(LovConstants.SURVEY_STATUS);
	}

	public void setParameterRelationsSearch(MbSurveyParameterRelationsSearch parameterRelationsSearch) {
		this.parameterRelationsSearch = parameterRelationsSearch;
	}
}
