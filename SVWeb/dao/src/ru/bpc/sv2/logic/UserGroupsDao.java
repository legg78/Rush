package ru.bpc.sv2.logic;

import com.ibatis.sqlmap.client.SqlMapSession;
import org.apache.log4j.Logger;
import ru.bpc.sv2.administrative.groups.Group;
import ru.bpc.sv2.administrative.users.User;
import ru.bpc.sv2.administrative.users.UserPrivConstants;
import ru.bpc.sv2.common.CommonPrivConstants;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.controller.CommonController;
import ru.bpc.sv2.logic.utility.db.IbatisAware;
import ru.bpc.sv2.logic.utility.db.IbatisSessionCallback;
import ru.bpc.sv2.utils.AuditParamUtil;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class UserGroupsDao extends IbatisAware {
	private static final Logger logger = Logger.getLogger("ACCESS_MANAGEMENT");

	public List<Group> getGroups(Long userSessionId, final SelectionParams params) {
		return executeWithSession(userSessionId,
				CommonPrivConstants.VIEW_USER_GROUPS,
				params,
				logger,
				new IbatisSessionCallback<List<Group>>() {
					@Override
					public List<Group> doInSession(SqlMapSession ssn) throws Exception {
						String limitation = CommonController.getLimitationByPriv(ssn, CommonPrivConstants.VIEW_USER_GROUPS);
						return ssn.queryForList("userGroups.get-groups", convertQueryParams(params, limitation));
					}
				});
	}

	public int getGroupsCount(Long userSessionId, final SelectionParams params) {
		return executeWithSession(userSessionId,
				CommonPrivConstants.VIEW_USER_GROUPS,
				params,
				logger,
				new IbatisSessionCallback<Integer>() {
					@Override
					public Integer doInSession(SqlMapSession ssn) throws Exception {
						String limitation = CommonController.getLimitationByPriv(ssn, CommonPrivConstants.VIEW_USER_GROUPS);
						return (Integer) ssn.queryForObject("userGroups.get-groups-count", convertQueryParams(params, limitation));
					}
				});
	}

	public void addGroup(Long userSessionId, final Group group) {
		executeWithSession(userSessionId,
				CommonPrivConstants.MODIFY_USER_GROUPS,
				AuditParamUtil.getCommonParamRec(group.getAuditParameters()),
				logger,
				new IbatisSessionCallback<Void>() {
					@Override
					public Void doInSession(SqlMapSession ssn) throws Exception {
						ssn.update("userGroups.add-group", group);
						return null;
					}
				});

	}

	public void modifyGroup(Long userSessionId, final Group group) {
		executeWithSession(userSessionId,
				CommonPrivConstants.MODIFY_USER_GROUPS,
				AuditParamUtil.getCommonParamRec(group.getAuditParameters()),
				logger,
				new IbatisSessionCallback<Void>() {
					@Override
					public Void doInSession(SqlMapSession ssn) throws Exception {
						ssn.update("userGroups.modify-group", group);
						return null;
					}
				});
	}

	public void attachUser(Long userSessionId, final int groupId, final int userId) {
		executeWithSession(userSessionId,
				CommonPrivConstants.MODIFY_USER_GROUPS,
				logger,
				new IbatisSessionCallback<Void>() {
					@Override
					public Void doInSession(SqlMapSession ssn) throws Exception {
						Map<String, Integer> map = new HashMap<String, Integer>();
						map.put("groupId", groupId);
						map.put("userId", userId);
						ssn.update("userGroups.attach-user", map);
						return null;
					}
				});
	}

	public void detachUser(Long userSessionId, final int groupId, final int userId) {
		executeWithSession(userSessionId,
				CommonPrivConstants.MODIFY_USER_GROUPS,
				logger,
				new IbatisSessionCallback<Void>() {
					@Override
					public Void doInSession(SqlMapSession ssn) throws Exception {
						Map<String, Integer> map = new HashMap<String, Integer>();
						map.put("groupId", groupId);
						map.put("userId", userId);
						ssn.update("userGroups.detach-user", map);
						return null;
					}
				});
	}

	@SuppressWarnings("unchecked")
	public List<User> getUsersByGroup(Long userSessionId, final SelectionParams params) {
		return executeWithSession(userSessionId,
				UserPrivConstants.VIEW_USER,
				params,
				logger,
				new IbatisSessionCallback<List<User>>() {
					@Override
					public List<User> doInSession(SqlMapSession ssn) throws Exception {
						String limitation = CommonController.getLimitationByPriv(ssn, UserPrivConstants.VIEW_USER);
						return ssn.queryForList("userGroups.get-users-by-group", convertQueryParams(params, limitation));
					}
				});
	}

	@SuppressWarnings("unchecked")
	public List<Group> getGroupsByUser(Long userSessionId, final SelectionParams params) {
		return executeWithSession(userSessionId,
				CommonPrivConstants.VIEW_USER_GROUPS,
				params,
				logger,
				new IbatisSessionCallback<List<Group>>() {
					@Override
					public List<Group> doInSession(SqlMapSession ssn) throws Exception {
						String limitation = CommonController.getLimitationByPriv(ssn, CommonPrivConstants.VIEW_USER_GROUPS);
						return ssn.queryForList("userGroups.get-groups-by-user", convertQueryParams(params, limitation));
					}
				});
	}
}
