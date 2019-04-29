create table ost_forbidden_action
(
    id           number(8)
  , inst_status  varchar2(8)
  , data_action  varchar2(8)
)
/
comment on table ost_forbidden_action is 'Institution status forbidden actions.'
/
comment on column ost_forbidden_action.id is 'Primary key.'
/
comment on column ost_forbidden_action.inst_status is 'Sequence number. Describe data version.'
/
comment on column ost_forbidden_action.data_action is 'Reference to parent institution.'
/

comment on column ost_forbidden_action.inst_status is 'Institution status (INSS dictionary).'
/
comment on column ost_forbidden_action.data_action is 'Data action (DACT dictionary).'
/
