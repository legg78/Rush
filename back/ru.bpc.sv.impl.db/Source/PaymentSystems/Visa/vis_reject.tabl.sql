create table vis_reject
(
  id                    number(16)
  , dst_bin             varchar2(6)
  , src_bin             varchar2(6)
  , original_tc         varchar2(2)
  , original_tcq        varchar2(1)
  , original_tcr        varchar2(1)
  , src_batch_date      date
  , src_batch_number    varchar2(6)
  , item_seq_number     varchar2(4)
  , original_amount     number(22,4)
  , original_currency   varchar2(3)
  , original_sttl_flag  varchar2(1)
  , crs_return_flag     varchar2(1)
  , reason_code1        varchar2(4)
  , reason_code2        varchar2(4)
  , reason_code3        varchar2(4)
  , reason_code4        varchar2(4)
  , reason_code5        varchar2(4)
  , original_id         number(16)
  , file_id             number(16)
  , batch_id            number(12)
  , record_number       number(8)
  , reason_code6        varchar2(4)
  , reason_code7        varchar2(4)
  , reason_code8        varchar2(4)
  , reason_code9        varchar2(4)
  , reason_code10       varchar2(4)
)
/

comment on table vis_reject is 'Contains data from VISA Rejected Item Files and VISA clearing files for records TC Collection Batch Acknowledgment Transactions'
/
comment on column vis_reject.id is 'Primary key'
/
comment on column vis_reject.dst_bin is 'Destination BIN'
/
comment on column vis_reject.src_bin is 'Source BIN'
/
comment on column vis_reject.original_tc is 'Original Transaction Code (vis_fin_message.trans_code)'
/
comment on column vis_reject.original_tcq is 'Original Transaction Code Qualifier (vis_fin_message.trans_code_qualifier)'
/
comment on column vis_reject.original_tcr is 'Original Transaction Component Sequence Number (vis_fin_message.transaction_id)'
/
comment on column vis_reject.src_batch_date is 'Source Batch Date (YYDDD)'
/
comment on column vis_reject.src_batch_number is 'Source Batch Number'
/
comment on column vis_reject.item_seq_number is 'Item Sequence Number'
/
comment on column vis_reject.original_amount is 'Original Source Amount (vis_fin_message.oper_amount)'
/
comment on column vis_reject.original_currency is 'Original Source Currency (vis_fin_message.oper_currency)'
/
comment on column vis_reject.original_sttl_flag is 'Original Settlement Flag (vis_fin_message.settlement_flag)'
/
comment on column vis_reject.crs_return_flag is 'Chargeback Reduction Service (CRS) Return Flag'
/
comment on column vis_reject.reason_code1 is 'Return Reason Code 1'
/
comment on column vis_reject.reason_code2 is 'Return Reason Code 2'
/
comment on column vis_reject.reason_code3 is 'Return Reason Code 3'
/
comment on column vis_reject.reason_code4 is 'Return Reason Code 4'
/
comment on column vis_reject.reason_code5 is 'Return Reason Code 5'
/
comment on column vis_reject.original_id is 'Original operation id (vis_fin_message.id)'
/
comment on column vis_reject.file_id is 'Original clearing file id (vis_file.id)'
/
comment on column vis_reject.batch_id is 'Original batch_id in clearing file (vis_fin_message.batch_id)'
/
comment on column vis_reject.record_number is 'Number of record in clearing file'
/
comment on column vis_reject.reason_code6 is 'Return Reason Code 6'
/
comment on column vis_reject.reason_code7 is 'Return Reason Code 7'
/
comment on column vis_reject.reason_code8 is 'Return Reason Code 8'
/
comment on column vis_reject.reason_code9 is 'Return Reason Code 9'
/
comment on column vis_reject.reason_code10 is 'Return Reason Code 10'
/
