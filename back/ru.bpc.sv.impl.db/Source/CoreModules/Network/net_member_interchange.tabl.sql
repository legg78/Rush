create table net_member_interchange (
    id          number(4) not null
    , seqnum    number(4)
    , mod_id    number(4)
    , value     varchar2(2)
)
/
comment on table net_member_interchange is 'Match modifier with code interchange'
/
comment on column net_member_interchange.id is 'Match identifier'
/
comment on column net_member_interchange.seqnum is 'Sequential number of record version'
/
comment on column net_member_interchange.mod_id is 'Modifier identifier'
/
comment on column net_member_interchange.value is 'Interchange rate designator'
/