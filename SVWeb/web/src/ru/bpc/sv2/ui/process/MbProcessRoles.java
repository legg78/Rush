package ru.bpc.sv2.ui.process;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;

import ru.bpc.sv2.administrative.roles.ComplexRole;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.invocation.Filter.Operator;
import ru.bpc.sv2.logic.RolesDao;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.TableRowSelection;
import util.auxil.ManagedBeanWrapper;
import util.auxil.SessionWrapper;

@ViewScoped
@ManagedBean (name = "MbProcessRoles")
public class MbProcessRoles extends AbstractBean {
	private RolesDao _rolesDao = new RolesDao();

	private ComplexRole _activeComplexRole;
	private ComplexRole filter;
	private String backLink;

	private boolean showModal;

	private final DaoDataModel<ComplexRole> _rolesSource;

	private final TableRowSelection<ComplexRole> _itemSelection;
	private static final Logger logger = Logger.getLogger("PROCESSES");
	private Integer processId;

	private static String COMPONENT_ID = "accountsTable";
	private String tabName;
	private String parentSectionId;
	
	public MbProcessRoles() {
		_rolesSource = new DaoDataModel<ComplexRole>() {
			@Override
			protected ComplexRole[] loadDaoData(SelectionParams params) {
				if (processId == null)
					return new ComplexRole[0];
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _rolesDao.getProcessRoles(userSessionId, params);
				} catch (Exception e) {
					setDataSize(0);
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return new ComplexRole[0];
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (processId == null)
					return 0;
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _rolesDao.getProcessRolesCount(userSessionId, params);
				} catch (Exception e) {
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return 0;
			}
		};
		_itemSelection = new TableRowSelection<ComplexRole>(null, _rolesSource);
	}

	public DaoDataModel<ComplexRole> getRoles() {
		return _rolesSource;
	}

	public ComplexRole getActiveRole() {
		return _activeComplexRole;
	}

	public void setActiveRole(ComplexRole activeRole) {
		_activeComplexRole = activeRole;
	}

	public SimpleSelection getItemSelection() {
		if (_activeComplexRole == null && _rolesSource.getRowCount() > 0) {
			setFirstRowActive();
		} else if (_activeComplexRole != null && _rolesSource.getRowCount() > 0) {
			SimpleSelection selection = new SimpleSelection();
			selection.addKey(_activeComplexRole.getModelId());
			_itemSelection.setWrappedSelection(selection);
			_activeComplexRole = _itemSelection.getSingleSelection();
		}
		return _itemSelection.getWrappedSelection();
	}
	
	public void setFirstRowActive() {
		_rolesSource.setRowIndex(0);
		SimpleSelection selection = new SimpleSelection();
		_activeComplexRole = (ComplexRole) _rolesSource.getRowData();
		selection.addKey(_activeComplexRole.getModelId());
		_itemSelection.setWrappedSelection(selection);
	}

	public void setItemSelection(SimpleSelection selection) {
		_itemSelection.setWrappedSelection(selection);
		_activeComplexRole = _itemSelection.getSingleSelection();
	}

	public void search() {
		_rolesSource.flushCache();
		_activeComplexRole = null;
	}

	public void deleteRole() {
		_rolesDao.deleteProcessRole(userSessionId, _activeComplexRole.getBindId());
		_rolesSource.flushCache();
		_itemSelection.clearSelection();
		_activeComplexRole = null;
	}

	public String addSelectedRolesToProcess() {
		List<ComplexRole> rolesToAdd = _itemSelection.getMultiSelection();
		if (processId != null) {
			_rolesDao.addRolesToProcess(userSessionId, processId, rolesToAdd
					.toArray(new ComplexRole[rolesToAdd.size()]));
		}
		return backLink;
	}

	public String deleteSelectedRolesFromProcess() {

		List<ComplexRole> rolesToDel = _itemSelection.getMultiSelection();
		if (processId != null) {
			_rolesDao.deleteRolesFromProcess(userSessionId, rolesToDel
					.toArray(new ComplexRole[rolesToDel.size()]));
			_rolesSource.flushCache();
			_itemSelection.clearSelection();
			_activeComplexRole = null;
		}
		return "";
	}

	public void setFilters() {
		List<Filter> filtersList = new ArrayList<Filter>();
		if (getFilter().getShortDesc() != null && !getFilter().getShortDesc().trim().equals("")) {
			Filter paramFilter = new Filter();
			paramFilter.setElement("shortDesc");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(getFilter().getShortDesc().trim().toUpperCase().replaceAll("[*]",
					"%").replaceAll("[?]", "_"));
			filtersList.add(paramFilter);
		}
		if (getFilter().getName() != null && !getFilter().getName().trim().equals("")) {
			Filter paramFilter = new Filter();
			paramFilter.setElement("name");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(getFilter().getName().trim().toUpperCase().replaceAll("[*]", "%")
					.replaceAll("[?]", "_"));
			filtersList.add(paramFilter);
		}

		Filter paramFilter = new Filter();
		paramFilter.setElement("processId");
		paramFilter.setOp(Operator.eq);
		paramFilter.setValue(processId.toString());
		filtersList.add(paramFilter);

		paramFilter = new Filter();
		paramFilter.setElement("lang");
		paramFilter.setOp(Operator.eq);
		paramFilter.setValue(SessionWrapper.getField("language"));
		filtersList.add(paramFilter);

		filters = filtersList;
	}

	public String addRole() {
		HashMap<String,Object> queueFilter = new HashMap<String,Object>();
		queueFilter.put("selectMode", "true");
		queueFilter.put("objectId", processId.longValue());
		queueFilter.put("addRolesToProcess", "true");
		queueFilter.put("backLink", backLink);
		addFilterToQueue("roles", queueFilter);

		MbProcesses procBean = (MbProcesses) ManagedBeanWrapper.getManagedBean("MbProcesses");
		procBean.setKeepState(true);
		search();
		return "acm_roles";
	}

	public ComplexRole getFilter() {
		if (filter == null)
			filter = new ComplexRole();
		return filter;
	}

	public void setFilter(ComplexRole filter) {
		this.filter = filter;
	}

	public String getBackLink() {
		return backLink;
	}

	public void setBackLink(String backLink) {
		this.backLink = backLink;
	}

	public boolean isShowModal() {
		return showModal;
	}

	public void setShowModal(boolean showModal) {
		this.showModal = showModal;
	}

	public Integer getProcessId() {
		return processId;
	}

	public void setProcessId(Integer processId) {
		this.processId = processId;
	}

	public void clearBean() {
		_rolesSource.flushCache();
		_itemSelection.clearSelection();
		_activeComplexRole = null;
	}

	public void fullCleanBean() {
		clearBean();
		filter = null;
		processId = null;
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
