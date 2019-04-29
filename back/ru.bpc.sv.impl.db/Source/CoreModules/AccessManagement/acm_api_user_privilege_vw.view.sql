create or replace force view acm_api_user_privilege_vw
as
  select ap.id as priv_id
       , ap.name as priv_name
       , ar.id as role_id
       , ar.name as role_name
       , arp.limit_id
  from   acm_privilege ap
       , acm_role_privilege arp
       , acm_role ar
       , (
            select distinct role_id from (
                select aur.role_id
                from   acm_user_role aur
                where  aur.user_id = acm_api_user_pkg.get_user_id
                union all
                select     arr.child_role_id
                from       acm_role_role arr
                connect by prior arr.child_role_id = arr.parent_role_id
                start with arr.parent_role_id in (
                    select aur.role_id
                    from   acm_user_role aur
                    where  aur.user_id = acm_api_user_pkg.get_user_id
                )
            )
         ) z
  where  ap.id = arp.priv_id
  and    arp.role_id = z.role_id
  and    arp.role_id = ar.id
/
