package ru.bpc.sv2.scheduler.process.multithread.lob;


import com.ibatis.sqlmap.client.SqlMapSession;

import org.apache.commons.vfs.FileObject;
import org.apache.log4j.Level;
import org.apache.log4j.Logger;

import ru.bpc.sv2.process.ProcessBO;
import ru.bpc.sv2.process.ProcessFileAttribute;
import ru.bpc.sv2.scheduler.process.FileSaver;
import ru.bpc.sv2.scheduler.process.converter.FileConverter;
import ru.bpc.sv2.settings.constants.SettingsConstants;
import ru.bpc.sv2.ui.utils.cache.SettingsCache;

import java.io.InputStream;
import java.io.RandomAccessFile;
import java.sql.Connection;
import java.util.List;
import java.util.Map;
import java.util.concurrent.BrokenBarrierException;
import java.util.concurrent.CyclicBarrier;

public class LobMultithreadFileLoader implements FileSaver {
    private static final Logger logger = Logger.getLogger("PROCESSES");

    private Connection connection;
    private FileObject fileObject;
    private ProcessFileAttribute processFileAttributes;

    private static final int availableProcessors = Runtime.getRuntime().availableProcessors();
    private static final int _1MB = 1024*1024;
    private String contentFieldName = "content";
    private String sqlText ="select substr(file_contents, ?, ?) as " + contentFieldName + " from prc_ui_file_out_vw where id = ?";

    private Integer traceLevel;
    private Integer traceLimit;
    private Integer traceThreadNumber;

    @Override
    public void save() throws Exception {
        setupTracelevel();

        long sourceLength = processFileAttributes.getFileContentLength();
        int threadsAmount = sourceLength > (_1MB * 30) ?  availableProcessors * 2 : 1;  // if <=30Mb then 1 thead
        long count = sourceLength / threadsAmount;
        int bufferSize = count > _1MB  ? _1MB  : _1MB / 8;
        long id = processFileAttributes.getId();
        String fileName = processFileAttributes.getLocation()+fileObject.getName().getBaseName();

        logger.debug("THREADS AMOUNT: " + threadsAmount);
        logger.debug("BUFFER SIZE: " + bufferSize + " bytes");

        RandomAccessFile f = new RandomAccessFile(fileName, "rw");
        f.setLength(count * threadsAmount);

        Finisher finisher = new Finisher(System.currentTimeMillis());
        CyclicBarrier barrier = new CyclicBarrier(threadsAmount+1, finisher);
        ClobCopier[] clobCopiers = new ClobCopier[threadsAmount];

        for(int i = 0; i <=  threadsAmount - 1; i++) {
            clobCopiers[i] = new ClobCopier(barrier, connection, fileName,
                    sqlText, contentFieldName, id, bufferSize, i * count + 1,
                    (i != threadsAmount - 1) ? count : Long.MAX_VALUE);

            Thread thread = new Thread(clobCopiers[i], "THREAD:" + i);
            thread.start();
        }

        try {
            barrier.await();
            logger.debug("All threads have finished copying.");
            f.close();
        } catch (InterruptedException e) {
            logger.error(e);
            throw new Exception(e);
        } catch (BrokenBarrierException e) {
            logger.error(e);
            throw new Exception(e);
        }finally {
            f.close();
        }


    }

    private Level getTraceLevel(int dbLevel) {
        switch (dbLevel) {
            case 6: return Level.TRACE;
            case 5: return Level.INFO;
            case 4: return Level.WARN;
            case 3: return Level.ERROR;
            case 2: return Level.FATAL;
            case 1: return Level.OFF;
            default: return Level.INFO;
        }
    }

    @Override
    public InputStream getInputStream() {
        return null;
    }

    @Override
    public void setInputStream(InputStream inputStream) {

    }

    @Override
    public FileObject getFileObject() {
        return fileObject;
    }

    @Override
    public void setFileObject(FileObject fileObject) {
        this.fileObject = fileObject;
    }

    @Override
    public Connection getConnection() {
        return connection;
    }

    @Override
    public void setConnection(Connection connection) {
        this.connection = connection;
    }

    @Override
    public FileConverter getConverter() {
        return null;
    }

    @Override
    public void setConverter(FileConverter converter) {

    }

    @Override
    public ProcessFileAttribute getFileAttributes() {
        return processFileAttributes;
    }

    @Override
    public void setFileAttributes(ProcessFileAttribute processFileAttributes) {
        this.processFileAttributes = processFileAttributes;
    }

    @Override
    public void setSsn(SqlMapSession ssn) {

    }

    @Override
    public void setThreadNum(int threadNum) {

    }

    @Override
    public void setParams(Map<String, Object> params) {

    }

    @Override
    public Map<String, Object> getOutParams() {
        return null;
    }

    @Override
    public void setUserSessionId(Long userSessionId) {

    }

    @Override
    public void setSessionId(Long sessionId) {

    }

	@Override
	public void setUserName(String userName) {

	}

	@Override
	public boolean isRequiredInFiles() {
		return true;
	}

	@Override
	public boolean isRequiredOutFiles() {
		// TODO Auto-generated method stub
		return true;
	}

	@Override
	public void setProcess(ProcessBO proc) {
		// TODO Auto-generated method stub
		
	}

    @Override
    public void setTraceLevel(Integer traceLevel) {
        this.traceLevel = traceLevel;
    }
    @Override
    public void setTraceLimit(Integer traceLimit) {
        this.traceLimit = traceLimit;
    }
    @Override
    public void setTraceThreadNumber(Integer traceThreadNumber) {
        this.traceThreadNumber = traceThreadNumber;
    }

    private void setupTracelevel() {
        Integer level = traceLevel;
        if (level == null) {
            level = SettingsCache.getInstance().getParameterNumberValue(SettingsConstants.TRACE_LEVEL).intValue();
        }
        logger.setLevel(getTraceLevel(level));
    }
}
