create or replace force view aut_buffer_vw as
select * from aut_buffer#1
union all
select * from aut_buffer#2
/

