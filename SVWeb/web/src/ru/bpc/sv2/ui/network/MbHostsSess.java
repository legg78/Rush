package ru.bpc.sv2.ui.network;

import java.io.Serializable;
import java.util.List;

import org.richfaces.model.selection.SimpleSelection;

import ru.bpc.sv2.net.Consumer;
import ru.bpc.sv2.net.NetworkMember;

import javax.faces.bean.ManagedBean;
import javax.faces.bean.SessionScoped;

@SessionScoped
@ManagedBean (name = "MbHostsSess")
public class MbHostsSess implements Serializable {
	private static final long serialVersionUID = 1L;
	
	private SimpleSelection hostSelection;
	private NetworkMember activeHost;
	private NetworkMember hostFilter;
	private String tabName;
	private Consumer activeConsumer;
	private SimpleSelection consumerSelection;
	private String backLink;
	private boolean blockNetwork;
	private boolean searching;
	private int rowsNum;
	private int pageNumber;
	
	private List<NetworkMember> hostsList;
	
	public SimpleSelection getHostSelection() {
		return hostSelection;
	}
	
	public void setHostSelection(SimpleSelection hostSelection) {
		this.hostSelection = hostSelection;
	}

	public NetworkMember getActiveHost() {
		return activeHost;
	}

	public void setActiveHost(NetworkMember activeHost) {
		this.activeHost = activeHost;
	}

	public NetworkMember getHostFilter() {
		return hostFilter;
	}

	public void setHostFilter(NetworkMember hostFilter) {
		this.hostFilter = hostFilter;
	}

	public String getTabName() {
		return tabName;
	}

	public void setTabName(String tabName) {
		this.tabName = tabName;
	}

	public Consumer getActiveConsumer() {
		return activeConsumer;
	}

	public void setActiveConsumer(Consumer activeConsumer) {
		this.activeConsumer = activeConsumer;
	}

	public SimpleSelection getConsumerSelection() {
		return consumerSelection;
	}

	public void setConsumerSelection(SimpleSelection consumerSelection) {
		this.consumerSelection = consumerSelection;
	}

	public String getBackLink() {
		return backLink;
	}

	public void setBackLink(String backLink) {
		this.backLink = backLink;
	}

	public boolean isBlockNetwork() {
		return blockNetwork;
	}

	public void setBlockNetwork(boolean blockNetwork) {
		this.blockNetwork = blockNetwork;
	}

	public boolean isSearching() {
		return searching;
	}

	public void setSearching(boolean searching) {
		this.searching = searching;
	}

	public List<NetworkMember> getHostsList() {
		return hostsList;
	}

	public void setHostsList(List<NetworkMember> hostsList) {
		this.hostsList = hostsList;
	}

	public int getRowsNum() {
		return rowsNum;
	}

	public void setRowsNum(int rowsNum) {
		this.rowsNum = rowsNum;
	}

	public int getPageNumber() {
		return pageNumber;
	}

	public void setPageNumber(int pageNumber) {
		this.pageNumber = pageNumber;
	}
}
