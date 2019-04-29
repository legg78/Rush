package ru.bpc.sv2.logic;

import com.ibatis.sqlmap.client.SqlMapSession;
import org.apache.log4j.Logger;
import ru.bpc.sv2.accounts.AccountPrivConstants;
import ru.bpc.sv2.common.CommonParamRec;
import ru.bpc.sv2.common.FlexFieldData;
import ru.bpc.sv2.constants.DataTypes;
import ru.bpc.sv2.constants.EntityNames;
import ru.bpc.sv2.constants.ModuleNames;
import ru.bpc.sv2.fcl.cycles.Cycle;
import ru.bpc.sv2.fcl.cycles.CycleShift;
import ru.bpc.sv2.fcl.fees.Fee;
import ru.bpc.sv2.fcl.fees.FeeTier;
import ru.bpc.sv2.fcl.limits.Limit;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.invocation.SortElement;
import ru.bpc.sv2.logic.controller.CommonController;
import ru.bpc.sv2.logic.utility.db.IbatisAware;
import ru.bpc.sv2.logic.utility.db.IbatisSessionCallback;
import ru.bpc.sv2.logic.utility.db.QueryParams;
import ru.bpc.sv2.products.*;
import ru.bpc.sv2.utils.AuditParamUtil;

import ru.bpc.sv2.logic.utility.db.DataAccessException;

import java.sql.SQLException;
import java.util.*;

/**
 * Session Bean implementation class ProductsDao
 */
public class ProductsDao extends IbatisAware {

	private static final Logger logger = Logger.getLogger("PRODUCTS");

	@SuppressWarnings("unchecked")
	public Product[] getProducts(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, ProductPrivConstants.VIEW_PRODUCT, paramArr);

			List<Product> prods;
			prods = ssn.queryForList("products.get-products-hier", convertQueryParams(params));

			return prods.toArray(new Product[prods.size()]);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public Product[] getProductsList(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, ProductPrivConstants.VIEW_PRODUCT, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, ProductPrivConstants.VIEW_PRODUCT);
			List<Product> prods = ssn.queryForList("products.get-products",
					convertQueryParams(params, limitation));

			return prods.toArray(new Product[prods.size()]);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public int getProductsCount(Long userSessionId) {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSessionFE(userSessionId);
			String limitation = CommonController.getLimitationByPriv(ssn, ProductPrivConstants.VIEW_PRODUCT);
			return (Integer) ssn.queryForObject("products.get-products-count", convertQueryParams(null, limitation));
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public Product addProduct(Long userSessionId, Product prod) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(prod.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, ProductPrivConstants.ADD_PRODUCT, paramArr);

			ssn.insert("products.add-product", prod);

			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("id");
			filters[0].setValue(prod.getId().toString());
			filters[1] = new Filter();
			filters[1].setElement("lang");
			filters[1].setValue(prod.getLang());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (Product) ssn
					.queryForObject("products.get-products", convertQueryParams(params));
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public Product modifyProduct(Long userSessionId, Product prod) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(prod.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, ProductPrivConstants.MODIFY_PRODUCT, paramArr);

			ssn.update("products.modify-product", prod);

			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("id");
			filters[0].setValue(prod.getId().toString());
			filters[1] = new Filter();
			filters[1].setElement("lang");
			filters[1].setValue(prod.getLang());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (Product) ssn
					.queryForObject("products.get-products", convertQueryParams(params));
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void removeProduct(Long userSessionId, Product product) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(product.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, ProductPrivConstants.REMOVE_PRODUCT, paramArr);

			ssn.delete("products.remove-product", product);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public Product getProductById(Long userSessionId, Integer prodId, String lang) {
		SqlMapSession ssn = null;
		try {
			HashMap<String, Object> map = new HashMap<String, Object>();
			map.put("productId", prodId);
			map.put("lang", lang);
			
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(map);
			ssn = getIbatisSession(userSessionId, null, ProductPrivConstants.VIEW_PRODUCT, paramArr);

			return (Product) ssn.queryForObject("products.get-product-by-id", map);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	@SuppressWarnings("unchecked")
	public ProductAttribute[] getObjectAttributes(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, ProductPrivConstants.VIEW_ATTRIBUTE_OBJECTS, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, ProductPrivConstants.VIEW_ATTRIBUTE_OBJECTS);
			List<ProductAttribute> attrs = ssn.queryForList("products.get-object-attrs",
					convertQueryParams(params, limitation));
			return attrs.toArray(new ProductAttribute[attrs.size()]);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	@SuppressWarnings("unchecked")
	public ProductAttribute[] getServiceAttributes(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, ProductPrivConstants.VIEW_ATTRIBUTE_SERVICE, paramArr);

			List<ProductAttribute> attrs = ssn.queryForList("products.get-service-attrs",
					convertQueryParams(params));
			setReadonlyServiceTerm(userSessionId,  params, attrs, "products.get-service-attrs");
			return attrs.toArray(new ProductAttribute[attrs.size()]);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}
	

	@SuppressWarnings("unchecked")
	public ProductAttribute[] getServiceAttributesLight(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, ProductPrivConstants.VIEW_ATTRIBUTE_SERVICE, paramArr);

			List<ProductAttribute> attrs = ssn.queryForList("products.get-service-attrs-light",
					convertQueryParams(params));
			return attrs.toArray(new ProductAttribute[attrs.size()]);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	@SuppressWarnings("unchecked")
	public ProductAttribute[] getProductAttributes(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, ProductPrivConstants.VIEW_ATTRIBUTE_PRODUCT, paramArr);

			List<ProductAttribute> attrs = ssn.queryForList("products.get-product-attrs",
					convertQueryParams(params));
			setReadonlyServiceTerm(userSessionId,  params, attrs, "products.get-product-attrs");
			return attrs.toArray(new ProductAttribute[attrs.size()]);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	/**
	 * Checks if limitation of privilege contains the element then this is readonly element
	 */
	public void setReadonlyServiceTerm(Long userSessionId, SelectionParams params, List<ProductAttribute> preparedAttrValues, String query) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, ProductPrivConstants.SET_ATTRIBUTE_VALUE, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, ProductPrivConstants.SET_ATTRIBUTE_VALUE);

			List<ProductAttribute> limitedAttrs = ssn.queryForList(query, convertQueryParams(params, limitation));
			// If list limitedAttrs contents element it means this element not readonly
			for (ProductAttribute preparedAttr : preparedAttrValues) {
				for (int i = 0; i < limitedAttrs.size(); i++) {
					preparedAttr.setReadonly(true);
					if (limitedAttrs.get(i).getId().equals(preparedAttr.getId())) {
						preparedAttr.setReadonly(false);
						break;
					}
				}
			}
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	@SuppressWarnings("unchecked")
	public AttributeValue[] getProductAttrValues(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, ProductPrivConstants.VIEW_PRODUCT_ATTRIBUTE_VALUES, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, ProductPrivConstants.VIEW_PRODUCT_ATTRIBUTE_VALUES);
			List<AttributeValue> attrValues = ssn.queryForList("products.get-product-attr-values",
					convertQueryParams(params, limitation));	
			
			setIsActualValueFlags(userSessionId, attrValues);


			return attrValues.toArray(new AttributeValue[attrValues.size()]);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}



	/* set isActual flags for each modId-defined group of Attribute Values */
	private void setIsActualValueFlags(Long userSessionId, List<AttributeValue> attrValues) {
		final HashMap<Integer,List<AttributeValue>> attrMap = new HashMap<Integer,List<AttributeValue>>();
		Integer modId;
		for (AttributeValue av: attrValues) {
			modId = av.getModId();
			if(!attrMap.containsKey(modId)){
				attrMap.put(modId, new ArrayList<AttributeValue>());
			}
			attrMap.get(modId).add(av);	
		}
		for (Integer mod : attrMap.keySet()) {		
			trySortAttr(attrMap.get(mod), userSessionId);
		}		
	}


	public int getProductAttrValuesCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, ProductPrivConstants.VIEW_PRODUCT_ATTRIBUTE_VALUES, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, ProductPrivConstants.VIEW_PRODUCT_ATTRIBUTE_VALUES);
			return (Integer) ssn.queryForObject("products.get-product-attr-values-count",
					convertQueryParams(params, limitation));
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	@SuppressWarnings("unchecked")
	public Attribute[] getAttributes(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, ProductPrivConstants.VIEW_ATTRIBUTES, paramArr);

			List<Attribute> attrs = ssn.queryForList("products.get-attributes",
					convertQueryParams(params));
			return attrs.toArray(new Attribute[attrs.size()]);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public List<Attribute> getAttributesHier(Long userSessionId, final SelectionParams params) {
		return executeWithSession(userSessionId,
								  ProductPrivConstants.VIEW_ATTRIBUTES,
								  params,
								  logger,
								  new IbatisSessionCallback<List<Attribute>>() {
			@Override
			public List<Attribute> doInSession(SqlMapSession ssn) throws Exception {
				return ssn.queryForList("products.get-attributes-hier", convertQueryParams(params));
			}
		});
	}

	public Attribute addAttribute(Long userSessionId, Attribute attr) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(attr.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, ProductPrivConstants.ADD_ATTRIBUTE, paramArr);

			ssn.update("products.add-attribute", attr);

			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("id");
			filters[0].setValue(attr.getId().toString());
			filters[1] = new Filter();
			filters[1].setElement("lang");
			filters[1].setValue(attr.getLang());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (Attribute) ssn.queryForObject("products.get-attributes", convertQueryParams(params));
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public Attribute modifyAttribute(Long userSessionId, Attribute attr) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(attr.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, ProductPrivConstants.MODIFY_ATTRIBUTE, paramArr);

			ssn.update("products.edit-attribute", attr);

			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("id");
			filters[0].setValue(attr.getId().toString());
			filters[1] = new Filter();
			filters[1].setElement("lang");
			filters[1].setValue(attr.getLang());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (Attribute) ssn.queryForObject("products.get-attributes", convertQueryParams(params));
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void removeAttribute(Long userSessionId, Long attrId) {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSessionFE(userSessionId);

			ssn.delete("products.delete-attribute", attrId);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	@SuppressWarnings("unchecked")
	public AttrScale[] getAttrScales(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, ProductPrivConstants.VIEW_ATTRIBUTE_SCALES, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, ProductPrivConstants.VIEW_ATTRIBUTE_SCALES);
			List<AttrScale> procs = ssn.queryForList("products.get-attr-scales",
					convertQueryParams(params, limitation));

			return procs.toArray(new AttrScale[procs.size()]);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public int getAttrScalesCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, ProductPrivConstants.VIEW_ATTRIBUTE_SCALES, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, ProductPrivConstants.VIEW_ATTRIBUTE_SCALES);
			return (Integer) ssn.queryForObject("products.get-attr-scales-count",
					convertQueryParams(params, limitation));
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public AttrScale addAttrScale(Long userSessionId, AttrScale attrScale) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(attrScale.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, ProductPrivConstants.ADD_ATTRIBUTE_SCALE, paramArr);

			ssn.update("products.add-attr-scale", attrScale);

			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("id");
			filters[0].setValue(attrScale.getId().toString());
			filters[1] = new Filter();
			filters[1].setElement("lang");
			filters[1].setValue(attrScale.getLang());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (AttrScale) ssn.queryForObject("products.get-attr-scales",
					convertQueryParams(params));
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public AttrScale editAttrScale(Long userSessionId, AttrScale attrScale) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(attrScale.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, ProductPrivConstants.MODIFY_ATTRIBUTE_SCALE, paramArr);

			ssn.update("products.edit-attr-scale", attrScale);

			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("id");
			filters[0].setValue(attrScale.getId().toString());
			filters[1] = new Filter();
			filters[1].setElement("lang");
			filters[1].setValue(attrScale.getLang());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (AttrScale) ssn.queryForObject("products.get-attr-scales",
					convertQueryParams(params));
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void removeAttrScale(Long userSessionId, AttrScale attrScale) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(attrScale.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, ProductPrivConstants.REMOVE_ATTRIBUTE_SCALE, paramArr);

			ssn.delete("products.remove-attr-scale", attrScale);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	@SuppressWarnings("unchecked")
	public AttributeValue[] getAttributeValues(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, ProductPrivConstants.VIEW_ATTRIBUTE_VALUES, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, ProductPrivConstants.VIEW_ATTRIBUTE_VALUES);
			List<AttributeValue> attrValues = ssn.queryForList("products.get-attribute-values",
					convertQueryParams(params, limitation));
			
			setIsActualValueFlags(userSessionId, attrValues);

			return attrValues.toArray(new AttributeValue[attrValues.size()]);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public int getAttributeValuesCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, ProductPrivConstants.VIEW_ATTRIBUTE_VALUES, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, ProductPrivConstants.VIEW_ATTRIBUTE_VALUES);
			return (Integer) ssn.queryForObject("products.get-attribute-values-count",
					convertQueryParams(params, limitation));
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	@SuppressWarnings("unchecked")
	public AttributeValue[] getMixedAttrValues(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, ProductPrivConstants.VIEW_ATTRIBUTE_VALUES, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, ProductPrivConstants.VIEW_ATTRIBUTE_VALUES);
			List<AttributeValue> attrValues = ssn.queryForList("products.get-mixed-attr-values",
					convertQueryParams(params, limitation));
			
			setIsActualValueFlags(userSessionId, attrValues);

			return attrValues.toArray(new AttributeValue[attrValues.size()]);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public int getMixedAttrValuesCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, ProductPrivConstants.VIEW_ATTRIBUTE_VALUES, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, ProductPrivConstants.VIEW_ATTRIBUTE_VALUES);
			return (Integer) ssn.queryForObject("products.get-mixed-attr-values-count",
					convertQueryParams(params, limitation));
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}
	
	public void setServiceAttribute(Long userSessionId, ProductAttribute attr) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(attr.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, ProductPrivConstants.SET_SERVICE_ATTRIBUTE, paramArr);
			ssn.queryForObject("products.set_service_attribute", attr);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public AttributeValue setAttributeValue(Long userSessionId, AttributeValue value,
			String dataType) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(value.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, ProductPrivConstants.SET_ATTRIBUTE_VALUE, paramArr);

			if (dataType.equals(DataTypes.CHAR)) {
				ssn.update("products.set-attr-value-char", value);
			} else if (dataType.equals(DataTypes.NUMBER)) {
				ssn.update("products.set-attr-value-num", value);
			} else if (dataType.equals(DataTypes.DATE)) {
				ssn.update("products.set-attr-value-date", value);
			}

			Filter[] filters = new Filter[3];
			filters[0] = new Filter();
			filters[0].setElement("id");
			filters[0].setValue(value.getValueId().toString());
			filters[1] = new Filter();
			filters[1].setElement("objectId");
			filters[1].setValue(value.getObjectId().toString());
			filters[2] = new Filter();
			filters[2].setElement("serviceId");
			filters[2].setValue(value.getServiceId().toString());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			if (EntityNames.PRODUCT.equals(value.getEntityType())
					|| ProductConstants.ISSUING_PRODUCT.equals(value.getEntityType())
					|| ProductConstants.ACQUIRING_PRODUCT.equals(value.getEntityType())) {
				return (AttributeValue) ssn.queryForObject("products.get-product-attr-values",
						convertQueryParams(params));
			} else if (EntityNames.SERVICE.equals(value.getEntityType())) {
				return (AttributeValue) ssn.queryForObject("products.get-attribute-values",
						convertQueryParams(params));
			} else {
				return (AttributeValue) ssn.queryForObject("products.get-mixed-attr-values",
						convertQueryParams(params));
			}
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public AttributeValue setAttrValueFee(Long userSessionId, AttributeValue attrValue, Fee fee,
			ArrayList<FeeTier> tiers, Limit limit, Cycle cycle, Cycle cycleForLimit,
			ArrayList<CycleShift> shifts, FlexFieldData[] feeFlexFields) {
		SqlMapSession ssn = null;
		boolean feeHadId = true;
		boolean limitHadId = true;
		boolean cycleHadId = true;

		try {
			ssn = getIbatisSession(userSessionId, null, ProductPrivConstants.SET_ATTRIBUTE_VALUE, null);

			// create new cycle or use existing one
			if (cycle != null) {
				if (cycle.getId() == null) {
					cycleHadId = false;
					// create new cycle
					ssn.insert("cycles.insert-new-cycle", cycle);
					if (shifts != null) {
						for (CycleShift shift: shifts) {
							shift.setCycleId(cycle.getId());
							shift.setId(null); // as we add new shift we don't
							// need old ID if there was one
							ssn.insert("cycles.insert-new-cycle-shift", shift);
						}
					}
				}

				fee.setCycleId(cycle.getId());
			}

			// create new cycle for fee's limit or use existing one (the latter
			// is possible only when we add existing fee)
			if (cycleForLimit != null) {
				if (cycleForLimit.getId() == null) {
					ssn.insert("cycles.insert-new-cycle", cycleForLimit);
					if (shifts != null) {
						for (CycleShift shift: shifts) {
							shift.setCycleId(cycleForLimit.getId());
							shift.setId(null); // as we add new shift we don't
							// need old ID if there was one
							ssn.insert("cycles.insert-new-cycle-shift", shift);
						}
					}
				}

				limit.setCycleId(cycleForLimit.getId());
			}

			// create new limit or use existing one
			if (limit != null) {
				if (limit.getId() == null) {
					limitHadId = false;
					ssn.insert("limits.insert-new-limit", limit);
				}

				fee.setLimitId(limit.getId());
			}

			// create new fee
			if (fee.getId() == null) {
				feeHadId = false;
				ssn.insert("fees.insert-new-fee", fee);

				if (tiers != null) {
					for (FeeTier tier: tiers) {
						tier.setFeeId(fee.getId());
						tier.setId(null); // as we add new tier we don't need
						// old ID if there was one
						ssn.insert("fees.insert-new-fee-tier", tier);
					}
				}
			}

			// save flexible fields for fee
			if (feeFlexFields != null && feeFlexFields.length > 0) {
				for (FlexFieldData field: feeFlexFields) {
					field.setObjectId(fee.getId().longValue());
					if (field.getDataType().equals("DTTPCHAR")) {
						ssn.update("common.set-flexible-value_v", field);
					} else if (field.getDataType().equals("DTTPNMBR")) {
						ssn.update("common.set-flexible-value_n", field);
					} else if (field.getDataType().equals("DTTPDATE")) {
						ssn.update("common.set-flexible-value_d", field);
					}
				}
			}

			// bind fee (existing or just created) to attribute as attribute
			// value
			attrValue.setValue(fee.getId());
			ssn.update("products.set-attr-value-fee", attrValue);

			// get created or modified value to return it as a result
			Filter[] filters = new Filter[3];
			filters[0] = new Filter();
			filters[0].setElement("id");
			filters[0].setValue(attrValue.getValueId().toString());
			filters[1] = new Filter();
			filters[1].setElement("objectId");
			filters[1].setValue(attrValue.getObjectId().toString());
			filters[2] = new Filter();
			filters[2].setElement("serviceId");
			filters[2].setValue(attrValue.getServiceId().toString());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			if (EntityNames.PRODUCT.equals(attrValue.getEntityType())
					|| ProductConstants.ISSUING_PRODUCT.equals(attrValue.getEntityType())
					|| ProductConstants.ACQUIRING_PRODUCT.equals(attrValue.getEntityType())) {
				return (AttributeValue) ssn.queryForObject("products.get-product-attr-values",
						convertQueryParams(params));
			} else if (EntityNames.SERVICE.equals(attrValue.getEntityType())) {
				return (AttributeValue) ssn.queryForObject("products.get-attribute-values",
						convertQueryParams(params));
			} else {
				return (AttributeValue) ssn.queryForObject("products.get-mixed-attr-values",
						convertQueryParams(params));
			}
		} catch (SQLException e) {
			// IDs of new objects (that hadn't IDs before calling this method)
			// are set back to null just in case some of them had already
			// obtained new IDs that became invalid if we reached this place.
			if (!feeHadId)
				fee.setId(null);
			if (!limitHadId)
				limit.setId(null);
			if (!cycleHadId)
				cycle.setId(null);

			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public AttributeValue setAttrValueLimit(Long userSessionId, AttributeValue attrValue,
			Limit limit, Cycle cycle, ArrayList<CycleShift> shifts) {
		SqlMapSession ssn = null;
		boolean limitHadId = true;
		boolean cycleHadId = true;

		try {
			ssn = getIbatisSession(userSessionId, null, ProductPrivConstants.SET_ATTRIBUTE_VALUE, null);

			// create new cycle or use existing one
			if (cycle != null) {
				if (cycle.getId() == null) {
					cycleHadId = false;
					ssn.insert("cycles.insert-new-cycle", cycle);
					if (shifts != null) {
						for (CycleShift shift: shifts) {
							shift.setCycleId(cycle.getId());
							shift.setId(null); // as we add new shift we don't
							// need old ID if there was one
							ssn.insert("cycles.insert-new-cycle-shift", shift);
						}
					}
				}

				limit.setCycleId(cycle.getId());
			}

			// create new limit
			if (limit.getId() == null) {
				limitHadId = false;
				ssn.insert("limits.insert-new-limit", limit);
			}

			// bind limit (existing or just created) to attribute as attribute
			// value
			attrValue.setValue(limit.getId());

			ssn.update("products.set-attr-value-limit", attrValue);

			// get created or modified value to return it as a result
			Filter[] filters = new Filter[3];
			filters[0] = new Filter();
			filters[0].setElement("id");
			filters[0].setValue(attrValue.getValueId().toString());
			filters[1] = new Filter();
			filters[1].setElement("objectId");
			filters[1].setValue(attrValue.getObjectId().toString());
			filters[2] = new Filter();
			filters[2].setElement("serviceId");
			filters[2].setValue(attrValue.getServiceId().toString());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			if (EntityNames.PRODUCT.equals(attrValue.getEntityType())
					|| ProductConstants.ISSUING_PRODUCT.equals(attrValue.getEntityType())
					|| ProductConstants.ACQUIRING_PRODUCT.equals(attrValue.getEntityType())) {
				return (AttributeValue) ssn.queryForObject("products.get-product-attr-values",
						convertQueryParams(params));
			} else if (EntityNames.SERVICE.equals(attrValue.getEntityType())) {
				return (AttributeValue) ssn.queryForObject("products.get-attribute-values",
						convertQueryParams(params));
			} else {
				return (AttributeValue) ssn.queryForObject("products.get-mixed-attr-values",
						convertQueryParams(params));
			}
		} catch (SQLException e) {
			// IDs of new objects (that hadn't IDs before calling this method)
			// are set back to null just in case some of them had already
			// obtained new IDs that became invalid if we reached this place.
			if (!limitHadId)
				limit.setId(null);
			if (!cycleHadId)
				cycle.setId(null);

			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public AttributeValue setAttrValueCycle(Long userSessionId, AttributeValue attrValue,
			Cycle cycle, ArrayList<CycleShift> shifts) {
		SqlMapSession ssn = null;
		boolean cycleHadId = true;

		try {
			ssn = getIbatisSession(userSessionId, null, ProductPrivConstants.SET_ATTRIBUTE_VALUE, null);

			// create new cycle
			if (cycle.getId() == null) {
				cycleHadId = false;
				ssn.insert("cycles.insert-new-cycle", cycle);
				if (shifts != null) {
					for (CycleShift shift: shifts) {
						shift.setCycleId(cycle.getId());
						shift.setId(null); // as we add new shift we don't need
						// old ID if there was one
						ssn.insert("cycles.insert-new-cycle-shift", shift);
					}
				}
			}

			// bind cycle (existing or just created) to attribute as attribute
			// value
			attrValue.setValue(cycle.getId());

			ssn.update("products.set-attr-value-cycle", attrValue);

			// get created or modified value to return it as a result
			Filter[] filters = new Filter[3];
			filters[0] = new Filter();
			filters[0].setElement("id");
			filters[0].setValue(attrValue.getValueId().toString());
			filters[1] = new Filter();
			filters[1].setElement("objectId");
			filters[1].setValue(attrValue.getObjectId().toString());
			filters[2] = new Filter();
			filters[2].setElement("serviceId");
			filters[2].setValue(attrValue.getServiceId().toString());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			if (EntityNames.PRODUCT.equals(attrValue.getEntityType())
					|| ProductConstants.ISSUING_PRODUCT.equals(attrValue.getEntityType())
					|| ProductConstants.ACQUIRING_PRODUCT.equals(attrValue.getEntityType())) {
				return (AttributeValue) ssn.queryForObject("products.get-product-attr-values",
						convertQueryParams(params));
			} else if (EntityNames.SERVICE.equals(attrValue.getEntityType())) {
				return (AttributeValue) ssn.queryForObject("products.get-attribute-values",
						convertQueryParams(params));
			} else {
				return (AttributeValue) ssn.queryForObject("products.get-mixed-attr-values",
						convertQueryParams(params));
			}
		} catch (SQLException e) {
			// ID of new cycle (if it hadn't ID before calling this method)
			// is set back to null just in case it had already obtained new
			// ID that became invalid if we reached this place.
			if (!cycleHadId)
				cycle.setId(null);

			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	@SuppressWarnings("unchecked")
	public Attribute[] getAttrGroups(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSessionFE(userSessionId);

			List<Attribute> groups = ssn.queryForList("products.get-attr-groups",
					convertQueryParams(params));
			return groups.toArray(new Attribute[groups.size()]);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	@SuppressWarnings("unchecked")
	public ServiceType[] getServiceTypes(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, ProductPrivConstants.VIEW_SERVICE_TYPES, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, ProductPrivConstants.VIEW_SERVICE_TYPES);
			List<ServiceType> types = ssn.queryForList("products.get-service-types",
					convertQueryParams(params, limitation));

			return types.toArray(new ServiceType[types.size()]);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public int getServiceTypesCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, ProductPrivConstants.VIEW_SERVICE_TYPES, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, ProductPrivConstants.VIEW_SERVICE_TYPES);
			return (Integer) ssn.queryForObject("products.get-service-types-count",
					convertQueryParams(params, limitation));
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public ServiceType addServiceType(Long userSessionId, ServiceType serviceType) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(serviceType.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, ProductPrivConstants.ADD_SERVICE_TYPE, paramArr);
			ssn.update("products.add-service-type", serviceType);

			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("id");
			filters[0].setValue(serviceType.getId().toString());
			filters[1] = new Filter();
			filters[1].setElement("lang");
			filters[1].setValue(serviceType.getLang());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (ServiceType) ssn.queryForObject("products.get-service-types",
					convertQueryParams(params));
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public ServiceType editServiceType(Long userSessionId, ServiceType serviceType) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(serviceType.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, ProductPrivConstants.MODIFY_SERVICE_TYPE, paramArr);

			ssn.update("products.edit-service-type", serviceType);

			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("id");
			filters[0].setValue(serviceType.getId().toString());
			filters[1] = new Filter();
			filters[1].setElement("lang");
			filters[1].setValue(serviceType.getLang());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (ServiceType) ssn.queryForObject("products.get-service-types",
					convertQueryParams(params));
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void removeServiceType(Long userSessionId, ServiceType serviceType) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(serviceType.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, ProductPrivConstants.REMOVE_SERVICE_TYPE, paramArr);

			ssn.delete("products.remove-service-type", serviceType);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	@SuppressWarnings("unchecked")
	public Service[] getServices(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, ProductPrivConstants.VIEW_SERVICES, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, ProductPrivConstants.VIEW_SERVICES);
			List<Service> services = ssn.queryForList("products.get-services",
					convertQueryParams(params, limitation));

			return services.toArray(new Service[services.size()]);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public int getServicesCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, ProductPrivConstants.VIEW_SERVICES, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, ProductPrivConstants.VIEW_SERVICES);
			return (Integer) ssn.queryForObject("products.get-services-count",
					convertQueryParams(params, limitation));
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public Service addService(Long userSessionId, Service service) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(service.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, ProductPrivConstants.ADD_SERVICE, paramArr);

			ssn.update("products.add-service", service);

			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("id");
			filters[0].setValue(service.getId().toString());
			filters[1] = new Filter();
			filters[1].setElement("lang");
			filters[1].setValue(service.getLang());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (Service) ssn
					.queryForObject("products.get-services", convertQueryParams(params));
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public Service editService(Long userSessionId, Service service) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(service.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, ProductPrivConstants.MODIFY_SERVICE, paramArr);

			ssn.update("products.edit-service", service);

			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("id");
			filters[0].setValue(service.getId().toString());
			filters[1] = new Filter();
			filters[1].setElement("lang");
			filters[1].setValue(service.getLang());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (Service) ssn
					.queryForObject("products.get-services", convertQueryParams(params));
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void removeService(Long userSessionId, Service service) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(service.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, ProductPrivConstants.REMOVE_SERVICE, paramArr);

			ssn.delete("products.remove-service", service);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	@SuppressWarnings("unchecked")
	public ProductService[] getProductServices(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, ProductPrivConstants.VIEW_PRODUCT_SERVICES, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, ProductPrivConstants.VIEW_PRODUCT_SERVICES);
			List<ProductService> pServices = ssn.queryForList("products.get-product-services",
					convertQueryParams(params, limitation));

			return pServices.toArray(new ProductService[pServices.size()]);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public int getProductServicesCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, ProductPrivConstants.VIEW_PRODUCT_SERVICES, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, ProductPrivConstants.VIEW_PRODUCT_SERVICES);
			return (Integer) ssn.queryForObject("products.get-product-services-count",
					convertQueryParams(params, limitation));
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	@SuppressWarnings("unchecked")
	public ProductService[] getProductServicesHier(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, ProductPrivConstants.VIEW_PRODUCT_SERVICES, paramArr);

			List<ProductService> pServices = ssn.queryForList("products.get-product-services-hier",
					convertQueryParams(params));

			return pServices.toArray(new ProductService[pServices.size()]);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	@SuppressWarnings("unchecked")
	public ProductService[] getServiceProductsHier(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, ProductPrivConstants.VIEW_PRODUCT_SERVICES, paramArr);

			List<ProductService> pServices = ssn.queryForList("products.get-service-products-hier",
					convertQueryParams(params));

			return pServices.toArray(new ProductService[pServices.size()]);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public ProductService addProductService(Long userSessionId, ProductService pService, String lang) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(pService.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, ProductPrivConstants.ADD_PRODUCT_SERVICE, paramArr);

			ssn.update("products.add-product-service", pService);

			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("id");
			filters[0].setValue(pService.getId());
			filters[1] = new Filter();
			filters[1].setElement("lang");
			filters[1].setValue(lang);

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (ProductService) ssn.queryForObject("products.get-product-services",
					convertQueryParams(params));
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public ProductService editProductService(Long userSessionId, ProductService pService,
			String lang) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(pService.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, ProductPrivConstants.MODIFY_PRODUCT_SERVICE, paramArr);

			ssn.update("products.edit-product-service", pService);

			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("id");
			filters[0].setValue(pService.getId());
			filters[1] = new Filter();
			filters[1].setElement("lang");
			filters[1].setValue(lang);

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (ProductService) ssn.queryForObject("products.get-product-services",
					convertQueryParams(params));
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public ProductService removeProductService(Long userSessionId, ProductService pService, String lang) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(pService.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, ProductPrivConstants.REMOVE_PRODUCT_SERVICE, paramArr);

			ssn.delete("products.remove-product-service", pService);
			//As this stored procedure does not delete but updates product service,
			//we have to update values from DB
			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("id");
			filters[0].setValue(pService.getId());
			filters[1] = new Filter();
			filters[1].setElement("lang");
			filters[1].setValue(lang);

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (ProductService) ssn.queryForObject("products.get-product-services",
					convertQueryParams(params));
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	@SuppressWarnings("unchecked")
	public ProductService[] getContractServices(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null,
								   (params.getPrivilege()!=null ? 
										   params.getPrivilege() : 
										   ProductPrivConstants.VIEW_CONTRACT_SERVICE),
								   paramArr);

			List<ProductService> pServices = ssn.queryForList("products.get-contract-services",
					convertQueryParams(params));

			return pServices.toArray(new ProductService[pServices.size()]);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}
	
	/**
	 * <p>
	 * Plain customers search. All customers that satisfy condition will be
	 * shown even if there's no object tied to it. Search is done by customer's
	 * properties only (person's or company's properties are ignored)
	 * </p>
	 */

	@SuppressWarnings("unchecked")
	public List<Customer> getCustomers(Long userSessionId, final SelectionParams params, final String lang) {
		final String privilege = params.getPrivilege() != null ? params.getPrivilege() : ProductPrivConstants.VIEW_CUSTOMERS;
		return executeWithSession(userSessionId,
								  privilege,
								  params,
								  logger,
								  new IbatisSessionCallback<List<Customer>>() {
			@Override
			public List<Customer> doInSession(SqlMapSession ssn) throws Exception {
				String limit = CommonController.getLimitationByPriv(ssn, privilege);
				return ssn.queryForList("products.get-customers", convertQueryParams(params, limit, lang));
			}
		});
	}

	public int getCustomersCount(Long userSessionId, final SelectionParams params, final String lang) {
		final String privilege = params.getPrivilege() != null ? params.getPrivilege() : ProductPrivConstants.VIEW_CUSTOMERS;
		return executeWithSession(userSessionId,
								  privilege,
								  params,
								  logger,
								  new IbatisSessionCallback<Integer>() {
			@Override
			public Integer doInSession(SqlMapSession ssn) throws Exception {
				String limit = CommonController.getLimitationByPriv(ssn, privilege);
				Object count = ssn.queryForObject("products.get-customers-count", convertQueryParams(params, limit, lang));
				return (count != null) ? (Integer)count : 0;
			}
		});
	}

	@SuppressWarnings("unchecked")
	public Customer[] getCombinedCustomers(Long userSessionId, SelectionParams params, String lang) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			String privil = (params.getPrivilege()!=null ? params.getPrivilege() : ProductPrivConstants.VIEW_CUSTOMERS);
			ssn = getIbatisSession(userSessionId, null, privil, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, privil);
			List<Customer> customers = ssn.queryForList("products.get-combined-customers",
					convertQueryParams(params, limitation, lang));

			return customers.toArray(new Customer[customers.size()]);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public int getCombinedCustomersCount(Long userSessionId, SelectionParams params, String lang) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			String privil = (params.getPrivilege()!=null ? params.getPrivilege() : ProductPrivConstants.VIEW_CUSTOMERS);
			ssn = getIbatisSession(userSessionId, null, privil, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, privil);
			return (Integer) ssn.queryForObject("products.get-combined-customers-count",
					convertQueryParams(params, limitation, lang));
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}
	

	@SuppressWarnings("unchecked")
	public Customer[] getCompanyCustomers(Long userSessionId, SelectionParams params, String lang) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			String privil = (params.getPrivilege()!=null ? params.getPrivilege() : ProductPrivConstants.VIEW_CUSTOMERS);
			ssn = getIbatisSession(userSessionId, null, privil, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, privil);
			List<Customer> customers = ssn.queryForList("products.get-company-customers",
					convertQueryParams(params, limitation, lang));

			return customers.toArray(new Customer[customers.size()]);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}
	

	@SuppressWarnings("unchecked")
	public Customer[] getPersonCustomers(Long userSessionId, SelectionParams params, String lang) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			String privil = (params.getPrivilege()!=null ? params.getPrivilege() : ProductPrivConstants.VIEW_CUSTOMERS);
			ssn = getIbatisSession(userSessionId, null, privil, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, privil);
			List<Customer> customers = ssn.queryForList("products.get-person-customers",
					convertQueryParams(params, limitation, lang));

			return customers.toArray(new Customer[customers.size()]);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	@SuppressWarnings("unchecked")
	public Customer[] getUndefinedCustomers(Long userSessionId, SelectionParams params, String lang) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			String privil = (params.getPrivilege()!=null ? params.getPrivilege() : ProductPrivConstants.VIEW_CUSTOMERS);
			ssn = getIbatisSession(userSessionId, null, privil, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, privil);
			List<Customer> customers = ssn.queryForList("products.get-undefined-customers",
					convertQueryParams(params, limitation, lang));

			return customers.toArray(new Customer[customers.size()]);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	@SuppressWarnings("unchecked")
	public Customer[] getCombinedCustomersProc(Long userSessionId, SelectionParams params, String tabName) {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSessionFE(userSessionId);
			QueryParams qparams = convertQueryParams(params);
			Map<String, Object> map = new HashMap<String, Object>();
			map.put("firstRow", qparams.getRange().getStartPlusOne());
			map.put("lastRow", qparams.getRange().getEndPlusOne());
			map.put("params", params.getFilters());
			map.put("sorters", params.getSortElement());
			map.put("tabName", tabName);
			map.put("rowCount", params.getRowCount());
			ssn.update("products.get-combined-customers-proc",map);
			List<Customer> customers = (List<Customer>)map.get("customers");
			return customers.toArray(new Customer[customers.size()]);
		} catch (SQLException e) {
			logger.error("", e);
			if (e.getErrorCode() >= 20000 && e.getErrorCode() <= 20999 ){
				throw createDaoException(e);
			} else {
				throw new DataAccessException(e);
			}
		} finally {
			close(ssn);
		}
	}


	public int getCombinedCustomersCountProc(Long userSessionId, SelectionParams params, String tabName) {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSessionFE(userSessionId);
			String limitation = null;
			if (params.getModule() != null && params.getModule().equals(ModuleNames.CASE_MANAGEMENT)) {
				limitation = null;
			} else {
				limitation = CommonController.getLimitationByPriv(ssn, ProductPrivConstants.VIEW_CUSTOMERS);
			}
			if (limitation != null){
				List<Filter> filters = new ArrayList<Filter> (Arrays.asList(params.getFilters()));
				filters.add(new Filter("PRIVIL_LIMITATION", limitation));
				params.setFilters(filters.toArray(new Filter[filters.size()]));
			}
			Map<String, Object> map = new HashMap<String, Object>();
			map.put("params", params.getFilters());
			map.put("tabName", tabName);
			ssn.update("products.get-combined-customers-count-proc",map);
			return (Integer)map.get("count");
		} catch (SQLException e) {
			logger.error("", e);
			if (e.getErrorCode() >= 20000 && e.getErrorCode() <= 20999 ){
				throw createDaoException(e);
			} else {
				throw new DataAccessException(e);
			}
		} finally {
			close(ssn);
		}
	}


	@SuppressWarnings("unchecked")
	public Customer[] getCardCustomers(Long userSessionId, SelectionParams params, String lang) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, ProductPrivConstants.VIEW_CUSTOMERS, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, ProductPrivConstants.VIEW_CUSTOMERS);
			List<Customer> customers = ssn.queryForList("products.get-combined-customers-by-card",
					convertQueryParams(params, limitation, lang));

			return customers.toArray(new Customer[customers.size()]);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public int getCardCustomersCount(Long userSessionId, SelectionParams params, String lang) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, ProductPrivConstants.VIEW_CUSTOMERS, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, ProductPrivConstants.VIEW_CUSTOMERS);
			return (Integer) ssn.queryForObject("products.get-combined-customers-by-card-count",
					convertQueryParams(params, limitation, lang));
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}
	

	@SuppressWarnings("unchecked")
	public Customer[] getAccountCustomers(Long userSessionId, SelectionParams params, String lang) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, ProductPrivConstants.VIEW_CUSTOMERS, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, ProductPrivConstants.VIEW_CUSTOMERS);
			List<Customer> customers = ssn.queryForList("products.get-combined-customers-by-account",
					convertQueryParams(params, limitation, lang));

			return customers.toArray(new Customer[customers.size()]);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public int getAccountCustomersCount(Long userSessionId, SelectionParams params, String lang) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, ProductPrivConstants.VIEW_CUSTOMERS, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, ProductPrivConstants.VIEW_CUSTOMERS);
			return (Integer) ssn.queryForObject("products.get-combined-customers-by-account-count",
					convertQueryParams(params, limitation, lang));
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}
	

	@SuppressWarnings("unchecked")
	public Customer[] getMerchantCustomers(Long userSessionId, SelectionParams params, String lang) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, ProductPrivConstants.VIEW_CUSTOMERS, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, ProductPrivConstants.VIEW_CUSTOMERS);
			List<Customer> customers = ssn.queryForList("products.get-combined-customers-by-merchant",
					convertQueryParams(params, limitation, lang));

			return customers.toArray(new Customer[customers.size()]);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public int getMerchantCustomersCount(Long userSessionId, SelectionParams params, String lang) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, ProductPrivConstants.VIEW_CUSTOMERS, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, ProductPrivConstants.VIEW_CUSTOMERS);
			return (Integer) ssn.queryForObject("products.get-combined-customers-by-merchant-count",
					convertQueryParams(params, limitation, lang));
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}
	

	@SuppressWarnings("unchecked")
	public Customer[] getTerminalCustomers(Long userSessionId, SelectionParams params, String lang) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, ProductPrivConstants.VIEW_CUSTOMERS, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, ProductPrivConstants.VIEW_CUSTOMERS);
			List<Customer> customers = ssn.queryForList("products.get-combined-customers-by-terminal",
					convertQueryParams(params, limitation, lang));

			return customers.toArray(new Customer[customers.size()]);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public int getTerminalCustomersCount(Long userSessionId, SelectionParams params, String lang) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, ProductPrivConstants.VIEW_CUSTOMERS, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, ProductPrivConstants.VIEW_CUSTOMERS);
			return (Integer) ssn.queryForObject("products.get-combined-customers-by-terminal-count",
					convertQueryParams(params, limitation, lang));
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}
	

	@SuppressWarnings("unchecked")
	public Customer[] getContractCustomers(Long userSessionId, SelectionParams params, String lang) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, ProductPrivConstants.VIEW_CUSTOMERS, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, ProductPrivConstants.VIEW_CUSTOMERS);
			List<Customer> customers = ssn.queryForList("products.get-combined-customers-by-contract",
					convertQueryParams(params, limitation, lang));

			return customers.toArray(new Customer[customers.size()]);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public int getContractCustomersCount(Long userSessionId, SelectionParams params, String lang) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, ProductPrivConstants.VIEW_CUSTOMERS, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, ProductPrivConstants.VIEW_CUSTOMERS);
			return (Integer) ssn.queryForObject("products.get-combined-customers-by-contract-count",
					convertQueryParams(params, limitation, lang));
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	@SuppressWarnings("unchecked")
	public Customer[] getAddressCustomers(Long userSessionId, SelectionParams params, String lang) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, ProductPrivConstants.VIEW_CUSTOMERS, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, ProductPrivConstants.VIEW_CUSTOMERS);
			List<Customer> customers = ssn.queryForList("products.get-combined-customers-by-address",
					convertQueryParams(params, limitation, lang));

			return customers.toArray(new Customer[customers.size()]);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public int getAddressCustomersCount(Long userSessionId, SelectionParams params, String lang) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, ProductPrivConstants.VIEW_CUSTOMERS, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, ProductPrivConstants.VIEW_CUSTOMERS);
			return (Integer) ssn.queryForObject("products.get-combined-customers-by-address-count",
					convertQueryParams(params, limitation, lang));
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}
	

	public Customer addCustomer(Long userSessionId, Customer customer, String lang) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(customer.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, ProductPrivConstants.ADD_CUSTOMER, paramArr);

			ssn.update("products.add-customer", customer);

			Filter[] filters = new Filter[1];
			filters[0] = new Filter();
			filters[0].setElement("id");
			filters[0].setValue(customer.getId().toString());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (Customer) ssn.queryForObject("products.get-combined-customers",
					convertQueryParams(params, null, lang));
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public Customer editCustomer(Long userSessionId, Customer customer, String lang) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(customer.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, ProductPrivConstants.MODIFY_CUSTOMER, paramArr);

			ssn.update("products.edit-customer", customer);

			Filter[] filters = new Filter[1];
			filters[0] = new Filter();
			filters[0].setElement("id");
			filters[0].setValue(customer.getId().toString());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (Customer) ssn.queryForObject("products.get-combined-customers",
					convertQueryParams(params, null, lang));
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void removeCustomer(Long userSessionId, Customer customer) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(customer.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, ProductPrivConstants.REMOVE_CUSTOMER, paramArr);

			ssn.delete("products.remove-customer", customer);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	@SuppressWarnings("unchecked")
	public Contract[] getContracts(Long userSessionId, SelectionParams params, String lang) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, (params.getPrivilege()!=null ? params.getPrivilege() : ProductPrivConstants.VIEW_CUSTOMER_CONTRACTS), paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, (params.getPrivilege()!=null ? params.getPrivilege() : ProductPrivConstants.VIEW_CUSTOMER_CONTRACTS));
			List<Contract> contracts = ssn.queryForList("products.get-contracts",
					convertQueryParams(params, limitation, lang));

			return contracts.toArray(new Contract[contracts.size()]);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public int getContractsCount(Long userSessionId, SelectionParams params, String lang) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			String privil = (params.getPrivilege()!=null ? params.getPrivilege() : ProductPrivConstants.VIEW_CUSTOMER_CONTRACTS);
			ssn = getIbatisSession(userSessionId, null, privil, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, privil);
			return (Integer) ssn.queryForObject("products.get-contracts-count", convertQueryParams(
					params, limitation, lang));
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

    @SuppressWarnings("unchecked")
    public Contract[] getContractsCur(Long userSessionId, SelectionParams params, Map<String, Object> paramsMap) {
        Contract[] result;
        SqlMapSession ssn = null;
        try {
            CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
            ssn = getIbatisSession(userSessionId, null, (params.getPrivilege()!=null ? params.getPrivilege() : ProductPrivConstants.VIEW_CUSTOMER_CONTRACTS), paramArr);
            String limitation = CommonController.getLimitationByPriv(ssn, (params.getPrivilege()!=null ? params.getPrivilege() : ProductPrivConstants.VIEW_CUSTOMER_CONTRACTS));

            List<Filter> filters = new ArrayList<Filter>(Arrays.asList((Filter[]) paramsMap.get("param_tab")));
            filters.add(new Filter("PRIVIL_LIMITATION", limitation));
            QueryParams qparams = convertQueryParams(params);
            paramsMap.put("param_tab", filters.toArray(new Filter[filters.size()]));
            paramsMap.put("first_row", qparams.getRange().getStartPlusOne());
            paramsMap.put("last_row", qparams.getRange().getEndPlusOne());
            paramsMap.put("row_count", params.getRowCount());
            paramsMap.put("sorting_tab", params.getSortElement());
            ssn.update("products.get-contracts-cur", paramsMap);
            List<Contract> cardholders = (ArrayList<Contract>) paramsMap.get("ref_cur");
            result = cardholders.toArray(new Contract[cardholders.size()]);
        } catch (SQLException e) {
            logger.error("", e);
            throw createDaoException(e);
        } finally {
            close(ssn);
        }
        return result;
    }


    public int getContractsCurCount(Long userSessionId, SelectionParams params, Map<String, Object> paramsMap) {
        Integer result = 0;
        SqlMapSession ssn = null;
        try {
            CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
            String privil = (params.getPrivilege()!=null ? params.getPrivilege() : ProductPrivConstants.VIEW_CUSTOMER_CONTRACTS);
            ssn = getIbatisSession(userSessionId, null, privil, paramArr);
            String limitation = CommonController.getLimitationByPriv(ssn, privil);

            List<Filter> filters = new ArrayList<Filter>(Arrays.asList((Filter[]) paramsMap.get("param_tab")));
            filters.add(new Filter("PRIVIL_LIMITATION", limitation));
            paramsMap.put("param_tab", filters.toArray(new Filter[filters.size()]));
            ssn.update("products.get-contracts-cur-count", paramsMap);
            result = (Integer) paramsMap.get("row_count");
        } catch (SQLException e) {
            logger.error("", e);
            throw createDaoException(e);
        } finally {
            close(ssn);
        }
        return result;
    }
	

	public void checkPanLength(Long userSessionId, Integer binId, Integer formatId) {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSessionFE(userSessionId);
			Map<String, Integer> map = new HashMap<String, Integer>();
			map.put("binId", binId);
			map.put("formatId", formatId);
			ssn.update("products.check-pan-length", map);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	@SuppressWarnings("unchecked")
	public ContractType[] getContractTypes(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null,  ProductPrivConstants.VIEW_CONTRACT_TYPE, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, ProductPrivConstants.VIEW_CONTRACT_TYPE);
			List<ContractType> types = ssn.queryForList("products.get-contract-types",
					convertQueryParams(params, limitation));

			return types.toArray(new ContractType[types.size()]);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public int getContractTypesCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null,  ProductPrivConstants.VIEW_CONTRACT_TYPE, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, ProductPrivConstants.VIEW_CONTRACT_TYPE);
			return (Integer) ssn.queryForObject("products.get-contract-types-count",
					convertQueryParams(params, limitation));
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}
	

	public String getProductType(Long userSessionId, ContractType contractType) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(contractType.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null,  ProductPrivConstants.VIEW_PRODUCT_TYPE, paramArr);
			
			return (String) ssn.queryForObject("products.get-product-type",
					contractType);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public ContractType addContractType(Long userSessionId, ContractType contractType) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(contractType.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null,  ProductPrivConstants.ADD_CONTRACT_TYPE, paramArr);

			ssn.update("products.add-contract-type", contractType);

			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("id");
			filters[0].setValue(contractType.getId().toString());
			filters[1] = new Filter();
			filters[1].setElement("lang");
			filters[1].setValue(contractType.getLang());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (ContractType) ssn.queryForObject("products.get-contract-types",
					convertQueryParams(params));
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void removeContractType(Long userSessionId, ContractType contractType) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(contractType.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null,  ProductPrivConstants.REMOVE_CONTRACT_TYPE, paramArr);

			ssn.delete("products.remove-contract-type", contractType);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	@SuppressWarnings("unchecked")
	public ServiceObject[] getServiceObjects(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, ProductPrivConstants.VIEW_SERVICE_OBJECTS, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, ProductPrivConstants.VIEW_SERVICE_OBJECTS);
			List<ServiceObject> items = ssn.queryForList("products.get-service-objects",
					convertQueryParams(params, limitation));

			return items.toArray(new ServiceObject[items.size()]);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public int getServiceObjectsCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, ProductPrivConstants.VIEW_SERVICE_OBJECTS, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, ProductPrivConstants.VIEW_SERVICE_OBJECTS);
			return (Integer) ssn.queryForObject("products.get-service-objects-count",
					convertQueryParams(params, limitation));
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}
	
	/**
	 * <p>
	 * Only customers that are either companies or persons will be shown.
	 * Customers without object tied to it won't be shown.
	 * </p>
	 */

	@SuppressWarnings("unchecked")
	public Customer[] getDocumentCustomers(Long userSessionId, SelectionParams params, String lang) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, ProductPrivConstants.VIEW_CUSTOMERS, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, ProductPrivConstants.VIEW_CUSTOMERS);
			List<Customer> customers = ssn.queryForList("products.get-combined-customers-by-document",
					convertQueryParams(params, limitation, lang));

			return customers.toArray(new Customer[customers.size()]);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public int getDocumentCustomersCount(Long userSessionId, SelectionParams params, String lang) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, ProductPrivConstants.VIEW_CUSTOMERS, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, ProductPrivConstants.VIEW_CUSTOMERS);
			return (Integer) ssn.queryForObject("products.get-combined-customers-by-document-count",
					convertQueryParams(params, limitation, lang));
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}
	
	/**
	 * <p>
	 * Only customers that are either companies or persons will be shown.
	 * Customers without object tied to it won't be shown.
	 * </p>
	 */

	@SuppressWarnings("unchecked")
	public Customer[] getContactCustomers(Long userSessionId, SelectionParams params, String lang) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, ProductPrivConstants.VIEW_CUSTOMERS, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, ProductPrivConstants.VIEW_CUSTOMERS);
			List<Customer> customers = ssn.queryForList("products.get-combined-customers-by-contact",
					convertQueryParams(params, limitation, lang));

			return customers.toArray(new Customer[customers.size()]);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public int getContactCustomersCount(Long userSessionId, SelectionParams params, String lang) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, ProductPrivConstants.VIEW_CUSTOMERS, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, ProductPrivConstants.VIEW_CUSTOMERS);
			return (Integer) ssn.queryForObject("products.get-combined-customers-by-contact-count",
					convertQueryParams(params, limitation, lang));
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	@SuppressWarnings("unchecked")
	public ProductAttribute[] getContractAttributes(Long userSessionId, Long contractId,
			Integer productId, Integer instId, String productType, String lang) {
		SqlMapSession ssn = null;
		
		try {
			ServiceObject[] serviceObjects = getServiceObjectsForContrtact(userSessionId,
					contractId, lang);
			List<ProductAttribute> contractAttributes = new ArrayList<ProductAttribute>();
			
			if (serviceObjects != null && serviceObjects.length > 0) {
				HashMap<String, List<Long>> serviceObjectsMap = new HashMap<String, List<Long>>();
				List<Long> objectsIds = new ArrayList<Long>();
				
				String lastEntityType = serviceObjects[0].getEntityType(); 
				for (ServiceObject so : serviceObjects) {
					if (!so.getEntityType().equals(lastEntityType)) {
						serviceObjectsMap.put(lastEntityType, objectsIds);
						lastEntityType = so.getEntityType();
						objectsIds = new ArrayList<Long>();
					}
					objectsIds.add(so.getObjectId());
				}
				serviceObjectsMap.put(lastEntityType, objectsIds);
				
				Filter[] filters = new Filter[5];
				filters[0] = new Filter("lang", lang);
				filters[1] = new Filter("instId", instId);
				filters[2] = new Filter("productId", productId);

				ssn = getIbatisSession(userSessionId, null, ProductPrivConstants.VIEW_ATTRIBUTE_PRODUCT, null);
				
				for (String entityType : serviceObjectsMap.keySet()) {
					filters[3] = new Filter("entityType", entityType);
					filters[4] = new Filter("objectIds", serviceObjectsMap.get(entityType));
					
					SelectionParams params = new SelectionParams();
					params.setFilters(filters);
					List<ProductAttribute> attrs = ssn.queryForList("products.get-object-attrs",
							convertQueryParams(params));
					contractAttributes.addAll(attrs);
				}
				return contractAttributes.toArray(new ProductAttribute[contractAttributes.size()]);
			}

			return new ProductAttribute[0];
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}
	
	private ServiceObject[] getServiceObjectsForContrtact(Long userSessionId, Long contractId,
			String lang) {
		Filter[] filters = new Filter[2];
		filters[0] = new Filter("lang", lang);
		filters[1] = new Filter("contractId", contractId);
		SortElement[] sorters = new SortElement[1];
		sorters[0] = new SortElement("entityType");
		
		SelectionParams params = new SelectionParams();
		params.setFilters(filters);
		params.setRowIndexEnd(Integer.MAX_VALUE);
		params.setSortElement(sorters);
		
		return getServiceObjects(userSessionId, params);
	}
	

	public void associateCustomer(Long userSessionId, Customer customer){
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSessionFE(userSessionId);
			
			ssn.delete("products.modify-customer", customer);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}
	

	public void clearCustomerExtFields(Long userSessionId, Customer customer){
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSessionFE(userSessionId);

			ssn.delete("products.clear-ext-fields", customer);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	/**
	 * <p>
	 * Simple customers search. Returns only fields that are available in
	 * PRD_UI_CUSTOMER_VW.
	 * </p>
	 */

	@SuppressWarnings("unchecked")
	public Customer[] getCustomersLight(Long userSessionId, SelectionParams params, String lang) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			String privil = (params.getPrivilege()!=null ? params.getPrivilege() : ProductPrivConstants.VIEW_CUSTOMERS);
			ssn = getIbatisSession(userSessionId, null, privil, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn,
					privil);
			List<Customer> customers = ssn.queryForList("products.get-customers-light",
					convertQueryParams(params, limitation, lang));

			return customers.toArray(new Customer[customers.size()]);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	
	@SuppressWarnings("unchecked")
	public ProductAccountType[] getProductAccountTypes(Long userSessionId,
			SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, AccountPrivConstants.VIEW_PRODUCT_ACCOUNT_TYPE, paramArr);
			List<ProductAccountType> prodAccTypes = ssn.queryForList("products.get-product-account-type", convertQueryParams(params));

			return prodAccTypes.toArray(new ProductAccountType[prodAccTypes.size()]);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}	

	public int getProductAccountTypesCount(Long userSessionId,
			SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, AccountPrivConstants.VIEW_PRODUCT_ACCOUNT_TYPE, paramArr);

			return (Integer) ssn.queryForObject("products.get-product-account-type-count", convertQueryParams(params));
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public ProductAccountType addProductAccountType(Long userSessionId, final ProductAccountType prodAccType) {
		return executeWithSession(userSessionId,
								  AccountPrivConstants.ADD_PRODUCT_ACCOUNT_TYPE,
								  AuditParamUtil.getCommonParamRec(prodAccType.getAuditParameters()),
								  logger,
								  new IbatisSessionCallback<ProductAccountType>() {
			@Override
			public ProductAccountType doInSession(SqlMapSession ssn) throws Exception {
				ssn.insert("products.add-product-account-type", prodAccType);
				List<Filter> filters = new ArrayList<Filter>(2);
				filters.add(Filter.create("id", prodAccType.getId().toString()));
				filters.add(Filter.create("lang", prodAccType.getLang()));
				SelectionParams params = new SelectionParams(filters);
				List<Object> out = ssn.queryForList("products.get-product-account-type", convertQueryParams(params));
				if (out != null && out.size() > 0) {
					return (ProductAccountType)out.get(0);
				}
				return prodAccType.clone();
			}
		});
	}


	public ProductAccountType editProductAccountType(Long userSessionId, final ProductAccountType prodAccType) {
		return executeWithSession(userSessionId,
								  AccountPrivConstants.MODIFY_PRODUCT_ACCOUNT_TYPE,
								  AuditParamUtil.getCommonParamRec(prodAccType.getAuditParameters()),
								  logger,
								  new IbatisSessionCallback<ProductAccountType>() {
			@Override
			public ProductAccountType doInSession(SqlMapSession ssn) throws Exception {
				ssn.update("products.edit-product-account-type", prodAccType);
				List<Filter> filters = new ArrayList<Filter>(2);
				filters.add(Filter.create("id", prodAccType.getId().toString()));
				filters.add(Filter.create("lang", prodAccType.getLang()));
				SelectionParams params = new SelectionParams(filters);
				List<Object> out = ssn.queryForList("products.get-product-account-type", convertQueryParams(params));
				if (out != null && out.size() > 0) {
					return (ProductAccountType)out.get(0);
				}
				return prodAccType.clone();
			}
		});
	}


	public void removeProductAccountType(Long userSessionId,
			ProductAccountType prodAccType) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(prodAccType.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, AccountPrivConstants.REMOVE_PRODUCT_ACCOUNT_TYPE, paramArr);
			
			ssn.delete("products.remove-product-account-type",
					prodAccType);
		} catch (SQLException e) {
				logger.error("", e);
				throw createDaoException(e);
			} finally {
				close(ssn);
			}
		}

	@SuppressWarnings("unchecked")
	public ServiceType[] getServiceTypeByProduct(Long userSessionId,
			SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, ProductPrivConstants.VIEW_SERVICE_TYPES, paramArr);
			List<ServiceType> types = ssn.queryForList("products.get-service-types-by-product", convertQueryParams(params));

			return types.toArray(new ServiceType[types.size()]);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}



	public int getServiceTypeByProductCount(Long userSessionId,
			SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, ProductPrivConstants.VIEW_SERVICE_TYPES, paramArr);
			return (Integer) ssn.queryForObject("products.get-service-types-by-product-count", convertQueryParams(params));
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
	
		}
	}

	public int getProductServiceMinCount(Long userSessionId,
			SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, ProductPrivConstants.VIEW_CONTRACT_SERVICE, paramArr);
			return (Integer) ssn.queryForObject("products.get-product-service-min-count", convertQueryParams(params));
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
	
		}
	}
	

	@SuppressWarnings("unchecked")
	public Service[] getServicesByAccountProduct(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, ProductPrivConstants.VIEW_SERVICES, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, ProductPrivConstants.VIEW_SERVICES);
			List<Service> services = ssn.queryForList("products.get-services-by-account-product",
					convertQueryParams(params, limitation));

			return services.toArray(new Service[services.size()]);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	@SuppressWarnings("unchecked")
	public Service[] getServicesByCardProduct(Long userSessionId,
			SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, ProductPrivConstants.VIEW_SERVICES, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, ProductPrivConstants.VIEW_SERVICES);
			List<Service> services = ssn.queryForList("products.get-services-by-card-product",
					convertQueryParams(params, limitation));

			return services.toArray(new Service[services.size()]);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}
	

	@SuppressWarnings("unchecked")
	public ProductAttribute[] getFlatObjectAttributes(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, ProductPrivConstants.VIEW_ATTRIBUTE_OBJECTS, paramArr);
			
			List<ProductAttribute> attrs = ssn.queryForList("products.get-object-attrs-flat",
					convertQueryParams(params));
			return attrs.toArray(new ProductAttribute[attrs.size()]);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}	
	

	@SuppressWarnings("unchecked")
	public ProductAttribute[] getDefinedAttrs(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, ProductPrivConstants.VIEW_ATTRIBUTE_OBJECTS, paramArr);

			List<ProductAttribute> attrs = ssn.queryForList("products.get-defined-attrs",
					convertQueryParams(params));
			return attrs.toArray(new ProductAttribute[attrs.size()]);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public Service[] getServicesByMerchantProduct(Long userSessionId,
			SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, ProductPrivConstants.VIEW_SERVICES, paramArr);
			List<Service> services = ssn.queryForList("products.get-services-by-merchant-product",
					convertQueryParams(params));

			return services.toArray(new Service[services.size()]);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public Service[] getServicesByTerminalProduct(Long userSessionId,
			SelectionParams params) {
		SqlMapSession ssn = null;
		try{
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, ProductPrivConstants.VIEW_SERVICES, paramArr);
			List<Service> services = ssn.queryForList("products.get-services-by-terminal-product",
					convertQueryParams(params));

			return services.toArray(new Service[services.size()]);
			
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
		
	}

	/**
	 * @brief sort received attributes by object hierarchy and by start time
	 *        and then setup correct value as actual one. We sort attributes by
	 *        three steps: effective date, object priority and registration date.
	 * @note Please do not change that logic unless you have absolute assurance
	 *       in its necessity. It has already invoked a lot of issues.
     */
	private void trySortAttr(List<AttributeValue> attrValues, Long userSessionId){
		if (attrValues.isEmpty()) {
			return; // nothing to set
		}

		final Date currentDate;
		if (attrValues.get(0).getOwnerProductId() != null) {
			currentDate = getDate(attrValues.get(0).getOwnerProductId(), "ENTTPROD", userSessionId);
		} else {
			currentDate = getDate(attrValues.get(0).getObjectId(), attrValues.get(0).getEntityType(), userSessionId);
		}
		if (currentDate == null) {
			logger.debug("There is no object's or owner product's date. Check BO procedures");
			return; // nothing to set
		}

		Collections.sort(attrValues, new Comparator<AttributeValue>() {

			public int compare( AttributeValue o1, AttributeValue o2 ){
				if (!(isSuitable(o1, currentDate) ^ isSuitable(o2, currentDate))) {
					if (o2.getLevelPriority().compareTo(o1.getLevelPriority()) != 0) {
						return o2.getLevelPriority().compareTo(o1.getLevelPriority());
					}
					return (o1.getRegDate().compareTo(o2.getRegDate()));
				} else if (isSuitable(o1, currentDate)) {
					return -1;
				}
				return 1;
			}

		});

		int i = attrValues.size() - 1;
		boolean find = false;
		while(i>=0 && !find){
			if(isSuitable(attrValues.get(i), currentDate)){
				attrValues.get(i).setActual(true);
				find = true;
			}
			i--;
		}
	}

	public boolean isSuitable(AttributeValue o, Date currentDate) {
		if (o.getStartDate().compareTo(currentDate) > 0) {
			return false;
		} else if (o.getEndDate() == null || o.getEndDate().after(currentDate)) {
			return true;
		}
		return false;
	}

	/*
	 * Return date by int_id
	 * */
	private Date getDate(Long objectId, String entityType, Long userSessionId) {
		Date result = null;
		SqlMapSession ssn = null;
		Integer instId;
		Map<String, Object> filters = new HashMap<String, Object>();
		filters.put("object_id", objectId);
		filters.put("entity_type", entityType);
		try {
			ssn = getIbatisSession(userSessionId);
			instId = (Integer) ssn.queryForObject("products.get-inst-id-by-object", filters);
			result = (Date) ssn.queryForObject("common.get-calc-date", instId);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
		return result;
	}


	@SuppressWarnings("unchecked")
	public String getCustomerInfo(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSession(userSessionId);
			return (String)ssn.queryForObject("products.get-customer-info", convertQueryParams(params));
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	@SuppressWarnings("unchecked")
	public String getCardType(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSession(userSessionId);
			return (String)ssn.queryForObject("products.get-card-type", convertQueryParams(params));
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	@SuppressWarnings("unchecked")
	public boolean checkConditionalService(Long userSessionId,
										   final Integer productId,
										   final Long serviceId,
										   final Integer count) {
		return executeWithSession(userSessionId, logger, new IbatisSessionCallback<Boolean>() {
			@Override
			public Boolean doInSession(SqlMapSession ssn) throws Exception {
				Map<String, Object> params = new HashMap<String, Object>();
				params.put("product_id", productId);
				params.put("service_id", serviceId);
				params.put("service_count", count);
				ssn.queryForObject("products.check-cond-service", params);
				return (Boolean)params.get("value");
			}
		});
	}


	@SuppressWarnings("unchecked")
	public String getConditionalGroup(Long userSessionId, final Integer productId, final Long serviceId) {
		return executeWithSession(userSessionId, logger, new IbatisSessionCallback<String>() {
			@Override
			public String doInSession(SqlMapSession ssn) throws Exception {
				Map<String, Object> params = new HashMap<String, Object>();
				params.put("product_id", productId);
				params.put("service_id", serviceId);
				return (String)ssn.queryForObject("products.get-cond-group-for-service", params);
			}
		});
	}


    @SuppressWarnings("unchecked")
    public ProductAttribute[] getObjectFeeAttrs(Long userSessionId, SelectionParams params) {
        SqlMapSession ssn = null;
        try {
            CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
            ssn = getIbatisSession(userSessionId, null, ProductPrivConstants.VIEW_ATTRIBUTE_OBJECTS, paramArr);

            List<ProductAttribute> attrs = ssn.queryForList("products.get-object-fee-attrs",
                convertQueryParams(params));
            return attrs.toArray(new ProductAttribute[attrs.size()]);
        } catch (SQLException e) {
            logger.error("", e);
            throw createDaoException(e);
        } finally {
            close(ssn);
        }
    }

	@SuppressWarnings("unchecked")
	public PriorityProduct[] getPriorityProducts(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, ProductPrivConstants.VIEW_PRIORITY_PRODUCTS, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn,
					ProductPrivConstants.VIEW_PRIORITY_PRODUCTS);
			List<PriorityProduct> priorProducts = ssn.queryForList(
					"products.get-priority-products", convertQueryParams(params, limitation));
			return priorProducts.toArray(new PriorityProduct[priorProducts.size()]);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public int getPriorityProductsCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, ProductPrivConstants.VIEW_PRIORITY_PRODUCTS, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn,
					ProductPrivConstants.VIEW_PRIORITY_PRODUCTS);
			return (Integer) ssn.queryForObject(
					"products.get-priority-products-count", convertQueryParams(params, limitation));
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	public List<String> getAccountProductCurrencies(Long userSessionId, final Integer productId) {
		return executeWithSession(userSessionId, logger, new IbatisSessionCallback<List<String>>() {
			@Override
			public List<String> doInSession(SqlMapSession ssn) throws Exception {
				return ssn.queryForList("products.get-account-product-currencies", productId);
			}
		});
	}
}
