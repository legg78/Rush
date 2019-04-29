package ru.bpc.sv2.ui.common.wizard.application;

import ru.bpc.sv2.accounts.Account;
import ru.bpc.sv2.application.Application;
import ru.bpc.sv2.application.ApplicationElement;
import ru.bpc.sv2.application.ApplicationFlowFilter;
import ru.bpc.sv2.common.application.ApplicationStatuses;
import ru.bpc.sv2.constants.EntityNames;
import ru.bpc.sv2.constants.application.AppElements;
import ru.bpc.sv2.constants.application.ApplicationConstants;
import ru.bpc.sv2.dsp.DisputeParameter;
import ru.bpc.sv2.issuing.Card;
import ru.bpc.sv2.issuing.ReissueReason;
import ru.bpc.sv2.logic.ApplicationDao;
import ru.bpc.sv2.operations.Operation;
import ru.bpc.sv2.operations.Participant;
import ru.bpc.sv2.svng.AupTag;
import ru.bpc.sv2.ui.session.UserSession;
import ru.bpc.sv2.utils.AppStructureUtils;
import util.auxil.ManagedBeanWrapper;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.concurrent.atomic.AtomicInteger;

public final class ApplicationBuilder {
	private static final int VISA_NETWORK_ID = 1003;
	private static final int MC_NETWORK_ID = 1002;

	private ApplicationDao applicationDao;
	private Long userSessionId;
	private int instId;
	private int flowId;
	private Application app;
	private ApplicationElement root;
	private AtomicInteger appObjectSeqNum;
	private boolean skipProcessing;
	private String applicationType;

	public ApplicationBuilder(ApplicationDao applicationDao, Long userSessionId, int instId, int flowId, String applicationType) {
		init(applicationDao, userSessionId, instId, flowId, false, applicationType);
	}

	public ApplicationBuilder(ApplicationDao applicationDao, Long userSessionId, int instId, int flowId) {
		init(applicationDao, userSessionId, instId, flowId, false, ApplicationConstants.TYPE_FIN_REQUEST);
	}

    public ApplicationBuilder(ApplicationDao applicationDao, Long userSessionId, int instId, int flowId, boolean skipProcessing) {
        init(applicationDao, userSessionId, instId, flowId, skipProcessing, ApplicationConstants.TYPE_FIN_REQUEST);
    }

    private void init(ApplicationDao applicationDao, Long userSessionId, int instId, int flowId, boolean skipProcessing, String applicationType) {
        this.applicationDao = applicationDao;
        this.userSessionId = userSessionId;
        this.instId = instId;
        this.flowId = flowId;
        this.skipProcessing = skipProcessing;
        this.applicationType = applicationType;
    }

	public void createAppAndRoot() {
		app = new Application();
		app.setAppType(applicationType);
		app.setFlowId(flowId);
		if (ApplicationConstants.TYPE_FIN_REQUEST.equals(applicationType)) {
			app.setStatus(ApplicationStatuses.READY_FOR_REVIEW);
		} else {
			app.setStatus(ApplicationStatuses.JUST_CREATED);
		}
		app.setNewStatus(app.getStatus());
		app.setInstId(instId);
        app.setSkipProcessing(skipProcessing);
		root = applicationDao.getApplicationStructure(userSessionId, app, new HashMap<Integer, ApplicationFlowFilter>());

		AppStructureUtils.setValue(root, AppElements.APPLICATION_FLOW_ID, flowId);
		AppStructureUtils.setValue(root, AppElements.APPLICATION_STATUS, app.getStatus());
		AppStructureUtils.setValue(root, AppElements.APPLICATION_TYPE, app.getAppType());
		appObjectSeqNum = new AtomicInteger(1);
	}

	public void buildFromOperation(ru.bpc.sv2.operations.incoming.Operation selectedOperation, boolean addParticipant) {
		createAppAndRoot();
		app.setCardNumber(selectedOperation.getCardNumber());
		app.setAccountNumber(selectedOperation.getAccountNumber());
		AppStructureUtils.setValue(root, AppElements.OPER_REASON, selectedOperation.getOperReason());

		ApplicationElement oper = root.getChildByName(AppElements.OPERATION, 1);
		if (oper != null) {
			AppStructureUtils.setValue(oper, AppElements.SESSION_ID, selectedOperation.getSessionId() == null ? userSessionId : selectedOperation.getSessionId());
            AppStructureUtils.setValue(oper, AppElements.SESSION_FILE_ID, selectedOperation.getSessionFileId());
			AppStructureUtils.setValue(oper, AppElements.OPERATION_ID, selectedOperation.getId());
			AppStructureUtils.setValue(oper, AppElements.OPERATION_TYPE, selectedOperation.getOperType());
			AppStructureUtils.setValue(oper, AppElements.MESSAGE_TYPE, selectedOperation.getMsgType());
			AppStructureUtils.setValue(oper, AppElements.STTL_TYPE, selectedOperation.getSttlType());
			AppStructureUtils.setValue(oper, AppElements.OPER_STATUS, selectedOperation.getStatus());
			AppStructureUtils.setValue(oper, AppElements.OPER_AMOUNT, selectedOperation.getOperationAmount());
			AppStructureUtils.setValue(oper, AppElements.OPER_CURRENCY, selectedOperation.getOperationCurrency());
			AppStructureUtils.setValue(oper, AppElements.OPER_DATE, selectedOperation.getOperationDate());
			AppStructureUtils.setValue(oper, AppElements.OPER_REASON, selectedOperation.getOperReason());
			AppStructureUtils.setValue(oper, AppElements.HOST_DATE, selectedOperation.getSourceHostDate());
			AppStructureUtils.setValue(oper, AppElements.IS_REVERSAL, selectedOperation.isReversal());
			AppStructureUtils.setValue(oper, AppElements.MERCHANT_NAME, selectedOperation.getMerchantName());
			AppStructureUtils.setValue(oper, AppElements.MERCHANT_NUMBER, selectedOperation.getMerchantNumber());
			AppStructureUtils.setValue(oper, AppElements.MERCHANT_CITY, selectedOperation.getMerchantCity());
			AppStructureUtils.setValue(oper, AppElements.MERCHANT_COUNTRY, selectedOperation.getMerchantCountryCode());
			AppStructureUtils.setValue(oper, AppElements.MERCHANT_POSTCODE, selectedOperation.getMerchantPostCode());
			AppStructureUtils.setValue(oper, AppElements.MERCHANT_REGION, selectedOperation.getMerchantRegion());
			AppStructureUtils.setValue(oper, AppElements.MERCHANT_STREET, selectedOperation.getMerchantStreet());
			AppStructureUtils.setValue(oper, AppElements.ORIGINAL_ID, selectedOperation.getOriginalId());
			AppStructureUtils.setValue(oper, AppElements.STATUS_REASON, selectedOperation.getStatusReason());
			AppStructureUtils.setValue(oper, AppElements.TERMINAL_NUMBER, selectedOperation.getTerminalNumber());
			AppStructureUtils.setValue(oper, AppElements.FORW_INST_BIN, selectedOperation.getForwInstBin());
			AppStructureUtils.setValue(oper, AppElements.ACQUIRER_INST_BIN, selectedOperation.getAcqInstBin());
			AppStructureUtils.setValue(oper, AppElements.FORW_INST_BIN, selectedOperation.getForwInstBin());
			AppStructureUtils.setValue(oper, AppElements.MCC, selectedOperation.getMccCode());
			AppStructureUtils.setValue(oper, AppElements.ORIGINATOR_REFNUM, selectedOperation.getRefnum());
			AppStructureUtils.setValue(oper, AppElements.NETWORK_REFNUM, selectedOperation.getNetworkRefnum());
			AppStructureUtils.setValue(oper, AppElements.OPER_COUNT, selectedOperation.getOperCount());
			AppStructureUtils.setValue(oper, AppElements.OPER_REQUEST_AMOUNT, selectedOperation.getOperationRequestAmount());
			AppStructureUtils.setValue(oper, AppElements.OPER_CASHBACK_AMOUNT, selectedOperation.getOperationCashbackAmount());
			AppStructureUtils.setValue(oper, AppElements.OPER_REPLACEMENT_AMOUNT, selectedOperation.getOperationReplacementAmount());
			AppStructureUtils.setValue(oper, AppElements.OPER_SURCHARGE_AMOUNT, selectedOperation.getOperationSurchargeAmount());
			AppStructureUtils.setValue(oper, AppElements.MATCH_STATUS, selectedOperation.getMatchStatus());
			AppStructureUtils.setValue(oper, AppElements.STTL_AMOUNT, selectedOperation.getSttlAmount());
			AppStructureUtils.setValue(oper, AppElements.STTL_CURRENCY, selectedOperation.getSttlCurrency());
			AppStructureUtils.setValue(oper, AppElements.DISPUTE_ID, selectedOperation.getDisputeId());
            AppStructureUtils.setValue(oper, AppElements.MATCH_ID, selectedOperation.getMatchId());
            AppStructureUtils.setValue(oper, AppElements.COMMAND, selectedOperation.getCommand());
            AppStructureUtils.setValue(oper, AppElements.EXTERNAL_AUTH_ID, selectedOperation.getExternalAuthId());
            AppStructureUtils.setValue(oper, AppElements.OPER_STATUS_NEW, selectedOperation.getNewOperStatus());

			if (addParticipant) {
				fillParticipant(construct(AppElements.PARTICIPANT, oper, app), selectedOperation);
			}
		}
	}

	public void buildFromCard(Card selectedCard) {
		createAppAndRoot();
		app.setCustomerNumber(selectedCard.getCustomerNumber());
		app.setContractNumber(selectedCard.getContractNumber());
		app.setCardNumber(selectedCard.getCardNumber());

		UserSession userSession = (UserSession) ManagedBeanWrapper.getManagedBean("usession");

		AppStructureUtils.setValue(root, AppElements.APPLICATION_TYPE, applicationType);
		AppStructureUtils.setValue(root, AppElements.APPLICATION_FLOW_ID, flowId);
		AppStructureUtils.setValue(root, AppElements.OPERATOR_ID, userSession.getUserName());
		AppStructureUtils.setValue(root, AppElements.INSTITUTION_ID, selectedCard.getInstId());
		AppStructureUtils.setValue(root, AppElements.AGENT_ID, selectedCard.getAgentId());
		AppStructureUtils.setValue(root, AppElements.CUSTOMER_TYPE, selectedCard.getCustomerType());

		ApplicationElement customer = root.getChildByName(AppElements.CUSTOMER, 1);
		if (customer != null) {
			AppStructureUtils.setValue(customer, AppElements.CUSTOMER_NUMBER, selectedCard.getCustomerNumber());
			ApplicationElement contract = customer.getChildByName(AppElements.CONTRACT, 1);
			if (contract != null) {
				AppStructureUtils.setValue(contract, AppElements.CONTRACT_TYPE, selectedCard.getContractType());
				AppStructureUtils.setValue(contract, AppElements.PRODUCT_ID, selectedCard.getProductId());
				AppStructureUtils.setValue(contract, AppElements.CONTRACT_NUMBER, selectedCard.getContractNumber());
				ApplicationElement card = contract.getChildByName(AppElements.CARD, 1);
				if (card != null) {
					AppStructureUtils.setValue(card, AppElements.CARD_ID, selectedCard.getCardUid());
					AppStructureUtils.setValue(card, AppElements.CARD_NUMBER, selectedCard.getCardNumber());
					AppStructureUtils.setValue(card, AppElements.CARD_TYPE, selectedCard.getCardTypeId());
					AppStructureUtils.setValue(card, AppElements.CARD_CATEGORY, selectedCard.getCategory());
					ApplicationElement cardholder = card.getChildByName(AppElements.CARDHOLDER, 1);
					if (cardholder != null) {
						AppStructureUtils.setValue(cardholder, AppElements.CARDHOLDER_NUMBER, selectedCard.getCardholderNumber());
						AppStructureUtils.setValue(cardholder, AppElements.CARDHOLDER_NAME, selectedCard.getCardholderName());
					}
				}
			}
		}
	}

	public void fillReissueReason(ReissueReason reissueReason) {
		ApplicationElement card = root.getChildByName(AppElements.CUSTOMER, 1)
									  .getChildByName(AppElements.CONTRACT, 1)
									  .getChildByName(AppElements.CARD, 1);
		if (card != null) {
			AppStructureUtils.setValue(card, AppElements.REISSUE_REASON, reissueReason.getReissueReason());
			AppStructureUtils.setValue(card, AppElements.REISSUE_COMMAND, reissueReason.getReissueCommand());
			AppStructureUtils.setValue(card, AppElements.PIN_REQUEST, reissueReason.getPinRequest());
			AppStructureUtils.setValue(card, AppElements.PIN_MAILER_REQUEST, reissueReason.getPinMailerRequest());
			AppStructureUtils.setValue(card, AppElements.EMBOSSING_REQUEST, reissueReason.getEmbossingRequest());
			AppStructureUtils.setValue(card, AppElements.START_DATE_RULE, reissueReason.getReissStartDateRule());
			AppStructureUtils.setValue(card, AppElements.EXPIRATION_DATE_RULE, reissueReason.getReissExpirDateRule());
			AppStructureUtils.setValue(card, AppElements.PERSO_PRIORITY, reissueReason.getPersoPriority());

		}
	}

	public void addParticipant(ru.bpc.sv2.operations.incoming.Operation operation) {
        ApplicationElement oper = root.getChildByName(AppElements.OPERATION, 1);
        if (oper != null) {
            fillParticipant(construct(AppElements.PARTICIPANT, oper, app), operation);
        }
    }

    public void addList(String element, List<?> values) {
        ApplicationElement oper = root.getChildByName(AppElements.OPERATION, 1);
        if (oper != null) {
            for (Object value: values) {
                ApplicationElement el = construct(AppElements.LOYALTY_OPERATION_ID, oper, app);
                AppStructureUtils.setValue(el, value);
            }
        }
    }

	public void addAupTags(List<AupTag> tags) {
		if (tags == null || tags.isEmpty()) {
			return;
		}

		ApplicationElement oper = root.getChildByName(AppElements.OPERATION, 1);
		if (oper == null) return;

		ApplicationElement tagsElement = construct(AppElements.TAGS, oper, app);

		for (AupTag tag: tags) {

			ApplicationElement tagElement = construct(AppElements.AUP_TAG, tagsElement, app);

			AppStructureUtils.setValue(tagElement, AppElements.TAG, tag.getTagName());
			AppStructureUtils.setValue(tagElement, AppElements.TAG_VALUE, tag.getTagValue());
			AppStructureUtils.setValue(tagElement, AppElements.SEQ_NUMBER, tag.getSeqNumber());
		}
	}

	public void buildFromOperation(Operation selectedOperation, boolean addParticipants) {
		createAppAndRoot();
		app.setCardNumber(selectedOperation.getCardNumber());
		app.setAccountNumber(selectedOperation.getAccountNumber());
		AppStructureUtils.setValue(root, AppElements.OPER_REASON, selectedOperation.getOperReason());

		ApplicationElement oper = root.getChildByName(AppElements.OPERATION, 1);
		if (oper != null) {
            AppStructureUtils.setValue(oper, AppElements.SESSION_ID, selectedOperation.getSessionId() == null ? userSessionId : selectedOperation.getSessionId());
            AppStructureUtils.setValue(oper, AppElements.SESSION_FILE_ID, selectedOperation.getSessionFileId());
			AppStructureUtils.setValue(oper, AppElements.OPERATION_ID, selectedOperation.getId());
			AppStructureUtils.setValue(oper, AppElements.OPERATION_TYPE, selectedOperation.getOperType());
			AppStructureUtils.setValue(oper, AppElements.MESSAGE_TYPE, selectedOperation.getMsgType());
			AppStructureUtils.setValue(oper, AppElements.STTL_TYPE, selectedOperation.getSttlType());
			AppStructureUtils.setValue(oper, AppElements.OPER_STATUS, selectedOperation.getStatus());
			AppStructureUtils.setValue(oper, AppElements.OPER_AMOUNT, selectedOperation.getOperAmount());
			AppStructureUtils.setValue(oper, AppElements.OPER_CURRENCY, selectedOperation.getOperCurrency());
			AppStructureUtils.setValue(oper, AppElements.OPER_DATE, selectedOperation.getOperDate());
			AppStructureUtils.setValue(oper, AppElements.OPER_REASON, selectedOperation.getOperReason());
			AppStructureUtils.setValue(oper, AppElements.HOST_DATE, selectedOperation.getHostDate());
			AppStructureUtils.setValue(oper, AppElements.IS_REVERSAL, selectedOperation.getIsReversal());
			AppStructureUtils.setValue(oper, AppElements.FORCED_PROCESSING, selectedOperation.getForcedProcessing());
			AppStructureUtils.setValue(oper, AppElements.MERCHANT_NAME, selectedOperation.getMerchantName());
			AppStructureUtils.setValue(oper, AppElements.MERCHANT_NUMBER, selectedOperation.getMerchantNumber());
			AppStructureUtils.setValue(oper, AppElements.MERCHANT_CITY, selectedOperation.getMerchantCity());
			AppStructureUtils.setValue(oper, AppElements.MERCHANT_COUNTRY, selectedOperation.getMerchantCountry());
			AppStructureUtils.setValue(oper, AppElements.MERCHANT_POSTCODE, selectedOperation.getMerchantPostCode());
			AppStructureUtils.setValue(oper, AppElements.MERCHANT_REGION, selectedOperation.getMerchantRegion());
			AppStructureUtils.setValue(oper, AppElements.MERCHANT_STREET, selectedOperation.getMerchantStreet());
			AppStructureUtils.setValue(oper, AppElements.ORIGINAL_ID, selectedOperation.getOriginalId());
			AppStructureUtils.setValue(oper, AppElements.STATUS_REASON, selectedOperation.getStatusReason());
			AppStructureUtils.setValue(oper, AppElements.TERMINAL_NUMBER, selectedOperation.getTerminalNumber());
			AppStructureUtils.setValue(oper, AppElements.FORW_INST_BIN, selectedOperation.getForwInstBin());
			AppStructureUtils.setValue(oper, AppElements.ACQUIRER_INST_BIN, selectedOperation.getAcqInstBin());
			AppStructureUtils.setValue(oper, AppElements.FORW_INST_BIN, selectedOperation.getForwInstBin());
			AppStructureUtils.setValue(oper, AppElements.MCC, selectedOperation.getMccCode());
			AppStructureUtils.setValue(oper, AppElements.ORIGINATOR_REFNUM, selectedOperation.getOriginatorRefnum());
			AppStructureUtils.setValue(oper, AppElements.NETWORK_REFNUM, selectedOperation.getNetworkRefnum());
			AppStructureUtils.setValue(oper, AppElements.OPER_COUNT, selectedOperation.getOperCount());
			AppStructureUtils.setValue(oper, AppElements.OPER_REQUEST_AMOUNT, selectedOperation.getOperRequestAmount());
			AppStructureUtils.setValue(oper, AppElements.OPER_CASHBACK_AMOUNT, selectedOperation.getOperCashbackAmount());
			AppStructureUtils.setValue(oper, AppElements.OPER_REPLACEMENT_AMOUNT, selectedOperation.getOperReplacementAmount());
			AppStructureUtils.setValue(oper, AppElements.OPER_SURCHARGE_AMOUNT, selectedOperation.getOperSurchargeAmount());
			AppStructureUtils.setValue(oper, AppElements.MATCH_STATUS, selectedOperation.getMatchStatus());
			AppStructureUtils.setValue(oper, AppElements.STTL_AMOUNT, selectedOperation.getSttlAmount());
			AppStructureUtils.setValue(oper, AppElements.STTL_CURRENCY, selectedOperation.getSttlCurrency());
			AppStructureUtils.setValue(oper, AppElements.DISPUTE_ID, selectedOperation.getDisputeId());
            AppStructureUtils.setValue(oper, AppElements.MATCH_ID, selectedOperation.getMatchId());
            AppStructureUtils.setValue(oper, AppElements.COMMAND, selectedOperation.getCommand());
            AppStructureUtils.setValue(oper, AppElements.EXTERNAL_AUTH_ID, selectedOperation.getExternalAuthId());
            AppStructureUtils.setValue(oper, AppElements.OPER_STATUS_NEW, selectedOperation.getNewOperStatus());

			if (addParticipants) {
				if (selectedOperation.getParticipants() != null) {
					for (Participant participant : selectedOperation.getParticipants()) {
						fillParticipant(construct(AppElements.PARTICIPANT, oper, app), selectedOperation, participant);
					}
				}
			}
		}
	}

	public void buildFromDispute(int networkId, List<DisputeParameter> parameters) {
		buildFromDispute(networkId, parameters, null, false);
	}

	public void buildFromDispute(int networkId, List<DisputeParameter> parameters, Operation selectedOperation, boolean addParticipants) {
		createAppAndRoot();
		ApplicationElement fields = null;
		if (networkId == VISA_NETWORK_ID) {
			if (root.getChildByName(AppElements.BASEII_DATA, 1) == null) {
				root.addChildren(addBlock(root.getChildByName(AppElements.BASEII_DATA), app));
			}
			fields = root.getChildByName(AppElements.BASEII_DATA, 1);
		} else if (networkId == MC_NETWORK_ID) {
			if (root.getChildByName(AppElements.IPM_DATA, 1) == null) {
				root.addChildren(addBlock(root.getChildByName(AppElements.IPM_DATA), app));
			}
			fields = root.getChildByName(AppElements.IPM_DATA, 1);
		}
		if (fields != null && parameters != null) {
			for (DisputeParameter param : parameters) {
				AppStructureUtils.setValue(fields, param.getSystemName(), param.getValue());
			}
		}

		if (selectedOperation != null) {
			app.setCardNumber(selectedOperation.getCardNumber());
			app.setAccountNumber(selectedOperation.getAccountNumber());
			AppStructureUtils.setValue(root, AppElements.OPER_REASON, selectedOperation.getOperReason());

			if (root.getChildByName(AppElements.OPERATION, 1) == null) {
				root.addChildren(addBlock(root.getChildByName(AppElements.OPERATION), app));
			}
			ApplicationElement oper = root.getChildByName(AppElements.OPERATION, 1);
			if (oper != null) {
				AppStructureUtils.setValue(oper, AppElements.SESSION_ID, userSessionId);
				AppStructureUtils.setValue(oper, AppElements.OPERATION_ID, selectedOperation.getId());
				AppStructureUtils.setValue(oper, AppElements.OPERATION_TYPE, selectedOperation.getOperType());
				AppStructureUtils.setValue(oper, AppElements.MESSAGE_TYPE, selectedOperation.getMsgType());
				AppStructureUtils.setValue(oper, AppElements.STTL_TYPE, selectedOperation.getSttlType());
				AppStructureUtils.setValue(oper, AppElements.OPER_STATUS, selectedOperation.getStatus());
				AppStructureUtils.setValue(oper, AppElements.OPER_AMOUNT, selectedOperation.getOperAmount());
				AppStructureUtils.setValue(oper, AppElements.OPER_CURRENCY, selectedOperation.getOperCurrency());
				AppStructureUtils.setValue(oper, AppElements.OPER_DATE, selectedOperation.getOperDate());
				AppStructureUtils.setValue(oper, AppElements.OPER_REASON, selectedOperation.getOperReason());
				AppStructureUtils.setValue(oper, AppElements.HOST_DATE, selectedOperation.getHostDate());
				AppStructureUtils.setValue(oper, AppElements.IS_REVERSAL, selectedOperation.getIsReversal());
				AppStructureUtils.setValue(oper, AppElements.FORCED_PROCESSING, selectedOperation.getForcedProcessing());
				AppStructureUtils.setValue(oper, AppElements.MERCHANT_NAME, selectedOperation.getMerchantName());
				AppStructureUtils.setValue(oper, AppElements.MERCHANT_NUMBER, selectedOperation.getMerchantNumber());
				AppStructureUtils.setValue(oper, AppElements.MERCHANT_CITY, selectedOperation.getMerchantCity());
				AppStructureUtils.setValue(oper, AppElements.MERCHANT_COUNTRY, selectedOperation.getMerchantCountry());
				AppStructureUtils.setValue(oper, AppElements.MERCHANT_POSTCODE, selectedOperation.getMerchantPostCode());
				AppStructureUtils.setValue(oper, AppElements.MERCHANT_REGION, selectedOperation.getMerchantRegion());
				AppStructureUtils.setValue(oper, AppElements.MERCHANT_STREET, selectedOperation.getMerchantStreet());
				AppStructureUtils.setValue(oper, AppElements.ORIGINAL_ID, selectedOperation.getOriginalId());
				AppStructureUtils.setValue(oper, AppElements.STATUS_REASON, selectedOperation.getStatusReason());
				AppStructureUtils.setValue(oper, AppElements.TERMINAL_NUMBER, selectedOperation.getTerminalNumber());
				AppStructureUtils.setValue(oper, AppElements.FORW_INST_BIN, selectedOperation.getForwInstBin());
				AppStructureUtils.setValue(oper, AppElements.ACQUIRER_INST_BIN, selectedOperation.getAcqInstBin());
				AppStructureUtils.setValue(oper, AppElements.FORW_INST_BIN, selectedOperation.getForwInstBin());
				AppStructureUtils.setValue(oper, AppElements.MCC, selectedOperation.getMccCode());
				AppStructureUtils.setValue(oper, AppElements.ORIGINATOR_REFNUM, selectedOperation.getOriginatorRefnum());
				AppStructureUtils.setValue(oper, AppElements.NETWORK_REFNUM, selectedOperation.getNetworkRefnum());
				AppStructureUtils.setValue(oper, AppElements.OPER_COUNT, selectedOperation.getOperCount());
				AppStructureUtils.setValue(oper, AppElements.OPER_REQUEST_AMOUNT, selectedOperation.getOperRequestAmount());
				AppStructureUtils.setValue(oper, AppElements.OPER_CASHBACK_AMOUNT, selectedOperation.getOperCashbackAmount());
				AppStructureUtils.setValue(oper, AppElements.OPER_REPLACEMENT_AMOUNT, selectedOperation.getOperReplacementAmount());
				AppStructureUtils.setValue(oper, AppElements.OPER_SURCHARGE_AMOUNT, selectedOperation.getOperSurchargeAmount());
				AppStructureUtils.setValue(oper, AppElements.MATCH_STATUS, selectedOperation.getMatchStatus());
				AppStructureUtils.setValue(oper, AppElements.STTL_AMOUNT, selectedOperation.getSttlAmount());
				AppStructureUtils.setValue(oper, AppElements.STTL_CURRENCY, selectedOperation.getSttlCurrency());
				AppStructureUtils.setValue(oper, AppElements.DISPUTE_ID, selectedOperation.getDisputeId());

				if (addParticipants) {
					if (selectedOperation.getParticipants() != null) {
						for (Participant participant : selectedOperation.getParticipants()) {
							fillParticipant(construct(AppElements.PARTICIPANT, oper, app), selectedOperation, participant);
						}
					}
				}
			}
		}
	}

	private void fillParticipant(ApplicationElement part, ru.bpc.sv2.operations.incoming.Operation operation) {
		AppStructureUtils.setValue(part, AppElements.OPERATION_TYPE, operation.getOperType());
		AppStructureUtils.setValue(part, AppElements.MESSAGE_TYPE, operation.getMsgType());
		AppStructureUtils.setValue(part, AppElements.PARTICIPANT_TYPE, operation.getParticipantType());
		AppStructureUtils.setValue(part, AppElements.HOST_DATE, operation.getSourceHostDate());
		AppStructureUtils.setValue(part, AppElements.CLIENT_ID_TYPE, operation.getClientIdType());
		AppStructureUtils.setValue(part, AppElements.CLIENT_ID_VALUE, operation.getClientIdValue());
		AppStructureUtils.setValue(part, AppElements.INSTITUTION_ID, operation.getIssInstId());
		AppStructureUtils.setValue(part, AppElements.NETWORK_ID, operation.getIssNetworkId());
		AppStructureUtils.setValue(part, AppElements.CARD_INSTITUTION_ID, operation.getCardInstId());
		AppStructureUtils.setValue(part, AppElements.CARD_NETWORK_ID, operation.getCardNetworkId());
		AppStructureUtils.setValue(part, AppElements.CARD_ID, operation.getCardId() != null ? operation.getCardId().toString() : null);
		AppStructureUtils.setValue(part, AppElements.CARD_INSTANCE_ID, operation.getCardInstanceId());
		AppStructureUtils.setValue(part, AppElements.CARD_TYPE, operation.getCardTypeId());
		AppStructureUtils.setValue(part, AppElements.CARD_NUMBER, operation.getCardNumber());
		AppStructureUtils.setValue(part, AppElements.CARD_MASK, operation.getCardMask());
		AppStructureUtils.setValue(part, AppElements.CARD_HASH, operation.getCardHash());
		AppStructureUtils.setValue(part, AppElements.SEQUENTIAL_NUMBER, operation.getCardSeqNumber());
		AppStructureUtils.setValue(part, AppElements.EXPIRATION_DATE, operation.getCardExpirationDate());
		AppStructureUtils.setValue(part, AppElements.COUNTRY, operation.getCardCountry());
		AppStructureUtils.setValue(part, AppElements.CUSTOMER_ID, operation.getCustomerId());
		AppStructureUtils.setValue(part, AppElements.ACCOUNT_ID, operation.getAccountId());
		AppStructureUtils.setValue(part, AppElements.ACCOUNT_TYPE, operation.getAccountType());
		AppStructureUtils.setValue(part, AppElements.ACCOUNT_NUMBER, operation.getAccountNumber());
		AppStructureUtils.setValue(part, AppElements.AVAILABLE_BALANCE, operation.getAccountAmount());
		AppStructureUtils.setValue(part, AppElements.CURRENCY, operation.getAccountCurrency());
		AppStructureUtils.setValue(part, AppElements.SPLIT_HASH, operation.getSplitHash());
		AppStructureUtils.setValue(part, AppElements.MERCHANT_NUMBER, operation.getMerchantNumber());
		AppStructureUtils.setValue(part, AppElements.MERCHANT_ID, operation.getMerchantId());
		AppStructureUtils.setValue(part, AppElements.WITHOUT_CHECKS, Boolean.TRUE);
	}

	private void fillParticipant(ApplicationElement part, Operation operation, Participant participant) {
		AppStructureUtils.setValue(part, AppElements.OPERATION_TYPE, operation.getOperationType());
		AppStructureUtils.setValue(part, AppElements.MESSAGE_TYPE, operation.getMsgType());
		AppStructureUtils.setValue(part, AppElements.PARTICIPANT_TYPE, participant.getParticipantType());
		AppStructureUtils.setValue(part, AppElements.HOST_DATE, operation.getHostDate());
		AppStructureUtils.setValue(part, AppElements.CLIENT_ID_TYPE, participant.getClientIdType());
		AppStructureUtils.setValue(part, AppElements.CLIENT_ID_VALUE, participant.getClientIdValue());
		AppStructureUtils.setValue(part, AppElements.INSTITUTION_ID, participant.getInstId());
		AppStructureUtils.setValue(part, AppElements.NETWORK_ID, participant.getNetworkId());
		AppStructureUtils.setValue(part, AppElements.CARD_INSTITUTION_ID, participant.getCardInstId());
		AppStructureUtils.setValue(part, AppElements.CARD_NETWORK_ID, participant.getCardNetworkId());
		AppStructureUtils.setValue(part, AppElements.CARD_ID, participant.getCardId().toString());
		AppStructureUtils.setValue(part, AppElements.CARD_INSTANCE_ID, participant.getCardInstanceId());
		AppStructureUtils.setValue(part, AppElements.CARD_TYPE, participant.getCardTypeId());
		AppStructureUtils.setValue(part, AppElements.CARD_NUMBER, participant.getCardNumber());
		AppStructureUtils.setValue(part, AppElements.CARD_MASK, participant.getCardMask());
		AppStructureUtils.setValue(part, AppElements.CARD_HASH, participant.getCardHash());
		AppStructureUtils.setValue(part, AppElements.SEQUENTIAL_NUMBER, participant.getCardSeqNumber());
		AppStructureUtils.setValue(part, AppElements.EXPIRATION_DATE, participant.getCardExpirDate());
		AppStructureUtils.setValue(part, AppElements.COUNTRY, participant.getCardCountry());
		AppStructureUtils.setValue(part, AppElements.CUSTOMER_ID, participant.getCustomerId());
		AppStructureUtils.setValue(part, AppElements.ACCOUNT_ID, participant.getAccountId());
		AppStructureUtils.setValue(part, AppElements.ACCOUNT_TYPE, participant.getAccountType());
		AppStructureUtils.setValue(part, AppElements.ACCOUNT_NUMBER, participant.getAccountNumber());
		AppStructureUtils.setValue(part, AppElements.AVAILABLE_BALANCE, participant.getAccountAmount());
		AppStructureUtils.setValue(part, AppElements.CURRENCY, participant.getAccountCurrency());
		AppStructureUtils.setValue(part, AppElements.SPLIT_HASH, participant.getSplitHash());
		AppStructureUtils.setValue(part, AppElements.MERCHANT_NUMBER, operation.getMerchantNumber());
		AppStructureUtils.setValue(part, AppElements.MERCHANT_ID, participant.getMerchantId());
		AppStructureUtils.setValue(part, AppElements.WITHOUT_CHECKS, Boolean.TRUE);
	}

	private ApplicationElement construct(String name, ApplicationElement root, Application app) {
		if (root.getChildByName(name, 0) != null) {
            root.addChildren(addBlock(root.getChildByName(name, 0), app));
			Integer inner = root.getChildByName(name, 0).getMaxCopy();
			return root.getChildByName(name, inner);
		}
		return null;
	}

	private ApplicationElement addBlock(ApplicationElement template, Application app) {
		ApplicationElement node = new ApplicationElement();
		Map<Integer, ApplicationFlowFilter> filters = new HashMap<Integer, ApplicationFlowFilter>();
		template.clone(node);
		node.setContent(false);
		template.setMaxCopy(template.getMaxCopy() + 1);
		node.setInnerId(template.getMaxCopy());
		node.setContentBlock(template);
		applicationDao.fillRootChilds(userSessionId, app.getInstId(), node, app, filters);
		return node;
	}

	public void createApplicationInDB() {
		app = applicationDao.createApplication(userSessionId, app);
		ApplicationElement applicationRootTmp = applicationDao.getApplicationForEdit(userSessionId, app);
		applicationRootTmp.apply(root);
		applicationDao.saveApplication(userSessionId, root, app);
	}

	public void createApplicationInDB(String status) {
		app.setStatus(status);
		app.setNewStatus(status);
		createApplicationInDB();
	}

	public void processApplication() {
		applicationDao.processApplication(userSessionId, app.getId(), Boolean.FALSE);
	}

	public void addApplicationObject(Operation operation) {
        addApplicationObject(operation.getId(), EntityNames.OPERATION);
	}

	public void addApplicationObject(ru.bpc.sv2.operations.incoming.Operation operation) {
		addApplicationObject(operation.getId(), EntityNames.OPERATION);
	}

	public void addApplicationObject(Account account) {
        addApplicationObject(account.getId(), EntityNames.ACCOUNT);
	}

	public void addApplicationObject(Card card) {
		addApplicationObject(card.getId(), EntityNames.CARD);
	}

    public void addApplicationObject(Long id, String entityType) {
        applicationDao.addApplicationObject(userSessionId, app.getId(), entityType, id, appObjectSeqNum.getAndIncrement());
    }

	public Application getApplication() {
		return app;
	}

	public ApplicationElement getRoot() {
		return root;
	}

	public Application getApp() {
		return app;
	}
}
