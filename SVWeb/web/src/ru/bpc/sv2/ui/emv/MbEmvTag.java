package ru.bpc.sv2.ui.emv;

import java.util.ArrayList;
import java.util.List;


import ru.bpc.sv2.logic.utility.db.DataAccessException;
import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.event.ValueChangeEvent;
import javax.faces.model.SelectItem;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;

import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.emv.EmvTag;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.EmvDao;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.TableRowSelection;

@ViewScoped
@ManagedBean (name = "MbEmvTag")
public class MbEmvTag extends AbstractBean {
	private static final Logger logger = Logger.getLogger("EMV");
	
	private static String COMPONENT_ID = "2270:EmvTagTable";

	private EmvDao emvDao = new EmvDao();
	
	
	
	private EmvTag filter;
	
	private EmvTag activeItem;
	
	private final DaoDataModel<EmvTag> dataModel;
	private final TableRowSelection<EmvTag> tableRowSelection;
	
	private EmvTag editingItem;
	 
	public MbEmvTag(){
		pageLink = "emv|tags";
		dataModel = new DaoDataModel<EmvTag>(){
			@Override
			protected EmvTag[] loadDaoData(SelectionParams params) {
				EmvTag[] result = null;
				if (searching) {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					try{
						result = emvDao.getTags(userSessionId, params);
					}catch (DataAccessException e){
			    		FacesUtils.addMessageError(e);
    					logger.error("", e);
					}
				} else {
					result = new EmvTag[0];
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
						result = emvDao.getTagsCount(userSessionId, params);
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
		tableRowSelection = new TableRowSelection<EmvTag>(null, dataModel);
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
			EmvTag[] tags = emvDao.getTags(userSessionId, params);
			if (tags != null && tags.length > 0) {
				activeItem = tags[0];
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
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
			EmvTag[] tags = emvDao.getTags(userSessionId, params);
			if (tags != null && tags.length > 0) {
				editingItem = tags[0];
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
		
		if (filter.getTag() != null && filter.getTag().trim().length() > 0){
			f = new Filter();
			f.setElement("tag");
			f.setValue(filter.getTag().trim().replaceAll("[*]", "%")
					.replaceAll("[?]", "_").toUpperCase());
			filters.add(f);
		}
		if (filter.getDataFormat() != null && filter.getDataFormat().trim().length() > 0){
			f = new Filter();
			f.setElement("dataFormat");
			f.setValue(filter.getDataFormat());
			filters.add(f);
		}
		if (filter.getDataType() != null){
			f = new Filter();
			f.setElement("dataType");
			f.setValue(filter.getDataType());
			filters.add(f);
		}
		if (filter.getTagType() != null){
			f = new Filter();
			f.setElement("tagType");
			f.setValue(filter.getTagType());
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
	
	public void createNewTag(){
		editingItem = new EmvTag();
		editingItem.setLang(curLang);
		curMode = AbstractBean.NEW_MODE;
	}
	
	public void editActiveTag(){
		editingItem = (EmvTag) activeItem.clone();
		curMode = AbstractBean.EDIT_MODE;
	}
	
	public void saveEditingTag() {
        if (editingItem != null)
            editingItem.setTag(editingItem.getTag() != null ? editingItem.getTag().toUpperCase() : null);

        try {
			if (isNewMode()) {

				emvDao.createTag(userSessionId, editingItem);
			} else if (isEditMode()) {
				emvDao.modifyTag(userSessionId, editingItem);
			}
		}catch (DataAccessException e){
			FacesUtils.addMessageError(e);
			logger.error("", e);
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
		resetEditingTag();
	}
	
	public void resetEditingTag(){
		curMode = AbstractBean.VIEW_MODE;
		editingItem = null;
	}
	
	public void deleteActiveTag(){
		try{
			emvDao.removeTag(userSessionId, activeItem);
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
		activeItem = (EmvTag)dataModel.getRowData();
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
	
	public EmvTag getFilter() {
		if (filter == null) {
			filter = new EmvTag();
		}
		return filter;
	}
	
	public DaoDataModel<EmvTag> getDataModel(){
		return dataModel;
	}
	
	public EmvTag getActiveItem(){
		return activeItem;
	}
	
	public EmvTag getEditingItem(){
		return editingItem;
	}

	public List<SelectItem> getDataTypes(){
		List<SelectItem> result = getDictUtils().getLov(LovConstants.EMV_TAG_DATA_TYPE);
		return result;
	}
	
	public List<SelectItem> getTagTypes(){
		List<SelectItem> result = getDictUtils().getLov(LovConstants.EMV_TAG_TYPE);
		return result;
	}
	
	public String getComponentId() {
		return COMPONENT_ID;
	}

	public Logger getLogger() {
		return logger;
	}

}
