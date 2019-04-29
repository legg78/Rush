create or replace force view com_ui_lov_vw as
select a.id
     , a.dict
     , a.lov_query
     , a.module_code
     , a.sort_mode
     , a.appearance
     , a.data_type
     , a.is_parametrized
     , com_api_i18n_pkg.get_text('com_lov', 'name', a.id, b.lang) name
     , b.lang
     , a.is_editable
  from com_lov a
     , com_language_vw b
/