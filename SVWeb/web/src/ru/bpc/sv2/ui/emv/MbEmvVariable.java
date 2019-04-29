package ru.bpc.sv2.ui.emv;

import java.util.ArrayList;
import java.util.List;


import ru.bpc.sv2.logic.utility.db.DataAccessException;
import javax.faces.bean.ManagedBean;
import javax.faces.bean.RequestScoped;
import javax.faces.event.ValueChangeEvent;
import javax.faces.model.SelectItem;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;

import org.ajax4jsf.model.KeepAlive;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.emv.EmvVariable;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.EmvDao;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.TableRowSelection;
import util.auxil.ManagedBeanWrapper;

@RequestScoped
@KeepAlive
@ManagedBean (name = "MbEmvVariable")
public class MbEmvVariable extends AbstractBean {
	private static final Logger logger = Logger.getLogger("EMV");
	
	private static final String VARIABLE_ENTITY = "ENTTEVAR";
	
	private EmvDao emvDao = new EmvDao();
	
	
	private MbEmvElement mbEmvElement;
	
	private EmvVariable filter;
	
	private EmvVariable activeItem;
	
	private final DaoDataModel<EmvVariable> dataModel;
	private final TableRowSelection<EmvVariable> tableRowSelection;
	
	private EmvVariable editingItem;
	private Integer applicationId;
	
	private static String COMPONENT_ID = "VariableTable";
	private String tabName;
	private String parentSectionId;
	 
	public MbEmvVariable(){
		
		mbEmvElement = (MbEmvElement) ManagedBeanWrapper.getManagedBean("MbEmvElement");
		dataModel = new DaoDataModel<EmvVariable>(){
			@Override
			protected EmvVariable[] loadDaoData(SelectionParams params) {
				EmvVariable[] result = null;
				if (searching) {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					try{
						result = emvDao.getVariables(userSessionId, params);
					}catch (DataAccessException e){
			    		FacesUtils.addMessageError(e);
    					logger.error("", e);
					}
				} else {
					result = new EmvVariable[0];
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
						result = emvDao.getVariablesCount(userSessionId, params);
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
		tableRowSelection = new TableRowSelection<EmvVariable>(null, dataModel);
	}
	
	public void changeLanguage(ValueChangeEvent event) {
		curLang = (String) event.getNewValue();
		dataModel.flushCache();
	}
	
	public void confirmEditLanguage() {
		filters = new ArrayList<Filter>();
		
		Filter f = new Filter();
		f.setElement("id");
		f.setValue(editingItem.getId());
		filters.add(f);

		f = new Filter();
		f.setElement("lang");
		f.setValue(editingItem.getLang());
		filters.add(f);

		SelectionParams params = new SelectionParams();
		params.setFilters(filters.toArray(new Filter[filters.size()]));
		try {
			EmvVariable[] variables = emvDao.getVariables(userSessionId, params);
			if (variables != null && variables.length > 0) {
				editingItem = variables[0];
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}
	
	private void setFilters() {
		filters = new ArrayList<Filter>();
		
		Filter f = new Filter();
		f.setElement("lang");
		f.setValue(curLang);
		filters.add(f);
		
		if (applicationId != null){
			f = new Filter();
			f.setElement("applicationId");
			f.setValue(applicationId);
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
		mbEmvElement.setObjectId(null);
	}
	
	public void clearFilter() {
		filter = null;
		clearState();
		clearBeansStates();
		searching = false;
	}
	
	public void createNewVariable(){
		editingItem = new EmvVariable();
		editingItem.setApplicationId(applicationId);
		editingItem.setLang(curLang);
		curMode = AbstractBean.NEW_MODE;
	}
	
	public void editActiveVariable(){
		editingItem = (EmvVariable) activeItem.clone();
		curMode = AbstractBean.EDIT_MODE;
	}
	
	public void saveEditingVariable(){
		try {
			if (isNewMode()) {
				emvDao.createVariable(userSessionId, editingItem);
			} else if (isEditMode()) {
				emvDao.modifyVariable(userSessionId, editingItem);
			}
		}catch (DataAccessException e){
			FacesUtils.addMessageError(e);
			logger.error("", e);
			resetEditingVariable();
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
		resetEditingVariable();
	}
	
	public void resetEditingVariable(){
		curMode = AbstractBean.VIEW_MODE;
		editingItem = null;
	}
	
	public void deleteActiveVariable(){
		try{
			emvDao.removeVariable(userSessionId, activeItem);
		}catch (DataAccessException e){
			FacesUtils.addMessageError(e);
			logger.error("", e);
			return;
		}
		activeItem = tableRowSelection.removeObjectFromList(activeItem);		
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
		activeItem = (EmvVariable)dataModel.getRowData();
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
		mbEmvElement.setObjectId(activeItem.getId());
		mbEmvElement.setEntityType(VARIABLE_ENTITY);
	}
	
	public EmvVariable getFilter() {
		if (filter == null) {
			filter = new EmvVariable();
		}
		return filter;
	}
	
	public DaoDataModel<EmvVariable> getDataModel(){
		return dataModel;
	}
	
	public EmvVariable getActiveItem(){
		return activeItem;
	}
	
	public EmvVariable getEditingItem(){
		return editingItem;
	}

	public Integer getApplicationId() {
		return applicationId;
	}

	public void setApplicationId(Integer applicationId) {
		this.applicationId = applicationId;
		if (applicationId != null){
			search();
		} else {
			clearFilter();
		}
	}

	public List<SelectItem> getVariableTypes(){
		List<SelectItem> result = getDictUtils().getLov(LovConstants.EMV_VARIABLE_TYPE);
		return result;
	}
	
	public List<SelectItem> getProfiles(){
		List<SelectItem> result = getDictUtils().getLov(LovConstants.EMV_APPLICATION_PROFILE);
		return result;
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
