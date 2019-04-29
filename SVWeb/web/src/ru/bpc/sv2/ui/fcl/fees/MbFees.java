package ru.bpc.sv2.ui.fcl.fees;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.HashMap;


import ru.bpc.sv2.logic.utility.db.DataAccessException;
import javax.faces.bean.ManagedBean;
import javax.faces.bean.SessionScoped;
import javax.faces.event.ValueChangeEvent;
import javax.faces.model.SelectItem;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;

import ru.bpc.sv2.constants.DictNames;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.constants.SystemConstants;
import ru.bpc.sv2.fcl.cycles.Cycle;
import ru.bpc.sv2.fcl.fees.Fee;
import ru.bpc.sv2.fcl.fees.FeeType;
import ru.bpc.sv2.fcl.limits.Limit;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.CyclesDao;
import ru.bpc.sv2.logic.FeesDao;
import ru.bpc.sv2.logic.LimitsDao;
import ru.bpc.sv2.ui.fcl.cycles.MbCycles;
import ru.bpc.sv2.ui.fcl.cycles.MbCyclesSearch;
import ru.bpc.sv2.ui.fcl.limits.MbLimitsSearch;
import ru.bpc.sv2.ui.utils.DictUtils;
import ru.bpc.sv2.ui.utils.FacesUtils;
import util.auxil.ManagedBeanWrapper;
import util.auxil.SessionWrapper;

@SessionScoped
@ManagedBean (name = "MbFees")
public class MbFees implements Serializable {
	private static final long serialVersionUID = 1L;

	private static final Logger logger = Logger.getLogger("FCL");

	private FeesDao _feesDao = new FeesDao();

	private CyclesDao _cyclesDao = new CyclesDao();

	private LimitsDao _limitsDao = new LimitsDao();

	private Fee currentFee;

	private transient DictUtils dictUtils;
	private Fee filter;
	private String backLink;
	private boolean selectMode;
	private String entityType;
	private Fee storedActiveFee; // to save state of MbFeesSearch
	private Fee searchFilter; // to save state of MbFeesSearch
	private String backLinkSearch; // to save state of MbFeesSearch
	private SimpleSelection storedItemSelection; // to save state of MbFeesSearch
	private boolean keepState = false;

	private boolean blockFeeType;
	private boolean modalMode = true;

	private boolean _managingNew;
	private final int MODE_FEE = 0;
	private final int MODE_SELECT_LIMIT = 1;
	private final int MODE_SELECT_CYCLE = 2;
	private int curMode;
	private HashMap<String, FeeType> feeTypesMap;

	private Long userSessionId = null;

	public MbFees() {
		userSessionId = SessionWrapper.getRequiredUserSessionId();
		curMode = 0;
		feeTypesMap = new HashMap<String, FeeType>();
	}

	public Fee getCurrentFee() {
		if (curMode == MODE_SELECT_LIMIT) {
			MbLimitsSearch limitsBean = (MbLimitsSearch) ManagedBeanWrapper.getManagedBean("MbLimitsSearch");
			Limit limit = limitsBean.getActiveLimit();
			if (limit != null) {
				currentFee.setLimitId(limit.getId());
			}
			curMode = MODE_FEE;
		}
		if (curMode == MODE_SELECT_CYCLE) {
			MbCycles cyclesBean = (MbCycles) ManagedBeanWrapper.getManagedBean("MbCycles");
			Cycle cycle = cyclesBean.getActiveCycle();
			if (cycle != null) {
				currentFee.setCycleId(cycle.getId());
			}
			curMode = MODE_FEE;
		}
		return currentFee;
	}

	public void setCurrentFee(Fee currentFee) {
		this.currentFee = currentFee;
	}

	// TODO: whether we need this or not? if yes, then apply new save/delete mechanism
	public String commit() {
		try {
			if (_managingNew) {
				currentFee = _feesDao.createFee(userSessionId, currentFee);
			} else {
				currentFee = _feesDao.updateFee(userSessionId, currentFee);
			}

			FacesUtils.addMessageInfo("Fee \"" + currentFee.getId() + "\" saved");
			getDictUtils().readAllArticles(); // reread articles to get changes we've done

			// renew fees table
			MbFeesSearch searchBean = (MbFeesSearch) ManagedBeanWrapper.getManagedBean("MbFeesSearch");
			searchBean.getFees().flushCache();

			if (backLink != null && !backLink.equals("")) {
				return backLink;
			}

			return "success";
		} catch (DataAccessException ee) {
			FacesUtils.addMessageError(ee);
			logger.error("", ee);
			return "failure";
		}
	}

	public String cancel() {
		if (backLink != null && !backLink.equals("")) {

			return backLink;
		}
		currentFee = null;
		return "cancel";
	}

	public boolean isManagingNew() {
		return _managingNew;
	}

	public void setManagingNew(boolean managingNew) {
		_managingNew = managingNew;
	}

	public ArrayList<SelectItem> getFeeBasesCalc() {
		return getDictUtils().getArticles(DictNames.FEE_BASES_CALC, true, false);
	}

	public ArrayList<SelectItem> getFeeRatesCalc() {
		return getDictUtils().getArticles(DictNames.FEE_RATES_CALC, true, false);
	}

	public ArrayList<SelectItem> getLengthTypes() {
		return getDictUtils().getArticles(DictNames.LENGTH_TYPES, true, false);
	}

	public SelectItem[] getCycles() {

		SelectItem[] items = null;
		try {
			Cycle[] cyclesArr = _cyclesDao.getCycles(userSessionId, null);
			SelectItem si;
			items = new SelectItem[cyclesArr.length];
			for (int i = 0; i < cyclesArr.length; i++) {
				si = new SelectItem((Integer) cyclesArr[i].getId(), Integer.toString(cyclesArr[i].getId()));

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

	public SelectItem[] getFeeTypes() {
		SelectItem[] items = null;
		try {
			SelectionParams params = null;

			// select only those fee types that are intended to be
			// used only with a given entity type
			if (entityType != null) {
				params = new SelectionParams();
				params.setRowIndexEnd(-1);
				Filter[] filters = new Filter[1];
				filters[0] = new Filter();

				// if entity type is tied on product, then we need
				// to find fee types that are tied not only on product
				// but also on account and card
				// TODO: make it as LOV value instead of hardcode
				if (entityType.equals(DictNames.BUSINESS_ENTITIES + DictNames.ISSUING_PRODUCT)) {
					filters[0].setElement("entityTypes");
					filters[0].setValue("('" + DictNames.BUSINESS_ENTITIES + DictNames.ISSUING_PRODUCT + "', '"
							+ DictNames.BUSINESS_ENTITIES + DictNames.ACCOUNT + "', '" + DictNames.BUSINESS_ENTITIES
							+ DictNames.CARD + "')");
				} else {
					filters[0].setElement("entityType");
					filters[0].setValue(entityType);
				}
				params.setFilters(filters);
			}
			FeeType[] feesArr = _feesDao.getFeeTypes(userSessionId, params);

			if (feesArr != null && feesArr.length > 0) {
				SelectItem si;
				items = new SelectItem[feesArr.length];
				for (int i = 0; i < feesArr.length; i++) {
					si = new SelectItem(feesArr[i].getFeeType(), feesArr[i].getFeeType() + " - "
							+ getDictUtils().getAllArticlesDesc().get(feesArr[i].getFeeType()));
					items[i] = si;

					feeTypesMap.put(feesArr[i].getFeeType(), feesArr[i]);
				}

				// set data to correspond to the selected fee type
				if (currentFee != null) {
					if (currentFee.getFeeType() == null) {
						// if new fee is created first fee type will be selected
						currentFee.setEntityType(feesArr[0].getEntityType());
						currentFee.setCycleType(feesArr[0].getCycleType());
						currentFee.setLimitType(feesArr[0].getLimitType());
					} else {
						currentFee.setEntityType(feeTypesMap.get(currentFee.getFeeType()).getEntityType());
						currentFee.setCycleType(feeTypesMap.get(currentFee.getFeeType()).getCycleType());
						currentFee.setLimitType(feeTypesMap.get(currentFee.getFeeType()).getLimitType());
					}
				}

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

	public ArrayList<SelectItem> getAllFeeTypes() {
		return getDictUtils().getArticles(DictNames.FEE_TYPE, true, false);
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
			logger.error("", e);
			if (e.getMessage().indexOf(SystemConstants.INSUFFICIENT_PRIVILEGES_ERROR) < 0) {
				FacesUtils.addMessageError(e);
			}
		} finally {
			if (items == null)
				items = new SelectItem[0];
		}
		return items;
	}

	public Fee getFilter() {
		if (filter == null)
			filter = new Fee();
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

	public String getBackLinkSearch() {
		return backLinkSearch;
	}

	public void setBackLinkSearch(String backLinkSearch) {
		this.backLinkSearch = backLinkSearch;
	}

	public String selectLimit() {
		MbLimitsSearch limitsBean = (MbLimitsSearch) ManagedBeanWrapper.getManagedBean("MbLimitsSearch");
		if (currentFee.getCycleId() != null) {
			limitsBean.getFilter().setCycleId(currentFee.getCycleId());
		}
		if (currentFee.getInstId() != null) {
			limitsBean.getFilter().setInstId(currentFee.getInstId());
		}
		if (currentFee.getLimitType() != null) {
			limitsBean.getFilter().setLimitType(currentFee.getLimitType());
		}
		limitsBean.setSelectMode(true);
		limitsBean.search();
		curMode = MODE_SELECT_LIMIT;

		// to restore state of MbFeesSearch (which is request scoped)
		keepState = true;

		// TODO: set some flag to block cycleId field on the form

		return "fcl|limits|list_limits";
	}

	public String selectCycle() {
		if (currentFee.getCycleType() != null) {
			MbCyclesSearch cyclesBean = (MbCyclesSearch) ManagedBeanWrapper.getManagedBean("MbCyclesSearch");
			cyclesBean.getFilter().setCycleType(currentFee.getCycleType());
			if (currentFee.getInstId() != null) {
				cyclesBean.getFilter().setInstId(currentFee.getInstId());
			}
			cyclesBean.setSelectMode(true);
			cyclesBean.setBlockCycleType(true);
			cyclesBean.search();
			curMode = MODE_SELECT_CYCLE;

			// to restore state of MbFeesSearch (which is request scoped)
			keepState = true;

			// TODO: set some flag to block cycleId field on the form

			return "fcl|cycles|list_cycles";
		}
		return "";
	}

	public void changeFeeType(ValueChangeEvent event) {
		FeeType newType = feeTypesMap.get((String) event.getNewValue());
		currentFee.setEntityType(newType.getEntityType());
		currentFee.setLimitType(newType.getLimitType());
		currentFee.setCycleType(newType.getCycleType());
	}

	public HashMap<String, FeeType> getFeeTypesMap() {
		return feeTypesMap;
	}

	public void setFeeTypesMap(HashMap<String, FeeType> feeTypesMap) {
		this.feeTypesMap = feeTypesMap;
	}

	public String getEntityType() {
		return entityType;
	}

	public void setEntityType(String entityType) {
		this.entityType = entityType;
	}

	public boolean isSelectMode() {
		return selectMode;
	}

	public void setSelectMode(boolean selectMode) {
		this.selectMode = selectMode;
	}

	public Fee getSearchFilter() {
		return searchFilter;
	}

	public void setSearchFilter(Fee searchFilter) {
		this.searchFilter = searchFilter;
	}

	public Fee getFeeById(Integer feeId) {
		return _feesDao.getFeeById(userSessionId, feeId);
	}

	public boolean isBlockFeeType() {
		return blockFeeType;
	}

	public void setBlockFeeType(boolean blockFeeType) {
		this.blockFeeType = blockFeeType;
	}

	public boolean isModalMode() {
		return modalMode;
	}

	public void setModalMode(boolean modalMode) {
		this.modalMode = modalMode;
	}

	public Fee getStoredActiveFee() {
		return storedActiveFee;
	}

	public void setStoredActiveFee(Fee storedActiveFee) {
		this.storedActiveFee = storedActiveFee;
	}

	public SimpleSelection getStoredItemSelection() {
		return storedItemSelection;
	}

	public void setStoredItemSelection(SimpleSelection storedItemSelection) {
		this.storedItemSelection = storedItemSelection;
	}

	public boolean isKeepState() {
		return keepState;
	}

	public void setKeepState(boolean keepState) {
		this.keepState = keepState;
	}

	public ArrayList<SelectItem> getInstitutions() {
		ArrayList<SelectItem> institutions = null;
		institutions = (ArrayList<SelectItem>) getDictUtils().getLov(LovConstants.INSTITUTIONS_SYS);
		if (institutions == null)
			institutions = new ArrayList<SelectItem>();
		return institutions;
	}

	public DictUtils getDictUtils() {
		if (dictUtils == null) {
			dictUtils = (DictUtils) ManagedBeanWrapper.getManagedBean("DictUtils");
		}
		return dictUtils;
	}
}
