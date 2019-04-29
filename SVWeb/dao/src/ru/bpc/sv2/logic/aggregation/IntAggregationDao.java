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


public class IntAggregationDao extends ModuleDao {

	public AggrType[] getAggrTypes(int networkId, SelectionParams params) throws Exception {
		params.setNetworkId(networkId);
		List<AggrType> list = getItems("int_aggregation.get_aggr_types", params);
		return list.toArray(new AggrType[list.size()]);
	}


	public long getAggrTypesCount(int networkId, SelectionParams params) throws Exception {
		params.setNetworkId(networkId);
		return getCount("int_aggregation.get_aggr_types_cnt", params);
	}


	public void saveAggrType(int networkId, AggrType type, boolean update) throws Exception {
		type.setNetworkId(networkId);
		if (update) {
			update("int_aggregation.update_aggr_type", type);
		} else {
			insert("int_aggregation.insert_aggr_type", type);
		}
	}


	public long getNewTypeId() {
		return getSeqVal("int_aggregation.new_type_id");
	}


	public void deleteAggrType(long typeId) throws Exception {
		delete("int_aggregation.delete_rules_for_type", String.valueOf(typeId));
		delete("int_aggregation.delete_aggr_type", String.valueOf(typeId));
	}


	public List<AggrRule> getAggrRules(long aggrTypeId) throws Exception {
		SelectionParams params = new SelectionParams();
		Filter filter = new Filter();
		filter.setElement("aggr_type_id");
		filter.setValue(aggrTypeId);
		params.setFilters(new Filter[]{filter});
		return getItems("int_aggregation.get_aggr_rules", params);
	}


	public void saveAggrRule(AggrRule rule, boolean update) throws Exception {
		if (update) {
			update("int_aggregation.update_aggr_rule", rule);
		} else {
			insert("int_aggregation.insert_aggr_rule", rule);
		}
	}


	public long getNewRuleId() {
		return getSeqVal("int_aggregation.new_rule_id");
	}


	public void deleteAggrRule(long ruleId) throws Exception {
		delete("int_aggregation.delete_aggr_rule", String.valueOf(ruleId));
	}


	public List<Map<String, Object>> getAggregationResults(long typeId)
			throws Exception {
		Map<String, Object> map = new HashMap<String, Object>();
		map.put("type_id", typeId);
		List<String> columns = getItems("int_aggregation.get_aggr_result_columns", map);
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
					"SELECT * FROM (SELECT p.field, pv.value, v.count, v.value as sum, v.currency, pv.value_id as id " +
							"FROM agr_param_value pv INNER JOIN agr_parameter p ON(pv.param_id=p.id)" +
							"INNER JOIN agr_value v ON (pv.value_id=v.id) WHERE pv.type_id=%d) PIVOT(MAX(value) FOR field IN (%s))",
					typeId, cols.toString());
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


	public List<String> getResultColumns(long typeId) {
		Map<String, Object> map = new HashMap<String, Object>();
		map.put("type_id", typeId);
		return getItems("int_aggregation.get_aggr_result_columns", map);
	}


	public Map<String, String> getResultColumnsMap(long typeId) {
		String sql = String.format(
				"SELECT DISTINCT p.field, p.name FROM agr_param_value pv INNER JOIN agr_parameter p ON(pv.param_id=p.id) WHERE pv.type_id = %d",
				typeId);
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


	public boolean isRulesValid(long typeId) {
		SelectionParams params = new SelectionParams();
		Filter filter = new Filter();
		filter.setElement("aggr_type_id");
		filter.setValue(typeId);
		params.setFilters(new Filter[]{filter});
		return getCount("int_aggregation.validate_rules", params) == 2L;
	}


	public List<AggrParam> getAggrParams(int networkId) throws Exception {
		SelectionParams params=new SelectionParams();
		params.setNetworkId(networkId);
		return getItems("int_aggregation.get_aggr_params", params);
	}
}
