create or replace force view com_lov_vw as
select id
     , dict
     , lov_query
     , module_code
     , sort_mode
     , appearance
     , data_type
     , is_parametrized
     , is_depended
     , is_editable
  from com_lov
/
