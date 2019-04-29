create table prs_template (
    id                  number(4)
    , seqnum            number(4)
    , method_id         number(4)
    , entity_type       varchar2(8)
    , format_id         number(4)
)
/
comment on table prs_template is 'Formats of personalization data'
/
comment on column prs_template.id is 'Record identifier'
/
comment on column prs_template.seqnum is 'Sequential number of record data version'
/
comment on column prs_template.method_id is 'Personalization method identifier'
/
comment on column prs_template.entity_type is 'Entity type which format relates to'
/
comment on column prs_template.format_id is 'Format identifier'
/
alter table prs_template add mod_id number(4)
/
comment on column prs_template.mod_id is 'Modifier identifier'
/
