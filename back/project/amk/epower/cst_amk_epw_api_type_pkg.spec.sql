create or replace package cst_amk_epw_api_type_pkg is

type t_file_rec is record (
    id                 com_api_type_pkg.t_short_id
  , is_incoming        com_api_type_pkg.t_boolean
  , network_id         com_api_type_pkg.t_tiny_id
  , inst_id            com_api_type_pkg.t_inst_id
  , session_file_id    com_api_type_pkg.t_long_id
  , total_records      com_api_type_pkg.t_count := 0
  , date_beg           date
  , date_end           date
);

type t_msg_rec is record (
    id                      com_api_type_pkg.t_short_id
  , status                  com_api_type_pkg.t_dict_value
  , file_id                 com_api_type_pkg.t_long_id
  , is_invalid              com_api_type_pkg.t_boolean
  , is_incoming             com_api_type_pkg.t_boolean
  , inst_id                 com_api_type_pkg.t_inst_id
  , network_id              com_api_type_pkg.t_tiny_id
  , row_number              number(22)
  , supplier_code           varchar2(200)
  , supplier_name           varchar2(200)
  , service_id              number(8)
  , customer_code           varchar2(200)
  , customer_name           varchar2(200)
  , customer_id             number(8)
  , trxn_datetime           date
  , amount                  number(22,4)
  , currency_name           com_api_type_pkg.t_curr_name
  , currency_code           com_api_type_pkg.t_curr_code
  , oper_id                 com_api_type_pkg.t_long_id
);

end ;
/
