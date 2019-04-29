package ru.bpc.sv2.ps.diners;

import ru.bpc.sv2.net.BinRange;

public class DinBinRange extends BinRange {
	private String agentCode;
	private String agentName;

	public String getAgentCode() {
		return agentCode;
	}

	public void setAgentCode(String agentCode) {
		this.agentCode = agentCode;
	}

	public String getAgentName() {
		return agentName;
	}

	public void setAgentName(String agentName) {
		this.agentName = agentName;
	}
}
