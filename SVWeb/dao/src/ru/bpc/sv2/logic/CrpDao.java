package ru.bpc.sv2.logic;

import java.sql.SQLException;
import java.util.List;


import org.apache.log4j.Logger;

import ru.bpc.sv2.common.CommonParamRec;
import ru.bpc.sv2.crp.CrpDepartment;
import ru.bpc.sv2.crp.CrpEmployee;
import ru.bpc.sv2.crp.CrpPrivConstants;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.controller.CommonController;
import ru.bpc.sv2.logic.utility.db.IbatisAware;
import ru.bpc.sv2.utils.AuditParamUtil;

import com.ibatis.sqlmap.client.SqlMapSession;

public class CrpDao extends IbatisAware {

	private static final Logger logger = Logger.getLogger("CRP");
	

	@SuppressWarnings("unchecked")
	public CrpDepartment[] getDepartments(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSessionFE(userSessionId);

			List<CrpDepartment> items = ssn.queryForList(
					"crp.get-departaments", convertQueryParams(params));
			return items.toArray(new CrpDepartment[items.size()]);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	@SuppressWarnings("unchecked")
	public CrpEmployee[] getEmployees(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, CrpPrivConstants.VIEW_EMPLOYEES, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, CrpPrivConstants.VIEW_EMPLOYEES);
			List<CrpEmployee> items = ssn.queryForList(
			        "crp.get-employees", convertQueryParams(params, limitation));
			return items.toArray(new CrpEmployee[items.size()]);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public int getEmployeesCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, CrpPrivConstants.VIEW_EMPLOYEES, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, CrpPrivConstants.VIEW_EMPLOYEES);
			int count = (Integer)ssn.queryForObject("crp.get-employees-count",
			        convertQueryParams(params, limitation));
			return count;
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

}
