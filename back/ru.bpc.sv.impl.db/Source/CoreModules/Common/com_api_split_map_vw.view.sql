create or replace force view com_api_split_map_vw as
select split_hash
  from com_split_map
 where get_thread_number in (thread_number, -1)
union all
select -1
  from dual
/ 