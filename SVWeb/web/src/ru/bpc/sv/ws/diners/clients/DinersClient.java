package ru.bpc.sv.ws.diners.clients;

import com.bpcbt.sv.diners.message.v1.FileLoadRequest;
import com.bpcbt.sv.diners.service.v1.DinersPortType;
import org.apache.cxf.jaxws.JaxWsProxyFactoryBean;
import org.apache.cxf.transport.jms.spec.JMSSpecConstants;
import org.apache.log4j.Logger;
import ru.bpc.sv2.diners.enums.LoadType;

public class DinersClient {

	private static final Logger logger = Logger.getLogger(DinersClient.class);

	private DinersPortType client;

	public DinersClient(String mqUrl, String queue) throws Exception {
		String address = String.format("jms:jndi:dynamicQueues/%s"
				+ "?jndiInitialContextFactory=org.apache.activemq.jndi.ActiveMQInitialContextFactory"
				+ "&jndiConnectionFactoryName=ConnectionFactory"
				+ "&jndiURL=%s", queue, mqUrl);
		JaxWsProxyFactoryBean factory = new JaxWsProxyFactoryBean();
		factory.setTransportId(JMSSpecConstants.SOAP_JMS_SPECIFICATION_TRANSPORTID);
		factory.setServiceClass(DinersPortType.class);
		factory.setAddress(address);
		client = (DinersPortType) factory.create();
	}

	public void startLoading(LoadType loadType, Long sessionId, String filename, String encoding,
	                         String dir, String outDir, String errorDir, String queue) throws Exception {
		try {
			logger.info("Diners Send init request for " + loadType + " loading");
			FileLoadRequest request = new FileLoadRequest();
			request.setSessionId(sessionId);
			request.setFilename(filename);
			request.setFileEncoding(encoding);
			request.setFileDir(dir);
			request.setOutDir(outDir);
			request.setErrorDir(errorDir);
			request.setQueue(queue);
			switch (loadType) {
				case DIN_CLEARING_IN:
					client.startClearingLoad(request);
					break;
				case DIN_BIN:
					client.startBinsLoad(request);
					break;
			}
			logger.info("Start waiting for async response");
		} catch (Exception ex) {
			logger.error("Error sending init load " + loadType + " command", ex);
			throw ex;
		}
	}

	public void startUnloadingClearingData(Long sessionId, String filename, String encoding,
	                                       String dir, String outDir, String errorDir) throws Exception {
		try {
			logger.info("Diners Send init request for unloading");
			FileLoadRequest request = new FileLoadRequest();
			request.setSessionId(sessionId);
			request.setFilename(filename);
			request.setFileEncoding(encoding);
			request.setFileDir(dir);
			request.setOutDir(outDir);
			request.setErrorDir(errorDir);
			client.startClearingUnload(request);
			logger.info("Start waiting for async response");
		} catch (Exception ex) {
			logger.error("Error sending init load disputes command", ex);
			throw ex;
		}
	}
}
