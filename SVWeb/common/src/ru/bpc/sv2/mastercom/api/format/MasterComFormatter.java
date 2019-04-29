package ru.bpc.sv2.mastercom.api.format;


import java.lang.annotation.ElementType;
import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;
import java.lang.annotation.Target;

@Target({ElementType.FIELD})
@Retention(RetentionPolicy.RUNTIME)
public @interface MasterComFormatter {
	Class<? extends MasterComValueFormatter> using();
}
