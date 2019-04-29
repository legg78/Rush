create or replace force view sec_api_rsa_key_terminal_vw as
select
    a.id
    , a.seqnum
    , a.object_id terminal_id
    , a.lmk_id
    , a.key_type
    , a.key_index
    , a.expir_date
    , a.sign_algorithm
    , a.modulus_length
    , a.exponent
    , a.public_key
    , a.private_key
    , a.public_key_mac
from
    sec_rsa_key_vw a
    , acq_terminal_vw b
where
    a.entity_type = 'ENTTTRMN'
    and a.object_id = b.id
/
