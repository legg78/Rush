create or replace force view sec_rsa_key_certificate_vw as
select
    c.id
    , c.seqnum
    , c.state
    , c.authority_id
    , c.certified_key_id
    , c.authority_key_id
    , c.certificate
    , c.reminder
    , c.hash
    , c.expir_date
    , c.tracking_number
    , c.subject_id
    , c.serial_number
    , c.visa_service_id
    , a.type authority_type
from
    sec_rsa_certificate_vw c
    , sec_authority_vw a
where
    c.certified_key_id = c.authority_key_id
    and a.id(+) = c.authority_id
/
