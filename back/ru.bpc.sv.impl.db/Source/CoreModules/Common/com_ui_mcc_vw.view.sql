create or replace force view com_ui_mcc_vw as
select a.id
     , a.seqnum
     , a.mcc
     , a.tcc
     , a.diners_code
     , a.mastercard_cab_type
     , com_api_i18n_pkg.get_text('com_mcc', 'name', a.id, b.lang) name
     , b.lang
  from com_mcc a, com_language_vw b
/