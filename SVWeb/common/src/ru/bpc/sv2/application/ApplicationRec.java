package ru.bpc.sv2.application;

import ru.bpc.sv2.common.SQLDataRec;
import ru.bpc.sv2.utils.AuthOracleTypeNames;

import java.io.Serializable;
import java.math.BigDecimal;
import java.sql.SQLData;
import java.sql.SQLException;
import java.sql.SQLInput;
import java.sql.SQLOutput;
import java.util.Date;

public class ApplicationRec extends SQLDataRec implements Serializable {
	private final ApplicationElement _applElement;

	public ApplicationRec( ApplicationElement applElement) {
		_applElement = applElement;
		if (_applElement.getValue() == null) {
			_applElement.setValue("");
		}
		if (!_applElement.isMultiLang()) {
			_applElement.setValueLang(null);
		}
	}

	@Override
	public String getSQLTypeName() throws SQLException {
		return AuthOracleTypeNames.APP_DATA_REC;
	}

	public void writeSQL(SQLOutput stream) throws SQLException {
		// appl_data_id							number,			1
		writeValueN(stream, _applElement.getDataId() );
		// element_id							number,			2
		writeValueN(stream,  _applElement.getId() );
		// parent_id							number,			3
		writeValueN(stream,  _applElement.getParentDataId() );
		// seq_number							number,			4
		writeValueN(stream, _applElement.getInnerId() );
		// valueV								varchar,		5
		writeValueV(stream, _applElement.getValueV());
		// valueD								date,			6
		writeValueT(stream, _applElement.getValueD());
		// valueN								number,			7
		writeValueN(stream, _applElement.getValueN());
		// lang									varchar,		8
		writeValueV(stream, _applElement.getValueLang());
	}
}