create or replace force view rul_ui_name_base_param_vw as
select 
    p.*
    , l.lang
    , com_api_i18n_pkg.get_text('rul_name_base_param', 'description', p.id, l.lang) description
from 
    rul_name_base_param p
    , com_language_vw l
/