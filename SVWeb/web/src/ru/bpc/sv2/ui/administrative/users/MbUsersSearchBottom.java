package ru.bpc.sv2.ui.administrative.users;

import org.apache.commons.lang3.StringUtils;
import org.apache.log4j.Logger;
import ru.bpc.sv2.administrative.users.User;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.FilterBuilder;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.UserGroupsDao;
import ru.bpc.sv2.logic.UsersDao;
import ru.bpc.sv2.ui.utils.AbstractSearchAllBean;

import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import java.util.*;

@ViewScoped
@ManagedBean(name = "MbUsersSearchBottom")
public class MbUsersSearchBottom extends AbstractSearchAllBean<User, User> {
	private static final long serialVersionUID = 1L;
	private static final Logger logger = Logger.getLogger("ACCESS_MANAGEMENT");
	public static String COMPONENT_ID = "bottomUsersForm";
	public static String ROLE_ID_FILTER = "roleId";
	public static String GROUP_ID_FILTER = "groupId";

	private String parentSectionId;
	private List<Filter> objectFilters;
	private UsersDao usersDao = new UsersDao();
	private UserGroupsDao userGroupsDao = new UserGroupsDao();

	@Override
	protected User createFilter() {
		return new User();
	}

	@Override
	protected Logger getLogger() {
		return logger;
	}

	@Override
	protected User addItem(User item) {
		return null;
	}

	@Override
	protected User editItem(User item) {
		return null;
	}

	@Override
	protected void deleteItem(User item) {

	}

	@Override
	protected void initFilters(User filter, List<Filter> filters) {
		Map<String, Object> map = new HashMap<>();
		map.put("lang", curLang);

		if (StringUtils.isNotBlank(filter.getStatus())) {
			map.put("status", filter.getStatus());
		}

		if (StringUtils.isNotBlank(filter.getName())) {
			map.put("name", filter.getName());
		}

		if (objectFilters != null) {
			filters.addAll(objectFilters);
		}

		filters.addAll(FilterBuilder.createFiltersAsString(map));
	}

	@Override
	protected List<User> getObjectList(Long userSessionId, SelectionParams params) {
		if (params.hasFilter(ROLE_ID_FILTER)) {
			return usersDao.getUsersByRole(userSessionId, params);
		} else if(params.hasFilter(GROUP_ID_FILTER)) {
			return userGroupsDao.getUsersByGroup(userSessionId, params);
		}
		return Collections.emptyList();
	}

	@Override
	public void clearFilter() {
		super.clearFilter();
		objectFilters = null;
	}

	public List<Filter> getObjectFilters() {
		return objectFilters;
	}

	public void setObjectFilters(List<Filter> objectFilters) {
		this.objectFilters = objectFilters;
	}

	public void addObjectFilter(Filter filter) {
		if (filter == null) {
			return;
		}
		if (objectFilters == null) {
			objectFilters = new ArrayList<>();
		}
		objectFilters.add(filter);
	}

	@Override
	public String getComponentId() {
		return parentSectionId + ":" + COMPONENT_ID;
	}

	public String getParentSectionId() {
		return parentSectionId;
	}

	public void setParentSectionId(String parentSectionId) {
		this.parentSectionId = parentSectionId;
	}
}
