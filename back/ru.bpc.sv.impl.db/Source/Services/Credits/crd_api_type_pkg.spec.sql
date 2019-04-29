create or replace package crd_api_type_pkg is

    type            t_invoice_rec is record(
        id                  com_api_type_pkg.t_medium_id
      , account_id          com_api_type_pkg.t_medium_id
      , serial_number       com_api_type_pkg.t_tiny_id
      , invoice_type        com_api_type_pkg.t_dict_value
      , exceed_limit        com_api_type_pkg.t_money
      , total_amount_due    com_api_type_pkg.t_money
      , own_funds           com_api_type_pkg.t_money
      , min_amount_due      com_api_type_pkg.t_money
      , invoice_date        date
      , grace_date          date
      , due_date            date
      , penalty_date        date
      , aging_period        com_api_type_pkg.t_tiny_id
      , is_tad_paid         com_api_type_pkg.t_boolean
      , is_mad_paid         com_api_type_pkg.t_boolean
      , inst_id             com_api_type_pkg.t_inst_id
      , agent_id            com_api_type_pkg.t_agent_id
      , split_hash          com_api_type_pkg.t_tiny_id
      , overdue_date        date
      , start_date          date
    );
    type            t_invoice_tab is table of t_invoice_rec index by binary_integer;

    type t_debt_interest_rec is record(
        debt_intr_id        com_api_type_pkg.t_long_id
      , debt_id             com_api_type_pkg.t_long_id
      , balance_type        com_api_type_pkg.t_dict_value
      , balance_date        date
      , amount              com_api_type_pkg.t_money
      , min_amount_due      com_api_type_pkg.t_money
      , interest_amount     com_api_type_pkg.t_money
      , fee_id              com_api_type_pkg.t_short_id
      , is_charged          com_api_type_pkg.t_boolean
      , is_grace_enable     com_api_type_pkg.t_boolean
      , split_hash          com_api_type_pkg.t_tiny_id
    );

    type t_payment_debt_rec is record(
        debt_id             com_api_type_pkg.t_long_id
      , bunch_type_id       com_api_type_pkg.t_tiny_id
      , amount              com_api_type_pkg.t_money
      , min_amount_due      com_api_type_pkg.t_money
      , balance_type        com_api_type_pkg.t_dict_value
      , macros_type_id      com_api_type_pkg.t_tiny_id
      , card_id             com_api_type_pkg.t_long_id
      , iteration           com_api_type_pkg.t_tiny_id
      , debt_balance_id     com_api_type_pkg.t_long_id
    );

    type t_payment_debt_tab is table of t_payment_debt_rec index by binary_integer;

    type t_interest_tab is table of com_api_type_pkg.t_money index by binary_integer;

    type t_acc_in_collection_rec is record(
        account_id                     com_api_type_pkg.t_medium_id
      , account_number                 com_api_type_pkg.t_account_number
      , account_type                   com_api_type_pkg.t_dict_value
      , account_currency               com_api_type_pkg.t_curr_code
      , account_status                 com_api_type_pkg.t_dict_value
      , card_mask                      com_api_type_pkg.t_card_number
      , agent_id                       com_api_type_pkg.t_short_id
      , agent_name                     com_api_type_pkg.t_text
      , card_expire_date               date
      , aging_period                   com_api_type_pkg.t_tiny_id
      , total_outstanding_value        com_api_type_pkg.t_money
      , min_amount_due                 com_api_type_pkg.t_money
      , customer_category              com_api_type_pkg.t_dict_value
      , customer_relation              com_api_type_pkg.t_dict_value
      , contract_type                  com_api_type_pkg.t_dict_value
      , contract_number                com_api_type_pkg.t_name
      , surname                        com_api_type_pkg.t_name
      , first_name                     com_api_type_pkg.t_name
      , second_name                    com_api_type_pkg.t_name
      , id_type                        com_api_type_pkg.t_dict_value
      , id_series                      com_api_type_pkg.t_name
      , id_number                      com_api_type_pkg.t_name
      , contact_type                   com_api_type_pkg.t_dict_value
      , preferred_lang                 com_api_type_pkg.t_dict_value
      , commun_method                  com_api_type_pkg.t_dict_value
      , commun_address                 com_api_type_pkg.t_name
      , address_type                   com_api_type_pkg.t_dict_value
      , address_country                com_api_type_pkg.t_country_code
      , address_region                 com_api_type_pkg.t_double_name
      , address_city                   com_api_type_pkg.t_double_name
      , address_street                 com_api_type_pkg.t_double_name
      , address_house                  com_api_type_pkg.t_double_name
      , address_apartment              com_api_type_pkg.t_double_name
    );

    type t_acc_in_collection_tab is table of t_acc_in_collection_rec index by binary_integer;

end crd_api_type_pkg;
/
