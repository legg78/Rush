package ru.bpc.sv2.scheduler.process.svng.reconciliation;

import oracle.sql.ARRAY;
import oracle.sql.ArrayDescriptor;
import oracle.sql.CLOB;
import oracle.sql.OracleSQLOutput;
import oracle.xdb.XMLType;
import org.apache.commons.lang3.StringUtils;
import ru.bpc.sv.svxp.reconciliation.AmountType;
import ru.bpc.sv.svxp.reconciliation.OperationType;
import ru.bpc.sv2.common.SQLDataRec;
import ru.bpc.sv2.utils.AuthOracleTypeNames;

import javax.xml.datatype.XMLGregorianCalendar;
import java.io.Writer;
import java.math.BigDecimal;
import java.sql.*;
import java.util.*;
import java.util.Date;

public class ReconciliationRec extends SQLDataRec {
    private OperationType operation;

    public ReconciliationRec(OperationType operation, Connection con) {
        this.operation = operation;
        setConnection(con);
    }

    @Override
    public String getSQLTypeName() throws SQLException {
        return AuthOracleTypeNames.RCN_RECON_MSG_REC;
    }
    @Override
    public void writeSQL(SQLOutput stream) throws SQLException {
        writeValueV(stream, operation.getOperType());
        writeValueV(stream, operation.getMsgType());
        writeValueV(stream, operation.getSttlType());
        writeValueT(stream, operation.getOperDate());
        writeValueN(stream, (operation.getOperAmount() != null) ? operation.getOperAmount().getAmountValue() : null);
        writeValueV(stream, (operation.getOperAmount() != null) ? operation.getOperAmount().getCurrency() : null);
        writeValueN(stream, (operation.getOperRequestAmount() != null) ? operation.getOperRequestAmount().getAmountValue() : null);
        writeValueV(stream, (operation.getOperRequestAmount() != null) ? operation.getOperRequestAmount().getCurrency() : null);
        writeValueN(stream, (operation.getOperSurchargeAmount() != null) ? operation.getOperSurchargeAmount().getAmountValue() : null);
        writeValueV(stream, (operation.getOperSurchargeAmount() != null) ? operation.getOperSurchargeAmount().getCurrency() : null);
        writeValueV(stream, operation.getOriginatorRefnum());
        writeValueV(stream, operation.getNetworkRefnum());
        writeValueV(stream, operation.getAcqInstBin());
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
        writeValueV(stream, operation.getCardCountry());
        writeValueN(stream, operation.getAcqInstId());
        writeValueN(stream, operation.getIssInstId());
        writeValueV(stream, operation.getAuthCode());
        writeValueA(stream, operation.getAdditionalAmount());
    }

    private void writeValueA(SQLOutput stream, List<AmountType> table) throws SQLException {
        if (table == null || table.size() == 0) {
            stream.writeObject(null);
        } else {
            List<AmountRec> list = new ArrayList<AmountRec>(table.size());
            for (AmountType amount : table) {
                list.add(new AmountRec(amount.getAmountValue(), amount.getCurrency(), amount.getAmountType()));
            }
            ArrayDescriptor tab = ArrayDescriptor.createDescriptor(AuthOracleTypeNames.RCN_ADDL_AMOUNT_TAB, connection);
            stream.writeArray(new ARRAY(tab, connection, list.toArray(new AmountRec[list.size()])));
        }
    }
}
