package ru.bpc.sv2.ui.fcl.cycles;

import java.io.Serializable;
import java.util.ArrayList;



import javax.faces.bean.ManagedBean;
import javax.faces.bean.SessionScoped;
import javax.faces.model.SelectItem;

import ru.bpc.sv2.constants.DictNames;
import ru.bpc.sv2.fcl.cycles.Cycle;
import ru.bpc.sv2.logic.CyclesDao;
import ru.bpc.sv2.ui.utils.DictUtils;
import util.auxil.ManagedBeanWrapper;

import util.auxil.SessionWrapper;

@SessionScoped
@ManagedBean (name = "MbCycles")
public class MbCycles implements Serializable {
	private static final long serialVersionUID = 1L;

	private CyclesDao _cyclesDao = new CyclesDao();

	private Cycle _activeCycle;
	private transient DictUtils dictUtils; 
	private String backLink;
	private String backLinkSearch;
	private boolean selectMode;

	private Cycle searchFilter;
	private boolean	_managingNew;
	private boolean searching;
	private boolean blockCycleType;
	
	private Long userSessionId = null;

	public MbCycles() {
		userSessionId = SessionWrapper.getRequiredUserSessionId();
	}

	public Cycle getCycleById(Integer cycleId) {
		return _cyclesDao.getCycleById( userSessionId, cycleId);
	}
	
	public Cycle getActiveCycle()
	{
		return _activeCycle;
	}

	public void setActiveCycle( Cycle activeCycle )
	{
		_activeCycle = activeCycle;
	}

	public String cancel()
	{
		if (backLink != null && !backLink.equals("")){
			return backLink;
		}

		_activeCycle = null;
		return "cancel";
	}

	public boolean isManagingNew()
	{
		return _managingNew;
	}

	public void setManagingNew( boolean managingNew )
	{
		_managingNew = managingNew;
	}

	public ArrayList<SelectItem> getCycleTypes() {
		return getDictUtils().getArticles(DictNames.CYCLE_TYPES, true, true);
	}

	public ArrayList<SelectItem> getLengthTypes() {
		return getDictUtils().getArticles(DictNames.LENGTH_TYPES, true, false);
	}

	public ArrayList<SelectItem> getTruncTypes() {
		return getDictUtils().getArticles(DictNames.LENGTH_TYPES, true, false);
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

	public Cycle getSearchFilter() {
		return searchFilter;
	}

	public void setSearchFilter(Cycle searchFilter) {
		this.searchFilter = searchFilter;
	}

	public boolean isSearching() {
		return searching;
	}

	public void setSearching(boolean searching) {
		this.searching = searching;
	}

	// TODO: do we need this? 
	public boolean isBlockCycleType() {
		return blockCycleType;
	}

	// TODO: do we need this? 
	public void setBlockCycleType(boolean blockCycleType) {
		this.blockCycleType = blockCycleType;
	}

	public String getDictCycleType() {
		return DictNames.CYCLE_TYPES;
	}

	public DictUtils getDictUtils() {
		if (dictUtils == null) {
			dictUtils = (DictUtils) ManagedBeanWrapper.getManagedBean("DictUtils");
		}
		return dictUtils;
	}
}
