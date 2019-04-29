package ru.bpc.sv2.logic;

import com.ibatis.sqlmap.client.SqlMapSession;
import org.apache.log4j.Logger;
import ru.bpc.sv2.common.CommonParamRec;
import ru.bpc.sv2.constants.EntityNames;
import ru.bpc.sv2.constants.ModuleNames;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.issuing.*;
import ru.bpc.sv2.issuing.personalization.PersonalizationPrivConstants;
import ru.bpc.sv2.logic.controller.CommonController;
import ru.bpc.sv2.logic.utility.db.IbatisAware;
import ru.bpc.sv2.logic.utility.db.IbatisSessionCallback;
import ru.bpc.sv2.logic.utility.db.QueryParams;
import ru.bpc.sv2.orgstruct.Agent;
import ru.bpc.sv2.utils.AuditParamUtil;


import java.sql.SQLException;
import java.util.*;

/**
 * Session Bean implementation class IssuingDao
 */
public class IssuingDao extends IbatisAware {

	private static final Logger logger = Logger.getLogger("ISSUING");

	@SuppressWarnings("unchecked")
	public IssuerBin[] getIssBins(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, IssuingPrivConstants.VIEW_ISSUING_BINS, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, IssuingPrivConstants.VIEW_ISSUING_BINS);
			List<IssuerBin> bins = ssn.queryForList("iss.get-iss-bins", convertQueryParams(params, limitation));
			return bins.toArray(new IssuerBin[bins.size()]);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public int getIssBinsCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, IssuingPrivConstants.VIEW_ISSUING_BINS, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, IssuingPrivConstants.VIEW_ISSUING_BINS);
			return (Integer) ssn.queryForObject("iss.get-iss-bins-count",
					convertQueryParams(params, limitation));
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public IssuerBin[] getIssBinsCur(Long userSessionId,
	                                 SelectionParams params, Map<String, Object> paramMap) {
		IssuerBin[] result = null;
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, null, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn,
					IssuingPrivConstants.VIEW_ISSUING_BINS);
			List<Filter> filters = new ArrayList<Filter>
					(Arrays.asList((Filter[]) paramMap.get("param_tab")));
			filters.add(new Filter("PRIVIL_LIMITATION", limitation));
			paramMap.put("param_tab", filters.toArray(new Filter[filters.size()]));
			QueryParams qparams = convertQueryParams(params);
			paramMap.put("first_row", qparams.getRange().getStartPlusOne());
			paramMap.put("last_row", qparams.getRange().getEndPlusOne());
			paramMap.put("sorting_tab", params.getSortElement());
			ssn.update("iss.get-iss-bin-cur", paramMap);
			List<IssuerBin> issBins = (List<IssuerBin>) paramMap.get("ref_cur");
			result = issBins.toArray(new IssuerBin[issBins.size()]);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
		return result;
	}


	public int getIssBinsCurCount(Long userSessionId, Map<String, Object> params) {
		Integer result = 0;
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSession(userSessionId);
			String limitation = CommonController.getLimitationByPriv(ssn,
					IssuingPrivConstants.VIEW_ISSUING_BINS);
			List<Filter> filters = new ArrayList<Filter>
					(Arrays.asList((Filter[]) params.get("param_tab")));
			filters.add(new Filter("PRIVIL_LIMITATION", limitation));
			params.put("param_tab", filters.toArray(new Filter[filters.size()]));
			ssn.update("iss.get-iss-bin-cur-count", params);
			result = (Integer) params.get("row_count");
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
		return result;
	}

	@SuppressWarnings("unchecked")
	public IssuerBin addIssBin(Long userSessionId, IssuerBin bin) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(bin.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, IssuingPrivConstants.ADD_ISSUING_BIN, paramArr);

			ssn.update("iss.add-bin", bin);

			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("ID");
			filters[0].setValue(bin.getId());
			filters[1] = new Filter();
			filters[1].setElement("LANG");
			filters[1].setValue(bin.getLang());
			HashMap<String, Object> paramMap = new HashMap<String, Object>();
			paramMap.put("param_tab", filters);
			paramMap.put("tab_name", "BIN");
			paramMap.put("first_row", 0L);
			paramMap.put("last_row", 1L);
			paramMap.put("sorting_tab", null);
			ssn.update("iss.get-iss-bin-cur", paramMap);

			return (IssuerBin) ((List<IssuerBin>) paramMap.get("ref_cur")).get(0);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public IssuerBin modifyIssBin(Long userSessionId, IssuerBin bin) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(bin.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, IssuingPrivConstants.MODIFY_ISSUING_BIN, paramArr);

			ssn.update("iss.modify-bin", bin);

			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("ID");
			filters[0].setValue(bin.getId());
			filters[1] = new Filter();
			filters[1].setElement("LANG");
			filters[1].setValue(bin.getLang());

			HashMap<String, Object> paramMap = new HashMap<String, Object>();
			paramMap.put("param_tab", filters);
			paramMap.put("tab_name", "BIN");
			paramMap.put("first_row", 0L);
			paramMap.put("last_row", 1L);
			paramMap.put("sorting_tab", null);
			ssn.update("iss.get-iss-bin-cur", paramMap);

			return (IssuerBin) ((List<IssuerBin>) paramMap.get("ref_cur")).get(0);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void deleteIssBin(Long userSessionId, IssuerBin bin) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(bin.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, IssuingPrivConstants.REMOVE_ISSUING_BIN, paramArr);

			ssn.delete("iss.remove-bin", bin);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public IssuerBinIndexRange[] getIssBinIndexRanges(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, IssuingPrivConstants.VIEW_BIN_INDEX_RANGE, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, IssuingPrivConstants.VIEW_BIN_INDEX_RANGE);
			List<IssuerBinIndexRange> binIndexRanges = ssn.queryForList(
					"iss.get-iss-bin-index-ranges", convertQueryParams(params, limitation));
			return binIndexRanges.toArray(new IssuerBinIndexRange[binIndexRanges.size()]);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public int getIssBinIndexRangesCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, IssuingPrivConstants.VIEW_BIN_INDEX_RANGE, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, IssuingPrivConstants.VIEW_BIN_INDEX_RANGE);
			return (Integer) ssn.queryForObject("iss.get-iss-bin-index-ranges-count",
					convertQueryParams(params, limitation));
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public IssuerBinIndexRange addIssBinIndexRange(Long userSessionId,
	                                               IssuerBinIndexRange binIndexRange, String lang) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(binIndexRange.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, IssuingPrivConstants.ADD_BIN_INDEX_RANGE, paramArr);

			ssn.insert("rules.sync-name-index-range", binIndexRange);
			ssn.insert("iss.add-bin-index-range", binIndexRange);

			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("binIndexRangeId");
			filters[0].setValue(binIndexRange.getBinIndexRangeId());
			filters[1] = new Filter();
			filters[1].setElement("lang");
			filters[1].setValue(lang);

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (IssuerBinIndexRange) ssn.queryForObject("iss.get-iss-bin-index-ranges",
					convertQueryParams(params));
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public IssuerBinIndexRange modifyIssBinIndexRange(Long userSessionId,
	                                                  IssuerBinIndexRange binIndexRange, String lang) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(binIndexRange.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, IssuingPrivConstants.MODIFY_BIN_INDEX_RANGE, paramArr);

			ssn.update("rules.sync-name-index-range", binIndexRange);

			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("binIndexRangeId");
			filters[0].setValue(binIndexRange.getBinIndexRangeId());
			filters[1] = new Filter();
			filters[1].setElement("lang");
			filters[1].setValue(lang);

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (IssuerBinIndexRange) ssn.queryForObject("iss.get-iss-bin-index-ranges",
					convertQueryParams(params));
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void deleteIssBinIndexRange(Long userSessionId, IssuerBinIndexRange binIndexRange) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(binIndexRange.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, IssuingPrivConstants.REMOVE_BIN_INDEX_RANGE, paramArr);

			ssn.delete("rules.remove-name-index-range", binIndexRange.getNameIndexRange());
			ssn.delete("iss.remove-bin-index-range", binIndexRange);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public ProductCardType[] getProductCardTypes(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, IssuingPrivConstants.VIEW_PRODUCT_CARD_TYPE, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, IssuingPrivConstants.VIEW_PRODUCT_CARD_TYPE);
			List<ProductCardType> productCardTypes = ssn.queryForList("iss.get-product-card-types",
					convertQueryParams(params, limitation));
			return productCardTypes.toArray(new ProductCardType[productCardTypes.size()]);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public int getProductCardTypesCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, IssuingPrivConstants.VIEW_PRODUCT_CARD_TYPE, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, IssuingPrivConstants.VIEW_PRODUCT_CARD_TYPE);
			return (Integer) ssn.queryForObject("iss.get-product-card-types-count",
					convertQueryParams(params, limitation));
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public ProductCardType addProductCardType(Long userSessionId, ProductCardType productCardType,
	                                          String lang) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(productCardType.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, IssuingPrivConstants.ADD_PRODUCT_CARD_TYPE, paramArr);

			ssn.update("iss.add-product-card-type", productCardType);

			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("id");
			filters[0].setValue(productCardType.getId().toString());
			filters[1] = new Filter();
			filters[1].setElement("lang");
			filters[1].setValue(lang);

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (ProductCardType) ssn.queryForObject("iss.get-product-card-types",
					convertQueryParams(params));
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public String checkIntersects(Long userSessionId,
	                              ProductCardType productCardType) {
		SqlMapSession ssn = null;
		String result = new String("");
		Map<String, Object> params = new HashMap<String, Object>();
		params.put("id", productCardType.getId());
		params.put("productId", productCardType.getProductId());
		params.put("cardtypeId", productCardType.getCardTypeId());
		params.put("seqNumLow", productCardType.getSeqNumberLow());
		params.put("seqNumHigh", productCardType.getSeqNumberHigh());
		params.put("warningMessage", new String());
		try {
			ssn = getIbatisSessionFE(userSessionId);
			ssn.queryForObject("iss.check-intersects", params);
			result = (String) params.get("warningMessage");
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		}
		return result;
	}


	public ProductCardType modifyProductCardType(Long userSessionId,
	                                             ProductCardType productCardType, String lang) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(productCardType.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, IssuingPrivConstants.MODIFY_PRODUCT_CARD_TYPE, paramArr);

			ssn.update("iss.modify-product-card-type", productCardType);

			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("id");
			filters[0].setValue(productCardType.getId().toString());
			filters[1] = new Filter();
			filters[1].setElement("lang");
			filters[1].setValue(lang);

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			if (productCardType.getWarningMsg() != null) {
				String msg = productCardType.getWarningMsg();
				productCardType = (ProductCardType) ssn.queryForObject("iss.get-product-card-types",
						convertQueryParams(params));
				productCardType.setWarningMsg(msg);
				return productCardType;
			}
			return (ProductCardType) ssn.queryForObject("iss.get-product-card-types",
					convertQueryParams(params));
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void deleteProductCardType(Long userSessionId, ProductCardType productCardType) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(productCardType.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, IssuingPrivConstants.REMOVE_PRODUCT_CARD_TYPE, paramArr);

			ssn.delete("iss.remove-product-card-type", productCardType);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public Card[] getCards(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			String privil = (params.getPrivilege() != null ? params.getPrivilege() : IssuingPrivConstants.VIEW_CARDS);
			ssn = getIbatisSession(userSessionId, null, privil, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, privil);
			List<Card> cards = ssn.queryForList("iss.get-cards", convertQueryParams(params, limitation));
			return cards.toArray(new Card[cards.size()]);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public int getCardsCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			String privil = (params.getPrivilege() != null ? params.getPrivilege() : IssuingPrivConstants.VIEW_CARDS);
			ssn = getIbatisSession(userSessionId, null, privil, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, privil);
			return (Integer) ssn.queryForObject("iss.get-cards-count", convertQueryParams(params, limitation));
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public CardInstance[] getCardInstances(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, IssuingPrivConstants.VIEW_CARD_INSTANCES, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, IssuingPrivConstants.VIEW_CARD_INSTANCES);
			List<CardInstance> instances = ssn.queryForList("iss.get-card-instances",
					convertQueryParams(params, limitation));
			return instances.toArray(new CardInstance[instances.size()]);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public int getCardInstancesCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, IssuingPrivConstants.VIEW_CARD_INSTANCES, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, IssuingPrivConstants.VIEW_CARD_INSTANCES);
			return (Integer) ssn.queryForObject("iss.get-card-instances-count",
					convertQueryParams(params, limitation));
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public Cardholder[] getCardholders(Long userSessionId, SelectionParams params, String lang) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			String privil = (params.getPrivilege() != null ? params.getPrivilege() : IssuingPrivConstants.VIEW_CARDHOLDERS);
			ssn = getIbatisSession(userSessionId, null, privil, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, privil);
			List<Cardholder> cardholders = ssn.queryForList("iss.get-cardholders",
					convertQueryParams(params, limitation, lang));
			return cardholders.toArray(new Cardholder[cardholders.size()]);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public int getCardholdersCount(Long userSessionId, SelectionParams params, String lang) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			String privil = (params.getPrivilege() != null ? params.getPrivilege() : IssuingPrivConstants.VIEW_CARDHOLDERS);
			ssn = getIbatisSession(userSessionId, null, privil, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, privil);
			return (Integer) ssn.queryForObject("iss.get-cardholders-count", convertQueryParams(
					params, limitation, lang));
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

    @SuppressWarnings("unchecked")
    public Cardholder[] getCardholdersCur(Long userSessionId, SelectionParams params, Map<String, Object> paramsMap) {
        Cardholder[] result;
        SqlMapSession ssn = null;
        try {
            CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
            String privil = (params.getPrivilege() != null ? params.getPrivilege() : IssuingPrivConstants.VIEW_CARDHOLDERS);
            ssn = getIbatisSession(userSessionId, null, privil, paramArr);
            String limitation = CommonController.getLimitationByPriv(ssn, privil);

            List<Filter> filters = new ArrayList<Filter>(Arrays.asList((Filter[]) paramsMap.get("param_tab")));
            filters.add(new Filter("PRIVIL_LIMITATION", limitation));
            QueryParams qparams = convertQueryParams(params);
            paramsMap.put("param_tab", filters.toArray(new Filter[filters.size()]));
            paramsMap.put("first_row", qparams.getRange().getStartPlusOne());
            paramsMap.put("last_row", qparams.getRange().getEndPlusOne());
            paramsMap.put("row_count", params.getRowCount());
            paramsMap.put("sorting_tab", params.getSortElement());
            ssn.update("iss.get-cardholders-cur", paramsMap);
            List<Cardholder> cardholders = (ArrayList<Cardholder>) paramsMap.get("ref_cur");
            result = cardholders.toArray(new Cardholder[cardholders.size()]);
        } catch (SQLException e) {
            logger.error("", e);
            throw createDaoException(e);
        } finally {
            close(ssn);
        }
        return result;
    }


    public int getCardholdersCurCount(Long userSessionId, SelectionParams params, Map<String, Object> paramsMap) {
        Integer result = 0;
        SqlMapSession ssn = null;
        try {
            CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
            String privil = (params.getPrivilege() != null ? params.getPrivilege() : IssuingPrivConstants.VIEW_CARDHOLDERS);
            ssn = getIbatisSession(userSessionId, null, privil, paramArr);
            String limitation = CommonController.getLimitationByPriv(ssn, privil);

            List<Filter> filters = new ArrayList<Filter>(Arrays.asList((Filter[]) paramsMap.get("param_tab")));
            filters.add(new Filter("PRIVIL_LIMITATION", limitation));
            paramsMap.put("param_tab", filters.toArray(new Filter[filters.size()]));
            ssn.update("iss.get-cardholders-cur-count", paramsMap);
            result = (Integer) paramsMap.get("row_count");
        } catch (SQLException e) {
            logger.error("", e);
            throw createDaoException(e);
        } finally {
            close(ssn);
        }
        return result;
    }

	@SuppressWarnings("unchecked")
	public List<Agent> getAgentsByCustomer(Long userSessionId, Long customerId) {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSessionFE(userSessionId);

			return ssn.queryForList("iss.get-agents-by-customer", customerId);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public Cardholder getCardholder(Long userSessionId, String cardNumber) {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSession(userSessionId);
			return ((Cardholder)ssn.queryForObject("iss.get-cardholder", cardNumber));
		}
		catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		}
		finally {
			close(ssn);
		}
	}


	public void viewCardNumber(Long userSessionId, Long cardId) {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSession(userSessionId, null, IssuingPrivConstants.VIEW_CARD_NUMBER,
					AuditParamUtil.getCommonParamRec(cardId, EntityNames.CARD));
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void viewCardToken(Long userSessionId, Long cardId) {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSession(userSessionId, null, IssuingPrivConstants.VIEW_CARD_TOKEN,
								   AuditParamUtil.getCommonParamRec(cardId, EntityNames.CARD));
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public Card[] getBlackCards(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, IssuingPrivConstants.VIEW_CARDS, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, IssuingPrivConstants.VIEW_CARDS);
			List<Card> cards = ssn.queryForList("iss.get-black-cards", convertQueryParams(params, limitation));
			return cards.toArray(new Card[cards.size()]);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public int getBlackCardsCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, IssuingPrivConstants.VIEW_CARDS, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, IssuingPrivConstants.VIEW_CARDS);
			return (Integer) ssn.queryForObject("iss.get-black-cards-count", convertQueryParams(params, limitation));
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public Card addBlackCard(Long userSessionId, Card card) {
		SqlMapSession ssn = null;

		Map<String, Object> map = new HashMap<String, Object>();
		map.put("id", card.getId());
		map.put("name", card.getCardNumber());

		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(map);
			ssn = getIbatisSession(userSessionId, null, IssuingPrivConstants.ADD_ISSUING_BIN, paramArr);

			ssn.update("iss.add-black-card", card);

			Filter[] filters = new Filter[1];
			filters[0] = new Filter();
			filters[0].setElement("cardNumber");
			filters[0].setValue(card.getCardNumber());
			filters[0].setCondition("=");

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (Card) ssn.queryForObject("iss.get-black-cards", convertQueryParams(params));
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void deleteBlackCard(Long userSessionId, Card card) {
		SqlMapSession ssn = null;

		Map<String, Object> map = new HashMap<String, Object>();
		map.put("id", card.getId());
		map.put("name", card.getCardNumber());

		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(map);
			ssn = getIbatisSession(userSessionId, null, IssuingPrivConstants.REMOVE_ISSUING_BIN, paramArr);

			ssn.delete("iss.remove-black-card", card);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public Card[] getCardsCur(Long userSessionId, SelectionParams params, Map<String, Object> paramsMap) {
		Card[] result;
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSession(userSessionId);
			String limitation = null;
			if (params.getModule() != null && params.getModule().equals(ModuleNames.CASE_MANAGEMENT)) {
				limitation = null;
			} else {
				limitation = CommonController.getLimitationByPriv(ssn, IssuingPrivConstants.VIEW_CARDS);
			}
			List<Filter> filters = new ArrayList<Filter>(Arrays.asList((Filter[]) paramsMap.get("param_tab")));
			filters.add(new Filter("PRIVIL_LIMITATION", limitation));
			QueryParams qparams = convertQueryParams(params);
			paramsMap.put("param_tab", filters.toArray(new Filter[filters.size()]));
			paramsMap.put("first_row", qparams.getRange().getStartPlusOne());
			paramsMap.put("last_row", qparams.getRange().getEndPlusOne());
            paramsMap.put("row_count", params.getRowCount());
			paramsMap.put("sorting_tab", params.getSortElement());
			ssn.update("iss.get-cards-cur", paramsMap);
			List<Card> cards = (ArrayList<Card>) paramsMap.get("ref_cur");
			result = cards.toArray(new Card[cards.size()]);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
		return result;
	}


	public int getCardsCurCount(Long userSessionId, SelectionParams params, Map<String, Object> paramsMap) {
		Integer result = 0;
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSession(userSessionId);
			String limitation = null;
			if (params.getModule() != null && params.getModule().equals(ModuleNames.CASE_MANAGEMENT)) {
				limitation = null;
			} else {
				limitation = CommonController.getLimitationByPriv(ssn, IssuingPrivConstants.VIEW_CARDS);
			}
			List<Filter> filters = new ArrayList<Filter>(Arrays.asList((Filter[]) paramsMap.get("param_tab")));
			filters.add(new Filter("PRIVIL_LIMITATION", limitation));
			paramsMap.put("param_tab", filters.toArray(new Filter[filters.size()]));
			ssn.update("iss.get-cards-cur-count", paramsMap);
			result = (Integer) paramsMap.get("row_count");
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
		return result;
	}


	public BaseCard modifyCardPersonalizationState(Long userSessionId, BaseCard baseCard, String lang, String iBatisSelect) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(baseCard.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, IssuingPrivConstants.MODIFY_CARD_INSTANCE_REQUESTING_ACTION, paramArr);
			ssn.update("iss.modify-card-instance", baseCard);
			if (baseCard.getWarningMsg() != null) return baseCard;

			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("id");
			filters[0].setValue(baseCard.getId().toString());
			filters[1] = new Filter();
			filters[1].setElement("lang");
			filters[1].setValue(lang);

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);
			//"prs.get-perso-cards"
			return (BaseCard) ssn.queryForObject(iBatisSelect, convertQueryParams(params));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public ReissueReason[] getReissueReasons(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, IssuingPrivConstants.VIEW_REISSUE_REASONS, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, IssuingPrivConstants.VIEW_REISSUE_REASONS);
			List<ReissueReason> items = ssn.queryForList(
					"iss.get-reissue-reasons", convertQueryParams(params, limitation));
			return items.toArray(new ReissueReason[items.size()]);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public int getReissueReasonsCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, IssuingPrivConstants.VIEW_REISSUE_REASONS, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, IssuingPrivConstants.VIEW_REISSUE_REASONS);
			return (Integer) ssn.queryForObject("iss.get-reissue-reasons-count",
					convertQueryParams(params, limitation));
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public ReissueReason addReissueReason(Long userSessionId, ReissueReason reissueReason) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(reissueReason.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, IssuingPrivConstants.VIEW_REISSUE_REASONS, paramArr);

			ssn.update("iss.add-reissue-reason", reissueReason);

			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("id");
			filters[0].setValue(reissueReason.getId().toString());
			filters[1] = new Filter();
			filters[1].setElement("lang");
			filters[1].setValue(reissueReason.getLang());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (ReissueReason) ssn.queryForObject("iss.get-reissue-reasons", convertQueryParams(params));
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public ReissueReason modifyReissueReason(Long userSessionId, ReissueReason reissueReason) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(reissueReason.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, IssuingPrivConstants.VIEW_REISSUE_REASONS, paramArr);

			ssn.update("iss.modify-reissue-reason", reissueReason);

			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("id");
			filters[0].setValue(reissueReason.getId().toString());
			filters[1] = new Filter();
			filters[1].setElement("lang");
			filters[1].setValue(reissueReason.getLang());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (ReissueReason) ssn.queryForObject("iss.get-reissue-reasons", convertQueryParams(params));
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void deleteReissueReason(Long userSessionId, ReissueReason reissueReason) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(reissueReason.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, IssuingPrivConstants.VIEW_REISSUE_REASONS, paramArr);

			ssn.delete("iss.remove-reissue-reason", reissueReason);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public CardInfoXml getCardInfoXml(Long userSessionId, Long applicationId, Boolean includeLimits, String lang) {
		final Map<String, Object> params = new HashMap<String, Object>();
		params.put("applId", applicationId);
		params.put("includeLimits", includeLimits);
		params.put("lang", lang);
		return executeWithSession(userSessionId, null, PersonalizationPrivConstants.VIEW_PERSO_BATCH_CARD,
				AuditParamUtil.getCommonParamRec(params), logger, new IbatisSessionCallback<CardInfoXml>() {
					@Override
					public CardInfoXml doInSession(SqlMapSession ssn) throws Exception {
						CardInfoXml result = new CardInfoXml();
						ssn.update("iss.get-cards-info", params);
						result.setBatchId((Long) params.get("batchId"));
						result.setXml((String) params.get("cardsInfo"));
						return result;
					}
				});
	}


	public CardData getCardData(Long userSessionId, Long cardId, Boolean includeLimits, Boolean includeService, String lang) {
		final Map<String, Object> params = new HashMap<String, Object>();
		params.put("cardId", cardId);
		params.put("includeLimits", includeLimits);
		params.put("includeService", includeService);
		params.put("lang", lang);
		return executeWithSession(userSessionId, null, PersonalizationPrivConstants.VIEW_PERSO_BATCH_CARD,
				AuditParamUtil.getCommonParamRec(params), logger, new IbatisSessionCallback<CardData>() {
					@Override
					public CardData doInSession(SqlMapSession ssn) throws Exception {
						CardData result = new CardData();
						ssn.update("iss.get-card-info", params);
						result.setAccountXml((String) params.get("accountInfo"));
						result.setCardXml((String) params.get("cardInfo"));
						return result;
					}
				});
	}


	public int getTokensCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSession(userSessionId);
			return (Integer) ssn.queryForObject("iss.get-tokens-count", convertQueryParams(params));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public Token[] getTokens(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSession(userSessionId);
			List<Token> tokens = ssn.queryForList("iss.get-tokens", convertQueryParams(params));
			return tokens.toArray(new Token[tokens.size()]);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public Long getCardIdByUid(Long userSessionId, final String cardUid) {
		return executeWithSession(userSessionId, logger, new IbatisSessionCallback<Long>() {
			@Override
			public Long doInSession(SqlMapSession ssn) throws Exception {
				return (Long) ssn.queryForObject("iss.get-card-id-by-uid", cardUid);
			}
		});
	}

	public void updateCardholderPhotoFileName(Long userSessionId, final Long cardId, final String photoFileName) {
		final Map<String, Object> params = new HashMap<String, Object>();
		params.put("cardId", cardId);
		params.put("photoFileName", photoFileName);
		executeWithSession(userSessionId, null, IssuingPrivConstants.CHANGE_CARDHOLDER_PHOTO,
			AuditParamUtil.getCommonParamRec(params), logger, new IbatisSessionCallback<Void>() {
			@Override
			public Void doInSession(SqlMapSession ssn) throws Exception {
				ssn.update("iss.update-photo-file-name", params);
				return null;
			}
		});
	}
}
