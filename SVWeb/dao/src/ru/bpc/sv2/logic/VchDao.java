package ru.bpc.sv2.logic;

import java.sql.SQLException;
import java.util.List;


import org.apache.log4j.Logger;

import ru.bpc.sv2.common.CommonParamRec;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.utility.db.IbatisAware;
import ru.bpc.sv2.utils.AuditParamUtil;
import ru.bpc.sv2.vch.Voucher;
import ru.bpc.sv2.vch.VoucherPrivConstants;
import ru.bpc.sv2.vch.VouchersBatch;

import com.ibatis.sqlmap.client.SqlMapSession;


public class VchDao extends IbatisAware {
	private static final Logger logger = Logger.getLogger("VCH");


	public VouchersBatch[] getVouchersBatches(Long userSessionId,
			SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, VoucherPrivConstants.VIEW_VOUCHER_BATCHES, paramArr);

			List<VouchersBatch> items = ssn.queryForList(
					"vch.get-vouchers-batches", convertQueryParams(params));
			return items.toArray(new VouchersBatch[items.size()]);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public int getVouchersBatchesCount(Long userSessionId,
			SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, VoucherPrivConstants.VIEW_VOUCHER_BATCHES, paramArr);

			int count = (Integer) ssn.queryForObject(
					"vch.get-vouchers-batches-count",
					convertQueryParams(params));
			return count;
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public VouchersBatch createVouchersBatch(Long userSessionId,
			VouchersBatch editingItem) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(editingItem.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, VoucherPrivConstants.ADD_VOUCHER_BATCH, paramArr);
			ssn.update("vch.add-batch", editingItem);

			Filter[] filters = new Filter[1];
			Filter f = new Filter();
			f.setElement("id");
			f.setValue(editingItem.getId());
			filters[0] = f;
			SelectionParams params = new SelectionParams();
			params.setFilters(filters);
			VouchersBatch result = (VouchersBatch) ssn.queryForObject(
					"vch.get-vouchers-batches", convertQueryParams(params));
			return result;
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public VouchersBatch modifyVouchersBatch(Long userSessionId,
			VouchersBatch editingItem) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(editingItem.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, VoucherPrivConstants.MODIFY_VOUCHER_BATCH, paramArr);
			ssn.update("vch.modify-batch", editingItem);

			Filter[] filters = new Filter[1];
			Filter f = new Filter();
			f.setElement("id");
			f.setValue(editingItem.getId());
			filters[0] = f;
			SelectionParams params = new SelectionParams();
			params.setFilters(filters);
			VouchersBatch result = (VouchersBatch) ssn.queryForObject(
					"vch.get-vouchers-batches", convertQueryParams(params));
			return result;
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void removeVouchersBatch(Long userSessionId, VouchersBatch activeItem) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(activeItem.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, VoucherPrivConstants.REMOVE_VOUCHER_BATCH, paramArr);
			ssn.update("vch.remove-batch", activeItem);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public Voucher[] getVouchers(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, VoucherPrivConstants.VIEW_VOUCHER, paramArr);

			List<Voucher> items = ssn.queryForList("vch.get-vouchers",
					convertQueryParams(params));
			return items.toArray(new Voucher[items.size()]);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public int getVouchersCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, VoucherPrivConstants.VIEW_VOUCHER, paramArr);

			int count = (Integer) ssn.queryForObject("vch.get-vouchers-count",
					convertQueryParams(params));
			return count;
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public Voucher createVoucher(Long userSessionId, Voucher editingItem) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(editingItem.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, VoucherPrivConstants.ADD_VOUCHER, paramArr);
			ssn.update("vch.add-voucher", editingItem);

			Filter[] filters = new Filter[1];
			Filter f = new Filter();
			f.setElement("id");
			f.setValue(editingItem.getId());
			filters[0] = f;
			SelectionParams params = new SelectionParams();
			params.setFilters(filters);
			Voucher result = (Voucher) ssn.queryForObject("vch.get-vouchers",
					convertQueryParams(params));
			return result;
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public Voucher modifyVoucher(Long userSessionId, Voucher editingItem) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(editingItem.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, VoucherPrivConstants.MODIFY_VOUCHER, paramArr);
			ssn.update("vch.modify-voucher", editingItem);

			Filter[] filters = new Filter[1];
			Filter f = new Filter();
			f.setElement("id");
			f.setValue(editingItem.getId());
			filters[0] = f;
			SelectionParams params = new SelectionParams();
			params.setFilters(filters);
			Voucher result = (Voucher) ssn.queryForObject("vch.get-vouchers",
					convertQueryParams(params));
			return result;
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void removeVoucher(Long userSessionId, Voucher activeItem) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(activeItem.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, VoucherPrivConstants.REMOVE_VOUCHER, paramArr);
			ssn.update("vch.remove-voucher", activeItem);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

}
