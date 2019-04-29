package ru.bpc.sv2.common.events;

public class EventConstants {
	public final static String APPLICATION_PROCESSED_SUCCESSFULLY	= "EVNT0002";
	public final static String APPLICATION_PROCESSING_FAILED		= "EVNT0003";
	public final static String DISPUTE_CASE_REGISTERED				= "EVNT1919";
	public final static String DISPUTE_IN_PROGRESS					= "EVNT1920";
	public final static String DISPUTE_RESOLVED_BY_INVALID			= "EVNT1921";
	public final static String DISPUTE_RESOLVED_BY_CREDIT			= "EVNT1922";
	public final static String DISPUTE_RESOLVED_BY_CARDHOLDER		= "EVNT1923";
	public final static String DISPUTE_WRITE_OFF					= "EVNT1924";
	public final static String DISPUTE_CLOSED						= "EVNT1925";
	public final static String DISPUTE_ASSIGNED_TO_USER				= "EVNT1926";
	public final static String ADDED_COMMENT_TO_DISPUTE				= "EVNT1927";
	public final static String DISPUTE_CHANGE_STATUS				= "EVNT1928";
	public final static String DISPUTE_CASE_REGISTERED_AUTO			= "EVNT1929";

	public final static String ADD_CARD_TO_STOP_LIST				= "EVNT2001";
	public final static String UPDATE_CARD_IN_STOP_LIST				= "EVNT2002";
	public final static String DELETE_CARD_FROM_STOP_LIST			= "EVNT2003";

	public final static String SUCCESSFULL_FILE_TRANSMISSION		= "EVNT2011";
	public final static String UNSUCCESSFULL_FILE_TRANSMISSION		= "EVNT2012";

	public final static String CREDIT_BALANCE_TRANSFER		        = "EVNT1035";
	public final static String ROLLBACK_CREDIT_BALANCE_TRANSFER		= "EVNT1036";
}
