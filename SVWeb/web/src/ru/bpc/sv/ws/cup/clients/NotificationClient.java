package ru.bpc.sv.ws.cup.clients;

import com.bpcbt.sv.notification.message.v1.AmountNotification;
import com.bpcbt.sv.notification.service.v1.NotificationPortType;
import org.apache.cxf.jaxws.JaxWsProxyFactoryBean;
import org.apache.cxf.transport.jms.spec.JMSSpecConstants;
import org.apache.log4j.Logger;


public class NotificationClient {
	private static final Logger logger = Logger.getLogger(NotificationClient.class);

	private NotificationPortType client;

	public NotificationClient(String mqUrl, String queue) throws Exception {
		String address = String.format("jms:jndi:dynamicQueues/%s"
				+ "?jndiInitialContextFactory=org.apache.activemq.jndi.ActiveMQInitialContextFactory"
				+ "&jndiConnectionFactoryName=ConnectionFactory"
				+ "&jndiURL=%s", queue, mqUrl);
		JaxWsProxyFactoryBean factory = new JaxWsProxyFactoryBean();
		factory.setTransportId(JMSSpecConstants.SOAP_JMS_SPECIFICATION_TRANSPORTID);
		factory.setServiceClass(NotificationPortType.class);
		factory.setAddress(address);
		client = (NotificationPortType) factory.create();
	}

	public void sendReadyToUnloadNotification(long totalRecords) {
		AmountNotification notification = new AmountNotification();
		notification.setTotalRecords(totalRecords);
		client.readyToUnloadNotification(notification);
	}
}
