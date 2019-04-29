create or replace package cst_api_files_type_pkg is

type t_sms_service_rec is record (
    card_number             com_api_type_pkg.t_card_number
  , sub_main                com_api_type_pkg.t_attr_name
  , card_number_main        com_api_type_pkg.t_card_number
  , cardholder_name         com_api_type_pkg.t_name
  , service_type_name       com_api_type_pkg.t_name
  , service_type_code       com_api_type_pkg.t_name
  , mobile_phone            com_api_type_pkg.t_name
  , product_name            com_api_type_pkg.t_name
  , product_id              com_api_type_pkg.t_auth_long_id
  , card_status_name        com_api_type_pkg.t_card_number
  , card_status_code        com_api_type_pkg.t_card_number
  , card_expire_date        com_api_type_pkg.t_date_long
  , contract_status         com_api_type_pkg.t_cmid
  , action_type             com_api_type_pkg.t_boolean
);

type t_sms_service_tab is table of t_sms_service_rec index by binary_integer;

end cst_api_files_type_pkg;
/
