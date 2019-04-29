create or replace force view com_ui_language_vw as
select
    a.code
    , com_api_i18n_pkg.get_text('com_dictionary', 'name', a.id, b.lang) name
    , b.lang
from (
    select
        id
        , dict||code code
    from
        com_dictionary a 
    where
        dict = 'LANG' 
    ) a
    , com_language_vw b
/
