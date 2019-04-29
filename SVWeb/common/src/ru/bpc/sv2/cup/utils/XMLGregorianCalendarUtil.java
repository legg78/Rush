package ru.bpc.sv2.cup.utils;

import org.apache.log4j.Logger;

import javax.xml.datatype.DatatypeConfigurationException;
import javax.xml.datatype.DatatypeConstants;
import javax.xml.datatype.DatatypeFactory;
import javax.xml.datatype.XMLGregorianCalendar;
import java.util.Date;
import java.util.GregorianCalendar;

public class XMLGregorianCalendarUtil {

	private static final Logger LOG = Logger.getLogger(XMLGregorianCalendarUtil.class);

	public static XMLGregorianCalendar toXMLGregorianCalendar(Date date) {
		if (date == null) {
			return null;
		}

		GregorianCalendar gCalendar = new GregorianCalendar();
		gCalendar.setTime(date);
		XMLGregorianCalendar xmlCalendar = null;
		try {
			xmlCalendar = DatatypeFactory.newInstance()
					.newXMLGregorianCalendar(gCalendar);
		} catch (DatatypeConfigurationException ex) {
			LOG.warn("Error converting date [{}]: {}", ex);
		}
		return xmlCalendar;
	}

	public static XMLGregorianCalendar toXMLGregorianCalendar(Date date, boolean asDate) {
		if (date == null) {
			return null;
		}

		GregorianCalendar gCalendar = new GregorianCalendar();
		gCalendar.setTime(date);
		XMLGregorianCalendar xmlCalendar = null;
		try {
			xmlCalendar = DatatypeFactory.newInstance().newXMLGregorianCalendar(gCalendar);
			if (asDate) {
				xmlCalendar.setHour(DatatypeConstants.FIELD_UNDEFINED);
				xmlCalendar.setMinute(DatatypeConstants.FIELD_UNDEFINED);
				xmlCalendar.setSecond(DatatypeConstants.FIELD_UNDEFINED);
				xmlCalendar.setMillisecond(DatatypeConstants.FIELD_UNDEFINED);
			}

		} catch (DatatypeConfigurationException ex) {
			LOG.warn("Error converting date [{}]: {}", ex);
		}
		return xmlCalendar;
	}

	public static Date toDate(XMLGregorianCalendar calendar) {
		if (calendar == null) {
			return null;
		}
		return calendar.toGregorianCalendar().getTime();
	}
}
