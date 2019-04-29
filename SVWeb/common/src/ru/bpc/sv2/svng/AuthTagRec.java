package ru.bpc.sv2.svng;

import java.sql.Connection;
import java.sql.SQLException;
import java.sql.SQLOutput;
import ru.bpc.sv2.common.SQLDataRec;
import ru.bpc.sv2.utils.AuthOracleTypeNames;
import ru.bpc.sv2.utils.DBUtils;

/**
 * BPC Group 2018 (c) All Rights Reserved
 */
public class AuthTagRec extends SQLDataRec {
	private final AuthTag authTag;

	public AuthTagRec(AuthTag authTag, Connection c) {
		this.authTag = authTag;
		setConnection(DBUtils.getNativeConnection(c));
	}

	@Override
	public String getSQLTypeName() throws SQLException {
		return AuthOracleTypeNames.AUTH_TAG_REC;
	}

	@Override
	public void writeSQL(SQLOutput s) throws SQLException {
		writeValueN(s, authTag.getOperId());	// oper_id      number(16)
		writeValueN(s, authTag.getTagId());		// tag_id       number(8)
		writeValueV(s, authTag.getTagValue());	// tag_value    varchar2(2000)
		writeValueV(s, authTag.getTagName());	// tag_name     varchar2(4000)
	}
}
