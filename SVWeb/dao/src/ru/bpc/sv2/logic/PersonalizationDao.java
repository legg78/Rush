package ru.bpc.sv2.logic;

import com.ibatis.sqlmap.client.SqlMapSession;
import org.apache.log4j.Logger;
import ru.bpc.sv2.common.CommonParamRec;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.issuing.CardSecurityData;
import ru.bpc.sv2.issuing.personalization.*;
import ru.bpc.sv2.logic.controller.CommonController;
import ru.bpc.sv2.logic.utility.db.IbatisAware;
import ru.bpc.sv2.logic.utility.db.IbatisSessionCallback;
import ru.bpc.sv2.logic.utility.db.QueryParams;
import ru.bpc.sv2.utils.AuditParamUtil;


import java.math.BigDecimal;
import java.sql.SQLException;
import java.util.*;

/**
 * Session Bean implementation class PersonalizationDao
 */
public class PersonalizationDao extends IbatisAware {
	private static final Logger logger = Logger.getLogger("PERSONALIZATION");

	@SuppressWarnings("unchecked")
	public KeySchema[] getKeySchemas(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, PersonalizationPrivConstants.VIEW_PERSO_KEY_SCHEMA, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, PersonalizationPrivConstants.VIEW_PERSO_KEY_SCHEMA);
			List<KeySchema> keySchemas = ssn.queryForList("prs.get-key-schemas",
			        convertQueryParams(params, limitation));
			return keySchemas.toArray(new KeySchema[keySchemas.size()]);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public int getKeySchemasCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, PersonalizationPrivConstants.VIEW_PERSO_KEY_SCHEMA, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, PersonalizationPrivConstants.VIEW_PERSO_KEY_SCHEMA);
			return (Integer) ssn.queryForObject("prs.get-key-schemas-count",
			        convertQueryParams(params, limitation));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public KeySchema addKeySchema(Long userSessionId, KeySchema keySchema) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(keySchema.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, PersonalizationPrivConstants.ADD_PERSO_KEY_SCHEMA, paramArr);

			ssn.update("prs.add-key-schema", keySchema);

			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("id");
			filters[0].setValue(keySchema.getId().toString());
			filters[1] = new Filter();
			filters[1].setElement("lang");
			filters[1].setValue(keySchema.getLang());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (KeySchema) ssn
					.queryForObject("prs.get-key-schemas", convertQueryParams(params));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public KeySchema modifyKeySchema(Long userSessionId, KeySchema keySchema) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(keySchema.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, PersonalizationPrivConstants.MODIFY_PERSO_KEY_SCHEMA, paramArr);

			ssn.update("prs.modify-key-schema", keySchema);

			// instId isn't modified so we don't need instName, other fields are
			// either
			// static or updated automatically
			return keySchema;
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void deleteKeySchema(Long userSessionId, KeySchema keySchema) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(keySchema.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, PersonalizationPrivConstants.REMOVE_PERSO_KEY_SCHEMA, paramArr);

			ssn.delete("prs.remove-key-schema", keySchema);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public KeySchemaEntity[] getKeySchemaEntities(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, PersonalizationPrivConstants.VIEW_PERSO_KEY_SCHEMA_ENTITY, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, PersonalizationPrivConstants.VIEW_PERSO_KEY_SCHEMA_ENTITY);
			List<KeySchemaEntity> keySchemaEntities = ssn.queryForList(
			        "prs.get-key-schema-entities", convertQueryParams(params, limitation));
			return keySchemaEntities.toArray(new KeySchemaEntity[keySchemaEntities.size()]);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public int getKeySchemaEntitiesCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, PersonalizationPrivConstants.VIEW_PERSO_KEY_SCHEMA_ENTITY, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, PersonalizationPrivConstants.VIEW_PERSO_KEY_SCHEMA_ENTITY);
			return (Integer) ssn.queryForObject("prs.get-key-schema-entities-count",
			        convertQueryParams(params, limitation));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public KeySchemaEntity addKeySchemaEntity(Long userSessionId, KeySchemaEntity keySchemaEntity) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(keySchemaEntity.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, PersonalizationPrivConstants.ADD_PERSO_KEY_SCHEMA_ENTITY, paramArr);

			ssn.update("prs.add-key-schema-entity", keySchemaEntity);

			return keySchemaEntity;
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public KeySchemaEntity modifyKeySchemaEntity(Long userSessionId, KeySchemaEntity keySchemaEntity) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(keySchemaEntity.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, PersonalizationPrivConstants.MODIFY_PERSO_KEY_SCHEMA_ENTITY, paramArr);

			ssn.update("prs.modify-key-schema-entity", keySchemaEntity);

			return keySchemaEntity;
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void deleteKeySchemaEntity(Long userSessionId, KeySchemaEntity keySchemaEntity) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(keySchemaEntity.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, PersonalizationPrivConstants.REMOVE_PERSO_KEY_SCHEMA_ENTITY, paramArr);

			ssn.delete("prs.remove-key-schema-entity", keySchemaEntity);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public PrsMethod[] getMethods(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, PersonalizationPrivConstants.VIEW_PERSO_METHODS, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, PersonalizationPrivConstants.VIEW_PERSO_METHODS);
			List<PrsMethod> methods = ssn.queryForList("prs.get-methods",
			        convertQueryParams(params, limitation));
			return methods.toArray(new PrsMethod[methods.size()]);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public int getMethodsCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, PersonalizationPrivConstants.VIEW_PERSO_METHODS, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, PersonalizationPrivConstants.VIEW_PERSO_METHODS);
			return (Integer) ssn
			        .queryForObject("prs.get-methods-count", convertQueryParams(params, limitation));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public PrsMethod addMethod(Long userSessionId, PrsMethod method) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(method.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, PersonalizationPrivConstants.ADD_PERSO_METHOD, paramArr);

			ssn.update("prs.add-method", method);

			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("id");
			filters[0].setValue(method.getId().toString());
			filters[1] = new Filter();
			filters[1].setElement("lang");
			filters[1].setValue(method.getLang());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (PrsMethod) ssn.queryForObject("prs.get-methods", convertQueryParams(params));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public PrsMethod modifyMethod(Long userSessionId, PrsMethod method) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(method.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, PersonalizationPrivConstants.MODIFY_PERSO_METHOD, paramArr);

			ssn.update("prs.modify-method", method);

			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("id");
			filters[0].setValue(method.getId().toString());
			filters[1] = new Filter();
			filters[1].setElement("lang");
			filters[1].setValue(method.getLang());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (PrsMethod) ssn.queryForObject("prs.get-methods", convertQueryParams(params));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void deleteMethod(Long userSessionId, PrsMethod method) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(method.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, PersonalizationPrivConstants.REMOVE_PERSO_METHOD, paramArr);

			ssn.delete("prs.remove-method", method);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public PrsTemplate[] getTemplates(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null,  PersonalizationPrivConstants.VIEW_PERSO_TEMPLATES, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, PersonalizationPrivConstants.VIEW_PERSO_TEMPLATES);
			List<PrsTemplate> templates = ssn.queryForList("prs.get-templates",
			        convertQueryParams(params, limitation));
			return templates.toArray(new PrsTemplate[templates.size()]);
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
			ssn = getIbatisSession(userSessionId, null,  PersonalizationPrivConstants.VIEW_PERSO_TEMPLATES, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, PersonalizationPrivConstants.VIEW_PERSO_TEMPLATES);
			return (Integer) ssn.queryForObject("prs.get-templates-count",
			        convertQueryParams(params, limitation));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public PrsTemplate addTemplate(Long userSessionId, PrsTemplate template, String lang) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(template.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null,  PersonalizationPrivConstants.ADD_PERSO_TEMPLATE, paramArr);

			ssn.update("prs.add-template", template);

			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("id");
			filters[0].setValue(template.getId().toString());
			filters[1] = new Filter();
			filters[1].setElement("lang");
			filters[1].setValue(lang);

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (PrsTemplate) ssn
					.queryForObject("prs.get-templates", convertQueryParams(params));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public PrsTemplate modifyTemplate(Long userSessionId, PrsTemplate template, String lang) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(template.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null,  PersonalizationPrivConstants.MODIFY_PERSO_TEMPLATE, paramArr);

			ssn.update("prs.modify-template", template);

			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("id");
			filters[0].setValue(template.getId().toString());
			filters[1] = new Filter();
			filters[1].setElement("lang");
			filters[1].setValue(lang);

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (PrsTemplate) ssn
					.queryForObject("prs.get-templates", convertQueryParams(params));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void deleteTemplate(Long userSessionId, PrsTemplate template) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(template.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null,  PersonalizationPrivConstants.REMOVE_PERSO_TEMPLATE, paramArr);

			ssn.delete("prs.remove-template", template);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public PersoCard[] getPersoCards(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, PersonalizationPrivConstants.VIEW_PERSO_CARD, paramArr);

			List<PersoCard> cards = ssn.queryForList("prs.get-perso-cards",
					convertQueryParams(params));
			return cards.toArray(new PersoCard[cards.size()]);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public int getPersoCardsCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, PersonalizationPrivConstants.VIEW_PERSO_CARD, paramArr);
			return (Integer) ssn.queryForObject("prs.get-perso-cards-count",
					convertQueryParams(params));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void addBatchCard(Long userSessionId, PersoCard card) {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSessionFE(userSessionId);

			ssn.update("prs.add-perso-batch-card", card);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void removeBatchCard(Long userSessionId, PersoCard card) {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSessionFE(userSessionId);

			ssn.update("prs.remove-perso-batch-card", card);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void markBatchCard(Long userSessionId, PersoCard card) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(card.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, PersonalizationPrivConstants.MARK_PERSO_BATCH_CARD, paramArr);

			ssn.update("prs.mark-perso-batch-card", card);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void unmarkBatchCard(Long userSessionId, PersoCard card) {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSessionFE(userSessionId);

			ssn.update("prs.unmark-perso-batch-card", card);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public PersoBatchCard[] getPersoBatchCards(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, PersonalizationPrivConstants.VIEW_PERSO_BATCH_CARD, paramArr);

			List<PersoBatchCard> cards = ssn.queryForList("prs.get-perso-batch-cards",
					convertQueryParams(params));
			return cards.toArray(new PersoBatchCard[cards.size()]);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public int getPersoBatchCardsCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, PersonalizationPrivConstants.VIEW_PERSO_BATCH_CARD, paramArr);
			return (Integer) ssn.queryForObject("prs.get-perso-batch-cards-count",
					convertQueryParams(params));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}
	
	@SuppressWarnings("unchecked")
	public PrsBatch[] getBatches(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, PersonalizationPrivConstants.VIEW_PERSO_BATCHES, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, PersonalizationPrivConstants.VIEW_PERSO_BATCHES);
			List<PrsBatch> batches = ssn
			        .queryForList("prs.get-batches", convertQueryParams(params, limitation));
			return batches.toArray(new PrsBatch[batches.size()]);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public int getBatchesCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, PersonalizationPrivConstants.VIEW_PERSO_BATCHES, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, PersonalizationPrivConstants.VIEW_PERSO_BATCHES);
			return (Integer) ssn
			        .queryForObject("prs.get-batches-count", convertQueryParams(params, limitation));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public PrsBatch addBatch(Long userSessionId, PrsBatch batch) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(batch.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, PersonalizationPrivConstants.ADD_PERSO_BATCH, paramArr);

			ssn.update("prs.add-batch", batch);

			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("id");
			filters[0].setValue(batch.getId().toString());
			filters[1] = new Filter();
			filters[1].setElement("lang");
			filters[1].setValue(batch.getLang());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (PrsBatch) ssn.queryForObject("prs.get-batches", convertQueryParams(params));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public PrsBatch modifyBatch(Long userSessionId, PrsBatch batch) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(batch.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, PersonalizationPrivConstants.MODIFY_PERSO_BATCH, paramArr);

			ssn.update("prs.modify-batch", batch);

			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("id");
			filters[0].setValue(batch.getId().toString());
			filters[1] = new Filter();
			filters[1].setElement("lang");
			filters[1].setValue(batch.getLang());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (PrsBatch) ssn.queryForObject("prs.get-batches", convertQueryParams(params));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void deleteBatch(Long userSessionId, PrsBatch batch) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(batch.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, PersonalizationPrivConstants.REMOVE_PERSO_BATCH, paramArr);

			ssn.delete("prs.remove-batch", batch);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}
	
	@SuppressWarnings("unchecked")
	public BlankType[] getBlankTypes(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, PersonalizationPrivConstants.VIEW_BLANK_TYPE, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, PersonalizationPrivConstants.VIEW_BLANK_TYPE);
			List<BlankType> blankTypes = ssn
			        .queryForList("prs.get-blank-types", convertQueryParams(params, limitation));
			return blankTypes.toArray(new BlankType[blankTypes.size()]);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public int getBlankTypesCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, PersonalizationPrivConstants.VIEW_BLANK_TYPE, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, PersonalizationPrivConstants.VIEW_BLANK_TYPE);
			return (Integer) ssn
			        .queryForObject("prs.get-blank-types-count", convertQueryParams(params, limitation));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public BlankType addBlankType(Long userSessionId, BlankType blankType) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(blankType.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, PersonalizationPrivConstants.ADD_BLANK_TYPE, paramArr);

			ssn.update("prs.add-blank-type", blankType);

			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("id");
			filters[0].setValue(blankType.getId().toString());
			filters[1] = new Filter();
			filters[1].setElement("lang");
			filters[1].setValue(blankType.getLang());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (BlankType) ssn.queryForObject("prs.get-blank-types", convertQueryParams(params));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public BlankType modifyBlankType(Long userSessionId, BlankType blankType) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(blankType.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, PersonalizationPrivConstants.MODIFY_BLANK_TYPE, paramArr);

			ssn.update("prs.modify-blank-type", blankType);

			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("id");
			filters[0].setValue(blankType.getId().toString());
			filters[1] = new Filter();
			filters[1].setElement("lang");
			filters[1].setValue(blankType.getLang());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (BlankType) ssn.queryForObject("prs.get-blank-types", convertQueryParams(params));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void deleteBlankType(Long userSessionId, BlankType blankType) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(blankType.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, PersonalizationPrivConstants.MODIFY_BLANK_TYPE, paramArr);

			ssn.delete("prs.remove-blank-type", blankType);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public PrsSort[] getSorts(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, PersonalizationPrivConstants.VIEW_PRS_SORT, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, PersonalizationPrivConstants.VIEW_PRS_SORT);
			List<PrsSort> sorts = ssn
			        .queryForList("prs.get-sorts", convertQueryParams(params, limitation));
			return sorts.toArray(new PrsSort[sorts.size()]);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public int getSortsCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, PersonalizationPrivConstants.VIEW_PRS_SORT, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, PersonalizationPrivConstants.VIEW_PRS_SORT);
			return (Integer) ssn
			        .queryForObject("prs.get-sorts-count", convertQueryParams(params, limitation));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public PrsSort addSort(Long userSessionId, PrsSort sort) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(sort.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, PersonalizationPrivConstants.ADD_PRS_SORT, paramArr);

			ssn.update("prs.add-sort", sort);

			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("id");
			filters[0].setValue(sort.getId().toString());
			filters[1] = new Filter();
			filters[1].setElement("lang");
			filters[1].setValue(sort.getLang());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (PrsSort) ssn.queryForObject("prs.get-sorts", convertQueryParams(params));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public PrsSort modifySort(Long userSessionId, PrsSort sort) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(sort.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, PersonalizationPrivConstants.MODIFY_PRS_SORT, paramArr);

			ssn.update("prs.modify-sort", sort);

			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("id");
			filters[0].setValue(sort.getId().toString());
			filters[1] = new Filter();
			filters[1].setElement("lang");
			filters[1].setValue(sort.getLang());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (PrsSort) ssn.queryForObject("prs.get-sorts", convertQueryParams(params));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void deleteSort(Long userSessionId, PrsSort sort) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(sort.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, PersonalizationPrivConstants.REMOVE_PRS_SORT, paramArr);

			ssn.delete("prs.remove-sort", sort);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public PrsBatch[] getBatchesCur(Long userSessionId, SelectionParams params,
			Map<String, Object> paramMap) {
		PrsBatch[] result;
		SqlMapSession ssn = null;
		try{
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, null, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn,
					PersonalizationPrivConstants.VIEW_PERSO_BATCHES);
			if (limitation != null){
				List<Filter> filters = new ArrayList<Filter> 
				(Arrays.asList((Filter[])paramMap.get("param_tab")));
				filters.add(new Filter("PRIVIL_LIMITATION", limitation));
				paramMap.put("param_tab", filters.toArray(new Filter[filters.size()]));
			}
			QueryParams qparams = convertQueryParams(params);
			paramMap.put("first_row", qparams.getRange().getStartPlusOne());
			paramMap.put("last_row", qparams.getRange().getEndPlusOne());
			paramMap.put("sorting_tab", params.getSortElement());
			ssn.update("prs.get-prs-cur", paramMap);
			List <PrsBatch>btch = (List<PrsBatch>)paramMap.get("ref_cur");
			for (PrsBatch singleBatch:btch){
				HashMap<String, Object> exParam = new HashMap<String, Object>();
				exParam.put("batch_id", singleBatch.getId());
				ssn = getIbatisSession(userSessionId, null, null, paramArr);
				ssn.update("prs.get-btc-details", exParam);
				singleBatch.setCardCountActual((
						(BigDecimal) exParam.get("card_count")).intValue());
				singleBatch.setPinRequestCount((
						(BigDecimal)exParam.get("pin_count")).intValue());
				singleBatch.setPinMailerRequestCount((
						(BigDecimal)exParam.get("pin_mailer_count")).intValue());
				singleBatch.setEmbossingRequestCount((
						(BigDecimal)exParam.get("embossing_count")).intValue());
				
			}
			result = btch.toArray(new PrsBatch[btch.size()]);
		}catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
		return result;
	}


	public int getBatchesCurCount(Long userSessionId, Map<String, Object> params) {
		Integer result = 0;
		SqlMapSession ssn = null;
		try{
			ssn = getIbatisSession(userSessionId);
			String limitation = CommonController.getLimitationByPriv(ssn,
					PersonalizationPrivConstants.VIEW_PERSO_BATCHES);
			if (limitation != null){
				List<Filter> filters = new ArrayList<Filter> 
				(Arrays.asList((Filter[])params.get("param_tab")));
				filters.add(new Filter("PRIVIL_LIMITATION", limitation));
				params.put("param_tab", filters.toArray(new Filter[filters.size()]));
			}
			ssn.update("prs.get-prs-cur-count", params);
			result = (Integer)params.get("row_count");
		}catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
		return result;
	}


    public void setBatchStatusDelivered(Long userSessionId, Long batchId, Integer agentId){
        SqlMapSession ssn = null;
        try {
            Map<String, Object> params = new HashMap();
            params.put("batch_id", batchId);
            params.put("agent_id", agentId);
            CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params);
            ssn = getIbatisSession(userSessionId, null,
                                   PersonalizationPrivConstants.SET_PERSO_BATCH_STATUS_DELIVERED, paramArr);
            ssn.update("prs.set-batch-status-delivered", params);

        }catch(SQLException e){
            throw createDaoException(e);
        }finally {
            close(ssn);
        }
    }
    

    public void changeBatchCardInstancesStatus(Long userSessionId, Long batchId, Integer agentId, String eventType){
        SqlMapSession ssn = null;
        try {
            Map<String, Object> params = new HashMap<String,Object>();
            params.put("batch_id", batchId);
            params.put("agent_id", agentId);
            params.put("event_type", eventType);
            CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params);
            ssn = getIbatisSession(userSessionId, null,
                                   PersonalizationPrivConstants.SET_PERSO_BATCH_STATUS_DELIVERED, paramArr);
            ssn.update("prs.change-batch-card-instances-status", params);

        }catch(SQLException e){
            throw createDaoException(e);
        }finally {
            close(ssn);
        }
    }

    @SuppressWarnings("unchecked")
    public CloneCandidateCard[] getBatchCloneCandidateCards(Long userSessionId,
                                    Long batchId) {
        CloneCandidateCard[] result;
        SqlMapSession ssn = null;
        try{

            Map<String, Object> params = new HashMap<String,Object>();
            params.put("batch_id", batchId);
            CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params);
            ssn = getIbatisSession(userSessionId, null,
                    PersonalizationPrivConstants.ADD_PERSO_BATCH, paramArr);
            ssn.update("prs.get-clone-candidate-cards", params);
            List <CloneCandidateCard> cloneCandidateCards = (List<CloneCandidateCard>)params.get("ref_cursor");
            result = cloneCandidateCards.toArray(new CloneCandidateCard[cloneCandidateCards.size()]);
        }catch (SQLException e) {
            throw createDaoException(e);
        } finally {
            close(ssn);
        }
        return result;
    }

    @SuppressWarnings("unchecked")
    public void cloneBatchWithAllOption(Long userSessionId,
                                        Long batchId,
                                        String clonedBatchName,
                                        String pinRequest, 
                                        String pinMailerRequest, 
                                        String embossingRequest) {
        SqlMapSession ssn = null;
        try{
            Map<String, Object> params = new HashMap<String,Object>();
            params.put("batch_id", batchId);
            params.put("batch_name", clonedBatchName);
            params.put("pin_request", pinRequest);
            params.put("pin_mailer_request", pinMailerRequest);
            params.put("embossing_request", embossingRequest);

            CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params);
            ssn = getIbatisSession(userSessionId, null,
                    PersonalizationPrivConstants.ADD_PERSO_BATCH, paramArr);
            ssn.update("prs.clone-batch-with-all-option", params);

        }catch (SQLException e) {
            throw createDaoException(e);
        } finally {
            close(ssn);
        }
    }

    @SuppressWarnings("unchecked")
    public void cloneBatchWithSelectOption(Long userSessionId,
                                          Long batchId,
                                          String clonedBatchName,
                                          Long[] instanceList,
                                          String pinRequest, 
                                          String pinMailerRequest, 
                                          String embossingRequest) {
        SqlMapSession ssn = null;
        try{
            Map<String, Object> params = new HashMap<String,Object>();
            params.put("batch_id", batchId);
            params.put("batch_name", clonedBatchName);
            params.put("instance_list", instanceList);
            params.put("pin_request", pinRequest);
            params.put("pin_mailer_request", pinMailerRequest);
            params.put("embossing_request", embossingRequest);

            CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params);
            ssn = getIbatisSession(userSessionId, null,
                    PersonalizationPrivConstants.ADD_PERSO_BATCH, paramArr);
            ssn.update("prs.clone-batch-with-select-option", params);

        }catch (SQLException e) {
            throw createDaoException(e);
        } finally {
            close(ssn);
        }
    }

    @SuppressWarnings("unchecked")
    public void cloneBatchWithRangeOption(Long userSessionId,
                                           Long batchId,
                                           String clonedBatchName,
                                           Integer firstRow,
                                           Integer lastRow,
                                           String pinRequest, 
                                           String pinMailerRequest, 
                                           String embossingRequest) {
        SqlMapSession ssn = null;
        try{
            Map<String, Object> params = new HashMap<String,Object>();
            params.put("batch_id", batchId);
            params.put("batch_name", clonedBatchName);
            params.put("first_row", firstRow);
            params.put("pin_request", pinRequest);
            params.put("pin_mailer_request", pinMailerRequest);
            params.put("embossing_request", embossingRequest);
            
            if(lastRow!=null) params.put("last_row", lastRow);

            CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params);
            ssn = getIbatisSession(userSessionId, null,
                    PersonalizationPrivConstants.ADD_PERSO_BATCH, paramArr);
            ssn.update("prs.clone-batch-with-range-option", params);

        }catch (SQLException e) {
            throw createDaoException(e);
        } finally {
            close(ssn);
        }
    }


    public void changeBatchCardInstancesState(Long userSessionId, Long batchId, Integer agentId, String state, String eventType) {
	    SqlMapSession ssn = null;
	    try {
		    Map<String, Object> params = new HashMap<String, Object>();
		    params.put("batch_id", batchId);
		    params.put("agent_id", agentId);
		    params.put("state", state);
		    params.put("eventType", eventType);
		    CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params);
		    ssn = getIbatisSession(userSessionId, null,
				    PersonalizationPrivConstants.SET_PERSO_BATCH_STATUS_DELIVERED, paramArr);
		    ssn.update("prs.change-batch-card-instances-state-by-new-state", params);

	    } catch (SQLException e) {
		    throw createDaoException(e);
	    } finally {
		    close(ssn);
	    }
    }


	public void changeCardSecurityData(Long userSessionId, final CardSecurityData cardSecurityData) {
		executeWithSession(userSessionId,
						   PersonalizationPrivConstants.VIEW_PERSO_BATCH_CARD,
						   AuditParamUtil.getCommonParamRec(cardSecurityData),
						   logger,
						   new IbatisSessionCallback<Void>() {
			@Override
			public Void doInSession(SqlMapSession ssn) throws Exception {
				ssn.update("prs.change-card-security-data", cardSecurityData);
				return null;
			}
		});
	}
}
