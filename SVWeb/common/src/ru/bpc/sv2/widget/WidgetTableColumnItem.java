package ru.bpc.sv2.widget;

public class WidgetTableColumnItem {

	private int columnNumber;
	private WidgetItem widget = new WidgetItem();
	private Dashboard2WidgetItem dashboardWidget = new Dashboard2WidgetItem();

	public int getColumnNumber() {
		return columnNumber;
	}
	public void setColumnNumber(int columnNumber) {
		this.columnNumber = columnNumber;
	}
	public WidgetItem getWidget() {
		return widget;
	}
	public void setWidget(WidgetItem widget) {
		this.widget = widget;
	}
	
	public Dashboard2WidgetItem getDashboardWidget() {
		return dashboardWidget;
	}
	public void setDashboardWidget(Dashboard2WidgetItem dashboardWidget) {
		this.dashboardWidget = dashboardWidget;
	}
	public int getWidth() {
		if(widget == null || widget.getWidth() == null || widget.getWidth() == 0) {
			return 1; //colspan must be >=1
		}
		return widget.getWidth();
	}

	public void removeWidget() {
		widget = new WidgetItem();
		dashboardWidget = new Dashboard2WidgetItem();
	}

}
