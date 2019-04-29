create or replace package pmo_api_type_pkg as

type t_payment_order_rec is record (
    id                          com_api_type_pkg.t_long_id
    , customer_id               com_api_type_pkg.t_medium_id
    , entity_type               com_api_type_pkg.t_dict_value
    , object_id                 com_api_type_pkg.t_long_id
    , purpose_id                com_api_type_pkg.t_short_id
    , template_id               com_api_type_pkg.t_long_id
    , amount                    com_api_type_pkg.t_money
    , currency                  com_api_type_pkg.t_curr_code
    , event_date                date
    , status                    com_api_type_pkg.t_dict_value
    , inst_id                   com_api_type_pkg.t_inst_id
    , attempt_count             com_api_type_pkg.t_tiny_id
    , split_hash                com_api_type_pkg.t_tiny_id
    , payment_order_number      com_api_type_pkg.t_name
    , expiration_date           date
    , resp_code                 com_api_type_pkg.t_dict_value
    , resp_amount               com_api_type_pkg.t_money
    , originator_refnum         com_api_type_pkg.t_rrn
);

type t_payment_order_tab is table of t_payment_order_rec index by binary_integer;

end pmo_api_type_pkg;
/
