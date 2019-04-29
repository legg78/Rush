package ru.bpc.sv2.operations.incoming;

import java.sql.SQLData;
import java.sql.SQLException;
import java.sql.SQLInput;
import java.sql.SQLOutput;
import java.util.Calendar;
import java.util.Date;
import java.util.GregorianCalendar;

import ru.bpc.sv2.common.SQLDataRec;
import ru.bpc.sv2.utils.AuthOracleTypeNames;

public class OperationReconciliationRec extends SQLDataRec {
	private final OperationReconciliation oper;

	public OperationReconciliationRec(OperationReconciliation oper) {
		this.oper = oper;
	}

	@Override
	public String getSQLTypeName() throws SQLException {
		return AuthOracleTypeNames.CST_BASE24_OPERATION_RECONCILATION_REC;
	}

	@Override
	public void writeSQL(SQLOutput stream) throws SQLException {
		writeValueV(stream, oper.getOperType());
		writeValueV(stream, oper.getTerminalNumber());
		writeValueN(stream, oper.getOperationAmount());
		writeValueN(stream, oper.getOperCount());
	}
}