package ru.bpc.sv2.ui.atm;

import java.io.Serializable;

import org.richfaces.model.selection.SimpleSelection;

import ru.bpc.sv2.atm.MonitoredAtm;

import javax.faces.bean.ManagedBean;
import javax.faces.bean.SessionScoped;

@SessionScoped
@ManagedBean (name = "MbAtmMonitoringSess")
public class MbAtmMonitoringSess implements Serializable {
	private static final long serialVersionUID = 1237065772642844843L;
	
	private boolean searching;
	private MonitoredAtm filter;
	private String tabName;
	private MonitoredAtm activeItem;
	private int pageNumber;
	private int rowsNum;
	private SimpleSelection itemSelection;
	private String filterAtmDevice;
	
	public boolean isSearching() {
		return searching;
	}
	public void setSearching(boolean searching) {
		this.searching = searching;
	}
	public MonitoredAtm getFilter() {
		return filter;
	}
	public void setFilter(MonitoredAtm filter) {
		this.filter = filter;
	}
	public String getTabName() {
		return tabName;
	}
	public void setTabName(String tabName) {
		this.tabName = tabName;
	}
	public MonitoredAtm getActiveItem() {
		return activeItem;
	}
	public void setActiveItem(MonitoredAtm activeItem) {
		this.activeItem = activeItem;
	}
	public int getPageNumber() {
		return pageNumber;
	}
	public void setPageNumber(int pageNumber) {
		this.pageNumber = pageNumber;
	}
	public int getRowsNum() {
		return rowsNum;
	}
	public void setRowsNum(int rowsNum) {
		this.rowsNum = rowsNum;
	}
	public SimpleSelection getItemSelection() {
		return itemSelection;
	}
	public void setItemSelection(SimpleSelection itemSelection) {
		this.itemSelection = itemSelection;
	}
	public String getFilterAtmDevice() {
		return filterAtmDevice;
	}
	public void setFilterAtmDevice(String filterAtmDevice) {
		this.filterAtmDevice = filterAtmDevice;
	}
}
