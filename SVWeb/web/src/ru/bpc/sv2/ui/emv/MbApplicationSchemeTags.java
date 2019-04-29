package ru.bpc.sv2.ui.emv;

import java.util.ArrayList;


import ru.bpc.sv2.logic.utility.db.DataAccessException;
import javax.faces.bean.ManagedBean;
import javax.faces.bean.RequestScoped;
import javax.faces.event.ValueChangeEvent;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;

import org.ajax4jsf.model.KeepAlive;
import ru.bpc.sv2.emv.EmvTag;
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
@ManagedBean (name = "MbApplicationSchemeTags")
public class MbApplicationSchemeTags extends AbstractBean {
	private static final Logger logger = Logger.getLogger("ISSUING");
	
	private static String COMPONENT_ID = "EmvTagTable";

	private EmvDao emvDao = new EmvDao();
	
	
	
	private EmvTag filter;
	
	private EmvTag activeItem;
	
	private final DaoDataModel<EmvTag> dataModel;
	private final TableRowSelection<EmvTag> tableRowSelection;
	
	private MbEmvTagValues mbTagsValues;
	private Long filterObjectId;
	private String filterEntityType;
	
	private String tabName;
	private String parentSectionId;
	
	public MbApplicationSchemeTags(){
		logger.debug("MbApplicationSchemeTags construction...");
		
		mbTagsValues = (MbEmvTagValues) ManagedBeanWrapper.getManagedBean("MbEmvTagValues");
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
		rowsNum = 999;
	}
	
	public void changeLanguage(ValueChangeEvent event) {
		curLang = (String) event.getNewValue();
		dataModel.flushCache();
	}
	
	private void setFilters() {
		filter = getFilter();
		filters = new ArrayList<Filter>();
		
		Filter f = new Filter();
		f.setElement("lang");
		f.setValue(curLang);
		filters.add(f);
		if ((filter.getTag() != null) && (!filter.getTag().isEmpty())) {
			f = new Filter();
			f.setElement("tag");
			f.setValue(filter.getTag().trim().toUpperCase().replaceAll("[*]", "%")
					.replaceAll("[?]", "_") + "%");
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
		mbTagsValues.clearFilter();
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
		mbTagsValues.clearFilter();
		mbTagsValues.getFilter().setObjectId(filterObjectId);
		mbTagsValues.getFilter().setEntityType(filterEntityType);
		mbTagsValues.getFilter().setTagId(activeItem.getId());
		mbTagsValues.search();
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
	
	public Logger getLogger() {
		return logger;
	}

	public String getFilterEntityType() {
		return filterEntityType;
	}

	public void setFilterEntityType(String filterEntityType) {
		this.filterEntityType = filterEntityType;
	}

	public Long getFilterObjectId() {
		return filterObjectId;
	}

	public void setFilterObjectId(Long filterObjectId) {
		this.filterObjectId = filterObjectId;
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
