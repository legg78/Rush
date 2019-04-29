package ru.bpc.sv2.scheduler.process.mergeable;

import org.apache.commons.lang3.StringUtils;
import org.apache.commons.lang3.tuple.MutablePair;
import org.apache.commons.lang3.tuple.Pair;
import org.apache.log4j.Logger;
import ru.bpc.sv2.constants.schedule.ProcessConstants;

import java.io.StringReader;
import java.io.UnsupportedEncodingException;
import java.sql.*;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class FileProcedures {
    private static final Logger logger = Logger.getLogger("PROCESSES");

    private static final String SQL_SELECT_ALL = "select id"
                                               + "     , file_contents"
                                               + "  from prc_session_file"
                                               + " where session_id = ?"
                                               + " order by id asc";
    private static final String SQL_SELECT = "select file_contents"
                                           + "  from prc_session_file "
                                           + " where id = ? "
                                           + " order by thread_number asc"
                                           + "     , id asc";
    private static final String SQL_APPEND = "{call prc_api_file_pkg.put_file("
                                           + "      i_sess_file_id => ?"
                                           + "    , i_clob_content => ?"
                                           + "    , i_add_to       => ?)}";
    private static final String SQL_UPDATE = "update prc_session_file"
                                           + "   set status = 'FLSTMRGD'"
                                           + "     , thread_number = nvl(?, thread_number)"
                                           + " where id  = ?";
    private static final String SQL_RECORD_ADD = "update prc_session_file"
                                               + "   set record_count = record_count + ?"
                                               + "     , status = 'FLSTACPT'"
                                               + " where id  = ?";
    private static final String SQL_RECORD_FULL = "update prc_session_file"
                                                + "   set record_count = ("
                                                + "       select sum(record_count)"
                                                + "         from prc_session_file"
                                                + "        where session_id = ?"
                                                + "          and id != ?)"
                                                + "     , status = 'FLSTACPT'"
                                                + " where id  = ?";
    private static final String SQL_CREATE = "{call prc_api_file_pkg.open_file("
                                           + "      o_sess_file_id       => ?"
                                           + "    , io_file_name         => ?"
                                           + "    , i_file_type          => ?"
                                           + "    , i_file_purpose       => ?)}";
    private static final String SQL_THREAD = "{call prc_api_session_pkg.set_thread_number("
                                           + "      i_thread_number => ?)}";

    public static String select(Connection connection, Long fileId) throws SQLException {
        String content = null;
        try (PreparedStatement pstmt = connection.prepareStatement(SQL_SELECT)) {
            pstmt.setLong(1, fileId);
            try (ResultSet results = pstmt.executeQuery()) {
                while (results != null && results.next()) {
                    content = results.getString(1);
                    logger.debug("Selected " + content.length() + " bytes of file content for id " + fileId);
                }
            }
        }
        return content;
    }

    public static List<Pair<Long, String>> selectAll(Connection connection, Long sessionId) throws SQLException {
        List<Pair<Long, String>> files = new ArrayList<Pair<Long, String>>();
        try (PreparedStatement pstmt = connection.prepareStatement(SQL_SELECT_ALL)) {
            pstmt.setLong(1, sessionId);
            try (ResultSet results = pstmt.executeQuery()) {
                while (results != null && results.next()) {
                    Long fileId = results.getLong(1);
                    String content = results.getString(2);
                    files.add(new MutablePair<Long, String>(fileId, content));
                    logger.debug("Selected " + content.length() + " bytes of file content for id " + fileId);
                }
            }
        }
        return files;
    }

    public static void append(Connection connection, Long fileId, String raw, Long records, boolean append) throws SQLException {
        logger.debug((append ? "Append " : "Update ") + raw.length() + " bytes of file content for id " + fileId);
        try (CallableStatement cstmt = connection.prepareCall(SQL_APPEND)) {
            cstmt.setLong(1, fileId);
            if (StringUtils.isNotEmpty(raw)) {
                cstmt.setCharacterStream(2, new StringReader(raw), raw.length());
            } else {
                cstmt.setNull(2, Types.CLOB);
            }
            cstmt.setBoolean(3, append);
            cstmt.execute();
            connection.commit();
        }
        if (records != null) {
            logger.debug("Update record count for file id " + fileId);
            try (PreparedStatement pstmt = connection.prepareStatement(SQL_RECORD_ADD)) {
                pstmt.setLong(1, records);
                pstmt.setLong(2, fileId);
                pstmt.executeUpdate();
                connection.commit();
            }
        }
    }

    public static void updateRecord(Connection connection, Long sessionId, Long mergedFileId) throws SQLException {
        logger.debug("Update record count for session id " + sessionId);
        try (PreparedStatement pstmt = connection.prepareStatement(SQL_RECORD_FULL)) {
            pstmt.setLong(1, sessionId);
            pstmt.setLong(2, mergedFileId);
            pstmt.setLong(3, mergedFileId);
            pstmt.executeUpdate();
            connection.commit();
        }
    }

    public static void update(Connection connection, Long fileId, Integer thread) throws SQLException {
        logger.debug("Update file status for id " + fileId + " in thread " + thread);
        try (PreparedStatement pstmt = connection.prepareStatement(SQL_UPDATE)) {
            if (thread == null) {
                pstmt.setNull(1, Types.INTEGER);
            } else {
                pstmt.setInt(1, thread);
            }
            pstmt.setLong(2, fileId);
            pstmt.executeUpdate();
            connection.commit();
        }
    }

    public static void initThread(Connection connection, Integer thread) throws SQLException {
        logger.debug("Initialize thread number " + thread);
        try (CallableStatement cstmt = connection.prepareCall(SQL_THREAD)) {
            cstmt.setInt(1, thread);
            cstmt.execute();
        }
    }

    public static FileSaverCache create(Connection connection, FileSaverCache file) throws SQLException {
        logger.debug("Create output file in thread " + file.getThread());
        try (CallableStatement cstmt = connection.prepareCall(SQL_CREATE)) {
            cstmt.registerOutParameter(1, Types.NUMERIC);
            cstmt.registerOutParameter(2, Types.VARCHAR);
            cstmt.setString(2, null);
            if (StringUtils.isNotBlank(file.getType())) {
                cstmt.setString(3, file.getType());
            } else {
                cstmt.setNull(3, Types.VARCHAR);
            }
            cstmt.setString(4, ProcessConstants.FILE_PURPOSE_OUTGOING);
            cstmt.execute();

            file.setId(cstmt.getLong(1));
            file.setName(cstmt.getString(2));
        }
        return file;
    }

    public static String getTrailer(String data, String trailer) {
        return data.substring(data.lastIndexOf(trailer));
    }

    public static String prepare(String data, boolean isFirst, String header, String trailer) {
        int headerLength = (isFirst || header == null) ? 0 : data.substring(0, data.indexOf(header)).length();
        return data.substring(headerLength, data.lastIndexOf(trailer));
    }
}
