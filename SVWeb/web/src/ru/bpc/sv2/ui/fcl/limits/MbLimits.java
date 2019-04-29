package ru.bpc.sv2.ui.fcl.limits;

import java.io.Serializable;
import java.util.ArrayList;


import ru.bpc.sv2.logic.utility.db.DataAccessException;
import javax.faces.bean.ManagedBean;
import javax.faces.bean.SessionScoped;
import javax.faces.model.SelectItem;

import org.apache.log4j.Logger;

import ru.bpc.sv2.constants.DictNames;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.constants.SystemConstants;
import ru.bpc.sv2.fcl.cycles.Cycle;
import ru.bpc.sv2.fcl.limits.Limit;
import ru.bpc.sv2.fcl.limits.LimitType;
import ru.bpc.sv2.logic.CyclesDao;
import ru.bpc.sv2.logic.LimitsDao;
import ru.bpc.sv2.ui.fcl.cycles.MbCycles;
import ru.bpc.sv2.ui.fcl.cycles.MbCyclesSearch;
import ru.bpc.sv2.ui.navigation.Menu;
import ru.bpc.sv2.ui.utils.DictUtils;
import ru.bpc.sv2.ui.utils.FacesUtils;
import util.auxil.ManagedBeanWrapper;

import util.auxil.SessionWrapper;

@SessionScoped
@ManagedBean (name = "MbLimits")
public class MbLimits implements Serializable {
	private static final long serialVersionUID = 1L;

	private static final Logger logger = Logger.getLogger("FCL");

	private LimitsDao _limitsDao = new LimitsDao();

	private CyclesDao _cyclesDao = new CyclesDao();

	private Limit _activeLimit;
	private Limit searchFilter;
	private boolean searching;
	private transient DictUtils dictUtils;
	private String backLink;
	private String backLinkSearch;
	private boolean selectMode;
	private ArrayList<SelectItem> counterAlgorithms;

	private boolean _managingNew;

	private int MODE_SELECT_CYCLE = 2;
	private int MODE_SELECT_LIMIT_TYPE = 1;
	private int MODE_LIMIT = 0;
	private int mode = 0;

	private Long userSessionId = null;

	public MbLimits() {
		userSessionId = SessionWrapper.getRequiredUserSessionId();
	}

	public Limit getLimitById(Long limitId) {
		return _limitsDao.getLimitById(userSessionId, limitId);
	}

	public Limit getActiveLimit() {
		if (mode == MODE_SELECT_LIMIT_TYPE) {
			MbLimitTypes limitsBean = (MbLimitTypes) ManagedBeanWrapper.getManagedBean("MbLimitTypes");
			LimitType limitType = limitsBean.getActiveLimitType();
			if (limitType != null) {
				_activeLimit.setLimitType(limitType.getLimitType());
				_activeLimit.setEntityType(limitType.getEntityType());
				_activeLimit.setCycleType(limitType.getCycleType());
			}
			setMode(MODE_LIMIT);
		}
		if (mode == MODE_SELECT_CYCLE) {
			MbCycles cyclesBean = (MbCycles) ManagedBeanWrapper.getManagedBean("MbCycles");
			Cycle cycle = cyclesBean.getActiveCycle();
			if (cycle != null) {
				_activeLimit.setCycleId(cycle.getId());
				_activeLimit.setCycleLength(Integer.toString(cycle.getCycleLength()));
				_activeLimit.setLengthType(cycle.getLengthType());
				_activeLimit.setTruncType(cycle.getTruncType());
			}
			setMode(MODE_LIMIT);
		}

		return _activeLimit;
	}

	public void setActiveLimit(Limit activeLimit) {
		_activeLimit = activeLimit;
	}

	public String createLimit() {
		_managingNew = true;

		return "open_details";
	}

	public String editLimit() {
		_managingNew = false;

		return "open_details";
	}

	public String save() {
		try {
			if (_managingNew) {
				MbLimitTypes limitTypesBean = (MbLimitTypes) ManagedBeanWrapper.getManagedBean("MbLimitTypes");
				LimitType limitType = limitTypesBean.getActiveLimitType();
				if (limitType != null) {
					_activeLimit.setEntityType(limitType.getEntityType());
					_activeLimit.setLimitType(limitType.getLimitType());
				}
				_limitsDao.createLimit(userSessionId, _activeLimit);
			} else {
				_limitsDao.updateLimit(userSessionId, _activeLimit);
			}

			FacesUtils.addMessageInfo("Limit \"" + _activeLimit.getId() + "\" saved");

			setSearchFilters();
			getDictUtils().readAllArticles();
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

	public boolean isManagingNew() {
		return _managingNew;
	}

	public void setManagingNew(boolean managingNew) {
		_managingNew = managingNew;
	}

	public ArrayList<SelectItem> getLimitTypes() {
		return getDictUtils().getArticles(DictNames.LIMIT_TYPES, true, false);
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

	public String cancel() {
		setSearchFilters();
		if (backLink != null && !backLink.equals("")) {

			return backLink;
		}
		_activeLimit = null;
		return "cancel";
	}

	public void setSearchFilters() {
		MbLimitsSearch limitsSearchBean = (MbLimitsSearch) ManagedBeanWrapper.getManagedBean("MbLimitsSearch");
		// limitsSearchBean.setSelectMode(true);
		// TODO make filters to store in session beans
		Limit filter = new Limit();
		filter.setInstId(_activeLimit.getInstId());
		filter.setEntityType(_activeLimit.getEntityType());

		limitsSearchBean.setFilter(filter);
	}

	public String getBackLink() {
		return backLink;
	}

	public void setBackLink(String backLink) {
		this.backLink = backLink;
	}

	public String selectLimitType() {
		MbLimitTypesSearch limitTypesSearchBean = (MbLimitTypesSearch) ManagedBeanWrapper
				.getManagedBean("MbLimitTypesSearch");
		limitTypesSearchBean.setSelectMode(true);
		LimitType filter = new LimitType();
		filter.setEntityType(_activeLimit.getEntityType());
		limitTypesSearchBean.setFilter(filter);
		setMode(MODE_SELECT_LIMIT_TYPE);

		Menu menu = (Menu) ManagedBeanWrapper.getManagedBean("menu");
		menu.setKeepState(true);

		return "fcl_limit_types";
	}

	public String selectCycle() {
		MbCyclesSearch cyclesSearchBean = (MbCyclesSearch) ManagedBeanWrapper.getManagedBean("MbCyclesSearch");
		cyclesSearchBean.setSelectMode(true);
		Cycle filter = new Cycle();
		filter.setCycleType(_activeLimit.getCycleType());

		filter.setInstId(_activeLimit.getInstId());
		cyclesSearchBean.setFilter(filter);
		setMode(MODE_SELECT_CYCLE);

		Menu menu = (Menu) ManagedBeanWrapper.getManagedBean("menu");
		menu.setKeepState(true);

		return "fcl_cycles";
	}

	public boolean isSelectMode() {
		return selectMode;
	}

	public void setSelectMode(boolean selectMode) {
		this.selectMode = selectMode;
	}

	public String getBackLinkSearch() {
		return backLinkSearch;
	}

	public void setBackLinkSearch(String backLinkSearch) {
		this.backLinkSearch = backLinkSearch;
	}

	public int getMode() {
		return mode;
	}

	public void setMode(int mode) {
		this.mode = mode;
	}

	public ArrayList<SelectItem> getPostMethods() {
		return getDictUtils().getArticles(DictNames.POSTING_METHOD, true);
	}

	public Limit getSearchFilter() {
		return searchFilter;
	}

	public void setSearchFilter(Limit searchFilter) {
		this.searchFilter = searchFilter;
	}

	public boolean isSelectLimitTypeMode() {
		return mode == MODE_SELECT_LIMIT_TYPE;
	}

	public boolean isSelectCycleMode() {
		return mode == MODE_SELECT_CYCLE;
	}

	public void clearState() {
		mode = MODE_LIMIT;
	}

	public boolean isSearching() {
		return searching;
	}

	public void setSearching(boolean searching) {
		this.searching = searching;
	}

	public DictUtils getDictUtils() {
		if (dictUtils == null) {
			dictUtils = (DictUtils) ManagedBeanWrapper.getManagedBean("DictUtils");
		}
		return dictUtils;
	}
	
	public ArrayList<SelectItem> getCounterAlgorithms(){
		if (counterAlgorithms == null){
			counterAlgorithms = (ArrayList<SelectItem>)getDictUtils().getLov(LovConstants.COUNTER_ALGORITHM);
		}
		return counterAlgorithms;
	}
}
