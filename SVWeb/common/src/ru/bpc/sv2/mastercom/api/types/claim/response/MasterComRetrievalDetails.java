package ru.bpc.sv2.mastercom.api.types.claim.response;

import ru.bpc.sv2.mastercom.api.format.MasterComFormatter;
import ru.bpc.sv2.mastercom.api.format.impl.MasterComDocNeededFormatter;
import ru.bpc.sv2.mastercom.api.types.MasterComResponse;

import java.io.Serializable;
import java.math.BigDecimal;
import java.util.Date;

public class MasterComRetrievalDetails implements MasterComResponse, Serializable {
	private static final long serialVersionUID = -1;

	private String acquirerRefNum;
	private String acquirerResponseCd;
	private String acquirerMemo;
	private Date acquirerResponseDt;

	/**
	 * Amount of the claim
	 * Example: 100.00
	 */
	private BigDecimal amount;
	private String currency;
	private String claimId;
	private Date createDate;

	/**
	 * Documentation Needed Indicator.
	 * The following values are valid : 2 - Copy or image (photocopy, microfilm, fax) of original document, 4 - Substitute draft
	 */
	@MasterComFormatter(using = MasterComDocNeededFormatter.class)
	private DocNeeded docNeeded;
	private String issuerResponseCd;
	private String issuerRejectRsnCd;
	private String issuerMemo;
	private Date issuerResponseDt;
	private String imageReviewDecision;
	private Date imageReviewDt;
	private String primaryAcctNum;
	private String requestId;
	private String retrievalRequestReason;

	private String chargebackRefNum;

	public String getAcquirerRefNum() {
		return acquirerRefNum;
	}

	public void setAcquirerRefNum(String acquirerRefNum) {
		this.acquirerRefNum = acquirerRefNum;
	}

	public String getAcquirerResponseCd() {
		return acquirerResponseCd;
	}

	public void setAcquirerResponseCd(String acquirerResponseCd) {
		this.acquirerResponseCd = acquirerResponseCd;
	}

	public String getAcquirerMemo() {
		return acquirerMemo;
	}

	public void setAcquirerMemo(String acquirerMemo) {
		this.acquirerMemo = acquirerMemo;
	}

	public Date getAcquirerResponseDt() {
		return acquirerResponseDt;
	}

	public void setAcquirerResponseDt(Date acquirerResponseDt) {
		this.acquirerResponseDt = acquirerResponseDt;
	}

	public BigDecimal getAmount() {
		return amount;
	}

	public void setAmount(BigDecimal amount) {
		this.amount = amount;
	}

	public String getCurrency() {
		return currency;
	}

	public void setCurrency(String currency) {
		this.currency = currency;
	}

	public String getClaimId() {
		return claimId;
	}

	public void setClaimId(String claimId) {
		this.claimId = claimId;
	}

	public Date getCreateDate() {
		return createDate;
	}

	public void setCreateDate(Date createDate) {
		this.createDate = createDate;
	}

	public DocNeeded getDocNeeded() {
		return docNeeded;
	}

	public void setDocNeeded(DocNeeded docNeeded) {
		this.docNeeded = docNeeded;
	}

	public String getIssuerResponseCd() {
		return issuerResponseCd;
	}

	public void setIssuerResponseCd(String issuerResponseCd) {
		this.issuerResponseCd = issuerResponseCd;
	}

	public String getIssuerRejectRsnCd() {
		return issuerRejectRsnCd;
	}

	public void setIssuerRejectRsnCd(String issuerRejectRsnCd) {
		this.issuerRejectRsnCd = issuerRejectRsnCd;
	}

	public String getIssuerMemo() {
		return issuerMemo;
	}

	public void setIssuerMemo(String issuerMemo) {
		this.issuerMemo = issuerMemo;
	}

	public Date getIssuerResponseDt() {
		return issuerResponseDt;
	}

	public void setIssuerResponseDt(Date issuerResponseDt) {
		this.issuerResponseDt = issuerResponseDt;
	}

	public String getImageReviewDecision() {
		return imageReviewDecision;
	}

	public void setImageReviewDecision(String imageReviewDecision) {
		this.imageReviewDecision = imageReviewDecision;
	}

	public Date getImageReviewDt() {
		return imageReviewDt;
	}

	public void setImageReviewDt(Date imageReviewDt) {
		this.imageReviewDt = imageReviewDt;
	}

	public String getPrimaryAcctNum() {
		return primaryAcctNum;
	}

	public void setPrimaryAcctNum(String primaryAcctNum) {
		this.primaryAcctNum = primaryAcctNum;
	}

	public String getRequestId() {
		return requestId;
	}

	public void setRequestId(String requestId) {
		this.requestId = requestId;
	}

	public String getRetrievalRequestReason() {
		return retrievalRequestReason;
	}

	public void setRetrievalRequestReason(String retrievalRequestReason) {
		this.retrievalRequestReason = retrievalRequestReason;
	}

	public String getChargebackRefNum() {
		return chargebackRefNum;
	}

	public void setChargebackRefNum(String chargebackRefNum) {
		this.chargebackRefNum = chargebackRefNum;
	}

	public enum DocNeeded {
		HardCopy(1),
		CopyOrImage(2),
		SubstituteDraft(4);

		private Integer code;

		DocNeeded(Integer code) {
			this.code = code;
		}

		public Integer getCode() {
			return code;
		}

		public static DocNeeded getByCode(Integer code) {
			for (DocNeeded item : DocNeeded.values()) {
				if (item.getCode().equals(code))
					return item;
			}
			throw new IllegalArgumentException("Unsupported doc needed value: " + code);
		}
	}
}
