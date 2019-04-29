package ru.bpc.sv2.pmo;

import ru.bpc.sv2.invocation.ModelIdentifiable;

import java.io.Serializable;

public class PmoOrder extends PmoPaymentOrder implements Serializable, ModelIdentifiable, Cloneable{

	private static final long serialVersionUID = 1L;

	private Long originalId;
	private String msgType;
	private Integer paymentHostId;
	
	public Long getOriginalId() {
		return originalId;
	}

	public void setOriginalId(Long originalId) {
		this.originalId = originalId;
	}

	public String getMsgType() {
		return msgType;
	}

	public void setMsgType(String msgType) {
		this.msgType = msgType;
	}

	public Integer getPaymentHostId() {
		return paymentHostId;
	}

	public void setPaymentHostId(Integer paymentHostId) {
		this.paymentHostId = paymentHostId;
	}
	
}