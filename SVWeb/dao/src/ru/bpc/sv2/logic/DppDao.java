package ru.bpc.sv2.logic;

import java.sql.SQLException;
import java.util.List;


import org.apache.log4j.Logger;

import ru.bpc.sv2.common.CommonParamRec;
import ru.bpc.sv2.dpp.DefferedPaymentPlan;
import ru.bpc.sv2.dpp.DppAttributeValue;
import ru.bpc.sv2.dpp.DppInstalment;
import ru.bpc.sv2.dpp.DppMacros;
import ru.bpc.sv2.dpp.DppPrivConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.controller.CommonController;
import ru.bpc.sv2.logic.utility.db.IbatisAware;
import ru.bpc.sv2.logic.utility.db.IbatisSessionCallback;
import ru.bpc.sv2.utils.AuditParamUtil;

import com.ibatis.sqlmap.client.SqlMapSession;


public class DppDao extends IbatisAware {

	private static final Logger logger = Logger.getLogger("DPP");

	@SuppressWarnings("unchecked")
	public DefferedPaymentPlan[] getDefferedPaymentPlans(Long userSessionId,
			SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, DppPrivConstants.VIEW_DPP_PAYMENT_PLAN, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, DppPrivConstants.VIEW_DPP_PAYMENT_PLAN);
			List<DefferedPaymentPlan> defferedPaymentPlans = ssn.queryForList(
					"dpp.get-deffered-payment-plans",
					convertQueryParams(params, limitation));
			return defferedPaymentPlans
					.toArray(new DefferedPaymentPlan[defferedPaymentPlans
							.size()]);

		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public int getDefferedPaymentPlansCount(Long userSessionId,
			SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, DppPrivConstants.VIEW_DPP_PAYMENT_PLAN, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, DppPrivConstants.VIEW_DPP_PAYMENT_PLAN);
			Integer defferedPaymentPlansCount = (Integer) ssn.queryForObject(
					"dpp.get-deffered-payment-plans-count",
					convertQueryParams(params, limitation));
			return defferedPaymentPlansCount;

		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public List<DppMacros> getDppMacroses(Long userSessionId, final SelectionParams params) {
		return executeWithSession(userSessionId, logger, new IbatisSessionCallback<List<DppMacros>>() {
			@Override
			public List<DppMacros> doInSession(SqlMapSession ssn) throws Exception {
				return ssn.queryForList("dpp.get-macroses", convertQueryParams(params));
			}
		});
	}

	public int getDppMacrosesCount(Long userSessionId, final SelectionParams params) {
		return executeWithSession(userSessionId, logger, new IbatisSessionCallback<Integer>() {
			@Override
			public Integer doInSession(SqlMapSession ssn) throws Exception {
				Object count = ssn.queryForObject("dpp.get-macroses-count", convertQueryParams(params));
				return (count != null) ? (Integer)count : 0;
			}
		});
	}


	public DefferedPaymentPlan registerDpp(Long userSessionId,
			DefferedPaymentPlan newDefferedPaymentPlan) {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSessionFE(userSessionId);
			ssn.update("dpp.register-dpp", newDefferedPaymentPlan);
			
			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("operId");
			filters[0].setValue(newDefferedPaymentPlan.getOperId());
			filters[1] = new Filter();
			filters[1].setElement("lang");
			filters[1].setValue(newDefferedPaymentPlan.getLang());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			DefferedPaymentPlan defferedPaymentPlan = (DefferedPaymentPlan) ssn
					.queryForObject("dpp.get-deffered-payment-plans",
							convertQueryParams(params));
			return defferedPaymentPlan;

		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}

	}


	public void accelerateDefferedPaymentPlan(Long userSessionId,
			DefferedPaymentPlan acceleratingDpp) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(acceleratingDpp.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, DppPrivConstants.ACCELERATE_PAYMENT_PLAN, paramArr);
			ssn.update("dpp.accelerate-dpp", acceleratingDpp);

		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}

	}


	public void deleteDefferedPaymentPlan(Long userSessionId,
			DefferedPaymentPlan activeItem) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(activeItem.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, DppPrivConstants.REMOVE_PAYMENT_PLAN, paramArr);
			ssn.update("dpp.cancel-dpp", activeItem);

		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	
	@SuppressWarnings("unchecked")
	public DppInstalment[] getDppInstalments(Long userSessionId,
			SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, DppPrivConstants.VIEW_DPP_INSTALMENT, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, DppPrivConstants.VIEW_DPP_INSTALMENT);
			List<DppInstalment> items = ssn.queryForList(
					"dpp.get-dpp-instalments", convertQueryParams(params, limitation));
			return items.toArray(new DppInstalment[items.size()]);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}

	}


	public int getDppInstalmentsCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, DppPrivConstants.VIEW_DPP_INSTALMENT, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, DppPrivConstants.VIEW_DPP_INSTALMENT);
			int count = (Integer) ssn
					.queryForObject("dpp.get-dpp-instalments-count",
							convertQueryParams(params, limitation));
			return count;
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}

	}

	@SuppressWarnings("unchecked")
	public DppAttributeValue[] getDppAttributeValues(Long userSessionId,
			SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, DppPrivConstants.VIEW_DPP_ATTRIBUTE_VALUE, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, DppPrivConstants.VIEW_DPP_ATTRIBUTE_VALUE);

			List<DppAttributeValue> items = ssn.queryForList(
					"dpp.get-dpp-attribute-values", convertQueryParams(params, limitation));
			return items.toArray(new DppAttributeValue[items.size()]);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public int getDppAttributeValuesCount(Long userSessionId,
			SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, DppPrivConstants.VIEW_DPP_ATTRIBUTE_VALUE, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, DppPrivConstants.VIEW_DPP_ATTRIBUTE_VALUE);

			int count = (Integer) ssn.queryForObject(
					"dpp.get-dpp-attribute-values-count",
					convertQueryParams(params, limitation));
			return count;
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

}
