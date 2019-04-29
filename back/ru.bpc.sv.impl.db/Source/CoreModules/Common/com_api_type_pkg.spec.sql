create or replace package com_api_type_pkg as
/****************************************************************
* The common types and constants                           <br />
* Created by Filimonov A.(filimonov@bpc.ru)  at 08.07.2009 <br />
* Module: COM_API_TYPE_PKG                                 <br />
* @headcom                                                 <br />
*****************************************************************/

subtype t_ref_cur           is sys_refcursor;

subtype t_boolean           is number(1);
subtype t_agent_id          is number(8);
subtype t_inst_id           is number(4);
subtype t_sign              is number(1);
subtype t_money             is number(22,4);
subtype t_large_id          is number(24);
subtype t_long_id           is number(16);
subtype t_medium_id         is number(12);
subtype t_short_id          is number(8);
subtype t_tiny_id           is number(4);
subtype t_curr_code         is varchar2(3);
subtype t_curr_name         is varchar2(3);
subtype t_name              is varchar2(200);
subtype t_double_name       is varchar2(400);  -- The "t_name" type which can contain Unicode symbols with two-byte length
subtype t_short_desc        is varchar2(200);
subtype t_full_desc         is varchar2(2000);
subtype t_port              is varchar2(7);
subtype t_remote_adr        is varchar2(127);
subtype t_dict_value        is varchar2(8);
subtype t_module_code       is varchar2(3);
subtype t_oracle_name       is varchar2(60);
subtype t_attr_name         is varchar2(30);
subtype t_person_id         is number(12);
subtype t_account_id        is t_medium_id;
subtype t_account_number    is varchar2(32);
subtype t_balance_id        is t_medium_id;
subtype t_card_number       is varchar2(24);
subtype t_bin               is varchar2(24);
subtype t_desc_id           is t_medium_id;
subtype t_seqnum            is number(4);
subtype t_mcc               is varchar2(4);
subtype t_rrn               is varchar2(36);
subtype t_auth_code         is varchar2(6);
subtype t_merchant_number   is varchar2(15);
subtype t_terminal_number   is varchar2(16);
subtype t_postal_code       is varchar2(10);
subtype t_network_id        is number(4);
subtype t_country_code      is varchar2(3);
subtype t_semaphore_name    is varchar2(128);
subtype t_cmid              is varchar2(12);
subtype t_param_value       is varchar2(2000);
subtype t_raw_data          is varchar2(4000);
subtype t_text              is varchar2(4000);
subtype t_rate              is number;
subtype t_date_long         is varchar2(16);
subtype t_date_short        is varchar2(8);
subtype t_pin_block         is varchar2(16);
subtype t_key               is varchar2(2048);
subtype t_exponent          is varchar2(256);
subtype t_region_code       is varchar2(11);
subtype t_tag               is varchar2(6);
subtype t_lob_data          is varchar2(32767);
subtype t_sql_statement     is varchar2(32767);
subtype t_geo_coord         is number(10,7);
subtype t_auth_amount       is varchar2(23);
subtype t_auth_long_id      is varchar2(16);
subtype t_auth_medium_id    is varchar2(12);
subtype t_auth_date_id      is varchar2(14);
subtype t_auth_date         is varchar2(14);
subtype t_original_data     is varchar2(42);
subtype t_byte_id           is number(3);
subtype t_byte_char         is varchar2(2);
subtype t_count             is simple_integer; -- for counters, not null
subtype t_uuid              is varchar2(36);
subtype t_hash_value        is varchar2(128);
subtype t_md5               is varchar2(32);
subtype t_one_char          is varchar2(1);
subtype t_arn               is varchar2(23);

type    t_sttl_day_rec      is record (
    sttl_day                number
  , sttl_date               date
);
type    t_sttl_day_tab          is table of t_sttl_day_rec index by binary_integer;

type    t_rowid_tab             is table of rowid index by binary_integer;
type    t_inst_id_tab           is table of t_inst_id index by binary_integer;
type    t_agent_id_tab          is table of t_agent_id index by binary_integer;
type    t_network_tab           is table of t_network_id index by binary_integer;
type    t_number_tab            is table of number index by binary_integer;
type    t_date_tab              is table of date index by binary_integer;
type    t_timestamp_tab         is table of timestamp index by binary_integer;
type    t_dict_tab              is table of t_dict_value index by binary_integer;
type    t_name_tab              is table of t_name index by binary_integer;
type    t_desc_tab              is table of t_full_desc index by binary_integer;
type    t_integer_tab           is table of pls_integer index by binary_integer;
type    t_boolean_tab           is table of t_boolean index by binary_integer;
type    t_oracle_name_tab       is table of t_oracle_name index by binary_integer;
type    t_curr_code_tab         is table of t_curr_code index by binary_integer;
type    t_account_number_tab    is table of t_account_number index by binary_integer;
type    t_mcc_tab               is table of t_mcc index by binary_integer;
type    t_rrn_tab               is table of t_rrn index by binary_integer;
type    t_merchant_number_tab   is table of t_merchant_number index by binary_integer;
type    t_terminal_number_tab   is table of t_terminal_number index by binary_integer;
type    t_auth_code_tab         is table of t_auth_code index by binary_integer;
type    t_postal_code_tab       is table of t_postal_code index by binary_integer;
type    t_card_number_tab       is table of t_card_number index by binary_integer;
type    t_varchar2_tab          is table of varchar2(4000) index by binary_integer;
type    t_country_code_tab      is table of t_country_code index by binary_integer;
type    t_cmid_tab              is table of t_cmid index by binary_integer;
type    t_raw_tab               is table of t_raw_data index by binary_integer;
type    t_XMLType_tab           is table of XMLType index by binary_integer;
type    t_param_tab             is table of t_param_value index by t_name;
type    t_tag_value_tab         is table of t_param_value index by t_tag;
type    t_lob_tab               is table of t_lob_data index by binary_integer;
type    t_lob2_tab              is table of t_lob_data index by t_name;
type    t_clob_tab              is table of clob index by binary_integer;
type    t_param2d_tab           is table of t_param_tab index by t_dict_value;

type    t_tiny_tab              is table of t_tiny_id index by binary_integer;
type    t_short_tab             is table of t_short_id index by binary_integer;
type    t_short_map             is table of t_short_id index by t_name;
type    t_medium_tab            is table of t_medium_id index by binary_integer;
type    t_long_tab              is table of t_long_id index by binary_integer;
type    t_large_tab             is table of t_large_id index by binary_integer;
type    t_auth_amount_tab       is table of t_auth_amount index by binary_integer;
type    t_auth_medium_tab       is table of t_auth_medium_id index by binary_integer;
type    t_auth_date_tab         is table of t_auth_date index by binary_integer;
type    t_auth_long_tab         is table of t_auth_long_id index by binary_integer;
type    t_money_tab             is table of t_money index by binary_integer;
type    t_byte_char_tab         is table of t_byte_char index by binary_integer;
type    t_count_tab             is table of t_count index by binary_integer;

TRUE             constant t_boolean     := 1;
FALSE            constant t_boolean     := 0;

CREDIT           constant t_sign       := 1;
DEBIT            constant t_sign       := -1;
NONE             constant t_sign       := 0;

type t_multilang_value is record(
    value               t_name
  , lang                t_dict_value
);

type t_multilang_value_tab is table of t_multilang_value index by binary_integer;

type t_multilang_desc is record(
    value               t_full_desc
  , lang                t_dict_value
);

type t_multilang_desc_tab is table of t_multilang_desc index by binary_integer;


type t_person is record(
    id                  t_person_id
  , lang                t_dict_value
  , person_title        t_dict_value
  , first_name          t_name
  , second_name         t_name
  , surname             t_name
  , suffix              t_dict_value
  , gender              t_dict_value
  , birthday            date
  , place_of_birth      t_name
  , inst_id             t_inst_id
);

type t_identity_card is record(
    person_id           t_medium_id
  , id_type             t_dict_value
  , id_series           t_name
  , id_number           t_name
  , id_issuer           t_full_desc
  , id_issue_date       date
  , id_expire_date      date
  , id_desc             t_full_desc
  , inst_id             t_inst_id
  , country             t_country_code
);

type t_company  is record(
    id                  t_short_id
  , embossed_name       t_name
  , company_short_name  t_multilang_value_tab
  , company_full_name   t_multilang_desc_tab
  , incorp_form         t_dict_value
  , inst_id             t_inst_id
);

type t_amount_rec is record (
    amount              t_money
  , currency            t_curr_code
  , conversion_rate     t_rate
  , rate_type           t_dict_value
);
type t_amount_by_name_tab is table of t_amount_rec index by t_oracle_name;

type t_amount2_rec is record (
    amount              t_money
  , currency            t_curr_code
  , conversion_rate     t_rate
  , amount_type         t_dict_value
);
type t_amount_tab is table of t_amount2_rec index by binary_integer;

type t_date_by_name_tab is table of date index by t_oracle_name;
type t_currency_by_name_tab is table of t_curr_code index by t_oracle_name;
type t_number_by_name_tab is table of number index by t_oracle_name;

type t_des_key_rec is record (
    lmk_id              t_tiny_id
  , key_type            t_dict_value
  , key_index           t_tiny_id
  , key_length          t_tiny_id
  , key_value           t_name
  , key_prefix          t_name
  , check_value         t_name
);
type t_des_key_tab is table of t_des_key_rec index by binary_integer;

type t_hmac_key_rec is record (
    lmk_id              t_tiny_id
  , key_index           t_tiny_id
  , key_length          t_tiny_id
  , key_value           t_name
);
type t_hmac_key_tab is table of t_hmac_key_rec index by binary_integer;

type t_card_type_rec is record (
    card_type_id        t_tiny_id
    , name              t_name
);
type t_card_type_tab is table of t_card_type_rec index by binary_integer;

type t_trc_log_rec is record (
    i_timestamp         timestamp
  , level               t_dict_value
  , section             t_full_desc
  , user                t_oracle_name
  , text                t_text
  , entity_type         t_dict_value
  , object_id           t_long_id
  , event_id            t_tiny_id
  , label_id            t_short_id
  , inst_id             t_tiny_id
  , session_id          t_long_id
  , thread_number       t_tiny_id
  , who_called          t_name
  , level_code          t_tiny_id
  , text_mode           t_boolean
  , env_param1          t_full_desc
  , env_param2          t_name
  , env_param3          t_name
  , env_param4          t_name
  , env_param5          t_name
  , env_param6          t_name
);

type t_trc_log_tab is table of t_trc_log_rec index by binary_integer;

type t_address_rec is record (
    id                  t_medium_id
  , seqnum              t_seqnum
  , lang                t_dict_value
  , country             t_country_code
  , region              t_double_name
  , city                t_double_name
  , street              t_double_name
  , house               t_double_name
  , apartment           t_double_name
  , postal_code         t_postal_code
  , region_code         varchar2(20)
  , latitude            number(10,7)
  , longitude           number(10,7)
  , inst_id             t_inst_id
  , place_code          t_name
  , address_type        t_dict_value
);

type t_object_rec is record (
    level_type          t_dict_value
  , entity_type         t_dict_value
  , object_id           num_tab_tpt
);

type t_object_tab is table of t_object_rec index by binary_integer;

type t_array_element_rec is record (
    id                  t_short_id
  , element_number      t_tiny_id
  , element_value       t_name
);

type t_flexible_field is record(
    id                  t_short_id
  , entity_type         t_dict_value
  , object_type         t_dict_value
  , name                t_name
  , data_type           t_dict_value
  , data_format         t_short_desc
  , lov_id              t_dict_value
  , is_user_defined     t_sign
  , inst_id             t_inst_id
  , default_value       t_short_desc
);

type t_flexible_data_rec is record(
    field_id            t_short_id
  , field_name          t_name
  , field_value         t_short_desc
);
type t_flexible_data_tab is table of t_flexible_data_rec index by binary_integer;

type t_contact_data_rec is record (
    id                  t_medium_id
  , contact_id          t_medium_id
  , commun_method       t_dict_value
  , commun_address      t_name
  , start_date          date
  , end_date            date
);

type t_array_element_tab is table of t_array_element_rec index by binary_integer;

type t_array_element_cache_tab is table of t_array_element_rec index by t_name;

function boolean_not (
    i_argument          in     t_boolean
) return t_boolean;

function invert_sign (
    i_argument          in     t_sign
) return t_sign;

function convert_to_char (
    n                   in     number
) return varchar2;

function convert_to_char (
    d                   in     date
) return varchar2;

function convert_to_char(
    i_data_type         in     t_dict_value
  , i_value_char        in     varchar2
  , i_value_num         in     number
  , i_value_date        in     date
) return varchar2;

function convert_to_number (
    s                   in     varchar2
  , i_mask_error        in     t_boolean                  default com_api_type_pkg.FALSE
  , i_format            in     varchar2                   default null
) return number;

function convert_to_date (
    s                   in     varchar2
) return date;

procedure nop;

function to_bool(
    i_statement         in     boolean
) return t_boolean;

function get_number_value(
    i_data_type         in     t_dict_value
  , i_value             in     t_name
  , i_format            in     t_name          default null
) return number;

function get_char_value(
    i_data_type         in     t_dict_value
  , i_value             in     t_name
) return t_name;

function get_date_value(
    i_data_type         in     t_dict_value
  , i_value             in     t_name
) return date;

function get_lov_value(
    i_data_type         in     t_dict_value
  , i_value             in     t_name
  , i_lov_id            in     t_tiny_id
) return t_text;

function num2str(
    i_source            in     t_money
  , i_lang              in     t_dict_value
  , i_currency          in     t_curr_code
) return t_name;

function pad_number (
    i_data              in     varchar2
  , i_min_length        in     integer
  , i_max_length        in     integer
) return varchar2;
          
function pad_char (
    i_data              in     varchar2
  , i_min_length        in     integer
  , i_max_length        in     integer
) return varchar2;

function reverse_value(
    i_value             in     t_name
) return t_name;

-- Get the "long_id" array from the input string.
procedure get_array_from_string(
    i_string            in     t_full_desc
  , o_array                out t_long_tab
);

-- Get the "full_desc" array from the input string.
procedure get_array_from_string(
    i_string            in     t_full_desc
  , o_array                out t_desc_tab
);

end com_api_type_pkg;
/
