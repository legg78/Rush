package ru.bpc.sv2.ui.fcl.fees;

import java.util.ArrayList;


import ru.bpc.sv2.logic.utility.db.DataAccessException;
import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.model.SelectItem;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;

import ru.bpc.sv2.constants.DictNames;
import ru.bpc.sv2.constants.EntityNames;
import ru.bpc.sv2.constants.SectionIdConstants;
import ru.bpc.sv2.constants.SystemConstants;
import ru.bpc.sv2.fcl.cycles.Cycle;
import ru.bpc.sv2.fcl.fees.Fee;
import ru.bpc.sv2.fcl.fees.FeeType;
import ru.bpc.sv2.fcl.limits.Limit;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.Filter.Operator;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.CyclesDao;
import ru.bpc.sv2.logic.FeesDao;
import ru.bpc.sv2.logic.LimitsDao;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.TableRowSelection;
import util.auxil.ManagedBeanWrapper;

@ViewScoped
@ManagedBean (name = "MbFeesSearch")
public class MbFeesSearch extends AbstractBean {
	private static final long serialVersionUID = 1L;

	private static final Logger logger = Logger.getLogger("FCL");

	private static String COMPONENT_ID = "1057:feesTable";

	private FeesDao _feesDao = new FeesDao();

	private CyclesDao _cyclesDao = new CyclesDao();

	private LimitsDao _limitsDao = new LimitsDao();

	private Fee _activeFee;

	private Fee filter;
	transient 
	private String backLink;
	private boolean selectMode;
	private boolean blockFeeType = false;

	private final DaoDataModel<Fee> _feesSource;

	private final TableRowSelection<Fee> _itemSelection;

	private boolean _managingNew;
	private MbFeeTiers tiersBean;
	private boolean showModal;

	private String tabName = "detailsTab";

	public MbFeesSearch() {
		pageLink = "fcl|fees|list_fees";
		MbFees fees = (MbFees) ManagedBeanWrapper.getManagedBean("MbFees");
		tiersBean = (MbFeeTiers) ManagedBeanWrapper.getManagedBean("MbFeeTiers");

		_feesSource = new DaoDataModel<Fee>() {
			private static final long serialVersionUID = 1L;

			@Override
			protected Fee[] loadDaoData(SelectionParams params) {
				if (!searching) {
					return new Fee[0];
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _feesDao.getFees(userSessionId, params);
				} catch (Exception e) {
					setDataSize(0);
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return new Fee[0];
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (!searching) {
					return 0;
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _feesDao.getFeesCount(userSessionId, params);
				} catch (Exception e) {
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return 0;
			}
		};

		if (!fees.isKeepState()) {
			// clear keepState flag
			fees.setKeepState(false);
			showModal = false;
			_itemSelection = new TableRowSelection<Fee>(null, _feesSource);
		} else {
			// restore bean's state from session bean
			filter = fees.getSearchFilter();
			selectMode = fees.isSelectMode();
			backLink = fees.getBackLinkSearch();
			fees.setKeepState(false);
			showModal = true;
			searching = true;
			_activeFee = fees.getStoredActiveFee();
			_itemSelection = new TableRowSelection<Fee>(fees.getStoredItemSelection(), _feesSource);
		}
	}

	public DaoDataModel<Fee> getFees() {
		return _feesSource;
	}

	public Fee getActiveFee() {
		return _activeFee;
	}

	public void setActiveFee(Fee activeFee) {
		_activeFee = activeFee;
	}

	public SimpleSelection getItemSelection() {
		if (_activeFee == null && _feesSource.getRowCount() > 0) {
			setFirstRowActive();
		} else if (_activeFee != null && _feesSource.getRowCount() > 0) {
			SimpleSelection selection = new SimpleSelection();
			selection.addKey(_activeFee.getModelId());
			_itemSelection.setWrappedSelection(selection);
			_activeFee = _itemSelection.getSingleSelection();
		}
		return _itemSelection.getWrappedSelection();
	}

	public void setItemSelection(SimpleSelection selection) {
		_itemSelection.setWrappedSelection(selection);
		_activeFee = _itemSelection.getSingleSelection();

		if (_activeFee != null) {
			setBeans();
		}
	}

	public void setFirstRowActive() {
		_feesSource.setRowIndex(0);
		SimpleSelection selection = new SimpleSelection();
		_activeFee = (Fee) _feesSource.getRowData();
		selection.addKey(_activeFee.getModelId());
		_itemSelection.setWrappedSelection(selection);

		setBeans();
	}

	/**
	 * Sets data for backing beans used by dependent pages
	 */
	private void setBeans() {
		tiersBean.clearBean();
		tiersBean.setActiveFeeId(_activeFee.getId());
	}

	public void createFee() {
		MbFees feeBean = (MbFees) ManagedBeanWrapper.getManagedBean("MbFees");
		feeBean.setCurrentFee(new Fee());
		if (getFilter().getEntityType() != null) {
			feeBean.getCurrentFee().setEntityType(filter.getEntityType());
			feeBean.setEntityType(filter.getEntityType());

			if (EntityNames.INSTITUTION.equals(filter.getEntityType())) {
				feeBean.getCurrentFee().setInstId(filter.getInstId());
			}
		}
		if (getFilter().getFeeType() != null) {
			feeBean.getCurrentFee().setFeeType(filter.getFeeType());
		}
		feeBean.setManagingNew(true);
		feeBean.setBackLinkSearch(backLink);
		feeBean.setModalMode(true);
		_managingNew = true;

		// save current state in session bean
		feeBean.setStoredActiveFee(_activeFee);
		feeBean.setSelectMode(selectMode);
		feeBean.setSearchFilter(filter);
		feeBean.setStoredItemSelection(_itemSelection.getWrappedSelection());

		// why do we need to clear active fee?
		// setActiveFee(new Fee());

		//return "open_details"; 
	}

	public void editFee() {
		MbFees feeBean = (MbFees) ManagedBeanWrapper.getManagedBean("MbFees");
		try {
			feeBean.setCurrentFee((Fee) _activeFee.clone());
		} catch (CloneNotSupportedException e) {
			logger.error("", e);
			feeBean.setCurrentFee(_activeFee);
		}
		feeBean.setBackLinkSearch(backLink);
		feeBean.setManagingNew(false);
		feeBean.setModalMode(true);
		_managingNew = false;

		// save current state in session bean
		feeBean.setStoredActiveFee(_activeFee);
		feeBean.setSelectMode(selectMode);
		feeBean.setSearchFilter(filter);
		feeBean.setStoredItemSelection(_itemSelection.getWrappedSelection());

		//return "open_details"; 
	}

	public void deleteFee() {
		try {
			_feesDao.deleteFee(userSessionId, _activeFee);

			FacesUtils.addMessageInfo("Fee with id=\"" + _activeFee.getId() + "\" was deleted");
			
			_activeFee = _itemSelection.removeObjectFromList(_activeFee);
			if (_activeFee == null) {
				clearBean();
			} else {
				setBeans();
			}
			curMode = VIEW_MODE;
			//_feesSource.flushCache();
			//_activeFee = null;

			//return "success";
		} catch (DataAccessException ee) {
			FacesUtils.addMessageError(ee);
			logger.error("", ee);
			//return "failure";
		}
	}

	public boolean isManagingNew() {
		return _managingNew;
	}

	public void setManagingNew(boolean managingNew) {
		_managingNew = managingNew;
	}

	public ArrayList<SelectItem> getFeeBasesCalc() {
		return getDictUtils().getArticles(DictNames.FEE_BASES_CALC, true);
	}

	public ArrayList<SelectItem> getFeeLimitsCalc() {
		return getDictUtils().getArticles(DictNames.FEE_LIMITS_CALC, true);
	}

	public ArrayList<SelectItem> getFeeRatesCalc() {
		return getDictUtils().getArticles(DictNames.FEE_RATES_CALC, true);
	}

	public ArrayList<SelectItem> getLengthTypes() {
		return getDictUtils().getArticles(DictNames.LENGTH_TYPES, true);
	}

	public SelectItem[] getCycles() {
		SelectItem[] items = null;
		try {
			Cycle[] cyclesArr = _cyclesDao.getCycles(userSessionId, null);
			SelectItem si;
			items = new SelectItem[cyclesArr.length];
			for (int i = 0; i < cyclesArr.length; i++) {
				si = new SelectItem((Integer) cyclesArr[i].getId(), Integer.toString(cyclesArr[i]
						.getId()));

				items[i] = si;
			}

		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		} finally {
			if (items == null)
				items = new SelectItem[0];
		}
		return items;
	}

	public ArrayList<SelectItem> getFeeTypes() {
		ArrayList<SelectItem> items = null;
		try {
			if (getFilter().getEntityType() != null && getFilter().getEntityType().length() > 0) {
				items = getFeeTypesFromDB();
			} else {
				items = getDictUtils().getArticles(DictNames.FEE_TYPE, true, true);
			}
		} catch (Exception e) {
			logger.error("", e);
			if (e.getMessage().indexOf(SystemConstants.INSUFFICIENT_PRIVILEGES_ERROR) < 0) {
				FacesUtils.addMessageError(e);
			}
		} finally {
			if (items == null)
				items = new ArrayList<SelectItem>(0);
		}
		return items;
	}

	/**
	 * Gets fee types directly from data base when we need to get fee types
	 * according to certain entity type(-s).
	 * 
	 * @return array of items suitable for <h:selectItems>
	 */
	private ArrayList<SelectItem> getFeeTypesFromDB() {
		SelectionParams params = null;

		// select only those fee types that are intended to be
		// used only with a given entity type
		params = new SelectionParams();
		params.setRowIndexEnd(-1);
		Filter[] filters = new Filter[1];
		filters[0] = new Filter();

		// if entity type is tied on product, then we need 
		// to find fee types that are tied not only on product
		// but also on account and card 
		// TODO: make it as LOV value instead of hardcode 
		if (getFilter().getEntityType().equals(
				DictNames.BUSINESS_ENTITIES + DictNames.ISSUING_PRODUCT)) {
			filters[0].setElement("entityTypes");
			filters[0].setValue("('" + DictNames.BUSINESS_ENTITIES + DictNames.ISSUING_PRODUCT
					+ "', '" + DictNames.BUSINESS_ENTITIES + DictNames.ACCOUNT + "', '"
					+ DictNames.BUSINESS_ENTITIES + DictNames.CARD + "')");
		} else {
			filters[0].setElement("entityType");
			filters[0].setValue(getFilter().getEntityType());
		}
		params.setFilters(filters);

		FeeType[] feesArr = _feesDao.getFeeTypes(userSessionId, params);

		ArrayList<SelectItem> items;
		if (feesArr != null && feesArr.length > 0) {
			items = new ArrayList<SelectItem>(feesArr.length);
			for (FeeType feeType: feesArr) {
				items.add(new SelectItem(feeType.getFeeType(), feeType.getFeeType() + " - "
						+ getDictUtils().getAllArticlesDesc().get(feeType.getFeeType())));
			}
		} else {
			items = new ArrayList<SelectItem>(0);
		}
		return items;
	}

	public SelectItem[] getLimits() {
		SelectItem[] items = null;
		try {
			Limit[] limitsArr = _limitsDao.getLimits(userSessionId, null);
			SelectItem si;
			items = new SelectItem[limitsArr.length];
			for (int i = 0; i < limitsArr.length; i++) {
				si = new SelectItem(limitsArr[i].getId(), limitsArr[i].getId().toString());

				items[i] = si;
			}

		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		} finally {
			if (items == null)
				items = new SelectItem[0];
		}
		return items;
	}

	public void clearFilter() {
		filter = null;
		clearBean();
		searching = false;
	}

	public void search() {
		searching = true;
		clearBean();
		//_itemSelection.setDataModel(_feesSource);
	}

	public void setFilters() {
		filters = new ArrayList<Filter>();
		Filter paramFilter = new Filter();
		if (getFilter().getFeeType() != null && !getFilter().getFeeType().equals("")) {
			paramFilter = new Filter();
			paramFilter.setElement("feeType");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(getFilter().getFeeType());
			filters.add(paramFilter);
		}
		if (getFilter().getEntityType() != null && !getFilter().getEntityType().equals("")) {
			paramFilter = new Filter();
			// if entity type is tied on product, then we need 
			// to find fee types that are tied not only on product
			// but also on account and card 
			// TODO: make it as LOV value instead of hardcode 
			if (getFilter().getEntityType().equals(
					DictNames.BUSINESS_ENTITIES + DictNames.ISSUING_PRODUCT)) {
				paramFilter.setElement("entityTypes");
				paramFilter.setValue("('" + DictNames.BUSINESS_ENTITIES + DictNames.ISSUING_PRODUCT
						+ "', '" + DictNames.BUSINESS_ENTITIES + DictNames.ACCOUNT + "', '"
						+ DictNames.BUSINESS_ENTITIES + DictNames.CARD + "')");
			} else {
				paramFilter.setElement("entityType");
				paramFilter.setValue(getFilter().getEntityType());
			}
			filters.add(paramFilter);
		}
		if (getFilter().getInstId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("instId");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(getFilter().getInstId().toString());
			filters.add(paramFilter);
		}
		if (getFilter().getCurrency() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("currency");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(getFilter().getCurrency());
			filters.add(paramFilter);
		}
		if (getFilter().getFeeRateCalc() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("feeRateCalc");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(getFilter().getFeeRateCalc());
			filters.add(paramFilter);
		}
		if (getFilter().getFeeBaseCalc() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("feeBaseCalc");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(getFilter().getFeeBaseCalc());
			filters.add(paramFilter);
		}
	}

	public Fee getFilter() {
		if (filter == null) {
			filter = new Fee();
			filter.setInstId(userInstId);
		}
		return filter;
	}

	public void setFilter(Fee filter) {
		this.filter = filter;
	}

	public String getBackLink() {
		return backLink;
	}

	public void setBackLink(String backLink) {
		this.backLink = backLink;
	}

	public boolean isSelectMode() {
		return selectMode;
	}

	public void setSelectMode(boolean selectMode) {
		this.selectMode = selectMode;
	}

	public String select() {
		MbFees feeBean = (MbFees) ManagedBeanWrapper.getManagedBean("MbFees");
		feeBean.setStoredActiveFee(_activeFee);
		return backLink;
	}

	public String cancelSelect() {
//		MbFees feeBean = (MbFees)ManagedBeanWrapper.getManagedBean("MbFees");
//		feeBean.setActiveFee(null);
		return backLink;
	}

	public void clearBean() {
		// clear selection
		if (_activeFee != null) {
			if (_itemSelection != null) {
				_itemSelection.unselect(_activeFee);
			}
			_activeFee = null;
		}
		_feesSource.flushCache();

		// clear dependent bean
		tiersBean.setActiveFeeId(null);
		tiersBean.getFeeTiers().flushCache();
	}

	public boolean isShowModal() {
		return showModal;
	}

	public void setShowModal(boolean showModal) {
		this.showModal = showModal;
	}

	public boolean isBlockFeeType() {
		return blockFeeType;
	}

	public void setBlockFeeType(boolean blockFeeType) {
		this.blockFeeType = blockFeeType;
	}

	public String getComponentId() {
		return COMPONENT_ID;
	}

	public Logger getLogger() {
		return logger;
	}

	public String getTabName() {
		return tabName;
	}

	public void setTabName(String tabName) {
		this.tabName = tabName;
		
		if (tabName.equalsIgnoreCase("tierTab")) {
			MbFeeTiers bean = (MbFeeTiers) ManagedBeanWrapper
					.getManagedBean("MbFeeTiers");
			bean.setTabName(tabName);
			bean.setParentSectionId(getSectionId());
			bean.setTableState(getSateFromDB(bean.getComponentId()));
		}
	}
	
	public String getSectionId() {
		return SectionIdConstants.CONFIGURATION_FEE_FEE;
	}

}
