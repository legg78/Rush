create or replace type oper_clearing_tpr as object (
    oper_id                           number(16)
  , default_inst_id                   number(4)
  , oper_type                         varchar2(8)
  , msg_type                          varchar2(8)
  , sttl_type                         varchar2(8)
  , recon_type                        varchar2(8)
  , oper_date                         date
  , host_date                         date
  , oper_count                        number(16)
  , oper_amount_value                 number(22,4)
  , oper_amount_currency              varchar2(3)
  , oper_request_amount_value         number(22,4)
  , oper_request_amount_currency      varchar2(3)
  , oper_surcharge_amount_value       number(22,4)
  , oper_surcharge_amount_currency    varchar2(3)
  , oper_cashback_amount_value        number(22,4)
  , oper_cashback_amount_currency     varchar2(3)
  , sttl_amount_value                 number(22,4)
  , sttl_amount_currency              varchar2(3)
  , interchange_fee_value             number(22,4)
  , interchange_fee_currency          varchar2(3)
  , oper_reason                       varchar2(8)
  , status                            varchar2(8)
  , status_reason                     varchar2(8)
  , is_reversal                       number(1)
  , originator_refnum                 varchar2(36)
  , network_refnum                    varchar2(36)
  , acq_inst_bin                      number(12)
  , merchant_number                   varchar2(15)
  , mcc                               varchar2(4)
  , merchant_name                     varchar2(200)
  , merchant_street                   varchar2(200)
  , merchant_city                     varchar2(200)
  , merchant_region                   varchar2(3)
  , merchant_country                  varchar2(3)
  , merchant_postcode                 varchar2(10)
  , terminal_type                     varchar2(8)
  , terminal_number                   varchar2(16)
  , sttl_date                         date

  , external_auth_id                  varchar2(30)
  , external_orig_id                  varchar2(30)
  , trace_number                      varchar2(30)
  , dispute_id                        number(16)

  , payment_order_id                  number(16)
  , payment_order_status              varchar2(8)
  , payment_order_number              varchar2(200)
  , purpose_id                        number(8)
  , purpose_number                    varchar2(200)
  , payment_order_amount              number(22,4)
  , payment_order_currency            varchar2(3)
  , payment_order_prty_type           varchar2(8)
  , payment_parameters                xmltype

  , issuer_client_id_type             varchar2(8)
  , issuer_client_id_value            varchar2(200)
  , issuer_card_number                varchar2(24)
  , issuer_card_id                    number(12)
  , issuer_card_seq_number            number(4)
  , issuer_card_expir_date            date
  , issuer_inst_id                    number(4)
  , issuer_network_id                 number(4)
  , issuer_auth_code                  varchar2(6)
  , issuer_account_amount             number(22,4)
  , issuer_account_currency           varchar2(3)
  , issuer_account_number             varchar2(32)

  , acquirer_client_id_type           varchar2(8)
  , acquirer_client_id_value          varchar2(200)
  , acquirer_card_number              varchar2(24)
  , acquirer_card_seq_number          number(4)
  , acquirer_card_expir_date          date
  , acquirer_inst_id                  number(4)
  , acquirer_network_id               number(4)
  , acquirer_auth_code                varchar2(6)
  , acquirer_account_amount           number(22,4)
  , acquirer_account_currency         varchar2(3)
  , acquirer_account_number           varchar2(32)

  , destination_client_id_type        varchar2(8)
  , destination_client_id_value       varchar2(200)
  , destination_card_number           varchar2(24)
  , destination_card_id               number(12)
  , destination_card_seq_number       number(4)
  , destination_card_expir_date       date
  , destination_inst_id               number(4)
  , destination_network_id            number(4)
  , destination_auth_code             varchar2(6)
  , destination_account_amount        number(22,4)
  , destination_account_currency      varchar2(3)
  , destination_account_number        varchar2(32)

  , aggregator_client_id_type         varchar2(8)
  , aggregator_client_id_value        varchar2(200)
  , aggregator_card_number            varchar2(24)
  , aggregator_card_seq_number        number(4)
  , aggregator_card_expir_date        date
  , aggregator_inst_id                number(4)
  , aggregator_network_id             number(4)
  , aggregator_auth_code              varchar2(6)
  , aggregator_account_amount         number(22,4)
  , aggregator_account_currency       varchar2(3)
  , aggregator_account_number         varchar2(32)

  , srvp_client_id_type               varchar2(8)
  , srvp_client_id_value              varchar2(200)
  , srvp_card_number                  varchar2(24)
  , srvp_card_seq_number              number(4)
  , srvp_card_expir_date              date
  , srvp_inst_id                      number(4)
  , srvp_network_id                   number(4)
  , srvp_auth_code                    varchar2(6)
  , srvp_account_amount               number(22,4)
  , srvp_account_currency             varchar2(3)
  , srvp_account_number               varchar2(32)

  , participant                       xmltype

  , payment_order_exists              number(1)
  , issuer_exists                     number(1)
  , acquirer_exists                   number(1)
  , destination_exists                number(1)
  , aggregator_exists                 number(1)
  , service_provider_exists           number(1)
  , incom_sess_file_id                number(16)
  , note                              xmltype
  , auth_data                         xmltype
  , ipm_data                          xmltype
  , baseii_data                       xmltype
  , match_status                      varchar2(8)
  , additional_amount                 xmltype
  , processing_stage                  xmltype
)
/

alter type oper_clearing_tpr drop attribute payment_parameters invalidate
/
alter type oper_clearing_tpr add attribute payment_parameters clob invalidate
/

alter type oper_clearing_tpr drop attribute participant invalidate
/
alter type oper_clearing_tpr add attribute participant clob invalidate
/

alter type oper_clearing_tpr drop attribute note invalidate
/
alter type oper_clearing_tpr add attribute note clob invalidate
/

alter type oper_clearing_tpr drop attribute auth_data invalidate
/
alter type oper_clearing_tpr add attribute auth_data clob invalidate
/

alter type oper_clearing_tpr drop attribute ipm_data invalidate
/
alter type oper_clearing_tpr add attribute ipm_data clob invalidate
/

alter type oper_clearing_tpr drop attribute baseii_data invalidate
/
alter type oper_clearing_tpr add attribute baseii_data clob invalidate
/

alter type oper_clearing_tpr drop attribute additional_amount invalidate
/
alter type oper_clearing_tpr add attribute additional_amount clob invalidate
/

alter type oper_clearing_tpr drop attribute processing_stage invalidate
/
alter type oper_clearing_tpr add attribute processing_stage clob invalidate
/
alter type oper_clearing_tpr add attribute forw_inst_bin number(12) invalidate
/
alter type oper_clearing_tpr add attribute acq_sttl_date date invalidate
/
alter type oper_clearing_tpr add attribute flexible_data clob invalidate
/

alter type oper_clearing_tpr add attribute original_id number(12) invalidate
/
alter type oper_clearing_tpr add attribute response_code varchar2(8) invalidate
/
alter type oper_clearing_tpr add attribute issuer_prty_type varchar2(8) invalidate
/
alter type oper_clearing_tpr add attribute issuer_card_instance_id number(12) invalidate
/
alter type oper_clearing_tpr add attribute acquirer_prty_type varchar2(8) invalidate
/
alter type oper_clearing_tpr add attribute acquirer_card_id number(12) invalidate
/
alter type oper_clearing_tpr add attribute acquirer_card_instance_id number(12) invalidate
/
alter type oper_clearing_tpr add attribute destination_prty_type varchar2(8) invalidate
/
alter type oper_clearing_tpr add attribute destination_card_instance_id number(12) invalidate
/
alter type oper_clearing_tpr add attribute aggregator_prty_type varchar2(8) invalidate
/
alter type oper_clearing_tpr add attribute aggregator_card_id number(12) invalidate
/
alter type oper_clearing_tpr add attribute aggregator_card_instance_id number(12) invalidate
/
alter type oper_clearing_tpr add attribute srvp_prty_type varchar2(8) invalidate
/
alter type oper_clearing_tpr add attribute srvp_card_id number(12) invalidate
/
alter type oper_clearing_tpr add attribute srvp_card_instance_id number(12) invalidate
/

alter type oper_clearing_tpr drop attribute response_code invalidate
/
alter type oper_clearing_tpr add attribute oper_id_batch number(16) invalidate
/

alter type oper_clearing_tpr drop attribute forw_inst_bin invalidate
/
alter type oper_clearing_tpr add attribute forw_inst_bin varchar2(12) invalidate
/
