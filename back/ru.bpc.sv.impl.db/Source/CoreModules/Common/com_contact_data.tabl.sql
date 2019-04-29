create table com_contact_data (
    id                number(12) not null
    , contact_id      number(12) not null
    , commun_method   varchar2(8) not null
    , commun_address  varchar2(200)
    , start_date      date
    , end_date        date
)
/

comment on table com_contact_data is 'Contact data'
/
comment on column com_contact_data.id is 'Primary key'
/
comment on column com_contact_data.contact_id is 'Reference to contact'
/
comment on column com_contact_data.commun_method is 'Communication method (mobile, e-mail, instant messenger)'
/
comment on column com_contact_data.commun_address is 'Communication address (mobile phone number, e-mail address)'
/
comment on column com_contact_data.start_date is 'Start date of address validity'
/
comment on column com_contact_data.end_date is 'End date of address validity'
/
