package ru.bpc.sv.ws.jcb.clients;

import com.bpcbt.sv.jcb.message.v1.SimpleFileLoadRequest;
import com.bpcbt.sv.jcb.service.v1.JcbPortType;
import org.apache.activemq.ActiveMQConnectionFactory;
import org.apache.cxf.jaxws.JaxWsProxyFactoryBean;
import org.apache.cxf.transport.jms.ConnectionFactoryFeature;
import org.apache.cxf.transport.jms.spec.JMSSpecConstants;
import org.apache.log4j.Logger;
import ru.bpc.sv2.jcb.enums.LoadType;

import java.util.Collections;

public class JcbClient {

	private static final Logger logger = Logger.getLogger(JcbClient.class);

	private JcbPortType client;

	public JcbClient(String mqUrl, String queue) throws Exception {
		String address = String.format("jms:jndi:dynamicQueues/%s"
				+ "?jndiInitialContextFactory=org.apache.activemq.jndi.ActiveMQInitialContextFactory"
				+ "&jndiConnectionFactoryName=ConnectionFactory"
				+ "&jndiURL=%s", queue, mqUrl);
		JaxWsProxyFactoryBean factory = new JaxWsProxyFactoryBean();
		factory.setTransportId(JMSSpecConstants.SOAP_JMS_SPECIFICATION_TRANSPORTID);
		factory.setServiceClass(JcbPortType.class);
		factory.setAddress(address);
		client = (JcbPortType) factory.create();
	}

	public void startLoading(LoadType loadType, Long sessionId, String filename, String encoding,
							 String dir, String outDir, String errorDir, String queue) throws Exception {
		try {
			logger.info("Jcb Send init request for " + loadType + " loading");
			SimpleFileLoadRequest request = new SimpleFileLoadRequest();
			request.setSessionId(sessionId);
			request.setFilename(filename);
			request.setFileEncoding(encoding);
			request.setFileDir(dir);
			request.setOutDir(outDir);
			request.setErrorDir(errorDir);
			request.setQueue(queue);
			switch (loadType) {
				case JCB_CLEARING:
					client.startClearingLoad(request);
					break;
				case JCB_BIN:
					client.startBinsLoad(request);
					break;
				case JCB_STOP_DATA:
					client.startStopDataLoad(request);
					break;
			}
			logger.info("Start waiting for async response");
		} catch (Exception ex) {
			logger.error("Error sending init load " + loadType + " command", ex);
			throw ex;
		}
	}

	public void startUnloadingMerchantData(Long sessionId, String filename, String encoding, String dir, String outDir, String errorDir)
			throws Exception {
		try {
			logger.info("Jcb Send init request for unloading");
			SimpleFileLoadRequest request = new SimpleFileLoadRequest();
			request.setSessionId(sessionId);
			request.setFilename(filename);
			request.setFileEncoding(encoding);
			request.setFileDir(dir);
			request.setOutDir(outDir);
			request.setErrorDir(errorDir);
			client.startMerchantDataUnload(request);
			logger.info("Start waiting for async response");
		} catch (Exception ex) {
			logger.error("Error sending init load disputes command", ex);
			throw ex;
		}
	}

	public void startUnloadingClearingData(Long sessionId, String filename, String encoding, String dir, String outDir, String errorDir)
			throws Exception {
		try {
			logger.info("Jcb Send init request for unloading");
			SimpleFileLoadRequest request = new SimpleFileLoadRequest();
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
