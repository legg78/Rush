package ru.bpc.sv2.widget;

import java.util.ArrayList;
import java.util.List;

public class WidgetTableRowItem {

	private int rowNumber;
	private List<WidgetTableColumnItem> columns;

	public int getRowNumber() {
		return rowNumber;
	}
	public void setRowNumber(int rowNumber) {
		this.rowNumber = rowNumber;
	}
	public List<WidgetTableColumnItem> getColumns() {
		return columns;
	}
	public void setColumns(List<WidgetTableColumnItem> columns) {
		this.columns = columns;
	}

	public List<WidgetTableColumnItem> getAvailableColumnItems() {
		List<WidgetTableColumnItem> resultColumns = new ArrayList<WidgetTableColumnItem>();

		int alreadyUsed = 1;

		for (WidgetTableColumnItem item : getColumns()) {
			if(item.getWidget().getId() != null) {
				if(alreadyUsed == 1) {
					if (item.getDashboardWidget() == null || item.getDashboardWidget().getRowPos() == getRowNumber()) {
						resultColumns.add(item);
					}
					alreadyUsed = item.getWidth(); // these columns do not have to get to the result list
				} else {
					alreadyUsed--;
					continue;
				}
			} else {
				resultColumns.add(item);
			}
		}

		return resultColumns;
	}

}
