package ru.bpc.sv2.ui.emv;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;


import ru.bpc.sv2.logic.utility.db.DataAccessException;
import javax.faces.bean.ManagedBean;
import javax.faces.bean.RequestScoped;
import javax.faces.model.SelectItem;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;

import org.ajax4jsf.model.KeepAlive;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.emv.EmvBlock;
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
@ManagedBean (name = "MbEmvBlock")
public class MbEmvBlock extends AbstractBean {
	private static final Logger logger = Logger.getLogger("EMV");
	
	private static final String BLOCK_ENTITY = "ENTTEBLK";
	
	private EmvDao emvDao = new EmvDao();
	
	
	private MbEmvElement mbEmvElement;
	
	private EmvBlock filter;
	
	private EmvBlock activeItem;
	
	private final DaoDataModel<EmvBlock> dataModel;
	private final TableRowSelection<EmvBlock> tableRowSelection;
	
	private EmvBlock editingItem;
	private Integer applicationId;
	
	private static String COMPONENT_ID = "BlockTable";
	private String tabName;
	private String parentSectionId;
	 
	public MbEmvBlock(){
		
		mbEmvElement = (MbEmvElement) ManagedBeanWrapper.getManagedBean("MbEmvElement");
		dataModel = new DaoDataModel<EmvBlock>(){
			@Override
			protected EmvBlock[] loadDaoData(SelectionParams params) {
				EmvBlock[] result = null;
				if (searching) {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					try{
						result = emvDao.getBlocks(userSessionId, params);
					}catch (DataAccessException e){
			    		FacesUtils.addMessageError(e);
    					logger.error("", e);
					}
				} else {
					result = new EmvBlock[0];
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
						result = emvDao.getBlocksCount(userSessionId, params);
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
		tableRowSelection = new TableRowSelection<EmvBlock>(null, dataModel);
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
		searching = false;
	}
	
	public void createNewBlock(){
		editingItem = new EmvBlock();
		editingItem.setApplicationId(applicationId);
		curMode = AbstractBean.NEW_MODE;
	}
	
	public void editActiveBlock(){
		editingItem = (EmvBlock) activeItem.clone();
		curMode = AbstractBean.EDIT_MODE;
	}
	
	public void saveEditingBlock(){
		try {
			EmvBlock updatedEditingItem = null;
			if (isNewMode()) {
				updatedEditingItem = emvDao.createBlock(userSessionId, editingItem);
			} else if (isEditMode()) {
				updatedEditingItem = emvDao.modifyBlock(userSessionId, editingItem);
			}
			editingItem = updatedEditingItem;
		}catch (DataAccessException e){
			FacesUtils.addMessageError(e);
			logger.error("", e);
			resetEditingBlock();
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
		resetEditingBlock();
		setBeansState();
	}
	
	public void resetEditingBlock(){
		curMode = AbstractBean.VIEW_MODE;
		editingItem = null;
	}
	
	public void deleteActiveBlock(){
		try{
			emvDao.removeBlock(userSessionId, activeItem);
		}catch (DataAccessException e){
			FacesUtils.addMessageError(e);
			logger.error("", e);
			return;
		}
		activeItem = tableRowSelection.removeObjectFromList(activeItem);
		clearBeansStates();
		if (activeItem!=null)
			setBeansState();
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
		activeItem = (EmvBlock)dataModel.getRowData();
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
		mbEmvElement.setEntityType(BLOCK_ENTITY);
	}
	
	public EmvBlock getFilter() {
		if (filter == null) {
			filter = new EmvBlock();
		}
		return filter;
	}
	
	public DaoDataModel<EmvBlock> getDataModel(){
		return dataModel;
	}
	
	public EmvBlock getActiveItem(){
		return activeItem;
	}
	
	public EmvBlock getEditingItem(){
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
			clearState();
			clearBeansStates();
			searching = false;
		}
	}

	public List<SelectItem> getTransportKeyVariables(){
		Map<String,Object> parameters = new HashMap<String,Object>();
		parameters.put("variable_type","EVTP0100");
		parameters.put("application_id",applicationId);
		List<SelectItem> result = getDictUtils().getLov(LovConstants.EMV_VARIABLE, parameters);
		return result;
	}
	
	public List<SelectItem> getEncryptionKeyVariables(){
		Map<String,Object> parameters = new HashMap<String,Object>();
		parameters.put("variable_type","EVTP0200");
		parameters.put("application_id",applicationId);
		List<SelectItem> result = getDictUtils().getLov(LovConstants.EMV_VARIABLE, parameters);
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
