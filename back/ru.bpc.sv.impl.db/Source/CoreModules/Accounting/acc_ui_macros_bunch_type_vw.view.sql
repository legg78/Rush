create or replace force view acc_ui_macros_bunch_type_vw as
select t.id
     , t.bunch_type_id
     , t.seqnum
     , t.status
     , t.inst_id
     , get_text('ost_institution', 'name', t.inst_id, l.lang) as inst_name
     , l.lang
     , get_text('acc_macros_type', 'name', t.id, l.lang) as name
     , get_text('acc_macros_type', 'description', t.id, l.lang) as description
     , get_text('acc_macros_type', 'details', t.id, l.lang) as details
  from acc_macros_bunch_type t
     , com_language_vw l
/
