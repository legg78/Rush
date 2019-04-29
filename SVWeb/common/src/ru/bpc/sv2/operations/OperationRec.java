package ru.bpc.sv2.operations;

import java.math.BigDecimal;
import java.sql.SQLData;
import java.sql.SQLException;
import java.sql.SQLInput;
import java.sql.SQLOutput;
import java.util.Calendar;
import java.util.Date;
import java.util.GregorianCalendar;

import ru.bpc.sv2.common.SQLDataRec;
import ru.bpc.sv2.operations.incoming.Operation;
import ru.bpc.sv2.operations.incoming.posting.Amount;
import ru.bpc.sv2.operations.incoming.posting.Authorization;
import ru.bpc.sv2.utils.AuthOracleTypeNames;

public class OperationRec extends SQLDataRec {
	private final Operation oper;
	private final Authorization auth;

	public OperationRec(Operation oper) {
		this.oper = oper;
		this.auth = null;
	}
	
	public OperationRec(Authorization auth) throws Exception {
		this.auth = auth;
		try {
			this.oper = createOperation(this.auth);
		} catch (Exception e) {
			throw e;
		}
	}

	@Override
	public String getSQLTypeName() throws SQLException {
		return AuthOracleTypeNames.OPR_OPERATION_REC;
	}

	@Override
	public void writeSQL(SQLOutput stream) throws SQLException {
		writeValueN(stream, oper.getId() );
		writeValueN(stream, oper.getSplitHash() );
		writeValueN(stream, oper.getSessionId());
		writeValueB(stream, oper.isReversal() );
		writeValueN(stream, oper.getOriginalId() );
		writeValueV(stream, oper.getOperType() );
		writeValueV(stream, oper.getOperReason() );
		writeValueV(stream, oper.getMsgType() );
		writeValueV(stream, oper.getStatus() );
		writeValueV(stream, oper.getStatusReason() );
		writeValueV(stream, oper.getSttlType() );
		writeValueN(stream, oper.getAcqInstId() );
		writeValueN(stream, oper.getAcqNetworkId() );
		writeValueN(stream, oper.getSplitHashAcq() );
		writeValueV(stream, oper.getTerminalType() );
		writeValueV(stream, oper.getAcqInstBin() );
		writeValueV(stream, oper.getForwInstBin() );
		writeValueN(stream, oper.getMerchantId() ) ;
		writeValueV(stream, oper.getMerchantNumber() );
		writeValueN(stream, oper.getTerminalId() );
		writeValueV(stream, oper.getTerminalNumber() );
		writeValueV(stream, oper.getMerchantName() );
		writeValueV(stream, oper.getMerchantStreet() );
		writeValueV(stream, oper.getMerchantCity() );
		writeValueV(stream, oper.getMerchantRegion() );
		writeValueV(stream, oper.getMerchantCountryCode() );
		writeValueV(stream, oper.getMerchantPostCode() );
		writeValueV(stream, oper.getMccCode() );
		writeValueV(stream, oper.getRefnum() );
		writeValueV(stream, oper.getNetworkRefnum() );
		writeValueV(stream, oper.getAuthCode() );
		writeValueN(stream, oper.getOperationRequestAmount() );
		writeValueN(stream, oper.getOperationAmount() );
		writeValueN(stream, oper.getOperCount() );
		writeValueV(stream, oper.getOperationCurrency() );
		writeValueN(stream, oper.getOperationCashbackAmount() );
		writeValueN(stream, oper.getOperationReplacementAmount() );
		writeValueN(stream, oper.getOperationSurchargeAmount() );
		writeValueD(stream, oper.getOperationDate() );
		writeValueD(stream, oper.getSttlDate() );
		writeValueD(stream, oper.getSourceHostDate() );
		writeValueN(stream, oper.getIssInstId() );
		writeValueN(stream, oper.getIssNetworkId() );
		writeValueN(stream, oper.getSplitHashIss() );
		writeValueN(stream, oper.getCardInstId() );
		writeValueN(stream, oper.getCardNetworkId() );
		writeValueV(stream, oper.getCardNumber() );
		writeValueN(stream, oper.getCardId() );
		writeValueN(stream, oper.getCardTypeId() );
		writeValueV(stream, oper.getCardMask() );
		writeValueN(stream, oper.getCardHash() );
		writeValueN(stream, oper.getCardSeqNumber() );
		writeValueD(stream, oper.getCardExpirationDate() );
		writeValueV(stream, oper.getCardCountry() );
		writeValueV(stream, oper.getAccountType() );
		writeValueV(stream, oper.getAccountNumber() );
		writeValueN(stream, oper.getAccountAmount() );
		writeValueV(stream, oper.getAccountCurrency() );
		writeValueV(stream, oper.getMatchStatus() );
		writeValueN(stream, oper.getAuthId() );
		writeValueN(stream, oper.getSttlAmount() );
		writeValueV(stream, oper.getSttlCurrency() );
		writeValueN(stream, oper.getDisputeId() );
	}

	private Operation createOperation(Authorization auth) throws Exception {
		Operation op = new Operation();
		op.setReversal(auth.isReversal());
		op.setMsgType(auth.getMsgType());
		op.setOperType(auth.getOperType());
		op.setSttlType(auth.getSttlType());
		op.setAcqInstId(auth.getAcqInstId());
		op.setAcqNetworkId(auth.getAcqNetworkId());
		op.setTerminalType(auth.getTerminalType());
		op.setAcqInstBin(auth.getAcqInstBin());
		op.setForwInstBin(auth.getForwInstBin());
		op.setMerchantId(auth.getMerchantId());
		op.setMerchantNumber(auth.getMerchantNumber());
		op.setTerminalId(auth.getTerminalId());
		op.setTerminalNumber(auth.getTerminalNumber());
		op.setMerchantName(auth.getMerchantName());
		op.setMerchantStreet(auth.getMerchantStreet());
		op.setMerchantCity(auth.getMerchantCity());
		op.setMerchantRegion(auth.getMerchantRegion());
		op.setMerchantCountryCode(auth.getMerchantCountry());
		op.setMerchantPostCode(auth.getMerchantPostcode());
		op.setMccCode(auth.getMcc());
		op.setRefnum(auth.getRefnum());
		op.setNetworkRefnum(auth.getNetworkRefnum());
		op.setAuthCode(auth.getAuthCode());
		if (auth.getOperDate() != null) {
			op.setOperationDate(new Date(auth.getOperDate().toGregorianCalendar().getTimeInMillis()));
		}
		if (auth.getHostDate() != null) {
			op.setSourceHostDate(new Date(auth.getHostDate().toGregorianCalendar().getTimeInMillis()));
		}
		op.setIssInstId(auth.getIssInstId());
		op.setIssNetworkId(auth.getIssNetworkId());
		op.setCardInstId(auth.getCardInstId());
		op.setCardNetworkId(auth.getCardNetworkId());
		op.setAccountType(auth.getAccountType());
		op.setAccountNumber(auth.getAccountNumber());
		if (auth.getOperCount() != null) {
			op.setOperCount(auth.getOperCount().longValue());
		}
		if (auth.getCard() != null) {
			op.setCardNumber(auth.getCard().getCardNumber());
			op.setCardSeqNumber(auth.getCard().getCardSeqNumber());
			if (auth.getCard().getCardExpirDate() != null) {
				op.setCardExpirationDate(new Date(auth.getCard().getCardExpirDate().toGregorianCalendar().getTimeInMillis()));
			}
		}
		op.setStatus(auth.getStatus());
		op.setMatchStatus(auth.getMatchStatus());
		for (Amount amount : auth.getAmount()) {
			if (amount.isOperationAmount()) {
				double amountValue = amount.getAmountValue();
				op.setOperationAmount(BigDecimal.valueOf(amountValue));
				op.setOperationCurrency(amount.getCurrency());
			}
		}
		return op;
	}
}