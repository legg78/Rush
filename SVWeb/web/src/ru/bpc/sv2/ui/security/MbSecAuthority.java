package ru.bpc.sv2.ui.security;

import java.util.ArrayList;
import java.util.List;


import ru.bpc.sv2.logic.SecurityDao;
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
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.security.SecAuthority;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.TableRowSelection;
import util.auxil.ManagedBeanWrapper;

@ViewScoped
@ManagedBean (name = "MbSecAuthority")
public class MbSecAuthority extends AbstractBean {
	private static final Logger logger = Logger.getLogger("SECURITY");
	
	private SecurityDao securityDao = new SecurityDao();
	
	
	
	private SecAuthority filter;
	
	private SecAuthority activeItem;
	private SecAuthority detailItem;
	
	private final DaoDataModel<SecAuthority> dataModel;
	private final TableRowSelection<SecAuthority> tableRowSelection;
	
	private SecAuthority editingItem;
	 
	private String tabName;
	
	public MbSecAuthority(){
		pageLink = "security|authority";
		tabName = "detailsTab";
		dataModel = new DaoDataModel<SecAuthority>(){
			@Override
			protected SecAuthority[] loadDaoData(SelectionParams params) {
				SecAuthority[] result = null;
				if (searching) {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					try{
						result = securityDao.getAuthorities(userSessionId, params);
					}catch (DataAccessException e){
			    		FacesUtils.addMessageError(e);
    					logger.error("", e);
					}
				} else {
					result = new SecAuthority[0];
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
						result = securityDao.getAuthoritiesCount(userSessionId, params);
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
		tableRowSelection = new TableRowSelection<SecAuthority>(null, dataModel);
	}
	
	private void setFilters() {
		filters = new ArrayList<Filter>();
		
		Filter f = new Filter();
		f.setElement("lang");
		f.setValue(userLang);
		filters.add(f);
		
		if (filter.getId() != null){
			f = new Filter();
			f.setElement("id");
			f.setValue(filter.getId());
			filters.add(f);
		}
	
		if (filter.getType() != null){
			f = new Filter();
			f.setElement("type");
			f.setValue(filter.getType());
			filters.add(f);
		}
	
		if (filter.getRid() != null && filter.getRid().trim().length() > 0) {
			f = new Filter();
			f.setElement("rid");
			f.setValue(filter.getRid().trim().replaceAll("[*]", "%")
					.replaceAll("[?]", "_"));
			filters.add(f);
		}
	
		if (filter.getName() != null && filter.getName().trim().length() > 0) {
			f = new Filter();
			f.setElement("name");
			f.setValue(filter.getName().trim().replaceAll("[*]", "%")
					.replaceAll("[?]", "_"));
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
	

	
	public void clearFilter() {
		filter = null;
		clearState();
		clearBeansStates();
		searching = false;
	}
	
	public void createNewAuthority(){
		editingItem = new SecAuthority();
		editingItem.setLang(userLang);
		curLang = editingItem.getLang();
		curMode = AbstractBean.NEW_MODE;
	}
	
	public void editActiveAuthority(){
		try {
			editingItem = (SecAuthority) detailItem.clone();
		} catch (CloneNotSupportedException e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
		curMode = AbstractBean.EDIT_MODE;
	}
	
	public void saveEditingAuthority(){
		try {
			if (isNewMode()) {
				editingItem = securityDao.createAuthority(userSessionId, editingItem);
				detailItem = (SecAuthority) editingItem.clone();
			} else if (isEditMode()) {
				editingItem = securityDao.modifyAuthority(userSessionId, editingItem);
				detailItem = (SecAuthority) editingItem.clone();
				//adjust newProvider according userLang
				if (!userLang.equals(editingItem.getLang())) {
					editingItem = getNodeByLang(activeItem.getId(), userLang);
				}
			}
		
			if (isNewMode()) {
				tableRowSelection.addNewObjectToList(editingItem);
			} else {
				dataModel.replaceObject(activeItem, editingItem);
			}
			activeItem = editingItem;
			resetEditingAuthority();
		} catch (Exception e){
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}
	
	public void resetEditingAuthority(){
		curMode = AbstractBean.VIEW_MODE;
		editingItem = null;
	}
	
	public void deleteActiveAuthority(){
		try{
			securityDao.removeAuthority(userSessionId, activeItem);
		
			activeItem = tableRowSelection.removeObjectFromList(activeItem);		
			if (activeItem == null){
				clearState();
			} else {
				detailItem = (SecAuthority) activeItem.clone();
			}
			curMode = VIEW_MODE;
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public SimpleSelection getItemSelection() {
		try {
			if (activeItem == null && dataModel.getRowCount() > 0){
				prepareItemSelection();
			} else if (activeItem != null && dataModel.getRowCount() > 0) {
				SimpleSelection selection = new SimpleSelection();
				selection.addKey(activeItem.getModelId());
				tableRowSelection.setWrappedSelection(selection);
				activeItem = tableRowSelection.getSingleSelection();
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
		activeItem = (SecAuthority)dataModel.getRowData();
		selection.addKey(activeItem.getModelId());
		tableRowSelection.setWrappedSelection(selection);
		if (activeItem != null) {
			setBeansState();
			detailItem = (SecAuthority) activeItem.clone();
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
					detailItem = (SecAuthority) activeItem.clone();
				}
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}
	
	private void setBeansState(){
		MbRsaKey mbRsaKey = (MbRsaKey) ManagedBeanWrapper.getManagedBean("MbRsaKey");
		mbRsaKey.clearFilter();
		mbRsaKey.setObjectId(activeItem.getId().longValue());
		mbRsaKey.setEntityType(EntityNames.AUTHORITY_CENTER);
		mbRsaKey.setBottom(true);
		mbRsaKey.search();
	}
	
	public void clearBeansStates(){
		MbRsaKey mbRsaKey = (MbRsaKey) ManagedBeanWrapper.getManagedBean("MbRsaKey");
		mbRsaKey.clearFilter();
	}
	
	public void changeLanguage(ValueChangeEvent event) {
		curLang = (String) event.getNewValue();
		detailItem = getNodeByLang(detailItem.getId(), curLang);
	}
	
	public SecAuthority getNodeByLang(Integer id, String lang) {
		filters = new ArrayList<Filter>();

		Filter f = new Filter();
		f.setElement("id");
		f.setValue(String.valueOf(id));
		filters.add(f);

		f = new Filter();
		f.setElement("lang");
		f.setValue(lang);
		filters.add(f);
		
		SelectionParams params = new SelectionParams();
		params.setFilters(filters.toArray(new Filter[filters.size()]));
		try {
			SecAuthority[] authorities = securityDao.getAuthorities(userSessionId, params);
			if (authorities != null && authorities.length > 0) {
				return authorities[0];
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
		return null;
	}
	
	public void confirmEditLanguage() {
		curLang = editingItem.getLang();
		SecAuthority tmp = getNodeByLang(editingItem.getId(), editingItem.getLang());
		if (tmp != null) {
			editingItem.setName(tmp.getName());
		}
	}	
	
	public SecAuthority getFilter() {
		if (filter == null) {
			filter = new SecAuthority();
		}
		return filter;
	}
	
	public DaoDataModel<SecAuthority> getDataModel(){
		return dataModel;
	}
	
	public SecAuthority getActiveItem(){
		return activeItem;
	}
	
	public SecAuthority getEditingItem(){
		return editingItem;
	}
	
	public List<SelectItem> getTypes(){
		List<SelectItem> result = getDictUtils().getLov(LovConstants.CERT_AUTHORITY_TYPE);
		return result;
	}
	
	public SecAuthority getDetailItem() {
		return detailItem;
	}

	public void setDetailItem(SecAuthority detailItem) {
		this.detailItem = detailItem;
	}

	public String getTabName() {
		return tabName;
	}

	public void setTabName(String tabName) {
		this.tabName = tabName;
		if (tabName.equalsIgnoreCase("rsaKeysTab")) {
			MbRsaKey bean = (MbRsaKey) ManagedBeanWrapper
					.getManagedBean("MbRsaKey");
			bean.setTabName(tabName);
			bean.setParentSectionId(getSectionId());
			bean.setTableState(getSateFromDB(bean.getComponentId()));
		}
	}	
	
	public String getSectionId() {
		return SectionIdConstants.ISSUING_PERSO_CERT_AUTH;
	}
	
}
