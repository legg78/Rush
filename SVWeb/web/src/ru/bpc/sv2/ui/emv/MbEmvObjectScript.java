package ru.bpc.sv2.ui.emv;

import java.util.ArrayList;
import java.util.List;


import ru.bpc.sv2.logic.utility.db.DataAccessException;
import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.model.SelectItem;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;

import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.emv.EmvObjectScript;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.EmvDao;
import ru.bpc.sv2.ui.utils.*;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import util.auxil.ManagedBeanWrapper;

@ViewScoped
@ManagedBean (name = "MbEmvObjectScript")
@SuppressWarnings("serial")
public class MbEmvObjectScript  extends AbstractBean{
	
	private EmvDao emvDao = new EmvDao();
	private static final Logger logger = Logger.getLogger("EMV");
	
	private final DaoDataModel<EmvObjectScript> dataModel;
	private final TableRowSelection<EmvObjectScript> tableRowSelection;
	private EmvObjectScript activeItem = null;
	private EmvObjectScript editingItem = null;
	private String path = null;

	EmvObjectScript filter = null;
	private DictUtils dictUtils;
	private List<SelectItem> scripts = null;
	
	private static String COMPONENT_ID = "scriptsTable";
	private String tabName;
	private String parentSectionId;
	
	public MbEmvObjectScript(){
		dictUtils = (DictUtils) ManagedBeanWrapper.getManagedBean("DictUtils");
		dataModel = new DaoDataModel<EmvObjectScript>(){
			
			
			@Override
			protected EmvObjectScript[] loadDaoData(SelectionParams params) {
				
				EmvObjectScript[] result = null;
				if (searching) {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					try{
						result = emvDao.getObjectScript(userSessionId, params);
					}catch (DataAccessException e){
			    		FacesUtils.addMessageError(e);
    					logger.error("", e);
					}
				} else {
					result = new EmvObjectScript[0];
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
						result = emvDao.getObjectScriptCount(userSessionId, params);
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
		tableRowSelection = new TableRowSelection<EmvObjectScript>(null, dataModel);
	}
	
	@Override
	public void clearFilter() {
		filter  = null;
		activeItem = null;
		searching = false;
		clearState();
		
	}

	public EmvObjectScript getFilter() {
		if (filter == null) {
			filter = new EmvObjectScript();
		}
		return filter;
	}

	public void setFilter(EmvObjectScript filter) {
		this.filter = filter;
	}
	
	public SimpleSelection getItemSelection() {
		if (activeItem == null && dataModel.getRowCount() > 0) {
			setFirstRowActive();
		} else if (activeItem != null && dataModel.getRowCount() > 0) {
			SimpleSelection selection = new SimpleSelection();
			selection.addKey(activeItem.getModelId());
			tableRowSelection.setWrappedSelection(selection);
			activeItem = tableRowSelection.getSingleSelection();
		} else if (activeItem != null && dataModel.getRowCount() == 0){
			activeItem = tableRowSelection.getSingleSelection();
		}
		
		return tableRowSelection.getWrappedSelection();
	}
	
	public void setItemSelection(SimpleSelection selection) {
		tableRowSelection.setWrappedSelection(selection);
		activeItem = tableRowSelection.getSingleSelection();

		if (activeItem != null) {
			setBeansState();
		}
	}
	
	public void setFirstRowActive() {
		dataModel.setRowIndex(0);
		SimpleSelection selection = new SimpleSelection();
		activeItem = (EmvObjectScript) dataModel.getRowData();
		selection.addKey(activeItem.getModelId());
		tableRowSelection.setWrappedSelection(selection);
		if (activeItem != null) {
			setBeansState();
		}
	}
	private void setBeansState(){
		
	}
	public EmvObjectScript getActiveItem(){
		return activeItem;
	}
				
	
	private void setFilters() {
		filters = new ArrayList<Filter>();
		Filter f = new Filter();
		f.setElement("lang");
		f.setValue(curLang);
		filters.add(f);
		
		if (filter.getObjectId() != null){
			f = new Filter("objectId", filter.getObjectId());			
			filters.add(f);
		}
		if (filter.getEntityType() != null){
			f = new Filter("entityType", filter.getEntityType());
			filters.add(f);
		}				
	}
	
	
	public void search() {
		clearState();	
		searching = true;
	}
	public void clearState() {
		tableRowSelection.clearSelection();
		dataModel.flushCache();
		curLang = userLang;
	}
	public void clearBeanState(){
		clearState();
	}
	
	public DaoDataModel<EmvObjectScript> getDataModel(){
		return dataModel;
	}
	
	public void add(){
		editingItem = new EmvObjectScript();
		curMode = AbstractBean.NEW_MODE;
		path = null;
		editingItem.setObjectId(filter.getObjectId());
		editingItem.setEntityType(filter.getEntityType());		
		
	}		
	
	public void delete(){
		try{
			emvDao.removeScript(userSessionId, activeItem);
		}catch (DataAccessException e){
			FacesUtils.addMessageError(e);
			logger.error("", e);
			return;
		}
		activeItem = tableRowSelection.removeObjectFromList(activeItem);
	}
	
	public void save(){
		try {
			EmvObjectScript updatedEditingItem = null;
			if (isNewMode()) {
				updatedEditingItem = emvDao.createScript(userSessionId, editingItem);
			} 			
			editingItem = updatedEditingItem;
		}catch (DataAccessException e){
			FacesUtils.addMessageError(e);
			logger.error(e.getMessage(), e);
			cancel();
			return;
		}
		if (isNewMode()) {
			tableRowSelection.addNewObjectToList(editingItem);
		} else {
			try {
				dataModel.replaceObject(activeItem, editingItem);
			} catch (Exception e) {
				e.printStackTrace();
			}
		}
		activeItem = editingItem;
		cancel();
		search();
	}
	
	public void cancel(){
		curMode = AbstractBean.VIEW_MODE;
		editingItem = null;
		path = null;
	}
	public List<SelectItem> getScripts(){
		if (scripts == null){
			scripts = dictUtils.getLov(LovConstants.SCRIPT_TYPE);
		}
		return scripts;
	}
	
	public EmvObjectScript getEditingItem(){
		return editingItem;
	}
		
	public String getPath(){
		List<Filter> fil = new ArrayList<Filter>();		
		if((editingItem != null) && (editingItem.getType() != null)){			
			Filter f = new Filter();
			f.setElement("type");
			f.setValue(editingItem.getType());			
			fil.add(f);
			
			SelectionParams params = new SelectionParams();
			params.setFilters(fil.toArray(new Filter[fil.size()]));;
			
			try{
				path = emvDao.getScriptFormUrl(userSessionId, params);
			}catch (DataAccessException e){
	    		FacesUtils.addMessageError(e);
				logger.error("", e);
			}
		}
		return path;
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
