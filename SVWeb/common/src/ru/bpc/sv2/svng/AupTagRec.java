package ru.bpc.sv2.svng;

import ru.bpc.sv2.common.SQLDataRec;
import ru.bpc.sv2.utils.AuthOracleTypeNames;
import ru.bpc.sv2.utils.DBUtils;

import java.sql.Connection;
import java.sql.SQLException;
import java.sql.SQLOutput;

/**
 * BPC Group 2018 (c) All Rights Reserved
 */
public class AupTagRec extends SQLDataRec {
	private final AupTag aupTag;

	public AupTagRec(AupTag aupTag, Connection c) {
		this.aupTag = aupTag;
		setConnection(DBUtils.getNativeConnection(c));
	}

	@Override
	public String getSQLTypeName() throws SQLException {
		return AuthOracleTypeNames.AUP_TAG_REC;
	}

	@Override
	public void writeSQL(SQLOutput s) throws SQLException {
		writeValueN(s, aupTag.getTagId());		// tag_id       number(8)
		writeValueV(s, aupTag.getTagValue());	// tag_value    varchar2(2000)
		writeValueV(s, aupTag.getTagName());	// tag_name     varchar2(4000)
		writeValueN(s, aupTag.getSeqNumber());	// seq_number   number(4)
	}
}
