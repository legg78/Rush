package ru.bpc.sv2.dsp;

import java.io.Serializable;

/**
 * search network by operation id or card number
 */
public class CaseNetworkContext implements Serializable {
	private static final long serialVersionUID = 1L;

	private Integer networkId;
	private Integer instId;

	private Long operId;
	private String cardNumber;

	public Integer getNetworkId() {
		return networkId;
	}

	public void setNetworkId(Integer networkId) {
		this.networkId = networkId;
	}

	public Integer getInstId() {
		return instId;
	}

	public void setInstId(Integer instId) {
		this.instId = instId;
	}

	public Long getOperId() {
		return operId;
	}

	public void setOperId(Long operId) {
		this.operId = operId;
	}

	public String getCardNumber() {
		return cardNumber;
	}

	public void setCardNumber(String cardNumber) {
		this.cardNumber = cardNumber;
	}
}
