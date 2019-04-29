package ru.bpc.sv2.ui.issuing;

import java.io.Serializable;

import ru.bpc.sv2.issuing.Card;

import javax.faces.bean.ManagedBean;
import javax.faces.bean.SessionScoped;

@SessionScoped
@ManagedBean (name = "MbCards")
public class MbCards implements Serializable {
	private static final long serialVersionUID = 1L;
	
	private Card activeCard;
	private Card filter;
	private int pageNumber;
	private int rowsNum;
	private String tabName;
	private String backLink;
	
	public void clear() {
		activeCard = null;
		filter = null;
		pageNumber = 1;
		rowsNum = 20;
		tabName = "";
		backLink = "";
	}

	public Card getActiveCard() {
		return activeCard;
	}

	public void setActiveCard(Card activeCard) {
		this.activeCard = activeCard;
	}

	public Card getFilter() {
		return filter;
	}

	public void setFilter(Card filter) {
		this.filter = filter;
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

	public String getTabName() {
		return tabName;
	}

	public void setTabName(String tabName) {
		this.tabName = tabName;
	}

	public String getBackLink() {
		return backLink;
	}

	public void setBackLink(String backLink) {
		this.backLink = backLink;
	}
}
