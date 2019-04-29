create or replace force view ost_ui_forbidden_action_vw as
select a.id
     , a.inst_status
     , a.data_action
     , l.lang
 from ost_forbidden_action a
    , com_language_vw l
/
