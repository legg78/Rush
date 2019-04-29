package ru.bpc.sv2.ui.application;

import ru.bpc.sv2.application.ApplicationFlow;

import javax.faces.bean.ManagedBean;
import javax.faces.bean.SessionScoped;

@SessionScoped
@ManagedBean (name = "MbFlows")
public class MbFlows {
    private ApplicationFlow activeFlow;
    private ApplicationFlow filter;
    private String activeTab;
    private boolean searching;
    private int rowIndexStart;
    private int rowIndexEnd;
    private int pageNumber;


    public void flush() {
        activeFlow = null;
        searching = false;
        filter = null;
        activeTab = null;
    }

    public ApplicationFlow getActiveFlow() {
        return activeFlow;
    }

    public void setActiveFlow(ApplicationFlow activeFlow) {
        this.activeFlow = activeFlow;
    }

    public ApplicationFlow getFilter() {
        return filter;
    }

    public void setFilter(ApplicationFlow filter) {
        this.filter = filter;
    }

    public String getActiveTab() {
        return activeTab;
    }

    public void setActiveTab(String activeTab) {
        this.activeTab = activeTab;
    }

    public boolean isSearching() {
        return searching;
    }

    public void setSearching(boolean searching) {
        this.searching = searching;
    }

    public int getRowIndexStart() {
        return rowIndexStart;
    }

    public void setRowIndexStart(int rowIndexStart) {
        this.rowIndexStart = rowIndexStart;
    }

    public int getRowIndexEnd() {
        return rowIndexEnd;
    }

    public void setRowIndexEnd(int rowIndexEnd) {
        this.rowIndexEnd = rowIndexEnd;
    }

    public int getPageNumber() {
        return pageNumber;
    }

    public void setPageNumber(int pageNumber) {
        this.pageNumber = pageNumber;
    }
}
