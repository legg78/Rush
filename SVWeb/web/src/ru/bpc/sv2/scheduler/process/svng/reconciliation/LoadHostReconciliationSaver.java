package ru.bpc.sv2.scheduler.process.svng.reconciliation;

import oracle.jdbc.OracleTypes;
import org.apache.commons.lang3.StringUtils;
import ru.bpc.sv.svxp.reconciliation.HostOperationType;
import ru.bpc.sv.ws.cup.utils.XmlUtils;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.scheduler.process.AbstractFileSaver;
import ru.bpc.sv2.utils.DBUtils;

import javax.xml.bind.JAXBContext;
import javax.xml.bind.Unmarshaller;
import javax.xml.stream.XMLEventReader;
import javax.xml.stream.XMLInputFactory;
import javax.xml.stream.events.StartElement;
import javax.xml.stream.events.XMLEvent;
import java.io.StringWriter;
import java.sql.CallableStatement;
import java.util.ArrayList;
import java.util.List;

public class LoadHostReconciliationSaver extends AbstractFileSaver {
    @Override
    public void save() throws Exception {
        setupTracelevel();
        XMLEventReader reader = null;
        try {
            List<HostOperationType> operations = new ArrayList<HostOperationType>(RegisterHostReconciliationJdbc.BATCH_SIZE);
            List<Filter> options = new ArrayList<Filter>(RegisterHostReconciliationJdbc.PARAMS_SIZE);
            RegisterHostReconciliationJdbc dao = new RegisterHostReconciliationJdbc(params, con);
            setUserContext();
            reader = getXMLEventReader();
            while (reader.hasNext()) {
                String element = getNextElement(reader);
                if (element != null) {
                    if (isOperation(element)) {
                        operations.add((HostOperationType) XmlUtils.toXMLObject(reader, HostOperationType.class));
                    } else if (isReconciliation(element)) {
                        reader.peek();
                        reader.nextEvent();
                    } else if (StringUtils.isNotEmpty(element)) {
                        options.add(new Filter(element, getElement(reader)));
                    }
                }
                if (operations.size() >= RegisterHostReconciliationJdbc.BATCH_SIZE) {
                    registerOperations(dao, options, operations);
                    operations.clear();
                }
            }
            dao.setSessionFileId(sessionId);
            registerOperations(dao, options, operations);
            dao.flush();
        }
        finally {
            if (reader != null) {
                reader.close();
            }
        }
    }

    protected void registerOperations(RegisterHostReconciliationJdbc dao, List<Filter> options,
                                      List<HostOperationType> operations) throws Exception {
        debug("Register batch of " + operations.size() + " host reconciliation operations");
        dao.insert(options, operations);
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

    private boolean isOperation(String name) {
        return RegisterHostReconciliationJdbc.OPERATION.equalsIgnoreCase(name);
    }

    private boolean isReconciliation(String name) {
        return RegisterHostReconciliationJdbc.RECONCILIATION.equalsIgnoreCase(name);
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

    protected void setUserContext() throws Exception {
        CallableStatement s = null;
        try {
            s = con.prepareCall(RegisterHostReconciliationJdbc.SQL_SET_USER_CONTEXT);
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