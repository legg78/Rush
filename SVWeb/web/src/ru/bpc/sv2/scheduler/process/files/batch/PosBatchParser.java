package ru.bpc.sv2.scheduler.process.files.batch;

import org.apache.log4j.Logger;
import ru.bpc.sv2.logic.PosBatchDao;
import ru.bpc.sv2.scheduler.process.files.strings.BlockAddressingString;

import java.nio.charset.Charset;
import java.nio.charset.StandardCharsets;
import java.sql.Connection;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;
import java.util.Map;

public abstract class PosBatchParser{
    public static final Long BUFFER_MAX_SIZE = 10000L;
    protected static Logger logger = Logger.getLogger("PROCESSES");
    protected static Charset charset = getCharset();
    protected static PosBatchDao batchDao = new PosBatchDao();
    protected BlockAddressingString raw = null;

    private String recordType;
    private Long recordNumber;
    private String batchVersion;

    private String subString( Integer from, Integer till ){
        /**
         * Decrease start offset here to save values of offsets in parser classes as in specification
         */
        Integer length = raw.getLengthInBlocks();
        if (length >= (from - 1)) {
            if (length >= till) {
                return raw.substringBlocks((from - 1), till).trim().toString();
            }
            else {
                return raw.substringBlocks((from - 1), length).trim().toString();
            }
        }
        return new String("");
    }
    public Long getLong( Integer from, Integer till ){
        String substring = subString(from, till);
        return substring.equals("") ? null : Long.parseLong(substring);
    }
    public Integer getInteger( Integer from, Integer till ){
        String substring = subString(from, till);
        return substring.equals("") ? null : Integer.valueOf(subString(from, till));
    }
    public String getString( Integer from, Integer till ){
        return subString(from, till);
    }
    public Date getDate( Integer from, Integer till, String format ){
        try {
            return (new SimpleDateFormat(format)).parse(subString(from, till));
        }
        catch (ParseException e) {
            logger.error(e);
        }
        return null;
    }

    public String getRecordType(){
        return recordType;
    }
    public void setRecordType( String recordType ){
        this.recordType = recordType;
    }

    public Long getRecordNumber(){
        return recordNumber;
    }
    public void setRecordNumber( Long recordNumber ){
        this.recordNumber = recordNumber;
    }

    public String getBatchVersion(){
        return batchVersion;
    }
    public void setBatchVersion( String batchVersion ){
        this.batchVersion = batchVersion;
    }


    public abstract void parse() throws Exception;
    public abstract Map<String, Object> get(Long fileId, Long blockId) throws Exception;
    public abstract Long save(Connection connection, Long sessionId, Long fileId, Long blockId) throws Exception;
    public abstract void saveAll(Connection connection, Long sessionId, List<Map<String, Object>> lines) throws Exception;

    public static PosBatchParser create(String in) {
        if (batchDao == null) {
	        batchDao = new PosBatchDao();
        }
        if (in != null) {
            BlockAddressingString line = BlockAddressingString.create(in, getCharset());
            if (line.startsWith(PosBatchRecordParser.TYPE)) {
                return new PosBatchRecordParser(line);
            }
            if (line.startsWith(PosBatchBlockHeaderParser.TYPE)) {
                return new PosBatchBlockHeaderParser(line);
            }
            if (line.startsWith(PosBatchBlockTrailerParser.TYPE)) {
                return new PosBatchBlockTrailerParser(line);
            }
            if (line.startsWith(PosBatchFileHeaderParser.TYPE)) {
                return new PosBatchFileHeaderParser(line);
            }
            if (line.startsWith(PosBatchFileTrailerParser.TYPE)) {
                return new PosBatchFileTrailerParser(line);
            }
            if (line.equals("")) {
                return new PosBatchRecordParser(line);
            }
        }
        return null;
    }

    public static Charset getCharset(){
        if (charset == null) {
            if (System.getProperty("svfe_encoding") == null) {
                charset = StandardCharsets.UTF_8;
            }
            else {
                charset = Charset.forName(System.getProperty("svfe_encoding"));
            }
            logger.info("Encoding charset: " + charset.displayName());
        }
        return charset;
    }
}
