create table aut_buffer#1 (
    id                          number(16)
    , split_hash                number(4)
    , source_id                 number(4)
    , original_auth_id          number(16) 
    , is_reversal               number(1)
    , msg_type                  varchar2(8)
    , oper_type                 varchar2(8)
    , resp_code                 varchar2(8)
    , status                    varchar2(8)
    , status_reason             varchar2(8) 
    , proc_type                 varchar2(8) 
    , proc_mode                 varchar2(8)
    , acq_inst_id               number(4)
    , acq_network_id            number(4)
    , terminal_type             varchar2(8)
    , cat_level                 varchar2(8)
    , acq_inst_bin              varchar2(12)
    , forw_inst_bin             varchar2(12)
    , merchant_id               number(8)
    , merchant_number           varchar2(15)
    , terminal_id               number(8)
    , terminal_number           varchar2(8)
    , merchant_name             varchar2(200)
    , merchant_street           varchar2(200)
    , merchant_city             varchar2(200)
    , merchant_region           varchar2(3)
    , merchant_country          varchar2(3)
    , merchant_postcode         varchar2(10)
    , mcc                       varchar2(4)
    , originator_refnum         varchar2(12)
    , network_refnum            varchar2(12)
    , card_data_input_cap       varchar2(8)
    , crdh_auth_cap             varchar2(8)
    , card_capture_cap          varchar2(8)
    , terminal_operating_env    varchar2(8)
    , crdh_presence             varchar2(8)
    , card_presence             varchar2(8)
    , card_data_input_mode      varchar2(8)
    , crdh_auth_method          varchar2(8)
    , crdh_auth_entity          varchar2(8)
    , card_data_output_cap      varchar2(8)
    , terminal_output_cap       varchar2(8)
    , pin_capture_cap           varchar2(8)
    , pin_presence              varchar2(8)
    , cvv2_presence             varchar2(8)
    , cvc_indicator             varchar2(8)
    , pos_entry_mode            varchar2(3)
    , pos_cond_code             varchar2(2)
    , payment_order_id          number(16)
    , payment_host_id           number(4)
    , emv_data                  varchar2(2000)
    , auth_code                 varchar2(6)
    , oper_request_amount       number(22, 4)
    , oper_amount               number(22, 4)
    , oper_currency             varchar2(3)
    , oper_cashback_amount      number(22, 4)
    , oper_replacement_amount   number(22, 4)
    , oper_surcharge_amount     number(22, 4)
    , oper_date                 date
    , host_date                 date
    , iss_inst_id               number(4)
    , iss_network_id            number(4)
    , card_mask                 varchar2(24)
    , card_hash                 number(12)
    , card_seq_number           number(3)
    , card_expir_date           date
    , card_service_code         varchar2(3)
    , account_type              varchar2(8)
    , account_number            varchar2(32)
    , account_amount            number(22, 4)
    , account_currency          varchar2(3)
    , bin_amount                number(22, 4)
    , bin_currency              varchar2(3)
    , network_amount            number(22, 4)
    , network_currency          varchar2(3)
    , network_cnvt_date         date
    , parent_id                 number(16)
)
/****************** partition start ********************
partition by list (split_hash)
(
    <partition_list>
)
******************** partition end ********************/
/    
comment on table aut_buffer#1 is 'Buffer for authorizations exchange'
/
comment on column aut_buffer#1.id is 'Record identifier'
/
comment on column aut_buffer#1.split_hash is 'Hash value to split further processing'
/
comment on column aut_buffer#1.source_id is 'Identifier of authorization source system'
/
comment on column aut_buffer#1.original_auth_id is 'Original authorization identifier (in case of reversal or completion) on the source system'
/
comment on column aut_buffer#1.is_reversal is 'Reversal indicator'
/
comment on column aut_buffer#1.msg_type is 'Message type (incl. completion indicator)'
/
comment on column aut_buffer#1.oper_type is 'Operation type (OPTP dictionary)'
/
comment on column aut_buffer#1.resp_code is 'Response code'
/
comment on column aut_buffer#1.status is 'Authorisation status (AUST dictionary)'
/
comment on column aut_buffer#1.status_reason is 'Authorisation status reason (AUSR dictionary)'
/
comment on column aut_buffer#1.proc_type is 'Type of authorisation processing (AUPT dictionary)'
/
comment on column aut_buffer#1.proc_mode is 'Mode of authorisation processing (AUPM dictionary)'
/
comment on column aut_buffer#1.acq_inst_id is 'Acquirer institution identifier'
/
comment on column aut_buffer#1.acq_network_id is 'Acquirer network identifier'
/
comment on column aut_buffer#1.terminal_type is 'Terminal type (TRMT dictionary)'
/
comment on column aut_buffer#1.cat_level is 'CAT level (CATL dictionary)'
/
comment on column aut_buffer#1.acq_inst_bin is 'Acquirer institution BIN'
/
comment on column aut_buffer#1.forw_inst_bin is 'Forwarding institution BIN'
/
comment on column aut_buffer#1.merchant_id is 'Merchant identifier'
/
comment on column aut_buffer#1.merchant_number is 'ISO Merchant number'
/
comment on column aut_buffer#1.terminal_id is 'Terminal identifier'
/
comment on column aut_buffer#1.terminal_number is 'ISO Terminal number'
/
comment on column aut_buffer#1.merchant_name is 'Merchant name'
/
comment on column aut_buffer#1.merchant_street is 'Merchant street'
/
comment on column aut_buffer#1.merchant_city is 'Merchant city'
/
comment on column aut_buffer#1.merchant_region is 'Merchant region'
/
comment on column aut_buffer#1.merchant_country is 'Merchant country'
/
comment on column aut_buffer#1.merchant_postcode is 'Merchant postal code'
/
comment on column aut_buffer#1.mcc is 'Merchant category code (MCC)'
/
comment on column aut_buffer#1.originator_refnum is 'Reference number'
/
comment on column aut_buffer#1.network_refnum is 'Network reference number'
/
comment on column aut_buffer#1.card_data_input_cap is 'Card data input capability'
/
comment on column aut_buffer#1.crdh_auth_cap is 'Cardholder authentication capability'
/
comment on column aut_buffer#1.card_capture_cap is 'Card capture capability'
/
comment on column aut_buffer#1.terminal_operating_env is 'Operating environment'
/
comment on column aut_buffer#1.crdh_presence is 'Cardholder presence indicator'
/
comment on column aut_buffer#1.card_presence is 'Card presence indicator'
/
comment on column aut_buffer#1.card_data_input_mode is 'Card data input mode'
/
comment on column aut_buffer#1.crdh_auth_method is 'Cardholder authentication method'
/
comment on column aut_buffer#1.crdh_auth_entity is 'Cardholder authentication entity'
/
comment on column aut_buffer#1.card_data_output_cap is 'Card data output capability'
/
comment on column aut_buffer#1.terminal_output_cap is 'Terminal output capability'
/
comment on column aut_buffer#1.pin_capture_cap is 'Pin capture capability'
/
comment on column aut_buffer#1.pin_presence is 'Pin presence indicator'
/
comment on column aut_buffer#1.cvv2_presence is 'CVC2/CVV2 presence indicator'
/
comment on column aut_buffer#1.cvc_indicator is 'CVC validation code result'
/
comment on column aut_buffer#1.pos_entry_mode is 'POS entry mode'
/
comment on column aut_buffer#1.pos_cond_code is 'POS condition code'
/
comment on column aut_buffer#1.payment_order_id is 'Reference to payment order.'
/
comment on column aut_buffer#1.payment_host_id is 'Host using as gateway to implement payment order.'
/
comment on column aut_buffer#1.emv_data is 'EMV raw data'
/
comment on column aut_buffer#1.auth_code is 'Authorisation code'
/
comment on column aut_buffer#1.oper_request_amount is 'Operation requested amount in operation currency'
/
comment on column aut_buffer#1.oper_amount is 'Operation amount  in operation currency'
/
comment on column aut_buffer#1.oper_currency is 'Operation currency'
/
comment on column aut_buffer#1.oper_cashback_amount is 'Cashback amount  in operation currency'
/
comment on column aut_buffer#1.oper_replacement_amount is 'Replacement amount  in operation currency (in case of reversal)'
/
comment on column aut_buffer#1.oper_surcharge_amount is 'Surcharge amount  in operation currency'
/
comment on column aut_buffer#1.oper_date is 'Operation date (local device date)'
/
comment on column aut_buffer#1.host_date is 'Source system date (host date)'
/
comment on column aut_buffer#1.iss_inst_id is 'Issuer institution identifier'
/
comment on column aut_buffer#1.iss_network_id is 'Issuer network identifier'
/
comment on column aut_buffer#1.card_mask is 'Card mask'
/
comment on column aut_buffer#1.card_hash is 'Card hash'
/
comment on column aut_buffer#1.card_seq_number is 'Card sequential number'
/
comment on column aut_buffer#1.card_expir_date is 'Card expiration date'
/
comment on column aut_buffer#1.card_service_code is 'Card service code'
/
comment on column aut_buffer#1.account_type is 'ISO account type involved in operation'
/
comment on column aut_buffer#1.account_number is 'Account number involved in operation'
/
comment on column aut_buffer#1.account_amount is 'Account billing amount in account currency'
/
comment on column aut_buffer#1.account_currency is 'Account currency'
/
comment on column aut_buffer#1.bin_amount is 'Account billing amount in BIN currency'
/
comment on column aut_buffer#1.bin_currency is 'BIN currency'
/
comment on column aut_buffer#1.network_amount is 'Account billing amount in network BIN currency'
/
comment on column aut_buffer#1.network_currency is 'Network BIN currency'
/
comment on column aut_buffer#1.network_cnvt_date is 'Date of network conversion'
/
comment on column aut_buffer#1.parent_id is 'Identifier of authorization which caused creation of this one'
/
alter table aut_buffer#1 modify (terminal_number varchar2(16))
/

