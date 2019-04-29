package ru.bpc.sv2.ps.visa;

import ru.bpc.sv2.invocation.ModelIdentifiable;

import java.io.Serializable;
import java.util.Date;

public class VisaVssReport implements Serializable, ModelIdentifiable, Cloneable {
	private Long id;
	private String dstBin;
	private String reportCode;
	private String reportIdNum;
	private String reportIdSfx;
	private Long sreId;
	private String sreName;
	private Long upSreId;
	private String upSreName;
	private Long fundsSreId;
	private String fundsSreName;
	private String settlementCurrency;
	private String clearingCurrency;
	private Date dateFrom;
	private Date dateTo;
	private Date settlementDate;
	private Date reportDate;
	private Date changeDate;

	private String reportTitle;

	@Override
	public Object getModelId() {
		return getId();
	}

	public Long getId() {
		return id;
	}

	public void setId(Long id) {
		this.id = id;
	}

	public String getDstBin() {
		return dstBin;
	}

	public void setDstBin(String dstBin) {
		this.dstBin = dstBin;
	}

	public String getReportCode() {
		return reportCode;
	}

	public void setReportCode(String reportCode) {
		this.reportCode = reportCode;
	}

	public String getReportIdNum() {
		return reportIdNum;
	}

	public void setReportIdNum(String reportIdNum) {
		this.reportIdNum = reportIdNum;
	}

	public String getReportIdSfx() {
		return reportIdSfx;
	}

	public void setReportIdSfx(String reportIdSfx) {
		this.reportIdSfx = reportIdSfx;
	}

	public Long getSreId() {
		return sreId;
	}

	public void setSreId(Long sreId) {
		this.sreId = sreId;
	}

	public String getSreName() {
		return sreName;
	}

	public void setSreName(String sreName) {
		this.sreName = sreName;
	}

	public Long getUpSreId() {
		return upSreId;
	}

	public void setUpSreId(Long upSreId) {
		this.upSreId = upSreId;
	}

	public String getUpSreName() {
		return upSreName;
	}

	public void setUpSreName(String upSreName) {
		this.upSreName = upSreName;
	}

	public Long getFundsSreId() {
		return fundsSreId;
	}

	public void setFundsSreId(Long fundsSreId) {
		this.fundsSreId = fundsSreId;
	}

	public String getFundsSreName() {
		return fundsSreName;
	}

	public void setFundsSreName(String fundsSreName) {
		this.fundsSreName = fundsSreName;
	}

	public String getSettlementCurrency() {
		return settlementCurrency;
	}

	public void setSettlementCurrency(String settlementCurrency) {
		this.settlementCurrency = settlementCurrency;
	}

	public String getClearingCurrency() {
		return clearingCurrency;
	}

	public void setClearingCurrency(String clearingCurrency) {
		this.clearingCurrency = clearingCurrency;
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

	public Date getSettlementDate() {
		return settlementDate;
	}

	public void setSettlementDate(Date settlementDate) {
		this.settlementDate = settlementDate;
	}

	public Date getReportDate() {
		return reportDate;
	}

	public void setReportDate(Date reportDate) {
		this.reportDate = reportDate;
	}

	public Date getChangeDate() {
		return changeDate;
	}

	public void setChangeDate(Date changeDate) {
		this.changeDate = changeDate;
	}

	public String getReportTitle() {
		return reportTitle;
	}

	public void setReportTitle(String reportTitle) {
		this.reportTitle = reportTitle;
	}
}
