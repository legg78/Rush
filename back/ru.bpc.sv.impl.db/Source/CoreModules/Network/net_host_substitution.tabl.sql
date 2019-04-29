create table net_host_substitution
(
    id                          number(12)
  , seqnum                      number(4)
  , oper_type                   varchar2(8)
  , terminal_type               varchar2(8)
  , pan_low                     varchar2(24)
  , pan_high                    varchar2(24)
  , acq_inst_id                 varchar2(4)
  , acq_network_id              varchar2(4)
  , card_inst_id                varchar2(4)
  , card_network_id             varchar2(4)
  , iss_inst_id                 varchar2(4)
  , iss_network_id              varchar2(4)
  , priority                    number(4)
  , substitution_inst_id        varchar2(4)
  , substitution_network_id     varchar2(4)
)
/

comment on table net_host_substitution is 'Substitution network host'
/

comment on column net_host_substitution.id is 'Primary key'
/

comment on column net_host_substitution.seqnum is 'Sequence number. Describe data version.'
/

comment on column net_host_substitution.terminal_type is 'Terminal type'
/

comment on column net_host_substitution.oper_type is 'Operation type'
/

comment on column net_host_substitution.pan_low is 'Range low value.'
/

comment on column net_host_substitution.pan_high is 'Range high value.'
/

comment on column net_host_substitution.acq_inst_id is 'Acquirer institution identifier'
/

comment on column net_host_substitution.acq_network_id is 'Acquirer network identifier.'
/

comment on column net_host_substitution.card_inst_id is 'Card institution identifier.'
/

comment on column net_host_substitution.card_network_id is 'Card network identifier.'
/

comment on column net_host_substitution.iss_inst_id is 'Issuing institution identifier.'
/

comment on column net_host_substitution.iss_network_id is 'Issuing network identifier.'
/

comment on column net_host_substitution.priority is 'Priority.'
/

comment on column net_host_substitution.substitution_inst_id is 'Substitution institution identifier.'
/

comment on column net_host_substitution.substitution_network_id is 'Substitution network identifier.'
/

alter table net_host_substitution add msg_type varchar2(8)
/
comment on column net_host_substitution.msg_type is 'Message type (MSGT dictionary).'
/
alter table net_host_substitution add oper_reason varchar2(8)
/
comment on column net_host_substitution.oper_reason is 'Operation reason (fee type or adjustment type)'
/
alter table net_host_substitution add oper_currency varchar2(3)
/
comment on column net_host_substitution.oper_currency is 'Operation currency'
/
alter table net_host_substitution add merchant_array_id varchar2(8)
/
comment on column net_host_substitution.merchant_array_id is 'Merchant array identifier'
/
alter table net_host_substitution add terminal_array_id varchar2(8)
/
comment on column net_host_substitution.terminal_array_id is 'Terminal array identifier'
/

alter table net_host_substitution add card_country varchar2(3)
/
comment on column net_host_substitution.card_country is 'Card country code'
/
