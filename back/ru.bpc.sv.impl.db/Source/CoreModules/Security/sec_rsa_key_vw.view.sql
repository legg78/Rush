create or replace force view sec_rsa_key_vw as
select
    k.id
    , k.seqnum
    , k.object_id
    , k.entity_type
    , k.lmk_id
    , k.key_type
    , k.key_index
    , k.expir_date
    , k.sign_algorithm
    , k.modulus_length
    , k.exponent
    , k.public_key
    , k.private_key
    , k.public_key_mac
    , k.standard_key_type
    , k.generate_date
    , k.generate_user_id
from
    sec_rsa_key k
/
