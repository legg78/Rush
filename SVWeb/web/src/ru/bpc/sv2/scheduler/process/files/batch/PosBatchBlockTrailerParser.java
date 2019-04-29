package ru.bpc.sv2.scheduler.process.files.batch;

import ru.bpc.sv2.scheduler.process.files.strings.BlockAddressingString;

import java.sql.Connection;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class PosBatchBlockTrailerParser extends PosBatchParser {
    public static final String TYPE = "POSB04";

    private String batchReference;
    private String merchantId;
    private String terminalId;
    private Long batchAmount;
    private String debitCreditFlag;
    private Integer batchRecordsNumber;

    public PosBatchBlockTrailerParser(BlockAddressingString raw ) {
        super.raw = raw;
    }

    public String getBatchReference(){
        return batchReference;
    }
    public void setBatchReference( String batchReference ){
        this.batchReference = batchReference;
    }

    public String getMerchantId(){
        return merchantId;
    }
    public void setMerchantId( String merchantId ){
        this.merchantId = merchantId;
    }

    public String getTerminalId(){
        return terminalId;
    }
    public void setTerminalId( String terminalId ){
        this.terminalId = terminalId;
    }

    public Long getBatchAmount(){
        return batchAmount;
    }
    public void setBatchAmount( Long batchAmount ){
        this.batchAmount = batchAmount;
    }

    public String getDebitCreditFlag(){
        return debitCreditFlag;
    }
    public void setDebitCreditFlag( String debitCreditFlag ){
        this.debitCreditFlag = debitCreditFlag;
    }

    public Integer getBatchRecordsNumber(){
        return batchRecordsNumber;
    }
    public void setBatchRecordsNumber( Integer batchRecordsNumber ){
        this.batchRecordsNumber = batchRecordsNumber;
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
        setBatchReference(getString(21, 26));
        setMerchantId(getString(27, 42));
        setTerminalId(getString(43, 58));
        setBatchAmount(getLong(59, 74));
        setDebitCreditFlag(getString(75, 76));
        setBatchRecordsNumber(getInteger(77, 80));
        return;
    }

    @Override
    public Long save(Connection connection, Long sessionId, Long fileId, Long blockId)
            throws Exception {
        Map<String, Object> params = new HashMap<String, Object>();

        params.put("id", blockId);
        params.put("trailer_record_type", super.getRecordType());
        params.put("trailer_record_number", super.getRecordNumber());
        params.put("trailer_batch_reference", getBatchReference());
        params.put("trailer_merchant_id", getMerchantId());
        params.put("trailer_terminal_id", getTerminalId());
        params.put("trailer_batch_amount", getBatchAmount());
        params.put("trailer_debit_credit", getDebitCreditFlag());
        params.put("number_records", getBatchRecordsNumber());

        super.batchDao.updateBlock(connection, params);
        return null;
    }
}
