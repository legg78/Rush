create table vis_returned (
   id                 number(16)
 , dst_bin            varchar2(6)
 , src_bin            varchar2(6)
 , original_tc        varchar2(2)
 , original_tcq       varchar2(1)
 , original_tcr       varchar2(1)
 , src_batch_date     date
 , src_batch_number   varchar2(6)
 , item_seq_number    varchar2(4)
 , original_amount    number(22 , 4)
 , original_currency  varchar2(3)
 , original_sttl_flag varchar2(1)
 , crs_return_flag    varchar2(1)
 , reason_code1       varchar2(3)
 , reason_code2       varchar2(3)
 , reason_code3       varchar2(3)
 , reason_code4       varchar2(3)
 , reason_code5       varchar2(3)
 , original_id        number(16)
 , file_id            number(16)
 , batch_id           number(12)
 , record_number      number(8)
)
/
comment on column vis_returned.id is 'Primary key.'
/

comment on column vis_returned.dst_bin is 'Destination BIN'
/

comment on column vis_returned.src_bin is 'Source BIN'
/

comment on column vis_returned.original_tc is 'Original Transaction Code'
/

comment on column vis_returned.original_tcq is 'Original Transaction Code Qualifier'
/

comment on column vis_returned.original_tcr is 'Original Transaction Component Sequence Number'
/

comment on column vis_returned.src_batch_date is 'Source Batch Date (YYDDD)'
/

comment on column vis_returned.src_batch_number is 'Source Batch Number'
/

comment on column vis_returned.item_seq_number is 'Item Sequence Number'
/

comment on column vis_returned.original_amount is 'Original Source Amount'
/

comment on column vis_returned.original_currency is 'Original Source Currency'
/

comment on column vis_returned.original_sttl_flag is 'Original Settlement Flag'
/

comment on column vis_returned.crs_return_flag is 'Chargeback Reduction Service (CRS) Return Flag'
/

comment on column vis_returned.reason_code1 is 'Return Reason Code 1'
/

comment on column vis_returned.reason_code2 is 'Return Reason Code 2'
/

comment on column vis_returned.reason_code3 is 'Return Reason Code 3'
/

comment on column vis_returned.reason_code4 is 'Return Reason Code 4'
/

comment on column vis_returned.reason_code5 is 'Return Reason Code 5'
/

comment on column vis_returned.original_id is 'Identifier of original transaction.'
/

comment on column vis_returned.file_id is 'Reference to clearing file.'
/

comment on column vis_returned.batch_id is 'Identifier of batch  in clearing file.'
/

comment on column vis_returned.record_number is 'Number of record in clearing file.'
/
 