package ru.bpc.sv2.scheduler.process.svng.reconciliation;

import oracle.sql.CLOB;
import oracle.sql.OracleSQLOutput;
import oracle.xdb.XMLType;
import org.apache.commons.lang3.StringUtils;
import ru.bpc.sv.svxp.reconciliation.HostOperationType;
import ru.bpc.sv2.common.SQLDataRec;
import ru.bpc.sv2.utils.AuthOracleTypeNames;

import javax.xml.datatype.XMLGregorianCalendar;
import java.io.IOException;
import java.io.Writer;
import java.math.BigDecimal;
import java.sql.*;

public class HostReconciliationRec extends SQLDataRec {
    private HostOperationType operation;

    public HostReconciliationRec(HostOperationType operation, Connection con) {
        this.operation = operation;
        setConnection(con);
    }

    @Override
    public String getSQLTypeName() throws SQLException {
        return AuthOracleTypeNames.RCN_HOST_RECON_MSG_REC;
    }
    @Override
    public void writeSQL(SQLOutput stream) throws SQLException {
        writeValueV(stream, operation.getOperType());
        writeValueV(stream, operation.getMsgType());
        writeValueT(stream, operation.getHostDate());
        writeValueT(stream, operation.getOperDate());
        writeValueN(stream, (operation.getOperAmount() != null) ? operation.getOperAmount().getAmountValue() : null);
        writeValueV(stream, (operation.getOperAmount() != null) ? operation.getOperAmount().getCurrency() : null);
        writeValueN(stream, (operation.getOperSurchargeAmount() != null) ? operation.getOperSurchargeAmount().getAmountValue() : null);
        writeValueV(stream, (operation.getOperSurchargeAmount() != null) ? operation.getOperSurchargeAmount().getCurrency() : null);
        writeValueV(stream, operation.getStatus());
        writeValueN(stream, operation.getIsReversal());
        writeValueN(stream, operation.getMcc());
        writeValueV(stream, operation.getMerchantNumber());
        writeValueV(stream, operation.getMerchantName());
        writeValueV(stream, operation.getMerchantStreet());
        writeValueV(stream, operation.getMerchantCity());
        writeValueV(stream, operation.getMerchantRegion());
        writeValueV(stream, operation.getMerchantCountry());
        writeValueV(stream, operation.getMerchantPostcode());
        writeValueV(stream, operation.getTerminalType());
        writeValueV(stream, operation.getTerminalNumber());
        writeValueV(stream, operation.getCardNumber());
        writeValueN(stream, operation.getCardSeqNumber());
        writeValueT(stream, operation.getCardExpirDate());
        writeValueN(stream, operation.getAcqInstId());
	    writeValueN(stream, (operation.getOperCashbackAmount() != null) ? operation.getOperCashbackAmount().getAmountValue() : null);
	    writeValueV(stream, (operation.getOperCashbackAmount() != null) ? operation.getOperCashbackAmount().getCurrency() : null);
	    writeValueV(stream, operation.getServiceCode());
	    writeValueV(stream, operation.getApprovalCode());
	    writeValueV(stream, operation.getRrn());
	    writeValueV(stream, operation.getTrn());
	    writeValueV(stream, operation.getOriginalId());


	    if (operation.getEmvData() == null) {
		    final int emvDataCount = 30;
		    for (int i = 0; i < emvDataCount; i++) {
			    stream.writeObject(null);
		    }
	    } else {
		    writeValueN(stream, operation.getEmvData().getTag5F2A());
		    writeValueN(stream, operation.getEmvData().getTag5F34());
		    writeValueV(stream, operation.getEmvData().getTag71());
		    writeValueV(stream, operation.getEmvData().getTag72());
		    writeValueV(stream, operation.getEmvData().getTag82());
		    writeValueV(stream, operation.getEmvData().getTag84());
		    writeValueV(stream, operation.getEmvData().getTag8A());
		    writeValueV(stream, operation.getEmvData().getTag91());
		    writeValueV(stream, operation.getEmvData().getTag95());
		    writeValueN(stream, operation.getEmvData().getTag9A());
		    writeValueN(stream, operation.getEmvData().getTag9C());
		    writeValueN(stream, operation.getEmvData().getTag9F02());
		    writeValueN(stream, operation.getEmvData().getTag9F03());
		    writeValueV(stream, operation.getEmvData().getTag9F06());
		    writeValueV(stream, operation.getEmvData().getTag9F09());
		    writeValueV(stream, operation.getEmvData().getTag9F10());
		    writeValueV(stream, operation.getEmvData().getTag9F18());
		    writeValueN(stream, operation.getEmvData().getTag9F1A());
		    writeValueV(stream, operation.getEmvData().getTag9F1E());
		    writeValueV(stream, operation.getEmvData().getTag9F26());
		    writeValueV(stream, operation.getEmvData().getTag9F27());
		    writeValueV(stream, operation.getEmvData().getTag9F28());
		    writeValueV(stream, operation.getEmvData().getTag9F29());
		    writeValueV(stream, operation.getEmvData().getTag9F33());
		    writeValueV(stream, operation.getEmvData().getTag9F34());
		    writeValueN(stream, operation.getEmvData().getTag9F35());
		    writeValueV(stream, operation.getEmvData().getTag9F36());
		    writeValueV(stream, operation.getEmvData().getTag9F37());
		    writeValueN(stream, operation.getEmvData().getTag9F41());
		    writeValueV(stream, operation.getEmvData().getTag9F53());
	    }

	    if (operation.getPdc() == null) {
		    final int pdcCount = 12;
		    for (int i = 0; i < pdcCount; i++) {
			    stream.writeObject(null);
		    }
	    } else {
		    writeValueV(stream, operation.getPdc().getPdc1());
		    writeValueV(stream, operation.getPdc().getPdc2());
		    writeValueV(stream, operation.getPdc().getPdc3());
		    writeValueV(stream, operation.getPdc().getPdc4());
		    writeValueV(stream, operation.getPdc().getPdc5());
		    writeValueV(stream, operation.getPdc().getPdc6());
		    writeValueV(stream, operation.getPdc().getPdc7());
		    writeValueV(stream, operation.getPdc().getPdc8());
		    writeValueV(stream, operation.getPdc().getPdc9());
		    writeValueV(stream, operation.getPdc().getPdc10());
		    writeValueV(stream, operation.getPdc().getPdc11());
		    writeValueV(stream, operation.getPdc().getPdc12());
	    }

	    writeValueV(stream, operation.getForwInstCode());
	    writeValueV(stream, operation.getReceivInstCode());
	    writeValueT(stream, operation.getSttlDate());
	    writeValueV(stream, operation.getOperReason());
	    writeValueV(stream, operation.getArn());
    }
}
