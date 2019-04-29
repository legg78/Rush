package ru.bpc.sv.ws.cup.clients;

import com.bpcbt.sv.cup.message.v1.FileLoadRequest;
import com.bpcbt.sv.cup.message.v1.FileLoadResponse;
import com.bpcbt.sv.cup.message.v1.SimpleFileLoadRequest;
import com.bpcbt.sv.cup.service.v1.CupPortType;
import org.apache.cxf.jaxws.JaxWsProxyFactoryBean;
import org.apache.cxf.transport.jms.spec.JMSSpecConstants;
import org.apache.log4j.Logger;
import ru.bpc.sv2.cup.enums.LoadType;

import javax.xml.ws.Response;


public class CupClient {
	private static final Logger logger = Logger.getLogger(CupClient.class);

	private CupPortType client;

	public CupClient(String mqUrl, String queue) throws Exception {
		String address = String.format("jms:jndi:dynamicQueues/%s"
				+ "?jndiInitialContextFactory=org.apache.activemq.jndi.ActiveMQInitialContextFactory"
				+ "&jndiConnectionFactoryName=ConnectionFactory"
				+ "&jndiURL=%s", queue, mqUrl);
		JaxWsProxyFactoryBean factory = new JaxWsProxyFactoryBean();
		factory.setTransportId(JMSSpecConstants.SOAP_JMS_SPECIFICATION_TRANSPORTID);
		factory.setServiceClass(CupPortType.class);
		factory.setAddress(address);
		client = (CupPortType) factory.create();
	}

	public FileLoadResponse startLoading(LoadType loadType, Long sessionId, String filename, String encoding,
										 String dir, String outDir, String errorDir, String queue, boolean issuer,
										 long timeout) throws Exception {
		try {
			logger.info("Send init request for " + loadType + " loading");
			FileLoadRequest request = new FileLoadRequest();
			request.setSessionId(sessionId);
			request.setFilename(filename);
			request.setFileEncoding(encoding);
			request.setFileDir(dir);
			request.setOutDir(outDir);
			request.setErrorDir(errorDir);
			request.setQueue(queue);
			request.setIssuer(issuer);
			Response<FileLoadResponse> resp = null;
			switch (loadType) {
				case CUP_CLEARING:
					resp = client.startClearingLoadAsync(request);
					break;
				case CUP_BIN:
					resp = client.startBinsLoadAsync(request);
					break;
				case CUP_SETTLEMENT:
					resp = client.startSettlementsLoadAsync(request);
					break;
				case CUP_REJECT:
					resp = client.startRejectsLoadAsync(request);
			}
			long i = 0;
			while (!resp.isDone() && i < timeout) {
				Thread.sleep(1000);
				i++;
			}
			if (i == timeout) {
				throw new Exception("No response in " + timeout + " seconds");
			}
			return resp.get();
		} catch (Exception ex) {
			logger.error("Error sending init load " + loadType + " command", ex);
			throw ex;
		}
	}

	public FileLoadResponse startLoadingDisputes(Long sessionId, String filename, String encoding, String dir,
												 String outDir, String errorDir, boolean issuer, long timeout)
			throws Exception {
		try {
			logger.info("Send init request for disputes loading");
			SimpleFileLoadRequest request = new SimpleFileLoadRequest();
			request.setSessionId(sessionId);
			request.setFilename(filename);
			request.setFileEncoding(encoding);
			request.setFileDir(dir);
			request.setOutDir(outDir);
			request.setErrorDir(errorDir);
			request.setIssuer(issuer);
			Response<FileLoadResponse> resp = client.startDisputesLoadAsync(request);
			logger.info("Start waiting for async response");
			long i = 0;
			while (!resp.isDone() && i < timeout) {
				Thread.sleep(1000);
				i++;
			}
			if (i == timeout) {
				throw new Exception("No response in " + timeout + " seconds");
			}
			return resp.get();
		} catch (Exception ex) {
			logger.error("Error sending init load disputes command", ex);
			throw ex;
		}
	}
}
