package ru.bpc.sv2.scheduler.process.diners;

import org.apache.commons.io.IOUtils;
import org.apache.commons.lang3.StringUtils;
import org.beanio.builder.CsvParserBuilder;
import org.beanio.stream.csv.CsvReader;
import ru.bpc.sv2.constants.SystemConstants;
import ru.bpc.sv2.constants.schedule.ProcessConstants;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.invocation.SortElement;
import ru.bpc.sv2.logic.DinersDao;
import ru.bpc.sv2.logic.NetworkDao;
import ru.bpc.sv2.logic.ProcessDao;
import ru.bpc.sv2.net.CardTypeMap;
import ru.bpc.sv2.process.ProcessFileAttribute;
import ru.bpc.sv2.process.SessionFile;
import ru.bpc.sv2.ps.diners.DinBinRange;
import ru.bpc.sv2.scheduler.process.IbatisExternalProcess;
import ru.bpc.sv2.utils.SystemException;
import ru.bpc.sv2.utils.UserException;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.util.*;
import java.util.regex.Pattern;

@SuppressWarnings("unused")
public class DinersBinLoadProcess extends IbatisExternalProcess {
	public static final Long DINERS_STANDARD_ID = 1033L;
	public static final String BIN_STATE_CANCELLED = "Cancelled";
	public static final String BIN_STATE_SUSPENDED = "Suspended";
	public static final String PARAM_NETWORK_ID = "I_NETWORK_ID";
	public static final String PARAM_INST_ID = "I_INST_ID";
	public static final String PARAM_CARD_NETWORK_ID = "I_CARD_NETWORK_ID";
	public static final String PARAM_CARD_INST_ID = "I_CARD_INST_ID";
	private ProcessDao processDao;
	private NetworkDao networkDao;
	private DinersDao dinersDao;

	private Integer instId;
	private Integer networkId;
	private Integer cardInstId;
	private Integer cardNetworkId;

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
				throw (UserException) e;
			} else if (e instanceof SystemException) {
				throw (SystemException) e;
			} else {
				throw new SystemException(e);
			}
		} finally {
			closeConAndSsn();
		}
	}

	@Override
	public void setParameters(Map<String, Object> parameters) {
		instId = getParam(parameters, PARAM_INST_ID);
		networkId = getParam(parameters, PARAM_NETWORK_ID);
		cardInstId = getParam(parameters, PARAM_CARD_INST_ID);
		cardNetworkId = getParam(parameters, PARAM_CARD_NETWORK_ID);
	}

	private Integer getParam(Map<String, Object> parameters, String name) {
		Object val = parameters.get(name);
		return val != null ? ((Number) val).intValue() : null;
	}

	private void initBeans() throws SystemException {
		processDao = new ProcessDao();
		networkDao = new NetworkDao();
		dinersDao = new DinersDao();
	}

	private void executeBody() throws Exception {
		ProcessFileAttribute[] incomingFiles = processDao.getIncomingFilesForProcess(userSessionId, processSession.getSessionId(), process.getContainerBindId());
		SessionFile[] files = processDao.getSessionFiles(userSessionId, SelectionParams.build("sessionId", processSession.getSessionId()), true);
		if (files.length == 0 || incomingFiles.length == 0) {
			getLogger().warn("No incoming files found for session " + processSession.getSessionId());
			return;
		}

		CardTypeMap[] cardTypeMaps = networkDao.getCardTypeMaps(userSessionId, SelectionParams.build("standardId", DINERS_STANDARD_ID, "lang", SystemConstants.ENGLISH_LANGUAGE)
				.setSortElement(new SortElement("priority", SortElement.Direction.ASC))
				.setRowIndexAll());
		LinkedHashMap<Pattern, Integer> cardTypePatterns = new LinkedHashMap<Pattern, Integer>();
		for (CardTypeMap cardTypeMap : cardTypeMaps) {
			cardTypePatterns.put(Pattern.compile(cardTypeMap.getNetworkCardType().replace('_', '.')), cardTypeMap.getCardTypeId());
		}
		Map<String, Integer> cardTypeMap = new HashMap<String, Integer>();
		Set<String> processedBins = new HashSet<String>();

		List<DinBinRange> binRanges = new ArrayList<DinBinRange>();
		int rejected = 0;
		for (SessionFile file : files) {
			if (!file.getFileAttrId().equals(incomingFiles[0].getId())) {
				continue;
			}
			try {
				InputStream stream = processDao.getSessionFileContentsStream(userSessionId, con, file.getId());

				BufferedReader br = null;
				CsvReader csvReader = null;
				Long cnt = 0L;
				try {
					br = new BufferedReader(new InputStreamReader(stream, SystemConstants.DEFAULT_CHARSET));
					csvReader = (CsvReader) new CsvParserBuilder().delimiter(',').build().getInstance().createReader(br);
					String[] line;
					while ((line = csvReader.read()) != null) {
						if (line.length == 0) {
							continue;
						}
						String state = line[5];
						if (state != null && (state.contains(BIN_STATE_CANCELLED) || state.contains(BIN_STATE_SUSPENDED))) {
							rejected++;
							continue;
						}
						DinBinRange binRange = new DinBinRange();
						String bin = line[0];
						if (processedBins.contains(bin)) {
							throw new UserException("Duplicate BIN: " + bin);
						}
						processedBins.add(bin);
						binRange.setAgentName(line[1]);
						binRange.setAgentCode(line[3]);
						binRange.setCountry(StringUtils.leftPad(line[7], 3, '0'));
						binRange.setCountryName(line[8]);
						binRange.setPanLength(Integer.parseInt(line[11]));
						binRange.setPanLow(StringUtils.rightPad(bin, binRange.getPanLength(), '0'));
						binRange.setPanHigh(StringUtils.rightPad(bin, binRange.getPanLength(), '9'));
						binRange.setCardInstId(cardInstId);
						binRange.setIssInstId(instId);
						binRange.setIssNetworkId(networkId);
						binRange.setCardNetworkId(cardNetworkId);
						String networkCardType = line[13];
						Integer cardTypeId = cardTypeMap.get(networkCardType);
						if (cardTypeId == null) {
							for (Map.Entry<Pattern, Integer> entry : cardTypePatterns.entrySet()) {
								if (entry.getKey().matcher(networkCardType).matches()) {
									cardTypeId = entry.getValue();
									cardTypeMap.put(networkCardType, cardTypeId);
									break;
								}
							}
						}
						if (cardTypeId == null) {
							throw new UserException("Could not find suitable SV card type for Diners card type " + networkCardType);
						}
						binRange.setCardTypeId(cardTypeId);
						binRange.setPriority(100);
						binRange.setModuleCode("DIN");
						binRanges.add(binRange);
					}
				} finally {
					try {
						if (csvReader != null) {
							csvReader.close();
						}
					} catch (IOException ignored) {
					}
					IOUtils.closeQuietly(br);
					IOUtils.closeQuietly(stream);
				}
				dinersDao.registerFile(userSessionId, file.getId(), true, networkId, instId, false);
			} catch (Exception e) {
				dinersDao.registerFile(userSessionId, file.getId(), true, networkId, instId, true);
				throw e;
			}
		}
		logEstimated(binRanges.size() + rejected);
		if (binRanges.size() > 0) {
			dinersDao.loadDinBinRanges(userSessionId, processSessionId(), binRanges, true);
			int index = 0;
			final int batchSize = 100;
			while (index < binRanges.size()) {
				networkDao.loadBinRanges(userSessionId, binRanges.subList(index, Math.min(index + batchSize, binRanges.size())), index == 0 ? networkId : null);
				index += batchSize;
				logCurrent(index + 1, 0);
			}
			networkDao.rebuildBinIndex(userSessionId);
			logCurrent(binRanges.size(), 0);
			endLogging(binRanges.size(), 0, rejected);
		} else {
			throw new Exception("Bin file does not contain data");
		}
	}
}
