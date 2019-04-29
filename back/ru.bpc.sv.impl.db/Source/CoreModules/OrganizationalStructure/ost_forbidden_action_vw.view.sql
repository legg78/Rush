create or replace force view ost_forbidden_action_vw as
select id
     , inst_status
     , data_action
 from ost_forbidden_action
/
