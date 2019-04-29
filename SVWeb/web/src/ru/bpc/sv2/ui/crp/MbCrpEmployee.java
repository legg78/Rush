package ru.bpc.sv2.ui.crp;

import java.util.ArrayList;


import ru.bpc.sv2.logic.utility.db.DataAccessException;
import javax.faces.bean.ManagedBean;
import javax.faces.bean.RequestScoped;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;

import org.ajax4jsf.model.KeepAlive;
import ru.bpc.sv2.crp.CrpEmployee;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.CrpDao;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.TableRowSelection;

@RequestScoped
@KeepAlive
@ManagedBean (name = "MbCrpEmployee")
public class MbCrpEmployee extends AbstractBean {
	private static final Logger logger = Logger.getLogger("CRP");
	
	private CrpDao crpDao = new CrpDao();
	
	private CrpEmployee filter;
	
	private CrpEmployee activeItem;
	private Integer departamentId;
	
	private final DaoDataModel<CrpEmployee> dataModel;
	private final TableRowSelection<CrpEmployee> tableRowSelection;
	
	public MbCrpEmployee(){
		dataModel = new DaoDataModel<CrpEmployee>(){
			@Override
			protected CrpEmployee[] loadDaoData(SelectionParams params) {
				CrpEmployee[] result = null;
				if (searching) {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					try{
						result = crpDao.getEmployees(userSessionId, params);
					}catch (DataAccessException e){
			    		FacesUtils.addMessageError(e);
    					logger.error("", e);
					}
				} else {
					result = new CrpEmployee[0];
				}
				return result;
			}
			
			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				int result = 0;
				if (searching){
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					try{
						result = crpDao.getEmployeesCount(userSessionId, params);
					}catch (DataAccessException e){
			    		FacesUtils.addMessageError(e);
    					logger.error("", e);						
					}
				} else {
					result = 0;
				}
				return result;
			}
		};
		tableRowSelection = new TableRowSelection<CrpEmployee>(null, dataModel);
	}
	
	private void setFilters() {
		filters = new ArrayList<Filter>();
		
		Filter f = new Filter();
		f.setElement("lang");
		f.setValue(curLang);
		filters.add(f);
		
		if (departamentId != null){
			f = new Filter();
			f.setElement("depId");
			f.setValue(departamentId);
			filters.add(f);
		}
		if (filter.getAccountNumber() != null  && filter.getAccountNumber().trim().length() > 0){
			f = new Filter();
			f.setElement("accountNumber");
			f.setValue(filter.getAccountNumber().trim().replaceAll("[*]", "%").replaceAll("[?]", "_").toUpperCase());
			filters.add(f);
		}
		if (filter.getEmployeeName() != null  && filter.getEmployeeName().trim().length() > 0){
			f = new Filter();
			f.setElement("employeeName");
			f.setValue(filter.getEmployeeName().trim().replaceAll("[*]", "%").replaceAll("[?]", "_").toUpperCase());
			filters.add(f);
		}
		if (filter.getContractNumber() != null  && filter.getContractNumber().trim().length() > 0){
			f = new Filter();
			f.setElement("contractNumber");
			f.setValue(filter.getContractNumber().trim().replaceAll("[*]", "%").replaceAll("[?]", "_").toUpperCase());
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
		filter = null;
		clearState();
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
		activeItem = (CrpEmployee)dataModel.getRowData();
		selection.addKey(activeItem.getModelId());
		tableRowSelection.setWrappedSelection(selection);
		if (activeItem != null) {
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
	
	public CrpEmployee getFilter() {
		if (filter == null) {
			filter = new CrpEmployee();
		}
		return filter;
	}
	
	public DaoDataModel<CrpEmployee> getDataModel(){
		return dataModel;
	}
	
	public CrpEmployee getActiveItem(){
		return activeItem;
	}

	public Integer getDepartamentId() {
		return departamentId;
	}

	public void setDepartamentId(Integer departamentId) {
		this.departamentId = departamentId;
		if (departamentId != null){
			search();
		} else {
			clearFilter();
		}
	}
	
}
