package ru.bpc.sv2.scheduler.process.converter;

import java.util.ArrayList;
import java.util.List;

import ru.bpc.sv2.process.btrt.BTRTMapping;
import ru.bpc.sv2.process.btrt.NodeItem;

public class BTRTUtils {
	private static final int MAX_LEVEL = 3;
	
//	public final static String STATUS_CREATED				= "APST0001";
//	public final static String STATUS_EXPORTED				= "APST0002";
	public final static String STATUS_PROCESSED_BY_EXT_SYS	= "APST0006";
//	public final static String STATUS_REJECTED_BY_EXT_SYS	= "APST0004";
//	public final static String STATUS_PROCESSED				= "APST0005";
	
	public static void addSimpleNodeToNode(NodeItem nodeA, NodeItem nodeB) {
		if (nodeA == null || nodeB == null) {
			return;
		}
		nodeA.setParent(nodeB);
		nodeB.getChildren().add(nodeA);
	}
	
	public static List<NodeItem> createApplication() {
		List<NodeItem> result = new ArrayList<NodeItem>();
		
		/////////////////////////FILE HEADER/////////////////////////////
		NodeItem header = new NodeItem(BTRTMapping.APP_FILE_HEADER.getCode(), null);
		result.add(header);
		
		NodeItem sequenceHeader1 = new NodeItem(BTRTMapping.SEQUENCE.getCode(), null);
		header.getChildren().add(sequenceHeader1);
		sequenceHeader1.setParent(header);
		
		NodeItem fileHeader = new NodeItem(BTRTMapping.FILE_HEADER.getCode(), null);
		header.getChildren().add(fileHeader);
		fileHeader.setParent(header);
		
		NodeItem sequenceHeader2 = new NodeItem(BTRTMapping.SEQUENCE.getCode(), null);
		fileHeader.getChildren().add(sequenceHeader1);
		sequenceHeader2.setParent(fileHeader);
		
		NodeItem fileType = new NodeItem(BTRTMapping.FILE_TYPE.getCode(), null);
		fileHeader.getChildren().add(fileType);
		fileType.setParent(fileHeader);
		
		NodeItem appDate = new NodeItem(BTRTMapping.APPLICATION_DATE.getCode(), "22.06.2012_14:46:12");
		fileHeader.getChildren().add(appDate);
		appDate.setParent(fileHeader);
		
		NodeItem instID = new NodeItem(BTRTMapping.INSTITUTION_ID.getCode(), "1812");
		fileHeader.getChildren().add(instID);
		instID.setParent(fileHeader);
		
		NodeItem agentID = new NodeItem(BTRTMapping.AGENT_ID.getCode(), "10000042");
		fileHeader.getChildren().add(agentID);
		agentID.setParent(fileHeader);
		/////////////////////////FILE HEADER/////////////////////////////
		
		/////////////////////////APPLICATION BLOCK/////////////////////////////
//		NodeItem app = createFullMerchantApp();
		NodeItem app = createCardAccApp();
//		NodeItem app = createMerchantApp();
//		NodeItem app = createTerminalApp();
//		NodeItem app = createFullMerchantApp();
//		NodeItem app = createBTRT59App();
		result.add(app);

		///////////////////////////MERCHANT BLOCK/////////////////////////////
		
		
		/////////////////////////FILE TRAILER///////////////////////////////
		NodeItem trailer = new NodeItem(BTRTMapping.APP_FILE_TRAILER.getCode(), null);
		result.add(trailer);
		
		NodeItem fileTrailer = new NodeItem(BTRTMapping.FILE_TRAILER.getCode(), null);
		trailer.getChildren().add(fileTrailer);
		fileTrailer.setParent(trailer);
		
		NodeItem numberOfRecords = new NodeItem(BTRTMapping.NUMBER_OF_RECORDS.getCode(), null);
		fileTrailer.getChildren().add(numberOfRecords);
		numberOfRecords.setParent(fileTrailer);
		/////////////////////////FILE TRAILER///////////////////////////////

		return result;
	}
	/**
	 * Create BTRT59 data application.
	 * @return
	 */
	private static NodeItem createBTRT59App() {
		/////////////////////////APPLICATION BLOCK/////////////////////////////
		NodeItem app = new NodeItem(BTRTMapping.BTRT59.getCode(), null);
		//result.add(app);
		
		NodeItem main = new NodeItem(BTRTMapping.MAIN_BLOCK.getCode(), null);
		app.getChildren().add(main);
		main.setParent(app);
		
		NodeItem sequence = new NodeItem(BTRTMapping.SEQUENCE.getCode(), "1");
		main.getChildren().add(sequence);
		sequence.setParent(main);
		
		NodeItem appType = new NodeItem(BTRTMapping.APPLICATION_TYPE.getCode(), "APTPISSA");
		main.getChildren().add(appType);
		appType.setParent(main);
		
		NodeItem merchantLevel = new NodeItem(BTRTMapping.MERCHANT_LEVEL.getCode(), null);
		app.getChildren().add(merchantLevel);
		merchantLevel.setParent(app);
		
		NodeItem entityID = new NodeItem(BTRTMapping.MERCHANT_ENTITY_ID.getCode(), null);
		merchantLevel.getChildren().add(entityID);
		entityID.setParent(merchantLevel);
		
		return app;
	}
	
	/**
	 * Create Merchant data application.
	 * @return
	 */
	private static NodeItem createMerchantApp() {
		/////////////////////////APPLICATION BLOCK/////////////////////////////
		NodeItem app = new NodeItem(BTRTMapping.BTRT51.getCode(), null);
		//result.add(app);
		
		NodeItem main = new NodeItem(BTRTMapping.MAIN_BLOCK.getCode(), null);
		app.getChildren().add(main);
		main.setParent(app);
		
		NodeItem sequence = new NodeItem(BTRTMapping.SEQUENCE.getCode(), "1");
		main.getChildren().add(sequence);
		sequence.setParent(main);
		
		NodeItem appType = new NodeItem(BTRTMapping.APPLICATION_TYPE.getCode(), "APTPISSA");
		main.getChildren().add(appType);
		appType.setParent(main);

		/////////////////////////////MERCHANT APPLICATION/////////////////////////////
		/////////////////////////////MERCHANT BLOCK/////////////////////////////
		NodeItem merchant = new NodeItem(BTRTMapping.MERCHANT.getCode(), null);
		app.getChildren().add(merchant);
		merchant.setParent(app);
		
		NodeItem merchantLevel = new NodeItem(BTRTMapping.MERCHANT_LEVEL.getCode(), null);
		merchant.getChildren().add(merchantLevel);
		merchantLevel.setParent(merchant);
		
		NodeItem merchantName = new NodeItem(BTRTMapping.MERCHANT_NAME.getCode(), null);
		merchantLevel.getChildren().add(merchantName);
		merchantName.setParent(merchantLevel);
		
		NodeItem merchantLabel = new NodeItem(BTRTMapping.MERCHANT_LABEL.getCode(), null);
		merchantLevel.getChildren().add(merchantLabel);
		merchantLabel.setParent(merchantLevel);
		
		NodeItem mcc = new NodeItem(BTRTMapping.MCC.getCode(), null);
		merchantLevel.getChildren().add(mcc);
		mcc.setParent(merchantLevel);
		
		NodeItem merchantStatus = new NodeItem(BTRTMapping.MERCHANT_STATUS.getCode(), null);
		merchantLevel.getChildren().add(merchantStatus);
		merchantStatus.setParent(merchantLevel);
		
		NodeItem contractDetails = new NodeItem(BTRTMapping.CONTRACT_DETAILS.getCode(), null);
		merchant.getChildren().add(contractDetails);
		contractDetails.setParent(merchant);
		
		NodeItem defaultAccNum = new NodeItem(BTRTMapping.DEFAULT_ACCOUNT_NUMBER.getCode(), null);
		contractDetails.getChildren().add(defaultAccNum);
		defaultAccNum.setParent(contractDetails);
		
		NodeItem merchantMsc = new NodeItem(BTRTMapping.MERCHANT_MSC.getCode(), null);
		merchant.getChildren().add(merchantMsc);
		merchantMsc.setParent(merchant);
		
		NodeItem domain = new NodeItem(BTRTMapping.DOMAIN.getCode(), null);
		merchantMsc.getChildren().add(domain);
		domain.setParent(merchantMsc);
		
		
		////////////////////CONTACT_INFO_BLOCK//////////////////////
		NodeItem contact = new NodeItem(BTRTMapping.CONTACT.getCode(), null);
		app.getChildren().add(contact);
		contact.setParent(app);
		
		NodeItem person1 = new NodeItem(BTRTMapping.PERSON.getCode(), null);
		contact.getChildren().add(person1);
		person1.setParent(contact);
		
		NodeItem firstName1 = new NodeItem(BTRTMapping.FIRST_NAME.getCode(), null);
		person1.getChildren().add(firstName1);
		firstName1.setParent(person1);
		
		NodeItem idNumber1_1 = new NodeItem(BTRTMapping.ID_NUMBER.getCode(), null);
		person1.getChildren().add(idNumber1_1);
		idNumber1_1.setParent(person1);
		
		NodeItem address1 = new NodeItem(BTRTMapping.ADDRESS.getCode(), null);
		person1.getChildren().add(address1);
		address1.setParent(person1);
		
		NodeItem region1 = new NodeItem(BTRTMapping.REGION.getCode(), "sub address");
		address1.getChildren().add(region1);
		region1.setParent(address1);
		
		NodeItem address2 = new NodeItem(BTRTMapping.ADDRESS.getCode(), null);
		contact.getChildren().add(address2);
		address2.setParent(contact);
		
		NodeItem region2 = new NodeItem(BTRTMapping.REGION.getCode(), null);
		address2.getChildren().add(region2);
		region2.setParent(address2);
		
		NodeItem mobilePhone1 = new NodeItem(BTRTMapping.MOBILE_PHONE.getCode(), "123456789");
		address2.getChildren().add(mobilePhone1);
		mobilePhone1.setParent(address2);
		
		NodeItem fax1 = new NodeItem(BTRTMapping.FAX.getCode(), "123");
		address2.getChildren().add(fax1);
		fax1.setParent(address2);
		
		NodeItem email1 = new NodeItem(BTRTMapping.EMAIL.getCode(), "lupaka2006@gmail.com");
		address2.getChildren().add(email1);
		email1.setParent(address2);
		///////////////////////////////CONTACT_INFO_BLOCK/////////////////////////////
		
		////////////////////////ACCOUNT///////////////////////////
		NodeItem account = new NodeItem(BTRTMapping.ACCOUNT.getCode(), null);
		app.getChildren().add(account);
		account.setParent(app);
		
		NodeItem sequence9 = new NodeItem(BTRTMapping.SEQUENCE.getCode(), "10");
		account.getChildren().add(sequence9);
		sequence9.setParent(account);
		
		NodeItem accInit = new NodeItem(BTRTMapping.ACCOUNT_INIT.getCode(), null);
		account.getChildren().add(accInit);
		accInit.setParent(account);
		
		NodeItem sequence10 = new NodeItem(BTRTMapping.SEQUENCE.getCode(), "11");
		accInit.getChildren().add(sequence10);
		sequence10.setParent(accInit);
		
		NodeItem accNumber = new NodeItem(BTRTMapping.ACCOUNT_NUMBER.getCode(), "987654321");
		accInit.getChildren().add(accNumber);
		accNumber.setParent(accInit);
		
		NodeItem accData = new NodeItem(BTRTMapping.ACCOUNT_DATA.getCode(), null);
		account.getChildren().add(accData);
		accData.setParent(account);
		
		NodeItem sequence11 = new NodeItem(BTRTMapping.SEQUENCE.getCode(), "12");
		accData.getChildren().add(sequence11);
		sequence11.setParent(accData);
		
		NodeItem accStatus = new NodeItem(BTRTMapping.ACCOUNT_STATUS.getCode(), "ACSTACTV");
		accData.getChildren().add(accStatus);
		accStatus.setParent(accData);
		/////////////////////////ACCOUNT//////////////////////////////
		
		////////////////////////ACCOUNT_2///////////////////////////
		NodeItem account2 = new NodeItem(BTRTMapping.ACCOUNT.getCode(), null);
		app.getChildren().add(account2);
		account2.setParent(app);
		
		NodeItem sequence39 = new NodeItem(BTRTMapping.SEQUENCE.getCode(), "10");
		account2.getChildren().add(sequence39);
		sequence39.setParent(account2);
		
		NodeItem accInit2 = new NodeItem(BTRTMapping.ACCOUNT_INIT.getCode(), null);
		account2.getChildren().add(accInit2);
		accInit2.setParent(account2);
		
		NodeItem sequence40 = new NodeItem(BTRTMapping.SEQUENCE.getCode(), "11");
		accInit2.getChildren().add(sequence40);
		sequence40.setParent(accInit2);
		
		NodeItem accNumber2 = new NodeItem(BTRTMapping.ACCOUNT_NUMBER.getCode(), "987654321");
		accInit2.getChildren().add(accNumber2);
		accNumber2.setParent(accInit2);
		
		NodeItem accData2 = new NodeItem(BTRTMapping.ACCOUNT_DATA.getCode(), null);
		account2.getChildren().add(accData2);
		accData2.setParent(account2);
		
		NodeItem sequence41 = new NodeItem(BTRTMapping.SEQUENCE.getCode(), "12");
		accData2.getChildren().add(sequence41);
		sequence41.setParent(accData2);
		
		NodeItem accStatus2 = new NodeItem(BTRTMapping.ACCOUNT_STATUS.getCode(), "ACSTACTV");
		accData2.getChildren().add(accStatus2);
		accStatus2.setParent(accData2);
		/////////////////////////ACCOUNT//////////////////////////////
		
		return app;
	}
	
	/**
	 * Create Terminal data application
	 * 
	 * @return
	 */
	private static NodeItem createTerminalApp() {
		/////////////////////////APPLICATION BLOCK/////////////////////////////
		NodeItem app = new NodeItem(BTRTMapping.BTRT52.getCode(), null);
		//result.add(app);
		
		NodeItem main = new NodeItem(BTRTMapping.MAIN_BLOCK.getCode(), null);
		app.getChildren().add(main);
		main.setParent(app);
		
		NodeItem sequence = new NodeItem(BTRTMapping.SEQUENCE.getCode(), "1");
		main.getChildren().add(sequence);
		sequence.setParent(main);
		
		NodeItem appType = new NodeItem(BTRTMapping.APPLICATION_TYPE.getCode(), "APTPISSA");
		main.getChildren().add(appType);
		appType.setParent(main);
		
		///////////////////////////TERMINAL BLOCK ////////////////////////////
		NodeItem terminal = new NodeItem(BTRTMapping.TERMINAL.getCode(), null);
		app.getChildren().add(terminal);
		terminal.setParent(app);
		
		NodeItem parentLevel = new NodeItem(BTRTMapping.PARENT_LEVEL.getCode(), null);
		terminal.getChildren().add(parentLevel);
		parentLevel.setParent(terminal);
		
		NodeItem parentEntryId = new NodeItem(BTRTMapping.PARENT_ENTRY_ID.getCode(), null);
		parentLevel.getChildren().add(parentEntryId);
		parentEntryId.setParent(parentLevel);
		
		NodeItem terminalLevel = new NodeItem(BTRTMapping.TERMINAL_LEVEL.getCode(), null);
		terminal.getChildren().add(terminalLevel);
		terminalLevel.setParent(terminal);
		
		NodeItem terminalType = new NodeItem(BTRTMapping.TERMINAL_TYPE.getCode(), null);
		terminalLevel.getChildren().add(terminalType);
		terminalType.setParent(terminalLevel);
		
		NodeItem catLevel = new NodeItem(BTRTMapping.CAT_LEVEL.getCode(), null);
		terminalLevel.getChildren().add(catLevel);
		catLevel.setParent(terminalLevel);
		
		NodeItem cardDataInputCap = new NodeItem(BTRTMapping.CARD_DATA_INPUT_CAP.getCode(), null);
		terminalLevel.getChildren().add(cardDataInputCap);
		cardDataInputCap.setParent(terminalLevel);
		
		NodeItem crdhAuthCap = new NodeItem(BTRTMapping.CRDH_AUTH_CAP.getCode(), null);
		terminalLevel.getChildren().add(crdhAuthCap);
		crdhAuthCap.setParent(terminalLevel);
		
		NodeItem cardCaptureCap = new NodeItem(BTRTMapping.CARD_CAPTURE_CAP.getCode(), null);
		terminalLevel.getChildren().add(cardCaptureCap);
		cardCaptureCap.setParent(terminalLevel);
		
		NodeItem address1 = new NodeItem(BTRTMapping.ADDRESS.getCode(), null);
		terminal.getChildren().add(address1);
		address1.setParent(terminal);
		
		NodeItem region1 = new NodeItem(BTRTMapping.REGION.getCode(), null);
		address1.getChildren().add(region1);
		region1.setParent(address1);
		
		NodeItem mobilePhone1 = new NodeItem(BTRTMapping.MOBILE_PHONE.getCode(), "123456789");
		address1.getChildren().add(mobilePhone1);
		mobilePhone1.setParent(address1);
		
		NodeItem fax1 = new NodeItem(BTRTMapping.FAX.getCode(), "123");
		address1.getChildren().add(fax1);
		fax1.setParent(address1);
		
		NodeItem email1 = new NodeItem(BTRTMapping.EMAIL.getCode(), "lupaka2006@gmail.com");
		address1.getChildren().add(email1);
		email1.setParent(address1);
		///////////////////////////TERMINAL BLOCK ////////////////////////////
		
		///////////////////////////TERMINAL 2 ////////////////////////////
		NodeItem terminal2 = new NodeItem(BTRTMapping.TERMINAL.getCode(), null);
		app.getChildren().add(terminal2);
		terminal2.setParent(app);
		
		NodeItem parentLevel2 = new NodeItem(BTRTMapping.PARENT_LEVEL.getCode(), null);
		terminal2.getChildren().add(parentLevel2);
		parentLevel2.setParent(terminal2);
		
		NodeItem parentEntryId2 = new NodeItem(BTRTMapping.PARENT_ENTRY_ID.getCode(), null);
		parentLevel2.getChildren().add(parentEntryId2);
		parentEntryId2.setParent(parentLevel2);
		
		NodeItem terminalLevel2 = new NodeItem(BTRTMapping.TERMINAL_LEVEL.getCode(), null);
		terminal2.getChildren().add(terminalLevel2);
		terminalLevel2.setParent(terminal2);
		
		NodeItem terminalType2 = new NodeItem(BTRTMapping.TERMINAL_TYPE.getCode(), null);
		terminalLevel2.getChildren().add(terminalType2);
		terminalType2.setParent(terminalLevel2);
		
		NodeItem catLevel2 = new NodeItem(BTRTMapping.CAT_LEVEL.getCode(), null);
		terminalLevel2.getChildren().add(catLevel2);
		catLevel2.setParent(terminalLevel2);
		
		NodeItem cardDataInputCap2 = new NodeItem(BTRTMapping.CARD_DATA_INPUT_CAP.getCode(), null);
		terminalLevel2.getChildren().add(cardDataInputCap2);
		cardDataInputCap2.setParent(terminalLevel2);
		
		NodeItem address2 = new NodeItem(BTRTMapping.ADDRESS.getCode(), null);
		terminal2.getChildren().add(address2);
		address2.setParent(terminal2);
		
		NodeItem region2 = new NodeItem(BTRTMapping.REGION.getCode(), null);
		address2.getChildren().add(region2);
		region2.setParent(address2);
		
		NodeItem email2 = new NodeItem(BTRTMapping.EMAIL.getCode(), "lupaka2006@gmail.com");
		address2.getChildren().add(email2);
		email2.setParent(address2);
		///////////////////////////TERMINAL 2 ////////////////////////////
		
		////////////////////////ACCOUNT///////////////////////////
		NodeItem account = new NodeItem(BTRTMapping.ACCOUNT.getCode(), null);
		app.getChildren().add(account);
		account.setParent(app);
		
		NodeItem sequence9 = new NodeItem(BTRTMapping.SEQUENCE.getCode(), "10");
		account.getChildren().add(sequence9);
		sequence9.setParent(account);
		
		NodeItem accInit = new NodeItem(BTRTMapping.ACCOUNT_INIT.getCode(), null);
		account.getChildren().add(accInit);
		accInit.setParent(account);
		
		NodeItem sequence10 = new NodeItem(BTRTMapping.SEQUENCE.getCode(), "11");
		accInit.getChildren().add(sequence10);
		sequence10.setParent(accInit);
		
		NodeItem accNumber = new NodeItem(BTRTMapping.ACCOUNT_NUMBER.getCode(), "987654321");
		accInit.getChildren().add(accNumber);
		accNumber.setParent(accInit);
		
		NodeItem accData = new NodeItem(BTRTMapping.ACCOUNT_DATA.getCode(), null);
		account.getChildren().add(accData);
		accData.setParent(account);
		
		NodeItem sequence11 = new NodeItem(BTRTMapping.SEQUENCE.getCode(), "12");
		accData.getChildren().add(sequence11);
		sequence11.setParent(accData);
		
		NodeItem accStatus = new NodeItem(BTRTMapping.ACCOUNT_STATUS.getCode(), "ACSTACTV");
		accData.getChildren().add(accStatus);
		accStatus.setParent(accData);
		/////////////////////////ACCOUNT//////////////////////////////
		
		////////////////////////ACCOUNT///////////////////////////
		NodeItem account2 = new NodeItem(BTRTMapping.ACCOUNT.getCode(), null);
		app.getChildren().add(account2);
		account2.setParent(app);
		
		NodeItem sequence49 = new NodeItem(BTRTMapping.SEQUENCE.getCode(), "10");
		account2.getChildren().add(sequence49);
		sequence49.setParent(account2);
		
		NodeItem accInit2 = new NodeItem(BTRTMapping.ACCOUNT_INIT.getCode(), null);
		account2.getChildren().add(accInit2);
		accInit2.setParent(account2);
		
		NodeItem sequence50 = new NodeItem(BTRTMapping.SEQUENCE.getCode(), "11");
		accInit2.getChildren().add(sequence50);
		sequence50.setParent(accInit2);
		
		NodeItem accNumber2 = new NodeItem(BTRTMapping.ACCOUNT_NUMBER.getCode(), "987654321");
		accInit2.getChildren().add(accNumber2);
		accNumber2.setParent(accInit2);
		
		NodeItem accData2 = new NodeItem(BTRTMapping.ACCOUNT_DATA.getCode(), null);
		account2.getChildren().add(accData2);
		accData2.setParent(account2);
		
		NodeItem sequence51 = new NodeItem(BTRTMapping.SEQUENCE.getCode(), "12");
		accData2.getChildren().add(sequence51);
		sequence51.setParent(accData2);
		
		NodeItem accStatus2 = new NodeItem(BTRTMapping.ACCOUNT_STATUS.getCode(), "ACSTACTV");
		accData2.getChildren().add(accStatus2);
		accStatus2.setParent(accData2);
		/////////////////////////ACCOUNT//////////////////////////////
		
		return app; 
	}
	
	/**
	 * Create Full Merchant hierarchy data application.
	 * @return
	 */
	private static NodeItem createFullMerchantApp() {
		/////////////////////////APPLICATION BLOCK/////////////////////////////
		NodeItem app = new NodeItem(BTRTMapping.BTRT55.getCode(), null);
//		result.add(app);
		
		NodeItem main = new NodeItem(BTRTMapping.MAIN_BLOCK.getCode(), null);
		app.getChildren().add(main);
		main.setParent(app);
		
		NodeItem sequence = new NodeItem(BTRTMapping.SEQUENCE.getCode(), "1");
		main.getChildren().add(sequence);
		sequence.setParent(main);
		
		NodeItem appType = new NodeItem(BTRTMapping.APPLICATION_TYPE.getCode(), "APTPISSA");
		main.getChildren().add(appType);
		appType.setParent(main);
		
		/////////////////////////////MERCHANT APPLICATION/////////////////////////////
		/////////////////////////////MERCHANT BLOCK/////////////////////////////
		NodeItem merchant = new NodeItem(BTRTMapping.MERCHANT.getCode(), null);
		app.getChildren().add(merchant);
		merchant.setParent(app);
		
		NodeItem merchantLevel = new NodeItem(BTRTMapping.MERCHANT_LEVEL.getCode(), null);
		merchant.getChildren().add(merchantLevel);
		merchantLevel.setParent(merchant);
		
		NodeItem merchantName = new NodeItem(BTRTMapping.MERCHANT_NAME.getCode(), null);
		merchantLevel.getChildren().add(merchantName);
		merchantName.setParent(merchantLevel);
		
		NodeItem merchantLabel = new NodeItem(BTRTMapping.MERCHANT_LABEL.getCode(), null);
		merchantLevel.getChildren().add(merchantLabel);
		merchantLabel.setParent(merchantLevel);
		
		NodeItem mcc = new NodeItem(BTRTMapping.MCC.getCode(), null);
		merchantLevel.getChildren().add(mcc);
		mcc.setParent(merchantLevel);
		
		NodeItem merchantStatus = new NodeItem(BTRTMapping.MERCHANT_STATUS.getCode(), null);
		merchantLevel.getChildren().add(merchantStatus);
		merchantStatus.setParent(merchantLevel);
		
		NodeItem contractDetails = new NodeItem(BTRTMapping.CONTRACT_DETAILS.getCode(), null);
		merchant.getChildren().add(contractDetails);
		contractDetails.setParent(merchant);
		
		NodeItem defaultAccNum = new NodeItem(BTRTMapping.DEFAULT_ACCOUNT_NUMBER.getCode(), null);
		contractDetails.getChildren().add(defaultAccNum);
		defaultAccNum.setParent(contractDetails);
		
		NodeItem merchantMsc = new NodeItem(BTRTMapping.MERCHANT_MSC.getCode(), null);
		merchant.getChildren().add(merchantMsc);
		merchantMsc.setParent(merchant);
		
		NodeItem domain = new NodeItem(BTRTMapping.DOMAIN.getCode(), null);
		merchantMsc.getChildren().add(domain);
		domain.setParent(merchantMsc);
		
		///////////////////////////sub CONTACT/////////////////////////////
		NodeItem contact = new NodeItem(BTRTMapping.CONTACT.getCode(), null);
		merchant.getChildren().add(contact);
		contact.setParent(merchant);
		
		NodeItem person1 = new NodeItem(BTRTMapping.PERSON.getCode(), null);
		contact.getChildren().add(person1);
		person1.setParent(contact);
		
		NodeItem firstName1 = new NodeItem(BTRTMapping.FIRST_NAME.getCode(), null);
		person1.getChildren().add(firstName1);
		firstName1.setParent(person1);
		
		NodeItem idNumber1_1 = new NodeItem(BTRTMapping.ID_NUMBER.getCode(), null);
		person1.getChildren().add(idNumber1_1);
		idNumber1_1.setParent(person1);
		
		NodeItem address = new NodeItem(BTRTMapping.ADDRESS.getCode(), null);
		person1.getChildren().add(address);
		address.setParent(person1);
		
		NodeItem region = new NodeItem(BTRTMapping.REGION.getCode(), "sub");
		address.getChildren().add(region);
		region.setParent(address);
		
		NodeItem mobilePhone = new NodeItem(BTRTMapping.MOBILE_PHONE.getCode(), "123456789");
		address.getChildren().add(mobilePhone);
		mobilePhone.setParent(address);
		
		NodeItem address1 = new NodeItem(BTRTMapping.ADDRESS.getCode(), null);
		contact.getChildren().add(address1);
		address1.setParent(contact);
		
		NodeItem region1 = new NodeItem(BTRTMapping.REGION.getCode(), null);
		address1.getChildren().add(region1);
		region1.setParent(address1);
		
		NodeItem mobilePhone1 = new NodeItem(BTRTMapping.MOBILE_PHONE.getCode(), "123456789");
		address1.getChildren().add(mobilePhone1);
		mobilePhone1.setParent(address1);
		
		NodeItem fax1 = new NodeItem(BTRTMapping.FAX.getCode(), "123");
		address1.getChildren().add(fax1);
		fax1.setParent(address1);
		
		NodeItem email1 = new NodeItem(BTRTMapping.EMAIL.getCode(), "lupaka2006@gmail.com");
		address1.getChildren().add(email1);
		email1.setParent(address1);
		///////////////////////////sub CONTACT////////////////////////////
		
		////////////////////////////sub ACCOUNT//////////////////////////////
		NodeItem account = new NodeItem(BTRTMapping.ACCOUNT.getCode(), null);
		merchant.getChildren().add(account);
		account.setParent(merchant);
		
		NodeItem sequence9 = new NodeItem(BTRTMapping.SEQUENCE.getCode(), "10");
		account.getChildren().add(sequence9);
		sequence9.setParent(account);
		
		NodeItem accInit = new NodeItem(BTRTMapping.ACCOUNT_INIT.getCode(), null);
		account.getChildren().add(accInit);
		accInit.setParent(account);
		
		NodeItem sequence10 = new NodeItem(BTRTMapping.SEQUENCE.getCode(), "11");
		accInit.getChildren().add(sequence10);
		sequence10.setParent(accInit);
		
		NodeItem accNumber = new NodeItem(BTRTMapping.ACCOUNT_NUMBER.getCode(), "987654321");
		accInit.getChildren().add(accNumber);
		accNumber.setParent(accInit);
		
		NodeItem accData = new NodeItem(BTRTMapping.ACCOUNT_DATA.getCode(), null);
		account.getChildren().add(accData);
		accData.setParent(account);
		
		NodeItem sequence11 = new NodeItem(BTRTMapping.SEQUENCE.getCode(), "12");
		accData.getChildren().add(sequence11);
		sequence11.setParent(accData);
		
		NodeItem accStatus = new NodeItem(BTRTMapping.ACCOUNT_STATUS.getCode(), "ACSTACTV");
		accData.getChildren().add(accStatus);
		accStatus.setParent(accData);
		///////////////////////////sub ACCOUNT////////////////////////////
		
		////////////////////////////sub ACCOUNT 2//////////////////////////////
		NodeItem account2 = new NodeItem(BTRTMapping.ACCOUNT.getCode(), null);
		merchant.getChildren().add(account2);
		account2.setParent(merchant);
		
		NodeItem sequence29 = new NodeItem(BTRTMapping.SEQUENCE.getCode(), "10");
		account2.getChildren().add(sequence29);
		sequence29.setParent(account2);
		
		NodeItem accInit2 = new NodeItem(BTRTMapping.ACCOUNT_INIT.getCode(), null);
		account2.getChildren().add(accInit2);
		accInit2.setParent(account2);
		
		NodeItem sequence40 = new NodeItem(BTRTMapping.SEQUENCE.getCode(), "11");
		accInit2.getChildren().add(sequence40);
		sequence40.setParent(accInit2);
		
		NodeItem accNumber2 = new NodeItem(BTRTMapping.ACCOUNT_NUMBER.getCode(), "987654321");
		accInit2.getChildren().add(accNumber2);
		accNumber2.setParent(accInit2);
		
		NodeItem accData2 = new NodeItem(BTRTMapping.ACCOUNT_DATA.getCode(), null);
		account2.getChildren().add(accData2);
		accData2.setParent(account2);
		
		NodeItem sequence41 = new NodeItem(BTRTMapping.SEQUENCE.getCode(), "12");
		accData2.getChildren().add(sequence41);
		sequence41.setParent(accData2);
		
		NodeItem accStatus2 = new NodeItem(BTRTMapping.ACCOUNT_STATUS.getCode(), "ACSTACTV");
		accData2.getChildren().add(accStatus2);
		accStatus2.setParent(accData2);
		///////////////////////////sub ACCOUNT////////////////////////////

		////////////////////////////MERCHANT SUB-LEVEL BLOCK//////////////////////////
		createSubLevelMerchant(merchant, 1);
		//////////////////////////MERCHANT SUB-LEVEL BLOCK//////////////////////////
		
		//////////////////////////GROUP TERMINAL/////////////////////////////
		NodeItem terminal = new NodeItem(BTRTMapping.GROUP_TERMINAL.getCode(), null);
		merchant.getChildren().add(terminal);
		terminal.setParent(merchant);
		
		NodeItem terminalLevel = new NodeItem(BTRTMapping.TERMINAL_LEVEL.getCode(), null);
		terminal.getChildren().add(terminalLevel);
		terminalLevel.setParent(terminal);
		
		NodeItem terminalType = new NodeItem(BTRTMapping.TERMINAL_TYPE.getCode(), null);
		terminalLevel.getChildren().add(terminalType);
		terminalType.setParent(terminalLevel);
		
		NodeItem catLevel = new NodeItem(BTRTMapping.CAT_LEVEL.getCode(), null);
		terminalLevel.getChildren().add(catLevel);
		catLevel.setParent(terminalLevel);
		
		NodeItem cardDataInputCap = new NodeItem(BTRTMapping.CARD_DATA_INPUT_CAP.getCode(), null);
		terminalLevel.getChildren().add(cardDataInputCap);
		cardDataInputCap.setParent(terminalLevel);
		
		NodeItem crdhAuthCap = new NodeItem(BTRTMapping.CRDH_AUTH_CAP.getCode(), null);
		terminalLevel.getChildren().add(crdhAuthCap);
		crdhAuthCap.setParent(terminalLevel);
		
		NodeItem cardCaptureCap = new NodeItem(BTRTMapping.CARD_CAPTURE_CAP.getCode(), null);
		terminalLevel.getChildren().add(cardCaptureCap);
		cardCaptureCap.setParent(terminalLevel);
		
		NodeItem address4 = new NodeItem(BTRTMapping.ADDRESS.getCode(), null);
		terminal.getChildren().add(address4);
		address4.setParent(terminal);
		
		NodeItem region4 = new NodeItem(BTRTMapping.REGION.getCode(), null);
		address4.getChildren().add(region4);
		region4.setParent(address4);
		
		NodeItem mobilePhone4 = new NodeItem(BTRTMapping.MOBILE_PHONE.getCode(), "123456789");
		address4.getChildren().add(mobilePhone4);
		mobilePhone4.setParent(address4);
		
		NodeItem account1 = new NodeItem(BTRTMapping.ACCOUNT.getCode(), null);
		terminal.getChildren().add(account1);
		account1.setParent(terminal);
		
		NodeItem sequence20 = new NodeItem(BTRTMapping.SEQUENCE.getCode(), "20");
		account1.getChildren().add(sequence20);
		sequence20.setParent(account1);
		
		NodeItem accInit1 = new NodeItem(BTRTMapping.ACCOUNT_INIT.getCode(), null);
		account1.getChildren().add(accInit1);
		accInit1.setParent(account1);
		
		NodeItem sequence21 = new NodeItem(BTRTMapping.SEQUENCE.getCode(), "21");
		accInit1.getChildren().add(sequence21);
		sequence21.setParent(accInit1);
		
		NodeItem accNumber1 = new NodeItem(BTRTMapping.ACCOUNT_NUMBER.getCode(), "Account of terminal");
		accInit1.getChildren().add(accNumber1);
		accNumber1.setParent(accInit1);
		
		NodeItem accData1 = new NodeItem(BTRTMapping.ACCOUNT_DATA.getCode(), null);
		account1.getChildren().add(accData1);
		accData1.setParent(account1);
		
		NodeItem sequence22 = new NodeItem(BTRTMapping.SEQUENCE.getCode(), "22");
		accData1.getChildren().add(sequence22);
		sequence22.setParent(accData1);
		
		NodeItem accStatus1 = new NodeItem(BTRTMapping.ACCOUNT_STATUS.getCode(), "ACSTACTV");
		accData1.getChildren().add(accStatus1);
		accStatus1.setParent(accData1);
		
		NodeItem account4 = new NodeItem(BTRTMapping.ACCOUNT.getCode(), null);
		terminal.getChildren().add(account4);
		account4.setParent(terminal);
		
		NodeItem sequence50 = new NodeItem(BTRTMapping.SEQUENCE.getCode(), "20");
		account4.getChildren().add(sequence50);
		sequence50.setParent(account4);
		
		NodeItem accInit4 = new NodeItem(BTRTMapping.ACCOUNT_INIT.getCode(), null);
		account4.getChildren().add(accInit4);
		accInit4.setParent(account4);
		
		NodeItem sequence51 = new NodeItem(BTRTMapping.SEQUENCE.getCode(), "21");
		accInit4.getChildren().add(sequence51);
		sequence51.setParent(accInit4);
		
		NodeItem accNumber4 = new NodeItem(BTRTMapping.ACCOUNT_NUMBER.getCode(), "Account of terminal");
		accInit4.getChildren().add(accNumber4);
		accNumber4.setParent(accInit4);
		
		NodeItem accData4 = new NodeItem(BTRTMapping.ACCOUNT_DATA.getCode(), null);
		account4.getChildren().add(accData4);
		accData4.setParent(account4);
		
		NodeItem sequence52 = new NodeItem(BTRTMapping.SEQUENCE.getCode(), "22");
		accData4.getChildren().add(sequence52);
		sequence52.setParent(accData4);
		
		NodeItem accStatus4 = new NodeItem(BTRTMapping.ACCOUNT_STATUS.getCode(), "ACSTACTV");
		accData4.getChildren().add(accStatus4);
		accStatus4.setParent(accData4);
		
		NodeItem encryption = new NodeItem(BTRTMapping.ENCRYPTION.getCode(), null);
		terminal.getChildren().add(encryption);
		encryption.setParent(terminal);
		
		NodeItem encryptionKeyType = new NodeItem(BTRTMapping.ENCRYPTION_KEY_TYPE.getCode(), "ACSTACTV");
		encryption.getChildren().add(encryptionKeyType);
		encryptionKeyType.setParent(encryption);
		///////////////////////////GROUP TERMINAL///////////////////////////////
		
		//////////////////////////GROUP TERMINAL 2/////////////////////////////
		NodeItem terminal2 = new NodeItem(BTRTMapping.GROUP_TERMINAL.getCode(), null);
		merchant.getChildren().add(terminal2);
		terminal2.setParent(merchant);
		
		NodeItem terminalLevel2 = new NodeItem(BTRTMapping.TERMINAL_LEVEL.getCode(), null);
		terminal2.getChildren().add(terminalLevel2);
		terminalLevel2.setParent(terminal2);
		
		NodeItem terminalType2 = new NodeItem(BTRTMapping.TERMINAL_TYPE.getCode(), null);
		terminalLevel2.getChildren().add(terminalType2);
		terminalType2.setParent(terminalLevel2);
		
		NodeItem catLevel2 = new NodeItem(BTRTMapping.CAT_LEVEL.getCode(), null);
		terminalLevel2.getChildren().add(catLevel2);
		catLevel2.setParent(terminalLevel2);
		
		NodeItem cardDataInputCap2 = new NodeItem(BTRTMapping.CARD_DATA_INPUT_CAP.getCode(), null);
		terminalLevel2.getChildren().add(cardDataInputCap2);
		cardDataInputCap2.setParent(terminalLevel2);
		
		NodeItem address5 = new NodeItem(BTRTMapping.ADDRESS.getCode(), null);
		terminal2.getChildren().add(address5);
		address5.setParent(terminal2);
		
		NodeItem region5 = new NodeItem(BTRTMapping.REGION.getCode(), null);
		address5.getChildren().add(region5);
		region5.setParent(address5);
		
		NodeItem mobilePhone5 = new NodeItem(BTRTMapping.MOBILE_PHONE.getCode(), "123456789");
		address5.getChildren().add(mobilePhone5);
		mobilePhone5.setParent(address5);
		
		NodeItem account3 = new NodeItem(BTRTMapping.ACCOUNT.getCode(), null);
		terminal2.getChildren().add(account3);
		account3.setParent(terminal2);
		
		NodeItem sequence23 = new NodeItem(BTRTMapping.SEQUENCE.getCode(), "20");
		account3.getChildren().add(sequence23);
		sequence23.setParent(account3);
		
		NodeItem accInit3 = new NodeItem(BTRTMapping.ACCOUNT_INIT.getCode(), null);
		account3.getChildren().add(accInit3);
		accInit3.setParent(account3);
		
		NodeItem sequence24 = new NodeItem(BTRTMapping.SEQUENCE.getCode(), "21");
		accInit3.getChildren().add(sequence24);
		sequence24.setParent(accInit3);
		
		NodeItem accNumber3 = new NodeItem(BTRTMapping.ACCOUNT_NUMBER.getCode(), "Account of terminal");
		accInit3.getChildren().add(accNumber3);
		accNumber3.setParent(accInit3);
		
		NodeItem encryption1 = new NodeItem(BTRTMapping.ENCRYPTION.getCode(), null);
		terminal2.getChildren().add(encryption1);
		encryption1.setParent(terminal2);
		
		NodeItem encryptionKeyType1 = new NodeItem(BTRTMapping.ENCRYPTION_KEY_TYPE.getCode(), "ACSTACTV");
		encryption1.getChildren().add(encryptionKeyType1);
		encryptionKeyType1.setParent(encryption1);
		///////////////////////////GROUP TERMINAL 2///////////////////////////////
		
		return app;
	}
	
	/**
	 * Create sub merchant structure with deepness as level.
	 * @param merchant
	 * @param level
	 */
	private static void createSubLevelMerchant(NodeItem merchant, int level) {
		////////////////////////////MERCHANT SUB-LEVEL BLOCK//////////////////////////
		NodeItem merchant1 = new NodeItem(BTRTMapping.MERCHANT_SUB_LEVEL_1.getCode(), null);
		merchant.getChildren().add(merchant1);
		merchant1.setParent(merchant);
		
		NodeItem merchantLevel1 = new NodeItem(BTRTMapping.MERCHANT_LEVEL.getCode(), null);
		merchant1.getChildren().add(merchantLevel1);
		merchantLevel1.setParent(merchant1);
		
		NodeItem merchantName1 = new NodeItem(BTRTMapping.MERCHANT_NAME.getCode(), "sub merchant 1");
		merchantLevel1.getChildren().add(merchantName1);
		merchantName1.setParent(merchantLevel1);
		
		NodeItem merchantLabel1 = new NodeItem(BTRTMapping.MERCHANT_LABEL.getCode(), "sub merchant 1");
		merchantLevel1.getChildren().add(merchantLabel1);
		merchantLabel1.setParent(merchantLevel1);
		
		///////////////////////////sub-level1 CONTACT/////////////////////////////
		NodeItem contact1 = new NodeItem(BTRTMapping.CONTACT.getCode(), null);
		merchant1.getChildren().add(contact1);
		contact1.setParent(merchant1);
		
		NodeItem person2 = new NodeItem(BTRTMapping.PERSON.getCode(), null);
		contact1.getChildren().add(person2);
		person2.setParent(contact1);
		
		NodeItem firstName2 = new NodeItem(BTRTMapping.FIRST_NAME.getCode(), null);
		person2.getChildren().add(firstName2);
		firstName2.setParent(person2);
		
		NodeItem address2 = new NodeItem(BTRTMapping.ADDRESS.getCode(), null);
		person2.getChildren().add(address2);
		address2.setParent(person2);
		
		NodeItem region2 = new NodeItem(BTRTMapping.REGION.getCode(), "sub-addr of sub-level merchant");
		address2.getChildren().add(region2);
		region2.setParent(address2);
		
		NodeItem mobilePhone2 = new NodeItem(BTRTMapping.MOBILE_PHONE.getCode(), "123456789");
		address2.getChildren().add(mobilePhone2);
		mobilePhone2.setParent(address2);
		
		NodeItem address3 = new NodeItem(BTRTMapping.ADDRESS.getCode(), null);
		contact1.getChildren().add(address3);
		address3.setParent(contact1);
		
		NodeItem region3 = new NodeItem(BTRTMapping.REGION.getCode(), null);
		address3.getChildren().add(region3);
		region3.setParent(address3);
		
		NodeItem mobilePhone3 = new NodeItem(BTRTMapping.MOBILE_PHONE.getCode(), "123456789");
		address3.getChildren().add(mobilePhone3);
		mobilePhone3.setParent(address3);
		
		///////////////////////////sub-level1 CONTACT////////////////////////////
		
		////////////////////////////sub-level1 ACCOUNT//////////////////////////////
		NodeItem account2 = new NodeItem(BTRTMapping.ACCOUNT.getCode(), null);
		merchant1.getChildren().add(account2);
		account2.setParent(merchant1);
		
		NodeItem sequence30 = new NodeItem(BTRTMapping.SEQUENCE.getCode(), "30");
		account2.getChildren().add(sequence30);
		sequence30.setParent(account2);
		
		NodeItem accInit2 = new NodeItem(BTRTMapping.ACCOUNT_INIT.getCode(), null);
		account2.getChildren().add(accInit2);
		accInit2.setParent(account2);
		
		NodeItem sequence31 = new NodeItem(BTRTMapping.SEQUENCE.getCode(), "31");
		accInit2.getChildren().add(sequence31);
		sequence31.setParent(accInit2);
		
		NodeItem accNumber2 = new NodeItem(BTRTMapping.ACCOUNT_NUMBER.getCode(), "sub-acc of sub-level merchant");
		accInit2.getChildren().add(accNumber2);
		accNumber2.setParent(accInit2);
		///////////////////////////sub-level1 ACCOUNT////////////////////////////
		
		//////////////////////////sub-level1 GROUP TERMINAL/////////////////////////////
		NodeItem terminal = new NodeItem(BTRTMapping.GROUP_TERMINAL.getCode(), null);
		merchant1.getChildren().add(terminal);
		terminal.setParent(merchant1);
		
		NodeItem terminalLevel = new NodeItem(BTRTMapping.TERMINAL_LEVEL.getCode(), null);
		terminal.getChildren().add(terminalLevel);
		terminalLevel.setParent(terminal);
		
		NodeItem terminalType = new NodeItem(BTRTMapping.TERMINAL_TYPE.getCode(), null);
		terminalLevel.getChildren().add(terminalType);
		terminalType.setParent(terminalLevel);
		
		NodeItem catLevel = new NodeItem(BTRTMapping.CAT_LEVEL.getCode(), null);
		terminalLevel.getChildren().add(catLevel);
		catLevel.setParent(terminalLevel);
		
		NodeItem cardDataInputCap = new NodeItem(BTRTMapping.CARD_DATA_INPUT_CAP.getCode(), null);
		terminalLevel.getChildren().add(cardDataInputCap);
		cardDataInputCap.setParent(terminalLevel);
		
		NodeItem crdhAuthCap = new NodeItem(BTRTMapping.CRDH_AUTH_CAP.getCode(), null);
		terminalLevel.getChildren().add(crdhAuthCap);
		crdhAuthCap.setParent(terminalLevel);
		
		NodeItem cardCaptureCap = new NodeItem(BTRTMapping.CARD_CAPTURE_CAP.getCode(), null);
		terminalLevel.getChildren().add(cardCaptureCap);
		cardCaptureCap.setParent(terminalLevel);
		
		NodeItem address4 = new NodeItem(BTRTMapping.ADDRESS.getCode(), null);
		terminal.getChildren().add(address4);
		address4.setParent(terminal);
		
		NodeItem region4 = new NodeItem(BTRTMapping.REGION.getCode(), null);
		address4.getChildren().add(region4);
		region4.setParent(address4);
		
		NodeItem mobilePhone4 = new NodeItem(BTRTMapping.MOBILE_PHONE.getCode(), "123456789");
		address4.getChildren().add(mobilePhone4);
		mobilePhone4.setParent(address4);
		
		NodeItem account1 = new NodeItem(BTRTMapping.ACCOUNT.getCode(), null);
		terminal.getChildren().add(account1);
		account1.setParent(terminal);
		
		NodeItem sequence20 = new NodeItem(BTRTMapping.SEQUENCE.getCode(), "20");
		account1.getChildren().add(sequence20);
		sequence20.setParent(account1);
		
		NodeItem accInit1 = new NodeItem(BTRTMapping.ACCOUNT_INIT.getCode(), null);
		account1.getChildren().add(accInit1);
		accInit1.setParent(account1);
		
		NodeItem sequence21 = new NodeItem(BTRTMapping.SEQUENCE.getCode(), "21");
		accInit1.getChildren().add(sequence21);
		sequence21.setParent(accInit1);
		
		NodeItem accNumber1 = new NodeItem(BTRTMapping.ACCOUNT_NUMBER.getCode(), "Account of terminal");
		accInit1.getChildren().add(accNumber1);
		accNumber1.setParent(accInit1);
		
		NodeItem accData1 = new NodeItem(BTRTMapping.ACCOUNT_DATA.getCode(), null);
		account1.getChildren().add(accData1);
		accData1.setParent(account1);
		
		NodeItem sequence22 = new NodeItem(BTRTMapping.SEQUENCE.getCode(), "22");
		accData1.getChildren().add(sequence22);
		sequence22.setParent(accData1);
		
		NodeItem accStatus1 = new NodeItem(BTRTMapping.ACCOUNT_STATUS.getCode(), "ACSTACTV");
		accData1.getChildren().add(accStatus1);
		accStatus1.setParent(accData1);
		
		NodeItem encryption = new NodeItem(BTRTMapping.ENCRYPTION.getCode(), null);
		terminal.getChildren().add(encryption);
		encryption.setParent(terminal);
		
		NodeItem encryptionKeyType = new NodeItem(BTRTMapping.ENCRYPTION_KEY_TYPE.getCode(), "ACSTACTV");
		encryption.getChildren().add(encryptionKeyType);
		encryptionKeyType.setParent(encryption);
		///////////////////////////sub-level1 GROUP TERMINAL///////////////////////////////
		
		///////////////////////////sub-level2 GROUP TERMINAL///////////////////////////////
		if (level + 1 <= MAX_LEVEL) createSubLevelMerchant(merchant1, level + 1);
		///////////////////////////sub-level2 GROUP TERMINAL///////////////////////////////
	}
	
	/**
	 * Create card/account data application.
	 * @return NodeItem
	 */
	private static NodeItem createCardAccApp() {
		/////////////////////////APPLICATION BLOCK/////////////////////////////
		NodeItem app = new NodeItem(BTRTMapping.BTRT05.getCode(), null);
//		result.add(app);
		
		NodeItem main = new NodeItem(BTRTMapping.MAIN_BLOCK.getCode(), null);
		app.getChildren().add(main);
		main.setParent(app);
		
		NodeItem sequence = new NodeItem(BTRTMapping.SEQUENCE.getCode(), "1");
		main.getChildren().add(sequence);
		sequence.setParent(main);
		
		NodeItem appType = new NodeItem(BTRTMapping.APPLICATION_TYPE.getCode(), "APTPISSA");
		main.getChildren().add(appType);
		appType.setParent(main);
		
		
		////////////////////////CUSTOMER BLOCK////////////////////////////
		NodeItem customer = new NodeItem(BTRTMapping.CUSTOMER.getCode(), null);
		app.getChildren().add(customer);
		customer.setParent(app);
		
		NodeItem sequence1 = new NodeItem(BTRTMapping.SEQUENCE.getCode(), "2");
		customer.getChildren().add(sequence1);
		sequence1.setParent(customer);
		
		NodeItem customerCate = new NodeItem(BTRTMapping.CUSTOMER_CATEGORY.getCode(), null);
		customer.getChildren().add(customerCate);
		customerCate.setParent(customer);
		
		NodeItem identityCard = new NodeItem(BTRTMapping.IDENTITY_CARD.getCode(), null);
		customer.getChildren().add(identityCard);
		identityCard.setParent(customer);
		
		NodeItem sequence2 = new NodeItem(BTRTMapping.SEQUENCE.getCode(), "3");
		identityCard.getChildren().add(sequence2);
		sequence2.setParent(identityCard);
		
		NodeItem idNumber = new NodeItem(BTRTMapping.ID_NUMBER.getCode(), "123456");
		identityCard.getChildren().add(idNumber);
		idNumber.setParent(identityCard);
		
		NodeItem additionalParam = new NodeItem(BTRTMapping.ADDITIONAL_PARAMETERS_BLOCK.getCode(), null);
		addSimpleNodeToNode(additionalParam, customer);
		
		NodeItem param = new NodeItem(BTRTMapping.PARAMETER.getCode(), null);
		addSimpleNodeToNode(param, additionalParam);
		
		NodeItem paramName = new NodeItem(BTRTMapping.PARAMETER_NAME.getCode(), "ownership_type");
		addSimpleNodeToNode(paramName, param);
		
		NodeItem paramValue = new NodeItem(BTRTMapping.PARAMETER_VALUE.getCode(), "06");
		addSimpleNodeToNode(paramValue, param);

		NodeItem param1 = new NodeItem(BTRTMapping.PARAMETER.getCode(), null);
		addSimpleNodeToNode(param1, additionalParam);
		
		NodeItem paramName1 = new NodeItem(BTRTMapping.PARAMETER_NAME.getCode(), "parent_customer");
		addSimpleNodeToNode(paramName1, param1);
		
		NodeItem paramValue1 = new NodeItem(BTRTMapping.PARAMETER_VALUE.getCode(), "parent customer");
		addSimpleNodeToNode(paramValue1, param1);
		
		/////////////////////////CUSTOMER BLOCK////////////////////////////


		//////////////////////////CARDHOLDER///////////////////////////
//		NodeItem cardHolder = new NodeItem(BTRTMapping.CARDHOLDER.getCode(), null);
//		app.getChildren().add(cardHolder);
//		cardHolder.setParent(app);
//		
//		NodeItem sequence3 = new NodeItem(BTRTMapping.SEQUENCE.getCode(), "4");
//		cardHolder.getChildren().add(sequence3);
//		sequence3.setParent(cardHolder);
//		
//		NodeItem person = new NodeItem(BTRTMapping.PERSON.getCode(), null);
//		cardHolder.getChildren().add(person);
//		person.setParent(cardHolder);
//		
//		NodeItem sequence4 = new NodeItem(BTRTMapping.SEQUENCE.getCode(), "5");
//		person.getChildren().add(sequence4);
//		sequence4.setParent(person);
//		
//		NodeItem firstName = new NodeItem(BTRTMapping.FIRST_NAME.getCode(), "Khanh");
//		person.getChildren().add(firstName);
//		firstName.setParent(person);
//		
//		NodeItem securityQuest1 = new NodeItem(BTRTMapping.SECURITY_QUESTION_1.getCode(), "SEQUW004");
//		person.getChildren().add(securityQuest1);
//		securityQuest1.setParent(person);
//		
//		NodeItem securityID1 = new NodeItem(BTRTMapping.SECURITY_ID_1.getCode(), "GCS");
//		person.getChildren().add(securityID1);
//		securityID1.setParent(person);
//		
//		NodeItem securityQuest2 = new NodeItem(BTRTMapping.SECURITY_QUESTION_2.getCode(), "SEQUW003");
//		person.getChildren().add(securityQuest2);
//		securityQuest2.setParent(person);
//		
//		NodeItem securityID2 = new NodeItem(BTRTMapping.SECURITY_ID_2.getCode(), "Luong Dinh Cua");
//		person.getChildren().add(securityID2);
//		securityID2.setParent(person);
//		
//		NodeItem idNumber1 = new NodeItem(BTRTMapping.ID_NUMBER.getCode(), "456789");
//		person.getChildren().add(idNumber1);
//		idNumber1.setParent(person);
//		
//		NodeItem languageCode = new NodeItem(BTRTMapping.LANGUAGE_CODE.getCode(), "CLNGENG");
//		person.getChildren().add(languageCode);
//		languageCode.setParent(person);
//		
//		NodeItem address = new NodeItem(BTRTMapping.ADDRESS.getCode(), null);
//		cardHolder.getChildren().add(address);
//		address.setParent(cardHolder);
//		
//		NodeItem sequence5 = new NodeItem(BTRTMapping.SEQUENCE.getCode(), "6");
//		address.getChildren().add(sequence5);
//		sequence5.setParent(address);
//		
//		NodeItem region = new NodeItem(BTRTMapping.REGION.getCode(), "region 1");
//		address.getChildren().add(region);
//		region.setParent(address);
//		
//		NodeItem mobilePhone = new NodeItem(BTRTMapping.MOBILE_PHONE.getCode(), "123456789");
//		address.getChildren().add(mobilePhone);
//		mobilePhone.setParent(address);
//		
//		NodeItem fax = new NodeItem(BTRTMapping.FAX.getCode(), "123");
//		address.getChildren().add(fax);
//		fax.setParent(address);
//		
//		NodeItem email = new NodeItem(BTRTMapping.EMAIL.getCode(), "lupaka2006@gmail.com");
//		address.getChildren().add(email);
//		email.setParent(address);
		///////////////////////CARDHOLDER///////////////////////////

		//////////////////////////CARD_1//////////////////////////////
		NodeItem card = new NodeItem(BTRTMapping.CARD.getCode(), null);
		app.getChildren().add(card);
		card.setParent(app);
		
		NodeItem sequence6 = new NodeItem(BTRTMapping.SEQUENCE.getCode(), "7");
		card.getChildren().add(sequence6);
		sequence6.setParent(card);
		
		NodeItem cardInit = new NodeItem(BTRTMapping.CARD_INIT.getCode(), null);
		card.getChildren().add(cardInit);
		cardInit.setParent(card);
		
		NodeItem sequence7 = new NodeItem(BTRTMapping.SEQUENCE.getCode(), "8");
		cardInit.getChildren().add(sequence7);
		sequence7.setParent(cardInit);
		
		NodeItem cardNumber = new NodeItem(BTRTMapping.CARD_NUMBER.getCode(), "123456789");
		cardInit.getChildren().add(cardNumber);
		cardNumber.setParent(cardInit);
		
		NodeItem cardData = new NodeItem(BTRTMapping.CARD_REISSUE_DATA.getCode(), null);
		card.getChildren().add(cardData);
		cardData.setParent(card);
		
		NodeItem sequence8 = new NodeItem(BTRTMapping.SEQUENCE.getCode(), "9");
		cardData.getChildren().add(sequence8);
		sequence8.setParent(cardData);
		
//		NodeItem cardHolderName = new NodeItem(BTRTMapping.CARDHOLDER_NAME.getCode(), "LUU PHAM VAN KHANH");
//		cardData.getChildren().add(cardHolderName);
//		cardHolderName.setParent(cardData);
//		
//		NodeItem startDate = new NodeItem(BTRTMapping.START_DATE.getCode(), "06222012");
//		cardData.getChildren().add(startDate);
//		startDate.setParent(cardData);
//		
//		NodeItem answer = new NodeItem(BTRTMapping.SECURITY_ID_1.getCode(), "SECURE CODE");
//		cardData.getChildren().add(answer);
//		answer.setParent(cardData);
		////////////////////////CARD/////////////////////////////

		////////////////////////ACCOUNT///////////////////////////
//		NodeItem account = new NodeItem(BTRTMapping.ACCOUNT.getCode(), null);
//		app.getChildren().add(account);
//		account.setParent(app);
//		
//		NodeItem sequence9 = new NodeItem(BTRTMapping.SEQUENCE.getCode(), "10");
//		account.getChildren().add(sequence9);
//		sequence9.setParent(account);
//		
//		NodeItem accInit = new NodeItem(BTRTMapping.ACCOUNT_INIT.getCode(), null);
//		account.getChildren().add(accInit);
//		accInit.setParent(account);
//		
//		NodeItem sequence10 = new NodeItem(BTRTMapping.SEQUENCE.getCode(), "11");
//		accInit.getChildren().add(sequence10);
//		sequence10.setParent(accInit);
//		
//		NodeItem accNumber = new NodeItem(BTRTMapping.ACCOUNT_NUMBER.getCode(), "987654321");
//		accInit.getChildren().add(accNumber);
//		accNumber.setParent(accInit);
//		
//		NodeItem accData = new NodeItem(BTRTMapping.ACCOUNT_DATA.getCode(), null);
//		account.getChildren().add(accData);
//		accData.setParent(account);
//		
//		NodeItem sequence11 = new NodeItem(BTRTMapping.SEQUENCE.getCode(), "12");
//		accData.getChildren().add(sequence11);
//		sequence11.setParent(accData);
//		
//		NodeItem accStatus = new NodeItem(BTRTMapping.ACCOUNT_STATUS.getCode(), "ACSTACTV");
//		accData.getChildren().add(accStatus);
//		accStatus.setParent(accData);
		/////////////////////////ACCOUNT//////////////////////////////
		
		////////////////////////ACCOUNT_2///////////////////////////
//		NodeItem account2 = new NodeItem(BTRTMapping.ACCOUNT.getCode(), null);
//		app.getChildren().add(account2);
//		account2.setParent(app);
//		
//		NodeItem sequence29 = new NodeItem(BTRTMapping.SEQUENCE.getCode(), "10");
//		account2.getChildren().add(sequence29);
//		sequence29.setParent(account2);
//		
//		NodeItem accInit2 = new NodeItem(BTRTMapping.ACCOUNT_INIT.getCode(), null);
//		account2.getChildren().add(accInit2);
//		accInit2.setParent(account2);
//		
//		NodeItem sequence30 = new NodeItem(BTRTMapping.SEQUENCE.getCode(), "11");
//		accInit2.getChildren().add(sequence30);
//		sequence30.setParent(accInit2);
//		
//		NodeItem accNumber2 = new NodeItem(BTRTMapping.ACCOUNT_NUMBER.getCode(), "987654321");
//		accInit2.getChildren().add(accNumber2);
//		accNumber2.setParent(accInit2);
//		
//		NodeItem accData2 = new NodeItem(BTRTMapping.ACCOUNT_DATA.getCode(), null);
//		account2.getChildren().add(accData2);
//		accData2.setParent(account2);
//		
//		NodeItem sequence31 = new NodeItem(BTRTMapping.SEQUENCE.getCode(), "12");
//		accData2.getChildren().add(sequence31);
//		sequence31.setParent(accData2);
//		
//		NodeItem accStatus2 = new NodeItem(BTRTMapping.ACCOUNT_STATUS.getCode(), "ACSTACTV");
//		accData2.getChildren().add(accStatus2);
//		accStatus2.setParent(accData2);
		/////////////////////////ACCOUNT_2//////////////////////////////


		////////////////////CONTACT_INFO_BLOCK//////////////////////
		NodeItem contact = new NodeItem(BTRTMapping.CONTACT.getCode(), null);
		app.getChildren().add(contact);
		contact.setParent(app);
		
		NodeItem person1 = new NodeItem(BTRTMapping.PERSON.getCode(), null);
		contact.getChildren().add(person1);
		person1.setParent(contact);
		
		NodeItem firstName1 = new NodeItem(BTRTMapping.FIRST_NAME.getCode(), null);
		person1.getChildren().add(firstName1);
		firstName1.setParent(person1);
		
		NodeItem securityQuest1_1 = new NodeItem(BTRTMapping.SECURITY_QUESTION_1.getCode(), null);
		person1.getChildren().add(securityQuest1_1);
		securityQuest1_1.setParent(person1);
		
		NodeItem securityID1_1 = new NodeItem(BTRTMapping.SECURITY_ID_1.getCode(), null);
		person1.getChildren().add(securityID1_1);
		securityID1_1.setParent(person1);
		
		NodeItem securityQuest2_1 = new NodeItem(BTRTMapping.SECURITY_QUESTION_2.getCode(), null);
		person1.getChildren().add(securityQuest2_1);
		securityQuest2_1.setParent(person1);
		
		NodeItem securityID2_1 = new NodeItem(BTRTMapping.SECURITY_ID_2.getCode(), null);
		person1.getChildren().add(securityID2_1);
		securityID2_1.setParent(person1);
		
		NodeItem idNumber1_1 = new NodeItem(BTRTMapping.ID_NUMBER.getCode(), null);
		person1.getChildren().add(idNumber1_1);
		idNumber1_1.setParent(person1);
		
//		NodeItem languageCode = new NodeItem(BTRTMapping.LANGUAGE_CODE.getCode(), "CLNGENG");
//		person1.getChildren().add(languageCode);
//		languageCode.setParent(person1);
		
		NodeItem address1 = new NodeItem(BTRTMapping.ADDRESS.getCode(), null);
		contact.getChildren().add(address1);
		address1.setParent(contact);
		
		NodeItem region1 = new NodeItem(BTRTMapping.REGION.getCode(), null);
		address1.getChildren().add(region1);
		region1.setParent(address1);
		
		NodeItem mobilePhone1 = new NodeItem(BTRTMapping.MOBILE_PHONE.getCode(), "123456789");
		address1.getChildren().add(mobilePhone1);
		mobilePhone1.setParent(address1);
		
		NodeItem fax1 = new NodeItem(BTRTMapping.FAX.getCode(), "123");
		address1.getChildren().add(fax1);
		fax1.setParent(address1);
		
		NodeItem email1 = new NodeItem(BTRTMapping.EMAIL.getCode(), "lupaka2006@gmail.com");
		address1.getChildren().add(email1);
		email1.setParent(address1);
		///////////////////////////////CONTACT_INFO_BLOCK/////////////////////////////

		return app;
	}
}
