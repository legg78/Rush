package ru.bpc.sv2.ui.process;

import java.util.ArrayList;
import java.util.List;


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
import ru.bpc.sv2.invocation.Filter.Operator;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.ProcessDao;
import ru.bpc.sv2.process.ProcessBO;
import ru.bpc.sv2.process.ProcessGroup;
import ru.bpc.sv2.ui.navigation.Menu;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.TableRowSelection;
import util.auxil.ManagedBeanWrapper;

@ViewScoped
@ManagedBean (name = "MbProcessGroupsSearch")
public class MbProcessGroupsSearch extends AbstractBean {
	private static final long serialVersionUID = 6094738932380073995L;

	private static String COMPONENT_ID = "1072:mainTable";

	private ProcessDao _processDao = new ProcessDao();

	private ProcessGroup filter;
	private ProcessGroup _activeGroup;
	private ProcessGroup newGroup;
	private MbProcessGroup groupBean; // related session bean
	private String backLink;
	private static final Logger logger = Logger.getLogger("PROCESSES");

	private Integer processId;

	private final DaoDataModel<ProcessGroup> _groupsSource;

	private final TableRowSelection<ProcessGroup> _itemSelection;

	private String tabName;
	
	public MbProcessGroupsSearch() {
		pageLink = "processes|groups";
		tabName = "detailsTab";
		groupBean = (MbProcessGroup) ManagedBeanWrapper.getManagedBean("MbProcessGroup");
		Menu menu = (Menu) ManagedBeanWrapper.getManagedBean("menu");
		_groupsSource = new DaoDataModel<ProcessGroup>() {
			private static final long serialVersionUID = -6320781127784516914L;

			@Override
			protected ProcessGroup[] loadDaoData(SelectionParams params) {
				if (!isSearching())
					return new ProcessGroup[0];

				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _processDao.getProcessGroups(userSessionId, params);
				} catch (Exception e) {
					setDataSize(0);
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return new ProcessGroup[0];
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (!isSearching())
					return 0;

				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _processDao.getProcessGroupsCount(userSessionId, params);
				} catch (Exception e) {
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return 0;
			}
		};
		_itemSelection = new TableRowSelection<ProcessGroup>(null, _groupsSource);

		if (!menu.isKeepState()) {

		} else {
			_activeGroup = groupBean.getGroup();
			backLink = groupBean.getBackLink();
			searching = groupBean.isSearching();
		}
	}

	public DaoDataModel<ProcessGroup> getGroups() {
		return _groupsSource;
	}

	public ProcessGroup getActiveGroup() {
		if (_activeGroup == null){
			_activeGroup = new ProcessGroup();
		}
		return _activeGroup;
	}

	public void setActiveGroup(ProcessGroup activeGroup) {
		_activeGroup = activeGroup;
	}

	public SimpleSelection getItemSelection() {
		if (_activeGroup == null && _groupsSource.getRowCount() > 0) {
			setFirstRowActive();
		} else if (_activeGroup != null && _groupsSource.getRowCount() > 0) {
			SimpleSelection selection = new SimpleSelection();
			selection.addKey(_activeGroup.getModelId());
			_itemSelection.setWrappedSelection(selection);
			_activeGroup = _itemSelection.getSingleSelection();
		}
		return _itemSelection.getWrappedSelection();
	}

	public void setFirstRowActive() {
		_groupsSource.setRowIndex(0);
		SimpleSelection selection = new SimpleSelection();
		_activeGroup = (ProcessGroup) _groupsSource.getRowData();
		selection.addKey(_activeGroup.getModelId());
		_itemSelection.setWrappedSelection(selection);
		setInfo();
	}

	public void setItemSelection(SimpleSelection selection) {
		_itemSelection.setWrappedSelection(selection);
		_activeGroup = _itemSelection.getSingleSelection();
		setInfo();
	}

	public void setInfo() {
		groupBean.setGroup(_activeGroup);
		if (_activeGroup != null) {
			MbProcessesSearch processesBean = (MbProcessesSearch) ManagedBeanWrapper
					.getManagedBean("MbProcessesSearch");
			ProcessBO filterProcess = new ProcessBO();
			filterProcess.setGroupId(_activeGroup.getId());
			filterProcess.setLang(userLang);
			processesBean.setFilter(filterProcess);
			processesBean.search();
		}
	}

	public void search() {
		clearState();
		setSearching(true);
	}

	public void clearState() {
		_activeGroup = null;
		_groupsSource.flushCache();
		_itemSelection.clearSelection();

		clearBeanStates();
	}
	
	public void clearFilter() {
		filter = new ProcessGroup();
		clearState();
		searching = false;
	}

	private void clearBeanStates() {
		MbProcessesSearch processesBean = (MbProcessesSearch) ManagedBeanWrapper
				.getManagedBean("MbProcessesSearch");
		processesBean.clearFilter();
	}

	public ProcessGroup getFilter() {
		if (filter == null)
			filter = new ProcessGroup();
		return filter;
	}

	public void setFilter(ProcessGroup filter) {
		this.filter = filter;
	}

	private void setFilters() {
		filter = getFilter();
		filters = new ArrayList<Filter>();

		Filter paramFilter;
		if (filter.getId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("id");
			paramFilter.setOp(Operator.like);
			paramFilter.setValue(filter.getId() + "%");
			filters.add(paramFilter);
		}

		paramFilter = new Filter();
		paramFilter.setElement("lang");
		paramFilter.setOp(Operator.eq);
		paramFilter.setValue(userLang);
		filters.add(paramFilter);

		if (filter.getSemaphoreName() != null && filter.getSemaphoreName().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("semaphoreName");
			paramFilter.setOp(Operator.like);
			paramFilter.setValue(filter.getSemaphoreName().trim().toUpperCase().replaceAll("[*]",
					"%").replaceAll("[?]", "_"));
			filters.add(paramFilter);
		}
		if (filter.getDescription() != null && filter.getDescription().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("description");
			paramFilter.setOp(Operator.like);
			paramFilter.setValue(filter.getDescription().trim().toUpperCase()
					.replaceAll("[*]", "%").replaceAll("[?]", "_"));
			filters.add(paramFilter);
		}
		if (filter.getName() != null && filter.getName().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("name");
			paramFilter.setOp(Operator.like);
			paramFilter.setValue(filter.getName().trim().toUpperCase().replaceAll("[*]", "%")
					.replaceAll("[?]", "_"));
			filters.add(paramFilter);
		}
	}

	public void add() {
		newGroup = new ProcessGroup();
		newGroup.setLang(userLang);
		curMode = NEW_MODE;
	}

	public void edit() {
		try {
			newGroup = (ProcessGroup) _activeGroup.clone();
		} catch (CloneNotSupportedException e) {
			logger.error("", e);
			newGroup = _activeGroup;
		}
		newGroup.setLang(curLang);
		curMode = EDIT_MODE;
	}

	public void save() {
		try {
			if (isNewMode()) {
				newGroup = _processDao.addProcessGroup(userSessionId, newGroup);
				_itemSelection.addNewObjectToList(newGroup);
			} else if (isEditMode()) {
				newGroup = _processDao.modifyProcessGroup(userSessionId, newGroup);
				_groupsSource.replaceObject(_activeGroup, newGroup);
			}
			_activeGroup = newGroup;
			setInfo();
			curMode = VIEW_MODE;
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void delete() {
		try {
			_processDao.deleteProcessGroup(userSessionId, _activeGroup);
			_activeGroup = _itemSelection.removeObjectFromList(_activeGroup);
			if (_activeGroup == null) {
				clearState();
			} else {
				setInfo();
			}
			curMode = VIEW_MODE;
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void close() {
		curMode = VIEW_MODE;
	}

	public ProcessGroup getNewGroup() {
		if (newGroup == null) {
			newGroup = new ProcessGroup();
		}
		return newGroup;
	}

	public void setNewGroup(ProcessGroup newGroup) {
		this.newGroup = newGroup;
	}

	public String getBackLink() {
		return backLink;
	}

	public void setBackLink(String backLink) {
		this.backLink = backLink;
	}

	public void viewGroup() {
		groupBean.setGroup(_activeGroup);
		groupBean.setSelectMode(false);
	}

	public void changeLanguage(ValueChangeEvent event) {
		curLang = (String) event.getNewValue();

		List<Filter> filtersList = new ArrayList<Filter>();

		Filter paramFilter = new Filter();
		paramFilter.setElement("id");
		paramFilter.setOp(Operator.eq);
		paramFilter.setValue(_activeGroup.getId().toString());
		filtersList.add(paramFilter);

		paramFilter = new Filter();
		paramFilter.setElement("lang");
		paramFilter.setOp(Operator.eq);
		paramFilter.setValue(curLang);
		filtersList.add(paramFilter);

		filters = filtersList;
		SelectionParams params = new SelectionParams();
		params.setFilters(filters.toArray(new Filter[filters.size()]));
		try {
			ProcessGroup[] groups = _processDao.getProcessGroups(userSessionId, params);
			if (groups != null && groups.length > 0) {
				_activeGroup = groups[0];
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public Integer getProcessId() {
		return processId;
	}

	public void setProcessId(Integer processId) {
		this.processId = processId;
	}
	
	public void addProcessToGroup() {
		this.processId = null;
	}

	public List<SelectItem> getProcessesToAdd() {
		if (_activeGroup != null &&
				_activeGroup.getId() != null){
			List<SelectItem> items = new ArrayList<SelectItem>();
			ArrayList<String> where = new ArrayList<String>(1);
			where.add(new String("group_id is null or group_id !="
					+ _activeGroup.getId()));
			items = getDictUtils().getLov(
					LovConstants.PROCESSES_AND_GROUPS, null, where);
		
			return items;
		}else{
			return new ArrayList<SelectItem>();
		}
	}

	public String addProcess() {
		try {
			_processDao.addProcessToGroup(userSessionId, _activeGroup.getId(), processId);

			MbProcessesSearch processesBean = (MbProcessesSearch) ManagedBeanWrapper
					.getManagedBean("MbProcessesSearch");
			ProcessBO filterProcess = new ProcessBO();
			filterProcess.setGroupId(_activeGroup.getId());
			filterProcess.setLang(userLang);
			processesBean.setFilter(filterProcess);
			processesBean.search();
		} catch (DataAccessException ee) {
			FacesUtils.addMessageError(ee);
			logger.error("", ee);
		}
		return backLink;
	}
	
	public void confirmEditLanguage() {
		Filter[] filters = new Filter[2];
		filters[0] = new Filter();
		filters[0].setElement("id");
		filters[0].setValue(newGroup.getId());
		filters[1] = new Filter();
		filters[1].setElement("lang");
		filters[1].setValue(newGroup.getLang());

		SelectionParams params = new SelectionParams();
		params.setFilters(filters);
		try {
			ProcessGroup[] groups = _processDao.getProcessGroups(userSessionId, params);
			if (groups != null && groups.length > 0) {
				newGroup = groups[0];
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public String getComponentId() {
		return COMPONENT_ID;
	}

	public Logger getLogger() {
		return logger;
	}
	
	public String getSectionId() {
		return SectionIdConstants.ADMIN_PROCESS_GROUP;
	}
	
	public String getTabName() {
		return tabName;
	}

	public void setTabName(String tabName) {
		this.tabName = tabName;
		if (tabName.equalsIgnoreCase("PROCESSESTAB")) {
			MbProcessesSearch processBean = (MbProcessesSearch) ManagedBeanWrapper.getManagedBean("MbProcessesSearch");
			processBean.setTabName(tabName);
			processBean.setParentSectionId(getSectionId());
			processBean.setTableState(getSateFromDB(processBean.getComponentId()));
		}
	}

}
