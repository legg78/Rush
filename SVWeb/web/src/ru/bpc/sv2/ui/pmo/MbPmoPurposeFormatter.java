package ru.bpc.sv2.ui.pmo;

import java.util.ArrayList;
import java.util.List;


import ru.bpc.sv2.logic.PaymentOrdersDao;
import ru.bpc.sv2.logic.utility.db.DataAccessException;
import javax.faces.bean.ManagedBean;
import javax.faces.bean.RequestScoped;
import javax.faces.model.SelectItem;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;

import org.ajax4jsf.model.KeepAlive;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.pmo.PmoPurposeFormatter;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.TableRowSelection;

@RequestScoped
@KeepAlive
@ManagedBean (name = "MbPmoPurposeFormatter")
public class MbPmoPurposeFormatter extends AbstractBean {
	private static final Logger logger = Logger.getLogger("PMO");
	
	private PaymentOrdersDao paymentOrdersDao = new PaymentOrdersDao();
	
	
	
	private PmoPurposeFormatter filter;
	
	private PmoPurposeFormatter activeItem;
	
	private final DaoDataModel<PmoPurposeFormatter> dataModel;
	private final TableRowSelection<PmoPurposeFormatter> tableRowSelection;
	
	private PmoPurposeFormatter editingItem;
	
	private Integer standardId;
	private Integer versionId;
	
	private static String COMPONENT_ID = "PmoPurposeFormatterTable";
	private String tabName;
	private String parentSectionId;
	
	public MbPmoPurposeFormatter(){
		
		dataModel = new DaoDataModel<PmoPurposeFormatter>(){
			@Override
			protected PmoPurposeFormatter[] loadDaoData(SelectionParams params) {
				PmoPurposeFormatter[] result = null;
				if (searching) {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					try{
						result = paymentOrdersDao.getPurposeFormatters(userSessionId, params);
					}catch (DataAccessException e){
			    		FacesUtils.addMessageError(e);
    					logger.error("", e);
					}
				} else {
					result = new PmoPurposeFormatter[0];
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
						result = paymentOrdersDao.getPurposeFormattersCount(userSessionId, params);
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
		tableRowSelection = new TableRowSelection<PmoPurposeFormatter>(null, dataModel);
	}
	
	private void setFilters() {
		filters = new ArrayList<Filter>();
		
		Filter f = new Filter();
		f.setElement("lang");
		f.setValue(curLang);
		filters.add(f);
		
		if (standardId != null){
			f = new Filter();
			f.setElement("standardId");
			f.setValue(standardId);
			filters.add(f);
		}
		
		f = new Filter();
		f.setElement("versionId");
		f.setValue(versionId);
		filters.add(f);
		
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
		clearBeansStates();
		searching = false;
	}
	
	public void createNewPurposeFormatter(){
		editingItem = new PmoPurposeFormatter();
		editingItem.setStandardId(standardId);
		editingItem.setVersionId(versionId);
		editingItem.setLang(curLang);
		curMode = AbstractBean.NEW_MODE;
	}
	
	public void editActivePurposeFormatter(){
		editingItem = activeItem;
		editingItem.setLang(curLang);
		curMode = AbstractBean.EDIT_MODE;
	}
	
	public void saveEditingPurposeFormatter(){
		try {
			if (isNewMode()) {
				editingItem = paymentOrdersDao.createPurposeFormatter(userSessionId, editingItem);
			} else if (isEditMode()) {
				editingItem = paymentOrdersDao.modifyPurposeFormatter(userSessionId, editingItem);
			}
		}catch (DataAccessException e){
			FacesUtils.addMessageError(e);
			logger.error("", e);			
			return;
		}
		if (isNewMode()) {
			tableRowSelection.addNewObjectToList(editingItem);
		} else {
			try{
				dataModel.replaceObject(activeItem, editingItem);
			}catch(Exception e){
				e.printStackTrace();
			}
		}
		activeItem = editingItem;
		resetEditingPurposeFormatter();
	}
	
	public void resetEditingPurposeFormatter(){
		curMode = AbstractBean.VIEW_MODE;
		editingItem = null;
	}
	
	public void deleteActivePurposeFormatter(){
		try{
			paymentOrdersDao.removePurposeFormatter(userSessionId, activeItem);
		}catch (DataAccessException e){
			FacesUtils.addMessageError(e);
			logger.error("", e);
			return;
		}
		activeItem = tableRowSelection.removeObjectFromList(activeItem);	
		if (activeItem == null){
			clearState();
		}
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
		activeItem = (PmoPurposeFormatter)dataModel.getRowData();
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
	
	public PmoPurposeFormatter getFilter() {
		if (filter == null) {
			filter = new PmoPurposeFormatter();
		}
		return filter;
	}
	
	public DaoDataModel<PmoPurposeFormatter> getDataModel(){
		return dataModel;
	}
	
	public PmoPurposeFormatter getActiveItem(){
		return activeItem;
	}
	
	public PmoPurposeFormatter getEditingItem(){
		return editingItem;
	}

	public Integer getStandardId() {
		return standardId;
	}

	public void setStandardId(Integer standardId) {
		this.standardId = standardId;
		if (standardId != null){
			search();
		} else {
			clearFilter();
		}
	}

	public List<SelectItem> getPurposes(){
		List<SelectItem> result = getDictUtils().getLov(LovConstants.PAYMENT_PURPOSE);
		return result;
	}
	
	public List<SelectItem> getMessTypes(){
		List<SelectItem> result = getDictUtils().getLov(LovConstants.PAYMENT_ORD_MESS_TYPE);
		return result;
	}

	public Integer getVersionId() {
		return versionId;
	}

	public void setVersionId(Integer versionId) {
		this.versionId = versionId;
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
