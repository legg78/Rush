package ru.bpc.sv2.logic;

import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import ru.bpc.sv2.logic.utility.db.DataAccessException;


import ru.bpc.sv2.common.CommonParamRec;
import ru.bpc.sv2.fraud.Case;
import ru.bpc.sv2.fraud.CaseEvent;
import ru.bpc.sv2.fraud.Check;
import ru.bpc.sv2.fraud.FraudAlert;
import ru.bpc.sv2.fraud.FraudData;
import ru.bpc.sv2.fraud.FraudObject;
import ru.bpc.sv2.fraud.FraudPrivConstants;
import ru.bpc.sv2.fraud.Matrix;
import ru.bpc.sv2.fraud.MatrixValue;
import ru.bpc.sv2.fraud.MonitoredFraudAlert;
import ru.bpc.sv2.fraud.Suite;
import ru.bpc.sv2.fraud.SuiteCase;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.controller.CommonController;
import ru.bpc.sv2.logic.utility.db.IbatisAware;
import ru.bpc.sv2.logic.utility.db.QueryParams;
import ru.bpc.sv2.utils.AuditParamUtil;

import com.ibatis.sqlmap.client.SqlMapSession;

/**
 * Session Bean implementation class FraudDao
 */
public class FraudDao extends IbatisAware {

	@SuppressWarnings("unchecked")
	public Suite[] getSuites(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, params.getPrivilege()!=null ? params.getPrivilege() : FraudPrivConstants.VIEW_SUITE, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, params.getPrivilege()!=null ? params.getPrivilege() : FraudPrivConstants.VIEW_SUITE);
			List<Suite> suites = ssn.queryForList("fraud.get-suites",
			        convertQueryParams(params, limitation));
			return suites.toArray(new Suite[suites.size()]);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public int getSuitesCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, FraudPrivConstants.VIEW_SUITE, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, FraudPrivConstants.VIEW_SUITE);
			return (Integer) ssn.queryForObject("fraud.get-suites-count",
			        convertQueryParams(params, limitation));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public Suite addSuite(Long userSessionId, Suite suite) {
		SqlMapSession ssn = null;

		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(suite.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, FraudPrivConstants.ADD_SUITE, paramArr);

			ssn.insert("fraud.add-suite", suite);

			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("lang");
			filters[0].setValue(suite.getLang());
			filters[1] = new Filter();
			filters[1].setElement("id");
			filters[1].setValue(suite.getId());
			
			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (Suite) ssn.queryForObject("fraud.get-suites",
					convertQueryParams(params));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public Suite modifySuite(Long userSessionId, Suite suite) {
		SqlMapSession ssn = null;

		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(suite.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, FraudPrivConstants.MODIFY_SUITE, paramArr);
			
			ssn.update("fraud.modify-suite", suite);
			
			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("lang");
			filters[0].setValue(suite.getLang());
			filters[1] = new Filter();
			filters[1].setElement("id");
			filters[1].setValue(suite.getId());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (Suite) ssn.queryForObject("fraud.get-suites",
					convertQueryParams(params));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}
	

	public void removeSuite(Long userSessionId, Suite suite) {
		SqlMapSession ssn = null;

		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(suite.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, FraudPrivConstants.REMOVE_SUITE, paramArr);

			ssn.delete("fraud.remove-suite", suite);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public Case[] getCases(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, FraudPrivConstants.VIEW_CASE, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, FraudPrivConstants.VIEW_CASE);
			List<Case> cases = ssn.queryForList("fraud.get-cases",
			        convertQueryParams(params, limitation));
			return cases.toArray(new Case[cases.size()]);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public int getCasesCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, FraudPrivConstants.VIEW_CASE, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, FraudPrivConstants.VIEW_CASE);
			return (Integer) ssn.queryForObject("fraud.get-cases-count",
			        convertQueryParams(params, limitation));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public Case addCase(Long userSessionId, Case frdCase) {
		SqlMapSession ssn = null;

		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(frdCase.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, FraudPrivConstants.ADD_CASE, paramArr);

			ssn.insert("fraud.add-case", frdCase);

			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("lang");
			filters[0].setValue(frdCase.getLang());
			filters[1] = new Filter();
			filters[1].setElement("id");
			filters[1].setValue(frdCase.getId());
			
			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (Case) ssn.queryForObject("fraud.get-cases",
					convertQueryParams(params));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public Case modifyCase(Long userSessionId, Case frdCase) {
		SqlMapSession ssn = null;

		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(frdCase.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, FraudPrivConstants.MODIFY_CASE, paramArr);
			
			ssn.update("fraud.modify-case", frdCase);
			
			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("lang");
			filters[0].setValue(frdCase.getLang());
			filters[1] = new Filter();
			filters[1].setElement("id");
			filters[1].setValue(frdCase.getId());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (Case) ssn.queryForObject("fraud.get-cases",
					convertQueryParams(params));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}
	

	public void removeCase(Long userSessionId, Case frdCase) {
		SqlMapSession ssn = null;

		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(frdCase.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, FraudPrivConstants.REMOVE_CASE, paramArr);

			ssn.delete("fraud.remove-case", frdCase);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public SuiteCase[] getSuiteCases(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, FraudPrivConstants.VIEW_CASE, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, FraudPrivConstants.VIEW_CASE);
			List<SuiteCase> suiteCases = ssn.queryForList("fraud.get-suite-cases",
			        convertQueryParams(params, limitation));
			return suiteCases.toArray(new SuiteCase[suiteCases.size()]);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public int getSuiteCasesCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, FraudPrivConstants.VIEW_CASE, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, FraudPrivConstants.VIEW_CASE);
			return (Integer) ssn.queryForObject("fraud.get-suite-cases-count",
			        convertQueryParams(params, limitation));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public SuiteCase addSuiteCase(Long userSessionId, SuiteCase suiteCase) {
		SqlMapSession ssn = null;

		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(suiteCase.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, FraudPrivConstants.ADD_CASE, paramArr);

			ssn.insert("fraud.add-suite-case", suiteCase);

			Filter[] filters = new Filter[3];
			filters[0] = new Filter();
			filters[0].setElement("lang");
			filters[0].setValue(suiteCase.getLang());
			filters[1] = new Filter();
			filters[1].setElement("suiteId");
			filters[1].setValue(suiteCase.getSuiteId());
			filters[2] = new Filter();
			filters[2].setElement("caseId");
			filters[2].setValue(suiteCase.getCaseId());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (SuiteCase) ssn.queryForObject("fraud.get-suite-cases",
					convertQueryParams(params));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public SuiteCase modifySuiteCase(Long userSessionId, SuiteCase suiteCase) {
		SqlMapSession ssn = null;

		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(suiteCase.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, FraudPrivConstants.MODIFY_CASE, paramArr);
			
			ssn.update("fraud.modify-suite-case", suiteCase);
			
			return suiteCase;
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}
	

	public void removeSuiteCase(Long userSessionId, SuiteCase suiteCase) {
		SqlMapSession ssn = null;

		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(suiteCase.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, FraudPrivConstants.REMOVE_CASE, paramArr);

			ssn.delete("fraud.remove-suite-case", suiteCase);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public CaseEvent[] getCaseEvents(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, FraudPrivConstants.VIEW_CASE_EVENT, paramArr);

			List<CaseEvent> caseEvents = ssn.queryForList("fraud.get-case-events",
					convertQueryParams(params));
			return caseEvents.toArray(new CaseEvent[caseEvents.size()]);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public int getCaseEventsCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, FraudPrivConstants.VIEW_CASE_EVENT, paramArr);
			return (Integer) ssn.queryForObject("fraud.get-case-events-count",
					convertQueryParams(params));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public CaseEvent addCaseEvent(Long userSessionId, CaseEvent caseEvent) {
		SqlMapSession ssn = null;

		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(caseEvent.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, FraudPrivConstants.ADD_CASE_EVENT, paramArr);

			ssn.insert("fraud.add-case-event", caseEvent);

			Filter[] filters = new Filter[1];
			filters[0] = new Filter();
			filters[0].setElement("id");
			filters[0].setValue(caseEvent.getId());
			
			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (CaseEvent) ssn.queryForObject("fraud.get-case-events",
					convertQueryParams(params));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public CaseEvent modifyCaseEvent(Long userSessionId, CaseEvent caseEvent) {
		SqlMapSession ssn = null;

		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(caseEvent.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, FraudPrivConstants.MODIFY_CASE_EVENT, paramArr);
			
			ssn.update("fraud.modify-case-event", caseEvent);
			
			Filter[] filters = new Filter[1];
			filters[0] = new Filter();
			filters[0].setElement("id");
			filters[0].setValue(caseEvent.getId());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (CaseEvent) ssn.queryForObject("fraud.get-case-events",
					convertQueryParams(params));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}
	

	public void removeCaseEvent(Long userSessionId, CaseEvent caseEvent) {
		SqlMapSession ssn = null;

		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(caseEvent.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, FraudPrivConstants.REMOVE_CASE_EVENT, paramArr);

			ssn.delete("fraud.remove-case-event", caseEvent);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public Matrix[] getMatrices(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, FraudPrivConstants.VIEW_MATRIX, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, FraudPrivConstants.VIEW_MATRIX);
			List<Matrix> matrices = ssn.queryForList("fraud.get-matrices",
			        convertQueryParams(params, limitation));
			return matrices.toArray(new Matrix[matrices.size()]);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public int getMatricesCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, FraudPrivConstants.VIEW_MATRIX, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, FraudPrivConstants.VIEW_MATRIX);
			return (Integer) ssn.queryForObject("fraud.get-matrices-count",
			        convertQueryParams(params, limitation));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public Matrix addMatrix(Long userSessionId, Matrix matrix) {
		SqlMapSession ssn = null;

		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(matrix.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, FraudPrivConstants.ADD_MATRIX, paramArr);

			ssn.insert("fraud.add-matrix", matrix);

			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("lang");
			filters[0].setValue(matrix.getLang());
			filters[1] = new Filter();
			filters[1].setElement("id");
			filters[1].setValue(matrix.getId());
			
			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (Matrix) ssn.queryForObject("fraud.get-matrices",
					convertQueryParams(params));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public Matrix modifyMatrix(Long userSessionId, Matrix matrix) {
		SqlMapSession ssn = null;

		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(matrix.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, FraudPrivConstants.MODIFY_MATRIX, paramArr);
			
			ssn.update("fraud.modify-matrix", matrix);
			
			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("lang");
			filters[0].setValue(matrix.getLang());
			filters[1] = new Filter();
			filters[1].setElement("id");
			filters[1].setValue(matrix.getId());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (Matrix) ssn.queryForObject("fraud.get-matrices",
					convertQueryParams(params));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}
	

	public void removeMatrix(Long userSessionId, Matrix matrix) {
		SqlMapSession ssn = null;

		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(matrix.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, FraudPrivConstants.REMOVE_MATRIX, paramArr);

			ssn.delete("fraud.remove-matrix", matrix);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public MatrixValue[] getMatrixValues(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, FraudPrivConstants.VIEW_MATRIX_VALUE, paramArr);

			List<MatrixValue> matrixValues = ssn.queryForList("fraud.get-matrix-values",
					convertQueryParams(params));
			return matrixValues.toArray(new MatrixValue[matrixValues.size()]);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public int getMatrixValuesCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, FraudPrivConstants.VIEW_MATRIX_VALUE, paramArr);
			return (Integer) ssn.queryForObject("fraud.get-matrix-values-count",
					convertQueryParams(params));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public MatrixValue addMatrixValue(Long userSessionId, MatrixValue matrixValue) {
		SqlMapSession ssn = null;

		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(matrixValue.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, FraudPrivConstants.ADD_MATRIX_VALUE, paramArr);

			ssn.insert("fraud.add-matrix-value", matrixValue);

			return matrixValue;
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public MatrixValue modifyMatrixValue(Long userSessionId, MatrixValue matrixValue) {
		SqlMapSession ssn = null;

		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(matrixValue.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, FraudPrivConstants.MODIFY_MATRIX_VALUE, paramArr);
			
			ssn.update("fraud.modify-matrix-value", matrixValue);
			
			return matrixValue;
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}
	

	public void removeMatrixValue(Long userSessionId, MatrixValue matrixValue) {
		SqlMapSession ssn = null;

		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(matrixValue.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, FraudPrivConstants.REMOVE_MATRIX_VALUE, paramArr);

			ssn.delete("fraud.remove-matrix-value", matrixValue);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void saveMatrixValues(Long userSessionId, List<MatrixValue> newValues, 
			List<MatrixValue> editedValues, List<MatrixValue> deletedValues) {
		SqlMapSession ssn = null;

		try {
			ssn = getIbatisSessionFE(userSessionId);
			
			for (MatrixValue newValue: newValues) {
				ssn.insert("fraud.add-matrix-value", newValue);
			}
			for (MatrixValue editedValue: editedValues) {
				ssn.update("fraud.modify-matrix-value", editedValue);
			}
			for (MatrixValue deletedValue: deletedValues) {
				ssn.delete("fraud.remove-matrix-value", deletedValue);
			}
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public Check[] getChecks(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, FraudPrivConstants.VIEW_CHECK, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, FraudPrivConstants.VIEW_CHECK);
			List<Check> checks = ssn.queryForList("fraud.get-checks",
			        convertQueryParams(params, limitation));
			return checks.toArray(new Check[checks.size()]);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public int getChecksCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, FraudPrivConstants.VIEW_CHECK, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, FraudPrivConstants.VIEW_CHECK);
			return (Integer) ssn.queryForObject("fraud.get-checks-count",
			        convertQueryParams(params, limitation));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public Check addCheck(Long userSessionId, Check check) {
		SqlMapSession ssn = null;

		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(check.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, FraudPrivConstants.ADD_CHECK, paramArr);

			ssn.insert("fraud.add-check", check);

			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("lang");
			filters[0].setValue(check.getLang());
			filters[1] = new Filter();
			filters[1].setElement("id");
			filters[1].setValue(check.getId());
			
			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (Check) ssn.queryForObject("fraud.get-checks",
					convertQueryParams(params));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public Check modifyCheck(Long userSessionId, Check check) {
		SqlMapSession ssn = null;

		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(check.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, FraudPrivConstants.MODIFY_CHECK, paramArr);
			
			ssn.update("fraud.modify-check", check);
			
			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("lang");
			filters[0].setValue(check.getLang());
			filters[1] = new Filter();
			filters[1].setElement("id");
			filters[1].setValue(check.getId());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (Check) ssn.queryForObject("fraud.get-checks",
					convertQueryParams(params));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}
	

	public void removeCheck(Long userSessionId, Check check) {
		SqlMapSession ssn = null;

		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(check.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, FraudPrivConstants.REMOVE_CHECK, paramArr);

			ssn.delete("fraud.remove-check", check);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public FraudData[] getFraudData(Long userSessionId, SelectionParams params, String lang) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, FraudPrivConstants.VIEW_FRAUD_DATA, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, FraudPrivConstants.VIEW_FRAUD_DATA);
			List<FraudData> fraudData = ssn.queryForList("fraud.get-fraud-data",
					convertQueryParams(params, limitation));
			return fraudData.toArray(new FraudData[fraudData.size()]);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public int getFraudDataCount(Long userSessionId, SelectionParams params, String lang) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, FraudPrivConstants.VIEW_FRAUD_DATA, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, FraudPrivConstants.VIEW_FRAUD_DATA);
			return (Integer) ssn.queryForObject("fraud.get-fraud-data-count",
					convertQueryParams(params, limitation));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}
	

	@SuppressWarnings("unchecked")
	public FraudAlert[] getFraudAlertsProc(Long userSessionId, SelectionParams params, String tabName) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, FraudPrivConstants.VIEW_FRP_ALERTS, paramArr);
			QueryParams qparams = convertQueryParams(params);
			Map<String, Object> map = new HashMap<String, Object>();
			String limitation = CommonController.getLimitationByPriv(ssn,
					FraudPrivConstants.VIEW_FRP_ALERTS);
			if (limitation != null){
				List<Filter> filters = new ArrayList<Filter> (Arrays.asList(params.getFilters()));
				filters.add(new Filter("PRIVIL_LIMITATION", limitation));
				params.setFilters(filters.toArray(new Filter[filters.size()]));
			}
			map.put("firstRow", qparams.getRange().getStartPlusOne());
			map.put("lastRow", qparams.getRange().getEndPlusOne());
			map.put("params", params.getFilters());
			map.put("sortingTab", params.getSortElement());
			map.put("tabName", tabName);
			ssn.update("fraud.get-alerts-proc",map);
			List<FraudAlert> frauds = (List<FraudAlert>)map.get("alerts");
			return frauds.toArray(new FraudAlert[frauds.size()]);
		} catch (SQLException e) {
			throw new DataAccessException(e);
		} finally {
			close(ssn);
		}
	}


	public int getFraudAlertsCountProc(Long userSessionId, SelectionParams params, String tabName) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, FraudPrivConstants.VIEW_FRP_ALERTS, paramArr);
			Map<String, Object> map = new HashMap<String, Object>();
			String limitation = CommonController.getLimitationByPriv(ssn,
					FraudPrivConstants.VIEW_FRP_ALERTS);
			if (limitation != null){
				List<Filter> filters = new ArrayList<Filter> (Arrays.asList(params.getFilters()));
				filters.add(new Filter("PRIVIL_LIMITATION", limitation));
				map.put("params", filters.toArray(new Filter[filters.size()]));
			}else{
				map.put("params", params.getFilters());
			}
			map.put("tabName", tabName);
			ssn.update("fraud.get-alerts-count-proc",map);
			Integer count = (Integer)map.get("count");
			return count;
		} catch (SQLException e) {
			throw new DataAccessException(e);
		} finally {
			close(ssn);
		}
	}


	public void generatePackage(Long userSessionId) {
		SqlMapSession ssn = null;

		try {
			ssn = getIbatisSession(userSessionId, null, FraudPrivConstants.GENERATE_PACKAGE, null);
			ssn.update("fraud.generate-package");
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}
	

	@SuppressWarnings("unchecked")
	public FraudObject[] getFraudObjects(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, params.getPrivilege()!=null ? params.getPrivilege() : FraudPrivConstants.VIEW_FRAUD_DATA, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, params.getPrivilege()!=null ? params.getPrivilege() : FraudPrivConstants.VIEW_FRAUD_DATA);
			List<FraudObject> fraudObjects = ssn.queryForList("fraud.get-fraud-objects",
					convertQueryParams(params, limitation));
			return fraudObjects.toArray(new FraudObject[fraudObjects.size()]);
		} catch (SQLException e) {
			throw new DataAccessException(e);
		} finally {
			close(ssn);
		}
	}


	public int getFraudObjectCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, params.getPrivilege()!=null ? params.getPrivilege() : FraudPrivConstants.VIEW_FRAUD_DATA, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, params.getPrivilege()!=null ? params.getPrivilege() : FraudPrivConstants.VIEW_FRAUD_DATA);
			return (Integer) ssn.queryForObject("fraud.get-fraud-objects-count",
			        convertQueryParams(params, limitation));
		} catch (SQLException e) {
			throw new DataAccessException(e);
		} finally {
			close(ssn);
		}
	}
	

	@SuppressWarnings("unchecked")
	public MonitoredFraudAlert[] getMonitoredFraudAlerts(Long userSessionId, SelectionParams params, String tabName) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, FraudPrivConstants.VIEW_MONITORED_FRAUD, paramArr);
			
			QueryParams qparams = convertQueryParams(params);
			Map<String, Object> map = new HashMap<String, Object>();
			map.put("firstRow", qparams.getRange().getStartPlusOne());
			map.put("lastRow", qparams.getRange().getEndPlusOne());
			String limitation = CommonController.getLimitationByPriv(ssn,
					FraudPrivConstants.VIEW_MONITORED_FRAUD);
			if (limitation != null){
				List<Filter> filters = new ArrayList<Filter> 
				(Arrays.asList(params.getFilters()));
				filters.add(new Filter("PRIVIL_LIMITATION", limitation));
				params.setFilters(filters.toArray(new Filter[filters.size()]));
			}	
			map.put("params", params.getFilters());
			map.put("sorting", params.getSortElement());
			map.put("tabName", tabName);
			ssn.update("fraud.get-monitored-fraud-alerts",map);
			List<MonitoredFraudAlert> customers = (List<MonitoredFraudAlert>)map.get("alerts");
			return customers.toArray(new MonitoredFraudAlert[customers.size()]);
		} catch (SQLException e) {
			throw new DataAccessException(e);
		} finally {
			close(ssn);
		}
	}


	public int getMonitoredFraudAlertsCount(Long userSessionId, SelectionParams params, String tabName) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, FraudPrivConstants.VIEW_MONITORED_FRAUD, paramArr);
			
			Map<String, Object> map = new HashMap<String, Object>();
			String limitation = CommonController.getLimitationByPriv(ssn,
					FraudPrivConstants.VIEW_MONITORED_FRAUD);
			if (limitation != null){
				List<Filter> filters = new ArrayList<Filter> 
				(Arrays.asList(params.getFilters()));
				filters.add(new Filter("PRIVIL_LIMITATION", limitation));
				params.setFilters(filters.toArray(new Filter[filters.size()]));
			}	
			map.put("params", params.getFilters());	
			map.put("tabName", tabName);
			ssn.update("fraud.get-monitored-fraud-alerts-count",map);
			Integer count = (Integer)map.get("count");
			return count;
		} catch (SQLException e) {
			throw new DataAccessException(e);
		} finally {
			close(ssn);
		}
	}
	

	public MonitoredFraudAlert modifyFraud(Long userSessionId, MonitoredFraudAlert fraud) {
		SqlMapSession ssn = null;

		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(fraud.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, FraudPrivConstants.MODIFY_MONITORED_FRAUD, paramArr);
			
			ssn.update("fraud.modify-fraud", fraud);
			
			
			return fraud;
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}
	

	public FraudObject addSuiteObject(Long userSessionId, FraudObject fraud) {
		SqlMapSession ssn = null;

		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(fraud.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, FraudPrivConstants.MODIFY_FRAUD_OBJECT, paramArr);
			
			ssn.update("fraud.add-suite-object", fraud);
			
			
			Filter[] filters = new Filter[1];
			filters[0] = new Filter();
			filters[0].setElement("id");
			filters[0].setValue(fraud.getId());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (FraudObject) ssn.queryForObject("fraud.get-fraud-objects",
					convertQueryParams(params));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}
	

	public FraudObject modifySuiteObject(Long userSessionId, FraudObject fraud) {
		SqlMapSession ssn = null;

		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(fraud.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, FraudPrivConstants.MODIFY_FRAUD_OBJECT, paramArr);
			
			ssn.update("fraud.modify-suite-object", fraud);
			
			
			Filter[] filters = new Filter[1];
			filters[0] = new Filter();
			filters[0].setElement("id");
			filters[0].setValue(fraud.getId());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (FraudObject) ssn.queryForObject("fraud.get-fraud-objects",
					convertQueryParams(params));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}
}
