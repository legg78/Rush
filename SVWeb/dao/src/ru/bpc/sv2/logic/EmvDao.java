package ru.bpc.sv2.logic;

import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

import ru.bpc.sv2.logic.utility.db.DataAccessException;


import org.apache.log4j.Logger;

import ru.bpc.sv2.common.CommonParamRec;
import ru.bpc.sv2.emv.EmvApplication;
import ru.bpc.sv2.emv.EmvApplicationScheme;
import ru.bpc.sv2.emv.EmvBlock;
import ru.bpc.sv2.emv.EmvCardInstance;
import ru.bpc.sv2.emv.EmvElement;
import ru.bpc.sv2.emv.EmvObjectScript;
import ru.bpc.sv2.emv.EmvPrivConstants;
import ru.bpc.sv2.emv.EmvScriptType;
import ru.bpc.sv2.emv.EmvTag;
import ru.bpc.sv2.emv.EmvVariable;
import ru.bpc.sv2.emv.TagValue;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.controller.CommonController;
import ru.bpc.sv2.logic.utility.db.IbatisAware;
import ru.bpc.sv2.utils.AuditParamUtil;

import com.ibatis.sqlmap.client.SqlMapSession;


public class EmvDao extends IbatisAware {
	private static final Logger logger = Logger.getLogger("EMV");

	@SuppressWarnings("unchecked")
	public EmvApplication[] getApplications(Long userSessionId,
			SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, EmvPrivConstants.VIEW_EMV_APPLICATIONS, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, EmvPrivConstants.VIEW_EMV_APPLICATIONS);
			List<EmvApplication> items = ssn.queryForList("emv.get-applications",
					convertQueryParams(params, limitation));
			return items.toArray(new EmvApplication[items.size()]);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public int getApplicationsCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, EmvPrivConstants.VIEW_EMV_APPLICATIONS, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, EmvPrivConstants.VIEW_EMV_APPLICATIONS);
			int count = (Integer) ssn.queryForObject(
					"emv.get-applications-count", convertQueryParams(params, limitation));
			return count;
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public EmvApplication modifyApplication(Long userSessionId, EmvApplication editingItem) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(editingItem.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, EmvPrivConstants.MODIFY_EMV_APPLICATION, paramArr);
			ssn.update("emv.modify-application", editingItem);
			Filter[] filters = new Filter[]{
					new Filter("id", editingItem.getId()),
					new Filter("lang", editingItem.getLang())
			};
			SelectionParams params = new SelectionParams(filters);
			List<EmvApplication> items = ssn.queryForList("emv.get-applications",
					convertQueryParams(params));
			if (items.size() > 0){
				return items.get(0);
			} else {
				throw new IllegalStateException("An unhandled exception occured while modification of a new application");
			}			
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void removeApplication(Long userSessionId, EmvApplication activeItem) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(activeItem.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, EmvPrivConstants.REMOVE_EMV_APPLICATION, paramArr);
			ssn.update("emv.remove-application", activeItem);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public EmvApplication createApplication(Long userSessionId, EmvApplication editingItem) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(editingItem.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, EmvPrivConstants.ADD_EMV_APPLICATION, paramArr);
			ssn.update("emv.add-application", editingItem);
			Filter[] filters = new Filter[]{
					new Filter("id", editingItem.getId()),
					new Filter("lang", editingItem.getLang())
			};
			SelectionParams params = new SelectionParams(filters);
			List<EmvApplication> items = ssn.queryForList("emv.get-applications",
					convertQueryParams(params));
			if (items.size() > 0){
				return items.get(0);
			} else {
				throw new IllegalStateException("An unhandled exception occured while creation of a new application");
			}
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public EmvBlock[] getBlocks(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, EmvPrivConstants.VIEW_EMV_DATA_BLOCKS, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, EmvPrivConstants.VIEW_EMV_DATA_BLOCKS);
			List<EmvBlock> items = ssn.queryForList(
					"emv.get-blocks", convertQueryParams(params, limitation));
			return items.toArray(new EmvBlock[items.size()]);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public int getBlocksCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, EmvPrivConstants.VIEW_EMV_DATA_BLOCKS, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, EmvPrivConstants.VIEW_EMV_DATA_BLOCKS);
			int count = (Integer)ssn.queryForObject("emv.get-blocks-count",
					convertQueryParams(params, limitation));
			return count;
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public EmvBlock createBlock(Long userSessionId, EmvBlock editingItem) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(editingItem.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, EmvPrivConstants.ADD_EMV_DATA_BLOCK, paramArr);
			ssn.update("emv.add-block", editingItem);
			
			Filter[] filters = new Filter[1];
			Filter f = new Filter();
			f.setElement("id");
			f.setValue(editingItem.getId());
			filters[0] = f;
			SelectionParams params = new SelectionParams();
			params.setFilters(filters);
			EmvBlock result = (EmvBlock) ssn.queryForObject("emv.get-blocks", convertQueryParams(params));
			return result;
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public EmvBlock modifyBlock(Long userSessionId, EmvBlock editingItem) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(editingItem.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, EmvPrivConstants.MODIFY_EMV_DATA_BLOCK, paramArr);
			ssn.update("emv.modify-block", editingItem);
			
			Filter[] filters = new Filter[1];
			Filter f = new Filter();
			f.setElement("id");
			f.setValue(editingItem.getId());
			filters[0] = f;
			SelectionParams params = new SelectionParams();
			params.setFilters(filters);
			EmvBlock result = (EmvBlock) ssn.queryForObject("emv.get-blocks", convertQueryParams(params));
			return result;
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void removeBlock(Long userSessionId, EmvBlock activeItem) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(activeItem.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, EmvPrivConstants.REMOVE_EMV_DATA_BLOCK, paramArr);
			ssn.update("emv.remove-block", activeItem);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public EmvVariable[] getVariables(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, EmvPrivConstants.VIEW_EMV_DATA_VARS, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, EmvPrivConstants.VIEW_EMV_DATA_VARS);
			List<EmvVariable> items = ssn.queryForList(
					"emv.get-variables", convertQueryParams(params, limitation));
			return items.toArray(new EmvVariable[items.size()]);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public int getVariablesCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, EmvPrivConstants.VIEW_EMV_DATA_VARS, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, EmvPrivConstants.VIEW_EMV_DATA_VARS);
			int count = (Integer)ssn.queryForObject("emv.get-variables-count",
					convertQueryParams(params, limitation));
			return count;
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}
	

	public EmvVariable createVariable(Long userSessionId, EmvVariable editingItem) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(editingItem.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, EmvPrivConstants.ADD_EMV_DATA_VAR, paramArr);
			ssn.update("emv.add-variable", editingItem);
			
			Filter[] filters = new Filter[1];
			Filter f = new Filter();
			f.setElement("id");
			f.setValue(editingItem.getId());
			filters[0] = f;
			SelectionParams params = new SelectionParams();
			params.setFilters(filters);
			EmvVariable result = (EmvVariable) ssn.queryForObject("emv.get-variables", convertQueryParams(params));
			return result;
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public EmvVariable modifyVariable(Long userSessionId, EmvVariable editingItem) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(editingItem.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, EmvPrivConstants.MODIFY_EMV_DATA_VAR, paramArr);
			ssn.update("emv.modify-variable", editingItem);
			
			Filter[] filters = new Filter[1];
			Filter f = new Filter();
			f.setElement("id");
			f.setValue(editingItem.getId());
			filters[0] = f;
			SelectionParams params = new SelectionParams();
			params.setFilters(filters);
			EmvVariable result = (EmvVariable) ssn.queryForObject("emv.get-variables", convertQueryParams(params));
			return result;
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void removeVariable(Long userSessionId, EmvVariable activeItem) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(activeItem.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, EmvPrivConstants.REMOVE_EMV_DATA_VAR, paramArr);
			ssn.update("emv.remove-variable", activeItem);
			
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public EmvElement[] getElements(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, EmvPrivConstants.VIEW_EMV_ELEMENTS, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, EmvPrivConstants.VIEW_EMV_ELEMENTS);
			List<EmvElement> items = ssn.queryForList(
					"emv.get-emv-elements", convertQueryParams(params, limitation));
			return items.toArray(new EmvElement[items.size()]);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public int getElementsCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, EmvPrivConstants.VIEW_EMV_ELEMENTS, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, EmvPrivConstants.VIEW_EMV_ELEMENTS);
			int count = (Integer)ssn.queryForObject("emv.get-emv-elements-count",
					convertQueryParams(params, limitation));
			return count;
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public EmvElement createElement( Long userSessionId, EmvElement editingItem){
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(editingItem.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, EmvPrivConstants.ADD_EMV_ELEMENT, paramArr);
			ssn.update("emv.add-element", editingItem);
			
			Filter[] filters = new Filter[1];
			Filter f = new Filter();
			f.setElement("id");
			f.setValue(editingItem.getId());
			filters[0] = f;
			SelectionParams params = new SelectionParams();
			params.setFilters(filters);
			EmvElement result = (EmvElement) ssn.queryForObject("emv.get-emv-elements", convertQueryParams(params));
			return result;
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public EmvElement modifyElement( Long userSessionId, EmvElement editingItem){
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(editingItem.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, EmvPrivConstants.MODIFY_EMV_ELEMENT, paramArr);
			ssn.update("emv.modify-element", editingItem);
			
			Filter[] filters = new Filter[1];
			Filter f = new Filter();
			f.setElement("id");
			f.setValue(editingItem.getId());
			filters[0] = f;
			SelectionParams params = new SelectionParams();
			params.setFilters(filters);
			EmvElement result = (EmvElement) ssn.queryForObject("emv.get-emv-elements", convertQueryParams(params));
			return result;
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void removeElement( Long userSessionId, EmvElement activeItem){
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(activeItem.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, EmvPrivConstants.REMOVE_EMV_ELEMENT, paramArr);
			ssn.update("emv.remove-element", activeItem);	
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public EmvTag[] getTags(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, EmvPrivConstants.VIEW_EMV_TAGS, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, EmvPrivConstants.VIEW_EMV_TAGS);
			List<EmvTag> items = ssn.queryForList(
					"emv.get-emv-tags", convertQueryParams(params, limitation));
			return items.toArray(new EmvTag[items.size()]);
		} catch (SQLException e) {
			logger.error("", e);
			throw new DataAccessException(e);
		} finally {
			close(ssn);
		}
	}


	public int getTagsCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, EmvPrivConstants.VIEW_EMV_TAGS, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, EmvPrivConstants.VIEW_EMV_TAGS);
			int count = (Integer)ssn.queryForObject("emv.get-emv-tags-count",
					convertQueryParams(params, limitation));
			return count;
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public EmvTag createTag( Long userSessionId, EmvTag editingItem){
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(editingItem.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, EmvPrivConstants.ADD_EMV_TAG, paramArr);
			ssn.update("emv.add-tag", editingItem);
			
			Filter[] filters = new Filter[1];
			Filter f = new Filter();
			f.setElement("id");
			f.setValue(editingItem.getId());
			filters[0] = f;
			SelectionParams params = new SelectionParams();
			params.setFilters(filters);
			EmvTag result = (EmvTag) ssn.queryForObject("emv.get-emv-tags", convertQueryParams(params));
			return result;
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public EmvTag modifyTag( Long userSessionId, EmvTag editingItem){
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(editingItem.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, EmvPrivConstants.MODIFY_EMV_TAG, paramArr);
			ssn.update("emv.modify-tag", editingItem);
			
			Filter[] filters = new Filter[1];
			Filter f = new Filter();
			f.setElement("id");
			f.setValue(editingItem.getId());
			filters[0] = f;
			SelectionParams params = new SelectionParams();
			params.setFilters(filters);
			EmvTag result = (EmvTag) ssn.queryForObject("emv.get-emv-tags", convertQueryParams(params));
			return result;
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void removeTag( Long userSessionId, EmvTag activeItem){
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(activeItem.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, EmvPrivConstants.REMOVE_EMV_TAG, paramArr);
			ssn.update("emv.remove-tag", activeItem);	
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public EmvApplicationScheme[] getApplicationSchemes(Long userSessionId,
			SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, EmvPrivConstants.VIEW_EMV_APPL_SCHEMES, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, EmvPrivConstants.VIEW_EMV_APPL_SCHEMES);
			List<EmvApplicationScheme> items = ssn.queryForList(
					"emv.get-application-schemes", convertQueryParams(params, limitation));
			return items.toArray(new EmvApplicationScheme[items.size()]);
		} catch (SQLException e) {
			throw new DataAccessException(e);
		} finally {
			close(ssn);
		}
	}


	public int getApplicationSchemesCount(Long userSessionId,
			SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, EmvPrivConstants.VIEW_EMV_APPL_SCHEMES, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, EmvPrivConstants.VIEW_EMV_APPL_SCHEMES);
			int count = (Integer) ssn.queryForObject(
					"emv.get-application-schemes-count",
					convertQueryParams(params, limitation));
			return count;
		} catch (SQLException e) {
			throw new DataAccessException(e);
		} finally {
			close(ssn);
		}
	}


	public EmvApplicationScheme createApplicationScheme(Long userSessionId,
			EmvApplicationScheme editingItem) {
		SqlMapSession ssn = null;	
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(editingItem.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, EmvPrivConstants.ADD_EMV_APPL_SCHEME, paramArr);
			ssn.update("emv.add-appl-scheme", editingItem);
			ArrayList<Filter> filters = new ArrayList<Filter>();			
			Filter f = new Filter();
			f.setElement("lang");
			f.setValue(editingItem.getLang());
			filters.add(f);
			
			f = new Filter();
			f.setElement("id");
			f.setValue(editingItem.getInstId());
			filters.add(f);
			
			SelectionParams params = new SelectionParams();
			params.setRowIndexStart(0);
			params.setRowIndexEnd(Integer.MAX_VALUE);
			params.setFilters(filters.toArray(new Filter[filters.size()]));
			editingItem.setInstName((String)ssn.queryForObject(
					"emv.get-inst-name", convertQueryParams(params)));
			
		} catch (SQLException e) {
			throw new DataAccessException(e);
		} finally {
			close(ssn);
		}		 
			return editingItem;		
	}


	public void modifyApplicationScheme(Long userSessionId,
			EmvApplicationScheme editingItem) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(editingItem.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, EmvPrivConstants.MODIFY_EMV_APPL_SCHEME, paramArr);
			ssn.update("emv.modify-appl-scheme", editingItem);
		} catch (SQLException e) {
			throw new DataAccessException(e);
		} finally {
			close(ssn);
		}
	}


	public void removeApplicationScheme(Long userSessionId,
			EmvApplicationScheme activeItem) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(activeItem.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, EmvPrivConstants.REMOVE_EMV_APPL_SCHEME, paramArr);
			ssn.update("emv.remove-appl-scheme", activeItem);
		} catch (SQLException e) {
			throw new DataAccessException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public TagValue[] getTagValues(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, EmvPrivConstants.VIEW_EMV_TAG_VALUES, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, EmvPrivConstants.VIEW_EMV_TAG_VALUES);

			List<TagValue> items = ssn.queryForList(
					"emv.get-tag-values", convertQueryParams(params, limitation));
			return items.toArray(new TagValue[items.size()]);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public int getTagValuesCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, EmvPrivConstants.VIEW_EMV_TAG_VALUES, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, EmvPrivConstants.VIEW_EMV_TAG_VALUES);

			int count = (Integer)ssn.queryForObject("emv.get-tag-values-count",
					convertQueryParams(params, limitation));
			return count;
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}
	
	@SuppressWarnings("unchecked")
	public TagValue setTagValue(Long userSessionId, TagValue tagValue){
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(tagValue.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, EmvPrivConstants.SET_EMV_TAG_VALUE, paramArr);
			ssn.update("emv.set-tag-value", tagValue);
			Filter[] filters = new Filter[]{
				new Filter("tagId", tagValue.getTagId()),
				new Filter("profile", tagValue.getProfile())
			};
			SelectionParams sp = new SelectionParams(filters);
			List<TagValue> items = ssn.queryForList(
					"emv.get-tag-values", convertQueryParams(sp));
			if (items.size() > 0){
				return items.get(0);
			} else {
				return null;
			}
		} catch (SQLException e) {
			throw new DataAccessException(e);
		} finally {
			close(ssn);
		}
	}
	
	@SuppressWarnings("unchecked")
	public void removeTagValue(Long userSessionId, TagValue tagValue){
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(tagValue.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, EmvPrivConstants.REMOVE_EMV_TAG_VALUE, paramArr);
			ssn.update("emv.remove-tag-value", tagValue);
		} catch (SQLException e) {
			throw new DataAccessException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public EmvCardInstance[] getCartInstance(Long userSessionId,
			SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, EmvPrivConstants.VIEW_EMV_ELEMENTS, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, EmvPrivConstants.VIEW_EMV_ELEMENTS);
			List<EmvCardInstance> items =  ssn.queryForList(
					"emv.get-emv-card-instances", convertQueryParams(params, limitation));
			return items.toArray(new EmvCardInstance[items.size()]);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}	
	}
	

	public int getCartInstanceCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, EmvPrivConstants.VIEW_EMV_ELEMENTS, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, EmvPrivConstants.VIEW_EMV_TAGS);
			int count = (Integer)ssn.queryForObject("emv.get-emv-card-instances-count",
					convertQueryParams(params, limitation));
			return count;
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public EmvObjectScript[] getObjectScript(Long userSessionId,
			SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSession(userSessionId);
			List<EmvObjectScript> items = ssn.queryForList(
					"emv.get-emv-object-script", convertQueryParams(params));
			return items.toArray(new EmvObjectScript[items.size()]);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}
	

	public int getObjectScriptCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSessionFE(userSessionId);
			int count = (Integer)ssn.queryForObject("emv.get-emv-object-script-count",
					convertQueryParams(params));
			return count;
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}
	

	public EmvObjectScript createScript(Long userSessionId, EmvObjectScript editingItem) {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSessionFE(userSessionId);
			ssn.update("emv.add-script", editingItem);
			
			Filter[] filters = new Filter[2];
			Filter f = new Filter();
			f.setElement("objectId");
			f.setValue(editingItem.getObjectId());
			filters[0] = f;
			f = new Filter();
			f.setElement("emtityType");
			f.setValue(editingItem.getEntityType());
			filters[1] = f;
			
			SelectionParams params = new SelectionParams();
			params.setFilters(filters);
			EmvObjectScript result = (EmvObjectScript) ssn.queryForObject("emv.get-emv-object-script",
					convertQueryParams(params));
			return result;
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public String getScriptFormUrl(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSessionFE(userSessionId);
			String url = (String)ssn.queryForObject("emv.get-emv-script-form-url",
					convertQueryParams(params));
			return url;
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void removeScript(Long userSessionId, EmvObjectScript activeItem) {		
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSessionFE(userSessionId);
			ssn.update("emv.remove-script", activeItem);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public EmvScriptType[] getScriptType(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, EmvPrivConstants.VIEW_EMV_SCRIPT_TYPE, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, EmvPrivConstants.VIEW_EMV_SCRIPT_TYPE);
			@SuppressWarnings("unchecked")
			List<EmvScriptType> items =  ssn.queryForList(
					"emv.get-emv-script-type", convertQueryParams(params, limitation));
			return items.toArray(new EmvScriptType[items.size()]);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public int getCardTypeCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, EmvPrivConstants.VIEW_EMV_TAGS, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, EmvPrivConstants.VIEW_EMV_TAGS);
			int count = (Integer)ssn.queryForObject("emv.get-emv-script-type-count",
					convertQueryParams(params, limitation));
			return count;
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public EmvScriptType createScriptType(Long userSessionId,
			EmvScriptType editingItem) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(editingItem.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, EmvPrivConstants.ADD_EMV_SCRIPT_TYPE, paramArr);
			ssn.update("emv.add-script-type", editingItem);
			
			Filter[] filters = new Filter[1];
			Filter f = new Filter();
			f.setElement("id");
			f.setValue(editingItem.getId());
			filters[0] = f;
			SelectionParams params = new SelectionParams();
			params.setFilters(filters);			
			List<EmvScriptType> items = ssn.queryForList("emv.get-emv-script-type",
					convertQueryParams(params));
			if (items.size() > 0){
				return items.get(0);
			} else {
				throw new IllegalStateException("");
			}
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public EmvScriptType modifyScriptType(Long userSessionId,
			EmvScriptType editingItem) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(editingItem.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, EmvPrivConstants.MODIFY_EMV_SCRIPT_TYPE, paramArr);
			ssn.update("emv.modify-script-type", editingItem);
			
			Filter[] filters = new Filter[1];
			Filter f = new Filter();
			f.setElement("id");
			f.setValue(editingItem.getId());
			filters[0] = f;
			SelectionParams params = new SelectionParams();
			params.setFilters(filters);
			List<EmvScriptType> items = ssn.queryForList("emv.get-emv-script-type",
					convertQueryParams(params));
			if (items.size() > 0){
				return items.get(0);
			} else {
				throw new IllegalStateException("");
			}			
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void removeScriptType(Long userSessionId, EmvScriptType activeItem) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(activeItem.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, EmvPrivConstants.REMOVE_EMV_SCRIPT_TYPE, paramArr);
			ssn.update("emv.remove-script-type", activeItem);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
		
	}

}
