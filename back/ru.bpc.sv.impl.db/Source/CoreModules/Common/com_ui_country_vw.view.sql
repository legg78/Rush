create or replace force view com_ui_country_vw as
select
    a.id
    , a.seqnum
    , a.code
    , a.name
    , a.curr_code
    , a.visa_country_code
    , a.mastercard_region
    , a.mastercard_eurozone
    , a.visa_region
    , b.lang
    , com_api_i18n_pkg.get_text('com_country', 'name', a.id, b.lang) country_name
from
    com_country a
    , com_language_vw b
/

