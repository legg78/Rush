create or replace force view acm_ui_role_role_vw as
select
    a.id
  , a.parent_role_id
  , a.child_role_id
from
    acm_role_role a
/
