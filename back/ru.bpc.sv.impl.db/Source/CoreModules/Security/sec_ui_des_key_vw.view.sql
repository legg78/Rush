create or replace force view sec_ui_des_key_vw as
select
    d.id
    , d.seqnum
    , d.object_id
    , d.entity_type
    , d.lmk_id
    , d.key_type
    , d.key_index
    , d.key_length
    , d.key_value
    , 'ENKP' || d.key_prefix key_prefix
    , d.check_value
    , d.standard_key_type
    , d.generate_date
    , acm_api_user_pkg.get_user_name(d.generate_user_id, 1) generate_user_name
from
    sec_des_key d
/
