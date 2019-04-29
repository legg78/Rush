package util.conversion.xml;

import org.jdom.Document;
import org.jdom.JDOMException;
import org.jdom.input.SAXBuilder;

import java.io.IOException;
import java.io.StringReader;

/**
 * BPC GROUP 2016 (c) All Rights Reserved
 */
public class ConversionXml {

    String xml;

    public ConversionXml() {
    }

    public ConversionXml(String xml){
        this.xml = xml;
    }

    public Document stringToXmlDocConversion() throws JDOMException, IOException {
        SAXBuilder saxBuilder = new SAXBuilder();
        Document doc = saxBuilder.build(new StringReader(xml));
        return doc;
    }
}
