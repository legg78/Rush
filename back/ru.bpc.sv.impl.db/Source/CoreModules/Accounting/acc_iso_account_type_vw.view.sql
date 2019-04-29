create or replace force view acc_iso_account_type_vw as
select
    id
  , seqnum
  , account_type
  , inst_id
  , iso_type
  , priority
from
    acc_iso_account_type
/
