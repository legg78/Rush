package ru.bpc.sv2.ui.emv;


import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.emv.EmvScriptType;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.EmvDao;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.TableRowSelection;

import java.util.ArrayList;
import java.util.List;


import ru.bpc.sv2.logic.utility.db.DataAccessException;
import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.event.ValueChangeEvent;
import javax.faces.model.SelectItem;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;

@ViewScoped
@ManagedBean (name = "MbEmvScriptType")
@SuppressWarnings("serial")
public class MbEmvScriptType extends AbstractBean{
	
	private static final Logger logger = Logger.getLogger("EMV");
	private EmvDao emvDao = new EmvDao();
	
	private EmvScriptType filter;
	private EmvScriptType activeItem;	
	private EmvScriptType editingItem;
	
	private List<SelectItem> type = null;
	private List<SelectItem> condition = null;
	
	private final DaoDataModel<EmvScriptType> dataModel;
	private final TableRowSelection<EmvScriptType> tableRowSelection; 

	public MbEmvScriptType(){
		pageLink = "emv|scriptTypes";
		dataModel = new DaoDataModel<EmvScriptType>(){

			@Override
			protected EmvScriptType[] loadDaoData(SelectionParams params) {
				EmvScriptType[] result = null;
				if (searching) {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					try{
						result = emvDao.getScriptType(userSessionId, params);
					}catch (DataAccessException e){
			    		FacesUtils.addMessageError(e);
    					logger.error("", e);
					}
				} else {
					result = new EmvScriptType[0];
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
						result = emvDao.getCardTypeCount(userSessionId, params);
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
		tableRowSelection = new TableRowSelection<EmvScriptType>(null, dataModel);			
	}
	
	private void setFilters() {
		filters = new ArrayList<Filter>();
		Filter f = new Filter();
		f.setElement("lang");
		f.setValue(curLang);
		filters.add(f);
		
		if ((filter.getCondition() != null) && (filter.getCondition().trim().length() > 0)){
			f = new Filter("condition", filter.getCondition());			
			filters.add(f);
		}
		
		if (filter.getType() != null && filter.getType().trim().length() > 0){
			f = new Filter("type", filter.getType());
			filters.add(f);
		}
	}
	
	@Override
	public void clearFilter() {
		filter = null;
		clearState();
		searching = false;
		
	}
	
	public void clearState() {
		tableRowSelection.clearSelection();
		activeItem = null;
		dataModel.flushCache();
		curLang = userLang;
	}
	
	public void search(){
		clearState();
		searching = true;
	}	
	
	public List <SelectItem> getScriptType(){
		if (type == null){
			type = getDictUtils().getLov(LovConstants.EMV_SCRIPT_TYPE);
		}
		return type;
	}	
	public void setType(List<SelectItem> type){
		this.type = type;
	}
	
	public EmvScriptType getFilter() {
		if (filter == null) {
			filter = new EmvScriptType();
		}
		return filter;
	}
	
	public SimpleSelection getItemSelection() {
		if (activeItem == null && dataModel.getRowCount() > 0) {
			setFirstRowActive();
		} else if (activeItem != null && dataModel.getRowCount() > 0) {
			SimpleSelection selection = new SimpleSelection();
			selection.addKey(activeItem.getModelId());
			tableRowSelection.setWrappedSelection(selection);
			activeItem = tableRowSelection.getSingleSelection();
		}
		return tableRowSelection.getWrappedSelection();
	}
 	public void setItemSelection(SimpleSelection selection) {
		tableRowSelection.setWrappedSelection(selection);
		activeItem = tableRowSelection.getSingleSelection();

		if (activeItem != null) {
			//setBeansState();
		}
	}

	public void setFirstRowActive() {
		dataModel.setRowIndex(0);
		SimpleSelection selection = new SimpleSelection();
		activeItem = (EmvScriptType) dataModel.getRowData();
		selection.addKey(activeItem.getModelId());
		tableRowSelection.setWrappedSelection(selection);
		if (activeItem != null) {
		//	setBeansState();
		}
	}
	
	public DaoDataModel<EmvScriptType> getDataModel(){
		return dataModel;
	}
	
	public void changeLanguage(ValueChangeEvent event) {
		curLang = (String) event.getNewValue();

		filters = new ArrayList<Filter>();

		Filter f = new Filter();
		f.setElement("id");
		f.setValue(activeItem.getId());
		filters.add(f);

		f = new Filter();
		f.setElement("lang");
		f.setValue(curLang);
		filters.add(f);
		
		SelectionParams params = new SelectionParams();
		params.setFilters(filters.toArray(new Filter[filters.size()]));
		try {
			EmvScriptType[] applications = emvDao.getScriptType(userSessionId, params);
			if (applications != null && applications.length > 0) {
				activeItem = applications[0];
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}
	
	public EmvScriptType getActiveItem(){
		return activeItem;
	}
	
	public void add(){
		editingItem = new EmvScriptType();
		curMode = AbstractBean.NEW_MODE;		
	}
	
	public void delete(){
		try{
			emvDao.removeScriptType(userSessionId, activeItem);
		}catch (DataAccessException e){
			FacesUtils.addMessageError(e);
			logger.error("", e);
			return;
		}
		activeItem = tableRowSelection.removeObjectFromList(activeItem);
	}
	
	public void save(){
		try {
			editingItem.setLang(curLang);
			EmvScriptType updatedEditingItem = null;
			if (isNewMode()) {
				updatedEditingItem = emvDao.createScriptType(userSessionId, editingItem);
			} else if (isEditMode()){
				updatedEditingItem = emvDao.modifyScriptType(userSessionId, editingItem);
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
	public void edit(){
		curMode = AbstractBean.EDIT_MODE;
		editingItem = activeItem ;
	}
	
	public void view(){
		curMode = AbstractBean.VIEW_MODE;
	}
	
	public void cancel(){
		curMode = AbstractBean.VIEW_MODE;
		editingItem = null;		
	}
	public EmvScriptType getEditingItem(){
		return editingItem;
	}
	
	public List <SelectItem> getCondition(){
		if (condition == null){
			condition = getDictUtils().getLov(LovConstants.CONDITION);
		}
		return condition;
	}
}
