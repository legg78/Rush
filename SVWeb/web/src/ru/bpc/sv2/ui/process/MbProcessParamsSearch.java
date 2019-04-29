package ru.bpc.sv2.ui.process;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;
import ru.bpc.sv2.constants.DataTypes;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.Filter.Operator;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.invocation.SortElement;
import ru.bpc.sv2.logic.ProcessDao;
import ru.bpc.sv2.process.ProcessParameter;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.TableRowSelection;
import util.auxil.ManagedBeanWrapper;


import ru.bpc.sv2.logic.utility.db.DataAccessException;
import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.model.SelectItem;
import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

@ViewScoped
@ManagedBean (name = "MbProcessParamsSearch")
public class MbProcessParamsSearch extends AbstractBean {
	private ProcessDao _processDao = new ProcessDao();

	public static final int SET_VALUE_MODE = 16;

	private ProcessParameter _activeProcessParam;
	private ProcessParameter newProcessParam;
	private ProcessParameter filter;

	
	private MbProcessParams sessBean;

	private String backLink;
	private boolean selectMode;
	private boolean containerProcessParams;
	private boolean isContainer;

	private final DaoDataModel<ProcessParameter> _processParamSource;

	private final TableRowSelection<ProcessParameter> _itemSelection;
	private static final Logger logger = Logger.getLogger("PROCESSES");
	
	private static String COMPONENT_ID = "processParamsTableBottom";
	private String tabName;
	private String parentSectionId;

	private Boolean allowProcessParameterModify;

	public MbProcessParamsSearch() {
		
		sessBean = (MbProcessParams) ManagedBeanWrapper.getManagedBean("MbProcessParams");
		_processParamSource = new DaoDataModel<ProcessParameter>() {
			@Override
			protected ProcessParameter[] loadDaoData(SelectionParams params) {
				if (!isSearching() || getFilter().getProcessId() == null)
					return new ProcessParameter[0];
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _processDao.getProcessParams(userSessionId, params,
							containerProcessParams);
				} catch (Exception e) {
					setDataSize(0);
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return new ProcessParameter[0];
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (!isSearching() || getFilter().getProcessId() == null)
					return 0;
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _processDao.getProcessParamsCount(userSessionId, params,
							containerProcessParams);
				} catch (Exception e) {
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return 0;
			}
		};
		_itemSelection = new TableRowSelection<ProcessParameter>(null, _processParamSource);
	}

	public DaoDataModel<ProcessParameter> getProcessParams() {
		return _processParamSource;
	}

	public ProcessParameter getActiveProcessParam() {
		return _activeProcessParam;
	}

	public void setActiveProcessParam(ProcessParameter activeProcessParam) {
		_activeProcessParam = activeProcessParam;
	}

	public SimpleSelection getItemSelection() {
		try {
			if (_activeProcessParam == null && _processParamSource.getRowCount() > 0) {
				setFirstRowActive();
			} else if (_activeProcessParam != null && _processParamSource.getRowCount() > 0) {
				SimpleSelection selection = new SimpleSelection();
				selection.addKey(_activeProcessParam.getModelId());
				_itemSelection.setWrappedSelection(selection);
				_activeProcessParam = _itemSelection.getSingleSelection();
			}
		} catch (Exception e) {
			logger.error("", e);
			FacesUtils.addErrorExceptionMessage(e);
		}
		return _itemSelection.getWrappedSelection();
	}

	public void setFirstRowActive() {
		_processParamSource.setRowIndex(0);
		SimpleSelection selection = new SimpleSelection();
		_activeProcessParam = (ProcessParameter) _processParamSource.getRowData();
		selection.addKey(_activeProcessParam.getModelId());
		_itemSelection.setWrappedSelection(selection);
	}

	public void setItemSelection(SimpleSelection selection) {
		_itemSelection.setWrappedSelection(selection);
		_activeProcessParam = _itemSelection.getSingleSelection();
	}

	public void search() {
		clearState();
		setSearching(true);
	}

	public void setFilters() {
		filters = new ArrayList<Filter>();

		Filter paramFilter = null;
		filter = getFilter();

		if (filter.getProcessId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("processId");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(filter.getProcessId().toString());
			filters.add(paramFilter);
		}
		if (filter.getContainerId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("containerId");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(filter.getContainerId().toString());
			filters.add(paramFilter);
		}
		if (filter.getContainerBindId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("containerBindId");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(filter.getContainerBindId().toString());
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
			paramFilter.setElement("description");
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

	public ProcessParameter getFilter() {
		if (filter == null)
			filter = new ProcessParameter();
		return filter;
	}

	public void setFilter(ProcessParameter filter) {
		this.filter = filter;
	}

	public void storeObjects() {
		sessBean.setSavedFilter(filter);
		sessBean.setSavedActiveParameter(_activeProcessParam);
		sessBean.setSavedNewParameter(newProcessParam);
		sessBean.setSavedBackLink(backLink);
		sessBean.setSavedCurMode(curMode);
	}

	public String getBackLink() {
		return backLink;
	}

	public void setBackLink(String backLink) {
		this.backLink = backLink;
	}

	public void setSearching(boolean searching) {
		this.searching = searching;
		sessBean.setSearching(searching);
	}

	public String cancelSelect() {
		return backLink;
	}

	public boolean isSelectMode() {
		return selectMode;
	}

	public void setSelectMode(boolean selectMode) {
		this.selectMode = selectMode;
	}

	public void clearFilter() {
		clearState();
		searching = false;
		filter = null;
	}

	public void clearState() {
		_processParamSource.flushCache();
		_itemSelection.clearSelection();
		_activeProcessParam = null;
	}

	public void add() {
		newProcessParam = new ProcessParameter();
		newProcessParam.setProcessId(getFilter().getProcessId());
		newProcessParam.setLang(userLang);
		curMode = NEW_MODE;
        initParametersSi();
	}

	public void edit() {
		try {
			newProcessParam = (ProcessParameter) _activeProcessParam.clone();
			allowProcessParameterModify = _processDao.allowProcessParameterModify(userSessionId, getFilter().getProcessId());
		} catch (CloneNotSupportedException e) {
			newProcessParam = _activeProcessParam;
			logger.error("", e);
		}
		curMode = EDIT_MODE;
        initParametersSi();
	}

	public void save() {
		try {
			if (newProcessParam.getDataType().equals(DataTypes.NUMBER)) {
				if (newProcessParam.getValueN() != null) {
					Pattern p = Pattern.compile("^-?(\\d{1,18})(\\.\\d{1,4})?$");
					Matcher m = p.matcher(newProcessParam.getValueN().toString());
					if (!m.matches()) {
						FacesUtils.addMessageError(new Exception(FacesUtils.getMessage(
								"ru.bpc.sv2.ui.bundles.Msg", "invalid_number", newProcessParam.getValueN())));
						return;
					}
				}
			}

			if (isNewMode()) {
//				newProcessParam = _processDao.addParamPrc(userSessionId, newProcessParam);
//				_itemSelection.addNewObjectToList(newProcessParam);
				_processDao.addParamPrc(userSessionId, newProcessParam);
				_processParamSource.flushCache();
			} else if (isEditMode()) {
				if (allowProcessParameterModify) {
					newProcessParam = _processDao.modifyParamPrc(userSessionId, newProcessParam);
				}
				else {
					_processDao.modifyProcessParameterDesc(userSessionId, newProcessParam);
				}
				_processParamSource.replaceObject(_activeProcessParam, newProcessParam);
			}

			_activeProcessParam = newProcessParam;
			curMode = VIEW_MODE;
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void delete() {
		try {
			_processDao.removeParamPrc(userSessionId, _activeProcessParam);
			_activeProcessParam = _itemSelection.removeObjectFromList(_activeProcessParam);
			if (_activeProcessParam == null) {
				clearState();
			}
			curMode = VIEW_MODE;
		} catch (DataAccessException ee) {
			FacesUtils.addMessageError(ee);
			logger.error("", ee);
		}
	}

	public void close() {
		curMode = VIEW_MODE;
	}

//	public String selectParameter() {
//		MbProcessParametersSearch paramsBean = (MbProcessParametersSearch) ManagedBeanWrapper
//				.getManagedBean("MbProcessParametersSearch");
//		if (newProcessParam.getId() == null) {
//			paramsBean.getFilter().setProcessId(newProcessParam.getProcessId());
//		}
//		paramsBean.setBackLink(backLink);
//		paramsBean.setSelectMode(true);
//		paramsBean.setAddParametersToProcess(true);
//
//		HashMap<String, Object> queueFilter = new HashMap<String, Object>();
//		queueFilter.put("backLink", backLink);
//		queueFilter.put("selectMode", true);
//		queueFilter.put("addParamToProcess", true);
//		addFilterToQueue("MbProcessParametersSearch", queueFilter);
//		sessBean.setCurMode(MbProcessParams.MODE_SELECT_PARAM);
//
//		storeObjects();
//
//		return "processes|parameters";
//	}

    private List<SelectItem> parametersSi;
    private ProcessParameter[] parameters;
    private String selectedParamIndex;

    public void selectedParamChanged() {
        newProcessParam = parameters[Integer.parseInt(selectedParamIndex)];
    }

    public void initParametersSi() {
        if (isNewMode()) {
            selectedParamIndex = null;
            parametersSi = new ArrayList<SelectItem>();

            SelectionParams params = new SelectionParams();
            Filter[] filters = new Filter[2];
            filters[0] = new Filter("processId", newProcessParam.getProcessId());
            filters[1] = new Filter("lang", userLang);
            filters[1].setOp(Operator.eq);

            SortElement[] sorters = new SortElement[1];
            sorters[0] = new SortElement("name", SortElement.Direction.ASC);

            params.setFilters(filters);
            params.setSortElement(sorters);
            parameters = _processDao.getParametersNotAssignedToProcess(userSessionId, params);
            for (int i = 0; i < parameters.length; i++) {
                parameters[i].setProcessId(getFilter().getProcessId());
                SelectItem nextSi = new SelectItem(i, parameters[i].getName());
                parametersSi.add(nextSi);
            }
        } else {
            selectedParamIndex = "0";
            parametersSi = new ArrayList<SelectItem>();
            SelectItem nextSi = new SelectItem("0", newProcessParam.getName());
            parametersSi.add(nextSi);
        }
    }

    public void setSelectedParamIndex(String selectedParamIndex) {
        this.selectedParamIndex = selectedParamIndex;
    }

    public String getSelectedParamIndex() {
        return this.selectedParamIndex;
    }

    public List<SelectItem> getParametersSi() {
        return parametersSi;
    }

	public ProcessParameter getNewProcessParam() {
		return newProcessParam;
	}

	public void setNewProcessParam(ProcessParameter newProcessParam) {
		this.newProcessParam = newProcessParam;
	}

	public boolean isShowModal() {
		return isEditMode() || isNewMode();
	}

	public List<SelectItem> getListValues() {
		List<SelectItem> list = null;
		try {
			if (newProcessParam != null && newProcessParam.getLovId() != null) {
				boolean isParentPresents = false;
				if(newProcessParam.getParentId() != null) {
					for (ProcessParameter parameter : _processParamSource.getActivePage()) {
						if(parameter.getId() != null && parameter.getId().equals(newProcessParam.getParentId())) {
							isParentPresents = true;
							Map<String, Object> params = new HashMap<String, Object>();
							params.put(parameter.getSystemName(), parameter.getValue());
							list = getDictUtils().getLov(newProcessParam.getLovId(), params);
						}
					}
				}
				if (!isParentPresents) {
					list = getDictUtils().getLov(newProcessParam.getLovId());
				}
			}
		} catch (Exception e) {
			logger.error("", e);
			FacesUtils.addMessageError(e);
		} finally {
			if (list == null) {
				list = new ArrayList<SelectItem>(0);
			}
		}
		return list;
	}

	public void setAttr() {
		try {
			newProcessParam = (ProcessParameter) _activeProcessParam.clone();
		} catch (CloneNotSupportedException e) {
			newProcessParam = _activeProcessParam;
			logger.error("", e);
		}
		curMode = SET_VALUE_MODE;
	}

	public void setProcessParam() {
		try {
			if (newProcessParam.getDataType().equals(DataTypes.NUMBER)) {
				Pattern p = Pattern.compile("^-?(\\d{1,18})(\\.\\d{1,4})?$");
				Matcher m = p.matcher(newProcessParam.getValueN().toString());
				if (!m.matches()) {
					FacesUtils.addMessageError(new Exception(FacesUtils.getMessage(
							"ru.bpc.sv2.ui.bundles.Msg", "invalid_number", newProcessParam.getValueN())));
					return;
				}
			}
			
			newProcessParam.setContainerBindId(getFilter().getContainerBindId());
			newProcessParam.setProcessId(getFilter().getProcessId());
			_processDao.setProcessParam(userSessionId, newProcessParam);
			if(!newProcessParam.getValue().equals(_activeProcessParam.getValue())) {
				deleteDependentParamValue();
			}
			_processParamSource.flushCache();

			curMode = VIEW_MODE;
		} catch (DataAccessException ee) {
			FacesUtils.addMessageError(ee);
			logger.error("", ee);
		}
	}

	public void removeAttr() {
		try {
			_processDao.removePrcAttr(userSessionId, _activeProcessParam);
			_activeProcessParam.setValue(null);
			_activeProcessParam.setValueD(null);
			_activeProcessParam.setValueN((BigDecimal)null);
			_activeProcessParam.setValueV(null);
			_activeProcessParam.setLovValue(null);
			_activeProcessParam.setPrcParamId(null);
		} catch (DataAccessException ee) {
			FacesUtils.addMessageError(ee);
			logger.error("", ee);
		}
	}

	public boolean isContainerProcessParams() {
		return containerProcessParams;
	}

	public void setContainerProcessParams(boolean containerProcessParams) {
		this.containerProcessParams = containerProcessParams;
	}

	public void restoreBean() {
		if (backLink != null){
			HashMap<String,Object> queueFilter = getQueueFilter("MbProcessParamsSearch");
			if (queueFilter == null){
				return;
			}
			if (!queueFilter.containsKey("restoreBean")){
				return;
			}
			restoreBean = (Boolean) queueFilter.get("restoreBean");
			if (restoreBean != null && restoreBean) {
				FacesUtils.setSessionMapValue(backLink, Boolean.FALSE);
				_activeProcessParam = sessBean.getSavedActiveParameter();
				filter = sessBean.getSavedFilter();
				backLink = sessBean.getSavedBackLink();
				newProcessParam = sessBean.getSavedNewParameter();
				curMode = sessBean.getSavedCurMode();
				if (newProcessParam == null)
					newProcessParam = new ProcessParameter();
		
				// set parameter if we returned from parameters form
				if (sessBean.getCurMode() == MbProcessParams.MODE_SELECT_PARAM) {
					MbProcessParameters paramsBean = (MbProcessParameters) ManagedBeanWrapper
							.getManagedBean("MbProcessParameters");
					ProcessParameter param = paramsBean.getParameter();
					if (param != null && newProcessParam != null && param.getId()!=null) {
						newProcessParam.setDataType(param.getDataType());
						newProcessParam.setLovId(param.getLovId());
						newProcessParam.setId(param.getId());
						newProcessParam.setSystemName(param.getSystemName());
						newProcessParam.setName(param.getName());
					}
					sessBean.setCurMode(MbProcessParams.MODE_PROCESS);
				}
			}
		}
	}

	private void deleteDependentParamValue() {
		if (_processParamSource != null && _processParamSource.getRowCount() > 0) {
			for (ProcessParameter parameter : _processParamSource.getActivePage()) {
				if (newProcessParam.getId().equals(parameter.getParentId())) {
					_processDao.removePrcAttr(userSessionId, parameter);
					return;
				}
			}
		}
	}

	public boolean isContainer() {
		return isContainer;
	}

	public void setContainer(boolean isContainer) {
		this.isContainer = isContainer;
	}
	
	public String getComponentId() {
		return parentSectionId + ":" + tabName + ":" + COMPONENT_ID;
	}

	public void setTabName(String tabName) {
		this.tabName = tabName;
	}

	public void setParentSectionId(String parentSectionId) {
		this.parentSectionId = parentSectionId;
	}

	public Boolean getAllowProcessParameterModify() {
		return !isEditMode() || allowProcessParameterModify;
	}

	public void setAllowProcessParameterModify(Boolean allowProcessParameterModify) {
		this.allowProcessParameterModify = allowProcessParameterModify;
	}

	public void confirmEditLanguage() {
		Filter[] filters = new Filter[3];
		filters[0] = Filter.create("paramId", newProcessParam.getId());
		filters[1] = Filter.create("processId", filter.getProcessId().toString());
		filters[2] = Filter.create("lang", newProcessParam.getLang());

		SelectionParams params = new SelectionParams();
		params.setFilters(filters);
		try {
			ProcessParameter[] prcParams = _processDao.getProcessParams(userSessionId, params, containerProcessParams);
			if (prcParams != null && prcParams.length > 0) {
				newProcessParam = prcParams[0];
				selectedParamIndex = "0";
				parametersSi = new ArrayList<SelectItem>();
				SelectItem nextSi = new SelectItem("0", newProcessParam.getName());
				parametersSi.add(nextSi);
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}
	
}
