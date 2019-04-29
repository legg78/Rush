package ru.bpc.sv2.logic;

import java.sql.SQLException;
import java.util.Date;
import java.util.List;

import ru.bpc.sv2.logic.utility.db.DataAccessException;


import org.apache.log4j.Logger;

import ru.bpc.sv2.atm.AdminOperation;
import ru.bpc.sv2.atm.AtmCashIn;
import ru.bpc.sv2.atm.AtmCollection;
import ru.bpc.sv2.atm.AtmCollectionDispenser;
import ru.bpc.sv2.atm.AtmDispenser;
import ru.bpc.sv2.atm.AtmPrivConstants;
import ru.bpc.sv2.atm.AtmScenario;
import ru.bpc.sv2.atm.CapturedCard;
import ru.bpc.sv2.atm.FraudOperation;
import ru.bpc.sv2.atm.MonitoredAtm;
import ru.bpc.sv2.atm.StatusMessage;
import ru.bpc.sv2.atm.TerminalATM;
import ru.bpc.sv2.atm.Unsolicited;
import ru.bpc.sv2.common.CommonParamRec;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.controller.CommonController;
import ru.bpc.sv2.logic.utility.db.IbatisAware;
import ru.bpc.sv2.utils.AuditParamUtil;

import com.ibatis.sqlmap.client.SqlMapSession;

public class AtmDao extends IbatisAware {

	private static final Logger logger = Logger.getLogger("ATM");
	
	/**
	 * Gets plain list of scenarios
	 */

	@SuppressWarnings("unchecked")
	public AtmScenario[] getScenarios(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, AtmPrivConstants.VIEW_ATM_SCENARIO, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, AtmPrivConstants.VIEW_ATM_SCENARIO);
			List<AtmScenario> scenarios = ssn.queryForList("atm.get-scenarios",
					convertQueryParams(params, limitation));
			return scenarios.toArray(new AtmScenario[scenarios.size()]);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public int getScenariosCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, AtmPrivConstants.VIEW_ATM_SCENARIO, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, AtmPrivConstants.VIEW_ATM_SCENARIO);
			return (Integer) ssn.queryForObject("atm.get-scenarios-count",
					convertQueryParams(params, limitation));
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}
	
	/**
	 * Gets plain list of atms
	 */

	@SuppressWarnings("unchecked")
	public TerminalATM[] getTerminalAtms(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, AtmPrivConstants.VIEW_ATM_TERMINAL, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, AtmPrivConstants.VIEW_ATM_TERMINAL);
			List<TerminalATM> atms = ssn.queryForList("atm.get-terminal-atms",
					convertQueryParams(params, limitation));
			return atms.toArray(new TerminalATM[atms.size()]);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public int getTerminalAtmsCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, AtmPrivConstants.VIEW_ATM_TERMINAL, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, AtmPrivConstants.VIEW_ATM_TERMINAL);
			return (Integer) ssn.queryForObject("atm.get-terminal-atms-count",
					convertQueryParams(params, limitation));
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}
	
	@SuppressWarnings("unchecked")
	public TerminalATM[] getTerminalTemplateAtms(Long userSessionId,
			SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, AtmPrivConstants.VIEW_ATM_TERMINAL, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, AtmPrivConstants.VIEW_ATM_TERMINAL);
			List<TerminalATM> atms = ssn.queryForList("atm.get-terminal-template-atms",
					convertQueryParams(params, limitation));
			return atms.toArray(new TerminalATM[atms.size()]);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public int getTerminalTemplateAtmsCount(Long userSessionId,
			SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, AtmPrivConstants.VIEW_ATM_TERMINAL, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, AtmPrivConstants.VIEW_ATM_TERMINAL);
			return (Integer) ssn.queryForObject("atm.get-terminal-template-atms-count",
					convertQueryParams(params, limitation));
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}
	

	public TerminalATM addTerminalAtm(Long userSessionId, TerminalATM atm, boolean isTemplate) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(atm.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, AtmPrivConstants.ADD_ATM_TERMINAL, paramArr);

			ssn.insert("atm.add-terminal-atm", atm);

			Filter[] filters = new Filter[1];
			filters[0] = new Filter("terminalId", atm.getId());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			if (isTemplate) {
				return (TerminalATM) ssn.queryForObject("atm.get-terminal-template-atms", convertQueryParams(params));
			} else {
				return (TerminalATM) ssn.queryForObject("atm.get-terminal-atms", convertQueryParams(params));
			}
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}
	

	public TerminalATM modifyTerminalAtm(Long userSessionId, TerminalATM atm, boolean isTemplate) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(atm.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, AtmPrivConstants.MODIFY_ATM_TERMINAL, paramArr);

			ssn.update("atm.modify-terminal-atm", atm);

			Filter[] filters = new Filter[1];
			filters[0] = new Filter("terminalId", atm.getId());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			if (isTemplate) {
				return (TerminalATM) ssn.queryForObject("atm.get-terminal-template-atms", convertQueryParams(params));
			} else {
				return (TerminalATM) ssn.queryForObject("atm.get-terminal-atms", convertQueryParams(params));
			}
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}
	

	public void removeTerminalAtm(Long userSessionId, TerminalATM atm) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(atm.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, AtmPrivConstants.REMOVE_ATM_TERMINAL, paramArr);

			ssn.delete("atm.remove-terminal-atm", atm);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}
	
	@SuppressWarnings("unchecked")
	public AtmDispenser[] getDispensers(Long userSessionId, SelectionParams params) {
    	SqlMapSession ssn = null;
		try	{
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, AtmPrivConstants.VIEW_ATM_DISPENSER, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, AtmPrivConstants.VIEW_ATM_DISPENSER);
			List<AtmDispenser> dispensers = ssn.queryForList("atm.get-dispensers", convertQueryParams(params, limitation));
			return dispensers.toArray(new AtmDispenser[dispensers.size()]);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}
    

    public int getDispensersCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, AtmPrivConstants.VIEW_ATM_DISPENSER, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, AtmPrivConstants.VIEW_ATM_DISPENSER);
			return (Integer) ssn.queryForObject("atm.get-dispensers-count", convertQueryParams(params, limitation));
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}
    

	public Date getLastSynchronization(Long userSessionId, SelectionParams params) {
    	SqlMapSession ssn = null;
		try	{
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, AtmPrivConstants.VIEW_ATM_DISPENSER, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, AtmPrivConstants.VIEW_ATM_DISPENSER);
			return (Date) ssn.queryForObject("atm.get-last-synchronization", convertQueryParams(params, limitation));
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}
    
    
    

    public AtmDispenser addDispenser(Long userSessionId, AtmDispenser dispenser) {
		SqlMapSession ssn = null;

		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(dispenser.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, AtmPrivConstants.ADD_ATM_DISPENSER, paramArr);
			ssn.insert("atm.add-dispenser", dispenser);

			Filter[] filters = new Filter[1];
			filters[0] = new Filter();
			filters[0].setElement("id");
			filters[0].setValue(dispenser.getId());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (AtmDispenser) ssn.queryForObject("atm.get-dispensers", convertQueryParams(params));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}
    

    public AtmDispenser modifyDispenser(Long userSessionId, AtmDispenser dispenser) {
    	SqlMapSession ssn = null;
    	try {
    		CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(dispenser.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, AtmPrivConstants.MODIFY_ATM_DISPENSER, paramArr);
    		
    		ssn.update("atm.edit-dispenser", dispenser);
    		
    		// as we don't modify anything that could require getting data from
    		// other tables we don't have to query for modified object
    		
    		Filter[] filters = new Filter[1];
			filters[0] = new Filter();
			filters[0].setElement("id");
			filters[0].setValue(dispenser.getId());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (AtmDispenser) ssn.queryForObject("atm.get-dispensers", convertQueryParams(params));
    	} catch (SQLException e) {
    		throw createDaoException(e);
    	} finally {
    		close(ssn);
    	}
    }
    

    public void modifyDispenserState(Long userSessionId, AtmDispenser dispenser) {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSessionFE(userSessionId);
			ssn.update("atm.modify-dispenser-state", dispenser);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}
    

    public void removeDispenser(Long userSessionId, AtmDispenser dispenser) {
		SqlMapSession ssn = null;

		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(dispenser.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, AtmPrivConstants.REMOVE_ATM_DISPENSER, paramArr);
			ssn.delete("atm.remove-dispenser", dispenser);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	@SuppressWarnings("unchecked")
	public AtmCashIn[] getAtmCashIns(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, AtmPrivConstants.VIEW_ATM_CASH_IN, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, AtmPrivConstants.VIEW_ATM_CASH_IN);
			List<AtmCashIn> items = ssn.queryForList("atm.get-atm-cash-ins",
					convertQueryParams(params, limitation));
			return items.toArray(new AtmCashIn[items.size()]);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public int getAtmCashInsCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, AtmPrivConstants.VIEW_ATM_CASH_IN, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, AtmPrivConstants.VIEW_ATM_CASH_IN);
			return (Integer) ssn.queryForObject("atm.get-atm-cash-ins-count",
					convertQueryParams(params, limitation));
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}
	

	@SuppressWarnings("unchecked")
	public AtmCollection[] getAtmCollections(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, AtmPrivConstants.VIEW_ATM_COLLECTION, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, AtmPrivConstants.VIEW_ATM_COLLECTION);
			List<AtmCollection> items = ssn.queryForList("atm.get-atm-collections",
					convertQueryParams(params, limitation));
			return items.toArray(new AtmCollection[items.size()]);
		} catch (SQLException e) {
			logger.error("", e);
			throw new DataAccessException(e);
		} finally {
			close(ssn);
		}
	}


	public int getAtmCollectionsCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, AtmPrivConstants.VIEW_ATM_COLLECTION, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, AtmPrivConstants.VIEW_ATM_COLLECTION);
			return (Integer) ssn.queryForObject("atm.get-atm-collections-count",
					convertQueryParams(params, limitation));
		} catch (SQLException e) {
			logger.error("", e);
			throw new DataAccessException(e);
		} finally {
			close(ssn);
		}
	}
	

	@SuppressWarnings("unchecked")
	public AtmCollectionDispenser[] getAtmCollectionDispensers(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, AtmPrivConstants.VIEW_ATM_COLLECTION, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, AtmPrivConstants.VIEW_ATM_COLLECTION);
			List<AtmCollectionDispenser> items = ssn.queryForList("atm.get-atm-collection-dispensers",
					convertQueryParams(params, limitation));
			return items.toArray(new AtmCollectionDispenser[items.size()]);
		} catch (SQLException e) {
			logger.error("", e);
			throw new DataAccessException(e);
		} finally {
			close(ssn);
		}
	}


	public int getAtmCollectionDispensersCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, AtmPrivConstants.VIEW_ATM_COLLECTION, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, AtmPrivConstants.VIEW_ATM_COLLECTION);
			return (Integer) ssn.queryForObject("atm.get-atm-collection-dispensers-count",
					convertQueryParams(params, limitation));
		} catch (SQLException e) {
			logger.error("", e);
			throw new DataAccessException(e);
		} finally {
			close(ssn);
		}
	}
	
	@SuppressWarnings("unchecked")
	public AtmDispenser[] getDispensersSum(Long userSessionId, SelectionParams params) {
    	SqlMapSession ssn = null;
		try	{
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, AtmPrivConstants.VIEW_ATM_DISPENSER, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, AtmPrivConstants.VIEW_ATM_DISPENSER);
			List<AtmDispenser> dispensers = ssn.queryForList("atm.get-atm-dispensers-sum", convertQueryParams(params, limitation));
			return dispensers.toArray(new AtmDispenser[dispensers.size()]);
		} catch (SQLException e) {
			logger.error("", e);
			throw new DataAccessException(e);
		} finally {
			close(ssn);
		}
	}
    

    public int getDispensersSumCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, AtmPrivConstants.VIEW_ATM_DISPENSER, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, AtmPrivConstants.VIEW_ATM_DISPENSER);
			return (Integer) ssn.queryForObject("atm.get-atm-dispensers-sum-count", convertQueryParams(params, limitation));
		} catch (SQLException e) {
			logger.error("", e);
			throw new DataAccessException(e);
		} finally {
			close(ssn);
		}
	}


    public MonitoredAtm[] getMonitoredAtms(Long userSessionId, SelectionParams params) {
    	SqlMapSession ssn = null;
    	try {
    		CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, AtmPrivConstants.VIEW_MONITORED_ATM, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, AtmPrivConstants.VIEW_MONITORED_ATM);

    		List<MonitoredAtm> items = ssn.queryForList(
    				"atm.get-monitored-atms", convertQueryParams(params, limitation));
    		return items.toArray(new MonitoredAtm[items.size()]);
    	} catch (SQLException e) {
    		logger.error("", e);
    		throw createDaoException(e);
    	} finally {
    		close(ssn);
    	}
    }


    public int getMonitoredAtmsCount(Long userSessionId, SelectionParams params) {
    	SqlMapSession ssn = null;
    	try {
    		CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, AtmPrivConstants.VIEW_MONITORED_ATM, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, AtmPrivConstants.VIEW_MONITORED_ATM);

    		int count = (Integer)ssn.queryForObject("atm.get-monitored-atms-count",
    				convertQueryParams(params, limitation));
    		return count;
    	} catch (SQLException e) {
    		logger.error("", e);
    		throw createDaoException(e);
    	} finally {
    		close(ssn);
    	}
    }


    public CapturedCard[] getCapturedCards(Long userSessionId, SelectionParams params) {
    	SqlMapSession ssn = null;
    	try {
    		ssn = getIbatisSessionFE(userSessionId);

    		List<CapturedCard> items = ssn.queryForList(
    				"atm.get-captured-cards", convertQueryParams(params));
    		return items.toArray(new CapturedCard[items.size()]);
    	} catch (SQLException e) {
    		logger.error("", e);
    		throw createDaoException(e);
    	} finally {
    		close(ssn);
    	}
    }


    public int getCapturedCardsCount(Long userSessionId, SelectionParams params) {
    	SqlMapSession ssn = null;
    	try {
    		ssn = getIbatisSessionFE(userSessionId);

    		int count = (Integer)ssn.queryForObject("atm.get-captured-cards-count",
    				convertQueryParams(params));
    		return count;
    	} catch (SQLException e) {
    		logger.error("", e);
    		throw createDaoException(e);
    	} finally {
    		close(ssn);
    	}
    }
    

    public String getAtmPlugin(Long userSessionId, Long terminalId, String lang){
    	SqlMapSession ssn = null;
    	try {
    		ssn = getIbatisSessionFE(userSessionId);
    		Filter[] filters = new Filter[2];
    		Filter f = new Filter();
    		f.setElement("terminalId");
    		f.setValue(terminalId);
    		filters[0] = f;
    		f = new Filter();
    		f.setElement("lang");
    		f.setValue(lang);
    		filters[1] = f;

    		SelectionParams sp = new SelectionParams();
    		sp.setFilters(filters);
    		
    		String atmPlugin = (String)ssn.queryForObject("atm.get-atm-plugin",
    				convertQueryParams(sp));
    		return atmPlugin;
    	} catch (SQLException e) {
    		logger.error("", e);
    		throw createDaoException(e);
    	} finally {
    		close(ssn);
    	}
    }


	public AdminOperation[] getAdminOperations(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSessionFE(userSessionId);

			List<AdminOperation> items = ssn.queryForList(
					"atm.get-admin-operations", convertQueryParams(params));
			return items.toArray(new AdminOperation[items.size()]);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public int getAdminOperationsCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSessionFE(userSessionId);

			int count = (Integer)ssn.queryForObject("atm.get-admin-operations-count",
					convertQueryParams(params));
			return count;
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public StatusMessage[] getStatusMessages(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSessionFE(userSessionId);

			List<StatusMessage> items = ssn.queryForList(
					"atm.get-status-messages", convertQueryParams(params));
			return items.toArray(new StatusMessage[items.size()]);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public int getStatusMessagesCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSessionFE(userSessionId);

			int count = (Integer)ssn.queryForObject("atm.get-status-messages-count",
					convertQueryParams(params));
			return count;
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public FraudOperation[] getFraudOperations(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSessionFE(userSessionId);

			List<FraudOperation> items = ssn.queryForList(
					"atm.get-fraud-operations", convertQueryParams(params));
			return items.toArray(new FraudOperation[items.size()]);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public int getFraudOperationsCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSessionFE(userSessionId);

			int count = (Integer)ssn.queryForObject("atm.get-fraud-operations-count",
					convertQueryParams(params));
			return count;
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}
	

	public Unsolicited[] getUnsolicited(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSessionFE(userSessionId);

			List<FraudOperation> items = ssn.queryForList("atm.get-receive-status-msg", convertQueryParams(params));
			return items.toArray(new Unsolicited[items.size()]);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}
	

	public int getUnsolicitedCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSessionFE(userSessionId);

			int count = (Integer)ssn.queryForObject("atm.get-receive-status-msg-count",
					convertQueryParams(params));
			return count;
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

}
