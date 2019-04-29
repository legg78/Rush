create or replace package crd_prc_migration_pkg as

type t_invoice_rec    is record (
    account_number          com_api_type_pkg.t_account_number
    , invoice_type          com_api_type_pkg.t_dict_value
    , exceed_limit          com_api_type_pkg.t_money 
    , total_amount_due      com_api_type_pkg.t_money 
    , mandatory_amount_due  com_api_type_pkg.t_money 
    , own_funds             com_api_type_pkg.t_money  
    , start_date            date
    , invoice_date          date
    , due_date              date
    , grace_date            date
    , penalty_date          date
    , overdue_date          date
    , aging_period          com_api_type_pkg.t_inst_id
    , is_tad_paid           com_api_type_pkg.t_boolean
    , is_mad_paid           com_api_type_pkg.t_boolean
);

type t_debt_rec    is record (
    id                      com_api_type_pkg.t_long_id
    , account_id            com_api_type_pkg.t_medium_id  
    , card_id               com_api_type_pkg.t_medium_id
    , product_id            com_api_type_pkg.t_short_id
    , service_id            com_api_type_pkg.t_short_id
    , oper_id               com_api_type_pkg.t_long_id
    , oper_type             com_api_type_pkg.t_dict_value
    , sttl_type             com_api_type_pkg.t_dict_value
    , fee_type              com_api_type_pkg.t_dict_value
    , terminal_type         com_api_type_pkg.t_dict_value
    , oper_date             date
    , posting_date          date
    , sttl_day              com_api_type_pkg.t_tiny_id
    , currency              com_api_type_pkg.t_curr_code
    , amount                com_api_type_pkg.t_money 
    , debt_amount           com_api_type_pkg.t_money 
    , mcc                   com_api_type_pkg.t_mcc 
    , aging_period          com_api_type_pkg.t_inst_id
    , is_new                com_api_type_pkg.t_boolean
    , status                com_api_type_pkg.t_dict_value
    , inst_id               com_api_type_pkg.t_inst_id
    , agent_id              com_api_type_pkg.t_agent_id
    , split_hash            com_api_type_pkg.t_tiny_id
    , macros_type_id        com_api_type_pkg.t_tiny_id
    , is_grace_enabled      com_api_type_pkg.t_boolean    
    , originator_refnum     com_api_type_pkg.t_rrn
    , account_number        com_api_type_pkg.t_account_number
    , card_number           com_api_type_pkg.t_card_number
    , invoice_date          date
    , debt_balance          xmltype
    , invoice_id            com_api_type_pkg.t_medium_id
);

type t_payment_rec    is record (
    id                      com_api_type_pkg.t_long_id
    , oper_id               com_api_type_pkg.t_long_id
    , is_reversal           com_api_type_pkg.t_boolean
    , original_oper_id      com_api_type_pkg.t_long_id
    , account_id            com_api_type_pkg.t_medium_id
    , card_id               com_api_type_pkg.t_medium_id
    , product_id            com_api_type_pkg.t_medium_id
    , posting_date          date
    , sttl_day              com_api_type_pkg.t_tiny_id
    , currency              com_api_type_pkg.t_curr_code
    , amount                com_api_type_pkg.t_money
    , pay_amount            com_api_type_pkg.t_money
    , is_new                com_api_type_pkg.t_boolean
    , status                com_api_type_pkg.t_dict_value
    , inst_id               com_api_type_pkg.t_inst_id
    , agent_id              com_api_type_pkg.t_medium_id
    , split_hash            com_api_type_pkg.t_tiny_id
    , originator_refnum     com_api_type_pkg.t_rrn
    , account_number        com_api_type_pkg.t_account_number
    , card_number           com_api_type_pkg.t_account_number
    , invoice_date          date
    , debt_payment          xmltype
    , invoice_id            com_api_type_pkg.t_medium_id
);

procedure load_invoice(
    i_inst_id       com_api_type_pkg.t_inst_id   
);

procedure load_debt(
    i_inst_id       com_api_type_pkg.t_inst_id   
);

procedure load_payment(
    i_inst_id       com_api_type_pkg.t_inst_id   
);

procedure apply_payment(
    i_inst_id     in  com_api_type_pkg.t_inst_id
);


end;
/
