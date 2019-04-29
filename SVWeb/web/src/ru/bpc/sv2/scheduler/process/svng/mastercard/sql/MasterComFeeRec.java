package ru.bpc.sv2.scheduler.process.svng.mastercard.sql;

import ru.bpc.sv2.common.SQLDataRec;
import ru.bpc.sv2.mastercom.api.types.claim.response.MasterComFeeDetails;
import ru.bpc.sv2.ui.utils.CountryCache;
import ru.bpc.sv2.ui.utils.CurrencyCache;
import ru.bpc.sv2.utils.AuthOracleTypeNames;
import ru.bpc.sv2.utils.DBUtils;

import java.sql.Connection;
import java.sql.SQLException;
import java.sql.SQLOutput;

public class MasterComFeeRec extends SQLDataRec {
	private final MasterComFeeDetails fee;
	private final String claimId;


	public MasterComFeeRec(MasterComFeeDetails fee, String claimId, Connection connection) {
		this.fee = fee;
		this.claimId = claimId;
		setConnection(DBUtils.getNativeConnection(connection));
	}
	@Override
	public String getSQLTypeName() throws SQLException {
		return AuthOracleTypeNames.MCW_MCOM_FEE_REC;
	}

	@Override
	public void writeSQL(SQLOutput stream) throws SQLException {
		writeValueV(stream, fee.getCardAcceptorIdCode());
		writeValueV(stream, fee.getCardNumber());
		writeValueV(stream, CountryCache.getInstance().getCodeMap().get(fee.getCountryCode()));
		writeValueV(stream, CurrencyCache.getInstance().getCodeMap().get(fee.getCurrency()));
		writeValueD(stream, fee.getFeeDate());
		writeValueV(stream, fee.getDestinationMember());
		writeValueV(stream, fee.getFeeId());
		writeValueN(stream, fee.getFeeAmount());
		writeValueB(stream, fee.getCreditSender());
		writeValueB(stream, fee.getCreditReceiver());
		writeValueV(stream, fee.getMessage());
		writeValueV(stream, fee.getReason());
		writeValueV(stream, claimId);
	}
}
