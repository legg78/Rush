package ru.bpc.sv2.ui.fcl.limits;

import java.io.Serializable;

import ru.bpc.sv2.fcl.limits.LimitType;
import util.auxil.ManagedBeanWrapper;

import javax.faces.bean.ManagedBean;
import javax.faces.bean.SessionScoped;

@SessionScoped
@ManagedBean (name = "MbLimitTypes")
public class MbLimitTypes implements Serializable {
	private static final long serialVersionUID = 1L;

	private LimitType _activeLimitType;

	private String backLink;
	private String backLinkSearch;
	private boolean selectMode;
	private boolean restoreState = false;
	private LimitType searchFilter;
	private String tabName;

	private boolean _managingNew;

	public MbLimitTypes() {
	}

	public LimitType getActiveLimitType() {
		return _activeLimitType;
	}

	public void setActiveLimitType(LimitType activeLimitType) {
		_activeLimitType = activeLimitType;
	}

	public boolean isManagingNew() {
		return _managingNew;
	}

	public void setManagingNew(boolean managingNew) {
		_managingNew = managingNew;
	}

	public String cancel() {
		setSearchFilters();
		if (backLink != null && !backLink.equals("")) {

			return backLink;
		}
		_activeLimitType = null;

		return "cancel";
	}

	public void setSearchFilters() {
		MbLimitTypesSearch limitTypesSearchBean = (MbLimitTypesSearch) ManagedBeanWrapper
				.getManagedBean("MbLimitTypesSearch");
		limitTypesSearchBean.setSelectMode(true);
		// TODO make filters to store in session beans
		LimitType filter = new LimitType();
		filter.setEntityType(_activeLimitType.getEntityType());

		limitTypesSearchBean.setFilter(filter);
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

	public boolean isSelectMode() {
		return selectMode;
	}

	public void setSelectMode(boolean selectMode) {
		this.selectMode = selectMode;
	}

	public boolean isRestoreState() {
		return restoreState;
	}

	public void setRestoreState(boolean restoreState) {
		this.restoreState = restoreState;
	}

	public LimitType getSearchFilter() {
		return searchFilter;
	}

	public void setSearchFilter(LimitType searchFilter) {
		this.searchFilter = searchFilter;
	}

	public void close() {

	}

	public String getTabName() {
		return tabName;
	}

	public void setTabName(String tabName) {
		this.tabName = tabName;
	}

}
