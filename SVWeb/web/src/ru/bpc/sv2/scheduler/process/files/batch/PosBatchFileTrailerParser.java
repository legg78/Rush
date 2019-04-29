package ru.bpc.sv2.scheduler.process.files.batch;

import ru.bpc.sv2.scheduler.process.files.strings.BlockAddressingString;

import java.sql.Connection;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class PosBatchFileTrailerParser extends PosBatchParser {
    public static final String TYPE = "POSB02";

    private Long totalBatchNumber;

    public PosBatchFileTrailerParser(BlockAddressingString raw ) {
        super.raw = raw;
    }

    public Long getTotalBatchNumber(){
        return totalBatchNumber;
    }
    public void setTotalBatchNumber(Long totalBatchNumber){
        this.totalBatchNumber = totalBatchNumber;
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
        if (raw == null || raw.isEmpty() || raw.getLengthInBlocks() < 32) {
            return;
        }
        super.setRecordType(TYPE);
        super.setRecordNumber(getLong(9, 20));
        setTotalBatchNumber(getLong(21, 32));
        return;
    }

    @Override
    public Long save(Connection connection, Long sessionId, Long fileId, Long blockId)
            throws Exception {
        Map<String, Object> params = new HashMap<String, Object>();

        params.put("id", fileId);
        params.put("trailer_record_type", super.getRecordType());
        params.put("trailer_record_number", super.getRecordNumber());
        params.put("total_batch_number", getTotalBatchNumber());

        super.batchDao.updateFile(connection, params);
        return null;
    }
}
