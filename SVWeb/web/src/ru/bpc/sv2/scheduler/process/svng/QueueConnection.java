package ru.bpc.sv2.scheduler.process.svng;

import org.apache.activemq.ActiveMQConnectionFactory;
import org.apache.activemq.command.ActiveMQQueue;
import org.apache.log4j.Logger;

import javax.jms.*;

public class QueueConnection {
	Logger logger;
	private Connection connection;
	private String queue;
	private String url;

	public static void main(String[] args) throws JMSException {
		QueueConnection task = new QueueConnection("tcp://svng.dmz1.bpc.in:61616", "merchInbox");
		task.send("test passed");
	}
	
	public QueueConnection(String url, String queue) throws JMSException{
		this.url = url;
		this.queue = queue;
		createConnection();
	}
	
	private void createConnection() throws JMSException{
		if (connection == null){
				ActiveMQConnectionFactory factory = new ActiveMQConnectionFactory(url);
				factory.setWatchTopicAdvisories(false);
				logger("create connection url:" + url + " queue:" + queue, 1);
				connection = factory.createConnection();
				connection.start();
		}
	}
	
	public void send(String text){
		try {
			Session session = connection.createSession(false, Session.AUTO_ACKNOWLEDGE);
			MessageProducer producer = session.createProducer(new ActiveMQQueue(queue));
			TextMessage message = session.createTextMessage();
			message.setText(text);
			producer.send(message);
		} catch (JMSException e) {
			logger(e,2);
		}
		
	}
	
	public void closeConnection() throws JMSException{
		if(connection == null){
			return;
		}
		try {
			connection.close();
		} catch (JMSException e) {
			logger(e, 2);
		}
	}
	
	private void logger(Object log, int c){
		if(logger == null){
			return;
		}
		switch(c){
			case 1: logger.debug(log);
			case 2: logger.error(log);
		}
		
	}

	public Logger getLogger() {
		return logger;
	}

	public void setLogger(Logger logger) {
		this.logger = logger;
	}

}
