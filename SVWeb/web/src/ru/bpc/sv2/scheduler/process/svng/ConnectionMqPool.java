package ru.bpc.sv2.scheduler.process.svng;

import org.apache.activemq.ActiveMQConnectionFactory;
import javax.jms.*;
import java.util.Vector;

public class ConnectionMqPool {
    private Vector<StorePool> storePool = new Vector<StorePool>();
    private Vector<MessageConsumer> availableCons = new Vector<MessageConsumer>();
    private Vector<MessageConsumer> usedConns = new Vector<MessageConsumer>();
    private String queueIdentifier;
    private ActiveMQConnectionFactory factory;

    public ConnectionMqPool(String url, String queueIdentifier) throws JMSException {
        this.queueIdentifier = queueIdentifier;
        factory = new ActiveMQConnectionFactory(url);

    }

    private MessageConsumer getNewConsumer() throws JMSException{
        Connection connection = factory.createConnection();
        connection.start();
        MessageConsumer consumer;
        Session session = connection.createSession(false, Session.AUTO_ACKNOWLEDGE);
        Destination destination = session.createQueue(queueIdentifier+"?consumer.prefetchSize=0");
        consumer = session.createConsumer(destination);
        storePool.add(new StorePool(connection, session, consumer));
        return consumer;
    }

    public MessageConsumer retrieve() throws JMSException{
        MessageConsumer newConn = null;
        synchronized(this) {
            if (availableCons.size() == 0) {
                newConn = getNewConsumer();
            } else {
                newConn = (MessageConsumer) availableCons.lastElement();
                availableCons.removeElement(newConn);
            }
        }
        usedConns.addElement(newConn);
        return newConn;
    }

    public void putback(MessageConsumer c) throws NullPointerException {
        synchronized(this){
            if (c != null) {
                if (usedConns.removeElement(c)) {
                    availableCons.addElement(c);
                } else {
                    throw new NullPointerException("Connection not in the usedConns array");
                }
            }
        }
    }

    public int getAvailableConnsCnt() {
        return availableCons.size();
    }

    public void closeConnections() throws Exception {
        for(StorePool conn:storePool){
            conn.getConsumer().close();
            conn.getSession().close();
            conn.getConnection().close();
        }
        storePool.clear();
        availableCons.clear();
        usedConns.clear();
    }

    public class StorePool{
        private Session session;
        private MessageConsumer consumer;
        private Connection connection;

        public StorePool(Connection connection, Session session, MessageConsumer consumer){
            this.connection = connection;
            this.session = session;
            this.consumer = consumer;
        }

        public Connection getConnection() {
            return connection;
        }

        public MessageConsumer getConsumer() {
            return consumer;
        }

        public Session getSession() {
            return session;
        }
    }
}
