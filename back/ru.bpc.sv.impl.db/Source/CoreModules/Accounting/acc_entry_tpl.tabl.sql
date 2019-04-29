create table acc_entry_tpl (
    id                          number(8)
    , seqnum                    number(4)
    , bunch_type_id             number(4)
    , transaction_type          varchar2(8)
    , transaction_num           number(4)
    , negative_allowed          number(1)
    , account_name              varchar2(30)
    , amount_name               varchar2(30)
    , date_name                 varchar2(30)
    , posting_method            varchar2(8)
    , balance_type              varchar2(8)
    , balance_impact            number(1)
    , dest_entity_type          varchar2(8)
    , dest_account_type         varchar2(8)
)
/
comment on table acc_entry_tpl is 'sets of entry templates are stored here'
/
comment on column acc_entry_tpl.id is 'identifier of row'
/
comment on column acc_entry_tpl.seqnum is 'Data version number'
/
comment on column acc_entry_tpl.bunch_type_id is 'Bunch type identifier'
/
comment on column acc_entry_tpl.transaction_type is 'transaction type'
/
comment on column acc_entry_tpl.transaction_num is 'transaction number (within set)'
/
comment on column acc_entry_tpl.negative_allowed is 'Flag that indicates that negative amount allowed and it causes swap of transaction sides'
/
comment on column acc_entry_tpl.account_name is 'name of account to use to post entry'
/
comment on column acc_entry_tpl.amount_name is 'name of amount to post entry'
/
comment on column acc_entry_tpl.date_name is 'name of date to post entry'
/
comment on column acc_entry_tpl.posting_method is 'Method of entry posting (POST dictionary)'
/
comment on column acc_entry_tpl.balance_type is 'type of balance to post entry'
/
comment on column acc_entry_tpl.balance_impact is 'impact of entry on balance'
/
comment on column acc_entry_tpl.balance_impact is 'Entity which account used to transform original account'
/
comment on column acc_entry_tpl.balance_impact is 'Type of account which used to transform original account'
/
comment on column acc_entry_tpl.dest_entity_type is 'Entity which account used to transform original account'
/
comment on column acc_entry_tpl.dest_account_type is 'Type of account which used to transform original account'
/


alter table acc_entry_tpl add (mod_id  number(4))
/
comment on column acc_entry_tpl.mod_id is 'Modifier identifier'
/