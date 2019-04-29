package ru.bpc.sv2.scheduler.process;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

import ru.bpc.sv2.utils.SystemException;

public class AccountResolver {
	private static final String ACCOUNT_ID_QUERY = "select id, inst_id from acc_account where account_number = ?";
	private String accountNumber;
	private Long accountId;
	private Integer instId;
	private Connection con;
	
	public AccountResolver(String accountNumber, Connection con){
		this.accountNumber = accountNumber;
		this.con = con;
	}
	
	public void resolve() throws SystemException{
		PreparedStatement stmt = null;
		ResultSet rs = null;
		try {
			stmt = con.prepareStatement(ACCOUNT_ID_QUERY);
			stmt.setString(1, accountNumber);
			rs = stmt.executeQuery();
			if (rs.next()){
				accountId = rs.getLong(1);
				instId = rs.getInt(2);
			}
			rs.close();
		} catch (SQLException e){
			throw new SystemException("An error occured while executing SQL query");
		}
	}
	
	public Long getAccountId(){
		return accountId;
	}
	
	public Integer getInstId(){
		return instId;
	}
}