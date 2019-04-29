create table acc_account_object (
    id              number(16)  not null
    , object_id     number(16)  not null
    , account_id    number(12)  not null
    , entity_type   varchar2(8) not null
    , usage_order   number(4)   not null
    , split_hash    number(4)
)
/****************** partition start ********************
partition by list (split_hash)
(
    <partition_list>
)
******************** partition end ********************/
/

comment on table acc_account_object is 'Links between objects and account are stored here.'
/
comment on column acc_account_object.id is 'Identifier.'
/
comment on column acc_account_object.object_id is 'Object identifier.'
/
comment on column acc_account_object.account_id is 'Account identifier.'
/
comment on column acc_account_object.entity_type is 'Object entity type.'
/
comment on column acc_account_object.usage_order is 'Usage order of account.'
/
comment on column acc_account_object.split_hash is 'Hash value to split further processing'
/
alter table acc_account_object add (is_pos_default number(1), is_atm_default number(1))
/
comment on column acc_account_object.is_pos_default is 'Is default account for POS.'
/
comment on column acc_account_object.is_atm_default is 'Is default account for ATM.'
/
alter table acc_account_object add is_atm_currency number(1)
/
alter table acc_account_object add is_pos_currency number(1)
/
comment on column acc_account_object.is_atm_currency is 'ATM default account per currency flag.'
/
comment on column acc_account_object.is_pos_currency is 'POS default account per currency flag.'
/
alter table acc_account_object add (account_seq_number number(2))
/
comment on column acc_account_object.account_seq_number is 'Account sequential number in relation to associated entity object'
/
alter table acc_account_object enable row movement
/

