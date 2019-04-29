create or replace force view ntb_ui_note_vw as
select n.id
     , n.entity_type
     , n.object_id
     , n.note_type
     , n.reg_date
     , n.user_id
     , acm_ui_user_pkg.get_user_full_name(user_id) user_fill_name
     , b.lang
     , com_api_i18n_pkg.get_text('ntb_note', 'header', n.id, b.lang) header
     , com_api_i18n_pkg.get_text('ntb_note', 'text', n.id, b.lang) text
     , n.start_date
     , n.end_date
  from ntb_note n
     , com_language_vw b
/
