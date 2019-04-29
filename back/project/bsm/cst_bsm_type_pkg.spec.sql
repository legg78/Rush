create or replace package cst_bsm_type_pkg is

type            t_event_card_rec is record (
    card_id                     com_api_type_pkg.t_medium_id
  , card_number                 com_api_type_pkg.t_card_number
  , card_status                 com_api_type_pkg.t_dict_value
  , card_category               com_api_type_pkg.t_dict_value
  , card_reg_date               date
  , card_expir_date             date
  , event_type                  varchar2(1)
  , account_count               com_api_type_pkg.t_account_number
  , count                       com_api_type_pkg.t_long_id
);

type            t_event_card_cur is ref cursor return t_event_card_rec;

type            t_event_card_tab is table of t_event_card_rec index by binary_integer;

type t_priority_prod_det_rec is record(
--    id                  com_api_type_pkg.t_medium_id
    product_id          com_api_type_pkg.t_medium_id
  , parent_product_id   com_api_type_pkg.t_medium_id
  , product_number      com_api_type_pkg.t_attr_name
  , product_description com_api_type_pkg.t_name
  , product_category    com_api_type_pkg.t_attr_name
  , product_subcategory com_api_type_pkg.t_attr_name
  , product_level3      com_api_type_pkg.t_attr_name
  , creation_date       date
  , product_level4      com_api_type_pkg.t_attr_name
  , product_lag         com_api_type_pkg.t_tiny_id
);

type t_priority_prod_det_tab is table of t_priority_prod_det_rec index by binary_integer;

type t_priority_acc_det_rec is record(
--    id                com_api_type_pkg.t_medium_id
    file_date         date
  , customer_number   com_api_type_pkg.t_attr_name --varchar2(30)
  , account_number    com_api_type_pkg.t_account_number -- varchar2(30)
  , account_balance   com_api_type_pkg.t_money     -- number(22,4)
  , customer_balance  com_api_type_pkg.t_money     -- number(22,4)
  , agent_number      com_api_type_pkg.t_attr_name -- varchar2(30)
  , product_number    com_api_type_pkg.t_attr_name -- varchar2(30)
  , priority_flag     com_api_type_pkg.t_byte_char --varchar2(1)
);

type t_priority_acc_det_tab is table of t_priority_acc_det_rec index by binary_integer;

end cst_bsm_type_pkg;
/
