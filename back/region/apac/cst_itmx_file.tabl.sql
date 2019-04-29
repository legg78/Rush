create table cst_itmx_file
(
    id                  number(16)
  , part_key            as (to_date(substr(lpad(to_char(id), 16, '0'), 1, 6), 'yymmdd'))
  , is_incoming         number(1)
  , is_returned         number(1)
  , network_id          number(4)
  , proc_bin            varchar2(6)
  , proc_date           date
  , sttl_date           date
  , release_number      varchar2(3)
  , test_option         varchar2(4)
  , security_code       varchar2(8)
  , itmx_file_id        varchar2(3)
  , batch_total         number(8)
  , monetary_total      number(8)
  , tcr_total           number(8)
  , trans_total         number(8)
  , src_amount          number(22,4)
  , dst_amount          number(22,4)
  , inst_id             number(4)
  , session_file_id     number(16)
  , is_rejected         number(1)
)
/****************** partition start ********************
partition by range (part_key) interval(numtoyminterval(1, 'MONTH'))
(
    partition cst_itmx_file_p01 values less than (to_date('1-1-2017','DD-MM-YYYY'))
)
******************** partition end ********************/
/

comment on table cst_itmx_file is 'ITMX clearing files'
/
comment on column cst_itmx_file.id is 'Primary key'
/
comment on column cst_itmx_file.is_incoming is 'Incoming flag'
/
comment on column cst_itmx_file.is_returned is 'Returned message flag'
/
comment on column cst_itmx_file.network_id is 'Network identifier'
/
comment on column cst_itmx_file.proc_bin is 'Processing BIN'
/
comment on column cst_itmx_file.proc_date is 'Processing date'
/
comment on column cst_itmx_file.sttl_date is 'Settlement date'
/
comment on column cst_itmx_file.release_number is 'Release number'
/
comment on column cst_itmx_file.test_option is 'Test option'
/
comment on column cst_itmx_file.security_code is 'Security code'
/
comment on column cst_itmx_file.itmx_file_id is 'ITMX file identifier'
/
comment on column cst_itmx_file.batch_total is 'Total batches in file'
/
comment on column cst_itmx_file.monetary_total is 'Number of monetary transactions'
/
comment on column cst_itmx_file.tcr_total is 'Number of TCRs'
/
comment on column cst_itmx_file.trans_total is 'Number of transactions'
/
comment on column cst_itmx_file.src_amount is 'Source amount'
/
comment on column cst_itmx_file.dst_amount is 'Destination amount'
/
comment on column cst_itmx_file.inst_id is 'Institution identifier'
/
comment on column cst_itmx_file.session_file_id is 'File object identifier(prc_session_file.id)'
/
comment on column cst_itmx_file.is_rejected is 'Rejected message flag'
/
