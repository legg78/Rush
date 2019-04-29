create or replace force view acc_selection_priority_vw as
select id
     , seqnum
     , inst_id
     , oper_type
     , account_type
     , account_status
     , party_type
     , priority
     , msg_type
     , mod_id
     , account_currency 
from acc_selection_priority
/
