package ru.bpc.sv2.scheduler.process.external.btrt;

import org.apache.log4j.Logger;
import ru.bpc.sv2.application.Application;
import ru.bpc.sv2.application.ApplicationElement;
import ru.bpc.sv2.constants.SystemConstants;
import ru.bpc.sv2.constants.schedule.ProcessConstants;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.ApplicationDao;
import ru.bpc.sv2.logic.ProcessDao;
import ru.bpc.sv2.process.SessionFile;
import ru.bpc.sv2.process.btrt.NodeItem;
import ru.bpc.sv2.scheduler.process.IbatisExternalProcess;
import ru.bpc.sv2.trace.TraceLogInfo;
import ru.bpc.sv2.utils.DBUtils;
import ru.bpc.sv2.utils.SystemException;
import ru.bpc.sv2.utils.UserException;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.OutputStreamWriter;
import java.nio.charset.Charset;
import java.sql.*;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/*
 * 1) Gets all BTRT files stored for the current process as INCOMING files
 * 2) Extracts the applications contained in BTRT files
 * 3) Every application extracted from BTRT file has temporary tag, that contains application ID of SV2 application
 * 4) Processes SV2 application by retrieved ID
 * 5) Update BTRT application in accordance with the results of SV2 application processing
 */
public class BTRTProcessor extends IbatisExternalProcess{

	private ProcessDao processDao;
	private ApplicationDao applicationDao;
	
	private final static String BTRT_APP_STATUS = "DF834B";
	private final static String BTRT_MAIN_BLOCK = "FF2E";
	private final static String BTRT_EXT_APP_ID = "DF8888";
	private final static String BTRT_APP_ERROR = "FF8034";
	private final static String BTRT_ERROR_CODE = "DF8307";
	private final static String BTRT_ERROR_TYPE = "DF8308";
	private final static String BTRT_ERROR_DESC = "DF8309";
	private final static String BTRT_ERROR_UNQ_SEQ = "DF830A";
	private final static String BTRT_ERROR_ELEMENT = "DF830B";
	private final static String BTRT_APP_TYPE = "DF8000";
	private final static String BTRT_CARD = "FF24";
	private final static String BTRT_CARD_INIT = "FF33";
	private final static String BTRT_CARD_NUMBER = "DF802C";
	public static final String SAVEPOINT_NAME = "APP_MIGR_SAVER_SP";
	
	private final static String CARD_NUMBER_QUERY = 
			"select a.element_char_value, level from app_ui_data_vw a "
			+ "where level < 3 and name = \'CARD_NUMBER\' "
			+ "start with a.element_id = (select id from app_element where name = \'CARD\') and a.appl_id = ? "
			+ "connect by nocycle prior id = a.parent_id "
			+ "order siblings by serial_number";
	
	private static final Logger logger = Logger.getLogger("PROCESS");
	private static Logger loggerDb = Logger.getLogger("PROCESSES_DB");
	
	@Override
	public void execute() throws SystemException, UserException {
		try {
			getIbatisSession();
			startSession();
//			startLogging();
			initBeans();
			
			executeBody();
			
			processSession.setResultCode(ProcessConstants.PROCESS_FINISHED);
			commit();
		} catch (Exception e){
			processSession.setResultCode(ProcessConstants.PROCESS_FAILED);
			success = 0;
			rollback();
			if (e instanceof UserException) throw new UserException(e);
			else throw new SystemException(e);
		} finally{
			int fail = estimated - success;
//			endLogging(success, fail);
			closeConAndSsn();
		}
	}

	private int success = 0;
	private int estimated = 0;
	
	private void logCurrent() throws SystemException{
		logCurrent(++success, 0);
	}
	
	private void estimate(int estimated){
		this.estimated = estimated;
	}
	
	private void executeBody() throws SystemException, UserException{
		trace("BTRTProcessor::execute...");

		Charset charset = retriveCharset();
		SessionFile[] files = obtainFiles();
		estimate(files.length);
		for (SessionFile file : files){
			List<NodeItem> nodes = splitToNodes(file.getFileContents());
			for (int i=1; i<nodes.size() - 1; i++){
				NodeItem node = nodes.get(i);
				Long appId = retriveAppId(node);
				if (appId == null) continue;
				
				try {
					processApp(appId);
				} catch (Exception e) {
					logger.error("", e);
					loggerDb.error(new TraceLogInfo(processSessionId(), e.getMessage()));					
				}
								
				ApplicationElement[] errors = obtainErrors(appId);
				String appStatus = retriveAppStatus(appId);
				if (appStatus == null) continue;
				
				int btrtNumber = decodeBTRTType(node);
				if (btrtNumber >= 1 && btrtNumber <= 4 || btrtNumber == 6){
					appendCardNumbers(node, appId);
				}
				
				appendStatus(node, appStatus);
				if (errors.length != 0){
					appendErrors(node, errors);
				}
			}
			String fileContent = nodesToString(nodes, charset);
			String fileName = retriveFileName(file.getFileName());
			storeFile(fileContent, fileName);
			
			logCurrent();
		}
	}
	
	@Override
	public void setParameters(Map<String, Object> parameters) {
		
	}

	private SessionFile[] obtainFiles(){
		trace("BTRTProcessor::obtainFiles...");
		SelectionParams sp = SelectionParams.build("sessionId", processSessionId());
		SessionFile[] sessionFiles = processDao.getSessionFilesContent(userSessionId, sp, false);
		return sessionFiles;
	}
	
	private void initBeans() throws SystemException{
		trace("BTRTProcessor::initBeans...");
		processDao = new ProcessDao();
		applicationDao = new ApplicationDao();
	}
	
	private List<NodeItem> splitToNodes(String btrtFile){
		trace("BTRTProcessor::splitToNodes...");
		String[] lines = btrtFile.split("\n");
		List<NodeItem> result = new ArrayList<NodeItem>();
		for (String line : lines){
			BTRTReader reader = new BTRTReader(line);
			NodeItem node = reader.read();
			result.add(node);
		}
		return result;
	}
	
	private Long retriveAppId(NodeItem node){
		trace("BTRTProcessor::retriveAppId...");
		NodeItem mainBlock = node.child(BTRT_MAIN_BLOCK);
		if (mainBlock == null) return null;
		NodeItem appId = mainBlock.child(BTRT_EXT_APP_ID);
		if (appId == null) return null;
		String appIdVal = appId.getData();
		Long parseLong = null;
		try {
			parseLong = Long.parseLong(appIdVal);
		} catch (NumberFormatException e){
			error(e);
		}
		mainBlock.getChildren().remove(appId);
		return parseLong;
	}
	
	private void processApp(Long appId){
		trace("BTRTProcessor::processApp...");
		trace(String.format("Processing application [ID: %d] ...", appId));
		applicationDao.processApplication(userSessionId, appId, false);
	}
	
	private ApplicationElement[] obtainErrors(Long appId){
		trace("BTRTProcessor::obtainErrors...");
		SelectionParams sp = SelectionParams.build("appId", appId);
		ApplicationElement[] applicationErrors = applicationDao.getApplicationErrors(userSessionId, sp);
		return applicationErrors;
	}
	
	private String retriveAppStatus(Long appId){
		trace("BTRTProcessor::retriveAppStatus...");
		SelectionParams sp = SelectionParams.build("id", appId, "lang", SystemConstants.ENGLISH_LANGUAGE);
		List<Application> applications = applicationDao.getApplications(userSessionId, sp);
		String appStatus = null;
		if (applications != null && applications.size() > 0){
			appStatus = applications.get(0).getStatus();
		}
		return appStatus;
	}
	
	private void appendStatus(NodeItem node, String status){
		trace("BTRTProcessor::appendStatus...");
		NodeItem mainBlock = node.child(BTRT_MAIN_BLOCK);
		if (mainBlock == null) return;
		NodeItem applicationStatus = node.child(BTRT_APP_STATUS);
		if (applicationStatus == null){
			applicationStatus = new NodeItem(BTRT_APP_STATUS, null);
			mainBlock.getChildren().add(applicationStatus);
		}
		applicationStatus.setData(status);
	}
	
	private void appendErrors(NodeItem node, ApplicationElement[] errors){
		trace("BTRTProcessor::appendErrors...");
		for (ApplicationElement error : errors){
			NodeItem appError = new NodeItem(BTRT_APP_ERROR, null);
			NodeItem errorType = new NodeItem(BTRT_ERROR_CODE, "AERT01");
			NodeItem errorDescription = new NodeItem(BTRT_ERROR_DESC, error.getValueText() + " " + error.getValue().toString());
			NodeItem errorUnqSeq = new NodeItem(BTRT_ERROR_UNQ_SEQ, "0");
			appError.getChildren().add(errorType);
			appError.getChildren().add(errorDescription);
			appError.getChildren().add(errorUnqSeq);
			node.getChildren().add(appError);
		}
	}
	
	private Charset retriveCharset(){
		Charset charset = Charset.forName("CP1251");
		return charset;
	}
	
	private String nodesToString(List<NodeItem> nodes, Charset charset){
		trace("BTRTProcessor::nodesToString...");
		StringBuilder sb = new StringBuilder();
		for (NodeItem node : nodes){
			BTRTWriter writer = new BTRTWriter(node);
			ByteArrayOutputStream baos = null;
			OutputStreamWriter osw = null;
			try {
				baos = new ByteArrayOutputStream();
				osw = new OutputStreamWriter(baos, charset);
				writer.write(osw);
			} catch (IOException e){
				error(e);
				continue;
			} finally {
				if (osw != null) try {osw.close();} catch (IOException e){}
			}
			byte[] appLineSrc = baos.toByteArray();
			String appLine = null;
			appLine = new String(appLineSrc, charset);

			sb.append(appLine);
			sb.append('\n');
		}
		String result = sb.toString();
		return result;
	}
	
	private String retriveFileName(String inputFileName) throws UserException, SystemException{
		trace("BTRTProcessor::retriveFileName...");
		Map<String, Object> map = new HashMap<String, Object>();
		map.put("KEY_INDEX", inputFileName);
		Map<String, Object> p = new HashMap<String, Object>();
		p.put("result", new String());
		p.put("fileType", null);
		p.put("filePurpose", ProcessConstants.FILE_PURPOSE_OUTGOING);
		p.put("params", map);
		try {
			ssn.queryForObject("process.get-default-file-name", p);
		} catch (SQLException e) {
			if (e.getErrorCode() >= 20000 && e.getErrorCode() <= 20999 ){
				throw new UserException(e);
			} else { 
				throw new SystemException(e);
			}
		} 
		String fileName = null;
		if (p.containsKey("result")){
			fileName = (String) p.get("result");
		}
		return fileName;		
	}
	
	private void storeFile(String fileContent, String fileName){
		trace("BTRTProcessor::storeFile...");
		Savepoint savePoint = null;
		CallableStatement cstmt = null;
		try{
			savePoint = con.setSavepoint(SAVEPOINT_NAME);
			
			cstmt = con.prepareCall("{call prc_api_file_pkg.open_file(?,?,?,?)}");
			cstmt.registerOutParameter(1, Types.NUMERIC);
			cstmt.setString(2, fileName);
			cstmt.setNull(3, Types.CHAR);
			cstmt.setString(4, ProcessConstants.FILE_PURPOSE_OUTGOING);
			cstmt.execute();
			long fileId = cstmt.getLong(1);
			debug(String.format("Opened file ID: %d", fileId));
			cstmt.close();
			
			cstmt = con.prepareCall("{call prc_api_file_pkg.put_file(?,?)}");
			cstmt.setLong(1, fileId);
			cstmt.setObject(2, fileContent);
			cstmt.execute();
			cstmt.close();
			
			cstmt = con.prepareCall("{call prc_api_file_pkg.close_file(?,?)}");
			cstmt.setLong(1, fileId);
			cstmt.setNull(2, Types.CHAR);
			cstmt.execute();
			cstmt.close();
			
			debug(String.format("File \"%s\" has been successfully registred", fileName));			
		} catch (SQLException e) {
			if (savePoint != null){
				try {
					con.rollback(savePoint);
				} catch (SQLException e2){
					warn(e.getMessage());
				}
			}
			error(e);
		} finally {
			DBUtils.close(cstmt);
			if (savePoint != null){
				try {
					con.releaseSavepoint(savePoint);
				} catch (SQLException e){
					warn(e.getMessage());
				}				
			}
		}
	}
	
	private List<String> obtainCardNumbers(Long appId){
		PreparedStatement stmt = null;
		ResultSet rs = null;
		List<String> result = new ArrayList<String>(5);
		try {
			stmt = con.prepareStatement(CARD_NUMBER_QUERY);
			stmt.setLong(1, appId);
			rs = stmt.executeQuery();			
			if (rs.next()){				
				String cardNumber = rs.getString(1);
				result.add(cardNumber);
			}			
		} catch (SQLException e){
			error(e);
		} finally {
			DBUtils.close(stmt);
			DBUtils.close(rs);
		}
		return result;
	}
	
	private void appendCardNumbers(NodeItem app, Long extAppId){
		List<String> cardNumbers = obtainCardNumbers(extAppId);
		List<NodeItem> cards = app.childs(BTRT_CARD);
		if (cards.size() != cardNumbers.size()) return;
		int cardsCount = cards.size();
		for (int i=0; i<cardsCount; i++){
			NodeItem card = cards.get(i);
			NodeItem cardInit = card.child(BTRT_CARD_INIT);
			if (cardInit == null) continue;
			NodeItem cardNumber = cardInit.child(BTRT_CARD_NUMBER);
			if (cardNumber == null){
				cardNumber = new NodeItem(BTRT_CARD_NUMBER, null);
				cardInit.getChildren().add(cardNumber);
			}
			String cardNumberValue = cardNumbers.get(i);
			cardNumber.setData(cardNumberValue);
		}
	}
	
	private int decodeBTRTType(NodeItem app){
		NodeItem mainBlock = app.child(BTRT_MAIN_BLOCK);
		if (mainBlock == null) return -1;
		NodeItem applicationType = mainBlock.child(BTRT_APP_TYPE);
		if (applicationType == null) return -1;
		String btrtType = applicationType.getData();
		String btrtNumberStr = "0x" + btrtType.substring(4);
		int btrtNumber = -1; 
		try {
			btrtNumber = Integer.decode(btrtNumberStr);
		} catch (NumberFormatException e){
			logger.error(e);
		}
		return btrtNumber;
	}
}
