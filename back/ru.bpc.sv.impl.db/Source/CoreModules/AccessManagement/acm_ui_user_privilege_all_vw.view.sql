create or replace force view acm_ui_user_privilege_all_vw as 
select
    r.user_id
  , arp.role_id
  , arp.limit_id
  , arp.priv_id
  , ap.name as priv_name
  , ap.section_id
  , ap.short_desc
  , ap.full_desc
  , ap.lang
  , ap.module_code
  , ap.is_active
from
    acm_role_privilege arp
  , acm_ui_privilege_vw ap
  , (select
         d.user_id
       , d.role_id
       , 'DIRECT' as grant_type
     from
         acm_user_role d
     union
     select
         user_id
       , role_id
       , grant_type
     from (
         select
             a.user_id
           , b.child_role_id role_id
           , 'SUBROLES' as grant_type
         from
             acm_user_role a
           , acm_role_role b
         where
             a.role_id = b.parent_role_id
         connect by
             prior  b.child_role_id = b.parent_role_id
          )
     where
         (user_id, role_id) not in (select user_id, role_id from acm_user_role)
    ) r
where
    arp.role_id = r.role_id
and
    ap.id = arp.priv_id
/
