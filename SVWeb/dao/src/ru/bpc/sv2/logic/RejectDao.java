package ru.bpc.sv2.logic;

import com.ibatis.sqlmap.client.SqlMapSession;
import oracle.jdbc.OracleTypes;
import org.apache.log4j.Logger;
import ru.bpc.sv2.common.ParticipantTableColumn;
import ru.bpc.sv2.common.TableColumn;
import ru.bpc.sv2.configuration.KeyValuePair;
import ru.bpc.sv2.enums.RejectFieldType;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.utility.db.IbatisAware;
import ru.bpc.sv2.ps.McRejectCode;
import ru.bpc.sv2.ps.RejectOperation;
import ru.bpc.sv2.ps.VisaRejectCode;

import ru.bpc.sv2.logic.utility.db.DataAccessException;

import java.math.BigDecimal;
import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;


public class RejectDao extends IbatisAware {
	private static Logger logger = Logger.getLogger("OPER_PROCESSING");


	public RejectOperation[] getRejectOperations(String module, Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSession(userSessionId);
			setModule(module, params);
			List<RejectOperation> items = ssn.queryForList("reject.get_rejects", convertQueryParams(params));
			return items.toArray(new RejectOperation[items.size()]);
		} catch (SQLException e) {
			logger.error("", e);
			throw new DataAccessException(e.getCause().getMessage());
		} finally {
			close(ssn);
		}
	}


	public long getRejectOperationsCount(String module, Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSessionNoContext();
			setModule(module, params);
			long count = (Long) ssn.queryForObject("reject.get_rejects_count", convertQueryParams(params));
			return count;
		} catch (SQLException e) {
			logger.error("", e);
			throw new DataAccessException(e.getCause().getMessage());
		} finally {
			close(ssn);
		}
	}

	private void setModule(String module, SelectionParams params) {
		if (module.equalsIgnoreCase("VISA")) {
			params.setModule("vis");
		} else {
			params.setModule("mcw");
		}
	}


	public List<TableColumn> getFields(String module, Long userSessionId, Long operId, RejectFieldType type) {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSession(userSessionId);
			Map<String, Object> params = new HashMap<String, Object>();
			params.put("id", operId);
			switch (type) {
				case ORIG_OPER:
					params.put("table", "opr_operation_unpivot_vw");
					break;
				case FIN_MESSAGE:
					if (module.equalsIgnoreCase("VISA")) {
						params.put("table", "vis_fin_message_unpivot_vw");
					} else {
						params.put("table", "mcw_fin_unpivot_vw");
					}
					break;
			}
			List<TableColumn> items = ssn.queryForList("reject.get_fields", params);
			return items;
		} catch (SQLException e) {
			logger.error("", e);
			throw new DataAccessException(e.getCause().getMessage());
		} finally {
			close(ssn);
		}
	}


	public List<ParticipantTableColumn> getParticipantFields(String module, Long userSessionId, Long operId) {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSession(userSessionId);
			List<ParticipantTableColumn> items = ssn.queryForList("reject.get_participant_fields", operId);
			return items;
		} catch (SQLException e) {
			logger.error("", e);
			throw new DataAccessException(e.getCause().getMessage());
		} finally {
			close(ssn);
		}
	}


	public void updateField(String module, Long userSessionId, TableColumn field, RejectFieldType type) {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSession(userSessionId);
			switch (type) {
				case GEN_FIELD:
					if (module.equalsIgnoreCase("VISA")) {
						module = "vis";
					} else {
						module = "mcw";
					}
					field.setTable(module + "_reject_data_vw");
					break;
				case ORIG_OPER:
					field.setTable("opr_operation_unpivot_vw");
					break;
				case PARTICIPANT:
					field.setTable("opr_participant_unpivot_vw");
					break;
				case FIN_MESSAGE:
					if (module.equalsIgnoreCase("VISA")) {
						field.setTable("vis_fin_message_unpivot_vw");
					} else {
						field.setTable("mcw_fin_unpivot_vw");
					}
					break;
			}
			if (type == RejectFieldType.GEN_FIELD) {
				ssn.update("reject.update_gen_field", field);
			} else {
				ssn.update("reject.update_field", field);
			}
		} catch (SQLException e) {
			logger.error("", e);
			throw new DataAccessException(e.getCause().getMessage());
		} finally {
			close(ssn);
		}
	}


	public void updateParticipantField(String module, Long userSessionId, ParticipantTableColumn field) {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSession(userSessionId);
			ssn.update("reject.update_participant_field", field);
		} catch (SQLException e) {
			logger.error("", e);
			throw new DataAccessException(e.getCause().getMessage());
		} finally {
			close(ssn);
		}
	}


	public List<VisaRejectCode> getVisaRejectCodes(Long userSessionId, Long rejectId) {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSession(userSessionId);
			List<VisaRejectCode> items = ssn.queryForList("reject.get_visa_reject_codes", rejectId);
			return items;
		} catch (SQLException e) {
			logger.error("", e);
			throw new DataAccessException(e.getCause().getMessage());
		} finally {
			close(ssn);
		}
	}


	public List<McRejectCode> getMcRejectCodes(Long userSessionId, Long rejectId) {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSession(userSessionId);
			List<McRejectCode> items = ssn.queryForList("reject.get_mc_reject_codes", rejectId);
			return items;
		} catch (SQLException e) {
			logger.error("", e);
			throw new DataAccessException(e.getCause().getMessage());
		} finally {
			close(ssn);
		}
	}


	public void assignUser(String module, Long userSessionId, Long rejectId, String userId) {
		SqlMapSession ssn = null;
		TableColumn tc = new TableColumn();
		try {
			ssn = getIbatisSession(userSessionId);
			if (module.equalsIgnoreCase("VISA")) {
				module = "vis";
			} else {
				module = "mcw";
			}
			tc.setTable(module + "_reject_data_vw");
			tc.setColumn("assigned");
			tc.setId(rejectId);
			tc.setValue(userId);
			ssn.update("reject.update_gen_field", tc);
		} catch (SQLException e) {
			logger.error("", e);
			throw new DataAccessException(e.getCause().getMessage());
		} finally {
			close(ssn);
		}
	}


	public void executeAction(Long userSessionId, Long operId, String action) {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSession(userSessionId);
			Map<String, Object> params = new HashMap<String, Object>();
			params.put("oper_id", operId);
			params.put("action", action);
			ssn.update("reject.exec_action", params);
		} catch (SQLException e) {
			logger.error("", e);
			throw new DataAccessException(e.getCause().getMessage());
		} finally {
			close(ssn);
		}
	}


	public List<KeyValuePair> getAllUsers(Long userSessionId, String userLang) {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSession(userSessionId);
			return ssn.queryForList("reject.get_all_users", userLang);
		} catch (SQLException e) {
			logger.error("", e);
			throw new DataAccessException(e.getCause().getMessage());
		} finally {
			close(ssn);
		}
	}


	public List<KeyValuePair> getGroups(Long userSessionId, Long operId, String userLang) {
		SqlMapSession ssn = null;
		CallableStatement cstm = null;
		ResultSet rs = null;
		try {
			ssn = getIbatisSession(userSessionId);
			Connection conn = ssn.getCurrentConnection();
			cstm = conn.prepareCall("{call COM_UI_REJECT_PKG.GET_LIST_OF_GROUP(i_id=>?, i_lang=>?, o_group_list=>?)}");
			cstm.setLong(1, operId);
			cstm.setString(2, userLang);
			cstm.registerOutParameter(3, OracleTypes.CURSOR);
			cstm.execute();
			rs = (ResultSet) cstm.getObject(3);
			if (rs == null) {
				return null;
			}
			List<KeyValuePair> list = new ArrayList<KeyValuePair>();
			while (rs.next()) {
				list.add(new KeyValuePair(String.valueOf(new BigDecimal(rs.getString("ELEMENT_VALUE")).longValue()),
						rs.getString("LABEL")));
			}
			return list;
		} catch (Exception e) {
			logger.error("", e);
			throw new DataAccessException(e.getCause().getMessage());
		} finally {
			try {
				if (rs != null) {
					rs.close();
				}
				if (cstm != null) {
					cstm.close();
				}
			} catch (Exception ex) {
			}
			close(ssn);
		}
	}


	public List<KeyValuePair> getGroupUsers(Long userSessionId, Long groupId, String userLang) {
		SqlMapSession ssn = null;
		CallableStatement cstm = null;
		ResultSet rs = null;
		try {
			ssn = getIbatisSession(userSessionId);
			Connection conn = ssn.getCurrentConnection();
			cstm = conn.prepareCall("{call COM_UI_REJECT_PKG.GET_LIST_OF_USER(i_group=>?, i_lang=>?, o_user_list=>?)}");
			cstm.setLong(1, groupId);
			cstm.setString(2, userLang);
			cstm.registerOutParameter(3, OracleTypes.CURSOR);
			cstm.execute();
			rs = (ResultSet) cstm.getObject(3);
			if (rs == null) {
				return null;
			}
			List<KeyValuePair> list = new ArrayList<KeyValuePair>();
			while (rs.next()) {
				list.add(new KeyValuePair(rs.getString("user_id"), rs.getString("user_name")));
			}
			return list;
		} catch (Exception e) {
			logger.error("", e);
			throw new DataAccessException(e.getCause().getMessage());
		} finally {
			try {
				if (rs != null) {
					rs.close();
				}
				if (cstm != null) {
					cstm.close();
				}
			} catch (Exception ex) {
			}
			close(ssn);
		}
	}
}
