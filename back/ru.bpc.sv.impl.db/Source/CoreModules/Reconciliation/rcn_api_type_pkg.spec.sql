create or replace package rcn_api_type_pkg is

subtype t_service_code              is varchar2(12 char);
subtype t_approval_code             is varchar2(24 char);
subtype t_tag_16                    is varchar2(16 char);
subtype t_tag_24                    is varchar2(24 char);
subtype t_tag_32                    is varchar2(32 char);
subtype t_tag_64                    is varchar2(64 char);
subtype t_tag_128                   is varchar2(128 char);
subtype t_tag_256                   is varchar2(256 char);

type t_rcn_host_msg_rec is record(
    id                              com_api_type_pkg.t_long_id
  , recon_type                      com_api_type_pkg.t_dict_value
  , msg_source                      com_api_type_pkg.t_dict_value
  , msg_date                        date
  , oper_id                         com_api_type_pkg.t_long_id
  , recon_msg_id                    com_api_type_pkg.t_long_id
  , recon_status                    com_api_type_pkg.t_dict_value
  , recon_date                      date
  , recon_inst_id                   com_api_type_pkg.t_tiny_id
  , oper_type                       com_api_type_pkg.t_dict_value
  , msg_type                        com_api_type_pkg.t_dict_value
  , host_date                       date
  , oper_date                       date
  , oper_amount                     com_api_type_pkg.t_money
  , oper_currency                   com_api_type_pkg.t_curr_code
  , oper_surcharge_amount           com_api_type_pkg.t_money
  , oper_surcharge_currency         com_api_type_pkg.t_curr_code
  , originator_refnum               com_api_type_pkg.t_rrn
  , status                          com_api_type_pkg.t_dict_value
  , is_reversal                     com_api_type_pkg.t_boolean
  , merchant_number                 com_api_type_pkg.t_merchant_number
  , mcc                             com_api_type_pkg.t_mcc
  , merchant_name                   com_api_type_pkg.t_name
  , merchant_street                 com_api_type_pkg.t_name
  , merchant_city                   com_api_type_pkg.t_name
  , merchant_region                 com_api_type_pkg.t_region_code
  , merchant_country                com_api_type_pkg.t_country_code
  , merchant_postcode               com_api_type_pkg.t_postal_code
  , terminal_type                   com_api_type_pkg.t_dict_value
  , terminal_number                 com_api_type_pkg.t_terminal_number
  , acq_inst_id                     com_api_type_pkg.t_tiny_id
  , card_mask                       com_api_type_pkg.t_card_number
  , card_seq_number                 com_api_type_pkg.t_byte_id
  , card_expir_date                 date
  , auth_code                       com_api_type_pkg.t_auth_code
  , oper_cashback_amount            com_api_type_pkg.t_money
  , oper_cashback_currency          com_api_type_pkg.t_curr_code
  , service_code                    t_service_code
  , approval_code                   t_approval_code
  , rrn                             com_api_type_pkg.t_rrn
  , trn                             t_tag_64
  , original_id                     varchar2(120 char)
  , emv_5f2a                        com_api_type_pkg.t_money
  , emv_5f34                        com_api_type_pkg.t_money
  , emv_71                          t_tag_64
  , emv_72                          t_tag_64
  , emv_82                          t_tag_32
  , emv_84                          t_tag_128
  , emv_8a                          t_tag_128
  , emv_91                          t_tag_128
  , emv_95                          varchar2(40 char)
  , emv_9a                          number(22, 6)
  , emv_9c                          number(22, 2)
  , emv_9f02                        number(22, 12)
  , emv_9f03                        number(22, 12)
  , emv_9f06                        t_tag_256
  , emv_9f09                        t_tag_16
  , emv_9f10                        t_tag_256
  , emv_9f18                        t_tag_32
  , emv_9f1a                        com_api_type_pkg.t_money
  , emv_9f1e                        t_tag_64
  , emv_9f26                        t_tag_64
  , emv_9f27                        com_api_type_pkg.t_dict_value
  , emv_9f28                        t_tag_64
  , emv_9f29                        t_tag_64
  , emv_9f33                        t_tag_24
  , emv_9f34                        t_tag_24
  , emv_9f35                        number(22, 2)
  , emv_9f36                        t_tag_128
  , emv_9f37                        t_tag_128
  , emv_9f41                        number(22, 8)
  , emv_9f53                        t_tag_128
  , pdc_1                           t_tag_32
  , pdc_2                           t_tag_32
  , pdc_3                           t_tag_32
  , pdc_4                           t_tag_32
  , pdc_5                           t_tag_32
  , pdc_6                           t_tag_32
  , pdc_7                           t_tag_32
  , pdc_8                           t_tag_32
  , pdc_9                           t_tag_32
  , pdc_10                          t_tag_32
  , pdc_11                          t_tag_32
  , pdc_12                          t_tag_32
  , forw_inst_code                  com_api_type_pkg.t_cmid
  , receiv_inst_code                com_api_type_pkg.t_cmid
  , sttl_date                       date
  , oper_reason                     com_api_type_pkg.t_dict_value
);

type t_rcn_host_msg_tab is table of t_rcn_host_msg_rec index by binary_integer;

end rcn_api_type_pkg;
/
