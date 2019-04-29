create table aut_auth (
    id                          number(16)
  , part_key                    as (to_date(substr(lpad(to_char(id), 16, '0'), 1, 6), 'yymmdd')) virtual -- [@skip patch]
  , resp_code                   varchar2(8)
  , proc_type                   varchar2(8)
  , proc_mode                   varchar2(8)
  , is_advice                   number(1)
  , is_repeat                   number(1)
  , is_completed                number(1)
  , bin_amount                  number(22,4)
  , bin_currency                varchar2(3)
  , bin_cnvt_rate               number(22,4)
  , network_amount              number(22,4)
  , network_currency            varchar2(3)
  , network_cnvt_date           date
  , network_cnvt_rate           number(22,4)
  , account_cnvt_rate           number(22,4)
  , parent_id                   number(16)
  , addr_verif_result           varchar2(8)
  , iss_network_device_id       number(8)
  , acq_device_id               number(8)
  , acq_resp_code               varchar2(8)
  , acq_device_proc_result      varchar2(8)
  , cat_level                   varchar2(8)
  , card_data_input_cap         varchar2(8)
  , crdh_auth_cap               varchar2(8)
  , card_capture_cap            varchar2(8)
  , terminal_operating_env      varchar2(8)
  , crdh_presence               varchar2(8)
  , card_presence               varchar2(8)
  , card_data_input_mode        varchar2(8)
  , crdh_auth_method            varchar2(8)
  , crdh_auth_entity            varchar2(8)
  , card_data_output_cap        varchar2(8)
  , terminal_output_cap         varchar2(8)
  , pin_capture_cap             varchar2(8)
  , pin_presence                varchar2(8)
  , cvv2_presence               varchar2(8)
  , cvc_indicator               varchar2(8)
  , pos_entry_mode              varchar2(3)
  , pos_cond_code               varchar2(2)
  , emv_data                    varchar2(2000)
  , atc                         varchar2(4)
  , tvr                         varchar2(200)
  , cvr                         varchar2(200)
  , addl_data                   varchar2(2000)
  , service_code                varchar2(3)
  , device_date                 date
  , cvv2_result                 varchar2(8)
  , certificate_method          varchar2(8)
  , certificate_type            varchar2(8)
  , merchant_certif             varchar2(100)
  , cardholder_certif           varchar2(100)
  , ucaf_indicator              varchar2(8)
  , is_early_emv                number(1)
)
/****************** partition start ********************
partition by range (part_key) interval(numtoyminterval(1, 'MONTH')) -- [@skip patch]
(
    partition aut_auth_p01 values less than (to_date('1-1-2017','DD-MM-YYYY'))   -- [@skip patch]
)
******************** partition end ********************/
/
comment on table aut_auth is 'Authorizations'
/
comment on column aut_auth.id is 'Record identifier'
/
comment on column aut_auth.parent_id is 'Identifier of authorization which caused creation of this one'
/
comment on column aut_auth.resp_code is 'Response code'
/
comment on column aut_auth.proc_type is 'Type of authorisation processing (AUPT dictionary)'
/
comment on column aut_auth.proc_mode is 'Mode of authorisation processing (AUPM dictionary)'
/
comment on column aut_auth.is_advice is 'Flag shows if authorization is advice.'
/
comment on column aut_auth.is_repeat is 'Flag shows if authorization is repeat.'
/
comment on column aut_auth.is_completed is 'Flag shows if authorization is completed.'
/
comment on column aut_auth.iss_network_device_id is 'Issuer network channel device identifier.'
/
comment on column aut_auth.account_cnvt_rate is 'Converting rate from account(billing) currency into transaction currency.'
/
comment on column aut_auth.bin_amount is 'Account billing amount in BIN currency'
/
comment on column aut_auth.bin_currency is 'BIN currency'
/
comment on column aut_auth.bin_cnvt_rate is 'Converting rate from BIN currency into transaction currency.'
/
comment on column aut_auth.network_amount is 'Account billing amount in network BIN currency'
/
comment on column aut_auth.network_currency is 'Network BIN currency'
/
comment on column aut_auth.network_cnvt_date is 'Date of network conversion'
/
comment on column aut_auth.network_cnvt_rate is 'Converting rate from network BIN currency into transaction currency.'
/
comment on column aut_auth.addr_verif_result is 'Result of address verification if it was performed.'
/
comment on column aut_auth.acq_device_id is 'Device of authorization origin'
/
comment on column aut_auth.acq_resp_code is 'Response code that was sent to authorization source'
/
comment on column aut_auth.acq_device_proc_result is 'Result of response processing by device'
/
comment on column aut_auth.cat_level is 'CAT level (CATL dictionary)'
/
comment on column aut_auth.card_data_input_cap is 'Card data input capability'
/
comment on column aut_auth.crdh_auth_cap is 'Cardholder authentication capability'
/
comment on column aut_auth.card_capture_cap is 'Card capture capability'
/
comment on column aut_auth.terminal_operating_env is 'Operating environment'
/
comment on column aut_auth.crdh_presence is 'Cardholder presence indicator'
/
comment on column aut_auth.card_presence is 'Card presence indicator'
/
comment on column aut_auth.card_data_input_mode is 'Card data input mode'
/
comment on column aut_auth.crdh_auth_method is 'Cardholder authentication method'
/
comment on column aut_auth.crdh_auth_entity is 'Cardholder authentication entity'
/
comment on column aut_auth.card_data_output_cap is 'Card data output capability'
/
comment on column aut_auth.terminal_output_cap is 'Terminal output capability'
/
comment on column aut_auth.pin_capture_cap is 'Pin capture capability'
/
comment on column aut_auth.pin_presence is 'Pin presence indicator'
/
comment on column aut_auth.cvv2_presence is 'CVC2/CVV2 presence indicator'
/
comment on column aut_auth.cvc_indicator is 'CVC validation code result'
/
comment on column aut_auth.pos_entry_mode is 'POS entry mode'
/
comment on column aut_auth.pos_cond_code is 'POS condition code'
/
comment on column aut_auth.addl_data is 'Additional authorization data.'
/
comment on column aut_auth.emv_data is 'EMV raw data'
/
comment on column aut_auth.atc is 'Application transaction counter'
/
comment on column aut_auth.tvr is 'Terminal verification results'
/
comment on column aut_auth.cvr is 'Card verification results'
/
comment on column aut_auth.service_code is 'Service code'
/
comment on column aut_auth.device_date is 'Date on device when authorization was recieved'
/
comment on column aut_auth.cvv2_result is 'CVV2 result (CV2R dictionary)'
/
comment on column aut_auth.certificate_method is 'Certificate method (CRTM dictionary - Secured, 3Ds, UCAF etc)'
/
comment on column aut_auth.certificate_type is 'Type of data encryption in E-Commerce transactions (CRTT dictionary)'
/
comment on column aut_auth.merchant_certif is 'Contains a value assigned to a VSEC merchant certificate issued by the acquirer''s certificate authority.'
/
comment on column aut_auth.cardholder_certif is 'Contains a value assigned to a VSEC cardholder certificate issued by the acquirer''s certificate authority.'
/
comment on column aut_auth.ucaf_indicator is 'Indicator of supporting UCAF data. This field indicate supporting MasterCard e-commerce Universal Cardholder Authentication data.'
/
comment on column aut_auth.is_early_emv is 'Early EMV option'
/
alter table aut_auth drop column is_completed
/
alter table aut_auth add is_completed varchar2(8)
/
comment on column aut_auth.is_completed is 'Flag shows if authorization is completed (CMPF key)'
/
alter table aut_auth add amounts varchar2(4000)
/
comment on column aut_auth.amounts is 'Authorization amounts for online authorization processing'
/
alter table aut_auth add (cavv_presence varchar2(8), aav_presence varchar2(8))
/
comment on column aut_auth.cavv_presence is 'CAVV presence indicator'
/
comment on column aut_auth.aav_presence is 'AAV presence indicator'
/
alter table aut_auth add (transaction_id varchar2(15))
/
comment on column aut_auth.transaction_id is 'Transaction Id'
/
alter table aut_auth add (system_trace_audit_number varchar2(6))
/
comment on column aut_auth.system_trace_audit_number is 'System Trace Audit Number'
/

alter table aut_auth add (external_auth_id varchar2(30))
/
comment on column aut_auth.external_auth_id is 'External authorization identifier from SVFE'
/
alter table aut_auth add (external_orig_id varchar2(30))
/
comment on column aut_auth.external_orig_id is 'External authorization identifier of original from SVFE'
/
comment on column aut_auth.external_auth_id is 'External authorization identifier'
/
comment on column aut_auth.external_orig_id is 'External authorization identifier of original'
/
alter table aut_auth add (agent_unique_id varchar2(5))
/
comment on column aut_auth.agent_unique_id is 'Agent Unique ID'
/
alter table aut_auth add (native_resp_code varchar2(2))
/
comment on column aut_auth.native_resp_code is 'Authorization response code in native format'
/
alter table aut_auth add (trace_number varchar2(30 char))
/
comment on column aut_auth.trace_number is 'External authorization identifier for first operation of online dispute'
/
alter table aut_auth add (auth_purpose_id number(16))
/
comment on column aut_auth.auth_purpose_id is 'Authorization purpose identifier is additional attribute of an operation that precises purpose of a payment. It does not have the same meaning as identifiers in table PMO_PURPOSE'
/
alter table aut_auth add (is_incremental number(1))
/
comment on column aut_auth.is_incremental is '1 - Transaction is incremental, 0 or absent - transaction is not incremental'
/
alter table aut_auth add (total_amount number(22,4))
/
comment on column aut_auth.total_amount is 'Total amount of Incremental Preauthorization Transactions'
/
alter table aut_auth drop column total_amount
/
