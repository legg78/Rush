package ru.bpc.sv2.logic;

import com.ibatis.sqlmap.client.SqlMapSession;
import org.apache.log4j.Logger;
import ru.bpc.sv2.common.CommonParamRec;
import ru.bpc.sv2.fcl.fees.*;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.Filter.Operator;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.controller.CommonController;
import ru.bpc.sv2.logic.utility.db.IbatisAware;
import ru.bpc.sv2.utils.AuditParamUtil;

import java.sql.SQLException;
import java.util.List;

/**
 * Session Bean implementation class Cycles
 */
public class FeesDao extends IbatisAware {
	private static final Logger logger = Logger.getLogger("FCL");

	CommonDao common = new CommonDao();


	public Fee getFeeById(Long userSessionId, Integer feeId) {
		SelectionParams params = new SelectionParams();
		Filter[] filters = new Filter[1];
		filters[0] = new Filter();
		filters[0].setElement("id");
		filters[0].setOp(Operator.eq);
		filters[0].setValue(feeId.toString());

		params.setFilters(filters);
		Fee[] fees = getFees(userSessionId, params);
		if (fees.length > 0) {
			return fees[0];
		}
		return null;
	}

	@SuppressWarnings("unchecked")
	public Fee[] getFees(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, FeePrivConstants.VIEW_FEE, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, FeePrivConstants.VIEW_FEE);
			List<Fee> fees = ssn.queryForList("fees.get-fees", convertQueryParams(params, limitation));

			return fees.toArray(new Fee[fees.size()]);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	public int getFeesCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, FeePrivConstants.VIEW_FEE, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, FeePrivConstants.VIEW_FEE);
			return (Integer) ssn.queryForObject("fees.get-fees-count", convertQueryParams(params, limitation));
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public Fee createFee(Long userSessionId, Fee fee) {
		SqlMapSession ssn = null;

		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(fee.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, FeePrivConstants.ADD_FEE, paramArr);

			ssn.insert("fees.insert-new-fee", fee);

			Filter[] filters = new Filter[1];
			filters[0] = new Filter();
			filters[0].setElement("id");
			filters[0].setValue(fee.getId().toString());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (Fee) ssn.queryForObject("fees.get-fees", convertQueryParams(params));
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public Fee updateFee(Long userSessionId, Fee fee) {
		SqlMapSession ssn = null;

		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(fee.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, FeePrivConstants.MODIFY_FEE, paramArr);

			ssn.update("fees.modify-fee", fee);

			Filter[] filters = new Filter[1];
			filters[0] = new Filter();
			filters[0].setElement("id");
			filters[0].setValue(fee.getId().toString());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (Fee) ssn.queryForObject("fees.get-fees", convertQueryParams(params));
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void deleteFee(Long userSessionId, Fee fee) {
		SqlMapSession ssn = null;

		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(fee.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, FeePrivConstants.REMOVE_FEE, paramArr);

			ssn.delete("fees.remove-fee", fee);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public FeeType[] getFeeTypes(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec((params != null)?params.getFilters():null);
			ssn = getIbatisSession(userSessionId, null, FeePrivConstants.VIEW_FEE_TYPE, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, FeePrivConstants.VIEW_FEE_TYPE);
			List<FeeType> feeTypes = ssn.queryForList("fees.get-fee-types", convertQueryParams(params, limitation));
			return feeTypes.toArray(new FeeType[feeTypes.size()]);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	public int getFeeTypesCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec((params != null)?params.getFilters():null);
			ssn = getIbatisSession(userSessionId, null, FeePrivConstants.VIEW_FEE_TYPE, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, FeePrivConstants.VIEW_FEE_TYPE);
			return (Integer) ssn.queryForObject("fees.get-fee-types-count",
					convertQueryParams(params, limitation));
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	public FeeType createFeeType(Long userSessionId, FeeType feeType) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(feeType.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, FeePrivConstants.ADD_FEE_TYPE, paramArr);
			ssn.insert("fees.add-fee-type", feeType);
			return feeType;
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	public FeeType updateFeeType(Long userSessionId, FeeType feeType) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(feeType.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, FeePrivConstants.MODIFY_FEE_TYPE, paramArr);
			ssn.insert("fees.modify-fee-type", feeType);
			return feeType;
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void deleteFeeType(Long userSessionId, FeeType feeType) {
		SqlMapSession ssn = null;

		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(feeType.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, FeePrivConstants.REMOVE_FEE_TYPE, paramArr);

			ssn.delete("fees.remove-fee-type", feeType);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public FeeTier[] getFeeTiers(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, FeePrivConstants.VIEW_FEE_TIER, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, FeePrivConstants.VIEW_FEE_TIER);
			List<FeeTier> feeTiers = ssn.queryForList("fees.get-fee-tiers",
					convertQueryParams(params, limitation));

			return feeTiers.toArray(new FeeTier[feeTiers.size()]);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public int getFeeTiersCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, FeePrivConstants.VIEW_FEE_TIER, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, FeePrivConstants.VIEW_FEE_TIER);
			return (Integer) ssn.queryForObject("fees.get-fee-tiers-count",
					convertQueryParams(params, limitation));
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public FeeTier createFeeTier(Long userSessionId, FeeTier feeTier) {
		SqlMapSession ssn = null;

		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(feeTier.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, FeePrivConstants.ADD_FEE_TIER, paramArr);

			ssn.insert("fees.insert-new-fee-tier", feeTier);
			
			return feeTier;
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void createFeeTiers(Long userSessionId, List<FeeTier> feeTiers) {
		SqlMapSession ssn = null;

		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(null);
			ssn = getIbatisSession(userSessionId, null, FeePrivConstants.ADD_FEE_TIER, paramArr);

			for (FeeTier rate : feeTiers) {
				rate.setId(null); // id is used to properly build richfaces
									// extended datatable,
				// here we need to null it so that DB can save fee rate properly
				ssn.insert("fees.insert-new-fee-tier", rate);
			}
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public FeeTier updateFeeTier(Long userSessionId, FeeTier feeTier) {
		SqlMapSession ssn = null;

		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(feeTier.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, FeePrivConstants.MODIFY_FEE_TIER, paramArr);

			ssn.update("fees.modify-fee-tier", feeTier);
			
			return feeTier;
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void deleteFeeTier(Long userSessionId, FeeTier feeTier) {
		SqlMapSession ssn = null;

		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(feeTier.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, FeePrivConstants.REMOVE_FEE_TIER, paramArr);

			ssn.delete("fees.remove-fee-tier", feeTier);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public FeeRate[] getFeeRates(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, FeePrivConstants.VIEW_FEE_RATE, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, FeePrivConstants.VIEW_FEE_RATE);
			List<FeeRate> feeRates = ssn.queryForList("fees.get-fee-rates",
					convertQueryParams(params, limitation));

			return feeRates.toArray(new FeeRate[feeRates.size()]);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public int getFeeRatesCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, FeePrivConstants.VIEW_FEE_RATE, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, FeePrivConstants.VIEW_FEE_RATE);
			return (Integer) ssn.queryForObject("fees.get-fee-rates-count",
					convertQueryParams(params, limitation));
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public FeeRate createFeeRate(Long userSessionId, FeeRate feeRate, String lang) {
		SqlMapSession ssn = null;

		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(feeRate.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, FeePrivConstants.ADD_FEE_RATE, paramArr);

			ssn.insert("fees.add-fee-rate", feeRate);
			
			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("id");
			filters[0].setValue(feeRate.getId().toString());
			filters[1] = new Filter();
			filters[1].setElement("lang");
			filters[1].setValue(lang);

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (FeeRate) ssn.queryForObject("fees.get-fee-rates", convertQueryParams(params));
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public FeeRate editFeeRate(Long userSessionId, FeeRate feeRate) {
		SqlMapSession ssn = null;

		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(feeRate.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, FeePrivConstants.MODIFY_FEE_RATE, paramArr);

			ssn.update("fees.modify-fee-rate", feeRate);
			
			return feeRate;
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void deleteFeeRate(Long userSessionId, FeeRate feeRate) {
		SqlMapSession ssn = null;

		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(feeRate.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, FeePrivConstants.REMOVE_FEE_RATE, paramArr);

			ssn.delete("fees.remove-fee-rate", feeRate);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public boolean isFeeTypeNeedLengthType(Long userSessionId, String feeType) {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSession(userSessionId);
			Boolean value = (Boolean)ssn.queryForObject("fees.is-fee-type-needs-length-type", feeType);
			return (value != null) ? (boolean)value : false;
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}
}
