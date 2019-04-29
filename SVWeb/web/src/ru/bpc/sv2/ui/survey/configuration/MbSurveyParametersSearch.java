package ru.bpc.sv2.ui.survey.configuration;

import org.apache.log4j.Logger;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.FilterBuilder;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.SurveysDao;
import ru.bpc.sv2.survey.configuration.SurveyParameter;
import ru.bpc.sv2.ui.utils.AbstractSearchTabbedBean;
import ru.bpc.sv2.ui.utils.FacesUtils;

import javax.annotation.PostConstruct;
import javax.faces.bean.ManagedBean;
import javax.faces.bean.ManagedProperty;
import javax.faces.bean.ViewScoped;
import javax.faces.model.SelectItem;
import java.util.*;

@ViewScoped
@ManagedBean(name = "MbSurveyParametersSearch")
public class MbSurveyParametersSearch extends AbstractSearchTabbedBean<SurveyParameter, SurveyParameter> {
	private static final Logger logger = Logger.getLogger(MbSurveyParametersSearch.class);

	private static final String ENTITY_TAB = "entityTab";
	public static final List<String> MASKED_FILTERS = Arrays.asList("name", "paramName");

	private SurveysDao surveysDao = new SurveysDao();
	private SurveyParameter newItem;

	@ManagedProperty("#{MbSurveyParameterEntitiesSearch}")
	private MbSurveyParameterEntitiesSearch entitiesSearch;


	@Override
	@PostConstruct
	public void init() {
		super.init();
		pageLink = "survey|configuration|params";
	}

	@Override
	protected void onLoadTab(String tabName) {
		if (ENTITY_TAB.equals(tabName)) {
			entitiesSearch.clearFilter();
			entitiesSearch.setParameter(getActiveItem());
			entitiesSearch.search();
		}
	}

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

		for (String key: MASKED_FILTERS) {
			if (map.containsKey(key)) {
				Object value = map.get(key);
				map.put(key, Filter.mask((String) value));
			}
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

	@Override
	public void clearState() {
		super.clearState();
		entitiesSearch.clearFilter();
	}


	public void createItem() {
		try {
			curMode = NEW_MODE;
			newItem = new SurveyParameter();
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
				activeItem = surveysDao.addParameter(userSessionId, newItem);
				tableRowSelection.addNewObjectToList(activeItem);
			} else {
				activeItem = surveysDao.modifyParameter(userSessionId, newItem);
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
			surveysDao.removeParameter(userSessionId, activeItem);
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

	public SurveyParameter getNewItem() {
		if (newItem == null) {
			newItem = new SurveyParameter();
		}
		return newItem;
	}

	public void setNewItem(SurveyParameter newItem) {
		this.newItem = newItem;
	}


	public List<SelectItem> getLovs() {
		if (newItem.getDataType() == null) {
			return new ArrayList<SelectItem>(0);
		}
		Map<String, Object> params = new HashMap<String, Object>(1);
		params.put("DATA_TYPE", newItem.getDataType());

		return getDictUtils().getLov(LovConstants.LOVS_LOV, params);
	}

	public List<SelectItem> getDataTypes() {
		return getDictUtils().getLov(LovConstants.DATA_TYPES);
	}

	public void setEntitiesSearch(MbSurveyParameterEntitiesSearch entitiesSearch) {
		this.entitiesSearch = entitiesSearch;
	}
}
