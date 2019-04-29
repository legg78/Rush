package ru.bpc.sv2.scheduler.process;

import com.ibatis.sqlmap.client.SqlMapSession;
import oracle.sql.ARRAY;
import oracle.sql.ArrayDescriptor;
import org.apache.commons.vfs.FileObject;
import org.apache.log4j.Level;
import org.apache.log4j.Logger;
import ru.bpc.sv2.operations.OperationRec;
import ru.bpc.sv2.operations.incoming.Operation;
import ru.bpc.sv2.operations.incoming.posting.Authorization;
import ru.bpc.sv2.operations.incoming.posting.Authorizations;
import ru.bpc.sv2.process.ProcessBO;
import ru.bpc.sv2.process.ProcessFileAttribute;
import ru.bpc.sv2.scheduler.process.converter.FileConverter;
import ru.bpc.sv2.settings.constants.SettingsConstants;
import ru.bpc.sv2.ui.utils.cache.SettingsCache;
import ru.bpc.sv2.utils.AuthOracleTypeNames;
import ru.bpc.sv2.utils.DBUtils;

import javax.xml.bind.JAXBContext;
import javax.xml.bind.JAXBElement;
import javax.xml.bind.Unmarshaller;
import java.io.InputStream;
import java.math.BigDecimal;
import java.sql.*;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.Map;

public class OperationsFileSaver implements FileSaver {

	FileConverter converter 			= null;
	Connection con						= null;
	ProcessFileAttribute fileAttributes = null;
	FileObject fileObject 				= null;
	InputStream inputStream 			= null;
	private int threadNum = 1;
	
	private static final Logger logger = Logger.getLogger("PROCESSES");

	private String tmpLocation = "./test/convertTmp";
	
	private final int NUM_IN_BATCH = 1000;
	
	private final int THREADS = 1;

	private Integer traceLevel;
	private Integer traceLimit;
	private Integer traceThreadNumber;

	@SuppressWarnings("unchecked")
	@Override
	public void save() throws Exception {
		setupTracelevel();

		CallableStatement cstmt = null;
		try {
			tmpLocation += fileObject.getName().getBaseName();
			
			if (converter != null) {
				convert();
				inputStream = converter.getInputStream();
			}
			
			long curtime = System.currentTimeMillis();
			
			cstmt = con.prepareCall("{call cst_prc_base24_pkg.create_operations(io_operation_tab => ?)}");
			int i=0;
			List<OperationRec> rawsAsArray = new ArrayList<OperationRec>();
			List<Integer> recNumList = new ArrayList<Integer>();
			ArrayDescriptor transactionsDescriptor;			
			
			int modNum = threadNum  % THREADS;
			int num=0; //line number 
			int num_in_batch = NUM_IN_BATCH;
			
			JAXBContext jc = JAXBContext.newInstance( "ru.bpc.sv2.operations.incoming.posting" );
			Unmarshaller u = jc.createUnmarshaller();
			Authorizations authorizations = (Authorizations)((JAXBElement<Authorizations>)u.unmarshal(inputStream)).getValue();
			List<Authorization> auths = authorizations.getAuthorization();
			System.out.println("Time taken to unmarshal: " + (System.currentTimeMillis() - curtime));
			for (Authorization auth : auths) {
				num++;
				try {
					if (num % THREADS != modNum) {
						continue;
					}
					cstmt.clearParameters();
					
					rawsAsArray.add(new OperationRec(auth));
					recNumList.add(num);
					i++;
					if (i == num_in_batch) {
						ARRAY oracleRawData = DBUtils.createArray( AuthOracleTypeNames.OPR_OPERATION_TAB, con,  rawsAsArray.toArray(new OperationRec[rawsAsArray.size()]));
						cstmt.setArray(1, oracleRawData);
						cstmt.execute();						
						rawsAsArray.clear();
						recNumList.clear();
						i=0;					
					}					
				} catch (Exception e) {
					logger.error("line " + i + "; " +e.getMessage());					
				}	    		
			}
			if (i>0) {
				ARRAY oracleRawData = DBUtils.createArray( AuthOracleTypeNames.OPR_OPERATION_TAB, con,  rawsAsArray.toArray(new OperationRec[rawsAsArray.size()]));
				cstmt.clearParameters();
				cstmt.setArray(1, oracleRawData);
				cstmt.execute();
				rawsAsArray.clear();
				recNumList.clear();
			}
			
			System.out.println("Saved in time: " + (System.currentTimeMillis() - curtime));
		} finally {
			if (cstmt != null) {
				cstmt.close();
			}	
			//TODO here you must close inputStream of local tmp file
			inputStream.close();
			fileObject.close();
		}
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

	@SuppressWarnings("unused")
	private void addOperation(PreparedStatement stmt, Operation oper) 
	throws SQLException {
		
		setLong( stmt, 1, oper.getId() );
		
		setInteger( stmt, 2, oper.getSplitHash() );
    	
		setLong( stmt, 3, oper.getSessionId());
		
		setBoolean( stmt, 4, oper.isReversal() );
		
		setLong( stmt, 5, oper.getOriginalId() );
		
		setString( stmt, 6, oper.getOperType() );
		
		setString( stmt, 7, oper.getOperReason() );
		
		setString( stmt, 8, oper.getMsgType() );
		
		setString( stmt, 9, oper.getStatus() );
		
		setString( stmt, 10, oper.getStatusReason() );
		
		setString( stmt, 11, oper.getSttlType() );
		
		setInteger( stmt, 12, oper.getAcqInstId() );
    	
		setInteger( stmt, 13, oper.getAcqNetworkId() );
    	
    	setInteger( stmt, 14, oper.getSplitHashAcq() );
    	
    	setString( stmt, 15, oper.getTerminalType() );
    	
    	setString( stmt, 16, oper.getAcqInstBin() );
    	
    	setString( stmt, 17, oper.getForwInstBin() );
    	
    	setInteger( stmt, 18, oper.getMerchantId() ) ;
    	
    	setString( stmt, 19, oper.getMerchantNumber() );
		
    	setInteger( stmt, 20, oper.getTerminalId() );
		
		setString( stmt, 21, oper.getTerminalNumber() );
		
		setString( stmt, 22, oper.getMerchantName() );
		
		setString( stmt, 23, oper.getMerchantStreet() );
		
		setString( stmt, 24, oper.getMerchantCity() );
		
		setString( stmt, 25, oper.getMerchantRegion() );
		
		setString( stmt, 26, oper.getMerchantCountryCode() );
		
		setString( stmt, 27, oper.getMerchantPostCode() );
		
		setString( stmt, 28, oper.getMccCode() );
		
		setString( stmt, 29, oper.getRefnum() );
		
		setString( stmt, 30, oper.getNetworkRefnum() );
		
		setString( stmt, 31, oper.getAuthCode() );
		
		setBigDecimal( stmt, 32, oper.getOperationRequestAmount() );
		
		setBigDecimal( stmt, 33, oper.getOperationAmount() );
		
		setString( stmt, 34, oper.getOperationCurrency() );
		
		setBigDecimal( stmt, 35, oper.getOperationCashbackAmount() );
		
		setBigDecimal( stmt, 36, oper.getOperationReplacementAmount() );
		
		setBigDecimal( stmt, 37, oper.getOperationSurchargeAmount() );
		
		setDate( stmt, 38, oper.getOperationDate() );
		
		setDate( stmt, 39, oper.getSourceHostDate() );
		
		setInteger( stmt, 40, oper.getIssInstId() );
		
		setInteger( stmt, 41, oper.getIssNetworkId() );
		
		setInteger( stmt, 42, oper.getSplitHashIss() );
		
		setInteger( stmt, 43, oper.getCardInstId() );
		
		setInteger( stmt, 44, oper.getCardNetworkId() );
		
		setString( stmt, 45, oper.getCardNumber() );
    	
    	setLong( stmt, 46, oper.getCardId() );
    	
		setInteger( stmt, 47, oper.getCardTypeId() );
		
		setString( stmt, 48, oper.getCardMask() );
    	
    	setLong( stmt, 49, oper.getCardHash() );
    	
		setInteger( stmt, 50, oper.getCardSeqNumber() );
		
		setDate( stmt, 51, oper.getCardExpirationDate() );
    
		setString( stmt, 52, oper.getCardCountry() );
		
		setString( stmt, 53, oper.getAccountType() );
		
		setString( stmt, 54, oper.getAccountNumber() );
		
		setBigDecimal( stmt, 55, oper.getAccountAmount() );
		
		setString( stmt, 56, oper.getAccountCurrency() );
		
		setString( stmt, 57, oper.getMatchStatus() );
		
		setLong( stmt, 58, oper.getAuthId() );
		
		setBigDecimal( stmt, 59, oper.getSttlAmount() );
		
		setString( stmt, 60, oper.getSttlCurrency() );
		
		setLong( stmt, 61, oper.getDisputeId() );
	}
	
	private void convert() 
	throws Exception{
		converter.setInputStream(inputStream);
		converter.setFileObject(fileObject);
		converter.setFileAttributes(fileAttributes);
		converter.setLocation(tmpLocation);
		converter.convertFile();
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
	
	
	private void setBoolean( PreparedStatement stmt, int i, boolean value )
	throws SQLException {
		stmt.setInt( i, ( value == true ? 1: 0 ) );
	}
	
	private void setDate( PreparedStatement stmt, int i, Date date )
	throws SQLException {
		if ( date != null ) {
			//stmt.setNull( i, Types.DATE );
			stmt.setDate( i, new java.sql.Date(date.getTime()));
		} else {
			stmt.setNull( i, Types.DATE );
		}
	}
	
	private void setInteger( PreparedStatement stmt, int i, Integer value )
	throws SQLException {
		if ( value != null ) {
			stmt.setInt( i, value );
		} else {
			stmt.setNull( i, Types.INTEGER );
		}
	}
	
	private void setLong( PreparedStatement stmt, int i, Long value )
	throws SQLException {
		if ( value != null ) {
			stmt.setLong( i, value );
		} else {
			stmt.setNull( i, Types.BIGINT );
		}
	}
	
	private void setDouble( PreparedStatement stmt, int i, Double value )
	throws SQLException {
		if ( value != null ) {
			stmt.setDouble( i, value );
		} else {
			stmt.setNull( i, Types.DOUBLE );
		}
	}
	
	private void setBigDecimal( PreparedStatement stmt, int i, BigDecimal value )
	throws SQLException {
		if ( value != null ) {
			stmt.setBigDecimal( i, value );
		} else {
			stmt.setNull( i, Types.NUMERIC );
		}
	}

	private void setString( PreparedStatement stmt, int i, String value )
	throws SQLException {
		if ( value != null ) {
			stmt.setString( i, value );
		} else {
			stmt.setNull( i, Types.VARCHAR );
		}
	}
	
	@Override
	public void setThreadNum(int threadNum) {
		this.threadNum = threadNum;
	}
	
	@Override
	public void setParams(Map<String, Object> params){
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
