package ru.bpc.sv2.ui.aut;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;


import ru.bpc.sv2.logic.utility.db.DataAccessException;
import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.model.SelectItem;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;

import ru.bpc.sv2.aut.RespCode;
import ru.bpc.sv2.constants.DictNames;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.AuthorizationDao;
import ru.bpc.sv2.ui.utils.*;
import util.auxil.ManagedBeanWrapper;

@ViewScoped
@ManagedBean (name = "MbAutRespCode")
public class MbAutRespCode extends AbstractBean {
	private static final long serialVersionUID = 8588739607580040219L;

	private static final Logger logger = Logger.getLogger("AUTH_PROCESSING");
	
	private static String COMPONENT_ID = "2265:respCodeTable";

	private AuthorizationDao authorizationDao = new AuthorizationDao();
	
	private RespCode filter;
	
	private RespCode activeItem;
	
	private List<SelectItem> msgTypes = null;
	private List<SelectItem> respCodes = null;
	private List<SelectItem> procTypes = null;
	private List<SelectItem> operStatuses = null;
	private List<SelectItem> procModes = null;
	private List<SelectItem> statusReasons = null;
	private List<SelectItem> operTypes = null;
	private List<SelectItem> signCompletion = null;
	private List<SelectItem> operReasons;
	
	private final DaoDataModel<RespCode> dataModel;
	private final TableRowSelection<RespCode> tableRowSelection;
	
	private RespCode editingItem;
	
	public MbAutRespCode(){
		pageLink = "aut|respCode";
		dataModel = new DaoDataModel<RespCode>(){
			private static final long serialVersionUID = -6009054591294114402L;

			@Override
			protected RespCode[] loadDaoData(SelectionParams params) {
				RespCode[] result = null;
				if (searching) {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					try {
						result = authorizationDao.getRespCodes(userSessionId,
								params);
					} catch (DataAccessException e) {
						FacesUtils.addMessageError(e);
						logger.error("", e);
					}
				} else {
					result = new RespCode[0];
				}
				return result;
			}
			
			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				int result = 0;
				if (searching){
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					try {
						result = authorizationDao.getRespCodesCount(
								userSessionId, params);
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
		tableRowSelection = new TableRowSelection<RespCode>(null, dataModel);
	}
	
	private void setFilters() {
		filters = new ArrayList<Filter>();
		
		Filter f = new Filter();
		f.setElement("lang");
		f.setValue(curLang);
		filters.add(f);
		
		if (filter.getRespCode() != null){
			f = new Filter();
			f.setElement("respCode");
			f.setValue(filter.getRespCode());
			filters.add(f);
		} 
		if (filter.getProcType() != null){
			f = new Filter();
			f.setElement("procType");
			f.setValue(filter.getProcType());
			filters.add(f);
		} 
		if (filter.getAuthStatus() != null){
			f = new Filter();
			f.setElement("authStatus");
			f.setValue(filter.getAuthStatus());
			filters.add(f);
		}
		if (filter.getProcMode() != null){
			f = new Filter();
			f.setElement("procMode");
			f.setValue(filter.getProcMode());
			filters.add(f);
		}
		if (filter.getStatusReason() != null){
			f = new Filter();
			f.setElement("statusReason");
			f.setValue(filter.getStatusReason());
			filters.add(f);
		}
		if (filter.getOperType() != null){
			f = new Filter();
			f.setElement("operType");
			f.setValue(filter.getOperType());
			filters.add(f);
		}
	}

	@Override
	protected void applySectionFilter(Integer filterId) {
		try {
			FilterFactory factory = (FilterFactory) ManagedBeanWrapper
					.getManagedBean("filterFactory");
			Map<String, String> filterRec = factory.getSectionFilterRecs(filterId);
			sectionFilter = factory.getUserSectionFiltersObjects().get(filterId);
			if (filterRec != null) {
				filter = new RespCode();
				if (filterRec.get("respCode") != null) {
					filter.setRespCode(filterRec.get("respCode"));
				}
				if (filterRec.get("procType") != null) {
					filter.setProcType(filterRec.get("procType"));
				}
				if (filterRec.get("authStatus") != null) {
					filter.setAuthStatus(filterRec.get("authStatus"));
				}
				if (filterRec.get("procMode") != null) {
					filter.setProcType(filterRec.get("procMode"));
				}
				if (filterRec.get("statusReason") != null) {
					filter.setStatusReason(filterRec.get("statusReason"));
				}
				if (filterRec.get("operType") != null) {
					filter.setOperType(filterRec.get("operType"));
				}
			}
			if (searchAutomatically) {
				search();
			}
			sectionFilterModeEdit = true;
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	@Override
	public void saveSectionFilter() {
		try {
			FilterFactory factory = (FilterFactory) ManagedBeanWrapper
					.getManagedBean("filterFactory");

			Map<String, String> filterRec = new HashMap<String, String>();
			filter = getFilter();
			if (filter.getRespCode() != null) {
				filterRec.put("respCode", filter.getRespCode());
			}
			if (filter.getProcType() != null) {
				filterRec.put("procType", filter.getProcType());
			}
			if (filter.getAuthStatus() != null) {
				filterRec.put("authStatus", filter.getAuthStatus());
			}
			if (filter.getProcMode() != null) {
				filterRec.put("procMode", filter.getProcMode());
			}
			if (filter.getStatusReason() != null) {
				filterRec.put("statusReason", filter.getStatusReason());
			}
			if (filter.getOperType() != null) {
				filterRec.put("operType", filter.getOperType());
			}

			sectionFilter = getSectionFilter();
			sectionFilter.setRecs(filterRec);

			factory.saveSectionFilter(sectionFilter, sectionFilterModeEdit);
			selectedSectionFilter = sectionFilter.getId();
			sectionFilterModeEdit = true;
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}
	
	public void createNewRespCode(){
		editingItem = new RespCode();
		curMode = AbstractBean.NEW_MODE;
	}
	
	public void editActiveRespCode(){
		editingItem = activeItem;
		curMode = AbstractBean.EDIT_MODE;
	}
	
	public void saveEditingRespCode() throws Exception{
		try {
			if (isNewMode()) {
				authorizationDao.createRespCode(userSessionId, editingItem);
			} else if (isEditMode()) {
				authorizationDao.modifyRespCode(userSessionId, editingItem);
			}
		}catch (DataAccessException e){
			FacesUtils.addMessageError(e);
			logger.error("", e);
			resetEditingRespCode();
			return;
		}
		if (isNewMode()) {
			tableRowSelection.addNewObjectToList(editingItem);
		} else {
			dataModel.replaceObject(activeItem, editingItem);
		}
		activeItem = editingItem;
		resetEditingRespCode();
	}	
	
	public void resetEditingRespCode(){
		curMode = AbstractBean.VIEW_MODE;
		editingItem = null;
	}
	
	public void deleteActiveRespCode(){
		try{
			authorizationDao.deleteRespCode(userSessionId, activeItem);
		}catch (DataAccessException e){
			FacesUtils.addMessageError(e);
			logger.error("", e);
			return;
		}
		activeItem = tableRowSelection.removeObjectFromList(activeItem);
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
	
	public RespCode getEditingItem() {
		if (editingItem == null) {
			editingItem = new RespCode();
		}
		return editingItem;
	}

	public List<SelectItem> getMsgTypes(){
		if (msgTypes == null) {
			msgTypes = getDictUtils().getLov(LovConstants.MESSAGE_TYPES);
		}
		return msgTypes;
	}
	
	public List<SelectItem> getRespCodes(){
		if (respCodes == null) {
			respCodes = getDictUtils().getLov(LovConstants.RESPONSE_CODES);
		}
		return respCodes;
	}
	
	public List<SelectItem> getSignCompletion(){
		if (signCompletion == null) {
			signCompletion = getDictUtils().getLov(LovConstants.SIGN_COMPLETION);
		}
		return signCompletion;
	}
	
	public List<SelectItem> getProcTypes(){
		if (procTypes == null) {
			procTypes = getDictUtils().getArticles(DictNames.AUTH_PROCESSING_TYPE, true, true);
		}
		return procTypes;
	}
	
	public List<SelectItem> getOperStatuses(){
		if (operStatuses == null) {
			operStatuses = getDictUtils().getArticles(DictNames.OPERATION_STATUS, true, true);
		}
		return operStatuses;
	}
	
	public List<SelectItem> getProcModes(){
		if (procModes == null) {
			procModes = getDictUtils().getArticles(DictNames.AUTH_PROCESSING_MODE, true, true);
		}
		return procModes;
	}
	
	public List<SelectItem> getStatusReasons(){
		if (statusReasons == null) {
			statusReasons = getDictUtils().getArticles(DictNames.AUTH_STATUS_REASON, true, true);
		}
		return statusReasons;
	}
	
	public List<SelectItem> getOperTypes(){
		if (operTypes == null) {
			operTypes = getDictUtils().getLov(LovConstants.OPERATION_TYPE);
		}
		return operTypes;
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
		activeItem = (RespCode) dataModel.getRowData();
		selection.addKey(activeItem.getModelId());
		tableRowSelection.setWrappedSelection(selection);

		setBeansState();
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
	
	public RespCode getFilter() {
		if (filter == null) {
			filter = new RespCode();
		}
		return filter;
	}
	
	public DaoDataModel<RespCode> getDataModel(){
		return dataModel;
	}
	
	public RespCode getActiveItem(){
		return activeItem;
	}

	public String getComponentId() {
		return COMPONENT_ID;
	}

	public Logger getLogger() {
		return logger;
	}

	public List<SelectItem> getSttlTypes() {
		return getDictUtils().getLov(LovConstants.SETTLEMENT_TYPES);
	}
	
	public List<SelectItem> getBooleans() {
		return getDictUtils().getLov(LovConstants.BOOLEAN);
	}
	
	public List<SelectItem> getOperReasons() {
		if (operReasons == null){
			updateOperReasons();
		}
		return operReasons;
	}

	public void updateOperReasons(){
		Map<String, Object> params = new HashMap<String, Object>();
		params.put("oper_type", getEditingItem().getOperType());
		operReasons = getDictUtils().getLov(LovConstants.OPER_REASON, params);
	}
}
