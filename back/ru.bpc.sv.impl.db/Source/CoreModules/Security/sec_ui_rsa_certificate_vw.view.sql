create or replace force view sec_ui_rsa_certificate_vw as
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
from
    sec_rsa_certificate c
/
