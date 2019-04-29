package ru.bpc.sv2.scheduler.process.svng;

import ru.bpc.sv.ws.cup.jms.DataMessageSender;
import ru.bpc.sv2.process.ProcessFileAttribute;
import ru.bpc.sv2.settings.constants.SettingsConstants;
import ru.bpc.sv2.svng.DataTypes;
import ru.bpc.sv2.trace.TraceLogInfo;
import ru.bpc.sv2.ui.utils.cache.SettingsCache;
import ru.bpc.sv2.utils.UserException;

import java.io.IOException;
import java.io.Reader;
import java.sql.Clob;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class SimpleMQSaver extends ActiveMQSaver {

	private StringBuilder sb;
	private List<ProcessFileAttribute> files;

	@Override
	public void save() throws Exception {
		SettingsCache settingParamsCache = SettingsCache.getInstance();
		try {
			logger.debug("start saver: " + this.getClass().getName());
			queue = fileAttributes.getQueueIdentifier();
			if (queue == null) {
				throw new UserException("No queue name");
			}
			if (sessionId == null) {
				sessionId = fileAttributes.getSessionId();
			}
			final StringBuilder errorMsg = new StringBuilder();

			PreparedStatement stmt = null;
			ResultSet rs = null;
			DataMessageSender jmsSender = null;
				try {
					String mqUrl = settingParamsCache.getParameterStringValue(SettingsConstants.MESSAGE_QUEUE_LOCATION);
					logger.info("Using active mq " + mqUrl);
					jmsSender = new DataMessageSender(mqUrl, sessionId, queue);
					Map<String, Long> recordsMap = getCalcRecords();
					Long totalRecords = recordsMap.get("totalRecords");
					if(totalRecords.equals(0L)){
						logger.info("File doesn't contain records");
						loggerDB.debug(new TraceLogInfo(sessionId,"File doesn't contain records"));
						return;
					}
					Long totalPacks = recordsMap.get("totalPacks");

					for (int i = 0; i < files.size(); i++) {
						ProcessFileAttribute file = files.get(i);
						if(file.getRecordCount() == null || file.getRecordCount().equals(0L)){
							logger.info("File: " + file.getFileName() + " id: " + file.getId() + " is empty");
							loggerDB.debug(new TraceLogInfo(sessionId,"File: " + file.getFileName() + " id: " + file.getId() + " is empty"));
							continue;
						}
						try {
							stmt = con.prepareStatement("SELECT file_contents FROM prc_ui_file_out_vw WHERE id = ?");
							stmt.setLong(1, file.getId());
							rs = stmt.executeQuery();
							if (!rs.next()) {
								return;
							}
							Clob clob = rs.getClob("file_contents");
							if (clob == null) {
								return;
							}
							String pack = pack(fileAttributes.getFileName(), totalRecords, file.getRecordCount(), totalPacks, i + 1,
									readClob(clob));
							logger.info("Send pack with " + file.getRecordCount() + " records");
							jmsSender.sendOperationsNoPack(pack);
						} finally {
							if (stmt != null) {
								stmt.close();
							}
							if (rs != null) {
								rs.close();
							}
						}
					}
			
			
				} catch (UserException e) {
					logger.debug(e);
					throw e;
				} catch (Exception e) {
					logger.debug(e);
					throw e;
				} finally {
					if (jmsSender != null) {
						jmsSender.close();
					}
					if (con != null) {
						con.close();
					}
				}
			} finally {
				logger.debug("finally saver " + this.getClass().getName());
			}
	}

	public Map<String, Long> getCalcRecords(){
		Long totalRecords = 0L;
		Long totalPacks = 0L;
		Map<String, Long> result = new HashMap<String, Long>();
		for (ProcessFileAttribute file : files) {
			if(file.getRecordCount() != null && file.getRecordCount() > 0){
				totalRecords = totalRecords + file.getRecordCount();
				totalPacks++;
			}
		}
		result.put("totalRecords", totalRecords);
		result.put("totalPacks", totalPacks);
		return result;
	}

	private String readClob(Clob clob) throws SQLException, IOException {
		if (sb == null) {
			sb = new StringBuilder((int) clob.length());
		} else {
			sb.setLength(0);
		}
		Reader r = clob.getCharacterStream();
		char[] cbuf = new char[2048];
		int n;
		while ((n = r.read(cbuf, 0, cbuf.length)) != -1) {
			sb.append(cbuf, 0, n);
		}
		return sb.toString();
	}


	private String pack(String fileName, Long recordsTotal, Long recordsInPack, Long packsTotal, int currentPack,
						String content) {
		StringBuilder sb = new StringBuilder("<?xml version=\"1.0\" encoding=\"UTF-8\"?>");
		sb.append(
				"<pack xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xsi:noNamespaceSchemaLocation=\"mq_envelopment.xsd\">");
		sb.append("<header><data-type>");
		sb.append(getDataType().name());
		sb.append("</data-type><session-id>");
		sb.append(sessionId);
		sb.append("</session-id><file-name>");
		sb.append(fileName);
		sb.append("</file-name><number>");
		sb.append(currentPack);
		sb.append("</number><packs-total>");
		sb.append(packsTotal);
		sb.append("</packs-total><records-number>");
		sb.append(recordsInPack.toString());
		sb.append("</records-number><records-total>");
		sb.append(recordsTotal);
		sb.append("</records-total>");
		sb.append("<additional-inf xsi:type=\"anyType\"/></header><body xsi:type=\"anyType\"><![CDATA[");
		sb.append(content);
		sb.append("]]></body></pack>");
		return sb.toString();
	}

	@Override
	protected DataTypes getDataType() {
		return DataTypes.COMMON;
	}


	public void setFiles(List<ProcessFileAttribute> files) {
		this.files = files;
		super.setFiles(files);
	}
}
