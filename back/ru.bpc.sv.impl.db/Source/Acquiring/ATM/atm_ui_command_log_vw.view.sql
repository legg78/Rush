create or replace force view atm_ui_command_log_vw as
select terminal_id
     , command_date
     , command
     , get_article_text(i_article => command, i_lang => l.lang) command_name
     , command_result
     , get_article_text(i_article => command_result, i_lang => l.lang) command_result_name
     , user_id
     , com_ui_person_pkg.get_person_name(i_person_id => u.person_id, i_lang => l.lang) user_name 
     , l.lang
  from atm_command_log a
     , acm_user u
     , com_language_vw l
 where a.user_id = u.id
/ 