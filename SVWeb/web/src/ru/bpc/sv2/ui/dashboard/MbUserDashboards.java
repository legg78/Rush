package ru.bpc.sv2.ui.dashboard;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.event.ValueChangeEvent;
import javax.faces.model.SelectItem;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;

import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.Filter.Operator;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.WidgetsDao;
import ru.bpc.sv2.ui.session.UserSession;
import ru.bpc.sv2.ui.utils.*;
import ru.bpc.sv2.widget.Dashboard;
import util.auxil.ManagedBeanWrapper;

/**
 * Manage Bean for List Dashboards page.
 */
@ViewScoped
@ManagedBean (name = "MbUserDashboards")
public class MbUserDashboards extends AbstractBean {
	private static final Logger logger = Logger.getLogger("DASHBOARD");

	private static String COMPONENT_ID = "2123:mainTable";

	private WidgetsDao _widgetDao = new WidgetsDao();
	
	private Dashboard _activeDashboard;
	private Dashboard newDashboard;
	private Dashboard detailDashboard;
	
	private Dashboard dashboardFilter;

	private boolean selectMode;

	private final DaoDataModel<Dashboard> _dashboardsSource;

	private final TableRowSelection<Dashboard> _dashboardSelection;
	
	private List<SelectItem> institutions;
	private UserSession us;

	public MbUserDashboards() {
		pageLink = "acm|dashboards";
		us = (UserSession)ManagedBeanWrapper.getManagedBean("usession");
		
		_dashboardsSource = new DaoDataModel<Dashboard>() {
			@Override
			protected Dashboard[] loadDaoData(SelectionParams params) {
				if (!isSearching())
					return new Dashboard[0];
				try {
					setDashboardsFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _widgetDao.getDashboards(userSessionId, params);
				} catch (Exception e) {
					setDataSize(0);
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return new Dashboard[0];
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (!isSearching())
					return 0;
				try {
					setDashboardsFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _widgetDao.getDashboardsCount(userSessionId, params);
				} catch (Exception e) {
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return 0;
			}
		};
		_dashboardSelection = new TableRowSelection<Dashboard>(null, _dashboardsSource);
		restoreFilter();
	}

	public DaoDataModel<Dashboard> getDashboards() {
		return _dashboardsSource;
	}

	public Dashboard getActiveDashboard() {
		return _activeDashboard;
	}

	public void setActiveDashboard(Dashboard activeDashboard) {
		this._activeDashboard = activeDashboard;
	}

	public SimpleSelection getDashboardSelection() {
		try {
			if (_activeDashboard == null && _dashboardsSource.getRowCount() > 0) {
				_dashboardsSource.setRowIndex(0);
				SimpleSelection selection = new SimpleSelection();
				_activeDashboard = (Dashboard) _dashboardsSource.getRowData();
				detailDashboard = (Dashboard) _activeDashboard.clone();
				selection.addKey(_activeDashboard.getModelId());
				_dashboardSelection.setWrappedSelection(selection);
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}	
		return _dashboardSelection.getWrappedSelection();
	}

	public void setDashboardSelection(SimpleSelection selection) {
		try {
			_dashboardSelection.setWrappedSelection(selection);
			boolean changeSelect = false;
			if (_dashboardSelection.getSingleSelection() != null 
					&& !_dashboardSelection.getSingleSelection().getId().equals(_activeDashboard.getId())) {
				changeSelect = true;
			}
			_activeDashboard = _dashboardSelection.getSingleSelection();
			if (changeSelect) {
				detailDashboard = (Dashboard) _activeDashboard.clone();
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}	
	}

	public void search() {
		clearBean();
		searching = true;
	}

	public void clearFilter() {
		dashboardFilter = null;
		clearBean();
	}

	public void clearBean() {
		searching = false;
		curLang = userLang;
		_dashboardsSource.flushCache();
		if (_dashboardSelection != null) {
			_dashboardSelection.clearSelection();
		}
		_activeDashboard = null;
		detailDashboard = null;
	}

	public void add() {
		newDashboard = new Dashboard();
		newDashboard.setLang(userLang);
		newDashboard.setUserId(us.getUser().getId());
		curLang = newDashboard.getLang();
		curMode = NEW_MODE;
	}
	
	public void edit() {
		try {
			newDashboard = (Dashboard) detailDashboard.clone();
		} catch (CloneNotSupportedException e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
		curMode = EDIT_MODE;
	}

	public void save() {
		try {
			if (isEditMode()) {
				newDashboard = _widgetDao.editDashboard(userSessionId, newDashboard);
				detailDashboard = (Dashboard) newDashboard.clone();
				if (!userLang.equals(newDashboard.getLang())) {
					newDashboard = getNodeByLang(_activeDashboard.getId(), userLang);
				}
				_dashboardsSource.replaceObject(_activeDashboard, newDashboard);
			} else {
				newDashboard = _widgetDao.addDashboard(userSessionId, newDashboard);
				detailDashboard = (Dashboard) newDashboard.clone();
				_dashboardSelection.addNewObjectToList(newDashboard);
			}
			_activeDashboard = newDashboard;
			us.resetDashboards();
			FacesUtils.addMessageInfo("Saved!");
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);

		}
	}

	public void delete() {
		try {
			_widgetDao.removeDashboard(userSessionId, _activeDashboard);
			FacesUtils.addMessageInfo("Dashboard (id = " + _activeDashboard.getId()
					+ ") has been deleted.");

			_activeDashboard = _dashboardSelection.removeObjectFromList(_activeDashboard);
			if (_activeDashboard == null) {
				clearBean();
			} else {
				detailDashboard = (Dashboard) _activeDashboard.clone();
			}
			us.resetDashboards();
			curMode = VIEW_MODE;
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void cancel() {
		
	}

	public void setDashboardsFilters() {
		filters = new ArrayList<Filter>();
		
		Filter paramFilter;
		paramFilter = new Filter();
		paramFilter.setElement("lang");
		paramFilter.setOp(Operator.eq);
		paramFilter.setValue(userLang);
		filters.add(paramFilter);
		
		if (getDashboardFilter().getId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("id");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(getDashboardFilter().getId());
			filters.add(paramFilter);
		}
		
		if (getDashboardFilter().getName() != null && !getDashboardFilter().getName().equals("")) {
			paramFilter = new Filter();
			paramFilter.setElement("name");
			paramFilter.setOp(Operator.like);
			paramFilter.setValue(getDashboardFilter().getName()
					.replaceAll("[*]", "%").replaceAll("[?]", "_"));
			filters.add(paramFilter);
		}
		
		if (getDashboardFilter().getUserId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("userId");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(getDashboardFilter().getUserId());
			filters.add(paramFilter);
		}
		
	}

	public Dashboard getDashboardFilter() {
		if (dashboardFilter == null)
			dashboardFilter = new Dashboard();
		return dashboardFilter;
	}

	public void setDashboardFilter(Dashboard dashboardFilter) {
		this.dashboardFilter = dashboardFilter;
	}

	public boolean isSelectMode() {
		return selectMode;
	}

	public void setSelectMode(boolean selectMode) {
		this.selectMode = selectMode;
	}

	public Dashboard getNewDashboard() {
		return newDashboard;
	}

	public void setNewDashboard(Dashboard newDashboard) {
		this.newDashboard = newDashboard;
	}

	public String getComponentId() {
		return COMPONENT_ID;
	}

	public Logger getLogger() {
		return logger;
	}

	public List<SelectItem> getInstitutions() {
		if (institutions == null) {
			institutions = getDictUtils().getLov(LovConstants.INSTITUTIONS);
		}
		return institutions;
	}
	
	public void changeLanguage(ValueChangeEvent event) {
		curLang = (String) event.getNewValue();
		detailDashboard = getNodeByLang(detailDashboard.getId(), curLang);
	}
	
	public Dashboard getNodeByLang(Integer id, String lang) {
		Filter[] filters = new Filter[2];
		filters[0] = new Filter();
		filters[0].setElement("id");
		filters[0].setValue(id.toString());
		filters[1] = new Filter();
		filters[1].setElement("lang");
		filters[1].setValue(lang);

		SelectionParams params = new SelectionParams();
		params.setFilters(filters);
		try {
			Dashboard[] items = _widgetDao.getDashboards(userSessionId, params);
			if (items != null && items.length > 0) {
				return items[0];
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
		return null;
	}
	
	public void confirmEditLanguage() {
		curLang = newDashboard.getLang();
		Dashboard tmp = getNodeByLang(newDashboard.getId(), newDashboard.getLang());
		if (tmp != null) {
			newDashboard.setName(tmp.getName());
			newDashboard.setDescription(tmp.getDescription());
		}
	}
	
	public String customize() {
		HashMap<String,Object> queueFilter = new HashMap<String,Object>();
		
		queueFilter.put("backLink", pageLink);
		queueFilter.put("dashboardsFilter", getDashboardFilter());
		queueFilter.put("currentDashboardId", _activeDashboard.getId());
		
		addFilterToQueue("MbDashboardCustomization", queueFilter);
		
		
		return "acm_dashboard_customization";
	}
	
	public String view() {
		HashMap<String,Object> queueFilter = new HashMap<String,Object>();
		
		queueFilter.put("currentDashboardId", _activeDashboard.getId());
		addFilterToQueue("MbDashboard", queueFilter);

		return "acm_dashboard";
	}

	public Dashboard getDetailDashboard() {
		return detailDashboard;
	}

	public void setDetailDashboard(Dashboard detailDashboard) {
		this.detailDashboard = detailDashboard;
	}
	
	private void restoreFilter(){
		HashMap<String,Object> queueFilter = getQueueFilter("MbUserDashboards");
		if (queueFilter==null)
			return;
		clearFilter();
		if (queueFilter.containsKey("dashboardsFilter")){
			setDashboardFilter((Dashboard)queueFilter.get("dashboardsFilter"));
		}
		search();
	}

	@Override
	protected void applySectionFilter(Integer filterId) {
		try {
			FilterFactory factory = (FilterFactory) ManagedBeanWrapper
					.getManagedBean("filterFactory");
			Map<String, String> filterRec = factory.getSectionFilterRecs(filterId);
			sectionFilter = factory.getUserSectionFiltersObjects().get(filterId);
			if (filterRec != null) {
				dashboardFilter = new Dashboard();
				if (filterRec.get("name") != null) {
					dashboardFilter.setName(filterRec.get("name"));
				}
			}
			if (searchAutomatically) {
				search();
			}
			sectionFilterModeEdit = true;
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	@Override
	public void saveSectionFilter() {
		try {
			FilterFactory factory = (FilterFactory) ManagedBeanWrapper
					.getManagedBean("filterFactory");

			Map<String, String> filterRec = new HashMap<String, String>();
			dashboardFilter = getDashboardFilter();
			if (dashboardFilter.getName() != null) {
				filterRec.put("name", dashboardFilter.getName());
			}
			sectionFilter = getSectionFilter();
			sectionFilter.setRecs(filterRec);

			factory.saveSectionFilter(sectionFilter, sectionFilterModeEdit);
			selectedSectionFilter = sectionFilter.getId();
			sectionFilterModeEdit = true;
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}
}
