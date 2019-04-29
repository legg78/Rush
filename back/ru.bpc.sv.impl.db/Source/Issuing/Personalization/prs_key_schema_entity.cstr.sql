alter table prs_key_schema_entity add constraint prs_key_schema_entity_pk primary key (
    id
)
/

create unique index prs_key_schema_entity on prs_key_schema_entity (
    key_schema_id
    , key_type
)
/ 
