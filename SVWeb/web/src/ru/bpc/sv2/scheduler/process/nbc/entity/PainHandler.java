package ru.bpc.sv2.scheduler.process.nbc.entity;

import org.apache.log4j.Logger;

import javax.xml.datatype.DatatypeConfigurationException;
import javax.xml.datatype.DatatypeFactory;
import javax.xml.datatype.XMLGregorianCalendar;
import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerFactory;
import java.io.StringWriter;
import java.util.Date;
import java.util.GregorianCalendar;

public abstract class PainHandler {
    public final static String HEADER = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>";
    public final static String SEPARATOR = "<\\?xml version=\"1\\.0\" encoding=\"UTF-8\" standalone=\"yes\"\\?>";
    public final static String FOOTER = "</Document>";

    protected static Logger logger = Logger.getLogger("PROCESSES");
    protected DocumentBuilder builder;
    protected Transformer transformer;
    protected Object data;
    protected Object template;

    public PainHandler() throws Exception {
        builder = DocumentBuilderFactory.newInstance().newDocumentBuilder();
        transformer = TransformerFactory.newInstance().newTransformer();
    }

    public Object getData() {
        return data;
    }
    public void setData(Object data) {
        this.data = data;
    }

    public abstract boolean parse(String raw);
    public abstract String asString(boolean cutHeader) throws Exception;

    protected XMLGregorianCalendar getGregorianCurrentDate() {
        XMLGregorianCalendar xmlGC = null;
        try {
            GregorianCalendar gc = new GregorianCalendar();
            gc.setTime(new Date());
            xmlGC = DatatypeFactory.newInstance().newXMLGregorianCalendar(gc);
        } catch (DatatypeConfigurationException e) {
            logger.error("", e);
        }
        return xmlGC;
    }

    protected String getCleanWriterContent(boolean cutHeader, StringWriter writer,
                                           String namespace1, String namespace2, String namespace3) {
        String out = writer.toString();
        out = out.replace(":ns2", "").replace("ns2:", "");
        out = out.replace(":xs", "").replace("xs:", "");
        if (cutHeader && namespace1 != null) {
            return out.replace(HEADER, "").replace(namespace1, "");
        }
        return (namespace2 != null && namespace3 != null) ? out.replace(namespace2, namespace3) : out;
    }
}
