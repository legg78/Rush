package ru.bpc.sv2.logic;

import java.math.BigDecimal;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

import ru.bpc.sv2.logic.utility.db.DataAccessException;


import ru.bpc.sv2.common.CommonParamRec;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.loyalty.LotteryTicket;
import ru.bpc.sv2.logic.utility.db.IbatisAware;
import ru.bpc.sv2.loyalty.LoyaltyBonus;
import ru.bpc.sv2.loyalty.LoyaltyPrivConstants;
import ru.bpc.sv2.loyalty.LoyaltyProgram;
import ru.bpc.sv2.loyalty.LoyaltyOperation;
import ru.bpc.sv2.loyalty.LoyaltyOperationRequest;
import ru.bpc.sv2.operations.OperationPrivConstants;
import ru.bpc.sv2.utils.AuditParamUtil;

import com.ibatis.sqlmap.client.SqlMapSession;

/**
 * Session Bean implementation class PersonalizationDao
 */
public class LoyaltyDao extends IbatisAware {

	@SuppressWarnings("unchecked")
	public LoyaltyProgram[] getLoyaltyPrograms(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSessionFE(userSessionId);

			List<LoyaltyProgram> programs = ssn.queryForList("lty.get-programs",
					convertQueryParams(params));
			return programs.toArray(new LoyaltyProgram[programs.size()]);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public int getLoyaltyProgramsCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSessionFE(userSessionId);
			return (Integer) ssn.queryForObject("lty.get-programs-count",
					convertQueryParams(params));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public LoyaltyProgram addLoyaltyProgram(Long userSessionId, LoyaltyProgram program) {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSessionFE(userSessionId);

			ssn.update("lty.add-key-schema", program);

			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("id");
			filters[0].setValue(program.getId().toString());
			filters[1] = new Filter();
			filters[1].setElement("lang");
			filters[1].setValue(program.getLang());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (LoyaltyProgram) ssn.queryForObject("lty.get-programs",
					convertQueryParams(params));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public LoyaltyProgram modifyLoyaltyProgram(Long userSessionId, LoyaltyProgram program) {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSessionFE(userSessionId);

			ssn.update("lty.modify-program", program);

			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("id");
			filters[0].setValue(program.getId().toString());
			filters[1] = new Filter();
			filters[1].setElement("lang");
			filters[1].setValue(program.getLang());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (LoyaltyProgram) ssn.queryForObject("lty.get-programs",
					convertQueryParams(params));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void deleteLoyaltyProgram(Long userSessionId, LoyaltyProgram program) {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSessionFE(userSessionId);

			ssn.delete("lty.remove-program", program);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public LoyaltyBonus[] getLoyaltyBonuses(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, LoyaltyPrivConstants.VIEW_LOYALTY_BONUS, paramArr);

			List<LoyaltyBonus> bonuses = ssn.queryForList("lty.get-bonuses",
					convertQueryParams(params));
			return bonuses.toArray(new LoyaltyBonus[bonuses.size()]);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public int getLoyaltyBonusesCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, LoyaltyPrivConstants.VIEW_LOYALTY_BONUS, paramArr);
			Integer count = (Integer) ssn.queryForObject(
					"lty.get-bonuses-count", convertQueryParams(params));
			return count;
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public int getLotteryTicketsCount(Long userSessionId, SelectionParams params) throws DataAccessException {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, LoyaltyPrivConstants.VIEW_LOTTERY_TICKET, paramArr);
			return (Integer) ssn.queryForObject("lty.get-lottery-tickets-count", convertQueryParams(params));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public LotteryTicket[] getLotteryTickets(Long userSessionId, SelectionParams params) throws DataAccessException {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, LoyaltyPrivConstants.VIEW_LOTTERY_TICKET, paramArr);
			List<LotteryTicket> tickets = ssn.queryForList("lty.get-lottery-tickets", convertQueryParams(params));
			return tickets.toArray(new LotteryTicket[tickets.size()]);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public LotteryTicket addLotteryTicket(Long userSessionId, LotteryTicket ticket) throws DataAccessException {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSession(userSessionId, null, LoyaltyPrivConstants.ADD_LOTTERY_TICKET, null);
			ssn.insert("lty.add-lottery-ticket", ticket);
			return ticket;
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public LotteryTicket modifyLotteryTicket(Long userSessionId, LotteryTicket ticket) throws DataAccessException {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSession(userSessionId, null, LoyaltyPrivConstants.MODIFY_LOTTERY_TICKET, null);
			ssn.update("lty.modify-lottery-ticket", ticket);
			return ticket;
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void removeLotteryTicket(Long userSessionId, LotteryTicket ticket) throws DataAccessException {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSession(userSessionId, null, LoyaltyPrivConstants.REMOVE_LOTTERY_TICKET, null);
			ssn.delete("lty.remove-lottery-ticket", ticket);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public LoyaltyOperation[] getLoyaltyOperations(Long userSessionId, LoyaltyOperationRequest request) {
		SqlMapSession ssn = null;
		try {
			HashMap<String, Object> params = new HashMap<String, Object>();
			params.put("i_inst_id", request.getInstId());
			params.put("i_merchant_id", request.getMerchantId());
			params.put("i_status", request.getStatus());
			params.put("i_card_number", request.getCardNumber());
			params.put("i_auth_code", request.getAuthCode());
			params.put("i_start_date", request.getStartDate());
			params.put("i_end_date", request.getEndDate());
			if (null != request.getSpentOperationId())
				params.put("i_spent_operation", request.getSpentOperationId());
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params);
			ssn = getIbatisSession(userSessionId, null, OperationPrivConstants.VIEW_OPERATION, paramArr);
			ssn.update("lty.get-acq-operation", params);
			ArrayList<LoyaltyOperation> operations = (ArrayList<LoyaltyOperation>) params.get("o_ref_cursor");
			return operations.toArray(new LoyaltyOperation[operations.size()]);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void addSpentOperation(Long userSessionId, LoyaltyOperation[] selectedOperations, Long spentOperationId) {
		BigDecimal[] idTab = new BigDecimal[selectedOperations.length];
		for (int i = 0; i < selectedOperations.length; i++ ) {
			idTab[i] =  new BigDecimal(selectedOperations[i].getOperId());
		}
		SqlMapSession ssn = null;
		try {
			HashMap<String, Object> params = new HashMap<String, Object>();
			params.put("i_oper_id_tab", idTab);
			params.put("i_spent_operation", spentOperationId);
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params);
			ssn = getIbatisSession(userSessionId, null, OperationPrivConstants.ADD_ADJUSTMENT, paramArr);
			ssn.update("lty.add-spent-operation", params);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}
}
