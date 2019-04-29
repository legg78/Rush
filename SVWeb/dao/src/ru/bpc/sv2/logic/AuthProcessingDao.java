package ru.bpc.sv2.logic;

import java.sql.SQLException;
import java.util.HashMap;
import java.util.List;


import ru.bpc.sv2.aup.Amount;
import ru.bpc.sv2.aup.AupPrivConstants;
import ru.bpc.sv2.aup.AuthScheme;
import ru.bpc.sv2.aup.AuthSchemeObject;
import ru.bpc.sv2.aup.AuthTemplate;
import ru.bpc.sv2.aup.CardStatResp;
import ru.bpc.sv2.aup.Tag;
import ru.bpc.sv2.aup.TagValue;
import ru.bpc.sv2.common.CommonParamRec;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.controller.CommonController;
import ru.bpc.sv2.logic.utility.db.IbatisAware;
import ru.bpc.sv2.reports.ReportPrivConstants;
import ru.bpc.sv2.utils.AuditParamUtil;

import com.ibatis.sqlmap.client.SqlMapSession;

/**
 * Session Bean implementation class AuthProcessingDao
 */
public class AuthProcessingDao extends IbatisAware {

	/**
	 * Default constructor.
	 */
	public AuthProcessingDao() {
	}

	@SuppressWarnings("unchecked")
	public Tag[] getTags(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, AupPrivConstants.VIEW_AUTH_TAGS, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, AupPrivConstants.VIEW_AUTH_TAGS);
			List<Tag> tags = ssn.queryForList("aup.get-tags", convertQueryParams(params, limitation));
			return tags.toArray(new Tag[tags.size()]);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public int getTagsCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, AupPrivConstants.VIEW_AUTH_TAGS, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, AupPrivConstants.VIEW_AUTH_TAGS);
			return (Integer) ssn.queryForObject("aup.get-tags-count", convertQueryParams(params, limitation));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public Tag addTag(Long userSessionId, Tag tag) {
		SqlMapSession ssn = null;

		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(tag.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, AupPrivConstants.ADD_AUTH_TAG, paramArr);

			ssn.insert("aup.add-tag", tag);

			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("lang");
			filters[0].setValue(tag.getLang());
			filters[1] = new Filter();
			filters[1].setElement("id");
			filters[1].setValue(tag.getId().toString());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (Tag) ssn.queryForObject("aup.get-tags", convertQueryParams(params));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public Tag editTag(Long userSessionId, Tag tag) {
		SqlMapSession ssn = null;

		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(tag.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, AupPrivConstants.MODIFY_AUTH_TAG, paramArr);

			ssn.update("aup.modify-tag", tag);

			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("lang");
			filters[0].setValue(tag.getLang());
			filters[1] = new Filter();
			filters[1].setElement("id");
			filters[1].setValue(tag.getId().toString());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (Tag) ssn.queryForObject("aup.get-tags", convertQueryParams(params));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void deleteTag(Long userSessionId, Tag tag) {
		SqlMapSession ssn = null;

		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(tag.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, AupPrivConstants.REMOVE_AUTH_TAG, paramArr);

			ssn.delete("aup.remove-tag", tag);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public AuthTemplate[] getTemplates(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, AupPrivConstants.VIEW_AUTHORIZATION_TEMPLATE, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, AupPrivConstants.VIEW_AUTHORIZATION_TEMPLATE);
			List<AuthTemplate> templates = ssn.queryForList("aup.get-templates", convertQueryParams(params, limitation));
			return templates.toArray(new AuthTemplate[templates.size()]);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public int getTemplatesCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, AupPrivConstants.VIEW_AUTHORIZATION_TEMPLATE, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, AupPrivConstants.VIEW_AUTHORIZATION_TEMPLATE);
			return (Integer) ssn.queryForObject("aup.get-templates-count", convertQueryParams(params, limitation));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public AuthTemplate addTemplate(Long userSessionId, AuthTemplate template) {
		SqlMapSession ssn = null;

		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(template.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, AupPrivConstants.ADD_AUTHORIZATION_TEMPLATE, paramArr);

			ssn.insert("aup.add-template", template);
			
			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("lang");
			filters[0].setValue(template.getLang());
			filters[1] = new Filter();
			filters[1].setElement("id");
			filters[1].setValue(template.getId().toString());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (AuthTemplate) ssn.queryForObject("aup.get-templates", convertQueryParams(params));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public AuthTemplate editTemplate(Long userSessionId, AuthTemplate template) {
		SqlMapSession ssn = null;

		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(template.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, AupPrivConstants.MODIFY_AUTHORIZATION_TEMPLATE, paramArr);

			ssn.insert("aup.modify-template", template);
			
			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("lang");
			filters[0].setValue(template.getLang());
			filters[1] = new Filter();
			filters[1].setElement("id");
			filters[1].setValue(template.getId().toString());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (AuthTemplate) ssn.queryForObject("aup.get-templates", convertQueryParams(params));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void deleteTemplate(Long userSessionId, AuthTemplate template) {
		SqlMapSession ssn = null;

		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(template.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, AupPrivConstants.REMOVE_AUTHORIZATION_TEMPLATE, paramArr);

			ssn.delete("aup.remove-template", template);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public AuthScheme[] getSchemes(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, AupPrivConstants.VIEW_AUTHORIZATION_SCHEME, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, AupPrivConstants.VIEW_AUTHORIZATION_SCHEME);
			List<AuthScheme> schemes = ssn.queryForList("aup.get-schemes",
			        convertQueryParams(params, limitation));
			return schemes.toArray(new AuthScheme[schemes.size()]);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public int getSchemesCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, AupPrivConstants.VIEW_AUTHORIZATION_SCHEME, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, AupPrivConstants.VIEW_AUTHORIZATION_SCHEME);
			return (Integer) ssn.queryForObject("aup.get-schemes-count",
			        convertQueryParams(params, limitation));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public AuthScheme addScheme(Long userSessionId, AuthScheme scheme) {
		SqlMapSession ssn = null;

		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(scheme.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, AupPrivConstants.ADD_AUTHORIZATION_SCHEME, paramArr);

			ssn.insert("aup.add-scheme", scheme);

			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("lang");
			filters[0].setValue(scheme.getLang());
			filters[1] = new Filter();
			filters[1].setElement("id");
			filters[1].setValue(scheme.getId().toString());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (AuthScheme) ssn.queryForObject("aup.get-schemes",
			        convertQueryParams(params));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public AuthScheme editScheme(Long userSessionId, AuthScheme scheme) {
		SqlMapSession ssn = null;

		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(scheme.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, AupPrivConstants.MODIFY_AUTHORIZATION_SCHEME, paramArr);

			ssn.update("aup.edit-scheme", scheme);

			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("lang");
			filters[0].setValue(scheme.getLang());
			filters[1] = new Filter();
			filters[1].setElement("id");
			filters[1].setValue(scheme.getId().toString());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (AuthScheme) ssn.queryForObject("aup.get-schemes",
			        convertQueryParams(params));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void deleteScheme(Long userSessionId, AuthScheme scheme) {
		SqlMapSession ssn = null;

		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(scheme.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, AupPrivConstants.REMOVE_AUTHORIZATION_SCHEME, paramArr);

			ssn.delete("aup.delete-scheme", scheme);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public AuthTemplate[] getTemplateForScheme(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, AupPrivConstants.VIEW_AUTHORIZATION_TEMPLATE, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, AupPrivConstants.VIEW_AUTHORIZATION_TEMPLATE);
			List<AuthTemplate> templates = ssn.queryForList("aup.get-templates-for-scheme", convertQueryParams(params, limitation));
			return templates.toArray(new AuthTemplate[templates.size()]);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public int getTemplatesForSchemeCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, AupPrivConstants.VIEW_AUTHORIZATION_TEMPLATE, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, AupPrivConstants.VIEW_AUTHORIZATION_TEMPLATE);
			return (Integer) ssn.queryForObject("aup.get-templates-for-scheme-count",
			        convertQueryParams(params, limitation));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public AuthTemplate addTemplateToScheme(Long userSessionId, Integer schemeId, Integer templateId) {
		SqlMapSession ssn = null;

		try {
			ssn = getIbatisSessionFE(userSessionId);

			HashMap<String, Integer> map = new HashMap<String, Integer>(2);
			map.put("schemeId", schemeId);
			map.put("templateId", templateId);

			ssn.insert("aup.add_scheme_template", map);

			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("schemeId");
			filters[0].setValue(schemeId);
			filters[1] = new Filter();
			filters[1].setElement("templateId");
			filters[1].setValue(templateId);

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);
			return (AuthTemplate) ssn.queryForObject("aup.get-templates-for-scheme",
			        convertQueryParams(params));

		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void removeTemplateFromScheme(Long userSessionId, Integer schemeId, Integer templateId) {
		SqlMapSession ssn = null;

		try {
			ssn = getIbatisSessionFE(userSessionId);

			HashMap<String, Integer> map = new HashMap<String, Integer>(2);
			map.put("schemeId", schemeId);
			map.put("templateId", templateId);

			ssn.delete("aup.remove_scheme_template", map);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public AuthSchemeObject[] getObjectsForScheme(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSessionFE(userSessionId);
			List<AuthSchemeObject> objects = ssn.queryForList("aup.get-objects-for-scheme", convertQueryParams(params));
			return objects.toArray(new AuthSchemeObject[objects.size()]);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public int getObjectsForSchemeCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSessionFE(userSessionId);
			return (Integer) ssn.queryForObject("aup.get-objects-for-scheme-count",
			        convertQueryParams(params));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public AuthSchemeObject addSchemeObject(Long userSessionId, AuthSchemeObject schemeObj) {
		SqlMapSession ssn = null;

		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(schemeObj.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, AupPrivConstants.ADD_SCHEME_OBJECT, paramArr);


			ssn.insert("aup.add-scheme-object", schemeObj);

			Filter[] filters = new Filter[1];
			filters[0] = new Filter();
			filters[0].setElement("id");
			filters[0].setValue(schemeObj.getId().toString());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (AuthSchemeObject) ssn.queryForObject("aup.get-objects-for-scheme",
			        convertQueryParams(params));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public AuthSchemeObject editSchemeObject(Long userSessionId, AuthSchemeObject schemeObj) {
		SqlMapSession ssn = null;

		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(schemeObj.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, AupPrivConstants.ADD_SCHEME_OBJECT, paramArr);

			ssn.update("aup.edit-scheme-object", schemeObj);

			Filter[] filters = new Filter[1];
			filters[0] = new Filter();
			filters[0].setElement("id");
			filters[0].setValue(schemeObj.getId().toString());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (AuthSchemeObject) ssn.queryForObject("aup.get-objects-for-scheme",
			        convertQueryParams(params));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}
	
	public void removeSchemeObject(Long userSessionId, AuthSchemeObject schemeObj) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(schemeObj.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, AupPrivConstants.REMOVE_SCHEME_OBJECT, paramArr);

			ssn.update("aup.remove-scheme-object", schemeObj);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public CardStatResp[] getCardStatResps(Long userSessionId,
			SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, AupPrivConstants.VIEW_CARD_STATUS_RESP, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, AupPrivConstants.VIEW_CARD_STATUS_RESP);
			List<CardStatResp> cardStatResps = ssn.queryForList("aup.get-card-stat-resps", convertQueryParams(params, limitation));
			return cardStatResps.toArray(new CardStatResp[cardStatResps.size()]);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public int getCardStatRespsCount(Long userSessionId,
			SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, AupPrivConstants.VIEW_CARD_STATUS_RESP, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, AupPrivConstants.VIEW_CARD_STATUS_RESP);
			return (Integer) ssn.queryForObject("aup.get-card-stat-resps-count",
			        convertQueryParams(params, limitation));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	public CardStatResp addCardStatResp(Long userSessionId,
			CardStatResp cardStatResp){
		SqlMapSession ssn = null;

		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(cardStatResp.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, AupPrivConstants.ADD_CARD_STATUS_RESP, paramArr);

			ssn.insert("aup.add-card-stat-resp", cardStatResp);
			Filter[] filters = new Filter[1];
			filters[0] = new Filter();
			filters[0].setElement("id");
			filters[0].setValue(cardStatResp.getId().toString());
			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (CardStatResp) ssn.queryForObject("aup.get-card-stat-resps", convertQueryParams(params));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	public CardStatResp editCardStatResp(Long userSessionId,
			CardStatResp cardStatResp){
		SqlMapSession ssn = null;

		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(cardStatResp.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, AupPrivConstants.MODIFY_CARD_STATUS_RESP, paramArr);

			ssn.update("aup.modify-card-stat-resp", cardStatResp);

			Filter[] filters = new Filter[1];
			filters[0] = new Filter();
			filters[0].setElement("id");
			filters[0].setValue(cardStatResp.getId().toString());
			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (CardStatResp) ssn.queryForObject("aup.get-card-stat-resps", convertQueryParams(params));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
		
	}
	
	public void removeCardStatRespLong(Long userSessionId, CardStatResp cardStatResp) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(cardStatResp.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, AupPrivConstants.REMOVE_CARD_STATUS_RESP, paramArr);

			ssn.update("aup.remove-card-stat-resp", cardStatResp);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	@SuppressWarnings("unchecked")
	public TagValue[] getTagValues(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, ReportPrivConstants.VIEW_TAG, paramArr);
			List<TagValue> items = ssn.queryForList("aup.get-tag-values", convertQueryParams(
					params));
			return items.toArray(new TagValue[items.size()]);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public int getTagValuesCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, ReportPrivConstants.VIEW_TAG, paramArr);
			int count = (Integer) ssn.queryForObject("aup.get-tag-values-count",
					convertQueryParams(params));
			return count;
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}
	

	public List<Amount> getAmounts(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSessionFE(userSessionId);
			return ssn.queryForList("aup.get-amounts", convertQueryParams(params));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}
}
