package ru.bpc.sv2.scheduler.process.svng.reconciliation;

import com.bpcbt.sv.camel.converters.Config;
import com.bpcbt.sv.camel.converters.mapping.BlockAddressingString;
import com.bpcbt.sv.camel.converters.mapping.ByteAddressingStringStreamReader;
import oracle.jdbc.OracleTypes;
import ru.bpc.sv2.reconciliation.export.atm.ReconciliationATM;
import ru.bpc.sv2.scheduler.process.AbstractFileSaver;
import ru.bpc.sv2.scheduler.process.svng.AbstractFeUnloadFileSaver;
import ru.bpc.sv2.settings.constants.SettingsConstants;
import ru.bpc.sv2.ui.utils.cache.SettingsCache;
import ru.bpc.sv2.utils.UserException;

import java.io.IOException;
import java.math.BigDecimal;
import java.nio.charset.Charset;
import java.sql.CallableStatement;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.Future;

public class LoadATMReconciliationSaver extends AbstractFileSaver {

    @Override
    public void save() throws Exception {
        setupTracelevel();
        RegisterReconciliationATMJdbc dao = new RegisterReconciliationATMJdbc(params, con);
        setUserContext();

        SettingsCache settingParamsCache = SettingsCache.getInstance();
        BigDecimal threadsNumberParam = settingParamsCache.getParameterNumberValue(SettingsConstants.PARALLEL_DEGREE);
        Integer THREAD_NUMBER = (process.getParallelDegree() != null) ? process.getParallelDegree() :
                (threadsNumberParam != null ? threadsNumberParam.intValue() : 1);

        AbstractFeUnloadFileSaver.setupConverterConfigPath(getFileAttributes());
        Charset inputCharset = Config.getFrontEndCharset();

        ByteAddressingStringStreamReader isr;
        BlockAddressingString line = null;

        ReconciliationATMParser[] reconciliationATMParser = new ReconciliationATMParser[THREAD_NUMBER];
        Future[] futures = new Future[THREAD_NUMBER];
        ExecutorService pool = Executors.newCachedThreadPool();

        for(int i = 0; i < THREAD_NUMBER; i++) {
            reconciliationATMParser[i] = new ReconciliationATMParser();
        }

        isr = new ByteAddressingStringStreamReader(inputStream, inputCharset);
        Integer lineNo = 0;
        Integer currThread = 0;
        boolean interrupt = false;
        Exception exception = null;
        try {
            while ((line = isr.readLine()) != null && !interrupt) {
                lineNo ++;
                if (currThread >= THREAD_NUMBER) {
                    currThread = 0;
                    interrupt = false;
                    for (int i = 0; i < THREAD_NUMBER; i++) {
                        if (interrupt && !futures[i].isDone()) {
                            futures[i].cancel(true);
                            if (futures[i].isCancelled()) {
                                debug("Process stopped. Thread " + i);
                            }
                            continue;
                        }
                        Object result = futures[i].get();
                        if (result instanceof Exception) {
                            if (process.isInterruptThreads()) {
                                interrupt = true;
                            }
                            exception = (Exception) result;
                            error("Error in line:" + (lineNo - THREAD_NUMBER + i));
                        } else {
                            //noinspection unchecked
                            dao.insert((ReconciliationATM) result);
                        }
                    }
                }

                reconciliationATMParser[currThread].setLine(line);
                futures[currThread] = pool.submit(reconciliationATMParser[currThread]);
                currThread++;
            }

            debug("Processed " + lineNo + " lines");

            if (currThread > 0) {
                for (int i = 0; i < currThread; i++) {
                    if (interrupt && !futures[i].isDone()) {
                        futures[i].cancel(true);
                        if (futures[i].isCancelled()) {
                            debug("Process stopped. Thread " + i);
                        }
                        continue;
                    }
                    Object result = futures[i].get();
                    if (result instanceof Exception) {
                        if (process.isInterruptThreads()) {
                            interrupt = true;
                        }
                        exception = (Exception) result;
                        error("Error in line:" + (lineNo - currThread + i));
                    } else {
                        dao.insert((ReconciliationATM) result);
                    }
                }
            }
            if (interrupt) {
                throw exception;
            } else if (exception != null) {
                error(exception);
                loggerDB.error(exception);
            }
            dao.setSessionFileId(sessionId);
            dao.flush();
        } catch (Exception e) {
        	String errorMessage = String.format("%s -> ERROR parsing line %d: %s", e.getMessage(), lineNo, line);
            error(errorMessage);
            throw new UserException(errorMessage, e);
        } finally {
            try {
                isr.close();
            } catch (IOException ioe) {
                // ignore
            }
        }
    }

    private void setUserContext() throws Exception {
        try (CallableStatement s = con.prepareCall(RegisterReconciliationATMJdbc.SQL_SET_USER_CONTEXT)) {
            s.setString(1, userName);
            s.setObject(2, sessionId, OracleTypes.BIGINT);
            s.setObject(3, null, OracleTypes.VARCHAR);
            s.registerOutParameter(2, OracleTypes.BIGINT);
            s.executeUpdate();
        }
    }
}
