package ru.bpc.sv2.scheduler.process.utils;

import oracle.sql.ARRAY;
import ru.bpc.sv2.process.file.SimpleFileRec;
import ru.bpc.sv2.utils.AuthOracleTypeNames;
import ru.bpc.sv2.utils.DBUtils;

import java.sql.CallableStatement;
import java.sql.Connection;
import java.util.ArrayList;
import java.util.List;

public class FlatFileSaver {

	private List<String> lines;
	private Connection con;
	private Long fileSessionId;
	
	public void setLines(List<String> lines){
		this.lines = lines;
	}
	
	public void setConnection(Connection con){
		this.con = con;
	}
	
	public void setFileSessionId(Long fileSessionId){
		this.fileSessionId = fileSessionId;
	}
	
	private void checkMandatoryFields(){
		if (lines == null ||
				con == null ||
				fileSessionId == null){
			throw new IllegalStateException("One of the mandatory fields isn't defined!");
		}
	}
	
	public void save(){
		checkMandatoryFields();
		List<SimpleFileRec> rawsAsArray = new ArrayList<SimpleFileRec>();
		List<Integer> recNumList = new ArrayList<Integer>();
		int i = 0;
		int num = 1;
		int batchSize = 1000;
		for (String line : lines){
			rawsAsArray.add(new SimpleFileRec(line));
			recNumList.add(num++);
			i++;			
			if (i == batchSize || (num == lines.size() + 1)){
				try{
					ARRAY oracleRecNums = DBUtils.createArray(AuthOracleTypeNames.PRC_SESSION_FILE_RECNUM_TAB, con,
							recNumList.toArray(new Integer[recNumList.size()]));
					ARRAY oracleRawData = DBUtils.createArray(AuthOracleTypeNames.PRC_SESSION_FILE_RAW_TAB, con,
							rawsAsArray.toArray(new SimpleFileRec[rawsAsArray.size()]));

					CallableStatement cstmt = null;
					try {
						cstmt = con
								.prepareCall("{call prc_api_file_pkg.put_bulk_web(?,?,?)}");
						cstmt.setLong(1, fileSessionId);

						cstmt.setArray(2, oracleRawData);
						cstmt.setArray(3, oracleRecNums);
						cstmt.execute();
					}finally {
						DBUtils.close(cstmt);
					}

				} catch (Exception ignored){
					
				}
				rawsAsArray.clear();
				recNumList.clear();
				i = 0;
			}
		}
	}
	
}
