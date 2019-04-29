package ru.bpc.sv2.ui.reports;

import java.util.ArrayList;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.RequestScoped;
import javax.faces.event.ValueChangeEvent;
import javax.faces.model.SelectItem;

import org.ajax4jsf.model.KeepAlive;
import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;

import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.invocation.Filter.Operator;
import ru.bpc.sv2.logic.ReportsDao;
import ru.bpc.sv2.reports.OutReportParameter;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.TableRowSelection;


@RequestScoped
@KeepAlive
@ManagedBean (name = "MbReportOutParametersSearch" )
public class MbReportOutParametersSearch extends AbstractBean {
	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;
	private static final Logger logger = Logger.getLogger("REPORTS");
	
	private ReportsDao _reportsDao = new ReportsDao();
	
	private OutReportParameter filter;
	private OutReportParameter newOutReportParameter;
	private ArrayList<SelectItem> dataTypes;
	private OutReportParameter _activeOutParameter;
	private final DaoDataModel<OutReportParameter> _parametersSource;

	private final TableRowSelection<OutReportParameter> _itemSelection;
	
	public MbReportOutParametersSearch(){
		_parametersSource = new DaoDataModel<OutReportParameter>() {
			
			/**
			 * 
			 */
			private static final long serialVersionUID = 1L;

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (!searching) {
					return 0;
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _reportsDao.getOutReportParametersCount(userSessionId, params);
				} catch (Exception e) {
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return 0;
			}
			
			@Override
			protected OutReportParameter[] loadDaoData(SelectionParams params) {
				if (!searching) {
					return new OutReportParameter[0];
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					OutReportParameter[] parameters = _reportsDao.getOutReportParameters(userSessionId, params);
					return parameters;
				} catch (Exception e) {
					setDataSize(0);
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return new OutReportParameter[0];
			}
		};
		_itemSelection = new TableRowSelection<OutReportParameter>(null, _parametersSource);
		
	}
	
	private void setFilters() {
		filter = getFilter();
		filters = new ArrayList<Filter>();

		Filter paramFilter;
		
		paramFilter = new Filter();
		paramFilter.setElement("lang");
		paramFilter.setOp(Operator.eq);
		paramFilter.setValue(curLang);
		filters.add(paramFilter);
		
		paramFilter = new Filter();
		paramFilter.setElement("reportId");
		paramFilter.setOp(Operator.eq);
		paramFilter.setValue(filter.getReportId());
		filters.add(paramFilter);
	}	

	@Override
	public void clearFilter() {
		filter = new OutReportParameter();
		clearState();
		searching = false;
	}
	
	public void clearState() {
		_itemSelection.clearSelection();
		setActiveOutParameter(null);
		_parametersSource.flushCache();
		curLang = userLang;
	}
	
	public void search() {
		clearState();
		searching = true;
	}
	
	public OutReportParameter getFilter(){
		if (filter == null){
			filter = new OutReportParameter();
		}
		return filter;
	}
	
	public void setFilter(OutReportParameter filter){
		this.filter = filter;
	}

	public OutReportParameter getNewOutReportParameter() {
		return newOutReportParameter;
	}

	public void setNewOutReportParameter(OutReportParameter newOutReportParameter) {
		this.newOutReportParameter = newOutReportParameter;
	}

	public OutReportParameter getActiveOutParameter() {
		return _activeOutParameter;
	}
	
	public ArrayList<SelectItem> getDataTypes() {
		if (dataTypes == null){
			dataTypes = (ArrayList<SelectItem>) getDictUtils().getLov(LovConstants.DATA_TYPES);
		}
		return dataTypes;
	}

	public void setActiveOutParameter(OutReportParameter _activeOutParameter) {
		this._activeOutParameter = _activeOutParameter;
	}
	
	public DaoDataModel<OutReportParameter> getOutParameters() {
		return _parametersSource;
	}
	
	public SimpleSelection getItemSelection() {
		try {
			if (_activeOutParameter == null && _parametersSource.getRowCount() > 0) {
				setFirstRowActive();
			} else if (_activeOutParameter != null && _parametersSource.getRowCount() > 0) {
				SimpleSelection selection = new SimpleSelection();
				selection.addKey(_activeOutParameter.getModelId());
				_itemSelection.setWrappedSelection(selection);
				_activeOutParameter = _itemSelection.getSingleSelection();
			}
		} catch (Exception e) {
			logger.error("", e);
			FacesUtils.addMessageError(e);
		}
		return _itemSelection.getWrappedSelection();
	}
	
	public void setItemSelection(SimpleSelection selection) {
		_itemSelection.setWrappedSelection(selection);
		_activeOutParameter = _itemSelection.getSingleSelection();
	}
	
	public void setFirstRowActive() {
		_parametersSource.setRowIndex(0);
		SimpleSelection selection = new SimpleSelection();
		_activeOutParameter = (OutReportParameter) _parametersSource.getRowData();
		selection.addKey(_activeOutParameter.getModelId());
		_itemSelection.setWrappedSelection(selection);
	}
	
	public void changeLanguage(ValueChangeEvent event) {
		curLang = (String) event.getNewValue();
		_parametersSource.flushCache();
	}
	
	public void add(){
		newOutReportParameter = new OutReportParameter();
		newOutReportParameter.setLang(curLang);
		newOutReportParameter.setReportId(filter.getReportId());
		curMode = NEW_MODE;
	}
	
	public void edit(){
		newOutReportParameter = _activeOutParameter;
		curMode = EDIT_MODE;
	}
	
	public void save(){
		try{switch(curMode){
			case NEW_MODE:
				newOutReportParameter = _reportsDao.addOutReportParam(
						newOutReportParameter, userSessionId);
				_itemSelection.addNewObjectToList(newOutReportParameter);
				break;
			case EDIT_MODE:
				newOutReportParameter = _reportsDao.modifyOutReportParam(
						newOutReportParameter, userSessionId);
				_parametersSource.replaceObject(
						_activeOutParameter, newOutReportParameter);
				break;
		}
			
		}catch (Exception e){
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}finally{
			cancel();
		}
	}
	
	public void delete(){
		try{
			_reportsDao.removeOutReportParameter(userSessionId, _activeOutParameter);
			_parametersSource.removeObjectFromList(_activeOutParameter);
			cancel();
		}catch (Exception e){
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}
	
	public void cancel(){
		newOutReportParameter = new OutReportParameter();
		curMode = VIEW_MODE;
	}

}
