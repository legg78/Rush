create or replace force view com_dictionary_vw as
select a.id
     , a.dict
     , a.code
     , a.is_numeric
     , a.is_editable
     , a.inst_id
     , a.module_code
  from com_dictionary a
/