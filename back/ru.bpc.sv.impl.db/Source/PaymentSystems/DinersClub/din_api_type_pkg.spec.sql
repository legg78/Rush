create or replace package din_api_type_pkg as
/*********************************************************
*  Data types for Diners Club API <br />
*  Created by Alalykin A.(alalykin@bpcbt.com) at 02.05.2016 <br />
*  Module: DIN_API_TYPE_PKG <br />
*  @headcom
**********************************************************/

subtype t_institution_code       is varchar2(2);
subtype t_recap_number           is number(3);
subtype t_batch_number           is number(3);
subtype t_type_of_charge         is varchar2(2);
subtype t_charge_type            is varchar2(3);
subtype t_function_code          is varchar2(2);
subtype t_field_name             is varchar2(10);

type t_file_rec is record (
    id                           com_api_type_pkg.t_long_id
  , is_incoming                  com_api_type_pkg.t_boolean
  , network_id                   com_api_type_pkg.t_network_id
  , inst_id                      com_api_type_pkg.t_inst_id
  , recap_total                  com_api_type_pkg.t_short_id
  , file_date                    date
  , is_rejected                  com_api_type_pkg.t_boolean
);

type t_recap_rec is record (
    id                           com_api_type_pkg.t_medium_id
  , file_id                      com_api_type_pkg.t_long_id
  , record_number                com_api_type_pkg.t_short_id
  , inst_id                      com_api_type_pkg.t_inst_id
  , sending_institution          t_institution_code
  , recap_number                 t_recap_number
  , receiving_institution        t_institution_code
  , currency                     com_api_type_pkg.t_curr_code
  , recap_date                   date
  , credit_count                 com_api_type_pkg.t_short_id
  , credit_amount                com_api_type_pkg.t_money
  , debit_count                  com_api_type_pkg.t_short_id
  , debit_amount                 com_api_type_pkg.t_money
  , program_transaction_amount   com_api_type_pkg.t_money
  , net_amount                   com_api_type_pkg.t_money
  , alt_currency                 com_api_type_pkg.t_curr_code
  , alt_rate_type                com_api_type_pkg.t_dict_value
  , alt_gross_amount             com_api_type_pkg.t_money
  , alt_net_amount               com_api_type_pkg.t_money
  , new_recap_number             t_recap_number
  , proc_date                    date
  , sttl_date                    date
  , is_rejected                  com_api_type_pkg.t_boolean
);

type t_batch_rec is record (
    id                           com_api_type_pkg.t_medium_id
  , recap_id                     com_api_type_pkg.t_medium_id
  , record_number                com_api_type_pkg.t_short_id
  , batch_number                 t_batch_number
  , sending_institution          t_institution_code
  , receiving_institution        t_institution_code
  , credit_count                 com_api_type_pkg.t_short_id
  , credit_amount                com_api_type_pkg.t_money
  , debit_count                  com_api_type_pkg.t_short_id
  , debit_amount                 com_api_type_pkg.t_money
  , is_rejected                  com_api_type_pkg.t_boolean
);

type t_fin_message_rec is record (
    id                           com_api_type_pkg.t_long_id
  , status                       com_api_type_pkg.t_dict_value
  , file_id                      com_api_type_pkg.t_long_id
  , record_number                com_api_type_pkg.t_short_id
  , batch_id                     com_api_type_pkg.t_medium_id
  , sequential_number            com_api_type_pkg.t_tiny_id
  , is_incoming                  com_api_type_pkg.t_boolean
  , is_rejected                  com_api_type_pkg.t_boolean
  , is_reversal                  com_api_type_pkg.t_boolean
  , is_invalid                   com_api_type_pkg.t_boolean
  , network_id                   com_api_type_pkg.t_network_id
  , inst_id                      com_api_type_pkg.t_inst_id
  , sending_institution          t_institution_code
  , receiving_institution        t_institution_code
  , dispute_id                   com_api_type_pkg.t_long_id
  , originator_refnum            varchar2(8)
  , network_refnum               varchar2(15)
  , card_id                      com_api_type_pkg.t_medium_id
  , card_number                  com_api_type_pkg.t_card_number
  , type_of_charge               t_type_of_charge
  , charge_type                  t_charge_type
  , date_type                    varchar2(2)
  , charge_date                  date
  , sttl_date                    date
  , host_date                    date
  , auth_code                    com_api_type_pkg.t_auth_code
  , action_code                  varchar(3)
  , oper_amount                  com_api_type_pkg.t_money
  , oper_currency                com_api_type_pkg.t_curr_code
  , sttl_amount                  com_api_type_pkg.t_money
  , sttl_currency                com_api_type_pkg.t_curr_code
  , mcc                          com_api_type_pkg.t_mcc
  , merchant_number              com_api_type_pkg.t_merchant_number
  , merchant_name                varchar2(36)
  , merchant_city                varchar2(26)
  , merchant_country             com_api_type_pkg.t_country_code
  , merchant_state               varchar2(20)
  , merchant_street              varchar2(35)
  , merchant_postcode            varchar2(11)
  , merchant_phone               varchar2(20)
  , merchant_international_code  com_api_type_pkg.t_mcc
  , terminal_number              com_api_type_pkg.t_terminal_number
  , program_transaction_amount   com_api_type_pkg.t_money
  , alt_currency                 com_api_type_pkg.t_curr_code
  , alt_rate_type                com_api_type_pkg.t_dict_value
  , tax_amount1                  com_api_type_pkg.t_money
  , tax_amount2                  com_api_type_pkg.t_money
  , original_document_number     varchar2(15)
  , crdh_presence                com_api_type_pkg.t_byte_char
  , card_presence                com_api_type_pkg.t_byte_char
  , card_data_input_mode         com_api_type_pkg.t_byte_char
  , card_data_input_capability   com_api_type_pkg.t_byte_char
  , card_type                    com_api_type_pkg.t_byte_char
  , payment_token                varchar2(19)
  , token_requestor_id           com_api_type_pkg.t_region_code
  , token_assurance_level        com_api_type_pkg.t_byte_char
);

type t_fin_message_tab           is table of t_fin_message_rec index by pls_integer;

type t_fin_message_cur           is ref cursor return t_fin_message_rec;

type t_addendum_rec is record (
    id                           com_api_type_pkg.t_long_id
  , function_code                t_function_code
  , fin_id                       com_api_type_pkg.t_long_id
  , file_id                      com_api_type_pkg.t_long_id
  , record_number                com_api_type_pkg.t_short_id
);

type t_addendum_tab              is table of t_addendum_rec index by pls_integer;

type t_addendum_value_rec is record (
    id                           com_api_type_pkg.t_long_id
  , addendum_id                  com_api_type_pkg.t_long_id
  , field_name                   t_field_name
  , field_value                  com_api_type_pkg.t_name
);

type t_addendum_value_tab        is table of t_addendum_value_rec index by pls_integer;

type t_addendum_extented_rec is record (
    id                           com_api_type_pkg.t_long_id
  , priority                     com_api_type_pkg.t_tiny_id
  , function_code                t_function_code
  , field_name                   t_field_name
  , field_value                  com_api_type_pkg.t_name
  , field_number                 com_api_type_pkg.t_tiny_id
  , format                       com_api_type_pkg.t_dict_value
  , field_length                 com_api_type_pkg.t_tiny_id
);

type t_addendum_extented_tab     is table of t_addendum_extented_rec index by pls_integer;

type t_message_field_rec is record (
    function_code                t_function_code
  , field_name                   t_field_name
  , field_number                 com_api_type_pkg.t_tiny_id
  , format                       com_api_type_pkg.t_dict_value
  , field_length                 com_api_type_pkg.t_tiny_id
  , is_mandatory                 com_api_type_pkg.t_boolean
  , default_value                com_api_type_pkg.t_name
  , emv_tag                      com_api_type_pkg.t_tag
  , description                  com_api_type_pkg.t_short_desc
);

type t_message_field_tab         is table of t_message_field_rec index by pls_integer;

type t_fields_by_funcd_tab       is table of t_message_field_tab index by t_function_code;

type t_message_category_tab      is table of com_api_type_pkg.t_dict_value index by t_function_code;

type t_addendum_values_tab       is table of com_api_type_pkg.t_name index by t_field_name;

end;
/
