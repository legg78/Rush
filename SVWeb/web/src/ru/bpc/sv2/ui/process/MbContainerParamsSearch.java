package ru.bpc.sv2.ui.process;

import java.util.ArrayList;
import java.util.List;


import ru.bpc.sv2.logic.utility.db.DataAccessException;
import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.model.SelectItem;

import org.apache.log4j.Logger;
import org.openfaces.util.Faces;
import org.richfaces.model.selection.SimpleSelection;

import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.invocation.Filter.Operator;
import ru.bpc.sv2.logic.ProcessDao;
import ru.bpc.sv2.process.ProcessParameter;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.TableRowSelection;
import util.auxil.ManagedBeanWrapper;

@ViewScoped
@ManagedBean(name = "MbContainerParamsSearch")
public class MbContainerParamsSearch extends AbstractBean {
	private static final long serialVersionUID = 1L;

	private static final int SET_VALUE_MODE = 8;

	private ProcessDao _processDao = new ProcessDao();

	private ProcessParameter _activeProcessParam;
	private ProcessParameter newProcessParam;
	private ProcessParameter filter;

	private MbProcessParams sessBean;

	private String backLink;
	private boolean selectMode;

	private final DaoDataModel<ProcessParameter> _processParamSource;

	private final TableRowSelection<ProcessParameter> _itemSelection;
	private static final Logger logger = Logger.getLogger("PROCESSES");
	
	private static String COMPONENT_ID = "accountsTable";
	private String tabName;
	private String parentSectionId;

	public MbContainerParamsSearch() {
		sessBean = (MbProcessParams) ManagedBeanWrapper.getManagedBean("MbProcessParams");
		_processParamSource = new DaoDataModel<ProcessParameter>() {
			private static final long serialVersionUID = 1L;

			@Override
			protected ProcessParameter[] loadDaoData(SelectionParams params) {
				if (!isSearching() || getFilter().getProcessId() == null)
					return new ProcessParameter[0];
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _processDao.getContainerLaunchParams(userSessionId, params);
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
					return _processDao.getContainerLaunchParamsCount(userSessionId, params);
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
		if (_activeProcessParam == null && _processParamSource.getRowCount() > 0) {
			setFirstRowActive();
		} else if (_activeProcessParam != null && _processParamSource.getRowCount() > 0) {
			SimpleSelection selection = new SimpleSelection();
			selection.addKey(_activeProcessParam.getModelId());
			_itemSelection.setWrappedSelection(selection);
			_activeProcessParam = _itemSelection.getSingleSelection();
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
			paramFilter.setValue(filter.getName().trim().toUpperCase().replaceAll("[*]", "%").replaceAll("[?]", "_"));
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

	public List<Filter> getFilters() {
		return filters;
	}

	public void setFilters(List<Filter> filters) {
		this.filters = filters;
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

	public void clearState() {
		_processParamSource.flushCache();
		_itemSelection.clearSelection();
		_activeProcessParam = null;
	}

	public ProcessParameter getNewProcessParam() {
		return newProcessParam;
	}

	public void setNewProcessParam(ProcessParameter newProcessParam) {
		this.newProcessParam = newProcessParam;
	}

	public List<SelectItem> getListValues() {
		List<SelectItem> list = null;
		try {
			ProcessParameter param = (ProcessParameter) Faces.var("item");
			if (param != null && param.getLovId() != null) {
				list = getDictUtils().getLov(param.getLovId());
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

	public void removeAttr() {
		try {
			_processDao.removePrcAttr(userSessionId, _activeProcessParam);
			_processParamSource.flushCache();
		} catch (DataAccessException ee) {
			FacesUtils.addMessageError(ee);
			logger.error("", ee);
		}
	}

	@Override
	public void clearFilter() {
		// TODO Auto-generated method stub

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

}
