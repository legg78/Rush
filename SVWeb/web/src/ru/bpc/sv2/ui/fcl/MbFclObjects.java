package ru.bpc.sv2.ui.fcl;

import org.apache.commons.lang3.StringUtils;
import org.apache.log4j.Logger;
import org.openfaces.util.Faces;
import ru.bpc.sv2.campaign.Campaign;
import ru.bpc.sv2.common.FlexFieldData;
import ru.bpc.sv2.constants.DictNames;
import ru.bpc.sv2.constants.EntityNames;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.constants.SystemConstants;
import ru.bpc.sv2.fcl.cycles.Cycle;
import ru.bpc.sv2.fcl.cycles.CycleShift;
import ru.bpc.sv2.fcl.fees.Fee;
import ru.bpc.sv2.fcl.fees.FeeTier;
import ru.bpc.sv2.fcl.fees.FeeType;
import ru.bpc.sv2.fcl.limits.Limit;
import ru.bpc.sv2.fcl.limits.LimitRate;
import ru.bpc.sv2.fcl.limits.LimitType;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.invocation.SortElement;
import ru.bpc.sv2.invocation.SortElement.Direction;
import ru.bpc.sv2.logic.*;
import ru.bpc.sv2.products.AttributeValue;
import ru.bpc.sv2.rules.Modifier;
import ru.bpc.sv2.ui.fcl.cycles.MbCycleShiftsSearch;
import ru.bpc.sv2.ui.fcl.fees.MbFeeTiers;
import ru.bpc.sv2.ui.utils.CommonUtils;
import ru.bpc.sv2.ui.utils.DictUtils;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.utils.UserException;
import util.auxil.ManagedBeanWrapper;
import util.auxil.SessionWrapper;


import javax.faces.application.FacesMessage;
import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.component.UIComponent;
import javax.faces.component.html.HtmlInputText;
import javax.faces.context.FacesContext;
import javax.faces.event.ValueChangeEvent;
import javax.faces.model.SelectItem;
import java.io.Serializable;
import java.math.BigDecimal;
import java.util.*;

@ViewScoped
@ManagedBean  (name = "MbFclObjects")
public class MbFclObjects implements Serializable {
	private static final long serialVersionUID = 1L;
	private static final Logger logger = Logger.getLogger("FCL");

	private RulesDao _rulesDao = new RulesDao();
	private ProductsDao _productsDao = new ProductsDao();
	private FeesDao _feesDao = new FeesDao();
	private CyclesDao _cyclesDao = new CyclesDao();
	private LimitsDao _limitsDao = new LimitsDao();
	private CommonDao _commonDao = new CommonDao();
	private CampaignDao _campaignDao = new CampaignDao();

	public static final int VIEW_MODE = 1;
	public static final int EDIT_MODE = 2;
	public static final int NEW_MODE = 4;
	public static final String BOUND = "BOUND";
	public static final String LIMIT = "LIMIT";
	public static final String CURRENCY = "CURRENCY";
	public static final String COUNT = "COUNT";
	public static final String SUM = "SUM";

	private int curMode;

	private Fee fee;
	private Cycle cycle;
	private Limit limit;
	private Limit parent;
	private Integer feeId;
	private Integer cycleId;
	private Long limitId;
	private String prevCurrency;
	private BigDecimal prevAmount;

	private ArrayList<SelectItem> feeRatesCalc;;
	private ArrayList<SelectItem> feeBasisCalc;;
	private List<SelectItem> postingMethods;;
	private List<SelectItem> limitCounterAlgorithms;
	private List<SelectItem> lengthTypes;
	private List<SelectItem> truncTypes;
	private List<SelectItem> limitCheckTypes;
	
	private FlexFieldData[] feeFlexFields;
	private boolean emptyFlexFields;
	
	private AttributeValue attrValue;
	private AttributeValue initialAttrValue;
	private DaoDataModel<?> dataModel;
	private String entityType;
	private Integer scaleId;
	private String feeType;
	private String cycleType;
	private String cycleTypeForLimit;
	private String limitType;
	private Integer instId;
	private Integer serviceId;
	private Long campaignId;

	private final int CREATE_VALUE = 1;
	private final int CLONE_VALUE = 2;
	private final int APPLY_VALUE = 4;

	// radio buttons
	private int feeMode;
	private int cycleMode;
	private int limitMode;

	private boolean feeNeedsLengthType;
	private boolean cyclicFee;
	private boolean isInheritedValue;
	private static DictUtils dictUtils;
	
	private String curLang;

	private MbFeeTiers tiersBean;
	private MbCycleShiftsSearch shiftsBean;

	private Long userSessionId = null;

	private String productType;

	private final BigDecimal maxNumber = (new BigDecimal("1.0E18")).subtract(new BigDecimal("1.0E-4"));;

	public MbFclObjects() {
		userSessionId = SessionWrapper.getRequiredUserSessionId();
		curLang = SessionWrapper.getField("language");

		tiersBean = (MbFeeTiers) ManagedBeanWrapper.getManagedBean("MbFeeTiers");
		tiersBean.fullCleanBean();
		tiersBean.setFeeNeedsLengthType(feeNeedsLengthType);
		shiftsBean = (MbCycleShiftsSearch) ManagedBeanWrapper.getManagedBean("MbCycleShiftsSearch");
		shiftsBean.fullCleanBean();
	}

	/**
	 * Initialization from object (to view object and may be edit (to be
	 * implemented))
	 * 
	 * @param attrEntityType
	 * @param entityType
	 * @param attrValue
	 * @param scaleId
	 * @param instId
	 */
	public void initialize(String attrEntityType, String entityType, AttributeValue attrValue, Integer scaleId, Integer instId) {
		fullCleanBean();

		this.initialAttrValue = attrValue;
		this.attrValue = attrValue.copy();
		this.scaleId = scaleId;
		this.instId = instId;
		this.entityType = entityType;

		if (EntityNames.FEE.equals(attrEntityType)) {
			feeId = attrValue.getValueN().intValue();
			cyclicFee = true; // just let it be true
		} else if (EntityNames.LIMIT.equals(attrEntityType)) {
			limitId = attrValue.getValueN().longValue();
		} else if (EntityNames.CYCLE.equals(attrEntityType)) {
			cycleId = attrValue.getValueN().intValue();
		}

		try {
			if (feeId != null) {
				SelectionParams params = new SelectionParams();
				Filter[] filters = new Filter[1];
				filters[0] = new Filter();
				filters[0].setElement("id");
				filters[0].setValue(feeId.toString());

				params.setFilters(filters);
				fee = _feesDao.getFeeById(userSessionId, feeId);
				if (fee == null) {
					throw new Exception(FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Fcl",
							"fee_not_found", feeId));
				}
				feeType = fee.getFeeType();
				limitId = fee.getLimitId();
				cycleId = fee.getCycleId();
				if (cycleId == null) {
					cyclicFee = false;
				}
				tiersBean.fullCleanBean();
				tiersBean.setActiveFeeId(feeId);
				tiersBean.setFeeCurrency(fee.getCurrency());
				tiersBean.setFeeRateCalc(fee.getFeeRateCalc());
				tiersBean.setFeeNeedsLengthType(feeNeedsLengthType);
				initFeeFlexFields(feeId);
			}

			if (limitId != null) {
				SelectionParams params = new SelectionParams();
				Filter[] filters = new Filter[1];
				filters[0] = new Filter();
				filters[0].setElement("id");
				filters[0].setValue(limitId.toString());

				params.setFilters(filters);
				limit = _limitsDao.getLimitById(userSessionId, limitId);
				if (limit == null) {
					throw new Exception(FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Fcl",
							"limit_not_found", limitId));
				}
				prevCurrency = limit.getCurrency();
				prevAmount = limit.getSumBound();
				limitType = limit.getLimitType();
				cycleTypeForLimit = limit.getCycleType();
				if (fee == null || cycleId == null) {
					cyclicFee = false;
					cycleId = limit.getCycleId();
				}
				prepareLimitForInterface();
			}

			if (cycleId != null) {
				SelectionParams params = new SelectionParams();
				Filter[] filters = new Filter[1];
				filters[0] = new Filter();
				filters[0].setElement("id");
				filters[0].setValue(cycleId.toString());

				params.setFilters(filters);
				cycle = getCycleById(cycleId);
				if (cycle == null) {
					throw new Exception(FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Fcl",
							"cycle_not_found", cycleId));
				}
				cycleType = cycle.getCycleType();
				shiftsBean.fullCleanBean();
				shiftsBean.setCycleId(cycleId);
				shiftsBean.search();
			}
			attrValue.setCyclic(StringUtils.isNotEmpty(cycleType));
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	/**
	 * <p>
	 * Initialization from attribute (for new objects)
	 * </p>
	 * 
	 * @param entityType
	 * @param objectId
	 * @param attributeName
	 * @param scaleId
	 * @param attrObjectType
	 *            - exact fee type or limit type, or cycle type of primary
	 *            object
	 * @param instId
	 */
	public void initialize(String entityType, Long objectId, String attributeName, Integer scaleId,
							String attrObjectType, Integer instId, Integer serviceId) {
		fullCleanBean();

		attrValue = new AttributeValue();
		attrValue.setEntityType(entityType);
		attrValue.setObjectId(objectId);
		attrValue.setAttrName(attributeName);
		attrValue.setServiceId(serviceId);
		this.entityType = entityType;
		this.scaleId = scaleId;
		this.instId = instId;

		try {
			if (attrObjectType.startsWith(DictNames.FEE_TYPE)) {
				feeType = attrObjectType;
				feeMode = CREATE_VALUE;

				SelectionParams params = new SelectionParams();
				Filter[] filters = new Filter[1];
				filters[0] = new Filter();
				filters[0].setElement("feeType");
				filters[0].setValue(feeType);

				params.setFilters(filters);
				FeeType[] feeTypes = _feesDao.getFeeTypes(userSessionId, params);
				if (feeTypes == null || feeTypes.length == 0) {
					throw new Exception(FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Fcl",
							"fee_type_for_attr_not_found", feeType, attrValue.getAttrName()));
				}
				limitType = feeTypes[0].getLimitType();
				cycleType = feeTypes[0].getCycleType();

				if (feeType != null) {
					feeNeedsLengthType = _feesDao.isFeeTypeNeedLengthType(userSessionId, feeType);
					tiersBean.setFeeNeedsLengthType(feeNeedsLengthType);
				}

				if (cycleType == null) {
					cyclicFee = false;
				} else {
					if (getDictUtils().getAllArticles().get(cycleType) == null) {
						throw new Exception(FacesUtils
								.getMessage("ru.bpc.sv2.ui.bundles.Fcl",
										"cycle_type_for_attr_not_found", cycleType, attrValue
												.getAttrName()));
					}
					cyclicFee = true;
					cycleMode = CREATE_VALUE;
					createNewCycle();
				}
				if (limitType != null) {
					limitMode = CREATE_VALUE;
					filters[0].setElement("limitType");
					filters[0].setValue(limitType);
					LimitType[] limTypes = _limitsDao.getLimitTypes(userSessionId, params);
					if (limTypes == null || limTypes.length == 0) {
						throw new Exception(FacesUtils
								.getMessage("ru.bpc.sv2.ui.bundles.Fcl",
										"limit_type_for_attr_not_found", limitType, attrValue
												.getAttrName()));
					}
					cycleTypeForLimit = limTypes[0].getCycleType();
					if (cycleType == null && cycleTypeForLimit != null) {
						cycleType = cycleTypeForLimit;
						if (getDictUtils().getAllArticles().get(cycleType) == null) {
							throw new Exception(FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Fcl",
									"cycle_type_for_attr_not_found", cycleType, attrValue
											.getAttrName()));
						}
						cycleMode = CREATE_VALUE;
						createNewCycle();
					}
					createNewLimit();
				}
				createNewFee();
				initFeeFlexFields(null);
			} else if (attrObjectType.startsWith(DictNames.LIMIT_TYPES)) {
				limitType = attrObjectType;
				limitMode = CREATE_VALUE;

				SelectionParams params = new SelectionParams();
				Filter[] filters = new Filter[1];
				filters[0] = new Filter();
				filters[0].setElement("limitType");
				filters[0].setValue(limitType);

				params.setFilters(filters);
				LimitType[] limTypes = _limitsDao.getLimitTypes(userSessionId, params);
				if (limTypes == null || limTypes.length == 0) {
					throw new Exception(FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Fcl",
							"limit_type_for_attr_not_found", limitType, attrValue.getAttrName()));
				}
				cycleType = cycleTypeForLimit = limTypes[0].getCycleType();
				if (cycleType != null) {
					if (getDictUtils().getAllArticles().get(cycleType) == null) {
						throw new Exception(FacesUtils
								.getMessage("ru.bpc.sv2.ui.bundles.Fcl",
										"cycle_type_for_attr_not_found", cycleType, attrValue
												.getAttrName()));
					}
					cycleMode = CREATE_VALUE;
					createNewCycle();
				}
				createNewLimit();
			} else if (attrObjectType.startsWith(DictNames.CYCLE_TYPES)) {
				cycleMode = CREATE_VALUE;
				cycleType = attrObjectType;
				if (getDictUtils().getAllArticles().get(cycleType) == null) {
					throw new Exception(FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Fcl",
							"cycle_type_for_attr_not_found", cycleType, attrValue.getAttrName()));
				}
				createNewCycle();
			}
			attrValue.setCyclic(StringUtils.isNotEmpty(cycleType));
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void fullCleanBean() {
		feeType = null;
		limitType = null;
		cycleType = null;
		cycleTypeForLimit = null;

		feeMode = 0;
		cycleMode = 0;
		limitMode = 0;

		fee = null;
		cycle = null;
		limit = null;
		feeId = null;
		cycleId = null;
		limitId = null;

		feeFlexFields = null;

		initialAttrValue = null;
		attrValue = null;
		dataModel = null;

		tiersBean.fullCleanBean();
		tiersBean.setDisableAll(true);
		tiersBean.setDontSave(true);
		tiersBean.setFeeNeedsLengthType(feeNeedsLengthType);

		shiftsBean.fullCleanBean();
		shiftsBean.setDisableAll(true);
		shiftsBean.setDontSave(true);
	}

	/**
	 * FEES TAB
	 */

	public ArrayList<SelectItem> getFees() {
		if (feeType != null && feeMode != CREATE_VALUE) {
			SelectionParams params = new SelectionParams();
			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("feeType");
			filters[0].setValue(feeType);
			filters[1] = new Filter();
			filters[1].setElement("instId");
			filters[1].setValue(instId.toString());

			params.setFilters(filters);
			params.setRowIndexEnd(Integer.MAX_VALUE);
			
			SortElement[] sort = new SortElement[1];
			sort[0] = new SortElement("id", Direction.ASC);
			params.setSortElement(sort);

			try {
				Fee[] fees = _feesDao.getFees(userSessionId, params);
				ArrayList<SelectItem> items = new ArrayList<SelectItem>(fees.length);
				for (Fee fee: fees) {
					items.add(new SelectItem(fee.getId(), fee.getId() + " - " + fee.getDescription()));
				}
				return items;
			} catch (Exception e) {
				logger.error("", e);
				if (e.getMessage().indexOf(SystemConstants.INSUFFICIENT_PRIVILEGES_ERROR) < 0) {
					FacesUtils.addMessageError(e);
				}
			}
		}
		return new ArrayList<SelectItem>(0);
	}

	public ArrayList<SelectItem> getFeeBasesCalc() {
		if (feeBasisCalc == null) {
			feeBasisCalc  = getDictUtils().getArticles(DictNames.FEE_BASES_CALC, true, false);
		}
		return feeBasisCalc;
	}

	public ArrayList<SelectItem> getFeeRatesCalc() {
		if (feeRatesCalc == null) {
			feeRatesCalc = getDictUtils().getArticles(DictNames.FEE_RATES_CALC, true, false);
		}
		return feeRatesCalc;
	}

	public void changeFeeMode(ValueChangeEvent event) {
		int newMode = (Integer) event.getNewValue();

		if (newMode == CREATE_VALUE) {
			createNewFee();
			if (limitType != null) {
				createNewLimit();
				limitMode = CREATE_VALUE;
			}
			if (cycleType != null) {
				createNewCycle();
				cycleMode = CREATE_VALUE;
			}
		} else if (newMode == CLONE_VALUE) {
			tiersBean.setDisableAll(false);
			createNewFee();
			
			if (limitType != null) {
				limitMode = CLONE_VALUE;
			}
			if (cycleType != null) {
				cycleMode = CLONE_VALUE;
				shiftsBean.setDisableAll(false);
			}
		} else if (newMode == APPLY_VALUE) {
			createNewFee();
			if (feeMode == CLONE_VALUE && fee != null && fee.getId() != null) {
				// to be sure that we'll get original fee if user changes something in clone mode 
				initFee(fee.getId());
			}
			tiersBean.setDisableAll(true);
			if (limitType != null) {
				limitMode = APPLY_VALUE;
			}
			if (cycleType != null) {
				cycleMode = APPLY_VALUE;
				shiftsBean.setDisableAll(true);
			}
		}
	}

	private void createNewFee() {
		feeId = null;
		fee = new Fee();
		fee.setFeeType(feeType);
		fee.setCycleType(cycleType);
		fee.setLimitType(limitType);
		fee.setEntityType(entityType);
		fee.setInstId(instId);
		cleanTiers();
	}
	
	private void cleanTiers(){
		tiersBean.fullCleanBean();
		tiersBean.setActiveFeeId(-1); // just temporary id to unblock buttons
		tiersBean.setDisableAll(false);
	}

	public void changeFee(ValueChangeEvent event) {
		Integer newFeeId = (Integer) event.getNewValue();
		initFee(newFeeId);
	}

	private void initFee(Integer feeId) {
		try {
			fee = (Fee)getFeeById(feeId).clone();
		} catch (CloneNotSupportedException e) {
			try {
				fee = getFeeById(feeId);
			}catch (Exception e1){
				logger.error(e1.getMessage());
			}
		} catch (Exception e){
			logger.error(e.getMessage());
		}

		tiersBean.fullCleanBean();
		if (fee != null) {
			tiersBean.setActiveFeeId(feeId);
			tiersBean.setFeeRateCalc(fee.getFeeRateCalc());
			tiersBean.setFeeCurrency(fee.getCurrency());
			tiersBean.setFeeNeedsLengthType(feeNeedsLengthType);
			tiersBean.initStoredFeeTiers();  // to load fee tiers before isTiersAvailable() is called
			initFeeFlexFields(fee.getId());
			if (fee.getCycleId() != null) {
				getCycles();	// as we now hide cycle selector when setting complex fee we should call this method manually
				try {
					cycle = getCycleById(fee.getCycleId());
				}catch (Exception e){
					logger.error(e.getMessage());
				}
				cycleId = fee.getCycleId();
				shiftsBean.fullCleanBean();
				shiftsBean.setCycleId(cycleId);
				shiftsBean.search();
			} else {
				cycle = null;
				cycleId = null;
				shiftsBean.fullCleanBean();
				shiftsBean.setSearching(false);
			}
			if (fee.getLimitId() != null) {
				getLimits();	// as we now hide limit selector when setting complex fee we should call this method manually
//				limit = limitsMap.get(fee.getLimitId());
				try {
					limit = getLimitById(fee.getLimitId());
				}catch (Exception e){
					logger.error(e.getMessage());
				}
				limitId = fee.getLimitId();
				// load cycle for cyclic limit
				if (fee.getCycleId() == null && limit.getCycleId() != null) {
					getCycles();
					try {
						cycle = getCycleById(limit.getCycleId());
					}catch (Exception e){
						logger.error(e.getMessage());
					}
					cycleId = limit.getCycleId();
					shiftsBean.fullCleanBean();
					shiftsBean.setCycleId(cycleId);
					shiftsBean.search();
				}
			} else {
				limit = null;
				limitId = null;	
			}
		} else {
			initFeeFlexFields(null);
		}
	}

	public void changeFeeRateCalc(ValueChangeEvent event) {
		tiersBean.setFeeRateCalc((String) event.getNewValue());
	}

	private void initFeeFlexFields(Integer feeId) {
		Filter[] filters;
		filters = new Filter[4];

		filters[0] = new Filter();
		filters[0].setElement("entityType");
		filters[0].setValue(EntityNames.FEE);
		filters[1] = new Filter();
		filters[1].setElement("lang");
		filters[1].setValue(curLang);
		filters[2] = new Filter();
		filters[2].setElement("instId");
		filters[2].setValue(instId.toString());
		filters[3] = new Filter();
		filters[3].setElement("objectId");
		filters[3].setValue(feeId == null ? null : feeId.toString());

		SelectionParams params = new SelectionParams();
		params.setRowIndexEnd(Integer.MAX_VALUE);
		params.setFilters(filters);
		try {
			feeFlexFields = _commonDao.getFlexFieldsData(userSessionId, params);
			if (feeFlexFields == null || feeFlexFields.length == 0) {
				feeFlexFields = new FlexFieldData[1];
				feeFlexFields[0] = new FlexFieldData();
				emptyFlexFields = true;
			} else {
				emptyFlexFields = false;
			}
		} catch (Exception e) {
			logger.error("", e);
			FacesUtils.addMessageError(e);
		}
	}

	public FlexFieldData[] getFeeFlexFields() {
		return feeFlexFields;
	}

	public void setFeeFlexFields(FlexFieldData[] feeFlexFields) {
		this.feeFlexFields = feeFlexFields;
	}

	public List<SelectItem> getListValues() {
		FlexFieldData curField = (FlexFieldData) Faces.var("field");
		return (curField != null) ? getDictUtils().getLov(curField.getLovId()) : new ArrayList<SelectItem>(0);
	}

	public boolean isFixedValueFee() {
		return fee == null ? false : MbFeeTiers.FIXED_VALUE_FEE_RATE.equals(fee.getFeeRateCalc());
	}

	public void changeFeeCurrency() {
		tiersBean.setFeeCurrency(fee.getCurrency());
		if (limitType != null) {
			limit.setCurrency(fee.getCurrency());
		}
	}

	public boolean isTiersAvailable() {
		return tiersBean.getStoredFeeTiers() == null ? false : tiersBean.getStoredFeeTiers().size() > 0;
	}

	/**
	 * END FEES TAB
	 */

	/**
	 * LIMITS TAB
	 */

	public List<SelectItem> getPostMethods() {
		if (postingMethods == null) {
			postingMethods = getDictUtils().getLov(LovConstants.POSTING_METHODS);
		}
		return postingMethods;
	}
	
	public List<SelectItem> getLimitCheckTypes() {
		if (limitCheckTypes == null) {
			limitCheckTypes = getDictUtils().getLov(LovConstants.LIMIT_CHECK_TYPE);
		}
		return limitCheckTypes;
	}

	public ArrayList<SelectItem> getLimits() {
		if (limitType != null) {
			SelectionParams params = new SelectionParams();
			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("limitType");
			filters[0].setValue(limitType);
			filters[1] = new Filter();
			filters[1].setElement("instId");
			filters[1].setValue(instId.toString());

			params.setFilters(filters);
			params.setRowIndexEnd(Integer.MAX_VALUE);
			
			SortElement[] sort = new SortElement[1];
			sort[0] = new SortElement("id", Direction.ASC);
			params.setSortElement(sort);

			try {
				Limit[] limits = _limitsDao.getLimits(userSessionId, params);
				ArrayList<SelectItem> items = new ArrayList<SelectItem>(limits.length);
//				limitsMap = new HashMap<Long, Limit>(limits.length);
				for (Limit limit: limits) {
					items.add(new SelectItem(limit.getId(), limit.getId() + " - "
							+ limit.getDescription()));
//					limitsMap.put(limit.getId(), limit);
				}
				return items;
			} catch (Exception e) {
				logger.error("", e);
				if (e.getMessage().indexOf(SystemConstants.INSUFFICIENT_PRIVILEGES_ERROR) < 0) {
					FacesUtils.addMessageError(e);
				}
			}
		}
		return new ArrayList<SelectItem>(0);
	}

	public void changeLimit(ValueChangeEvent event) {
		Long newLimitId = (Long) event.getNewValue();
		initLimit(newLimitId);
	}

	private Limit getLimitById(Long limitId) throws Exception{
		try {
			SelectionParams params = new SelectionParams();
			Filter[] filters = new Filter[1];
			filters[0] = new Filter("id", limitId);
			params.setFilters(filters);
			params.setRowIndexEnd(Integer.MAX_VALUE);
			Limit[] limits = _limitsDao.getLimits(userSessionId, params);
			if (limits.length > 0) {
				return limits[0];
			}
		} catch (Exception e) {
			logger.error("", e);
			if (e.getMessage().contains("PRIVILEGES")){
				FacesUtils.addMessageError(e.getMessage());
				throw e;
			}
		}
		return null;
	}
	
	private Cycle getCycleById(Integer cycleId) throws Exception{
		try {
			return _cyclesDao.getCycleById(userSessionId, cycleId);
		} catch (Exception e) {
			logger.error("", e);
			if (e.getMessage().contains("PRIVILEGES")){
				FacesUtils.addMessageError(e.getMessage());
				throw e;
			}
		}
		return null;
	}
	
	private Fee getFeeById(Integer feeId) throws Exception {
		try {
			return fee = _feesDao.getFeeById(userSessionId, feeId);
		} catch (Exception e) {
			logger.error("", e);
			if (e.getMessage().contains("PRIVILEGES")){
				FacesUtils.addMessageError(e.getMessage());
				throw e;
			}
		}
		return null;
	}
	
	private void initLimit(Long limitId) {
		try {
			limit = (Limit) getLimitById(limitId).clone();
		} catch (CloneNotSupportedException e) {
			try {
				limit = (Limit) getLimitById(limitId);
			}catch (Exception e1){
				logger.error(e1.getMessage());
			}
		} catch (Exception e){
			logger.error(e.getMessage());
		}
		prepareLimitForInterface();
		// change limit when fee is not available. When fee is available
		// only changing fee will affect cycle.
		if (cycleType != null && feeType == null) {
			if (limit != null && limit.getCycleId() != null) {
				getCycles();	// as we now hide cycle selector when setting complex limit we should call this method manually
				try {
					cycle = getCycleById(limit.getCycleId());
				}catch (Exception e){
					logger.error(e.getMessage());
				}
				cycleId = limit.getCycleId();
				shiftsBean.fullCleanBean();
				shiftsBean.setCycleId(cycleId);
				shiftsBean.search();
			} else {
				cycle = null;
				cycleId = null;
				shiftsBean.fullCleanBean();
				shiftsBean.setSearching(false);
			}
		}
	}

	public void changeLimitMode(ValueChangeEvent event) {
		int newMode = (Integer) event.getNewValue();
		if (newMode == CREATE_VALUE) {
			createNewLimit();
			if (cycleType != null) {
				createNewCycle();
				cycleMode = CREATE_VALUE;
			}
		} else if (newMode == CLONE_VALUE) {
			if (cycleType != null) {
				cycleMode = CLONE_VALUE;
			}
		} else if (newMode == APPLY_VALUE) {
			if (limitMode == CLONE_VALUE && limit != null && limit.getId() != null) {
				// to be sure that we'll get original limit if user changes something in clone mode 
				initLimit(limit.getId());
			}
			if (cycleType != null) {
				cycleMode = APPLY_VALUE;
				shiftsBean.setDisableAll(true);
			}
		}
	}

	/**
	 * END LIMITS TAB
	 */

	private void createNewLimit() {
		limitId = null;
		limit = new Limit();
		limit.setLimitType(limitType);
		limit.setEntityType(entityType);
		limit.setCycleType(cycleTypeForLimit);
		limit.setInstId(instId);
		limit.setCountLimit(null);
		limit.setSumLimit(null);
		limit.setLimitRate(new BigDecimal(0.0));
	}

	/**
	 * CYCLES TAB
	 */

	public ArrayList<SelectItem> getCycles() {
		if (cycleType != null) {
			SelectionParams params = new SelectionParams();
			Filter[] filters = new Filter[3];
			filters[0] = new Filter();
			filters[0].setElement("cycleType");
			filters[0].setValue(cycleType);
			filters[1] = new Filter();
			filters[1].setElement("lang");
			filters[1].setValue(curLang);
			filters[2] = new Filter();
			filters[2].setElement("instId");
			filters[2].setValue(instId.toString());

			params.setFilters(filters);
			params.setRowIndexEnd(Integer.MAX_VALUE);
			
			SortElement[] sort = new SortElement[1];
			sort[0] = new SortElement("id", Direction.ASC);
			params.setSortElement(sort);

			try {
				Cycle[] cycles = _cyclesDao.getCycles(userSessionId, params);
				ArrayList<SelectItem> items = new ArrayList<SelectItem>(cycles.length);
				for (Cycle cycle: cycles) {
					items.add(new SelectItem(cycle.getId(), cycle.getId() + " - "
							+ cycle.getDescription()));
				}
				return items;
			} catch (Exception e) {
				logger.error("", e);
				if (e.getMessage().indexOf(SystemConstants.INSUFFICIENT_PRIVILEGES_ERROR) < 0) {
					FacesUtils.addMessageError(e);
				}
			}
		}
		return new ArrayList<SelectItem>(0);
	}

	public List<SelectItem> getTruncTypes() {
		if (truncTypes == null) {
			truncTypes = getDictUtils().getLov(LovConstants.PERIOD_TYPES);
		}
		return truncTypes;
	}

	public void changeCycle(ValueChangeEvent event) {
		Integer newCycleId = (Integer) event.getNewValue();

		initCycle(newCycleId);
	}

	private void initCycle(Integer cycleId) {
		if (cycleId != null) {
			try {
				cycle = getCycleById(cycleId).clone();
			} catch (CloneNotSupportedException e) {
				try {
					cycle = getCycleById(cycleId);
				}	catch (Exception e1){
					logger.error(e1.getMessage());
				}
			} catch (Exception e){
				logger.error(e.getMessage());
			}
			shiftsBean.fullCleanBean();
			shiftsBean.setCycleId(cycleId);
			shiftsBean.search();
		} else {
			cycle = null;
			shiftsBean.fullCleanBean();
			shiftsBean.setSearching(false);
		}
	}

	public void changeCycleMode(ValueChangeEvent event) {
		int newMode = (Integer) event.getNewValue();

		if (newMode == CREATE_VALUE) {
			createNewCycle();
		} else if (newMode == CLONE_VALUE) {
			shiftsBean.setDisableAll(false);
		} else if (newMode == APPLY_VALUE) {
			if (cycleMode == CLONE_VALUE && cycle != null && cycle.getId() != null) {
				// to be sure that we'll get original cycle if user changes something in clone mode 
				initCycle(cycle.getId());
			}
			shiftsBean.setDisableAll(true);
		}
	}

	private void createNewCycle() {
		cycleId = null;
		shiftsBean.setSearching(true);
		cycle = new Cycle();
		cycle.setCycleType(cycleType);
		cycle.setInstId(instId);
		shiftsBean.fullCleanBean();
		shiftsBean.setCycleId(-1); // just temporary id to unblock buttons
		shiftsBean.setDisableAll(false);
	}

	/**
	 * END CYCLES TAB
	 */

	public List<SelectItem> getLengthTypes() {
		if (lengthTypes == null) {
			lengthTypes = getDictUtils().getLov(LovConstants.PERIOD_TYPES);
		}
		return lengthTypes;
	}

	public ArrayList<SelectItem> getModifiers() {
		ArrayList<SelectItem> items;
		if (scaleId != null) {
			try {
				Modifier[] mods = _rulesDao.getModifiers(userSessionId, scaleId);
				items = new ArrayList<SelectItem>();
				for (Modifier mod: mods) {
					items.add(new SelectItem(mod.getId(), mod.getName()));
				}
			} catch (Exception e) {
				logger.error("", e);
				if (e.getMessage().indexOf(SystemConstants.INSUFFICIENT_PRIVILEGES_ERROR) < 0) {
					FacesUtils.addMessageError(e);
				}
				return new ArrayList<SelectItem>(0);
			}
		} else {
			return new ArrayList<SelectItem>(0);
		}
		return items;
	}

	public void save() {
		prepareLimitToStore();
		if (!checkDate()) {
			return;
		}

		preprocessCampaign();

		// editing inherited values is prohibited
		if (isInheritedValue) {
			Exception e = new Exception(FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Msg",
					"inh_edit_proh"));
			logger.error("", e);
			FacesUtils.addMessageError(e);
			return;
		}

		if (isEditMode()) {
			try {
				if (feeType != null) {
					_productsDao.setAttrValueFee(userSessionId, attrValue, fee, null, null, null,
							null, null, emptyFlexFields ? null : feeFlexFields);
				} else if (limitType != null) {
					_productsDao.setAttrValueLimit(userSessionId, attrValue, limit, null, null);
				} else if (cycleType != null) {
					_productsDao.setAttrValueCycle(userSessionId, attrValue, cycle, null);
				}
			} catch (Exception e) {
				logger.error(e.getMessage(), e);
				FacesUtils.addMessageError(e);
				return;
			}
		} else {
			if (!checkForm()) {
				return;
			}

			// When cloning new objects are created (unlike when applying)
			if (feeMode == CLONE_VALUE) {
				fee.setId(null);
			}
			if (limitMode == CLONE_VALUE) {
				limit.setId(null);
			}
			if (cycleMode == CLONE_VALUE) {
				cycle.setId(null);
			}

			ArrayList<FeeTier> tiers = null; // tiers to save
			List<FeeTier> originalTiers = null; // original tiers, keep them in
			// case of errors
			if (feeType != null && (feeMode == CREATE_VALUE || feeMode == CLONE_VALUE)) {
				originalTiers = tiersBean.getStoredFeeTiers();
				if (originalTiers == null || originalTiers.size() == 0) {
					Exception e = new Exception(FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Msg",
							"tiers_needed"));
					logger.error("", e);
					FacesUtils.addMessageError(e);
					return;
				}
				tiers = new ArrayList<FeeTier>(originalTiers.size());
				for (FeeTier tier: originalTiers) {
					FeeTier tmp = tiersBean.correctTier(tier);
					if (tmp == null) {
						Exception e = new Exception(FacesUtils.getMessage(
								"ru.bpc.sv2.ui.bundles.Fcl", "incorrect_tier"));
						logger.error("", e);
						FacesUtils.addMessageError(e);
						return;
					} else {
						if (tmp.getCountThreshold() == 0 && tmp.getSumThreshold().doubleValue() == 0.0) {
							tiers.add(0, tmp);
						} else {
							tiers.add(tmp);
						}
					}
				}
				if (MbFeeTiers.FIXED_VALUE_FEE_RATE.equals(fee.getFeeRateCalc()) && fee.getFeeBaseCalc() == null) {
					// "Incoming amount" set as default when "Fixed value" is
					// selected as fee rate calculation method and fee base is not set
					fee.setFeeBaseCalc("FEEB0001");
				}
			}

			ArrayList<CycleShift> shifts = null;
			Cycle cycleForLimit = null;
			if (cycleType != null && (cycleMode == CREATE_VALUE || cycleMode == CLONE_VALUE)) {
				shifts = shiftsBean.getStoredCycleShifts();
			}

			// If we create new cyclic limit to create new cyclic fee we
			// should copy cycle to create two of them: one is for fee,
			// another is for limit - as their cycle types are different.
			// This is also true when we use existing limit but create
			// new cycle or even when we use both existing limit
			// and existing cycle: old cycle that is binded to limit is
			// replaced by new one that is copied from cycle for fee.
			if (cycleTypeForLimit != null && feeType != null
					&& (feeMode == CREATE_VALUE || feeMode == CLONE_VALUE)) {
				cycleForLimit = cycle.copy();
				cycleForLimit.setCycleType(cycleTypeForLimit);
				cycleForLimit.setId(null); // cycle for limit is always created new
				if (!cyclicFee) {
					cycle = null;
				}
			}

			try {
				// if fee object is created
				if (feeType != null) {
					_productsDao.setAttrValueFee(userSessionId, attrValue, fee, tiers, limit,
							cycle, cycleForLimit, shifts, emptyFlexFields ? null : feeFlexFields);
				}
				// if limit object is created (fee is omitted)
				else if (limitType != null) {
					_productsDao.setAttrValueLimit(userSessionId, attrValue, limit, cycle, shifts);
				}
				// if cycle object is created (fee and limit are omitted)
				// TODO: do we need this?
				else if (cycleType != null) {
					_productsDao.setAttrValueCycle(userSessionId, attrValue, cycle, shifts);
				}

			} catch (Exception e) {
				logger.error(e.getMessage(), e);
				FacesUtils.addMessageError(e);

				// if something unexpected happened when saving fee with cyclic
				// limit
				// it's important to set cycle back to its previous value to
				// avoid
				// errors if user attempts to save it again.
				if (cycle == null && cycleForLimit != null) {
					cycle = cycleForLimit;
				}
				return;
			}
		}

		if (dataModel != null) {
			dataModel.flushCache();
		}
	}

	public boolean checkDate() {
		CommonUtils common = (CommonUtils) ManagedBeanWrapper.getManagedBean("CommonUtils");
		Calendar now = Calendar.getInstance(common.getTimeZone());
		boolean success = true;

		Calendar startDate = null;
		if (attrValue.getStartDate() == null) {
			startDate = Calendar.getInstance(common.getTimeZone());
		} else {
			startDate = Calendar.getInstance(common.getTimeZone());
			startDate.setTime(attrValue.getStartDate());
		}

		Calendar endDate = null;
		if (attrValue.getEndDate() != null) {
			endDate = Calendar.getInstance(common.getTimeZone());
			endDate.setTime(attrValue.getEndDate());
		}

		Calendar initialStartDate = null;
		if (isEditMode() && initialAttrValue != null && initialAttrValue.getStartDate() != null) {
			initialStartDate = Calendar.getInstance(common.getTimeZone());
			initialStartDate.setTime(initialAttrValue.getStartDate());
		}

		Calendar initialEndDate = null;
		if (isEditMode() && initialAttrValue != null && initialAttrValue.getEndDate() != null) {
			initialEndDate = Calendar.getInstance(common.getTimeZone());
			initialEndDate.setTime(initialAttrValue.getEndDate());
			if (initialEndDate != null && initialEndDate.before(now)) {
				FacesUtils.addMessageError(new Exception(FacesUtils.getMessage(
						"ru.bpc.sv2.ui.bundles.Msg", "eff_period_ended")));
				return false;
			}
		}

		if ((isNewMode() || (isEditMode() && initialStartDate != null && initialStartDate.after(now))) && startDate.before(now)) {
			FacesUtils.addMessageError(new Exception(FacesUtils.getMessage(
					"ru.bpc.sv2.ui.bundles.Msg", "start_date_passed")));
			success = false;
		}

		if (endDate != null && endDate.before(now)) {
			FacesUtils.addMessageError(new Exception(FacesUtils.getMessage(
					"ru.bpc.sv2.ui.bundles.Msg", "end_date_passed")));
			success = false;
		}

		if (endDate != null && startDate.after(endDate)) {
			FacesUtils.addMessageError(new Exception(FacesUtils.getMessage(
					"ru.bpc.sv2.ui.bundles.Msg", "start_date_after_end_date")));
			success = false;
		}

		return success;
	}

	public void preprocessCampaign() {
		attrValue.setCampaignId(campaignId);

		if (campaignId != null) {
			SelectionParams params = SelectionParams.build("lang", curLang, "id", campaignId);
			List<Campaign> campaigns = _campaignDao.getCampaigns(userSessionId, params);
			if (campaigns != null && !campaigns.isEmpty()) {
				if (attrValue.getStartDate() == null) {
					attrValue.setStartDate(campaigns.get(0).getStartDate());
				} else if (attrValue.getStartDate().compareTo(campaigns.get(0).getStartDate()) < 0) {
					attrValue.setStartDate(campaigns.get(0).getStartDate());
				}

				if (attrValue.getEndDate() == null) {
					attrValue.setEndDate(campaigns.get(0).getEndDate());
				} else if (attrValue.getEndDate().compareTo(campaigns.get(0).getEndDate()) > 0) {
					attrValue.setEndDate(campaigns.get(0).getEndDate());
				}
			}
		}
	}

	public boolean checkForm() {
		boolean result = true;

		if (feeType != null) {
			if (feeMode == APPLY_VALUE && feeId == null) {
				FacesUtils.addMessageError(new Exception(FacesUtils.getMessage(
						"ru.bpc.sv2.ui.bundles.Fcl", "select_fee")));
				result = false;
			} else if (feeMode == CREATE_VALUE || feeMode == CLONE_VALUE) {
				if (fee.getCurrency() == null || fee.getFeeRateCalc() == null
						|| fee.getFeeRateCalc() == null) {
					FacesUtils.addMessageError(new Exception(FacesUtils.getMessage(
							"ru.bpc.sv2.ui.bundles.Fcl", "check_fee_form")));
					result = false;
				}
			}

		}

		if (limitType != null) {
			if (limitMode == APPLY_VALUE && limitId == null) {
				FacesUtils.addMessageError(new Exception(FacesUtils.getMessage(
						"ru.bpc.sv2.ui.bundles.Fcl", "select_limit")));
				result = false;
			} else if (limitMode == CREATE_VALUE || limitMode == CLONE_VALUE) {
				if (limit.getCountLimit() == null || limit.getSumLimit() == null
						|| (!limit.getSumLimit().equals(new BigDecimal(-1)) && limit.getCurrency() == null)) {
					FacesUtils.addMessageError(new Exception(FacesUtils.getMessage(
							"ru.bpc.sv2.ui.bundles.Fcl", "check_limit_form")));
					result = false;
				}
			}
		}

		if (cycleType != null) {
			if (cycleMode == APPLY_VALUE && cycleId == null) {
				FacesUtils.addMessageError(new Exception(FacesUtils.getMessage(
						"ru.bpc.sv2.ui.bundles.Fcl", "select_cycle")));
				result = false;
			} else if (cycleMode == CREATE_VALUE || cycleMode == CLONE_VALUE) {
				if (cycle.getCycleLength() == null || cycle.getCycleType() == null) {
					FacesUtils.addMessageError(new Exception(FacesUtils.getMessage(
							"ru.bpc.sv2.ui.bundles.Fcl", "check_cycle_form")));
					result = false;
				}
			}
		}

		return result;
	}

	public void cancel() {

	}

	public Fee getFee() {
		if (fee == null){
			createNewFee();
		}
		return fee;
	}

	public void setFee(Fee fee) {
		this.fee = fee;
	}

	public Cycle getCycle() {
		if (cycle == null){
			createNewCycle();
		}
		return cycle;
	}

	public void setCycle(Cycle cycle) {
		this.cycle = cycle;
	}

	public Limit getLimit() {
		if (limit == null){
			createNewLimit();
		}
		return limit;
	}

	public void setLimit(Limit limit) {
		this.limit = limit;
	}

	public Integer getFeeId() {
		return feeId;
	}

	public void setFeeId(Integer feeId) {
		this.feeId = feeId;
	}

	public Long getLimitId() {
		return limitId;
	}

	public void setLimitId(Long limitId) {
		this.limitId = limitId;
	}

	public Integer getCycleId() {
		return cycleId;
	}

	public void setCycleId(Integer cycleId) {
		this.cycleId = cycleId;
	}

	public Integer getInstId() {
		return instId;
	}

	public void setInstId(Integer instId) {
		this.instId = instId;
	}

	public String getEntityType() {
		return entityType;
	}

	public void setEntityType(String entityType) {
		this.entityType = entityType;
	}

	public Integer getScaleId() {
		return scaleId;
	}

	public void setScaleId(Integer scaleId) {
		this.scaleId = scaleId;
	}

	public String getFeeType() {
		return feeType;
	}

	public void setFeeType(String feeType) {
		this.feeType = feeType;
	}

	public String getCycleType() {
		return cycleType;
	}

	public void setCycleType(String cycleType) {
		this.cycleType = cycleType;
	}

	public String getLimitType() {
		return limitType;
	}

	public void setLimitType(String limitType) {
		this.limitType = limitType;
	}

	public int getFeeMode() {
		return feeMode;
	}

	public void setFeeMode(int feeMode) {
		this.feeMode = feeMode;
	}

	public int getCycleMode() {
		return cycleMode;
	}

	public void setCycleMode(int cycleMode) {
		this.cycleMode = cycleMode;
	}

	public int getLimitMode() {
		return limitMode;
	}

	public void setLimitMode(int limitMode) {
		this.limitMode = limitMode;
	}

	public AttributeValue getAttrValue() {
		return attrValue;
	}

	public void setAttrValue(AttributeValue attrValue) {
		this.attrValue = attrValue;
	}

	public DaoDataModel<?> getDataModel() {
		return dataModel;
	}

	public void setDataModel(DaoDataModel<?> dataModel) {
		this.dataModel = dataModel;
	}

	/**
	 * <p>
	 * If fee type is defined then limit depends on selected fee. Dependency can
	 * be broken only if we're creating new fee.
	 * </p>
	 * 
	 * @return whether block controls on limit tab or not
	 */
	public boolean isBlockLimit() {
		return feeType != null && feeMode == APPLY_VALUE;
	}

	/**
	 * <p>
	 * If either fee type or limit type is defined then cycle depends on fee or
	 * limit correspondingly. Dependency can be broken only if we're creating
	 * either new fee (if fee type is defined) or new limit (if fee type is not
	 * defined and limit type is).
	 * </p>
	 * 
	 * @return whether block controls on cycle tab or not
	 */
	public boolean isBlockCycle() {
		return (feeType != null && feeMode == APPLY_VALUE)
				|| (feeType == null && limitType != null && limitMode == APPLY_VALUE);
	}

	public boolean isViewMode() {
		return curMode == VIEW_MODE;
	}

	public boolean isEditMode() {
		return curMode == EDIT_MODE;
	}

	public boolean isNewMode() {
		return curMode == NEW_MODE;
	}

	public void setCurMode(int mode) {
		curMode = mode;
	}

	public boolean isInheritedValue() {
		return isInheritedValue;
	}

	public void setInheritedValue(boolean isInheritedValue) {
		this.isInheritedValue = isInheritedValue;
	}

	public int getCreateValue() {
		return CREATE_VALUE;
	}

	public int getCloneValue() {
		return CLONE_VALUE;
	}

	public int getApplyValue() {
		return APPLY_VALUE;
	}

	public Integer getServiceId() {
		return serviceId;
	}

	public void setServiceId(Integer serviceId) {
		this.serviceId = serviceId;
	}

	public Long getCampaignId() {
		return campaignId;
	}

	public void setCampaignId(Long campaignId) {
		this.campaignId = campaignId;
	}

	public boolean isPeriodStarted() {
		if (!isEditMode()) return false;
		
		CommonUtils common = (CommonUtils) ManagedBeanWrapper.getManagedBean("CommonUtils");
//		Calendar tmp = Calendar.getInstance(common.getTimeZone());
		Calendar today = Calendar.getInstance(common.getTimeZone());
		/**
		 * time matters
		 */
//		today.clear();
//		today.set(tmp.get(Calendar.YEAR), tmp.get(Calendar.MONTH), tmp.get(Calendar.DATE));

		Calendar startDate = Calendar.getInstance(common.getTimeZone());
		startDate.setTime(initialAttrValue.getStartDate());
		
		return startDate.compareTo(today) < 0;
	}
	
	public List<SelectItem> getLimitBases(){
		List<SelectItem> result;
		if (productType != null){
			Map<String, Object> paramMap = new HashMap<String, Object>();
			paramMap.put("PRODUCT_TYPE", productType);
			result = getDictUtils().getLov(LovConstants.DEPENDEND_LIMIT_BASES, paramMap);
		} else {
			result = new ArrayList<SelectItem>(0); 
		}
		return result;
	}

	
	public String getProductType() {
		return productType;
	}

	public void setProductType(String productType) {
		this.productType = productType;
	}
	
	private void prepareLimitForInterface(){
		if (limit != null) {
			if (limit.getCountLimit() == -1){
				limit.setCountLimit(null);
			}
			if (limit.getSumLimit().equals(new BigDecimal(-1))){
				limit.setSumLimit(null);
			}

			if (limit.getCountBound() != null && limit.getCountBound().equals(-1l)) {
				limit.setCountBound(null);
			}
			if (limit.getSumBound() != null && limit.getSumBound().equals(new BigDecimal(-1))) {
				limit.setSumBound(null);
			}
		}
	}
	
	private void prepareLimitToStore(){
		if (limit != null) {
			if (limit.getCountLimit() == null) {
				limit.setCountLimit(-1l);
			}
			if (limit.getSumLimit() == null) {
				limit.setSumLimit(new BigDecimal(-1));
			}
			if (limit.getCountBound() == null) {
				limit.setCountBound(-1l);
			}
			if (limit.getSumBound() == null) {
				limit.setSumBound(new BigDecimal(-1));
			}
		}
	}

	public DictUtils getDictUtils() {
		if (dictUtils == null) {
			dictUtils = (DictUtils) ManagedBeanWrapper.getManagedBean("DictUtils");
		}
		return dictUtils;
	}

	public List<SelectItem> getLimitCounterAlgorithms() {
		if (limitCounterAlgorithms == null){
			limitCounterAlgorithms = (ArrayList<SelectItem>)getDictUtils().getLov(LovConstants.COUNTER_ALGORITHM);
		}
		return limitCounterAlgorithms;
	}

	public void setLimitCounterAlgorithms(List<SelectItem> limitCounterAlgorithms) {
		this.limitCounterAlgorithms = limitCounterAlgorithms;
	}

	public void validateBigDecimal(FacesContext context, UIComponent toValidate, Object value) {
		try {
			BigDecimal newValue = (BigDecimal) value;

			// as we get converted value before validating it we should convert it back
			Number exponent = null;
			try {
				exponent = (Number) toValidate.getAttributes().get("exponent");
			} catch (NumberFormatException ignored) {
			}
			if (exponent == null || exponent.intValue() < 0) {
				exponent = 2;
			}
			newValue = newValue.divide(BigDecimal.valueOf(Math.pow(10, exponent.intValue())));

			// checks if new value less then maximum allowed value
			if (maxNumber.compareTo(newValue) == -1 || (new BigDecimal(0.0)).compareTo(newValue) == 1) {
				((HtmlInputText) toValidate).setValid(false);

				// String label = ((HtmlInputText) toValidate).getLabel() != null ?
				// ((HtmlInputText) toValidate).getLabel() : ((HtmlInputText)
				// toValidate).getId();
				String msg = FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Msg",
						"value_mustbe_in_range", 0, maxNumber.toString());
				FacesMessage message = new FacesMessage(FacesMessage.SEVERITY_ERROR, msg, msg);
				context.addMessage(toValidate.getClientId(context), message);
				return;
			}

			final int maxFractionDigits = 4;

			try {
				newValue.setScale(maxFractionDigits);
			} catch (ArithmeticException e) {
				((HtmlInputText) toValidate).setValid(false);

				String msg = FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Msg",
						"max_fract_digits_exceed", maxFractionDigits);
				FacesMessage message = new FacesMessage(FacesMessage.SEVERITY_ERROR, msg, msg);
				context.addMessage(toValidate.getClientId(context), message);
			}
		} catch (Exception e) {
			logger.error("", e);
			FacesUtils.addMessageError(e);
		}
	}

	public boolean isDisabled(String component) {
		return isDisabled(component, null);
	}
	public boolean isDisabled(String component, Boolean enableBoundsEdit) {
		if (!isNewMode() || limitMode == getApplyValue()) {
			return true;
		} else if (!CURRENCY.equalsIgnoreCase(component)) {
			if (limit == null || limit.getLimitBase() != null) {
				return true;
			} else if (BOUND.equalsIgnoreCase(component)) {
				if (!EntityNames.PRODUCT.equals(entityType) || Boolean.FALSE.equals(enableBoundsEdit)) {
					return true;
				}
			}
		}
		return false;
	}

	public boolean isCleanupRendered(String component) {
		return isCleanupRendered(component, null);
	}
	public boolean isCleanupRendered(String component, Boolean enableBoundsEdit) {
		if (isNewMode() && limitMode != getApplyValue() && limit != null && limit.getLimitBase() == null) {
			if (BOUND.equalsIgnoreCase(component)) {
				if (EntityNames.PRODUCT.equals(entityType) && Boolean.TRUE.equals(enableBoundsEdit)) {
					return true;
				}
			} else {
				return true;
			}
		}
		return false;
	}

	public boolean isRendered() {
		validate(COUNT);
		validate(SUM);
		return true;
	}

	public void changeLimitCurrency() {
		if (feeType != null) {
			fee.setCurrency(limit.getCurrency());
		}
		if (limit.getSumBound() != null && limit.getSumBound().compareTo(BigDecimal.valueOf(-1)) > 0) {
			if (limit.getCurrency() != null && prevCurrency != null && limit.getBoundCurrency() != null) {
				try {
					List<Filter> filters = new ArrayList<Filter>(2);
					SelectionParams params = new SelectionParams();
					filters.add(Filter.create("lang", curLang));
					filters.add(Filter.create("limitType", limit.getLimitType()));
					filters.add(Filter.create("instId", instId));
					params.setFilters(Filter.asArray(filters));
					LimitRate[] rates = _limitsDao.getLimitRates(userSessionId, params);
					if (rates != null && rates.length > 0) {
						Map<String, Object> map = new HashMap<String, Object>();
						map.put("dstCurr", limit.getCurrency());
						map.put("rateType", rates[0].getRateType());
						map.put("instId", limit.getInstId());
						map.put("effDate", new Date());

						map.put("srcCurr", prevCurrency);
						map.put("srcAmount", prevAmount);
						limit.setSumBound(_limitsDao.convertAmount(userSessionId, map));
						map.put("srcCurr", limit.getBoundCurrency());
						map.put("srcAmount", limit.getSumLimit());
						limit.setSumLimit(_limitsDao.convertAmount(userSessionId, map));

						limit.setBoundCurrency(limit.getCurrency());
					} else {
						throw new UserException("The appropriate service term's currency rate isn't found");
					}
				} catch (Exception e) {
					logger.debug("", e);
					FacesUtils.addMessageError(e);
				}
			}
		}
		prevCurrency = limit.getCurrency();
		prevAmount = limit.getSumBound();
		validate(SUM);
	}

	public void validate(String component) {
		if (limit != null) {
			if (COUNT.equals(component)) {
				if (limit.getCountBound() != null && limit.getCountBound() > -1) {
					if (limit.getCountLimit() == null || limit.getCountLimit() > limit.getCountBound()) {
						limit.setCountLimit(limit.getCountBound());
					}
				}
			} else if (SUM.equals(component)) {
				if (limit.getSumBound() != null && limit.getSumBound().compareTo(BigDecimal.valueOf(-1)) > 0) {
					if (limit.getSumLimit() == null || limit.getSumLimit().compareTo(limit.getSumBound()) > 0) {
						limit.setSumLimit(limit.getSumBound());
					}
				}
			}
		}
	}
}
