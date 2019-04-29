create table sec_rsa_certificate (
    id                      number(12)
    , seqnum                number(4)
    , state                 varchar2(8)
    , authority_id          number(4)
    , certified_key_id      number(12)
    , authority_key_id      number(12)
    , certificate           varchar2(2048)
    , reminder              varchar2(2048)
    , hash                  varchar2(2048)
    , expir_date            date
    , tracking_number       number(6)
    , subject_id            varchar2(10)
    , serial_number         number(6)
    , visa_service_id       varchar2(8)
)
/
comment on table sec_rsa_certificate is 'RSA certificates'
/
comment on column sec_rsa_certificate.id is 'Certificate identifier'
/
comment on column sec_rsa_certificate.seqnum is 'Sequential number of data version'
/
comment on column sec_rsa_certificate.state is 'RSA certificate state'
/
comment on column sec_rsa_certificate.authority_id is 'Authority identifier'
/
comment on column sec_rsa_certificate.certified_key_id is 'Identifier of key certified'
/
comment on column sec_rsa_certificate.authority_key_id is 'Identifier of authority key'
/
comment on column sec_rsa_certificate.certificate is 'Certificate'
/
comment on column sec_rsa_certificate.reminder is 'Certified key reminder'
/
comment on column sec_rsa_certificate.hash is 'Certificate hash'
/
comment on column sec_rsa_certificate.expir_date is 'Certificate expiration date'
/
comment on column sec_rsa_certificate.tracking_number is 'Certificate request number or member identifier assigned by certificate authority'
/
comment on column sec_rsa_certificate.subject_id is 'Identifier of certificate subject'
/
comment on column sec_rsa_certificate.serial_number is 'Certificate serial number assigned by certificate authority'
/
comment on column sec_rsa_certificate.visa_service_id is 'Identifies specific Visa Service'
/
alter table sec_rsa_certificate modify (serial_number varchar2(6 char))
/
