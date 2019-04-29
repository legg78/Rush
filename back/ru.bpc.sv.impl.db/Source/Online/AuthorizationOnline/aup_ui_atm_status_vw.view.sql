create or replace force view aup_ui_atm_status_vw as
select s.id
     , s.tech_id
     , s.time_mark
     , s.device_id
     , com_api_dictionary_pkg.get_article_text(
            i_article     => s.device_id
          , i_lang        => l.lang
        ) as device_name
     , s.device_status
     , s.error_severity
     , s.diag_status
     , s.supplies_status
     , l.lang
  from aup_atm_status s, com_language_vw l
/
