package ru.bpc.sv2.ui.process;

import java.util.ArrayList;
import java.util.List;

import javax.annotation.Resource;

import javax.faces.bean.ManagedBean;
import javax.faces.bean.RequestScoped;
import javax.faces.event.ValueChangeEvent;
import javax.faces.model.SelectItem;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;

import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.invocation.Filter.Operator;
import ru.bpc.sv2.logic.ProcessDao;
import ru.bpc.sv2.process.ProcessBO;
import ru.bpc.sv2.process.ProcessParameter;
import ru.bpc.sv2.schedule.ScheduledTask;
import ru.bpc.sv2.ui.navigation.Menu;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.TableRowSelection;
import util.auxil.ManagedBeanWrapper;

@RequestScoped
@ManagedBean (name = "MbContainersSearch" )
public class MbContainersSearch extends AbstractBean {
	private ProcessDao _processDao = new ProcessDao();
    
	private ProcessBO _activeProcess;
	private ProcessBO newProcess;
	
	 
	private ProcessBO filter;

	private String backLink;
	private boolean selectMode;
	private boolean loadState; 
	private MbContainersAll procBean;
	
	private ArrayList<SelectItem> institutions;
	
	private final DaoDataModel<ProcessBO> _processesSource;
	
	private final TableRowSelection<ProcessBO> _itemSelection;
	
	private static final Logger logger = Logger.getLogger("PROCESSES");
	
	public MbContainersSearch() {
		procBean = (MbContainersAll)ManagedBeanWrapper.getManagedBean("MbContainersAll");
		Menu menu = (Menu) ManagedBeanWrapper.getManagedBean("menu");
		
		_processesSource = new DaoDataModel<ProcessBO>()
							{
								@Override
								protected ProcessBO[] loadDaoData(SelectionParams params )
								{
									if (!isSearching())
										return new ProcessBO[0];
									setFilters();
									params.setFilters(filters.toArray(new Filter[filters.size()]));
									return _processDao.getContainersAll( userSessionId,  params );
								}
					
								@Override
								protected int loadDaoDataSize(SelectionParams params )
								{
									if (!isSearching())
										return 0;
									setFilters();
									params.setFilters(filters.toArray(new Filter[filters.size()]));
									return _processDao.getContainersAllCount( userSessionId,  params );
								}
							};
		
		_itemSelection = new TableRowSelection<ProcessBO>( null, _processesSource );
		
		if (!menu.isKeepState()) {
        	procBean.setTabName("");
        	
        } else {
        	_activeProcess = procBean.getProcess();
        	backLink = procBean.getBackLink();
        	searching = procBean.isSearching();  
        	filter = procBean.getSavedFilter();
        	loadState = true;
        }
	}
	
	public DaoDataModel<ProcessBO> getProcesses()
	{
		return _processesSource;
	}
	
	public ProcessBO getActiveProcess()
	{
		return _activeProcess;
	}

	public void setActiveProcess( ProcessBO activeProcess )
	{
		_activeProcess = activeProcess;
	}

	public SimpleSelection getItemSelection() {
		if (_activeProcess == null && _processesSource.getRowCount() > 0) {
			setFirstRowActive();
		}
		else if (_activeProcess != null && _processesSource.getRowCount() > 0)
		{
			SimpleSelection selection = new SimpleSelection();
			selection.addKey(_activeProcess.getModelId());
			_itemSelection.setWrappedSelection(selection);
			_activeProcess = _itemSelection.getSingleSelection();
			
			if (loadState == true) {
				setInfo();
				loadState = false;
			}
		}
		return _itemSelection.getWrappedSelection();
	}

	public void setFirstRowActive(){
		_processesSource.setRowIndex(0);
		SimpleSelection selection = new SimpleSelection();
		_activeProcess = (ProcessBO)_processesSource.getRowData();
		selection.addKey(_activeProcess.getModelId());
		_itemSelection.setWrappedSelection(selection);
		procBean.setProcess(_activeProcess);
		setInfo();			
	}

	public void setItemSelection( SimpleSelection selection )
	{
		_itemSelection.setWrappedSelection( selection );
		_activeProcess = _itemSelection.getSingleSelection();
		procBean.setProcess(_activeProcess);
		setInfo();
	}

	public void setInfo() {
		if (_activeProcess != null)
		{
			MbContainerParamsSearch procParamBean = (MbContainerParamsSearch)ManagedBeanWrapper.getManagedBean("MbContainerParamsSearch");
			ProcessParameter paramFilter = new ProcessParameter();
			paramFilter.setContainerId(_activeProcess.getId());
			procParamBean.setFilter(paramFilter);
			procParamBean.search();
			
			MbContainerProcessesSearch procBean = (MbContainerProcessesSearch)ManagedBeanWrapper.getManagedBean("MbContainerProcessesSearch");
			ProcessBO procFilter = new ProcessBO();
			procFilter.setContainerId(_activeProcess.getId());
			procBean.setFilter(procFilter);
			procBean.search();
			
			MbContainerTasksSearch taskBean = (MbContainerTasksSearch)ManagedBeanWrapper.getManagedBean("MbContainerTasksSearch");
			ScheduledTask task = new ScheduledTask();
			task.setContainerId(_activeProcess.getId());
			taskBean.setFilter(task);
			taskBean.search();
			
//			MbProgressBars barBean = (MbProgressBars)ManagedBeanWrapper.getManagedBean("MbProgressBars");
//			barBean.setEnabled(true);
			
		}
	}
	public void search()
	{
		clearState();
		setSearching(true);
		procBean.setSavedFilter(filter);
	}

	public void setFilters()
	{
		Filter paramFilter = null;
		filters = new ArrayList<Filter>();
		filter = getFilter();
		
		paramFilter = new Filter();
		paramFilter.setElement("lang");
		paramFilter.setOp(Operator.eq);
		paramFilter.setValue(userLang);
		filters.add(paramFilter);
		
		if (filter.getProcedureName() != null && filter.getProcedureName().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("procedureName");
			paramFilter.setOp(Operator.like);
			paramFilter.setValue(filter.getProcedureName().trim().toUpperCase().replaceAll("[*]", "%").replaceAll("[?]", "_"));
			filters.add(paramFilter);
		}
		if (filter.getDescription() != null && filter.getDescription().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("description");
			paramFilter.setOp(Operator.like);
			paramFilter.setValue(filter.getDescription().trim().toUpperCase().replaceAll("[*]", "%").replaceAll("[?]", "_"));
			filters.add(paramFilter);
		}
		if (filter.getName() != null && filter.getName().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("name");
			paramFilter.setOp(Operator.like);
			paramFilter.setValue(filter.getName().trim().toUpperCase().replaceAll("[*]", "%").replaceAll("[?]", "_"));
			filters.add(paramFilter);
		}
		if (filter.getGroupId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("groupId");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(filter.getGroupId().toString());
			filters.add(paramFilter);
		}
		if (filter.getContainerId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("containerId");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(filter.getContainerId().toString());
			filters.add(paramFilter);
		}
		if (filter.getInstId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("instId");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(filter.getInstId().toString());
			filters.add(paramFilter);
		}
	}


	public void add() {
		newProcess = new ProcessBO();
		newProcess.setLang(userLang);
		curMode = NEW_MODE;
	}

	public void edit() {
		try {
			newProcess = (ProcessBO) _activeProcess.clone();
		} catch (CloneNotSupportedException e) {
			logger.error("",e);
			newProcess = _activeProcess;
		}
		curMode = EDIT_MODE;
	}
	
	public void save() {
    	try {
    		if (isEditMode()) {
    			newProcess = _processDao.modifyProcess( userSessionId, newProcess);
    			_processesSource.replaceObject(_activeProcess, newProcess);
    		} else if (isNewMode()){
    			newProcess = _processDao.addProcess( userSessionId, newProcess);
    			_itemSelection.addNewObjectToList(newProcess);
    		}
    		_activeProcess = newProcess;
    		setInfo();
    		curMode = VIEW_MODE;
    	} catch (Exception e) {
    		FacesUtils.addMessageError(e);
    		logger.error("",e);
    	}
    }
	public void delete() {
		try {
			_processDao.deleteProcess( userSessionId, _activeProcess);
			_activeProcess = _itemSelection.removeObjectFromList(_activeProcess);
			if (_activeProcess == null) {
				clearState();
			} else {
				setInfo();
			}
			curMode = VIEW_MODE;
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("",e);
		}
	}
	
	public void close() {
		curMode = VIEW_MODE;
	}

	public void setCurMode(int mode) {
		curMode = mode;
	}

	public boolean isViewMode() {
		return curMode == VIEW_MODE;
	}

	public boolean isEditMode() {
		return curMode == EDIT_MODE;
	}

	public boolean isNewMode() {
		return curMode == NEW_MODE;
	}
	
	public ProcessBO getFilter() {
		if (filter == null)
			filter = new ProcessBO();
		return filter;
	}

	public void setFilter(ProcessBO filter) {
		this.filter = filter;
	}
	
	public String getBackLink() {
		return backLink;
	}

	public void setBackLink(String backLink) {
		this.backLink = backLink;
	}

	public void setSearching(boolean searching) {
		this.searching = searching;
		procBean.setSearching(searching);
	}
	
	public String cancelSelect()
	{
		return backLink;
	}

	public boolean isSelectMode() {
		return selectMode;
	}

	public void setSelectMode(boolean selectMode) {
		this.selectMode = selectMode;
	}
	
	public String addProcess() {
		
		setSelectMode(true);
		getFilter().setGroupId(null);
		Menu menu = (Menu) ManagedBeanWrapper.getManagedBean("menu");
        menu.setKeepState(true);
        MbProcesses prcBean = (MbProcesses)ManagedBeanWrapper.getManagedBean("MbProcesses");
		prcBean.setProcess(null);
        return "prc_prc_to_container";
	}
	
	public void clearState() {
		_processesSource.flushCache();
		_itemSelection.clearSelection();
		_activeProcess = null;
		
		clearBeansStates();
	}
	
	public void clearBeansStates() {
		MbContainerParamsSearch procParamBean = (MbContainerParamsSearch)ManagedBeanWrapper.getManagedBean("MbContainerParamsSearch");
		procParamBean.clearState();
		
		MbContainerProcessesSearch procBean = (MbContainerProcessesSearch)ManagedBeanWrapper.getManagedBean("MbContainerProcessesSearch");
		procBean.clearState();
		
		MbContainerTasksSearch taskBean = (MbContainerTasksSearch)ManagedBeanWrapper.getManagedBean("MbContainerTasksSearch");
		taskBean.clearState();
	}
	
	public String addProcessToContainer() {
		Menu menu = (Menu) ManagedBeanWrapper.getManagedBean("menu");
        menu.setKeepState(true);
        
        this.selectMode = true;
		return "prc_processes";
	}

	public ArrayList<SelectItem> getInstitutions() {
		if (institutions == null) {
			institutions = (ArrayList<SelectItem>) getDictUtils().getLov(LovConstants.INSTITUTIONS_SYS);
		}
		if (institutions == null)
			institutions = new ArrayList<SelectItem>();
		return institutions;
	}

	public ProcessBO getNewProcess() {
		if (newProcess == null) {
			newProcess = new ProcessBO();
		}
		return newProcess;
	}

	public void setNewProcess(ProcessBO newProcess) {
		this.newProcess = newProcess;
	}

	public void changeLanguage(ValueChangeEvent event) {	
		curLang = (String)event.getNewValue();
		
		List<Filter> filtersList = new ArrayList<Filter>();
		
		Filter paramFilter = new Filter();
		paramFilter.setElement("id");
		paramFilter.setOp(Operator.eq);
		paramFilter.setValue(_activeProcess.getId().toString());
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
			ProcessBO[] processes = _processDao.getContainersAll( userSessionId, params);
			if (processes != null && processes.length > 0) {
				_activeProcess = processes[0];				
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("",e);
		}		
	}

	@Override
	public void clearFilter() {
		// TODO Auto-generated method stub
		
	}
}
