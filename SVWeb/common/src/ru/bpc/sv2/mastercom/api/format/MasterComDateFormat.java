package ru.bpc.sv2.mastercom.api.format;

import java.lang.annotation.ElementType;
import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;
import java.lang.annotation.Target;

/**
 * Only for Date fields
 */
@Target({ElementType.FIELD})
@Retention(RetentionPolicy.RUNTIME)
public @interface MasterComDateFormat {
	/**
	 * can be value 'number' or any valid date format (for example: yyMMdd)
 	 */
	String value();
}
