create or replace force view com_ui_label_vw as
select
      lb.id
    , lb.name
    , lb.label_type
    , lb.module_code
    , lb.env_variable  
    , lg.lang
    , com_api_i18n_pkg.get_text('com_label', 'name', lb.id, lg.lang) text
from
    com_label lb
    , com_language_vw lg
/
