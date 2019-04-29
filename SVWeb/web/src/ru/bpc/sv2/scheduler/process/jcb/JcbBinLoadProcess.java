package ru.bpc.sv2.scheduler.process.jcb;

import org.apache.commons.io.IOUtils;
import org.apache.commons.lang3.StringUtils;
import ru.bpc.sv2.constants.SystemConstants;
import ru.bpc.sv2.constants.schedule.ProcessConstants;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.invocation.SortElement;
import ru.bpc.sv2.logic.JcbDao;
import ru.bpc.sv2.logic.NetworkDao;
import ru.bpc.sv2.logic.ProcessDao;
import ru.bpc.sv2.net.BinRange;
import ru.bpc.sv2.net.CardTypeMap;
import ru.bpc.sv2.process.ProcessFileAttribute;
import ru.bpc.sv2.process.SessionFile;
import ru.bpc.sv2.process.filereader.FlatFileItem;
import ru.bpc.sv2.process.filereader.PlainItemReader;
import ru.bpc.sv2.scheduler.process.IbatisExternalProcess;
import ru.bpc.sv2.scheduler.process.jcb.plain.IinRecord;
import ru.bpc.sv2.ui.utils.CountryCache;
import ru.bpc.sv2.utils.SystemException;
import ru.bpc.sv2.utils.UserException;

import java.io.InputStream;
import java.io.InputStreamReader;
import java.util.*;
import java.util.regex.Pattern;

@SuppressWarnings("unused")
public class JcbBinLoadProcess extends IbatisExternalProcess {
	public static final Long JCB_STANDARD_ID = 1032L;
	public static final String PARAM_NETWORK_ID = "I_NETWORK_ID";
	public static final String PARAM_INST_ID = "I_INST_ID";
	public static final String PARAM_CARD_NETWORK_ID = "I_CARD_NETWORK_ID";
	public static final String PARAM_CARD_INST_ID = "I_CARD_INST_ID";
	public static final String CONFIG_XML = "ru/bpc/sv2/scheduler/process/jcb/resource/plain.xml";
	private ProcessDao processDao;
	private NetworkDao networkDao;
	private JcbDao jcbDao;

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
		jcbDao = new JcbDao();
	}

	private void executeBody() throws Exception {
		ProcessFileAttribute[] incomingFiles = processDao.getIncomingFilesForProcess(userSessionId, processSession.getSessionId(), process.getContainerBindId());
		SessionFile[] files = processDao.getSessionFiles(userSessionId, SelectionParams.build("sessionId", processSession.getSessionId()), true);
		if (files.length == 0 || incomingFiles.length == 0) {
			getLogger().warn("No incoming files found for session " + processSession.getSessionId());
			return;
		}
		CardTypeMap[] cardTypeMaps = networkDao.getCardTypeMaps(userSessionId, SelectionParams.build("standardId", JCB_STANDARD_ID, "lang", SystemConstants.ENGLISH_LANGUAGE)
				.setSortElement(new SortElement("priority", SortElement.Direction.ASC))
				.setRowIndexAll());
		LinkedHashMap<Pattern, Integer> cardTypePatterns = new LinkedHashMap<Pattern, Integer>();
		for (CardTypeMap cardTypeMap : cardTypeMaps) {
			cardTypePatterns.put(Pattern.compile(cardTypeMap.getNetworkCardType().replace('_', '.')), cardTypeMap.getCardTypeId());
		}
		Map<String, Integer> cardTypeMap = new HashMap<String, Integer>();
		Map<String, String> countryCodeMap = CountryCache.getInstance().getCodeMap();
		Set<String> processedIinPrefixes = new HashSet<String>();

		List<BinRange> binRanges = new ArrayList<BinRange>();
		for (SessionFile file : files) {
			if (!file.getFileAttrId().equals(incomingFiles[0].getId())) {
				continue;
			}
			try {
				InputStream stream = processDao.getSessionFileContentsStream(userSessionId, con, file.getId());

				try {
					PlainItemReader<FlatFileItem> itemReader = new PlainItemReader<FlatFileItem>(CONFIG_XML,
							new InputStreamReader(stream, SystemConstants.DEFAULT_CHARSET), "iinFile");

					FlatFileItem item;
					while ((item = itemReader.next()) != null) {
						if (item.getBean() instanceof IinRecord) {
							IinRecord message = (IinRecord) item.getBean();
							BinRange bin = new BinRange();
							bin.setPanLength(message.getPrimaryAccountNumberLength());
							String iinPrefix = message.getIinPrefix();
							if (processedIinPrefixes.contains(iinPrefix)) {
								throw new UserException("Duplicate IIN Prefix: " + iinPrefix);
							}
							processedIinPrefixes.add(iinPrefix);
							bin.setPanLow(StringUtils.rightPad(iinPrefix, message.getPrimaryAccountNumberLength(), '0'));
							bin.setPanHigh(StringUtils.rightPad(iinPrefix, message.getPrimaryAccountNumberLength(), '9'));
							String countryCode = countryCodeMap.get(message.getIssuerCountry());
							if (countryCode == null) {
								throw new UserException("Could not find country code for name " + message.getIssuerCountry());
							}
							bin.setCountry(countryCode);
							bin.setCardInstId(cardInstId);
							bin.setIssInstId(instId);
							bin.setIssNetworkId(networkId);
							bin.setCardNetworkId(cardNetworkId);
							bin.setModuleCode("JCB");
							String networkCardType = message.getCardGrade() + message.getCardProduct();
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
								throw new UserException("Could not find suitable SV card type for JCB card type " + networkCardType);
							}
							bin.setCardTypeId(cardTypeId);
							bin.setPriority(100);
							binRanges.add(bin);
						}
					}
				} finally {
					IOUtils.closeQuietly(stream);
				}
				jcbDao.registerFile(userSessionId, file.getId(), true, networkId, instId, false);
			} catch (Exception e) {
				jcbDao.registerFile(userSessionId, file.getId(), true, networkId, instId, true);
				throw e;
			}
		}
		logEstimated(binRanges.size());
		if (binRanges.size() > 0) {
			int index = 0;
			final int batchSize = 100;
			while (index < binRanges.size()) {
				networkDao.loadBinRanges(userSessionId, binRanges.subList(index, Math.min(index + batchSize, binRanges.size())), index == 0 ? networkId : null);
				index += batchSize;
				logCurrent(index + 1, 0);
			}
			networkDao.rebuildBinIndex(userSessionId);
			logCurrent(binRanges.size(), 0);
			endLogging(binRanges.size(), 0);
		}
	}
}
