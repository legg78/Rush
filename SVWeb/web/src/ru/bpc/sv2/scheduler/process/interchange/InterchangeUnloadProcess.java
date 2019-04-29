package ru.bpc.sv2.scheduler.process.interchange;

import com.bpcbt.sv.interchange.message.v1.LoadResponse;
import ru.bpc.sv2.constants.schedule.ProcessConstants;
import ru.bpc.sv2.scheduler.process.IbatisExternalProcess;
import ru.bpc.sv2.utils.DBUtils;
import ru.bpc.sv2.utils.SystemException;
import ru.bpc.sv2.utils.UserException;

import javax.xml.stream.XMLStreamWriter;
import javax.xml.ws.Response;
import java.lang.reflect.Method;
import java.sql.*;
import java.util.*;

public abstract class InterchangeUnloadProcess extends XmlMqProcess {
	protected PreparedStatement pstm = null;
	private ResultSet rs = null;
	private Set<Long> eventIds;

	private static final String[] operationFields =
			{"oper_id", "oper_type", "msg_type", "sttl_type", "oper_date", "host_date", "oper_request_amount",
			 "network_refnum", "acq_inst_bin", "status", "is_reversal", "merchant_number", "mcc", "merchant_name",
			 "merchant_street", "merchant_city", "merchant_region", "merchant_country", "merchant_postcode",
			 "terminal_type", "terminal_number"};

	private static final String[] issuerFields =
			{"iss_network_id", "iss_inst_id", "iss_card_number", "iss_card_country"};
	private static final String[] acquirerFields = {"acq_network_id", "acq_inst_id"};
	private static final String[] operAmountFields = {"oper_amount_value", "oper_currency"};
	private static final String[] sttlAmountFields = {"sttl_amount_value", "sttl_currency"};

	private static final String[] currencyRateFields =
			{"inst_id", "rate_type", "effective_date", "expiration_date", "rate"};
	private static final String[] srcScaleFields = {"src_scale", "src_currency", "src_exponent_scale"};
	private static final String[] dstScaleFields = {"dst_scale", "dst_currency", "dst_exponent_scale"};

	private static final String[] binFields =
			{"pan_low", "pan_high", "pan_length", "priority", "card_type_id", "country", "iss_network_id",
			 "iss_inst_id", "card_network_id", "card_inst_id"};
	private List<String> timestamps;

	protected InterchangeUnloadProcess(IbatisExternalProcess process) {
		super(process);
	}

	public void execute() throws SystemException, UserException {
		try {
			super.execute();
			process.startLogging();
			timestamps = new ArrayList<String>();
			timestamps.addAll(getTimestampFields());
			executeBody();
			process.logEstimated(total);
			process.logCurrent(total, 0);
			process.endLogging(total, 0);
			process.getProcessSession().setResultCode(ProcessConstants.PROCESS_FINISHED);
			process.commit();
		} catch (Exception e) {
			process.error(e);
			process.getProcessSession().setResultCode(ProcessConstants.PROCESS_FAILED);
			process.endLogging(0, total);
			process.rollback();
			if (e instanceof UserException) {
				throw new UserException(e);
			} else {
				throw new SystemException(e);
			}
		}

	}

	private ResultSet getCurrencyRates() throws Exception {
		String sql =
				"SELECT r.inst_id, r.rate_type, r.eff_date as effective_date, r.exp_date as expiration_date, r.src_scale, r.src_currency, r.src_exponent_scale, " +
						"r.dst_scale, r.dst_currency, r.dst_exponent_scale, r.eff_rate as rate, r.inverted FROM com_rate r WHERE r.status = 'RTSTVALD'";
		pstm = process.getSsn().getCurrentConnection().prepareStatement(sql);
		return pstm.executeQuery();
	}

	private void closeResources() throws Exception {
		if (writer != null) {
			writer.close();
		}
		if (buffer != null) {
			buffer.close();
		}
		if (jmsSender != null) {
			jmsSender.close();
		}
		if (pstm != null) {
			pstm.close();
		}
		if (rs != null) {
			rs.close();
		}
	}

	protected void updateEvents(Long[] ids) throws Exception {
		Connection conn = process.getSsn().getCurrentConnection();
		if (conn.getClass().getName().equalsIgnoreCase("com.ibm.ws.rsadapter.jdbc.WSJdbcConnection")) {
			process.trace("Found WAS jdbc connection");
			conn = unwrapWASConnection(conn);
		}
		CallableStatement cstmt = null;
		try {
			cstmt = conn.prepareCall("{call EVT_API_EVENT_PKG.process_event_object(i_event_object_id_tab => ?)}");
			Array array = DBUtils.createArray("NUM_TAB_TPT", conn, ids);
			cstmt.setArray(1, array);
			cstmt.execute();
		} finally {
			if (cstmt != null) {
				cstmt.close();
			}
		}
	}

	private void executeBody() throws Exception {
		try {
			eventIds = new HashSet<Long>();
			Response<LoadResponse> loadResponse = interchangeClient.load(getDataType().name());
			switch (getDataType()) {
				case OPERATIONS:
					rs = getOperations();
					break;
				case CURRENCY_RATES:
					rs = getCurrencyRates();
					break;
				case BINS:
					rs = getBins();
					break;
			}
			switch (getDataType()) {
				case OPERATIONS:
					processOperations();
					break;
				case CURRENCY_RATES:
					processRates();
					break;
				case BINS:
					processBins();
					break;
			}
			long secondsCnt = 0;
			process.trace("Start waiting for async response...");
			while (!loadResponse.isDone()) {
				Thread.sleep(1000);
				secondsCnt++;
				if (secondsCnt == getTimeout()) {
					throw new Exception("Process is interrupted by timeout");
				}
			}
			if (loadResponse.get().getError() != null) {
				throw new Exception(
						"Error in module: " + loadResponse.get().getError() + ". See module log for details.");
			}
			if (loadResponse.isCancelled()) {
				throw new Exception("Error on load request");
			} else {
				process.trace("Module load result is " + (loadResponse.get().isResult() ? "OK" : "FAILURE"));
			}
			process.trace("Update events");
			updateEvents(eventIds.toArray(new Long[eventIds.size()]));
			process.trace("Finished");
		} catch (Exception ex) {
			ex.printStackTrace();
			throw ex;
		} finally {
			closeResources();
		}
	}

	private Connection unwrapWASConnection(Connection conn) throws Exception {
		Class cl = Class.forName("com.ibm.websphere.rsadapter.WSCallHelper");
		Method method = cl.getMethod("getNativeConnection", Object.class);
		return (Connection) method.invoke(null, conn);
	}

	private void processOperations() throws Exception {
		process.trace("Start writing xml for operations");
		addStartTag("file_type", "INTERCH");
		processData(rs, "clearing", "operation", new WriteContentListener() {
			@Override
			public void writeContent(XMLStreamWriter writer) throws Exception {
				eventIds.add(rs.getLong("event_id"));
				writeTags(operationFields, null, null);
				writeTags(operAmountFields, "oper_amount", 5);
				writeTags(sttlAmountFields, "sttl_amount", 5);
				writeTags(issuerFields, "issuer", 4);
				writeTags(acquirerFields, "acquirer", 4);
				writeCustomOperationTags();
			}
		});
	}

	private void processRates() throws Exception {
		process.trace("Start writing xml for currency rates");
		processData(rs, "currency_rates", "currency_rate", new WriteContentListener() {
			@Override
			public void writeContent(XMLStreamWriter writer) throws Exception {
				writeTags(currencyRateFields, null, null);
				writeTags(srcScaleFields, "src_currency", 4);
				writeTags(dstScaleFields, "dst_currency", 4);
			}
		});
		process.trace("Finished currency rates processing");
	}

	private void processBins() throws Exception {
		process.trace("Start writing xml for bins");
		processData(rs, "bins", "bin", new WriteContentListener() {
			@Override
			public void writeContent(XMLStreamWriter writer) throws Exception {
				writeTags(binFields, null, null);
				writeCustomBinFields();
			}
		});
		process.trace("Finished bins processing");
	}

	protected void writeTags(String[] array, String wrap, Integer prefixLength) throws Exception {
		boolean hasContent = false;
		for (String name : array) {
			try {
				Object value = rs.getObject(name);
				if (value == null) {
					continue;
				}
				if (wrap != null && !hasContent) {
					hasContent = true;
					writer.writeStartElement(wrap);
				}
				if (prefixLength != null) {
					name = name.substring(prefixLength);
				}
				if (timestamps.contains(name)) {
					writeTag(name, (Timestamp) value);
				} else {
					writeTag(name, value);
				}
			} catch (Exception ex) {
				ex.printStackTrace();
				throw new RuntimeException(ex);
			}
		}
		if (hasContent) {
			writer.writeEndElement();
		}
	}

	protected abstract List<String> getTimestampFields() throws Exception;

	protected abstract void writeCustomOperationTags() throws Exception;

	protected abstract void writeCustomBinFields() throws Exception;

	protected abstract int getTimeout();

	protected abstract ResultSet getOperations() throws Exception;

	protected abstract ResultSet getBins() throws Exception;

	protected abstract String getModuleName();

	public abstract void setParameters(Map<String, Object> parameters);

	@Override
	protected String getQueue() {
		return getModuleName() + "_INTERCHANGE_IN";
	}

	@Override
	protected String getWsQueue() {
		return getModuleName() + "_WS_INTERCHANGE";
	}
}
