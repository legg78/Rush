create or replace package acc_api_type_pkg is
/*********************************************************
 *  API for types of accounting <br />
 *  Created by Khougaev A.(khougaev@bpcbt.com)  at 20.09.2011 <br />
 *  Module: ACC_API_TYPE_PKG <br />
 *  @headcom
 **********************************************************/

subtype t_account_seq_number is number(2);

type t_selection_step_rec is record (
    id                         com_api_type_pkg.t_tiny_id
  , selection_id               com_api_type_pkg.t_tiny_id
  , exec_order                 com_api_type_pkg.t_tiny_id
  , step                       com_api_type_pkg.t_dict_value
);
type t_selection_step_tab is table of t_selection_step_rec index by binary_integer;

type t_account_rec is record (
    account_id                 com_api_type_pkg.t_account_id
  , split_hash                 com_api_type_pkg.t_tiny_id
  , account_type               com_api_type_pkg.t_dict_value
  , account_number             com_api_type_pkg.t_account_number
  , friendly_name              com_api_type_pkg.t_account_number
  , currency                   com_api_type_pkg.t_curr_code
  , inst_id                    com_api_type_pkg.t_inst_id
  , agent_id                   com_api_type_pkg.t_agent_id
  , status                     com_api_type_pkg.t_dict_value
  , status_reason              com_api_type_pkg.t_dict_value
  , contract_id                com_api_type_pkg.t_medium_id
  , customer_id                com_api_type_pkg.t_medium_id
  , scheme_id                  com_api_type_pkg.t_tiny_id
  , mod_id                     com_api_type_pkg.t_tiny_id
);
type t_account_tab is table of t_account_rec index by binary_integer;

type t_balance_rec is record (
    balance_type               com_api_type_pkg.t_dict_value
  , balance_currency           com_api_type_pkg.t_curr_code
  , balance_amount             com_api_type_pkg.t_money
  , account_currency           com_api_type_pkg.t_curr_code
  , account_amount             com_api_type_pkg.t_money
  , aval_impact                com_api_type_pkg.t_sign
);
type t_balance_tab is table of t_balance_rec index by binary_integer;

type t_account_by_name_tab is table of t_account_rec index by com_api_type_pkg.t_oracle_name;

type t_transaction_rec is record (
    transaction_type           com_api_type_pkg.t_dict_value
  , transaction_id             com_api_type_pkg.t_long_id
  , macros_id                  com_api_type_pkg.t_long_id
  , bunch_id                   com_api_type_pkg.t_long_id
  , split_hash                 com_api_type_pkg.t_tiny_id
  , posting_date               date
  , inst_id                    com_api_type_pkg.t_inst_id
  , balance_type               com_api_type_pkg.t_dict_value
);
type t_transaction_tab is table of t_transaction_rec index by binary_integer;

type t_entry_rec is record (
    oper_id                    com_api_type_pkg.t_long_id
  , document_number            com_api_type_pkg.t_name
  , document_date              date
  , document_type              com_api_type_pkg.t_dict_value
  , transaction_id             com_api_type_pkg.t_long_id
  , transaction_date           date
  , transaction_type           com_api_type_pkg.t_dict_value
  , debit_account_number       com_api_type_pkg.t_account_number
  , credit_account_number      com_api_type_pkg.t_account_number
  , balance_type               com_api_type_pkg.t_dict_value
  , debit_amount               com_api_type_pkg.t_money
  , debit_currency             com_api_type_pkg.t_dict_value
  , credit_amount              com_api_type_pkg.t_money
  , credit_currency            com_api_type_pkg.t_dict_value
);
type t_entry_tab    is table of t_entry_rec index by binary_integer;

type t_transaction_external_rec is record(
    oper_id                    com_api_type_pkg.t_long_id
  , oper_type                  com_api_type_pkg.t_dict_value
  , oper_reason                com_api_type_pkg.t_dict_value
  , is_reversal                com_api_type_pkg.t_sign
  , msg_type                   com_api_type_pkg.t_dict_value
  , sttl_type                  com_api_type_pkg.t_dict_value
  , oper_amount                com_api_type_pkg.t_money
  , oper_currency              com_api_type_pkg.t_curr_code
  , oper_date                  date
  , host_date                  date
  , unhold_date                date
  , oper_sttl_date             date
  , macros_id                  com_api_type_pkg.t_long_id
  , macros_account_id          com_api_type_pkg.t_account_id
  , macros_amount              com_api_type_pkg.t_money
  , macros_currency            com_api_type_pkg.t_curr_code
  , macros_amount_purpose      com_api_type_pkg.t_dict_value
  , macros_posting_date        date
  , macros_conversion_rate     com_api_type_pkg.t_rate
  , macros_conversion_rate_id  com_api_type_pkg.t_short_id
  , transaction_id             com_api_type_pkg.t_long_id
  , transaction_type           com_api_type_pkg.t_dict_value
  , debt_entry_id              com_api_type_pkg.t_long_id
  , debt_account_id            com_api_type_pkg.t_account_id
  , debt_account_number        com_api_type_pkg.t_account_number
  , debt_account_currency      com_api_type_pkg.t_curr_code
  , debt_balance_currency      com_api_type_pkg.t_curr_code
  , debt_amount                com_api_type_pkg.t_money
  , debt_currency              com_api_type_pkg.t_curr_code
  , debt_balance_type          com_api_type_pkg.t_dict_value
  , debt_balance_impact        com_api_type_pkg.t_sign
  , debt_balance               com_api_type_pkg.t_money
  , debt_posting_date          date
  , debt_sttl_date             date
  , credit_entry_id            com_api_type_pkg.t_long_id
  , credit_account_id          com_api_type_pkg.t_account_id
  , credit_account_number      com_api_type_pkg.t_account_number
  , credit_account_currency    com_api_type_pkg.t_curr_code
  , credit_balance_currency    com_api_type_pkg.t_curr_code
  , credit_amount              com_api_type_pkg.t_money
  , credit_currency            com_api_type_pkg.t_curr_code
  , credit_balance_type        com_api_type_pkg.t_dict_value
  , credit_balance_impact      com_api_type_pkg.t_sign
  , credit_balance             com_api_type_pkg.t_money
  , credit_posting_date        date
  , credit_sttl_date           date
);

type t_transaction_external_tab    is table of t_transaction_external_rec index by binary_integer;

type t_gl_account_numbers_ext_rec is record(
     account_number            com_api_type_pkg.t_account_number
   , card_account_id           com_api_type_pkg.t_account_id
   , card_split_hash           com_api_type_pkg.t_tiny_id
   , card_mask                 com_api_type_pkg.t_card_number
   , customer_number           com_api_type_pkg.t_name
   , customer_entity_type      com_api_type_pkg.t_dict_value
   , customer_object_id        com_api_type_pkg.t_long_id
   , national_id               com_api_type_pkg.t_name
   , gl_account_number         com_api_type_pkg.t_account_number
   , macros_type_id            com_api_type_pkg.t_tiny_id
   , oper_type                 com_api_type_pkg.t_dict_value
   , oper_date                 date
   , posting_date              date
   , amount                    com_api_type_pkg.t_money
   , currency                  com_api_type_pkg.t_curr_code
   , due_date                  date
   , aging                     com_api_type_pkg.t_tiny_id
   , gl_account_type           com_api_type_pkg.t_dict_value
   , overdue_date              date
);

type t_gl_account_numbers_ext_tab is table of t_gl_account_numbers_ext_rec index by binary_integer;

type t_active_account_ext_rec is record(
     account_id                com_api_type_pkg.t_account_id
   , account_number            com_api_type_pkg.t_account_number
   , split_hash                com_api_type_pkg.t_tiny_id
   , card_mask                 com_api_type_pkg.t_card_number
   , customer_number           com_api_type_pkg.t_name
   , national_id_type          com_api_type_pkg.t_dict_value
   , national_id               com_api_type_pkg.t_name
   , product_id                com_api_type_pkg.t_short_id
   , product_number            com_api_type_pkg.t_name
   , loan_for_year             com_api_type_pkg.t_short_id
   , aging                     com_api_type_pkg.t_tiny_id
);

type t_active_account_ext_tab is table of t_active_account_ext_rec index by binary_integer;

type t_link_account_balance_ext_rec is record(
     account_id                com_api_type_pkg.t_account_id
   , link_account_id           com_api_type_pkg.t_account_id
   , link_account_number       com_api_type_pkg.t_account_number
   , balance_amount            com_api_type_pkg.t_money
);

type t_link_account_balance_ext_tab is table of t_link_account_balance_ext_rec index by binary_integer;

end acc_api_type_pkg;
/
