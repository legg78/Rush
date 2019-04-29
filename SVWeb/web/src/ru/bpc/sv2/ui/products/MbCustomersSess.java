package ru.bpc.sv2.ui.products;

import java.io.Serializable;

import org.richfaces.model.selection.SimpleSelection;

import ru.bpc.sv2.accounts.Account;
import ru.bpc.sv2.acquiring.Merchant;
import ru.bpc.sv2.acquiring.Terminal;
import ru.bpc.sv2.invocation.SortElement;
import ru.bpc.sv2.issuing.Card;
import ru.bpc.sv2.products.Contract;
import ru.bpc.sv2.products.Customer;

import javax.faces.bean.ManagedBean;
import javax.faces.bean.SessionScoped;

@SessionScoped
@ManagedBean (name = "MbCustomersSess")
public class MbCustomersSess implements Serializable {
	private static final long serialVersionUID = 1L;
	
	private Customer filter;
	private Card filterCard;
	private Contract filterContract;
	private Account filterAccount;
	private Merchant filterMerchant;
	private Terminal filterTerminal;
	
	private Customer activeCustomer;
	private int pageNumber;
	private int rowsNum;
	private String tabName;
	private String searchTabName;
	private SimpleSelection customerSelection;
	private int searchMode;
	private SortElement[] sort = null;
	
	public Customer getActiveCustomer() {
		return activeCustomer;
	}

	public void setActiveCustomer(Customer activeCustomer) {
		this.activeCustomer = activeCustomer;
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

	public String getSearchTabName() {
		return searchTabName;
	}

	public void setSearchTabName(String searchTabName) {
		this.searchTabName = searchTabName;
	}

	public SimpleSelection getCustomerSelection() {
		return customerSelection;
	}

	public void setCustomerSelection(SimpleSelection customerSelection) {
		this.customerSelection = customerSelection;
	}

	public Customer getFilter() {
		return filter;
	}

	public void setFilter(Customer filter) {
		this.filter = filter;
	}

	public Card getFilterCard() {
		return filterCard;
	}

	public void setFilterCard(Card filterCard) {
		this.filterCard = filterCard;
	}

	public Contract getFilterContract() {
		return filterContract;
	}

	public void setFilterContract(Contract filterContract) {
		this.filterContract = filterContract;
	}

	public Account getFilterAccount() {
		return filterAccount;
	}

	public void setFilterAccount(Account filterAccount) {
		this.filterAccount = filterAccount;
	}

	public Merchant getFilterMerchant() {
		return filterMerchant;
	}

	public void setFilterMerchant(Merchant filterMerchant) {
		this.filterMerchant = filterMerchant;
	}

	public Terminal getFilterTerminal() {
		return filterTerminal;
	}

	public void setFilterTerminal(Terminal filterTerminal) {
		this.filterTerminal = filterTerminal;
	}

	public int getSearchMode() {
		return searchMode;
	}

	public void setSearchMode(int searchMode) {
		this.searchMode = searchMode;
	}

	public SortElement[] getSort() {
		return sort;
	}

	public void setSort(SortElement[] sort) {
		this.sort = sort;
	}
}
