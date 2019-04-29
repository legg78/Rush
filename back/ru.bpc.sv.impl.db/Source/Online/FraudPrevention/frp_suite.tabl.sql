create table frp_suite (
    id          number(4)
  , seqnum      number(4)
  , entity_type varchar2(8)
  , inst_id     number(4))
/

comment on table frp_suite is 'Set of cases execute for exact entity.'
/

comment on column frp_suite.id is 'Primary key.'
/

comment on column frp_suite.seqnum is 'Sequential number of data record version.'
/

comment on column frp_suite.entity_type is 'Entity type.'
/

comment on column frp_suite.inst_id is 'Institution identifier. Suite owner.'
/