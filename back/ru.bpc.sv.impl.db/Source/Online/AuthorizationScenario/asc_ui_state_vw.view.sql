create or replace force view asc_ui_state_vw as 
select a.id
     , a.code
     , a.state_type
     , a.scenario_id
     , a.seqnum
     , get_text('asc_state', 'description', a.id, b.lang) description
     , b.lang
  from asc_state a
     , com_language_vw b     
 where a.scenario_id != 0
/