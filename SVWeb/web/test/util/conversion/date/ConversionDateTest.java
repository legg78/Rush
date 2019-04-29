package util.conversion.date;

import org.junit.After;
import org.junit.Before;
import org.junit.Test;

import javax.xml.datatype.DatatypeConfigurationException;
import javax.xml.datatype.DatatypeFactory;
import javax.xml.datatype.XMLGregorianCalendar;
import java.text.DateFormat;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.GregorianCalendar;

import static org.junit.Assert.assertEquals;

/**
 * BPC GROUP 2016 (c) All Rights Reserved
 */
public class ConversionDateTest {

    ConversionDate conversionDate;
    public DateFormat dFormat;
    String testTime;
    String format = "YYYY-MM-DD'T'hh:mm:ss";

    @Before
    public void setUp() throws ParseException, DatatypeConfigurationException {
        dFormat = new SimpleDateFormat("YYYY-MM-DD'T'hh:mm:ss");
        testTime = "2017-08-15T14:41:00";
        GregorianCalendar cal = new GregorianCalendar();
        cal.setTime(new SimpleDateFormat(format).parse(testTime));
        XMLGregorianCalendar calendar = DatatypeFactory.newInstance().newXMLGregorianCalendar(cal);
        conversionDate = new ConversionDate(calendar);
    }

    @Test
    public void calendarToDateTest() throws ParseException {
        Date result = conversionDate.calendarToDate();
        assertEquals(result, dFormat.parse(testTime));
    }
}
