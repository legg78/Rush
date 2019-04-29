package ru.bpc.sv2.scheduler.process;

import com.ibatis.sqlmap.client.SqlMapSession;
import oracle.sql.ARRAY;
import oracle.sql.ArrayDescriptor;
import org.apache.commons.vfs.FileObject;
import org.apache.log4j.Level;
import org.apache.log4j.Logger;
import ru.bpc.sv2.process.ProcessBO;
import ru.bpc.sv2.process.ProcessFileAttribute;
import ru.bpc.sv2.process.file.SimpleFileRec;
import ru.bpc.sv2.scheduler.process.converter.FileConverter;
import ru.bpc.sv2.settings.constants.SettingsConstants;
import ru.bpc.sv2.ui.utils.cache.SettingsCache;
import ru.bpc.sv2.utils.AuthOracleTypeNames;
import ru.bpc.sv2.utils.DBUtils;

import java.io.BufferedReader;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.sql.CallableStatement;
import java.sql.Connection;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

public class StoplistFileSaver implements FileSaver {
	private static final Logger logger = Logger.getLogger("PROCESSES");

	FileConverter converter 			= null;
	Connection con						= null;
	ProcessFileAttribute fileAttributes = null;
	FileObject fileObject 				= null;
	InputStream inputStream 			= null;
	
	private final int NUM_IN_BATCH = 10000;

	private Integer traceLevel;
	private Integer traceLimit;
	private Integer traceThreadNumber;

	@Override
	public void save() throws Exception {
		setupTracelevel();

		long curtime = System.currentTimeMillis();
		
		BufferedReader br = new BufferedReader(new InputStreamReader(inputStream));
		converter = getConverter();
		
		String strLine;

			List<SimpleFileRec> rawsAsArray = new ArrayList<SimpleFileRec>();
			List<Integer> recNumList = new ArrayList<Integer>();
			ArrayDescriptor transactionsDescriptor;			
			ArrayDescriptor transactionsDescriptor1;
			
			int i=0;
			int num=1;
			int num_in_batch = NUM_IN_BATCH; //TODO Make a constant
			long batchtime = System.currentTimeMillis();
			long batchexec;
			while ((strLine = br.readLine()) != null) {
				
				if (i==0) {
					batchtime = System.currentTimeMillis();
				}
				if (converter != null) {
//					long convTime = System.currentTimeMillis();
					strLine = converter.convertByteArrayToString(strLine.getBytes());
//					System.out.println("Covert string time:" + (System.currentTimeMillis() - convTime));
				}
				String[] raw = strLine.split(";");
				if (raw.length == 3) {
					strLine = raw[1] +"_" +raw[0] + "_" + raw[1] + "_" + raw[2];
				}
				rawsAsArray.add(new SimpleFileRec(strLine));
				recNumList.add(num);
//				ssn.insert("process.put-line", map);
				i++;
				if (i == num_in_batch) {
					batchexec = System.currentTimeMillis() - batchtime;
					System.out.println("batch created in :" + batchexec );
					
					batchexec = System.currentTimeMillis();
					
					ARRAY oracleRecNums = DBUtils.createArray( AuthOracleTypeNames.PRC_SESSION_FILE_RECNUM_TAB, con, recNumList.toArray(new Integer[recNumList.size()]));
					ARRAY oracleRawData = DBUtils.createArray( AuthOracleTypeNames.PRC_SESSION_FILE_RAW_TAB, con,  rawsAsArray.toArray(new SimpleFileRec[rawsAsArray.size()]));
					CallableStatement cstmt = null;
					try {
						cstmt = con.prepareCall("{call prc_api_file_pkg.put_bulk_web(?,?,?)}");
						cstmt.setInt(1, fileAttributes.getSessionId().intValue());

						cstmt.setArray(2, oracleRawData);
						cstmt.setArray(3, oracleRecNums);
						cstmt.execute();
					}finally {
						DBUtils.close(cstmt);
					}

					rawsAsArray.clear();
					recNumList.clear();
					i=0;
				}
				num++;
			}
			br.close();
			if (i>0) {
				ARRAY oracleRecNums = DBUtils.createArray( AuthOracleTypeNames.PRC_SESSION_FILE_RECNUM_TAB, con, recNumList.toArray(new Integer[recNumList.size()]));
				ARRAY oracleRawData = DBUtils.createArray( AuthOracleTypeNames.PRC_SESSION_FILE_RAW_TAB, con,  rawsAsArray.toArray(new SimpleFileRec[rawsAsArray.size()]));

				CallableStatement cstmt = null;
				try {
					cstmt = con.prepareCall("{call prc_api_file_pkg.put_bulk_web(?,?,?)}");
					cstmt.setInt(1, fileAttributes.getSessionId().intValue());
					cstmt.setArray(2, oracleRawData);
					cstmt.setArray(3, oracleRecNums);
					cstmt.execute();
				}finally {
					DBUtils.close(cstmt);
				}

				rawsAsArray.clear();
				recNumList.clear();
			}		
		
		System.out.println("Saved in time: " + (System.currentTimeMillis() - curtime));
	}

	private Level getTraceLevel(int dbLevel) {
		switch (dbLevel) {
			case 6: return Level.TRACE;
			case 5: return Level.INFO;
			case 4: return Level.WARN;
			case 3: return Level.ERROR;
			case 2: return Level.FATAL;
			case 1: return Level.OFF;
			default: return Level.INFO;
		}
	}

	public FileConverter getConverter() {
		return converter;
	}

	public void setConverter(FileConverter converter) {
		this.converter = converter;
	}

	public Connection getConnection() {
		return con;
	}

	public void setConnection(Connection con) {
		this.con = con;
	}

	public ProcessFileAttribute getFileAttributes() {
		return fileAttributes;
	}

	public void setFileAttributes(ProcessFileAttribute fileAttributes) {
		this.fileAttributes = fileAttributes;
	}

	public FileObject getFileObject() {
		return fileObject;
	}

	public void setFileObject(FileObject fileObject) {
		this.fileObject = fileObject;
	}

	public InputStream getInputStream() {
		return inputStream;
	}

	public void setInputStream(InputStream inputStream) {
		this.inputStream = inputStream;
	}
	
	public void setSsn(SqlMapSession ssn) {		
	}
	
	@Override
	public void setThreadNum(int threadNum) {
	}
	
	@Override
	public void setParams(Map<String, Object> params) {
	}

	@Override
	public Map<String, Object> getOutParams() {
		return null;
	}


	@Override
	public void setUserSessionId(Long userSessionId) {
		// TODO Auto-generated method stub
		
	}


	@Override
	public void setSessionId(Long sessionId) {
		// TODO Auto-generated method stub
		
	}

	@Override
	public void setUserName(String userName) {
		// TODO Auto-generated method stub
	}

	@Override
	public boolean isRequiredInFiles() {
		return true;
	}

	@Override
	public boolean isRequiredOutFiles() {
		// TODO Auto-generated method stub
		return true;
	}


	@Override
	public void setProcess(ProcessBO proc) {
		// TODO Auto-generated method stub
		
	}

	@Override
	public void setTraceLevel(Integer traceLevel) {
		this.traceLevel = traceLevel;
	}

	@Override
	public void setTraceLimit(Integer traceLimit) {
		this.traceLimit = traceLimit;
	}

	@Override
	public void setTraceThreadNumber(Integer traceThreadNumber) {
		this.traceThreadNumber = traceThreadNumber;
	}

	private void setupTracelevel() {
		Integer level = traceLevel;
		if (level == null) {
			level = SettingsCache.getInstance().getParameterNumberValue(SettingsConstants.TRACE_LEVEL).intValue();
		}
		logger.setLevel(getTraceLevel(level));
	}
}
