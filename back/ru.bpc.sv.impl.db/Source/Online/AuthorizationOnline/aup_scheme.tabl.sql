create table aup_scheme
(
    id                  number(4)
  , seqnum              number(4)
  , scheme_type         varchar2(8)
  , inst_id             number(4)
  , scale_id            number(4)
  , resp_code           varchar2(8)
)
/

comment on table aup_scheme is 'Authorization scheme'
/

comment on column aup_scheme.id is 'Primary key.'
/

comment on column aup_scheme.seqnum is 'Sequential number of data version'
/

comment on column aup_scheme.scheme_type is 'Type of authorization scheme (Positive, Negative, Positive-Negative, Negative-Positive)'
/

comment on column aup_scheme.inst_id is 'Institution identifier'
/

comment on column aup_scheme.scale_id is 'Reference to modifier scale.'
/

comment on column aup_scheme.resp_code is 'Default response code returning if authorization not correspond with scheme.'
/

alter table aup_scheme add (system_name varchar2(200))
/

comment on column aup_scheme.system_name is 'Scheme system name.'
/
