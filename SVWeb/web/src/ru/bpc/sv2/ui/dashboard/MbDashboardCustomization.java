package ru.bpc.sv2.ui.dashboard;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;

import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.WidgetsDao;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.widget.Dashboard;
import ru.bpc.sv2.widget.Dashboard2WidgetItem;
import ru.bpc.sv2.widget.DashboardInfo;
import ru.bpc.sv2.widget.WidgetItem;
import ru.bpc.sv2.widget.WidgetTableColumnItem;
import ru.bpc.sv2.widget.WidgetTableRowItem;

@ViewScoped
@ManagedBean(name = "MbDashboardCustomization")
public class MbDashboardCustomization extends AbstractBean {

	private Integer dropRow;
	private Integer dropColumn;

	private WidgetItem[] widgetList;
	private Integer draggedWidgetId;
	private Integer currentDashboardId;
	private DashboardInfo currentDashboard;
	private String backLink;
	private Dashboard dashbordFilter;

	private WidgetsDao widgetDao = new WidgetsDao();

	public MbDashboardCustomization(){
		restoreFilter();
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

	private void updateCurrentDashboard() {
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
			Dashboard2WidgetItem[] widgetPositionsList = widgetDao.getDashboardWidgets(userSessionId, params);

			currentDashboard = new DashboardInfo(dashboardItems[0], widgetPositionsList, getWidgetList());
		}
	}

	public String addWidget() {
		if(getCurrentDashboard() != null) {

			String result = currentDashboard.addWidget(dropRow, dropColumn, draggedWidgetId);

			if("occupied".equals(result)) {
				FacesUtils.addMessageInfo("Occupied, delete previous");
			}
			if("nowidth".equals(result)) {
				FacesUtils.addMessageInfo("Widget longer than the remaining space in the dashboard");
			}
			if("duplicate".equals(result)) {
				FacesUtils.addMessageInfo("Widget has already existed.");
			}
		} else {
			FacesUtils.addMessageInfo("Current dashboard is empty");
		}
		return null;
	}

	public String removeWidget() {
		String result = currentDashboard.removeWidget(dropRow, dropColumn);
		return null;
	}

	public String save() {

		List<Dashboard2WidgetItem> newWidgetPositionList = new ArrayList<Dashboard2WidgetItem>();
		Dashboard2WidgetItem[] oldWidgetPositionList = getCurrentDashboard().getDashboard2widgetList();

		// make Dashboard2WidgetItem objects using widgetTable
		for (WidgetTableRowItem row : getCurrentDashboard().getWidgetTable()) {
			for (WidgetTableColumnItem column : row.getAvailableColumnItems()) {
				if(column.getWidget().getId() != null && column.getWidget().getId() != 0) {
					Dashboard2WidgetItem widgetPosition = new Dashboard2WidgetItem(
							getCurrentDashboard().getId(), column.getWidget()
							.getId(), row.getRowNumber(),
							column.getColumnNumber());

					newWidgetPositionList.add(widgetPosition);
				}
			}
		}

		// delete old widgets and add new
		try {
			Dashboard2WidgetItem[] newWidgetPositionListArr = newWidgetPositionList.toArray(new Dashboard2WidgetItem[newWidgetPositionList.size()]);
			widgetDao.addDashboardWidgetList(userSessionId, oldWidgetPositionList, newWidgetPositionListArr);

			updateCurrentDashboard();

			FacesUtils.addMessageInfo("Successfully completed");
		} catch (Exception e) {
			FacesUtils.addMessageInfo("Error has occured");
		}
		return prepareReturn();
	}

	public String cancel() {
		updateCurrentDashboard();
		return prepareReturn();
	}

	private WidgetItem getWidgetItemById(Integer id) {
		WidgetItem[] widgetItems = getWidgetList();
		for (WidgetItem widgetItem : widgetItems) {
			if (widgetItem.getId().equals(id)) {
				return widgetItem;
			}
		}
		return null;
	}

	public int getDraggedWidgetWidth() {
		if(draggedWidgetId != null) {
			return getWidgetItemById(draggedWidgetId).getWidth();
		}
		return 0;
	}

	public int getDraggedWidgetHeight() {
		if(draggedWidgetId != null) {
			return getWidgetItemById(draggedWidgetId).getHeight();
		}
		return 0;
	}

	public void setWidgetList(WidgetItem[] widgetList) {
		this.widgetList = widgetList;
	}

	public WidgetItem[] getWidgetList() {
		if(widgetList == null) {
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

	public Integer getDropRow() {
		return dropRow;
	}

	public void setDropRow(Integer dropRow) {
		this.dropRow = dropRow;
	}

	public Integer getDropColumn() {
		return dropColumn;
	}

	public void setDropColumn(Integer dropColumn) {
		this.dropColumn = dropColumn;
	}

	public Integer getDraggedWidgetId() {
		return draggedWidgetId;
	}

	public void setDraggedWidgetId(Integer draggedWidgetId) {
		this.draggedWidgetId = draggedWidgetId;
	}

	public Integer getCurrentDashboardId() {
		return currentDashboardId;
	}

	public void setCurrentDashboardId(Integer currentDashboardId) {
		this.currentDashboardId = currentDashboardId;
	}

	@Override
	public void clearFilter() {
		// TODO Auto-generated method stub

	}

	public String getBackLink() {
		if (backLink == null){
			return "acm|dashboards";
		}
		return backLink;
	}

	public void setBackLink(String backLink) {
		this.backLink = backLink;
	}

	public Dashboard getDashbordFilter() {
		if (dashbordFilter == null){
			dashbordFilter = new Dashboard();
		}
		return dashbordFilter;
	}

	public void setDashbordFilter(Dashboard dashbordFilter) {
		this.dashbordFilter = dashbordFilter;
	}

	public String prepareReturn(){
		HashMap<String,Object> queueFilter = new HashMap<String,Object>();

		queueFilter.put("dashboardsFilter", getDashbordFilter());

		addFilterToQueue("MbUserDashboards", queueFilter);
		return getBackLink();
	}

	private void restoreFilter(){
		HashMap<String,Object> queueFilter = getQueueFilter("MbDashboardCustomization");
		if (queueFilter==null)
			return;
		clearFilter();
		if (queueFilter.containsKey("backLink")){
			setBackLink((String)queueFilter.get("backLink"));
		}
		if (queueFilter.containsKey("dashboardsFilter")){
			setDashbordFilter((Dashboard) queueFilter.get("dashboardsFilter"));
		}
		if (queueFilter.containsKey("currentDashboardId")){
			setCurrentDashboardId((Integer) queueFilter.get("currentDashboardId"));
		}
	}

}
