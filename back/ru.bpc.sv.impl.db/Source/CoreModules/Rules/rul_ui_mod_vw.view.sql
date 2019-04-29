create or replace force view rul_ui_mod_vw as
select
    m.*
    , l.lang
    , com_api_i18n_pkg.get_text('rul_mod', 'name', m.id, l.lang) name
    , com_api_i18n_pkg.get_text('rul_mod', 'description', m.id, l.lang) description
from 
    rul_mod m
    , com_language_vw l
/
