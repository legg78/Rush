create table acc_iso_account_type (
    id              number(4)
    , seqnum        number(4)
    , account_type  varchar2(8)
    , inst_id       number(4)
    , iso_type      varchar2(8)
    , priority      number(4)
)
/
comment on column acc_iso_account_type.id is 'Record identifier'
/
comment on column acc_iso_account_type.seqnum is 'Data version number'
/
comment on column acc_iso_account_type.account_type is 'Account type'
/
comment on column acc_iso_account_type.inst_id is 'Institution identifier'
/
comment on column acc_iso_account_type.iso_type is 'ISO account type conformity'
/
comment on column acc_iso_account_type.priority is 'ISO account type conformity priority'
/
