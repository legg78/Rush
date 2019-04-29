package ru.bpc.sv2.mastercom.api;

import com.mastercard.api.core.ApiConfig;
import com.mastercard.api.core.exception.ApiException;
import com.mastercard.api.core.model.Environment;
import com.mastercard.api.core.model.RequestMap;
import com.mastercard.api.core.model.ResourceList;
import com.mastercard.api.core.security.Authentication;
import com.mastercard.api.core.security.oauth.OAuthAuthentication;
import com.mastercard.api.mastercom.Claims;
import com.mastercard.api.mastercom.HealthCheck;
import com.mastercard.api.mastercom.Queues;
import com.mastercard.api.mastercom.Transactions;
import org.apache.log4j.Logger;
import ru.bpc.sv2.mastercom.api.types.claim.request.MasterComClaimCreate;
import ru.bpc.sv2.mastercom.api.types.claim.request.MasterComClaimUpdate;
import ru.bpc.sv2.mastercom.api.types.claim.response.MasterComClaim;
import ru.bpc.sv2.mastercom.api.types.claim.response.MasterComClaimDetailed;
import ru.bpc.sv2.mastercom.api.types.transaction.request.MasterComTransactionSearch;
import ru.bpc.sv2.mastercom.api.types.transaction.response.MasterComTransactions;

import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.util.ArrayList;
import java.util.List;

public class MasterCom {
	private static final Logger logger = Logger.getLogger("MASTERCOM");
	private static final Object LOCK_OBJECT = new Object();

	private MasterComMapper mapper;
	private Authentication authentication;

	public static void initEnvironment(MasterComEnvironment env) {
		synchronized (LOCK_OBJECT) {
			logger.info("MasterCom set environment to " + env.name());
			ApiConfig.setEnvironment(Environment.parse(env.name()));
		}
	}

	public static boolean initDefaultAuthentication(String consumerKey, String keyAlias, String keyPassword, String privateKeyPath) {
		synchronized (LOCK_OBJECT) {
			ApiConfig.setAuthentication(null);

			if (consumerKey == null) {
				logger.warn("MasterCom initialization failed: consumer key is empty");
				return false;
			} else if (keyAlias == null) {
				logger.warn("MasterCom initialization failed: key alias is empty");
				return false;
			} else if (keyPassword == null) {
				logger.warn("MasterCom initialization failed: key password is empty");
				return false;
			} else if (privateKeyPath == null) {
				logger.warn("MasterCom initialization failed: private key path is empty");
				return false;
			}

			try(InputStream is = new FileInputStream(privateKeyPath)) {
				ApiConfig.setAuthentication(new OAuthAuthentication(consumerKey, is, keyAlias, keyPassword));   // You only need to set this once
				return true;
			} catch (IOException e) {
				logger.warn("MasterCom initialization failed: can't read file by path: " + privateKeyPath, e);
				return false;
			}
		}
	}

	public void requireValidHealth() throws MasterComException {
		if (!healthCheck()) {
			throw new RuntimeException("MasterCom health check is false");
		}
	}

	public boolean healthCheck() throws MasterComException {
		try {
			RequestMap map = new RequestMap();
			HealthCheck response = HealthCheck.healthCheck(getAuthenticationRequired(), map);
			Object value = response.get("status");
			return Boolean.TRUE.equals(value);
		} catch (ApiException e) {
			throw new MasterComException(e);
		}
	}

	public List<String> retrieveQueueNames() throws MasterComException {
		try {
			ResourceList<Queues> responseList = Queues.retrieveQueueNames(getAuthenticationRequired());
			List<String> list = new ArrayList<>(responseList.getList().size());
			for (Queues queues: responseList.getList()) {
				list.add(String.valueOf(queues.get("queueName")));
			}
			return list;
		} catch (ApiException e) {
			throw new MasterComException(e);
		}
	}

	public List<MasterComClaim> retrieveClaimsFromQueue(String queueName) throws MasterComException {
		try {
			RequestMap map = new RequestMap();
			map.set("queue-name", queueName);

			ResourceList<Queues> responseList = Queues.retrieveClaimsFromQueue(getAuthenticationRequired(), map);
			List<MasterComClaim> list = new ArrayList<>(responseList.getList().size());
			for (Queues queues: responseList.getList()) {
				list.add(getMapper().parseResponse(queues, MasterComClaim.class));
			}
			return list;
		} catch (ApiException e) {
			throw new MasterComException(e);
		}
	}

	public List<String> retrieveClaimIdsFromQueue(String queueName) throws MasterComException {
		try {
			RequestMap map = new RequestMap();
			map.set("queue-name", queueName);

			ResourceList<Queues> responseList = Queues.retrieveClaimsFromQueue(getAuthenticationRequired(), map);
			List<String> list = new ArrayList<>(responseList.getList().size());
			for (Queues queues: responseList.getList()) {
				list.add(queues.get("claimId").toString());
			}
			return list;
		} catch (ApiException e) {
			throw new MasterComException(e);
		}
	}

	public MasterComClaimDetailed retrieveClaimDetails(String claimId) throws MasterComException {

		try {
			RequestMap map = new RequestMap();
			map.set("claim-id", claimId);

			Claims response = Claims.retrieve(getAuthenticationRequired(), "", map);

			return getMapper().parseResponse(response, MasterComClaimDetailed.class);

		} catch (ApiException e) {
			throw new MasterComException(e);
		}
	}

	/**
	 * @return claim id
	 */
	public String createClaim(MasterComClaimCreate claim) throws MasterComException {
		try {
			RequestMap request = getMapper().formatRequest(claim);
			Claims response = Claims.create(getAuthenticationRequired(), request);
			return response.get("claimId").toString();
		} catch (ApiException e) {
			throw new MasterComException(e);
		}
	}

	/**
	 * @return claim id
	 */
	public String updateClaim(MasterComClaimUpdate claim) throws MasterComException {
		try {
			RequestMap request = getMapper().formatRequest(claim);
			Claims response = new Claims(request).update(getAuthenticationRequired());
			return response.get("claimId").toString();
		} catch (ApiException e) {
			throw new MasterComException(e);
		}
	}


	public MasterComTransactions searchForTransaction(MasterComTransactionSearch search) throws MasterComException {
		try {
			RequestMap request = getMapper().formatRequest(search);
			Transactions response = Transactions.searchForTransaction(getAuthenticationRequired(), request);
			return getMapper().parseResponse(response, MasterComTransactions.class);
		} catch (ApiException e) {
			throw new MasterComException(e);
		}
	}

	public MasterComMapper getMapper() {
		if (mapper == null) {
			mapper = new MasterComMapper();
		}
		return mapper;
	}

	public void setMapper(MasterComMapper mapper) {
		this.mapper = mapper;
	}

	public Authentication getAuthenticationRequired() {
		Authentication authentication = getAuthentication();
		if (authentication == null) {
			throw new RuntimeException("Please initialize default MasterCom authentication with MasterCom.initDefaultAuthentication or set authentication with MasterCom.setAuthentication");
		}
		return authentication;
	}

	public Authentication getAuthentication() {
		if (authentication == null) {
			synchronized (LOCK_OBJECT) {
				authentication = ApiConfig.getAuthentication();
			}
		}
		return authentication;
	}

	public void setAuthentication(Authentication authentication) {
		this.authentication = authentication;
	}
}
