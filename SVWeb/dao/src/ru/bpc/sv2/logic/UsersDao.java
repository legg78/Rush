package ru.bpc.sv2.logic;

import com.ibatis.sqlmap.client.SqlMapSession;
import org.apache.log4j.Logger;
import ru.bpc.sv2.acm.AcmPrivConstants;
import ru.bpc.sv2.administrative.users.User;
import ru.bpc.sv2.administrative.users.UserPrivConstants;
import ru.bpc.sv2.common.CommonParamRec;
import ru.bpc.sv2.filters.SectionFilter;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.controller.CommonController;
import ru.bpc.sv2.logic.utility.db.IbatisAware;
import ru.bpc.sv2.logic.utility.db.IbatisSessionCallback;
import ru.bpc.sv2.orgstruct.Agent;
import ru.bpc.sv2.orgstruct.Institution;
import ru.bpc.sv2.orgstruct.OrgStructType;
import ru.bpc.sv2.utils.AuditParamUtil;
import ru.bpc.sv2.utils.KeyLabelItem;
import ru.bpc.sv2.utils.UserException;

import ru.bpc.sv2.logic.utility.db.DataAccessException;

import java.math.BigDecimal;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Session Bean implementation class Cycles
 */
public class UsersDao extends IbatisAware {
	private static final Logger logger = Logger.getLogger("ACCESS_MANAGEMENT");


	public User getCurrentUserInfo(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSession(userSessionId);
			User user = (User) ssn.queryForObject("users.get-users", convertQueryParams(params));
			return user;
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public User[] getUsers(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, UserPrivConstants.VIEW_USER, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, UserPrivConstants.VIEW_USER);
			List<User> users = ssn.queryForList("users.get-users", convertQueryParams(params, limitation));

			return users.toArray(new User[users.size()]);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	public int getUsersCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, UserPrivConstants.VIEW_USER, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, UserPrivConstants.VIEW_USER);
			return (Integer) ssn
					.queryForObject("users.get-users-count", convertQueryParams(params, limitation));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public User[] getUsersByPriv(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, UserPrivConstants.VIEW_USER, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, UserPrivConstants.VIEW_USER);
			List<User> users = ssn.queryForList("users.get-users-by-priv",
					convertQueryParams(params, limitation));

			return users.toArray(new User[users.size()]);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public int getUsersByPrivCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, UserPrivConstants.VIEW_USER, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, UserPrivConstants.VIEW_USER);
			return (Integer) ssn.queryForObject("users.get-users-by-priv-count",
					convertQueryParams(params, limitation));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public User createUser(Long userSessionId, User user) {
		SqlMapSession ssn = null;

		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(user.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, UserPrivConstants.ADD_NEW_USER, paramArr);
			user.setForce(false);
			ssn.insert("roles.add-new-user", user);

			Filter[] filters = new Filter[1];
			filters[0] = new Filter();
			filters[0].setElement("id");
			filters[0].setValue(user.getId().toString());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (User) ssn.queryForObject("users.get-users", convertQueryParams(params));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public User blockUser(Long userSessionId, Integer id) {
		SqlMapSession ssn = null;

		try {
			ssn = getIbatisSession(userSessionId, null, UserPrivConstants.BLOCK_USER, null);

			ssn.update("roles.block-user", id);

			Filter[] filters = new Filter[1];
			filters[0] = new Filter();
			filters[0].setElement("id");
			filters[0].setValue(id.toString());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (User) ssn.queryForObject("users.get-users", convertQueryParams(params));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			flushReusedSessionCache(userSessionId);
			close(ssn);
		}
	}


	public User unblockUser(Long userSessionId, Integer id) {
		SqlMapSession ssn = null;

		try {
			ssn = getIbatisSession(userSessionId, null, UserPrivConstants.UNBLOCK_USER, null);
			ssn.update("roles.unblock-user", id);

			Filter[] filters = new Filter[1];
			filters[0] = new Filter();
			filters[0].setElement("id");
			filters[0].setValue(id.toString());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (User) ssn.queryForObject("users.get-users", convertQueryParams(params));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			flushReusedSessionCache(userSessionId);
			close(ssn);
		}
	}


	public void changeUserAuthScheme(Long userSessionId, final Integer userId, final String authScheme) {
		executeWithSession(userSessionId, UserPrivConstants.CHANGE_USER_AUTH_SCHEME, (CommonParamRec[]) null, logger, new IbatisSessionCallback<Object>() {
			@Override
			public Object doInSession(SqlMapSession ssn) throws Exception {
				Map<String, Object> params = new HashMap<>();
				params.put("userId", userId);
				params.put("authScheme", authScheme);
				ssn.update("roles.change-user-auth-scheme", params);
				return null;
			}
		});
	}


	public void setPassword(Long userSessionId, String username, String oldPassword, String newPassword) {
		setPassword(userSessionId, username, oldPassword, newPassword, false);
	}


	public void setPassword(Long userSessionId, String username, String oldPassword, String newPassword, boolean forceReset) {
		SqlMapSession ssn = null;

		try {
			if (userSessionId == null && forceReset) {
				ssn = getIbatisSessionNoContext();
			}
			else {
				ssn = getIbatisSession(userSessionId, null, UserPrivConstants.CHANGE_PASSWORD, null);
			}
			HashMap<String, String> map = new HashMap<String, String>();
			map.put("username", username);
			map.put("oldPassword", oldPassword);
			map.put("newPassword", newPassword);

			ssn.update("roles.set-password", map);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public String getPassword(Long userSessionId, String username) {
		SqlMapSession ssn = null;

		try {
			if (userSessionId == null) {
				ssn = getIbatisSessionNoContext();
			} else {
				ssn = getIbatisSession(userSessionId, null, null, null);
			}
			HashMap<String, String> map = new HashMap<String, String>();
			map.put("username", username);

			return (String) ssn.queryForObject("roles.get-password", map);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void addInstsToUser(Long userSessionId, User user, Institution[] insts) {
		SqlMapSession ssn = null;

		try {
			ssn = getIbatisSession(userSessionId, null, UserPrivConstants.ADD_INST_TO_USER, null);

			HashMap<String, Object> map = new HashMap<String, Object>();
			map.put("userId", user.getId());
			map.put("id", new Integer(0));
			for (Institution inst : insts) {
				System.out.println("inst: " + inst.getName() + "; entirely: "
						+ inst.isEntirelyForUser());
				map.put("objectId", inst.getId());
				map.put("isEntirely", inst.isEntirelyForUser());
				map.put("force", true);
				if (inst.isAssignedToUser())
					ssn.update("roles.add-inst-to-user", map);
				else
					ssn.update("roles.remove-inst-from-user", map);
			}
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void assignInstToUser(Long userSessionId, User user, Institution inst) throws UserException {
		SqlMapSession ssn = null;

		try {
			HashMap<String, Object> map = new HashMap<String, Object>();
			map.put("userId", user.getId());
			map.put("id", new Integer(0));
			System.out.println("inst: " + inst.getName() + "; entirely: "
					+ inst.isEntirelyForUser());
			map.put("objectId", inst.getId());
			map.put("isEntirely", inst.isEntirelyForUser());
			map.put("force", true);

			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(map);
			ssn = getIbatisSession(userSessionId, null, UserPrivConstants.ADD_INST_TO_USER, paramArr);

			if (inst.isAssignedToUser())
				ssn.update("roles.add-inst-to-user", map);
			else
				ssn.update("roles.remove-inst-from-user", map);
		} catch (SQLException e) {
			if (e.getErrorCode() >= 20000 && e.getErrorCode() <= 20999) {
				throw new UserException(e.getCause().getMessage());
			} else {
				throw createDaoException(e);
			}
		} finally {
			close(ssn);
		}
	}


	public void setUserDefaultInst(Long userSessionId, User user, Long instId) {
		SqlMapSession ssn = null;

		try {
			HashMap<String, Object> map = new HashMap<String, Object>();
			map.put("userId", user.getId());
			map.put("instId", instId);

			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(map);
			ssn = getIbatisSession(userSessionId, null, UserPrivConstants.SET_USER_DEFAULT_INST, paramArr);

			ssn.update("roles.set-user-default-inst", map);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			flushReusedSessionCache(userSessionId);
			close(ssn);
		}
	}


	public void addAgentsToUser(Long userSessionId, User user, Agent[] agents) {
		SqlMapSession ssn = null;

		try {
			ssn = getIbatisSession(userSessionId, null, UserPrivConstants.ADD_AGENT_TO_USER, null);
			HashMap<String, Object> map = new HashMap<String, Object>();
			map.put("userId", user.getId());
			map.put("id", new Integer(0));
			for (Agent agent : agents) {
				map.put("objectId", agent.getId());
				map.put("isDefault", agent.isDefaultForUser());
				map.put("force", true);
				if (agent.isAssignedToUser())
					ssn.update("roles.add-agent-to-user", map);
				else
					ssn.update("roles.remove-agent-from-user", map);

			}
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public Institution[] getInstitutionsForUser(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, UserPrivConstants.VIEW_USER_INST, paramArr);

			List<Institution> insts;

			insts = ssn.queryForList("roles.get-all-insts-for-user", convertQueryParams(params));

			return insts.toArray(new Institution[insts.size()]);
		} catch (SQLException e) {
			throw new DataAccessException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public Agent[] getAgentsForUser(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, UserPrivConstants.VIEW_USER_AGENT, paramArr);

			List<Agent> insts;

			insts = ssn.queryForList("roles.get-all-agents-for-user", convertQueryParams(params));

			return insts.toArray(new Agent[insts.size()]);
		} catch (SQLException e) {
			throw new DataAccessException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public List<User> getUsersByRole(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, UserPrivConstants.VIEW_USER, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, UserPrivConstants.VIEW_USER);
			List<User> users = ssn.queryForList("users.get-users-by-role",
					convertQueryParams(params, limitation));

			return users;
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public String getUserLanguage(Long userSessionId) {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSession(userSessionId);
			return (String) ssn.queryForObject("users.get-user-language");
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public Integer getUserDefaultInst(Long userSessionId) {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSession(userSessionId);
			return (Integer) ssn.queryForObject("users.get-user-inst");
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public String getUserDatePattern(Long userSessionId) {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSession(userSessionId);
			return (String) ssn.queryForObject("users.get-user-date-pattern");
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public String getUserTimePattern(Long userSessionId) {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSession(userSessionId);
			return (String) ssn.queryForObject("users.get-user-time-pattern");
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public OrgStructType[] getStructTypesForUser(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, UserPrivConstants.VIEW_USER_INST, paramArr);

			List<OrgStructType> insts = ssn.queryForList("roles.get-insts-for-user", convertQueryParams(params));

			Filter[] baseFilters = params.getFilters();

			for (int i = 0; i < insts.size(); i++) {
				if (!insts.get(i).isAgent()) {
					int length = baseFilters.length;
					Filter[] filters = new Filter[length + 1];
					// save old filters
					for (int j = 0; j < length; j++) {
						filters[j] = baseFilters[j];
					}
					// add new one
					filters[length] = new Filter();
					filters[length].setElement("instId");
					filters[length].setValue(insts.get(i).getId());

					params.setFilters(filters);
					// get all agents of current institution granted to user
					List<OrgStructType> agents = ssn.queryForList("roles.get-agents-for-user",
							convertQueryParams(params));

					// add agents to institutions list to show them in one table
					int j = 0;
					boolean isDefault = insts.get(i).isDefaultForUser();
					int idAgent = -1;
					boolean isDefaultUser = false;
					for (OrgStructType agent : agents) {
						// put agent right after its parent institution
						isDefaultUser = agent.isDefaultForUser();
						if (agent.isDefaultForInst()) {
							idAgent = j;
						}
						insts.add(insts.indexOf(insts.get(i)) + j++ + 1, agent);
					}
					if (isDefault && isDefaultUser && idAgent >= 0) {
						agents.get(idAgent).setDefaultAgent(agents.get(idAgent).isDefaultForInst());
					}
					i += j; // update index to not to read just added agents;
				}

			}

			return insts.toArray(new OrgStructType[insts.size()]);
		} catch (SQLException e) {
			throw new DataAccessException(e);
		} finally {
			close(ssn);
		}
	}

	public Boolean getRootUser(Long userSessionId) {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSession(userSessionId, null, UserPrivConstants.VIEW_ROOT_USER, null);
			int count = (Integer) ssn.queryForObject("roles.get-root-user");

			if (count > 0) {
				return true;
			}

			return false;
		} catch (SQLException e) {
			throw new DataAccessException(e);
		} finally {
			close(ssn);
		}
	}


	public void setSessionLastUse(Long userSessionId, String userName) {
		SqlMapSession ssn = null;

		try {
			if (userSessionId != null) {
				ssn = getIbatisSession(userSessionId, userName);
			} else {
				ssn = getIbatisSessionNoContext();
			}
			ssn.update("users.set-session-last-use");
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public SectionFilter[] getSectionFilters(Long userSessionId, Integer sectionId) {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSession(userSessionId, null, AcmPrivConstants.VIEW_FILTER, null);

			List<SectionFilter> filters = ssn.queryForList("users.get-section-filters", sectionId);

			return filters.toArray(new SectionFilter[filters.size()]);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public SectionFilter[] getUserSectionsFilters(Long userSessionId) {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSession(userSessionId, null, AcmPrivConstants.VIEW_FILTER, null);

			List<SectionFilter> filters = ssn.queryForList("users.get-user-sections-filters");

			return filters.toArray(new SectionFilter[filters.size()]);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public KeyLabelItem[] getSectionFilterRecords(Long userSessionId, Integer filterId) {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSession(userSessionId, null, UserPrivConstants.VIEW_FILTER_RECORD, null);

			List<KeyLabelItem> recs = ssn.queryForList("users.get-section-filter-records", filterId);

			return recs.toArray(new KeyLabelItem[recs.size()]);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void addSectionFilter(Long userSessionId, SectionFilter filter) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(filter.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, AcmPrivConstants.ADD_FILTER, paramArr);

			ssn.update("users.add-filter", filter);
			ssn.update("users.modify-filter-records", filter);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void modifySectionFilterRecs(Long userSessionId, SectionFilter filter) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(filter.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, UserPrivConstants.MODIFY_FILTER_RECORD, paramArr);

			ssn.update("users.modify-filter-records", filter);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void removeSectionFilter(Long userSessionId, SectionFilter filter) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(filter.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, AcmPrivConstants.REMOVE_FILTER, paramArr);

			ssn.update("users.remove-filter", filter);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void modifySectionFilter(Long userSessionId, SectionFilter filter) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(filter.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, AcmPrivConstants.MODIFY_FILTER, paramArr);

			ssn.update("users.modify-filter", filter);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public String getUserArticleFormat(Long userSessionId) {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSession(userSessionId);
			return (String) ssn.queryForObject("users.get-user-article-format");
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public Integer getUserDefaultAgent(Long userSessionId) {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSession(userSessionId);
			return (Integer) ssn.queryForObject("users.get-user-agent");
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public Agent[] getAgentsForUserFlat(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, UserPrivConstants.VIEW_USER_AGENT, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, UserPrivConstants.VIEW_USER_AGENT);
			List<Agent> result = ssn.queryForList("roles.get-agents-for-user-flat",
					convertQueryParams(params, limitation));
			return result.toArray(new Agent[result.size()]);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public Integer getDefaultUserAgent(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, UserPrivConstants.VIEW_USER_AGENT, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, UserPrivConstants.VIEW_USER_AGENT);
			Integer agentId = (Integer) ssn.queryForObject("roles.get-default-user-agent", convertQueryParams(params, limitation));
			return agentId;
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public User createUser(Long userSessionId, User user, Long instId) throws UserException {
		SqlMapSession ssn = null;

		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(user.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, UserPrivConstants.ADD_NEW_USER, paramArr);
			user.setForce(false);
			Map<String, Object> parametrs = new HashMap<String, Object>();
			parametrs.put("userName", user.getName());
			parametrs.put("userId", user.getId());
			parametrs.put("personId", user.getPersonId());
			parametrs.put("instId", instId);
			parametrs.put("password", user.getPassword());
			parametrs.put("passwordChangeNeeded", user.isPasswordChangeNeeded());
			parametrs.put("authScheme", user.getAuthScheme());
			ssn.update("roles.add-new-user-with-inst", parametrs);
			user.setId(((BigDecimal) parametrs.get("userId")).intValue());

			Filter[] filters = new Filter[1];
			filters[0] = new Filter();
			filters[0].setElement("id");
			filters[0].setValue(user.getId().toString());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			User newUser = (User) ssn.queryForObject("users.get-users", convertQueryParams(params));
			if (newUser == null && !instId.toString().equals("9999")) {
				return user;
			}

			return newUser;
		} catch (SQLException e) {
			//if (e.getErrorCode() >= 20000 && e.getErrorCode() <= 20999) {
			//	throw new UserException(e.getCause().getMessage());
			//} else {
			throw createDaoException(e);
			//}
		} finally {
			close(ssn);
		}
	}


	public boolean isUserActive(String userName) {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSessionNoContext();
			Number result = (Number) ssn.queryForObject("users.get-user-is-active", userName);
			return result != null && result.intValue() == 1;
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void avoidExpireDate(Long userSessionId, User user) throws UserException {
		SqlMapSession ssn = null;

		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(user.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, UserPrivConstants.ADD_NEW_USER, paramArr);
			ssn.update("users.avoid-expire-date", user);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public Long[] getActiveSessionsIdByUser(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSession(userSessionId);
			List<Long> sessions = ssn.queryForList("users.get-active-user-sessions", convertQueryParams(params));
			return sessions.toArray(new Long[sessions.size()]);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public String getUserAuthScheme(Long userSessionId, String username) {
		SqlMapSession ssn = null;
		try {
			if (userSessionId != null) {
				ssn = getIbatisSession(userSessionId);
			} else {
				ssn = getIbatisSessionNoContext();
			}
			return (String) ssn.queryForObject("users.get-user-auth-scheme", username);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void modifyUserInstData(Long userSessionId, final List<Institution> institutions) {
		executeWithSession(userSessionId,
						   UserPrivConstants.ADD_INST_TO_USER,
						   logger,
						   new IbatisSessionCallback<Void>() {
			@Override
			public Void doInSession(SqlMapSession ssn) throws Exception {
				Map<String, Object> map = new HashMap<String, Object>(2);
				map.put("tabName", "USER_INST");
				map.put("userData", institutions);
				ssn.update("users.modify-user-data", map);
				return null;
			}
		});
	}


	public void modifyUserAgentData(Long userSessionId, final List<Agent> agents) {
		executeWithSession(userSessionId,
						   UserPrivConstants.ADD_AGENT_TO_USER,
						   logger,
						   new IbatisSessionCallback<Void>() {
			@Override
			public Void doInSession(SqlMapSession ssn) throws Exception {
				Map<String, Object> map = new HashMap<String, Object>(2);
				map.put("tabName", "USER_AGENT");
				map.put("userData", agents);
				ssn.update("users.modify-user-data", map);
				return null;
			}
		});
	}


	public User getUserById(Long userSessionId, final Long userId) {
		return executeWithSession(userSessionId,
						   UserPrivConstants.VIEW_USER,
						   logger,
						   new IbatisSessionCallback<User>() {
			@Override
			public User doInSession(SqlMapSession ssn) throws Exception {
				List<Filter> filters = new ArrayList<Filter>(1);
				filters.add(Filter.create("id", userId));
				SelectionParams params = new SelectionParams(filters);
				List<User> users = ssn.queryForList("users.get-users", convertQueryParams(params));
				return (users != null && users.size() > 0) ? users.get(0) : null;
			}
		});
	}


	public String getGroupSeparator(Long userSessionId) {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSession(userSessionId);
			return (String) ssn.queryForObject("users.get-user-group-separator");
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	public void resetLockout(Long userSessionId, final User user) {
		executeWithSession(userSessionId,
						   UserPrivConstants.CHANGE_PASSWORD,
						   AuditParamUtil.getCommonParamRec(user.getAuditParameters()),
						   logger,
						   new IbatisSessionCallback<Void>() {
			@Override
			public Void doInSession(SqlMapSession ssn) throws Exception {
				ssn.update("users.reset-lockout", user);
				return null;
			}
		});
	}


	public List<Integer> getUserInstitionIds(Long userSessionId, final int userId) {
		return executeWithSession(userSessionId,
				UserPrivConstants.VIEW_USER,
				logger,
				new IbatisSessionCallback<List<Integer>>() {
					@Override
					public List<Integer> doInSession(SqlMapSession ssn) throws Exception {
						Map<String, Object> map = new HashMap<String, Object>();
						map.put("userId", userId);
						return ssn.queryForList("users.get-user-inst-ids", map);
					}
				});
	}
}
