create or replace force view rul_ui_mod_param_vw as
select m.*
     , l.lang
     , com_api_i18n_pkg.get_text('rul_mod_param', 'short_description', m.id, l.lang) short_description
     , com_api_i18n_pkg.get_text('rul_mod_param', 'description', m.id, l.lang) description
  from rul_mod_param m
     , com_language_vw l
/