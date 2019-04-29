create or replace force view sec_ui_hmac_key_vw as
select
    d.id
    , d.seqnum
    , d.object_id
    , d.entity_type
    , d.lmk_id
    , d.key_index
    , d.key_length
    , d.key_value
    , d.generate_date
    , acm_api_user_pkg.get_user_name(d.generate_user_id, 1) generate_user_name
from
    sec_hmac_key d
/
