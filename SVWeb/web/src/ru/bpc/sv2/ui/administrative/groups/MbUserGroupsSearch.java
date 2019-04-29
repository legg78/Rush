package ru.bpc.sv2.ui.administrative.groups;

import org.apache.log4j.Logger;
import ru.bpc.sv2.administrative.groups.Group;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.FilterBuilder;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.UserGroupsDao;
import ru.bpc.sv2.ui.administrative.users.MbUsersSearchBottom;
import ru.bpc.sv2.ui.utils.AbstractSearchTabbedBean;
import ru.bpc.sv2.ui.utils.FacesUtils;
import util.auxil.ManagedBeanWrapper;

import javax.annotation.PostConstruct;
import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@ViewScoped
@ManagedBean(name = "MbUserGroupsSearch")
public class MbUserGroupsSearch extends AbstractSearchTabbedBean<Group, Group> {
	private static final long serialVersionUID = 1L;
	private static final Logger logger = Logger.getLogger("ACCESS_MANAGEMENT");
	private static final String USERS_TAB = "usersTab";

	private UserGroupsDao userGroupsDao = new UserGroupsDao();

	private Group newItem;

	@Override
	@PostConstruct
	public void init() {
		super.init();
		pageLink = "admin|manage_groups|list_groups";
	}

	@Override
	protected Group createFilter() {
		return new Group();
	}

	@Override
	protected Logger getLogger() {
		return logger;
	}

	@Override
	protected Group addItem(Group item) {
		return null;
	}

	@Override
	protected Group editItem(Group item) {
		return null;
	}

	@Override
	protected void deleteItem(Group item) {

	}

	@Override
	protected void initFilters(Group filter, List<Filter> filters) {
		Map<String, Object> map = new HashMap<>();
		map.put("lang", curLang);

		map.putAll(FilterBuilder.createMapFromBean(filter));

		String name = (String) map.get("name");
		if (name != null) {
			name = Filter.mask(name);
			map.put("name", name);
		}

		filters.addAll(FilterBuilder.createFiltersAsString(map));
	}

	@Override
	protected List<Group> getObjectList(Long userSessionId, SelectionParams params) {
		return userGroupsDao.getGroups(userSessionId, params);
	}

	@Override
	protected int getObjectCount(Long userSessionId, SelectionParams params) {
		return userGroupsDao.getGroupsCount(userSessionId, params);
	}

	@Override
	protected void onLoadTab(String tabName) {
		if (USERS_TAB.equals(tabName)) {
			MbUsersSearchBottom usersSearchBottom = ManagedBeanWrapper.getManagedBean(MbUsersSearchBottom.class);
			usersSearchBottom.clearFilter();
			usersSearchBottom.setParentSectionId(getComponentId());
			usersSearchBottom.addObjectFilter(Filter.create(MbUsersSearchBottom.GROUP_ID_FILTER, activeItem.getId().toString()));
			usersSearchBottom.search();
		}
	}

	public void createGroup() {
		try {
			curMode = NEW_MODE;
			newItem = new Group();
		} catch(Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void editGroup() {
		try {
			curMode = EDIT_MODE;
			try {
				newItem = activeItem.clone();
			} catch (CloneNotSupportedException e) {
				newItem = activeItem;
				FacesUtils.addMessageError(e);
				logger.error("", e);
			}
		} catch(Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public Group getNewItem() {
		if (newItem == null) {
			newItem = new Group();
		}
		return newItem;
	}

	public void setNewItem(Group newItem) {
		this.newItem = newItem;
	}

	public void cancel() {
		curMode = VIEW_MODE;
	}

	public void saveGroup() {
		try {
			if (isNewMode()) {
				userGroupsDao.addGroup(userSessionId, newItem);
				activeItem = newItem.clone();
				tableRowSelection.addNewObjectToList(activeItem);
			} else {
				userGroupsDao.modifyGroup(userSessionId, newItem);
				dataModel.replaceObject(activeItem, newItem);
				activeItem = newItem;
			}
			curMode = VIEW_MODE;
		} catch (Exception ee) {
			FacesUtils.addMessageError(ee);
			logger.error("", ee);
		}
	}
}
