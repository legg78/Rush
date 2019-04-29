package ru.bpc.sv2.scheduler.process.svng.reconciliation;

import ru.bpc.sv2.common.SQLDataRec;
import ru.bpc.sv2.reconciliation.export.atm.ReconciliationATM;
import ru.bpc.sv2.utils.AuthOracleTypeNames;

import java.sql.*;

public class ReconciliationATMRec extends SQLDataRec {
    private ReconciliationATM reconciliationATM;

    public ReconciliationATMRec(ReconciliationATM reconciliationATM, Connection con) {
        this.reconciliationATM = reconciliationATM;
        setConnection(con);
    }

    @Override
    public String getSQLTypeName() throws SQLException {
        return AuthOracleTypeNames.RCN_ATM_RECON_MSG_REC;
    }
    @Override
    public void writeSQL(SQLOutput stream) throws SQLException {
        writeValueN(stream, reconciliationATM.getId());
        writeValueV(stream, reconciliationATM.getOperType());
        writeValueT(stream, reconciliationATM.getOperDate());
        writeValueN(stream, reconciliationATM.getOperAmount());
        writeValueV(stream, reconciliationATM.getOperCurrency());
        writeValueV(stream, reconciliationATM.getTraceNumber());
        writeValueN(stream, reconciliationATM.getAcqInstId());
        writeValueV(stream, reconciliationATM.getCardNumber());
        writeValueV(stream, reconciliationATM.getAuthCode());
        writeValueN(stream, reconciliationATM.isReversal() ? 1 : 0);
        writeValueV(stream, reconciliationATM.getTerminalType());
        writeValueV(stream, reconciliationATM.getTerminalNum());
        writeValueN(stream, reconciliationATM.getIssFee());
        writeValueV(stream, reconciliationATM.getAccFrom());
        writeValueV(stream, reconciliationATM.getAccTo());
    }
}
