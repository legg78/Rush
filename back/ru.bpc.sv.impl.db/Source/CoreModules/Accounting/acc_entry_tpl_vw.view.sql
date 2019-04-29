create or replace force view acc_entry_tpl_vw as
select
    id
  , seqnum
  , bunch_type_id
  , transaction_type
  , transaction_num
  , negative_allowed
  , account_name
  , amount_name
  , date_name
  , posting_method
  , balance_type
  , balance_impact
  , dest_entity_type
  , dest_account_type
  , mod_id
from
    acc_entry_tpl
/

