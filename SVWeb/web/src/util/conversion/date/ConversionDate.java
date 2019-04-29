package util.conversion.date;

import javax.xml.datatype.DatatypeFactory;
import javax.xml.datatype.XMLGregorianCalendar;
import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Date;

/**
 * BPC GROUP 2016 (c) All Rights Reserved
 */
public class ConversionDate {

    String sdate;
    XMLGregorianCalendar calendar;

    public ConversionDate(){}

    //Only for yyyy-MM-dd format
    public ConversionDate(String date) {
        this.sdate = date;
    }

    public ConversionDate(XMLGregorianCalendar calendar) {
        this.calendar = calendar;
    }

    public Date calendarToDate() {
        return calendar.toGregorianCalendar().getTime();
    }

    public XMLGregorianCalendar stringDateToCalendar() throws Exception {
        XMLGregorianCalendar result = DatatypeFactory.newInstance().newXMLGregorianCalendar(sdate);
        return result;
    }

}
