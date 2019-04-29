package ru.bpc.sv2.ui.application;

import java.util.ArrayList;


import ru.bpc.sv2.logic.utility.db.DataAccessException;
import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;

import ru.bpc.sv2.application.ApplicationHistory;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.ApplicationDao;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.TableRowSelection;

@ViewScoped
@ManagedBean (name = "MbApplicationHistory")
public class MbApplicationHistory extends AbstractBean {
	private static final Logger logger = Logger.getLogger("APPLICATION");

	private ApplicationDao applicationDao = new ApplicationDao();

	private ApplicationHistory filter;
	private ApplicationHistory activeItem;

	private final DaoDataModel<ApplicationHistory> dataModel;
	private final TableRowSelection<ApplicationHistory> tableRowSelection;

	private static String COMPONENT_ID = "ApplicationHistoryTable";
	private String tabName;
	private String parentSectionId;

	public MbApplicationHistory() {
		dataModel = new DaoDataModel<ApplicationHistory>(){
			@Override
			protected ApplicationHistory[] loadDaoData(SelectionParams params) {
				ApplicationHistory[] result = null;
				if (getFilter().getApplId() != null) {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));

					try{
						result = applicationDao.getApplicationHistories(userSessionId, params);
					}catch (DataAccessException e){
			    		FacesUtils.addMessageError(e);
						logger.error("", e);
					}
				} else {
					result = new ApplicationHistory[0];
				}
				return result;
			}
			
			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				int result = 0;
				if (getFilter().getApplId() != null){
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					try{
						result = applicationDao.getApplicationHistoriesCount(userSessionId, params);
					}catch (DataAccessException e) {
						FacesUtils.addMessageError(e);
						logger.error("", e);
					}
				} else {
					result = 0;
				}
				return result;
			}
		};
		tableRowSelection = new TableRowSelection<ApplicationHistory>(null, dataModel);
	}
	
	private void setFilters() {
		filters = new ArrayList<Filter>();
		
		Filter f = new Filter();
		f.setElement("lang");
		f.setValue(curLang);
		filters.add(f);
		
		if (filter.getApplId() != null){
			f = new Filter();
			f.setElement("applId");
			f.setValue(filter.getApplId());
			filters.add(f);
		}
	
		if (filter.getApplStatus() != null){
			f = new Filter();
			f.setElement("applStatus");
			f.setValue(filter.getApplStatus());
			filters.add(f);
		}
	}
	
	public void search() {
		clearState();
		clearBeansStates();
		searching = true;
	}
	
	public void clearState() {
		tableRowSelection.clearSelection();
		activeItem = null;
		dataModel.flushCache();
		curLang = userLang;
	}
	
	public void clearBeansStates(){
		
	}
	
	public void clearFilter() {
		setFilter(null);
		clearState();
		clearBeansStates();
		searching = false;
	}
	
	public SimpleSelection getItemSelection() {
		if (activeItem == null && dataModel.getRowCount() > 0){
			prepareItemSelection();
		}
		return tableRowSelection.getWrappedSelection();
	}
	
	public void prepareItemSelection(){
		dataModel.setRowIndex(0);
		SimpleSelection selection = new SimpleSelection();
		activeItem = (ApplicationHistory)dataModel.getRowData();
		if (activeItem != null) {
			selection.addKey(activeItem.getModelId());
			tableRowSelection.setWrappedSelection(selection);
			setBeansState();
		}
	}
	
	public void setItemSelection(SimpleSelection selection) {
		tableRowSelection.setWrappedSelection(selection);
		activeItem = tableRowSelection.getSingleSelection();
		if (activeItem != null) {
			setBeansState();
		}
	}
	
	private void setBeansState(){
	
	}
	
	public ApplicationHistory getFilter() {
		if (filter == null) {
			filter = new ApplicationHistory();
		}
		return filter;
	}
	
	public DaoDataModel<ApplicationHistory> getDataModel(){
		return dataModel;
	}
	
	public ApplicationHistory getActiveItem(){
		return activeItem;
	}

	public void setFilter(ApplicationHistory filter) {
		this.filter = filter;
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
