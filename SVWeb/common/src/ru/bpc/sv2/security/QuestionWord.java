package ru.bpc.sv2.security;

import java.io.Serializable;
import java.util.HashMap;
import java.util.Map;

import ru.bpc.sv2.invocation.IAuditableObject;

public class QuestionWord implements Serializable, IAuditableObject {
	private static final long serialVersionUID = 1737962390256894884L;
	
	private Long id;
	private Integer seqNum;
	private String entityType;
	private Long objectId;
	private String question;
	private Long wordHash;
	private String word;
	private boolean validated;
	private Integer validated2;
	
	public Long getId() {
		return id;
	}
	
	public void setId(Long id) {
		this.id = id;
	}

	public Integer getSeqNum() {
		return seqNum;
	}

	public void setSeqNum(Integer seqNum) {
		this.seqNum = seqNum;
	}

	public String getEntityType() {
		return entityType;
	}

	public void setEntityType(String entityType) {
		this.entityType = entityType;
	}

	public Long getObjectId() {
		return objectId;
	}

	public void setObjectId(Long objectId) {
		this.objectId = objectId;
	}

	public String getQuestion() {
		return question;
	}

	public void setQuestion(String question) {
		this.question = question;
	}

	public Long getWordHash() {
		return wordHash;
	}

	public void setWordHash(Long wordHash) {
		this.wordHash = wordHash;
	}

	public String getWord() {
		return word;
	}

	public void setWord(String word) {
		this.word = word;
	}

	public boolean isValidated() {
		return validated;
	}

	public void setValidated(boolean validated) {
		this.validated = validated;
	}

	public Integer getValidated2() {
		return validated2;
	}

	public void setValidated2(Integer validated2) {
		this.validated2 = validated2;
	}

	@Override
	public Map<String, Object> getAuditParameters() {
		Map<String, Object> result = new HashMap<String, Object>();
		result.put("id", getId());
		result.put("validated", isValidated());
		result.put("entityType", getEntityType());
		result.put("objectId", getObjectId());
		result.put("word", getWord());
		result.put("question", getQuestion());
		return result;
	}
	
}
