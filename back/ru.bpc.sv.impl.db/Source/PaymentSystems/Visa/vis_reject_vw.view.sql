create or replace force view vis_reject_vw as
select
    id
    , dst_bin
    , src_bin
    , original_tc
    , original_tcq
    , original_tcr
    , src_batch_date
    , src_batch_number
    , item_seq_number
    , original_amount
    , original_currency
    , original_sttl_flag
    , crs_return_flag
    , reason_code1
    , reason_code2
    , reason_code3
    , reason_code4
    , reason_code5
    , original_id
    , file_id
    , batch_id
    , record_number
    , reason_code6
    , reason_code7
    , reason_code8
    , reason_code9
    , reason_code10
from vis_reject
/
 