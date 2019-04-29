package ru.bpc.sv2.logic.aggregation;

import com.ibatis.sqlmap.client.SqlMapSession;
import ru.bpc.sv2.aggregation.AggrParam;
import ru.bpc.sv2.aggregation.AggrRule;
import ru.bpc.sv2.aggregation.AggrType;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.ModuleDao;
import ru.bpc.sv2.logic.utility.db.DataAccessException;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;


public class AggregationDao extends ModuleDao {

	public AggrType[] getAggrTypes(String module, SelectionParams params) throws Exception {
		List<AggrType> list = getItems(module, "aggregation.get_aggr_types", params);
		return list.toArray(new AggrType[list.size()]);
	}


	public long getAggrTypesCount(String module, SelectionParams params) throws Exception {
		return getCount(module, "aggregation.get_aggr_types_cnt", params);
	}


	public void saveAggrType(String module, AggrType type, boolean update) throws Exception {
		if (update) {
			update(module, "aggregation.update_aggr_type", type);
		} else {
			insert(module, "aggregation.insert_aggr_type", type);
		}
	}


	public long getNewTypeId() {
		return getSeqVal("aggregation.new_type_id");
	}


	public void deleteAggrType(String module, long typeId) throws Exception {
		delete(module, "aggregation.delete_rules_for_type", String.valueOf(typeId));
		delete(module, "aggregation.delete_aggr_type", String.valueOf(typeId));
	}


	public List<AggrRule> getAggrRules(String module, long aggrTypeId) throws Exception {
		SelectionParams params = new SelectionParams();
		Filter filter = new Filter();
		filter.setElement("aggr_type_id");
		filter.setValue(aggrTypeId);
		params.setFilters(new Filter[]{filter});
		return getItems(module, "aggregation.get_aggr_rules", params);
	}


	public void saveAggrRule(String module, AggrRule rule, boolean update) throws Exception {
		if (update) {
			update(module, "aggregation.update_aggr_rule", rule);
		} else {
			insert(module, "aggregation.insert_aggr_rule", rule);
		}
	}


	public long getNewRuleId() {
		return getSeqVal("aggregation.new_rule_id");
	}


	public void deleteAggrRule(String module, long ruleId) throws Exception {
		delete(module, "aggregation.delete_aggr_rule", String.valueOf(ruleId));
	}


	public List<Map<String, Object>> getAggregationResults(String module, long typeId)
			throws Exception {
		Map<String, Object> map = new HashMap<String, Object>();
		map.put("type_id", typeId);
		List<String> columns = getItems(module, "aggregation.get_aggr_result_columns", map);
		if (columns.isEmpty()) {
			return null;
		}
		StringBuilder cols = new StringBuilder();
		for (String c : columns) {
			cols.append('\'');
			cols.append(c);
			cols.append("',");
		}
		cols.setLength(cols.length() - 1);
		SqlMapSession ssn = null;
		PreparedStatement pstm = null;
		ResultSet rs = null;
		try {
			ssn = getIbatisSessionNoContext();
			String sql = String.format(
					"SELECT * FROM (SELECT p.field, pv.value, v.count, v.sum, v.currency, pv.aggr_value_id as id " +
							"FROM %s_aggr_param_value pv INNER JOIN %s_aggr_param p ON(pv.param_id=p.id)" +
							"INNER JOIN %s_aggr_value v ON (pv.aggr_value_id=v.id) WHERE pv.aggr_type_id=%d) PIVOT(MAX(value) FOR field IN (%s))",
					module, module, module, typeId, cols.toString());
			pstm = ssn.getCurrentConnection().prepareStatement(sql);
			rs = pstm.executeQuery();
			List<Map<String, Object>> result = new ArrayList<Map<String, Object>>();
			while (rs.next()) {
				Map<String, Object> row = new HashMap<String, Object>();
				for (int i = 1; i <= rs.getMetaData().getColumnCount(); i++) {
					row.put(rs.getMetaData().getColumnName(i).replaceAll("\'", ""), rs.getObject(i));
				}
				result.add(row);
			}
			return result;
		} catch (SQLException e) {
			logger.error("", e);
			throw new DataAccessException(e.getCause().getMessage());
		} finally {
			if (pstm != null) {
				pstm.close();
			}
			if (rs != null) {
				rs.close();
			}
			close(ssn);
		}
	}


	public List<String> getResultColumns(String module, long typeId) {
		Map<String, Object> map = new HashMap<String, Object>();
		map.put("type_id", typeId);
		return getItems(module, "aggregation.get_aggr_result_columns", map);
	}


	public Map<String, String> getResultColumnsMap(String module, long typeId) {
		String sql = String.format(
				"SELECT DISTINCT p.field, p.name FROM %s_aggr_param_value pv INNER JOIN %s_aggr_param p ON(pv.param_id=p.id) WHERE pv.aggr_type_id = %d",
				module, module, typeId);
		SqlMapSession ssn = null;
		PreparedStatement pstm = null;
		ResultSet rs = null;
		try {
			ssn = getIbatisSessionNoContext();
			pstm = ssn.getCurrentConnection().prepareStatement(sql);
			rs = pstm.executeQuery();
			Map<String, String> result = new HashMap<String, String>();
			while (rs.next()) {
				result.put(rs.getString("field"), rs.getString("name"));
			}
			return result;
		} catch (SQLException e) {
			logger.error("", e);
			throw new DataAccessException(e.getCause().getMessage());
		} finally {
			try {
				if (pstm != null) {
					pstm.close();
				}
				if (rs != null) {
					rs.close();
				}
			} catch (Exception e) {
			}
			close(ssn);
		}
	}


	public boolean isRulesValid(String module, long typeId) {
		SelectionParams params = new SelectionParams();
		Filter filter = new Filter();
		filter.setElement("aggr_type_id");
		filter.setValue(typeId);
		params.setFilters(new Filter[]{filter});
		return getCount(module, "aggregation.validate_rules", params) == 2L;
	}


	public List<AggrParam> getAggrParams(String module) throws Exception {
		return getItems(module, "aggregation.get_aggr_params", new SelectionParams());
	}
}
