package ru.bpc.sv2.dsp;

import java.io.Serializable;

public class DisputeListCondition implements Serializable {
	private static final long serialVersionUID = -4956817365768396633L;
	
	private Integer id;
	private Integer initRule;
	private Integer genRule;
	private Integer funcOrder;
	private Integer modId;
	private String type;
	private String lang;
	private String msgType;
	
	public Integer getId() {
		return id;
	}
	
	public void setId(Integer id) {
		this.id = id;
	}

	public Integer getInitRule() {
		return initRule;
	}

	public void setInitRule(Integer initRule) {
		this.initRule = initRule;
	}

	public Integer getGenRule() {
		return genRule;
	}

	public void setGenRule(Integer genRule) {
		this.genRule = genRule;
	}

	public Integer getFuncOrder() {
		return funcOrder;
	}

	public void setFuncOrder(Integer funcOrder) {
		this.funcOrder = funcOrder;
	}

	public Integer getModId() {
		return modId;
	}

	public void setModId(Integer modId) {
		this.modId = modId;
	}

	public String getType() {
		return type;
	}

	public void setType(String type) {
		this.type = type;
	}

	public String getLang() {
		return lang;
	}

	public void setLang(String lang) {
		this.lang = lang;
	}

	public String getMsgType() {
		return msgType;
	}

	public void setMsgType(String msgType) {
		this.msgType = msgType;
	}
}
