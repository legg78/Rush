create or replace force view acm_cu_inst_vw as
select inst_id
     , is_default
     , is_entirely      
  from acm_user_inst_mvw
 where user_id = get_user_id
/
