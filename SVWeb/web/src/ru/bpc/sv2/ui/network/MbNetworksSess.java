package ru.bpc.sv2.ui.network;

import java.io.Serializable;

import org.richfaces.model.selection.SimpleSelection;

import ru.bpc.sv2.net.Network;
import ru.bpc.sv2.net.NetworkMember;

import javax.faces.bean.ManagedBean;
import javax.faces.bean.SessionScoped;

@SessionScoped
@ManagedBean (name = "MbNetworksSess")
public class MbNetworksSess implements Serializable {
	private static final long serialVersionUID = 1L;
	
	private Network networkFilter;
	private Network activeNetwork;
	private String networkTab;
	private NetworkMember activeMember;
	private SimpleSelection networkSelection;
	private SimpleSelection memberSelection;
	private int pageNumber;
	private int rowsNum;
	
	public Network getNetworkFilter() {
		return networkFilter;
	}
	
	public void setNetworkFilter(Network networkFilter) {
		this.networkFilter = networkFilter;
	}

	public Network getActiveNetwork() {
		return activeNetwork;
	}

	public void setActiveNetwork(Network activeNetwork) {
		this.activeNetwork = activeNetwork;
	}

	public String getNetworkTab() {
		return networkTab;
	}

	public void setNetworkTab(String networkTab) {
		this.networkTab = networkTab;
	}

	public NetworkMember getActiveMember() {
		return activeMember;
	}

	public void setActiveMember(NetworkMember activeMember) {
		this.activeMember = activeMember;
	}

	public SimpleSelection getNetworkSelection() {
		return networkSelection;
	}

	public void setNetworkSelection(SimpleSelection networkSelection) {
		this.networkSelection = networkSelection;
	}

	public SimpleSelection getMemberSelection() {
		return memberSelection;
	}

	public void setMemberSelection(SimpleSelection memberSelection) {
		this.memberSelection = memberSelection;
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

}
