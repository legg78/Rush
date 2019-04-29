create or replace force view rul_ui_mod_scale_param_vw as
select 
    p.*
    , l.lang
    , com_api_i18n_pkg.get_text('rul_mod_scale', 'name', p.scale_id, l.lang) scale_name
    , com_api_i18n_pkg.get_text('rul_mod_scale', 'description', p.scale_id, l.lang) scale_description
    , com_api_i18n_pkg.get_text('rul_mod_param', 'short_description', p.id, l.lang) param_short_description
    , com_api_i18n_pkg.get_text('rul_mod_param', 'description', p.id, l.lang) param_description
from 
    rul_mod_scale_param p
    , com_language_vw l
/