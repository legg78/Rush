package ru.bpc.sv2.constants.pmo;

public class PaymentOrderConstants {

	public final static String ORDER_STATUS_CONFIRMATION 		= "POSA0002";
	public final static String ORDER_STATUS_NOT_REGISTERED		= "POSA0001";	
	public final static String ORDER_STATUS_PROCESSED 			= "POSA0010";
	public final static String ORDER_STATUS_CANCELED 			= "POSA0020";	

	public final static String LINKED_CARD_STATUS_NOT_VALID     = "LNCS0003"; 

	public final static int PURPOSE_TRANSFER_FROM_ORG	= 10000007;
	public final static int PURPOSE_TRANSFER_LINKED_CARD	= 50000013;
	
}
