package ru.bpc.sv2.scheduler.process.svng.mastercard;

import oracle.jdbc.internal.OracleTypes;
import ru.bpc.sv2.constants.schedule.ProcessConstants;
import ru.bpc.sv2.dsp.CaseNetworkContext;
import ru.bpc.sv2.logic.DisputesDao;
import ru.bpc.sv2.mastercom.api.MasterCom;
import ru.bpc.sv2.mastercom.api.MasterComException;
import ru.bpc.sv2.mastercom.api.types.claim.response.MasterComChargebackDetails;
import ru.bpc.sv2.mastercom.api.types.claim.response.MasterComClaim;
import ru.bpc.sv2.mastercom.api.types.claim.response.MasterComClaimDetailed;
import ru.bpc.sv2.mastercom.api.types.claim.response.MasterComFeeDetails;
import ru.bpc.sv2.scheduler.process.IbatisExternalProcess;
import ru.bpc.sv2.scheduler.process.svng.mastercard.sql.MasterComChargebackRec;
import ru.bpc.sv2.scheduler.process.svng.mastercard.sql.MasterComClaimRec;
import ru.bpc.sv2.scheduler.process.svng.mastercard.sql.MasterComFeeRec;
import ru.bpc.sv2.scheduler.process.svng.mastercard.sql.MasterComRetrievalRec;
import ru.bpc.sv2.utils.AuthOracleTypeNames;
import ru.bpc.sv2.utils.DBUtils;
import ru.bpc.sv2.utils.SystemException;
import ru.bpc.sv2.utils.UserException;

import java.math.BigDecimal;
import java.sql.CallableStatement;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.concurrent.*;

public class MasterComLoadDisputesProcess extends IbatisExternalProcess {
	private static final String PARAM_NETWORK_ID = "I_NETWORK_ID";
	private static final String PARAM_INST_ID = "I_INST_ID";
	private static final String PARAM_CREATE_OPERATION = "I_CREATE_OPERATION";

	// language=SQL
	private static final String SQL_SAVE_DATA = "{call mcw_prc_mcom_pkg.load(" +
			"    i_inst_id              => ? " +
			"  , i_network_id           => ? " +
			"  , i_create_operation     => ? " +
			"  , i_claim_tab            => ? " +
			"  , i_retrieval_tab        => ? " +
			"  , i_chargeback_tab       => ? " +
			"  , i_fee_tab              => ?)}";

	private Map<String, Object> parameters;

	private DisputesDao disputesDao = new DisputesDao();

	@Override
	public void setParameters(Map<String, Object> parameters) {
		this.parameters = parameters;
	}

	@Override
	public void execute() throws SystemException, UserException {
		getIbatisSession();
		startSession();
		startLogging();

		try {
			MasterCom mc = new MasterCom();
			mc.requireValidHealth();
			List<String> queueNames = mc.retrieveQueueNames();
			debug("Found " + queueNames.size() + " queues");

			BigDecimal networkId = (BigDecimal) parameters.get(PARAM_NETWORK_ID);
			BigDecimal instId = (BigDecimal) parameters.get(PARAM_INST_ID);
			BigDecimal createOperation = (BigDecimal) parameters.get(PARAM_CREATE_OPERATION);

			if (instId == null) {
				throw new Exception("Inst id can't be null");
			}

			if (networkId == null) {
				throw new Exception("Network id can't be null");
			}

			debug("Inst id: " + instId + ", network id: " + networkId);

			CaseNetworkContext context = new CaseNetworkContext();
			context.setInstId(instId.intValue());
			context.setNetworkId(networkId.intValue());

			if (!disputesDao.isMasterComEnabled(userSessionId, context)) {
				throw new Exception("Master com is not enabled for inst id " + instId + " and network id " + networkId);
			}

			CallableResult<List<MasterComClaim>> claims = retrieveClaims(queueNames);
			logCurrent(claims.getResult().size(), claims.getExceptions().size());
			List<Exception> errors = new ArrayList<>(claims.getExceptions());

			CallableResult<List<MasterComClaimDetailed>> claimsDetailed = retrieveClaimsDetailed(claims.getResult());
			logCurrent(claimsDetailed.getResult().size(), claimsDetailed.getExceptions().size());
			errors.addAll(claimsDetailed.getExceptions());

			saveData(instId.intValue(), networkId.intValue(), createOperation, claims.getResult(), claimsDetailed.getResult());

			if (errors.isEmpty()) {
				processSession.setResultCode(ProcessConstants.PROCESS_FINISHED);
			} else {
				processSession.setResultCode(ProcessConstants.PROCESS_FINISHED_WITH_ERRORS);
			}

			endLogging(claimsDetailed.getResult().size(), claimsDetailed.getExceptions().size());

			commit();
		} catch (Exception e) {
			error(e.getMessage(), e);
			processSession.setResultCode(ProcessConstants.PROCESS_FAILED);

			endLogging(0, 0);
			rollback();

			throw new SystemException(e);
		} finally {
			closeConAndSsn();
		}
	}

	private void saveData(int instId, int networkId, Number createOperation, List<MasterComClaim> claims, List<MasterComClaimDetailed> claimsDetailed) throws SQLException {
		CallableStatement cstmt = null;
		try {
			cstmt = con.prepareCall(SQL_SAVE_DATA);

			cstmt.setInt(1, instId);
			cstmt.setInt(2, networkId);
			if(createOperation != null) {
				cstmt.setInt(3, createOperation.intValue());
			} else {
				cstmt.setObject(3, null, OracleTypes.VARCHAR);
			}

			cstmt.setArray(4, DBUtils.createArray(AuthOracleTypeNames.MCW_MCOM_CLAIM_TAB, con, convertClaimsToRecs(claims)));
			cstmt.setArray(5, DBUtils.createArray(AuthOracleTypeNames.MCW_MCOM_RETRIEVAL_TAB, con, convertRetrievalsToRecs(claimsDetailed)));
			cstmt.setArray(6, DBUtils.createArray(AuthOracleTypeNames.MCW_MCOM_CHARGEBACK_TAB, con, convertChargebacksToRecs(claimsDetailed)));
			cstmt.setArray(7, DBUtils.createArray(AuthOracleTypeNames.MCW_MCOM_FEE_TAB, con, convertFeesToRecs(claimsDetailed)));

			cstmt.execute();
		} finally {
			DBUtils.close(cstmt);
		}
	}

	// CLAIMS RECS
	private MasterComClaimRec[] convertClaimsToRecs(List<MasterComClaim> claims) {
		MasterComClaimRec[] recs = new MasterComClaimRec[claims.size()];
		for (int i = 0; i < claims.size(); i++) {
			recs[i] = new MasterComClaimRec(claims.get(i), con);
		}
		return recs;
	}

	// CHARGEBACK RECS
	private MasterComChargebackRec[] convertChargebacksToRecs(List<MasterComClaimDetailed> claims) {
		List<MasterComChargebackRec> recs = new ArrayList<>(claims.size());
		for (MasterComClaimDetailed claim: claims) {
			if (claim.getChargebackDetails() == null) {
				continue;
			}
			for (MasterComChargebackDetails chargeback: claim.getChargebackDetails()) {
				recs.add(new MasterComChargebackRec(chargeback, con));
			}
		}

		return recs.toArray(new MasterComChargebackRec[0]);
	}


	// RETRIEVAL RECS
	private MasterComRetrievalRec[] convertRetrievalsToRecs(List<MasterComClaimDetailed> claims) {
		List<MasterComRetrievalRec> recs = new ArrayList<>(claims.size());
		for (MasterComClaimDetailed claim: claims) {
			if (claim.getRetrievalDetails() == null) {
				continue;
			}
			recs.add(new MasterComRetrievalRec(claim.getRetrievalDetails(), con));
		}

		return recs.toArray(new MasterComRetrievalRec[0]);
	}


	// FEE RECS
	private MasterComFeeRec[] convertFeesToRecs(List<MasterComClaimDetailed> claims) {
		List<MasterComFeeRec> recs = new ArrayList<>(claims.size());
		for (MasterComClaimDetailed claim: claims) {
			if (claim.getFeeDetails() == null) {
				continue;
			}
			for (MasterComFeeDetails fee: claim.getFeeDetails()) {
				recs.add(new MasterComFeeRec(fee, claim.getClaimId(), con));
			}
		}

		return recs.toArray(new MasterComFeeRec[0]);
	}



	private CallableResult<List<MasterComClaim>> retrieveClaims(List<String> queueNames) throws ExecutionException, InterruptedException {
		debug("Getting queues and claim ids from MasterCom");

		ExecutorService executor = Executors.newFixedThreadPool(threadsNumber);
		CompletionService<List<MasterComClaim>> completionService = new ExecutorCompletionService<>(executor);

		for (String queueName : queueNames) {
			completionService.submit(new GetQueueClaimsTask(queueName));
		}

		executor.shutdown();

		Map<String, MasterComClaim> result = new HashMap<>();
		List<Exception> exceptions = new ArrayList<>();
		for (int i = 0; i < queueNames.size(); i++) {
			try {
				List<MasterComClaim> claims = completionService.take().get();
				for (MasterComClaim claim : claims) {
					result.put(claim.getClaimId(), claim);
				}
			} catch (ExecutionException e) {
				if (process.isInterruptThreads()) {
					executor.shutdownNow();
					throw e;
				}
				exceptions.add(e);
			}
		}

		debug("Found " + result.size() + " claims");
		return new CallableResult<List<MasterComClaim>>(new ArrayList<>(result.values()), exceptions);
	}

	private CallableResult<List<MasterComClaimDetailed>> retrieveClaimsDetailed(List<MasterComClaim> claims) throws ExecutionException, InterruptedException {
		debug("Getting claim details");

		ExecutorService executor = Executors.newFixedThreadPool(threadsNumber);
		CompletionService<MasterComClaimDetailed> completionService = new ExecutorCompletionService<>(executor);

		for (MasterComClaim claim : claims) {
			completionService.submit(new GetClaimDetailsTask(claim.getClaimId()));
		}

		executor.shutdown();

		List<MasterComClaimDetailed> result = new ArrayList<>();
		List<Exception> exceptions = new ArrayList<>();
		for (int i = 0; i < claims.size(); i++) {
			try {
				MasterComClaimDetailed claim = completionService.take().get();
				result.add(claim);
			} catch (ExecutionException e) {
				if (process.isInterruptThreads()) {
					executor.shutdownNow();
					throw e;
				}
				exceptions.add(e);
			}
		}

		debug("Retrieve " + result.size() + " claim details");
		return new CallableResult<>(result, exceptions);
	}

	private class GetQueueClaimsTask implements Callable<List<MasterComClaim>> {
		private final String queueName;

		public GetQueueClaimsTask(String queueName) {
			this.queueName = queueName;
		}

		@Override
		public List<MasterComClaim> call() throws Exception {
			try {
				MasterCom mc = new MasterCom();
				return mc.retrieveClaimsFromQueue(queueName);
			} catch (MasterComException e) {
				error("Error while retrieve MasterCom claims from queue: " + queueName, e);
				throw e;
			}
		}
	}


	private class GetClaimDetailsTask implements Callable<MasterComClaimDetailed> {
		private final String claimId;

		public GetClaimDetailsTask(String claimId) {
			this.claimId = claimId;
		}

		@Override
		public MasterComClaimDetailed call() throws Exception {
			try {
				MasterCom mc = new MasterCom();
				return mc.retrieveClaimDetails(claimId);
			} catch (MasterComException e) {
				error("Error while retrieve MasterCom claim: " + claimId, e);
				throw e;
			}
		}
	}

	private class CallableResult<T> {
		private final T result;
		private final List<Exception> exceptions;

		public CallableResult(T result, List<Exception> exceptions) {
			this.result = result;
			this.exceptions = exceptions;
		}

		public T getResult() {
			return result;
		}

		public List<Exception> getExceptions() {
			return exceptions;
		}
	}
}
