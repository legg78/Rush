package ru.bpc.sv2.scheduler.process.svng.reconciliation;

import oracle.sql.CLOB;
import oracle.sql.OracleSQLOutput;
import oracle.xdb.XMLType;
import org.apache.commons.lang3.StringUtils;
import ru.bpc.sv.svxp.reconciliation.SettleOperationType;
import ru.bpc.sv2.common.SQLDataRec;
import ru.bpc.sv2.utils.AuthOracleTypeNames;

import javax.xml.datatype.XMLGregorianCalendar;
import java.io.IOException;
import java.io.Writer;
import java.math.BigDecimal;
import java.sql.*;

public class NationalSwitchReconRec extends SQLDataRec {
    private SettleOperationType operation;
    private Integer inst_id;

    public NationalSwitchReconRec(SettleOperationType operation, Connection con, Integer inst_id) {
        this.operation = operation;
        this.inst_id = inst_id;
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
        writeValueN(stream, (BigDecimal) null); //OperSurchargeAmount.AmountValue
        writeValueV(stream, (String) null);     //OperSurchargeAmount.Currency
        writeValueV(stream, (String) null);     //Status
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
        writeValueN(stream, (BigDecimal) null); //AcqInstId
        writeValueN(stream, (BigDecimal) null); //OperCashbackAmount.AmountValue
        writeValueV(stream, (String) null);     //OperCashbackAmount.Currency
        writeValueV(stream, (String) null);     //ServiceCode
        writeValueV(stream, operation.getAuthCode() );//ApprovalCode
        writeValueV(stream, operation.getOriginatorRefnum());//Rrn
        writeValueV(stream, (String) null);     //Trn
        writeValueV(stream, (String) null);     //OriginalId
        writeValueN(stream, (BigDecimal) null); //Emv5F2A
        writeValueN(stream, (BigDecimal) null); //Emv5F34
        writeValueV(stream, (String) null);     //Emv71
        writeValueV(stream, (String) null);     //Emv72
        writeValueV(stream, (String) null);     //Emv82
        writeValueV(stream, (String) null);     //Emv84
        writeValueV(stream, (String) null);     //Emv8A
        writeValueV(stream, (String) null);     //Emv91
        writeValueV(stream, (String) null);     //Emv95
        writeValueN(stream, (BigDecimal) null); //Emv9A
        writeValueN(stream, (BigDecimal) null); //Emv9C
        writeValueN(stream, (BigDecimal) null); //Emv9F02
        writeValueN(stream, (BigDecimal) null); //tEmv9F03
        writeValueV(stream, (String) null);     //Emv9F06
        writeValueV(stream, (String) null);     //Emv9F09
        writeValueV(stream, (String) null);     //Emv9F10
        writeValueV(stream, (String) null);     //Emv9F18
        writeValueN(stream, (BigDecimal) null); //tEmv9F1A
        writeValueV(stream, (String) null);     //Emv9F1E
        writeValueV(stream, (String) null);     //Emv9F26
        writeValueV(stream, (String) null);     //Emv9F27
        writeValueV(stream, (String) null);     //Emv9F28
        writeValueV(stream, (String) null);     //Emv9F29
        writeValueV(stream, (String) null);     //Emv9F33
        writeValueV(stream, (String) null);     //Emv9F34
        writeValueN(stream, (BigDecimal) null); //Emv9F35
        writeValueV(stream, (String) null);     //Emv9F36
        writeValueV(stream, (String) null);     //Emv9F37
        writeValueN(stream, (BigDecimal) null); //Emv9F41
        writeValueV(stream, (String) null);     //Emv9F53
        writeValueV(stream, (String) null);     //Pdc1
        writeValueV(stream, (String) null);     //Pdc2
        writeValueV(stream, (String) null);     //Pdc3
        writeValueV(stream, (String) null);     //Pdc4
        writeValueV(stream, (String) null);     //Pdc5
        writeValueV(stream, (String) null);     //Pdc6
        writeValueV(stream, (String) null);     //Pdc7
        writeValueV(stream, (String) null);     //Pdc8
        writeValueV(stream, (String) null);     //Pdc9
        writeValueV(stream, (String) null);     //Pdc10
        writeValueV(stream, (String) null);     //Pdc11
        writeValueV(stream, (String) null);     //Pdc12
        writeValueV(stream, (String) null);     //ForwInstCode
        writeValueV(stream, this.inst_id.toString());//ReceivInstCode
        writeValueT(stream, operation.getSttlDate());
        writeValueV(stream, operation.getOperReason());
        writeValueV(stream, operation.getNetworkRefnum());//Arn
    }
}
