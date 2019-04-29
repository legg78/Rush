package ru.bpc.sv2.reconciliation;

import ru.bpc.sv2.invocation.ModelIdentifiable;

import java.sql.Timestamp;

/**
 * Created by Nikishkin on 02.06.2015.
 */
public class RecDataSource {

	private String name;
	private long caseId;
	private String caseName;
	private long captureRuleConfId;
	private String desc;
	private long expectedCount;
	private String lastMsg;
	private long receivedCount;
	private Timestamp refreshedAt;
	private String status;

	public String getName() {
		return name;
	}

	public void setName(String name) {
		this.name = name;
	}

	public long getCaptureRuleConfId() {
		return captureRuleConfId;
	}

	public void setCaptureRuleConfId(long captureRuleConfId) {
		this.captureRuleConfId = captureRuleConfId;
	}

	public String getLastMsg() {
		return lastMsg;
	}

	public void setLastMsg(String lastMsg) {
		this.lastMsg = lastMsg;
	}

	public Timestamp getRefreshedAt() {
		return refreshedAt;
	}

	public void setRefreshedAt(Timestamp refreshedAt) {
		this.refreshedAt = refreshedAt;
	}

	public String getDesc() {
		return desc;
	}

	public void setDesc(String desc) {
		this.desc = desc;
	}

	public long getExpectedCount() {
		return expectedCount;
	}

	public void setExpectedCount(long expectedCount) {
		this.expectedCount = expectedCount;
	}

	public long getReceivedCount() {
		return receivedCount;
	}

	public void setReceivedCount(long receivedCount) {
		this.receivedCount = receivedCount;
	}

	public String getStatus() {
		return status;
	}

	public void setStatus(String status) {
		this.status = status;
	}

	public long getCaseId() {
		return caseId;
	}

	public void setCaseId(long caseId) {
		this.caseId = caseId;
	}

	public String getCaseName() {
		return caseName;
	}

	public void setCaseName(String caseName) {
		this.caseName = caseName;
	}
}
