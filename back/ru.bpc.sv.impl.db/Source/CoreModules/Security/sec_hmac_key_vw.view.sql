create or replace force view sec_hmac_key_vw as
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
    , d.generate_user_id
from
    sec_hmac_key d
/