create or replace force view com_api_dictionary_vw as
select a.id
     , a.dict
     , a.code
     , a.is_numeric
     , a.is_editable
     , get_text ('com_dictionary', 'name', a.id, l.lang) name
     , get_text ('com_dictionary', 'description', a.id, l.lang) description
     , a.inst_id
     , a.module_code
     , l.lang
  from com_dictionary a
     , com_language_vw l
/
