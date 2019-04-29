package ru.bpc.sv2.scheduler.process.external.svng;

import org.apache.activemq.ActiveMQConnectionFactory;
import org.apache.log4j.Logger;
import ru.bpc.sv2.constants.SystemConstants;
import ru.bpc.sv2.constants.settings.LevelNames;
import ru.bpc.sv2.io.BytesMessageInputStream;
import ru.bpc.sv2.logic.SettingsDao;
import ru.bpc.sv2.settings.constants.SettingsConstants;
import ru.bpc.sv2.utils.UserException;

import javax.jms.*;
import java.io.ByteArrayInputStream;
import java.io.InputStream;

public class ProcessQueue {
	private static final Logger logger = Logger.getLogger("PROCESSES");
	private javax.jms.Connection connection;
	private MessageConsumer consumer;
	private QueueBrowser queueBrowser;

	public static ProcessQueue create(String queueIdentifier) throws UserException {
		ProcessQueue processQueue = new ProcessQueue();
		processQueue.openConnection(queueIdentifier);
		return processQueue;
	}

	private void openConnection(String queueIdentifier) throws UserException {
		connection = null;
		try {
			SettingsDao _settingsDao = new SettingsDao();
			String url = _settingsDao.getParameterValueV(null, SettingsConstants.MESSAGE_QUEUE_LOCATION, LevelNames.SYSTEM, null);
			ActiveMQConnectionFactory factory = new ActiveMQConnectionFactory(url);
			connection = factory.createConnection();
			connection.start();

			Session session = connection.createSession(false, Session.AUTO_ACKNOWLEDGE);
			Destination destination = session.createQueue(queueIdentifier+"?consumer.prefetchSize=1");
			consumer = session.createConsumer(destination);

		} catch (Exception e) {
			logger.error(e);
			throw new UserException(e);
		}
	}

	public void closeConnection() throws Exception {
		Exception exc = null;
		try {
			if (consumer != null)
				consumer.close();
		} catch (Exception e) {
			logger.error(e);
			exc = exc != null ? exc : e;
		}
		try {
			if (connection != null)
				connection.close();
		} catch (Exception e) {
			logger.error(e);
			exc = exc != null ? exc : e;
		}
		if (exc != null) {
			throw exc;
		}
	}

	public InputStream getMessageStream(Integer timeout) throws Exception {
		InputStream bmis = null;
		logger.debug("gets inputstream...");
		Message message;
		try {
			message = consumer.receive(timeout * 1000);
		} catch (JMSException e) {
			throw new UserException("Can't get data from the queue within " + timeout + " seconds.");
		}
		if(message == null){
			throw new UserException("Queue is empty");
		}
		if (message instanceof TextMessage) {
			logger.debug("message instanceof TextMessage");
			TextMessage bMessage = (TextMessage) message;
			bmis = new ByteArrayInputStream(bMessage.getText().getBytes(SystemConstants.DEFAULT_CHARSET));
		} else if (message instanceof BytesMessage) {
			BytesMessage bMessage = (BytesMessage) message;
			bmis = new BytesMessageInputStream(bMessage);
		}
		return bmis;
	}
}
