package ru.bpc.sv2.logic;

import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import ru.bpc.sv2.logic.utility.db.DataAccessException;


import org.apache.log4j.Logger;

import ru.bpc.sv2.accounts.AccountPrivConstants;
import ru.bpc.sv2.acquiring.AccountPattern;
import ru.bpc.sv2.acquiring.AccountScheme;
import ru.bpc.sv2.acquiring.AcquiringPrivConstants;
import ru.bpc.sv2.acquiring.MCC;
import ru.bpc.sv2.acquiring.MccSelection;
import ru.bpc.sv2.acquiring.MccSelectionTpl;
import ru.bpc.sv2.acquiring.Merchant;
import ru.bpc.sv2.acquiring.MerchantType;
import ru.bpc.sv2.acquiring.RevenueSharing;
import ru.bpc.sv2.acquiring.Terminal;
import ru.bpc.sv2.acquiring.reimbursement.ReimbursementBatchEntry;
import ru.bpc.sv2.acquiring.reimbursement.ReimbursementChannel;
import ru.bpc.sv2.acquiring.reimbursement.ReimbursementOperation;
import ru.bpc.sv2.atm.TerminalATM;
import ru.bpc.sv2.cmn.CmnPrivConstants;
import ru.bpc.sv2.cmn.TcpIpDevice;
import ru.bpc.sv2.common.CommonParamRec;
import ru.bpc.sv2.common.Parameter;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.issuing.Card;
import ru.bpc.sv2.issuing.IssuingPrivConstants;
import ru.bpc.sv2.logic.controller.CommonController;
import ru.bpc.sv2.logic.utility.db.IbatisAware;
import ru.bpc.sv2.logic.utility.db.IbatisSessionCallback;
import ru.bpc.sv2.logic.utility.db.QueryParams;
import ru.bpc.sv2.utils.AuditParamUtil;

import com.ibatis.sqlmap.client.SqlMapSession;

/**
 * Session Bean implementation class AcquiringDao
 */
public class AcquiringDao extends IbatisAware {

	private static final Logger logger = Logger.getLogger("ACQUIRING");


	@SuppressWarnings("unchecked")
	public Terminal[] getTerminals(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, AcquiringPrivConstants.VIEW_TERMINAL, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn,
					AcquiringPrivConstants.VIEW_TERMINAL);
			List<Terminal> terminals = ssn.queryForList("acquiring.get-terminals",
					convertQueryParams(params, limitation));
			return terminals.toArray(new Terminal[terminals.size()]);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}
	

	@SuppressWarnings("unchecked")
	public Terminal[] getTerminals(SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSessionNoContext();
			List<Terminal> terminals = ssn.queryForList("acquiring.get-terminals-sys",
					convertQueryParams(params));
			return terminals.toArray(new Terminal[terminals.size()]);
			
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}
	

	@SuppressWarnings("unchecked")
	public Terminal[] getTerminalsCur(Long userSessionId,
			SelectionParams params, HashMap<String, Object> map) {
		Terminal [] result;
		SqlMapSession ssn = null;
		try{
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, null, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn,
					AcquiringPrivConstants.VIEW_TERMINAL);
			List<Filter> filters = new ArrayList<Filter> (Arrays.asList(params.getFilters()));
			filters.add(new Filter("PRIVIL_LIMITATION", limitation));
			params.setFilters(filters.toArray(new Filter[filters.size()]));
			QueryParams qparams = convertQueryParams(params);
            map.put("row_count", params.getRowCount());
			map.put("first_row", qparams.getRange().getStartPlusOne());
			map.put("param_tab", filters.toArray(new Filter[filters.size()]));
			map.put("last_row", qparams.getRange().getEndPlusOne());
			map.put("sorting_tab", params.getSortElement());
			ssn.update("acquiring.get-terminals-cur", map);
			List <Terminal>terminals = (List<Terminal>)map.get("ref_cur");
			result = terminals.toArray(new Terminal[terminals.size()]);
		}catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
		return result;
	}


	public int getTerminalsCountCur(Long userSessionId,
			HashMap<String, Object> params) {
		Integer result = 0;
		SqlMapSession ssn = null;
		try{
			ssn = getIbatisSession(userSessionId);
			String limitation = CommonController.getLimitationByPriv(ssn,
					AcquiringPrivConstants.VIEW_TERMINAL);
			List<Filter> filters = new ArrayList<Filter> 
				(Arrays.asList((Filter[])params.get("param_tab")));
			filters.add(new Filter("PRIVIL_LIMITATION", limitation));
			params.put("param_tab", filters.toArray(new Filter[filters.size()]));
			ssn.update("acquiring.get-terminals-cur-count", params);
			result = (Integer)params.get("row_count");
		}catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
		return result;
	}


	public int getTerminalsCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, AcquiringPrivConstants.VIEW_TERMINAL, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn,
					AcquiringPrivConstants.VIEW_TERMINAL);
			return (Integer) ssn.queryForObject("acquiring.get-terminals-count",
					convertQueryParams(params, limitation));
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	@SuppressWarnings("unchecked")
	public Terminal[] getTerminalTemplates(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, AcquiringPrivConstants.VIEW_TERMINAL_TEMPLATE, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn,
					AcquiringPrivConstants.VIEW_TERMINAL_TEMPLATE);
			List<Terminal> templs = ssn.queryForList("acquiring.get-terminal-templates",
					convertQueryParams(params, limitation));
			return templs.toArray(new Terminal[templs.size()]);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public int getTerminalTemplatesCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, AcquiringPrivConstants.VIEW_TERMINAL_TEMPLATE, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn,
					AcquiringPrivConstants.VIEW_TERMINAL_TEMPLATE);
			return (Integer) ssn.queryForObject("acquiring.get-terminal-templates-count",
					convertQueryParams(params, limitation));
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public Terminal addTerminalTemplate(Long userSessionId, Terminal template) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(template.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, AcquiringPrivConstants.ADD_TERMINAL_TEMPLATE, paramArr);

			ssn.insert("acquiring.add-terminal-template", template);

			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("id");
			filters[0].setValue(template.getId().toString());
			filters[1] = new Filter();
			filters[1].setElement("lang");
			filters[1].setValue(template.getLang());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (Terminal) ssn.queryForObject("acquiring.get-terminal-templates",
					convertQueryParams(params));
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public Terminal modifyTerminalTemplate(Long userSessionId, Terminal template) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(template.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, AcquiringPrivConstants.MODIFY_TERMINAL_TEMPLATE, paramArr);

			ssn.update("acquiring.modify-terminal-template", template);

			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("id");
			filters[0].setValue(template.getId().toString());
			filters[1] = new Filter();
			filters[1].setElement("lang");
			filters[1].setValue(template.getLang());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (Terminal) ssn.queryForObject("acquiring.get-terminal-templates",
					convertQueryParams(params));
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void deleteTerminalTemplate(Long userSessionId, Terminal template, TerminalATM atm) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(template.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, AcquiringPrivConstants.REMOVE_TERMINAL_TEMPLATE, paramArr);

			ssn.delete("acquiring.remove-terminal-template", template.getId());
			if (atm != null){
				ssn.delete("atm.remove-terminal-atm", atm);
			}
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	@SuppressWarnings("unchecked")
	public MerchantType[] getMerchantTypes(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSessionFE(userSessionId);

			List<MerchantType> types = ssn.queryForList("acquiring.get-merchant-types",
					convertQueryParams(params));
			return types.toArray(new MerchantType[types.size()]);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	@SuppressWarnings("unchecked")
	public MerchantType[] getMerchantTypesList(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSessionFE(userSessionId);

			List<MerchantType> types = ssn.queryForList("acquiring.get-merchant-types-list",
					convertQueryParams(params));
			return types.toArray(new MerchantType[types.size()]);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public MerchantType addMerchantTypesBranch(Long userSessionId, MerchantType type) {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSessionFE(userSessionId);

			ssn.update("acquiring.add-merchant-type-branch", type);

			Filter[] filters = new Filter[1];
			filters[0] = new Filter();
			filters[0].setElement("id");
			filters[0].setValue(type.getBranchId().toString());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (MerchantType) ssn.queryForObject("acquiring.get-merchant-types-list",
					convertQueryParams(params));
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void deleteMerchantTypesBranch(Long userSessionId, Integer branchId) {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSession(userSessionId, null, AcquiringPrivConstants.REMOVE_MCC, null);

			ssn.delete("acquiring.remove-merchant-type-branch", branchId);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public MCC[] getMCCs(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, AcquiringPrivConstants.VIEW_MCC, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, AcquiringPrivConstants.VIEW_MCC);
			
			List<MCC> mccs = ssn.queryForList("acquiring.get-mccs", convertQueryParams(params, limitation));

			return mccs.toArray(new MCC[mccs.size()]);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public int getMCCsCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, AcquiringPrivConstants.VIEW_MCC, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, AcquiringPrivConstants.VIEW_MCC);
			return (Integer) ssn.queryForObject("acquiring.get-mccs-count",
					convertQueryParams(params, limitation));
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public MCC addMCC(Long userSessionId, MCC mcc) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(mcc.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, AcquiringPrivConstants.ADD_MCC, paramArr);

			ssn.insert("acquiring.add-mcc", mcc);

			Filter[] filters = new Filter[1];
			filters[0] = new Filter();
			filters[0].setElement("id");
			filters[0].setValue(mcc.getId().toString());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (MCC) ssn.queryForObject("acquiring.get-mccs", convertQueryParams(params));
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public MCC modifyMCC(Long userSessionId, MCC mcc) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(mcc.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, AcquiringPrivConstants.MODIFY_MCC, paramArr);

			ssn.update("acquiring.edit-mcc", mcc);

			Filter[] filters = new Filter[1];
			filters[0] = new Filter();
			filters[0].setElement("id");
			filters[0].setValue(mcc.getId().toString());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (MCC) ssn.queryForObject("acquiring.get-mccs", convertQueryParams(params));
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void removeMCC(Long userSessionId, MCC mcc) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(mcc.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, AcquiringPrivConstants.REMOVE_MCC, paramArr);

			ssn.delete("acquiring.remove-mcc", mcc);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	/**
	 * Gets hierarchical list of merchants
	 */

	@SuppressWarnings("unchecked")
	public Merchant[] getMerchants(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSessionFE(userSessionId);

			List<Merchant> merchants = ssn.queryForList("acquiring.get-merchants",
					convertQueryParams(params));
			return merchants.toArray(new Merchant[merchants.size()]);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	/**
	 * Gets plain list of merchants
	 */

	@SuppressWarnings("unchecked")
	public Merchant[] getMerchantsList(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, AcquiringPrivConstants.VIEW_MERCHANT, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn,
					AcquiringPrivConstants.VIEW_MERCHANT);
			List<Merchant> merchants = ssn.queryForList("acquiring.get-merchants-list",
					convertQueryParams(params, limitation));
			return merchants.toArray(new Merchant[merchants.size()]);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public int getMerchantsCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, AcquiringPrivConstants.VIEW_MERCHANT, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn,
					AcquiringPrivConstants.VIEW_MERCHANT);
			return (Integer) ssn.queryForObject("acquiring.get-merchants-count",
					convertQueryParams(params, limitation));
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public ReimbursementChannel[] getReimbursementChannels(Long userSessionId,
			SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, AcquiringPrivConstants.VIEW_REIMBURSEMENT_CHANNEL, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn,
					AcquiringPrivConstants.VIEW_REIMBURSEMENT_CHANNEL);
			List<ReimbursementChannel> channels;
			channels = ssn.queryForList("acquiring.get-reimb-channels", convertQueryParams(params,
					limitation));

			return channels.toArray(new ReimbursementChannel[channels.size()]);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public int getReimbursementChannelsCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, AcquiringPrivConstants.VIEW_REIMBURSEMENT_CHANNEL, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn,
					AcquiringPrivConstants.VIEW_REIMBURSEMENT_CHANNEL);
			return (Integer) ssn.queryForObject("acquiring.get-reimb-channels-count",
					convertQueryParams(params, limitation));
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public ReimbursementChannel addReimbursementChannel(Long userSessionId,
			ReimbursementChannel channel) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(channel.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, AcquiringPrivConstants.ADD_REIMBURSEMENT_CHANNEL, paramArr);

			ssn.insert("acquiring.add-reimb-channel", channel);

			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("id");
			filters[0].setValue(channel.getId().toString());
			filters[1] = new Filter();
			filters[1].setElement("lang");
			filters[1].setValue(channel.getLang());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (ReimbursementChannel) ssn.queryForObject("acquiring.get-reimb-channels",
					convertQueryParams(params));
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public ReimbursementChannel modifyReimbursementChannel(Long userSessionId,
			ReimbursementChannel channel) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(channel.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, AcquiringPrivConstants.MODIFY_REIMBURSEMENT_CHANNEL, paramArr);

			ssn.update("acquiring.modify-reimb-channel", channel);

			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("id");
			filters[0].setValue(channel.getId().toString());
			filters[1] = new Filter();
			filters[1].setElement("lang");
			filters[1].setValue(channel.getLang());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (ReimbursementChannel) ssn.queryForObject("acquiring.get-reimb-channels",
					convertQueryParams(params));
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void removeReimbursementChannel(Long userSessionId, ReimbursementChannel channel) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(channel.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, AcquiringPrivConstants.REMOVE_REIMBURSEMENT_CHANNEL, paramArr);

			ssn.delete("acquiring.remove-reimb-channel", channel);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public ReimbursementBatchEntry[] getReimbursementBatchEntries(Long userSessionId,
			SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, AcquiringPrivConstants.VIEW_REIMBURSEMENT_BATCH, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn,
					AcquiringPrivConstants.VIEW_REIMBURSEMENT_BATCH);
			List<ReimbursementBatchEntry> entries;
			entries = ssn.queryForList("acquiring.get-reimb-batch-entries", convertQueryParams(
					params, limitation));

			return entries.toArray(new ReimbursementBatchEntry[entries.size()]);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public int getReimbursementBatchEntriesCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, AcquiringPrivConstants.VIEW_REIMBURSEMENT_BATCH, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn,
					AcquiringPrivConstants.VIEW_REIMBURSEMENT_BATCH);
			return (Integer) ssn.queryForObject("acquiring.get-reimb-batch-entries-count",
					convertQueryParams(params, limitation));
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public ReimbursementBatchEntry modifyReimbursementBatchEntry(Long userSessionId,
			ReimbursementBatchEntry batchEntry) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(batchEntry.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, AcquiringPrivConstants.MODIFY_REIMBURSEMENT_BATCH, paramArr);

			ssn.update("acquiring.modify-reimb-batch-entry", batchEntry);

			Filter[] filters = new Filter[1];
			filters[0] = new Filter();
			filters[0].setElement("id");
			filters[0].setValue(batchEntry.getId().toString());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (ReimbursementBatchEntry) ssn.queryForObject(
					"acquiring.get-reimb-batch-entries", convertQueryParams(params));
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public ReimbursementOperation[] getReimbursementOperations(Long userSessionId,
			SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, AcquiringPrivConstants.VIEW_REIMBURSEMENT_OPER, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn,
					AcquiringPrivConstants.VIEW_REIMBURSEMENT_OPER);
			List<ReimbursementOperation> opers;
			opers = ssn.queryForList("acquiring.get-reimb-operations", convertQueryParams(params,
					limitation));

			return opers.toArray(new ReimbursementOperation[opers.size()]);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public int getReimbursementOperationsCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, AcquiringPrivConstants.VIEW_REIMBURSEMENT_OPER, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn,
					AcquiringPrivConstants.VIEW_REIMBURSEMENT_OPER);
			return (Integer) ssn.queryForObject("acquiring.get-reimb-operations-count",
					convertQueryParams(params, limitation));
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	@SuppressWarnings("unchecked")
	public AccountScheme[] getAccountSchemes(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, AcquiringPrivConstants.VIEW_ACQ_ACCOUNT_SCHEME, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn,
					AcquiringPrivConstants.VIEW_ACQ_ACCOUNT_SCHEME);
			List<AccountScheme> schemes = ssn.queryForList("acquiring.get-account-schemes",
					convertQueryParams(params, limitation));
			return schemes.toArray(new AccountScheme[schemes.size()]);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public int getAccountSchemesCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, AcquiringPrivConstants.VIEW_ACQ_ACCOUNT_SCHEME, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn,
					AcquiringPrivConstants.VIEW_ACQ_ACCOUNT_SCHEME);
			return (Integer) ssn.queryForObject("acquiring.get-account-schemes-count",
					convertQueryParams(params, limitation));
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public AccountScheme addAccountScheme(Long userSessionId, AccountScheme scheme) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(scheme.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, AcquiringPrivConstants.ADD_ACQ_ACCOUNT_SCHEME, paramArr);

			ssn.insert("acquiring.add-account-scheme", scheme);

			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("id");
			filters[0].setValue(scheme.getId().toString());
			filters[1] = new Filter();
			filters[1].setElement("lang");
			filters[1].setValue(scheme.getLang());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (AccountScheme) ssn.queryForObject("acquiring.get-account-schemes",
					convertQueryParams(params));
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public AccountScheme modifyAccountScheme(Long userSessionId, AccountScheme scheme) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(scheme.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, AcquiringPrivConstants.MODIFY_ACQ_ACCOUNT_SCHEME, paramArr);

			ssn.update("acquiring.modify-account-scheme", scheme);

			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("id");
			filters[0].setValue(scheme.getId().toString());
			filters[1] = new Filter();
			filters[1].setElement("lang");
			filters[1].setValue(scheme.getLang());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (AccountScheme) ssn.queryForObject("acquiring.get-account-schemes",
					convertQueryParams(params));
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void removeAccountScheme(Long userSessionId, AccountScheme scheme) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(scheme.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, AcquiringPrivConstants.REMOVE_ACQ_ACCOUNT_SCHEME, paramArr);

			ssn.delete("acquiring.remove-account-scheme", scheme);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	@SuppressWarnings("unchecked")
	public AccountPattern[] getAccountPatterns(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, AcquiringPrivConstants.VIEW_ACQ_ACCOUNT_PATTERN, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn,
					AcquiringPrivConstants.VIEW_ACQ_ACCOUNT_PATTERN);
			List<AccountPattern> patterns = ssn.queryForList("acquiring.get-account-patterns",
					convertQueryParams(params, limitation));
			return patterns.toArray(new AccountPattern[patterns.size()]);
		} catch (SQLException e) {
			logger.error("", e);
			throw new DataAccessException(e);
		} finally {
			close(ssn);
		}
	}


	public int getAccountPatternsCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, AcquiringPrivConstants.VIEW_ACQ_ACCOUNT_PATTERN, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn,
					AcquiringPrivConstants.VIEW_ACQ_ACCOUNT_PATTERN);
			return (Integer) ssn.queryForObject("acquiring.get-account-patterns-count",
					convertQueryParams(params, limitation));
		} catch (SQLException e) {
			logger.error("", e);
			throw new DataAccessException(e);
		} finally {
			close(ssn);
		}
	}


	public AccountPattern addAccountPattern(Long userSessionId, AccountPattern pattern, String lang) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(pattern.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, AcquiringPrivConstants.ADD_ACQ_ACCOUNT_PATTERN, paramArr);

			ssn.insert("acquiring.add-account-pattern", pattern);

			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("id");
			filters[0].setValue(pattern.getId().toString());
			filters[1] = new Filter();
			filters[1].setElement("lang");
			filters[1].setValue(lang);

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (AccountPattern) ssn.queryForObject("acquiring.get-account-patterns",
					convertQueryParams(params));
		} catch (SQLException e) {
			logger.error("", e);
			throw new DataAccessException(e);
		} finally {
			close(ssn);
		}
	}


	public AccountPattern modifyAccountPattern(Long userSessionId, AccountPattern pattern,
			String lang) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(pattern.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, AcquiringPrivConstants.MODIFY_ACQ_ACCOUNT_PATTERN, paramArr);

			ssn.update("acquiring.modify-account-pattern", pattern);

			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("id");
			filters[0].setValue(pattern.getId().toString());
			filters[1] = new Filter();
			filters[1].setElement("lang");
			filters[1].setValue(lang);

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (AccountPattern) ssn.queryForObject("acquiring.get-account-patterns",
					convertQueryParams(params));
		} catch (SQLException e) {
			logger.error("", e);
			throw new DataAccessException(e);
		} finally {
			close(ssn);
		}
	}


	public void removeAccountPattern(Long userSessionId, AccountPattern pattern) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(pattern.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, AcquiringPrivConstants.REMOVE_ACQ_ACCOUNT_PATTERN, paramArr);

			ssn.delete("acquiring.remove-account-pattern", pattern);
		} catch (SQLException e) {
			logger.error("", e);
			throw new DataAccessException(e);
		} finally {
			close(ssn);
		}
	}


	@SuppressWarnings("unchecked")
	public Parameter[] getTerminalParameters(String terminalNumber) {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSessionNoContext();
			List<Parameter> params = ssn.queryForList("acquiring.get-terminal-parameters",
					terminalNumber);			
			return params.toArray(new Parameter[params.size()]);
		} catch (Exception e) {
			logger.error("", e);
			throw new DataAccessException(e);
		} finally {
			close(ssn);
		}
	}


	@SuppressWarnings("unchecked")
	public MccSelection[] getMccSelections(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, AcquiringPrivConstants.VIEW_MCC_SELECTION, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, AcquiringPrivConstants.VIEW_MCC_SELECTION);
			
			List<MccSelection> items = ssn.queryForList(
					"acquiring.get-mcc-selections", convertQueryParams(params, limitation));
			return items.toArray(new MccSelection[items.size()]);
		} catch (SQLException e) {
			logger.error("", e);
			throw new DataAccessException(e);
		} finally {
			close(ssn);
		}
	}


	public int getMccSelectionsCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, AcquiringPrivConstants.VIEW_MCC_SELECTION, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, AcquiringPrivConstants.VIEW_MCC_SELECTION);

			int count = (Integer)ssn.queryForObject("acquiring.get-mcc-selections-count",
					convertQueryParams(params, limitation));
			return count;
		} catch (SQLException e) {
			logger.error("", e);
			throw new DataAccessException(e);
		} finally {
			close(ssn);
		}
	}


	public MccSelection createMccSelection( Long userSessionId, MccSelection newItem){
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(newItem.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, AcquiringPrivConstants.ADD_MCC_SELECTION, paramArr);
			ssn.update("acquiring.add-mcc-selection", newItem);
			
			Filter[] filters = new Filter[2];
			Filter f = new Filter();
			f.setElement("id");
			f.setValue(newItem.getId());
			filters[0] = f;
			filters[1] = new Filter();
			filters[1].setElement("lang");
			filters[1].setValue(newItem.getLang());
			SelectionParams params = new SelectionParams();
			params.setFilters(filters);
			MccSelection result = (MccSelection) ssn.queryForObject("acquiring.get-mcc-selections", convertQueryParams(params));
			return result;
		} catch (SQLException e) {
			logger.error("", e);
			throw new DataAccessException(e);
		} finally {
			close(ssn);
		}
	}


	public MccSelection modifyMccSelection( Long userSessionId, MccSelection editingItem){
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(editingItem.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, AcquiringPrivConstants.MODIFY_MCC_SELECTION, paramArr);
			ssn.update("acquiring.modify-mcc-selection", editingItem);
			
			Filter[] filters = new Filter[]{
					new Filter("id", editingItem.getId()),
					new Filter("lang", editingItem.getLang())
			};
			SelectionParams params = new SelectionParams(filters);
			MccSelection result = (MccSelection) ssn.queryForObject("acquiring.get-mcc-selections", convertQueryParams(params));
			return result;
		} catch (SQLException e) {
			logger.error("", e);
			throw new DataAccessException(e);
		} finally {
			close(ssn);
		}
	}


	public void removeMccSelection( Long userSessionId, MccSelection activeItem){
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(activeItem.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, AcquiringPrivConstants.REMOVE_MCC_SELECTION, paramArr);
			ssn.update("acquiring.remove-mcc-selection", activeItem);	
		} catch (SQLException e) {
			logger.error("", e);
			throw new DataAccessException(e);
		} finally {
			close(ssn);
		}
	}
	
	
	@SuppressWarnings("unchecked")
	public RevenueSharing[] getRevenueSharings(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, (params.getPrivilege()!=null ? params.getPrivilege() : AccountPrivConstants.VIEW_ACCOUNT_SELECTION_PRIORITY), paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn,
					(params.getPrivilege()!=null ? params.getPrivilege() : AccountPrivConstants.VIEW_ACCOUNT_SELECTION_PRIORITY));
			List<RevenueSharing> priorities = ssn.queryForList(
					"acquiring.get-revenue-sharing", convertQueryParams(params, limitation));
			return priorities.toArray(new RevenueSharing[priorities.size()]);
		} catch (SQLException e) {
			logger.error("", e);
			throw new DataAccessException(e);
		} finally {
			close(ssn);
		}
	}


	public int getRevenueSharingsCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, (params.getPrivilege()!=null ? params.getPrivilege() : AccountPrivConstants.VIEW_ACCOUNT_SELECTION_PRIORITY), paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn,
					(params.getPrivilege()!=null ? params.getPrivilege() : AccountPrivConstants.VIEW_ACCOUNT_SELECTION_PRIORITY));
			return (Integer) ssn.queryForObject("acquiring.get-revenue-sharing-count",
					convertQueryParams(params, limitation));
		} catch (SQLException e) {
			throw new DataAccessException(e);
		} finally {
			close(ssn);
		}
	}


	public RevenueSharing addRevenueSharing(Long userSessionId, RevenueSharing priority) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(priority.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, AccountPrivConstants.ADD_ACCOUNT_SELECTION_PRIORITY, paramArr);
			
			ssn.update("acquiring.add-revenue-sharing", priority);

			Filter[] filters = new Filter[1];
			filters[0] = new Filter();
			filters[0].setElement("id");
			filters[0].setValue(priority.getId());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (RevenueSharing) ssn.queryForObject("acquiring.get-revenue-sharing",
					convertQueryParams(params));
		} catch (SQLException e) {
			throw new DataAccessException(e);
		} finally {
			close(ssn);
		}
	}


	public RevenueSharing modifyRevenueSharing(Long userSessionId, RevenueSharing priority) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(priority.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, AccountPrivConstants.MODIFY_ACCOUNT_SELECTION_PRIORITY, paramArr);

			ssn.update("acquiring.modify-revenue-sharing", priority);

			Filter[] filters = new Filter[1];
			filters[0] = new Filter();
			filters[0].setElement("id");
			filters[0].setValue(priority.getId());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (RevenueSharing) ssn.queryForObject("acquiring.get-revenue-sharing",
					convertQueryParams(params));
		} catch (SQLException e) {
			throw new DataAccessException(e);
		} finally {
			close(ssn);
		}
	}


	public void removeRevenueSharing(Long userSessionId, RevenueSharing priority) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(priority.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, AccountPrivConstants.REMOVE_ACCOUNT_SELECTION_PRIORITY, paramArr);

			ssn.delete("acquiring.remove-revenue-sharing", priority);
		} catch (SQLException e) {
			throw new DataAccessException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public TcpIpDevice[] getTerminalDevices(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, (params.getPrivilege()!=null ? params.getPrivilege() : CmnPrivConstants.VIEW_COMMUNIC_DEVICE), paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, CmnPrivConstants.VIEW_COMMUNIC_DEVICE);
			List<TcpIpDevice> devices = ssn.queryForList("acquiring.get-terminal-devices",
					convertQueryParams(params, limitation));
			return devices.toArray(new TcpIpDevice[devices.size()]);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}
	
	@SuppressWarnings("unchecked")
	public MccSelectionTpl[] getMccSelectionTpls(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, AcquiringPrivConstants.VIEW_MCC_SELECTION_TEMPLATE, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, CmnPrivConstants.VIEW_COMMUNIC_DEVICE);

			List<MccSelectionTpl> items = ssn.queryForList(
					"acquiring.get-mcc-selection-tpls", convertQueryParams(params, limitation));
			return items.toArray(new MccSelectionTpl[items.size()]);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public int getMccSelectionTplsCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, AcquiringPrivConstants.VIEW_MCC_SELECTION_TEMPLATE, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, CmnPrivConstants.VIEW_COMMUNIC_DEVICE);

			int count = (Integer)ssn.queryForObject("acquiring.get-mcc-selection-tpls-count",
					convertQueryParams(params, limitation));
			return count;
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public MccSelectionTpl createMccSelectionTpl( Long userSessionId, MccSelectionTpl editingItem){
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(editingItem.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, AcquiringPrivConstants.ADD_MCC_SELECTION_TEMPLATE, paramArr);
			ssn.update("acquiring.add-selection-tpl", editingItem);
			
			Filter[] filters = new Filter[1];
			Filter f = new Filter();
			f.setElement("id");
			f.setValue(editingItem.getId());
			filters[0] = f;
			SelectionParams params = new SelectionParams();
			params.setFilters(filters);
			MccSelectionTpl result = (MccSelectionTpl) ssn.queryForObject("acquiring.get-mcc-selection-tpls", convertQueryParams(params));
			return result;
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public MccSelectionTpl modifyMccSelectionTpl( Long userSessionId, MccSelectionTpl editingItem){
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(editingItem.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, AcquiringPrivConstants.MODIFY_MCC_SELECTION_TEMPLATE, paramArr);
			ssn.update("acquiring.modify-selection-tpl", editingItem);
			
			Filter[] filters = new Filter[1];
			Filter f = new Filter();
			f.setElement("id");
			f.setValue(editingItem.getId());
			filters[0] = f;
			SelectionParams params = new SelectionParams();
			params.setFilters(filters);
			MccSelectionTpl result = (MccSelectionTpl) ssn.queryForObject("acquiring.get-mcc-selection-tpls", convertQueryParams(params));
			return result;
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void removeMccSelectionTpl( Long userSessionId, MccSelectionTpl activeItem){
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(activeItem.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, AcquiringPrivConstants.REMOVE_MCC_SELECTION_TEMPLATE, paramArr);
			ssn.update("acquiring.remove-selection-tpl", activeItem);	
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public Merchant[] getMerchantsCur(Long userSessionId,
			SelectionParams params, Map<String, Object> paramMap) {
		Merchant [] result;
		SqlMapSession ssn = null;
		try{
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, AcquiringPrivConstants.VIEW_MERCHANT, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn,
					AcquiringPrivConstants.VIEW_MERCHANT);
			List<Filter> filters = new ArrayList<Filter> (Arrays.asList(params.getFilters()));
			filters.add(new Filter("PRIVIL_LIMITATION", limitation));
			params.setFilters(filters.toArray(new Filter[filters.size()]));
			
			QueryParams qparams = convertQueryParams(params);
            paramMap.put("row_count", params.getRowCount());
			paramMap.put("first_row", qparams.getRange().getStartPlusOne());
			paramMap.put("last_row", new Long(Integer.MAX_VALUE));
			paramMap.put("sorting_tab", params.getSortElement());
			paramMap.put("param_tab", filters.toArray(new Filter[filters.size()]));
			ssn.update("acquiring.get-merchants-cur", paramMap);
			List <Merchant> merchants  = (List<Merchant>)paramMap.get("ref_cur");
			result = merchants.toArray(new Merchant[merchants.size()]);
		}catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
		return result;
	}


	public int getMerchantsCurCount(Long userSessionId,
			Map<String, Object> paramMap) {
		Integer result = 0;
		SqlMapSession ssn = null;
		try{
			ssn = getIbatisSession(userSessionId);
			String limitation = CommonController.getLimitationByPriv(ssn,
					AcquiringPrivConstants.VIEW_MERCHANT);
			List<Filter> filters = new ArrayList<Filter> 
			(Arrays.asList((Filter[])paramMap.get("param_tab")));
			filters.add(new Filter("PRIVIL_LIMITATION", limitation));
			paramMap.put("param_tab", filters.toArray(new Filter[filters.size()]));
			ssn.update("acquiring.get-merchants-cur-count", paramMap);
			result = (Integer)paramMap.get("row_count");
		}catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
		return result;
	}


	public Long getAccountObjectId(Long userSessionId,  Map<String, Object> paramMap) {
		SqlMapSession ssn = null;
		try{
			ssn = getIbatisSession(userSessionId);
			return (Long)ssn.queryForObject("acquiring.get-account-object-id", paramMap);
		}catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public List<Card> getMerchantCards(Long userSessionId, final SelectionParams params) {
		return executeWithSession(userSessionId,
								  IssuingPrivConstants.VIEW_CARDS,
								  params,
								  logger,
								  new IbatisSessionCallback<List<Card>>() {
			@Override
			public List<Card> doInSession(SqlMapSession ssn) throws Exception {
				String limitation = CommonController.getLimitationByPriv(ssn, IssuingPrivConstants.VIEW_CARDS);
				return ssn.queryForList("acquiring.get-merchant-cards", convertQueryParams(params, limitation));
			}
		});
	}


	public int getMerchantCardsCount(Long userSessionId, final SelectionParams params) {
		return executeWithSession(userSessionId,
								  IssuingPrivConstants.VIEW_CARDS,
								  params,
								  logger,
								  new IbatisSessionCallback<Integer>() {
			@Override
			public Integer doInSession(SqlMapSession ssn) throws Exception {
				String limitation = CommonController.getLimitationByPriv(ssn, IssuingPrivConstants.VIEW_CARDS);
				Object count = ssn.queryForObject("acquiring.get-merchant-cards-count", convertQueryParams(params, limitation));
				return (count != null) ? (Integer)count : 0;
			}
		});
	}
}
