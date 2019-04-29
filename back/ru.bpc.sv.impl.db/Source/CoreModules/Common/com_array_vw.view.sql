create or replace force view com_array_vw as
select id
     , seqnum
     , array_type_id
     , inst_id
     , mod_id
     , agent_id
     , is_private
  from com_array
/
