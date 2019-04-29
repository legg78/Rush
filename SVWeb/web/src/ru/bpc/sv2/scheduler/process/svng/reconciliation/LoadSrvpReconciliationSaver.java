package ru.bpc.sv2.scheduler.process.svng.reconciliation;

import oracle.jdbc.OracleTypes;
import org.apache.commons.lang3.StringUtils;
import ru.bpc.sv.svxp.reconciliation.PaymentOrderType;
import ru.bpc.sv.ws.cup.utils.XmlUtils;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.scheduler.process.AbstractFileSaver;
import ru.bpc.sv2.utils.DBUtils;

import javax.xml.bind.JAXBContext;
import javax.xml.bind.JAXBElement;
import javax.xml.bind.Unmarshaller;
import javax.xml.stream.XMLEventReader;
import javax.xml.stream.XMLInputFactory;
import javax.xml.stream.events.StartElement;
import javax.xml.stream.events.XMLEvent;
import javax.xml.transform.stream.StreamSource;
import java.io.StringReader;
import java.io.StringWriter;
import java.sql.CallableStatement;
import java.util.ArrayList;
import java.util.List;

public class LoadSrvpReconciliationSaver extends AbstractFileSaver {
    @Override
    public void save() throws Exception {
        setupTracelevel();
        XMLEventReader reader = null;
        try {
            List<PaymentOrderType> orders = new ArrayList<PaymentOrderType>(RegisterSrvpReconciliationJdbc.BATCH_SIZE);
            List<Filter> options = new ArrayList<Filter>(RegisterSrvpReconciliationJdbc.PARAMS_SIZE);
            RegisterSrvpReconciliationJdbc dao = new RegisterSrvpReconciliationJdbc(params, con);
            setUserContext();
            reader = getXMLEventReader();
            while (reader.hasNext()) {
                String element = getNextElement(reader);
                if (element != null) {
                    if (isOrder(element)) {
                        orders.add((PaymentOrderType) XmlUtils.toXMLObject(reader, PaymentOrderType.class));
                    } else if (isReconciliation(element)) {
                        reader.peek();
                        reader.nextEvent();
                    } else if (StringUtils.isNotEmpty(element)) {
                        options.add(new Filter(element, getElement(reader)));
                    }
                }
                if (orders.size() >= RegisterSrvpReconciliationJdbc.BATCH_SIZE) {
                    registerOrders(dao, options, orders);
                    orders.clear();
                }
            }
            dao.setSessionFileId(sessionId);
            registerOrders(dao, options, orders);
            dao.flush();
        } finally {
            if (reader != null) {
                reader.close();
            }
        }
    }

    protected void registerOrders(RegisterSrvpReconciliationJdbc dao,
                                  List<Filter> options,
                                  List<PaymentOrderType> orders) throws Exception {
        debug("Register batch of " + orders.size() + " service provider's reconciliation payment orders");
        dao.insert(options, orders);
    }

    private XMLEventReader getXMLEventReader() throws Exception {
        XMLInputFactory inputFactory = XMLInputFactory.newFactory();
        inputFactory.setProperty(XMLInputFactory.IS_COALESCING, true);
        return (inputFactory.createXMLEventReader(inputStream));
    }

    private String getNextElement(XMLEventReader eventReader) throws Exception {
        XMLEvent event = eventReader.peek();
        if (event.isStartElement()) {
            StartElement startElement = event.asStartElement();
            return startElement.getName().getLocalPart();
        }
        eventReader.nextEvent();
        return null;
    }

    private boolean isOrder(String name) {
        return RegisterSrvpReconciliationJdbc.ORDER.equalsIgnoreCase(name);
    }

    private boolean isReconciliation(String name) {
        return RegisterSrvpReconciliationJdbc.RECONCILIATION.equalsIgnoreCase(name);
    }

    private String getElement(XMLEventReader eventReader) throws Exception {
        StringWriter stringWriter = new StringWriter(4096);
        int depth = 0;
        while (eventReader.hasNext()) {
            XMLEvent event = eventReader.peek();
            if (event.isStartElement()) {
                depth++;
            } else if (event.isEndElement()) {
                depth--;
            } else if (event.isCharacters()) {
                event.writeAsEncodedUnicode(stringWriter);
            }
            event = eventReader.nextEvent();
            if (depth == 0) {
                break;
            }
        }
        return stringWriter.toString();
    }

    private String toXMLString(XMLEventReader eventReader) throws Exception {
        StringWriter stringWriter = new StringWriter(4096);
        int depth = 0;
        while (eventReader.hasNext()) {
            XMLEvent event = eventReader.peek();
            if (event.isStartElement()) {
                depth++;
            } else if (event.isEndElement()) {
                depth--;
            }
            event = eventReader.nextEvent();
            event.writeAsEncodedUnicode(stringWriter);
            if (depth == 0) {
                break;
            }
        }
        return stringWriter.toString();
    }

    protected void setUserContext() throws Exception {
        CallableStatement s = null;
        try {
            s = con.prepareCall(RegisterSrvpReconciliationJdbc.SQL_SET_USER_CONTEXT);
            s.setString(1, userName);
            s.setObject(2, sessionId, OracleTypes.BIGINT);
            s.setObject(3, null, OracleTypes.VARCHAR);
            s.registerOutParameter(2, OracleTypes.BIGINT);
            s.executeUpdate();
        } finally {
            DBUtils.close(s);
        }
    }
}
