create or replace force view atm_ui_status_log_vw as
select a.terminal_id
     , a.change_date
     , a.status
     , get_article_text(i_article => a.status, i_lang => l.lang) status_name
     , l.lang
  from atm_status_log a
     , com_language_vw l
/