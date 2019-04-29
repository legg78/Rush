package ru.bpc.sv2.ui.products;

import org.apache.commons.lang3.StringUtils;
import org.apache.log4j.Logger;
import org.openfaces.util.Faces;
import org.richfaces.model.selection.SimpleSelection;
import ru.bpc.sv2.campaign.Campaign;
import ru.bpc.sv2.campaign.CampaignAttributeValue;
import ru.bpc.sv2.constants.*;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.Filter.Operator;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.CampaignDao;
import ru.bpc.sv2.logic.CommonDao;
import ru.bpc.sv2.logic.ProductsDao;
import ru.bpc.sv2.logic.RulesDao;
import ru.bpc.sv2.products.AttributeValue;
import ru.bpc.sv2.products.ProductAttribute;
import ru.bpc.sv2.products.ProductConstants;
import ru.bpc.sv2.products.ProductPrivConstants;
import ru.bpc.sv2.rules.Modifier;
import ru.bpc.sv2.ui.fcl.MbFclObjects;
import ru.bpc.sv2.ui.session.UserSession;
import ru.bpc.sv2.ui.utils.*;
import util.auxil.ManagedBeanWrapper;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.model.SelectItem;
import java.math.BigDecimal;
import java.text.SimpleDateFormat;
import java.util.*;

@ViewScoped
@ManagedBean(name = "MbAttributeValues")
public class MbAttributeValues extends AbstractBean {
	private static final long serialVersionUID = 1L;

	private static final Logger logger = Logger.getLogger("PRODUCTS");

	private ProductsDao _productsDao = new ProductsDao();
	private CommonDao _commonDao = new CommonDao();
	private RulesDao _rulesDao = new RulesDao();
	private CampaignDao _campaignDao = new CampaignDao();

	private AttributeValue searchFilter;
	private ArrayList<SelectItem> accountTypes;
	private AttributeValue newAttributeValue;
	private List<SelectItem> lovs;
	private Date effDate;

	// additional parameters (are passed from MbProductAttributes)
	private ProductAttribute attribute;
	private Integer productId;
	private String entityType;
	private Long objectId;
	private Long campaignId;
	private Integer instId;

	private final DaoDataModel<AttributeValue> _prodAttrValueSource;
	private final TableRowSelection<AttributeValue> _itemSelection;
	private AttributeValue _activeAttributeValue;

	private MbProductsSess productsSession;

	private String productType;
	
	private static String COMPONENT_ID = "attrValuesTable";
	private String tabName;
	private String parentSectionId;

	private boolean caching = false;

	public MbAttributeValues() {
		productsSession = (MbProductsSess) ManagedBeanWrapper.getManagedBean("MbProductsSess");

		_prodAttrValueSource = new DaoDataModel<AttributeValue>() {
			private static final long serialVersionUID = 1L;

			@Override
			protected AttributeValue[] loadDaoData(SelectionParams params) {
				if (objectId == null || attribute == null) {
					return new AttributeValue[0];
				}
				try {
					setFilters();
					params.setFilters(filters);
					if (isProduct()) {
						return _productsDao.getProductAttrValues(userSessionId, params);
					} else if (isService()) {
						return _productsDao.getAttributeValues(userSessionId, params);
					} else {
						return _productsDao.getMixedAttrValues(userSessionId, params);
					}
				} catch (Exception e) {
					setDataSize(0);
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return new AttributeValue[0];
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (objectId == null || attribute == null) {
					return 0;
				}
				try {
					setFilters();
					params.setFilters(filters);
					if (isProduct()) {
						return _productsDao.getProductAttrValuesCount(userSessionId, params);
					} else if (isService()) {
						return _productsDao.getAttributeValuesCount(userSessionId, params);
					} else {
						return _productsDao.getMixedAttrValuesCount(userSessionId, params);
					}
				} catch (Exception e) {
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return 0;
			}
		};

		_itemSelection = new TableRowSelection<AttributeValue>(null, _prodAttrValueSource);
	}

	public DaoDataModel<AttributeValue> getAttributeValues() {
		return _prodAttrValueSource;
	}

	public AttributeValue getActiveAttributeValue() {
		return _activeAttributeValue;
	}

	public void setActiveAttributeValue(AttributeValue activeAttributeValue) {
		_activeAttributeValue = activeAttributeValue;
	}

	public SimpleSelection getItemSelection() {
		return _itemSelection.getWrappedSelection();
	}

	public void setItemSelection(SimpleSelection selection) {
		_itemSelection.setWrappedSelection(selection);
		_activeAttributeValue = _itemSelection.getSingleSelection();

		if (_activeAttributeValue != null) {
			storeParams();
		}
	}

	private void storeParams() {
		productsSession.setActiveAttributeValue(_activeAttributeValue);
		productsSession.setAttributeValueSelection(_itemSelection);
	}

	public String search() {
		// search using new criteria
		_prodAttrValueSource.flushCache();

		// reset selection
		if (_activeAttributeValue != null) {
			if (_itemSelection != null) {
				_itemSelection.unselect(_activeAttributeValue);
			}
			_activeAttributeValue = null;
		}

		return "";
	}

	public void clearFilter() {
		curLang = userLang;
		searchFilter = new AttributeValue();
	}

	private void setFilters() {
		searchFilter = getFilter();
		filters = new ArrayList<Filter>();

		filters.add(Filter.create("attrId", attribute.getId().toString()));
		filters.add(Filter.create("entityType", entityType));
		filters.add(Filter.create("objectId", objectId.toString()));
		if (attribute.getServiceId() != null) {
			filters.add(Filter.create("serviceId", attribute.getServiceId().toString()));
		}
		if (productId != null) {
			filters.add(Filter.create("productId", productId.toString()));
		}

		if (effDate != null) {
			SimpleDateFormat df = new SimpleDateFormat(DatePatterns.SHORT_DATETIME_PATTERN);
			filters.add(Filter.create("effDate", df.format(effDate)));
		}
		if(campaignId != null) {
			filters.add(Filter.create("campaignId", campaignId));
		}
	}

	public AttributeValue getFilter() {
		if (searchFilter == null) {
			searchFilter = new AttributeValue();
		}
		return searchFilter;
	}

	public void setFilter(AttributeValue searchFilter) {
		this.searchFilter = searchFilter;
	}

    public void add() {
        if (attribute.getAttrEntityType() != null) {
            MbFclObjects bean = ManagedBeanWrapper.getManagedBean(MbFclObjects.class);
            if (bean != null) {
                bean.initialize(entityType, objectId,
                                attribute.getSystemName(), attribute.getScaleId(),
                                attribute.getAttrObjectType(), instId,
                                attribute.getServiceId());
                bean.setDataModel(_prodAttrValueSource);
                bean.setCurMode(MbFclObjects.NEW_MODE);
                bean.setInheritedValue(false);
                bean.setProductType(productType);
                bean.setCampaignId(campaignId);
            }
        } else {
            newAttributeValue = new AttributeValue();
            newAttributeValue.setObjectId(objectId);
            newAttributeValue.setAttrId(attribute.getId());
            newAttributeValue.setEntityType(entityType);
            newAttributeValue.setAttrName(attribute.getSystemName());
            newAttributeValue.setServiceId(attribute.getServiceId());
            newAttributeValue.setLang(userLang);
            newAttributeValue.setCampaignId(campaignId);
        }
        curMode = NEW_MODE;
    }

    public void edit() {
        if (attribute.getAttrEntityType() != null) {
            MbFclObjects bean = ManagedBeanWrapper.getManagedBean(MbFclObjects.class);
            if (bean != null) {
                bean.initialize(attribute.getAttrEntityType(), entityType,
                                _activeAttributeValue, attribute.getScaleId(), instId);
                bean.setDataModel(_prodAttrValueSource);
                bean.setCurMode(MbFclObjects.EDIT_MODE);
                bean.setInheritedValue((isProduct() && _activeAttributeValue.isInherited()) ||
                                       (!isProduct() && _activeAttributeValue.getOwnerProductId() != null));
                bean.setProductType(productType);
                bean.setCampaignId(campaignId);
            }
        } else {
            newAttributeValue = _activeAttributeValue.copy();
            newAttributeValue.setCampaignId(campaignId);
        }
        curMode = EDIT_MODE;
    }

    public void view() {
        _activeAttributeValue = getCurrentItem();
        SimpleSelection selection = new SimpleSelection();
        selection.addKey(_activeAttributeValue.getModelId());
        _itemSelection.setWrappedSelection(selection);

        if (attribute.getAttrEntityType() != null) {
            MbFclObjects bean = ManagedBeanWrapper.getManagedBean(MbFclObjects.class);
            if (bean != null) {
                bean.initialize(attribute.getAttrEntityType(), entityType, _activeAttributeValue, attribute.getScaleId(), instId);
                bean.setCurMode(MbFclObjects.VIEW_MODE);
                bean.setProductType(productType);
                bean.setCampaignId(campaignId);
            }
        }
        curMode = VIEW_MODE;
    }

	public void save() {
		if (!checkDate()) {
			return;
		}

		preprocessCampaign();

		try {
			if (!caching) {
				newAttributeValue = _productsDao.setAttributeValue(userSessionId, newAttributeValue, attribute.getDataType());
			}
			if (isNewMode()) {
				_itemSelection.addNewObjectToList(newAttributeValue);
			} else {
				_prodAttrValueSource.replaceObject(_activeAttributeValue, newAttributeValue);
			}
			_activeAttributeValue = newAttributeValue;
			curMode = VIEW_MODE;
			FacesUtils.addMessageInfo("Attribute value has been saved.");
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void delete() {
		try {
			curMode = VIEW_MODE;

			_activeAttributeValue = _itemSelection.removeObjectFromList(_activeAttributeValue);
			if (_activeAttributeValue == null) {
				clearBean();
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	private void preprocessCampaign() {
		newAttributeValue.setCampaignId(campaignId);

		if (campaignId != null) {
			SelectionParams params = SelectionParams.build("lang", curLang, "id", campaignId);
			List<Campaign> campaigns = _campaignDao.getCampaigns(userSessionId, params);
			if (campaigns != null && !campaigns.isEmpty()) {
				if (newAttributeValue.getStartDate() == null) {
					newAttributeValue.setStartDate(campaigns.get(0).getStartDate());
				} else if (newAttributeValue.getStartDate().compareTo(campaigns.get(0).getStartDate()) < 0) {
					newAttributeValue.setStartDate(campaigns.get(0).getStartDate());
				}

				if (newAttributeValue.getEndDate() == null) {
					newAttributeValue.setEndDate(campaigns.get(0).getEndDate());
				} else if (newAttributeValue.getEndDate().compareTo(campaigns.get(0).getEndDate()) > 0) {
					newAttributeValue.setEndDate(campaigns.get(0).getEndDate());
				}
			}
		}
	}

	private boolean checkDate() {
		CommonUtils common = (CommonUtils) ManagedBeanWrapper.getManagedBean("CommonUtils");
		boolean success = true;

		Calendar now = Calendar.getInstance(common.getTimeZone());
		
		now.setTime(_commonDao.getBankDate(userSessionId, instId));

		Calendar startDate = null;
		if (newAttributeValue.getStartDate() == null) {
			startDate = Calendar.getInstance(common.getTimeZone());
		} else {
			startDate = Calendar.getInstance(common.getTimeZone());
			startDate.setTime(newAttributeValue.getStartDate());
		}
		Calendar endDate = null;
		if (newAttributeValue.getEndDate() != null) {
			endDate = Calendar.getInstance(common.getTimeZone());
			endDate.setTime(newAttributeValue.getEndDate());
		}

		Calendar initialStartDate = null;
		if (isEditMode() && _activeAttributeValue != null
				&& _activeAttributeValue.getStartDate() != null) {
			initialStartDate = Calendar.getInstance(common.getTimeZone());
			initialStartDate.setTime(_activeAttributeValue.getStartDate());
		}

		Calendar initialEndDate = null;
		if (isEditMode() && _activeAttributeValue != null && _activeAttributeValue.getEndDate() != null) {
			initialEndDate = Calendar.getInstance(common.getTimeZone());
			initialEndDate.setTime(_activeAttributeValue.getEndDate());
			// when editing one can't change end date if it's in the past (actually,
			// editing must be locked completely)
			if (initialEndDate.before(now)) {
				FacesUtils.addMessageError(new Exception(FacesUtils.getMessage(
						"ru.bpc.sv2.ui.bundles.Msg", "eff_period_ended")));
				return false;
			}
		}

		// Check if start date is in the past. It makes sense only when attribute value
		// is created or when it is edited and its initial start date is in the future.
		if ((isNewMode() || (isEditMode() && initialStartDate != null && initialStartDate
				.after(now))) && startDate.before(now)) {
			FacesUtils.addMessageError(new Exception(FacesUtils.getMessage(
					"ru.bpc.sv2.ui.bundles.Msg", "start_date_passed")));
			success = false;
		}

		// end date can't be in the past
		if (endDate != null && endDate.before(now)) {
			FacesUtils.addMessageError(new Exception(FacesUtils.getMessage(
					"ru.bpc.sv2.ui.bundles.Msg", "end_date_passed")));
			success = false;
		}
		// end date can't be less than start date
		if (endDate != null && startDate.after(endDate)) {
			FacesUtils.addMessageError(new Exception(FacesUtils.getMessage(
					"ru.bpc.sv2.ui.bundles.Msg", "start_date_after_end_date")));
			success = false;
		}

		return success;
	}

	public int getRowsNum() {
		return rowsNum;
	}

	public void setRowsNum(int rowsNum) {
		this.rowsNum = rowsNum;
	}

	public void cancel() {
		curMode = VIEW_MODE;
	}

	public ArrayList<SelectItem> getAllAccountTypes() {
		if (accountTypes == null) {
			accountTypes = getDictUtils().getArticles(DictNames.ACCOUNT_TYPE, true, false);
		}
		return accountTypes;
	}

	public AttributeValue getNewAttributeValue() {
		if (newAttributeValue == null) {
			newAttributeValue = new AttributeValue();
		}
		return newAttributeValue;
	}

	public void setNewAttributeValue(AttributeValue newAttributeValue) {
		this.newAttributeValue = newAttributeValue;
	}

	public void clearBean() {
		_itemSelection.clearSelection();
		_activeAttributeValue = null;
		_prodAttrValueSource.flushCache();
	}

	public void fullCleanBean() {
		productId = null;
		objectId = null;
		entityType = null;
		attribute = null;
		effDate = null;
		productType = null;
		clearBean();
	}

	public Integer getProductId() {
		return productId;
	}

	public void setProductId(Integer productId) {
		this.productId = productId;
	}

	public String getEntityType() {
		return entityType;
	}

	public void setEntityType(String entityType) {
		this.entityType = entityType;
	}

	public ProductAttribute getAttribute() {
		return attribute;
	}

	public void setAttribute(ProductAttribute attribute) {
		this.attribute = attribute;
		if (attribute.getLovId() != null) {
			if (attribute.getLovId() == LovConstants.NOTIFICATION_SCHEMES && getInstId() != null) {
				lovs = getDictUtils().getNotificationSchemes(getInstId());
			}
			else {
				lovs = getDictUtils().getLov(attribute.getLovId());
			}
		}
	}

	public List<SelectItem> getLovs() {
		return lovs;
	}

	public void setLovs(List<SelectItem> lovs) {
		this.lovs = lovs;
	}

	private AttributeValue getCurrentItem() {
		return (AttributeValue) Faces.var("item");
	}

	public String getLovValue() {
		AttributeValue currentItem = getCurrentItem();
		for (SelectItem lov: lovs) {
			if (lov.getValue() != null) {
				if (lov.getValue().equals(currentItem.getValue())
						|| (DataTypes.NUMBER.equals(attribute.getDataType())
								&& currentItem.getValueN() != null && lov.getValue().equals(
								String.valueOf(currentItem.getValueN().longValue())))) {
					return lov.getLabel();
				}
			}
		}
		if (currentItem.getValue() == null)
			return null;
		return currentItem.getValue().toString();
	}

	public ArrayList<SelectItem> getMods() {
		ArrayList<SelectItem> modsList;
		if (attribute.getScaleId() != null) {
			try {
				Modifier[] mods = _rulesDao.getModifiers(userSessionId, attribute.getScaleId());
				modsList = new ArrayList<SelectItem>(mods.length + 1);
				modsList.add(new SelectItem("", ""));
				for (Modifier mod: mods) {
					modsList.add(new SelectItem(mod.getId(), mod.getName()));
				}
			} catch (Exception e) {
				modsList = new ArrayList<SelectItem>(0);
				logger.error("", e);
				if (e.getMessage().indexOf(SystemConstants.INSUFFICIENT_PRIVILEGES_ERROR) < 0) {
					FacesUtils.addMessageError(e);
				}
			}
		} else {
			modsList = new ArrayList<SelectItem>(0);
		}
		return modsList;
	}

	/**
	 * @return <code>true</code> if attribute is of some entity type,
	 *         <code>false</code> if it's simple data type (char, number, date).
	 */
	public boolean isEntityType() {
		if (attribute != null && attribute.getAttrEntityType() != null)
			return true;
		return false;
	}

	public String editFromLink() {
		// Make sure to select correct item. If not to do this
		// then sometimes (when this action is called before row
		// has been selected) selection may absent or be outdated.
		_activeAttributeValue = getCurrentItem();
		SimpleSelection selection = new SimpleSelection();
		selection.addKey(_activeAttributeValue.getModelId());
		_itemSelection.setWrappedSelection(selection);

		return "";
	}

	public boolean isDateValue() {
		if (attribute != null) {
			return DataTypes.DATE.equals(attribute.getDataType());
		}
		return false;
	}

	public boolean isCharValue() {
		if (attribute != null) {
			return DataTypes.CHAR.equals(attribute.getDataType());
		}
		return true;
	}

	public boolean isNumberValue() {
		if (attribute != null) {
			return DataTypes.NUMBER.equals(attribute.getDataType());
		}
		return false;
	}

	public void restoreBean() {
		_activeAttributeValue = productsSession.getActiveAttributeValue();
		if (productsSession.getAttributeValueSelection() != null) {
			_itemSelection.setWrappedSelection(productsSession.getAttributeValueSelection()
					.getWrappedSelection());
		}
	}

	public String getInheritedText() {
		AttributeValue val = getCurrentItem();
		return FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Rul", "inherited_attr_value", val
				.getOwnerProductName(), val.getOwnerProductId());
	}

	public Date getEffDate() {
		return effDate;
	}

	public void setEffDate(Date effDate) {
		this.effDate = effDate;
	}

	public void filterByEffDate() {
		_prodAttrValueSource.flushCache();
	}

	public Integer getInstId() {
		return instId;
	}

	public void setInstId(Integer instId) {
		this.instId = instId;
	}

	public boolean isValue() {
		return attribute != null;
	}

	public Long getObjectId() {
		return objectId;
	}

	public void setObjectId(Long objectId) {
		this.objectId = objectId;
	}

	public Long getCampaignId() {
		return campaignId;
	}

	public void setCampaignId(Long campaignId) {
		this.campaignId = campaignId;
	}

	public boolean isProduct() {
		return EntityNames.PRODUCT.equals(entityType)
				|| ProductConstants.ISSUING_PRODUCT.equals(entityType)
				|| ProductConstants.ACQUIRING_PRODUCT.equals(entityType);
	}

	public boolean isService() {
		return EntityNames.SERVICE.equals(entityType);
	}

	public boolean isContract() {
		return EntityNames.CONTRACT.equals(entityType);
	}

	public boolean isInherited() {
		return (!isProduct() && _activeAttributeValue.getOwnerProductId() != null)
				|| (isProduct() && _activeAttributeValue.isInherited());
	}

	public boolean isPeriodStarted() {
		if (_activeAttributeValue == null || !isEditMode())
			return false;

		CommonUtils common = (CommonUtils) ManagedBeanWrapper.getManagedBean("CommonUtils");
		Calendar today = Calendar.getInstance(common.getTimeZone());
		Calendar startDate = Calendar.getInstance(common.getTimeZone());
		startDate.setTime(_activeAttributeValue.getStartDate());

		return startDate.compareTo(today) < 0;
	}

	public boolean isEditableAttribute() {
		if (_activeAttributeValue == null || isInherited())
			return false;
		
		if (_activeAttributeValue.getEndDate() == null) {
			return true;
		}

		CommonUtils common = (CommonUtils) ManagedBeanWrapper.getManagedBean("CommonUtils");
		Calendar today = Calendar.getInstance(common.getTimeZone());

		Calendar endDate = Calendar.getInstance(common.getTimeZone());
		endDate.setTime(_activeAttributeValue.getEndDate());

		return endDate.compareTo(today) > 0;
	}

	public boolean isAppropriateType() {
		return (isProduct() && attribute.isDefLevelProduct())
				|| (isService() && attribute.isDefLevelService())
				|| (isContract() && EntityNames.CONTRACT.equals(attribute.getEntityType()))
				|| (!isProduct() && !isService() && !isContract() && (attribute.isDefLevelObject() 
						|| attribute.isDefLevelProduct()));
	}

	public String getProductType() {
		return productType;
	}

	public void setProductType(String productType) {
		this.productType = productType;
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

	public boolean isCaching() {
		return caching;
	}
	public void setCaching(boolean caching) {
		this.caching = caching;
	}

	public boolean isDisabled(String component) {
		if (attribute == null || attribute.isReadonly() || !isAppropriateType()) {
			return true;
		} else if ("editBtn".equals(component) || "editExtBtn".equals(component)) {
			if (getActiveAttributeValue() == null || !isEditableAttribute()) {
				return true;
			}
		}
		return false;
	}

	public boolean isRendered(String component, Boolean disableEditing) {
		Map<String, Boolean> role = ((UserSession)ManagedBeanWrapper.getManagedBean("usession")).getInRole();
		if (role != null && role.get(ProductPrivConstants.SET_ATTRIBUTE_VALUE)) {
			if (disableEditing == null || Boolean.FALSE.equals(disableEditing)) {
				if (isValue()) {
					if (!attribute.isClosed()) {
						if ("setBtn".equals(component) || "editBtn".equals(component)) {
							return StringUtils.isEmpty(attribute.getAttrEntityType());
						} else if ("setExtBtn".equals(component) || "editExtBtn".equals(component)) {
							return StringUtils.isNotEmpty(attribute.getAttrEntityType());
						}
					}
				}
			}
		}
		return false;
	}

	public boolean isEnableBoundsEdit() {
		if (attribute != null) {
			if (ProductAttribute.DEF_LEVEL_PRODUCT.equals(attribute.getDefLevel())) {
				if (EntityNames.LIMIT.equals(attribute.getAttrEntityType())) {
					return true;
				}
			}
		}
		return false;
	}

	public Long getParentLimit() {
		if (isEnableBoundsEdit()) {
			List<AttributeValue> list = getAttributeValues().getActivePage();
			if (list != null) {
				for (AttributeValue value : list) {
					if (value.isActual()) {
						return new BigDecimal(value.getValue().toString()).longValue();
					}
				}
			}
		}
		return null;
	}
}
