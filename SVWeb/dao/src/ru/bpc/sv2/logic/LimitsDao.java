package ru.bpc.sv2.logic;

import java.math.BigDecimal;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;


import org.apache.log4j.Logger;

import ru.bpc.sv2.common.CommonParamRec;
import ru.bpc.sv2.fcl.limits.Limit;
import ru.bpc.sv2.fcl.limits.LimitCounter;
import ru.bpc.sv2.fcl.limits.LimitPrivConstants;
import ru.bpc.sv2.fcl.limits.LimitRate;
import ru.bpc.sv2.fcl.limits.LimitType;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.Filter.Operator;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.controller.CommonController;
import ru.bpc.sv2.logic.utility.db.IbatisAware;
import ru.bpc.sv2.logic.utility.db.IbatisSessionCallback;
import ru.bpc.sv2.utils.AuditParamUtil;

import com.ibatis.sqlmap.client.SqlMapSession;

/**
 * Session Bean implementation class Cycles
 */
public class LimitsDao extends IbatisAware {

	private static final Logger logger = Logger.getLogger("FCL");


	public Limit getLimitById(Long userSessionId, Long limitId) {
		SelectionParams params = new SelectionParams();
		Filter[] filters = new Filter[1];
		filters[0] = new Filter();
		filters[0].setElement("id");
		filters[0].setOp(Operator.eq);
		filters[0].setValue(limitId.toString());

		params.setFilters(filters);
		Limit[] limits = getLimits(userSessionId, params);
		if (limits.length > 0) {
			return limits[0];
		}
		return null;
	}

	@SuppressWarnings("unchecked")
	public Limit[] getLimits(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, LimitPrivConstants.VIEW_LIMIT, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, LimitPrivConstants.VIEW_LIMIT);
			List<Limit> limits = ssn.queryForList("limits.get-limits", convertQueryParams(params, limitation));

			return limits.toArray(new Limit[limits.size()]);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	public int getLimitsCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, LimitPrivConstants.VIEW_LIMIT, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, LimitPrivConstants.VIEW_LIMIT);
			return (Integer) ssn.queryForObject("limits.get-limits-count",
					convertQueryParams(params, limitation));
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public Limit createLimit(Long userSessionId, Limit limit) {
		SqlMapSession ssn = null;

		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(limit.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, LimitPrivConstants.ADD_LIMIT, paramArr);

			ssn.insert("limits.insert-new-limit", limit);

			Filter[] filters = new Filter[1];
			filters[0] = new Filter();
			filters[0].setElement("id");
			filters[0].setValue(limit.getId().toString());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (Limit) ssn.queryForObject("limits.get-limits", convertQueryParams(params));
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public Limit updateLimit(Long userSessionId, Limit limit) {
		SqlMapSession ssn = null;

		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(limit.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, LimitPrivConstants.MODIFY_LIMIT, paramArr);

			ssn.update("limits.modify-limit", limit);

			Filter[] filters = new Filter[1];
			filters[0] = new Filter();
			filters[0].setElement("id");
			filters[0].setValue(limit.getId().toString());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (Limit) ssn.queryForObject("limits.get-limits", convertQueryParams(params));
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void deleteLimit(Long userSessionId, Limit limit) {
		SqlMapSession ssn = null;

		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(limit.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, LimitPrivConstants.REMOVE_LIMIT, paramArr);

			ssn.delete("limits.remove-limit", limit);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public LimitType[] getLimitTypes(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, LimitPrivConstants.VIEW_LIMIT_TYPE, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, LimitPrivConstants.VIEW_LIMIT_TYPE);
			List<LimitType> limitTypes = ssn.queryForList("limits.get-limit-types",
					convertQueryParams(params, limitation));

			return limitTypes.toArray(new LimitType[limitTypes.size()]);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	public int getLimitTypesCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, LimitPrivConstants.VIEW_LIMIT_TYPE, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, LimitPrivConstants.VIEW_LIMIT_TYPE);
			return (Integer) ssn.queryForObject("limits.get-limit-types-count",
					convertQueryParams(params, limitation));
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	public LimitType createLimitType(Long userSessionId, LimitType limitType) {
		SqlMapSession ssn = null;

		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(limitType.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, LimitPrivConstants.ADD_LIMIT_TYPE, paramArr);

			ssn.insert("limits.add-limit-type", limitType);

			Filter[] filters = new Filter[1];
			filters[0] = new Filter();
			filters[0].setElement("id");
			filters[0].setValue(limitType.getId().toString());
			filters[1] = new Filter();
			filters[1].setElement("lang");
			filters[1].setValue(limitType.getLang());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (LimitType) ssn.queryForObject("limits.get-limit-types",
					convertQueryParams(params));
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	public LimitType updateLimitType(Long userSessionId, LimitType limitType) {
		SqlMapSession ssn = null;

		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(limitType.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, LimitPrivConstants.MODIFY_LIMIT_TYPE, paramArr);

			ssn.insert("limits.modify-limit-type", limitType);

			Filter[] filters = new Filter[1];
			filters[0] = new Filter();
			filters[0].setElement("id");
			filters[0].setValue(limitType.getId().toString());
			filters[1] = new Filter();
			filters[1].setElement("lang");
			filters[1].setValue(limitType.getLang());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (LimitType) ssn.queryForObject("limits.get-limit-types",
					convertQueryParams(params));
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void deleteLimitType(Long userSessionId, LimitType limitType) {
		SqlMapSession ssn = null;

		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(limitType.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, LimitPrivConstants.REMOVE_LIMIT_TYPE, paramArr);

			ssn.delete("limits.remove-limit-type", limitType);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public LimitRate[] getLimitRates(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, LimitPrivConstants.VIEW_LIMIT_RATE, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, LimitPrivConstants.VIEW_LIMIT_RATE);
			List<LimitRate> limitRates = ssn.queryForList("limits.get-limit-rates",
					convertQueryParams(params, limitation));

			return limitRates.toArray(new LimitRate[limitRates.size()]);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public int getLimitRatesCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, LimitPrivConstants.VIEW_LIMIT_RATE, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, LimitPrivConstants.VIEW_LIMIT_RATE);
			return (Integer) ssn.queryForObject("limits.get-limit-rates-count",
					convertQueryParams(params, limitation));
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public LimitRate createLimitRate(Long userSessionId, LimitRate limitRate, String lang) {
		SqlMapSession ssn = null;

		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(limitRate.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, LimitPrivConstants.ADD_LIMIT_RATE, paramArr);

			ssn.insert("limits.add-limit-rate", limitRate);

			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("id");
			filters[0].setValue(limitRate.getId().toString());
			filters[1] = new Filter();
			filters[1].setElement("lang");
			filters[1].setValue(lang);

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (LimitRate) ssn.queryForObject("limits.get-limit-rates", convertQueryParams(params));
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public LimitRate editLimitRate(Long userSessionId, LimitRate limitRate) {
		SqlMapSession ssn = null;

		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(limitRate.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, LimitPrivConstants.MODIFY_LIMIT_RATE, paramArr);

			ssn.update("limits.modify-limit-rate", limitRate);

			return limitRate;
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void deleteLimitRate(Long userSessionId, LimitRate limitRate) {
		SqlMapSession ssn = null;

		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(limitRate.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, LimitPrivConstants.REMOVE_LIMIT_RATE, paramArr);

			ssn.delete("limits.remove-limit-rate", limitRate);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public LimitCounter[] getLimitCounters(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, LimitPrivConstants.VIEW_LIMIT_COUNTER, paramArr);

			List<LimitCounter> counters = ssn.queryForList("limits.get-limit-counters",
					convertQueryParams(params));

			return counters.toArray(new LimitCounter[counters.size()]);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public int getLimitCountersCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, LimitPrivConstants.VIEW_LIMIT_COUNTER, paramArr);
			return (Integer) ssn.queryForObject("limits.get-limit-counters-count",
					convertQueryParams(params));
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}
	
	@SuppressWarnings("unchecked")
	public LimitCounter[] getLimitCountersCur(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		LimitCounter [] result;
		try {
			Map<String, Object> map = new HashMap<String, Object>();
			Filter[] filters = params.getFilters();
			for (Filter filter : filters){
				map.put(filter.getElement(), filter.getValue());
			}
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(map);
			ssn = getIbatisSession(userSessionId, null, LimitPrivConstants.VIEW_LIMIT_COUNTER, paramArr);
			
			ssn.update("limits.get-limit-counters-cur", map);
			List<LimitCounter> counters = (ArrayList<LimitCounter>)map.get("ref_cur");
			result = counters.toArray(new LimitCounter [counters.size()]);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
		return result;
	}
	
	@SuppressWarnings("unchecked")
	public int getLimitCountersCurCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		LimitCounter [] result;
		result = getLimitCountersCur(userSessionId, params);
		if(result == null){
			return 0;
		} 
		return result.length;
	}


	@SuppressWarnings("unchecked")
	public BigDecimal convertAmount(Long userSessionId, final Map<String, Object> params) {
		return executeWithSession(userSessionId, logger, new IbatisSessionCallback<BigDecimal>() {
			@Override
			public BigDecimal doInSession(SqlMapSession ssn) throws Exception {
				ssn.queryForObject("limits.get-convert-amount", params);
				if (params.get("value") == null) {
					throw new SQLException("Failed to convert amount");
				}
				return (BigDecimal)params.get("value");
			}
		});
	}
}
