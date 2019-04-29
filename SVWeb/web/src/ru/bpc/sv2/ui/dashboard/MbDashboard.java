package ru.bpc.sv2.ui.dashboard;

import org.ajax4jsf.model.KeepAlive;
import org.apache.log4j.Logger;
import org.openfaces.component.chart.ChartModel;
import org.openfaces.component.chart.PlainModel;
import org.openfaces.component.chart.PlainSeries;
import org.openfaces.component.chart.Tuple;

import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.constants.SystemConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.WidgetsDao;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.widget.Dashboard;
import ru.bpc.sv2.widget.Dashboard2WidgetItem;
import ru.bpc.sv2.widget.DashboardInfo;
import ru.bpc.sv2.widget.WidgetItem;
import ru.bpc.sv2.widget.WidgetParameter;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.RequestScoped;
import javax.faces.model.SelectItem;

import java.util.ArrayList;
import java.util.Comparator;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.TreeMap;

@RequestScoped
@KeepAlive
@ManagedBean (name = "MbDashboard")
public class MbDashboard extends AbstractBean {
	private static final Logger logger = Logger.getLogger("DASHBOARD");

	private WidgetItem[] widgetList;
	private Integer currentDashboardId;
	private DashboardInfo currentDashboard;
	private String paramsPath;
	private WidgetParameter newParameter;
	
	private Integer activeDashboardWidgetId;
	private Integer activeWidgetId;
	private String activeDashboardWidgetForm;
	private String refreshWidgetFunction;
	
	private WidgetsDao widgetDao = new WidgetsDao();
	
	private List<SelectItem> dataTypes;

	
	
	public MbDashboard() {
		init();
	}
	
	private void init(){
		restoreFilter();
	}
	
	private void restoreFilter(){
		HashMap<String,Object> queueFilter = getQueueFilter("MbDashboard");

		if (queueFilter==null)
			return;
		if (queueFilter.containsKey("currentDashboardId")){
			setCurrentDashboardId(Integer.valueOf(queueFilter.get("currentDashboardId").toString()));
		}
	}
	
	private WidgetItem[] getWidgetList() {
		if (widgetList == null) {
			// FIXME! Just for testing. DAO method should be used instead!
			Filter[] filters = new Filter[1];
			filters[0] = new Filter();
			filters[0].setElement("lang");
			filters[0].setValue(curLang);

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);
			params.setRowIndexEnd(-1);
			widgetList = widgetDao.getWidgets(userSessionId, params);
		}
		return widgetList;
	}

	public void setWidgetList(WidgetItem[] widgetList) {
		this.widgetList = widgetList;
	}

	public DashboardInfo getCurrentDashboard() {
		if (currentDashboard == null) {
			updateCurrentDashboard();
		}

		return currentDashboard;
	}

	public void setCurrentDashboard(DashboardInfo currentDashboard) {
		this.currentDashboard = currentDashboard;
	}

	public Integer getCurrentDashboardId() {
		return currentDashboardId;
	}

	public void setCurrentDashboardId(Integer currentDashboardId) {
		this.currentDashboardId = currentDashboardId;
	}

	public void updateCurrentDashboard() {
		Filter[] filters = new Filter[2];
		filters[0] = new Filter();
		filters[0].setElement("id");
		filters[0].setValue(getCurrentDashboardId());
		filters[1] = new Filter();
		filters[1].setElement("lang");
		filters[1].setValue(curLang);

		SelectionParams params = new SelectionParams();
		params.setFilters(filters);

		Dashboard[] dashboardItems = widgetDao.getDashboards(userSessionId, params);
		if (dashboardItems != null && dashboardItems.length > 0) {
			filters = new Filter[1];
			filters[0] = new Filter();
			filters[0].setElement("dashboardId");
			filters[0].setValue(dashboardItems[0].getId());

			params = new SelectionParams();
			params.setFilters(filters);
			params.setRowIndexEnd(-1);
			Dashboard2WidgetItem[] widgetPositionsList = widgetDao.getDashboardWidgets(
					userSessionId, params);

			currentDashboard = new DashboardInfo(dashboardItems[0], widgetPositionsList,
					getWidgetList());
		}
	}

	public void cancel() {

	}

	public ChartModel getPopulation() {
		PlainModel model = new PlainModel();
		PlainSeries series = null;
		Map<String, Integer> data = null;

		data = new TreeMap<String, Integer>();
		data.put("Monday", new Integer(6000));
		data.put("Tuesday", new Integer(5500));
		data.put("Wednesday", new Integer(7100));
		data.put("Thursday", new Integer(6800));
		data.put("Friday", new Integer(5900));
		series = new PlainSeries();
		series.setData(data);
		series.setKey("In");
		Comparator<Tuple> comparator = new Comparator<Tuple>() {
			@Override
			public int compare(Tuple o1, Tuple o2) {
				return 0;
			}
		};

		series.setComparator(comparator);
		model.addSeries(series);

		data = new TreeMap<String, Integer>();
		data.put("Monday", new Integer(10000));
		data.put("Tuesday", new Integer(12000));
		data.put("Wednesday", new Integer(11000));
		data.put("Thursday", new Integer(11500));
		data.put("Friday", new Integer(13000));
		series = new PlainSeries();
		series.setData(data);
		series.setKey("Out");
		model.addSeries(series);

		return model;
	}

	public int getRowsNumber() {
		return DashboardInfo.ROWS; 
	}

	public int getColumnsNumber() {
		return DashboardInfo.COLUMNS; 
	}

	public String getParamsPath() {
		if (paramsPath == null || paramsPath.isEmpty()) {
			return SystemConstants.EMPTY_PAGE;
		}
		return paramsPath;
	}

	public void setParamsPath(String paramsPath) {
		this.paramsPath = paramsPath;
	}

	public Integer getActiveDashboardWidgetId() {
		return activeDashboardWidgetId;
	}

	public void setActiveDashboardWidgetId(Integer activeDashboardWidgetId) {
		this.activeDashboardWidgetId = activeDashboardWidgetId;
	}

	public Integer getActiveWidgetId() {
		return activeWidgetId;
	}

	public void setActiveWidgetId(Integer activeWidgetId) {
		this.activeWidgetId = activeWidgetId;
	}

	public WidgetParameter getNewParameter() {
		return newParameter;
	}

	public void setNewParameter(WidgetParameter newParameter) {
		this.newParameter = newParameter;
	}

	public void addWidgetParameter() {
		newParameter = new WidgetParameter();
		newParameter.setLang(userLang);
		newParameter.setWidgetId(activeWidgetId);
		newParameter.setDashboardWidgetId(activeDashboardWidgetId);
		curMode = NEW_MODE;
	}
	
	public void saveWidgetParameter() {
		try {
			widgetDao.addWidgetParameter(userSessionId, newParameter);
			if ((newParameter.isChar() && newParameter.getValueV() != null) 
					|| (newParameter.isNumber() && newParameter.getValueN() != null)
					|| (newParameter.isDate() && newParameter.getValueD() != null)) {
				widgetDao.setWidgetParamValue(userSessionId, newParameter);
			}
			curMode = VIEW_MODE;
		} catch (Exception e) {
			logger.error("", e);
			FacesUtils.addMessageError(e);
		}
	}
	
	public List<SelectItem> getLovs() {
		if (newParameter == null || newParameter.getDataType() == null) {
			return new ArrayList<SelectItem>(0);
		}
		Map<String, Object> params = new HashMap<String, Object>(1);
		params.put("DATA_TYPE", newParameter.getDataType());
		
		return getDictUtils().getLov(LovConstants.LOVS_LOV, params);
	}
	
	public List<SelectItem> getLovValues() {
		if (newParameter == null || newParameter.getLovId() == null) {
			return new ArrayList<SelectItem>(0);
		}
		return getDictUtils().getLov(newParameter.getLovId());
	}

	public String getActiveDashboardWidgetForm() {
		return activeDashboardWidgetForm;
	}

	public void setActiveDashboardWidgetForm(String activeDashboardWidgetForm) {
		this.activeDashboardWidgetForm = activeDashboardWidgetForm;
	}

	public String getRefreshWidgetFunction() {
		return refreshWidgetFunction;
	}

	public void setRefreshWidgetFunction(String refreshWidgetFunction) {
		this.refreshWidgetFunction = refreshWidgetFunction;
	}
	
	public List<SelectItem> getDataTypes() {
		if (dataTypes == null){
			dataTypes = (ArrayList<SelectItem>) getDictUtils().getLov(LovConstants.DATA_TYPES);
		}
		return dataTypes;
	}

	@Override
	public void clearFilter() {
		// TODO Auto-generated method stub
		
	}
}
