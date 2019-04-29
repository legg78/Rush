package ru.bpc.sv2.scheduler.process.converter;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

import org.apache.log4j.Logger;

import ru.bpc.sv2.constants.SystemConstants;
import ru.bpc.sv2.logic.ApplicationDao;
import ru.bpc.sv2.process.btrt.BTRTMapping;
import ru.bpc.sv2.process.btrt.NodeItem;

public class BTRTConverter {
	
	private static final Logger logger = Logger.getLogger("PROCESSES");
	private static final int TRANSFORMING_DECIMAL = 32768;
	
	private static final int MAX_NAME_LENGTH = 3;
	private static final int MAX_LENGTH_LENGTH = 2;
	
	private static final String LANG_CONSTANT = SystemConstants.RUSSIAN_LANGUAGE;

	private static String[] HEX = { "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "A", "B", "C", "D", "E", "F" };
	private static String[] BINARY = { "0000", "0001", "0010", "0011", "0100", "0101", "0110", "0111", "1000", "1001", "1010", "1011",
	        "1100", "1101", "1110", "1111" };
	
	private static final Map<String, String> LANG_MAP = new HashMap<String, String>() {{
		put("CLNGENG", SystemConstants.ENGLISH_LANGUAGE);
		put("CLNGRUS", SystemConstants.RUSSIAN_LANGUAGE);
	}};
	
	private static final List<String> CARD_ACC_APPS = new ArrayList<String>(){{
		add(BTRTMapping.BTRT01.getCode());
		add(BTRTMapping.BTRT02.getCode());
		add(BTRTMapping.BTRT03.getCode());
		add(BTRTMapping.BTRT04.getCode());
		add(BTRTMapping.BTRT05.getCode());
		add(BTRTMapping.BTRT06.getCode());
		add(BTRTMapping.BTRT07.getCode());
		add(BTRTMapping.BTRT08.getCode());
		add(BTRTMapping.BTRT10.getCode());
		add(BTRTMapping.BTRT20.getCode());
		add(BTRTMapping.BTRT21.getCode());
		add(BTRTMapping.BTRT25.getCode());
		add(BTRTMapping.BTRT30.getCode());
		add(BTRTMapping.BTRT35.getCode());
		add(BTRTMapping.BTRT40.getCode());
	}};
	

	private static final List<String> STRANGE_APPS = new ArrayList<String>(){{
		add(BTRTMapping.BTRT15.getCode());
		add(BTRTMapping.BTRT18.getCode());
		add(BTRTMapping.BTRT19.getCode());
	}};
	
	private static final List<String> CONTACT_INFO_CARD_ACC_APPS = new ArrayList<String>(){{
		add(BTRTMapping.BTRT05.getCode());
		add(BTRTMapping.BTRT21.getCode());
		add(BTRTMapping.BTRT30.getCode());
	}};
	
	private static final List<String> MERCHANT_APPS = new ArrayList<String>(){{
		add(BTRTMapping.BTRT51.getCode());
		add(BTRTMapping.BTRT53.getCode());
		add(BTRTMapping.BTRT54.getCode());
		add(BTRTMapping.BTRT56.getCode());
		add(BTRTMapping.BTRT60.getCode());
	}};
	
	private static final List<String> CONTACT_INFO_MERCHANT_APPS = new ArrayList<String>(){{
		add(BTRTMapping.BTRT51.getCode());
		add(BTRTMapping.BTRT53.getCode());
		add(BTRTMapping.BTRT56.getCode());
	}};
	
	private static final List<String> TERMINAL_APPS = new ArrayList<String>(){{
		add(BTRTMapping.BTRT52.getCode());
	}};
	
	private static final List<String> MERCHANT_SUB_LEVELs = new ArrayList<String>(){{
		add(BTRTMapping.MERCHANT_SUB_LEVEL_1.getCode());
		add(BTRTMapping.MERCHANT_SUB_LEVEL_2.getCode());
		add(BTRTMapping.MERCHANT_SUB_LEVEL_3.getCode());
	}};
	
	public static final String PRODUCT_ID = "productId";
	public static final String ACCOUNT_TYPE = "accountType";
	public static final String CARD_TYPE_ID = "cardTypeId";
	public static final String CARD_TYPE_ARR_TYPE = "CARD_TYPES";
	private NodeItem currentNode = null;
	private NodeItem productIdNode = null;
	private NodeItem companyNode = null;
	private NodeItem serviceObject = null;
	
	private ApplicationDao appDao;
	private Long userSessionId;
	
	public static void main(String[] args) {
		testData();
	}
	
	public static List<NodeItem> testData() {
		BTRTConverter util = new BTRTConverter();
		List<NodeItem> apps = BTRTUtils.createApplication();
		NodeItem node = apps.get(1);
		try {
			if (node != null) {
				if (!BTRTMapping.APP_FILE_PROCESSING_RESPONSE.getCode().equals(node.getName())) {
					util.refactorMainBlock(node);
					if (CARD_ACC_APPS.contains(node.getName())) {
						util.refactorCardAccApp(node);
						if (CONTACT_INFO_CARD_ACC_APPS.contains(node.getName())) {
							util.moveContactBlockToCustomer(node);
						}
					} else if (MERCHANT_APPS.contains(node.getName())) {
						util.refactorMerchantApp(node);
					} else if (TERMINAL_APPS.contains(node.getName())) {
						util.refactorTerminalApp(node);
					} else if (BTRTMapping.BTRT55.getCode().equals(node.getName())) {
						util.refactorFullMerchantApp(node);
					} else if (BTRTMapping.BTRT59.getCode().equals(node.getName())) {
						util.refactorBTRT59(node);
					}
				}
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
		util.writeOutputToConsole(node, "");
		return apps;
	}
	/**
	 * Main method for reading stream and refactor BTRT structure following SV2 structure.
	 * @param is input stream
	 * @return List<NodeItem>
	 */
	public List<NodeItem> readData(InputStream is) {
		BufferedReader in = null;
		List<NodeItem> nodeItems = new ArrayList<NodeItem>();
		try {
			in = new BufferedReader(new InputStreamReader(is));
			String line;
			while ((line = in.readLine()) != null) {
				NodeItem node = createNode(line, null);
				currentNode = node;
				if (node != null) {
					if (!BTRTMapping.APP_FILE_PROCESSING_RESPONSE.getCode().equals(node.getName())) {
						refactorMainBlock(node);
						if (CARD_ACC_APPS.contains(node.getName())) {
							refactorCardAccApp(node);
							if (CONTACT_INFO_CARD_ACC_APPS.contains(node.getName())) {
								moveContactBlockToCustomer(node);
							}
						} else if (MERCHANT_APPS.contains(node.getName())) {
							refactorMerchantApp(node);
						} else if (TERMINAL_APPS.contains(node.getName())) {
							refactorTerminalApp(node);
						} else if (BTRTMapping.BTRT55.getCode().equals(node.getName())) {
							refactorFullMerchantApp(node);
						} else if (BTRTMapping.BTRT59.getCode().equals(node.getName())) {
							refactorBTRT59(node);
						}
					}
					nodeItems.add(node);
				}
			}
		} catch (Exception e) {
			e.printStackTrace();
		} finally {
			try {
				if (in != null) {
					in.close();
				}
			} catch (IOException e) {
				e.printStackTrace();
			}
		}
		return nodeItems;
	}
	
	public List<NodeItem> testReadData(InputStream is) {
		BufferedReader in = null;
		List<NodeItem> nodeItems = new ArrayList<NodeItem>();
		try {
			in = new BufferedReader(new InputStreamReader(is));
			String line;
			while ((line = in.readLine()) != null) {
				NodeItem node = createNode(line, null);
				if (node != null) {
					nodeItems.add(node);
				}
			}
		} catch (Exception e) {
			e.printStackTrace();
		} finally {
			try {
				if (in != null) {
					in.close();
				}
			} catch (IOException e) {
				e.printStackTrace();
			}
		}
		return nodeItems;
	}
	/**
	 * Refactore BTRT59 application.
	 * @param application
	 */
	private void refactorBTRT59(NodeItem application) {
		NodeItem merchantBranch = new NodeItem(BTRTMapping.MERCHANT_BRANCH.getCode(), null);
		Iterator<NodeItem> childrenOfApp = application.getChildren().iterator();
		NodeItem merchant = new NodeItem(BTRTMapping.MERCHANT.getCode(), null);

		while (childrenOfApp.hasNext()) {
			NodeItem item = (NodeItem) childrenOfApp.next();
			if (BTRTMapping.MERCHANT_LEVEL.getCode().equals(item.getName())) {
				NodeItem entityID = item.getChildren().get(0);
				merchant.getChildren().add(entityID);
				entityID.setParent(merchant);
				
				childrenOfApp.remove();
			}
		}
		
		//make relationship between merchant and merchant branch
		addNodeAtoNodeB(merchant, merchantBranch);
		addNodeAtoNodeB(merchantBranch, application);
	}
	/**
	 * Refactor full merchant application - BTRT55.
	 * @param application
	 * @throws CloneNotSupportedException
	 */
	private void refactorFullMerchantApp(NodeItem application) throws CloneNotSupportedException {
		NodeItem merchantBranch = new NodeItem(BTRTMapping.MERCHANT_BRANCH.getCode(), null);
		Iterator<NodeItem> childrenOfApp = application.getChildren().iterator();
		NodeItem merchant = new NodeItem(BTRTMapping.MERCHANT.getCode(), null);
		NodeItem contract = new NodeItem(BTRTMapping.CONTRACT.getCode(), null);
		while (childrenOfApp.hasNext()) {
			NodeItem item = (NodeItem) childrenOfApp.next();
			if (BTRTMapping.MERCHANT.getCode().equals(item.getName())) {
				refactorMerchantBlock(item, merchant, contract, childrenOfApp);
			}
		}
		//make relationship between merchant and merchant branch
		addNodeAtoNodeB(merchant, merchantBranch);
		addNodeAtoNodeB(merchantBranch, application);
		
		//make relationship between customer and contract
		addNodeAtoNodeB(contract, application);
	}
	
	/**
	 * Refactor merchant block.
	 * @param item
	 * @param merchant
	 * @param contract
	 * @param childrenOfApp
	 * @throws CloneNotSupportedException
	 */
	private void refactorMerchantBlock(NodeItem item, NodeItem merchant, NodeItem contract, Iterator<NodeItem> childrenOfApp) throws CloneNotSupportedException {
		//iterate merchant
		Iterator<NodeItem> childrenOfMerchant = item.getChildren().iterator();
		while (childrenOfMerchant.hasNext()) {
			NodeItem item1 = childrenOfMerchant.next();
			if (BTRTMapping.MERCHANT_LEVEL.getCode().equals(item1.getName())) {
				List<NodeItem> childrenOfMerchantLevel = item1.getChildren();
				for (NodeItem item2 : childrenOfMerchantLevel) {
					if (BTRTMapping.MERCHANT_NAME.getCode().equals(item2.getName())
						|| BTRTMapping.MERCHANT_LABEL.getCode().equals(item2.getName())
						|| BTRTMapping.MCC.getCode().equals(item2.getName())
						|| BTRTMapping.MERCHANT_STATUS.getCode().equals(item2.getName())) {
						NodeItem copy = item2.clone();
						merchant.getChildren().add(copy);
						copy.setParent(merchant);
					}
				}
//				break;
			}
			if (BTRTMapping.CONTACT.getCode().equals(item1.getName())) {
				refactorMerchantContact(item1, merchant);
			}
			if (BTRTMapping.ACCOUNT.getCode().equals(item1.getName())) {
				refactorAccount(item1);
				
				//make relationship between contract and account
				childrenOfMerchant.remove();//remove account
				addNodeAtoNodeB(item1, contract);
			}
			
			if (MERCHANT_SUB_LEVELs.contains(item1.getName())) {
				NodeItem subMerchant = new NodeItem(BTRTMapping.MERCHANT.getCode(), null);
				refactorMerchantBlock(item1, subMerchant, contract, childrenOfMerchant);
				//make relationship between sub-merchant and sub-merchant branch
				addNodeAtoNodeB(subMerchant, merchant);
			}
			
			if (BTRTMapping.GROUP_TERMINAL.getCode().equals(item1.getName())) {
				refactorGroupTerminalBlock(item1, merchant, contract);
			}
		}
		//remove old merchant
		childrenOfApp.remove();
//		break;
	}
	/**
	 * Insert nodeA into nodeB.
	 * @param nodeA
	 * @param nodeB
	 */
	private void addNodeAtoNodeB(NodeItem nodeA, NodeItem nodeB) {
		if (nodeA == null || nodeB == null) {
//			logger.warn("Cannot add node " + nodeA.getName() + " into node " + nodeB.getName());
			return;
		}
		if (!nodeA.getChildren().isEmpty()) {
			nodeA.setParent(nodeB);
			nodeB.getChildren().add(nodeA);
		}
	}
	/**
	 * Refactor merchant application.
	 * @param application
	 * @throws CloneNotSupportedException
	 */
	private void refactorMerchantApp(NodeItem application) throws CloneNotSupportedException {
		NodeItem merchantBranch = new NodeItem(BTRTMapping.MERCHANT_BRANCH.getCode(), null);
		Iterator<NodeItem> childrenOfApp = application.getChildren().iterator();
		NodeItem merchant = new NodeItem(BTRTMapping.MERCHANT.getCode(), null);
		NodeItem contract = new NodeItem(BTRTMapping.CONTRACT.getCode(), null);
		while (childrenOfApp.hasNext()) {
			NodeItem item = (NodeItem) childrenOfApp.next();
			if (BTRTMapping.MERCHANT.getCode().equals(item.getName())) {
//				merchant = item.clone();
				//iterate merchant
				List<NodeItem> childrenOfMerchant = item.getChildren();
				for (NodeItem item1 : childrenOfMerchant) {
					if (BTRTMapping.MERCHANT_LEVEL.getCode().equals(item1.getName())) {
						List<NodeItem> childrenOfMerchantLevel = item1.getChildren();
						for (NodeItem item2 : childrenOfMerchantLevel) {
							if (BTRTMapping.MERCHANT_NAME.getCode().equals(item2.getName())
								|| BTRTMapping.MERCHANT_LABEL.getCode().equals(item2.getName())
								|| BTRTMapping.MCC.getCode().equals(item2.getName())
								|| BTRTMapping.MERCHANT_STATUS.getCode().equals(item2.getName())) {
								NodeItem copy = item2.clone();
								merchant.getChildren().add(copy);
								copy.setParent(merchant);
							}
						}
						break;
					}
				}
				//remove old merchant
				childrenOfApp.remove();
//				break;
			}
			if (BTRTMapping.ACCOUNT.getCode().equals(item.getName())) {
				refactorAccount(item);
				
				//make relationship between contract and account
				childrenOfApp.remove();//remove account
				addNodeAtoNodeB(item, contract);
			}
		}
		//make relationship between merchant and merchant branch
		addNodeAtoNodeB(merchant, merchantBranch);
		addNodeAtoNodeB(merchantBranch, application);
		
		if (CONTACT_INFO_MERCHANT_APPS.contains(application.getName())) {
			moveContactBlockToMerchant(application);
		}
		
		//make relationship between customer and contract
		addNodeAtoNodeB(contract, application);
	}
	
	private void createServiceLinkAccObject(NodeItem contract) {
//		NodeItem service = null;
		String productId = currentNode.getSubDatas().get(PRODUCT_ID);
		String accountType = currentNode.getSubDatas().get(ACCOUNT_TYPE);
		if (productId != null && accountType != null) {
			if (appDao != null) {
				Integer serviceId = appDao.getServiceId(userSessionId, accountType, Integer.parseInt(productId));
				if (serviceId != null) {
					NodeItem service1 = new NodeItem(BTRTMapping.SERVICE.getCode(), serviceId.toString());
					NodeItem serviceObject = new NodeItem(BTRTMapping.SERVICE_OBJECT.getCode(), null);
					serviceObject.getSubDatas().put(ACCOUNT_TYPE, "");//just set key for identify 
					BTRTUtils.addSimpleNodeToNode(serviceObject, service1);
					addNodeAtoNodeB(service1, contract);
				}
			}
		}
//		return service;
	}
	
	private void createServiceLinkCardObject(NodeItem contract) {
//		NodeItem service = null;
		String productId = currentNode.getSubDatas().get(PRODUCT_ID);
		String cardTypeId = currentNode.getSubDatas().get(CARD_TYPE_ID);
		if (productId != null && cardTypeId != null) {
			if (appDao != null) {
				Integer serviceId = appDao.getServiceIdByCardType(userSessionId, Integer.parseInt(cardTypeId), Integer.parseInt(productId));
				if (serviceId != null) {
					NodeItem service2 = new NodeItem(BTRTMapping.SERVICE.getCode(), serviceId.toString());
					NodeItem serviceObject = new NodeItem(BTRTMapping.SERVICE_OBJECT.getCode(), null);
					serviceObject.getSubDatas().put(CARD_TYPE_ID, "");//just set key for identify 
					BTRTUtils.addSimpleNodeToNode(serviceObject, service2);
					addNodeAtoNodeB(service2, contract);
				}
			}
		}
//		return service;
	}
	
	/**
	 * Refactor Account block.
	 * @param account
	 */
	private void refactorAccount(NodeItem account) {
		List<NodeItem> childrenOfAcc = account.getChildren();
		List<NodeItem> temp = new ArrayList<NodeItem>();
		//just keep the first sequence
		temp.add(childrenOfAcc.get(0));
		for (NodeItem child : childrenOfAcc) {
			if (!BTRTMapping.SEQUENCE.getCode().equals(child.getName())) {
				Iterator<NodeItem> chitList = child.getChildren().iterator();
				while (chitList.hasNext()) {
					NodeItem child1 = chitList.next();
					if (!BTRTMapping.SEQUENCE.getCode().equals(child1.getName())) {
						//transform into 2-level structure 
						temp.add(child1);
						child1.setParent(account);
						
						if (BTRTMapping.ACCOUNT_TYPE.getCode().equals(child1.getName())) {
							currentNode.getSubDatas().put(ACCOUNT_TYPE, child1.getData());
						}
					}
					
				}
			}
		}
		
		account.setChildren(temp);
		//add account_object node for linking account -> card
		NodeItem accountObject = new NodeItem(BTRTMapping.ACCOUNT_OBJECT.getCode(), null);
		BTRTUtils.addSimpleNodeToNode(accountObject, account);
	}
	
	/**
	 * Refactor terminal application.
	 * @param application
	 * @throws CloneNotSupportedException
	 */
	private void refactorTerminalApp(NodeItem application) throws CloneNotSupportedException {
		NodeItem merchantBranch = new NodeItem(BTRTMapping.MERCHANT_BRANCH.getCode(), null);
		NodeItem merchant = new NodeItem(BTRTMapping.MERCHANT.getCode(), null);
		merchantBranch.getChildren().add(merchant);
		merchant.setParent(merchantBranch);
		
		NodeItem contract = new NodeItem(BTRTMapping.CONTRACT.getCode(), null);
		
		Iterator<NodeItem> childrenOfApp = application.getChildren().iterator();
		while (childrenOfApp.hasNext()) {
			NodeItem item = (NodeItem) childrenOfApp.next();
			if (BTRTMapping.TERMINAL.getCode().equals(item.getName())) {
				NodeItem terminal = new NodeItem(BTRTMapping.TERMINAL.getCode(), null);
				merchant.getChildren().add(terminal);
				terminal.setParent(merchant);
				//iterate terminal
				List<NodeItem> childrenOfTerminal = item.getChildren();
				for (NodeItem item1 : childrenOfTerminal) {
					if (BTRTMapping.TERMINAL_LEVEL.getCode().equals(item1.getName())) {
						List<NodeItem> childrenOfTerminalLevel = item1.getChildren();
						for (NodeItem item2 : childrenOfTerminalLevel) {
							if (BTRTMapping.TERMINAL_TYPE.getCode().equals(item2.getName())
								|| BTRTMapping.CAT_LEVEL.getCode().equals(item2.getName())
								|| BTRTMapping.CARD_DATA_INPUT_CAP.getCode().equals(item2.getName())
								|| BTRTMapping.CRDH_AUTH_CAP.getCode().equals(item2.getName())
								|| BTRTMapping.CARD_CAPTURE_CAP.getCode().equals(item2.getName())
								|| BTRTMapping.TERM_OPERATING_ENV.getCode().equals(item2.getName())
								|| BTRTMapping.CARD_DATA_OUTPUT_CAP.getCode().equals(item2.getName())
								|| BTRTMapping.TERM_DATA_OUTPUT_CAP.getCode().equals(item2.getName())
								|| BTRTMapping.PIN_CAPTURE_CAP.getCode().equals(item2.getName())
								|| BTRTMapping.TERMINAL_STATUS.getCode().equals(item2.getName())
								|| BTRTMapping.TERMINAL_QUANTITY.getCode().equals(item2.getName())) {
								NodeItem copy = item2.clone();
								terminal.getChildren().add(copy);
								copy.setParent(terminal);
							}
						}
					}
					if (BTRTMapping.ADDRESS.getCode().equals(item1.getName())) {
						refactorTerminalAddress(item1, terminal);
					}
					if (BTRTMapping.ENCRYPTION.getCode().equals(item1.getName())) {
						terminal.getChildren().add(item1);
						item1.setParent(terminal);
					}
				}
				//remove terminal
				childrenOfApp.remove();
			}
			
			if (BTRTMapping.ACCOUNT.getCode().equals(item.getName())) {
				refactorAccount(item);
				
				//make relationship between contract and account
				childrenOfApp.remove();//remove account
				addNodeAtoNodeB(item, contract);
			}
		}
		addNodeAtoNodeB(merchantBranch, application);
		
		addNodeAtoNodeB(contract, application);
	}
	
	/**
	 * Refactor group terminal block.
	 * @param terminal
	 * @param merchant
	 * @param contract This contract has been existed since refactoring MERCHANT/ACCOUNT
	 * @throws CloneNotSupportedException
	 */
	private void refactorGroupTerminalBlock(NodeItem terminal, NodeItem merchant, NodeItem contract) throws CloneNotSupportedException {
		NodeItem terminalCopy = new NodeItem(BTRTMapping.TERMINAL.getCode(), null);
		
		Iterator<NodeItem> childrenOfTerminal = terminal.getChildren().iterator();
		//iterate terminal
		while (childrenOfTerminal.hasNext()) {
			NodeItem item1 = childrenOfTerminal.next();
			if (BTRTMapping.TERMINAL_LEVEL.getCode().equals(item1.getName())) {
				List<NodeItem> childrenOfTerminalLevel = item1.getChildren();
				for (NodeItem item2 : childrenOfTerminalLevel) {
					if (BTRTMapping.TERMINAL_TYPE.getCode().equals(item2.getName())
						|| BTRTMapping.CAT_LEVEL.getCode().equals(item2.getName())
						|| BTRTMapping.CARD_DATA_INPUT_CAP.getCode().equals(item2.getName())
						|| BTRTMapping.CRDH_AUTH_CAP.getCode().equals(item2.getName())
						|| BTRTMapping.CARD_CAPTURE_CAP.getCode().equals(item2.getName())
						|| BTRTMapping.TERM_OPERATING_ENV.getCode().equals(item2.getName())
						|| BTRTMapping.CARD_DATA_OUTPUT_CAP.getCode().equals(item2.getName())
						|| BTRTMapping.TERM_DATA_OUTPUT_CAP.getCode().equals(item2.getName())
						|| BTRTMapping.PIN_CAPTURE_CAP.getCode().equals(item2.getName())
						|| BTRTMapping.TERMINAL_STATUS.getCode().equals(item2.getName())
						|| BTRTMapping.TERMINAL_QUANTITY.getCode().equals(item2.getName())) {
						NodeItem copy = item2.clone();
						terminalCopy.getChildren().add(copy);
						copy.setParent(terminalCopy);
					}
				}
			}
			if (BTRTMapping.ADDRESS.getCode().equals(item1.getName())) {
				refactorTerminalAddress(item1, terminalCopy);
			}
			if (BTRTMapping.ENCRYPTION.getCode().equals(item1.getName())) {
				terminalCopy.getChildren().add(item1);
				item1.setParent(terminalCopy);
			}
			if (BTRTMapping.ACCOUNT.getCode().equals(item1.getName())) {
				refactorAccount(item1);
				//make relationship between contract and account
				addNodeAtoNodeB(item1, contract);
			}
		}
		
		//remove old terminal
		merchant.getChildren().remove(terminal);
		//add new terminal into merchant
		merchant.getChildren().add(terminalCopy);
		terminalCopy.setParent(merchant);
	}
	
	/**
	 * Refactor terminal address block.
	 * @param address
	 * @param terminal
	 */
	private void refactorTerminalAddress(NodeItem address, NodeItem terminal) {
		NodeItem primaryPhone = new NodeItem(BTRTMapping.CONTACT_DATA.getCode(), null);
		NodeItem mobilePhone = new NodeItem(BTRTMapping.CONTACT_DATA.getCode(), null);
		NodeItem fax = new NodeItem(BTRTMapping.CONTACT_DATA.getCode(), null);
		NodeItem email = new NodeItem(BTRTMapping.CONTACT_DATA.getCode(), null);
		
		Map<String, NodeItem> contactDatas = new HashMap<String, NodeItem>();
	    contactDatas.put(BTRTMapping.PRIMARY_PHONE.toString(), primaryPhone);
	    contactDatas.put(BTRTMapping.MOBILE_PHONE.toString(), mobilePhone);
	    contactDatas.put(BTRTMapping.FAX.toString(), fax);
	    contactDatas.put(BTRTMapping.EMAIL.toString(), email);
	    
		refactorAddress(address, contactDatas);
		
		addNodeAtoNodeB(address, terminal);
		
		NodeItem contact = new NodeItem(BTRTMapping.CONTACT.getCode(), null);
		addNodeAtoNodeB(primaryPhone, contact);
		addNodeAtoNodeB(mobilePhone, contact);
		addNodeAtoNodeB(fax, contact);
		addNodeAtoNodeB(email, contact);
		addNodeIntoNode(contact, terminal);
	}
	
	/**
	 * Refactor main block.
	 * 
	 * @param nodeItem
	 */
	private void refactorMainBlock(NodeItem application) {
		List<NodeItem> childrenOfApp = application.getChildren();
		for (NodeItem node : childrenOfApp) {
			if (BTRTMapping.MAIN_BLOCK.getCode().equals(node.getName())) {
				List<NodeItem> childrenOfMain = node.getChildren();
				int index = 1;
				NodeItem appIdNode = null;
				NodeItem appNumberNode = null;
				for (NodeItem child : childrenOfMain) {
					if (!BTRTMapping.SEQUENCE.getCode().equals(child.getName())) {
						application.getChildren().add(index, child);
					}
					if (BTRTMapping.APPLICATION_ID.getCode().equals(child.getName())) {
						appIdNode = child;
						appNumberNode = new NodeItem(BTRTMapping.ORIGIN_APPL_NUMBER.getCode(), child.getData());
					}
					if (BTRTMapping.PRODUCT_ID.getCode().equals(child.getName())) {
						currentNode.getSubDatas().put(PRODUCT_ID, child.getData());
						productIdNode = child;
					}
					index++;
				}
				application.getChildren().remove(node);
				application.getChildren().remove(appIdNode);
				application.getChildren().remove(productIdNode);
				BTRTUtils.addSimpleNodeToNode(appNumberNode, application);
				break;
			}				
		}
	}
	
	/**
	 * Refactor CardHolder block.
	 * @param cardHolder
	 */
	private void refactorCardHolder(NodeItem cardHolder) {
		Iterator<NodeItem> childrenOfCardHolder = cardHolder.getChildren().iterator();
		NodeItem secWord1 = new NodeItem(BTRTMapping.SEC_WORD.getCode(), null);
		NodeItem secWord2 = new NodeItem(BTRTMapping.SEC_WORD.getCode(), null);
		NodeItem secWord3 = new NodeItem(BTRTMapping.SEC_WORD.getCode(), null);
		NodeItem secWord4 = new NodeItem(BTRTMapping.SEC_WORD.getCode(), null);
		NodeItem secWord5 = new NodeItem(BTRTMapping.SEC_WORD.getCode(), null);
		
		NodeItem primaryPhone = new NodeItem(BTRTMapping.CONTACT_DATA.getCode(), null);
		NodeItem mobilePhone = new NodeItem(BTRTMapping.CONTACT_DATA.getCode(), null);
		NodeItem fax = new NodeItem(BTRTMapping.CONTACT_DATA.getCode(), null);
		NodeItem email = new NodeItem(BTRTMapping.CONTACT_DATA.getCode(), null);
		
		NodeItem personName = null;
		NodeItem addressName = null;
		
		while (childrenOfCardHolder.hasNext()) {
			NodeItem item = childrenOfCardHolder.next();
			if (BTRTMapping.PERSON.getCode().equals(item.getName())) {
				personName = refactorPerson(item, secWord1, secWord2, secWord3, secWord4, secWord5);
			}
			if (BTRTMapping.ADDRESS.getCode().equals(item.getName())) {
				Map<String, NodeItem> contactDatas = new HashMap<String, NodeItem>();
			    contactDatas.put(BTRTMapping.PRIMARY_PHONE.toString(), primaryPhone);
			    contactDatas.put(BTRTMapping.MOBILE_PHONE.toString(), mobilePhone);
			    contactDatas.put(BTRTMapping.FAX.toString(), fax);
			    contactDatas.put(BTRTMapping.EMAIL.toString(), email);
			    
				addressName = refactorAddress(item, contactDatas);
			}
		}
		if (personName != null && addressName != null) {
			addressName.setLang(personName.getLang());
		}
		
		//add sec_word into CardHolder
		addNodeAtoNodeB(secWord1, cardHolder);
		addNodeAtoNodeB(secWord2, cardHolder);
		addNodeAtoNodeB(secWord3, cardHolder);
		addNodeAtoNodeB(secWord4, cardHolder);
		addNodeAtoNodeB(secWord5, cardHolder);
		
		NodeItem contact = new NodeItem(BTRTMapping.CONTACT.getCode(), null);
		
		//add contact_data into CARDHOLDER/CONTACT or CONTACT
		addNodeAtoNodeB(primaryPhone, contact);
		addNodeAtoNodeB(mobilePhone, contact);
		addNodeAtoNodeB(fax, contact);
		addNodeAtoNodeB(email, contact);

		addNodeAtoNodeB(contact, cardHolder);
	}
	
	/**
	 * Refactor person block.
	 * @param item
	 * @param secWord1
	 * @param secWord2
	 * @param secWord3
	 * @param secWord4
	 * @param secWord5
	 * @return personName
	 */
	private NodeItem refactorPerson(NodeItem item, NodeItem secWord1, NodeItem secWord2, NodeItem secWord3, NodeItem secWord4, NodeItem secWord5) {
		Iterator<NodeItem> childrenOfPerson = item.getChildren().iterator();
		NodeItem personName = new NodeItem(BTRTMapping.PERSON_NAME.getCode(), null); 
		NodeItem identityCard = new NodeItem(BTRTMapping.IDENTITY_CARD.getCode(), null);
		while(childrenOfPerson.hasNext()) {
			NodeItem item1 = childrenOfPerson.next();
			if (BTRTMapping.FIRST_NAME.getCode().equals(item1.getName())
				|| BTRTMapping.SURNAME.getCode().equals(item1.getName())
				|| BTRTMapping.SECOND_NAME.getCode().equals(item1.getName())) {
				//make relationship between item1 and person name then remove
				item1.setParent(personName);
				personName.getChildren().add(item1);
				childrenOfPerson.remove();
			}
			if (BTRTMapping.ID_TYPE.getCode().equals(item1.getName())
				|| BTRTMapping.ID_EXPIRE_DATE.getCode().equals(item1.getName())
				|| BTRTMapping.ID_ISSUE_DATE.getCode().equals(item1.getName())
				|| BTRTMapping.ID_ISSUER.getCode().equals(item1.getName())
				|| BTRTMapping.ID_NUMBER.getCode().equals(item1.getName())
				|| BTRTMapping.ID_SERIES.getCode().equals(item1.getName())) {
				//make relationship between item1 and identity card then remove
				item1.setParent(identityCard);
				identityCard.getChildren().add(item1);
				childrenOfPerson.remove();
			}
			if (BTRTMapping.LANGUAGE_CODE.getCode().equals(item1.getName())) {
				personName.setLang(LANG_MAP.get(item1.getData()));
				childrenOfPerson.remove();
			}
			
			createSecWord(childrenOfPerson, secWord1, item1, BTRTMapping.SECURITY_ID_1.getCode(), BTRTMapping.SECURITY_QUESTION_1.getCode());
			createSecWord(childrenOfPerson, secWord2, item1, BTRTMapping.SECURITY_ID_2.getCode(), BTRTMapping.SECURITY_QUESTION_2.getCode());
			createSecWord(childrenOfPerson, secWord3, item1, BTRTMapping.SECURITY_ID_3.getCode(), BTRTMapping.SECURITY_QUESTION_3.getCode());
			createSecWord(childrenOfPerson, secWord4, item1, BTRTMapping.SECURITY_ID_4.getCode(), BTRTMapping.SECURITY_QUESTION_4.getCode());
			createSecWord(childrenOfPerson, secWord5, item1, BTRTMapping.SECURITY_ID_5.getCode(), BTRTMapping.SECURITY_QUESTION_5.getCode());
		}
		//make relationship between person_name and person
		addNodeAtoNodeB(personName, item);
		//make relationship between identity_card and person
		addNodeAtoNodeB(identityCard, item);
		
		return personName;
	}
	
	/**
	 * Refactor address block.
	 * @param address
	 * @param mobilePhone
	 * @param fax
	 * @param email
	 * @return addressName
	 */
//	private NodeItem refactorAddress(NodeItem address, NodeItem primaryPhone, NodeItem mobilePhone, NodeItem fax, NodeItem email) {
//		Iterator<NodeItem> childrenOfAddress = address.getChildren().iterator();
//		NodeItem addrName = new NodeItem(BTRTMapping.ADDRESS_NAME.getCode(), null); 
//		while(childrenOfAddress.hasNext()) {
//			NodeItem item1 = childrenOfAddress.next();
//			if (BTRTMapping.REGION.getCode().equals(item1.getName())
//				|| BTRTMapping.CITY.getCode().equals(item1.getName())
//				|| BTRTMapping.STREET.getCode().equals(item1.getName())) {
//				//make relationship between item1 and addrName then remove
//				item1.setParent(addrName);
//				addrName.getChildren().add(item1);
//				childrenOfAddress.remove();
//			}
//			createContactData(childrenOfAddress, primaryPhone, item1, BTRTMapping.PRIMARY_PHONE.getCode(), "CMNM0001");
//			createContactData(childrenOfAddress, mobilePhone, item1, BTRTMapping.MOBILE_PHONE.getCode(), "CMNM0001");
//			createContactData(childrenOfAddress, fax, item1, BTRTMapping.FAX.getCode(), "CMNM0004");
//			createContactData(childrenOfAddress, email, item1, BTRTMapping.EMAIL.getCode(), "CMNM0002");
//		}
//		//make relationship between address_name and address
//		addNodeAtoNodeB(addrName, address);
//		
//		return addrName;
//	}
	
	private NodeItem refactorAddress(NodeItem address, Map<String, NodeItem> contactDatas) {
		Iterator<NodeItem> childrenOfAddress = address.getChildren().iterator();
		NodeItem addrName = new NodeItem(BTRTMapping.ADDRESS_NAME.getCode(), null); 
		while(childrenOfAddress.hasNext()) {
			NodeItem item1 = childrenOfAddress.next();
			if (BTRTMapping.REGION.getCode().equals(item1.getName())
				|| BTRTMapping.CITY.getCode().equals(item1.getName())
				|| BTRTMapping.STREET.getCode().equals(item1.getName())) {
				//make relationship between item1 and addrName then remove
				item1.setParent(addrName);
				addrName.getChildren().add(item1);
				childrenOfAddress.remove();
			}
			
			for (String item : contactDatas.keySet()) {
				if (item.equals(BTRTMapping.PRIMARY_PHONE.toString())) {
					createContactData(childrenOfAddress, contactDatas.get(item), item1, BTRTMapping.PRIMARY_PHONE.getCode(), "CMNM0003");
				} else if (item.equals(BTRTMapping.SECONDARY_PHONE.toString())) {
					createContactData(childrenOfAddress, contactDatas.get(item), item1, BTRTMapping.SECONDARY_PHONE.getCode(), "CMNM0005");
				} else if (item.equals(BTRTMapping.MOBILE_PHONE.toString())) {
					createContactData(childrenOfAddress, contactDatas.get(item), item1, BTRTMapping.MOBILE_PHONE.getCode(), "CMNM0001");
				} else if (item.equals(BTRTMapping.FAX.toString())) {
					createContactData(childrenOfAddress, contactDatas.get(item), item1, BTRTMapping.FAX.getCode(), "CMNM0004");
				} else if (item.equals(BTRTMapping.EMAIL.toString())) {
					createContactData(childrenOfAddress,  contactDatas.get(item), item1, BTRTMapping.EMAIL.getCode(), "CMNM0002");
				}
			}
		}
		//make relationship between address_name and address
		addNodeAtoNodeB(addrName, address);
		
		return addrName;
	}
	
	/**
	 * Refactor contact block - used for card/account app.
	 * @param contactInformation
	 * @param customer
	 */
	private void refactorContact(NodeItem contactInformation, NodeItem customer) {
		List<NodeItem> childrenOfContact = contactInformation.getChildren();
		NodeItem person = null;
		NodeItem address = null;
		NodeItem secWord1 = new NodeItem(BTRTMapping.SEC_WORD.getCode(), null);
		NodeItem secWord2 = new NodeItem(BTRTMapping.SEC_WORD.getCode(), null);
		NodeItem secWord3 = new NodeItem(BTRTMapping.SEC_WORD.getCode(), null);
		NodeItem secWord4 = new NodeItem(BTRTMapping.SEC_WORD.getCode(), null);
		NodeItem secWord5 = new NodeItem(BTRTMapping.SEC_WORD.getCode(), null);
		
		NodeItem primaryPhone = new NodeItem(BTRTMapping.CONTACT_DATA.getCode(), null);
		NodeItem secondaryPhone = new NodeItem(BTRTMapping.CONTACT_DATA.getCode(), null);
		NodeItem mobilePhone = new NodeItem(BTRTMapping.CONTACT_DATA.getCode(), null);
		NodeItem fax = new NodeItem(BTRTMapping.CONTACT_DATA.getCode(), null);
		NodeItem email = new NodeItem(BTRTMapping.CONTACT_DATA.getCode(), null);
		
		NodeItem personName = null;
		NodeItem addressName = null;
		
		for (NodeItem item : childrenOfContact) {
			if (BTRTMapping.PERSON.getCode().equals(item.getName())) {
				person = item;
				personName = refactorPerson(item, secWord1, secWord2, secWord3, secWord4, secWord5);
			}
			if (BTRTMapping.ADDRESS.getCode().equals(item.getName())) {
				address = item;
				Map<String, NodeItem> contactDatas = new HashMap<String, NodeItem>();
			    contactDatas.put(BTRTMapping.PRIMARY_PHONE.toString(), primaryPhone);
			    contactDatas.put(BTRTMapping.SECONDARY_PHONE.toString(), secondaryPhone);
			    contactDatas.put(BTRTMapping.MOBILE_PHONE.toString(), mobilePhone);
			    contactDatas.put(BTRTMapping.FAX.toString(), fax);
			    contactDatas.put(BTRTMapping.EMAIL.toString(), email);
				addressName = refactorAddress(item, contactDatas);
			}
		}
		if (person != null && address != null) {
			addressName.setLang(personName.getLang());
		}
		
		//add person, address into customer
		if (person != null) {
			childrenOfContact.remove(person);
			addNodeIntoNode(person, customer);
		}
		if (address != null) {
			childrenOfContact.remove(address);
			addNodeIntoNode(address, customer);
		}
		
		//add sec_word into Customer
		addNodeAtoNodeB(secWord1, customer);
		addNodeAtoNodeB(secWord2, customer);
		addNodeAtoNodeB(secWord3, customer);
		addNodeAtoNodeB(secWord4, customer);
		addNodeAtoNodeB(secWord5, customer);
		
		//add contact_data into CUSTOMER/CONTACT
		addNodeAtoNodeB(primaryPhone, contactInformation);
		addNodeAtoNodeB(secondaryPhone, contactInformation);
		addNodeAtoNodeB(mobilePhone, contactInformation);
		addNodeAtoNodeB(fax, contactInformation);
		addNodeAtoNodeB(email, contactInformation);

		addNodeAtoNodeB(contactInformation, customer);
	}
	
	/**
	 * Refactor contact block - used for merchant app.
	 * @param contactInformation
	 * @param merchant
	 */
	private void refactorMerchantContact(NodeItem contactInformation, NodeItem merchant) {
		List<NodeItem> childrenOfContact = contactInformation.getChildren();
		NodeItem address = null;
		NodeItem personAddress = null;
		
		NodeItem primaryPhone = new NodeItem(BTRTMapping.CONTACT_DATA.getCode(), null);
		NodeItem mobilePhone = new NodeItem(BTRTMapping.CONTACT_DATA.getCode(), null);
		NodeItem fax = new NodeItem(BTRTMapping.CONTACT_DATA.getCode(), null);
		NodeItem email = new NodeItem(BTRTMapping.CONTACT_DATA.getCode(), null);
		
		NodeItem primaryPhone1 = new NodeItem(BTRTMapping.CONTACT_DATA.getCode(), null);
		NodeItem mobilePhone1 = new NodeItem(BTRTMapping.CONTACT_DATA.getCode(), null);
		NodeItem fax1 = new NodeItem(BTRTMapping.CONTACT_DATA.getCode(), null);
		NodeItem email1 = new NodeItem(BTRTMapping.CONTACT_DATA.getCode(), null);
		
		for (NodeItem item : childrenOfContact) {
			if (BTRTMapping.PERSON.getCode().equals(item.getName())) {
				Iterator<NodeItem> childrenOfPerson = item.getChildren().iterator();
				NodeItem personName = new NodeItem(BTRTMapping.PERSON_NAME.getCode(), null); 
				NodeItem identityCard = new NodeItem(BTRTMapping.IDENTITY_CARD.getCode(), null);
				while(childrenOfPerson.hasNext()) {
					NodeItem item1 = childrenOfPerson.next();
					if (BTRTMapping.FIRST_NAME.getCode().equals(item1.getName())
						|| BTRTMapping.SURNAME.getCode().equals(item1.getName())
						|| BTRTMapping.SECOND_NAME.getCode().equals(item1.getName())) {
						//make relationship between item1 and person name then remove
						item1.setParent(personName);
						personName.getChildren().add(item1);
						childrenOfPerson.remove();
					}
					if (BTRTMapping.ID_TYPE.getCode().equals(item1.getName())
						|| BTRTMapping.ID_EXPIRE_DATE.getCode().equals(item1.getName())
						|| BTRTMapping.ID_ISSUE_DATE.getCode().equals(item1.getName())
						|| BTRTMapping.ID_ISSUER.getCode().equals(item1.getName())
						|| BTRTMapping.ID_NUMBER.getCode().equals(item1.getName())
						|| BTRTMapping.ID_SERIES.getCode().equals(item1.getName())) {
						//make relationship between item1 and identity card then remove
						item1.setParent(identityCard);
						identityCard.getChildren().add(item1);
						childrenOfPerson.remove();
					}
					
					if (BTRTMapping.ADDRESS.getCode().equals(item1.getName())) {
						personAddress = item1;
						Map<String, NodeItem> contactDatas = new HashMap<String, NodeItem>();
					    contactDatas.put(BTRTMapping.PRIMARY_PHONE.toString(), primaryPhone);
					    contactDatas.put(BTRTMapping.MOBILE_PHONE.toString(), mobilePhone);
					    contactDatas.put(BTRTMapping.FAX.toString(), fax);
					    contactDatas.put(BTRTMapping.EMAIL.toString(), email);
						refactorAddress(item1, contactDatas);
						childrenOfPerson.remove();
					}
					
				}
				//make relationship between person_name and person
				addNodeAtoNodeB(personName, item);
				//make relationship between identity_card and person
				addNodeAtoNodeB(identityCard, item);
			}
			if (BTRTMapping.ADDRESS.getCode().equals(item.getName())) {
				address = item;
				Map<String, NodeItem> contactDatas = new HashMap<String, NodeItem>();
			    contactDatas.put(BTRTMapping.PRIMARY_PHONE.toString(), primaryPhone1);
			    contactDatas.put(BTRTMapping.MOBILE_PHONE.toString(), mobilePhone1);
			    contactDatas.put(BTRTMapping.FAX.toString(), fax1);
			    contactDatas.put(BTRTMapping.EMAIL.toString(), email1);
				refactorAddress(item, contactDatas);
			}
		}
		
		addNodeIntoNode(contactInformation, merchant);
		
		if (address != null) {
			childrenOfContact.remove(address);
			addNodeIntoNode(address, merchant);
		}

		if (personAddress != null) {
			addNodeIntoNode(personAddress, contactInformation);
		}
		
		addNodeIntoNode(mobilePhone, contactInformation);
		addNodeIntoNode(fax, contactInformation);
		addNodeIntoNode(email, contactInformation);
		addNodeIntoNode(mobilePhone1, contactInformation);
		addNodeIntoNode(fax1, contactInformation);
		addNodeIntoNode(email1, contactInformation);
	}
	
	/**
	 * Add node into node - process duplicate case
	 * @param child
	 * @param parent
	 */
	private void addNodeIntoNode(NodeItem child, NodeItem parent) {
		Iterator<NodeItem> childrenOfParent = parent.getChildren().iterator();
		boolean isExist = false;
		while(childrenOfParent.hasNext()) {
			NodeItem item = childrenOfParent.next();
			if (item.getName().equals(child.getName())) {
				isExist = true;
				//merge 2 nodes
				for (NodeItem item1 : child.getChildren()) {
					item1.setParent(item);
				}
				item.getChildren().addAll(child.getChildren());
				break;
			}
		}
		if (!isExist) {
			addNodeAtoNodeB(child, parent);
		}
	}
	
	/**
	 * Create contact data block.
	 * @param childrenOfAddress
	 * @param contacData
	 * @param item1
	 * @param contactDataCode
	 * @param communMethodStr
	 */
	private void createContactData(Iterator<NodeItem> childrenOfAddress, NodeItem contacData, NodeItem item1, String contactDataCode, String communMethodStr) {
		if (contactDataCode.equals(item1.getName())) {
			NodeItem communMethod = new NodeItem(BTRTMapping.COMMUN_METHOD.getCode(), communMethodStr);
			//add communMethod to contactData 
			contacData.getChildren().add(communMethod);
			communMethod.setParent(contacData);
			NodeItem communAddr = new NodeItem(BTRTMapping.COMMUN_ADDRESS.getCode(), item1.getData());
			//add communAddr to contactData
			contacData.getChildren().add(communAddr);
			communAddr.setParent(contacData);
			//then remove this node
			childrenOfAddress.remove();
			
		}
	}
	/**
	 * Create SEC_WORD block.
	 * @param childrenOfPerson
	 * @param secWord empty sec_word
	 * @param node
	 * @param securityIdCode
	 * @param securityQuestionCode
	 */
	private void createSecWord(Iterator<NodeItem> childrenOfPerson, NodeItem secWord, NodeItem node, String securityIdCode, String securityQuestionCode) {
		secWord.setLang(LANG_CONSTANT);
		if (securityQuestionCode.equals(node.getName())) {
			//then remove
			childrenOfPerson.remove();
			//change name 
			node.setName(BTRTMapping.SECRET_QUESTION.getCode());
			//make relationship with secWord1
			node.setParent(secWord);
			secWord.getChildren().add(node);
		}
		if (securityIdCode.equals(node.getName())) {
			//remove first
			childrenOfPerson.remove();
			//change name 
			node.setName(BTRTMapping.SECRET_ANSWER.getCode());
			//make relationship with secWord1
			node.setParent(secWord);
			secWord.getChildren().add(node);
		}
	}
	
	/**
	 * Create SEC_WORD without question.
	 * @param childrenOfPerson
	 * @param secWord
	 * @param node
	 * @param securityIdCode
	 */
	private void createHalfSecWord(Iterator<NodeItem> childrenOfPerson, NodeItem secWord, NodeItem node, String securityIdCode) {
		secWord.setLang(LANG_CONSTANT);
		if (securityIdCode.equals(node.getName())) {
			//remove first
			childrenOfPerson.remove();
			
			//change name 
			NodeItem question = new NodeItem(BTRTMapping.SECRET_QUESTION.getCode(), "SEQUWORD");
			//make relationship with secWord1
			question.setParent(secWord);
			secWord.getChildren().add(question);
			
			//change name 
			node.setName(BTRTMapping.SECRET_ANSWER.getCode());
			//make relationship with secWord1
			node.setParent(secWord);
			secWord.getChildren().add(node);
			
		}
	}
	/**
	 * Refactor card/account application.
	 * @param application
	 */
	private void refactorCardAccApp(NodeItem application) {
		NodeItem customer = null;
		NodeItem contract = new NodeItem(BTRTMapping.CONTRACT.getCode(), null);
		NodeItem cardHolder = null;
		
		Iterator<NodeItem> childrenOfApp = application.getChildren().iterator();
		while (childrenOfApp.hasNext()) {
			NodeItem node = childrenOfApp.next();
			// find customer node because customer is always above card, account 
			if(BTRTMapping.CUSTOMER.getCode().equals(node.getName())) {
				//move document block of customer
				moveDocumentBlock(node);
				refactorParamBlock(node);
				customer = node;
			}
			//find cardholder block and remove
			if (BTRTMapping.CARDHOLDER.getCode().equals(node.getName())) {
				cardHolder = node;
				childrenOfApp.remove();
			}
			//find card or account block
			if(BTRTMapping.CARD.getCode().equals(node.getName())) {
				NodeItem secWord = new NodeItem(BTRTMapping.SEC_WORD.getCode(), null);
				List<NodeItem> childrenOfCard = node.getChildren();
				List<NodeItem> temp = new ArrayList<NodeItem>();
				//just keep the first sequence
				temp.add(childrenOfCard.get(0));
				for (NodeItem child : childrenOfCard) {
					if (!BTRTMapping.SEQUENCE.getCode().equals(child.getName())) {
						Iterator<NodeItem> chitList = child.getChildren().iterator();
						while (chitList.hasNext()) {
							NodeItem child1 = chitList.next();
							if (BTRTMapping.CARDHOLDER_NAME.getCode().equals(child1.getName())) {
								chitList.remove();
								//add cardHolderName into cardHolder
								cardHolder.getChildren().add(child1);
								child1.setParent(cardHolder);
							} else if (BTRTMapping.CARD_TYPE.getCode().equals(child1.getName())) {
								String convertedValue = "";
								if (appDao != null) {
									convertedValue = appDao.getArrayConvertedValue(userSessionId, CARD_TYPE_ARR_TYPE, child1.getData());
								}
								if (!convertedValue.isEmpty()) {
									child1.setData(convertedValue);
									currentNode.getSubDatas().put(CARD_TYPE_ID, convertedValue);
								}
//								currentNode.getSubDatas().put(CARD_TYPE, child1.getData());
								temp.add(child1);
								child1.setParent(node);
							} else if (BTRTMapping.EMBOSSED_NAME.getCode().equals(child1.getName())
									|| BTRTMapping.COMPANY_NAME.getCode().equals(child1.getName())) {
								BTRTUtils.addSimpleNodeToNode(child1, companyNode);
							} else if (BTRTMapping.EXPRESS_FLAG.getCode().equals(child1.getName())) {
								if (serviceObject == null) {//initialization
									NodeItem serviceNode = new NodeItem(BTRTMapping.SERVICE.getCode(), null);
									serviceObject = new NodeItem(BTRTMapping.SERVICE_OBJECT.getCode(), null);
									BTRTUtils.addSimpleNodeToNode(serviceObject, serviceNode);
									BTRTUtils.addSimpleNodeToNode(serviceNode, contract);
								}
								NodeItem attributeChar = new NodeItem(BTRTMapping.ATTRIBUTE_CHAR.getCode(), "60000123");
								BTRTUtils.addSimpleNodeToNode(attributeChar, serviceObject);
								
								NodeItem attributeValueChar = new NodeItem(BTRTMapping.ATTRIBUTE_VALUE_CHAR.getCode(), child1.getData());
								BTRTUtils.addSimpleNodeToNode(attributeValueChar, attributeChar);	
							} else if (BTRTMapping.SECURITY_ID_1.getCode().equals(child1.getName())) {
								createHalfSecWord(chitList, secWord, child1, BTRTMapping.SECURITY_ID_1.getCode());
							} else if (!BTRTMapping.SEQUENCE.getCode().equals(child1.getName())) {
								//transform into 2-level structure 
								temp.add(child1);
								child1.setParent(node);
							}
							
						}
						
						addNodeAtoNodeB(companyNode, customer);
					}
				}
				node.setChildren(temp);
				
				//make relationship between contract and card/account
				childrenOfApp.remove();//remove card/acc
				addNodeAtoNodeB(node, contract);
				
				addNodeAtoNodeB(cardHolder, node);
				if (cardHolder != null) refactorCardHolder(cardHolder);
				
				//add sec_word into card
				addNodeAtoNodeB(secWord, node);
				
				createServiceLinkCardObject(contract);
				
			}
			
			if (BTRTMapping.ACCOUNT.getCode().equals(node.getName())) {
				refactorAccount(node);
				
				//make relationship between contract and card/account
				childrenOfApp.remove();//remove card/acc
				addNodeAtoNodeB(node, contract);
				
				createServiceLinkAccObject(contract);
//				addNodeAtoNodeB(serviceNode, contract);
			}
			
		}
		
		BTRTUtils.addSimpleNodeToNode(productIdNode, contract);
		//make relationship between customer and contract
		addNodeAtoNodeB(contract, customer);
	}
	
	/**
	 * Create document block and insert into customer block.
	 * @param customer
	 */
	private void moveDocumentBlock(NodeItem customer) {
		List<NodeItem> childrenOfCustomer = customer.getChildren();
		NodeItem identityCard = null;
		NodeItem inn = null;
		NodeItem kpp = null;
		NodeItem okpo = null;
		NodeItem idCard1 = null;
		NodeItem idCard2 = null;
		NodeItem idCard3 = null;
		for (NodeItem item : childrenOfCustomer) {
			if (BTRTMapping.IDENTITY_CARD.getCode().equals(item.getName())) {
				identityCard = item;
			}
			if (BTRTMapping.INN.getCode().equals(item.getName())) {
				inn = item;
				// INN BLOCK
				idCard3 = new NodeItem(BTRTMapping.IDENTITY_CARD.getCode(), null);
				
				NodeItem innType = new NodeItem(BTRTMapping.ID_TYPE.getCode(), "INN");
				BTRTUtils.addSimpleNodeToNode(innType, idCard3);
				
				NodeItem innValue = new NodeItem(BTRTMapping.ID_NUMBER.getCode(), item.getData());
				BTRTUtils.addSimpleNodeToNode(innValue, idCard3);
			}
			if (BTRTMapping.KPP.getCode().equals(item.getName())) {
				kpp = item; 
				idCard1 = new NodeItem(BTRTMapping.IDENTITY_CARD.getCode(), null);
				
				NodeItem kppType = new NodeItem(BTRTMapping.ID_TYPE.getCode(), "KPP");
				BTRTUtils.addSimpleNodeToNode(kppType, idCard1);
				
				NodeItem kppValue = new NodeItem(BTRTMapping.ID_NUMBER.getCode(), item.getData());
				BTRTUtils.addSimpleNodeToNode(kppValue, idCard1);
			}
			if (BTRTMapping.OKPO.getCode().equals(item.getName())) {
				okpo = item;
				idCard2 = new NodeItem(BTRTMapping.IDENTITY_CARD.getCode(), null);
				
				NodeItem okpoType = new NodeItem(BTRTMapping.ID_TYPE.getCode(), "OKPO");
				BTRTUtils.addSimpleNodeToNode(okpoType, idCard2);
				
				NodeItem okpoValue = new NodeItem(BTRTMapping.ID_NUMBER.getCode(), item.getData());
				BTRTUtils.addSimpleNodeToNode(okpoValue, idCard2);
			}
		}
		NodeItem person = new NodeItem(BTRTMapping.PERSON.getCode(), null);
		if (identityCard != null) {
			//remove identity_card
			childrenOfCustomer.remove(identityCard);
			
			// add identity_card into person 
			BTRTUtils.addSimpleNodeToNode(identityCard, person);
		}
		companyNode = new NodeItem(BTRTMapping.COMPANY.getCode(), null);
		if (idCard3 != null) {
			childrenOfCustomer.remove(inn);
			BTRTUtils.addSimpleNodeToNode(idCard3, companyNode);
		}
		if (idCard1 != null) {
			childrenOfCustomer.remove(kpp);
			BTRTUtils.addSimpleNodeToNode(idCard1, companyNode);
		}
		if (idCard2 != null) {
			childrenOfCustomer.remove(okpo);
			BTRTUtils.addSimpleNodeToNode(idCard2, companyNode);
		}
		if (person.getChildren() != null && !person.getChildren().isEmpty()) {
			//add person into customer
			BTRTUtils.addSimpleNodeToNode(person, customer);
		}
		if (companyNode.getChildren() != null && !companyNode.getChildren().isEmpty()) {
			//add company into customer
			BTRTUtils.addSimpleNodeToNode(companyNode, customer);
		}
	}
	
	private void refactorParamBlock(NodeItem customer) {
		List<NodeItem> childrenOfCustomer = customer.getChildren();
		NodeItem additionalParamBlock = null;
		NodeItem ownershipType = null;
		NodeItem parentCustomer = null;
		for (NodeItem item : childrenOfCustomer) {
			if (BTRTMapping.ADDITIONAL_PARAMETERS_BLOCK.getCode().equals(item.getName())) {
				additionalParamBlock = item;
			}
		}
		if (additionalParamBlock != null) {
			//remove identity_card
			childrenOfCustomer.remove(additionalParamBlock);
			
			// extract ownership_type and parent_customer then insert into customer 
			List<NodeItem> childrenOfAddParamBlock = additionalParamBlock.getChildren();
			for (NodeItem item : childrenOfAddParamBlock) {
				if (BTRTMapping.PARAMETER.getCode().equals(item.getName())) {
					List<NodeItem> childrenOfParamBlock = item.getChildren();
					boolean isOwnershipType = false;
					for (NodeItem item1 : childrenOfParamBlock) {
						if (BTRTMapping.PARAMETER_NAME.getCode().equals(item1.getName())) {
							if (BTRTMapping.OWNERSHIP_TYPE.toString().equalsIgnoreCase(item1.getData())) {
								isOwnershipType = true;
							} else {
								isOwnershipType = false;
							}
						}
						if (BTRTMapping.PARAMETER_VALUE.getCode().equals(item1.getName())) {
							if (isOwnershipType) {
								ownershipType = new NodeItem(BTRTMapping.OWNERSHIP_TYPE.getCode(), item1.getData());
								BTRTUtils.addSimpleNodeToNode(ownershipType, customer);
							} else {
								parentCustomer = new NodeItem(BTRTMapping.PARENT_CUSTOMER.getCode(), item1.getData());
								BTRTUtils.addSimpleNodeToNode(parentCustomer, customer);
							}
						}
					}
				}
			}
			
		}
	}
	
	/**
	 * Write output to console.
	 * @param node
	 * @param spaces
	 */
	public void writeOutputToConsole(NodeItem node, String spaces) {
		System.out.println(spaces + node.getName() + "-" + BTRTMapping.get(node.getName()) + "(" + node.getLength() + ")" + "=" + node.getData());
		spaces += "    ";
		for (NodeItem ni : node.getChildren()) {
			writeOutputToConsole(ni, spaces);
		}
    }

	/**
	 * Refactor and move contact block to customer. 
	 * @param application
	 */
	private void moveContactBlockToCustomer(NodeItem application) {
		List<NodeItem> nodeList = application.getChildren();
		NodeItem customer = null;
		NodeItem contact = null;
		for (NodeItem node : nodeList) {
			if (BTRTMapping.CUSTOMER.getCode().equals(node.getName())) {
				customer = node;
			}
			if (BTRTMapping.CONTACT.getCode().equals(node.getName())) {
				contact = node;
			}
		}
		
		if (customer != null && contact != null) {
			nodeList.remove(contact);
			//refactor contact node
			refactorContact(contact, customer);
		}
	}
	
	/**
	 * Refactor and move contact block to merchant. 
	 * @param application
	 */
	private void moveContactBlockToMerchant(NodeItem application) {
		List<NodeItem> nodeList = application.getChildren();
		NodeItem merchant = null;
		NodeItem contact = null;
		for (NodeItem node : nodeList) {
			if (BTRTMapping.MERCHANT_BRANCH.getCode().equals(node.getName())) {
				merchant = node.getChildren().get(0);//skip the first item - sequence
			}
			if (BTRTMapping.CONTACT.getCode().equals(node.getName())) {
				contact = node;
			}
		}
		
		if (merchant != null && contact != null) {
			nodeList.remove(contact);
			
			//refactor contact node
			refactorMerchantContact(contact, merchant);
		}
	}
	
	/**
	 * Used for reading BTRT format file. 
	 * @param input
	 * @param parentNode
	 * @return
	 */
	private NodeItem createNode(String input, NodeItem parentNode) {
		if ("".equals(input)) {
			return null;
		}

		NodeItem node = new NodeItem();
		node.setParent(parentNode);
		if (parentNode != null) {
			parentNode.getChildren().add(node);
		}
		// read a line to create a Tree object
		int start = 0, end = 0;
		for (int i = 0; i < MAX_NAME_LENGTH + MAX_LENGTH_LENGTH; i++) {
			String s = input.substring(end, end + 2);
			end += 2;
			if (hexToBin(s).charAt(0) == '0' || ((node.getName() == null) && (end - start == MAX_NAME_LENGTH * 2))
			        || ((null != node.getName()) && (end - start == MAX_LENGTH_LENGTH * 2))) {
				String value = input.substring(start, end);
				start = end;

				if (node.getName() == null) {
					node.setName(value);
				} else {
					node.setLength(computeLength(value));
					// if node has no data
					if (node.getName().startsWith("FF")) {
						createNode(input.substring(start, start + node.getLength()), node);
						createNode(input.substring(start + node.getLength()), parentNode);
					} else {
						end = start + node.getLength();
						node.setData(input.substring(start, end));
						createNode(input.substring(end), parentNode);
					}
					break;
				}
			}
		}

		return node;
	}
	
	/**
	 * Calculate length of block - used for reading BTRT format file. 
	 * @param length
	 * @return
	 */
	private int computeLength(String length) {
		if ("".equals(length)) {
			return 0;
		}
		String firstChar = length.charAt(0) + "";
		int firstCharValue = hexToDec(firstChar);
		int result = hexToDec(length);
		return (firstCharValue > 7) ? (result - TRANSFORMING_DECIMAL) : result;
	}
	
	/**
	 * Convert hexa to binary.
	 * @param userInput
	 * @return
	 */
	public static String hexToBin(String userInput) {
		String result = "";
		for (int i = 0; i < userInput.length(); i++) {
			char temp = userInput.charAt(i);
			String temp2 = "" + temp + "";
			for (int j = 0; j < HEX.length; j++) {
				if (temp2.equalsIgnoreCase(HEX[j])) {
					result = result + BINARY[j];
				}
			}
		}
		return result;
	}

	/**
	 * Convert hexa to decimal.
	 * @param input
	 * @return
	 */
	public static int hexToDec(String input) {
		return Integer.parseInt(input, 16);
	}

	public void setAppDao(ApplicationDao appDao) {
		this.appDao = appDao;
	}

	public void setUserSessionId(Long userSessionId) {
		this.userSessionId = userSessionId;
	}
	
}
