create table frp_auth (
    id                   number(16)
  , part_key             as (to_date(substr(lpad(to_char(id), 16, '0'), 1, 6), 'yymmdd')) virtual    -- [@skip patch]
  , msg_type             varchar2(8)
  , oper_type            varchar2(8)
  , resp_code            varchar2(8)
  , acq_inst_bin         varchar2(12)
  , merchant_number      varchar2(15)
  , merchant_country     varchar2(3)
  , merchant_city        varchar2(200)
  , merchant_street      varchar2(200)
  , mcc                  varchar2(4)
  , terminal_number      varchar2(8)
  , card_data_input_mode varchar2(8)
  , card_data_output_cap varchar2(8)
  , pin_presence         varchar2(8)
  , oper_amount          number(22 , 4)
  , oper_currency        varchar2(3)
  , oper_date            date
  , split_hash           number(4)
)
/****************** partition start ********************
partition by range (part_key) interval(numtoyminterval(1, 'MONTH'))                   -- [@skip patch]
subpartition by list (split_hash)                                                     -- [@skip patch]
subpartition template                                                                 -- [@skip patch]
(                                                                                     -- [@skip patch]
    <subpartition_list>                                                               -- [@skip patch]
)                                                                                     -- [@skip patch]
(                                                                                     -- [@skip patch]
    partition frp_auth_p01 values less than (to_date('01-01-2017','DD-MM-YYYY'))      -- [@skip patch]
)                                                                                     -- [@skip patch]
******************** partition end ********************/
/

comment on table frp_auth is 'Authorizations used in fraud prevention.'
/

comment on column frp_auth.id is 'Primary key. Authorization identifier.'
/
comment on column frp_auth.msg_type is 'Message type (MSGT dictionary)'
/
comment on column frp_auth.oper_type is 'Operation type (OPTP dictionary)'
/
comment on column frp_auth.resp_code is 'Response code'
/
comment on column frp_auth.acq_inst_bin is 'Acquirer institution BIN'
/
comment on column frp_auth.merchant_number is 'ISO Merchant number'
/
comment on column frp_auth.merchant_country is 'Merchant country'
/
comment on column frp_auth.merchant_city is 'Merchant city'
/
comment on column frp_auth.merchant_street is 'Merchant street'
/
comment on column frp_auth.mcc is 'Merchant category code (MCC)'
/
comment on column frp_auth.terminal_number is 'ISO Terminal number'
/
comment on column frp_auth.card_data_input_mode is 'Card data input mode'
/
comment on column frp_auth.card_data_output_cap is 'Card data output capability'
/
comment on column frp_auth.pin_presence is 'PIN presence indicator'
/
comment on column frp_auth.oper_amount is 'Operation amount in operation currency'
/
comment on column frp_auth.oper_currency is 'Operation currency'
/
comment on column frp_auth.oper_date is 'Operation date (local device date)'
/
comment on column frp_auth.split_hash is 'Hash value to split processing'
/
alter table frp_auth add (merchant_region  varchar2(3))
/
comment on column frp_auth.merchant_region is 'Merchant region'
/
alter table frp_auth modify (terminal_number varchar2(16))
/

