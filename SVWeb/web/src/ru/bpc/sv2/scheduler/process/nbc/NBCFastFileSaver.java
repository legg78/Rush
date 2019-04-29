package ru.bpc.sv2.scheduler.process.nbc;

import com.bpcbt.sv.utils.StringCrypter;
import kh.org.nbc.fastwebservice.NBCInterface;
import org.apache.cxf.jaxws.JaxWsProxyFactoryBean;
import org.apache.cxf.ws.addressing.WSAddressingFeature;
import ru.bpc.sv2.constants.schedule.ProcessConstants;
import ru.bpc.sv2.logic.ProcessDao;
import ru.bpc.sv2.scheduler.process.AbstractFileSaver;
import ru.bpc.sv2.scheduler.process.nbc.entity.NBCFastConnection;
import ru.bpc.sv2.scheduler.process.nbc.entity.Pain001Handler;
import ru.bpc.sv2.scheduler.process.nbc.entity.Pain002Handler;
import ru.bpc.sv2.scheduler.process.nbc.entity.PainHandler;
import ru.bpc.sv2.settings.constants.SettingsConstants;
import ru.bpc.sv2.trace.TraceLogInfo;
import ru.bpc.sv2.ui.utils.cache.SettingsCache;
import ru.bpc.sv2.utils.SystemException;

import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Date;
import java.util.List;

public class NBCFastFileSaver  extends AbstractFileSaver {
    private final static String FILE_NAME_TEMPLATE_INC = "NBCFAST_inc_tr_%.xml";
    private final static String FILE_NAME_TEMPLATE_OUT = "NBCFAST_out_tr_%.xml";
    private NBCFastConnection connect;
    private StringBuilder pain001;
    private StringBuilder pain002;

    private ProcessDao processDao = new ProcessDao();

    @Override
    public boolean isRequiredInFiles() {
        return false;
    }

    @Override
    public void save() throws Exception {
        setupTracelevel();
        initConnectionParameters();
        initBeans();
        try {
            logger.debug("start saver: " + this.getClass().getName());
            loggerDB.debug(new TraceLogInfo(sessionId, getClass().getSimpleName() + ": save WS messages"));
            JaxWsProxyFactoryBean factory = new JaxWsProxyFactoryBean();
            factory.setServiceClass(NBCInterface.class);
            factory.getFeatures().add(new WSAddressingFeature());
            factory.setAddress(connect.getUrl());
            NBCInterface client = (NBCInterface) factory.create();
            getTransactions(client, ProcessConstants.FILE_PURPOSE_INCOMING);
            getTransactions(client, ProcessConstants.FILE_PURPOSE_OUTGOING);
        } finally {
            logger.debug("finally saver " + this.getClass().getName());
        }
    }

    protected void initConnectionParameters() throws Exception {
        connect = new NBCFastConnection();
        connect.setUrl(SettingsCache.getInstance().getParameterStringValue(SettingsConstants.NBC_FAST_WS_URL));
        connect.setUsername(SettingsCache.getInstance().getParameterStringValue(SettingsConstants.NBC_FAST_USERNAME));
        connect.setParticipantCode(SettingsCache.getInstance().getParameterStringValue(SettingsConstants.NBC_FAST_PARTICIPANT_CODE));
        connect.setPassword(SettingsCache.getInstance().getParameterStringValue(SettingsConstants.NBC_FAST_PASSWORD));
        connect.setPassword((new StringCrypter()).decrypt(connect.getPassword()));
        connect.check();
    }

    protected void initBeans() throws SystemException {
        processDao = new ProcessDao();
    }

    protected void getTransactions(NBCInterface client, String purpose) throws Exception {
        List<String> raws = prepareRawList(getResponse(client, purpose).split(PainHandler.SEPARATOR));
        logger.debug("Start to parse [" + raws.size() + "] transactions of [" + purpose + "]");

        Pain001Handler pain1 = new Pain001Handler();
        Pain002Handler pain2 = new Pain002Handler();
        Long count = 0L;

        for (String raw : raws) {
            if (!raw.trim().isEmpty()) {
                try {
                    if (pain1.parse(raw)) {
                        count = addPain001Transaction(pain1.asString(true), count);
                        pain2.setData(pain1.getData());
                        client.makeAcknowledgment(connect.getUsername(), connect.getPassword(), pain2.asString(false));
                    } else if (pain2.parse(raw)) {
                        count = addPain002Transaction(pain2.asString(true), count);
                    }
                } catch (Exception e) {
                    logger.error("Failed to process transaction", e);
                    loggerDB.error("Failed to process transaction", e);
                }
            }
        }

        saveIntoDB(getFileTemplate(purpose), count);
    }

    private String getResponse(NBCInterface client, String purpose) throws Exception {
        if (ProcessConstants.FILE_PURPOSE_INCOMING.equals(purpose)) {
            return client.getIncomingTransaction(connect.getUsername(), connect.getPassword(), connect.getParticipantCode());
        }
        return client.getOutgoingTransaction(connect.getUsername(), connect.getPassword(), connect.getParticipantCode());
    }

    private String getFileTemplate(String purpose) throws Exception {
        if (ProcessConstants.FILE_PURPOSE_INCOMING.equals(purpose)) {
            return new String(FILE_NAME_TEMPLATE_INC).replace("%", new SimpleDateFormat("yyyyMMddHHmmss").format(new Date()));
        }
        return new String(FILE_NAME_TEMPLATE_OUT).replace("%", new SimpleDateFormat("yyyyMMddHHmmss").format(new Date()));
    }

    private List<String> prepareRawList(String[] array) {
        List<String> raws = new ArrayList<String>();
        if (array != null) {
            raws.addAll(Arrays.asList(array));
            List<String> emptyStrings = new ArrayList<String>(1);
            emptyStrings.add("");
            raws.removeAll(emptyStrings);
        }
        return raws;
    }

    private Long addPain001Transaction(String transaction, Long count) {
        if (transaction != null) {
            if (pain001 == null) {
                pain001 = new StringBuilder();
                pain001.append(Pain001Handler.HEADER);
            }
            pain001.append(transaction + "\n");
            count++;
        }
        return count;
    }

    private Long addPain002Transaction(String transaction, Long count) {
        if (transaction != null) {
            if (pain002 == null) {
                pain002 = new StringBuilder();
                pain002.append(Pain002Handler.HEADER);
            }
            pain002.append(transaction + "\n");
            count++;
        }
        return count;
    }

    private String getPain001Transactions() {
        pain001.append(PainHandler.FOOTER);
        return pain001.toString();
    }

    private String getPain002Transactions() {
        pain002.append(PainHandler.FOOTER);
        return pain002.toString();
    }

    private void saveIntoDB(String fileName, Long count) throws Exception {
        try {
            if (count > 0) {
                logger.debug("Save [" + fileName + "] with [" + count + "] transactions");
                processDao.storeNbcFastTransactions(sessionId,
                                                    process.getContainerBindId(),
                                                    fileName,
                                                    ProcessConstants.FILE_PURPOSE_INCOMING,
                                                    (pain001 != null) ? getPain001Transactions() : getPain002Transactions(),
                                                    count);
            } else {
                logger.debug("No transactions to save");
            }
        } finally {
            pain001 = null;
            pain002 = null;
        }
    }
}
