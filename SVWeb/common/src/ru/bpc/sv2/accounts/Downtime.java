package ru.bpc.sv2.accounts;

import java.util.Date;

public class Downtime {
	private Integer terminalId;
	private Date dateFrom;
	private Date dateTo;
	private Integer downtimeType;
	
	public Integer getTerminalId() {
		return terminalId;
	}
	
	public void setTerminalId(Integer terminalId) {
		this.terminalId = terminalId;
	}

	public Date getDateFrom() {
		return dateFrom;
	}

	public void setDateFrom(Date dateFrom) {
		this.dateFrom = dateFrom;
	}

	public Date getDateTo() {
		return dateTo;
	}

	public void setDateTo(Date dateTo) {
		this.dateTo = dateTo;
	}

	public Integer getDowntimeType() {
		return downtimeType;
	}

	public void setDowntimeType(Integer downtimeType) {
		this.downtimeType = downtimeType;
	} 

}
