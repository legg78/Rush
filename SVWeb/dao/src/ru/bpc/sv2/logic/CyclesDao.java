package ru.bpc.sv2.logic;

import java.sql.SQLException;
import java.util.List;


import org.apache.log4j.Logger;

import ru.bpc.sv2.common.CommonParamRec;
import ru.bpc.sv2.common.Dictionary;
import ru.bpc.sv2.constants.DictNames;
import ru.bpc.sv2.fcl.cycles.Cycle;
import ru.bpc.sv2.fcl.cycles.CycleCounter;
import ru.bpc.sv2.fcl.cycles.CyclePrivConstants;
import ru.bpc.sv2.fcl.cycles.CycleShift;
import ru.bpc.sv2.fcl.cycles.TreeCycleCounter;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.Filter.Operator;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.controller.CommonController;
import ru.bpc.sv2.logic.utility.db.IbatisAware;
import ru.bpc.sv2.utils.AuditParamUtil;

import com.ibatis.sqlmap.client.SqlMapSession;

/**
 * Session Bean implementation class Cycles
 */
public class CyclesDao extends IbatisAware {
	private static final Logger logger = Logger.getLogger("FCL");


	public Cycle getCycleById(Long userSessionId, Integer cycleId) {
		SelectionParams params = new SelectionParams();
		Filter[] filters = new Filter[1];
		filters[0] = new Filter();
		filters[0].setElement("id");
		filters[0].setOp(Operator.eq);
		filters[0].setValue(cycleId.toString());

		params.setFilters(filters);
		Cycle[] cycles = getCycles(userSessionId, params);
		if (cycles.length > 0) {
			return cycles[0];
		}
		return null;
	}

	@SuppressWarnings("unchecked")
	public Cycle[] getCycles(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, CyclePrivConstants.VIEW_CYCLE, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, CyclePrivConstants.VIEW_CYCLE);
			List<Cycle> cycles = ssn.queryForList("cycles.get-cycles", convertQueryParams(params, limitation));

			return cycles.toArray(new Cycle[cycles.size()]);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	public int getCyclesCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, CyclePrivConstants.VIEW_CYCLE, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, CyclePrivConstants.VIEW_CYCLE);
			return (Integer) ssn.queryForObject("cycles.get-cycles-count",
			        convertQueryParams(params, limitation));
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public Cycle createCycle(Long userSessionId, Cycle cycle, String lang) {
		SqlMapSession ssn = null;

		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(cycle.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, CyclePrivConstants.ADD_CYCLE, paramArr);
			ssn.insert("cycles.insert-new-cycle", cycle);

			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("id");
			filters[0].setValue(cycle.getId().toString());
			filters[1] = new Filter();
			filters[1].setElement("lang");
			filters[1].setValue(lang);

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (Cycle) ssn.queryForObject("cycles.get-cycles", convertQueryParams(params));
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public Cycle updateCycle(Long userSessionId, Cycle cycle) {
		SqlMapSession ssn = null;

		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(cycle.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, CyclePrivConstants.MODIFY_CYCLE, paramArr);

			ssn.update("cycles.modify-cycle", cycle);

			cycle.setSeqNum(cycle.getSeqNum() + 1);

			return cycle;
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void deleteCycle(Long userSessionId, Cycle cycle) {
		SqlMapSession ssn = null;

		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(cycle.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, CyclePrivConstants.REMOVE_CYCLE, paramArr);
			ssn.delete("cycles.remove-cycle", cycle);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@Deprecated
	public Dictionary createCycleType(Long userSessionId, Dictionary cycleType) {
		SqlMapSession ssn = null;

		try {
			ssn = getIbatisSessionFE(userSessionId);

			ssn.insert("cycles.add-cycle-type", cycleType);

			Filter[] filters = new Filter[3];
			filters[0] = new Filter();
			filters[0].setElement("dict");
			filters[0].setValue(DictNames.CYCLE_TYPES);
			filters[1] = new Filter();
			filters[1].setElement("code");
			filters[1].setValue(cycleType.getCode());
			filters[2] = new Filter();
			filters[2].setElement("lang");
			filters[2].setValue(cycleType.getLang());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (Dictionary) ssn.queryForObject("common.get-dictionaries",
					convertQueryParams(params));
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@Deprecated
	public Dictionary updateCycleType(Long userSessionId, Dictionary cycleType) {
		SqlMapSession ssn = null;

		try {
			ssn = getIbatisSessionFE(userSessionId);

			ssn.insert("cycles.add-cycle-type", cycleType);

			Filter[] filters = new Filter[3];
			filters[0] = new Filter();
			filters[0].setElement("dict");
			filters[0].setValue(DictNames.CYCLE_TYPES);
			filters[1] = new Filter();
			filters[1].setElement("code");
			filters[1].setValue(cycleType.getCode());
			filters[2] = new Filter();
			filters[2].setElement("lang");
			filters[2].setValue(cycleType.getLang());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (Dictionary) ssn.queryForObject("common.get-dictionaries",
					convertQueryParams(params));
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@Deprecated

	public void deleteCycleType(Long userSessionId, Dictionary cycleType) {
		SqlMapSession ssn = null;

		try {
			ssn = getIbatisSessionFE(userSessionId);
			String cycleTypeCode = cycleType.getDict() + cycleType.getCode();
			ssn.delete("cycles.remove-cycle-type", cycleTypeCode);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public CycleShift[] getCycleShifts(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, CyclePrivConstants.VIEW_CYCLE_SHIFT, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, CyclePrivConstants.VIEW_CYCLE_SHIFT);
			List<CycleShift> cycleShifts = ssn.queryForList("cycles.get-cycle-shifts",
			        convertQueryParams(params, limitation));

			return cycleShifts.toArray(new CycleShift[cycleShifts.size()]);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public CycleShift[] getCycleShiftsByCycle(Long userSessionId, int cycleId) {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSessionFE(userSessionId);

			List<CycleShift> cycleShifts = ssn.queryForList("cycles.get-cycle-shifts-by-cycle",
					cycleId);

			return cycleShifts.toArray(new CycleShift[cycleShifts.size()]);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	public int getCycleShiftsCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, CyclePrivConstants.VIEW_CYCLE_SHIFT, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, CyclePrivConstants.VIEW_CYCLE_SHIFT);
			return (Integer) ssn.queryForObject("cycles.get-cycle-shifts-count",
			        convertQueryParams(params, limitation));
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	public CycleShift createCycleShift(Long userSessionId, CycleShift cycleShift) {
		SqlMapSession ssn = null;

		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(cycleShift.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, CyclePrivConstants.ADD_CYCLE_SHIFT, paramArr);

			ssn.insert("cycles.insert-new-cycle-shift", cycleShift);

			Filter[] filters = new Filter[1];
			filters[0] = new Filter();
			filters[0].setElement("id");
			filters[0].setValue(cycleShift.getId().toString());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (CycleShift) ssn.queryForObject("cycles.get-cycle-shifts",
					convertQueryParams(params));
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	public CycleShift updateCycleShift(Long userSessionId, CycleShift cycleShift) {
		SqlMapSession ssn = null;

		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(cycleShift.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, CyclePrivConstants.MODIFY_CYCLE_SHIFT, paramArr);

			ssn.insert("cycles.modify-cycle-shift", cycleShift);

			Filter[] filters = new Filter[1];
			filters[0] = new Filter();
			filters[0].setElement("id");
			filters[0].setValue(cycleShift.getId().toString());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (CycleShift) ssn.queryForObject("cycles.get-cycle-shifts",
					convertQueryParams(params));
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void deleteCycleShift(Long userSessionId, CycleShift cycleShift) {
		SqlMapSession ssn = null;

		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(cycleShift.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, CyclePrivConstants.REMOVE_CYCLE_SHIFT, paramArr);
			ssn.delete("cycles.remove-cycle-shift", cycleShift);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public CycleCounter[] getCycleCounters(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, CyclePrivConstants.VIEW_CYCLE_COUNTER, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, CyclePrivConstants.VIEW_CYCLE_COUNTER);
			List<CycleCounter> counters = ssn.queryForList("cycles.get-cycle-counters",
					convertQueryParams(params, limitation));

			return counters.toArray(new CycleCounter[counters.size()]);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public int getCycleCountersCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, CyclePrivConstants.VIEW_CYCLE_COUNTER, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, CyclePrivConstants.VIEW_CYCLE_COUNTER);
			return (Integer) ssn.queryForObject("cycles.get-cycle-counters-count",
					convertQueryParams(params, limitation));
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}
	

	public void switchCycle(Long userSessionId, CycleCounter cycleCounter) {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSession(userSessionId);
			ssn.update("switch-cycle-by-payment-order", cycleCounter);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}
	

	public CycleCounter modifyCycleCounter(Long userSessionId, CycleCounter editingItem){
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSessionFE(userSessionId);
			ssn.update("cycles.modify-cycle-counter", editingItem);
			SelectionParams sp = new SelectionParams(
					new Filter("id", editingItem.getId())
					);
			CycleCounter result = (CycleCounter) ssn.queryForObject("cycles.get-cycle-counters", convertQueryParams(sp));
			return result;
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}
	
	@SuppressWarnings("unchecked")
	public TreeCycleCounter[] getCardCycleCounters(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, CyclePrivConstants.VIEW_CYCLE_COUNTER, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, CyclePrivConstants.VIEW_CYCLE_COUNTER);
			List<TreeCycleCounter> counters = ssn.queryForList("cycles.get-card-cycle-counters",
					convertQueryParams(params, limitation));

			return counters.toArray(new TreeCycleCounter[counters.size()]);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}
	
	@SuppressWarnings("unchecked")
	public TreeCycleCounter[] getAccountCycleCounters(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, CyclePrivConstants.VIEW_CYCLE_COUNTER, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, CyclePrivConstants.VIEW_CYCLE_COUNTER);
			List<TreeCycleCounter> counters = ssn.queryForList("cycles.get-account-cycle-counters",
					convertQueryParams(params, limitation));

			return counters.toArray(new TreeCycleCounter[counters.size()]);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}
	
}
