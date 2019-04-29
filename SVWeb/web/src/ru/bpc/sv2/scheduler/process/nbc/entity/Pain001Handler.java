package ru.bpc.sv2.scheduler.process.nbc.entity;

import com.bpcbt.sv.nbc.pain001.CustomerCreditTransferInitiationV05;
import com.bpcbt.sv.nbc.pain001.Document;
import org.apache.commons.io.IOUtils;
import org.xml.sax.SAXException;
import ru.bpc.sv2.utils.UserException;

import javax.xml.XMLConstants;
import javax.xml.bind.JAXBContext;
import javax.xml.bind.JAXBElement;
import javax.xml.bind.Marshaller;
import javax.xml.bind.Unmarshaller;
import javax.xml.namespace.QName;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.transform.Source;
import javax.xml.transform.dom.DOMSource;
import javax.xml.transform.stream.StreamResult;
import javax.xml.transform.stream.StreamSource;
import javax.xml.validation.Schema;
import javax.xml.validation.SchemaFactory;
import javax.xml.validation.Validator;
import java.io.ByteArrayInputStream;
import java.io.InputStream;
import java.io.StringReader;
import java.io.StringWriter;

public class Pain001Handler extends PainHandler {
    public final static String HEADER = "<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\"?>\n" +
                                        "<Document xsi:schemaLocation=\"xsd/pain.001.001.05.xsd\" " +
                                        "xmlns=\"urn:iso:std:iso:20022:tech:xsd:pain.001.001.05\" " +
                                        "xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\">\n";
    public final static String NAMESPACE = " xmlns=\"http://www.w3.org/2001/XMLSchema\" " +
                                           "xmlns=\"urn:iso:std:iso:20022:techd:pain.001.001.05\"";

    private Unmarshaller unmarshaller;
    private Marshaller marshaller;
    private QName qName;

    public Pain001Handler() throws Exception {
        JAXBContext jaxbContext = JAXBContext.newInstance(Document.class);
        DocumentBuilderFactory factory = DocumentBuilderFactory.newInstance();
        JAXBContext instance = JAXBContext.newInstance(CustomerCreditTransferInitiationV05.class);

        qName = new QName("http://www.w3.org/2001/XMLSchema", "CstmrCdtTrfInitn");
        unmarshaller = jaxbContext.createUnmarshaller();
        marshaller = instance.createMarshaller();
    }

    @Override
    public String asString(boolean cutHeader) throws Exception {
        CustomerCreditTransferInitiationV05 content = ((Document)data).getCstmrCdtTrfInitn();
        JAXBElement<CustomerCreditTransferInitiationV05> root = new JAXBElement<CustomerCreditTransferInitiationV05>(qName, CustomerCreditTransferInitiationV05.class, content);
        org.w3c.dom.Document document = builder.newDocument();
        marshaller.marshal(root, document);
        StringWriter writer = new StringWriter();
        transformer.transform(new DOMSource(document), new StreamResult(writer));
        return getCleanWriterContent(cutHeader, writer, NAMESPACE, null, null);
    }
    @Override
    public boolean parse(final String raw) {
        try {
            JAXBElement<Document>tmp = (JAXBElement)unmarshaller.unmarshal(new StringReader(raw));
            data = tmp.getValue();
        } catch (Exception e) {
            logger.trace(e.getMessage());
            return false;
        }
        return true;
    }
}
