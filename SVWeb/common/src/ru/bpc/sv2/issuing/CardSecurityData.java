package ru.bpc.sv2.issuing;

import ru.bpc.sv2.invocation.IAuditableObject;

import java.io.Serializable;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;

@SuppressWarnings("unused")
public class CardSecurityData implements Serializable, IAuditableObject {
	private Long cardId;
	private String cardNumber;
	private Date expirationDate;
	private Integer cardSequentalNumber;
	private Long cardInstanceId;
	private String state;
	private String pvv;
	private Long pinOffset;
	private String pinBlock;
	private Integer keyIndex;
	private String pinBlockFormat;
	private Date issueDate;

	public Long getCardId() {
		return cardId;
	}
	public void setCardId(Long cardId) {
		this.cardId = cardId;
	}

	public String getCardNumber() {
		return cardNumber;
	}
	public void setCardNumber(String cardNumber) {
		this.cardNumber = cardNumber;
	}

	public Date getExpirationDate() {
		return expirationDate;
	}
	public void setExpirationDate(Date expirationDate) {
		this.expirationDate = expirationDate;
	}

	public Integer getCardSequentalNumber() {
		return cardSequentalNumber;
	}
	public void setCardSequentalNumber(Integer cardSequentalNumber) {
		this.cardSequentalNumber = cardSequentalNumber;
	}

	public Long getCardInstanceId() {
		return cardInstanceId;
	}
	public void setCardInstanceId(Long cardInstanceId) {
		this.cardInstanceId = cardInstanceId;
	}

	public String getState() {
		return state;
	}
	public void setState(String state) {
		this.state = state;
	}

	public String getPvv() {
		return pvv;
	}
	public void setPvv(String pvv) {
		this.pvv = pvv;
	}

	public Long getPinOffset() {
		return pinOffset;
	}
	public void setPinOffset(Long pinOffset) {
		this.pinOffset = pinOffset;
	}

	public String getPinBlock() {
		return pinBlock;
	}
	public void setPinBlock(String pinBlock) {
		this.pinBlock = pinBlock;
	}

	public Integer getKeyIndex() {
		return keyIndex;
	}
	public void setKeyIndex(Integer keyIndex) {
		this.keyIndex = keyIndex;
	}

	public String getPinBlockFormat() {
		return pinBlockFormat;
	}
	public void setPinBlockFormat(String pinBlockFormat) {
		this.pinBlockFormat = pinBlockFormat;
	}

	public Date getIssueDate() {
		return issueDate;
	}
	public void setIssueDate(Date issueDate) {
		this.issueDate = issueDate;
	}

	@Override
	public Map<String, Object> getAuditParameters() {
		Map<String, Object> result = new HashMap<String, Object>();
		result.put("cardId", getCardId());
		result.put("cardNumber", getCardNumber());
		result.put("cardSequentalNumber", getCardSequentalNumber());
		result.put("cardInstanceId", getCardInstanceId());
		result.put("state", getState());
		result.put("pvv", getPvv());
		result.put("pinBlock", getPinBlock());
		result.put("keyIndex", getKeyIndex());
		result.put("pinBlockFormat", getPinBlockFormat());
		return result;
	}
}
