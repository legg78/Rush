package ru.bpc.sv2.scheduler.process.svng.mastercard.sql;

import ru.bpc.sv2.common.SQLDataRec;
import ru.bpc.sv2.mastercom.api.types.claim.response.MasterComRetrievalDetails;
import ru.bpc.sv2.ui.utils.CurrencyCache;
import ru.bpc.sv2.utils.AuthOracleTypeNames;
import ru.bpc.sv2.utils.DBUtils;

import java.sql.Connection;
import java.sql.SQLException;
import java.sql.SQLOutput;

public class MasterComRetrievalRec extends SQLDataRec {
	private final MasterComRetrievalDetails retrieval;

	public MasterComRetrievalRec(MasterComRetrievalDetails retrieval, Connection connection) {
		this.retrieval = retrieval;
		setConnection(DBUtils.getNativeConnection(connection));
	}


	@Override
	public String getSQLTypeName() throws SQLException {
		return AuthOracleTypeNames.MCW_MCOM_RETRIEVAL_REC;
	}

	@Override
	public void writeSQL(SQLOutput stream) throws SQLException {
		writeValueV(stream, retrieval.getAcquirerRefNum());
		writeValueV(stream, retrieval.getAcquirerResponseCd());
		writeValueV(stream, retrieval.getAcquirerMemo());
		writeValueD(stream, retrieval.getAcquirerResponseDt());
		writeValueN(stream, retrieval.getAmount());
		writeValueV(stream, CurrencyCache.getInstance().getCodeMap().get(retrieval.getCurrency()));
		writeValueV(stream, retrieval.getClaimId());
		writeValueD(stream, retrieval.getCreateDate());
		writeValueN(stream, retrieval.getDocNeeded().getCode());
		writeValueV(stream, retrieval.getIssuerResponseCd());
		writeValueV(stream, retrieval.getIssuerRejectRsnCd());
		writeValueV(stream, retrieval.getIssuerMemo());
		writeValueD(stream, retrieval.getIssuerResponseDt());
		writeValueV(stream, retrieval.getImageReviewDecision());
		writeValueD(stream, retrieval.getImageReviewDt());
		writeValueV(stream, retrieval.getPrimaryAcctNum());
		writeValueV(stream, retrieval.getRequestId());
		writeValueV(stream, retrieval.getRetrievalRequestReason());

	}
}
