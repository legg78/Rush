package ru.bpc.sv2.logic;

import java.sql.SQLException;
import java.util.*;

import ru.bpc.sv2.logic.utility.db.DataAccessException;


import ru.bpc.sv2.administrative.roles.ComplexRole;
import ru.bpc.sv2.administrative.roles.Privilege;
import ru.bpc.sv2.administrative.roles.PrivilegeGroupNode;
import ru.bpc.sv2.administrative.roles.PrivilegeNode;
import ru.bpc.sv2.administrative.roles.RoleIdPrivilegeIdBind;
import ru.bpc.sv2.administrative.roles.RolePrivConstants;
import ru.bpc.sv2.common.CommonParamRec;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.controller.CommonController;
import ru.bpc.sv2.logic.utility.db.IbatisAware;
import ru.bpc.sv2.utils.AuditParamUtil;

import com.ibatis.sqlmap.client.SqlMapSession;
import ru.bpc.sv2.utils.UserException;

/**
 * Session Bean implementation class Roles
 */
public class RolesDao extends IbatisAware {

	@SuppressWarnings("unchecked")
	public ComplexRole[] getRoles(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, RolePrivConstants.VIEW_ROLE, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, RolePrivConstants.VIEW_ROLE);
			List<ComplexRole> roles = ssn.queryForList("roles.get-roles",
					convertQueryParams(params, limitation));

			return roles.toArray(new ComplexRole[roles.size()]);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public int getRolesCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, RolePrivConstants.VIEW_ROLE, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, RolePrivConstants.VIEW_ROLE);
			return (Integer) ssn
					.queryForObject("roles.get-roles-count", convertQueryParams(params, limitation));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public ComplexRole[] getRolesUnassignedToObject(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, RolePrivConstants.VIEW_ROLE, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, RolePrivConstants.VIEW_ROLE);
			List<ComplexRole> roles = ssn.queryForList("roles.get-roles-not-assigned-to-object",
					convertQueryParams(params, limitation));

			return roles.toArray(new ComplexRole[roles.size()]);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	// strange name :-/

	public int getRolesUnassignedToObjectCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, RolePrivConstants.VIEW_ROLE, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, RolePrivConstants.VIEW_ROLE);
			return (Integer) ssn.queryForObject("roles.get-roles-not-assigned-to-object-count",
					convertQueryParams(params, limitation));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public ComplexRole[] getRoleSubroles(Long userSessionId, SelectionParams params) {

		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, RolePrivConstants.VIEW_ROLE, paramArr);

			List<ComplexRole> roles;

			roles = ssn.queryForList("roles.get-role-subroles", convertQueryParams(params));

			return roles.toArray(new ComplexRole[roles.size()]);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public Privilege[] getRolePrivs(Long userSessionId, SelectionParams params) {

		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, RolePrivConstants.VIEW_ROLE_PRIVILEGE, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, RolePrivConstants.VIEW_ROLE_PRIVILEGE);
			List<Privilege> roles = ssn.queryForList("roles.get-role-privs",
					convertQueryParams(params, limitation));

			return roles.toArray(new Privilege[roles.size()]);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	public int getRolePrivsCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, RolePrivConstants.VIEW_ROLE_PRIVILEGE, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, RolePrivConstants.VIEW_ROLE_PRIVILEGE);
			return (Integer) ssn.queryForObject("roles.get-role-privs-count",
					convertQueryParams(params, limitation));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public Privilege[] getPrivs(Long userSessionId, SelectionParams params, boolean addPrivToRole) {

		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, RolePrivConstants.VIEW_PRIVILEGE, paramArr);

			List<Privilege> roles;
			String limitation = CommonController.getLimitationByPriv(ssn, RolePrivConstants.VIEW_PRIVILEGE);
			if (!addPrivToRole) {
				roles = ssn.queryForList("roles.get-privs", convertQueryParams(params, limitation));
			} else {
				roles = ssn.queryForList("roles.get-privs-not-assigned-to-role",
						convertQueryParams(params, limitation));
			}

			return roles.toArray(new Privilege[roles.size()]);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	public int getPrivsCount(Long userSessionId, SelectionParams params, boolean addPrivToRole) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, RolePrivConstants.VIEW_PRIVILEGE, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, RolePrivConstants.VIEW_PRIVILEGE);
			if (!addPrivToRole) {
				return (Integer) ssn.queryForObject("roles.get-privs-count",
						convertQueryParams(params, limitation));
			} else {
				return (Integer) ssn.queryForObject("roles.get-privs-not-assigned-to-role-count",
						convertQueryParams(params, limitation));
			}
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public Privilege addPrivilege(Long userSessionId, Privilege privilege) {
		SqlMapSession ssn = null;

		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(privilege.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, RolePrivConstants.ADD_PRIVILEGE, paramArr);
			ssn.insert("roles.add-privilege", privilege);

			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("id");
			filters[0].setValue(privilege.getId().toString());
			filters[1] = new Filter();
			filters[1].setElement("lang");
			filters[1].setValue(privilege.getLang());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (Privilege) ssn.queryForObject("roles.get-privs", convertQueryParams(params));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void removePrivilege(Long userSessionId, Integer privId) {
		SqlMapSession ssn = null;

		try {
			ssn = getIbatisSessionFE(userSessionId);
			ssn.delete("roles.remove-privilege", privId);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	public PrivilegeGroupNode getRoleSections(Long userSessionId) {
		SqlMapSession ssn = null;

		try {
			ssn = getIbatisSessionFE(userSessionId);

			PrivilegeGroupNode root = new PrivilegeGroupNode();
			root.setId(-1);
			root.setName("Root");

			return fillPrivilegeNode(ssn, root);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	private PrivilegeGroupNode fillPrivilegeNode(SqlMapSession ssn, PrivilegeGroupNode node)
			throws SQLException {
		// List<PrivilegeGroupNode> members = ssn.queryForList(
		// "roles.get-privilege-node-group-members", node.getId() );
		// node.getMembers().addAll( members );
		node.getMembers().addAll(Collections.EMPTY_LIST);
		List<PrivilegeNode> privileges = ssn.queryForList("roles.get-privilege-node-privileges",
				node.getId());
		node.getPrivileges().addAll(privileges);

		// for ( PrivilegeGroupNode subnode : node.getMembers() )
		// {
		// fillPrivilegeNode( ssn, subnode );
		// }

		return node;
	}

	public PrivilegeGroupNode getRoleSections(Long userSessionId, int role_id) {
		SqlMapSession ssn = null;

		try {
			ssn = getIbatisSessionFE(userSessionId);

			PrivilegeGroupNode root = new PrivilegeGroupNode();
			root.setId(-1);
			root.setName("Root");

			return fillPrivilegeNode(ssn, role_id, root);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	private PrivilegeGroupNode fillPrivilegeNode(SqlMapSession ssn, int role_id,
			PrivilegeGroupNode node) throws SQLException {
		RoleIdPrivilegeIdBind binding = new RoleIdPrivilegeIdBind();

		binding.roleId = role_id;
		binding.privilegeId = node.getId();

		// List<PrivilegeGroupNode> members = ssn.queryForList(
		// "roles.get-privilege-node-group-members-byrole", binding );
		// node.getMembers().addAll( members );
		node.getMembers().addAll(Collections.EMPTY_LIST);

		List<PrivilegeNode> privileges = ssn.queryForList(
				"roles.get-privilege-node-privileges-byrole", binding);
		node.getPrivileges().addAll(privileges);

		// for ( PrivilegeGroupNode subnode : node.getMembers() )
		// {
		// fillPrivilegeNode( ssn, role_id, subnode );
		// }
		//
		return node;
	}


	public ComplexRole createRole(Long userSessionId, ComplexRole role) {
		SqlMapSession ssn = null;

		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(role.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, RolePrivConstants.ADD_NEW_ROLE, paramArr);

			ssn.insert("roles.insert-new-role", role);

			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("id");
			filters[0].setValue(role.getId().toString());
			filters[1] = new Filter();
			filters[1].setElement("lang");
			filters[1].setValue(role.getLang());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (ComplexRole) ssn.queryForObject("roles.get-roles", convertQueryParams(params));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public ComplexRole updateRole(Long userSessionId, ComplexRole role) {
		SqlMapSession ssn = null;

		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(role.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, RolePrivConstants.EDIT_ROLE, paramArr);
			role.setForce(1);
			ssn.update("roles.update-existing-role", role);

			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("id");
			filters[0].setValue(role.getId().toString());
			filters[1] = new Filter();
			filters[1].setElement("lang");
			filters[1].setValue(role.getLang());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (ComplexRole) ssn.queryForObject("roles.get-roles", convertQueryParams(params));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void deleteRole(Long userSessionId, Integer roleId) {
		SqlMapSession ssn = null;

		try {
			ssn = getIbatisSessionFE(userSessionId);

			ssn.insert("roles.remove-role", roleId);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public ComplexRole[] getUserRoles(Long userSessionId, SelectionParams params) {

		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, RolePrivConstants.VIEW_USER_ROLE, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, RolePrivConstants.VIEW_USER_ROLE);
			List<ComplexRole> roles = ssn.queryForList("roles.get-user-roles",
					convertQueryParams(params, limitation));

			return roles.toArray(new ComplexRole[roles.size()]);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	public int getUserRolesCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, RolePrivConstants.VIEW_USER_ROLE, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, RolePrivConstants.VIEW_USER_ROLE);
			return (Integer) ssn.queryForObject("roles.get-user-roles-count",
					convertQueryParams(params, limitation));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void deleteUserRole(Long userSessionId, Integer userId, Integer roleId) {
		SqlMapSession ssn = null;

		try {
			ssn = getIbatisSession(userSessionId, null, RolePrivConstants.REMOVE_ROLE_FROM_USER, null);
			HashMap<String, Object> map = new HashMap<String, Object>();
			map.put("roleId", roleId);
			map.put("userId", userId);
			ssn.delete("roles.remove-role-from-user", map);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void addUserRole(Long userSessionId, Integer userId, Integer roleId) {
		SqlMapSession ssn = null;

		try {
			ssn = getIbatisSessionFE(userSessionId);
			HashMap<String, Object> map = new HashMap<String, Object>();
			map.put("objectId", userId);
			map.put("roleId", roleId);
			ssn.insert("roles.add-user-to-object", map);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void addRolesToUser(Long userSessionId, Integer userId, ComplexRole[] roles) throws UserException {
		SqlMapSession ssn = null;

		try {
			ssn = getIbatisSession(userSessionId, null, RolePrivConstants.ADD_ROLE_TO_USER, null);

			for (ComplexRole role : roles) {
				HashMap<String, Integer> map = new HashMap<String, Integer>();
				map.put("objectId", userId);
				map.put("roleId", role.getId());
				map.put("id", 0);
				ssn.insert("roles.add-role-to-user", map);
			}

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


	public void deleteRolesFromUser(Long userSessionId, Integer userId, ComplexRole[] roles) {
		SqlMapSession ssn = null;

		try {
			ssn = getIbatisSession(userSessionId, null, RolePrivConstants.REMOVE_ROLE_FROM_USER, null);

			for (ComplexRole role : roles) {
				HashMap<String, Integer> map = new HashMap<String, Integer>();
				map.put("userId", userId);
				map.put("roleId", role.getId());
				ssn.delete("roles.remove-role-from-user", map);
			}

		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void addPrivsToRole(Long userSessionId, Integer roleId, Privilege[] privs) {
		SqlMapSession ssn = null;

		try {
			ssn = getIbatisSession(userSessionId, null, RolePrivConstants.ADD_PRIV_TO_ROLE, null);

			for (Privilege priv : privs) {
				HashMap<String, Object> map = new HashMap<String, Object>();
				map.put("id", 0);
				map.put("roleId", roleId);
				map.put("privId", priv.getId());
				map.put("limitId", "");

				ssn.insert("roles.add-priv-to-role", map);
			}

		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void addSubrolesToRole(Long userSessionId, Integer roleId, ComplexRole[] subroles) {
		SqlMapSession ssn = null;

		try {
			ssn = getIbatisSession(userSessionId, null, RolePrivConstants.ADD_ROLE_TO_ROLE, null);

			for (ComplexRole role : subroles) {
				HashMap<String, Integer> map = new HashMap<String, Integer>();
				map.put("subroleId", role.getId());
				map.put("roleId", roleId);
				map.put("id", new Integer(0));
				ssn.insert("roles.add-subrole-to-role", map);
			}

		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void deletePrivsFromRole(Long userSessionId, Integer roleId, Privilege[] privs) {
		SqlMapSession ssn = null;

		try {
			ssn = getIbatisSession(userSessionId, null, RolePrivConstants.REMOVE_PRIV_FROM_ROLE, null);

			for (Privilege priv : privs) {
				HashMap<String, Object> map = new HashMap<String, Object>();
				map.put("roleId", roleId);
				map.put("privId", priv.getId());
				ssn.insert("roles.remove-priv-from-role", map);
			}

		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void deleteSubrolesFromRole(Long userSessionId, Integer roleId, ComplexRole[] subroles) {
		SqlMapSession ssn = null;

		try {
			ssn = getIbatisSession(userSessionId, null, RolePrivConstants.REMOVE_ROLE_FROM_ROLE, null);

			for (ComplexRole role : subroles) {
				HashMap<String, Integer> map = new HashMap<String, Integer>();
				map.put("subroleId", role.getId());
				map.put("roleId", roleId);
				ssn.insert("roles.remove-subrole-from-role", map);
			}

		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public Privilege[] getPrivsForCombo(Long userSessionId) {

		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSessionFE(userSessionId);

			List<Privilege> roles = ssn.queryForList("roles.get-privs-for-combo");

			return roles.toArray(new Privilege[roles.size()]);
		} catch (SQLException e) {
			throw new DataAccessException(e);
		} finally {
			close(ssn);
		}
	}


	public ComplexRole getRoleById(Long userSessionId, Integer roleId, String lang) {

		SqlMapSession ssn = null;
		try {
			ComplexRole role = new ComplexRole();
			role.setId(roleId);
			role.setLang(lang);
			
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(role.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, RolePrivConstants.VIEW_ROLE, paramArr);
			
			return (ComplexRole) ssn.queryForObject("roles.get-role-by-id", role);

		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public String[] getLanguagesByRole(Long userSessionId, ComplexRole role) {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSessionFE(userSessionId);

			List<String> langs = ssn.queryForList("roles.get-langs-by-role", role);

			return langs.toArray(new String[langs.size()]);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public Privilege getPrivilegeById(Long userSessionId, Integer privId, String lang) {

		SqlMapSession ssn = null;
		try {
			Privilege priv = new Privilege();
			priv.setId(privId);
			priv.setLang(lang);
			
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(priv.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, RolePrivConstants.VIEW_PRIVILEGE, paramArr);

			List<Privilege> privileges;
			SelectionParams params = new SelectionParams();
			params.setRowIndexStart(0);
			params.setRowIndexEnd(Integer.MAX_VALUE);
			List<Filter> filters = new ArrayList<Filter>();
			filters.add(new Filter("id", privId));
			filters.add(new Filter("lang", lang));
			params.setFilters(filters);
			//noinspection unchecked
			privileges = ssn.queryForList("roles.get-privs", convertQueryParams(params, null));
			return privileges.isEmpty() ? null : privileges.get(0);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public String[] getLanguagesByPriv(Long userSessionId, Privilege priv) {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSessionFE(userSessionId);

			List<String> langs = ssn.queryForList("roles.get-langs-by-priv", priv);

			return langs.toArray(new String[langs.size()]);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public ComplexRole[] getProcessRoles(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, RolePrivConstants.VIEW_ROLE_PRC, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, RolePrivConstants.VIEW_ROLE_PRC);
			List<ComplexRole> roles = ssn.queryForList("roles.get-process-roles",
					convertQueryParams(params, limitation));

			return roles.toArray(new ComplexRole[roles.size()]);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public int getProcessRolesCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, RolePrivConstants.VIEW_ROLE_PRC, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, RolePrivConstants.VIEW_ROLE_PRC);
			return (Integer) ssn.queryForObject("roles.get-process-roles-count",
					convertQueryParams(params, limitation));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void addProcessRole(Long userSessionId, Integer processId, Integer roleId) {
		SqlMapSession ssn = null;

		try {
			ssn = getIbatisSession(userSessionId, null, RolePrivConstants.ADD_ROLE_PRC, null);
			HashMap<String, Object> map = new HashMap<String, Object>();
			map.put("objectId", processId);
			map.put("roleId", roleId);
			ssn.insert("roles.add-role-to-process", map);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}
	

	public void addReportRole(Long userSessionId, Integer reportId, Integer roleId) {
		SqlMapSession ssn = null;

		try {
			HashMap<String, Object> map = new HashMap<String, Object>();
			map.put("objectId", reportId);
			map.put("roleId", roleId);
			
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(map);
			ssn = getIbatisSession(userSessionId, null, RolePrivConstants.ADD_ROLE_RPT, paramArr);
			
			ssn.insert("roles.add-role-to-report", map);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void deleteProcessRole(Long userSessionId, Integer bindId) {
		SqlMapSession ssn = null;

		try {
			ssn = getIbatisSession(userSessionId, null, RolePrivConstants.REMOVE_ROLE_PRC, null);
			
			ssn.delete("roles.remove-role-from-process", bindId);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void addRolesToProcess(Long userSessionId, Integer processId, ComplexRole[] roles) {
		SqlMapSession ssn = null;

		try {
			ssn = getIbatisSession(userSessionId, null, RolePrivConstants.VIEW_ROLE_PRC, null);

			for (ComplexRole role : roles) {
				HashMap<String, Integer> map = new HashMap<String, Integer>();
				map.put("objectId", processId);
				map.put("roleId", role.getId());
				ssn.insert("roles.add-role-to-process", map);
			}
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void deleteRolesFromProcess(Long userSessionId, ComplexRole[] roles) {
		SqlMapSession ssn = null;

		try {
			ssn = getIbatisSession(userSessionId, null, RolePrivConstants.REMOVE_ROLE_PRC, null);

			for (ComplexRole role : roles) {
				ssn.delete("roles.remove-role-from-process", role.getBindId());
			}
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public List<Privilege> getPrivilegesByUserId(Long userSessionId, Integer userId) {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSession(userSessionId);
			String roles = (String) ssn.queryForObject("roles.get-user-role-list", userId);
			if(roles == null || roles.isEmpty()) {
				return Collections.EMPTY_LIST;
			}
			List<String> roleList = Arrays.asList(roles.split(","));
            List<Filter> filters = new ArrayList<Filter>();
            filters.add(new Filter("roleList", null, roleList));
			SelectionParams params = new SelectionParams();
			params.setRowIndexStart(Integer.MIN_VALUE);
			params.setRowIndexEnd(Integer.MAX_VALUE);
			params.setFilters(filters.toArray(new Filter[filters.size()]));
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, RolePrivConstants.VIEW_USER_PRIVILEGE, paramArr);

			String limitation = CommonController.getLimitationByPriv(ssn, RolePrivConstants.VIEW_USER_PRIVILEGE);
			return  (List<Privilege>) ssn
					.queryForList("roles.get-privileges-by-user-id", convertQueryParams(params, limitation));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	public int getPrivilegesByUserIdCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, RolePrivConstants.VIEW_USER_PRIVILEGE, paramArr);
/*
			ssn.update("roles.set-user-id", userId);
*/
			String limitation = CommonController.getLimitationByPriv(ssn, RolePrivConstants.VIEW_USER_PRIVILEGE);
			return (Integer) ssn.queryForObject("roles.get-privileges-by-user-id-count", convertQueryParams(params, limitation));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	public Long setUserContext(String remoteAddress) {
		SqlMapSession ssn = null;
		try {
			Long sessionId = null;
			HashMap<String, Object> params = new HashMap<String, Object>();
			params.put("remoteAddress", remoteAddress);
			params.put("sessionId", sessionId);
			ssn = getIbatisSessionInitContext(params);
			sessionId = (Long) params.get("sessionId");
			return sessionId;
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public Long setInitialUserContext(Long sessionId, String remoteAddress, String userName, String privName) {
		try {
			HashMap<String, Object> params = new HashMap<String, Object>();
			params.put("remoteAddress", remoteAddress);
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params);
			Long resultSessionId = getUserSessionId(sessionId, userName, privName, remoteAddress, paramArr);
			return resultSessionId;
		} catch (SQLException e) {
			throw createDaoException(e);
		}
	}


    public Long setInitialUserContext(String remoteAddress, String userName, String privName) {
        return setInitialUserContext(null, remoteAddress, userName, privName);
    }


	@SuppressWarnings("unchecked")
	public ComplexRole[] getReportRoles(Long userSessionId,
			SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, RolePrivConstants.VIEW_ROLES_RPT, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, RolePrivConstants.VIEW_ROLES_RPT);
			List<ComplexRole> roles = ssn.queryForList("roles.get-report-roles",
					convertQueryParams(params, limitation));

			return roles.toArray(new ComplexRole[roles.size()]);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public int getReportRolesCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, RolePrivConstants.VIEW_ROLES_RPT, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, RolePrivConstants.VIEW_ROLES_RPT);
			return (Integer) ssn.queryForObject("roles.get-report-roles-count",
					convertQueryParams(params, limitation));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public ComplexRole[] getFlowRoles(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, RolePrivConstants.VIEW_ROLES_FLOW, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, RolePrivConstants.VIEW_ROLES_FLOW);
			List<ComplexRole> roles = ssn.queryForList("roles.get-flow-roles",
					convertQueryParams(params, limitation));

			return roles.toArray(new ComplexRole[roles.size()]);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public int getFlowRolesCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, RolePrivConstants.VIEW_ROLES_FLOW, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, RolePrivConstants.VIEW_ROLES_FLOW);
			return (Integer) ssn.queryForObject("roles.get-flow-roles-count",
					convertQueryParams(params, limitation));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void addRolesToReport(Long userSessionId, int reportId,
			ComplexRole[] roles) {
		SqlMapSession ssn = null;

		try {
			ssn = getIbatisSession(userSessionId, null, RolePrivConstants.VIEW_ROLES_RPT, null);

			for (ComplexRole role : roles) {
				HashMap<String, Integer> map = new HashMap<String, Integer>();
				map.put("objectId", reportId);
				map.put("roleId", role.getId());
				ssn.insert("roles.add-role-to-report", map);
			}
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void deleteRoleFromReport(Long userSessionId, Integer bindId) {
		SqlMapSession ssn = null;

		try {
			ssn = getIbatisSession(userSessionId, null, RolePrivConstants.REMOVE_ROLE_RPT, null);
			ssn.delete("roles.remove-role-from-report", bindId);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}	
	}


	public void addRolesToRole(Long userSessionId, Integer roleId,
			ComplexRole[] roles) {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSession(userSessionId, null, RolePrivConstants.ADD_ROLE_TO_ROLE, null);
			
			for (ComplexRole role : roles) {
				HashMap<String, Integer> map = new HashMap<String, Integer>();
				map.put("roleId", role.getId());
				map.put("objectId", roleId);
				ssn.insert("roles.add-role-in-role", map);
			}
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
		
	}
	

	@SuppressWarnings("unchecked")
	public ComplexRole[] getObjectRoles(Long userSessionId,
			SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, RolePrivConstants.VIEW_OBJECT_ROLES, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, RolePrivConstants.VIEW_OBJECT_ROLES);
			List<ComplexRole> roles = ssn.queryForList("roles.get-object-roles",
					convertQueryParams(params, limitation));

			return roles.toArray(new ComplexRole[roles.size()]);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public int getObjectRolesCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, RolePrivConstants.VIEW_OBJECT_ROLES, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, RolePrivConstants.VIEW_OBJECT_ROLES);
			return (Integer) ssn.queryForObject("roles.get-object-roles-count",
					convertQueryParams(params, limitation));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}
	

	public void addRolesToEntityObject(Long userSessionId, int objectId, String entityType, ComplexRole[] roles) {
		SqlMapSession ssn = null;

		try {
			ssn = getIbatisSession(userSessionId, null, RolePrivConstants.ADD_OBJECT_ROLES, null);

			for (ComplexRole role : roles) {
				HashMap<String, Object> map = new HashMap<String, Object>();
				map.put("objectId", objectId);
				map.put("roleId", role.getId());
				map.put("entityType", entityType);
				ssn.insert("roles.add-role-to-object", map);
			}
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}
	

	public void deleteRoleFromObject(Long userSessionId, Integer bindId) {
		SqlMapSession ssn = null;

		try {
			ssn = getIbatisSession(userSessionId, null, RolePrivConstants.REMOVE_OBJECT_ROLES, null);
			ssn.delete("roles.remove-role-from-object", bindId);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}	
	}


	public boolean checkPasswordExpired(String userName) throws UserException {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSessionNoContext();
			Map<String, Object> params = new HashMap<String, Object>();
			params.put("userName", userName);
			ssn.update("roles.check-password-expired", params);
			return (Boolean)params.get("expired");
		} catch (SQLException e) {
			if (e.getErrorCode() >= 20000 && e.getErrorCode() <= 20999) {
				throw new UserException(e.getCause().getMessage(), e.getErrorCode(), e);
			} else {
				throw new DataAccessException(e);
			}
		} finally {
			close(ssn);
		}
	}


	public Long getUserIdByName(String userName) throws UserException {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSessionNoContext();
			Map<String, Object> params = new HashMap<String, Object>();
			params.put("userName", userName);
			ssn.update("roles.check-user-exist", params);
			return params.containsKey("userId") ? (Long)params.get("userId") : null;
		} catch (SQLException e) {
			if (e.getErrorCode() >= 20000 && e.getErrorCode() <= 20999) {
				throw new UserException(e.getCause().getMessage(), e.getErrorCode(), e);
			} else {
				throw new DataAccessException(e);
			}
		} finally {
			close(ssn);
		}
	}
}
