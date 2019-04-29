create or replace force view acm_ui_role_user_vw as
select u.user_id
     , u.user_name
     , u.user_status
     , u.person_id
     , u.lang
     , u.title
     , u.first_name
     , u.second_name
     , u.surname
     , u.suffix
     , u.gender
     , u.birthday
     , r.role_id
     , r.grant_type
     , u.place_of_birth
     , u.creation_date
     , u.auth_scheme
  from acm_ui_user_vw u
  , (select d.user_id
          , d.role_id
          , 'DIRECT' as grant_type
       from acm_user_role d
      union
     select user_id
          , role_id
          , grant_type
       from(select connect_by_root a.user_id as user_id
                 , b.child_role_id role_id
                 , 'SUBROLES' as grant_type
              from acm_user_role a
                 , acm_role_role b
             where a.role_id = b.parent_role_id
        connect by prior  b.child_role_id = b.parent_role_id)
      where (user_id, role_id) not in (select user_id, role_id from acm_user_role)) r
where u.user_id = r.user_id
/