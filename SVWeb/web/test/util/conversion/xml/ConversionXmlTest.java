package util.conversion.xml;

import org.jdom.Document;
import org.jdom.Element;
import org.jdom.JDOMException;
import org.junit.Before;
import org.junit.Test;

import java.io.IOException;
import java.util.List;

import static org.junit.Assert.assertEquals;

/**
 * BPC GROUP 2016 (c) All Rights Reserved
 */
public class ConversionXmlTest {

    ConversionXml conversionXml;
    Element element;

    @Before
    public void setUp() throws JDOMException, IOException {
        conversionXml = new ConversionXml(testXml);
        Document document = conversionXml.stringToXmlDocConversion();
        element = document.getRootElement();
    }

    @Test
    public void testThatXmlHaveNeededTags() {
        assertEquals("transaction_amount", element.getChild("transaction_amount").getName());
        assertEquals("installments_count", element.getChild("installments_count").getName());
        assertEquals("fixed_payment_amount", element.getChild("fixed_payment_amount").getName());
        assertEquals("installment_period", element.getChild("installment_period").getName());
        assertEquals("first_installment_date", element.getChild("first_installment_date").getName());
        assertEquals("interest_rate", element.getChild("interest_rate").getName());
        assertEquals("installment_algorithm", element.getChild("installment_algorithm").getName());

        Element installmentsElement = element.getChild("installments");
        List installmentList = installmentsElement.getChildren("installment");

        for (int i = 0; i < installmentList.size(); i++) {
            Element installment = (Element) installmentList.get(i);

            assertEquals("number", installment.getChild("number").getName());
            assertEquals("date", installment.getChild("date").getName());
            assertEquals("amount", installment.getChild("amount").getName());
            assertEquals("installment_amount", installment.getChild("installment_amount").getName());
            assertEquals("interest", installment.getChild("interest").getName());
        }
    }

    @Test
    public void testThatXmlContainCorrectValues() {
        assertEquals("10000", element.getChild("transaction_amount").getValue());
        assertEquals("12", element.getChild("installments_count").getValue());
        assertEquals("8500", element.getChild("fixed_payment_amount").getValue());
        assertEquals("12", element.getChild("installment_period").getValue());
        assertEquals("2017-08-15", element.getChild("first_installment_date").getValue());
        assertEquals("0", element.getChild("interest_rate").getValue());
        assertEquals("DPPAANNU", element.getChild("installment_algorithm").getValue());

        Element installmentsElement = element.getChild("installments");
        List installmentList = installmentsElement.getChildren("installment");

        Element installment1 = (Element) installmentList.get(0);
        assertEquals("1", installment1.getChild("number").getValue());
        assertEquals("2017-08-15", installment1.getChild("date").getValue());
        assertEquals("856", installment1.getChild("amount").getValue());
        assertEquals("856", installment1.getChild("installment_amount").getValue());
        assertEquals("36", installment1.getChild("interest").getValue());

        Element installment2 = (Element) installmentList.get(1);
        assertEquals("2", installment2.getChild("number").getValue());
        assertEquals("2017-09-15", installment2.getChild("date").getValue());
        assertEquals("856", installment2.getChild("amount").getValue());
        assertEquals("856", installment2.getChild("installment_amount").getValue());
        assertEquals("39", installment2.getChild("interest").getValue());
    }


    private static final String testXml = "" +
            "<installment_plan>" +
            "   <transaction_amount>10000</transaction_amount>" +
            "   <installments_count>12</installments_count>" +
            "   <fixed_payment_amount>8500</fixed_payment_amount>" +
            "   <installment_period>12</installment_period>" +
            "   <first_installment_date>2017-08-15</first_installment_date>" +
            "   <interest_rate>0</interest_rate>" +
            "   <installment_algorithm>DPPAANNU</installment_algorithm>" +
            "   <installments>" +
            "       <installment>" +
            "           <number>1</number>" +
            "           <date>2017-08-15</date>" +
            "           <amount>856</amount>" +
            "           <installment_amount>856</installment_amount>" +
            "           <interest>36</interest></installment>" +
            "       <installment>" +
            "           <number>2</number>" +
            "           <date>2017-09-15</date>" +
            "           <amount>856</amount>" +
            "           <installment_amount>856</installment_amount>" +
            "           <interest>39</interest>" +
            "       </installment>" +
            "   </installments>" +
            "</installment_plan>";


}
