create or replace package h2h_api_type_pkg as

subtype t_inst_code is varchar2(11);
type t_inst_code_tab is table of t_inst_code index by binary_integer;

type t_h2h_tag_rec is record(
    tag_id                          com_api_type_pkg.t_short_id    -- reference to h2h_tag.id
  , fe_tag_id                       com_api_type_pkg.t_short_id    -- reference to h2h_tag.fe_tag_id
  , ips_field                       com_api_type_pkg.t_oracle_name -- associated IPS field (H2H_TAG.***_field)
  , position                        com_api_type_pkg.t_name        -- substring position (when IPS tag is used partially)
  , date_format                     com_api_type_pkg.t_oracle_name -- for the case when IPS field is present as a date
);
-- Associative array (map) of tags details indexed by tag name
type t_h2h_tag_tab is table of t_h2h_tag_rec index by com_api_type_pkg.t_oracle_name;

type t_h2h_tag_value_rec is record(
    id                              com_api_type_pkg.t_long_id
  , tag_id                          com_api_type_pkg.t_short_id
  , tag_name                        com_api_type_pkg.t_name
  , tag_value                       com_api_type_pkg.t_param_value
);
type t_h2h_tag_value_tab is table of t_h2h_tag_value_rec index by binary_integer;

type t_h2h_file_rec is record(
    id                              com_api_type_pkg.t_long_id
  , file_type                       com_api_type_pkg.t_dict_value
  , file_date                       date
  , session_file_id                 com_api_type_pkg.t_long_id
  , proc_date                       date
  , is_incoming                     com_api_type_pkg.t_boolean
  , is_rejected                     com_api_type_pkg.t_boolean
  , network_id                      com_api_type_pkg.t_network_id
  , inst_id                         com_api_type_pkg.t_inst_id
  , forw_inst_code                  t_inst_code
  , receiv_inst_code                t_inst_code
  , orig_file_id                    com_api_type_pkg.t_long_id
);
type t_h2h_file_tab is table of t_h2h_file_rec index by binary_integer;

type t_h2h_fin_message_rec is record(
    id                              com_api_type_pkg.t_long_id
  , split_hash                      com_api_type_pkg.t_tiny_id
  , status                          com_api_type_pkg.t_dict_value
  , inst_id                         com_api_type_pkg.t_inst_id
  , network_id                      com_api_type_pkg.t_network_id
  , forw_inst_code                  t_inst_code
  , receiv_inst_code                t_inst_code
  , file_id                         com_api_type_pkg.t_long_id
  , file_type                       com_api_type_pkg.t_dict_value
  , file_date                       date
  , is_incoming                     com_api_type_pkg.t_boolean
  , is_reversal                     com_api_type_pkg.t_boolean
  , is_collection_only              com_api_type_pkg.t_boolean
  , is_rejected                     com_api_type_pkg.t_boolean
  , reject_id                       com_api_type_pkg.t_long_id
  , dispute_id                      com_api_type_pkg.t_long_id
  , oper_type                       com_api_type_pkg.t_dict_value
  , msg_type                        com_api_type_pkg.t_dict_value
  , oper_date                       date
  , oper_amount_value               com_api_type_pkg.t_money
  , oper_amount_currency            com_api_type_pkg.t_curr_code
  , oper_surcharge_amount_value     com_api_type_pkg.t_money
  , oper_surcharge_amount_currency  com_api_type_pkg.t_curr_code
  , oper_cashback_amount_value      com_api_type_pkg.t_money
  , oper_cashback_amount_currency   com_api_type_pkg.t_curr_code
  , sttl_amount_value               com_api_type_pkg.t_money
  , sttl_amount_currency            com_api_type_pkg.t_curr_code
  , sttl_rate                       number
  , crdh_bill_amount_value          com_api_type_pkg.t_money
  , crdh_bill_amount_currency       com_api_type_pkg.t_curr_code
  , crdh_bill_rate                  number
  , acq_inst_bin                    com_api_type_pkg.t_bin
  , arn                             com_api_type_pkg.t_arn
  , merchant_number                 com_api_type_pkg.t_merchant_number
  , mcc                             com_api_type_pkg.t_mcc
  , merchant_name                   com_api_type_pkg.t_name
  , merchant_street                 com_api_type_pkg.t_name
  , merchant_city                   com_api_type_pkg.t_name
  , merchant_region                 com_api_type_pkg.t_country_code
  , merchant_country                com_api_type_pkg.t_country_code
  , merchant_postcode               com_api_type_pkg.t_postal_code
  , terminal_type                   com_api_type_pkg.t_dict_value
  , terminal_number                 com_api_type_pkg.t_terminal_number
  , card_number                     com_api_type_pkg.t_card_number
  , card_seq_num                    com_api_type_pkg.t_seqnum
  , card_expiry                     date
  , service_code                    varchar2(3)
  , approval_code                   com_api_type_pkg.t_auth_code
  , rrn                             com_api_type_pkg.t_rrn
  , trn                             com_api_type_pkg.t_rrn
  , oper_id                         com_api_type_pkg.t_uuid
  , original_id                     com_api_type_pkg.t_uuid
  , emv_5f2a                        number(4)
  , emv_5f34                        number(4)
  , emv_71                          varchar2(16)
  , emv_72                          varchar2(16)
  , emv_82                          varchar2(8)
  , emv_84                          varchar2(32)
  , emv_8a                          varchar2(32)
  , emv_91                          varchar2(32)
  , emv_95                          varchar2(10)
  , emv_9a                          number(6)
  , emv_9c                          number(2)
  , emv_9f02                        number(12)
  , emv_9f03                        number(12)
  , emv_9f06                        varchar2(64)
  , emv_9f09                        varchar2(4)
  , emv_9f10                        varchar2(64)
  , emv_9f18                        varchar2(8)
  , emv_9f1a                        number(4)
  , emv_9f1e                        varchar2(16)
  , emv_9f26                        varchar2(16)
  , emv_9f27                        varchar2(2)
  , emv_9f28                        varchar2(16)
  , emv_9f29                        varchar2(16)
  , emv_9f33                        varchar2(6)
  , emv_9f34                        varchar2(6)
  , emv_9f35                        number(2)
  , emv_9f36                        varchar2(32)
  , emv_9f37                        varchar2(32)
  , emv_9f41                        number(8)
  , emv_9f53                        varchar2(32)
  , pdc_1                           varchar2(1)
  , pdc_2                           varchar2(1)
  , pdc_3                           varchar2(1)
  , pdc_4                           varchar2(1)
  , pdc_5                           varchar2(1)
  , pdc_6                           varchar2(1)
  , pdc_7                           varchar2(1)
  , pdc_8                           varchar2(1)
  , pdc_9                           varchar2(1)
  , pdc_10                          varchar2(1)
  , pdc_11                          varchar2(1)
  , pdc_12                          varchar2(1)
);
type t_h2h_fin_message_tab is table of t_h2h_fin_message_rec index by binary_integer;

type t_h2h_flex_clearing_rec is record(
    field_name                      com_api_type_pkg.t_name
  , field_value                     com_api_type_pkg.t_name
);
type t_h2h_flex_clearing_tab is table of t_h2h_flex_clearing_rec index by binary_integer;

-- Data types to load incoming clearing
type t_h2h_clearing_rec is record(
    id                              com_api_type_pkg.t_long_id
  , split_hash                      com_api_type_pkg.t_tiny_id
  , status                          com_api_type_pkg.t_dict_value
  , inst_id                         com_api_type_pkg.t_inst_id
  , network_id                      com_api_type_pkg.t_network_id
  , forw_inst_code                  t_inst_code
  , receiv_inst_code                t_inst_code
  , file_id                         com_api_type_pkg.t_long_id
  , file_type                       com_api_type_pkg.t_dict_value
  , file_date                       date
  , is_incoming                     com_api_type_pkg.t_boolean
  , is_reversal                     com_api_type_pkg.t_boolean
  , is_collection_only              com_api_type_pkg.t_boolean
  , is_rejected                     com_api_type_pkg.t_boolean
  , reject_id                       com_api_type_pkg.t_long_id
  , dispute_id                      com_api_type_pkg.t_long_id
  , oper_type                       com_api_type_pkg.t_dict_value
  , msg_type                        com_api_type_pkg.t_dict_value
  , oper_date                       date
  , oper_amount_value               com_api_type_pkg.t_money
  , oper_amount_currency            com_api_type_pkg.t_curr_code
  , oper_surcharge_amount_value     com_api_type_pkg.t_money
  , oper_surcharge_amount_currency  com_api_type_pkg.t_curr_code
  , oper_cashback_amount_value      com_api_type_pkg.t_money
  , oper_cashback_amount_currency   com_api_type_pkg.t_curr_code
  , sttl_amount_value               com_api_type_pkg.t_money
  , sttl_amount_currency            com_api_type_pkg.t_curr_code
  , sttl_rate                       number
  , crdh_bill_amount_value          com_api_type_pkg.t_money
  , crdh_bill_amount_currency       com_api_type_pkg.t_curr_code
  , crdh_bill_rate                  number
  , acq_inst_bin                    com_api_type_pkg.t_bin
  , arn                             com_api_type_pkg.t_arn
  , merchant_number                 com_api_type_pkg.t_merchant_number
  , mcc                             com_api_type_pkg.t_mcc
  , merchant_name                   com_api_type_pkg.t_name
  , merchant_street                 com_api_type_pkg.t_name
  , merchant_city                   com_api_type_pkg.t_name
  , merchant_region                 com_api_type_pkg.t_country_code
  , merchant_country                com_api_type_pkg.t_country_code
  , merchant_postcode               com_api_type_pkg.t_postal_code
  , terminal_type                   com_api_type_pkg.t_dict_value
  , terminal_number                 com_api_type_pkg.t_terminal_number
  , card_number                     com_api_type_pkg.t_card_number
  , card_seq_num                    com_api_type_pkg.t_seqnum
  , card_expiry                     date
  , service_code                    varchar2(3)
  , approval_code                   com_api_type_pkg.t_auth_code
  , rrn                             com_api_type_pkg.t_rrn
  , trn                             com_api_type_pkg.t_rrn
  , oper_id                         com_api_type_pkg.t_uuid
  , original_id                     com_api_type_pkg.t_uuid
  , emv_5f2a                        number(4)
  , emv_5f34                        number(4)
  , emv_71                          varchar2(16)
  , emv_72                          varchar2(16)
  , emv_82                          varchar2(8)
  , emv_84                          varchar2(32)
  , emv_8a                          varchar2(32)
  , emv_91                          varchar2(32)
  , emv_95                          varchar2(10)
  , emv_9a                          number(6)
  , emv_9c                          number(2)
  , emv_9f02                        number(12)
  , emv_9f03                        number(12)
  , emv_9f06                        varchar2(64)
  , emv_9f09                        varchar2(4)
  , emv_9f10                        varchar2(64)
  , emv_9f18                        varchar2(8)
  , emv_9f1a                        number(4)
  , emv_9f1e                        varchar2(16)
  , emv_9f26                        varchar2(16)
  , emv_9f27                        varchar2(2)
  , emv_9f28                        varchar2(16)
  , emv_9f29                        varchar2(16)
  , emv_9f33                        varchar2(6)
  , emv_9f34                        varchar2(6)
  , emv_9f35                        number(2)
  , emv_9f36                        varchar2(32)
  , emv_9f37                        varchar2(32)
  , emv_9f41                        number(8)
  , emv_9f53                        varchar2(32)
  , pdc_1                           varchar2(1)
  , pdc_2                           varchar2(1)
  , pdc_3                           varchar2(1)
  , pdc_4                           varchar2(1)
  , pdc_5                           varchar2(1)
  , pdc_6                           varchar2(1)
  , pdc_7                           varchar2(1)
  , pdc_8                           varchar2(1)
  , pdc_9                           varchar2(1)
  , pdc_10                          varchar2(1)
  , pdc_11                          varchar2(1)
  , pdc_12                          varchar2(1)
  , tags                            xmltype
  , flexible_fields                 xmltype
);
type t_h2h_clearing_tab is table of t_h2h_clearing_rec index by binary_integer;

end;
/
