package ru.bpc.sv2.scheduler.process.files.batch;

import ru.bpc.sv2.scheduler.process.files.strings.BlockAddressingString;

import java.sql.Connection;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class PosBatchRecordParser extends PosBatchParser {
    public static final String TYPE = "POSB05";

    private Long voucherNumber;
    private String cardNumber;
    private Integer cardMemberNumber;
    private String cardExpirationDate;
    private Long transactionAmount;
    private String transactionCurrency;
    private String debitCreditFlag;
    private String transactionDate;
    private String transactionTime;
    private String authorizationCode;
    private Integer transactionType;
    private Long utrnno;
    private Integer reversalFlag;
    private Long authorizationUtrnno;
    private String posDataCode;
    private Long rrn;
    private Long traceNumber;
    private Integer networkId;
    private String acqInstCode;
    private String transactionStatus;
    private String additionalData;
    private String emvData;
    private String serviceId;
    private String paymentDetails;
    private String serviceProviderIdentifier;
    private String uniquePaymentNumber;
    private String additionalAmounts;
    private Long svfeTraceNumber;

    public PosBatchRecordParser(BlockAddressingString raw) {
        super.raw = raw;
    }

    private void parseVersion0() throws Exception {
        setVoucherNumber(getLong(21, 26));
        setCardNumber(getString(27, 50));
        setCardMemberNumber(getInteger(51, 51));
        setCardExpirationDate(getString(52, 55));
        setTransactionAmount(getLong(56, 67));
        setTransactionCurrency(getString(68, 70));
        setDebitCreditFlag(getString(71, 72));
        setTransactionDate(getString(73, 80));
        setTransactionTime(getString(81, 86));
        setAuthorizationCode(getString(87, 92));
        setTransactionType(getInteger(95, 97));
        setUtrnno(getLong(98, 106));
        setReversalFlag(getInteger(107, 107));
        setAuthorizationUtrnno(getLong(108, 116));
        setPosDataCode(getString(117, 128));
        setRrn(getLong(129, 140));
        setTraceNumber(getLong(141, 146));
        setNetworkId(getInteger(147, 149));
        setAcqInstCode(getString(150, 153));
        setTransactionStatus(getString(154, 161));
        setAdditionalData(getString(162, 461));
        setEmvData(getString(462, 861));
        setServiceId(getString(862, 869));
    }
    private void parseVersion1() throws Exception {
        setVoucherNumber(getLong(21, 26));
        setCardNumber(getString(27, 50));
        setCardMemberNumber(getInteger(51, 51));
        setCardExpirationDate(getString(52, 55));
        setTransactionAmount(getLong(56, 67));
        setTransactionCurrency(getString(68, 70));
        setDebitCreditFlag(getString(71, 72));
        setTransactionDate(getString(73, 80));
        setTransactionTime(getString(81, 86));
        setAuthorizationCode(getString(87, 92));
        setTransactionType(getInteger(95, 97));
        setUtrnno(getLong(98, 109));
        setReversalFlag(getInteger(110, 110));
        setAuthorizationUtrnno(getLong(111, 122));
        setPosDataCode(getString(123, 134));
        setRrn(getLong(135, 146));
        setTraceNumber(getLong(147, 152));
        setNetworkId(getInteger(153, 155));
        setAcqInstCode(getString(156, 159));
        setTransactionStatus(getString(160, 167));
        setAdditionalData(getString(168, 467));
        setEmvData(getString(468, 867));
        setServiceId(getString(868, 875));
        setPaymentDetails(getString(899, 998));
        setServiceProviderIdentifier(getString(999, 1008));
        setUniquePaymentNumber(getString(1009, 1033));
        setAdditionalAmounts(getString(1034, 1333));
        setSvfeTraceNumber(getLong(1334, 1345));
    }
    private void parseVersion2() throws Exception {
        setVoucherNumber(getLong(21, 26));
        setCardNumber(getString(27, 50));
        setCardMemberNumber(getInteger(51, 53));
        setCardExpirationDate(getString(54, 57));
        setTransactionAmount(getLong(58, 69));
        setTransactionCurrency(getString(70, 72));
        setDebitCreditFlag(getString(73, 74));
        setTransactionDate(getString(75, 82));
        setTransactionTime(getString(83, 88));
        setAuthorizationCode(getString(89, 94));
        setTransactionType(getInteger(97, 99));
        setUtrnno(getLong(100, 111));
        setReversalFlag(getInteger(112, 112));
        setAuthorizationUtrnno(getLong(113, 124));
        setPosDataCode(getString(125, 136));
        setRrn(getLong(137, 148));
        setTraceNumber(getLong(149, 154));
        setNetworkId(getInteger(155, 157));
        setAcqInstCode(getString(158, 161));
        setTransactionStatus(getString(162, 169));
        setAdditionalData(getString(170, 469));
        setEmvData(getString(470, 869));
        setServiceId(getString(870, 877));
        setPaymentDetails(getString(901, 1000));
        setServiceProviderIdentifier(getString(1001, 1010));
        setUniquePaymentNumber(getString(1011, 1035));
        setAdditionalAmounts(getString(1036, 1335));
        setSvfeTraceNumber(getLong(1336, 1347));
    }
    private Map<String, Object> makeParams(Long blockId) {
        Map<String, Object> params = new HashMap<String, Object>();

        params.put("batch_block_id", blockId);
        params.put("record_type", super.getRecordType());
        params.put("record_number", super.getRecordNumber());
        params.put("voucher_number", getVoucherNumber() == null ? "" : getVoucherNumber());
        params.put("card_number", getCardNumber());
        params.put("card_member_number", getCardMemberNumber() == null ? "" : getCardMemberNumber());
        params.put("card_expir_date", getCardExpirationDate());
        params.put("trans_amount", getTransactionAmount() == null ? "" : getTransactionAmount());
        params.put("trans_currency", getTransactionCurrency());
        params.put("debit_credit", getDebitCreditFlag());
        params.put("trans_date", getTransactionDate());
        params.put("trans_time", getTransactionTime());
        params.put("auth_code", getAuthorizationCode());
        params.put("trans_type", getTransactionType() == null ? "" : getTransactionType());
        params.put("utrnno", getUtrnno() == null ? "" : getUtrnno());
        params.put("is_reversal", getReversalFlag() == null ? "" : getReversalFlag());
        params.put("auth_utrnno", getAuthorizationUtrnno() == null ? "" : getAuthorizationUtrnno());
        params.put("pos_data_code", getPosDataCode());
        params.put("retrieval_reference_number", getRrn() == null ? "" : getRrn());
        params.put("trace_number", getTraceNumber() == null ? "" : getTraceNumber());
        params.put("network_id", getNetworkId() == null ? "" : getNetworkId());
        params.put("acq_inst_id", getAcqInstCode());
        params.put("trans_status", getTransactionStatus());
        params.put("add_data", getAdditionalData());
        params.put("emv_data", getEmvData());
        params.put("service_id", getServiceId());

        if (super.getBatchVersion().equals("1.1") || super.getBatchVersion().equals("1.2") ) {
            params.put("payment_details", getPaymentDetails());
            params.put("service_provider_id", getServiceProviderIdentifier());
            params.put("unique_number_payment", getUniquePaymentNumber());
            params.put("add_amounts", getAdditionalAmounts());
            params.put("svfe_trace_number", getSvfeTraceNumber() == null ? "" : getSvfeTraceNumber());
        }

        return params;
    }

    public Long getVoucherNumber(){
        return voucherNumber;
    }
    public void setVoucherNumber( Long voucherNumber ){
        this.voucherNumber = voucherNumber;
    }

    public String getCardNumber(){
        return cardNumber;
    }
    public void setCardNumber( String cardNumber ){
        this.cardNumber = cardNumber;
    }

    public Integer getCardMemberNumber(){
        return cardMemberNumber;
    }
    public void setCardMemberNumber( Integer cardMemberNumber ){
        this.cardMemberNumber = cardMemberNumber;
    }

    public String getCardExpirationDate(){
        return cardExpirationDate;
    }
    public void setCardExpirationDate( String cardExpirationDate ){
        this.cardExpirationDate = cardExpirationDate;
    }

    public Long getTransactionAmount(){
        return transactionAmount;
    }
    public void setTransactionAmount( Long transactionAmount ){
        this.transactionAmount = transactionAmount;
    }

    public String getTransactionCurrency(){
        return transactionCurrency;
    }
    public void setTransactionCurrency( String transactionCurrency ){
        this.transactionCurrency = transactionCurrency;
    }

    public String getDebitCreditFlag(){
        return debitCreditFlag;
    }
    public void setDebitCreditFlag( String debitCreditFlag ){
        this.debitCreditFlag = debitCreditFlag;
    }

    public String getTransactionDate(){
        return transactionDate;
    }
    public void setTransactionDate( String transactionDate ){
        this.transactionDate = transactionDate;
    }

    public String getTransactionTime(){
        return transactionTime;
    }
    public void setTransactionTime( String transactionTime ){
        this.transactionTime = transactionTime;
    }

    public String getAuthorizationCode(){
        return authorizationCode;
    }
    public void setAuthorizationCode( String authorizationCode ){
        this.authorizationCode = authorizationCode;
    }

    public Integer getTransactionType(){
        return transactionType;
    }
    public void setTransactionType( Integer transactionType ){
        this.transactionType = transactionType;
    }

    public Long getUtrnno(){
        return utrnno;
    }
    public void setUtrnno( Long utrnno ){
        this.utrnno = utrnno;
    }

    public Integer getReversalFlag(){
        return reversalFlag;
    }
    public void setReversalFlag( Integer reversalFlag ){
        this.reversalFlag = reversalFlag;
    }

    public Long getAuthorizationUtrnno(){
        return authorizationUtrnno;
    }
    public void setAuthorizationUtrnno( Long authorizationUtrnno ){
        this.authorizationUtrnno = authorizationUtrnno;
    }

    public String getPosDataCode(){
        return posDataCode;
    }
    public void setPosDataCode( String posDataCode ){
        this.posDataCode = posDataCode;
    }

    public Long getRrn(){
        return rrn;
    }
    public void setRrn( Long rrn ){
        this.rrn = rrn;
    }

    public Long getTraceNumber(){
        return traceNumber;
    }
    public void setTraceNumber( Long traceNumber ){
        this.traceNumber = traceNumber;
    }

    public Integer getNetworkId(){
        return networkId;
    }
    public void setNetworkId( Integer networkId ){
        this.networkId = networkId;
    }

    public String getAcqInstCode(){
        return acqInstCode;
    }
    public void setAcqInstCode( String acqInstCode ){
        this.acqInstCode = acqInstCode;
    }

    public String getTransactionStatus(){
        return transactionStatus;
    }
    public void setTransactionStatus( String transactionStatus ){
        this.transactionStatus = transactionStatus;
    }

    public String getAdditionalData(){
        return additionalData;
    }
    public void setAdditionalData( String additionalData ){
        this.additionalData = additionalData;
    }

    public String getEmvData(){
        return emvData;
    }
    public void setEmvData( String emvData ){
        this.emvData = emvData;
    }

    public String getServiceId(){
        return serviceId;
    }
    public void setServiceId( String serviceId ){
        this.serviceId = serviceId;
    }

    public String getPaymentDetails(){
        return paymentDetails;
    }
    public void setPaymentDetails( String paymentDetails ){
        this.paymentDetails = paymentDetails;
    }

    public String getServiceProviderIdentifier(){
        return serviceProviderIdentifier;
    }
    public void setServiceProviderIdentifier( String serviceProviderIdentifier ){
        this.serviceProviderIdentifier = serviceProviderIdentifier;
    }

    public String getUniquePaymentNumber(){
        return uniquePaymentNumber;
    }
    public void setUniquePaymentNumber( String uniquePaymentNumber ){
        this.uniquePaymentNumber = uniquePaymentNumber;
    }

    public String getAdditionalAmounts(){
        return additionalAmounts;
    }
    public void setAdditionalAmounts( String additionalAmounts ){
        this.additionalAmounts = additionalAmounts;
    }

    public Long getSvfeTraceNumber(){
        return svfeTraceNumber;
    }
    public void setSvfeTraceNumber( Long svfeTraceNumber ){
        this.svfeTraceNumber = svfeTraceNumber;
    }

    @Override
    public Map<String, Object> get(Long fileId, Long blockId) throws Exception {
        return makeParams(blockId);
    }

    @Override
    public void saveAll(Connection connection, Long sessionId, List<Map<String, Object>> lines) throws Exception{
        super.batchDao.insertDetail(connection, lines);
    }

    @Override
    public void parse() throws Exception {
        if (raw == null || raw.isEmpty() || raw.getLengthInBlocks() < 32) {
            return;
        }
        super.setRecordType(TYPE);
        super.setRecordNumber(getLong(9, 20));
        if (super.getBatchVersion().equals("1.0")) {
            parseVersion0();
        } else if (super.getBatchVersion().equals("1.1")) {
            parseVersion1();
        } else if (super.getBatchVersion().equals("1.2")) {
            parseVersion2();
        } else {
            return;
        }
        return;
    }

    @Override
    public Long save(Connection connection, Long sessionId, Long fileId, Long blockId)
            throws Exception{
        return null;
    }
}
