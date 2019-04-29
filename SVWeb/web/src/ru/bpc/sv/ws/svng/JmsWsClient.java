package ru.bpc.sv.ws.svng;

import org.apache.cxf.jaxws.JaxWsProxyFactoryBean;
import org.apache.cxf.transport.jms.spec.JMSSpecConstants;

public abstract class JmsWsClient<T> {
	protected T client;
	public JmsWsClient(String mqUrl, String queue, Class<T> cl) {
		String address = String.format("jms:jndi:dynamicQueues/%s"
				+ "?jndiInitialContextFactory=org.apache.activemq.jndi.ActiveMQInitialContextFactory"
				+ "&jndiConnectionFactoryName=ConnectionFactory"
				+ "&jndiURL=%s", queue, mqUrl);
		JaxWsProxyFactoryBean factory = new JaxWsProxyFactoryBean();
		factory.setTransportId(JMSSpecConstants.SOAP_JMS_SPECIFICATION_TRANSPORTID);
		factory.setAddress(address);

		factory.setServiceClass(cl);
		client = (T) factory.create();
	}
}
