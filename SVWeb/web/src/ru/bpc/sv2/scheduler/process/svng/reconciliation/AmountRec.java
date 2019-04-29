package ru.bpc.sv2.scheduler.process.svng.reconciliation;

import ru.bpc.sv2.common.SQLDataRec;
import ru.bpc.sv2.utils.AuthOracleTypeNames;

import java.math.BigDecimal;
import java.sql.SQLException;
import java.sql.SQLOutput;
import java.util.Date;

public class AmountRec extends SQLDataRec {
    private String type;
    private Long value;
    private String currency;

    public AmountRec(Long value, String currency) {
        this.value = value;
        this.currency = currency;
        this.type = null;
    }
    public AmountRec(Long value, String currency, String type) {
        this.value = value;
        this.currency = currency;
        this.type = type;
    }

    @Override
    public String getSQLTypeName() throws SQLException {
        return AuthOracleTypeNames.RCN_ADDL_AMOUNT_REC;
    }
    @Override
    public void writeSQL(SQLOutput stream) throws SQLException {
        // amount_value		number		1
        writeValueN(stream, getValue());
        // currency			varchar2	2
        writeValueV(stream, getCurrency());
        // amount_type		varchar2	3
        writeValueV(stream, getType());
    }

    public String getType() {
        return type;
    }
    public void setType(String type) {
        this.type = type;
    }

    public Long getValue() {
        return value;
    }
    public void setValue(Long value) {
        this.value = value;
    }

    public String getCurrency() {
        return currency;
    }
    public void setCurrency(String currency) {
        this.currency = currency;
    }
}
