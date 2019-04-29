create table bgn_retrieval (
    id                      number(16)
  , part_key                as (to_date(substr(lpad(to_char(id), 16, '0'), 1, 6), 'yymmdd')) virtual  -- [@skip patch]
  , file_id                 number(16)
  , record_type             varchar2(2)
  , record_number           number(6)
  , sender_code             varchar2(5)
  , receiver_code           varchar2(5)
  , file_number             number(3)
  , test_option             varchar2(1)
  , creation_date           date
  , original_file_id        number(16)
  , transaction_number      number(20)
  , original_fin_id         number(16)
  , sttl_amount             number(18)
  , interbank_fee_amount    number(18)
  , bank_card_id            number(5)
  , error_code              number(3)
)
/****************** partition start ********************                                 -- [@skip patch]
partition by range (part_key) interval(numtoyminterval(1, 'MONTH'))                      -- [@skip patch]
(                                                                                        -- [@skip patch]
    partition bgn_retrieval_p01 values less than (to_date('1-1-2017','DD-MM-YYYY'))      -- [@skip patch]
)                                                                                        -- [@skip patch]
******************** partition end ********************/
/

comment on table bgn_retrieval is 'Borica''s answers'
/

comment on column bgn_retrieval.id is 'Primary key'
/
comment on column bgn_retrieval.file_id is 'Income file identificator'
/
comment on column bgn_retrieval.record_type is 'Record type'
/
comment on column bgn_retrieval.record_number is 'Record sequence number'
/
comment on column bgn_retrieval.sender_code is 'File sender code'
/
comment on column bgn_retrieval.receiver_code is 'File receiver code'
/
comment on column bgn_retrieval.file_number is 'Original file sequence number due day'
/
comment on column bgn_retrieval.test_option is 'Test or real file'
/
comment on column bgn_retrieval.creation_date is 'Original file creation date'
/
comment on column bgn_retrieval.original_file_id is 'Original file identificator'
/
comment on column bgn_retrieval.transaction_number is 'Original transaction number'
/
comment on column bgn_retrieval.original_fin_id is 'Original fin message id'
/
comment on column bgn_retrieval.sttl_amount is 'Settlement amount'
/
comment on column bgn_retrieval.interbank_fee_amount is 'Interbank fee amount'
/
comment on column bgn_retrieval.bank_card_id is 'Bank card id'
/
comment on column bgn_retrieval.error_code is 'Error code'
/
alter table bgn_retrieval add (is_invalid number(1))
/
comment on column bgn_retrieval.is_invalid is 'Is record invalid'
/
