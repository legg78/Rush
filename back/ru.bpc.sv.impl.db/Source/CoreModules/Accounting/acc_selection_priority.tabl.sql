create table acc_selection_priority (
    id                  number(4)
    , seqnum            number(4)
    , inst_id           varchar2(8)
    , oper_type         varchar2(8)
    , account_type      varchar2(8)
    , account_status    varchar2(8)
    , party_type        varchar2(8)
    , priority          number(4)
)
/
comment on table acc_selection_priority is 'Priority of account usage depending on account and operation parameters'
/
comment on column acc_selection_priority.id is 'Record identifier'
/
comment on column acc_selection_priority.seqnum is 'Sequential number of record data version'
/
comment on column acc_selection_priority.inst_id is 'Institution identifier'
/
comment on column acc_selection_priority.oper_type is 'Operation type'
/
comment on column acc_selection_priority.account_type is 'Account type'
/
comment on column acc_selection_priority.account_status is 'Account status'
/
comment on column acc_selection_priority.party_type is 'Type of operation participant'
/
comment on column acc_selection_priority.priority is 'Priority'
/
alter table acc_selection_priority add (msg_type varchar2(8))
/
comment on column acc_selection_priority.msg_type is 'Message type (MSGT dictionary)'
/
alter table acc_selection_priority add (mod_id number(4))
/
comment on column acc_selection_priority.mod_id is 'Modifier identifier'
/
alter table acc_selection_priority add (account_currency  varchar2(3))
/
comment on column acc_selection_priority.account_currency is 'Account currency'
/
