package ru.bpc.sv2.reconciliation;

/**
 * Created by Nikishkin on 22.05.2015.
 */
public class RecCase {

	private long id;
	private long parentId;
	private String caseNumber;
	private String name;
	private String desc;
	private String matchSql;

	public long getId() {
		return id;
	}

	public void setId(long id) {
		this.id = id;
	}

	public long getParentId() {
		return parentId;
	}

	public void setParentId(long parentId) {
		this.parentId = parentId;
	}

	public String getCaseNumber() {
		return caseNumber;
	}

	public void setCaseNumber(String caseNumber) {
		this.caseNumber = caseNumber;
	}

	public String getName() {
		return name;
	}

	public void setName(String name) {
		this.name = name;
	}

	public String getDesc() {
		return desc;
	}

	public void setDesc(String desc) {
		this.desc = desc;
	}

	public String getMatchSql() {
		return matchSql;
	}

	public void setMatchSql(String matchSql) {
		this.matchSql = matchSql;
	}
}
