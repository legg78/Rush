create or replace package cst_lvp_type_pkg as

    type t_order_evt_list_rec is record (
        id                        com_api_type_pkg.t_long_id
      , order_id                  com_api_type_pkg.t_long_id
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
      , customer_number           com_api_type_pkg.t_name
      , amount_algorithm          com_api_type_pkg.t_dict_value
    );
    type t_order_evt_list_tab is table of t_order_evt_list_rec index by binary_integer;
    type t_order_evt_list_cur is ref cursor return t_order_evt_list_rec;

    type t_order_parameters_rec is record (
        param_name                com_api_type_pkg.t_name
      , param_value               com_api_type_pkg.t_param_value
    );
    type t_order_parameters_tab is table of t_order_parameters_rec index by binary_integer;
    type t_order_parameters_cur is ref cursor return t_order_parameters_rec;

    type t_order_list_rec is record (
        id                        com_api_type_pkg.t_long_id
      , split_hash                com_api_type_pkg.t_tiny_id
      , customer_id               com_api_type_pkg.t_medium_id
      , customer_number           com_api_type_pkg.t_name
      , amount                    com_api_type_pkg.t_money
      , currency                  com_api_type_pkg.t_curr_code
      , inst_id                   com_api_type_pkg.t_inst_id
      , event_date                date
      , entity_type               com_api_type_pkg.t_dict_value
      , object_id                 com_api_type_pkg.t_long_id
      , purpose_id                com_api_type_pkg.t_short_id
    );
    type t_order_list_tab is table of t_order_list_rec index by binary_integer;
    type t_order_list_cur is ref cursor return t_order_list_rec;

    type t_credit_card_info_rec is record (
        id                        com_api_type_pkg.t_medium_id
      , account_id                com_api_type_pkg.t_account_id
      , account_number            com_api_type_pkg.t_account_number
      , account_currency          com_api_type_pkg.t_curr_code
      , account_currency_name     com_api_type_pkg.t_curr_name
      , agent_id                  com_api_type_pkg.t_agent_id
      , agent_number              com_api_type_pkg.t_name
      , card_id                   com_api_type_pkg.t_medium_id
      , card_number               com_api_type_pkg.t_card_number
      , card_is_main              com_api_type_pkg.t_boolean
      , card_embossed_name        com_api_type_pkg.t_name
      , account_credit_limit      com_api_type_pkg.t_money
      , account_cash_limit        com_api_type_pkg.t_money
      , account_credit_available  com_api_type_pkg.t_money
      , account_cash_available    com_api_type_pkg.t_money
      , card_credit_limit         com_api_type_pkg.t_money
      , card_cash_limit           com_api_type_pkg.t_money
      , card_credit_available     com_api_type_pkg.t_money
      , card_cash_available       com_api_type_pkg.t_money
      , available_balance         com_api_type_pkg.t_money
      , last_invoice_date         date
      , last_due_date             date
      , last_total_amount_due     com_api_type_pkg.t_money
      , last_min_amount_due       com_api_type_pkg.t_money
      , account_status            com_api_type_pkg.t_dict_value
      , card_instance_state       com_api_type_pkg.t_dict_value
    );
    type t_credit_card_info_tab is table of t_credit_card_info_rec index by binary_integer;

end cst_lvp_type_pkg;
/
