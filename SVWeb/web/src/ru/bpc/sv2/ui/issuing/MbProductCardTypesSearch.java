package ru.bpc.sv2.ui.issuing;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;


import ru.bpc.sv2.logic.utility.db.DataAccessException;
import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.event.ValueChangeEvent;
import javax.faces.model.SelectItem;

import org.apache.commons.lang3.StringUtils;
import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;

import ru.bpc.sv2.constants.DictNames;
import ru.bpc.sv2.constants.EntityNames;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.constants.SystemConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.Filter.Operator;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.issuing.ProductCardType;
import ru.bpc.sv2.issuing.personalization.BlankType;
import ru.bpc.sv2.issuing.personalization.PrsMethod;
import ru.bpc.sv2.logic.*;
import ru.bpc.sv2.net.CardType;
import ru.bpc.sv2.products.Contract;
import ru.bpc.sv2.products.ProductConstants;
import ru.bpc.sv2.rules.naming.NameFormat;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.TableRowSelection;

@ViewScoped
@ManagedBean (name = "MbProductCardTypesSearch")
public class MbProductCardTypesSearch extends AbstractBean {
	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;

	private static final Logger logger = Logger.getLogger("ISSUING");

	private IssuingDao _issuingDao = new IssuingDao();

	private PersonalizationDao _personalizationDao = new PersonalizationDao();

	private RulesDao _rulesDao = new RulesDao();

	private ProductsDao _productsDao = new ProductsDao();

	private NetworkDao _networkDao = new NetworkDao();

	private ProductCardType filter;
	private ProductCardType _activeProductCardType;
	private ProductCardType newProductCardType;

	private ArrayList<SelectItem> numberFormats;
	private ArrayList<SelectItem> methods;

	private final DaoDataModel<ProductCardType> _productCardTypesSource;

	private final TableRowSelection<ProductCardType> _itemSelection;

	private Integer instId;

	private String panLengthErrorBin;
	private String panLengthErrorFormat;
	private List<SelectItem> cachedApplications;
	private List<SelectItem> cardTypesItems;
	private List<SelectItem> reissBins;
	private List<SelectItem> reissCardTypes;

	private CardType[] cardTypes = null;

	
	private static String COMPONENT_ID = "mainTable";
	private String tabName;
	private String parentSectionId;
	
	private static final String HIER_LEVEL_PREFIX = " -- ";
	
	public MbProductCardTypesSearch() {
		_productCardTypesSource = new DaoDataModel<ProductCardType>() {
			private static final long serialVersionUID = 1L;

			@Override
			protected ProductCardType[] loadDaoData(SelectionParams params) {
				if (!searching) {
					return new ProductCardType[0];
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _issuingDao.getProductCardTypes(userSessionId, params);
				} catch (Exception e) {
					setDataSize(0);
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return new ProductCardType[0];
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (!searching) {
					return 0;
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _issuingDao.getProductCardTypesCount(userSessionId, params);
				} catch (Exception e) {
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return 0;
			}
		};

		_itemSelection = new TableRowSelection<ProductCardType>(null, _productCardTypesSource);
	}

	public DaoDataModel<ProductCardType> getProductCardTypes() {
		return _productCardTypesSource;
	}

	public ProductCardType getActiveProductCardType() {
		return _activeProductCardType;
	}

	public void setActiveProductCardType(ProductCardType activeProductCardType) {
		_activeProductCardType = activeProductCardType;
	}

	public SimpleSelection getItemSelection() {
		if (_activeProductCardType == null && _productCardTypesSource.getRowCount() > 0) {
			setFirstRowActive();
		} else if (_activeProductCardType != null && _productCardTypesSource.getRowCount() > 0) {
			SimpleSelection selection = new SimpleSelection();
			selection.addKey(_activeProductCardType.getModelId());
			_itemSelection.setWrappedSelection(selection);
			_activeProductCardType = _itemSelection.getSingleSelection();
		}
		return _itemSelection.getWrappedSelection();
	}

	public void setFirstRowActive() {
		_productCardTypesSource.setRowIndex(0);
		SimpleSelection selection = new SimpleSelection();
		_activeProductCardType = (ProductCardType) _productCardTypesSource.getRowData();
		selection.addKey(_activeProductCardType.getModelId());
		_itemSelection.setWrappedSelection(selection);
		if (_activeProductCardType != null) {
			setInfo();
		}
	}

	public void setItemSelection(SimpleSelection selection) {
		_itemSelection.setWrappedSelection(selection);
		_activeProductCardType = _itemSelection.getSingleSelection();
		if (_activeProductCardType != null) {
			setInfo();
		}
	}

	public void setInfo() {		
		// MbNameComponentsSearch compSearch =
		// (MbNameComponentsSearch)ManagedBeanWrapper.getManagedBean("MbNameComponentsSearch");
		// NameComponent componentFilter = new NameComponent();
		// componentFilter.setFormatId(_activeFormat.getId());
		// compSearch.setFilter(componentFilter);
		//		
		// NameBaseParam baseParamFilter = new NameBaseParam();
		// baseParamFilter.setEntityType(_activeFormat.getEntityType());
		// compSearch.setBaseParamFilter(baseParamFilter);
		// compSearch.setBaseValues(null);
		// compSearch.search();
	}

	public void search() {
		clearState();
		searching = true;
	}

	public void clearFilter() {
		filter = new ProductCardType();
		clearState();
		searching = false;
	}

	public ProductCardType getFilter() {
		if (filter == null)
			filter = new ProductCardType();
		return filter;
	}

	public void setFilter(ProductCardType filter) {
		this.filter = filter;
	}

	private void setFilters() {
		filter = getFilter();
		filters = new ArrayList<Filter>();

		Filter paramFilter = new Filter();
		paramFilter.setElement("lang");
		paramFilter.setOp(Operator.eq);
		paramFilter.setValue(curLang);
		filters.add(paramFilter);

		if (filter.getId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("id");
			paramFilter.setOp(Operator.like);
			paramFilter.setValue(filter.getId() + "%");
			filters.add(paramFilter);
		}

		if (filter.getBinId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("binId");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(filter.getBinId().toString());
			filters.add(paramFilter);
		}

		if (filter.getProductId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("productId");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(filter.getProductId().toString());
			filters.add(paramFilter);
		}

		if (filter.getIndexRangeId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("indexRangeId");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(filter.getIndexRangeId().toString());
			filters.add(paramFilter);
		}
	}

	public void add() {
		newProductCardType = new ProductCardType();
		newProductCardType.setProductId(getFilter().getProductId());
		curMode = NEW_MODE;
	}

	public void edit() {
		try {
			newProductCardType = (ProductCardType) _activeProductCardType.clone();
			updateReissCardTypes();
			updateReissBins();
		} catch (CloneNotSupportedException e) {
			logger.error("", e);
			newProductCardType = _activeProductCardType;
		}
		curMode = EDIT_MODE;
	}

	public void view() {

	}

	public void save() {
		try {
			checkLength(newProductCardType.getBinId(), newProductCardType.getNumberFormatId());
			
			if (isNewMode()) {
				_issuingDao.checkIntersects(userSessionId, newProductCardType);
				newProductCardType = _issuingDao.addProductCardType(userSessionId,
						newProductCardType, userLang);
				_itemSelection.addNewObjectToList(newProductCardType);
			} else if (isEditMode()) {
				if (!checkSameProductCardType(newProductCardType)){
					_issuingDao.checkIntersects(userSessionId, newProductCardType);
				}
				newProductCardType = _issuingDao.modifyProductCardType(userSessionId,
						newProductCardType, userLang);
				_productCardTypesSource.replaceObject(_activeProductCardType, newProductCardType);
			}

			_activeProductCardType = newProductCardType;
			
			/*if (_activeProductCardType.getWarningMsg() != null) {
				showWarning = true;
			}*/
			curMode = VIEW_MODE;
		} catch (DataAccessException e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		} 
		catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}
	
	private boolean checkSameProductCardType(ProductCardType productCardType){
		boolean check = true;
			check = (check && productCardType.getBinId().equals(_activeProductCardType.getBinId()));
			check = (check && productCardType.getProductId().equals(_activeProductCardType.getProductId()));
			check = (check && productCardType.getCardTypeId().equals(_activeProductCardType.getCardTypeId()));
			check = (check && productCardType.getSeqNumberLow().equals(_activeProductCardType.getSeqNumberLow()));
			check = (check && productCardType.getSeqNumberHigh().equals(_activeProductCardType.getSeqNumberHigh()));
		return check;
	}
	
	public void realySave() {
			try {
				checkLength(newProductCardType.getBinId(), newProductCardType.getNumberFormatId());
				
				if (isNewMode()) {
					newProductCardType = _issuingDao.addProductCardType(userSessionId,
							newProductCardType, userLang);
					_itemSelection.addNewObjectToList(newProductCardType);
				} else if (isEditMode()) {
					newProductCardType = _issuingDao.modifyProductCardType(userSessionId,
							newProductCardType, userLang);
					_productCardTypesSource.replaceObject(_activeProductCardType, newProductCardType);
				}
	
				_activeProductCardType = newProductCardType;
				curMode = VIEW_MODE;
			} catch (Exception e) {
				FacesUtils.addMessageError(e);
				logger.error("", e);
			}
	}

	public void delete() {
		try {
			_issuingDao.deleteProductCardType(userSessionId, _activeProductCardType);
			_activeProductCardType = _itemSelection.removeObjectFromList(_activeProductCardType);

			if (_activeProductCardType == null) {
				clearState();
			} else {
				setInfo();
			}

			curMode = VIEW_MODE;
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void close() {
		panLengthErrorFormat = null;
	}

	public ProductCardType getNewProductCardType() {
		if (newProductCardType == null) {
			newProductCardType = new ProductCardType();
		}
		return newProductCardType;
	}

	public void setNewProductCardType(ProductCardType newProductCardType) {
		this.newProductCardType = newProductCardType;
	}

	public void clearState() {
		_itemSelection.clearSelection();
		_activeProductCardType = null;
		_productCardTypesSource.flushCache();
		curLang = userLang;
	}

	public void fullCleanBean() {
		clearState();
		filter = null;
		numberFormats = null;
		methods = null;
		instId = null;
	}

	public ArrayList<SelectItem> getPinRequests() {
		final String PIN_STORE_METHOD_NO = "PNSM0020";
		final String PVV_STORE_METHOD_NO = "PVSM0020";
		final String PIN_REQUEST_INHERIT = "PNRQINHR";
		
		ArrayList<SelectItem> result = getDictUtils().getArticles(DictNames.PIN_REQUEST, false, true);
		if (newProductCardType.getMethodId() != null) {
			Filter[] filters = new Filter[2];
			filters[0] = new Filter("id", newProductCardType.getMethodId());
			filters[1] = new Filter("lang", curLang);
			
			SelectionParams params = new SelectionParams(filters);
			try {
				PrsMethod[] methods = _personalizationDao.getMethods(userSessionId, params);
				if (PIN_STORE_METHOD_NO.equals(methods[0].getPinStoreMethod())
						&& PVV_STORE_METHOD_NO.equals(methods[0].getPvvStoreMethod())) {
					for (SelectItem item : result) {
						if (PIN_REQUEST_INHERIT.equals(item.getValue())) {
							result.remove(item);
							break;
						}
					}
				}
			} catch (Exception e) {
				logger.error("", e);
			}
		}
		return result;
	}

	public ArrayList<SelectItem> getPinMailerRequests() {
		return getDictUtils().getArticles(DictNames.PIN_MAILER_REQUEST, false, true);
	}

	public ArrayList<SelectItem> getEmbossingRequests() {
		return getDictUtils().getArticles(DictNames.EMBOSSING_REQUEST, false, true);
	}

	public List<SelectItem> getOnlineStatuses() {
		return getDictUtils().getLov(LovConstants.CARD_TYPES_ONLINE_STATUSES);
	}
	
	public List<SelectItem> getServices() {
		Map<String, Object> paramMap = new HashMap<String, Object>();
		paramMap.put("PRODUCT_ID", getFilter().getProductId());
		paramMap.put("ENTITY_TYPE", EntityNames.CARD);
		paramMap.put("IS_INITIAL", 1);
		return getDictUtils().getLov(LovConstants.SERVICE_PRODUCT, paramMap);
	}

	public ArrayList<SelectItem> getPersoPriorities() {
		return getDictUtils().getArticles(DictNames.PERSO_PRIORITY, false, true);
	}


	public void changeLanguage(ValueChangeEvent event) {
		curLang = (String) event.getNewValue();

		List<Filter> filtersList = new ArrayList<Filter>();

		Filter paramFilter = new Filter();
		paramFilter.setElement("id");
		paramFilter.setOp(Operator.eq);
		paramFilter.setValue(_activeProductCardType.getId().toString());
		filtersList.add(paramFilter);

		paramFilter = new Filter();
		paramFilter.setElement("lang");
		paramFilter.setOp(Operator.eq);
		paramFilter.setValue(curLang);
		filtersList.add(paramFilter);

		filters = filtersList;
		SelectionParams params = new SelectionParams();
		params.setFilters(filters.toArray(new Filter[filters.size()]));
		try {
			ProductCardType[] productCardTypes = _issuingDao.getProductCardTypes(userSessionId,
					params);
			if (productCardTypes != null && productCardTypes.length > 0) {
				_activeProductCardType = productCardTypes[0];
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public List<SelectItem> getIndexRanges() {
		if (getNewProductCardType().getBinId() == null) {
			return new ArrayList<SelectItem>(0);
		}
		Map<String, Object> paramMap = new HashMap<String, Object>();
		paramMap.put("BIN_ID", getNewProductCardType().getBinId());
		
		return getDictUtils().getLov(LovConstants.BIN_INDEX_RANGES, paramMap);
	}

	public ArrayList<SelectItem> getMethods() {
		if (instId == null) {
			return new ArrayList<SelectItem>(0);
		}

		if (methods == null) {
			try {
				Filter[] filters = new Filter[2];
				filters[0] = new Filter();
				filters[0].setElement("lang");
				filters[0].setValue(userLang);
				filters[1] = new Filter();
				filters[1].setElement("instId");
				filters[1].setValue(instId.toString());

				SelectionParams params = new SelectionParams();
				params.setRowIndexEnd(-1);
				params.setFilters(filters);

				PrsMethod[] prsMethods = _personalizationDao.getMethods(userSessionId, params);
				methods = new ArrayList<SelectItem>(prsMethods.length);
				for (PrsMethod method: prsMethods) {
					methods.add(new SelectItem(method.getId(), method.getId() + " - "
							+ method.getName()));
				}
			} catch (Exception e) {
				logger.error("", e);
				if (e.getMessage().indexOf(SystemConstants.INSUFFICIENT_PRIVILEGES_ERROR) < 0) {
					FacesUtils.addMessageError(e);
				}
				methods = new ArrayList<SelectItem>(0);
			}
		}
		return methods;
	}

	public ArrayList<SelectItem> getNumberFormats() {
		if (instId == null) {
			return new ArrayList<SelectItem>(0);
		}

		if (numberFormats == null) {
			try {
				Filter[] filters = new Filter[3];
				filters[0] = new Filter();
				filters[0].setElement("lang");
				filters[0].setValue(userLang);
				filters[1] = new Filter();
				filters[1].setElement("entityType");
				filters[1].setValue(EntityNames.CARD);
				filters[2] = new Filter();
				filters[2].setElement("instId");
				filters[2].setValue(instId.toString());

				SelectionParams params = new SelectionParams();
				params.setRowIndexEnd(-1);
				params.setFilters(filters);

				NameFormat[] formats = _rulesDao.getNameFormats(userSessionId, params);
				numberFormats = new ArrayList<SelectItem>(formats.length);
				for (NameFormat format: formats) {
					numberFormats.add(new SelectItem(format.getId(), format.getId() + " - "
							+ format.getLabel()));
				}
			} catch (Exception e) {
				logger.error("", e);
				if (e.getMessage().indexOf(SystemConstants.INSUFFICIENT_PRIVILEGES_ERROR) < 0) {
					FacesUtils.addMessageError(e);
				}
				numberFormats = new ArrayList<SelectItem>(0);
			}
		}
		return numberFormats;
	}

	/*
	public List<SelectItem> getBins() {
		Map<String, Object> paramMap = new HashMap<String, Object>();
		if (getNewProductCardType().getCardTypeId() != null) {
			paramMap.put("CARD_TYPE_ID", getNewProductCardType().getCardTypeId());
		}
		if (instId != null) {
			paramMap.put("INST_ID", instId);
		}
		return getDictUtils().getLov(LovConstants.BLANK_TYPES, paramMap);
	}
	*/
	
	public ArrayList<SelectItem> getBins() {
		if (instId == null || getNewProductCardType().getCardTypeId() == null) {
			getNewProductCardType().setBinId(null);
			return new ArrayList<SelectItem>(0);
		}
		ArrayList<SelectItem> bins = new ArrayList<SelectItem>();
		Map<String, Object>filters = new HashMap<String, Object>();
		filters.put("institution_id", instId);
		filters.put("card_type_id", getNewProductCardType().getCardTypeId());
		bins = (ArrayList<SelectItem>) getDictUtils().getLov(LovConstants.BINS, filters);

		return bins;
	}

	public List<SelectItem> getCardTypes() {
		if (cardTypesItems == null){
			cardTypesItems = new ArrayList<SelectItem>();
			
			List<Filter> lFilters = new ArrayList<Filter>();
			lFilters.add(new Filter("lang", userLang));
			if (instId != null){
				lFilters.add(new Filter("instId", instId.toString()));
			}
			SelectionParams params = new SelectionParams(lFilters);			
			try {
				cardTypes = _networkDao.getCardTypes(userSessionId, params);
			} catch (DataAccessException e){
				logger.error("", e);
				if (e.getMessage().indexOf(SystemConstants.INSUFFICIENT_PRIVILEGES_ERROR) < 0) {
					FacesUtils.addMessageError(e);
				}
				return new ArrayList<SelectItem>(0);
			}
			
			for (CardType type : cardTypes) {
				SelectItem item = new SelectItem(type.getId(),
						String.format("%s - %s", type.getId(),
								type.getName() != null ? StringUtils.leftPad(type.getName(),
										type.getName().length() + (type.getLevel() - 1) * HIER_LEVEL_PREFIX.length(),
										HIER_LEVEL_PREFIX) : null));

				// disable card types with level 1 and level 2
				item.setDisabled(type.getLevel() < 3);

				cardTypesItems.add(item);
			}
		}
		
		return cardTypesItems;
	}

	public ArrayList<SelectItem> getBlankTypes() {
		ArrayList<SelectItem> items = new ArrayList<SelectItem>();
		try {
			SelectionParams params = new SelectionParams();
			params.setRowIndexEnd(-1);

			List<Filter> filtersList = new ArrayList<Filter>();
			Filter paramFilter = new Filter();
			paramFilter.setElement("lang");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(userLang);
			filtersList.add(paramFilter);

			if (instId != null) {
				paramFilter = new Filter();
				paramFilter.setElement("instId");
				paramFilter.setOp(Operator.eq);
				paramFilter.setValue(instId.toString());
				filtersList.add(paramFilter);
			}
			if (getNewProductCardType().getCardTypeId() != null) {
				paramFilter = new Filter();
				paramFilter.setElement("cardTypeId");
				paramFilter.setOp(Operator.eq);
				paramFilter.setValue(getNewProductCardType().getCardTypeId().toString());
				filtersList.add(paramFilter);
			}
			params.setFilters(filtersList.toArray(new Filter[filtersList.size()]));

			BlankType[] types = _personalizationDao.getBlankTypes(userSessionId, params);
			for (BlankType type: types) {
				items.add(new SelectItem(type.getId(), type.getId() + " - " + type.getName()));
			}
		} catch (Exception e) {
			logger.error("", e);
			if (e.getMessage().indexOf(SystemConstants.INSUFFICIENT_PRIVILEGES_ERROR) < 0) {
				FacesUtils.addMessageError(e);
			}
		} finally {
			if (items == null)
				items = new ArrayList<SelectItem>();
		}
		return items;
	}

	public ArrayList<SelectItem> getReissCommands() {
		return getDictUtils().getArticles(DictNames.REISSUE_COMMAND, true);
	}

	public ArrayList<SelectItem> getReissStartDateRules() {
		return getDictUtils().getArticles(DictNames.REISSUE_START_DATE_RULE, true);
	}

	public ArrayList<SelectItem> getReissExpirDateRules() {
		return getDictUtils().getArticles(DictNames.REISSUE_EXPIRY_DATE_RULE, true);
	}

	public ArrayList<SelectItem> getReissContracts() {
		if (instId == null) {
			return new ArrayList<SelectItem>(0);
		}

		ArrayList<SelectItem> items = null;

		Filter[] filters = new Filter[3];
		filters[0] = new Filter();
		filters[0].setElement("LANG");
		filters[0].setValue(curLang);
		filters[1] = new Filter();
		filters[1].setElement("PRODUCT_TYPE");
		filters[1].setValue(ProductConstants.ISSUING_PRODUCT);
		filters[2] = new Filter();
		filters[2].setElement("INST_ID");
		filters[2].setValue(instId.toString());

		SelectionParams params = new SelectionParams();
		params.setFilters(filters);
		params.setRowIndexEnd(-1);

		Map<String, Object> paramsMap = new HashMap<String, Object>();
		paramsMap.put("param_tab", filters);
		paramsMap.put("tab_name", "CONTRACT");
		try {
			Contract[] contracts = _productsDao.getContractsCur(userSessionId, params, paramsMap);
			items = new ArrayList<SelectItem>(contracts.length);
			for (Contract contract: contracts) {
				items.add(new SelectItem(contract.getId(), contract.getContractNumber()));
			}
		} catch (Exception e) {
			logger.error("", e);
			items = new ArrayList<SelectItem>(0);
		}
		return items;
	}

	public Integer getInstId() {
		return instId;
	}

	public void setInstId(Integer instId) {
		this.instId = instId;
		cardTypesItems = null;
	}

	public void checkPanLengthBin() {
		ProductCardType type = getNewProductCardType();
		panLengthErrorFormat = "";
		panLengthErrorBin = "";
		if (type.getBinId() != null && type.getNumberFormatId() != null) {
			try {
				checkLength(type.getBinId(), type.getNumberFormatId());
			} catch (Exception e) {
				panLengthErrorBin = FacesUtils.getMessage(e);
				FacesUtils.addMessageError(e);
			}
		}
	}

	public void checkPanLengthFormat() {
		ProductCardType type = getNewProductCardType();
		panLengthErrorFormat = "";
		panLengthErrorBin = "";
		if (type.getBinId() != null && type.getNumberFormatId() != null) {
			try {
				checkLength(type.getBinId(), type.getNumberFormatId());
			} catch (Exception e) {
				panLengthErrorFormat = FacesUtils.getMessage(e);
				FacesUtils.addMessageError(e);
			}
		}
	}

	private void checkLength(Integer binId, Integer formatId) throws Exception {
		_productsDao.checkPanLength(userSessionId, binId, formatId);
	}

	public String getPanLengthErrorBin() {
		return panLengthErrorBin;
	}

	public void setPanLengthErrorBin(String panLengthErrorBin) {
		this.panLengthErrorBin = panLengthErrorBin;
	}

	public String getPanLengthErrorFormat() {
		return panLengthErrorFormat;
	}

	public void setPanLengthErrorFormat(String panLengthErrorFormat) {
		this.panLengthErrorFormat = panLengthErrorFormat;
	}


	public List<SelectItem> getCardStates() {
		List<SelectItem> result = getDictUtils().getLov(LovConstants.CARD_STATES);
		return result;
	}
	
	public List<SelectItem> getApplicationSchemes(){
		Map<String, Object> map = new HashMap<String, Object>();
		if (instId != null){
			map.put("institution_id", instId);
		}
		cachedApplications = getDictUtils().getLov(LovConstants.APPLICATION_SCHEMES, map); 
		return cachedApplications;
	}
	
	
	public String getComponentId() {
		return parentSectionId + ":" + tabName + ":" + COMPONENT_ID;
	}

	public void setTabName(String tabName) {
		this.tabName = tabName;
	}

	public void setParentSectionId(String parentSectionId) {
		this.parentSectionId = parentSectionId;
	}
	
	/* 
	 * we should return a new List every time this method is called
	 * because ISSUING_PRODUCTS list is not constant in the bean's scope
	 */		
	public List<SelectItem> getReissProducts() {
		Map<String, Object> paramMap = new HashMap<String, Object>();
		if (instId!=null) {
			paramMap.put("INSTITUTION_ID", instId);
		}	
		return getDictUtils().getLov(LovConstants.ISSUING_PRODUCTS, paramMap);
	}

	public void updateReissCardTypes() {
		reissCardTypes = new ArrayList<SelectItem>();
		if (newProductCardType.getReissProductId()== null) {
			return;
		}
		List<Filter> lFilters = new ArrayList<Filter>();
		lFilters.add(new Filter("lang", userLang));
		if (instId != null){
			lFilters.add(new Filter("instId", instId.toString()));
		}
		lFilters.add(new Filter("productId", newProductCardType.getReissProductId()));
		SelectionParams params = new SelectionParams(lFilters);
		CardType[] reissCardTypesLocal = null;
		try {
			reissCardTypesLocal = _networkDao.getCardTypes(userSessionId, params);
		} catch (DataAccessException e){
			logger.error("", e);
			if (e.getMessage().indexOf(SystemConstants.INSUFFICIENT_PRIVILEGES_ERROR) < 0) {
				FacesUtils.addMessageError(e);
			}
		}
		for (CardType type : reissCardTypesLocal) {
			SelectItem item = new SelectItem(type.getId(),
					String.format("%s - %s", type.getId(),
							type.getName() != null ? StringUtils.leftPad(type.getName(),
									type.getName().length() + (type.getLevel() - 1) * HIER_LEVEL_PREFIX.length(),
									HIER_LEVEL_PREFIX) : null));

			// disable card types with level 1 and level 2
			item.setDisabled(type.getLevel() < 3);

			reissCardTypes.add(item);
		}
	}

	public void updateReissBins(){
		reissBins = new ArrayList<SelectItem>();
		if (newProductCardType.getCardTypeId() == null) {
			return;
		}
		Map<String, Object> paramMap = new HashMap<String, Object>();
		paramMap.put("institution_id", instId);
		paramMap.put("card_type_id", newProductCardType.getReissCardTypeId());
		reissBins = getDictUtils().getLov(LovConstants.BINS, paramMap);
	}
	
	public List<SelectItem> getReissBins(){
		if(reissBins == null){
			updateReissBins();
		}
		return reissBins;
	}

	public List<SelectItem> getReissCardTypes() {
		if(reissCardTypes == null) {
			updateReissCardTypes();
		}
		return reissCardTypes;
	}

	public void setReissCardTypes(List<SelectItem> reissCardTypes) {
		this.reissCardTypes = reissCardTypes;
	}

	public List<SelectItem> getUidFormatIds(){
		Map<String, Object> paramMap = new HashMap<String, Object>();
		if (instId!=null) {
			paramMap.put("INSTITUTION_ID", instId);
		}
		return getDictUtils().getLov(LovConstants.NAME_FORMATS, paramMap);
	}

}
