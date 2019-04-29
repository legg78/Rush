package ru.bpc.sv2.ui.reports;

import java.util.ArrayList;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.RequestScoped;
import javax.faces.event.ValueChangeEvent;
import javax.faces.model.SelectItem;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;

import org.ajax4jsf.model.KeepAlive;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.invocation.Filter.Operator;
import ru.bpc.sv2.logic.ReportsDao;
import ru.bpc.sv2.reports.ReportRunParameter;
import ru.bpc.sv2.ui.utils.*;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import util.auxil.ManagedBeanWrapper;

@RequestScoped
@KeepAlive
@ManagedBean (name = "MbReportRunParametersSearch")
public class MbReportRunParametersSearch extends AbstractBean{
	private static final Logger logger = Logger.getLogger("REPORTS");
	
	private ReportsDao _reportsDao = new ReportsDao();
	
	DictUtils dictUtils;
    
    private ReportRunParameter filter;
    private ReportRunParameter _activeParameter;
    private ReportRunParameter newParameter;

	private final DaoDataModel<ReportRunParameter> _parametersSource;

	private final TableRowSelection<ReportRunParameter> _itemSelection;
	
	private static String COMPONENT_ID = "mainTable";
	private String tabName;
	private String parentSectionId;
	private ArrayList<SelectItem> dataTypes;

	public MbReportRunParametersSearch() {
		dictUtils = (DictUtils)ManagedBeanWrapper.getManagedBean("DictUtils");

		_parametersSource = new DaoDataModel<ReportRunParameter>()
		{
			@Override
			protected ReportRunParameter[] loadDaoData(SelectionParams params) {
				if (!searching) {
					return new ReportRunParameter[0];
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _reportsDao.getReportRunParameters( userSessionId, params);
				} catch (Exception e) {
					setDataSize(0);
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return new ReportRunParameter[0];
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (!searching) {
					return 0;
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _reportsDao.getReportRunParametersCount( userSessionId, params);
				} catch (Exception e) {
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return 0;
			}
		};

		_itemSelection = new TableRowSelection<ReportRunParameter>( null, _parametersSource);
    }

    public DaoDataModel<ReportRunParameter> getParameters() {
		return _parametersSource;
	}

	public ReportRunParameter getActiveParameter() {
		return _activeParameter;
	}

	public void setActiveParameter(ReportRunParameter activeParameter) {
		_activeParameter = activeParameter;
	}

	public SimpleSelection getItemSelection() {
		if (_activeParameter == null && _parametersSource.getRowCount() > 0) {
			setFirstRowActive();
		}
		else if (_activeParameter != null && _parametersSource.getRowCount() > 0)
		{
			SimpleSelection selection = new SimpleSelection();
			selection.addKey(_activeParameter.getModelId());
			_itemSelection.setWrappedSelection(selection);
			_activeParameter = _itemSelection.getSingleSelection();			
		}
		return _itemSelection.getWrappedSelection();
	}

	public void setFirstRowActive() {
		_parametersSource.setRowIndex(0);
		SimpleSelection selection = new SimpleSelection();
		_activeParameter = (ReportRunParameter) _parametersSource.getRowData();
		selection.addKey(_activeParameter.getModelId());
		_itemSelection.setWrappedSelection(selection);
		if (_activeParameter != null) {
			setInfo();
		}
	}
	
	public void setItemSelection(SimpleSelection selection) {
		_itemSelection.setWrappedSelection( selection );
		_activeParameter = _itemSelection.getSingleSelection();
		if (_activeParameter != null) {
			setInfo();
		}
	}

	public void setInfo() {
//		MbNameComponentsSearch compSearch = (MbNameComponentsSearch)ManagedBeanWrapper.getManagedBean("MbNameComponentsSearch");
//		NameComponent componentFilter = new NameComponent();
//		componentFilter.setFormatId(_activeFormat.getId());
//		compSearch.setFilter(componentFilter);
//		
//		NameBaseParam baseParamFilter = new NameBaseParam();
//		baseParamFilter.setEntityType(_activeFormat.getEntityType());
//		compSearch.setBaseParamFilter(baseParamFilter);
//		compSearch.setBaseValues(null);
//		compSearch.search();
	}
	
	public void search() {
		clearState();
		searching = true;		
	}
	
	public void clearFilter() {
		filter = new ReportRunParameter();		
		clearState();
		searching = false;		
	}
	
	public ReportRunParameter getFilter() {
		if (filter == null)
			filter = new ReportRunParameter();
		return filter;
	}

	public void setFilter(ReportRunParameter filter) {
		this.filter = filter;
	}

	private void setFilters() {
		filter = getFilter();
		filters = new ArrayList<Filter>();

		Filter paramFilter;
		if (filter.getId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("id");
			paramFilter.setOp(Operator.like);
			paramFilter.setValue(filter.getId().toString());
			filters.add(paramFilter);
		}
		
		paramFilter = new Filter();
		paramFilter.setElement("lang");
		paramFilter.setOp(Operator.eq);
		paramFilter.setValue(curLang);
		filters.add(paramFilter);
		
		if (filter.getRunId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("runId");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(filter.getRunId().toString());
			filters.add(paramFilter);
		}
		
		if (filter.getSystemName() != null && filter.getSystemName().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("name");
			paramFilter.setOp(Operator.like);
			paramFilter.setValue(filter.getSystemName().trim().replaceAll("[*]", "%").replaceAll("[?]", "_").toUpperCase());
			filters.add(paramFilter);
		}
		
		if (filter.getName() != null && filter.getName().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("shortDesc");
			paramFilter.setOp(Operator.like);
			paramFilter.setValue(filter.getName().trim().replaceAll("[*]", "%").replaceAll("[?]", "_").toUpperCase());
			filters.add(paramFilter);
		}
	}

	public void add() {
		newParameter = new ReportRunParameter();
		newParameter.setLang(userLang);
		curMode = NEW_MODE;
	}

	public void edit() {
		try {
			newParameter = (ReportRunParameter) _activeParameter.clone();
		} catch (CloneNotSupportedException e) {
			logger.error("",e);
			newParameter = _activeParameter;
		}
		curMode = EDIT_MODE;
	}

	public void view() {
		
	}
	
	public void save() {
		try {
			if (isNewMode()) {
				
			} else if (isEditMode()) {
			
			}
						
			curMode = VIEW_MODE;
			_parametersSource.flushCache();
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("",e);
		}
	}

	public void delete() {
		try {
			_itemSelection.clearSelection();
			_parametersSource.flushCache();
			_activeParameter = null;
			curMode = VIEW_MODE;
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("",e);
		}
	}
	
	public void close() {
		curMode = VIEW_MODE;
	}

	public ReportRunParameter getNewParameter() {
		if (newParameter == null) {
			newParameter = new ReportRunParameter();		
		}
		return newParameter;
	}

	public void setNewParameter(ReportRunParameter newParameter) {
		this.newParameter = newParameter;
	}

	public void clearState() {
		_itemSelection.clearSelection();
		_activeParameter = null;			
		_parametersSource.flushCache();
		curLang = userLang;
	}
	
	public ArrayList<SelectItem> getDataTypes() {
		if (dataTypes == null){
			dataTypes = (ArrayList<SelectItem>) getDictUtils().getLov(LovConstants.DATA_TYPES);
		}
		return dataTypes;
	}
	
	public void changeLanguage(ValueChangeEvent event) {	
		curLang = (String)event.getNewValue();
		_parametersSource.flushCache();
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
