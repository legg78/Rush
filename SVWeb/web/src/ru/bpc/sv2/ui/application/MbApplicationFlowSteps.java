package ru.bpc.sv2.ui.application;

import java.util.ArrayList;
import java.util.List;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.RequestScoped;
import javax.faces.model.SelectItem;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;

import org.ajax4jsf.model.KeepAlive;
import ru.bpc.sv2.common.application.AppFlowStep;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.invocation.Filter.Operator;
import ru.bpc.sv2.logic.ApplicationDao;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.TableRowSelection;

@RequestScoped
@KeepAlive
@ManagedBean (name = "MbApplicationFlowSteps")
public class MbApplicationFlowSteps extends AbstractBean{
	private AppFlowStep filter;
	private AppFlowStep activeStep;
	private AppFlowStep newStep;
	private final DaoDataModel<AppFlowStep> dataModel;
	private final TableRowSelection<AppFlowStep> itemSelection;
	private List<SelectItem> status = null;
	
	private static final Logger logger = Logger.getLogger("APPLICATIONS");
	
	private ApplicationDao applicationDao = new ApplicationDao();
	
	private static String COMPONENT_ID = "stepsTable";
	private String tabName;
	private String parentSectionId;

	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;
	
	public MbApplicationFlowSteps() {
		dataModel = new DaoDataModel<AppFlowStep>() {
			private static final long serialVersionUID = 1L;

			@Override
			protected AppFlowStep[] loadDaoData(SelectionParams params) {
				if (!searching) {
					return new AppFlowStep[0];
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return applicationDao.getAppFlowSteps(userSessionId, params);
				} catch (Exception e) {
					setDataSize(0);
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return new AppFlowStep[0];
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (!searching) {
					return 0;
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return applicationDao.getAppFlowStepsCount(userSessionId, params);
				} catch (Exception e) {
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return 0;
			}
			
		};
		itemSelection = new TableRowSelection<AppFlowStep>(null, dataModel);
	}
	
	@Override
	public void clearFilter() {
		curLang = userLang;
		filter = null;
		searching = false;
		clearBean();
	}
	
	private void clearBean() {
		dataModel.flushCache();
		itemSelection.clearSelection();
		activeStep = null;
	}
	
	public void search() {
		clearBean();
		searching = true;
		curLang = userLang;
	}
	
	public void setFilters() {
		filter = getFilter();

		filters = new ArrayList<Filter>();

		Filter paramFilter;
		paramFilter = new Filter();
		paramFilter.setElement("lang");
		paramFilter.setOp(Operator.eq);
		paramFilter.setValue(userLang);
		filters.add(paramFilter);

		if (filter.getFlowId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("flowId");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(filter.getFlowId());
			filters.add(paramFilter);
		}
		
	}
	
	public DaoDataModel<AppFlowStep> getDataModel() {
		return dataModel;
	}
	
	public SimpleSelection getItemSelection() {
		try {
			if (activeStep == null && dataModel.getRowCount() > 0) {
				setFirstRowActive();
			} else if (activeStep != null && dataModel.getRowCount() > 0) {
				SimpleSelection selection = new SimpleSelection();
				selection.addKey(activeStep.getModelId());
				itemSelection.setWrappedSelection(selection);
				activeStep = itemSelection.getSingleSelection();
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}	
		return itemSelection.getWrappedSelection();
	}

	public void setItemSelection(SimpleSelection selection) {
		itemSelection.setWrappedSelection(selection);
		activeStep = itemSelection.getSingleSelection();

	}

	public AppFlowStep getFilter() {
		if (filter == null){
			filter = new AppFlowStep();
		}
		return filter;
	}
	
	public void setFirstRowActive() {
		dataModel.setRowIndex(0);
		SimpleSelection selection = new SimpleSelection();
		activeStep = (AppFlowStep) dataModel.getRowData();
		selection.addKey(activeStep.getModelId());
		itemSelection.setWrappedSelection(selection);
	}

	public void setFilter(AppFlowStep filter) {
		this.filter = filter;
	}

	public AppFlowStep getActiveStep() {
		return activeStep;
	}

	public void setActiveStep(AppFlowStep activeStep) {
		this.activeStep = activeStep;
	}
	
	public void add(){
		newStep = new AppFlowStep();
		newStep.setFlowId(filter.getFlowId());
		newStep.setLang(userLang);
		curLang = newStep.getLang();
		curMode = NEW_MODE;
	}
	
	public void edit(){
		newStep = activeStep;
		newStep.setFlowId(filter.getFlowId());
		newStep.setLang(userLang);
		curLang = newStep.getLang();
		curMode = EDIT_MODE;
	}
	
	public void fullCleanBean() {
		clearBean();
	}
	
	public void save(){
		try {
			if (isNewMode()){
				newStep = applicationDao.createAppFlowStep(userSessionId, newStep);
				itemSelection.addNewObjectToList(newStep);
						
			} else {
				newStep = applicationDao.modifyAppFlowStep(userSessionId, newStep);
				dataModel.replaceObject(activeStep, newStep);
			}
			cancel();
			search();
			activeStep = newStep;
		}catch (Exception e){
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}
	
	public void delete(){
		try{
			applicationDao.removeAppFlowStep(userSessionId, activeStep);
			cancel();
			search();
		}catch (Exception e){
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}
	
	public AppFlowStep getNewStep(){
		return newStep;
	}
	
	public List<SelectItem> getStatuses(){
		if (status == null) {
			status = getDictUtils().getLov(LovConstants.APPLICATION_STATUS);
		}		
		return status;
	}
	
	public void cancel(){
		curMode = AbstractBean.VIEW_MODE;
		newStep = null;
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
