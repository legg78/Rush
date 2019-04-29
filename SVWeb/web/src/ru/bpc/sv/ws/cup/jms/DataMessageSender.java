package ru.bpc.sv.ws.cup.jms;

import com.bpcbt.sv.pack.HeaderType;
import com.bpcbt.sv.pack.Pack;
import org.apache.activemq.ActiveMQConnectionFactory;
import org.apache.log4j.Logger;
import ru.bpc.sv.ws.cup.utils.XmlUtils;

import javax.jms.*;

public class DataMessageSender {
	private static final Logger logger = Logger.getLogger(DataMessageSender.class);
	private Long sessionId;
	private Connection connection;
	private Session session;
	private MessageProducer producer;

	public DataMessageSender(String url, Long sessionId, String queue) throws Exception {
		this.sessionId = sessionId;
		ActiveMQConnectionFactory connectionFactory = new ActiveMQConnectionFactory(url);
		connection = connectionFactory.createConnection();
		connection.start();
		session = connection.createSession(false, Session.AUTO_ACKNOWLEDGE);
		Destination destination = session.createQueue(queue);
		producer = session.createProducer(destination);
		producer.setDeliveryMode(DeliveryMode.PERSISTENT);
	}

	public void sendOperations(String fileName, String content, long totalRecords, String dataType) {
		try {
			TextMessage message = session.createTextMessage(content);
			Pack pack = new Pack();
			HeaderType header = new HeaderType();
			header.setDataType(dataType);
			header.setSessionId(sessionId.toString());
			header.setFileName(fileName);
			header.setNumber(1);
			header.setPacksTotal(1);
			header.setRecordsTotal(totalRecords);
			header.setRecordsNumber(totalRecords);
			pack.setHeader(header);

			pack.setBody("<![CDATA[" + content + "]]>");
			String xml = XmlUtils.toXMLString("", "pack", pack).replaceAll("&lt;", "<").replaceAll("&gt;", ">");
			message.setText(xml);

			logger.info("Send operations ids to module for session " + sessionId);
			producer.send(message);
		} catch (Exception ex) {
			logger.error("Jms error on sending operations ids to module", ex);
		}
	}

	public void sendOperationsNoPack(String content, boolean first, boolean last, long total, String dataType) {
		try {
			TextMessage message = session.createTextMessage(content);
			message.setLongProperty("session_id", sessionId);
			message.setLongProperty("total", total);
			message.setBooleanProperty("first", first);
			message.setBooleanProperty("last", last);
			message.setStringProperty("data_type", dataType);
			first = false;
			message.setText(content);
			logger.info("Send operations to to module for session " + sessionId);
			producer.send(message);
		} catch (Exception ex) {
			logger.error("Jms error on sending operations to module", ex);
		}
	}
	public void sendOperationsNoPack(String content) {
		try {
			producer.send(session.createTextMessage(content));
		} catch (Exception ex) {
			logger.error("Jms error on sending operations to module", ex);
		}
	}

	public void close() {
		try {
			if (producer != null) {
				producer.close();
			}
		} catch (JMSException e) {
			logger.error("Error on closing JMS producer: " + e.getMessage(), e);
		}
		if (session != null) {
			try {
				session.close();
			} catch (JMSException e) {
				logger.error("Error on closing JMS session: " + e.getMessage(), e);
			}
		}
		try {
			if (connection != null) {
				connection.close();
			}
		} catch (JMSException e) {
			logger.error("Error on closing JMS connection: " + e.getMessage(), e);
		}
	}
}
