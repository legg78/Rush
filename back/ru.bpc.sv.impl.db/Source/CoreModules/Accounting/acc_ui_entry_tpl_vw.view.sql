create or replace force view acc_ui_entry_tpl_vw as
select
    min(decode(balance_impact, -1, bunch_type_id,  bunch_type_id))  bunch_type_id
    , min(decode(balance_impact, -1, transaction_num, transaction_num)) transaction_num
    , min(decode(balance_impact, -1, transaction_type, transaction_type)) transaction_type
    , min(decode(balance_impact, -1, negative_allowed, negative_allowed)) negative_allowed
    , min(decode(balance_impact, -1, amount_name, amount_name)) amount_name
    , min(decode(balance_impact, -1, date_name, date_name)) date_name
    , min(decode(balance_impact, -1, id, null)) debit_id
    , min(decode(balance_impact, -1, seqnum, null)) debit_seqnum
    , min(decode(balance_impact, -1, -1, null)) debit
    , min(decode(balance_impact, -1, amount_name, null)) debit_amount_name
    , min(decode(balance_impact, -1, account_name, null)) debit_account
    , min(decode(balance_impact, -1, posting_method, null)) debit_posting_method
    , min(decode(balance_impact, -1, balance_type, null)) debit_balance
    , min(decode(balance_impact, -1, dest_entity_type, null)) debit_dest_entity_type
    , min(decode(balance_impact, -1, dest_account_type, null)) debit_dest_account_type
    , min(decode(balance_impact, -1, mod_id, null)) debit_mod_id
    , min(decode(balance_impact, 1, id, null)) credit_id
    , min(decode(balance_impact, 1, seqnum, null)) credit_seqnum
    , min(decode(balance_impact, 1, 1, null)) credit
    , min(decode(balance_impact, 1, amount_name, null)) credit_amount_name
    , min(decode(balance_impact, 1, account_name, null)) credit_account
    , min(decode(balance_impact, 1, posting_method, null)) credit_posting_method
    , min(decode(balance_impact, 1, balance_type, null)) credit_balance
    , min(decode(balance_impact, 1, dest_entity_type, null)) credit_dest_entity_type
    , min(decode(balance_impact, 1, dest_account_type, null)) credit_dest_account_type
    , min(decode(balance_impact, 1, mod_id, null)) credit_mod_id
    , nvl(
          get_text(
              i_table_name    => 'rul_mod'
            , i_column_name   => 'description'
            , i_object_id     => min(decode(balance_impact, 1, mod_id, null))
            , i_lang          => get_user_lang
          )
         , get_text(
              i_table_name    => 'rul_mod'
            , i_column_name   => 'name'
            , i_object_id     => min(decode(balance_impact, 1, mod_id, null))
            , i_lang          => get_user_lang
          )
      ) credit_mod_desc
    , nvl(
          get_text(
              i_table_name    => 'rul_mod'
            , i_column_name   => 'description'
            , i_object_id     => min(decode(balance_impact, -1, mod_id, null))
            , i_lang          => get_user_lang
          )
         , get_text(
              i_table_name    => 'rul_mod'
            , i_column_name   => 'name'
            , i_object_id     => min(decode(balance_impact, -1, mod_id, null))
            , i_lang          => get_user_lang
          )
      ) debit_mod_desc
from
    acc_entry_tpl
group by
    bunch_type_id, transaction_num, mod_id
/
