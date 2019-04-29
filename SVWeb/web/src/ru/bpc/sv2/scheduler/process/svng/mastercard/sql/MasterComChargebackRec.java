package ru.bpc.sv2.scheduler.process.svng.mastercard.sql;

import ru.bpc.sv2.common.SQLDataRec;
import ru.bpc.sv2.mastercom.api.types.claim.response.MasterComChargebackDetails;
import ru.bpc.sv2.ui.utils.CurrencyCache;
import ru.bpc.sv2.utils.AuthOracleTypeNames;
import ru.bpc.sv2.utils.DBUtils;

import java.sql.Connection;
import java.sql.SQLException;
import java.sql.SQLOutput;

public class MasterComChargebackRec extends SQLDataRec {
	private final MasterComChargebackDetails chargeback;

	public MasterComChargebackRec(MasterComChargebackDetails chargeback, Connection connection) {
		this.chargeback = chargeback;
		setConnection(DBUtils.getNativeConnection(connection));
	}

	@Override
	public String getSQLTypeName() throws SQLException {
		return AuthOracleTypeNames.MCW_MCOM_CHARGEBACK_REC;
	}

	@Override
	public void writeSQL(SQLOutput stream) throws SQLException {
		writeValueV(stream, CurrencyCache.getInstance().getCodeMap().get(chargeback.getCurrency()));
		writeValueD(stream, chargeback.getCreateDate());
		writeValueB(stream, chargeback.getDocumentIndicator());
		writeValueV(stream, chargeback.getMessageText());
		writeValueN(stream, chargeback.getAmount());
		writeValueV(stream, chargeback.getReasonCode());
		writeValueB(stream, chargeback.getIsPartialChargeback());
		writeValueV(stream, chargeback.getChargebackType().name());
		writeValueV(stream, chargeback.getChargebackId());
		writeValueV(stream, chargeback.getClaimId());
		writeValueB(stream, chargeback.getReversed());
		writeValueB(stream, chargeback.getReversal());
	}
}
