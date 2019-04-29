package ru.bpc.sv2.scheduler.process;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.Date;

import ru.bpc.sv2.utils.SystemException;

public class DocumentResolver {
	private static final String DOCUMENT_ID_QUERY = "select id, inst_id from rpt_document_vw where " +
			"document_number = ? " +
			"and document_date = ?" +
			"and document_type = ?";
	private String documentNumber;
	private Date documentDate;
	private Long documentId;
	private String documentType;
	private Connection con;
	
	public DocumentResolver(String documentNumber, Date documentDate, Connection con){
		this.documentNumber = documentNumber;
		this.documentDate = documentDate;
		this.con = con;
	}
	
	public void resolve() throws SystemException{
		PreparedStatement stmt = null;
		ResultSet rs = null;
		try {
			stmt = con.prepareStatement(DOCUMENT_ID_QUERY);
			stmt.setString(1, documentNumber);
			stmt.setDate(2, new java.sql.Date(documentDate.getTime()));
			stmt.setString(3, documentType);
			rs = stmt.executeQuery();
			if (rs.next()){
				documentId = rs.getLong(1);
			}
			rs.close();
		} catch (SQLException e){
			throw new SystemException("An error occured while executing SQL query");
		}
	}
	
	public Long getDocumentId(){
		return documentId;
	}

	public void setDocumentType(String documentType) {
		this.documentType = documentType;
	}
	
}