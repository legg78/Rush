package ru.bpc.sv2.scheduler.process.svng;

import java.io.StringWriter;
import java.sql.CallableStatement;
import java.util.ArrayList;
import java.util.List;
import javax.xml.stream.XMLEventReader;
import javax.xml.stream.XMLInputFactory;
import javax.xml.stream.events.StartElement;
import javax.xml.stream.events.XMLEvent;
import oracle.jdbc.OracleTypes;
import org.apache.commons.lang3.StringUtils;
import org.dom4j.DocumentHelper;
import ru.bpc.sv2.scheduler.process.AbstractFileSaver;
import ru.bpc.sv2.svng.ClearingOperation;
import ru.bpc.sv2.svng.ClearingOperationGenerate;


/**
 * BPC Group 2017 (c) All Rights Reserved
 */
public class LoadSvxpPostingSaver extends AbstractFileSaver {

	private static final int BATCH_SIZE = 1000;

	@Override
	public void save() throws Exception {
		setupTracelevel();
		XMLEventReader eventReader = null;
		long lineCount = 1;

		try {
			List<ClearingOperation> operationList = new ArrayList<ClearingOperation>(BATCH_SIZE);
			RegisterOperationJdbc dao = new RegisterOperationJdbc(params, con);
			eventReader = getXMLEventReader();
			setUserContext();
			while (eventReader.hasNext()) {
				String operationXML = nextOperation(eventReader);
				if (StringUtils.isNotEmpty(operationXML)) {
					lineCount++;
					operationList.add(ClearingOperationGenerate.assembleFromNode(DocumentHelper.parseText(operationXML).node(0), "yyyy-MM-dd"));
					if (operationList.size() == BATCH_SIZE) {
						registerOperations(dao, operationList);
						operationList.clear();
					}
				}
			}
			if (!operationList.isEmpty()) {
				registerOperations(dao, operationList);
			}
			dao.flush();
		} catch (Exception e) {
			error(String.format("ERROR parsing line %d of file %s", lineCount, fileAttributes != null ? fileAttributes.getFileName() : "(null)"));
			throw e;
		}
		finally {
			if (eventReader != null) {
				eventReader.close();
			}
		}
	}

	private void setUserContext() throws Exception {
		CallableStatement s = null;
		try {
			s = con.prepareCall("{ call com_ui_user_env_pkg.set_user_context( " +
					"  i_user_name  	=> ?" +
					", io_session_id	=> ?" +
					", i_ip_address		=> ?)}"
			);
			s.setString(1, userName);
			s.setObject(2, sessionId, OracleTypes.BIGINT);
			s.setObject(3, null, OracleTypes.VARCHAR);
			s.registerOutParameter(2, OracleTypes.BIGINT);
			s.executeUpdate();
		}
		finally {
			s.close();
		}
	}

	private void registerOperations(RegisterOperationJdbc dao, List<ClearingOperation> operationList) throws Exception {
		debug("Registering " + operationList.size() + " operations");
		dao.insert(operationList);
	}

	private XMLEventReader getXMLEventReader() throws Exception {
		XMLInputFactory inputFactory = XMLInputFactory.newFactory();
		inputFactory.setProperty(XMLInputFactory.IS_COALESCING, true);
		return (inputFactory.createXMLEventReader(inputStream));
	}

	private String nextOperation(XMLEventReader eventReader) throws Exception {
		XMLEvent event = eventReader.peek();
		if (event.isStartElement()) {
			StartElement startElement = event.asStartElement();
			String name = startElement.getName().getLocalPart();
			if ("operation".equalsIgnoreCase(name)) {
				return (toXMLString(eventReader));
			}
		}
		eventReader.nextEvent();
		return (null);
	}

	private String toXMLString(XMLEventReader eventReader) throws Exception {
		StringWriter stringWriter = new StringWriter(4096);
		int depth = 0;
		while (eventReader.hasNext()) {
			XMLEvent event = eventReader.peek();
			if (event.isStartElement()) {
				depth++;
			}
			else if (event.isEndElement()) {
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
}
