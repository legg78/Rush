create or replace force view acc_ui_bunch_type_vw as
select s.id
     , s.seqnum
     , s.inst_id
     , l.lang
     , get_text ('OST_INSTITUTION', 'NAME', s.inst_id, l.lang) inst_name
     , com_api_i18n_pkg.get_text('acc_bunch_type', 'name', s.id, l.lang) name
     , com_api_i18n_pkg.get_text('acc_bunch_type', 'description', s.id, l.lang) description
     , com_api_i18n_pkg.get_text('acc_bunch_type', 'details', s.id, l.lang) details
  from acc_bunch_type s
     , com_language_vw l
/
