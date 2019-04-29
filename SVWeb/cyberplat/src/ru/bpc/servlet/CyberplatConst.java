package ru.bpc.servlet;

public abstract class CyberplatConst {
	
	public static final String ACTION = "action";
	public static final String NUMBER = "number";
	public static final String TYPE = "type";
	public static final String AMOUNT = "amount";
	public static final String RECEIPT = "receipt";
	public static final String DATE = "date";
	public static final String MES = "mes";
	public static final String ADDITIONAL = "additional";
	
	public static final String ACTION_CHECK = "check";
	public static final String ACTION_PAYMENT = "payment";
	public static final String ACTION_CANCEL = "cancel";
	public static final String ACTION_STATUS = "status";
	
	public static final String RESPONSE_ROOT = "response";
	public static final String RESPONSE_CODE = "code";
	public static final String RESPONSE_MESSAGE = "message";
	public static final String RESPONSE_DATE = "date";
	public static final String RESPONSE_AUTHCODE = "authcode";
	public static final String RESPONSE_ADD = "add";
	
	public static final int ERR_INTERNAL_ERROR		 	= -1;
	public static final int ERR_UNKNOW_REQUEST_TYPE 	= 1;
	public static final int ERR_CERT_NOT_PRESENTED 		= 10;
	
	
}
