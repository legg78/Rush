package ru.bpc.sv2.logic;

import java.sql.SQLException;
import java.util.HashMap;
import java.util.List;


import org.apache.log4j.Logger;
import ru.bpc.sv2.common.Address;
import ru.bpc.sv2.common.CommonParamRec;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.controller.CommonController;
import ru.bpc.sv2.logic.utility.db.IbatisAware;
import ru.bpc.sv2.logic.utility.db.IbatisSessionCallback;
import ru.bpc.sv2.orgstruct.*;
import ru.bpc.sv2.utils.AuditParamUtil;

import com.ibatis.sqlmap.client.SqlMapSession;

/**
 * Session Bean implementation class OrgStructDao
 */
public class OrgStructDao extends IbatisAware {
	private static final Logger logger = Logger.getLogger("ORG_STRUCTURE");

	/**
	 * Gets either hierarchical or plain list of institutions.
	 * 
	 * @param params
	 *            - sorting and filtering parameters
	 * @param lang
	 *            - description language
	 * @param hierarchy
	 *            - if <code>true</code> result set will be hierarchical
	 * @return
	 */
	@SuppressWarnings("unchecked")
	public Institution[] getInstitutions(Long userSessionId, SelectionParams params, String lang,
			boolean hierarchy) {
		SqlMapSession ssn = null;
		try {

			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, OrgStructPrivConstants.VIEW_INSTITUTION, paramArr);

			List<Institution> insts;

			if (hierarchy) {
				insts = ssn.queryForList("orgStructure.get-inst-hier", convertQueryParams(params,
						null, lang));
			} else {
				insts = ssn.queryForList("orgStructure.get-institutions", convertQueryParams(
						params, null, lang));
			}

			return insts.toArray(new Institution[insts.size()]);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public Institution[] getInstitutionsForDropdown(Long userSessionId, SelectionParams params,
			String lang, boolean hierarchy) {
		SqlMapSession ssn = null;
		try {

			ssn = getIbatisSessionFE(userSessionId);

			List<Institution> insts;

			if (hierarchy) {
				insts = ssn.queryForList("orgStructure.get-inst-hier-for-dropdown",
						convertQueryParams(params, null, lang));
			} else {
				insts = ssn.queryForList("orgStructure.get-institutions-for-dropdown",
						convertQueryParams(params, null, lang));
			}

			return insts.toArray(new Institution[insts.size()]);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public int getInstitutionsCount(Long userSessionId, String lang) {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSessionFE(userSessionId);
			return (Integer) ssn.queryForObject("orgStructure.get-institutions-count", lang);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public Institution getInstDescription(Long userSessionId, Institution inst) {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSessionFE(userSessionId);

			return (Institution) ssn.queryForObject("orgStructure.get-inst-description", inst);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public Institution addInstitution(Long userSessionId, Institution inst) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(inst.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, OrgStructPrivConstants.ADD_INSTITUTION, paramArr);
			if (inst.getType() == null) {
				inst.setType("");
			}
			ssn.insert("orgStructure.add-institution", inst);
			
			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("id");
			filters[0].setValue(inst.getId().toString());
			filters[1] = new Filter();
			filters[1].setElement("lang");
			filters[1].setValue(inst.getLang());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (Institution)ssn.queryForObject("orgStructure.get-institutions", convertQueryParams(params, null, null));
			
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public Institution modifyInstitution(Long userSessionId, Institution inst) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(inst.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, OrgStructPrivConstants.MODIFY_INSTITUTION, paramArr);
			if (inst.getType() == null) {
				inst.setType("");
			}
			ssn.update("orgStructure.modify-institution", inst);
			
			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("id");
			filters[0].setValue(inst.getId().toString());
			filters[1] = new Filter();
			filters[1].setElement("lang");
			filters[1].setValue(inst.getLang());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (Institution)ssn.queryForObject("orgStructure.get-institutions", convertQueryParams(params, null, null));
			
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void removeInstitution(Long userSessionId, Institution inst) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(inst.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, OrgStructPrivConstants.REMOVE_INSTITUTION, paramArr);

			ssn.delete("orgStructure.remove-institution", inst);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public AgentType[] getAgentTypes(Long userSessionId, Integer instId) {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSessionFE(userSessionId);

			List<AgentType> types = ssn.queryForList("orgStructure.get-agent-types", instId);
			return types.toArray(new AgentType[types.size()]);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void addAgentTypeBranch(Long userSessionId, AgentType agent) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(agent.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, OrgStructPrivConstants.ADD_AGENT_TYPE_TREE_ELEMENT, paramArr);

			ssn.insert("orgStructure.add-agent-type-branch", agent);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void removeAgentTypeBranch(Long userSessionId, int branchId) {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSessionFE(userSessionId);

			ssn.delete("orgStructure.remove-agent-type-branch", branchId);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public String addInstAddress(Long userSessionId, Address addr, Integer instId, String addrType) {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSessionFE(userSessionId);

			HashMap params = new HashMap();
			params.put("lang", addr.getLang());
			params.put("country", addr.getCountry());
			params.put("region", addr.getRegion());
			params.put("city", addr.getCity());
			params.put("street", addr.getStreet());
			params.put("house", addr.getHouse());
			params.put("apt", addr.getApartment());
			params.put("postalCode", addr.getPostalCode());
			params.put("regionCode", addr.getRegionCode());

			ssn.update("common.add-address", params);

			String addressId = (String) params.get("addressId");
			params = new HashMap();
			params.put("instId", instId);
			params.put("addressId", addressId);
			params.put("addressType", addrType);

			ssn.update("orgStruct.add-inst-address", params);
			return (String) params.get("addressObjectId");
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public Address getInstAddresses(Long userSessionId, Integer instId, String curLang,
			String defaultLang) {
		SqlMapSession ssn = null;
		try {
			Filter[] filters = new Filter[2];
			// filters[0] = new Filter();
			// filters[0].setElement("instId");
			// filters[0].setOp(Operator.eq);
			// filters[0].setValue(instId.toString());
			// filters[1] = new Filter();
			// filters[1].setElement("addressType");
			// filters[1].setOp(Operator.eq);
			// filters[1].setValue(addressType);

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			ssn = getIbatisSessionFE(userSessionId);

			return (Address) ssn.queryForObject("orgStructure.get-inst-address",
					convertQueryParams(params));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public Agent[] getAgentsTree(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, params.getPrivilege()!=null ? params.getPrivilege() : OrgStructPrivConstants.VIEW_AGENT, paramArr);


			List<Agent> agents = ssn.queryForList("orgStructure.get-agents-hier",
					convertQueryParams(params));

			return agents.toArray(new Agent[agents.size()]);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public Agent[] getAgentsList(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, OrgStructPrivConstants.VIEW_AGENT, paramArr);
			List<Agent> agents = ssn.queryForList("orgStructure.get-agents",
					convertQueryParams(params));
			return agents.toArray(new Agent[agents.size()]);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public Agent getAgentDescription(Long userSessionId, Agent agent) {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSessionFE(userSessionId);

			return (Agent) ssn.queryForObject("orgStructure.get-agent-description", agent);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}

	}


	public Agent addAgent(Long userSessionId, Agent agent) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(agent.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, OrgStructPrivConstants.ADD_AGENT, paramArr);

			ssn.insert("orgStructure.add-agent", agent);

			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("id");
			filters[0].setValue(agent.getId().toString());
			filters[1] = new Filter();
			filters[1].setElement("lang");
			filters[1].setValue(agent.getLang());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			Agent result = (Agent) ssn
					.queryForObject("orgStructure.get-agents", convertQueryParams(params));
			return result;
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public Agent modifyAgent(Long userSessionId, Agent agent) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(agent.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, OrgStructPrivConstants.MODIFY_AGENT, paramArr);

			ssn.update("orgStructure.modify-agent", agent);

			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("id");
			filters[0].setValue(agent.getId().toString());
			filters[1] = new Filter();
			filters[1].setElement("lang");
			filters[1].setValue(agent.getLang());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (Agent) ssn
					.queryForObject("orgStructure.get-agents", convertQueryParams(params));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void removeAgent(Long userSessionId, Agent agent) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(agent.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, OrgStructPrivConstants.REMOVE_AGENT, paramArr);

			ssn.delete("orgStructure.remove-agent", agent);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public String[] getAgentTypesByParent(Long userSessionId, AgentType agentType) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(agentType.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, OrgStructPrivConstants.VIEW_AGENT_TYPE_TREE, paramArr);

			List<String> types;
			if (agentType.getType() == null) {
				types = ssn.queryForList("orgStructure.get-top-agent-types-by-inst", agentType
						.getInstId());
			} else {
				types = ssn.queryForList("orgStructure.get-agent-types-by-parent", agentType);
			}
			return types.toArray(new String[types.size()]);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	public void addAgentToUser(Long userSessionId) {

	}

	public void addInstToUser(Long userSessionId) {

	}

	@SuppressWarnings("unchecked")
	public List<Agent> getAgentsByCustomer(Long userSessionId, Long customerId) {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSession(userSessionId, null, OrgStructPrivConstants.VIEW_AGENT, null);

			return ssn.queryForList("orgStructure.get-agents-by-customer", customerId);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public Integer getDefaultAgentId(Long userSessionId, Integer instId) {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSession(userSessionId, null, OrgStructPrivConstants.VIEW_USER_AGENT, null);
			Integer agentId = (Integer) ssn.queryForObject("orgStructure.get-default-agent", instId);
			return agentId;
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}
	

	public Integer getNetworkIdByInstId(Long userSessionId, Integer instId, String curLang){
		Integer result = null;
		SelectionParams sp = SelectionParams.build("instId", instId);
		Institution[] insts = getInstitutions(userSessionId, sp, curLang, false);
		if (insts.length != 0){
			result = insts[0].getNetworkId();
		}
		return result;
	}


	@SuppressWarnings("unchecked")
	public List<ForbiddenAction> getForbiddenActions(Long userSessionId, final SelectionParams params) {
		return executeWithSession(userSessionId,
								  OrgStructPrivConstants.VIEW_FORBID_ACTIONS,
								  logger,
								  new IbatisSessionCallback<List<ForbiddenAction>>() {
			@Override
			public List<ForbiddenAction> doInSession(SqlMapSession ssn) throws Exception {
				String limitation = CommonController.getLimitationByPriv(ssn, OrgStructPrivConstants.VIEW_FORBID_ACTIONS);
				return ssn.queryForList("orgStructure.get-forbidden-actions", convertQueryParams(params, limitation));
			}
		});
	}


	public int getForbiddenActionsCount(Long userSessionId, final SelectionParams params) {
		return executeWithSession(userSessionId,
								  OrgStructPrivConstants.VIEW_FORBID_ACTIONS,
								  logger,
								  new IbatisSessionCallback<Integer>() {
			@Override
			public Integer doInSession(SqlMapSession ssn) throws Exception {
				String limitation = CommonController.getLimitationByPriv(ssn, OrgStructPrivConstants.VIEW_FORBID_ACTIONS);
				Object count = ssn.queryForObject("orgStructure.get-forbidden-actions-count", convertQueryParams(params, limitation));
				return (count != null) ? (Integer)count : 0;
			}
		});
	}


	public ForbiddenAction addForbiddenAction(Long userSessionId, final ForbiddenAction action) {
		return executeWithSession(userSessionId,
								  OrgStructPrivConstants.ADD_FORBID_ACTION,
								  AuditParamUtil.getCommonParamRec(action.getAuditParameters()),
								  logger,
								  new IbatisSessionCallback<ForbiddenAction>() {
			@Override
			public ForbiddenAction doInSession(SqlMapSession ssn) throws Exception {
				ssn.insert("orgStructure.add-forbidden-action", action);
				return action.clone();
			}
		});
	}


	public void removeForbiddenAction(Long userSessionId, final ForbiddenAction action) {
		executeWithSession(userSessionId,
						   OrgStructPrivConstants.REMOVE_FORBID_ACTION,
						   AuditParamUtil.getCommonParamRec(action.getAuditParameters()),
						   logger,
						   new IbatisSessionCallback<Void>() {
			@Override
			public Void doInSession(SqlMapSession ssn) throws Exception {
				ssn.delete("orgStructure.remove-forbidden-action", action);
				return null;
			}
		});
	}
}
