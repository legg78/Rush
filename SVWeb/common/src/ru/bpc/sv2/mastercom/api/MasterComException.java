package ru.bpc.sv2.mastercom.api;

import com.mastercard.api.core.exception.ApiException;

public class MasterComException extends Exception {
	public MasterComException(ApiException e) {
		super(String.format("Http status: %d, message: %s, reason code: %s, source: %s", e.getHttpStatus(), e.getMessage(), e.getReasonCode(), e.getSource()), e);
	}
}
