package ru.bpc.sv2.logic;

import java.sql.SQLException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import ru.bpc.sv2.logic.utility.db.DataAccessException;


import org.apache.log4j.Logger;

import ru.bpc.sv2.common.CommonParamRec;
import ru.bpc.sv2.constants.EntityNames;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.controller.CommonController;
import ru.bpc.sv2.logic.utility.db.IbatisAware;
import ru.bpc.sv2.security.DesKey;
import ru.bpc.sv2.security.HmacKey;
import ru.bpc.sv2.security.QuestionWord;
import ru.bpc.sv2.security.RsaCertificate;
import ru.bpc.sv2.security.RsaKey;
import ru.bpc.sv2.security.SecAuthority;
import ru.bpc.sv2.security.SecPrivConstants;
import ru.bpc.sv2.utils.AuditParamUtil;
import ru.bpc.sv2.utils.UserException;

import com.ibatis.sqlmap.client.SqlMapSession;

/**
 * Session Bean implementation class SecurityDao
 */
public class SecurityDao extends IbatisAware {

	private static final Logger logger = Logger.getLogger("SECURITY");
	
	@SuppressWarnings("unchecked")
	public DesKey[] getDesKeys(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, (params.getPrivilege()!=null ? params.getPrivilege() : SecPrivConstants.VIEW_DES_KEY), paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, (params.getPrivilege()!=null ? params.getPrivilege() : SecPrivConstants.VIEW_DES_KEY));
			List<DesKey> keys = ssn.queryForList("sec.get-des-keys", convertQueryParams(params, limitation));
			return keys.toArray(new DesKey[keys.size()]);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public int getDesKeysCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, (params.getPrivilege()!=null ? params.getPrivilege() : SecPrivConstants.VIEW_DES_KEY), paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, (params.getPrivilege()!=null ? params.getPrivilege() : SecPrivConstants.VIEW_DES_KEY));
			return (Integer) ssn.queryForObject("sec.get-des-keys-count",
					convertQueryParams(params, limitation));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public DesKey addDesKey(Long userSessionId, DesKey key, String lang) {
		SqlMapSession ssn = null;

		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(key.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, SecPrivConstants.ADD_DES_KEY, paramArr);

			ssn.insert("sec.add-des-key", key);

			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("id");
			filters[0].setValue(key.getId().toString());
			filters[1] = new Filter();
			filters[1].setElement("lang");
			filters[1].setValue(lang);

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (DesKey) ssn.queryForObject("sec.get-des-keys", convertQueryParams(params));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public DesKey generateDesKey(Long userSessionId, DesKey key, String lang) {
		SqlMapSession ssn = null;

		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(key.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, SecPrivConstants.GENERATE_DES_KEY, paramArr);

			ssn.insert("sec.generate-des-key", key);

			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("id");
			filters[0].setValue(key.getId().toString());
			filters[1] = new Filter();
			filters[1].setElement("lang");
			filters[1].setValue(lang);

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (DesKey) ssn.queryForObject("sec.get-des-keys", convertQueryParams(params));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public DesKey translateDesKey(Long userSessionId, DesKey key, String lang) {
		SqlMapSession ssn = null;

		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(key.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, SecPrivConstants.TRANSLATE_DES_KEY, paramArr);

//			ssn.update("hsm.deinit-hsm-devices", new Integer(-8));
//			ssn.update("hsm.init-hsm-devices", new Integer(-8));
			ssn.insert("sec.translate-des-key", key);

			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("id");
			filters[0].setValue(key.getId().toString());
			filters[1] = new Filter();
			filters[1].setElement("lang");
			filters[1].setValue(lang);

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (DesKey) ssn.queryForObject("sec.get-des-keys", convertQueryParams(params));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public DesKey editDesKey(Long userSessionId, DesKey key, String lang) {
		SqlMapSession ssn = null;

		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(key.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, SecPrivConstants.MODIFY_DES_KEY, paramArr);

			ssn.update("sec.edit-des-key", key);

			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("id");
			filters[0].setValue(key.getId().toString());
			filters[1] = new Filter();
			filters[1].setElement("lang");
			filters[1].setValue(lang);

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (DesKey) ssn.queryForObject("sec.get-des-keys", convertQueryParams(params));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void deleteDesKey(Long userSessionId, DesKey key) {
		SqlMapSession ssn = null;

		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(key.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, SecPrivConstants.REMOVE_DES_KEY, paramArr);

			ssn.delete("sec.delete-des-key", key);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public String generateDesKeyCheckValue(Long userSessionId, DesKey key) {
		SqlMapSession ssn = null;

		try {
			ssn = getIbatisSessionFE(userSessionId);
			return (String) ssn.queryForObject("sec.generate-key-check-value", key);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public Long checkDesKey(Long userSessionId, DesKey key) {
		SqlMapSession ssn = null;

		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(key.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, SecPrivConstants.CHECK_DES_KEY, paramArr);
			ssn.update("sec.check-des-key", key);

			return key.getId();
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public String getKeyType(Long userSessionId, DesKey key) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(key.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, SecPrivConstants.VIEW_KEY_TYPE, paramArr);
			ssn.update("sec.get-key-type", key);
			return key.getKeyType();
		} catch (SQLException e) {
			throw new DataAccessException(e);
		} finally {
			close(ssn);
		}
	}


	public boolean checkSecurityWord(Long userSessionId, QuestionWord qw) {
		SqlMapSession ssn = null;

		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(qw.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, SecPrivConstants.CHECK_SECURITY_WORD, paramArr);
			ssn.queryForObject("sec.check-security-word", qw);

			return qw.isValidated();
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public QuestionWord[] getQuestions(Long userSessionId, Long cardholderId, Long cardId,
			Long customerId) {
		SqlMapSession ssn = null;

		Filter[] filters = new Filter[2];
		filters[0] = new Filter();
		filters[0].setElement("entityType");
		filters[0].setValue(EntityNames.CARDHOLDER);
		filters[1] = new Filter();
		filters[1].setElement("objectId");
		filters[1].setValue(cardholderId);

		SelectionParams params = new SelectionParams();
		params.setFilters(filters);

		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, SecPrivConstants.VIEW_SECURITY_WORD, paramArr);

			List<QuestionWord> keys = ssn.queryForList("sec.get-questions",
					convertQueryParams(params));
			if (keys == null || keys.size() == 0) {
				filters[0].setValue(EntityNames.CARD);
				filters[1].setValue(cardId);
				keys = ssn.queryForList("sec.get-questions", convertQueryParams(params));
			}
			if (keys == null || keys.size() == 0) {
				filters[0].setValue(EntityNames.CUSTOMER);
				filters[1].setValue(customerId);
				keys = ssn.queryForList("sec.get-questions", convertQueryParams(params));
			}
			return keys.toArray(new QuestionWord[keys.size()]);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public SecAuthority[] getAuthorities(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, SecPrivConstants.VIEW_SEC_AUTHORITY, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, SecPrivConstants.VIEW_SEC_AUTHORITY);
			List<SecAuthority> items = ssn.queryForList(
					"sec.get-authorities", convertQueryParams(params, limitation));
			return items.toArray(new SecAuthority[items.size()]);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public int getAuthoritiesCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, SecPrivConstants.VIEW_SEC_AUTHORITY, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, SecPrivConstants.VIEW_SEC_AUTHORITY);
			int count = (Integer)ssn.queryForObject("sec.get-authorities-count",
					convertQueryParams(params, limitation));
			return count;
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public SecAuthority createAuthority( Long userSessionId, SecAuthority editingItem){
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(editingItem.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, SecPrivConstants.ADD_SEC_AUTHORITY, paramArr);
			ssn.update("sec.add-authority", editingItem);
			
			Filter[] filters = new Filter[1];
			Filter f = new Filter();
			f.setElement("id");
			f.setValue(editingItem.getId());
			filters[0] = f;
			SelectionParams params = new SelectionParams();
			params.setFilters(filters);
			SecAuthority result = (SecAuthority) ssn.queryForObject("sec.get-authorities", convertQueryParams(params));
			return result;
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public SecAuthority modifyAuthority( Long userSessionId, SecAuthority editingItem){
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(editingItem.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, SecPrivConstants.MODIFY_SEC_AUTHORITY, paramArr);
			ssn.update("sec.modify-authority", editingItem);
			
			Filter[] filters = new Filter[2];
			Filter f = new Filter();
			f.setElement("id");
			f.setValue(editingItem.getId());
			filters[0] = f;
			filters[1] = new Filter();
			filters[1].setElement("lang");
			filters[1].setValue(editingItem.getLang());
			SelectionParams params = new SelectionParams();
			params.setFilters(filters);
			SecAuthority result = (SecAuthority) ssn.queryForObject("sec.get-authorities", convertQueryParams(params));
			return result;
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void removeAuthority( Long userSessionId, SecAuthority activeItem){
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(activeItem.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, SecPrivConstants.REMOVE_SEC_AUTHORITY, paramArr);
			ssn.update("sec.remove-authority", activeItem);	
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}
	

	public RsaCertificate[] getRsaCertificates(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, SecPrivConstants.VIEW_RSA_CERTIFICATE, paramArr);

			List<RsaCertificate> items = ssn.queryForList(
					"sec.get-rsa-certificates", convertQueryParams(params));
			return items.toArray(new RsaCertificate[items.size()]);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public int getRsaCertificatesCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, SecPrivConstants.VIEW_RSA_CERTIFICATE, paramArr);

			int count = (Integer)ssn.queryForObject("sec.get-rsa-certificates-count",
					convertQueryParams(params));
			return count;
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}
	

	public void removeRsaCertificate(Long userSessionId,
			RsaCertificate activeItem) {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSession(userSessionId, null, SecPrivConstants.REMOVE_RSA_CERTIFICATE, null);
			ssn.update("sec.remove-certificate", activeItem);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}
	

	public RsaKey[] getRsaKeys(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, params.getUser(), SecPrivConstants.VIEW_RSA_KEYPAIR, paramArr);

			List<RsaKey> items = ssn.queryForList(
					"sec.get-rsa-keys", convertQueryParams(params));
			return items.toArray(new RsaKey[items.size()]);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public int getRsaKeysCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, SecPrivConstants.VIEW_RSA_KEYPAIR, paramArr);

			int count = (Integer)ssn.queryForObject("sec.get-rsa-keys-count",
					convertQueryParams(params));
			return count;
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public List<RsaKey> createRsaKey(Long userSessionId, RsaKey editingItem) throws UserException{
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(editingItem.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, SecPrivConstants.ADD_RSA_KEYPAIR, paramArr);
			ssn.update("sec.add-rsa-key", editingItem);
			
			Filter[] filters = new Filter[1];
			Filter f = new Filter();
			f.setElement("id");
			f.setValue(editingItem.getId());
			filters[0] = f;
			SelectionParams params = new SelectionParams();
			params.setFilters(filters);
            params.setRowIndexEnd(Integer.MAX_VALUE);
			return ssn.queryForList("sec.get-rsa-keys", convertQueryParams(params));
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


	public void removeRsaKey( Long userSessionId, RsaKey activeItem) throws UserException{
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(activeItem.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, SecPrivConstants.REMOVE_RSA_KEYPAIR, paramArr);
			ssn.update("sec.remove-rsa-keypair", activeItem);	
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
	
	public RsaKey[] getRsaKeysForCertificate(Long userSessionId, RsaCertificate certificate, String lang){
		SqlMapSession ssn = null;
		try {
			Map<String, Object> paramMap = new HashMap<String, Object>();
			paramMap.put("authorityKeyId", certificate.getAuthorityKeyId());
			paramMap.put("certifiedKeyId", certificate.getCertifiedKeyId());
			paramMap.put("lang", lang);
			
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(paramMap);
			ssn = getIbatisSession(userSessionId, null, SecPrivConstants.VIEW_RSA_KEYPAIR, paramArr);
			
			List<RsaKey> items = ssn.queryForList("sec.get-rsa-keys-for-cert", paramMap);
			return items.toArray(new RsaKey[items.size()]);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}
	
	public int getRsaKeysForCertificateCount(Long userSessionId, RsaCertificate certificate, String lang){
		SqlMapSession ssn = null;
		try {
			Map<String, Object> paramMap = new HashMap<String, Object>();
			paramMap.put("authorityKeyId", certificate.getAuthorityKeyId());
			paramMap.put("certifiedKeyId", certificate.getCertifiedKeyId());
			paramMap.put("lang", lang);
			
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(paramMap);
			ssn = getIbatisSession(userSessionId, null, SecPrivConstants.VIEW_RSA_KEYPAIR, paramArr);
			
			int count = (Integer)ssn.queryForObject("sec.get-rsa-keys-for-cert-count", paramMap);
			return count;
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}
	
	public RsaCertificate[] getRsaCertificesByKey(Long userSessionId, RsaKey rsaKey){
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSession(userSessionId, null, SecPrivConstants.VIEW_RSA_CERTIFICATE, null);
			
			Filter[] filters = new Filter[1];
			Filter f = new Filter();
			f.setElement("keyId");
			f.setValue(rsaKey.getId());
			filters[0] = f;
			SelectionParams params = new SelectionParams();
			params.setFilters(filters);
			List<RsaCertificate> items = ssn.queryForList("sec.get-rsa-certificates-by-key-id", convertQueryParams(params));
			return items.toArray(new RsaCertificate[items.size()]);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}
	
	public int getRsaCertificesCountByKey(Long userSessionId, RsaKey rsaKey){
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSession(userSessionId, null, SecPrivConstants.VIEW_RSA_CERTIFICATE, null);
			Filter[] filters = new Filter[1];
			Filter f = new Filter();
			f.setElement("keyId");
			f.setValue(rsaKey.getId());
			filters[0] = f;
			SelectionParams params = new SelectionParams();
			params.setFilters(filters);
			int count = (Integer)ssn.queryForObject("sec.get-rsa-certificates-count-by-key-id", convertQueryParams(params));
			return count;
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}
	

	public void setCaIndex( Long userSessionId, Long certifiedKeyId, Integer authorityKeyIndex) throws UserException{
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSession(userSessionId, null, SecPrivConstants.LINK_CA_KEY_INDEX, null);
			Map<String, Object> map = new HashMap<String, Object>();
			map.put("certifiedKeyId", certifiedKeyId);
			map.put("authorityKeyIndex", authorityKeyIndex);
			
			ssn.update("sec.link-authority-key-index", map);	
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
	

	public HmacKey[] getHmacKeys(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, SecPrivConstants.VIEW_HMAC_KEY, paramArr);

			List<HmacKey> items = ssn.queryForList(
					"sec.get-hmac-keys", convertQueryParams(params));
			return items.toArray(new HmacKey[items.size()]);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public int getHmacKeysCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, SecPrivConstants.VIEW_HMAC_KEY, paramArr);

			int count = (Integer)ssn.queryForObject("sec.get-hmac-keys-count",
					convertQueryParams(params));
			return count;
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public HmacKey createHmacKey( Long userSessionId, HmacKey editingItem){
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(editingItem.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, SecPrivConstants.ADD_HMAC_KEY, paramArr);
			ssn.update("sec.add-hmac-key", editingItem);
			
			Filter[] filters = new Filter[1];
			Filter f = new Filter();
			f.setElement("id");
			f.setValue(editingItem.getId());
			filters[0] = f;
			SelectionParams params = new SelectionParams();
			params.setFilters(filters);
			HmacKey result = (HmacKey) ssn.queryForObject("sec.get-hmac-keys", convertQueryParams(params));
			return result;
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public HmacKey generateHmacKey( Long userSessionId, HmacKey editingItem) throws UserException{
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(editingItem.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, SecPrivConstants.GENERATE_HMAC_KEY, paramArr);
			ssn.update("sec.generate-hmac-key", editingItem);
			
			Filter[] filters = new Filter[1];
			Filter f = new Filter();
			f.setElement("id");
			f.setValue(editingItem.getId());
			filters[0] = f;
			SelectionParams params = new SelectionParams();
			params.setFilters(filters);
			HmacKey result = (HmacKey) ssn.queryForObject("sec.get-hmac-keys", convertQueryParams(params));
			return result;
		} catch (SQLException e) {
			logger.error(e);
			if (e.getErrorCode() >= 20001){
				throw new UserException(e.getCause().getMessage(), e);
			} else {
				throw new DataAccessException(e);
			}
		} finally {
			close(ssn);
		}
	}


	public void removeHmacKey( Long userSessionId, HmacKey activeItem){
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(activeItem.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, SecPrivConstants.REMOVE_HMAC_KEY, paramArr);
			ssn.update("sec.remove-hmac-key", activeItem);	
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}
	

	public String get_iss_bin(Long userSessionId, Long id) {
		SqlMapSession ssn = null;

		try {
			Map<String, Object> params = new HashMap<String, Object>();
			params.put("id", id);
			ssn = getIbatisSession(userSessionId, null, SecPrivConstants.VIEW_RSA_KEYPAIR, null);
			ssn.queryForObject("sec.get-iss-bin", params);

			return (String) params.get("bin");
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}
	
}
