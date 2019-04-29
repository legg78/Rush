create or replace force view cmn_ui_standard_version_vw as
select s.id
     , s.standard_id
     , s.version_number
     , s.version_order
     , get_text('cmn_standard_version'
              , 'description'
              , s.id
              , l.lang) description
     , l.lang
     , s.seqnum               
  from cmn_standard_version s, com_language_vw l
/
