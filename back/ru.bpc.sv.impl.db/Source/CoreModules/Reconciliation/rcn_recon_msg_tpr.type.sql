create or replace type rcn_recon_msg_tpr as object (
    oper_type                           varchar2(8)
  , msg_type                            varchar2(8)
  , sttl_type                           varchar2(8)
  , oper_date                           date
  , oper_amount                         number(22, 4)
  , oper_currency                       varchar2(3)
  , oper_request_amount                 number(22, 4)
  , oper_request_currency               varchar2(3)
  , oper_surcharge_amount               number(22, 4)
  , oper_surcharge_currency             varchar2(3)
  , originator_refnum                   varchar2(36)
  , network_refnum                      varchar2(36)
  , acq_inst_bin                        varchar2(36)
  , status                              varchar2(8)
  , is_reversal                         number(1)
  , mcc                                 varchar2(4)
  , merchant_number                     varchar2(15)
  , merchant_name                       varchar2(200)
  , merchant_street                     varchar2(200)
  , merchant_city                       varchar2(200)
  , merchant_region                     varchar2(200)
  , merchant_country                    varchar2(3)
  , merchant_postcode                   varchar2(200)
  , terminal_type                       varchar2(8)
  , terminal_number                     varchar2(16)
  , card_number                         varchar2(24)
  , card_seq_number                     number(4)
  , card_expir_date                     date
  , card_country                        varchar2(3)
  , acq_inst_id                         number(4)
  , iss_inst_id                         number(4)
  , auth_code                           varchar2(6)
)
/

drop type rcn_recon_msg_tpr force
/

create or replace type rcn_recon_msg_tpr as object (
    oper_type                           varchar2(8)
  , msg_type                            varchar2(8)
  , sttl_type                           varchar2(8)
  , oper_date                           date
  , oper_amount                         number(22, 4)
  , oper_currency                       varchar2(3)
  , oper_request_amount                 number(22, 4)
  , oper_request_currency               varchar2(3)
  , oper_surcharge_amount               number(22, 4)
  , oper_surcharge_currency             varchar2(3)
  , originator_refnum                   varchar2(36)
  , network_refnum                      varchar2(36)
  , acq_inst_bin                        varchar2(36)
  , status                              varchar2(8)
  , is_reversal                         number(1)
  , mcc                                 varchar2(4)
  , merchant_number                     varchar2(15)
  , merchant_name                       varchar2(200)
  , merchant_street                     varchar2(200)
  , merchant_city                       varchar2(200)
  , merchant_region                     varchar2(200)
  , merchant_country                    varchar2(3)
  , merchant_postcode                   varchar2(200)
  , terminal_type                       varchar2(8)
  , terminal_number                     varchar2(16)
  , card_number                         varchar2(24)
  , card_seq_number                     number(4)
  , card_expir_date                     date
  , card_country                        varchar2(3)
  , acq_inst_id                         number(4)
  , iss_inst_id                         number(4)
  , auth_code                           varchar2(6)
  , additional_amount                   rcn_additional_amount_tpt
)
/
