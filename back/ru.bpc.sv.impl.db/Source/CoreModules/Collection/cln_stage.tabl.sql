create table cln_stage (
    id            number(8)
  , seqnum        number(4)
  , status        varchar2(8)
  , resolution    varchar2(8)
)
/
comment on table cln_stage is 'Collection case.'
/
comment on column cln_stage.id is 'Primary key.'
/
comment on column cln_stage.seqnum is 'Sequence number (for data integrity)'
/
comment on column cln_stage.status is 'Case status. Dictionary CNST'
/
comment on column cln_stage.resolution is 'Status resolution. Dictionary CNRN'
/
