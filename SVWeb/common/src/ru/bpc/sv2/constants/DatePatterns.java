package ru.bpc.sv2.constants;

public interface DatePatterns {
	String DEFAULT_TIME						= "00:00:00";
	String DEFAULT_SHORT_TIME				= "00:00";

	String TIME_PATTERN						= "HH:mm";
	String TIME_SECONDS_PATTERN				= "HH:mm:ss";
	String TIME_MILLISECONDS_PATTERN		= "HH:mm:ss.SSS";
	String TIME_PATTERN_US					= "HH:mm";
	String TIME_SECONDS_PATTERN_US			= "HH:mm:ss";
	String TIME_MILLISECONDS_PATTERN_US		= "HH:mm:ss.SSS";
	String ISO_TIME_PATTERN					= "HH:mm:ss";

	String DATE_PATTERN						= "dd.MM.yyyy";
	String DATE_PATTERN_US					= "MM.dd.yyyy";
	String ISO_DATE_PATTERN					= "yyyy-MM-dd";
	String EXP_DATE_PATTERN					= "MM/yy";
	String FULL_EXP_DATE_PATTERN			= "MM/yyyy";

	String FULL_DATE_PATTERN				= "yyyy-MM-dd HH:mm:ss";
	String EXTENDED_DATE_PATTERN			= "yyyy-MM-dd HH:mm:ss.SSS";
	String REPORT_DATE_TIME_PATTERN			= "yyyyMMdd_HHmmss";
	String DB_CONVERT_DATE_PATTERN			= "yyyyMMddHHmmss";
	String SHORT_DATETIME_PATTERN			= "dd.MM.yyyy HH:mm";
	String DATETIME_PATTERN					= "dd.MM.yyyy HH:mm:ss";
	String DATETIME_PATTERN_US				= "MM.dd.yyyy hh:mm:ss";
}
