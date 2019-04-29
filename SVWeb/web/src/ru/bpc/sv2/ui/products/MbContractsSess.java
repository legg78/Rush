package ru.bpc.sv2.ui.products;

import java.io.Serializable;

import org.richfaces.model.selection.SimpleSelection;

import ru.bpc.sv2.products.Contract;

import javax.faces.bean.ManagedBean;
import javax.faces.bean.SessionScoped;

@SessionScoped
@ManagedBean (name = "MbContractsSess")
public class MbContractsSess implements Serializable {
	private static final long serialVersionUID = 1L;
	
	private Contract activeContract;
	private SimpleSelection itemSelection;
	private Contract filter;
	private int pageNumber;
	private int rowsNum;
	private String tabName;

	public Contract getActiveContract() {
		return activeContract;
	}
	
	public void setActiveContract(Contract activeContract) {
		this.activeContract = activeContract;
	}

	public SimpleSelection getItemSelection() {
		return itemSelection;
	}

	public void setItemSelection(SimpleSelection itemSelection) {
		this.itemSelection = itemSelection;
	}

	public Contract getFilter() {
		return filter;
	}

	public void setFilter(Contract filter) {
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
}
