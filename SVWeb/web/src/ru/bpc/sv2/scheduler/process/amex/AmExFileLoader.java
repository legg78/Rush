package ru.bpc.sv2.scheduler.process.amex;

import com.ibatis.sqlmap.client.SqlMapSession;
import org.apache.commons.codec.binary.Hex;
import org.apache.commons.lang3.StringUtils;
import org.apache.commons.vfs.FileObject;
import org.apache.log4j.Level;
import org.apache.log4j.Logger;
import ru.bpc.sv2.constants.SystemConstants;
import ru.bpc.sv2.process.ProcessBO;
import ru.bpc.sv2.process.ProcessFileAttribute;
import ru.bpc.sv2.scheduler.process.FileSaver;
import ru.bpc.sv2.scheduler.process.SimpleFileSaver;
import ru.bpc.sv2.scheduler.process.converter.FileConverter;
import ru.bpc.sv2.settings.constants.SettingsConstants;
import ru.bpc.sv2.ui.utils.cache.SettingsCache;
import ru.bpc.sv2.utils.SystemException;

import javax.xml.bind.DatatypeConverter;
import java.io.InputStream;
import java.io.OutputStream;
import java.io.UnsupportedEncodingException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.Map;

public class AmExFileLoader implements FileSaver {
    private static final Logger logger = Logger.getLogger("PROCESSES");

    private static final String MSG_CODE_1 = "9240";
    private static final String MSG_CODE_2 = "9340";
    private static final String NULL_CHARACTER = "0";
    private static final String EMV_CODE = "07";

    private static final int BATCH_SIZE = 2000;
    private static final int MSG_LENGTH = 4;
    private static final int TYPE_OFFSET = 4;
    private static final int TYPE_LENGTH = 6;
    private static final int HEAD_LENGTH = 6;
    private static final int ASCII_BLOCK_1 = 589;
    private static final int ASCII_BLOCK_2 = 1093;

    private InputStream inputStream;
    private FileObject fileObject = null;
    protected FileConverter converter = null;
    private Connection connection = null;
    private ProcessFileAttribute fileAttributes = null;
    private OutputStream outputStream = null;
    private Map<String, Object> params;

    private Integer traceLevel;
    private Integer traceLimit;
    private Integer traceThreadNumber;

    private static final String queryCount = "select count(record_number) " +
                                               "from prc_ui_file_raw_data_vw " +
                                              "where session_file_id = ?";

    private static final String queryData = "select raw_data " +
                                              "from prc_ui_file_raw_data_vw " +
                                             "where session_file_id = ? " +
                                               "and record_number >= ? " +
                                               "and record_number <= ? " +
                                          "order by record_number";

    @Override
    public void save() throws Exception {
        setupTracelevel();
        logger.debug("AmEx File Loader: start");
        try {
            outputStream = fileObject.getContent().getOutputStream();
            int count = getCount();
            if (count == 0) {
                logger.debug("AmEx File Loader: no records");
                return;
            }
            int position = 0;
            int records = 0;
            boolean finish = false;
            ResultSet results = getData(position);
            while (!finish) {
                if (results == null || !results.next()) {
                    results.close();
                    position += (records+1);
                    results = getData(position);
                    if (results == null || !results.next()) {
                        break;
                    }
                }
                String hex = getEncodedString(results.getString(1));
                outputStream.write(DatatypeConverter.parseHexBinary(hex));
                if (records >= count) {
                    finish = true;
                } else {
                    records++;
                }
            }
            logger.debug("AmEx File Loader: flushing file");
            outputStream.flush();
        } catch (Exception e) {
            logger.error("", e);
            throw new SystemException(e);
        }
    }

    private int getCount() throws SQLException {
        int out = 0;
        PreparedStatement pstmt = connection.prepareStatement(queryCount);
        pstmt.setLong(1, fileAttributes.getId());
        ResultSet result = pstmt.executeQuery();
        if (result.next()) {
            out = result.getInt(1);
            logger.debug("AmEx File Loader: records count = " + out);
        }
        result.close();
        return out;
    }

    private ResultSet getData(int position) throws SQLException {
        PreparedStatement pstmt = connection.prepareStatement(queryData);
        pstmt.setLong(1, fileAttributes.getId());
        pstmt.setInt(2, position);
        pstmt.setInt(3, position + BATCH_SIZE - 1);
        return pstmt.executeQuery();
    }

    private String getEncodedString(String in) throws UnsupportedEncodingException {
        String charset = null;
        if (fileAttributes != null) {
            charset = fileAttributes.getCharacterSet();
            if (SimpleFileSaver.CHARSET_WE8EBCDIC37.equals(charset)) {
                charset = SimpleFileSaver.CHARSET_EBCDIC_IBM01140;
            }
        }
        return convertHex(in, charset);
    }

    private String getEncodedHex(String in, String charset, boolean isBinary) throws UnsupportedEncodingException {
        if (isBinary) {
            return Hex.encodeHexString(DatatypeConverter.parseHexBinary(in));
        }
        return Hex.encodeHexString(in.getBytes(charset));
    }

    private String convertHex(String in, String charset) throws UnsupportedEncodingException {
        if (isEmvAddendum(in)) {
            return getEncodedHex(in.substring(0, ASCII_BLOCK_1), charset, false) +
                   getEncodedHex(in.substring(ASCII_BLOCK_1, ASCII_BLOCK_2), charset, true) +
                   getEncodedHex(in.substring(ASCII_BLOCK_2), charset, false);
        }
        return getEncodedHex(in, charset, false);
    }

    private String eof() {
        String eof = "";
        for (int i = 0; i < 8; i++) {
            eof += NULL_CHARACTER;
        }
        return eof;
    }

    private boolean isEmvAddendum(String in) {
        if (StringUtils.isNotEmpty(in) && in.length() > HEAD_LENGTH) {
            if (MSG_CODE_1.equals(in.substring(0, MSG_LENGTH).trim()) ||
                MSG_CODE_2.equals(in.substring(0, MSG_LENGTH).trim())) {
                if (EMV_CODE.equals(in.substring(TYPE_OFFSET, TYPE_LENGTH).trim())) {
                    return true;
                }
            }
        }
        return false;
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
        return inputStream;
    }
    @Override
    public void setInputStream(InputStream inputStream) {
        this.inputStream = inputStream;
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
    public FileConverter getConverter() {
        return converter;
    }
    @Override
    public void setConverter(FileConverter converter) {
        this.converter = converter;
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
    public ProcessFileAttribute getFileAttributes() {
        return fileAttributes;
    }
    @Override
    public void setFileAttributes(ProcessFileAttribute fileAttributes) {
        this.fileAttributes = fileAttributes;
    }

    @Override
    public void setParams(Map<String, Object> params) {
        this.params = params;
    }
    @Override
    public Map<String, Object> getOutParams() {
        return null;
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
    public void setSsn(SqlMapSession ssn) {
        throw new UnsupportedOperationException(Thread.currentThread().getStackTrace()[1].getMethodName());
    }
    @Override
    public void setThreadNum(int threadNum) {
        throw new UnsupportedOperationException(Thread.currentThread().getStackTrace()[1].getMethodName());
    }

    @Override
    public void setUserSessionId(Long userSessionId) {}
    @Override
    public void setSessionId(Long sessionId) {}
    @Override
    public void setUserName(String userName) {}
    @Override
    public void setProcess(ProcessBO proc) {}

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
