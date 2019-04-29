package ru.bpc.sv2.ui.fcl.limits;

import java.util.ArrayList;
import java.util.List;


import ru.bpc.sv2.logic.utility.db.DataAccessException;
import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.model.SelectItem;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;

import ru.bpc.sv2.constants.DictNames;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.constants.SystemConstants;
import ru.bpc.sv2.fcl.cycles.Cycle;
import ru.bpc.sv2.fcl.limits.Limit;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.invocation.Filter.Operator;
import ru.bpc.sv2.logic.CyclesDao;
import ru.bpc.sv2.logic.LimitsDao;
import ru.bpc.sv2.ui.navigation.Menu;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.TableRowSelection;
import util.auxil.ManagedBeanWrapper;

@ViewScoped
@ManagedBean (name = "MbLimitsSearch" )
public class MbLimitsSearch extends AbstractBean {
	private static final long serialVersionUID = -1124409091504082579L;

	private static final Logger logger = Logger.getLogger("FCL");

	private LimitsDao _limitsDao = new LimitsDao();

	private CyclesDao _cyclesDao = new CyclesDao();

	private Limit _activeLimit;
	private Limit filter;
	
	private String backLink;
	private boolean selectMode;
	private boolean showModal;
	private final DaoDataModel<Limit> _limitsSource;

	private final TableRowSelection<Limit> _itemSelection;

	private boolean _managingNew;
	private ArrayList<SelectItem> institutions;
	private MbLimits limitBean;

	public MbLimitsSearch() {
		pageLink = "fcl|limits|list_limits";
		limitBean = (MbLimits) ManagedBeanWrapper.getManagedBean("MbLimits");

		Menu menu = (Menu) ManagedBeanWrapper.getManagedBean("menu");
		if (!menu.isKeepState()) {
			limitBean.clearState();
		} else {
			// restore bean's state from session bean
			backLink = limitBean.getBackLinkSearch();
			searching = limitBean.isSearching();
			selectMode = limitBean.isSelectMode();
			filter = limitBean.getSearchFilter();

			if (limitBean.isSelectCycleMode() || limitBean.isSelectLimitTypeMode()) {
				showModal = true;
			}
		}

		_limitsSource = new DaoDataModel<Limit>() {
			private static final long serialVersionUID = -6523755153142106133L;

			@Override
			protected Limit[] loadDaoData(SelectionParams params) {
				if (!searching) {
					return new Limit[0];
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _limitsDao.getLimits(userSessionId, params);
				} catch (Exception e) {
					setDataSize(0);
					FacesUtils.addMessageError(e);
				}
				return new Limit[0];
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (!searching) {
					return 0;
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _limitsDao.getLimitsCount(userSessionId, params);
				} catch (Exception e) {
					FacesUtils.addMessageError(e);
				}
				return 0;
			}
		};

		_itemSelection = new TableRowSelection<Limit>(null, _limitsSource);
	}

	public DaoDataModel<Limit> getLimits() {
		return _limitsSource;
	}

	public Limit getActiveLimit() {
		return _activeLimit;
	}

	public void setActiveLimit(Limit activeLimit) {
		_activeLimit = activeLimit;
	}

	public SimpleSelection getItemSelection() {
		if (_activeLimit == null && _limitsSource.getRowCount() > 0) {
			setFirstRowActive();
		}
		return _itemSelection.getWrappedSelection();
	}

	public void setItemSelection(SimpleSelection selection) {
		_itemSelection.setWrappedSelection(selection);
		_activeLimit = _itemSelection.getSingleSelection();
	}

	public void setFirstRowActive() {
		_limitsSource.setRowIndex(0);
		SimpleSelection selection = new SimpleSelection();
		_activeLimit = (Limit) _limitsSource.getRowData();
		selection.addKey(_activeLimit.getModelId());
		_itemSelection.setWrappedSelection(selection);

	}

	public void load() {
		System.out.println("loaded");
	}

	public void createLimit() {
		if (_activeLimit != null)
			_itemSelection.unselect(_activeLimit);
		Limit tmp = new Limit();
		tmp.setEntityType(filter.getEntityType());
		tmp.setInstId(filter.getInstId());
		setActiveLimit(tmp);

		limitBean.setActiveLimit(tmp);
		limitBean.setManagingNew(true);
		// save bean's state
		limitBean.setSelectMode(this.selectMode);
		limitBean.setBackLinkSearch(this.backLink);
		limitBean.setSearchFilter(getFilter());
		_managingNew = true;
	}

	public void editLimit() {

		limitBean.setActiveLimit(_activeLimit);
		limitBean.setManagingNew(false);

		// save bean's state
		limitBean.setSelectMode(this.selectMode);
		limitBean.setBackLinkSearch(this.backLink);
		limitBean.setSearchFilter(getFilter());

		_managingNew = false;
	}

	public void deleteLimit() {
		try {

			_limitsDao.deleteLimit(userSessionId, _activeLimit);
			FacesUtils.addMessageInfo("Limit with id=\"" + _activeLimit.getId() + "\" was deleted");

			_activeLimit = _itemSelection.removeObjectFromList(_activeLimit);
			if (_activeLimit == null) {
				clearBean();
			}
		} catch (DataAccessException ee) {
			FacesUtils.addMessageError(ee);
			logger.error("", ee);
		}
	}

	public boolean isManagingNew() {
		return _managingNew;
	}

	public void setManagingNew(boolean managingNew) {
		_managingNew = managingNew;
	}

	public ArrayList<SelectItem> getLimitTypes() {
		return getDictUtils().getArticles(DictNames.LIMIT_TYPES, true);
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

	public void clearFilter() {
		filter = null;
		clearBean();
		setSearching(false);
	}

	public void search() {
		clearBean();
		limitBean.setSearchFilter(filter);
		setSearching(true);
	}

	public void setFilters() {
		filters = new ArrayList<Filter>();
		if (getFilter().getLimitType() != null && !getFilter().getLimitType().trim().equals("")) {
			Filter paramFilter = new Filter();
			paramFilter.setElement("limitType");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(getFilter().getLimitType());
			filters.add(paramFilter);
		}
		if (getFilter().getEntityType() != null && !getFilter().getEntityType().trim().equals("")) {
			Filter paramFilter = new Filter();
			paramFilter.setElement("entityType");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(getFilter().getEntityType());
			filters.add(paramFilter);
		}
		if (getFilter().getInstId() != null) {
			Filter paramFilter = new Filter();
			paramFilter.setElement("instId");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(getFilter().getInstId().toString());
			filters.add(paramFilter);
		}

		if (getFilter().getCurrency() != null) {
			Filter paramFilter = new Filter();
			paramFilter.setElement("currency");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(getFilter().getCurrency());
			filters.add(paramFilter);
		}

		if (getFilter().getPostMethod() != null) {
			Filter paramFilter = new Filter();
			paramFilter.setElement("postMethod");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(getFilter().getPostMethod());
			filters.add(paramFilter);
		}

	}

	public void clearBean() {
		if (_activeLimit != null) {
			if (_itemSelection != null) {
				_itemSelection.unselect(_activeLimit);
			}
			_activeLimit = null;
		}
		_limitsSource.flushCache();
	}

	public Limit getFilter() {
		if (filter == null) {
			filter = new Limit();
			filter.setInstId(userInstId);
		}
		return filter;
	}

	public void setFilter(Limit filter) {
		this.filter = filter;
	}

	public List<Filter> getFilters() {
		return filters;
	}

	public void setFilters(List<Filter> filters) {
		this.filters = filters;
	}

	public String cancel() {
		_activeLimit = null;
		if (backLink != null && !backLink.equals(""))
			return backLink;
		return "cancel";
	}

	public void setInstId(String instId) {
		Filter paramFilter = new Filter();
		paramFilter.setElement("instId");
		paramFilter.setOp(Operator.eq);
		paramFilter.setValue(instId);
		filters = new ArrayList<Filter>();
		filters.add(paramFilter);
	}

	public String toLimits() {
		_itemSelection.clearSelection();
		search();

		return "toLimits";
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
		MbLimits limitBean = (MbLimits) ManagedBeanWrapper.getManagedBean("MbLimits");
		limitBean.setActiveLimit(_activeLimit);
		return backLink;
	}

	public String cancelSelect() {
		MbLimits limitBean = (MbLimits) ManagedBeanWrapper.getManagedBean("MbLimits");
		limitBean.setActiveLimit(null);
		return backLink;
	}

	public ArrayList<SelectItem> getInstitutions() {
		if (institutions == null) {
			institutions = (ArrayList<SelectItem>) getDictUtils().getLov(LovConstants.INSTITUTIONS_SYS);
		}
		if (institutions == null)
			institutions = new ArrayList<SelectItem>();
		return institutions;
	}

	public boolean isShowModal() {
		return showModal;
	}

	public void setShowModal(boolean showModal) {
		this.showModal = showModal;
	}

	public void setSearching(boolean searching) {
		limitBean.setSearching(searching);
		this.searching = searching;
	}

}
