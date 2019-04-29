package ru.bpc.sv2.logic;

import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;


import org.apache.log4j.Logger;

import ru.bpc.sv2.acm.AcmAction;
import ru.bpc.sv2.acm.AcmActionGroup;
import ru.bpc.sv2.acm.AcmActionValue;
import ru.bpc.sv2.acm.AcmPrivConstants;
import ru.bpc.sv2.acm.ComponentState;
import ru.bpc.sv2.acm.PrivLimitation;
import ru.bpc.sv2.acm.PrivLimitationField;
import ru.bpc.sv2.acm.SectionParameter;
import ru.bpc.sv2.administrative.Partition;
import ru.bpc.sv2.administrative.PartitionTable;
import ru.bpc.sv2.administrative.roles.Privilege;
import ru.bpc.sv2.common.CommonParamRec;
import ru.bpc.sv2.fcl.cycles.Cycle;
import ru.bpc.sv2.fcl.cycles.CycleShift;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.controller.CommonController;
import ru.bpc.sv2.logic.utility.db.IbatisAware;
import ru.bpc.sv2.utils.AuditParamUtil;
import ru.bpc.sv2.utils.KeyLabelItem;

import com.ibatis.sqlmap.client.SqlMapSession;

/**
 * Session Bean implementation class AccessManagementDao
 */
public class AccessManagementDao extends IbatisAware {

	private static final Logger logger = Logger.getLogger("ACCESS_MANAGEMENT");
	
	private CyclesDao _cyclesDao = new CyclesDao();
	private RolesDao _rolesDao = new RolesDao();


	@SuppressWarnings("unchecked")
	public AcmAction[] getAcmActions(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, AcmPrivConstants.VIEW_ACTION, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, AcmPrivConstants.VIEW_ACTION);

			List<AcmAction> actions = ssn.queryForList("acm.get-actions",
					convertQueryParams(params, limitation));
			
			return actions.toArray(new AcmAction[actions.size()]);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	@SuppressWarnings("unchecked")
	public AcmAction[] getAcmActionsWithParams(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, AcmPrivConstants.VIEW_ACTION, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, AcmPrivConstants.VIEW_ACTION);

			List<AcmAction> actions = ssn.queryForList("acm.get-actions",
					convertQueryParams(params, limitation));
			
			Filter[] filters = new Filter[2];
			for (AcmAction action: actions) {
				filters[0] = new Filter();
				filters[0].setElement("actionId");
				filters[0].setValue(action.getId());
				filters[1] = new Filter();
				filters[1].setElement("lang");
				filters[1].setValue(action.getLang());
				
				params = new SelectionParams();
				params.setFilters(filters);
				
				action.setActionValues(ssn.queryForList("acm.get-action-values",
						convertQueryParams(params)));
			}
			return actions.toArray(new AcmAction[actions.size()]);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}
	

	@SuppressWarnings("unchecked")
	public AcmAction[] getAcmActionsWithParamsNoPriv(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, null, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, AcmPrivConstants.VIEW_ACTION);

			List<AcmAction> actions = ssn.queryForList("acm.get-actions",
					convertQueryParams(params, limitation));
			
			Filter[] filters = new Filter[2];
			for (AcmAction action: actions) {
				filters[0] = new Filter();
				filters[0].setElement("actionId");
				filters[0].setValue(action.getId());
				filters[1] = new Filter();
				filters[1].setElement("lang");
				filters[1].setValue(action.getLang());
				
				params = new SelectionParams();
				params.setFilters(filters);
				
				action.setActionValues(ssn.queryForList("acm.get-action-values",
						convertQueryParams(params)));
			}
			return actions.toArray(new AcmAction[actions.size()]);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public int getAcmActionsCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, AcmPrivConstants.VIEW_ACTION, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, AcmPrivConstants.VIEW_ACTION);
			return (Integer) ssn
					.queryForObject("acm.get-actions-count", convertQueryParams(params, limitation));
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public AcmAction addAcmAction(Long userSessionId, AcmAction action) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(action.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, AcmPrivConstants.ADD_ACTION, paramArr);

			ssn.update("acm.add-action", action);

			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("id");
			filters[0].setValue(action.getId());
			filters[1] = new Filter();
			filters[1].setElement("lang");
			filters[1].setValue(action.getLang());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (AcmAction) ssn.queryForObject("acm.get-actions", convertQueryParams(params));
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public AcmAction modifyAcmAction(Long userSessionId, AcmAction action) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(action.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, AcmPrivConstants.MODIFY_ACTION, paramArr);

			ssn.update("acm.modify-action", action);

			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("id");
			filters[0].setValue(action.getId());
			filters[1] = new Filter();
			filters[1].setElement("lang");
			filters[1].setValue(action.getLang());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (AcmAction) ssn.queryForObject("acm.get-actions", convertQueryParams(params));
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void removeAcmAction(Long userSessionId, AcmAction action) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(action.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, AcmPrivConstants.REMOVE_ACTION, paramArr);

			ssn.update("acm.remove-action", action);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	@SuppressWarnings("unchecked")
	public AcmActionGroup[] getAcmActionGroupsTree(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, AcmPrivConstants.VIEW_ACTION_GROUPS, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, AcmPrivConstants.VIEW_ACTION_GROUPS);

			List<AcmActionGroup> actions = ssn.queryForList("acm.get-action-groups-hier",
			        convertQueryParams(params, limitation));

			return actions.toArray(new AcmActionGroup[actions.size()]);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	@SuppressWarnings("unchecked")
	public AcmActionGroup[] getAcmActionGroups(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, AcmPrivConstants.VIEW_ACTION_GROUPS, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, AcmPrivConstants.VIEW_ACTION_GROUPS);

			List<AcmActionGroup> actions = ssn.queryForList("acm.get-action-groups",
			        convertQueryParams(params, limitation));

			return actions.toArray(new AcmActionGroup[actions.size()]);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}
	

	@SuppressWarnings("unchecked")
	public AcmActionGroup[] getAcmActionGroupsNoPriv(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, null, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, AcmPrivConstants.VIEW_ACTION_GROUPS);

			List<AcmActionGroup> actions = ssn.queryForList("acm.get-action-groups",
			        convertQueryParams(params, limitation));

			return actions.toArray(new AcmActionGroup[actions.size()]);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public AcmActionGroup addAcmActionGroup(Long userSessionId, AcmActionGroup action) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(action.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, AcmPrivConstants.ADD_ACTION_GROUP, paramArr);

			ssn.update("acm.add-action-group", action);

			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("id");
			filters[0].setValue(action.getId());
			filters[1] = new Filter();
			filters[1].setElement("lang");
			filters[1].setValue(action.getLang());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (AcmActionGroup) ssn.queryForObject("acm.get-action-groups", convertQueryParams(params));
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public AcmActionGroup modifyAcmActionGroup(Long userSessionId, AcmActionGroup action) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(action.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, AcmPrivConstants.MODIFY_ACTION_GROUP, paramArr);

			ssn.update("acm.modify-action-group", action);

			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("id");
			filters[0].setValue(action.getId());
			filters[1] = new Filter();
			filters[1].setElement("lang");
			filters[1].setValue(action.getLang());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (AcmActionGroup) ssn.queryForObject("acm.get-action-groups", convertQueryParams(params));
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void removeAcmAction(Long userSessionId, AcmActionGroup action) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(action.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, AcmPrivConstants.REMOVE_ACTION_GROUP, paramArr);
			ssn.update("acm.remove-action-group", action);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	@SuppressWarnings("unchecked")
	public AcmActionValue[] getAcmActionValues(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, AcmPrivConstants.VIEW_ACTION_VALUE, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, AcmPrivConstants.VIEW_ACTION_VALUE);

			List<AcmActionValue> values = ssn.queryForList("acm.get-action-values",
					convertQueryParams(params, limitation+9));
			return values.toArray(new AcmActionValue[values.size()]);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public int getAcmActionValuesCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, AcmPrivConstants.VIEW_ACTION_VALUE, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, AcmPrivConstants.VIEW_ACTION_VALUE);
			return (Integer) ssn.queryForObject("acm.get-action-values-count",
					convertQueryParams(params, limitation));
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public AcmActionValue addAcmActionValue(Long userSessionId, AcmActionValue actionValue) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(actionValue.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, AcmPrivConstants.ADD_ACTION_VALUE, paramArr);

			ssn.update("acm.add-action-value", actionValue);

			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("id");
			filters[0].setValue(actionValue.getId());
			filters[1] = new Filter();
			filters[1].setElement("lang");
			filters[1].setValue(actionValue.getLang());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (AcmActionValue) ssn.queryForObject("acm.get-action-values",
					convertQueryParams(params));
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public AcmActionValue modifyAcmActionValue(Long userSessionId, AcmActionValue actionValue) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(actionValue.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, AcmPrivConstants.MODIFY_ACTION_VALUE, paramArr);

			ssn.update("acm.modify-action-value", actionValue);

			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("id");
			filters[0].setValue(actionValue.getId());
			filters[1] = new Filter();
			filters[1].setElement("lang");
			filters[1].setValue(actionValue.getLang());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (AcmActionValue) ssn.queryForObject("acm.get-action-values",
					convertQueryParams(params));
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void removeAcmActionValue(Long userSessionId, AcmActionValue actionValue) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(actionValue.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, AcmPrivConstants.REMOVE_ACTION_VALUE, paramArr);

			ssn.update("acm.remove-action-value", actionValue);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	@SuppressWarnings("unchecked")
	public SectionParameter[] getSectionParameters(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, AcmPrivConstants.VIEW_SECTION_PARAMETER, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, AcmPrivConstants.VIEW_SECTION_PARAMETER);

			List<SectionParameter> sParams = ssn.queryForList("acm.get-section-params",
					convertQueryParams(params, limitation));
			return sParams.toArray(new SectionParameter[sParams.size()]);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public int getSectionParametersCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, AcmPrivConstants.VIEW_SECTION_PARAMETER, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, AcmPrivConstants.VIEW_SECTION_PARAMETER);
			
			return (Integer) ssn.queryForObject("acm.get-section-params-count",
					convertQueryParams(params, limitation));
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public SectionParameter addSectionParameter(Long userSessionId, SectionParameter parameter) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(parameter.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, AcmPrivConstants.ADD_SECTION_PARAMETER, paramArr);

			ssn.update("acm.add-section-param", parameter);

			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("id");
			filters[0].setValue(parameter.getId());
			filters[1] = new Filter();
			filters[1].setElement("lang");
			filters[1].setValue(parameter.getLang());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (SectionParameter) ssn.queryForObject("acm.get-section-params",
					convertQueryParams(params));
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public SectionParameter modifySectionParameter(Long userSessionId, SectionParameter parameter) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(parameter.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, AcmPrivConstants.MODIFY_SECTION_PARAMETER, paramArr);

			ssn.update("acm.modify-section-param", parameter);

			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("id");
			filters[0].setValue(parameter.getId());
			filters[1] = new Filter();
			filters[1].setElement("lang");
			filters[1].setValue(parameter.getLang());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (SectionParameter) ssn.queryForObject("acm.get-section-params",
					convertQueryParams(params));
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void removeSectionParameter(Long userSessionId, SectionParameter parameter) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(parameter.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, AcmPrivConstants.REMOVE_SECTION_PARAMETER, paramArr);

			ssn.update("acm.remove-section-param", parameter);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public Privilege addPrivLimitation(Long userSessionId,
			Privilege privilege) {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSessionFE(userSessionId);

			ssn.update("acm.set-priv-limitation", privilege);
			
			Filter[] filters = new Filter[1];
			filters[0] = new Filter();
			filters[0].setElement("privId");
			filters[0].setValue(privilege.getId().toString());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			Privilege[] privileges = _rolesDao.getRolePrivs(userSessionId, params);
			if (privileges != null && privileges.length > 0) {
				return privileges[0];
			} else {
				return null;
			}
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
		
	}


	@SuppressWarnings("unchecked")
	public PrivLimitation[] getPrivLimitations(Long userSessionId,
			SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, AcmPrivConstants.VIEW_LIMITATION, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, AcmPrivConstants.VIEW_LIMITATION);

			List<PrivLimitation> privLimitations = ssn.queryForList("acm.get-priv-limitations",
					convertQueryParams(params, limitation));
			return privLimitations.toArray(new PrivLimitation[privLimitations.size()]);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	public int getPrivLimitationsCount(Long userSessionId,
			SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, AcmPrivConstants.VIEW_LIMITATION, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, AcmPrivConstants.VIEW_LIMITATION);

			int privLimitationsCount = (Integer) ssn.queryForObject("acm.get-priv-limitations-count",
					convertQueryParams(params, limitation));
			return privLimitationsCount;
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	public List<PrivLimitationField> getPrivLimitationFields(Long userSessionId,
	                                                         SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, AcmPrivConstants.VIEW_LIMITATION, paramArr);

			String limitationField = CommonController.getLimitationByPriv(ssn, AcmPrivConstants.VIEW_LIMITATION);

			List<PrivLimitationField> privLimitationFields = ssn.queryForList("acm.get-priv-limitation-fields",
					convertQueryParams(params, limitationField));
			return privLimitationFields;
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}
	

	public PrivLimitation addLimitation(Long userSessionId, PrivLimitation limitation) {
		SqlMapSession ssn = null;

		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(limitation.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, AcmPrivConstants.ADD_LIMITATION, paramArr);
			ssn.insert("acm.add-limitation", limitation);

			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("id");
			filters[0].setValue(limitation.getId().toString());
			filters[1] = new Filter();
			filters[1].setElement("lang");
			filters[1].setValue(limitation.getLang());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (PrivLimitation) ssn.queryForObject("acm.get-priv-limitations", convertQueryParams(params));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public PrivLimitationField addLimitationField(Long userSessionId, String lang, PrivLimitationField limitationField) {
		SqlMapSession ssn = null;

		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(limitationField.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, AcmPrivConstants.MODIFY_LIMITATION, paramArr);
			ssn.update("acm.add-limitation-field", limitationField);

			SelectionParams params = SelectionParams.build("lang", lang, "id", limitationField.getId());

			return (PrivLimitationField) ssn.queryForObject("acm.get-priv-limitation-fields", convertQueryParams(params));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public PrivLimitation modifyLimitation(Long userSessionId, PrivLimitation limitation) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(limitation.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, AcmPrivConstants.MODIFY_LIMITATION, paramArr);

			ssn.update("acm.modify-limitation", limitation);

			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("id");
			filters[0].setValue(limitation.getId().toString());
			filters[1] = new Filter();
			filters[1].setElement("lang");
			filters[1].setValue(limitation.getLang());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (PrivLimitation) ssn.queryForObject("acm.get-priv-limitations", convertQueryParams(params));
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	public PrivLimitationField modifyLimitationField(Long userSessionId, String lang, PrivLimitationField limitationField) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(limitationField.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, AcmPrivConstants.MODIFY_LIMITATION, paramArr);

			ssn.update("acm.modify-limitation-field", limitationField);

			SelectionParams params = SelectionParams.build("lang", lang, "id", limitationField.getId());

			return (PrivLimitationField) ssn.queryForObject("acm.get-priv-limitation-fields", convertQueryParams(params));
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	public void removeLimitation(Long userSessionId, PrivLimitation limitation) {
		SqlMapSession ssn = null;

		try {
			ssn = getIbatisSessionFE(userSessionId);
			ssn.delete("acm.remove-limitation", limitation);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void removeLimitationField(Long userSessionId, PrivLimitationField limitationField) {
		SqlMapSession ssn = null;

		try {
			ssn = getIbatisSessionFE(userSessionId);
			ssn.delete("acm.remove-limitation-field", limitationField);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	@SuppressWarnings("unchecked")
	public ComponentState[] getComponentStates(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSessionFE(userSessionId);

			List<ComponentState> compState = ssn.queryForList("acm.get-component-states",
			        convertQueryParams(params));
			return compState.toArray(new ComponentState[compState.size()]);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public ComponentState addComponentState(Long userSessionId, ComponentState componentState) {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSessionFE(userSessionId);

			ssn.update("acm.add-component-state", componentState);

			Filter[] filters = new Filter[1];
			filters[0] = new Filter();
			filters[0].setElement("id");
			filters[0].setValue(componentState.getId());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (ComponentState) ssn.queryForObject("acm.get-component-states",
			        convertQueryParams(params));
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void removeComponentState(Long userSessionId, ComponentState componentState) {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSessionFE(userSessionId);

			ssn.update("acm.remove-component-state", componentState);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}
	

	@SuppressWarnings("unchecked")
	public PartitionTable[] getPartitionTables(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, AcmPrivConstants.VIEW_PARTITION_TABLE, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, AcmPrivConstants.VIEW_PARTITION_TABLE);

			List<PartitionTable> actions = ssn.queryForList("acm.get-partition-tables",
					convertQueryParams(params, limitation));
			
			return actions.toArray(new PartitionTable[actions.size()]);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public int getPartitionTablesCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, AcmPrivConstants.VIEW_PARTITION_TABLE, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, AcmPrivConstants.VIEW_PARTITION_TABLE);
			return (Integer) ssn
					.queryForObject("acm.get-partition-tables-count", convertQueryParams(params, limitation));
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}
	

	public PartitionTable registerTransactionalTable(Long userSessionId, PartitionTable partitionValue,
			Cycle cycle, ArrayList<CycleShift> shifts, Cycle stoCycle, ArrayList<CycleShift> stoShifts) {
		SqlMapSession ssn = null;

		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(partitionValue.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, AcmPrivConstants.ADD_PARTITION_TABLE, paramArr);

			// create new cycle
			if (cycle.getId() == null) {
				ssn.insert("cycles.insert-new-cycle", cycle);
				if (shifts != null) {
					for (CycleShift shift: shifts) {
						shift.setCycleId(cycle.getId());
						shift.setId(null); // as we add new shift we don't need
						ssn.insert("cycles.insert-new-cycle-shift", shift);
					}
				}
			}
			
			// create new cycle
			if (stoCycle.getId() == null) {
				ssn.insert("cycles.insert-new-cycle", stoCycle);
				if (stoShifts != null) {
					for (CycleShift shift: stoShifts) {
						shift.setCycleId(stoCycle.getId());
						shift.setId(null); // as we add new shift we don't need
						ssn.insert("cycles.insert-new-cycle-shift", shift);
					}
				}
			}

			// bind cycle (just created) to partition table as attribute
			// value
			partitionValue.setPartitionCycleId(cycle.getId());
			partitionValue.setStorageCycleId(stoCycle.getId());

			ssn.update("acm.register-transactional-table", partitionValue);

			// get created value to return it as a result
			Filter[] filters = new Filter[1];
			filters[0] = new Filter();
			filters[0].setElement("tableName");
			filters[0].setValue(partitionValue.getTableName());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (PartitionTable) ssn.queryForObject("acm.get-partition-tables",
					convertQueryParams(params));
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}
	
	@SuppressWarnings("unchecked")
	public void unregisterTransactionalTable(Long userSessionId, PartitionTable partitionTable) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(partitionTable.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, AcmPrivConstants.REMOVE_PARTITION_TABLE, paramArr);
			
			//delete cycle shifts first
			int parCycleId = partitionTable.getPartitionCycleId();
			int stoCycleId = partitionTable.getStorageCycleId();

			int parCycleUsageCount = (Integer) ssn.queryForObject("cycles.get-partition-cycles-usage-count",
					parCycleId);
			int stoCycleUsageCount = (Integer) ssn.queryForObject("cycles.get-storage-cycles-usage-count",
					stoCycleId);
			//If this cycle is used only for table which we want to delete
			if(parCycleUsageCount == 1) {
				List<CycleShift> parCycleShifts = ssn.queryForList("cycles.get-cycle-shifts-by-cycle",
						parCycleId);
				for (CycleShift shift : parCycleShifts) {
					ssn.delete("cycles.remove-cycle-shift", shift);
				}
				Cycle parCycle = _cyclesDao.getCycleById(userSessionId, parCycleId);
				if(parCycle != null){
					ssn.delete("cycles.remove-cycle", parCycle);
				}
			}
			//If this cycle is used only for table which we want to delete
			if(stoCycleUsageCount == 1) {
				List<CycleShift> stoCycleShifts = ssn.queryForList("cycles.get-cycle-shifts-by-cycle",
						stoCycleId);
				for (CycleShift shift : stoCycleShifts) {
					ssn.delete("cycles.remove-cycle-shift", shift);
				}
				Cycle stoCycle = _cyclesDao.getCycleById(userSessionId, stoCycleId);
				if(stoCycle != null){
					ssn.delete("cycles.remove-cycle", stoCycle);
				}
			}

			ssn.update("acm.unregister-transactional-table", partitionTable);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}
	

	public  List<KeyLabelItem> getTables(Long userSessionId) {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSessionFE(userSessionId);

			List<KeyLabelItem> result = ssn.queryForList("acm.get-tables");
			return result;
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	@SuppressWarnings("unchecked")
	public Partition[] getPartitions(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, AcmPrivConstants.VIEW_PARTITION, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, AcmPrivConstants.VIEW_PARTITION);

			List<PartitionTable> actions = ssn.queryForList("acm.get-partitions",
					convertQueryParams(params, limitation));
			
			return actions.toArray(new Partition[actions.size()]);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public int getPartitionsCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, AcmPrivConstants.VIEW_PARTITION, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, AcmPrivConstants.VIEW_PARTITION);
			return (Integer) ssn
					.queryForObject("acm.get-partitions-count", convertQueryParams(params, limitation));
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}
}
