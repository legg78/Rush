package ru.bpc.sv2.widget;

import java.util.ArrayList;
import java.util.List;

public class DashboardInfo {

	private Dashboard item;
	private Dashboard2WidgetItem[] dashboard2widgetList; // widget position for this dashboard
	private WidgetItem[] widgetList;

	public static final int ITEM_HEIGHT = 250;
	public static final int ROWS = 3;
	public static final int COLUMNS = 4;

	private List<WidgetTableRowItem> widgetTable;

	public DashboardInfo(Dashboard item, Dashboard2WidgetItem[] dashboard2WidgetList,
						 WidgetItem[] widgetList) {
		this.item = item;
		this.setDashboard2widgetList(dashboard2WidgetList);
		this.widgetList = widgetList;
		createWidgetTable();
	}

	public void createWidgetTable() {

		widgetTable = new ArrayList<WidgetTableRowItem>();

		for (int rowIndex = 0; rowIndex < ROWS; rowIndex++) {

			WidgetTableRowItem row = new WidgetTableRowItem();
			List<WidgetTableColumnItem> columns = new ArrayList<WidgetTableColumnItem>();

			row.setRowNumber(rowIndex);
			for (int columnIndex = 0; columnIndex < COLUMNS; columnIndex++) {
				WidgetTableColumnItem column = new WidgetTableColumnItem();
				column.setColumnNumber(columnIndex);
				columns.add(column);
			}
			row.setColumns(columns);

			widgetTable.add(row);
		}

		// accomodate existing widgets on the dashboard
		if (dashboard2widgetList != null) {
			for (Dashboard2WidgetItem item : dashboard2widgetList) {
				addExistingWidget(item);
			}
		}
	}

	// add new widgets to dashboard
	public String addWidget(int dropRow, int dropColumn, int draggedWidgetId) {
		WidgetTableRowItem row = widgetTable.get(dropRow);
		boolean isCellsEmpty = true; // if cells for widget is empty this property true
		boolean isDashboardWidth = true; // if the widget length is not greater than the length of
		boolean isDuplicateWidget = true; // check duplicate widget
		// the widget dashboard

		/* get widget item */
		WidgetItem widget = getWidgetItemById(draggedWidgetId);

		/* check table cell is empty */
		int low = (dropRow - widget.getHeight() + 1 > 0) ? dropRow - widget.getHeight() + 1 : 0;
		for (int rowNum = dropRow; rowNum>=low; rowNum--) {
			row = widgetTable.get(rowNum);
			for (int colNum = dropColumn; colNum < dropColumn + widget.getWidth(); colNum++) {
				if (colNum < COLUMNS) {
					if (row.getColumns().get(colNum).getWidget().getId() != null) {
						isCellsEmpty = false;
						return "occupied"; // return the result, cell is occupied
					}
				}
			}
		}

		/* check remaining dashboard width */
		if (isCellsEmpty) {
			if (dropColumn + widget.getWidth() > COLUMNS) {
				isDashboardWidth = false;
				return "nowidth"; // return the result, remaining dashboard width is small
			}
		}

		if (isCellsEmpty) {
			if (dropRow - widget.getHeight() + 1 < 0 ) {
				isDashboardWidth = false;
				return "nowidth"; // return the result, remaining dashboard width is small
			}
		}
		
		/* check duplicate widget */
//		for (int rowNum = 0; rowNum < ROWS; rowNum++) {
//			for (int colNum = 0; colNum < COLUMNS; colNum++) {
//				WidgetItem checkItem = widgetTable.get(rowNum).getColumns().get(colNum).getWidget();
//				if (checkItem != null && checkItem.getId() != null && checkItem.getId() == draggedWidgetId) {
//					isDuplicateWidget = false;
//					return "duplicate";
//				}
//			}
//		}

		/* add widget id to widgetTable */
		if (isCellsEmpty && isDashboardWidth && isDuplicateWidget) {
			for (int rowNum = dropRow; rowNum>=low; rowNum--) {
				row = widgetTable.get(rowNum);
				for (int colNum = dropColumn; colNum < dropColumn + widget.getWidth(); colNum++) {
					row.getColumns().get(colNum).setWidget(widget);
					Dashboard2WidgetItem d2wi = new Dashboard2WidgetItem();
					d2wi.setRowPos(low);
					d2wi.setColumnPos(dropColumn);
					row.getColumns().get(colNum).setDashboardWidget(d2wi);
				}
			}
		}

		return null;
	}

	// add existing widgets to dashboard
	private String addExistingWidget(Dashboard2WidgetItem dashboardWidget) {
		int columnPos = dashboardWidget.getColumnPos();
		int rowPos = dashboardWidget.getRowPos();

		//WidgetTableRowItem row = widgetTable.get(rowPos);
		// the widget dashboard

		/* get widget item */
		WidgetItem widget = getWidgetItemById(dashboardWidget.getWidgetId());


		/* add widget id to widgetTable */
//		for (int colNum = columnPos; colNum < columnPos + widget.getWidth(); colNum++) {
//			row.getColumns().get(colNum).setWidget(widget);
//			row.getColumns().get(colNum).setDashboardWidget(dashboardWidget);
//		}

		for (int rc = 0; rc < widget.getHeight(); rc ++) {
			WidgetTableRowItem row = widgetTable.get(rowPos + rc);
			for (int colNum = columnPos; colNum < columnPos + widget.getWidth(); colNum++) {
				row.getColumns().get(colNum).setWidget(widget);
				row.getColumns().get(colNum).setDashboardWidget(dashboardWidget);
			}
		}
		return null;
	}

	// remove widget from dashboard
	public String removeWidget(int dropRow, int dropColumn) {

		WidgetTableRowItem row = widgetTable.get(dropRow);

		/* get widget item */
		WidgetItem widget = row.getColumns().get(dropColumn).getWidget();


		for (int rc = 0; rc < widget.getHeight(); rc ++) {
			row = widgetTable.get(dropRow + rc);
			for (int colNum = dropColumn; colNum < dropColumn + widget.getWidth(); colNum++) {
				row.getColumns().get(colNum).removeWidget();
			}
		}
//		for (int column = dropColumn; column < dropColumn + widget.getWidth(); column++) {
//			row.getColumns().get(column).removeWidget();
//		}

		return null;
	}

	private WidgetItem getWidgetItemById(Integer id) {
		if (id != null) {
			for (WidgetItem widgetItem : widgetList) {
				if (id.equals(widgetItem.getId())) {
					return widgetItem;
				}
			}
		}
		return null;
	}

	public Dashboard getItem() {
		return item;
	}

	public void setItem(Dashboard item) {
		this.item = item;
	}

	public List<WidgetTableRowItem> getWidgetTable() {
		return widgetTable;
	}

	public void setWidgetTable(List<WidgetTableRowItem> widgetTable) {
		this.widgetTable = widgetTable;
	}

	public Dashboard2WidgetItem[] getDashboard2widgetList() {
		return dashboard2widgetList;
	}

	public void setDashboard2widgetList(Dashboard2WidgetItem[] dashboard2widgetList) {
		this.dashboard2widgetList = dashboard2widgetList;
	}

	public WidgetItem[] getWidgetList() {
		return widgetList;
	}

	public void setWidgetList(WidgetItem[] widgetList) {
		this.widgetList = widgetList;
	}

	/*
	 * Delegated methods
	 */
	public Integer getId() {
		return item.getId();
	}

	public void setId(Integer id) {
		item.setId(id);
	}

	public String getName() {
		return item.getName();
	}

	public void setName(String name) {
		item.setName(name);
	}

	public Integer getUserId() {
		return item.getUserId();
	}

	public void setUserId(Integer userId) {
		item.setUserId(userId);
	}

	public int getItemHeight() {
		return ITEM_HEIGHT;
	}
}
