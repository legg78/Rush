create or replace package nbf_api_type_pkg is

type t_file_rec is record (
    id                 com_api_type_pkg.t_short_id
  , is_incoming        com_api_type_pkg.t_boolean
  , inst_id            com_api_type_pkg.t_inst_id
  , network_id         com_api_type_pkg.t_network_id
  , session_file_id    com_api_type_pkg.t_long_id
  , records_total      com_api_type_pkg.t_count := 0
  , date_beg           date
  , date_end           date
);

type t_msg_rec is record ( 
    id                        com_api_type_pkg.t_long_id
  , status                    com_api_type_pkg.t_dict_value
  , file_id                   com_api_type_pkg.t_short_id
  , is_incoming               com_api_type_pkg.t_boolean
  , oper_id                   com_api_type_pkg.t_long_id
  , iss_account_id            com_api_type_pkg.t_account_id
  , debit_bank_code           varchar2(12)
  , debit_account_number      varchar2(20)
  , credit_bank_code          varchar2(12)
  , credit_account_number     varchar2(20)
  , amount                    number(22,4)
  , currency                  com_api_type_pkg.t_curr_code
  , oper_date                 date
  , rrn                       com_api_type_pkg.t_rrn
);

type t_msg_tab is table of t_msg_rec index by binary_integer;

end;
/
