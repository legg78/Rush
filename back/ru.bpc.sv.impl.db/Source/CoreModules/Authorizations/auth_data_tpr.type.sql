create or replace type auth_data_tpr as object (
    oper_id                           number(16)
  , resp_code                         varchar2(8)
  , proc_type                         varchar2(8)
  , proc_mode                         varchar2(8)
  , is_advice                         number(1)
  , is_repeat                         number(1)
  , bin_amount                        number
  , bin_currency                      varchar(3)
  , bin_cnvt_rate                     number
  , network_amount                    number
  , network_currency                  varchar(3)
  , network_cnvt_date                 varchar2(20)
  , network_cnvt_rate                 number
  , account_cnvt_rate                 number
  , addr_verif_result                 varchar2(8)
  , acq_resp_code                     varchar2(8)
  , acq_device_proc_result            varchar2(8)
  , cat_level                         varchar2(8)
  , card_data_input_cap               varchar2(8)
  , crdh_auth_cap                     varchar2(8)
  , card_capture_cap                  varchar2(8)
  , terminal_operating_env            varchar2(8)
  , crdh_presence                     varchar2(8)
  , card_presence                     varchar2(8)
  , card_data_input_mode              varchar2(8)
  , crdh_auth_method                  varchar2(8)
  , crdh_auth_entity                  varchar2(8)
  , card_data_output_cap              varchar2(8)
  , terminal_output_cap               varchar2(8)
  , pin_capture_cap                   varchar2(8)
  , pin_presence                      varchar2(8)
  , cvv2_presence                     varchar2(8)
  , cvc_indicator                     varchar2(8)
  , pos_entry_mode                    varchar(3)
  , pos_cond_code                     varchar2(2)
  , emv_data                          varchar2(2000)
  , atc                               varchar2(4)
  , tvr                               varchar2(200)
  , cvr                               varchar2(200)
  , addl_data                         varchar2(2000)
  , service_code                      varchar(3)
  , device_date                       varchar2(20)
  , cvv2_result                       varchar2(8)
  , certificate_method                varchar2(8)
  , certificate_type                  varchar2(8)
  , merchant_certif                   varchar2(100)
  , cardholder_certif                 varchar2(100)
  , ucaf_indicator                    varchar2(8)
  , is_early_emv                      number(1)
  , is_completed                      varchar2(8)
  , amounts                           varchar2(4000)
  , system_trace_audit_number         varchar2(6)
  , transaction_id                    varchar2(15)
  , external_auth_id                  varchar2(30)
  , external_orig_id                  varchar2(30)
  , agent_unique_id                   varchar2(5)
  , native_resp_code                  varchar2(2)
  , trace_number                      varchar2(30)
  , auth_purpose_id                   number(16)
)
/