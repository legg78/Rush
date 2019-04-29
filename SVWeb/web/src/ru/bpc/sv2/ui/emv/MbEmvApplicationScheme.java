package ru.bpc.sv2.ui.emv;

import java.util.ArrayList;
import java.util.List;

import javax.annotation.PostConstruct;

import ru.bpc.sv2.logic.utility.db.DataAccessException;
import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.event.ValueChangeEvent;
import javax.faces.model.SelectItem;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;

import ru.bpc.sv2.constants.EntityNames;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.constants.SectionIdConstants;
import ru.bpc.sv2.constants.application.ApplicationConstants;
import ru.bpc.sv2.emv.EmvApplicationScheme;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.EmvDao;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.TableRowSelection;
import util.auxil.ManagedBeanWrapper;

@ViewScoped
@ManagedBean (name = "MbEmvApplicationScheme")
public class MbEmvApplicationScheme extends AbstractBean {
	private static final long serialVersionUID = -1886773148684700408L;

	private static final Logger logger = Logger.getLogger("ISSUING");
	
	private static String COMPONENT_ID = "2268:ApplicationSchemeTable";

	private EmvDao emvDao = new EmvDao();
	
	private EmvApplicationScheme filter;
	
	private EmvApplicationScheme activeItem;
	
	private final DaoDataModel<EmvApplicationScheme> dataModel;
	private final TableRowSelection<EmvApplicationScheme> tableRowSelection;
	
	private EmvApplicationScheme editingItem;

	private List<SelectItem> institutions;
	private MbApplicationSchemeTags mbApplicationSchemeTags;
	private List<SelectItem> applictionTypes;
	
	private String tabName;
	
	public MbEmvApplicationScheme(){
		logger.debug("MbEmvApplicationScheme construction...");
		pageLink = "emv|applicationScheme";
		tabName = "detailsTab";
		mbApplicationSchemeTags = (MbApplicationSchemeTags) ManagedBeanWrapper.getManagedBean("MbApplicationSchemeTags");
		dataModel = new DaoDataModel<EmvApplicationScheme>(){
			private static final long serialVersionUID = -6421374247371618109L;

			@Override
			protected EmvApplicationScheme[] loadDaoData(SelectionParams params) {
				EmvApplicationScheme[] result = null;
				if (searching) {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					try{
						result = emvDao.getApplicationSchemes(userSessionId, params);
					}catch (DataAccessException e){
			    		FacesUtils.addMessageError(e);
    					logger.error("", e);
					}
				} else {
					result = new EmvApplicationScheme[0];
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
						result = emvDao.getApplicationSchemesCount(userSessionId, params);
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
		tableRowSelection = new TableRowSelection<EmvApplicationScheme>(null, dataModel);
	}
	
	@PostConstruct
	public void init() {
		setDefaultValues();
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
			EmvApplicationScheme[] applicationScheme = emvDao.getApplicationSchemes(userSessionId, params);
			if (applicationScheme != null && applicationScheme.length > 0) {
				activeItem = applicationScheme[0];
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
			EmvApplicationScheme[] applicationScheme = emvDao.getApplicationSchemes(userSessionId, params);
			if (applicationScheme != null && applicationScheme.length > 0) {
				editingItem = applicationScheme[0];
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
		
		if (filter.getInstId() != null){
			f = new Filter();
			f.setElement("instId");
			f.setValue(filter.getInstId());
			filters.add(f);
		}
		
		if (filter.getName() != null && filter.getName().trim().length() > 0){
			f = new Filter();
			f.setElement("name");
			f.setValue(filter.getName().trim().replaceAll("[*]", "%")
					.replaceAll("[?]", "_").toUpperCase());
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
		setDefaultValues();
		searching = false;
	}
	
	public void createNewApplicationScheme(){
		editingItem = new EmvApplicationScheme();
		editingItem.setLang(curLang);
		curMode = AbstractBean.NEW_MODE;
	}
	
	public void editActiveApplicationScheme(){
		editingItem = (EmvApplicationScheme) activeItem.clone();
		curMode = AbstractBean.EDIT_MODE;
	}
	
	public void saveEditingApplicationScheme(){
		logger.debug("EditingItem saving...");
		try {
			if (isNewMode()) {
				editingItem = emvDao.createApplicationScheme(userSessionId,
						editingItem);
			} else if (isEditMode()) {
				emvDao.modifyApplicationScheme(userSessionId, editingItem);
			}
		}catch (DataAccessException e){
			FacesUtils.addMessageError(e);
			logger.error("", e);
			resetEditingApplicationScheme();
			return;
		}
		if (isNewMode()) {
			tableRowSelection.addNewObjectToList(editingItem);
		} else {
			try {
				dataModel.replaceObject(activeItem, editingItem);
			} catch (Exception e) {
	    		FacesUtils.addMessageError(e);
				logger.error("", e);
			}
		}
		activeItem = editingItem;
		resetEditingApplicationScheme();
	}
	
	public void resetEditingApplicationScheme(){
		curMode = AbstractBean.VIEW_MODE;
		editingItem = null;
	}
	
	public void deleteActiveApplicationShema(){
		try{
			emvDao.removeApplicationScheme(userSessionId, activeItem);
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
		activeItem = (EmvApplicationScheme)dataModel.getRowData();
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
		mbApplicationSchemeTags.clearFilter();
		mbApplicationSchemeTags.setFilterEntityType(EntityNames.APPLICATION_SCHEME);
		mbApplicationSchemeTags.setFilterObjectId(activeItem.getId());
		mbApplicationSchemeTags.search();
	}
	
	public EmvApplicationScheme getFilter() {
		if (filter == null) {
			filter = new EmvApplicationScheme();
		}
		return filter;
	}
	
	public DaoDataModel<EmvApplicationScheme> getDataModel(){
		return dataModel;
	}
	
	public EmvApplicationScheme getActiveItem(){
		return activeItem;
	}
	
	public EmvApplicationScheme getEditingItem(){
		return editingItem;
	}
	
	public List<SelectItem> getInstitutions() {
		if (institutions == null) {
			institutions = (List<SelectItem>) getDictUtils().getLov(LovConstants.INSTITUTIONS_SYS);
		}
		if (institutions == null) {
			return new ArrayList<SelectItem>();
		}
		return institutions;
	}

	public String getComponentId() {
		return COMPONENT_ID;
	}

	public Logger getLogger() {
		return logger;
	}

	private void setDefaultValues() {
		if (sectionFilterModeEdit) return;
		
		Integer defaultInstId = null;
		List<SelectItem> instList = getInstitutions();
		if (userInstId == ApplicationConstants.DEFAULT_INSTITUTION && !instList.isEmpty()) {
			// instId from LOV is for some reason String 
			defaultInstId = Integer.valueOf((String) getInstitutions().get(0).getValue());
		} else {
			defaultInstId = userInstId;
		}
		
		filter = new EmvApplicationScheme();
		filter.setInstId(defaultInstId);
	}	
	
	public List<SelectItem> getApplicationSchemeTypes(){
		if (applictionTypes == null){
			applictionTypes = getDictUtils().getLov(LovConstants.EMV_SCHEME_IDS);
		}
		return applictionTypes; 
	}

	public String getTabName() {
		return tabName;
	}

	public void setTabName(String tabName) {
		this.tabName = tabName;
		if (tabName.equalsIgnoreCase("tabsValuesTab")) {
			MbApplicationSchemeTags bean = (MbApplicationSchemeTags) ManagedBeanWrapper
					.getManagedBean("MbApplicationSchemeTags");
			bean.setTabName(tabName);
			bean.setParentSectionId(getSectionId());
			bean.setTableState(getSateFromDB(bean.getComponentId()));
			
			MbEmvTagValues bean1 = (MbEmvTagValues) ManagedBeanWrapper
					.getManagedBean("MbEmvTagValues");
			bean1.setTabName(tabName);
			bean1.setParentSectionId(getSectionId());
			bean1.setTableState(getSateFromDB(bean1.getComponentId()));
		}
	}
	
	public String getSectionId() {
		return SectionIdConstants.ISSUING_EMV_SCHEME;
	}
}
