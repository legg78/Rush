package ru.bpc.sv2.ui.dashboard.widgets;

import java.io.Serializable;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.TimeZone;

import javax.annotation.PostConstruct;

import javax.faces.bean.ManagedBean;
import javax.faces.bean.RequestScoped;
import javax.faces.model.SelectItem;

import org.apache.log4j.Logger;
import org.openfaces.util.Faces;

import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.ProcessDao;
import ru.bpc.sv2.logic.WidgetsDao;
import ru.bpc.sv2.process.ProcessSession;
import ru.bpc.sv2.ui.dashboard.MbDashboard;
import ru.bpc.sv2.ui.utils.CommonUtils;
import ru.bpc.sv2.ui.utils.DictUtils;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.widget.Dashboard2WidgetItem;
import ru.bpc.sv2.widget.WidgetItem;
import ru.bpc.sv2.widget.WidgetParameter;
import util.auxil.ManagedBeanWrapper;
import util.auxil.SessionWrapper;

@RequestScoped
@ManagedBean (name = "MbProcessSessionsWidget")
public class MbProcessSessionsWidget implements Serializable {

	private static final long serialVersionUID = 1L;
	
	private static final Logger logger = Logger.getLogger("DASHBOARD");
	private static final String path = "/pages/widgets/process_sessions.jspx";

	private static final int LAST_PRC_QUANTITY = 10;

	private Long userSessionId = null;
	private String userLang;

	private HashMap<Integer, ProcessSessionsWidget> widgets;
	private Integer activeDashboardWidgetId;
	private Dashboard2WidgetItem newDashboardWidget;
	private Dashboard2WidgetItem savedDashboardWidget;

	private MbDashboard dashboardBean;
	private transient DictUtils dictUtils;
	private CommonUtils commonUtils;
	
	private ProcessDao _processDao = new ProcessDao();

	private WidgetsDao widgetDao = new WidgetsDao();

	public MbProcessSessionsWidget() {
		userSessionId = SessionWrapper.getRequiredUserSessionId();
		userLang = SessionWrapper.getField("language");
		dashboardBean = (MbDashboard) ManagedBeanWrapper.getManagedBean("MbDashboard");
		
		commonUtils = (CommonUtils) ManagedBeanWrapper.getManagedBean("CommonUtils");
	}

	@PostConstruct
	public void init() {
		Dashboard2WidgetItem[] dashboard2widgetList = dashboardBean.getCurrentDashboard()
				.getDashboard2widgetList();
		WidgetItem[] widgetList = dashboardBean.getCurrentDashboard().getWidgetList();

		widgets = new HashMap<Integer, ProcessSessionsWidget>(dashboard2widgetList.length);
		for (Dashboard2WidgetItem item : dashboard2widgetList) {
			for (WidgetItem widget : widgetList) {
				// check for path can be removed if it looks like too hardcoded
				if (path.equals(widget.getPath()) && widget.getId().equals(item.getWidgetId())) {
					widgets.put(item.getId(), new ProcessSessionsWidget(item.getId(), widget));
				}
			}
		}
	}

	public HashMap<Integer, ProcessSessionsWidget> getWidgets() {
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
				savedDashboardWidget = (Dashboard2WidgetItem) newDashboardWidget.clone();
			} else {
				newDashboardWidget = new Dashboard2WidgetItem();
				newDashboardWidget.setId(activeDashboardWidgetId);
				savedDashboardWidget = new Dashboard2WidgetItem();
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
			// boolean update = ((newDashboardWidget.getRefresh() ^
			// savedDashboardWidget.getRefresh())
			// || (newDashboardWidget.getRefresh() && (newDashboardWidget.getRefreshInterval()
			// != savedDashboardWidget.getRefreshInterval())));
			// if (newDashboardWidget.getRefresh() != null && savedDashboardWidget.getRefresh() !=
			// null) {
			// update = newDashboardWidget.getRefresh() ^ savedDashboardWidget.getRefresh();
			// } else {
			// update = true;
			// }
			// update = update || (newDashboardWidget.getRefresh() != null
			// && newDashboardWidget.getRefresh() && (newDashboardWidget
			// .getRefreshInterval() != savedDashboardWidget.getRefreshInterval()));
			// if (update) {
			// dashboardBean.updateCurrentDashboard();
			// init();
			// }
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

	public class ProcessSessionsWidget {
		private Integer dashboardWidgetId;
		private WidgetItem widget;
		private ProcessSession[] sessionsList = null;
		private List<WidgetParameter> widgetParameters;
		private HashMap<String, WidgetParameter> paramsMap;
		protected List<Filter> filters;

		public ProcessSessionsWidget(Integer id, WidgetItem item) {
			dashboardWidgetId = id;
			widget = item;
		}

		public ProcessSession[] getSessionsList() {
			if (sessionsList == null) {
				SelectionParams params = new SelectionParams();
				setFilters();
				params.setFilters(filters.toArray(new Filter[filters.size()]));
				params.setRowIndexEnd(-1);
				try {
					sessionsList = _processDao.getProcessSessionHierarchy(userSessionId, params);
				} catch (Exception e) {
					logger.error("", e);
					FacesUtils.addMessageError(e);
					sessionsList = new ProcessSession[0];
				}
			}
			return sessionsList;
		}

		public void setFilters() {
			filters = new ArrayList<Filter>();

			Filter paramFilter = new Filter();
			paramFilter.setElement("lang");
			paramFilter.setValue(userLang);
			filters.add(paramFilter);

			String dbDateFormat = "dd.MM.yyyy";
			SimpleDateFormat df = new SimpleDateFormat(dbDateFormat);
			df.setTimeZone(TimeZone.getTimeZone(commonUtils.getTimeZoneId()));
			paramFilter = new Filter();
			paramFilter.setElement("startDate");
			paramFilter.setValue(df.format(new Date()));
			filters.add(paramFilter);

			Calendar calendar = Calendar.getInstance();
			calendar.setTime(new Date());
			calendar.add(Calendar.DAY_OF_MONTH, 1);
			paramFilter = new Filter();
			paramFilter.setElement("endDate");
			paramFilter.setValue(df.format(calendar.getTime()));
			filters.add(paramFilter);

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
				// all filters are from "get-devices" query of HsmSqlMap.xml
				if (paramsMap.get("id") != null) {
					addFilter("id", filters);
				}
				if (paramsMap.get("type") != null) {
					addFilter("type", filters);
				}
				if (paramsMap.get("plugin") != null) {
					addFilter("plugin", filters);
				}
				if (paramsMap.get("lmkId") != null) {
					addFilter("lmkId", filters);
				}
				if (paramsMap.get("manufacturer") != null) {
					addFilter("manufacturer", filters);
				}
				if (paramsMap.get("serialNumber") != null) {
					addFilter("serialNumber", filters);
				}
				if (paramsMap.get("isEnabled") != null) {
					addFilter("isEnabled", filters);
				}
				if (paramsMap.get("desKeyPrefix") != null) {
					addFilter("desKeyPrefix", filters);
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

		public void refreshHsms() {
			sessionsList = null;
			widgetParameters = null;
			paramsMap = null;
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
