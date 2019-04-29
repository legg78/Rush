package ru.bpc.sv2.logic;

import com.ibatis.sqlmap.client.SqlMapSession;
import org.apache.log4j.Logger;
import ru.bpc.sv2.common.CommonParamRec;
import ru.bpc.sv2.credit.*;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.controller.CommonController;
import ru.bpc.sv2.logic.utility.db.IbatisAware;
import ru.bpc.sv2.logic.utility.db.IbatisSessionCallback;
import ru.bpc.sv2.logic.utility.db.QueryParams;
import ru.bpc.sv2.utils.AuditParamUtil;

import ru.bpc.sv2.logic.utility.db.DataAccessException;

import java.sql.SQLException;
import java.util.*;

/**
 * Session Bean implementation class IssuingDao
 */
public class CreditDao extends IbatisAware {

	private static final Logger logger = Logger.getLogger("CREDIT");

	@SuppressWarnings("unchecked")
	public CreditInvoice[] getInvoices( Long userSessionId, SelectionParams params) {
    	SqlMapSession ssn = null;
		try	{
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, CreditPrivConstants.VIEW_CREDIT_INVOICE, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, CreditPrivConstants.VIEW_CREDIT_INVOICE);
			List<CreditInvoice> invoices = ssn.queryForList("crd.get-invoices", convertQueryParams(params, limitation));
			return invoices.toArray(new CreditInvoice[invoices.size()]);
		} catch (SQLException e) {
			logger.error("", e);
			throw new DataAccessException(e);
		} finally {
			close(ssn);
		}
	}


	public int getInvoicesCount( Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, CreditPrivConstants.VIEW_CREDIT_INVOICE, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, CreditPrivConstants.VIEW_CREDIT_INVOICE);
			return (Integer) ssn.queryForObject("crd.get-invoices-count", convertQueryParams(params, limitation));
		} catch (SQLException e) {
			logger.error("", e);
			throw new DataAccessException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public CreditInvoiceDebt[] getInvoiceDebts( Long userSessionId, SelectionParams params) {
    	SqlMapSession ssn = null;
		try	{
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, CreditPrivConstants.VIEW_CREDIT_INVOICE_DEBT, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, CreditPrivConstants.VIEW_CREDIT_INVOICE_DEBT);
			List<CreditInvoiceDebt> debts = ssn.queryForList("crd.get-invoice-debts", convertQueryParams(params, limitation));
			return debts.toArray(new CreditInvoiceDebt[debts.size()]);
		} catch (SQLException e) {
			logger.error("", e);
			throw new DataAccessException(e);
		} finally {
			close(ssn);
		}
	}


	public int getInvoiceDebtsCount( Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, CreditPrivConstants.VIEW_CREDIT_INVOICE_DEBT, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, CreditPrivConstants.VIEW_CREDIT_INVOICE_DEBT);
			return (Integer) ssn.queryForObject("crd.get-invoice-debts-count", convertQueryParams(params, limitation));
		} catch (SQLException e) {
			logger.error("", e);
			throw new DataAccessException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public CreditInvoicePayment[] getInvoicePayments( Long userSessionId, SelectionParams params) {
    	SqlMapSession ssn = null;
		try	{
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, CreditPrivConstants.VIEW_CREDIT_INVOICE_PAYMENT, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, CreditPrivConstants.VIEW_CREDIT_INVOICE_PAYMENT);
			List<CreditInvoicePayment> payments = ssn.queryForList("crd.get-invoice-payments", convertQueryParams(params, limitation));
			return payments.toArray(new CreditInvoicePayment[payments.size()]);
		} catch (SQLException e) {
			logger.error("", e);
			throw new DataAccessException(e);
		} finally {
			close(ssn);
		}
	}


	public int getInvoicePaymentsCount( Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, CreditPrivConstants.VIEW_CREDIT_INVOICE_PAYMENT, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, CreditPrivConstants.VIEW_CREDIT_INVOICE_PAYMENT);
			return (Integer) ssn.queryForObject("crd.get-invoice-payments-count", convertQueryParams(params, limitation));
		} catch (SQLException e) {
			logger.error("", e);
			throw new DataAccessException(e);
		} finally {
			close(ssn);
		}
	}
	
	@SuppressWarnings("unchecked")
	public Aging[] getInvoiceAgings( Long userSessionId, SelectionParams params) {
    	SqlMapSession ssn = null;
		try	{
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, CreditPrivConstants.VIEW_AGING, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, CreditPrivConstants.VIEW_AGING);
			List<Aging> agings = ssn.queryForList("crd.get-invoice-agings", convertQueryParams(params, limitation));
			return agings.toArray(new Aging[agings.size()]);
		} catch (SQLException e) {
			logger.error("", e);
			throw new DataAccessException(e);
		} finally {
			close(ssn);
		}
	}


	public int getInvoiceAgingsCount( Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, CreditPrivConstants.VIEW_AGING, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, CreditPrivConstants.VIEW_AGING);
			return (Integer) ssn.queryForObject("crd.get-invoice-agings-count", convertQueryParams(params, limitation));
		} catch (SQLException e) {
			logger.error("", e);
			throw new DataAccessException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public CreditDebt[] getDebts(Long userSessionId, SelectionParams params){
		SqlMapSession ssn = null;
		try{
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, CreditPrivConstants.VIEW_CREDIT_DEBT, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, CreditPrivConstants.VIEW_CREDIT_DEBT);
			List<CreditDebt> debts = ssn.queryForList("crd.get-debts", convertQueryParams(params, limitation));
			return debts.toArray(new CreditDebt[debts.size()]);
		} catch (SQLException e){
			logger.error("", e);
			throw new DataAccessException(e);
		} finally {
			close(ssn);
		}
	}

	public int getDebtsCount(Long userSessionId, SelectionParams params){
		SqlMapSession ssn = null;
		try{
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, CreditPrivConstants.VIEW_CREDIT_DEBT, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, CreditPrivConstants.VIEW_CREDIT_DEBT);
			Integer debtsCount = (Integer)ssn.queryForObject("crd.get-debts-count", convertQueryParams(params, limitation));
			return debtsCount;
		} catch (SQLException e){
			logger.error("", e);
			throw new DataAccessException(e);
		} finally {
			close(ssn);
		}
	}
	
	@SuppressWarnings("unchecked")
	public CreditDebt[] getDebtsCur(Long userSessionId, SelectionParams params,
			Map<String, Object> paramMap) {
		CreditDebt result[];
		SqlMapSession ssn = null;
		try{
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, null, paramArr);
			QueryParams qparams = convertQueryParams(params);
			paramMap.put("first_row", qparams.getRange().getStartPlusOne());
			paramMap.put("last_row", qparams.getRange().getEndPlusOne());
			paramMap.put("sorting_tab", params.getSortElement());
			ssn.update("crd.get-debits-cur", paramMap);
			List <CreditDebt> debs = (List<CreditDebt>)paramMap.get("ref_cur");
			result = debs.toArray(new CreditDebt[debs.size()]);
		}catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
		return result;
	}


	public int getDebtsCountCur(Long userSessionId, Map<String, Object> paramMap) {
		Integer result = 0;
		SqlMapSession ssn = null;
		try{
			ssn = getIbatisSession(userSessionId);
			ssn.update("crd.get-debits-cur-count", paramMap);
			result = (Integer)paramMap.get("row_count");
		}catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
		return result;
	}

	@SuppressWarnings("unchecked")
	public CreditDebtPayment[] getDebtPayments(Long userSessionId, SelectionParams params){
		SqlMapSession ssn = null;
		try{
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, CreditPrivConstants.VIEW_CREDIT_DEBT_PAYMENT, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, CreditPrivConstants.VIEW_CREDIT_DEBT_PAYMENT);
			List<CreditDebtPayment> debtPayments = ssn.queryForList("crd.get-debtPayments", convertQueryParams(params, limitation));
			return debtPayments.toArray(new CreditDebtPayment[debtPayments.size()]);
		} catch (SQLException e){
			logger.error("", e);
			throw new DataAccessException(e);
		} finally {
			close(ssn);
		}
	}

	public int getDebtPaymentsCount(Long userSessionId, SelectionParams params){
		SqlMapSession ssn = null;
		try{
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, CreditPrivConstants.VIEW_CREDIT_DEBT_PAYMENT, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, CreditPrivConstants.VIEW_CREDIT_DEBT_PAYMENT);
			Integer debtPaymentsCount = (Integer)ssn.queryForObject("crd.get-debtPayments-count", convertQueryParams(params, limitation));
			return debtPaymentsCount;
		} catch (SQLException e){
			logger.error("", e);
			throw new DataAccessException(e);
		} finally {
			close(ssn);
		}
	}


	@SuppressWarnings("unchecked")
	public List<CreditDebtInterest> getDebtInterests(Long userSessionId, SelectionParams params){
		SqlMapSession ssn = null;
		try{
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, CreditPrivConstants.VIEW_CREDIT_DEBT_INTEREST, paramArr);
			Map<String, Object> paramMap = new HashMap<String, Object>();
			List<Filter> filters = new ArrayList<Filter>(Arrays.asList(params.getFilters()));
			for (Filter filter : filters) {
				if (filter.getElement().equals("debtId")) {
					paramMap.put("debt_id", filter.getValue());
				}
			}
			paramMap.put("sorting_tab", params.getSortElement());
			ssn.update("crd.get-debt-interests", paramMap);
			return (List<CreditDebtInterest>)paramMap.get("ref_cur");
		} catch (SQLException e){
			logger.error("", e);
			throw new DataAccessException(e);
		} finally {
			close(ssn);
		}
	}


	public int getDebtInterestsCount(Long userSessionId, SelectionParams params){
		SqlMapSession ssn = null;
		try{
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, CreditPrivConstants.VIEW_CREDIT_DEBT_INTEREST, paramArr);
			Map<String, Object> paramMap = new HashMap<String, Object>();
			List<Filter> filters = new ArrayList<Filter>(Arrays.asList(params.getFilters()));
			for (Filter filter : filters) {
				if (filter.getElement().equals("debtId")) {
					paramMap.put("debt_id", filter.getValue());
				}
			}
			ssn.update("crd.get-debt-interests-count", paramMap);
			return (Integer)paramMap.get("row_count");
		} catch (SQLException e){
			logger.error("", e);
			throw new DataAccessException(e);
		} finally {
			close(ssn);
		}
	}


	@SuppressWarnings("unchecked")
	public List<CreditDebtInterest> getInvoiceInterests(Long userSessionId, SelectionParams params){
		SqlMapSession ssn = null;
		try{
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, CreditPrivConstants.VIEW_CREDIT_INVOICE_INTEREST, paramArr);
			Map<String, Object> paramMap = new HashMap<String, Object>();
			List<Filter> filters = new ArrayList<Filter>(Arrays.asList(params.getFilters()));
			for (Filter filter : filters) {
				if (filter.getElement().equals("invoiceId")) {
					paramMap.put("invoice_id", filter.getValue());
				}
				if (filter.getElement().equals("accountId")) {
					paramMap.put("account_id", filter.getValue());
				}
			}
			paramMap.put("sorting_tab", params.getSortElement());
			ssn.update("crd.get-invoice-interests", paramMap);
			return (List<CreditDebtInterest>)paramMap.get("ref_cur");
		} catch (SQLException e){
			logger.error("", e);
			throw new DataAccessException(e);
		} finally {
			close(ssn);
		}
	}


	public int getInvoiceInterestsCount(Long userSessionId, SelectionParams params){
		SqlMapSession ssn = null;
		try{
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, CreditPrivConstants.VIEW_CREDIT_INVOICE_INTEREST, paramArr);
			Map<String, Object> paramMap = new HashMap<String, Object>();
			List<Filter> filters = new ArrayList<Filter>(Arrays.asList(params.getFilters()));
			for (Filter filter : filters) {
				if (filter.getElement().equals("invoiceId")) {
					paramMap.put("invoice_id", filter.getValue());
				}
				if (filter.getElement().equals("accountId")) {
					paramMap.put("account_id", filter.getValue());
				}
			}
			ssn.update("crd.get-invoice-interests-count", paramMap);
			return (Integer)paramMap.get("row_count");
		} catch (SQLException e){
			logger.error("", e);
			throw new DataAccessException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public CreditPayment[] getPayments(Long userSessionId, SelectionParams params){
		SqlMapSession ssn = null;
		try{
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, CreditPrivConstants.VIEW_CREDIT_PAYMENT, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, CreditPrivConstants.VIEW_CREDIT_PAYMENT);
			List<CreditPayment> payments = ssn.queryForList("crd.get-payments", convertQueryParams(params, limitation));
			return payments.toArray(new CreditPayment[payments.size()]);
		} catch (SQLException e){
			logger.error("", e);
			throw new DataAccessException(e);
		} finally {
			close(ssn);
		}
	}

	public int getPaymentsCount(Long userSessionId, SelectionParams params){
		SqlMapSession ssn = null;
		try{
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, CreditPrivConstants.VIEW_CREDIT_PAYMENT, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, CreditPrivConstants.VIEW_CREDIT_PAYMENT);
			Integer paymentsCount = (Integer)ssn.queryForObject("crd.get-payments-count", convertQueryParams(params, limitation));
			return paymentsCount;
		} catch (SQLException e){
			logger.error("", e);
			throw new DataAccessException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public CreditPaymentExpenditure[] getPaymentExpenditures(Long userSessionId, SelectionParams params){
		SqlMapSession ssn = null;
		try{
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, CreditPrivConstants.VIEW_CREDIT_PAYMENT_EXPENDITURE, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, CreditPrivConstants.VIEW_CREDIT_PAYMENT_EXPENDITURE);
			List<CreditPaymentExpenditure> expenditures = ssn.queryForList("crd.get-payment-expenditures", convertQueryParams(params, limitation));
			return expenditures.toArray(new CreditPaymentExpenditure[expenditures.size()]);
		} catch (SQLException e){
			logger.error("", e);
			throw new DataAccessException(e);
		} finally {
			close(ssn);
		}
	}

	public int getPaymentExpendituresCount(Long userSessionId, SelectionParams params){
		SqlMapSession ssn = null;
		try{
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, CreditPrivConstants.VIEW_CREDIT_PAYMENT_EXPENDITURE, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, CreditPrivConstants.VIEW_CREDIT_PAYMENT_EXPENDITURE);
			Integer expendituresCount = (Integer)ssn.queryForObject("crd.get-payment-expenditures-count", convertQueryParams(params, limitation));
			return expendituresCount;
		} catch (SQLException e){
			logger.error("", e);
			throw new DataAccessException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public CreditEventBunchType[] getEventBunchTypes(Long userSessionId,
			SelectionParams params) {
		SqlMapSession ssn = null;
		try{
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, CreditPrivConstants.VIEW_EVENT_BUNCH_TYPE, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, CreditPrivConstants.VIEW_EVENT_BUNCH_TYPE);
			List<CreditEventBunchType> eventBunchTypes = ssn.queryForList("crd.get-eventBunchTypes", convertQueryParams(params, limitation));
			return eventBunchTypes.toArray(new CreditEventBunchType[eventBunchTypes.size()]);
		} catch (SQLException e){
			logger.error("", e);
			throw new DataAccessException(e);
		} finally {
			close(ssn);
		}
	}


	public int getEventBunchTypesCount(Long userSessionId,
			SelectionParams params) {
		SqlMapSession ssn = null;
		try{
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, CreditPrivConstants.VIEW_EVENT_BUNCH_TYPE, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, CreditPrivConstants.VIEW_EVENT_BUNCH_TYPE);
			Integer eventBunchTypesCount = (Integer)ssn.queryForObject("crd.get-eventBunchTypes-count", convertQueryParams(params, limitation));
			return eventBunchTypesCount;
		} catch (SQLException e){
			logger.error("", e);
			throw new DataAccessException(e);
		} finally {
			close(ssn);
		}
	}


	public CreditEventBunchType addEventBunchType(Long userSessionId, CreditEventBunchType eventBunchType, String lang) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(eventBunchType.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, CreditPrivConstants.ADD_EVENT_BUNCH_TYPE, paramArr);

			ssn.update("crd.add-event-bunch-type", eventBunchType);

			Filter[] filters = new Filter[2];
			filters[0] = new Filter("id", eventBunchType.getId());
			filters[1] = new Filter("lang", lang);
			SelectionParams params = new SelectionParams();
			params.setFilters(filters);
			
			CreditEventBunchType newBunchType = (CreditEventBunchType) ssn.queryForObject(
					"crd.get-eventBunchTypes", convertQueryParams(params));
			return newBunchType;
		} catch (SQLException e) {
			logger.error("", e);
			throw new DataAccessException(e);
		} finally {
			close(ssn);
		}
	}


	public CreditEventBunchType editEventBunchType(Long userSessionId, CreditEventBunchType eventBunchType, String lang) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(eventBunchType.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, CreditPrivConstants.MODIFY_EVENT_BUNCH_TYPE, paramArr);

			ssn.update("crd.edit-event-bunch-type", eventBunchType);

			Filter[] filters = new Filter[2];
			filters[0] = new Filter("id", eventBunchType.getId());
			filters[1] = new Filter("lang", lang);
			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			CreditEventBunchType newBunchType = (CreditEventBunchType) ssn.queryForObject(
					"crd.get-eventBunchTypes", convertQueryParams(params));

			return newBunchType;
		} catch (SQLException e) {
			logger.error("", e);
			throw new DataAccessException(e);
		} finally {
			close(ssn);
		}
	}


	public void removeEventBunchType(Long userSessionId, CreditEventBunchType eventBunchType) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(eventBunchType.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, CreditPrivConstants.REMOVE_EVENT_BUNCH_TYPE, paramArr);
			ssn.update("crd.remove-event-bunch-type", eventBunchType);
		} catch (SQLException e) {
			logger.error("", e);
			throw new DataAccessException(e);
		} finally {
			close(ssn);
		}
	}

    public CreditDebtBalance[] getDebtBalances(Long userSessionId, SelectionParams params){
        SqlMapSession ssn = null;
        try{
            CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
            ssn = getIbatisSession(userSessionId, null, CreditPrivConstants.VIEW_CREDIT_DEBT_BALANCE, paramArr);
            String limitation = CommonController.getLimitationByPriv(ssn, CreditPrivConstants.VIEW_CREDIT_DEBT_BALANCE);
            List<CreditDebtBalance> debtBalances = ssn.queryForList("crd.get-debtBalances", convertQueryParams(params, limitation));
            return debtBalances.toArray(new CreditDebtBalance[debtBalances.size()]);
        } catch (SQLException e){
            logger.error("", e);
            throw new DataAccessException(e);
        } finally {
            close(ssn);
        }
    }

    public int getDebtBalancesCount(Long userSessionId, SelectionParams params){
        SqlMapSession ssn = null;
        try{
            CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
            ssn = getIbatisSession(userSessionId, null, CreditPrivConstants.VIEW_CREDIT_DEBT_BALANCE, paramArr);
            String limitation = CommonController.getLimitationByPriv(ssn, CreditPrivConstants.VIEW_CREDIT_DEBT_BALANCE);
            Integer debtBalancesCount = (Integer)ssn.queryForObject("crd.get-debtBalances-count", convertQueryParams(params, limitation));
            return debtBalancesCount;
        } catch (SQLException e){
            logger.error("", e);
            throw new DataAccessException(e);
        } finally {
            close(ssn);
        }
    }
    
    public CreditDebtBalance[] getMadDebtBalances(Long userSessionId, SelectionParams params){
        SqlMapSession ssn = null;
        try{
            CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
            ssn = getIbatisSession(userSessionId, null, CreditPrivConstants.VIEW_CREDIT_DEBT_BALANCE, paramArr);
            String limitation = CommonController.getLimitationByPriv(ssn, CreditPrivConstants.VIEW_CREDIT_DEBT_BALANCE);
            List<CreditDebtBalance> debtBalances = ssn.queryForList("crd.get-invoice-mad", convertQueryParams(params, limitation));
            return debtBalances.toArray(new CreditDebtBalance[debtBalances.size()]);
        } catch (SQLException e){
            logger.error("", e);
            throw new DataAccessException(e);
        } finally {
            close(ssn);
        }
    }

    public int getMadDebtBalancesCount(Long userSessionId, SelectionParams params){
        SqlMapSession ssn = null;
        try{
            CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
            ssn = getIbatisSession(userSessionId, null, CreditPrivConstants.VIEW_CREDIT_DEBT_BALANCE, paramArr);
            String limitation = CommonController.getLimitationByPriv(ssn, CreditPrivConstants.VIEW_CREDIT_DEBT_BALANCE);
            Integer debtBalancesCount = (Integer)ssn.queryForObject("crd.get-invoice-mad-count", convertQueryParams(params, limitation));
            return debtBalancesCount;
        } catch (SQLException e){
            logger.error("", e);
            throw new DataAccessException(e);
        } finally {
            close(ssn);
        }
    }

    @SuppressWarnings("unchecked")
	public CreditDetailsRecord[] getCreditInfoCur(Long userSessionId,
			Long accountId) {
		CreditDetailsRecord result[];
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSession(userSessionId);
			Map<String, Object> map = new HashMap<String, Object>();
			map.put("accountId", accountId);
			ssn.update("crd.get-credit-details", map);
			List <CreditDetailsRecord> records = (List<CreditDetailsRecord>)map.get("ref_cur");
			result = records.toArray(new CreditDetailsRecord[records.size()]);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
		return result;
	}

	@SuppressWarnings("unchecked")
	public CreditDetailsRecord[] getCreditPayOffCur(Long userSessionId, SelectionParams params) {
		CreditDetailsRecord result[];
		SqlMapSession ssn = null;
		try {
			if (userSessionId != null) {
				ssn = getIbatisSession(userSessionId);
			} else {
				ssn = getIbatisSessionNoContext();
			}
			Map<String, Object> map = new HashMap<String, Object>();
			for (Filter filter : params.getFilters()) {
				if ("accountId".equals(filter.getElement())) {
					map.put("accountId", (Long)filter.getValue());
				} else if ("payOffDate".equals(filter.getElement())) {
					map.put("payOffDate", (Date)filter.getValue());
				}
			}
			ssn.update("crd.get-total-debt-calculation", map);
			List<CreditDetailsRecord> records = (List<CreditDetailsRecord>)map.get("ref_cur");
			result = records.toArray(new CreditDetailsRecord[records.size()]);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
		return result;
	}


	public void getCreditPayOffClose(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			if (userSessionId != null) {
				ssn = getIbatisSession(userSessionId);
			} else {
				ssn = getIbatisSessionNoContext();
			}
			Map<String, Object> map = new HashMap<String, Object>();
			for (Filter filter : params.getFilters()) {
				if ("accountId".equals(filter.getElement())) {
					map.put("accountId", (Long)filter.getValue());
				} else if ("payOffDate".equals(filter.getElement())) {
					map.put("payOffDate", (Date)filter.getValue());
				}
			}
			ssn.update("crd.get-close-credit", map);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public DppCalculation getDppCalculation(Long userSessionId, final DppCalculation dppCalculation) {
		return executeWithSession(userSessionId, logger, new IbatisSessionCallback<DppCalculation>() {
			@Override
			public DppCalculation doInSession(SqlMapSession ssn) throws Exception {
				ssn.queryForObject("crd.get-dpp-calculation", dppCalculation);
				return dppCalculation;
			}
		});
	}


	public List<CreditDetailsRecord> getCreditInterestCalcCur(Long userSessionId, final SelectionParams params) {
		return executeWithSession(userSessionId, logger, new IbatisSessionCallback<List<CreditDetailsRecord>>() {
			@Override
			public List<CreditDetailsRecord> doInSession(SqlMapSession ssn) throws Exception {
				Map<String, Object> map = new HashMap<String, Object>();
				for (Filter filter : params.getFilters()) {
					if ("accountId".equals(filter.getElement())) {
						map.put("accountId", (Long)filter.getValue());
					} else if ("startDate".equals(filter.getElement())) {
						map.put("startDate", (Date)filter.getValue());
					} else if ("endDate".equals(filter.getElement())) {
						map.put("endDate", (Date)filter.getValue());
					}
				}
				ssn.update("crd.get-interest-calc", map);
				if (map.get("result") != null) {
					return (List<CreditDetailsRecord>)map.get("result");
				}
				return new ArrayList<CreditDetailsRecord>();
			}
		});
	}

	public void getOperationDebt(Long userSessionId, final Map<String, Object> map) {
		executeWithSession(userSessionId, logger, new IbatisSessionCallback<Void>() {
			@Override
			public Void doInSession(SqlMapSession ssn) throws Exception {
				ssn.update("crd.get-operation-debt", map);
				return null;
			}
		});
	}
}
