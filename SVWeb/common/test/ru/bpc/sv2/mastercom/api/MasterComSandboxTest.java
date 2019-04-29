package ru.bpc.sv2.mastercom.api;

import org.junit.Assert;
import org.junit.BeforeClass;
import org.junit.FixMethodOrder;
import org.junit.Test;
import org.junit.runners.MethodSorters;
import ru.bpc.sv2.mastercom.api.types.claim.request.MasterComClaimCreate;
import ru.bpc.sv2.mastercom.api.types.claim.request.MasterComClaimUpdate;
import ru.bpc.sv2.mastercom.api.types.claim.response.MasterComClaim;
import ru.bpc.sv2.mastercom.api.types.claim.response.MasterComClaimDetailed;
import ru.bpc.sv2.mastercom.api.types.transaction.request.MasterComTransactionSearch;
import ru.bpc.sv2.mastercom.api.types.transaction.response.MasterComTransactions;

import java.math.BigDecimal;
import java.text.DateFormat;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.List;

import static ru.bpc.sv2.mastercom.api.MasterComMapper.DATE_DEFAULT_FORMAT;

@FixMethodOrder(MethodSorters.NAME_ASCENDING)
public class MasterComSandboxTest {
	private MasterCom mc = new MasterCom();

	@BeforeClass
	public static void init() {
		String consumerKey = "h-33KCtRMSDggP00nGHqO_ih-h7l3N8R0-tf5ttJe996dfa1!a6f67e5fb3ee4337a8a9f9dad650a8d60000000000000000";   // You should copy this from "My Keys" on your project page e.g. UTfbhDCSeNYvJpLL5l028sWL9it739PYh6LU5lZja15xcRpY!fd209e6c579dc9d7be52da93d35ae6b6c167c174690b72fa
		String keyAlias = "keyalias";   // For production: change this to the key alias you chose when you created your production key
		String keyPassword = "keystorepassword";   // For production: change this to the key alias you chose when you created your production key
		String privateKeyPath = "D:\\SV\\MasterCom\\BPC_Mastercom-sandbox.p12"; // e.g. /Users/yourname/project/sandbox.p12 | C:\Users\yourname\project\sandbox.p12

		MasterCom.initEnvironment(MasterComEnvironment.SANDBOX);
		MasterCom.initDefaultAuthentication(consumerKey, keyAlias, keyPassword, privateKeyPath);
	}


	@Test
	public void _healthCheck() throws MasterComException {
		Assert.assertTrue(mc.healthCheck());
	}

	@Test
	public void retrieveClaimsFromQueues() throws MasterComException {
		List<String> queueNames = mc.retrieveQueueNames();
		System.out.println("Found " + queueNames.size() + " queue names");
		Assert.assertTrue(queueNames.size() > 0);

		for (String queueName: queueNames) {
			System.out.println("Work queue " + queueName);
			List<MasterComClaim> list = mc.retrieveClaimsFromQueue(queueName);
			Assert.assertNotNull(list);
			System.out.println("Found " + list.size() + " claims");
		}
	}

	@Test
	public void retrieveClaimsDetailedFromQueues() throws MasterComException {
		List<String> queueNames = mc.retrieveQueueNames();
		System.out.println("Found " + queueNames.size() + " queue names");
		Assert.assertTrue(queueNames.size() > 0);

		for (String queueName: queueNames) {
			System.out.println("Work queue " + queueName);
			List<String> ids = mc.retrieveClaimIdsFromQueue(queueName);
			Assert.assertTrue(ids.size() > 0);

			for (String id: ids) {
				MasterComClaimDetailed claim = mc.retrieveClaimDetails(id);
				Assert.assertNotNull(claim);
				Assert.assertNotNull(claim.getClaimId());
			}
		}
	}

	@Test
	public void claimCreate() throws MasterComException {
		MasterComClaimCreate claim = new MasterComClaimCreate();
		claim.setDisputedAmount(new BigDecimal("100.00"));
		claim.setDisputedCurrency("USD");
		claim.setClaimType(MasterComClaimCreate.ClaimType.Standard);
		claim.setClearingTransactionId("hqCnaMDqmto4wnL+BSUKSdzROqGJ7YELoKhEvluycwKNg3XTz/faIJhFDkl9hW081B5tTqFFiAwCpcocPdB2My4t7DtSTk63VXDl1CySA8Y");

		String caseId = mc.createClaim(claim);
		Assert.assertNotNull(caseId);
	}

	@Test
	public void claimUpdate() throws MasterComException {
		MasterComClaimUpdate claim = new MasterComClaimUpdate();
		claim.setClaimId("200002020654");
		claim.setAction(MasterComClaimUpdate.ClaimAction.CLOSE);
		claim.setCloseClaimReasonCode("10");

		String caseId = mc.updateClaim(claim);
		Assert.assertNotNull(caseId);
	}


	@Test
	public void searchForTransaction() throws MasterComException, ParseException {
		MasterComTransactionSearch search = new MasterComTransactionSearch();

		DateFormat dateFormat = new SimpleDateFormat(DATE_DEFAULT_FORMAT);

		search.setAcquirerRefNumber("05436847276000293995738");
		search.setPrimaryAccountNum("5488888888887192");
		search.setTransAmountFrom(new BigDecimal("10000"));
		search.setTransAmountTo(new BigDecimal("20050"));
		search.setTranStartDate(dateFormat.parse("2019-03-01"));
		search.setTranEndDate(dateFormat.parse("2019-03-01"));

		MasterComTransactions result = mc.searchForTransaction(search);
		Assert.assertNotNull(result);
		System.out.println(result.getMessage());

		Assert.assertNotNull(result.getAuthorizationSummary());
		System.out.println("Found " + result.getAuthorizationSummary().size() + " authorizations");

		Assert.assertTrue(result.getAuthorizationSummary().size() > 0);
	}
}
