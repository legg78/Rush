create table net_sttl_map (
    id                  number(4)
  , seqnum            number(4)
  , iss_inst_id       number(4)
  , iss_network_id    number(4)
  , acq_inst_id       number(4)
  , acq_network_id    number(4)
  , card_inst_id      number(4)
  , card_network_id   number(4)
  , mod_id            number(4)
  , priority          number(4)
  , sttl_type         varchar2(8)
  , match_status      varchar2(8)
)
/
comment on table net_sttl_map is 'mapping of institutions and networks into settlement type'
/

comment on column net_sttl_map.seqnum is 'Sequence number. Describe data version.'
/
comment on column net_sttl_map.id is 'Record identifier'
/
comment on column net_sttl_map.iss_inst_id is 'Issuer institution identifier'
/
comment on column net_sttl_map.acq_inst_id is 'Acquirer institution identifier'
/
comment on column net_sttl_map.card_inst_id is 'Card owner institution identifier'
/
comment on column net_sttl_map.iss_network_id is 'Issuer network identifier'
/
comment on column net_sttl_map.acq_network_id is 'Acquirer network identifier'
/
comment on column net_sttl_map.card_network_id is 'Card owner network identifier'
/
comment on column net_sttl_map.mod_id is 'Modifier'
/
comment on column net_sttl_map.sttl_type is 'Settlement type'
/
comment on column net_sttl_map.match_status is 'Necessity of matching between authorizations and presentments'
/
comment on column net_sttl_map.priority is 'Priority'
/
alter table net_sttl_map add oper_type varchar2(8)
/
comment on column net_sttl_map.oper_type is 'Operation type (OPTP dictionary)'
/
