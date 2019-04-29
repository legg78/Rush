create or replace force view com_ui_currency_vw as
select a.id
     , a.code
     , a.name
     , a.exponent
     , a.seqnum
     , com_api_i18n_pkg.get_text('com_currency', 'name', a.id, b.lang) currency_name
     , b.lang
  from com_currency a
     , com_language_vw b
order by a.code
/