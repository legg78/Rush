package ru.bpc.sv2.ui.process;

import java.io.IOException;
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
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.ProcessDao;
import ru.bpc.sv2.process.ProcessFileDirectory;
import ru.bpc.sv2.ui.process.files.MbFileAttributesSearch;
import ru.bpc.sv2.ui.utils.*;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import util.auxil.ManagedBeanWrapper;

@ViewScoped
@ManagedBean (name = "MbProcessFileDirectories")
@SuppressWarnings("serial")
public class MbProcessFileDirectories extends AbstractBean{
	private static final Logger logger = Logger.getLogger("PRC");
	private ProcessFileDirectory filter;
	private ProcessFileDirectory activeItem;
	private final TableRowSelection<ProcessFileDirectory> tableRowSelection;
	private final DaoDataModel<ProcessFileDirectory> dataModel;
	private ProcessFileDirectory editItem;
	private List<SelectItem> encriptionTypes = null;
	private List<SelectItem> directories = null;
	private String warningMsg;
	
	ProcessDao _processDao = new ProcessDao();
	
	public MbProcessFileDirectories(){
		pageLink = "processes|directories";
		dataModel = new DaoDataModel<ProcessFileDirectory>() {
			@Override
			protected ProcessFileDirectory [] loadDaoData(SelectionParams params) {
				ProcessFileDirectory [] result = null;
				if (searching) {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					try{
						result = _processDao.getProcessFileDirectories(userSessionId, params);
					}catch (DataAccessException e){
    					logger.error("", e);
					}
			} else {
				result = new ProcessFileDirectory[0];
			}
			return result;
		}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				int result = 0;
				if (searching) {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					try{
						result = _processDao.getProcessFileDirectoriesCount(userSessionId, params);
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
		tableRowSelection = new TableRowSelection<ProcessFileDirectory>(null, dataModel);
	}
	
	@Override
	public void clearFilter() {
		filter = null;
		clearState();
		searching = false;
	}
	
	public DaoDataModel<ProcessFileDirectory> getDataModel(){
		return dataModel;
	}
	
	private void setFilters(){
		filters = new ArrayList<Filter>();
		Filter f = new Filter();
		f.setElement("lang");
		f.setValue(curLang);
		filters.add(f);
		
		if ((filter.getDirectoryPath() != null) && 
				(filter.getDirectoryPath().length() > 0) ){
			f = new Filter("id", filter.getDirectoryPath());
			filters.add(f);
		}
		
		if ((filter.getEncryptionType() != null) && 
				(filter.getEncryptionType().length() > 0)){
			f = new Filter("encryptionType", filter.getEncryptionType());
			filters.add(f);
		}
		
		if ((filter.getEncryptionTypeDesc() != null) &&
				(filter.getEncryptionTypeDesc().length() > 0)){
			f = new Filter("encriptionTypeDesc", filter.getEncryptionTypeDesc());
			filters.add(f);
		}
		
        if (filter.getName() != null && filter.getName().trim().length() > 0) {

            Filter paramFilter = new Filter();
            paramFilter.setElement("name");
            paramFilter.setOp(Filter.Operator.like);
            paramFilter.setValue(filter.getName().trim().toUpperCase().replaceAll("[*]", "%").replaceAll("[?]", "_"));
            filters.add(paramFilter);
        }




	}
		
	
	public void clearState() {
		tableRowSelection.clearSelection();
		setActiveItem(null);
		dataModel.flushCache();
		curLang = userLang;
	}

	public ProcessFileDirectory getFilter() {
		if (filter == null){
			filter = new ProcessFileDirectory();
		}
		return filter;
	}

	public void setFilter(ProcessFileDirectory filter) {
		this.filter = filter;
	}
	
	public void search(){
		clearState();
		searching = true;
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
			ProcessFileDirectory[] direct = _processDao.getProcessFileDirectories(userSessionId, params);
			if (direct != null && direct.length > 0) {
				activeItem = direct[0];
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public ProcessFileDirectory getActiveItem() {
		return activeItem;
	}

	private void setActiveItem(ProcessFileDirectory activeItem) {
		this.activeItem = activeItem;
	}
	
	public void setItemSelection(SimpleSelection selection) {
		tableRowSelection.setWrappedSelection(selection);
		activeItem = tableRowSelection.getSingleSelection();

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
	
	public void setFirstRowActive() {
		dataModel.setRowIndex(0);
		SimpleSelection selection = new SimpleSelection();
		activeItem = (ProcessFileDirectory) dataModel.getRowData();
		selection.addKey(activeItem.getModelId());
		tableRowSelection.setWrappedSelection(selection);
	}

	public ProcessFileDirectory getEditItem() {
		return editItem;
	}

	public void setEditItem(ProcessFileDirectory editItem) {
		this.editItem = editItem;
	}
	
	public void add(){
		editItem = new ProcessFileDirectory();
		curMode = NEW_MODE;
	}
	
	public void edit(){
		editItem = activeItem;
		curMode = EDIT_MODE;
	}
	
	public void delete(){
		try{
			_processDao.deleteFileDirectory(userSessionId, activeItem);
			activeItem = tableRowSelection.removeObjectFromList(activeItem);
			cancel();
		}catch(DataAccessException e){
			FacesUtils.addMessageError(e);
			logger.error("", e);
			cancel();
			return;
		}
		clearDirectories();
	}
	
	private void clearDirectories(){
		MbFileAttributesSearch attr = (MbFileAttributesSearch)
				ManagedBeanWrapper.getManagedBean
					(MbFileAttributesSearch.class);
		attr.setDirectories(null);
	}
	
	public void cancel(){
		editItem = null;
		curMode = VIEW_MODE;
	}
	
	public void tryToSave() {
		clearWarningMsg();
		String path = _processDao.resolvePath(editItem.getDirectoryPath(), userSessionId);
		try {
			CommonUtils.checkFilepath(path, true, false, false);
			save();
		} catch (IOException e) {
			setWarningMsg(e.getMessage());
		}
	}

	public void save() {
		clearWarningMsg();
		editItem.setLang(curLang);
		if (isNewMode()) {
			try {			
				editItem = _processDao.addFileDirectory(userSessionId, editItem);
				tableRowSelection.addNewObjectToList(editItem);
			} catch (DataAccessException e) {
				FacesUtils.addMessageError(e);
				logger.error("", e);
				cancel();
				return;
			} catch (Exception e) {
				FacesUtils.addMessageError(e);
				logger.error("", e);
				cancel();
				return;
			}
		} else if (isEditMode()) {
			try {				
				editItem = _processDao.modifyFileDirectory(userSessionId, editItem);
				dataModel.replaceObject(activeItem, editItem);
			} catch (DataAccessException e) {
				FacesUtils.addMessageError(e);
				logger.error("", e);
				cancel();
				return;
			} catch (Exception e) {
				FacesUtils.addMessageError(e);
				logger.error("", e);
				cancel();
				return;
			}
			curMode = VIEW_MODE;
		}
		clearDirectories();
	}	



	public String getWarningMsg() {
		return warningMsg;
	}

	public void setWarningMsg(String warningMsg) {
		this.warningMsg = warningMsg;
	}
	
	public void clearWarningMsg() {
		this.warningMsg = "";
	}

	public List<SelectItem> getEncriptionTypes() {
		if (encriptionTypes == null){
			encriptionTypes = getDictUtils().getLov(LovConstants.ENCRYPTION_TYPE);
		}
		return encriptionTypes;
	}

	public void setEncriptionTypes(List<SelectItem> encriptionTypes) {
		this.encriptionTypes = encriptionTypes;
	}

	public List<SelectItem> getDirectories() {
		if (directories == null){
			directories = getDictUtils().getLov(LovConstants.DIRECTORIES);
		}
		return directories;
	}

	public void setDirectories(List<SelectItem> directories) {
		this.directories = directories;
	}
}
