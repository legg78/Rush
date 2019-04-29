package ru.bpc.sv.ws.cup.servers;

import com.bpcbt.sv.notification.message.v1.AmountNotification;
import com.bpcbt.sv.notification.message.v1.FileLoadedNotification;
import com.bpcbt.sv.notification.service.v1.NotificationPortType;
import org.apache.cxf.endpoint.Server;
import org.apache.cxf.jaxws.JaxWsServerFactoryBean;
import org.apache.cxf.transport.jms.spec.JMSSpecConstants;

public class NotificationServer implements NotificationPortType {

	public static interface NotificationListener {
		void onNotification();
		void onFileLoadedNotification(long totalRecords, int totalPackages);
	}

	private String address;
	private Server server;
	private NotificationListener listener;

	public NotificationServer(String mqUrl, String queue, NotificationListener listener) {
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

	@Override
	public void fileSavedNotification(AmountNotification response) {
		if (listener != null) {
			listener.onNotification();
		}
	}

	@Override
	public void fileLoadedNotification(FileLoadedNotification request) {
		if (listener != null) {
			listener.onFileLoadedNotification(request.getTotalRecords(), request.getTotalPackages());
		}
	}

	@Override
	public void readyToUnloadNotification(AmountNotification request) {
		//not implemented on this side
	}

	public void stop() {
		if (server != null) {
			server.stop();
			server.destroy();
		}
	}
}
