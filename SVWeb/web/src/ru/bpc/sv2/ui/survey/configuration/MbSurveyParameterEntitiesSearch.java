package ru.bpc.sv2.ui.survey.configuration;

import org.apache.log4j.Logger;
import ru.bpc.sv2.constants.EntityNames;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.FilterBuilder;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.SurveysDao;
import ru.bpc.sv2.survey.configuration.SurveyParameter;
import ru.bpc.sv2.survey.configuration.SurveyParameterEntity;
import ru.bpc.sv2.ui.utils.AbstractSearchAllBean;
import ru.bpc.sv2.ui.utils.FacesUtils;

import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.model.SelectItem;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@ViewScoped
@ManagedBean(name = "MbSurveyParameterEntitiesSearch")
public class MbSurveyParameterEntitiesSearch extends AbstractSearchAllBean<SurveyParameterEntity, SurveyParameterEntity> {
	private static final Logger logger = Logger.getLogger(MbSurveyParameterEntitiesSearch.class);

	private SurveysDao surveysDao = new SurveysDao();
	private SurveyParameterEntity newItem;

	private SurveyParameter parameter;


	@Override
	protected SurveyParameterEntity createFilter() {
		return new SurveyParameterEntity();
	}

	@Override
	protected Logger getLogger() {
		return logger;
	}

	@Override
	protected SurveyParameterEntity addItem(SurveyParameterEntity item) {
		return null;
	}

	@Override
	protected SurveyParameterEntity editItem(SurveyParameterEntity item) {
		return null;
	}

	@Override
	protected void deleteItem(SurveyParameterEntity item) {

	}

	@Override
	protected void initFilters(SurveyParameterEntity filter, List<Filter> filters) {
		Map<String, Object> map = new HashMap<>();
		map.put("lang", curLang);

		filter.setParamId(parameter.getId());
		map.putAll(FilterBuilder.createMapFromBean(filter));

		filters.addAll(FilterBuilder.createFiltersFromMap(map, FilterBuilder.FilterMode.ALL_TO_STRING));
	}

	@Override
	protected List<SurveyParameterEntity> getObjectList(Long userSessionId, SelectionParams params) {
		return surveysDao.getParameterEntities(userSessionId, params);
	}

	@Override
	public void clearFilter() {
		super.clearFilter();
		parameter = null;
	}


	public void createItem() {
		try {
			curMode = NEW_MODE;
			newItem = new SurveyParameterEntity();
			newItem.setParamId(parameter.getId());
		} catch(Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void saveItem() {
		try {
			newItem.setLang(curLang);
			if (isNewMode()) {
				activeItem = surveysDao.addParameterEntity(userSessionId, newItem);
				tableRowSelection.addNewObjectToList(activeItem);
			}
			curMode = VIEW_MODE;
		} catch (Exception ee) {
			FacesUtils.addMessageError(ee);
			logger.error("", ee);
		}
	}

	public void cancel() {
		curMode = VIEW_MODE;
	}

	public void removeItem() {
		try {
			if (activeItem == null) {
				return;
			}
			surveysDao.removeParameterEntity(userSessionId, activeItem);
			dataModel.removeObjectFromList(activeItem);
			activeItem = null;
		} catch (Exception ee) {
			FacesUtils.addMessageError(ee);
			logger.error("", ee);
		}
	}

	public List<SelectItem> getEntityTypes() {
		List<SelectItem> items = getDictUtils().getLov(LovConstants.SCHEME_EVENT_ENTITY_TYPES);
		ArrayList<SelectItem> result = new ArrayList<>();
		for(SelectItem item: items) {
			if (EntityNames.CUSTOMER.equals(item.getValue())) {
				result.add(item);
			}
		}
		return result;
	}

	public SurveyParameterEntity getNewItem() {
		if (newItem == null) {
			newItem = new SurveyParameterEntity();
		}
		return newItem;
	}

	public void setNewItem(SurveyParameterEntity newItem) {
		this.newItem = newItem;
	}

	public SurveyParameter getParameter() {
		return parameter;
	}

	public void setParameter(SurveyParameter parameter) {
		this.parameter = parameter;
	}
}
