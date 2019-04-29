alter table sec_authority add constraint sec_authority_pk primary key (
    id
)
/

create unique index sec_authority_uk on sec_authority (
    type
)
/

create unique index sec_authority_rid on sec_authority (rid)
/
