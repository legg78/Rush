package ru.bpc.sv2.scheduler.process.files.batch;

import ru.bpc.sv2.scheduler.process.files.strings.BlockAddressingString;

import java.sql.Connection;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class PosBatchBlockHeaderParser extends PosBatchParser {
    public static final String TYPE = "POSB03";

    private String batchReference;
    private String creationDate;
    private String creationTime;
    private Long batchAmount;
    private String debitCreditFlag;
    private String merchantId;
    private String terminalId;
    private String mcc;

    public PosBatchBlockHeaderParser(BlockAddressingString raw ) {
        super.raw = raw;
    }

    public String getBatchReference(){
        return batchReference;
    }
    public void setBatchReference( String batchReference ){
        this.batchReference = batchReference;
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

    public String getMcc(){
        return mcc;
    }
    public void setMcc( String mcc ){
        this.mcc = mcc;
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
        setBatchReference(getString(21, 26));
        setCreationDate(getString(27, 34));
        setCreationTime(getString(35, 42));
        setBatchAmount(getLong(43, 58));
        setDebitCreditFlag(getString(59, 60));
        setMerchantId(getString(61, 76));
        setTerminalId(getString(77, 92));
        setMcc(getString(93, 96));
        return;
    }

    @Override
    public Long save(Connection connection, Long sessionId, Long fileId, Long blockId)
            throws Exception {
        Map<String, Object> params = new HashMap<String, Object>();

        params.put("batch_file_id", fileId);
        params.put("header_record_type", super.getRecordType());
        params.put("header_record_number", super.getRecordNumber());
        params.put("header_batch_reference", getBatchReference());
        params.put("creation_date", getCreationDate());
        params.put("creation_time", getCreationTime());
        params.put("header_batch_amount", getBatchAmount());
        params.put("header_debit_credit", getDebitCreditFlag());
        params.put("header_merchant_id", getMerchantId());
        params.put("header_terminal_id", getTerminalId());
        params.put("mcc", getMcc());

        return super.batchDao.insertBlock(connection, params);
    }
}
