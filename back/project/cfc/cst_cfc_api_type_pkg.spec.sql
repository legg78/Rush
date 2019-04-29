create or replace package cst_cfc_api_type_pkg as
/*********************************************************
 *  API for types of CFC <br />
 *  Created by Chau Huynh (huynh@bpcbt.com) at 2017-12-04 <br />
 *  Module: CST_CFC_API_TYPE_PKG  <br />
 *  @headcom
 **********************************************************/

type t_scr_outgoing_rec is record (
    customer_number         com_api_type_pkg.t_account_number
  , customer_id             com_api_type_pkg.t_medium_id
  , account_number          com_api_type_pkg.t_account_number
  , account_id              com_api_type_pkg.t_account_id
  , card_id                 com_api_type_pkg.t_medium_id
  , split_hash              com_api_type_pkg.t_tiny_id
  , card_mask               com_api_type_pkg.t_card_number
  , category                com_api_type_pkg.t_boolean
  , status                  com_api_type_pkg.t_dict_value
  , sub_acct                com_api_type_pkg.t_account_number
);
type t_scr_outgoing_tab is table of t_scr_outgoing_rec index by binary_integer;

type t_event_id_tab is table of com_api_type_pkg.t_number_tab index by com_api_type_pkg.t_name;

type t_object_rec  is record(
    object_id               com_api_type_pkg.t_number_tab
  , event_id                t_event_id_tab
);
type t_entity_tab  is table of t_object_rec index by com_api_type_pkg.t_dict_value;

type t_col_rec is record (
    tag                     com_api_type_pkg.t_tag
  , tag_order               com_api_type_pkg.t_seqnum
  , customer_number         com_api_type_pkg.t_name
  , data_content            com_api_type_pkg.t_text
);

type t_col_tab is table of t_col_rec index by binary_integer;

type t_scr_info_rec is record (
    gen_date                date
  , card_limit              com_api_type_pkg.t_money
  , exceed_limit            com_api_type_pkg.t_money
  , sub_acct_bal            com_api_type_pkg.t_money
  , atm_wdr_cnt             com_api_type_pkg.t_medium_id
  , pos_cnt                 com_api_type_pkg.t_medium_id
  , all_trx_cnt             com_api_type_pkg.t_medium_id
  , atm_wdr_amt             com_api_type_pkg.t_money
  , pos_amt                 com_api_type_pkg.t_money
  , total_trx_amt           com_api_type_pkg.t_money
  , daily_repayment         com_api_type_pkg.t_money
  , cycle_repayment         com_api_type_pkg.t_money
  , current_dpd             com_api_type_pkg.t_seqnum
  , bucket                  com_api_type_pkg.t_byte_char
  , revised_bucket          com_api_type_pkg.t_byte_char
  , eff_date                com_api_type_pkg.t_date_long
  , expir_date              com_api_type_pkg.t_date_long
  , valid_period            com_api_type_pkg.t_byte_id
  , reason                  com_api_type_pkg.t_name
  , highest_bucket_01       com_api_type_pkg.t_byte_char
  , highest_bucket_03       com_api_type_pkg.t_byte_char
  , highest_bucket_06       com_api_type_pkg.t_byte_char
  , highest_dpd             com_api_type_pkg.t_seqnum
  , cycle_wdr_amt           com_api_type_pkg.t_money
  , total_debit_amt         com_api_type_pkg.t_money
  , cycle_avg_wdr_amt       com_api_type_pkg.t_money
  , cycle_daily_avg_usage   com_api_type_pkg.t_money
  , life_wdr_amt            com_api_type_pkg.t_money
  , life_wdr_cnt            com_api_type_pkg.t_medium_id
  , avg_wdr                 com_api_type_pkg.t_money
  , daily_usage             com_api_type_pkg.t_money
  , monthly_usage           com_api_type_pkg.t_money
  , tmp_crd_limit           com_api_type_pkg.t_money
  , limit_start_date        date
  , limit_end_date          date
  , card_usage_limit        com_api_type_pkg.t_money
  , total_debt              com_api_type_pkg.t_money
  , overdue_amt             com_api_type_pkg.t_money
  , first_wdr_date          date
  , overdue_interest        com_api_type_pkg.t_money
  , indue_interest          com_api_type_pkg.t_money
  , invoice_date            date
  , due_date                date
  , min_amount_due          com_api_type_pkg.t_money
  , cycle_wdr_cnt           com_api_type_pkg.t_long_id
);
type t_scr_info_tab is table of t_scr_info_rec index by binary_integer;

type t_scoring_rec is record (
    customer_number         com_api_type_pkg.t_account_number
  , account_number          com_api_type_pkg.t_account_number
  , card_mask               com_api_type_pkg.t_card_number
  , category                com_api_type_pkg.t_boolean
  , status                  com_api_type_pkg.t_dict_value
  , card_limit              com_api_type_pkg.t_money
  , invoice_date            date
  , due_date                date  
  , min_amount_due          com_api_type_pkg.t_money  
  , exceed_limit            com_api_type_pkg.t_money
  , sub_acct                com_api_type_pkg.t_account_number  
  , sub_acct_bal            com_api_type_pkg.t_money  
  , atm_wdr_cnt             com_api_type_pkg.t_medium_id
  , pos_cnt                 com_api_type_pkg.t_medium_id
  , all_trx_cnt             com_api_type_pkg.t_medium_id
  , atm_wdr_amt             com_api_type_pkg.t_money
  , pos_amt                 com_api_type_pkg.t_money
  , total_trx_amt           com_api_type_pkg.t_money
  , daily_repayment         com_api_type_pkg.t_money
  , cycle_repayment         com_api_type_pkg.t_money
  , current_dpd             com_api_type_pkg.t_seqnum
  , bucket                  com_api_type_pkg.t_byte_char
  , revised_bucket          com_api_type_pkg.t_byte_char
  , eff_date                com_api_type_pkg.t_date_long
  , expir_date              com_api_type_pkg.t_date_long
  , valid_period            com_api_type_pkg.t_byte_id
  , reason                  com_api_type_pkg.t_name
  , highest_bucket_01       com_api_type_pkg.t_byte_char
  , highest_bucket_03       com_api_type_pkg.t_byte_char
  , highest_bucket_06       com_api_type_pkg.t_byte_char
  , highest_dpd             com_api_type_pkg.t_seqnum
  , cycle_wdr_amt           com_api_type_pkg.t_money
  , total_debit_amt         com_api_type_pkg.t_money
  , cycle_avg_wdr_amt       com_api_type_pkg.t_money
  , cycle_daily_avg_usage   com_api_type_pkg.t_money
  , life_wdr_amt            com_api_type_pkg.t_money
  , life_wdr_cnt            com_api_type_pkg.t_medium_id
  , avg_wdr                 com_api_type_pkg.t_money
  , daily_usage             com_api_type_pkg.t_money
  , monthly_usage           com_api_type_pkg.t_money
  , tmp_crd_limit           com_api_type_pkg.t_money
  , limit_start_date        date
  , limit_end_date          date
  , card_usage_limit        com_api_type_pkg.t_money
  , overdue_interest        com_api_type_pkg.t_money
  , indue_interest          com_api_type_pkg.t_money  
  , split_hash              com_api_type_pkg.t_tiny_id
);
type t_scoring_tab is table of t_scoring_rec index by binary_integer;

end cst_cfc_api_type_pkg;
/
