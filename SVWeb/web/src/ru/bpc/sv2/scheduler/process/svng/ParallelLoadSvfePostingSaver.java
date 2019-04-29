package ru.bpc.sv2.scheduler.process.svng;

import com.bpcbt.sv.camel.converters.Config;
import com.bpcbt.sv.camel.converters.mapping.BlockAddressingString;
import com.bpcbt.sv.camel.converters.mapping.ByteAddressingStringStreamReader;
import com.bpcbt.sv.camel.converters.mapping.file.PostingMapper;
import com.bpcbt.sv.camel.converters.transform.TransformUtils;
import com.bpcbt.sv.camel.converters.transform.model.TransformationMap;
import oracle.jdbc.OracleTypes;
import org.apache.commons.lang3.StringUtils;
import org.dom4j.Node;
import org.xml.sax.InputSource;
import ru.bpc.sv2.constants.schedule.ProcessConstants;
import ru.bpc.sv2.logic.utility.JndiUtils;
import ru.bpc.sv2.scheduler.process.AbstractFileSaver;
import ru.bpc.sv2.svng.AuthDataParser;
import ru.bpc.sv2.svng.AuthTag;
import ru.bpc.sv2.svng.ClearingOperation;
import ru.bpc.sv2.svng.ClearingOperationGenerate;
import ru.bpc.sv2.utils.UserException;

import javax.sql.DataSource;
import javax.xml.bind.JAXBContext;
import javax.xml.bind.JAXBElement;
import javax.xml.bind.Unmarshaller;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.InputStream;
import java.nio.charset.Charset;
import java.sql.CallableStatement;
import java.sql.Connection;
import java.util.*;
import java.util.concurrent.*;


/**
 * BPC Group 2018 (c) All Rights Reserved
 */
public class ParallelLoadSvfePostingSaver extends AbstractFileSaver {
	private static final String POSTING_DIRECTORY = "posting";
	private static final int BATCH_SIZE = 1000;
	private static final int THREAD_AWAIT_SECONDS = 120;
	private static final int QUEUE_SIZE = 4;

	private class Buffer {
		private boolean last;
		private List<ClearingOperation> ops;

		public Buffer() {
			this.ops = new ArrayList<>(BATCH_SIZE);
		}

		public boolean isFull() {
			return (ops.size() > BATCH_SIZE - 1);
		}

		public void add(ClearingOperation op) {
			ops.add(op);
		}

		public List<ClearingOperation> getOps() {
			return (ops);
		}

		public void setLast(boolean last) {
			this.last = last;
		}

		public boolean isLast() {
			return (last);
		}
	}

	private class Worker implements Runnable {
		private final int threadNumber;
		private final BlockingQueue<Buffer> queue;
		private RegisterOperationJdbc dao;

		public Worker(int threadNumber, BlockingQueue<Buffer> queue, Connection connection) {
			this.threadNumber = threadNumber;
			this.queue = queue;
			try {
				this.dao = new RegisterOperationJdbc(params, connection);
			} catch (Exception e) {
				error(e);
			}
		}

		@Override
		public void run() {
			info("Worker thread " + threadNumber + " started");
			try {
				while (!Thread.currentThread().isInterrupted()) {
					Buffer buffer = queue.take();
					info("Worker thread " + threadNumber + " processing " + buffer.getOps().size() + " records, queue size is " + queue.size());
					long t1 = System.currentTimeMillis();
					dao.setSessionFileId(getFileAttributes());
					dao.insert(buffer.getOps());
					if (buffer.isLast()) {
						dao.flush();
					}
					long t2 = System.currentTimeMillis();
					info("Worker thread " + threadNumber + " processed " + buffer.getOps().size() + " records in " + (t2 - t1) / 1000 + " seconds");
					if (buffer.isLast()) {
						break;
					}
				}
			} catch (Exception e) {
				error(e);
			}
			info("Worker thread " + threadNumber + " terminated");
		}
	}


	@Override
	public void save() throws Exception {
		setupTracelevel();
		long t1 = System.currentTimeMillis();
		int parallelDegree = (process.getParallelDegree() == null) ? 1 : process.getParallelDegree();
		info("Start loading of file " + fileAttributes != null ? fileAttributes.getFileName() : "(null)");
		info("Session ID = " + sessionId + ", parallel degree = " + parallelDegree);

		AbstractFeUnloadFileSaver.setupConverterConfigPath(getFileAttributes());
		Charset inputCharset = Config.getFrontEndCharset();
		ByteAddressingStringStreamReader isr;
		BlockAddressingString line = null;

		isr = new ByteAddressingStringStreamReader(inputStream, inputCharset);
		PostingMapper mapper = getPostingMapper();
		StringBuilder builder = new StringBuilder();
		AuthDataParser adp = new AuthDataParser();


		Buffer buffers[] = new Buffer[parallelDegree];
		BlockingQueue<Buffer> queues[] = new LinkedBlockingQueue[parallelDegree];
		Future[] futures = new Future[parallelDegree];
		ExecutorService threads = Executors.newFixedThreadPool(parallelDegree);
		Connection[] connections = null;

		try {
			connections = initConnections(parallelDegree);
			for (int i = 0; i < parallelDegree; i++) {
				buffers[i] = new Buffer();
				queues[i] = new LinkedBlockingQueue<>(QUEUE_SIZE);
				futures[i] = threads.submit(new Worker(i, queues[i], connections[i]));
			}

			long operCount = 0;
			long lineNumber = 0;
			try {
				while ((line = isr.readLine()) != null) {
					lineNumber++;
					ClearingOperation operation = parseLine(mapper, line, builder, adp, operCount);
					if (operation != null) {
						operCount++;
						int hashCode = getHashCode(operation, parallelDegree);
						buffers[hashCode].add(operation);
						if (buffers[hashCode].isFull()) {
							info("Buffer is prepared for queue " + hashCode + ", current queue size is " + queues[hashCode].size());
							queues[hashCode].put(buffers[hashCode]);
							buffers[hashCode] = new Buffer();
						}
					}
					builder.setLength(0);
				}
			}
			catch (Exception e) {
				error(String.format("ERROR parsing line %d of file %s", lineNumber, fileAttributes != null ? fileAttributes.getFileName() : "(null)"));
				String errorMessage = String.format("%s -> ERROR parsing line %d: [%s]", e.getMessage(), lineNumber, line != null ? line.getTarget() : "null");
				error(errorMessage);
				throw e;
			}

			for (int i = 0; i < parallelDegree; i++) {
				buffers[i].setLast(true);
				queues[i].put(buffers[i]);
			}
			long t2 = System.currentTimeMillis();
			info("Finished parsing " + lineNumber + " lines (" + operCount + " operations) in " + (t2 - t1) / 1000 + " seconds, wait for loading completion...");
			for (int i = 0; i < parallelDegree; i++) {
				futures[i].get();
			}
			long t3 = System.currentTimeMillis();
			info("Finished processing a total of " + operCount + " records in " + (t3 - t1) / 1000 + " seconds");
			info("File " + fileAttributes != null ? fileAttributes.getFileName() : "(null)" + "has been processed");
		}
		finally {
			closeConnections(connections);
			poolShutdown(threads);
		}
	}

	private void poolShutdown(ExecutorService threads) {
		info("Attempting thread pool shutdown...");
		threads.shutdown();
		try {
			if (!threads.awaitTermination(THREAD_AWAIT_SECONDS, TimeUnit.SECONDS)) {
				threads.shutdownNow();
				if (!threads.awaitTermination(THREAD_AWAIT_SECONDS, TimeUnit.SECONDS)) {
					warn("Unable to terminate thread pool");
				}
			}
			if (threads.isShutdown()) {
				info("Thread pool terminated successfully");
			}
		}
		catch (InterruptedException ie) {
			error(ie);
			threads.shutdownNow();
			Thread.currentThread().interrupt();
		}
	}

	private PostingMapper getPostingMapper() throws Exception {

		JAXBContext jaxbContext = JAXBContext.newInstance("com.bpcbt.sv.camel.converters.transform.model");
		Unmarshaller unmarshaller = jaxbContext.createUnmarshaller();
		JAXBElement<TransformationMap> mapElement =
				(JAXBElement<TransformationMap>) unmarshaller.unmarshal(getFileInputStream(POSTING_DIRECTORY + "/" + "posting_mapping_config.xml", false));
		final TransformationMap tMap = mapElement.getValue();
		final Map<String, Map<String, String>> rMap = new HashMap<String, Map<String, String>>();

		if (StringUtils.isNotEmpty(tMap.getReferencesProps())) {

			Properties properties = new Properties();
			properties.load(getFileInputStream(tMap.getReferencesProps(), (tMap.getIsFullPaths() == null || tMap.getIsFullPaths())));
			Enumeration keys = properties.propertyNames();
			if (keys != null) {
				while (keys.hasMoreElements()) {
					String refName = (String) keys.nextElement();
					String refFile = properties.getProperty(refName);
					info("Mapping field:  " + refName + " = " + refFile);
					Map<String, String> refMap =
							TransformUtils.parse(new InputSource(getFileInputStream(refFile, (tMap.getIsFullPaths() == null || tMap.getIsFullPaths()))));
					if (refMap == null) {
						refMap = new HashMap<String, String>(0);
					}
					rMap.put(refName, refMap);
				}
			}
		}
		return (new PostingMapper(null, false) {{
			setTransformationMap(tMap);
			setReferencesMap(rMap);
		}});

	}

	private ClearingOperation parseLine(PostingMapper mapper, BlockAddressingString line, StringBuilder builder, AuthDataParser adp, Long lineCount) throws Exception {
		List<Node> elements = mapper.parse(line);
		if (elements != null) {
			if (elements.size() > 1) {
				throw new UserException("Line parsed into multiple nodes");
			}
			if (!elements.isEmpty()) {
				ClearingOperation operation = new ClearingOperation();
				if (ClearingOperationGenerate.generate(elements.get(0), operation, builder)) {
					operation.setOperIdBatch(lineCount);
					operation.setAuthDataObject(adp.parse(operation.getAuthData(), operation.getOperIdBatch()));
					operation.setAuthData(null);
					return (operation);
				}
			}
		}
		return (null);
	}

	private int getHashCode(ClearingOperation operation, int hashSize) {
		if ("OPTP0690".equals(operation.getOperType()) && "CITPCARD".equals(operation.getIssClientIdType())) {
			if (operation.getAuthDataObject() != null && operation.getAuthDataObject().getAuthTags() != null) {
				for (AuthTag at : operation.getAuthDataObject().getAuthTags()) {
					if (at.getTagId() != null && at.getTagId().intValue() == 10) {
						return (Math.abs(("CITPCARD/" + at.getTagValue()).hashCode()) % hashSize);
					}
				}
			}
			return (0);
		}
		else {
			return (Math.abs((operation.getIssClientIdType() + "/" + operation.getIssClientIdValue()).hashCode()) % hashSize);
		}
	}

	private InputStream getFileInputStream(String configFile, boolean isFullPath) throws FileNotFoundException {
		if (isFullPath) {
			return new FileInputStream(configFile);
		}
		else {
			return Config.getInputSteam(Config.getConfigPath() + configFile);
		}
	}

	private Connection[] initConnections(int parallelDegree) throws Exception {
		Connection[] connections = new Connection[parallelDegree];
		DataSource ds = JndiUtils.getDataSource();
		for (int i = 0; i < parallelDegree; i++) {
			connections[i] = ds.getConnection();
			setUserContext(connections[i], i);
		}
		return (connections);
	}

	private void closeConnections(Connection[] connections) {
		info("Closing thread pool connections...");
		try {
			if (connections != null) {
				for (int i = 0; i < connections.length; i++) {
					if (connections[i] != null) {
						CallableStatement s = null;
						try {
							s = connections[i].prepareCall("{ call  itf_prc_import_pkg.after_register_batch( " +
									"  i_session_id => ?" +
									", i_thread_number => ?" +
									")}");
							s.setObject(1, sessionId, OracleTypes.BIGINT);
							s.setObject(2, (i + 1), OracleTypes.SMALLINT);
							s.executeUpdate();
						}
						finally {
							if (s != null) {
								s.close();
							}
							connections[i].close();
						}
					}
				}
			}
			info("Thread pool connections closed successfully");
		}
		catch (Exception e) {
			error(e);
		}
	}

	private void setUserContext(Connection connection, int threadNumber) throws Exception {
		CallableStatement s = null;
		try {
			s = connection.prepareCall("{ call com_ui_user_env_pkg.set_user_context( " +
					"  i_user_name  	=> ?" +
					", io_session_id	=> ?" +
					", i_ip_address		=> ?)}"
			);
			s.setString(1, userName);
			s.setObject(2, sessionId, OracleTypes.BIGINT);
			s.setObject(3, null, OracleTypes.VARCHAR);
			s.registerOutParameter(2, OracleTypes.BIGINT);
			s.executeUpdate();
		}
		finally {
			if (s != null) {
				s.close();
			}
		}
		try {
			s = connection.prepareCall("{ call itf_prc_import_pkg.before_register_batch( " +
					"  i_session_id => ?" +
					", i_thread_number => ?" +
					", i_container_id => ?" +
					", i_process_id => ?" +
					", i_oracle_trace_level => ?" +
					", i_trace_thread_number => ?" +
					")}");
			s.setObject(1, sessionId, OracleTypes.BIGINT);
			s.setObject(2, (threadNumber + 1), OracleTypes.SMALLINT);
			s.setObject(3, process.getContainerBindId(), OracleTypes.INTEGER);
			s.setObject(4, process.getId(), OracleTypes.INTEGER);
			s.setObject(5, getTraceLevel(), OracleTypes.SMALLINT);
			s.setObject(6, getTraceThreadNumber(), OracleTypes.SMALLINT);
			s.executeUpdate();
		}
		finally {
			if (s != null) {
				s.close();
			}
		}
	}
}
