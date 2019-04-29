create table aup_tag (
    id           number(8) not null
    , tag        number(8) not null
    , tag_type   varchar2(8) not null
    , seqnum     number(4)
    , reference  varchar2(200)
    , db_stored  number(1)
)
/
comment on table aup_tag is 'Table is used to store available tags for authorization message. Table is used as extended dictionary.'
/
comment on column aup_tag.id is 'Substitute identifier.'
/
comment on column aup_tag.tag is 'Tag value from 0x0001 to 0xFFFF.'
/
comment on column aup_tag.tag_type is 'Tag value type. Valid values are taken from dictionary ''ATTP''.'
/
comment on column aup_tag.seqnum is 'Sequential number of record version'
/
comment on column aup_tag.reference is 'External reference for tag'
/
comment on column aup_tag.db_stored is 'Srored tag in database'
/
