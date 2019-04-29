package ru.bpc.sv.ws.cup.servers;

import com.bpcbt.sv.cancel.message.v1.CancelNotification;
import com.bpcbt.sv.cancel.service.v1.CancelPortType;
import org.apache.cxf.endpoint.Server;
import org.apache.cxf.jaxws.JaxWsServerFactoryBean;
import org.apache.cxf.transport.jms.spec.JMSSpecConstants;

public class CancelServer implements CancelPortType {

	public interface CancelListener {
		void onCancel(String reason);
	}

	private String address;
	private Server server;
	private CancelListener listener;

	public CancelServer(String mqUrl, String queue, CancelListener listener) {
		this.listener = listener;
		this.address = String.format("jms:jndi:dynamicQueues/%s"
				+ "?jndiInitialContextFactory=org.apache.activemq.jndi.ActiveMQInitialContextFactory"
				+ "&jndiConnectionFactoryName=ConnectionFactory"
				+ "&jndiURL=%s", queue, mqUrl);
	}

	public void start() throws Exception {
		JaxWsServerFactoryBean svrFactory = new JaxWsServerFactoryBean();
		svrFactory.setServiceBean(this);
		svrFactory.setTransportId(JMSSpecConstants.SOAP_JMS_SPECIFICATION_TRANSPORTID);
		svrFactory.setAddress(address);
		server = svrFactory.create();
	}

	public void stop() {
		if (server != null) {
			server.stop();
			server.destroy();
		}
	}

	@Override
	public void cancelNotification(CancelNotification request) {
		listener.onCancel(request.getReason());
	}
}
