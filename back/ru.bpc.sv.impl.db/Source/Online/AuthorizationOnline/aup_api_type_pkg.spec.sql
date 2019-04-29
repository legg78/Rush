create or replace package aup_api_type_pkg is

type t_auth_stmt_rec is record (
    auth_id               com_api_type_pkg.t_long_id
  , card_id               com_api_type_pkg.t_medium_id
  , oper_date             date
  , host_date             date
  , oper_type             com_api_type_pkg.t_dict_value
  , auth_code             com_api_type_pkg.t_auth_code
  , oper_amount           com_api_type_pkg.t_money
  , oper_currency         com_api_type_pkg.t_curr_code
  , account_amount        com_api_type_pkg.t_money
  , account_currency      com_api_type_pkg.t_curr_code
  , terminal_number       com_api_type_pkg.t_terminal_number
  , merchant_number       com_api_type_pkg.t_merchant_number
  , merchant_name         com_api_type_pkg.t_name
  , merchant_street       com_api_type_pkg.t_name
  , merchant_city         com_api_type_pkg.t_name
  , merchant_region       com_api_type_pkg.t_curr_code
  , merchant_country      com_api_type_pkg.t_curr_code
  , merchant_postcode     com_api_type_pkg.t_postal_code
  , is_reversal           com_api_type_pkg.t_boolean
);
type t_auth_stmt_tab is table of t_auth_stmt_rec index by binary_integer;

type t_aup_mastercard_rec is record(
    auth_id               com_api_type_pkg.t_long_id
  , tech_id               com_api_type_pkg.t_rrn
  , iso_msg_type          com_api_type_pkg.t_tiny_id
  , trace                 com_api_type_pkg.t_auth_code
  , trms_datetime         date
  , time_mark             com_api_type_pkg.t_date_long
  , bitmap                com_api_type_pkg.t_account_number
  , sttl_date             com_api_type_pkg.t_tiny_id
  , acq_inst_bin          com_api_type_pkg.t_cmid
  , forw_inst_bin         com_api_type_pkg.t_cmid
  , host_id               com_api_type_pkg.t_tiny_id
  , eci                   com_api_type_pkg.t_module_code
  , auth_code             com_api_type_pkg.t_auth_code
  , resp_code             com_api_type_pkg.t_byte_char
);
type t_aup_mastercard_tab is table of t_aup_mastercard_rec index by binary_integer;

type t_aup_visa_basei_rec is record(
    auth_id               com_api_type_pkg.t_long_id
  , tech_id               com_api_type_pkg.t_rrn
  , iso_msg_type          com_api_type_pkg.t_tiny_id
  , acq_inst_bin          com_api_type_pkg.t_cmid
  , forw_inst_bin         com_api_type_pkg.t_cmid
  , host_id               com_api_type_pkg.t_tiny_id
  , validation_code       com_api_type_pkg.t_mcc
  , srv_indicator         com_api_type_pkg.t_byte_char
  , ecommerce_indicator   com_api_type_pkg.t_byte_char
  , trace                 com_api_type_pkg.t_auth_code
  , resp_code             com_api_type_pkg.t_byte_char
);
type t_aup_visa_basei_tab is table of t_aup_visa_basei_rec index by binary_integer;

type t_aup_tag_rec is record(
    tag_id                com_api_type_pkg.t_short_id
  , tag_value             com_api_type_pkg.t_full_desc
  , seq_number            com_api_type_pkg.t_tiny_id
);
type t_aup_tag_tab is table of t_aup_tag_rec index by binary_integer;

end;
/
