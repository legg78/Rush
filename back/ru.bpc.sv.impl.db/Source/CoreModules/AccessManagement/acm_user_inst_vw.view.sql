create or replace force view acm_user_inst_vw
as
  select a.id
       , a.user_id
       , a.inst_id
       , a.is_default
       , a.is_entirely
  from   acm_user_inst a
       , ost_institution b
  where  a.inst_id = b.id
/
