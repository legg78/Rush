package ru.bpc.sv2.ui.process;

import java.util.*;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.event.ValueChangeEvent;
import javax.faces.model.SelectItem;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;

import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.Filter.Operator;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.ProcessDao;
import ru.bpc.sv2.process.ProcessParameter;
import ru.bpc.sv2.ui.utils.*;
import util.auxil.ManagedBeanWrapper;

@ViewScoped
@ManagedBean (name = "MbProcessParametersSearch")
public class MbProcessParametersSearch extends AbstractBean {
	
	private static final long serialVersionUID = 1L;

	private static final Logger logger = Logger.getLogger("PROCESSES");

	private static String COMPONENT_ID = "1071:mainTable";

	private ProcessDao _processDao = new ProcessDao();

	private ProcessParameter filter;
	private ProcessParameter _activeParameter;
	private ProcessParameter newParameter;

	private String backLink;
	private boolean selectMode;

	private MbProcessParameters paramBean;

	private boolean showModal;
	private boolean addParametersToProcess;

	private final DaoDataModel<ProcessParameter> _parametersSource;

	private final TableRowSelection<ProcessParameter> _itemSelection;
	
	private ArrayList<SelectItem> dataTypes;

	private List<SelectItem> parentParameters;

	public MbProcessParametersSearch() {
		pageLink = "processes|parameters";
		paramBean = (MbProcessParameters) ManagedBeanWrapper.getManagedBean("MbProcessParameters");

		_parametersSource = new DaoDataModel<ProcessParameter>() {
			private static final long serialVersionUID = 1L;

			@Override
			protected ProcessParameter[] loadDaoData(SelectionParams params) {
				if (!isSearching())
					return new ProcessParameter[0];
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					if (addParametersToProcess)
						return _processDao.getParametersNotAssignedToProcess(userSessionId, params);

					return _processDao.getParameters(userSessionId, params);
				} catch (Exception e) {
					setDataSize(0);
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return new ProcessParameter[0];
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (!isSearching())
					return 0;
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));

					if (addParametersToProcess)
						return _processDao.getParametersNotAssignedToProcessCount(userSessionId,
								params);

					return _processDao.getParametersCount(userSessionId, params);
				} catch (Exception e) {
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return 0;
			}
		};
		_itemSelection = new TableRowSelection<ProcessParameter>(null, _parametersSource);
		restoreFilters();
	}
	
	private void restoreFilters(){
		HashMap<String,Object> queueFilter = getQueueFilter("MbProcessParametersSearch");
		if (queueFilter != null){
			if (queueFilter.containsKey("backLink")){
				backLink = (String)queueFilter.get("backLink");
			}
			
			if (queueFilter.containsKey("selectMode")){
				selectMode = (Boolean)queueFilter.get("selectMode");
			}
			
			if (queueFilter.containsKey("addParamToProcess")){
				addParametersToProcess = (Boolean)queueFilter.get("addParamToProcess");
			}
		}
	}

	public DaoDataModel<ProcessParameter> getParameters() {
		return _parametersSource;
	}

	public ProcessParameter getActiveParameter() {
		return _activeParameter;
	}

	public void setActiveParameter(ProcessParameter activeParameter) {
		_activeParameter = activeParameter;
	}

	public SimpleSelection getItemSelection() {
		try {
			if (_activeParameter == null && _parametersSource.getRowCount() > 0) {
				setFirstRowActive();
			} else if (_activeParameter != null && _parametersSource.getRowCount() > 0) {
				SimpleSelection selection = new SimpleSelection();
				selection.addKey(_activeParameter.getModelId());
				_itemSelection.setWrappedSelection(selection);
				_activeParameter = _itemSelection.getSingleSelection();
			}
		} catch (Exception e) {
			logger.error("", e);
			FacesUtils.addMessageError(e);
		}
		return _itemSelection.getWrappedSelection();
	}

	public void setFirstRowActive() {
		_parametersSource.setRowIndex(0);
		SimpleSelection selection = new SimpleSelection();
		_activeParameter = (ProcessParameter) _parametersSource.getRowData();
		selection.addKey(_activeParameter.getModelId());
		_itemSelection.setWrappedSelection(selection);
		if (_activeParameter != null) {
			// setInfo();
		}
	}

	public void setItemSelection(SimpleSelection selection) {
		_itemSelection.setWrappedSelection(selection);
		_activeParameter = _itemSelection.getSingleSelection();
//		paramBean.setParameter(_activeParameter);
	}

	public void search() {
		clearState();
		setSearching(true);
	}

	public void setFilters() {
		filters = new ArrayList<Filter>();

		Filter paramFilter = null;
		filter = getFilter();

		if (getFilter().getProcessId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("processId");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(filter.getProcessId().toString());
			filters.add(paramFilter);
		}
		if (getFilter().getContainerId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("containerId");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(filter.getContainerId().toString());
			filters.add(paramFilter);
		}

		if (filter.getName() != null && filter.getName().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("name");
			paramFilter.setOp(Operator.like);
			paramFilter.setValue(filter.getName().trim().toUpperCase().replaceAll("[*]", "%")
					.replaceAll("[?]", "_"));
			filters.add(paramFilter);
		}
		if (filter.getDescription() != null && filter.getDescription().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("descriprion");
			paramFilter.setOp(Operator.like);
			paramFilter.setValue(filter.getDescription().trim().toUpperCase().replaceAll("[*]", "%")
					.replaceAll("[?]", "_"));
			filters.add(paramFilter);
		}
		if (filter.getSystemName() != null && filter.getSystemName().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("paramName");
			paramFilter.setOp(Operator.like);
			paramFilter.setValue(filter.getSystemName().trim().toUpperCase().replaceAll("[*]", "%")
					.replaceAll("[?]", "_"));
			filters.add(paramFilter);
		}
		if (filter.getDataType() != null && filter.getDataType().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("dataType");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(filter.getDataType());
			filters.add(paramFilter);
		}
		paramFilter = new Filter();
		paramFilter.setElement("lang");
		paramFilter.setOp(Operator.eq);
		paramFilter.setValue(userLang);
		filters.add(paramFilter);

	}

	public void add() {
		newParameter = new ProcessParameter();
		newParameter.setLang(userLang);
		curMode = NEW_MODE;
	}

	public void edit() {
		try {
			newParameter = (ProcessParameter) _activeParameter.clone();
		} catch (CloneNotSupportedException e) {
			logger.error("", e);
			newParameter = _activeParameter;
		}
		curMode = EDIT_MODE;
	}

	public void save() {
		try {
			if (isNewMode()) {
				newParameter = _processDao.addParam(userSessionId, newParameter);
				_itemSelection.addNewObjectToList(newParameter);
			} else if (isEditMode()) {
				newParameter = _processDao.modifyParam(userSessionId, newParameter);
				_parametersSource.replaceObject(_activeParameter, newParameter);
			}

			_activeParameter = newParameter;
			curMode = VIEW_MODE;
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void delete() {
		try {
			_processDao.removeParam(userSessionId, _activeParameter);
			_activeParameter = _itemSelection.removeObjectFromList(_activeParameter);
			if (_activeParameter == null) {
				clearState();
			}
			curMode = VIEW_MODE;
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void close() {
		curMode = VIEW_MODE;
	}

	public ProcessParameter getNewParameter() {
		if (newParameter == null) {
			newParameter = new ProcessParameter();
		}
		return newParameter;
	}

	public void setNewParameter(ProcessParameter newParameter) {
		this.newParameter = newParameter;
	}

	public ProcessParameter getFilter() {
		if (filter == null) {
			filter = new ProcessParameter();
		}
		return filter;
	}

	public void setFilter(ProcessParameter filter) {
		this.filter = filter;
	}

	public ArrayList<SelectItem> getDataTypes() {
		if (dataTypes == null){
			dataTypes = (ArrayList<SelectItem>) getDictUtils().getLov(LovConstants.DATA_TYPES);
		}
		return dataTypes;
	}

	public List<SelectItem> getLovs() {
		if (getNewParameter().getDataType() == null) {
			return new ArrayList<SelectItem>(0);
		}
		Map<String, Object> params = new HashMap<String, Object>(1);
		params.put("DATA_TYPE", getNewParameter().getDataType());
		
		return getDictUtils().getLov(LovConstants.NOT_PARAMETRIZED_LOVS, params);
	}

	public List<SelectItem> getParentParameters() {
		if(parentParameters != null) {
			return parentParameters;
		}
		parentParameters = new ArrayList<SelectItem>();
		SelectionParams params = new SelectionParams();
		params.setFilters(new Filter("lang", userLang));

		ProcessParameter[] parameters = _processDao.getParameters(userSessionId, params.setRowIndexAll());
		for (int i = 0; i < parameters.length; i++) {
			SelectItem nextSi = new SelectItem(parameters[i].getId(), parameters[i].getId() + " - " + parameters[i].getName());
			parentParameters.add(nextSi);
		}
		return parentParameters;
	}

	public String getBackLink() {
		return backLink;
	}

	public void setBackLink(String backLink) {
		this.backLink = backLink;
	}

	public boolean isShowModal() {
		return showModal;
	}

	public void setShowModal(boolean showModal) {
		this.showModal = showModal;
	}

	public String cancelSelect() {
		paramBean.setParameter(null);
		FacesUtils.setSessionMapValue(backLink, Boolean.TRUE);
		return backLink;
	}

	public boolean isSelectMode() {
		return selectMode;
	}

	public void setSelectMode(boolean selectMode) {
		this.selectMode = selectMode;
	}

	public void clearFilter() {
		filter = new ProcessParameter();
		clearState();
		searching = false;
	}
	
	public void clearState() {
		_parametersSource.flushCache();
		_itemSelection.clearSelection();
		_activeParameter = null;
	}

	public boolean isAddParametersToProcess() {
		return addParametersToProcess;
	}

	public void setAddParametersToProcess(boolean addParametersToProcess) {
		this.addParametersToProcess = addParametersToProcess;
	}

	public String selectParam() {
		paramBean.setParameter(_activeParameter);
		FacesUtils.setSessionMapValue(backLink, Boolean.TRUE);
		HashMap<String, Object> queueFilter = new HashMap<String, Object>();
		queueFilter.put("restoreBean", true);
		addFilterToQueue("MbProcessParamsSearch", queueFilter);
		
		return backLink;
	}

	public void changeLanguage(ValueChangeEvent event) {
		curLang = (String) event.getNewValue();

		List<Filter> filtersList = new ArrayList<Filter>();

		Filter paramFilter = new Filter();
		paramFilter.setElement("id");
		paramFilter.setOp(Operator.eq);
		paramFilter.setValue(_activeParameter.getId().toString());
		filtersList.add(paramFilter);

		paramFilter = new Filter();
		paramFilter.setElement("lang");
		paramFilter.setOp(Operator.eq);
		paramFilter.setValue(curLang);
		filtersList.add(paramFilter);

		filters = filtersList;
		SelectionParams params = new SelectionParams();
		params.setFilters(filters.toArray(new Filter[filters.size()]));
		try {
			ProcessParameter[] prcParams = _processDao.getParameters(userSessionId, params);
			if (prcParams != null && prcParams.length > 0) {
				_activeParameter = prcParams[0];
//				paramBean.setParameter(_activeParameter);
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void disableLov() {
		if (getNewParameter().isDate()) {
			getNewParameter().setLovId(null);
		}
	}
	
	public void confirmEditLanguage() {
		Filter[] filters = new Filter[2];
		filters[0] = new Filter();
		filters[0].setElement("id");
		filters[0].setValue(newParameter.getId());
		filters[1] = new Filter();
		filters[1].setElement("lang");
		filters[1].setValue(newParameter.getLang());

		SelectionParams params = new SelectionParams();
		params.setFilters(filters);
		try {
			ProcessParameter[] prcParams = _processDao.getParameters(userSessionId, params);
			if (prcParams != null && prcParams.length > 0) {
				newParameter = prcParams[0];
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public String getComponentId() {
		return COMPONENT_ID;
	}

	public Logger getLogger() {
		return logger;
	}

	@Override
	protected void applySectionFilter(Integer filterId) {
		try {
			FilterFactory factory = (FilterFactory) ManagedBeanWrapper
					.getManagedBean("filterFactory");
			Map<String, String> filterRec = factory.getSectionFilterRecs(filterId);
			sectionFilter = factory.getUserSectionFiltersObjects().get(filterId);
			if (filterRec != null) {
				filter = new ProcessParameter();
				if (filterRec.get("systemName") != null) {
					filter.setSystemName(filterRec.get("systemName"));
				}
				if (filterRec.get("name") != null) {
					filter.setName(filterRec.get("name"));
				}
				if (filterRec.get("dataType") != null) {
					filter.setDataType(filterRec.get("dataType"));
				}
			}
			if (searchAutomatically) {
				search();
			}
			sectionFilterModeEdit = true;
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	@Override
	public void saveSectionFilter() {
		try {
			FilterFactory factory = (FilterFactory) ManagedBeanWrapper
					.getManagedBean("filterFactory");

			Map<String, String> filterRec = new HashMap<String, String>();
			filter = getFilter();
			if (filter.getSystemName() != null) {
				filterRec.put("systemName", filter.getSystemName());
			}
			if (filter.getName() != null) {
				filterRec.put("name", filter.getName());
			}
			if (filter.getDataType() != null) {
				filterRec.put("dataType", filter.getDataType());
			}
			sectionFilter = getSectionFilter();
			sectionFilter.setRecs(filterRec);

			factory.saveSectionFilter(sectionFilter, sectionFilterModeEdit);
			selectedSectionFilter = sectionFilter.getId();
			sectionFilterModeEdit = true;
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}
}
