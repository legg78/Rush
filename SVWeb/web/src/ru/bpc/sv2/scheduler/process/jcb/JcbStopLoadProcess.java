package ru.bpc.sv2.scheduler.process.jcb;

import org.apache.commons.io.IOUtils;
import ru.bpc.sv2.constants.SystemConstants;
import ru.bpc.sv2.constants.schedule.ProcessConstants;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.issuing.Card;
import ru.bpc.sv2.logic.IssuingDao;
import ru.bpc.sv2.logic.ProcessDao;
import ru.bpc.sv2.process.ProcessFileAttribute;
import ru.bpc.sv2.process.SessionFile;
import ru.bpc.sv2.process.filereader.FlatFileItem;
import ru.bpc.sv2.process.filereader.PlainItemReader;
import ru.bpc.sv2.scheduler.process.IbatisExternalProcess;
import ru.bpc.sv2.scheduler.process.jcb.plain.StopDataRecord;
import ru.bpc.sv2.utils.SystemException;
import ru.bpc.sv2.utils.UserException;

import java.io.InputStream;
import java.io.InputStreamReader;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

@SuppressWarnings("unused")
public class JcbStopLoadProcess extends IbatisExternalProcess {
	public static final String CONFIG_XML = "ru/bpc/sv2/scheduler/process/jcb/resource/plain.xml";
	private ProcessDao processDao;
	private IssuingDao issuingDao;

	private Integer instId;
	private Integer networkId;
	private Integer cardInstId;
	private Integer cardNetworkId;
	private Integer cardTypeId;
	private boolean cleanupBins;

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
	}

	private void initBeans() throws SystemException {
		processDao = new ProcessDao();
		issuingDao = new IssuingDao();
	}

	private void executeBody() throws Exception {
		ProcessFileAttribute[] incomingFiles = processDao.getIncomingFilesForProcess(userSessionId, processSession.getSessionId(), process.getContainerBindId());
		SessionFile[] files = processDao.getSessionFiles(userSessionId, SelectionParams.build("sessionId", processSession.getSessionId()), true);
		if (files.length == 0 || incomingFiles.length == 0) {
			getLogger().warn("No incoming files found for session " + processSession.getSessionId());
			return;
		}
		List<Card> cards = new ArrayList<Card>();
		for (SessionFile file : files) {
			if (!file.getFileAttrId().equals(incomingFiles[0].getId())) {
				continue;
			}
			InputStream stream = processDao.getSessionFileContentsStream(userSessionId, con, file.getId());

			try {
				PlainItemReader<FlatFileItem> itemReader = new PlainItemReader<FlatFileItem>(CONFIG_XML,
						new InputStreamReader(stream, SystemConstants.DEFAULT_CHARSET), "stopDataFile");

				FlatFileItem item;
				while ((item = itemReader.next()) != null) {
					if (item.getBean() instanceof StopDataRecord) {
						StopDataRecord message = (StopDataRecord) item.getBean();
						Card card = new Card();
						card.setCardNumber(message.getJcbCardnumber());
						cards.add(card);
					}
				}
			} finally {
				IOUtils.closeQuietly(stream);
			}
		}
		logEstimated(cards.size());
		if (cards.size() > 0) {
			int index = 0;
			for (Card card : cards) {
				if (issuingDao.getBlackCardsCount(userSessionId, SelectionParams.build("cardNumber", card.getCardNumber())) == 0) {
					issuingDao.addBlackCard(userSessionId, card);
				}
				logCurrent(++index, 0);
			}
			endLogging(cards.size(), 0);
		}
	}
}
