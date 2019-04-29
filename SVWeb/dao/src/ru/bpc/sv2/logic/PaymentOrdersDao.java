package ru.bpc.sv2.logic;

import java.sql.SQLException;
import java.util.*;

import ru.bpc.sv2.logic.utility.db.DataAccessException;


import org.apache.log4j.Logger;

import ru.bpc.sv2.common.CommonParamRec;
import ru.bpc.sv2.ecm.ECMPrivConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.controller.CommonController;
import ru.bpc.sv2.logic.utility.db.IbatisAware;
import ru.bpc.sv2.logic.utility.db.IbatisSessionCallback;
import ru.bpc.sv2.logic.utility.db.QueryParams;
import ru.bpc.sv2.pmo.*;
import ru.bpc.sv2.utils.AuditParamUtil;

import com.ibatis.sqlmap.client.SqlMapSession;

/**
 * Payment Orders Bean implementation class PaymentOrdersDao
 */
public class PaymentOrdersDao extends IbatisAware {
	private static final Logger logger = Logger.getLogger("PAYMENT_ORDERS");

	@SuppressWarnings("unchecked")
	public List<PmoService> getServices(Long userSessionId, final SelectionParams params) {
		return executeWithSession(userSessionId,
								  PaymentOrderPrivConstants.VIEW_PMO_SERVICES,
								  params,
								  logger,
								  new IbatisSessionCallback<List<PmoService>>() {
			@Override
			public List<PmoService> doInSession(SqlMapSession ssn) throws Exception {
				String limit = CommonController.getLimitationByPriv(ssn, PaymentOrderPrivConstants.VIEW_PMO_SERVICES);
				return ssn.queryForList("pmo.get-services", convertQueryParams(params, limit));
			}
		});
	}

	public int getServicesCount(Long userSessionId, final SelectionParams params) {
		return executeWithSession(userSessionId,
								  PaymentOrderPrivConstants.VIEW_PMO_SERVICES,
								  params,
								  logger,
								  new IbatisSessionCallback<Integer>() {
			@Override
			public Integer doInSession(SqlMapSession ssn) throws Exception {
				String limit = CommonController.getLimitationByPriv(ssn, PaymentOrderPrivConstants.VIEW_PMO_SERVICES);
				Object count = ssn.queryForObject("pmo.get-services-count", convertQueryParams(params, limit));
				return (count != null) ? (Integer)count : 0;
			}
		});
	}


	public PmoService addService(Long userSessionId, final PmoService service) {
		return executeWithSession(userSessionId,
								  PaymentOrderPrivConstants.ADD_PMO_SERVICE,
								  AuditParamUtil.getCommonParamRec(service.getAuditParameters()),
								  logger,
								  new IbatisSessionCallback<PmoService>() {
			@Override
			public PmoService doInSession(SqlMapSession ssn) throws Exception {
				ssn.update("pmo.add-service", service);

				List<Filter> filters = new ArrayList<Filter>(2);
				filters.add(Filter.create("id", service.getId().toString()));
				filters.add(Filter.create("lang", service.getLang()));

				SelectionParams params = new SelectionParams(filters);
				Object out = ssn.queryForList("pmo.get-services", convertQueryParams(params));
				return (out != null && !(((List) out).isEmpty())) ? ((List<PmoService>)out).get(0) : service;
			}
		});
	}


	public PmoService editService(Long userSessionId, final PmoService service) {
		return executeWithSession(userSessionId,
								  PaymentOrderPrivConstants.MODIFY_PMO_SERVICE,
								  AuditParamUtil.getCommonParamRec(service.getAuditParameters()),
								  logger,
								  new IbatisSessionCallback<PmoService>() {
			@Override
			public PmoService doInSession(SqlMapSession ssn) throws Exception {
				ssn.update("pmo.edit-service", service);
				return service;
			}
		});
	}

	public void removeService(Long userSessionId, final PmoService service) {
		executeWithSession(userSessionId,
						   PaymentOrderPrivConstants.REMOVE_PMO_SERVICE,
						   AuditParamUtil.getCommonParamRec(service.getAuditParameters()),
						   logger,
						   new IbatisSessionCallback<Void>() {
			@Override
			public Void doInSession(SqlMapSession ssn) throws Exception {
				ssn.delete("pmo.remove-service", service);
				return null;
			}
		});
	}

	@SuppressWarnings("unchecked")
	public List<PmoProvider> getProviders(Long userSessionId, final SelectionParams params) {
		return executeWithSession(userSessionId,
								  PaymentOrderPrivConstants.VIEW_PMO_PROVIDER,
								  params,
								  logger,
								  new IbatisSessionCallback<List<PmoProvider>>() {
			@Override
			public List<PmoProvider> doInSession(SqlMapSession ssn) throws Exception {
				String limit = CommonController.getLimitationByPriv(ssn, PaymentOrderPrivConstants.VIEW_PMO_PROVIDER);
				return ssn.queryForList("pmo.get-providers-hier", convertQueryParams(params, limit));
			}
		});
	}

	public int getProvidersCount(Long userSessionId, final SelectionParams params) {
		return executeWithSession(userSessionId,
								  PaymentOrderPrivConstants.VIEW_PMO_PROVIDER,
								  params,
								  logger,
								  new IbatisSessionCallback<Integer>() {
			@Override
			public Integer doInSession(SqlMapSession ssn) throws Exception {
				String limit = CommonController.getLimitationByPriv(ssn, PaymentOrderPrivConstants.VIEW_PMO_PROVIDER);
				Object count = ssn.queryForObject("pmo.get-providers-count", convertQueryParams(params, limit));
				return (count != null) ? (Integer)count : 0;
			}
		});
	}

	public PmoProvider addProvider(Long userSessionId, final PmoProvider provider) {
		return executeWithSession(userSessionId,
								  PaymentOrderPrivConstants.ADD_PMO_PROVIDER,
								  AuditParamUtil.getCommonParamRec(provider.getAuditParameters()),
								  logger,
								  new IbatisSessionCallback<PmoProvider>() {
			@Override
			public PmoProvider doInSession(SqlMapSession ssn) throws Exception {
				if (provider.isProviderGroup()){
					ssn.insert("pmo.add-provider-group", provider);
				} else {
					ssn.insert("pmo.add-provider", provider);
				}

				List<Filter> filters = new ArrayList<Filter>(2);
				filters.add(Filter.create("id", provider.getId().toString()));
				filters.add(Filter.create("lang", provider.getLang()));

				SelectionParams params = new SelectionParams(filters);
				Object out = ssn.queryForList("pmo.get-providers", convertQueryParams(params));
				return (out != null && !(((List) out).isEmpty())) ? ((List<PmoProvider>)out).get(0) : provider;
			}
		});
	}

	public PmoProvider editProvider(Long userSessionId, final PmoProvider provider) {
		return executeWithSession(userSessionId,
								  PaymentOrderPrivConstants.MODIFY_PMO_PROVIDER,
								  AuditParamUtil.getCommonParamRec(provider.getAuditParameters()),
								  logger,
								  new IbatisSessionCallback<PmoProvider>() {
			@Override
			public PmoProvider doInSession(SqlMapSession ssn) throws Exception {
				if (provider.isProviderGroup()){
					ssn.update("pmo.edit-provider-group", provider);
				} else {
					ssn.update("pmo.edit-provider", provider);
				}
				return provider;
			}
		});
	}

	public void removeProvider(Long userSessionId, final PmoProvider provider) {
		executeWithSession(userSessionId,
						   PaymentOrderPrivConstants.REMOVE_PMO_PROVIDER,
						   AuditParamUtil.getCommonParamRec(provider.getAuditParameters()),
						   logger,
						   new IbatisSessionCallback<Void>() {
			@Override
			public Void doInSession(SqlMapSession ssn) throws Exception {
				if (provider.isProviderGroup()){
					ssn.delete("pmo.remove-provider-group", provider);
				} else{
					ssn.delete("pmo.remove-provider", provider);
				}
				return null;
			}
		});
	}

	@SuppressWarnings("unchecked")
	public PmoHost[] getHosts(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, PaymentOrderPrivConstants.VIEW_PMO_HOSTS, paramArr);
			List<PmoProvider> providers = ssn.queryForList("pmo.get-hosts",
					convertQueryParams(params));
			return providers.toArray(new PmoHost[providers.size()]);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public int getHostsCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, PaymentOrderPrivConstants.VIEW_PMO_HOSTS, paramArr);
			return (Integer) ssn.queryForObject("pmo.get-hosts-count", convertQueryParams(params));
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public PmoHost addHost(Long userSessionId, PmoHost host) {
		SqlMapSession ssn = null;

		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(host.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, PaymentOrderPrivConstants.ADD_PMO_HOST, paramArr);
			ssn.insert("pmo.add-host", host);

			Filter[] filters = new Filter[3];
			filters[0] = new Filter();
			filters[0].setElement("providerId");
			filters[0].setValue(host.getProviderId().toString());
			filters[1] = new Filter();
			filters[1].setElement("lang");
			filters[1].setValue(host.getLang());
			filters[2] = new Filter();
			filters[2].setElement("hostId");
			filters[2].setValue(host.getHostId());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (PmoHost) ssn.queryForObject("pmo.get-hosts", convertQueryParams(params));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public PmoHost editHost(Long userSessionId, PmoHost host) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(host.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, PaymentOrderPrivConstants.MODIFY_PMO_HOST, paramArr);
			ssn.update("pmo.edit-host", host);

			Filter[] filters = new Filter[3];
			filters[0] = new Filter();
			filters[0].setElement("providerId");
			filters[0].setValue(host.getProviderId().toString());
			filters[1] = new Filter();
			filters[1].setElement("lang");
			filters[1].setValue(host.getLang());
			filters[2] = new Filter();
			filters[2].setElement("hostId");
			filters[2].setValue(host.getHostId());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (PmoHost) ssn.queryForObject("pmo.get-hosts", convertQueryParams(params));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void removeHost(Long userSessionId, PmoHost host) {
		SqlMapSession ssn = null;

		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(host.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, PaymentOrderPrivConstants.REMOVE_PMO_HOST, paramArr);
			ssn.delete("pmo.remove-host", host);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public PmoPurpose[] getPurposesForCombo(Long userSessionId) {

		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSessionFE(userSessionId);

			List<PmoPurpose> purposes = ssn.queryForList("pmo.get-purposes-for-combo");

			return purposes.toArray(new PmoPurpose[purposes.size()]);
		} catch (SQLException e) {
			throw new DataAccessException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public List<PmoPurpose> getPurposes(Long userSessionId, final SelectionParams params) {
		final String privilege = params.getPrivilege() != null ? params.getPrivilege()
															   : PaymentOrderPrivConstants.VIEW_PMO_PROVIDER;
		return executeWithSession(userSessionId,
								  privilege,
								  params,
								  logger,
								  new IbatisSessionCallback<List<PmoPurpose>>() {
			@Override
			public List<PmoPurpose> doInSession(SqlMapSession ssn) throws Exception {
				String limit = CommonController.getLimitationByPriv(ssn, privilege);
				return ssn.queryForList("pmo.get-purposes", convertQueryParams(params, limit));
			}
		});
	}

	public int getPurposesCount(Long userSessionId, final SelectionParams params) {
		final String privilege = params.getPrivilege() != null ? params.getPrivilege()
															   : PaymentOrderPrivConstants.VIEW_PMO_PROVIDER;
		return executeWithSession(userSessionId,
								  privilege,
								  params,
								  logger,
								  new IbatisSessionCallback<Integer>() {
			@Override
			public Integer doInSession(SqlMapSession ssn) throws Exception {
				String limit = CommonController.getLimitationByPriv(ssn, privilege);
				Object count = ssn.queryForObject("pmo.get-purposes-count", convertQueryParams(params, limit));
				return (count != null) ? (Integer)count : 0;
			}
		});
	}

	public PmoPurpose addPurpose(Long userSessionId, PmoPurpose purpose) {
		SqlMapSession ssn = null;

		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(purpose.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, PaymentOrderPrivConstants.ADD_PMO_PROVIDER, paramArr);
			ssn.insert("pmo.add-purpose", purpose);

			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("id");
			filters[0].setValue(purpose.getId().toString());
			filters[1] = new Filter();
			filters[1].setElement("lang");
			filters[1].setValue(purpose.getLang());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (PmoPurpose) ssn.queryForObject("pmo.get-purposes", convertQueryParams(params));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public PmoPurpose editPurpose(Long userSessionId, PmoPurpose purpose) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(purpose.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, PaymentOrderPrivConstants.MODIFY_PMO_PROVIDER, paramArr);
			ssn.update("pmo.edit-purpose", purpose);

			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("id");
			filters[0].setValue(purpose.getId().toString());
			filters[1] = new Filter();
			filters[1].setElement("lang");
			filters[1].setValue(purpose.getLang());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (PmoPurpose) ssn.queryForObject("pmo.get-purposes", convertQueryParams(params));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void removePurpose(Long userSessionId, PmoPurpose purpose) {
		SqlMapSession ssn = null;

		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(purpose.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, PaymentOrderPrivConstants.REMOVE_PMO_PROVIDER, paramArr);
			ssn.delete("pmo.remove-purpose", purpose);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public PmoPurposeParameter[] getPurposeParameters(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, PaymentOrderPrivConstants.VIEW_PURPOSE_PARAMETER, paramArr);

			List<PmoPurposeParameter> parameters = ssn.queryForList("pmo.get-purpose-parameters",
					convertQueryParams(params));
			return parameters.toArray(new PmoPurposeParameter[parameters.size()]);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public int getPurposeParametersCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, PaymentOrderPrivConstants.VIEW_PURPOSE_PARAMETER, paramArr);
			return (Integer) ssn.queryForObject("pmo.get-purpose-parameters-count",
					convertQueryParams(params));
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public PmoPurposeParameter addPurposeParameter(Long userSessionId,
			PmoPurposeParameter purposeParameter) {
		SqlMapSession ssn = null;

		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(purposeParameter.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, PaymentOrderPrivConstants.ADD_PURPOSE_PARAMETER, paramArr);
			ssn.insert("pmo.add-purpose-parameter", purposeParameter);

			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("id");
			filters[0].setValue(purposeParameter.getId().toString());
			filters[1] = new Filter();
			filters[1].setElement("lang");
			filters[1].setValue(purposeParameter.getLang());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (PmoPurposeParameter) ssn.queryForObject("pmo.get-purpose-parameters",
					convertQueryParams(params));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public PmoPurposeParameter editPurposeParameter(Long userSessionId,
			PmoPurposeParameter purposeParameter) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(purposeParameter.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, PaymentOrderPrivConstants.MODIFY_PURPOSE_PARAMETER, paramArr);

			ssn.update("pmo.edit-purpose-parameter", purposeParameter);

			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("id");
			filters[0].setValue(purposeParameter.getId().toString());
			filters[1] = new Filter();
			filters[1].setElement("lang");
			filters[1].setValue(purposeParameter.getLang());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (PmoPurposeParameter) ssn.queryForObject("pmo.get-purpose-parameters",
					convertQueryParams(params));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void removePurposeParameter(Long userSessionId, PmoPurposeParameter purposeParameter) {
		SqlMapSession ssn = null;

		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(purposeParameter.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, PaymentOrderPrivConstants.REMOVE_PURPOSE_PARAMETER, paramArr);
			ssn.delete("pmo.remove-purpose-parameter", purposeParameter);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public List<PmoService> getServicesForCombo(Long userSessionId, final SelectionParams params) {
		return executeWithSession(userSessionId,
								  PaymentOrderPrivConstants.VIEW_PMO_SERVICES,
								  logger,
								  new IbatisSessionCallback<List<PmoService>>() {
			@Override
			public List<PmoService> doInSession(SqlMapSession ssn) throws Exception {
				String limit = CommonController.getLimitationByPriv(ssn, PaymentOrderPrivConstants.VIEW_PMO_SERVICES);
				return ssn.queryForList("pmo.get-services-for-combo", convertQueryParams(params, limit));
			}
		});
	}

	@SuppressWarnings("unchecked")
	public PmoParameter[] getParametersForCombo(Long userSessionId) {

		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSession(userSessionId, null, PaymentOrderPrivConstants.VIEW_PMO_PARAMETER, null);

			List<PmoParameter> parameters = ssn.queryForList("pmo.get-parameters-for-combo");

			return parameters.toArray(new PmoParameter[parameters.size()]);
		} catch (SQLException e) {
			throw new DataAccessException(e);
		} finally {
			close(ssn);
		}
	}


	public PmoParameter addParameter(Long userSessionId, final PmoParameter parameter) {
		return executeWithSession(userSessionId,
								  PaymentOrderPrivConstants.ADD_PMO_PARAMETER,
								  AuditParamUtil.getCommonParamRec(parameter.getAuditParameters()),
								  logger,
								  new IbatisSessionCallback<PmoParameter>() {
			@Override
			public PmoParameter doInSession(SqlMapSession ssn) throws Exception {
				PmoParameter param = (PmoParameter)parameter.clone();
				ssn.insert("pmo.add-parameter", param);

				List<Filter> filters = new ArrayList<Filter>(2);
				filters.add(Filter.create("id", param.getId().toString()));
				filters.add(Filter.create("lang", param.getLang()));
				SelectionParams params = new SelectionParams(filters);

				List<PmoParameter> out = ssn.queryForList("pmo.get-parameters", convertQueryParams(params));
				return (out != null && out.size() > 0) ? out.get(0) : param;
			}
		});
	}


	public PmoParameter editParameter(Long userSessionId, final PmoParameter parameter) {
		return executeWithSession(userSessionId,
								  PaymentOrderPrivConstants.MODIFY_PMO_PARAMETER,
								  AuditParamUtil.getCommonParamRec(parameter.getAuditParameters()),
								  logger,
								  new IbatisSessionCallback<PmoParameter>() {
			@Override
			public PmoParameter doInSession(SqlMapSession ssn) throws Exception {
				PmoParameter param = (PmoParameter)parameter.clone();
				ssn.update("pmo.edit-parameter", param);

				List<Filter> filters = new ArrayList<Filter>(2);
				filters.add(Filter.create("id", param.getId().toString()));
				filters.add(Filter.create("lang", param.getLang()));
				SelectionParams params = new SelectionParams(filters);

				List<PmoParameter> out = ssn.queryForList("pmo.get-parameters", convertQueryParams(params));
				return (out != null && out.size() > 0) ? out.get(0) : param;
			}
		});
	}


	public void removeParameter(Long userSessionId, final PmoParameter parameter) {
		executeWithSession(userSessionId,
						   PaymentOrderPrivConstants.REMOVE_PMO_PARAMETER,
						   AuditParamUtil.getCommonParamRec(parameter.getAuditParameters()),
						   logger,
						   new IbatisSessionCallback<PmoParameter>() {
			@Override
			public PmoParameter doInSession(SqlMapSession ssn) throws Exception {
				ssn.delete("pmo.remove-parameter", parameter);
				return null;
			}
		});
	}

	@SuppressWarnings("unchecked")
	public List<PmoParameter> getParameters(Long userSessionId, final SelectionParams params) {
		return executeWithSession(userSessionId,
								  PaymentOrderPrivConstants.VIEW_PMO_PARAMETER,
								  AuditParamUtil.getCommonParamRec(params.getFilters()),
								  logger,
								  new IbatisSessionCallback<List<PmoParameter>>() {
			@Override
			public List<PmoParameter> doInSession(SqlMapSession ssn) throws Exception {
				String limitation = CommonController.getLimitationByPriv(ssn, PaymentOrderPrivConstants.VIEW_PMO_PARAMETER);
				return ssn.queryForList("pmo.get-parameters", convertQueryParams(params, limitation));
			}
		});
	}


	public int getParametersCount(Long userSessionId, final SelectionParams params) {
		return executeWithSession(userSessionId,
								  PaymentOrderPrivConstants.VIEW_PMO_PARAMETER,
								  AuditParamUtil.getCommonParamRec(params.getFilters()),
								  logger,
								  new IbatisSessionCallback<Integer>() {
			@Override
			public Integer doInSession(SqlMapSession ssn) throws Exception {
				String limitation = CommonController.getLimitationByPriv(ssn, PaymentOrderPrivConstants.VIEW_PMO_PARAMETER);
				return (Integer) ssn.queryForObject("pmo.get-parameters-count", convertQueryParams(params, limitation));
			}
		});
	}

	@SuppressWarnings("unchecked")
	public PmoPaymentOrder[] getPaymentOrders(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, PaymentOrderPrivConstants.VIEW_PMO_ORDER, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn,
					PaymentOrderPrivConstants.VIEW_PMO_ORDER);
			List<PmoPaymentOrder> paymentOrders = ssn.queryForList("pmo.get-payment-orders",
					convertQueryParams(params, limitation));
			return paymentOrders.toArray(new PmoPaymentOrder[paymentOrders.size()]);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public int getPaymentOrdersCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, PaymentOrderPrivConstants.VIEW_PMO_ORDER, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn,
					PaymentOrderPrivConstants.VIEW_PMO_ORDER);
			return (Integer) ssn.queryForObject("pmo.get-payment-orders-count", convertQueryParams(
					params, limitation));
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public PmoTemplate addTemplate(Long userSessionId, PmoTemplate template) {
		SqlMapSession ssn = null;

		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(template.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, PaymentOrderPrivConstants.ADD_PMO_TEMPLATE, paramArr);
			ssn.insert("pmo.add-template", template);
			if (template.getSchedule() != null) {
				template.getSchedule().setOrderId(template.getId());
				ssn.insert("pmo.add-schedule", template.getSchedule());
			}

			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("id");
			filters[0].setValue(template.getId());
			filters[1] = new Filter();
			filters[1].setElement("lang");
			filters[1].setValue(template.getLang());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (PmoTemplate) ssn
					.queryForObject("pmo.get-templates", convertQueryParams(params));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public PmoTemplate editTemplate(Long userSessionId, PmoTemplate template) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(template.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, PaymentOrderPrivConstants.MODIFY_PMO_TEMPLATE, paramArr);
			ssn.update("pmo.edit-template", template);
			if (template.getSchedule() != null) {
				if (template.isAddSchedule()) {
					template.getSchedule().setOrderId(template.getId());
					ssn.insert("pmo.add-schedule", template.getSchedule());
				} else if (template.isEditSchedule()) {
					ssn.insert("pmo.modify-schedule", template.getSchedule());
				} else if (template.isDeleteSchedule()) {
					ssn.insert("pmo.remove-schedule", template.getSchedule());
				}
			}

			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("id");
			filters[0].setValue(template.getId().toString());
			filters[1] = new Filter();
			filters[1].setElement("lang");
			filters[1].setValue(template.getLang());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (PmoTemplate) ssn
					.queryForObject("pmo.get-templates", convertQueryParams(params));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void removeTemplate(Long userSessionId, PmoTemplate template) {
		SqlMapSession ssn = null;

		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(template.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, PaymentOrderPrivConstants.REMOVE_PMO_TEMPLATE, paramArr);
			ssn.delete("pmo.remove-template", template);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public PmoTemplate[] getTemplates(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, (params.getPrivilege()!=null ? params.getPrivilege() : PaymentOrderPrivConstants.VIEW_PMO_TEMPLATE), paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn,
					(params.getPrivilege()!=null ? params.getPrivilege() : PaymentOrderPrivConstants.VIEW_PMO_TEMPLATE));
			List<PmoTemplate> templates = ssn.queryForList("pmo.get-templates", convertQueryParams(
					params, limitation));
			return templates.toArray(new PmoTemplate[templates.size()]);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public int getTemplatesCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, (params.getPrivilege()!=null ? params.getPrivilege() : PaymentOrderPrivConstants.VIEW_PMO_TEMPLATE), paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn,
					(params.getPrivilege()!=null ? params.getPrivilege() : PaymentOrderPrivConstants.VIEW_PMO_TEMPLATE));
			return (Integer) ssn.queryForObject("pmo.get-templates-count", convertQueryParams(
					params, limitation));
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public PmoTemplateParameter[] getTemplateParameters(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, PaymentOrderPrivConstants.VIEW_PMO_TEMPLATE, paramArr);
			List<PmoTemplateParameter> templates = ssn.queryForList("pmo.get-template-parameters",
					convertQueryParams(params));
			return templates.toArray(new PmoTemplateParameter[templates.size()]);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public int getTemplateParametersCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, PaymentOrderPrivConstants.VIEW_PMO_TEMPLATE, paramArr);
			return (Integer) ssn.queryForObject("pmo.get-template-parameters-count",
					convertQueryParams(params));
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	public void addTemplateParameter(Long userSessionId, PmoTemplateParameter templateParameter) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(templateParameter.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, PaymentOrderPrivConstants.ADD_PMO_TEMPLATE, paramArr);
			ssn.update("pmo.add-template-parameter", templateParameter);

		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	public void editTemplateParameter(Long userSessionId, PmoTemplateParameter templateParameter) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(templateParameter.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, PaymentOrderPrivConstants.MODIFY_PMO_TEMPLATE, paramArr);
			ssn.update("pmo.edit-template-parameter", templateParameter);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void removeTemplateParameter(Long userSessionId, PmoTemplateParameter templateParameter) {
		SqlMapSession ssn = null;

		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(templateParameter.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, PaymentOrderPrivConstants.REMOVE_PMO_TEMPLATE, paramArr);
			ssn.delete("pmo.remove-template-parameter", templateParameter);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public PmoPaymentOrderParameter[] getPaymentOrderParameters(Long userSessionId,
			SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, PaymentOrderPrivConstants.VIEW_PMO_PARAMETER, paramArr);
			List<PmoPaymentOrderParameter> paymentOrders = ssn.queryForList(
					"pmo.get-payment-order-parameters", convertQueryParams(params));
			return paymentOrders.toArray(new PmoPaymentOrderParameter[paymentOrders.size()]);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public int getPaymentOrderParametersCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, PaymentOrderPrivConstants.VIEW_PMO_PARAMETER, paramArr);
			return (Integer) ssn.queryForObject("pmo.get-payment-order-parameters-count",
					convertQueryParams(params));
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	/* Purpose parameter values */
	@SuppressWarnings("unchecked")
	public PmoParameterValue[] getParameterValues(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, PaymentOrderPrivConstants.VIEW_PMO_PARAM_VALUE, paramArr);
			List<PmoParameterValue> parameterValues = ssn.queryForList(
					"pmo.get-payment-order-parameter-values", convertQueryParams(params));
			return parameterValues.toArray(new PmoParameterValue[parameterValues.size()]);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public int getParameterValuesCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, PaymentOrderPrivConstants.VIEW_PMO_PARAM_VALUE, paramArr);
			return (Integer) ssn.queryForObject("pmo.get-payment-order-parameter-values-count",
					convertQueryParams(params));
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public PmoParameterValue addParameterValue(Long userSessionId, PmoParameterValue parameterValue) {
		SqlMapSession ssn = null;

		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(parameterValue.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, PaymentOrderPrivConstants.ADD_PMO_PARAM_VALUE, paramArr);
			ssn.insert("pmo.add-payment-order-parameter-values", parameterValue);

			Filter[] filters = new Filter[1];
			filters[0] = new Filter();
			filters[0].setElement("id");
			filters[0].setValue(parameterValue.getId().toString());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (PmoParameterValue) ssn.queryForObject("pmo.get-payment-order-parameter-values",
					convertQueryParams(params));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public PmoParameterValue editParameterValue(Long userSessionId, PmoParameterValue parameterValue) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(parameterValue.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, PaymentOrderPrivConstants.MODIFY_PMO_PARAM_VALUE, paramArr);
			ssn.update("pmo.edit-payment-order-parameter-values", parameterValue);

			Filter[] filters = new Filter[1];
			filters[0] = new Filter();
			filters[0].setElement("id");
			filters[0].setValue(parameterValue.getId().toString());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (PmoParameterValue) ssn.queryForObject("pmo.get-payment-order-parameter-values",
					convertQueryParams(params));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void removeParameterValue(Long userSessionId, PmoParameterValue parameterValue) {
		SqlMapSession ssn = null;

		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(parameterValue.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, PaymentOrderPrivConstants.REMOVE_PMO_PARAM_VALUE, paramArr);
			ssn.delete("pmo.remove-payment-order-parameter-values", parameterValue);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public PmoPurposeHasParameter[] getPurposesHasParameter(Long userSessionId,
			SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, PaymentOrderPrivConstants.VIEW_PMO_PARAMETER, paramArr);
			List<PmoPurposeHasParameter> purposeParams = ssn.queryForList(
					"pmo.get-purposes-has-parameter", convertQueryParams(params));
			return purposeParams.toArray(new PmoPurposeHasParameter[purposeParams.size()]);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public int getPurposesHasParameterCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, PaymentOrderPrivConstants.VIEW_PMO_PARAMETER, paramArr);
			return (Integer) ssn.queryForObject("pmo.get-purposes-has-parameter-count",
					convertQueryParams(params));
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public PmoParameterValue[] getObjectPurposeParameterValues(Long userSessionId,
			SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, (params.getPrivilege()!=null ? params.getPrivilege() : PaymentOrderPrivConstants.VIEW_PMO_PARAMETER), paramArr);
			List<PmoParameterValue> parameterValues = ssn.queryForList(
					"pmo.get-object-purpose-parameter-values", convertQueryParams(params));
			return parameterValues.toArray(new PmoParameterValue[parameterValues.size()]);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public int getObjectPurposeParameterValuesCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, (params.getPrivilege()!=null ? params.getPrivilege() : PaymentOrderPrivConstants.VIEW_PMO_PARAMETER), paramArr);
			return (Integer) ssn.queryForObject("pmo.get-object-purpose-parameter-values-count",
					convertQueryParams(params));
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public PmoParameter[] getObjectParametersForCombo(Long userSessionId, SelectionParams params) {

		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSessionFE(userSessionId);

			List<PmoParameter> parameters = ssn.queryForList("pmo.get-object-parameters-for-combo",
					convertQueryParams(params));

			return parameters.toArray(new PmoParameter[parameters.size()]);
		} catch (SQLException e) {
			throw new DataAccessException(e);
		} finally {
			close(ssn);
		}
	}


	public PmoParameterValue addObjectParameterValue(Long userSessionId,
			PmoParameterValue parameterValue) {
		SqlMapSession ssn = null;

		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(parameterValue.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, PaymentOrderPrivConstants.ADD_PMO_PARAM_VALUE, paramArr);
			ssn.insert("pmo.add-payment-order-parameter-values", parameterValue);

			Filter[] filters = new Filter[1];
			filters[0] = new Filter();
			filters[0].setElement("id");
			filters[0].setValue(parameterValue.getId().toString());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (PmoParameterValue) ssn.queryForObject(
					"pmo.get-object-purpose-parameter-values", convertQueryParams(params));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public PmoParameterValue editObjectParameterValue(Long userSessionId,
			PmoParameterValue parameterValue) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(parameterValue.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, PaymentOrderPrivConstants.MODIFY_PMO_PARAM_VALUE, paramArr);
			ssn.update("pmo.edit-payment-order-parameter-values", parameterValue);

			Filter[] filters = new Filter[1];
			filters[0] = new Filter();
			filters[0].setElement("id");
			filters[0].setValue(parameterValue.getId().toString());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (PmoParameterValue) ssn.queryForObject(
					"pmo.get-object-purpose-parameter-values", convertQueryParams(params));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public PmoPurposeFormatter[] getPurposeFormatters(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, PaymentOrderPrivConstants.VIEW_PURPOSE_FORMATTERS, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn,
					PaymentOrderPrivConstants.VIEW_PURPOSE_FORMATTERS);
			List<PmoPurposeFormatter> items = ssn.queryForList("pmo.get-purpose-formatters",
					convertQueryParams(params, limitation));
			return items.toArray(new PmoPurposeFormatter[items.size()]);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public int getPurposeFormattersCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, PaymentOrderPrivConstants.VIEW_PURPOSE_FORMATTERS, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn,
					PaymentOrderPrivConstants.VIEW_PURPOSE_FORMATTERS);
			int count = (Integer) ssn.queryForObject("pmo.get-purpose-formatters-count",
					convertQueryParams(params, limitation));
			return count;
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public PmoPurposeFormatter createPurposeFormatter(Long userSessionId,
			PmoPurposeFormatter editingItem) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(editingItem.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, PaymentOrderPrivConstants.ADD_PURPOSE_FORMATTER, paramArr);
			ssn.update("pmo.add-purpose-formatter", editingItem);

			Filter[] filters = new Filter[2];
			Filter f = new Filter();
			f.setElement("id");
			f.setValue(editingItem.getId());
			filters[0] = f;
			f = new Filter();
			f.setElement("lang");
			f.setValue(editingItem.getLang());
			filters[1] = f;
			SelectionParams params = new SelectionParams();
			params.setFilters(filters);
			PmoPurposeFormatter result = (PmoPurposeFormatter) ssn.queryForObject(
					"pmo.get-purpose-formatters", convertQueryParams(params));
			return result;
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public PmoPurposeFormatter modifyPurposeFormatter(Long userSessionId,
			PmoPurposeFormatter editingItem) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(editingItem.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, PaymentOrderPrivConstants.MODIFY_PURPOSE_FORMATTER, paramArr);
			ssn.update("pmo.modify-purpose-formatter", editingItem);

			Filter[] filters = new Filter[2];
			Filter f = new Filter();
			f.setElement("id");
			f.setValue(editingItem.getId());
			filters[0] = f;
			f = new Filter();
			f.setElement("lang");
			f.setValue(editingItem.getLang());
			filters[1] = f;
			SelectionParams params = new SelectionParams();
			params.setFilters(filters);
			PmoPurposeFormatter result = (PmoPurposeFormatter) ssn.queryForObject(
					"pmo.get-purpose-formatters", convertQueryParams(params));
			return result;
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void removePurposeFormatter(Long userSessionId, PmoPurposeFormatter activeItem) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(activeItem.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, PaymentOrderPrivConstants.REMOVE_PURPOSE_FORMATTER, paramArr);
			ssn.update("pmo.remove-purpose-formatter", activeItem);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public PmoSchedule createSchedule(Long userSessionId, PmoSchedule schedule) {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSession(userSessionId);
			ssn.update("pmo.add-schedule", schedule);

			Filter[] filters = new Filter[1];
			Filter f = new Filter();
			f.setElement("id");
			f.setValue(schedule.getId());
			filters[0] = f;
			SelectionParams params = new SelectionParams();
			params.setFilters(filters);
			PmoSchedule result = (PmoSchedule) ssn.queryForObject("pmo.get-schedules",
					convertQueryParams(params));
			return result;
		} catch (SQLException e) {
			throw new DataAccessException(e);
		} finally {
			close(ssn);
		}
	}


	public PmoSchedule createSchedule(PmoSchedule schedule) {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSessionNoContext();
			ssn.update("pmo.add-schedule", schedule);

			Filter[] filters = new Filter[1];
			Filter f = new Filter();
			f.setElement("id");
			f.setValue(schedule.getId());
			filters[0] = f;
			SelectionParams params = new SelectionParams();
			params.setFilters(filters);
			PmoSchedule result = (PmoSchedule) ssn.queryForObject("pmo.get-schedules",
					convertQueryParams(params));
			return result;
		} catch (SQLException e) {
			throw new DataAccessException(e);
		} finally {
			close(ssn);
		}
	}


	public PmoSchedule modifySchedule(Long userSessionId, PmoSchedule editingItem) {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSession(userSessionId);
			ssn.update("pmo.modify-schedule", editingItem);

			Filter[] filters = new Filter[1];
			Filter f = new Filter();
			f.setElement("id");
			f.setValue(editingItem.getId());
			filters[0] = f;
			SelectionParams params = new SelectionParams();
			params.setFilters(filters);
			PmoSchedule result = (PmoSchedule) ssn.queryForObject("pmo.get-schedules",
					convertQueryParams(params));
			return result;
		} catch (SQLException e) {
			throw new DataAccessException(e);
		} finally {
			close(ssn);
		}
	}


	public void removeSchedule(Long userSessionId, PmoSchedule activeItem) {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSession(userSessionId);
			ssn.update("pmo.remove-schedule", activeItem);
		} catch (SQLException e) {
			throw new DataAccessException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public PmoOrder[] getOrders(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			if (userSessionId != null) {
				ssn = getIbatisSessionFE(userSessionId);
			} else {
				ssn = getIbatisSessionNoContext();
			}
			List<PmoOrder> items = ssn.queryForList("pmo.get-orders", convertQueryParams(params));
			return items.toArray(new PmoOrder[items.size()]);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public PmoOrder[] getOrders(SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSessionNoContext();

			List<PmoOrder> items = ssn.queryForList("pmo.get-orders", convertQueryParams(params));
			return items.toArray(new PmoOrder[items.size()]);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}
	

	public void setOrderStatus(Long userSessionId, PmoOrder order) {
		SqlMapSession ssn = null;
		try {
			if (userSessionId != null) {
				ssn = getIbatisSessionFE(userSessionId);
			} else {
				ssn = getIbatisSessionNoContext();
			}
			ssn.update("pmo.set-order-status", order);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void setOrderAttemptCount(Long userSessionId, PmoOrder order) {
		SqlMapSession ssn = null;
		try {
			if (userSessionId != null) {
				ssn = getIbatisSessionFE(userSessionId);
			} else {
				ssn = getIbatisSessionNoContext();
			}
			ssn.update("pmo.set-attempt-count", order);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public PmoOrderReport[] getOrderReports(SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSessionNoContext();

			List<PmoOrder> items = ssn.queryForList("pmo.get-order-reports",
					convertQueryParams(params));
			return items.toArray(new PmoOrderReport[items.size()]);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void setOrderStatus(PmoOrder order) {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSessionNoContext();
			ssn.update("pmo.set-order-status", order);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void addOrder(Long userSessionId, PmoPaymentOrder order, Map<String, Object> params) {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSessionFE(userSessionId);
			ssn.update("pmo.add-order", order);
			if (params != null && !params.isEmpty()) {
				params.put("orderId", order.getId());
				ssn.insert("pmo.add-order-parameters", params);
			}
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}
	
	@SuppressWarnings("unchecked")
	public List<Map<String, Object>> getLinkedCards(Long userSessionId, Map<String, Object> params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params);
			ssn = getIbatisSession(userSessionId, null, PaymentOrderPrivConstants.VIEW_LINKED_CARD, paramArr);
			ssn.update("pmo.get-linked-cards", params);
			return (List<Map<String, Object>>) params.get("linkedCards");
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void unlinkCard(Long userSessionId, Map<String, Object> params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params);
			ssn = getIbatisSession(userSessionId, null, PaymentOrderPrivConstants.UNLINK_CARD, paramArr);
			ssn.update("pmo.unlink-card", params);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public PmoPaymentOrder[] getPaymentOrdersSys(SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSessionNoContext();
			List<PmoPaymentOrder> paymentOrders = ssn.queryForList("pmo.get-payment-orders-sys",
					convertQueryParams(params));
			return paymentOrders.toArray(new PmoPaymentOrder[paymentOrders.size()]);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}
	
	@SuppressWarnings("unchecked")
	public List<Map<String, Object>> getLinkedCardsEC(Long userSessionId, Map<String, Object> params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params);
			ssn = getIbatisSession(userSessionId, null, ECMPrivConstants.VIEW_LINKED_CARD_EC, paramArr);
			ssn.update("pmo.get-linked-cards-ec", params);
			return (List<Map<String, Object>>) params.get("linkedCards");
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}
	

	public Map<String, String> getMerchantCreds(String merchantNumber, Integer instId) {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSessionNoContext();
			Map<String, String> map = new HashMap<String, String>();
			map.put("merchantNumber", merchantNumber);
			map.put("instId", instId.toString());
			Map<String, String> map1 =  (Map<String, String>)ssn.queryForObject("pmo.get-merchant-creds", map);			
			return map1;
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}
	
	public Map<String, Object> getLinkedCardData(Long userSessionId, Long linkedCardId) {
		SqlMapSession ssn = null;
		try {
			String user = "ADMIN";
			
			ssn = getIbatisSession(userSessionId, user);
			Map<String, Object> map = new HashMap<String, Object>();
			map.put("linkedCardId", linkedCardId);
			ssn.update("pmo.get-linked-card-number", map);			
			return map;
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	public List<PmoPaymentOrder> getPmoPaymentOrders(Long userSessionId, final SelectionParams params) {
		return executeWithSession(userSessionId, PaymentOrderPrivConstants.VIEW_PAYMENT_ORDER, params, logger, new IbatisSessionCallback<List<PmoPaymentOrder>>() {
			@Override
			public List<PmoPaymentOrder> doInSession(SqlMapSession ssn) throws Exception {
				List<Filter> filters = new ArrayList<Filter> (Arrays.asList(params.getFilters()));
				String limitation = CommonController.getLimitationByPriv(ssn, PaymentOrderPrivConstants.VIEW_PAYMENT_ORDER);
				filters.add(Filter.create("PRIVIL_LIMITATION", limitation));
				params.setFilters(Filter.asArray(filters));
				Map<String, Object> paramsMap = new HashMap<String, Object>();
				paramsMap.put("tab_name", "PMO_ORDER");
				paramsMap.put("param_tab", filters.toArray(new Filter[filters.size()]));
				QueryParams qparams = convertQueryParams(params);
				paramsMap.put("first_row", qparams.getRange().getStartPlusOne());
				paramsMap.put("last_row", qparams.getRange().getEndPlusOne());
				paramsMap.put("row_count", params.getRowCount());
				paramsMap.put("sorting_tab", params.getSortElement());
				ssn.update("pmo.get-pmo-payment-orders-cur", paramsMap);
				return (paramsMap.get("ref_cur") != null) ? (List<PmoPaymentOrder>) paramsMap.get("ref_cur") : new ArrayList<PmoPaymentOrder>();
			}
		});
	}

	@SuppressWarnings ("unchecked")
	public int getPmoPaymentOrdersCount(Long userSessionId, final SelectionParams params) {
		return executeWithSession(userSessionId, PaymentOrderPrivConstants.VIEW_PAYMENT_ORDER, params, logger, new IbatisSessionCallback<Integer>() {
			@Override
			public Integer doInSession(SqlMapSession ssn) throws Exception {
				List<Filter> filters = new ArrayList<Filter> (Arrays.asList(params.getFilters()));
				CommonController.checkFilterLimitation(ssn, PaymentOrderPrivConstants.VIEW_PAYMENT_ORDER, filters.toArray(new Filter[filters.size()]));
				String limitation = CommonController.getLimitationByPriv(ssn, PaymentOrderPrivConstants.VIEW_PAYMENT_ORDER);
				filters.add(Filter.create("PRIVIL_LIMITATION", limitation));
				params.setFilters(Filter.asArray(filters));
				Map<String, Object> paramsMap = new HashMap<String, Object>();
				paramsMap.put("tab_name", "PMO_ORDER");
				paramsMap.put("param_tab", filters.toArray(new Filter[filters.size()]));
				ssn.update("pmo.get-pmo-payment-orders-cur-count", paramsMap);
				return (paramsMap.get("row_count") != null) ? (Integer)paramsMap.get("row_count") : 0;
			}
		});
	}

	public List<PmoPaymentOrderDetail> getPaymentOrderDetails(Long userSessionId, final SelectionParams params) {
		return executeWithSession(userSessionId, logger, new IbatisSessionCallback<List<PmoPaymentOrderDetail>>() {
			@Override
			public List<PmoPaymentOrderDetail> doInSession(SqlMapSession ssn) throws Exception {
				return ssn.queryForList("pmo.get-payment-order-details", convertQueryParams(params));
			}
		});
	}

	public int getPaymentOrderDetailsCount(Long userSessionId, final SelectionParams params) {
		return executeWithSession(userSessionId, logger, new IbatisSessionCallback<Integer>() {
			@Override
			public Integer doInSession(SqlMapSession ssn) throws Exception {
				Object count = ssn.queryForObject("pmo.get-payment-order-details-count", convertQueryParams(params));
				return (count != null) ? (Integer)count : 0;
			}
		});
	}


}
