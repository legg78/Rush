package ru.bpc.sv2.scheduler.process.interchange;

import ru.bpc.sv.ws.cup.jms.JmsQueueService;
import ru.bpc.sv.ws.svng.InterchangeClient;
import ru.bpc.sv2.constants.schedule.ProcessConstants;
import ru.bpc.sv2.interchange.InterchangeResult;
import ru.bpc.sv2.logic.interchange.InterchangeDao;
import ru.bpc.sv2.scheduler.process.IbatisExternalProcess;
import ru.bpc.sv2.settings.constants.SettingsConstants;
import ru.bpc.sv2.ui.utils.cache.SettingsCache;
import ru.bpc.sv2.utils.SystemException;
import ru.bpc.sv2.utils.UserException;

import javax.xml.stream.XMLInputFactory;
import javax.xml.stream.XMLStreamConstants;
import javax.xml.stream.XMLStreamReader;
import java.io.StringReader;
import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.concurrent.atomic.AtomicBoolean;

public class InterchangeLoadProcess extends IbatisExternalProcess {
	private static final String TIMEOUT_PARAM_KEY = "I_TIMEOUT";
	private static final String MODULE_PARAM_KEY = "I_MODULE";
	private static final String NEW_OPER_STATUS_PARAM_KEY = "I_NEW_OPER_STATUS";

	private InterchangeDao interchangeDao;
	private final AtomicBoolean finished = new AtomicBoolean(false);
	private long total = 0;
	private Exception failEx;
	private String mqUrl;//for tests use tcp://localhost:61616
	private int timeout;
	private String module;
	private String newOperStatus;


	@Override
	public void execute() throws SystemException, UserException {
		try {
			getIbatisSession();
			startSession();
			startLogging();
			initBeans();
			executeBody();
			processSession.setResultCode(ProcessConstants.PROCESS_FINISHED);
			commit();
		} catch (Exception e) {
			processSession.setResultCode(ProcessConstants.PROCESS_FAILED);
			rollback();
			if (e instanceof UserException) {
				throw new UserException(e);
			} else {
				throw new SystemException(e);
			}
		} finally {
			closeConAndSsn();
		}
	}

	private void executeBody() throws Exception {
		trace("Interchange Load Process::execute...");
		JmsQueueService jmsService = null;
		try {
			trace("Interchange Load Process::send load request");
			InterchangeClient client =
					new InterchangeClient(mqUrl, module + "_WS_INTERCHANGE", processSessionId());
			total = client.unload();
			trace("Interchange Load Process::received response from module. Total records " + total);
			logEstimated((int) total);
			if (total == 0L) {
				trace("No data in module");
				logCurrent(0, 0);
				endLogging(0, 0);
			} else {
				trace("Interchange Load Process::launch jms queue listener");
				jmsService = new JmsQueueService(mqUrl, module + "_INTERCHANGE_OUT",
						new JmsQueueService.JmsQueueListener() {
							private long cnt = 0;

							@Override
							public void onReceiveData(String fileName, String svxp, long recordsNum,
													  boolean lastPackage) {
								try {
									if (svxp != null) {
										trace("Interchange Load Process::received package");
										List<InterchangeResult> list = parseSvxp(svxp);
										interchangeDao.saveFee(processSessionId(), list, newOperStatus);
										cnt += list.size();
										logCurrent((int) cnt, 0);
									}
									if (cnt == total) {
										endLogging((int) cnt, 0);
										finished.getAndSet(true);
										trace("Interchange Load Process::received last. Finishing process...");
									}
								} catch (Exception ex) {
									failEx = ex;
									finished.getAndSet(true);
								}
							}

							@Override
							public void onError(Exception ex) {
								finished.getAndSet(true);
								failEx = ex;
							}
						}, true);
				jmsService.start();
				int i = 0;
				while (!finished.get()) {
					Thread.sleep(1000);
					i++;
					if (i >= timeout) {
						failEx = new Exception("No actions in " + timeout + " seconds");
						break;
					}
				}
				if (failEx != null) {
					throw failEx;
				}
			}
		} finally {
			if (jmsService != null) {
				jmsService.stop();
			}
		}
	}

	public List<InterchangeResult> parseSvxp(String svxp) throws Exception {
		XMLStreamReader reader = XMLInputFactory.newInstance().createXMLStreamReader(new StringReader(svxp));
		List<InterchangeResult> list = new ArrayList<InterchangeResult>();
		long operId = 0;
		String rrn = null;
		while (reader.hasNext()) {
			int event = reader.next();
			if (event == XMLStreamReader.START_ELEMENT) {
				if (reader.getLocalName().equals("oper_id")) {
					operId = Long.valueOf(reader.getElementText());
				} else if (reader.getLocalName().equals("originator_refnum")) {
					rrn = reader.getElementText();
				} else if (reader.getLocalName().equals("additional_amount")) {
					InterchangeResult result = new InterchangeResult();
					result.setRrn(rrn);
					result.setOperId(operId);
					result.setFeeAmount(BigDecimal.valueOf(Double.parseDouble(getTagValue(reader, "amount_value"))));
					result.setFeeCurrency(getTagValue(reader, "currency"));
					result.setFeeType(getTagValue(reader, "amount_type"));
					list.add(result);
				}
			}
		}
		return list;
	}

	private String getTagValue(XMLStreamReader reader, String tag) throws Exception {
		while (!(reader.nextTag() == XMLStreamConstants.START_ELEMENT &&
				reader.getLocalName().equals(tag))) {
			;
		}
		return reader.getElementText();
	}

	@Override
	public void setParameters(Map<String, Object> parameters) {
		mqUrl = SettingsCache.getInstance().getParameterStringValue(SettingsConstants.MESSAGE_QUEUE_LOCATION);
		module = parameters.get(MODULE_PARAM_KEY).toString().substring(4).replaceAll("0", "");
		if (parameters.get(NEW_OPER_STATUS_PARAM_KEY) != null) {
			newOperStatus = parameters.get(NEW_OPER_STATUS_PARAM_KEY).toString();
		}
		if (parameters.get(TIMEOUT_PARAM_KEY) != null) {
			timeout = Integer.valueOf(parameters.get(TIMEOUT_PARAM_KEY).toString());
		}
	}

	private void initBeans() throws SystemException {
		trace("Interchange Load Process::initBeans...");
		try {
			interchangeDao = new InterchangeDao();
		} catch (Exception e) {
			error(e);
			throw new SystemException(e.getMessage());
		}
	}
}
