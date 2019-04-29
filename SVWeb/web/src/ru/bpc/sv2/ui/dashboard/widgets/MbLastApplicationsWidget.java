package ru.bpc.sv2.ui.dashboard.widgets;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

import javax.annotation.PostConstruct;

import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.model.SelectItem;

import org.apache.log4j.Logger;
import org.openfaces.util.Faces;

import ru.bpc.sv2.application.Application;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.invocation.SortElement;
import ru.bpc.sv2.invocation.SortElement.Direction;
import ru.bpc.sv2.logic.ApplicationDao;
import ru.bpc.sv2.logic.WidgetsDao;
import ru.bpc.sv2.ui.dashboard.MbDashboard;
import ru.bpc.sv2.ui.utils.DictUtils;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.widget.Dashboard2WidgetItem;
import ru.bpc.sv2.widget.WidgetItem;
import ru.bpc.sv2.widget.WidgetParameter;
import util.auxil.ManagedBeanWrapper;
import util.auxil.SessionWrapper;

@ViewScoped
@ManagedBean (name = "MbLastApplicationsWidget")
public class MbLastApplicationsWidget implements Serializable {
	private static final long serialVersionUID = 1L;
	
	private static final Logger logger = Logger.getLogger("DASHBOARD");
	private static final String path = "/pages/widgets/last_applications.jspx";
		
	private static final int LAST_APP_QUANTITY = 5;

	private Long userSessionId = null;
	private String userLang;

	private HashMap<Integer, LastApplicationsWidget> widgets;
	private Integer activeDashboardWidgetId;
	private Dashboard2WidgetItem newDashboardWidget;
	
	private MbDashboard dashboardBean;
	private transient DictUtils dictUtils;
	
	private ApplicationDao appDao = new ApplicationDao();

	private WidgetsDao widgetDao = new WidgetsDao();

	public MbLastApplicationsWidget() {
		userSessionId = SessionWrapper.getRequiredUserSessionId();
		userLang = SessionWrapper.getField("language");
		dashboardBean = (MbDashboard) ManagedBeanWrapper.getManagedBean("MbDashboard");
	}

	@PostConstruct
	public void init() {
		Dashboard2WidgetItem[] dashboard2widgetList = dashboardBean.getCurrentDashboard().getDashboard2widgetList();
		WidgetItem[] widgetList = dashboardBean.getCurrentDashboard().getWidgetList();
		
		widgets = new HashMap<Integer, LastApplicationsWidget>(dashboard2widgetList.length);
		for (Dashboard2WidgetItem item : dashboard2widgetList) {
			for (WidgetItem widget : widgetList) {
				// check for path can be removed if it looks like too hardcoded 
				if (path.equals(widget.getPath()) && widget.getId().equals(item.getWidgetId())) {
					widgets.put(item.getId(), new LastApplicationsWidget(item.getId(), widget));
				}
			}
		}
	}
	
	public HashMap<Integer, LastApplicationsWidget> getWidgets() {
		return widgets;
	}

	public Integer getActiveDashboardWidgetId() {
		return activeDashboardWidgetId;
	}

	public void setActiveDashboardWidgetId(Integer activeDashboardWidgetId) {
		this.activeDashboardWidgetId = activeDashboardWidgetId;
	}

	public void editDashboardWidget() {
		Filter[] filters = new Filter[1];
		filters[0] = new Filter("id", activeDashboardWidgetId);

		SelectionParams params = new SelectionParams();
		params.setFilters(filters);
		try {
			Dashboard2WidgetItem[] items = widgetDao.getDashboardWidgets(userSessionId, params);
			if (items != null && items.length > 0) {
				newDashboardWidget = items[0];
			} else {
				newDashboardWidget = new Dashboard2WidgetItem();
				newDashboardWidget.setId(activeDashboardWidgetId);
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void saveDashboardWidget() {
		try {
			newDashboardWidget = widgetDao.editDashboardWidget(userSessionId, newDashboardWidget,
					widgets.get(activeDashboardWidgetId).getWidgetParamsForSave());
			FacesUtils.addMessageInfo("Saved!");
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void cancel() {
		
	}
	
	public Dashboard2WidgetItem getNewDashboardWidget() {
		return newDashboardWidget;
	}

	public void setNewDashboardWidget(Dashboard2WidgetItem newDashboardWidget) {
		this.newDashboardWidget = newDashboardWidget;
	}

	public List<WidgetParameter> getWidgetParams() {
		if (activeDashboardWidgetId == null) {
			return new ArrayList<WidgetParameter>(0);
		}
		List<WidgetParameter> params = widgets.get(activeDashboardWidgetId).getWidgetParams();
		if (params == null || params.size() == 0) {
			params = new ArrayList<WidgetParameter>(1);
			params.add(new WidgetParameter());
		}
		return params;
	}
	
	public List<SelectItem> getLovValues() {
		WidgetParameter param = (WidgetParameter) Faces.var("widgetParam");
		return getDictUtils().getLov(param.getLovId());
	}

	public class LastApplicationsWidget {
		private Integer dashboardWidgetId;
		private WidgetItem widget;
		private List<Application> lastApplications = null;
		private List<WidgetParameter> widgetParameters;
		private HashMap<String, WidgetParameter> paramsMap;
		
		public LastApplicationsWidget(Integer id, WidgetItem item) {
			dashboardWidgetId = id;
			widget = item;
		}
		
		public List<Application> getLastApplications() {
			if (lastApplications == null) {
				List<Filter> filters = getFilters();
				SelectionParams params = new SelectionParams();
				params.setFilters(filters);
				params.setRowIndexEnd(LAST_APP_QUANTITY - 1);
				SortElement srt = new SortElement("id", Direction.DESC);
				SortElement[] sortArr = new SortElement[1];
				sortArr[0] = srt;
				params.setSortElement(sortArr);
				try {
					lastApplications = appDao.getApplications(userSessionId, params);
				} catch (Exception e) {
					logger.error("", e);
					FacesUtils.addMessageError(e);
				}
			}
			return lastApplications;
		}

		public List<WidgetParameter> getWidgetParamsForSave() {
			if (widgetParameters == null)
				return getWidgetParams();
			return widgetParameters;
		}

		public List<WidgetParameter> getWidgetParams() {
			Filter[] filters = new Filter[3];
			filters[0] = new Filter("lang", userLang);
			filters[1] = new Filter("dashboardWidgetId", dashboardWidgetId);
			filters[2] = new Filter("widgetId", widget.getId());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);
			params.setRowIndexEnd(Integer.MAX_VALUE);
			try {
				WidgetParameter[] wParams = widgetDao.getWidgetParamsWithValues(userSessionId,
						params);
				widgetParameters = new ArrayList<WidgetParameter>(wParams.length);
				paramsMap = new HashMap<String, WidgetParameter>(wParams.length);
				for (WidgetParameter param : wParams) {
					if (param.getDashboardWidgetId() == null) {
						param.setDashboardWidgetId(dashboardWidgetId);
					}
					widgetParameters.add(param);
					paramsMap.put(param.getSystemName(), param);
				}
			} catch (Exception e) {
				logger.error("", e);
				FacesUtils.addMessageError(e);
				return new ArrayList<WidgetParameter>(0);
			}
			return widgetParameters;
		}

		private List<Filter> getFilters() {
			List<Filter> filters = new ArrayList<Filter>();
			filters.add(new Filter("lang", userLang));
			
			if (getWidgetParams() != null) {
				// TODO: add applications filters (see ApplicationsSqlMap.xml "get-apps")
				if (paramsMap.get("id") != null) {
					addFilter("id", filters);
				}
				if (paramsMap.get("type") != null) {
					addFilter("type", filters);
				}
			}
			return filters;
		}
		
		private void addFilter(String name, List<Filter> filters) {
			Filter filter = new Filter();
			if (paramsMap.get(name).isChar()) {
				if (paramsMap.get(name).getValueV() == null) {
					return;
				}
				filter.setValue(paramsMap.get(name).getValueV());
			} else if (paramsMap.get(name).isNumber()) {
				if (paramsMap.get(name).getValueN() == null) {
					return;
				}
				filter.setValue(paramsMap.get(name).getValueN());
			} else if (paramsMap.get(name).isDate()) {
				if (paramsMap.get(name).getValueD() == null) {
					return;
				}
				filter.setValue(paramsMap.get(name).getValueD());
			} else {
				return;
			}
			filter.setElement(name);
			
			filters.add(filter);
		}

		public void refreshApplications() {
			lastApplications = null;
		}

		public WidgetItem getWidget() {
			return widget;
		}
	}

	public DictUtils getDictUtils() {
		if (dictUtils == null) {
			dictUtils = (DictUtils) ManagedBeanWrapper.getManagedBean("DictUtils");
		}
		return dictUtils;
	}
}
