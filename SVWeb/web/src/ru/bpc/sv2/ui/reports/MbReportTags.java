package ru.bpc.sv2.ui.reports;

import java.util.ArrayList;
import java.util.List;


import ru.bpc.sv2.logic.ReportsDao;
import ru.bpc.sv2.logic.utility.db.DataAccessException;
import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.event.ValueChangeEvent;
import javax.faces.model.SelectItem;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;

import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.constants.SectionIdConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.reports.ReportTag;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.TableRowSelection;
import util.auxil.ManagedBeanWrapper;

@ViewScoped
@ManagedBean (name = "MbReportTags")
public class MbReportTags extends AbstractBean {
	private static final Logger logger = Logger.getLogger("REPORT");
	
	private ReportsDao rptBean = new ReportsDao();
	
	
	
	private MbTagReports mbTagReports;
	
	private ReportTag filter;
	
	private ReportTag activeItem;
	private ReportTag detailItem;
	
	private final DaoDataModel<ReportTag> dataModel;
	private final TableRowSelection<ReportTag> tableRowSelection;
	
	private ReportTag editingItem;
	private List<SelectItem> institutions;
	
	private String tabName;
	
	public MbReportTags(){
		pageLink = "reports|tags";
		mbTagReports = (MbTagReports) ManagedBeanWrapper.getManagedBean("MbTagReports");
		dataModel = new DaoDataModel<ReportTag>(){
			@Override
			protected ReportTag[] loadDaoData(SelectionParams params) {
				ReportTag[] result = null;
				if (searching) {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					try{
						result = rptBean.getReportTags(userSessionId, params);
					}catch (DataAccessException e){
			    		FacesUtils.addMessageError(e);
    					logger.error("", e);
					}
				} else {
					result = new ReportTag[0];
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
						result = rptBean.getReportTagsCount(userSessionId, params);
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
		tableRowSelection = new TableRowSelection<ReportTag>(null, dataModel);
	}
	
	private void setFilters() {
		filters = new ArrayList<Filter>();
		
		Filter f = new Filter();
		f.setElement("lang");
		f.setValue(userLang);
		filters.add(f);
		
		if (filter.getInstId() != null){
			f = new Filter();
			f.setElement("instId");
			f.setValue(filter.getInstId());
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
		
	}
	
	public void clearFilter() {
		filter = null;
		clearState();
		clearBeansStates();
		searching = false;
	}
	
	public void createNewReportTag(){
		editingItem = new ReportTag();
		editingItem.setLang(userLang);
		curLang = editingItem.getLang();
		curMode = AbstractBean.NEW_MODE;
	}
	
	public void editActiveReportTag(){
		try {
			editingItem = (ReportTag) detailItem.clone();
		} catch (CloneNotSupportedException e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
		curMode = AbstractBean.EDIT_MODE;
	}
	
	public void saveEditingReportTag(){
		try {
			if (isNewMode()) {
				editingItem = rptBean.createReportTag(userSessionId, editingItem);
				detailItem = (ReportTag) editingItem.clone();
			} else if (isEditMode()) {
				editingItem = rptBean.modifyReportTag(userSessionId, editingItem);
				detailItem = (ReportTag) editingItem.clone();
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
			resetEditingReportTag();
			setBeansState();
		} catch (Exception e){
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}
	
	public void resetEditingReportTag(){
		curMode = AbstractBean.VIEW_MODE;
		editingItem = null;
	}
	
	public void deleteActiveReportTag(){
		try{
			rptBean.removeReportTag(userSessionId, activeItem);
			
			activeItem = tableRowSelection.removeObjectFromList(activeItem);		
			if (activeItem == null){
				clearState();
			} else {
				detailItem = (ReportTag) activeItem.clone();
			}
			curMode = VIEW_MODE;
			setBeansState();
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
		activeItem = (ReportTag)dataModel.getRowData();
		selection.addKey(activeItem.getModelId());
		tableRowSelection.setWrappedSelection(selection);
		if (activeItem != null) {
			setBeansState();
			detailItem = (ReportTag) activeItem.clone();
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
					detailItem = (ReportTag) activeItem.clone();
				}
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}
	
	private void setBeansState(){
		mbTagReports.setTagId(null);
		Integer id = activeItem != null ? activeItem.getId() : null;
		mbTagReports.setTagId(id);
	}
	
	public ReportTag getFilter() {
		if (filter == null) {
			filter = new ReportTag();
		}
		return filter;
	}
	
	public DaoDataModel<ReportTag> getDataModel(){
		return dataModel;
	}
	
	public ReportTag getActiveItem(){
		return activeItem;
	}
	
	public ReportTag getEditingItem(){
		return editingItem;
	}

	public List<SelectItem> getInstitutions(){
		if (institutions == null) {
			institutions = (ArrayList<SelectItem>) getDictUtils().getLov(LovConstants.INSTITUTIONS_SYS);
		}
		return institutions;
	}

	public void changeLanguage(ValueChangeEvent event) {
		curLang = (String) event.getNewValue();
		detailItem = getNodeByLang(detailItem.getId(), curLang);
	}
	
	public ReportTag getNodeByLang(Integer id, String lang) {
		filters = new ArrayList<Filter>();

		Filter f = new Filter();
		f.setElement("id");
		f.setValue(id.toString());
		filters.add(f);

		f = new Filter();
		f.setElement("lang");
		f.setValue(lang);
		filters.add(f);
		
		SelectionParams params = new SelectionParams();
		params.setFilters(filters.toArray(new Filter[filters.size()]));
		try {
			ReportTag[] reportTags = rptBean.getReportTags(userSessionId, params);
			if (reportTags != null && reportTags.length > 0) {
				return reportTags[0];
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
		return null;
	}
	
	public void confirmEditLanguage() {
		curLang = editingItem.getLang();
		ReportTag tmp = getNodeByLang(editingItem.getId(), editingItem.getLang());
		if (tmp != null) {
			editingItem.setLabel(tmp.getLabel());
			editingItem.setDescription(tmp.getDescription());
		}
	}

	public ReportTag getDetailItem() {
		return detailItem;
	}

	public void setDetailItem(ReportTag detailItem) {
		this.detailItem = detailItem;
	}

	public String getTabName() {
		return tabName;
	}

	public void setTabName(String tabName) {
		this.tabName = tabName;
		
		if (tabName.equalsIgnoreCase("reportsTab")) {
			MbTagReports bean = (MbTagReports) ManagedBeanWrapper
					.getManagedBean("MbTagReports");
			bean.setTabName(tabName);
			bean.setParentSectionId(getSectionId());
			bean.setTableState(getSateFromDB(bean.getComponentId()));
		}
	}	

	public String getSectionId() {
		return SectionIdConstants.CONFIGURATION_RPT_TAG;
	}
}
