package ru.bpc.sv2.logic;

import com.ibatis.sqlmap.client.SqlMapSession;
import org.apache.log4j.Logger;
import ru.bpc.sv2.accounts.*;
import ru.bpc.sv2.common.CommonParamRec;
import ru.bpc.sv2.credit.DppCalculation;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.controller.CommonController;
import ru.bpc.sv2.logic.utility.db.IbatisAware;
import ru.bpc.sv2.logic.utility.db.IbatisSessionCallback;
import ru.bpc.sv2.logic.utility.db.QueryParams;
import ru.bpc.sv2.orgstruct.Institution;
import ru.bpc.sv2.reports.QueryResult;
import ru.bpc.sv2.utils.AuditParamUtil;
import ru.bpc.sv2.utils.UserException;

import ru.bpc.sv2.logic.utility.db.DataAccessException;

import java.sql.SQLException;
import java.util.*;

/**
 * Session Bean implementation class AcquiringDao
 */
public class AccountsDao extends IbatisAware {

	private static final Logger logger = Logger.getLogger("ACCOUNTING");

	@SuppressWarnings("unchecked")
	public AccountGL[] getGLAccounts(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, params.getPrivilege()!=null ? params.getPrivilege() : AccountPrivConstants.VIEW_GL_ACCOUNT, paramArr);
			
			String limitation = CommonController.getLimitationByPriv(ssn,
					params.getPrivilege()!=null ? params.getPrivilege() : AccountPrivConstants.VIEW_GL_ACCOUNT);
			List<AccountGL> accs = ssn.queryForList("accounts.get-gl-accounts", convertQueryParams(
					params, limitation));
			return accs.toArray(new AccountGL[accs.size()]);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	public int getGLAccountsCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, params.getPrivilege()!=null ? params.getPrivilege() : AccountPrivConstants.VIEW_GL_ACCOUNT, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn,
					params.getPrivilege()!=null ? params.getPrivilege() : AccountPrivConstants.VIEW_GL_ACCOUNT);
			return (Integer) ssn.queryForObject("accounts.get-gl-accounts-count",
					convertQueryParams(params, limitation));
		} catch (SQLException e) {
			logger.error("", e);
			throw new DataAccessException(e);
		} finally {
			close(ssn);
		}
	}


	@SuppressWarnings("unchecked")
	public AccountType[] getAccountTypes(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, AccountPrivConstants.VIEW_ACCOUNT_TYPE, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn,
					AccountPrivConstants.VIEW_ACCOUNT_TYPE);
			List<AccountType> accTypes = ssn.queryForList("accounts.get-account-types",
					convertQueryParams(params, limitation));
			return accTypes.toArray(new AccountType[accTypes.size()]);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public int getAccountTypesCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, AccountPrivConstants.VIEW_ACCOUNT_TYPE, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn,
					AccountPrivConstants.VIEW_ACCOUNT_TYPE);
			return (Integer) ssn.queryForObject("accounts.get-account-types-count",
					convertQueryParams(params, limitation));
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	@SuppressWarnings("unchecked")
	public Institution[] getBalanceTypeInstsByAccountType(Long userSessionId, String accountType,
			String lang) {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSessionFE(userSessionId);

			List<Institution> insts = ssn.queryForList("accounts.get-insts-by-account-type",
					accountType);

			return (Institution[]) insts.toArray(new Institution[insts.size()]);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public AccountType addAccountType(Long userSessionId, AccountType accountType) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(accountType.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, AccountPrivConstants.ADD_ACCOUNT_TYPE, paramArr);
			
			ssn.update("accounts.add-account-type", accountType);

			Filter[] filters = new Filter[1];
			filters[0] = new Filter();
			filters[0].setElement("id");
			filters[0].setValue(accountType.getId().toString());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (AccountType) ssn.queryForObject("accounts.get-account-types",
					convertQueryParams(params));
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public AccountType editAccountType(Long userSessionId, AccountType accountType, String lang) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(accountType.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, AccountPrivConstants.MODIFY_ACCOUNT_TYPE, paramArr);

			ssn.update("accounts.modify-account-type", accountType);

			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("id");
			filters[0].setValue(accountType.getId().toString());
			
			filters[1] = new Filter();
			filters[1].setElement("lang");
			filters[1].setValue(lang);

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (AccountType) ssn.queryForObject("accounts.get-account-types",
					convertQueryParams(params));
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void removeAccountType(Long userSessionId, AccountType accountType) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(accountType.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, AccountPrivConstants.REMOVE_ACCOUNT_TYPE, paramArr);

			ssn.update("accounts.remove-account-type", accountType);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public AccountType addAccountTypeWithBalanceType(Long userSessionId, AccountType accountType,
			BalanceType balanceType, String lang) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(accountType.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, AccountPrivConstants.ADD_ACCOUNT_TYPE, paramArr);

			ssn.update("accounts.add-account-type", accountType);

			balanceType.setAccountType(accountType.getAccountType());
			ssn.update("accounts.add-balance-type", balanceType);

			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("id");
			filters[0].setValue(accountType.getId().toString());
			
			filters[1] = new Filter();
			filters[1].setElement("lang");
			filters[1].setValue(lang);

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (AccountType) ssn.queryForObject("accounts.get-account-types",
					convertQueryParams(params));
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	@SuppressWarnings("unchecked")
	public BalanceType[] getBalanceTypes(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, AccountPrivConstants.VIEW_ACCOUNT_BALANCE_TYPE, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn,
					AccountPrivConstants.VIEW_ACCOUNT_BALANCE_TYPE);
			List<BalanceType> accTypes = ssn.queryForList("accounts.get-balance-types",
					convertQueryParams(params, limitation));
			return accTypes.toArray(new BalanceType[accTypes.size()]);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public int getBalanceTypesCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, AccountPrivConstants.VIEW_ACCOUNT_BALANCE_TYPE, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn,
					AccountPrivConstants.VIEW_ACCOUNT_BALANCE_TYPE);
			return (Integer) ssn.queryForObject("accounts.get-balance-types-count",
					convertQueryParams(params, limitation));
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public BalanceType addBalanceType(Long userSessionId, BalanceType balanceType) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(balanceType.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, AccountPrivConstants.ADD_ACCOUNT_BALANCE_TYPE, paramArr);

			ssn.update("accounts.add-balance-type", balanceType);

			Filter[] filters = new Filter[1];
			filters[0] = new Filter();
			filters[0].setElement("id");
			filters[0].setValue(balanceType.getId().toString());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (BalanceType) ssn.queryForObject("accounts.get-balance-types",
					convertQueryParams(params));
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public BalanceType editBalanceType(Long userSessionId, BalanceType balanceType) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(balanceType.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, AccountPrivConstants.MODIFY_ACCOUNT_BALANCE_TYPE, paramArr);

			ssn.update("accounts.modify-balance-type", balanceType);

			Filter[] filters = new Filter[1];
			filters[0] = new Filter();
			filters[0].setElement("id");
			filters[0].setValue(balanceType.getId().toString());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (BalanceType) ssn.queryForObject("accounts.get-balance-types",
					convertQueryParams(params));
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void removeBalanceType(Long userSessionId, BalanceType balanceType) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(balanceType.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, AccountPrivConstants.REMOVE_ACCOUNT_BALANCE_TYPE, paramArr);

			ssn.update("accounts.remove-balance-type", balanceType);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public BunchType[] getMacrosBunchTypes(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, AccountPrivConstants.VIEW_BUNCH_TYPES, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, AccountPrivConstants.VIEW_BUNCH_TYPES);
			List<BunchType> types = ssn.queryForList("accounts.get-acc-macros-bunch-type", convertQueryParams(params, limitation));
			return types.toArray(new BunchType[types.size()]);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public BunchType[] getBunchTypes(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, AccountPrivConstants.VIEW_BUNCH_TYPES, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, AccountPrivConstants.VIEW_BUNCH_TYPES);
			List<BunchType> types = ssn.queryForList("accounts.get-bunch-types", convertQueryParams(params, limitation));
			return types.toArray(new BunchType[types.size()]);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public Integer getBunchTypesCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, AccountPrivConstants.VIEW_BUNCH_TYPES, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, AccountPrivConstants.VIEW_BUNCH_TYPES);
			return (Integer) ssn.queryForObject("accounts.get-bunch-types-count", convertQueryParams(params, limitation));
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public BunchType addBunchType(Long userSessionId, BunchType bunchType) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(bunchType.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, AccountPrivConstants.ADD_ACCOUNT_ENTRY_SET, paramArr);
			ssn.update("accounts.add-bunch-type", bunchType);

			List<Filter> filters = new ArrayList<Filter>();
			filters.add(Filter.create("id", bunchType.getId()));
			filters.add(Filter.create("lang", bunchType.getLang()));
			if (bunchType.getInstId() != null) {
				filters.add(Filter.create("instId", bunchType.getInstId()));
			}
			SelectionParams params = new SelectionParams();
			params.setFilters(filters);
			List<BunchType> types = ssn.queryForList("accounts.get-bunch-types", convertQueryParams(params));
			if (types != null && types.size() > 0) {
				return types.get(0);
			} else {
				return bunchType;
			}
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public BunchType addComplexBunchType(Long userSessionId, BunchType bunchType,
			EntryTemplatePair entryTemplatePair) {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSessionFE(userSessionId);
			ssn.update("accounts.add-bunch-type", bunchType);

			entryTemplatePair.setBunchTypeId(bunchType.getId());
			addEntryTemplatePairImpl(entryTemplatePair, ssn);

			return bunchType;
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public BunchType editBunchType(Long userSessionId, BunchType bunchType) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(bunchType.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, AccountPrivConstants.MODIFY_ACCOUNT_ENTRY_SET, paramArr);
			ssn.update("accounts.modify-bunch-type", bunchType);

			List<Filter> filters = new ArrayList<Filter>();
			filters.add(Filter.create("id", bunchType.getId()));
			filters.add(Filter.create("lang", bunchType.getLang()));
			if (bunchType.getInstId() != null) {
				filters.add(Filter.create("instId", bunchType.getInstId()));
			}
			SelectionParams params = new SelectionParams();
			params.setFilters(filters);
			List<BunchType> types = ssn.queryForList("accounts.get-bunch-types", convertQueryParams(params));
			if (types != null && types.size() > 0) {
				return types.get(0);
			} else {
				return bunchType;
			}
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void removeBunchType(Long userSessionId, BunchType bunchType) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(bunchType.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, AccountPrivConstants.REMOVE_ACCOUNT_ENTRY_SET, paramArr);

			ssn.update("accounts.remove-bunch-type", bunchType);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public EntryTemplate[] getEntryTemplates(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, AccountPrivConstants.VIEW_ACCOUNT_ENTRY_TEMPLATE, paramArr);
			long tmptime = System.currentTimeMillis();
			String limitation = CommonController.getLimitationByPriv(ssn,
					AccountPrivConstants.VIEW_ACCOUNT_ENTRY_TEMPLATE);
			List<EntryTemplate> sets = ssn.queryForList("accounts.get-entry-templates",
					convertQueryParams(params, limitation));
			System.out.println(System.currentTimeMillis() - tmptime);
			return sets.toArray(new EntryTemplate[sets.size()]);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public Integer getEntryTemplatesCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, AccountPrivConstants.VIEW_ACCOUNT_ENTRY_TEMPLATE, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn,
					AccountPrivConstants.VIEW_ACCOUNT_ENTRY_TEMPLATE);
			return (Integer) ssn.queryForObject("accounts.get-entry-templates-count",
					convertQueryParams(params, limitation));
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public EntryTemplatePair getEntryTemplatePair(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSessionFE(userSessionId);
			List<EntryTemplatePair> tmpls = ssn.queryForList("accounts.get-entry-template-pair",
					convertQueryParams(params));
			if (!tmpls.isEmpty())
				return tmpls.get(0);
			else
				return new EntryTemplatePair();
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public EntryTemplate addEntryTemplate(Long userSessionId, EntryTemplate entryTemplate) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(entryTemplate.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, AccountPrivConstants.ADD_ACCOUNT_ENTRY_TEMPLATE, paramArr);

			ssn.update("accounts.add-entry-template", entryTemplate);

			Filter[] filters = new Filter[1];
			filters[0] = new Filter();
			filters[0].setElement("id");
			filters[0].setValue(entryTemplate.getId().toString());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (EntryTemplate) ssn.queryForObject("accounts.get-entry-templates",
					convertQueryParams(params));
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public EntryTemplate editEntryTemplate(Long userSessionId, EntryTemplate entryTemplate) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(entryTemplate.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, AccountPrivConstants.MODIFY_ACCOUNT_ENTRY_TEMPLATE, paramArr);

			ssn.update("accounts.modify-entry-template", entryTemplate);

			Filter[] filters = new Filter[1];
			filters[0] = new Filter();
			filters[0].setElement("id");
			filters[0].setValue(entryTemplate.getId().toString());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (EntryTemplate) ssn.queryForObject("accounts.get-entry-templates",
					convertQueryParams(params));
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void removeEntryTemplate(Long userSessionId, EntryTemplate entryTemplate) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(entryTemplate.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, AccountPrivConstants.REMOVE_ACCOUNT_ENTRY_TEMPLATE, paramArr);

			ssn.update("accounts.remove-entry-template", entryTemplate);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public List<MacrosType> getMacrosTypes(Long userSessionId, final SelectionParams params) {
		return executeWithSession(userSessionId, AccountPrivConstants.VIEW_ACCOUNT_MACROS_TYPE,
								  AuditParamUtil.getCommonParamRec(params.getFilters()), logger,
								  new IbatisSessionCallback<List<MacrosType>>() {
			@Override
			public List<MacrosType> doInSession(SqlMapSession ssn) throws Exception {
				String limitation = CommonController.getLimitationByPriv(ssn, AccountPrivConstants.VIEW_ACCOUNT_MACROS_TYPE);
				return ssn.queryForList("accounts.get-macros-types", convertQueryParams(params, limitation));
			}
		});
	}


	public Integer getMacrosTypesCount(Long userSessionId, final SelectionParams params) {
		return executeWithSession(userSessionId, AccountPrivConstants.VIEW_ACCOUNT_MACROS_TYPE,
								  AuditParamUtil.getCommonParamRec(params.getFilters()), logger,
								  new IbatisSessionCallback<Integer>() {
			@Override
			public Integer doInSession(SqlMapSession ssn) throws Exception {
				String limitation = CommonController.getLimitationByPriv(ssn, AccountPrivConstants.VIEW_ACCOUNT_MACROS_TYPE);
				return (Integer) ssn.queryForObject("accounts.get-macros-types-count", convertQueryParams(params, limitation));
			}
		});
	}


	public MacrosType addMacrosType(Long userSessionId, final MacrosType macrosType) {
		return executeWithSession(userSessionId, AccountPrivConstants.ADD_ACCOUNT_MACROS_TYPE,
								  AuditParamUtil.getCommonParamRec(macrosType.getAuditParameters()), logger,
								  new IbatisSessionCallback<MacrosType>() {
			@Override
			public MacrosType doInSession(SqlMapSession ssn) throws Exception {
				ssn.update("accounts.add-macros-type", macrosType);

				List<Filter> filters = new ArrayList<Filter>();
				filters.add(Filter.create("id", macrosType.getId()));
				filters.add(Filter.create("lang", macrosType.getLang()));
				if (macrosType.getInstId() != null) {
					filters.add(Filter.create("instId", macrosType.getInstId()));
				}
				if (macrosType.getBunchTypeId() != null) {
					filters.add(Filter.create("bunchTypeId", macrosType.getBunchTypeId()));
				}
				if (macrosType.getStatus() != null) {
					filters.add(Filter.create("status", macrosType.getStatus()));
				}
				SelectionParams params = new SelectionParams();
				params.setFilters(filters);

				List<MacrosType> types = ssn.queryForList("accounts.get-macros-types", convertQueryParams(params));
				if (types != null && types.size() > 0) {
					return types.get(0);
				} else {
					return macrosType;
				}
			}
		});
	}


	public MacrosType editMacrosType(Long userSessionId, final MacrosType macrosType) {
		return executeWithSession(userSessionId, AccountPrivConstants.MODIFY_ACCOUNT_MACROS_TYPE,
								  AuditParamUtil.getCommonParamRec(macrosType.getAuditParameters()), logger,
								  new IbatisSessionCallback<MacrosType>() {
			@Override
			public MacrosType doInSession(SqlMapSession ssn) throws Exception {
				ssn.update("accounts.modify-macros-type", macrosType);

				List<Filter> filters = new ArrayList<Filter>();
				filters.add(Filter.create("id", macrosType.getId()));
				filters.add(Filter.create("lang", macrosType.getLang()));
				if (macrosType.getInstId() != null) {
					filters.add(Filter.create("instId", macrosType.getInstId()));
				}
				if (macrosType.getBunchTypeId() != null) {
					filters.add(Filter.create("bunchTypeId", macrosType.getBunchTypeId()));
				}
				if (macrosType.getStatus() != null) {
					filters.add(Filter.create("status", macrosType.getStatus()));
				}
				SelectionParams params = new SelectionParams();
				params.setFilters(filters);

				List<MacrosType> types = ssn.queryForList("accounts.get-macros-types", convertQueryParams(params));
				if (types != null && types.size() > 0) {
					return types.get(0);
				} else {
					return macrosType;
				}
			}
		});
	}


	public void removeMacrosType(Long userSessionId, final MacrosType macrosType) {
		executeWithSession(userSessionId, AccountPrivConstants.REMOVE_ACCOUNT_MACROS_TYPE,
						   AuditParamUtil.getCommonParamRec(macrosType.getAuditParameters()), logger,
						   new IbatisSessionCallback<Void>() {
			@Override
			public Void doInSession(SqlMapSession ssn) throws Exception {
				ssn.update("accounts.remove-macros-type", macrosType);
				return null;
			}
		});
	}

	@SuppressWarnings("unchecked")
	public List<String> getAccountTypesByEntityType(Long userSessionId, String entityType) {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSessionFE(userSessionId);

			return ssn.queryForList("accounts.get-account-types-by-entity-type", entityType);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void generateGLAccounts(Long userSessionId, AccountGL filter) {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSessionFE(userSessionId);

			ssn.update("accounts.generate-gl-accounts", filter);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public AccountGL createGLAccount(Long userSessionId, AccountGL account) {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSessionFE(userSessionId);

			ssn.update("accounts.create-gl-account", account);

			Filter[] filters = new Filter[1];
			filters[0] = new Filter();
			filters[0].setElement("id");
			filters[0].setValue(account.getId().toString());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (AccountGL) ssn.queryForObject("accounts.get-gl-accounts",
					convertQueryParams(params));
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void deleteGLAccount(Long userSessionId, AccountGL account) {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSessionFE(userSessionId);

			ssn.update("accounts.remove-gl-account", account);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public EntryTemplatePair[] getEntryTemplatePairs(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, AccountPrivConstants.VIEW_ENTRY_TEMPLATE_PAIR, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, AccountPrivConstants.VIEW_ENTRY_TEMPLATE_PAIR);
			
			List<EntryTemplate> sets = ssn.queryForList("accounts.get-entry-template-pairs",
					convertQueryParams(params, limitation));
			return sets.toArray(new EntryTemplatePair[sets.size()]);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public Integer getEntryTemplatePairsCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, AccountPrivConstants.VIEW_ENTRY_TEMPLATE_PAIR, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, AccountPrivConstants.VIEW_ENTRY_TEMPLATE_PAIR);
			
			return (Integer) ssn.queryForObject("accounts.get-entry-template-pairs-count",
					convertQueryParams(params, limitation));
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public EntryTemplatePair addEntryTemplatePair(Long userSessionId, EntryTemplatePair pair) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(pair.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, AccountPrivConstants.ADD_ENTRY_TEMPLATE_PAIR, paramArr);

			pair = addEntryTemplatePairImpl(pair, ssn);

			ArrayList<Filter> filters = new ArrayList<Filter>();
			if (pair.getDebitId() != null) {
				Filter filter = new Filter();
				filter.setElement("debitId");
				filter.setValue(pair.getDebitId().toString());
				filters.add(filter);
			}
			if (pair.getCreditId() != null) {
				Filter filter = new Filter();
				filter.setElement("creditId");
				filter.setValue(pair.getCreditId().toString());
				filters.add(filter);
			}

			SelectionParams params = new SelectionParams();
			params.setFilters((Filter[]) filters.toArray(new Filter[filters.size()]));

			return (EntryTemplatePair) ssn.queryForObject("accounts.get-entry-template-pairs",
					convertQueryParams(params));
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	private EntryTemplatePair addEntryTemplatePairImpl(EntryTemplatePair pair, SqlMapSession ssn)
			throws SQLException {
		if (pair.isEditDebit() && !pair.isEditCredit()) {
			EntryTemplate debit = pair.getDebit();
			ssn.update("accounts.add-entry-template", debit);
			pair.setDebitId(debit.getId());
		} else if (!pair.isEditDebit() && pair.isEditCredit()) {
			EntryTemplate credit = pair.getCredit();
			ssn.update("accounts.add-entry-template", credit);
			pair.setCreditId(credit.getId());
		} else {
			ssn.update("accounts.add-entry-template-pair", pair);
		}

		return pair;
	}


	public EntryTemplatePair editEntryTemplatePair(Long userSessionId, EntryTemplatePair pair) {
		SqlMapSession ssn = null;

		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(pair.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, AccountPrivConstants.MODIFY_ENTRY_TEMPLATE_PAIR, paramArr);

			Integer debitId = pair.getDebitId();
			Integer creditId = pair.getCreditId();

			if (pair.isEditDebit() && pair.getDebitId() != null) {
				ssn.update("accounts.modify-entry-template", pair.getDebit());
			} else if (pair.isEditDebit() && pair.getDebitId() == null) {
				ssn.update("accounts.add-entry-template", pair.getDebit());
				debitId = pair.getDebitId();
			} else if (!pair.isEditDebit() && pair.getDebitId() != null) {
				ssn.delete("accounts.remove-entry-template", pair.getDebit());
				debitId = null;
			}

			if (pair.isEditCredit() && pair.getCreditId() != null) {
				ssn.update("accounts.modify-entry-template", pair.getCredit());
			} else if (pair.isEditCredit() && pair.getCreditId() == null) {
				ssn.update("accounts.add-entry-template", pair.getCredit());
				creditId = pair.getCreditId();
			} else if (!pair.isEditCredit() && pair.getCreditId() != null) {
				ssn.delete("accounts.remove-entry-template", pair.getCredit());
				creditId = null;
			}

			ArrayList<Filter> filters = new ArrayList<Filter>();
			if (debitId != null) {
				Filter filter = new Filter();
				filter.setElement("debitId");
				filter.setValue(pair.getDebitId().toString());
				filters.add(filter);
			}
			if (creditId != null) {
				Filter filter = new Filter();
				filter.setElement("creditId");
				filter.setValue(pair.getCreditId().toString());
				filters.add(filter);
			}

			SelectionParams params = new SelectionParams();
			params.setFilters((Filter[]) filters.toArray(new Filter[filters.size()]));

			return (EntryTemplatePair) ssn.queryForObject("accounts.get-entry-template-pairs",
					convertQueryParams(params));
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void removeEntryTemplatePair(Long userSessionId, EntryTemplatePair pair) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(pair.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, AccountPrivConstants.REMOVE_ENTRY_TEMPLATE_PAIR, paramArr);

			if (pair.getDebitId() != null) {
				ssn.delete("accounts.remove-entry-template", pair.getDebit());
			}

			if (pair.getCreditId() != null) {
				ssn.delete("accounts.remove-entry-template", pair.getCredit());
			}
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	@SuppressWarnings("unchecked")
	public Account[] getAccountObjects(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, (params.getPrivilege()!=null ? params.getPrivilege() : AccountPrivConstants.VIEW_ACCOUNT), paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn,
					(params.getPrivilege()!=null ? params.getPrivilege() : AccountPrivConstants.VIEW_ACCOUNT));
			List<Account> accs = ssn.queryForList("accounts.get-account-objects",
					convertQueryParams(params, limitation));
			return accs.toArray(new Account[accs.size()]);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public int getAccountObjectsCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, (params.getPrivilege()!=null ? params.getPrivilege() : AccountPrivConstants.VIEW_ACCOUNT), paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn,
					(params.getPrivilege()!=null ? params.getPrivilege() : AccountPrivConstants.VIEW_ACCOUNT));
			return (Integer) ssn.queryForObject("accounts.get-account-objects-count",
					convertQueryParams(params, limitation));
		} catch (SQLException e) {
			logger.error("", e);
			throw new DataAccessException(e);
		} finally {
			close(ssn);
		}
	}


	@SuppressWarnings("unchecked")
	public Account[] getAccounts(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, (params.getPrivilege()!=null ? params.getPrivilege() : AccountPrivConstants.VIEW_ACCOUNT), paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn,
					(params.getPrivilege()!=null ? params.getPrivilege() : AccountPrivConstants.VIEW_ACCOUNT));
			List<Account> accs = ssn.queryForList("accounts.get-accounts", convertQueryParams(
					params, limitation));
			return accs.toArray(new Account[accs.size()]);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public int getAccountsCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, (params.getPrivilege()!=null ? params.getPrivilege() : AccountPrivConstants.VIEW_ACCOUNT), paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn,
					(params.getPrivilege()!=null ? params.getPrivilege() : AccountPrivConstants.VIEW_ACCOUNT));
			return (Integer) ssn.queryForObject("accounts.get-accounts-count", convertQueryParams(
					params, limitation));
		} catch (SQLException e) {
			logger.error("", e);
			throw new DataAccessException(e);
		} finally {
			close(ssn);
		}
	}


	public QueryResult getIssAccountsRs(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, AccountPrivConstants.VIEW_ISSUING_ACCOUNTS, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn,
					AccountPrivConstants.VIEW_ISSUING_ACCOUNTS);
			QueryResult data = (QueryResult)ssn.queryForObject("accounts.get-iss-accounts-rs", convertQueryParams(
					params, limitation));
			
			return data;
		} catch (SQLException e) {
			logger.error("", e);
			throw new DataAccessException(e);
		} finally {
			close(ssn);
		}
	}


	@SuppressWarnings("unchecked")
	public Account[] getIssAccounts(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, AccountPrivConstants.VIEW_ISSUING_ACCOUNTS, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn,
					AccountPrivConstants.VIEW_ISSUING_ACCOUNTS);
			List<Account> accs = ssn.queryForList("accounts.get-iss-accounts", convertQueryParams(
					params, limitation));
			return accs.toArray(new Account[accs.size()]);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public int getIssAccountsCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, AccountPrivConstants.VIEW_ISSUING_ACCOUNTS, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn,
					AccountPrivConstants.VIEW_ISSUING_ACCOUNTS);
			return (Integer) ssn.queryForObject("accounts.get-iss-accounts-count",
					convertQueryParams(params, limitation));
		} catch (SQLException e) {
			logger.error("", e);
			throw new DataAccessException(e);
		} finally {
			close(ssn);
		}
	}


	@SuppressWarnings("unchecked")
	public Account[] getAcqAccounts(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, AccountPrivConstants.VIEW_ACQUIRING_ACCOUNTS, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn,
					AccountPrivConstants.VIEW_ACQUIRING_ACCOUNTS);
			List<Account> accs = ssn.queryForList("accounts.get-acq-accounts", convertQueryParams(
					params, limitation));
			return accs.toArray(new Account[accs.size()]);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public int getAcqAccountsCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, AccountPrivConstants.VIEW_ACQUIRING_ACCOUNTS, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn,
					AccountPrivConstants.VIEW_ACQUIRING_ACCOUNTS);
			return (Integer) ssn.queryForObject("accounts.get-acq-accounts-count",
					convertQueryParams(params, limitation));
		} catch (SQLException e) {
			logger.error("", e);
			throw new DataAccessException(e);
		} finally {
			close(ssn);
		}
	}


	@SuppressWarnings("unchecked")
	public Account[] getAccountsByObject(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSessionFE(userSessionId);

			List<Account> accs = ssn.queryForList("accounts.get-accounts-by-object",
					convertQueryParams(params));
			return accs.toArray(new Account[accs.size()]);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	@SuppressWarnings("unchecked")
	public AccountTypeEntity[] getAccountTypeEntities(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, AccountPrivConstants.VIEW_ACCOUNT_TYPE_ENTITY, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn,
					AccountPrivConstants.VIEW_ACCOUNT_TYPE_ENTITY);
			List<AccountTypeEntity> accTypes = ssn.queryForList(
					"accounts.get-account-type-entities", convertQueryParams(params, limitation));
			return accTypes.toArray(new AccountTypeEntity[accTypes.size()]);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public int getAccountTypeEntitiesCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, AccountPrivConstants.VIEW_ACCOUNT_TYPE_ENTITY, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn,
					AccountPrivConstants.VIEW_ACCOUNT_TYPE_ENTITY);
			return (Integer) ssn.queryForObject("accounts.get-account-type-entities-count",
					convertQueryParams(params, limitation));
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public AccountTypeEntity addAccountTypeEntity(Long userSessionId,
			AccountTypeEntity accountTypeEntity) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(accountTypeEntity.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, AccountPrivConstants.ADD_ACCOUNT_TYPE_ENTITY, paramArr);

			ssn.update("accounts.add-account-type-entity", accountTypeEntity);

			Filter[] filters = new Filter[1];
			filters[0] = new Filter();
			filters[0].setElement("id");
			filters[0].setValue(accountTypeEntity.getId().toString());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (AccountTypeEntity) ssn.queryForObject("accounts.get-account-type-entities",
					convertQueryParams(params));
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void removeAccountTypeEntity(Long userSessionId, AccountTypeEntity accountTypeEntity) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(accountTypeEntity.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, AccountPrivConstants.REMOVE_ACCOUNT_TYPE_ENTITY, paramArr);

			ssn.update("accounts.remove-account-type-entity", accountTypeEntity);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	@SuppressWarnings("unchecked")
	public Balance[] getBalances(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, AccountPrivConstants.VIEW_ACCOUNT_BALANCES, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn,
					AccountPrivConstants.VIEW_ACCOUNT_BALANCES);
			List<Balance> balances = ssn.queryForList("accounts.get-balances", convertQueryParams(
					params, limitation));
			return balances.toArray(new Balance[balances.size()]);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public int getBalancesCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, AccountPrivConstants.VIEW_ACCOUNT_BALANCES, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn,
					AccountPrivConstants.VIEW_ACCOUNT_BALANCES);
			return (Integer) ssn.queryForObject("accounts.get-balances-count", convertQueryParams(
					params, limitation));
		} catch (SQLException e) {
			logger.error("", e);
			throw new DataAccessException(e);
		} finally {
			close(ssn);
		}
	}


	@SuppressWarnings("unchecked")
	public Transaction[] getTransactions(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, AccountPrivConstants.VIEW_TRANSACTION, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn,
					AccountPrivConstants.VIEW_TRANSACTION);
			List<Transaction> balances = ssn.queryForList("accounts.get-transactions",
					convertQueryParams(params, limitation));
			return balances.toArray(new Transaction[balances.size()]);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public int getTransactionsCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, AccountPrivConstants.VIEW_TRANSACTION, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn,
					AccountPrivConstants.VIEW_TRANSACTION);
			return (Integer) ssn.queryForObject("accounts.get-transactions-count",
					convertQueryParams(params, limitation));
		} catch (SQLException e) {
			logger.error("", e);
			throw new DataAccessException(e);
		} finally {
			close(ssn);
		}
	}


	@SuppressWarnings("unchecked")
	public Entry[] getEntries(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, AccountPrivConstants.VIEW_ACCOUNT_ENTRY_SET, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn,
					AccountPrivConstants.VIEW_ACCOUNT_ENTRY_SET);
			List<Entry> balances = ssn.queryForList("accounts.get-entries", convertQueryParams(
					params, limitation));
			return balances.toArray(new Entry[balances.size()]);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public int getEntriesCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, AccountPrivConstants.VIEW_ACCOUNT_ENTRY_SET, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn,
					AccountPrivConstants.VIEW_ACCOUNT_ENTRY_SET);
			return (Integer) ssn.queryForObject("accounts.get-entries-count", convertQueryParams(
					params, limitation));
		} catch (SQLException e) {
			logger.error("", e);
			throw new DataAccessException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public IsoAccountType[] getIsoAccountTypes(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, AccountPrivConstants.VIEW_ISO_ACCOUNT_TYPE, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, AccountPrivConstants.VIEW_ISO_ACCOUNT_TYPE);
			List<IsoAccountType> types = ssn.queryForList("accounts.get-iso-account-types",
					convertQueryParams(params, limitation));
			return types.toArray(new IsoAccountType[types.size()]);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public Integer getIsoAccountTypesCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, AccountPrivConstants.VIEW_ISO_ACCOUNT_TYPE, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, AccountPrivConstants.VIEW_ISO_ACCOUNT_TYPE);

			return (Integer) ssn.queryForObject("accounts.get-iso-account-types-count",
					convertQueryParams(params, limitation));
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public IsoAccountType addIsoAccountType(Long userSessionId, IsoAccountType isoType) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(isoType.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, AccountPrivConstants.ADD_ISO_ACCOUNT_TYPE, paramArr);

			ssn.update("accounts.add-iso-account-type", isoType);

			Filter[] filters = new Filter[1];
			filters[0] = new Filter();
			filters[0].setElement("id");
			filters[0].setValue(isoType.getId().toString());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (IsoAccountType) ssn.queryForObject("accounts.get-iso-account-types",
					convertQueryParams(params));
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public IsoAccountType editIsoAccountType(Long userSessionId, IsoAccountType isoType) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(isoType.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, AccountPrivConstants.MODIFY_ISO_ACCOUNT_TYPE, paramArr);

			ssn.update("accounts.modify-iso-account-type", isoType);

			Filter[] filters = new Filter[1];
			filters[0] = new Filter();
			filters[0].setElement("id");
			filters[0].setValue(isoType.getId().toString());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (IsoAccountType) ssn.queryForObject("accounts.get-iso-account-types",
					convertQueryParams(params));
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void removeIsoAccountType(Long userSessionId, IsoAccountType isoType) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(isoType.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, AccountPrivConstants.REMOVE_ISO_ACCOUNT_TYPE, paramArr);

			ssn.update("accounts.remove-iso-account-type", isoType);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public AccountAlgorithm[] getAccountAlgorithms(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, AccountPrivConstants.VIEW_ACCOUNT_SELECTION_ALGORITHM, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn,
					AccountPrivConstants.VIEW_ACCOUNT_SELECTION_ALGORITHM);
			List<AccountAlgorithm> algos = ssn.queryForList("accounts.get-account-algorithms",
					convertQueryParams(params, limitation));
			return algos.toArray(new AccountAlgorithm[algos.size()]);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public int getAccountAlgorithmsCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, AccountPrivConstants.VIEW_ACCOUNT_SELECTION_ALGORITHM, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn,
					AccountPrivConstants.VIEW_ACCOUNT_SELECTION_ALGORITHM);
			return (Integer) ssn.queryForObject("accounts.get-account-algorithms-count",
					convertQueryParams(params, limitation));
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public AccountAlgorithm addAccountAlgorithm(Long userSessionId, final AccountAlgorithm algorithm) {
		return executeWithSession(userSessionId,
								  AccountPrivConstants.ADD_ACCOUNT_SELECTION_ALGORITHM,
								  AuditParamUtil.getCommonParamRec(algorithm.getAuditParameters()),
								  logger,
								  new IbatisSessionCallback<AccountAlgorithm>() {
			@Override
			public AccountAlgorithm doInSession (SqlMapSession ssn) throws Exception {
				ssn.update("accounts.add-account-algorithm", algorithm);
				return algorithm.clone();
			}
		});
	}


	public AccountAlgorithm modifyAccountAlgorithm(Long userSessionId, final AccountAlgorithm algorithm) {
		return executeWithSession(userSessionId,
								  AccountPrivConstants.MODIFY_ACCOUNT_SELECTION_ALGORITHM,
								  AuditParamUtil.getCommonParamRec(algorithm.getAuditParameters()),
								  logger,
								  new IbatisSessionCallback<AccountAlgorithm>() {
			@Override
			public AccountAlgorithm doInSession (SqlMapSession ssn) throws Exception {
				ssn.update("accounts.modify-account-algorithm", algorithm);
				return algorithm.clone();
			}
		});
	}


	public void deleteAccountAlgorithm(Long userSessionId, final AccountAlgorithm algorithm) {
		executeWithSession(userSessionId,
						   AccountPrivConstants.REMOVE_ACCOUNT_SELECTION_ALGORITHM,
						   AuditParamUtil.getCommonParamRec(algorithm.getAuditParameters()),
						   logger,
						   new IbatisSessionCallback<Void>() {
			@Override
			public Void doInSession (SqlMapSession ssn) throws Exception {
				ssn.delete("accounts.remove-account-algorithm", algorithm);
				return null;
			}
		});
	}

	@SuppressWarnings("unchecked")
	public AccountAlgorithmStep[] getAccountAlgorithmSteps(Long userSessionId,
			SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, AccountPrivConstants.VIEW_ACCOUNT_SELECTION_STEPS, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn,
					AccountPrivConstants.VIEW_ACCOUNT_SELECTION_STEPS);
			List<AccountAlgorithmStep> steps = ssn.queryForList(
					"accounts.get-account-algorithm-steps", convertQueryParams(params, limitation));
			return steps.toArray(new AccountAlgorithmStep[steps.size()]);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public int getAccountAlgorithmStepsCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, AccountPrivConstants.VIEW_ACCOUNT_SELECTION_STEPS, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn,
					AccountPrivConstants.VIEW_ACCOUNT_SELECTION_STEPS);
			return (Integer) ssn.queryForObject("accounts.get-account-algorithm-steps-count",
					convertQueryParams(params, limitation));
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public AccountAlgorithmStep addAccountAlgorithmStep(Long userSessionId,
			AccountAlgorithmStep step) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(step.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, AccountPrivConstants.ADD_ACCOUNT_SELECTION_STEP, paramArr);

			ssn.update("accounts.add-account-algorithm-step", step);

			return step;
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public AccountAlgorithmStep modifyAccountAlgorithmStep(Long userSessionId,
			AccountAlgorithmStep step) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(step.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, AccountPrivConstants.MODIFY_ACCOUNT_SELECTION_STEP, paramArr);

			ssn.update("accounts.modify-account-algorithm-step", step);

			return step;
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void deleteAccountAlgorithmStep(Long userSessionId, AccountAlgorithmStep step) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(step.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, AccountPrivConstants.REMOVE_ACCOUNT_SELECTION_STEP, paramArr);

			ssn.delete("accounts.remove-account-algorithm-step", step);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public SelectionPriority[] getSelectionPriorities(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, AccountPrivConstants.VIEW_ACCOUNT_SELECTION_PRIORITY, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn,
					AccountPrivConstants.VIEW_ACCOUNT_SELECTION_PRIORITY);
			List<SelectionPriority> priorities = ssn.queryForList(
					"accounts.get-selection-priorities", convertQueryParams(params, limitation));
			return priorities.toArray(new SelectionPriority[priorities.size()]);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public int getSelectionPrioritiesCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, AccountPrivConstants.VIEW_ACCOUNT_SELECTION_PRIORITY, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn,
					AccountPrivConstants.VIEW_ACCOUNT_SELECTION_PRIORITY);
			return (Integer) ssn.queryForObject("accounts.get-selection-priorities-count",
					convertQueryParams(params, limitation));
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	public SelectionPriority addSelectionPriority(Long userSessionId, final SelectionPriority priority) {
		return executeWithSession(userSessionId,
								  AccountPrivConstants.ADD_ACCOUNT_SELECTION_PRIORITY,
								  AuditParamUtil.getCommonParamRec(priority.getAuditParameters()),
								  logger,
								  new IbatisSessionCallback<SelectionPriority>() {
			@Override
			public SelectionPriority doInSession (SqlMapSession ssn) throws Exception {
				ssn.update("accounts.add-selection-priority", priority);

				List<Filter> filters = new ArrayList<Filter>(1);
				filters.add(Filter.create("id", priority.getId()));
				SelectionParams params = new SelectionParams(filters);

				List<SelectionPriority> out = ssn.queryForList("accounts.get-selection-priorities", convertQueryParams(params));
				return (out != null && !out.isEmpty()) ? out.get(0) : priority;
			}
		});
	}

	public SelectionPriority modifySelectionPriority(Long userSessionId, final SelectionPriority priority) {
		return executeWithSession(userSessionId,
								  AccountPrivConstants.MODIFY_ACCOUNT_SELECTION_PRIORITY,
								  AuditParamUtil.getCommonParamRec(priority.getAuditParameters()),
								  logger,
								  new IbatisSessionCallback<SelectionPriority>() {
			@Override
			public SelectionPriority doInSession (SqlMapSession ssn) throws Exception {
				ssn.update("accounts.modify-selection-priority", priority);

				List<Filter> filters = new ArrayList<Filter>(1);
				filters.add(Filter.create("id", priority.getId()));
				SelectionParams params = new SelectionParams(filters);

				List<SelectionPriority> out = ssn.queryForList("accounts.get-selection-priorities", convertQueryParams(params));
				return (out != null && !out.isEmpty()) ? out.get(0) : priority;
			}
		});
	}

	public void removeSelectionPriority(Long userSessionId, final SelectionPriority priority) {
		executeWithSession(userSessionId,
						   AccountPrivConstants.MODIFY_ACCOUNT_SELECTION_PRIORITY,
						   AuditParamUtil.getCommonParamRec(priority.getAuditParameters()),
						   logger,
						   new IbatisSessionCallback<Void>() {
			@Override
			public Void doInSession (SqlMapSession ssn) throws Exception {
				ssn.delete("accounts.remove-selection-priority", priority);
				return null;
			}
		});
	}


	public Account getAccountInfo(Long userSessionId, String accountNumber) {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSessionFE(userSessionId);
			return (Account) ssn.queryForObject("accounts.get-account-info", accountNumber);
		} catch (SQLException e) {
			throw new DataAccessException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public Account[] getAccountsCur(Long userSessionId, SelectionParams params,
			Map<String, Object> paramMap) {
		Account [] result;
		SqlMapSession ssn = null;
		try{
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, null, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn,
					AccountPrivConstants.VIEW_ACCOUNT);
			List<Filter> filters = new ArrayList<Filter> 
			(Arrays.asList((Filter[])paramMap.get("param_tab")));
			filters.add(new Filter("PRIVIL_LIMITATION", limitation));
			paramMap.put("param_tab", filters.toArray(new Filter[filters.size()]));
			QueryParams qparams = convertQueryParams(params);
			paramMap.put("first_row", qparams.getRange().getStartPlusOne());
			paramMap.put("last_row", qparams.getRange().getEndPlusOne());
			paramMap.put("sorting_tab", params.getSortElement());
            paramMap.put("row_count", params.getRowCount());
			ssn.update("accounts.get-all-accounts-cur", paramMap);
			List <Account>accounts = (List<Account>)paramMap.get("ref_cur");
			result = accounts.toArray(new Account[accounts.size()]);
		}catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
		return result;
	}


	public int getAccountsCountCur(Long userSessionId,
			Map<String, Object> params) {
		Integer result = 0;
		SqlMapSession ssn = null;
		try{
			ssn = getIbatisSession(userSessionId);
			String limitation = CommonController.getLimitationByPriv(ssn,
					AccountPrivConstants.VIEW_ACCOUNT);
			List<Filter> filters = new ArrayList<Filter> 
			(Arrays.asList((Filter[])params.get("param_tab")));
			filters.add(new Filter("PRIVIL_LIMITATION", limitation));
			params.put("param_tab", filters.toArray(new Filter[filters.size()]));
			ssn.update("accounts.get-all-accounts-cur-count", params);
			result = (Integer)params.get("row_count");
		}catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
		return result;
	}
	
	@SuppressWarnings("unchecked")
	public List<BalanceType> getBalanceExistsMacros(Long userSessionId, SelectionParams params) throws UserException{
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSession(userSessionId);
			return (List<BalanceType>) ssn.queryForList("accounts.get-balance-update-macros", convertQueryParams(params));
		} catch (SQLException e) {			
			if (e.getErrorCode() >= 20000 && e.getErrorCode() <= 20999 ){
				throw new UserException(e.getCause().getMessage());
			} else {
				throw createDaoException(e);
			}
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public List<String> getAccountNumbersByCard(Long userSessionId, String cardNumber, String lang) throws UserException {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSession(userSessionId);
			Map<String, Object> map = new HashMap<String, Object>();
			map.put("cardNumber", cardNumber);
			map.put("lang", lang);
			return ssn.queryForList("accounts.get-accounts-by-card-number", map);
		} catch (SQLException e) {
			if (e.getErrorCode() >= 20000 && e.getErrorCode() <= 20999 ){
				throw new UserException(e.getCause().getMessage());
			} else {
				throw createDaoException(e);
			}
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public List<Account> getAccountsByCardId(Long userSessionId, Long cardId) throws UserException {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSession(userSessionId);
			Map<String, Object> map = new HashMap<String, Object>();
			map.put("cardId", cardId);
			return ssn.queryForList("accounts.get-accounts-by-card-id", map);
		} catch (SQLException e) {
			if (e.getErrorCode() >= 20000 && e.getErrorCode() <= 20999 ){
				throw new UserException(e.getCause().getMessage());
			} else {
				throw createDaoException(e);
			}
		} finally {
			close(ssn);
		}
	}


	public void restructureToDpp(Long userSessionId, final DppCalculation dppCalculation) {
		executeWithSession(userSessionId, logger, new IbatisSessionCallback<Void>() {
			@Override
			public Void doInSession(SqlMapSession ssn) throws Exception {
				ssn.update("accounts.restructure-to-dpp", dppCalculation);
				return null;
			}
		});
	}

	@SuppressWarnings("unchecked")
	public PriorityAccount[] getPriorityAccounts(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, AccountPrivConstants.VIEW_PRIORITY_ACCOUNTS, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn,
					AccountPrivConstants.VIEW_PRIORITY_ACCOUNTS);
			List<PriorityAccount> priorAccounts = ssn.queryForList(
					"accounts.get-priority-accounts", convertQueryParams(params, limitation));
			return priorAccounts.toArray(new PriorityAccount[priorAccounts.size()]);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public int getPriorityAccountsCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, AccountPrivConstants.VIEW_PRIORITY_ACCOUNTS, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn,
					AccountPrivConstants.VIEW_PRIORITY_ACCOUNTS);
			return (Integer) ssn.queryForObject(
					"accounts.get-priority-accounts-count", convertQueryParams(params, limitation));
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}
}
