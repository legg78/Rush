package ru.bpc.sv2.constants.schedule;

public class PosBatchSqlRequests {
    public static final String DETAIL_INSERT = "insert into pos_batch_detail( id" +
                                                                           ", batch_block_id" +
                                                                           ", record_type" +
                                                                           ", record_number" +
                                                                           ", voucher_number" +
                                                                           ", card_number" +
                                                                           ", card_member_number" +
                                                                           ", card_expir_date" +
                                                                           ", trans_amount" +
                                                                           ", trans_currency" +
                                                                           ", debit_credit" +
                                                                           ", trans_date" +
                                                                           ", trans_time" +
                                                                           ", auth_code" +
                                                                           ", trans_type" +
                                                                           ", utrnno" +
                                                                           ", is_reversal" +
                                                                           ", auth_utrnno" +
                                                                           ", pos_data_code" +
                                                                           ", retrieval_reference_number" +
                                                                           ", trace_number" +
                                                                           ", network_id" +
                                                                           ", acq_inst_id" +
                                                                           ", trans_status" +
                                                                           ", add_data" +
                                                                           ", emv_data" +
                                                                           ", service_id" +
                                                                           ", payment_details" +
                                                                           ", service_provider_id" +
                                                                           ", unique_number_payment" +
                                                                           ", add_amounts" +
                                                                           ", svfe_trace_number ) " +
                                                                     "values( ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, " +
                                                                             "?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, " +
                                                                             "?, ?, ?, ?, ?, ? )";

    public static final String FILE_SEQ = "select pos_batch_file_seq.nextval from dual";

    public static final String FILE_INSERT = "insert into pos_batch_file( id" +
                                                                       ", session_id" +
                                                                       ", proc_date" +
                                                                       ", file_type" +
                                                                       ", header_record_type" +
                                                                       ", header_record_number" +
                                                                       ", inst_id" +
                                                                       ", creation_date" +
                                                                       ", creation_time" +
                                                                       ", batch_version ) " +
                                                                 "values( ?, ?" +
                                                                       ", to_date(?, 'YYYY-MM-DD HH24:MI:SS')" +
                                                                       ", ?, ?, ?, ?, ?, ?, ? )";

    public static final String FILE_UPDATE = "update pos_batch_file " +
                                             "set trailer_record_type = ?" +
                                               ", trailer_record_number = ?" +
                                               ", total_batch_number = ? " +
                                             "where id = ?";

    public static final String BLOCK_SEQ = "select pos_batch_block_seq.nextval from dual";

    public static final String BLOCK_INSERT = "insert into pos_batch_block( id" +
                                                                         ", batch_file_id" +
                                                                         ", header_record_type" +
                                                                         ", header_record_number" +
                                                                         ", header_batch_reference" +
                                                                         ", creation_date" +
                                                                         ", creation_time" +
                                                                         ", header_batch_amount" +
                                                                         ", header_debit_credit" +
                                                                         ", header_merchant_id" +
                                                                         ", header_terminal_id" +
                                                                         ", mcc )" +
                                                                   "values( ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ? )";

    public static final String BLOCK_UPDATE = "update pos_batch_block " +
                                              "set trailer_record_type = ?" +
                                                ", trailer_record_number = ?" +
                                                ", trailer_batch_reference = ?" +
                                                ", trailer_merchant_id = ?" +
                                                ", trailer_terminal_id = ?" +
                                                ", trailer_batch_amount = ?" +
                                                ", trailer_debit_credit = ?" +
                                                ", number_records = ? " +
                                              "where id = ?";

    public static final String GET_ID_BEGIN = "{ ? = call opr_api_create_pkg.get_id( i_shift => ";
    public static final String GET_ID_END = " ) }";
}
