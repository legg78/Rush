create table frp_case (
    id         number(4)
  , seqnum     number(4)
  , inst_id    number(4)
  , hist_depth number(4) )
/

comment on table frp_case is 'Fraud cases.'
/

comment on column frp_case.id is 'Primary key.'
/

comment on column frp_case.seqnum is 'Sequential number of data record version.'
/

comment on column frp_case.inst_id is 'Institution identifier. Case owner.'
/

comment on column frp_case.hist_depth is 'Maximum depth of authorizations history needed for the case.'
/