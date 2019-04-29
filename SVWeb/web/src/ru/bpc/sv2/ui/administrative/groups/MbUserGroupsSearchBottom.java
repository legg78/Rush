package ru.bpc.sv2.ui.administrative.groups;

import org.apache.commons.lang3.StringUtils;
import org.apache.log4j.Logger;
import ru.bpc.sv2.administrative.groups.Group;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.FilterBuilder;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.UserGroupsDao;
import ru.bpc.sv2.ui.utils.AbstractSearchAllBean;
import ru.bpc.sv2.ui.utils.AbstractSearchBean;
import ru.bpc.sv2.ui.utils.FacesUtils;

import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.model.SelectItem;
import java.util.*;

@ViewScoped
@ManagedBean(name = "MbUserGroupsSearchBottom")
public class MbUserGroupsSearchBottom extends AbstractSearchAllBean<Group, Group> {
	private static final long serialVersionUID = 1L;
	private static final Logger logger = Logger.getLogger("ACCESS_MANAGEMENT");

	private static final int GROUPS_LOV_ID = LovConstants.USER_GROUPS;

	private Integer userId;

	private List<Integer> instIds;

	private Group newItem;

	private UserGroupsDao userGroupsDao = new UserGroupsDao();

	private String parentSectionId;

	public static String COMPONENT_ID = "bottomUserGroupsForm";

	@Override
	public String getComponentId() {
		return parentSectionId + ":" + COMPONENT_ID;
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
		map.put("userId", getUserId());
		map.putAll(FilterBuilder.createMapFromBean(filter));
		filters.addAll(FilterBuilder.createFiltersAsString(map));
	}

	@Override
	protected List<Group> getObjectList(Long userSessionId, SelectionParams params) {
		return userGroupsDao.getGroupsByUser(userSessionId, params);
	}

	@Override
	public void clearFilter() {
		super.clearFilter();
		userId = null;
		instIds = null;
	}

	public void setParentSectionId(String parentSectionId) {
		this.parentSectionId = parentSectionId;
	}

	public String getParentSectionId() {
		return parentSectionId;
	}

	public void detachUser() {
		try {
			if (activeItem == null) {
				return;
			}
			userGroupsDao.detachUser(userSessionId, activeItem.getId(), getUserId());
			getDataModel().removeObjectFromList(activeItem);
		} catch(Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void attachUser() {
		try {
			if (getNewItem().getId() == null) {
				return;
			}
			userGroupsDao.attachUser(userSessionId, getNewItem().getId(), getUserId());
			getDataModel().flushCache();
			newItem = null;
		} catch(Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}


	public List<SelectItem> getGroups() {
		if(userId == null) {
			return Collections.emptyList();
		}
		Set<Integer> set = new HashSet<Integer>();
		set.add(9999);
		if (instIds != null) {
			set.addAll(instIds);
		}
		String where = "INSTITUTION_ID in (" + StringUtils.join(set, ",") + ")";
		return getDictUtils().getLov(GROUPS_LOV_ID, null, Arrays.asList(where));
	}

	public Integer getUserId() {
		return userId;
	}

	public void setUserId(Integer userId) {
		this.userId = userId;
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


	public List<Integer> getInstIds() {
		return instIds;
	}

	public void setInstIds(List<Integer> instIds) {
		this.instIds = instIds;
	}
}
