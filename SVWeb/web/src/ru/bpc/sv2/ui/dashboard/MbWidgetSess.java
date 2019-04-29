package ru.bpc.sv2.ui.dashboard;

import java.io.Serializable;
import java.util.List;

import javax.faces.bean.ManagedBean;
import javax.faces.bean.SessionScoped;

import ru.bpc.sv2.widget.WidgetItem;

@SessionScoped
@ManagedBean (name = "MbWidgetSess")
public class MbWidgetSess implements Serializable {

	private static final long serialVersionUID = 1L;

	private WidgetItem widget;
	private WidgetItem newWidget;

	private boolean privNeeded = false;
	private boolean managingNew;
	private String backLink;
	private boolean searching;
	private int pageNum;
	private int rowsNum;
	
	private List<WidgetItem> widgetsList;
	private int numberOfWidget;
	
	public MbWidgetSess() {
		
	}
	
	public WidgetItem getWidget() {
		if (widget == null) {
			widget = new WidgetItem();
		}
		return widget;
	}
	
	public void setWidget(WidgetItem widget) {
		this.widget = widget;
	}
	
	public WidgetItem getNewWidget() {
		return newWidget;
	}
	
	public void setNewWidget(WidgetItem newWidget) {
		this.newWidget = newWidget;
	}
	
	public boolean isManagingNew() {
		return managingNew;
	}
	public void setManagingNew(boolean managingNew) {
		this.managingNew = managingNew;
	}
	public String getBackLink() {
		return backLink;
	}
	public void setBackLink(String backLink) {
		this.backLink = backLink;
	}
	public boolean isSearching() {
		return searching;
	}
	public void setSearching(boolean searching) {
		this.searching = searching;
	}
	public int getPageNum() {
		return pageNum;
	}
	public void setPageNum(int pageNum) {
		this.pageNum = pageNum;
	}
	public int getRowsNum() {
		return rowsNum;
	}
	public void setRowsNum(int rowsNum) {
		this.rowsNum = rowsNum;
	}
	
	public List<WidgetItem> getWidgetsList() {
		return widgetsList;
	}
	
	public void setWidgetsList(List<WidgetItem> widgetsList) {
		this.widgetsList = widgetsList;
	}
	
	public int getNumberOfWidget() {
		return numberOfWidget;
	}
	
	public void setNumberOfWidget(int numberOfWidget) {
		this.numberOfWidget = numberOfWidget;
	}
	
	public boolean isPrivNeeded() {
		return privNeeded;
	}
	
	public void setPrivNeeded(boolean privNeeded) {
		this.privNeeded = privNeeded;
	}
	
}
