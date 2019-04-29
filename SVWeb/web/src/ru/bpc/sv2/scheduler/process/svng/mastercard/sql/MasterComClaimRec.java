package ru.bpc.sv2.scheduler.process.svng.mastercard.sql;

import org.apache.commons.lang3.StringUtils;
import ru.bpc.sv2.common.SQLDataRec;
import ru.bpc.sv2.mastercom.api.types.claim.response.MasterComClaim;
import ru.bpc.sv2.ui.utils.CurrencyCache;
import ru.bpc.sv2.utils.AuthOracleTypeNames;
import ru.bpc.sv2.utils.DBUtils;

import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.SQLException;
import java.sql.SQLOutput;

public class MasterComClaimRec extends SQLDataRec {
	private final MasterComClaim claim;


	public MasterComClaimRec(MasterComClaim claim, Connection connection) {
		this.claim = claim;
		setConnection(DBUtils.getNativeConnection(connection));
	}

	@Override
	public String getSQLTypeName() throws SQLException {
		return AuthOracleTypeNames.MCW_MCOM_CLAIM_REC;
	}

	@Override
	public void writeSQL(SQLOutput stream) throws SQLException {
		writeValueV(stream, claim.getAcquirerId());
		writeValueV(stream, claim.getAcquirerRefNum());
		writeValueV(stream, claim.getPrimaryAccountNum());
		writeValueV(stream, claim.getClaimId());
		writeValueV(stream, claim.getClaimType());
		BigDecimal value = null;
		String currency = null;
		if (StringUtils.isNotEmpty(claim.getClaimValue())) {
			String claimValue = claim.getClaimValue().trim().replaceAll("\\s+", " ");
			int spaceIndex = claimValue.indexOf(' ');
			if (spaceIndex > -1) {
				value = new BigDecimal(claimValue.substring(0, spaceIndex));
				currency = CurrencyCache.getInstance().getCodeMap().get(claimValue.substring(spaceIndex + 1));
			} else {
				value = new BigDecimal(claimValue);
			}
		}
		writeValueN(stream, value);
		writeValueV(stream, currency);
		writeValueD(stream, claim.getClearingDueDate());
		writeValueV(stream, claim.getClearingNetwork());
		writeValueD(stream, claim.getCreateDate());
		writeValueD(stream, claim.getDueDate());
		writeValueV(stream, claim.getTransactionId());
		writeValueB(stream, claim.getIsAccurate());
		writeValueB(stream, claim.getIsAcquirer());
		writeValueB(stream, claim.getIsIssuer());
		writeValueB(stream, claim.getIsOpen());
		writeValueV(stream, claim.getIssuerId());
		writeValueV(stream, claim.getLastModifiedBy());
		writeValueD(stream, claim.getLastModifiedDate());
		writeValueV(stream, claim.getMerchantId());
		writeValueV(stream, claim.getProgressState());
		writeValueV(stream, claim.getQueueName());

	}
}
