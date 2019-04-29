package ru.bpc.sv2.ui.emv;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;


import ru.bpc.sv2.logic.utility.db.DataAccessException;
import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.event.ValueChangeEvent;
import javax.faces.model.SelectItem;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;

import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.constants.SectionIdConstants;
import ru.bpc.sv2.constants.scale.ScaleConstants;
import ru.bpc.sv2.emv.EmvApplication;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.EmvDao;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.TableRowSelection;
import util.auxil.ManagedBeanWrapper;

@ViewScoped
@ManagedBean (name = "MbEmvApplication")
public class MbEmvApplication extends AbstractBean {
	private static final Logger logger = Logger.getLogger("EMV");
	
	private static String COMPONENT_ID = "2269:ApplicationTable";

	private static final String DETAILS_TAB = "detailsTab";
	private static final String VARIABLES_TAB = "variablesTab";
	private static final String BLOCKS_TAB = "blocksTab";
	
	private EmvDao emvDao = new EmvDao();
	
	
	private MbEmvBlock mbEmvBlock;
	private MbEmvVariable mbEmvVariable;
	
	private EmvApplication filter;
	
	private EmvApplication activeItem;
	private EmvApplication detailItem;
	
	private final DaoDataModel<EmvApplication> dataModel;
	private final TableRowSelection<EmvApplication> tableRowSelection;
	
	private EmvApplication editingItem;
	private List<SelectItem> emvSchemes = null;
	private List<SelectItem> institutions = null;
	private List<SelectItem> rid = null;
	private ArrayList<SelectItem> emvAppPar = null;
	
	private String tabName = DETAILS_TAB;
	 
	public MbEmvApplication(){
		pageLink = "emv|application";
		mbEmvBlock = (MbEmvBlock) ManagedBeanWrapper.getManagedBean("MbEmvBlock");
		mbEmvVariable = (MbEmvVariable) ManagedBeanWrapper.getManagedBean("MbEmvVariable");
		dataModel = new DaoDataModel<EmvApplication>(){
			@Override
			protected EmvApplication[] loadDaoData(SelectionParams params) {
				EmvApplication[] result = null;
				if (searching) {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					try{
						result = emvDao.getApplications(userSessionId, params);
					}catch (DataAccessException e){
			    		FacesUtils.addMessageError(e);
    					logger.error("", e);
					}
				} else {
					result = new EmvApplication[0];
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
						result = emvDao.getApplicationsCount(userSessionId, params);
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
		tableRowSelection = new TableRowSelection<EmvApplication>(null, dataModel);
	}
	
	public void changeLanguage(ValueChangeEvent event) {
		curLang = (String) event.getNewValue();
		detailItem = getNodeByLang(detailItem.getId(), curLang);
	}
	
	public EmvApplication getNodeByLang(Integer id, String lang) {
		filters = new ArrayList<Filter>();

		Filter f = new Filter();
		f.setElement("id");
		f.setValue(id);
		filters.add(f);

		f = new Filter();
		f.setElement("lang");
		f.setValue(lang);
		filters.add(f);
		
		SelectionParams params = new SelectionParams();
		params.setFilters(filters.toArray(new Filter[filters.size()]));
		try {
			EmvApplication[] applications = emvDao.getApplications(userSessionId, params);
			if (applications != null && applications.length > 0) {
				return applications[0];
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
		return null;
	}
	
	public void confirmEditLanguage() {
		curLang = editingItem.getLang();
		EmvApplication tmp = getNodeByLang(editingItem.getId(), editingItem.getLang());
		if (tmp != null) {
			editingItem.setName(tmp.getName());
		}
	}
	
	private void setFilters() {
		filters = new ArrayList<Filter>();
		
		Filter f = new Filter();
		f.setElement("lang");
		f.setValue(userLang);
		filters.add(f);
		
		if (filter.getAid() != null && filter.getAid().trim().length() > 0) {
			f = new Filter();
			f.setElement("aid");
			f.setValue(filter.getAid().trim().replaceAll("[*]", "%")
					.replaceAll("[?]", "_").toUpperCase());
			filters.add(f);
		}
		if (filter.getApplSchemeId() != null){
			f = new Filter("applSchemeId", filter.getApplSchemeId());
			filters.add(f);
		}
		if (filter.getName() != null && filter.getName().trim().length() > 0) {
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
		detailItem = null;
		dataModel.flushCache();
		curLang = userLang;		
	}
	
	public void clearBeansStates(){
		mbEmvBlock.setApplicationId(null);
		mbEmvVariable.setApplicationId(null);
	}
	
	public void clearFilter() {
		filter = null;
		clearState();
		clearBeansStates();
		searching = false;
	}
	
	public void createNewApplication(){
		editingItem = new EmvApplication();
		editingItem.setLang(curLang);
		curLang = editingItem.getLang();
		curMode = AbstractBean.NEW_MODE;
	}
	
	public void editActiveApplication(){
		try {
			editingItem = (EmvApplication) detailItem.clone();
		} catch (CloneNotSupportedException e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
		curMode = AbstractBean.EDIT_MODE;
	}
	
	public void saveEditingApplication(){
		try {
			try {
				if (isNewMode()) {
					editingItem = emvDao.createApplication(userSessionId, editingItem);
					detailItem = (EmvApplication) editingItem.clone();
				} else if (isEditMode()) {
					editingItem = emvDao.modifyApplication(userSessionId, editingItem);
					detailItem = (EmvApplication) editingItem.clone();
					if (!userLang.equals(editingItem.getLang())) {
						editingItem = getNodeByLang(activeItem.getId(), userLang);
					}
				}
			}catch (DataAccessException e){
				FacesUtils.addMessageError(e);
				logger.error("", e);
				resetEditingApplication();
				return;
			}
			if (isNewMode()) {
				tableRowSelection.addNewObjectToList(editingItem);
			} else {
				dataModel.replaceObject(activeItem, editingItem);
			}
			activeItem = editingItem;
			resetEditingApplication();
			setBeansState();
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}	
	}
	
	public void resetEditingApplication(){
		curMode = AbstractBean.VIEW_MODE;
		editingItem = null;
	}
	
	public void deleteActiveApplication(){
		try{
			emvDao.removeApplication(userSessionId, activeItem);
		
			activeItem = tableRowSelection.removeObjectFromList(activeItem);
			detailItem = (activeItem != null)?(EmvApplication) activeItem.clone():null;
			setBeansState();
		} catch (Exception e){
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public SimpleSelection getItemSelection() {
		try {
			if (activeItem == null && dataModel.getRowCount() > 0){
				prepareItemSelection();
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}	
		return tableRowSelection.getWrappedSelection();
	}
	
	public void prepareItemSelection() throws CloneNotSupportedException{
		dataModel.setRowIndex(0);
		SimpleSelection selection = new SimpleSelection();
		activeItem = (EmvApplication)dataModel.getRowData();
		detailItem = (EmvApplication) activeItem.clone();
		selection.addKey(activeItem.getModelId());
		tableRowSelection.setWrappedSelection(selection);
		if (activeItem != null) {
			setBeansState();
		}
	}
	
	public void setItemSelection(SimpleSelection selection) {
		try {
			tableRowSelection.setWrappedSelection(selection);
			boolean changeSelect = false;
			if (tableRowSelection.getSingleSelection() != null 
					&& !tableRowSelection.getSingleSelection().getId().equals(activeItem.getId())) {
				changeSelect = true;
			}
			activeItem = tableRowSelection.getSingleSelection();
			if (activeItem != null) {
				setBeansState();
				if (changeSelect) {
					detailItem = (EmvApplication) activeItem.clone();
				}
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}	
	}
	
	private void setBeansState(){
		loadCurrentTab();
	}
	
	private void loadCurrentTab(){

		if (tabName.equalsIgnoreCase(BLOCKS_TAB)){
			mbEmvVariable.setApplicationId(null);
			Integer id = activeItem != null ? activeItem.getId() : null;
			mbEmvBlock.setApplicationId(id);
		} else if (tabName.equalsIgnoreCase(VARIABLES_TAB)){
			mbEmvBlock.setApplicationId(null);
			Integer id = activeItem != null ? activeItem.getId() : null;
			mbEmvVariable.setApplicationId(id);
		} 
	}
	
	public EmvApplication getFilter() {
		if (filter == null) {
			filter = new EmvApplication();
		}
		return filter;
	}
	
	public DaoDataModel<EmvApplication> getDataModel(){
		return dataModel;
	}
	
	public EmvApplication getActiveItem(){
		return activeItem;
	}
	
	public EmvApplication getEditingItem(){
		return editingItem;
	}
	
	public List<SelectItem> getInstitutions(){
		if (institutions == null) {
			institutions = getDictUtils().getLov(LovConstants.INSTITUTIONS_SYS);
		}		
		return institutions;
	}
	
	public List<SelectItem> getEmvSchemes(){
		if (emvSchemes == null) {
			emvSchemes = getDictUtils().getLov(LovConstants.APPLICATION_SCHEMES);
		}		
		return emvSchemes;
	}
	
	public List<SelectItem> getRid(){
		if (rid == null) {
			rid = getDictUtils().getLov(LovConstants.RID);
		}		
		return rid;
	}
	
	public ArrayList<SelectItem> getEmvAppPar(){
		if (emvAppPar == null) {
			 Map<String, Object> paramMap = new HashMap<String, Object>();
	            paramMap.put("SCALE_TYPE", ScaleConstants.SCALE_FOR_EMV_APPL);
	            emvAppPar =  (ArrayList<SelectItem>)getDictUtils().getLov(LovConstants.MODIFIER_LIST, paramMap);
		}		
		return emvAppPar;
	}
	
	public String getTabName() {
		return tabName;
	}

	public void setTabName(String tabName) {
		this.tabName = tabName;
		loadCurrentTab();
		
		if (tabName.equalsIgnoreCase(BLOCKS_TAB)){
			mbEmvBlock.setTabName(tabName);
			mbEmvBlock.setParentSectionId(getSectionId());
			mbEmvBlock.setTableState(getSateFromDB(mbEmvBlock.getComponentId()));
		} else if (tabName.equalsIgnoreCase(VARIABLES_TAB)){
			mbEmvVariable.setTabName(tabName);
			mbEmvVariable.setParentSectionId(getSectionId());
			mbEmvVariable.setTableState(getSateFromDB(mbEmvVariable.getComponentId()));
		} 
	}

	public String getSectionId() {
		return SectionIdConstants.ISSUING_EMV_APP;
	}
	
	public String getComponentId() {
		return COMPONENT_ID;
	}

	public Logger getLogger() {
		return logger;
	}

	public EmvApplication getDetailItem() {
		return detailItem;
	}

	public void setDetailItem(EmvApplication detailItem) {
		this.detailItem = detailItem;
	}

}
