package ru.bpc.sv2.logic.ws;

import com.ibatis.sqlmap.client.SqlMapSession;
import oracle.sql.ARRAY;
import org.apache.commons.codec.binary.Base64;
import org.apache.log4j.Logger;
import ru.bpc.sv2.accounts.Account;
import ru.bpc.sv2.application.Application;
import ru.bpc.sv2.application.ApplicationElement;
import ru.bpc.sv2.application.ApplicationError;
import ru.bpc.sv2.application.ApplicationRec;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.utility.db.IbatisAware;
import ru.bpc.sv2.orgstruct.Institution;
import ru.bpc.sv2.utils.AuthOracleTypeNames;
import ru.bpc.sv2.utils.DBUtils;
import ru.bpc.sv2.utils.UserException;

import ru.bpc.sv2.logic.utility.db.DataAccessException;

import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import java.io.ByteArrayInputStream;
import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.SQLException;
import java.util.*;

/**
 * Session Bean implementation class SVAP
 */
public class ApplicationsWsDao extends IbatisAware {

	private static final Logger logger = Logger.getLogger("SVAP");
	private static final String user = "ADMIN";
	private static final boolean traceTime = false;

	public Long registerSession(String userWS, String privName) throws UserException {
		if (userWS == null)
			userWS = user;
		try {
			return getUserSessionId(userWS, privName, null, null);
		} catch (SQLException e) {
			if (e.getErrorCode() >= 20000 && e.getErrorCode() <= 20999 ){
				throw new UserException(e.getCause().getMessage());
			} else {
				throw createDaoException(e);
			}
		}
	}
	
	public String getXml(Long sessionId, Long appId) throws UserException {
		return getXml(sessionId, appId, null);
	}
	
	public String getXml(Long sessionId, Long appId, String userName) throws UserException {
		if (userName == null || userName.trim().length() == 0){
			userName = user;
		}
		SqlMapSession ssn = null;
		try {
			long getXmlBegin = System.currentTimeMillis();
			ssn = getIbatisSession(sessionId, userName);
			String resultXml = (String) ssn.queryForObject("application.get-xml", appId);
			if (traceTime) {
				logger.trace("WEB SERVICE: Time get xml DAO: " +
						(System.currentTimeMillis() - getXmlBegin));
			}
			return resultXml;
		} catch (SQLException e) {			
			if (e.getErrorCode() >= 20000 && e.getErrorCode() <= 20999 ){
				throw new UserException(e.getCause().getMessage());
			} else {
				throw createDaoException(e);
			}
		} finally {
			close(ssn);
		}
	}


	public void createApplication(Long sessionId, Application app) throws UserException {
		createApplication(sessionId, app, null);
	}
	

	public void createApplication(Long sessionId, Application app, String userName) throws UserException {
		if (userName == null || userName.trim().length() == 0){
			userName = user;
		}
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSession(sessionId, userName);
			ssn.insert("application.add-application", app);
		} catch (SQLException e) {			
			if (e.getErrorCode() >= 20000 && e.getErrorCode() <= 20999 ){
				throw new UserException(e.getCause().getMessage());
			} else {
				throw createDaoException(e);
			}
		} finally {
			close(ssn);
		}
	}
	

	public void modifyApplication(Long sessionId, Application app) throws UserException {
		modifyApplication(sessionId, app, null);
	}
	

	public void modifyApplication(Long sessionId, Application app, String userName) throws UserException {
		if (userName == null || userName.trim().length() == 0){
			userName = user;
		}
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSession(sessionId, userName);
			ssn.insert("application.modify-application", app);
		} catch (SQLException e) {			
			if (e.getErrorCode() >= 20000 && e.getErrorCode() <= 20999 ){
				throw new UserException(e.getCause().getMessage());
			} else {
				throw createDaoException(e);
			}
		} finally {
			close(ssn);
		}
	}
	

	public String processApplication(Long sessionId, Long appId, Date sysdate) throws UserException {
		String result = null;
		result = processApplication(sessionId, appId, sysdate, null);
		return result;	
		
	}
	

	public String processApplication(Long sessionId, Long appId, Date sysdate, String userName) throws UserException {
		if (userName == null || userName.trim().length() == 0){
			userName = user;
		}
		SqlMapSession ssn = null;
		try {
			long processBegin = System.currentTimeMillis();
			ssn = getIbatisSession(sessionId, userName);
			if (sysdate != null) {
				ssn.update("common.set-sysdate", sysdate);
			}
			Map<String, Object> map = new HashMap<String, Object>();
			map.put("appId", appId);
			ssn.insert("application.process-application-main-handler", map);
			if (traceTime) {
				logger.trace("WEB SERVICE: Time process application (main handler) DAO: " + (System.currentTimeMillis() - processBegin));
			}
			return (String)map.get("result");
		} catch (SQLException e) {			
			if (e.getErrorCode() >= 20000 && e.getErrorCode() <= 20999 ){
				throw new UserException(e.getCause().getMessage());
			} else {
				throw createDaoException(e);
			}
		} finally {
			close(ssn);
		}
	}
	

	public void addErrorToApplication(Long sessionId, ApplicationError error) throws UserException {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSession(sessionId, user);
			ssn.update("application.add-error", error);			
		} catch (SQLException e) {			
			if (e.getErrorCode() >= 20000 && e.getErrorCode() <= 20999 ){
				throw new UserException(e.getCause().getMessage());
			} else {
				throw createDaoException(e);
			}
		} finally {
			close(ssn);
		}
	}
	

	public void modifyApplicationData(Long sessionId, ApplicationRec[] appRecs, Long appId) throws UserException {
		modifyApplicationData(sessionId, appRecs, appId, null);
	}
	

	public void modifyApplicationData(Long sessionId, ApplicationRec[] appRecs, Long appId, String userName) 
			throws UserException {
		if (userName == null || userName.trim().length() == 0){
			userName = user;
		}
		SqlMapSession ssn = null;
		CallableStatement cstmt = null;
		Connection con = null;
		try {
			ssn = getIbatisSession(sessionId, userName);
			con = ssn.getCurrentConnection();
			
			cstmt = con.prepareCall("{ call app_ui_application_pkg.modify_application_data(?,?,?) }");
			cstmt.setLong(1, appId);

			ARRAY oracleApps = DBUtils.createArray(AuthOracleTypeNames.APP_DATA_TAB, con, appRecs);
			cstmt.setArray(2, oracleApps);
			cstmt.setInt(3, 1);
			cstmt.execute();
		} catch (SQLException e) {
			if (e.getErrorCode() >= 20000 && e.getErrorCode() <= 20999 ){
				throw new UserException(e.getCause().getMessage());
			} else {
				throw new DataAccessException(e);
			}
		} catch (Exception e) {
			throw new DataAccessException(e);
		} finally {
			DBUtils.close(cstmt);
			DBUtils.close(con);
			close(ssn);
		}
	}
	

	public Account getAccountInfo(Long sessionId, String accountNumber) throws UserException {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSession(sessionId, user);
			return (Account) ssn.queryForObject("accounts.get-account-info", accountNumber);
		} catch (SQLException e) {			
			if (e.getErrorCode() >= 20000 && e.getErrorCode() <= 20999 ){
				throw new UserException(e.getCause().getMessage());
			} else {
				throw createDaoException(e);
			}
		} finally {
			close(ssn);
		}
	}
	

	@Deprecated
	public String saveDocument(Long sessionId, Long dataId, String document, String customerEds) throws UserException {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSession(sessionId, user);
			Map<String, Object> map = new HashMap<String, Object>();
			map.put("dataId", dataId);
			map.put("document", document);			
			map.put("customerEds", customerEds);
			ssn.queryForObject("application.save-document", map);
			String savePath = (String)map.get("savePath");
			return savePath;
		} catch (SQLException e) {			
			if (e.getErrorCode() >= 20000 && e.getErrorCode() <= 20999 ){
				throw new UserException(e.getCause().getMessage());
			} else {
				throw createDaoException(e);
			}
		} finally {
			close(ssn);
		}
	}
	

	public List<String> saveDocuments(Long sessionId, List<Long> documentsDataIdList,
			Map<Long, String> documentsMap, Map<Long, String> edsMap, Map<Long, String> svEdsMap,
			List<byte[]> byteList) throws UserException, Exception {
		
		return saveDocuments(sessionId, documentsDataIdList, 
				documentsMap, edsMap, svEdsMap, byteList, null);
	}
	

	public List<String> saveDocuments(Long sessionId, List<Long> documentsDataIdList,
			Map<Long, String> documentsMap, Map<Long, String> edsMap, Map<Long, String> svEdsMap,
			List<byte[]> byteList, String userName) throws UserException, Exception {
		if (userName == null || userName.trim().length() == 0){
			userName = user;
		}
		List<String> result = new ArrayList<String>();
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSession(sessionId, userName);
			
			for (Long documentDataId : documentsDataIdList) {
				String documentTextBase64 = documentsMap.get(documentDataId);
				String eds = edsMap.get(documentDataId);
				String svEds = svEdsMap.get(documentDataId);
				byte[] decodedBytes = new byte[0];
				boolean needSave = true;
				String str = null;
				if (documentTextBase64 == null || "".equals(documentTextBase64)) {
					needSave = false;
				} else {
					decodedBytes = Base64.decodeBase64(documentTextBase64);
					str = new String(decodedBytes, "UTF-8");

					try {
						DocumentBuilderFactory dbf = DocumentBuilderFactory.newInstance();
						DocumentBuilder db = dbf.newDocumentBuilder();
						db.parse(new ByteArrayInputStream(decodedBytes));
					} catch (Exception e) {
						throw new UserException("Cannot parse document!");
					}
				}
			
				Map<String, Object> map = new HashMap<String, Object>();
				map.put("dataId", documentDataId);
				map.put("document", str);			
				map.put("customerEds", eds);
				map.put("supervisorEds", svEds);
				ssn.queryForObject("application.save-document", map);
				String savePath = (String)map.get("savePath");
				
				if (needSave) { 
					result.add(savePath);
					byteList.add(decodedBytes);
				} else { 
					result.add(null);
					byteList.add(null);
				}
			}
		} catch (SQLException e) {			
			if (e.getErrorCode() >= 20000 && e.getErrorCode() <= 20999 ){
				throw getUserExceptionWithErrorCode(ssn, e.getCause().getMessage());
			} else {
				throw new DataAccessException(e);
			}
		} finally {
			close(ssn);
		}
		return result;
	}
	

	public String generateOrderText(Long sessionId, Long appId) throws UserException {
		SqlMapSession ssn = null;
		try {
			long processBegin = System.currentTimeMillis();
			ssn = getIbatisSession(sessionId, user);
			Map<String, Object> map = new HashMap<String, Object>();
			map.put("appId", appId);
			ssn.insert("application.process-application-generate-order", map);
			if (traceTime) {
				logger.trace("WEB SERVICE: Time generate order (main handler) DAO: " + (System.currentTimeMillis() - processBegin));
			}
			return (String)map.get("result");
		} catch (SQLException e) {			
			if (e.getErrorCode() >= 20000 && e.getErrorCode() <= 20999 ){
				throw new UserException(e.getCause().getMessage());
			} else {
				throw new DataAccessException(e);
			}
		} finally {
			close(ssn);
		}
	}
	

	public Long putOrder(Long sessionId, Map<String, Object> map) throws UserException {
		SqlMapSession ssn = null;
		try {
			long processBegin = System.currentTimeMillis();
			ssn = getIbatisSession(sessionId, user);
			ssn.update("svip.find-customer", map);
			ssn.insert("application.put-order", map);
			Long orderId = (Long)map.get("orderId");
			ssn.insert("application.put-order-parameters", map);
			if (traceTime) {
				logger.trace("WEB SERVICE: Time put order (main handler) DAO: " + (System.currentTimeMillis() - processBegin));
			}
			return orderId;
		} catch (SQLException e) {			
			if (e.getErrorCode() >= 20000 && e.getErrorCode() <= 20999 ){
				throw getUserExceptionWithErrorCode(ssn, e.getCause().getMessage());
			} else {
				throw new DataAccessException(e);
			}
		} finally {
			close(ssn);
		}
	}
	

	public void checkCloseNesp(Map<String, Object> map) throws UserException {
		SqlMapSession ssn = null;
		try {
			long processBegin = System.currentTimeMillis();
			ssn = getIbatisSessionNoContext();
			ssn.insert("cst.check-close", map);
			if (traceTime) {
				logger.trace("WEB SERVICE: Time check close NESP DAO: " + (System.currentTimeMillis() - processBegin));
			}			
		} catch (SQLException e) {			
			if (e.getErrorCode() >= 20000 && e.getErrorCode() <= 20999 ){
				throw new UserException(e.getCause().getMessage());
			} else {
				throw new DataAccessException(e);
			}
		} finally {
			close(ssn);
		}
	}
	

	public void linkOrderDocument(Long sessionId, Long appId, Long orderId) throws UserException {
		SqlMapSession ssn = null;
		try {
			long processBegin = System.currentTimeMillis();
			ssn = getIbatisSession(sessionId, user);
			Map<String, Object> map = new HashMap<String, Object>();
			map.put("appId", appId);
			map.put("orderId", orderId);
			ssn.insert("application.link-document-order", map);
			if (traceTime) {
				logger.trace("WEB SERVICE: Time link order document DAO: " + (System.currentTimeMillis() - processBegin));
			}			
		} catch (SQLException e) {			
			if (e.getErrorCode() >= 20000 && e.getErrorCode() <= 20999 ){
				throw new UserException(e.getCause().getMessage());
			} else {
				throw new DataAccessException(e);
			}
		} finally {
			close(ssn);
		}
	}
	

	public void modifyApplicationElementData(Long sessionId, Long applicationId, ApplicationElement el) throws UserException {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSession(sessionId, user);
			Map<String, Object> map = new HashMap<String, Object>();
			map.put("applicationId", applicationId);
			map.put("data", el);
			ssn.insert("application.modify-application-element-data", map);					
		} catch (SQLException e) {			
			if (e.getErrorCode() >= 20000 && e.getErrorCode() <= 20999 ){
				throw new UserException(e.getCause().getMessage());
			} else {
				throw new DataAccessException(e);
			}
		} finally {
			close(ssn);
		}
	}
	

	public String removeUndefCustomer(Long sessionId, Long appId) throws UserException {
		SqlMapSession ssn = null;
		try {
			long processBegin = System.currentTimeMillis();
			ssn = getIbatisSession(sessionId, user);
			Map<String, Object> map = new HashMap<String, Object>();
			map.put("appId", appId);
			ssn.insert("application.process-application-remove-undef-customer", map);
			if (traceTime) {
				logger.trace("WEB SERVICE: Time remove undef customer DAO: " + (System.currentTimeMillis() - processBegin));
			}
			return (String)map.get("result");
		} catch (SQLException e) {			
			if (e.getErrorCode() >= 20000 && e.getErrorCode() <= 20999 ){
				throw new UserException(e.getCause().getMessage());
			} else {
				throw new DataAccessException(e);
			}
		} finally {
			close(ssn);
		}
	}
	

	public String cancelProcessing(Long sessionId, Long appId) throws UserException {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSession(sessionId, user);
			Map<String, Object> map = new HashMap<String, Object>();
			map.put("appId", appId);
			ssn.insert("application.process-application-cancel-processing", appId);			
			return (String)map.get("result");
		} catch (SQLException e) {			
			if (e.getErrorCode() >= 20000 && e.getErrorCode() <= 20999 ){
				throw new UserException(e.getCause().getMessage());
			} else {
				throw new DataAccessException(e);
			}
		} finally {
			close(ssn);
		}
	}


	public void addCommonErrorToApplication(Long sessionId, ApplicationError error)
			throws UserException {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSession(sessionId, user);
			ssn.update("application.add-app-error", error);
		} catch (SQLException e) {
			if (e.getErrorCode() >= 20000 && e.getErrorCode() <= 20999) {
				throw new UserException(e.getCause().getMessage());
			} else {
				throw createDaoException(e);
			}
		} finally {
			close(ssn);
		}
	}


	public String getXmlWithId(Long sessionId, Long appId) throws UserException {
		SqlMapSession ssn = null;
		try {
			long getXmlBegin = System.currentTimeMillis();
			ssn = getIbatisSession(sessionId, user);
			String resultXml = (String) ssn.queryForObject("application.get-xml-with-id", appId);
			if (traceTime) {
				logger.trace("WEB SERVICE: Time get xml with id DAO: " +
						(System.currentTimeMillis() - getXmlBegin));
			}
			return resultXml;
		} catch (SQLException e) {			
			if (e.getErrorCode() >= 20000 && e.getErrorCode() <= 20999 ){
				throw new UserException(e.getCause().getMessage());
			} else {
				throw createDaoException(e);
			}
		} finally {
			close(ssn);
		}
	}


	public boolean isUserInInst(Long userSessionId, String userName, Long instId) {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSession(userSessionId, userName);
			//noinspection unchecked
			List<Institution> insts = ssn.queryForList("roles.get-insts-for-user", convertQueryParams(SelectionParams.build("userName", userName)));
			for (Institution inst : insts) {
				if (inst.getId().equals(instId))
					return true;
			}
			return false;
		} catch (SQLException e) {
			throw new DataAccessException(e);
		} finally {
			close(ssn);
		}
	}
}
