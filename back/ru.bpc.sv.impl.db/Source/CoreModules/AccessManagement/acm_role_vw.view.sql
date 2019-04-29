create or replace force view acm_role_vw as
select
    a.id
  , a.name
  , a.notif_scheme_id
  , a.inst_id
  , a.ext_name
from
    acm_role a
/
