package ru.bpc.sv2.ui.common;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;
import ru.bpc.sv2.common.Appearance;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.CommonDao;
import ru.bpc.sv2.logic.utility.db.DataAccessException;
import ru.bpc.sv2.ui.utils.*;

import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.model.SelectItem;
import java.util.ArrayList;
import java.util.List;

@ViewScoped
@ManagedBean (name = "MbAppearance")
@SuppressWarnings("serial")
public class MbAppearance extends AbstractBean{
	
	private Appearance filter;
	private Appearance activeItem;
	private Appearance editingItem;
	private static final Logger logger = Logger.getLogger("COMMON");
	private List<SelectItem> entity;

	private CommonDao commonDao = new CommonDao();
	
	private final DaoDataModel<Appearance> dataModel;
	private transient final TableRowSelection<Appearance> tableRowSelection;
	
	public MbAppearance(){
		pageLink = "common|appearance";
		dataModel = new DaoDataModel<Appearance>() {
			@Override
			protected Appearance[] loadDaoData(SelectionParams params){
				Appearance [] result = null;
				if (searching){
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					try{
						result = commonDao.getAppearances(userSessionId, params);
					}catch (DataAccessException e){
						FacesUtils.addMessageError(e);
    					logger.error("", e);
					}
				}else {
					result = new Appearance[0];
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
						result = commonDao.getAppearanceCount(userSessionId, params);
					}catch(DataAccessException e){
						FacesUtils.addMessageError(e);
    					logger.error("", e);
					}
				}
				
				return result;
			}			
		};
		tableRowSelection = new TableRowSelection<Appearance>(null, dataModel);
	}
	
	private void setFilters(){
		filters = new ArrayList<Filter>();
		Filter f = new Filter();
		
		if (filter.getEntityType() != null &&
				filter.getEntityType().trim().length() > 0){
			f = new Filter ("entityType", filter.getEntityType());
			filters.add(f);
		}
		
		if (filter.getObjectId() != null &&
				filter.getObjectId().toString().length() > 0){
			f = new Filter ("objectId", filter.getObjectId());
			filters.add(f);
		}
		
		if (filter.getObjectReference() != null &&
				filter.getObjectReference().toString().length() > 0){
			f = new Filter ("objectReference", filter.getObjectReference());
			filters.add(f);
		}
		
		if (filter.getCssClass() != null &&
				filter.getCssClass().trim().length() > 0){
			f = new Filter ("cssClass", filter.getCssClass());
			filters.add(f);
		}				
	}

	@Override
	public void clearFilter() {
		filter = null;
		clearState();
		searching = false;
	}
	public void search(){
		clearState();
		searching = true;
	}
	
	public void clearState() {
		tableRowSelection.clearSelection();
		activeItem = null;
		dataModel.flushCache();
		curLang = userLang;
	}
	
	public DaoDataModel<Appearance> getDataModel(){
		return dataModel;
	}
	
	public List<SelectItem> getEntity(){
		if (entity == null){
			entity = getDictUtils().getLov(LovConstants.ENTITY_TYPES);
		}
		return entity;
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
		activeItem = (Appearance)dataModel.getRowData();
		selection.addKey(activeItem.getModelId());
		tableRowSelection.setWrappedSelection(selection);
		
	}
	
	public void setItemSelection(SimpleSelection selection) {
		tableRowSelection.setWrappedSelection(selection);
		activeItem = tableRowSelection.getSingleSelection();
	
	}
	
	public void setFirstRowActive() {
		dataModel.setRowIndex(0);
		SimpleSelection selection = new SimpleSelection();
		activeItem = (Appearance) dataModel.getRowData();
		selection.addKey(activeItem.getModelId());
		tableRowSelection.setWrappedSelection(selection);
	}
	
	public Appearance getActiveItem(){
		return activeItem;
	}
	
	public Appearance getFilter(){
		if (filter == null){
			filter = new Appearance();
		}
		return filter;
		
	}
	
	public void add(){
		editingItem = new Appearance();
		curMode = AbstractBean.NEW_MODE;
	}
	
	public void edit(){
		editingItem = activeItem;
		curMode = AbstractBean.EDIT_MODE;
	}
	
	public void view(){
		editingItem = activeItem;
		curMode = AbstractBean.VIEW_MODE;
	}
	
	public void save(){
		try{
		if (isNewMode()){
				editingItem = commonDao.addAppearance(userSessionId, editingItem);
				tableRowSelection.addNewObjectToList(editingItem);
			}else {
				editingItem = commonDao.modifyAppearance(userSessionId, editingItem);
				dataModel.replaceObject(activeItem, editingItem);
			}
		}catch (DataAccessException e){
			FacesUtils.addMessageError(e);
			logger.error(e.getMessage(), e);
			cancel();
			return;
		}catch (Exception e) {
			e.printStackTrace();
		}
		activeItem = editingItem;
		curMode = AbstractBean.VIEW_MODE;
//		search();
	}
	
	public void cancel(){
		curMode = AbstractBean.VIEW_MODE;
		editingItem = null;	
	}
	
	public Appearance getEditingItem(){
		return editingItem;
	}
	
	public void delete(){
		try{
			commonDao.deleteAppearance(userSessionId, activeItem);
			
		}catch (DataAccessException e){
			FacesUtils.addMessageError(e);
			logger.error("", e);
			return;
		}
		activeItem = tableRowSelection.removeObjectFromList(activeItem);
	}

	public void reload() {
	
		try {
			EntityIcons.getInstance().reload();
		} catch (Exception e) {
			logger.error("Error during reloading appearance cache", e);
		}
	
	}
}
