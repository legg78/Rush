package ru.bpc.sv2.ui.emv;

import java.util.ArrayList;
import java.util.List;


import ru.bpc.sv2.logic.utility.db.DataAccessException;
import javax.faces.bean.ManagedBean;
import javax.faces.bean.RequestScoped;
import javax.faces.model.SelectItem;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;

import org.ajax4jsf.model.KeepAlive;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.emv.TagValue;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.EmvDao;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.TableRowSelection;

@RequestScoped
@KeepAlive
@ManagedBean (name = "MbEmvTagValues")
public class MbEmvTagValues extends AbstractBean {
	private static final Logger logger = Logger.getLogger("ISSUING");

	private EmvDao emvDao = new EmvDao();

	

	private TagValue filter;

	private TagValue activeItem;

	private final DaoDataModel<TagValue> dataModel;
	private final TableRowSelection<TagValue> tableRowSelection;

	private TagValue editingItem; 
	
	private static String COMPONENT_ID = "tagValueTable";
	private String tabName;
	private String parentSectionId;
	
	public MbEmvTagValues() {
		logger.debug("MbTagValues construction...");
		
		dataModel = new DaoDataModel<TagValue>() {
			@Override
			protected TagValue[] loadDaoData(SelectionParams params) {
				TagValue[] result = null;
				if (searching) {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					try {
						result = emvDao.getTagValues(userSessionId, params);
					} catch (DataAccessException e) {
						FacesUtils.addMessageError(e);
						logger.error("", e);
					}
				} else {
					result = new TagValue[0];
				}
				return result;
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				int result = 0;
				if (searching) {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					try {
						result = emvDao.getTagValuesCount(userSessionId,
								params);
					} catch (DataAccessException e) {
						FacesUtils.addMessageError(e);
						logger.error("", e);
					}
				} else {
					result = 0;
				}
				return result;
			}
		};
		tableRowSelection = new TableRowSelection<TagValue>(null, dataModel);
	}

	private void setFilters() {
		filters = new ArrayList<Filter>();

		filters = new ArrayList<Filter>();
		
		Filter f = new Filter("lang", curLang);
		filters.add(f);
		
		if (filter.getId() != null){
			f = new Filter("id", filter.getId());
			filters.add(f);
		}
		if (filter.getObjectId() != null){
			f = new Filter("objectId", filter.getObjectId());
			filters.add(f);
		}
		if (filter.getEntityType() != null){
			f = new Filter("entityType", filter.getEntityType());
			filters.add(f);
		}
		if (filter.getTagId() != null){
			f = new Filter("tagId", filter.getTagId());
			filters.add(f);
		}
		if (filter.getTagValue() != null){
			f = new Filter("tagValue", filter.getTagValue());
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

	public void clearBeansStates() {

	}

	public void clearFilter() {
		filter = null;
		clearState();
		clearBeansStates();
		searching = false;
	}

	public SimpleSelection getItemSelection() {
		if (activeItem == null && dataModel.getRowCount() > 0) {
			prepareItemSelection();
		}
		return tableRowSelection.getWrappedSelection();
	}

	public void prepareItemSelection() {
		dataModel.setRowIndex(0);
		SimpleSelection selection = new SimpleSelection();
		activeItem = (TagValue) dataModel.getRowData();
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

	private void setBeansState() {

	}

	public TagValue getFilter() {
		if (filter == null) {
			filter = new TagValue();
		}
		return filter;
	}

	public DaoDataModel<TagValue> getDataModel() {
		return dataModel;
	}

	public TagValue getActiveItem() {
		return activeItem;
	}

	public void saveEditingTagValue(){
		try {
			setEditingItem(emvDao.setTagValue(userSessionId, getEditingItem()));
		}catch (DataAccessException e){
			FacesUtils.addMessageError(e);
			logger.error("", e);
			return;
		}
		if (isNewMode()) {
			tableRowSelection.addNewObjectToList(getEditingItem());
		} else {
			try {
				dataModel.replaceObject(activeItem, getEditingItem());
			} catch (Exception e) {
				e.printStackTrace();
			}
		}
		activeItem = getEditingItem();
		resetEditingTagValue();
	}
	
	public void createNewTagValue(){
		editingItem = new TagValue();
		editingItem.setObjectId(filter.getObjectId());
		editingItem.setEntityType(filter.getEntityType());
		editingItem.setTagId(filter.getTagId());
		curMode = NEW_MODE;
	}
	
	public void prepareForEditing(){
		setEditingItem((TagValue) activeItem.clone());
		curMode = EDIT_MODE;
	}
	
	public void resetEditingTagValue(){
		setEditingItem(null);
		curMode = VIEW_MODE;
	}
	
	public void deleteSelectedItem(){
		try {
			emvDao.removeTagValue(userSessionId, activeItem);
			dataModel.removeObjectFromList(activeItem);
		}catch (DataAccessException e){
			FacesUtils.addMessageError(e);
			logger.error("", e);
			return;
		}
	}

	public TagValue getEditingItem() {
		return editingItem;
	}

	public void setEditingItem(TagValue editingItem) {
		this.editingItem = editingItem;
	}
	
	private List<SelectItem> profiles;
	
	public List<SelectItem> getProfiles(){
		if (profiles == null){
			profiles = getDictUtils().getLov(LovConstants.EMV_APPLICATION_PROFILE);
		}
		return profiles;
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
