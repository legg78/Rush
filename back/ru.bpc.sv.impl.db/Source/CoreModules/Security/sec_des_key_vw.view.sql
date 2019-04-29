create or replace force view sec_des_key_vw as
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
    , d.key_prefix
    , d.check_value
    , d.standard_key_type
    , d.generate_date
    , d.generate_user_id
from
    sec_des_key d
/