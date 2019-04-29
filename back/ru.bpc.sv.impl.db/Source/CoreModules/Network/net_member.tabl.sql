create table net_member (
    id               number(4)
  , seqnum           number(4)
  , network_id       number(4)
  , inst_id          number(4)
  , participant_type varchar2(8)
  , status           varchar2(8)
  , inactive_till    date
)
/

comment on table net_member is 'Networs member institutions'
/

comment on column net_member.id is 'Record identifier'
/

comment on column net_member.seqnum is 'Sequential number of record data version'
/

comment on column net_member.network_id is 'Network identifier'
/

comment on column net_member.inst_id is 'Institution identifier'
/

comment on column net_member.participant_type is 'Host participant type'
/

comment on column net_member.status is 'Host status (Active, Inactive). Applicable only for hosts.'
/

comment on column net_member.inactive_till is 'Until that date system will not use this host for sending financial transactions. Applicable only if current date less that date of inactivity.'
/
alter table net_member add scale_id number(4)
/
comment on column net_member.scale_id is 'Modifier scale which define interchange parametrization.'
/