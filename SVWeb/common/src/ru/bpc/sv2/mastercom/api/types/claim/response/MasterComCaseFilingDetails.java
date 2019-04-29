package ru.bpc.sv2.mastercom.api.types.claim.response;

import ru.bpc.sv2.mastercom.api.format.impl.MasterComCaseTypeFormatter;
import ru.bpc.sv2.mastercom.api.format.MasterComFormatter;
import ru.bpc.sv2.mastercom.api.format.impl.MasterComParticipantFormatter;
import ru.bpc.sv2.mastercom.api.types.MasterComResponse;

import java.io.Serializable;
import java.math.BigDecimal;
import java.util.Date;
import java.util.List;

public class MasterComCaseFilingDetails implements MasterComResponse, Serializable {
	private static final long serialVersionUID = -1;

	private String caseFilingStatus;
	private FilingDetails caseFilingDetails;
	private List<MasterComCaseFilingRespHistory> caseFilingRespHistory;

	public String getCaseFilingStatus() {
		return caseFilingStatus;
	}

	public void setCaseFilingStatus(String caseFilingStatus) {
		this.caseFilingStatus = caseFilingStatus;
	}

	public FilingDetails getCaseFilingDetails() {
		return caseFilingDetails;
	}

	public void setCaseFilingDetails(FilingDetails caseFilingDetails) {
		this.caseFilingDetails = caseFilingDetails;
	}

	public List<MasterComCaseFilingRespHistory> getCaseFilingRespHistory() {
		return caseFilingRespHistory;
	}

	public void setCaseFilingRespHistory(List<MasterComCaseFilingRespHistory> caseFilingRespHistory) {
		this.caseFilingRespHistory = caseFilingRespHistory;
	}

	public static class FilingDetails implements MasterComResponse, Serializable {
		private static final long serialVersionUID = -1;

		private String claimId;
		private String claimType;
		private String caseId;

		@MasterComFormatter(using = MasterComCaseTypeFormatter.class)
		private MasterComCaseType caseType;
		private List<String> chargebackRefNum;

		/**
		 * Currency Code. The following values are valid. USD, EUR, GBP, MXN
		 */
		private String currencyCode;
		private String customerFilingNumber;

		/**
		 * Dispute amount. The currency will be determined by the ICA region entered in the Filed ICA and Filed Against ICA
		 * Example: 100.00
		 */
		private BigDecimal disputeAmount;

		private Date dueDate;
		private String filingAgaintstIca;

		@MasterComFormatter(using = MasterComParticipantFormatter.class)
		private Participant filingAs;
		private String filingIca;
		private String merchantName;
		private String primaryAccountNum;
		private String violationCode;
		private Date violationDate;
		private Date rulingDate;
		private String rulingStatus;
		private Date creditDate;
		private String reasonCode;
		private Date chargebackDate;

		public String getClaimId() {
			return claimId;
		}

		public void setClaimId(String claimId) {
			this.claimId = claimId;
		}

		public String getClaimType() {
			return claimType;
		}

		public void setClaimType(String claimType) {
			this.claimType = claimType;
		}

		public MasterComCaseType getCaseType() {
			return caseType;
		}

		public void setCaseType(MasterComCaseType caseType) {
			this.caseType = caseType;
		}

		public List<String> getChargebackRefNum() {
			return chargebackRefNum;
		}

		public void setChargebackRefNum(List<String> chargebackRefNum) {
			this.chargebackRefNum = chargebackRefNum;
		}

		public String getCurrencyCode() {
			return currencyCode;
		}

		public void setCurrencyCode(String currencyCode) {
			this.currencyCode = currencyCode;
		}

		public String getCustomerFilingNumber() {
			return customerFilingNumber;
		}

		public void setCustomerFilingNumber(String customerFilingNumber) {
			this.customerFilingNumber = customerFilingNumber;
		}

		public BigDecimal getDisputeAmount() {
			return disputeAmount;
		}

		public void setDisputeAmount(BigDecimal disputeAmount) {
			this.disputeAmount = disputeAmount;
		}

		public Date getDueDate() {
			return dueDate;
		}

		public void setDueDate(Date dueDate) {
			this.dueDate = dueDate;
		}

		public String getFilingAgaintstIca() {
			return filingAgaintstIca;
		}

		public void setFilingAgaintstIca(String filingAgaintstIca) {
			this.filingAgaintstIca = filingAgaintstIca;
		}

		public Participant getFilingAs() {
			return filingAs;
		}

		public void setFilingAs(Participant filingAs) {
			this.filingAs = filingAs;
		}

		public String getFilingIca() {
			return filingIca;
		}

		public void setFilingIca(String filingIca) {
			this.filingIca = filingIca;
		}

		public String getMerchantName() {
			return merchantName;
		}

		public void setMerchantName(String merchantName) {
			this.merchantName = merchantName;
		}

		public String getPrimaryAccountNum() {
			return primaryAccountNum;
		}

		public void setPrimaryAccountNum(String primaryAccountNum) {
			this.primaryAccountNum = primaryAccountNum;
		}

		public String getViolationCode() {
			return violationCode;
		}

		public void setViolationCode(String violationCode) {
			this.violationCode = violationCode;
		}

		public Date getViolationDate() {
			return violationDate;
		}

		public void setViolationDate(Date violationDate) {
			this.violationDate = violationDate;
		}

		public Date getRulingDate() {
			return rulingDate;
		}

		public void setRulingDate(Date rulingDate) {
			this.rulingDate = rulingDate;
		}

		public String getRulingStatus() {
			return rulingStatus;
		}

		public void setRulingStatus(String rulingStatus) {
			this.rulingStatus = rulingStatus;
		}

		public Date getCreditDate() {
			return creditDate;
		}

		public void setCreditDate(Date creditDate) {
			this.creditDate = creditDate;
		}

		public String getCaseId() {
			return caseId;
		}

		public void setCaseId(String caseId) {
			this.caseId = caseId;
		}

		public String getReasonCode() {
			return reasonCode;
		}

		public void setReasonCode(String reasonCode) {
			this.reasonCode = reasonCode;
		}

		public Date getChargebackDate() {
			return chargebackDate;
		}

		public void setChargebackDate(Date chargebackDate) {
			this.chargebackDate = chargebackDate;
		}
	}

	/**
	 * Changed to string, because from MasterCom we get value 'Favor Sender'
	 */
	public enum RulingStatus {
		REVIEWED,
		FILED_IN_ERROR,
		DECLINED,
		EXPIRED,
		FAVOR_SENDER,
		FAVOR_RECEIVER,
	}

	public enum Participant {
		Issuer,
		Acquirer,
	}
}
