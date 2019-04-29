create or replace force view sec_api_rsa_certificate_vw as
select
    c.*
    , a.type authority_type
from
    sec_rsa_certificate_vw c
    , sec_authority_vw a
where
    c.certified_key_id = c.authority_key_id
    and a.id(+) = c.authority_id
/
