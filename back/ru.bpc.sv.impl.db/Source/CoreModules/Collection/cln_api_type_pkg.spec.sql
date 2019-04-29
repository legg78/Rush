create or replace package cln_api_type_pkg as

type t_case_rec is record(
    id            com_api_type_pkg.t_long_id
  , seqnum        com_api_type_pkg.t_tiny_id
  , inst_id       com_api_type_pkg.t_tiny_id
  , split_hash    com_api_type_pkg.t_tiny_id
  , case_number   com_api_type_pkg.t_name
  , creation_date DATE
  , customer_id   com_api_type_pkg.t_medium_id
  , user_id       com_api_type_pkg.t_short_id
  , status        com_api_type_pkg.t_dict_value
  , resolution    com_api_type_pkg.t_dict_value
);

end;
/
