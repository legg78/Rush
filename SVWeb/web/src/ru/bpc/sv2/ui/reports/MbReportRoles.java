package ru.bpc.sv2.ui.reports;

import java.util.ArrayList;
import java.util.HashMap;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.RequestScoped;

import org.ajax4jsf.model.ExtendedDataModel;
import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;
import org.ajax4jsf.model.KeepAlive;

import ru.bpc.sv2.administrative.roles.ComplexRole;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.RolesDao;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.TableRowSelection;

@RequestScoped
@KeepAlive
@ManagedBean (name = "MbReportRoles")
public class MbReportRoles extends AbstractBean{
	private static final String ROLES_NAVIGATION_RULE = "acm_roles";
	private static final String NROLES_BEAN = "roles"; 
	
	private Logger logger = Logger.getLogger("REPORTS");
	
	private RolesDao rolesDao = new RolesDao();
	
	private final DaoDataModel<ComplexRole> rolesSource;
	private Integer reportId;
	private final TableRowSelection<ComplexRole> tableRowSelection;
	private ComplexRole activeComplexRole;
	private String backLink;
	
	private static String COMPONENT_ID = "reportRolesTable";
	private String tabName;
	private String parentSectionId;
	
	public MbReportRoles(){
		rolesSource = new DaoDataModel<ComplexRole>(){
			@Override
			protected ComplexRole[] loadDaoData(SelectionParams params) {
				if (reportId == null)
					return new ComplexRole[0];
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return rolesDao.getReportRoles(userSessionId, params);
				} catch (Exception e) {
					setDataSize(0);
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return new ComplexRole[0];
			}
			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (reportId == null)
					return 0;
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return rolesDao.getReportRolesCount(userSessionId, params);
				} catch (Exception e) {
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return 0;
			}
		};
		tableRowSelection = new TableRowSelection<ComplexRole>(null, rolesSource);
	}
	
	private void setFilters(){
		filters = new ArrayList<Filter>();
		
		Filter filter = new Filter();
		filter.setElement("reportId");
		filter.setValue(reportId);
		filters.add(filter);
		
		filter = new Filter();
		filter.setElement("lang");
		filter.setValue(userLang);
		filters.add(filter);
	}
	
	public void search() {
		rolesSource.flushCache();
	}
	
	public void clearBean(){
		rolesSource.flushCache();
		reportId = null;
	}
	
	public String addRole(){
/*
		NRoles rolesBean = (NRoles) ManagedBeanWrapper.getManagedBean(NROLES_BEAN);
		rolesBean.setSelectMode(true);
		rolesBean.setObjectId(reportId.longValue());
		rolesBean.setAddRolesToReport(true);
		rolesBean.setBackLink(backLink);
*/
		HashMap<String,Object> queueFilter = new HashMap<String,Object>();
		queueFilter.put("selectMode", "true");
		queueFilter.put("objectId", reportId.longValue());
		queueFilter.put("setAddRolesToReport", "true");
		queueFilter.put("backLink", backLink);
		addFilterToQueue(NROLES_BEAN, queueFilter);

		return ROLES_NAVIGATION_RULE;
	}

	public void deleteRole(){
		rolesDao.deleteRoleFromReport(userSessionId, activeComplexRole.getBindId());
		rolesSource.flushCache();
		tableRowSelection.clearSelection();
		activeComplexRole = null;
	}
	
	public void setSearching(boolean searching){
		if (!searching){
			clearBean();
		}
	}
	
	public ExtendedDataModel getRoles() {
		return rolesSource;
	}

	public SimpleSelection getItemSelection() {
		return tableRowSelection.getWrappedSelection();
	}

	public void setItemSelection(SimpleSelection simpleSelection){
		tableRowSelection.setWrappedSelection(simpleSelection);
		activeComplexRole = tableRowSelection.getSingleSelection();
	}

	public ComplexRole getActiveComplexRole() {
		return activeComplexRole;
	}

	public void setActiveComplexRole(ComplexRole activeComplexRole) {
		this.activeComplexRole = activeComplexRole;
	}

	public Integer getReportId() {
		return reportId;
	}
	
	public void setReportId(Integer reportId) {
		this.reportId = reportId;
	}

	public String getBackLink() {
		return backLink;
	}

	public void setBackLink(String backLink) {
		this.backLink = backLink;
	}

	@Override
	public void clearFilter() {
		// TODO Auto-generated method stub
		
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
