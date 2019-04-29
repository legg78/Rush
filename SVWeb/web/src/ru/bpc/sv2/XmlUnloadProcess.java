package ru.bpc.sv2;

import com.bpcbt.sv.sv_sync.SyncResultType;
import ru.bpc.sv.ws.cup.jms.DataMessageSender;
import ru.bpc.sv.ws.process.svng.CallbackService;
import ru.bpc.sv.ws.process.svng.Invalidation;
import ru.bpc.sv.ws.process.svng.WsClient;
import ru.bpc.sv2.logic.SettingsDao;
import ru.bpc.sv2.scheduler.process.IbatisExternalProcess;
import ru.bpc.sv2.scheduler.process.external.svng.NotificationListener;
import ru.bpc.sv2.settings.constants.SettingsConstants;
import ru.bpc.sv2.svng.DataTypes;
import ru.bpc.sv2.ui.utils.CommonUtils;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.cache.SettingsCache;
import ru.bpc.sv2.utils.SystemException;
import ru.bpc.sv2.utils.UserException;

import javax.xml.stream.XMLOutputFactory;
import javax.xml.stream.XMLStreamWriter;
import java.io.StringWriter;
import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Timestamp;
import java.text.SimpleDateFormat;
import java.util.Map;
import java.util.concurrent.atomic.AtomicBoolean;

public abstract class XmlUnloadProcess extends IbatisExternalProcess {
	private static final int RECORDS_IN_PACKAGE = 2000;
	private static final int BUFFER_SIZE = 5000;

	protected int waitSeconds = 120;
	protected final SimpleDateFormat timestampSdf = new SimpleDateFormat("yyyy-MM-dd");
	protected XMLStreamWriter writer;

	private StringWriter buffer;
	private DataMessageSender jmsSender;

	private int total = 0;
	private int packCnt = 1;

	private String mqUrl = "tcp://localhost:61616";
	protected Integer instId;
	protected String queue;
	private StringBuilder sb = new StringBuilder(5000);


	@SuppressWarnings({"FieldCanBeLocal", "UnusedDeclaration"})
	private SettingsDao _settingsDao;

	public abstract String getRootTag();

	public abstract String getItemTag();

	public abstract String getNamespace();//"http://sv.bpc.in/SVXP"

	public abstract DataTypes getDataType();

	public abstract void writeStartTags() throws Exception;

	public abstract int getTotal(Connection conn) throws Exception;

	public abstract PreparedStatement getItemsStatement(Connection conn) throws Exception;

	protected abstract boolean writeContent(ResultSet rs) throws Exception;

	protected void writeTag(String tag, Object value) throws Exception {
		if (value != null) {
			writer.writeStartElement(tag);
			writer.writeCharacters(value.toString());
			writer.writeEndElement();
		}
	}

	protected void writeTag(String tag, String value) throws Exception {
		if (value != null) {
			writer.writeStartElement(tag);
			writer.writeCharacters(value);
			writer.writeEndElement();
		}
	}

	protected void writeTag(String tag, Timestamp value) throws Exception {
		if (value != null) {
			writeTag(tag, timestampSdf.format(value));
		}
	}

	private String getCodeDesc(int code) {
		String msg = FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Process", "ws_err_code_" + code);
		if (msg == null || msg.equals("")) {
			msg = code + " - unknown code";
		}
		return code + " - " + msg;
	}

	private void initBeans() throws SystemException {
		_settingsDao = new SettingsDao();
	}

	@Override
	public void execute() throws SystemException, UserException {
		getIbatisSession();
		startSession();
		startLogging();
		initBeans();
		PreparedStatement pstm = null;
		ResultSet rs = null;
		int totalRecords = 0;
		try {
			final AtomicBoolean finishFlag = new AtomicBoolean(false);
			final AtomicBoolean failedFlag = new AtomicBoolean(false);
			final StringBuilder errorMsg = new StringBuilder();
			NotificationListener listener = new NotificationListener() {
				@Override
				public void notify(Map<String, Object> values) {
					SyncResultType result = (SyncResultType) values.get("result");
					int code = result.getCode();
					trace("Result ws request: " + code + "  Session ID:" + processSessionId());
					try {
						if (code == 0) {
							trace("receive finished event");
							finishFlag.getAndSet(true);
						} else {
							errorMsg.append("received code:").append(getCodeDesc(code));
							throw new Exception(errorMsg.toString());
						}
					} catch (Exception ex) {
						error(ex);
						finishFlag.getAndSet(true);
						failedFlag.getAndSet(true);
						throw new RuntimeException(ex);
					}
				}
			};
			NotificationListener invalidationListener = new NotificationListener() {
				@Override
				public void notify(Map<String, Object> values) {
					Long sessionIdCancal = Long.parseLong((String) values.get("sessionId"));
					trace("Invalidation for " + sessionIdCancal);
					try {
						trace("receive invalidation");
						finishFlag.getAndSet(true);
						failedFlag.getAndSet(true);
						Invalidation inv = new Invalidation(sessionIdCancal);
						inv.setException(
								((values.get("exception") == null) ? false : (Boolean) (values.get("exception"))));
						inv.callCancel(userName);
					} catch (Exception ex) {
						error(ex);
						finishFlag.getAndSet(true);
						failedFlag.getAndSet(true);
						throw new RuntimeException(ex);
					}
				}
			};
			jmsSender = new DataMessageSender(mqUrl, processSessionId(), queue);

			CallbackService.addListener(processSessionId().toString(), listener);
			CallbackService.addInvalList(processSessionId().toString(), invalidationListener);
			
			String callbackAddress = CommonUtils.getWsCallbackUrl(null);
			
			
			WsClient client = new WsClient(getBpelUrl(), callbackAddress, processSessionId(), getDataType());
			client.sendRequest(instId);
			
			buffer = new StringWriter(BUFFER_SIZE);
			writer = XMLOutputFactory.newInstance().createXMLStreamWriter(buffer);
			Connection conn = ssn.getCurrentConnection();
			totalRecords = getTotal(conn);
			if (totalRecords <= 0) {
				throw new UserException("no records found");
			}
			//data query
			pstm = getItemsStatement(conn);
			rs = pstm.executeQuery();
			processData(rs, getNamespace(), getRootTag(), getItemTag(), totalRecords);
			int i = 0;
			while (!finishFlag.get() && i++ < waitSeconds) {
				Thread.sleep(1000);
			}
			if (!finishFlag.get()) {
				throw new UserException("Error. No response for " + waitSeconds + " seconds");
			}
			if (failedFlag.get()) {
				throw new UserException(errorMsg.toString());
			}
		} catch (Exception ex) {
			error(ex);
			throw new UserException(ex);
		} finally {
			CallbackService.removeListener(processSessionId().toString());
			CallbackService.removeInvalList(processSessionId().toString());
			endLogging(totalRecords, 0);
			closeResources(pstm, rs);
			closeConAndSsn();
		}
	}

	private String getBpelUrl() throws Exception {
		SettingsCache settingParamsCache = SettingsCache.getInstance();
		return settingParamsCache.getParameterStringValue(SettingsConstants.BPEL_URL);
	}

	protected void closeResources(PreparedStatement pstm, ResultSet rs) {
		try {
			if (pstm != null) {
				pstm.close();
			}
			if (rs != null) {
				rs.close();
			}
		} catch (Exception ex) {
			error(ex);
			throw new RuntimeException(ex);
		}
	}

	@Override
	public void setParameters(Map<String, Object> parameters) {
		instId = ((BigDecimal) parameters.get("I_INST_ID")).intValue();
		waitSeconds = ((BigDecimal) parameters.get("I_TIMEOUT")).intValue();
		queue = (String) parameters.get("I_QUEUE");
		mqUrl = SettingsCache.getInstance().getParameterStringValue(SettingsConstants.MESSAGE_QUEUE_LOCATION);
	}

	private void startDocument(String rootTag, String namespace) throws Exception {
		writer = XMLOutputFactory.newInstance().createXMLStreamWriter(buffer);
		writer.writeStartDocument("UTF-8", "1.0");
		writer.writeStartElement(rootTag);
		writer.writeAttribute("xmlns", namespace);
		writeStartTags();
	}

	private String pack(String content, long sessionId, String dataType, String fileName, int number, int packsTotal,
						int recordsNumber, int recordsTotal) {
		try {
			sb.append("<?xml version=\"1.0\" encoding=\"UTF-8\"?><pack><header><session-id>");
			sb.append(sessionId);
			sb.append("</session-id><data-type>");
			sb.append(dataType);
			sb.append("</data-type><file-name>");
			sb.append(fileName);
			sb.append("</file-name><number>");
			sb.append(number);
			sb.append("</number><packs-total>");
			sb.append(packsTotal);
			sb.append("</packs-total><records-number>");
			sb.append(recordsNumber);
			sb.append("</records-number><records-total>");
			sb.append(recordsTotal);
			sb.append("</records-total><additional-inf/></header><body><![CDATA[");
			sb.append(content);
			sb.append("]]></body></pack>");
			return sb.toString();
		} finally {
			sb.setLength(0);
		}
	}

	private void processData(ResultSet rs, String namespace, String startTag, String wrapTag, int totalRecords)
			throws Exception {
		int cnt = 0;
		int total = 0;
		int totalPacks = (int) Math.ceil(((double) totalRecords) / ((double) RECORDS_IN_PACKAGE));
		startDocument(startTag, namespace);
		rs.next();
		boolean exit;
		while (true) {
			writer.writeStartElement(wrapTag);
			exit = writeContent(rs);
			writer.writeEndElement();
			cnt++;
			if (cnt >= RECORDS_IN_PACKAGE) {
				sendPack(cnt, totalPacks, totalRecords);
				total += cnt;
				cnt = 0;
				logCurrent(total, 0);
				startDocument(startTag, namespace);
			}
			if (exit) {
				break;
			}
		}
		if (cnt > 0) {
			sendPack(cnt, totalPacks, totalRecords);
		}
	}

	protected void sendPack(int cnt, int packsTotal, int totalRecords) throws Exception {
		writer.writeEndElement();
		writer.writeEndDocument();
		writer.flush();
		total += cnt;
		logCurrent(total, 0);
		trace("Send " + cnt + " records. Total sent " + total);
		jmsSender.sendOperationsNoPack(
				pack(buffer.toString(), processSessionId(), getDataType().name(), "unknown", packCnt,
						packsTotal, RECORDS_IN_PACKAGE, totalRecords));
		buffer.getBuffer().setLength(0);
		packCnt++;
	}
}
