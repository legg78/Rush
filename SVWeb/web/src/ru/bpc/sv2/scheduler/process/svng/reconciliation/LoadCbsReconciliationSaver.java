package ru.bpc.sv2.scheduler.process.svng.reconciliation;

import oracle.jdbc.OracleTypes;
import org.apache.commons.lang3.StringUtils;
import ru.bpc.sv.svxp.reconciliation.OperationType;
import ru.bpc.sv2.cup.utils.XMLGregorianCalendarUtil;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.scheduler.process.AbstractFileSaver;
import ru.bpc.sv.ws.cup.utils.XmlUtils;

import javax.xml.bind.JAXBContext;
import javax.xml.bind.JAXBElement;
import javax.xml.bind.Unmarshaller;
import javax.xml.datatype.XMLGregorianCalendar;
import javax.xml.stream.XMLEventReader;
import javax.xml.stream.XMLInputFactory;
import javax.xml.stream.events.StartElement;
import javax.xml.stream.events.XMLEvent;
import java.io.StringReader;
import java.io.StringWriter;
import java.math.BigDecimal;
import java.sql.CallableStatement;
import java.sql.Date;
import java.util.ArrayList;
import java.util.List;

public class LoadCbsReconciliationSaver extends AbstractFileSaver {
    @Override
    public void save() throws Exception {
        setupTracelevel();
        XMLEventReader reader = null;
        try {
            List<OperationType> operations = new ArrayList<OperationType>(RegisterReconciliationJdbc.BATCH_SIZE);
            List<Filter> options = new ArrayList<Filter>(RegisterReconciliationJdbc.PARAMS_SIZE);
            RegisterReconciliationJdbc dao = new RegisterReconciliationJdbc(params, con);
            setUserContext();
            reader = getXMLEventReader();
            while (reader.hasNext()) {
                String element = getNextElement(reader);
                if (isOperation(element)) {
                    operations.add((OperationType)XmlUtils.toXMLObject(reader, OperationType.class));
                } else if (isReconciliation(element)) {
                    reader.peek();
                    reader.nextEvent();
                } else if (StringUtils.isNotEmpty(element)) {
                    options.add(new Filter(element, getElement(reader)));
                }
                if (operations.size() >= RegisterReconciliationJdbc.BATCH_SIZE) {
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

    protected void registerOperations(RegisterReconciliationJdbc dao, List<Filter> options,
                                    List<OperationType> operations) throws Exception {
        debug("Register batch of " + operations.size() + " reconciliation operations from CBS");
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
        return RegisterReconciliationJdbc.OPERATION.equalsIgnoreCase(name);
    }

    private boolean isReconciliation(String name) {
        return RegisterReconciliationJdbc.RECONCILIATION.equalsIgnoreCase(name);
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
            s = con.prepareCall(RegisterReconciliationJdbc.SQL_SET_USER_CONTEXT);
            s.setString(1, userName);
            s.setObject(2, sessionId, OracleTypes.BIGINT);
            s.setObject(3, null, OracleTypes.VARCHAR);
            s.registerOutParameter(2, OracleTypes.BIGINT);
            s.executeUpdate();
        } finally {
            s.close();
        }
    }
}
