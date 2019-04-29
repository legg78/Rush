package ru.bpc.sv2.scheduler.process.files.batch;

import ru.bpc.sv2.scheduler.process.files.strings.BlockAddressingString;

import java.sql.Connection;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class PosBatchFileHeaderParser extends PosBatchParser {
    public static final String TYPE = "POSB01";

    private String fileType;
    private String creationDate;
    private String creationTime;
    private String instituteId;

    public PosBatchFileHeaderParser(BlockAddressingString raw) {
        super.raw = raw;
    }

    public String getFileType(){
        return fileType;
    }
    public void setFileType( String fileType ){
        this.fileType = fileType;
    }

    public String getCreationDate(){
        return creationDate;
    }
    public void setCreationDate(String creationDate){
        this.creationDate = creationDate;
    }

    public String getCreationTime(){
        return creationTime;
    }
    public void setCreationTime(String creationTime){
        this.creationTime = creationTime;
    }

    public String getInstituteId(){
        return instituteId;
    }
    public void setInstituteId(String instituteId){
        this.instituteId = instituteId;
    }

    @Override
    public Map<String, Object> get(Long fileId, Long blockId) throws Exception {
        return null;
    }

    @Override
    public void saveAll(Connection connection, Long sessionId, List<Map<String, Object>> lines) throws Exception{
    }

    @Override
    public void parse() throws Exception {
        if (raw == null || raw.isEmpty() || raw.getLengthInBlocks() < 61) {
            return;
        }
        super.setRecordType(TYPE);
        super.setRecordNumber(getLong(9, 20));
        setFileType(getString(22, 29));
        setCreationDate(getString(30, 37));
        setCreationTime(getString(38, 45));
        setInstituteId(getString(47, 58));
        super.setBatchVersion(getString(59, 61));
        return;
    }

    @Override
    public Long save(Connection connection, Long sessionId, Long fileId, Long blockId)
            throws Exception {
        Map<String, Object> params = new HashMap<String, Object>();
        params.put("session_id", sessionId);
        params.put("proc_date", new SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(new Date()));
        params.put("file_type", getFileType());
        params.put("header_record_type", super.getRecordType());
        params.put("header_record_number", super.getRecordNumber());
        params.put("inst_id", getInstituteId());
        params.put("creation_date", getCreationDate());
        params.put("creation_time", getCreationTime());
        params.put("batch_version", super.getBatchVersion());

        return super.batchDao.insertFile(connection, params);
    }
}
