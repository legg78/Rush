create or replace force view rul_ui_rule_set_vw as
select 
    s.*
    , b.lang
    , com_api_i18n_pkg.get_text('rul_rule_set', 'name', s.id, b.lang) name 
from 
    rul_rule_set s
    , com_language_vw b
/