create or replace force view acc_scheme_account_vw as
select
    a.id
  , a.seqnum
  , a.scheme_id
  , a.account_type
  , a.entity_type
  , a.object_id
  , a.mod_id
  , a.account_id
from
    acc_scheme_account a
/
