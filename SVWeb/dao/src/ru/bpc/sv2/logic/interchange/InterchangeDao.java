package ru.bpc.sv2.logic.interchange;

import com.ibatis.sqlmap.client.SqlMapSession;
import org.apache.log4j.Logger;
import ru.bpc.sv2.interchange.*;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.utils.DBUtils;
import ru.bpc.sv2.logic.utility.db.IbatisAware;


import java.sql.*;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;


@SuppressWarnings("unchecked")
public class InterchangeDao extends IbatisAware {
	public static final String MODULES_WITH_OPERATIONS_AS_VIEWS = "AMX,CUP,DIN,JCB,MCW,MUP,NBC,VIS";
	public static final String CORE_MODULES = "AMX,CUP,DIN,JCB,MCW,MUP,VIS";
	public static final String MODULES_WHICH_NEEDS_DATASOURCE = "";

	private static final Logger logger = Logger.getLogger(InterchangeDao.class);
	private static final String USER = "ADMIN";


	public void saveFee(long sessionId, List<InterchangeResult> results, String newOperStatus) throws Exception {
		logger.info("Start saving fees for " + results.size() + " operations");
		if (results.isEmpty()) {
			logger.info("Result is empty");
			return;
		}
		SqlMapSession ssn = null;
		Connection conn;
		CallableStatement cstmt = null;
		PreparedStatement insertPstm;
		PreparedStatement operIdPstm = null;
		try {
			ssn = getIbatisSession(sessionId, USER);
			conn = ssn.getCurrentConnection();
			boolean useRrn = results.get(0).getRrn() != null;
			String sql;
			if (newOperStatus != null) {
				if (useRrn) {
					sql = "{call UPDATE opr_operation SET status=? WHERE originator_refnum=? RETURNING id INTO ?}";
				} else {
					sql = "{call UPDATE opr_operation SET status=? WHERE id=? RETURNING id INTO ?}";
				}
				cstmt = conn.prepareCall(sql);
			} else if (useRrn) {
				operIdPstm = conn.prepareStatement("SELECT id FROM opr_operation WHERE originator_refnum=?");
			}
			insertPstm = conn.prepareStatement(
					"INSERT INTO opr_additional_amount(oper_id, amount_type, currency, amount) VALUES(?,?,?,?)");
			List<Long> operIds = new ArrayList<Long>();
			long operId;
			int i = 0;
			for (InterchangeResult r : results) {
				if (cstmt != null) {
					cstmt.setString(1, newOperStatus);
					if (useRrn) {
						cstmt.setString(2, r.getRrn());
					} else {
						cstmt.setLong(2, r.getOperId());
					}
					cstmt.registerOutParameter(3, Types.NUMERIC);
					int result = cstmt.executeUpdate();
					if (result > 0) {
						operId = cstmt.getLong(3);
						operIds.add(operId);
					} else {
						throw new Exception(
								"Operation is not found. Oper ID = " + r.getOperId() + "; RRN=" + r.getRrn());
					}
				} else if (useRrn) {
					assert operIdPstm != null;
					operIdPstm.setString(1, r.getRrn());
					ResultSet rs = operIdPstm.executeQuery();
					if (rs.next()) {
						operId = rs.getLong("id");
					} else {
						throw new Exception(
								"Operation is not found. Oper ID = " + r.getOperId() + "; RRN=" + r.getRrn());
					}
				} else {
					operId = r.getOperId();
				}
				operIds.add(operId);
				insertPstm.setLong(1, operId);
				insertPstm.setString(2, r.getFeeType());
				insertPstm.setString(3, r.getFeeCurrency());
				insertPstm.setBigDecimal(4, r.getFeeAmount());
				insertPstm.addBatch();
				i++;
				if (i == 300) {
					insertPstm.executeBatch();
					i = 0;
				}
			}
			if (i > 0) {
				insertPstm.executeBatch();
				i = 0;
			}
			ssn.startBatch();
			for (Long opId : operIds) {
				ssn.insert("interchange.insert_oper_stage", opId);
				i++;
				if (i == 300) {
					ssn.executeBatch();
					i = 0;
				}
			}
			if (i > 0) {
				ssn.executeBatch();
			}
			logger.info("Updates executed");
		} catch (SQLException ex) {
			logger.error("Error saving package", ex);
			throw createDaoException(ex);
		} finally {
			DBUtils.close(cstmt);
			close(ssn);
		}

	}


	public Fee[] getFees(String module, SelectionParams params) throws Exception {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSessionNoContext();
			params.setModule(module);
			List<Fee> items = ssn.queryForList("interchange.get_fees", convertQueryParams(params));
			return items.toArray(new Fee[items.size()]);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	public List<Fee> getFees(String module) throws Exception {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSessionNoContext();
			return ssn.queryForList("interchange.get_all_fees", module);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public long getFeesCount(String module, SelectionParams params) throws Exception {
		return getCount(module, "interchange.get_fees_count", params);
	}


	public List<CalculatedFee> getCalculatedFees(String module, long operId) throws Exception {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSessionNoContext();
			Map<String, Object> map = new HashMap<String, Object>();
			map.put("oper_id", operId);
			map.put("module", module);
			return ssn.queryForList("interchange.get_calculated_fees", map);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public List<FeeCriteria> getFeeCriterias(String module, long feeId) throws Exception {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSessionNoContext();
			Map<String, String> map = new HashMap<String, String>();
			map.put("fee_id", String.valueOf(feeId));
			map.put("module", module);
			return ssn.queryForList("interchange.get_fee_criterias", map);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public FeeCriteria[] getFeeCriterias(String module, SelectionParams params) throws Exception {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSessionNoContext();
			params.setModule(module);
			List<FeeCriteria> items =
					ssn.queryForList("interchange.get_fee_criterias_array", convertQueryParams(params));
			return items.toArray(new FeeCriteria[items.size()]);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void saveFeeCriteria(String module, FeeCriteria tree, boolean update) throws Exception {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSessionNoContext();
			tree.setModule(module);
			if (update) {
				ssn.update("interchange.update_fee_criteria", tree);
			} else {
				ssn.insert("interchange.insert_fee_criteria", tree);
			}
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void cloneFeeCriteria(String module, FeeCriteria tree) throws Exception {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSessionNoContext();
			tree.setModule(module);
			Long id = (Long) ssn.queryForObject("interchange.new_fee_criteria_id", module);
			tree.setId(id);
			ssn.insert("interchange.insert_fee_criteria_with_id", tree);
			saveChildren(ssn, module, tree);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	private void saveChildren(SqlMapSession ssn, String module, FeeCriteria parent) throws Exception {
		List<FeeCriteria> children = parent.getChildren();
		if (children != null) {
			for (FeeCriteria fc : children) {
				fc.setParentId(parent.getId());
				Long id = (Long) ssn.queryForObject("interchange.new_fee_criteria_id", module);
				fc.setId(id);
				fc.setModule(module);
				ssn.insert("interchange.insert_fee_criteria_with_id", fc);
				saveChildren(ssn, module, fc);
			}
		}
	}


	public void deleteFeeCriteria(String module, long rootId) throws Exception {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSessionNoContext();
			Map<String, String> map = new HashMap<String, String>();
			map.put("fee_criteria_id", String.valueOf(rootId));
			map.put("module", module);
			ssn.delete("interchange.delete_fee_criteria", map);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public List<CommonOperation> getOperations(String module, SelectionParams params) throws Exception {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSessionNoContext();
			params.setModule(module);
			if (MODULES_WITH_OPERATIONS_AS_VIEWS.contains(module)) {
				params.setTableSuffix("_vw");
				params.setModule(module + "_ui");
				return ssn.queryForList("interchange.get_operations_nofee", convertQueryParams(params));
			} else {
				return ssn.queryForList("interchange.get_operations", convertQueryParams(params));
			}
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public long getOperationsCount(String module, SelectionParams params) throws Exception {
		return getCount(module, "interchange.get_operations_count", params);
	}


	public void deleteFee(String module, long feeId) throws Exception {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSessionNoContext();
			Map<String, String> map = new HashMap<String, String>();
			map.put("fee_id", String.valueOf(feeId));
			map.put("module", module);
			ssn.delete("interchange.delete_fee", map);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void saveFee(String module, Fee fee, boolean update) throws Exception {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSessionNoContext();
			fee.setModule(module);
			if (update) {
				ssn.update("interchange.update_fee", fee);
			} else {
				ssn.insert("interchange.insert_fee", fee);
			}
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public Fee getFee(String module, long feeId) throws Exception {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSessionNoContext();
			Map<String, String> map = new HashMap<String, String>();
			map.put("fee_id", String.valueOf(feeId));
			map.put("module", module);
			return (Fee) ssn.queryForObject("interchange.get_fee", map);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	private long getCount(String module, String queryId, SelectionParams params) throws Exception {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSessionNoContext();
			params.setModule(module);
			if (MODULES_WITH_OPERATIONS_AS_VIEWS.contains(module)) {
				params.setTableSuffix("_vw");
				params.setModule(module + "_ui");
			}
			return (Long) ssn.queryForObject(queryId, convertQueryParams(params));
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}
}
