create or replace force view acc_account_type_vw as
select a.id
     , a.seqnum
     , a.account_type
     , a.inst_id
     , a.number_format_id
     , a.number_prefix
     , a.product_type 
from acc_account_type a
/