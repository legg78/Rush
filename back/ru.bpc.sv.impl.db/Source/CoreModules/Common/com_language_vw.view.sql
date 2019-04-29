create or replace force view com_language_vw as
select a.dict||a.code lang
     , com_api_i18n_pkg.get_text('com_dictionary', 'name', a.id) name
  from com_dictionary a 
 where dict = 'LANG' 
/