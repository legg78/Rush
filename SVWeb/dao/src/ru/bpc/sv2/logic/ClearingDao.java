package ru.bpc.sv2.logic;

import com.ibatis.sqlmap.client.SqlMapSession;
import ru.bpc.sv.svxp.clearing.AdditionalAmount;
import ru.bpc.sv.svxp.clearing.Operation;
import ru.bpc.sv.svxp.clearing.OperationResult;
import ru.bpc.sv.svxp.clearing.Participant;
import ru.bpc.sv2.logic.utility.db.IbatisAware;
import ru.bpc.sv2.svng.AuthData;
import ru.bpc.sv2.utils.UserException;

import java.sql.SQLException;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Session Bean implementation class Clearing
 */
public class ClearingDao extends IbatisAware {

	private OperationDao operationDao = new OperationDao();

	public void add(Operation operation) {
		SqlMapSession ssn = null;
		try {
			Map<String, Object> map = new HashMap<String, Object>();
			ssn = getIbatisSessionNoContext();

		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	public Long performOperation(Operation operation) throws UserException {
		SqlMapSession ssn = null;
		try{
			ssn = getIbatisSessionNoContext();
			performChecks(operation);

			HashMap<String, Object> map = prepareMap(operation);
			ssn.update("clearing.add-operation", map);
			operation.setOperId((Long)map.get("operId"));

			operationDao.addAuthData(ssn, Arrays.asList(AuthData.from(operation.getOperId(), operation.getAuthData())));

			if (operation.getIssuer() != null) {
				ssn.update("clearing.add-participant", getParticipantParameters(operation, ru.bpc.sv2.operations.Participant.ISS_PARTICIPANT));
			}
			if (operation.getAcquirer() != null) {
				ssn.update("clearing.add-participant", getParticipantParameters(operation, ru.bpc.sv2.operations.Participant.ACQ_PARTICIPANT));
			}
			if (operation.getDestination() != null) {
				ssn.update("clearing.add-participant", getParticipantParameters(operation, ru.bpc.sv2.operations.Participant.DESTINATION_PARTICIPANT));
			}
            addAdditionalAmount(ssn, operation);
			ssn.update("clearing.process-operation", operation.getOperId());

		} catch (Exception e) {
			if (e instanceof SQLException) {
				if (ssn != null) {
					SQLException se = (SQLException) e;
					if (se.getErrorCode() >= 20000 && se.getErrorCode() <= 20999) {
						String result = null;
						try {
							result = (String) ssn.queryForObject("common.get-last-error");
						} catch (SQLException ignored) {
						}
						throw new UserException(e.getCause().getMessage(), result, null);
					}
				}
			}
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
		return operation.getOperId();
	}

	public void performChecks(Operation operation) throws IllegalArgumentException{
		if (operation.getProcessingStage() != null && operation.getProcessingStage().size() > 0) {
			throw new IllegalArgumentException("Processing stage block is not supported");
		}
		if (operation.getFlexibleData() != null && operation.getFlexibleData().size() > 0) {
			throw new IllegalArgumentException("Flexible data block is not supported");
		}
		if (operation.getPaymentOrder() != null) {
			throw new IllegalArgumentException("Payment order block is not supported");
		}
	}
    
    private HashMap<String, Object>prepareMap(Operation operation){
    	HashMap<String, Object> result = new HashMap<String, Object>();
    	if (operation.getOperId() != null){
    		result.put("operId", operation.getOperId());
    	}
    	if (operation.getIsReversal() == null){
    		result.put("isReversal", 0);
    	}else if (operation.getIsReversal() > 0){
    		result.put("isReversal", 1);
    	}else{
    		result.put("isReversal", 0);
    	}
    	result.put("operType", operation.getOperType());
    	result.put("operReason", operation.getOperReason());
    	result.put("msgType", operation.getMsgType());
    	if (operation.getStatus() == null){
    		result.put("status", "OPST0100");
    	}else{
    		result.put("status", operation.getStatus());
    	}
    	result.put("statusReason", operation.getStatusReason());
    	result.put("sttlType", operation.getSttlType());
    	result.put("terminalType", operation.getTerminalType());
    	result.put("acqInstBin", operation.getAcqInstBin());
    	result.put("merchantNumber", operation.getMerchantNumber());
    	result.put("terminalNumber", operation.getTerminalNumber());
    	result.put("merchantName", operation.getMerchantName());
    	result.put("merchantStreet", operation.getMerchantStreet());
    	result.put("merchantCity", operation.getMerchantCity());
    	result.put("merchantRegion", operation.getMerchantRegion());
    	result.put("merchantCountry", operation.getMerchantCountry());
    	result.put("merchantPostcode", operation.getMerchantPostcode());
    	result.put("mcc", operation.getMcc());
    	result.put("originatorRefnum", operation.getOriginatorRefnum());
    	result.put("networkRefnum", operation.getNetworkRefnum());
		result.put("operCount", operation.getOperCount());
    	result.put("operRequestAmountAmountValue", operation.getOperRequestAmount() != null ? operation.getOperRequestAmount().getAmountValue() : null);
    	result.put("operAmountAmountValue", operation.getOperAmount() != null ? operation.getOperAmount().getAmountValue() : null);
    	result.put("operAmountCurrency", operation.getOperAmount() != null ? operation.getOperAmount().getCurrency() : null);
    	if (operation.getOperDate() != null){
    		result.put("operDate", operation.getOperDate().toGregorianCalendar().getTime());
    	}
    	if (operation.getHostDate() != null){
    		result.put("hostDate", operation.getHostDate().toGregorianCalendar().getTime());
    	}

		result.put("originalId", operation.getOriginalId());
		result.put("operSurchargeAmount", operation.getOperSurchargeAmount() != null ? operation.getOperSurchargeAmount().getAmountValue() : null);
		result.put("operCashbackAmount", operation.getOperCashbackAmount() != null ? operation.getOperCashbackAmount().getAmountValue() : null);
		result.put("sttlAmount", operation.getSttlAmount() != null ? operation.getSttlAmount().getAmountValue() : null);
		result.put("sttlCurrency", operation.getSttlAmount() != null ? operation.getSttlAmount().getCurrency() : null);
		result.put("interchangeFeeAmount", operation.getInterchangeFee() != null ? operation.getInterchangeFee().getAmountValue() : null);
		result.put("interchangeFeeCurrency", operation.getInterchangeFee() != null ? operation.getInterchangeFee().getCurrency() : null);
		result.put("forwardingInstBin", operation.getForwardingInstBin());
		if (operation.getSttlDate() != null){
			result.put("sttlDate", operation.getSttlDate().toGregorianCalendar().getTime());
		}
		if (operation.getAcqSttlDate() != null){
			result.put("acqSttlDate", operation.getAcqSttlDate().toGregorianCalendar().getTime());
		}
		result.put("matchStatus", operation.getMatchStatus());
    	return result;
    }
    
    private Map<String, Object> getParticipantParameters(Operation operation, String partyType) {
    	Participant participant = null;
    	if (ru.bpc.sv2.operations.Participant.ACQ_PARTICIPANT.equals(partyType)) {
    		participant = operation.getAcquirer();
    		participant.setParticipantType(partyType);
    	} else if (ru.bpc.sv2.operations.Participant.ISS_PARTICIPANT.equals(partyType)) {
    		participant = operation.getIssuer();
    		participant.setParticipantType(partyType);
    	} else if (ru.bpc.sv2.operations.Participant.DESTINATION_PARTICIPANT.equals(partyType)) {
    		participant = operation.getDestination();
    		participant.setParticipantType(partyType);
    	}
    	return getParticipantParameters(operation, participant);
    }
    
    private Map<String, Object> getParticipantParameters(Operation operation, Participant participant) {
    	Map<String, Object> partyParams = new HashMap<String, Object>();
    	partyParams.put("operId", operation.getOperId());
    	partyParams.put("operType", operation.getOperType());
    	partyParams.put("msgType", operation.getMsgType());
    	partyParams.put("participantType", participant.getParticipantType());
    	partyParams.put("clientIdType", participant.getClientIdType());
    	partyParams.put("clientIdValue", participant.getClientIdValue());
    	partyParams.put("cardNumber", participant.getCardNumber());
    	partyParams.put("cardSeqNumber", participant.getCardSeqNumber());
    	partyParams.put("instId", participant.getInstId());
    	partyParams.put("networkId", participant.getNetworkId());
    	partyParams.put("authCode", participant.getAuthCode());
    	partyParams.put("accountNumber", participant.getAccountNumber());
    	partyParams.put("accountAmount", participant.getAccountAmount());
    	partyParams.put("accountCurrency", participant.getAccountCurrency());
	    if (participant.getCardExpirDate() != null) {
		    partyParams.put("cardExpirDate", participant.getCardExpirDate().toGregorianCalendar().getTime());
	    }
	    partyParams.put("cardId", participant.getCardId());
		partyParams.put("cardInstanceId", participant.getCardInstanceId());
		partyParams.put("cardCountry", participant.getCardCountry());
		return partyParams;
    }

    private void addAdditionalAmount(SqlMapSession ssn, Operation operation) throws SQLException {
        if (operation.getAdditionalAmount() == null) return;
        Map<String, Object> map = new HashMap<String, Object>();
        map.put("oper_id", operation.getOperId());
        for(AdditionalAmount amount: operation.getAdditionalAmount()) {
            map.put("amount_type", amount.getAmountType());
            map.put("amount", amount.getAmountValue());
            map.put("amount_currency", amount.getCurrency());

            ssn.update("clearing.add-additional-amount", map);
        }
    }

	public OperationResult getOperationResult(Long operId) throws UserException {
		SqlMapSession ssn = null;
		try{
			ssn = getIbatisSessionNoContext();
			return (OperationResult) ssn.queryForObject("clearing.get-oper-result", operId);
		} catch (Exception e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	public List<OperationResult> getOperationResults(List<Long> operIds) throws UserException {
		SqlMapSession ssn = null;
		try{
			ssn = getIbatisSessionNoContext();
			return (List<OperationResult>) ssn.queryForList("clearing.get-oper-results", operIds);
		} catch (Exception e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}
}
