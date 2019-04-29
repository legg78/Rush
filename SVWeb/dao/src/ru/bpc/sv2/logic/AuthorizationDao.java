package ru.bpc.sv2.logic;

import java.sql.SQLException;
import java.util.List;


import org.apache.log4j.Logger;

import ru.bpc.sv2.aut.Authorization;
import ru.bpc.sv2.aut.AuthorizationPrivConstants;
import ru.bpc.sv2.aut.RespCode;
import ru.bpc.sv2.common.CommonParamRec;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.controller.CommonController;
import ru.bpc.sv2.logic.utility.db.IbatisAware;
import ru.bpc.sv2.utils.AuditParamUtil;

import com.ibatis.sqlmap.client.SqlMapSession;

public class AuthorizationDao extends IbatisAware {
	private static final Logger logger = Logger.getLogger("OPER_PROCESSING");


	@SuppressWarnings("unchecked")
	public RespCode[] getRespCodes(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, AuthorizationPrivConstants.VIEW_AUT_RESP_CODE, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, AuthorizationPrivConstants.VIEW_AUT_RESP_CODE);
			List<RespCode> items = ssn.queryForList("aut.get-resp-codes",
					convertQueryParams(params, limitation));
			return items.toArray(new RespCode[items.size()]);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public int getRespCodesCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, AuthorizationPrivConstants.VIEW_AUT_RESP_CODE, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, AuthorizationPrivConstants.VIEW_AUT_RESP_CODE);
			int count = (Integer) ssn.queryForObject("aut.get-resp-codes-count",
					convertQueryParams(params, limitation));
			return count;
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void createRespCode(Long userSessionId, RespCode respCode) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(respCode.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, AuthorizationPrivConstants.ADD_AUT_RESP_CODE, paramArr);
			ssn.update("aut.add-resp-code", respCode);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void modifyRespCode(Long userSessionId, RespCode respCode) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(respCode.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, AuthorizationPrivConstants.MODIFY_AUT_RESP_CODE, paramArr);
			ssn.update("aut.modify-resp-code", respCode);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void deleteRespCode(Long userSessionId, RespCode respCode) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(respCode.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, AuthorizationPrivConstants.REMOVE_AUT_RESP_CODE, paramArr);
			ssn.update("aut.remove-resp-code", respCode);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	@SuppressWarnings("unchecked")
	public Authorization[] getAuthorizations(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSessionFE(userSessionId);
			List<Authorization> items = ssn.queryForList("aut.get-authorizations",
					convertQueryParams(params));
			return items.toArray(new Authorization[items.size()]);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public int getAuthorizationsCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSessionFE(userSessionId);
			int count = (Integer) ssn.queryForObject("aut.get-authorizations-count",
					convertQueryParams(params));
			return count;
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}
}
