create table ntf_scheme (
    id              number(4)
    , seqnum        number(4)
    , scheme_type   varchar2(8)
    , inst_id       number(4)
)
/
comment on table ntf_scheme is 'Notification schemes.'
/
comment on column ntf_scheme.id is 'Primary key'
/
comment on column ntf_scheme.seqnum is 'Data version sequencial number.'
/
comment on column ntf_scheme.scheme_type is 'Notification scheme type.'
/
comment on column ntf_scheme.inst_id is 'Institution identifier.'
/

