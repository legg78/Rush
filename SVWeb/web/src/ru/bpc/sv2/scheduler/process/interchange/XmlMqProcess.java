package ru.bpc.sv2.scheduler.process.interchange;

import ru.bpc.sv.ws.cup.jms.DataMessageSender;
import ru.bpc.sv.ws.svng.InterchangeClient;
import ru.bpc.sv2.scheduler.process.IbatisExternalProcess;
import ru.bpc.sv2.utils.SystemException;
import ru.bpc.sv2.utils.UserException;

import javax.xml.stream.XMLOutputFactory;
import javax.xml.stream.XMLStreamWriter;
import java.io.StringWriter;
import java.sql.ResultSet;
import java.sql.Timestamp;
import java.text.SimpleDateFormat;
import java.util.HashMap;
import java.util.Map;

public abstract class XmlMqProcess {
	private static final long OPERATIONS_IN_PACKAGE = 2000;
	private static final int BUFFER_SIZE = 5000;

	protected final SimpleDateFormat timestampSdf = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss");
	protected XMLStreamWriter writer;
	protected StringWriter buffer;
	protected DataMessageSender jmsSender;
	protected InterchangeClient interchangeClient;
	protected int total = 0;
	protected IbatisExternalProcess process;

	private Map<String, String> startTags = new HashMap<String, String>();

	public static interface WriteContentListener {
		void writeContent(XMLStreamWriter writer) throws Exception;
	}

	protected XmlMqProcess(IbatisExternalProcess process) {
		this.process = process;
	}

	public void execute() throws SystemException, UserException {
		try {
			jmsSender = new DataMessageSender(getMqUrl(), process.processSessionId(), getQueue());
			interchangeClient = new InterchangeClient(getMqUrl(), getWsQueue(), process.processSessionId());
			buffer = new StringWriter(BUFFER_SIZE);
			writer = XMLOutputFactory.newInstance().createXMLStreamWriter(buffer);
		} catch (Exception ex) {
			process.error(ex);
		}
	}

	protected void writeTag(String tag, Object value) throws Exception {
		if (value != null) {
			writer.writeStartElement(tag);
			writer.writeCharacters(value.toString());
			writer.writeEndElement();
		}
	}

	protected void writeTag(String tag, String value) throws Exception {
		if (value != null) {
			writer.writeStartElement(tag);
			writer.writeCharacters(value.toString());
			writer.writeEndElement();
		}
	}

	protected void writeTag(String tag, Timestamp value) throws Exception {
		if (value != null) {
			writeTag(tag, timestampSdf.format(value));
		}
	}

	protected void addStartTag(String name, String value) {
		startTags.put(name, value);
	}

	protected void startDocument(String rootTag) throws Exception {
		writer = XMLOutputFactory.newInstance().createXMLStreamWriter(buffer);
		writer.writeStartDocument("UTF-8", "1.0");
		writer.writeStartElement(rootTag);
		if (!startTags.isEmpty()) {
			for (Map.Entry<String, String> en : startTags.entrySet()) {
				writeTag(en.getKey(), en.getValue());
			}
		}
	}

	protected void processData(ResultSet rs, String startTag, String wrapTag, WriteContentListener listener)
			throws Exception {
		int cnt = 0;
		int total = 0;
		boolean first = true;
		startDocument(startTag);
		while (rs.next()) {
			writer.writeStartElement(wrapTag);
			listener.writeContent(writer);
			writer.writeEndElement();
			cnt++;
			if (cnt >= OPERATIONS_IN_PACKAGE) {
				sendPack(cnt, first, false);
				first = false;
				total += cnt;
				cnt = 0;
				process.logCurrent(total, 0);
				startDocument(startTag);
			}
		}
		sendPack(cnt, first, true);
	}

	protected void sendPack(int cnt, boolean first, boolean last) throws Exception {
		writer.writeEndElement();
		writer.writeEndDocument();
		writer.flush();
		process.trace("Send " + cnt + " " + getDataType().name().toLowerCase());
		total += cnt;
		process.logCurrent(total, 0);
		jmsSender.sendOperationsNoPack(buffer.toString(), first, last, cnt, getDataType().name());
		buffer.getBuffer().setLength(0);
	}

	protected abstract InterchangeDataTypes getDataType();

	protected abstract String getMqUrl();

	protected abstract String getQueue();

	protected abstract String getWsQueue();
}
