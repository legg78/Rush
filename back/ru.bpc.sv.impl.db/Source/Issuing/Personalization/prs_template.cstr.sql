alter table prs_template add constraint prs_template_pk primary key (
    id
)
/
create unique index prs_template_uk on prs_template (
    method_id
    , entity_type
)
/
drop index prs_template_uk
/
create index prs_template_uk on prs_template (method_id, entity_type, mod_id)
/
