package ru.bpc.sv2.scheduler.process;

import com.bpcbt.sv.sv_sync.SyncResultType;
import com.ibatis.sqlmap.client.SqlMapSession;

import java.io.InputStream;
import java.sql.Connection;
import java.util.HashMap;
import java.util.Map;

import org.apache.commons.io.FilenameUtils;
import org.apache.commons.lang3.StringUtils;
import org.apache.commons.vfs.FileObject;
import org.apache.log4j.Level;
import org.apache.log4j.Logger;
import ru.bpc.sv2.constants.schedule.ProcessConstants;
import ru.bpc.sv2.process.ProcessBO;
import ru.bpc.sv2.process.ProcessFileAttribute;
import ru.bpc.sv2.scheduler.process.converter.FileConverter;
import ru.bpc.sv2.settings.constants.SettingsConstants;
import ru.bpc.sv2.ui.utils.CommonUtils;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.cache.SettingsCache;
import ru.bpc.sv2.utils.SystemUtils;

import java.io.InputStream;
import java.io.OutputStream;
import java.io.UnsupportedEncodingException;
import java.sql.Connection;
import java.util.HashMap;
import java.util.Map;

public abstract class AbstractFileSaver implements FileSaver {
    protected static Logger logger = Logger.getLogger("PROCESSES");
    protected static Logger loggerDB = Logger.getLogger("PROCESSES_DB");

    protected FileConverter converter = null;
    protected Connection con = null;
    protected ProcessFileAttribute fileAttributes = null;
    protected FileObject fileObject = null;
    protected InputStream inputStream = null;
    protected Map<String, Object> params;
    protected Long userSessionId;
    protected Long sessionId;
    protected String userName;
    protected ProcessBO process;
    private Map<String, Object> outParams;

    private boolean fileParamsInitialized;
    private static final long DEFAULT_TIMEOUT = 180;
    private long timeout;
    private String filename;
    private String encoding;
    private String inputDir;
    private String outputDir;
    private String errorDir;

    private Integer traceLevel;
    private Integer traceLimit;
    private Integer traceThreadNumber;

    @Override
    public abstract void save() throws Exception;

    public FileConverter getConverter() {
        return converter;
    }

    public void setConverter(FileConverter converter) {
        this.converter = converter;
    }

    public Connection getConnection() {
        return con;
    }

    public void setConnection(Connection con) {
        this.con = con;
    }

    public ProcessFileAttribute getFileAttributes() {
        return fileAttributes;
    }

    public void setFileAttributes(ProcessFileAttribute fileAttributes) {
        this.fileAttributes = fileAttributes;
    }

    public FileObject getFileObject() {
        return fileObject;
    }

    public void setFileObject(FileObject fileObject) {
        fileParamsInitialized = false;
        this.fileObject = fileObject;
    }

    public InputStream getInputStream() {
        return inputStream;
    }

    public void setInputStream(InputStream inputStream) {
        this.inputStream = inputStream;
    }

    public void setSsn(SqlMapSession ssn) {
    }

    @Override
    public void setThreadNum(int threadNum) {}

    protected Map<String, Object> getParams() {
        if (params == null) {
            params = new HashMap<String, Object>();
        }
        return params;
    }

    @Override
    public void setParams(Map<String, Object> params) {
        this.params = params;
    }

    @Override
    public void setUserSessionId(Long userSessionId) {
        this.userSessionId = userSessionId;
    }

    @Override
    public void setSessionId(Long sessionId) {
        this.sessionId = sessionId;
    }

    @Override
    public void setUserName(String userName) {
        this.userName = userName;
    }

    protected void setupTracelevel() {
        Integer level = getTraceLevel();
        if (level == null) {
            if (userName != null) {
                try {
                    level = SettingsCache.getInstance().getUserParameterNumberValue(userName, SettingsConstants.TRACE_LEVEL).intValue();
                } catch (Exception ignore) {
                    level = null;
                }
            }
            if (level == null) {
                level = SettingsCache.getInstance().getParameterNumberValue(SettingsConstants.TRACE_LEVEL).intValue();
            }
        }
        logger.setLevel(determineTraceLevel(level));
        loggerDB.setLevel(determineTraceLevel(level));
    }

    @SuppressWarnings ("UnusedDeclaration")
    protected Level determineTraceLevel(int dbLevel) {
        switch (dbLevel) {
            case 6:  return Level.TRACE;
            case 5:  return Level.INFO;
            case 4:  return Level.WARN;
            case 3:  return Level.ERROR;
            case 2:  return Level.FATAL;
            case 1:  return Level.OFF;
            default: return Level.INFO;
        }
    }

    public static String getSyncResultCodeDesc(SyncResultType result) {
        StringBuilder buf = new StringBuilder();
        if (CommonUtils.hasText(result.getDescription())) {
            buf.append(result.getCode()).append(": ").append(result.getDescription());
            if (result.getExtendedCode() != null && result.getExtendedCode() != 0) {
                buf.append(" ").append(result.getExtendedCode());
            }
        }
        String msg = null;
        try {
            msg = FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Process", "ws_err_code_" + result.getCode());
        } catch (Exception ignored) {}
        if (CommonUtils.hasText(msg)) {
            if (buf.length() > 0) {
                buf.insert(0, result.getCode() + " - " + msg + " (").append(")");
            } else {
                buf.append(msg);
            }
        } else if (buf.length() == 0) {
            buf.append(result.getCode()).append(" - unknown ws error code");
        }
        return buf.toString();
    }

    @Override
    public boolean isRequiredInFiles() {
        return true;
    }

    @Override
    public boolean isRequiredOutFiles() {
        return true;
    }

    @Override
    public void setProcess(ProcessBO process) {
        this.process = process;
    }

    @Override
    public Map<String, Object> getOutParams() {
        if (outParams == null) {
            outParams = new HashMap<String, Object>();
        }
        return outParams;
    }

    public Integer getTraceLevel() {
        return traceLevel;
    }

    public Level getTraceLevel(int dbLevel) {
        switch (dbLevel) {
            case 6:  return Level.TRACE;
            case 5:  return Level.INFO;
            case 4:  return Level.WARN;
            case 3:  return Level.ERROR;
            case 2:  return Level.FATAL;
            case 1:  return Level.OFF;
            default: return Level.INFO;
        }
    }

    @Override
    public void setTraceLevel(Integer traceLevel) {
        this.traceLevel = traceLevel;
    }

    public Integer getTraceLimit() {
        return traceLimit;
    }

    @Override
    public void setTraceLimit(Integer traceLimit) {
        this.traceLimit = traceLimit;
    }

    public Integer getTraceThreadNumber() {
        return traceThreadNumber;
    }

    @Override
    public void setTraceThreadNumber(Integer traceThreadNumber) {
        this.traceThreadNumber = traceThreadNumber;
    }

    protected long getTimeout() {
        initFileParamsIfNecessary();
        return timeout;
    }

    protected String getFilename() {
        initFileParamsIfNecessary();
        return filename;
    }

    protected String getEncoding() {
        initFileParamsIfNecessary();
        return encoding;
    }

    protected String getInputDir() {
        initFileParamsIfNecessary();
        return inputDir;
    }

    protected String getOutputDir() {
        initFileParamsIfNecessary();
        return outputDir;
    }

    protected String getErrorDir() {
        initFileParamsIfNecessary();
        return errorDir;
    }

    private void initFileParamsIfNecessary() {
        if (!fileParamsInitialized) {
            fileParamsInitialized = true;
            timeout = DEFAULT_TIMEOUT;
            filename = null;
            encoding = null;
            inputDir = null;
            outputDir = null;
            errorDir = null;
            if (fileObject != null) {
                filename = fileObject.getName().getBaseName();
                String directory = SystemUtils.getFileDirectoryPath(fileObject);
                inputDir = directory;
                if (directory.endsWith(ProcessConstants.IN_PROCESS_FOLDER)) {
                    String parent = directory.substring(0, directory.lastIndexOf(ProcessConstants.IN_PROCESS_FOLDER));
                    outputDir = FilenameUtils.concat(parent, ProcessConstants.PROCESSED_FOLDER);
                    errorDir = FilenameUtils.concat(parent, ProcessConstants.REJECTED_FOLDER);
                } else {
                    outputDir = FilenameUtils.concat(directory, ProcessConstants.PROCESSED_FOLDER);
                    errorDir = FilenameUtils.concat(directory, ProcessConstants.REJECTED_FOLDER);
                }
            }
            ProcessFileAttribute fileAttrs = getFileAttributes();
            if (fileAttrs != null) {
                encoding = fileAttrs.getCharacterSet();
            }
            Map<String, Object> params = getParams();
            Object timeoutParam = params.get(ProcessConstants.TIMEOUT_PARAM);
            if (timeoutParam instanceof Number) {
                timeout = ((Number) timeoutParam).longValue();
            } else if (fileAttrs != null && fileAttrs.getTimeWait() != null) {
                timeout = fileAttrs.getTimeWait().longValue();
            }
        }
    }

    protected Object getLogMessagePrefix() {
        return null;
    }

    private String prepareLogMessage(String message) {
        Object prefix = getLogMessagePrefix();
        return prefix != null ? prefix + " " + message : message;
    }

    protected String getCharset() {
        String charset = null;
        if (fileAttributes != null) {
            charset = fileAttributes.getCharacterSet();
            if (StringUtils.isNotBlank(charset)) {
                charset = charset.trim().toUpperCase();
            }
            if (SimpleFileSaver.CHARSET_WE8EBCDIC37.equals(charset)) {
                charset = SimpleFileSaver.CHARSET_EBCDIC_IBM01140;
            }
        }
        return charset;
    }

    protected String getEncodedString(String in) throws UnsupportedEncodingException {
        if (in != null) {
            String charset = getCharset();
            return charset != null ? new String(in.getBytes(), charset) : in;
        } else {
            return null;
        }
    }

    protected boolean isMerge() {
        return !isNotMerge();
    }

    protected boolean isNotMerge() {
        return (!isMergeByThread() && !isMergeByProcess());
    }

    protected boolean isMergeByThread() {
        if (getFileAttributes() != null) {
            return MERGE_FILES_OF_THREAD.equals(getFileAttributes().getMergeFileMode());
        }
        return false;
    }

    protected boolean isMergeByProcess() {
        if (getFileAttributes() != null) {
            return MERGE_FILES_OF_PROCESS.equals(getFileAttributes().getMergeFileMode());
        }
        return false;
    }

    protected void trace(String message) {
        logger.trace(prepareLogMessage(message));
    }

    protected void debug(String message) {
        logger.debug(prepareLogMessage(message));
    }

    protected void info(String message) {
        logger.info(prepareLogMessage(message));
    }

    protected void warn(String message) {
        logger.warn(prepareLogMessage(message));
    }

    protected void error(Throwable exception) {
        logger.error(prepareLogMessage(exception.getMessage()), exception);
    }

    protected void error(String message) {
        logger.error(prepareLogMessage(message));
    }

    protected void error(String message, Throwable exception) {
        logger.error(prepareLogMessage(message), exception);
    }
}
