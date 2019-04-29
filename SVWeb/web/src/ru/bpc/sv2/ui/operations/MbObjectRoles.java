package ru.bpc.sv2.ui.operations;

import java.util.ArrayList;
import java.util.HashMap;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;

import org.ajax4jsf.model.ExtendedDataModel;
import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;

import ru.bpc.sv2.administrative.roles.ComplexRole;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.RolesDao;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.TableRowSelection;

@ViewScoped
@ManagedBean (name = "MbObjectRoles")
public class MbObjectRoles extends AbstractBean{
	private static final String ROLES_NAVIGATION_RULE = "acm_roles";
	private static final String NROLES_BEAN = "roles"; 
	
	private Logger logger = Logger.getLogger("OPER_PROCESSING");
	
	private RolesDao rolesDao = new RolesDao();
	
	private final DaoDataModel<ComplexRole> rolesSource;
	private Integer objectId;
	private String entityType;
	private final TableRowSelection<ComplexRole> tableRowSelection;
	private ComplexRole activeComplexRole;
	private String backLink;
	
	private static String COMPONENT_ID = "objectRolesTable";
	private String tabName;
	private String parentSectionId;
	private String parentBean;
	private HashMap<String,Object> parentQueueFilter;
	
	public MbObjectRoles(){
		rolesSource = new DaoDataModel<ComplexRole>(){
			@Override
			protected ComplexRole[] loadDaoData(SelectionParams params) {
				if (objectId == null)
					return new ComplexRole[0];
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return rolesDao.getObjectRoles(userSessionId, params);
				} catch (Exception e) {
					setDataSize(0);
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return new ComplexRole[0];
			}
			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (objectId == null)
					return 0;
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return rolesDao.getObjectRolesCount(userSessionId, params);
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
		filter.setElement("objectId");
		filter.setValue(objectId);
		filters.add(filter);
		
		filter = new Filter();
		filter.setElement("lang");
		filter.setValue(userLang);
		filters.add(filter);
		
		filter = new Filter();
		filter.setElement("entity_type");
		filter.setValue(entityType);
		filters.add(filter);
	}
	
	public void search() {
		rolesSource.flushCache();
	}
	
	public void clearBean(){
		rolesSource.flushCache();
		objectId = null;
	}
	
	public String addRole(){
		addFilterToQueue(parentBean, parentQueueFilter);
		HashMap<String,Object> queueFilter = new HashMap<String,Object>();
		queueFilter.put("selectMode", "true");
		queueFilter.put("objectId", objectId.longValue());
		queueFilter.put("setAddRolesToObject", "true");
		queueFilter.put("entityType", entityType);
		queueFilter.put("backLink", backLink);
		addFilterToQueue(NROLES_BEAN, queueFilter);

		return ROLES_NAVIGATION_RULE;
	}

	public void deleteRole(){
		rolesDao.deleteRoleFromObject(userSessionId, activeComplexRole.getBindId());
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

	public Integer getObjectId() {
		return objectId;
	}
	
	public void setObjectId(Integer objectId) {
		this.objectId = objectId;
	}

	public String getEntityType() {
		return entityType;
	}

	public void setEntityType(String entityType) {
		this.entityType = entityType;
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

	public void setParentBean(String parentBean) {
		this.parentBean = parentBean;
	}

	public void setParentQueueFilter(HashMap<String, Object> parentQueueFilter) {
		this.parentQueueFilter = parentQueueFilter;
	}
}
