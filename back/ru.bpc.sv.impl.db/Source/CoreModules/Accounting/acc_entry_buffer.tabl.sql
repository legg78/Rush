create table acc_entry_buffer (
    id                          number(16)
    , split_hash                number(4)
    , macros_id                 number(16)
    , bunch_id                  number(16)
    , transaction_id            number(16)
    , transaction_type          varchar2(8)
    , account_id                number(12)
    , amount                    number(22 , 5)
    , currency                  varchar2(3)
    , account_type              varchar2(8)
    , balance_type              varchar2(8)
    , balance_impact            number(1)
    , dest_entity_type          varchar2(8)
    , dest_account_type         varchar2(8)
    , dest_account_id           number(12)
    , reason                    varchar2(8)
    , posting_date              date
    , status                    varchar2(8)
)
/****************** partition start ********************
partition by list (split_hash)
(
    <partition_list>
)
******************** partition end ********************/
/
comment on table acc_entry_buffer is 'Buffer for storing entries to pump posting'
/
comment on column acc_entry_buffer.id is 'Entry identifier'
/
comment on column acc_entry_buffer.split_hash is 'Hash value to split further processing'
/
comment on column acc_entry_buffer.macros_id is 'Macros identifier which entry belongs to'
/
comment on column acc_entry_buffer.bunch_id is 'Bunch identifier'
/
comment on column acc_entry_buffer.transaction_id is 'Transaction identifier which entry belongs to'
/
comment on column acc_entry_buffer.transaction_type is 'Transaction type which entry belongs to'
/
comment on column acc_entry_buffer.account_id is 'Account identifier'
/
comment on column acc_entry_buffer.amount is 'Entry amount'
/
comment on column acc_entry_buffer.currency is 'Entry currency'
/
comment on column acc_entry_buffer.account_type is 'Entry account type (ACTP key)'
/
comment on column acc_entry_buffer.balance_type is 'Balance type which entry affects'
/
comment on column acc_entry_buffer.balance_impact is 'Impact of entry on balance'
/
comment on column acc_entry_buffer.dest_entity_type is 'Entity which account used to transform original account'
/
comment on column acc_entry_buffer.dest_account_type is 'Type of account which used to transform original account'
/
comment on column acc_entry_buffer.dest_account_id is 'Destination account to post entry'
/
comment on column acc_entry_buffer.reason is 'Exception reason'
/
comment on column acc_entry_buffer.posting_date is 'Targed date to post entry'
/
comment on column acc_entry_buffer.status is 'Buffer status (BUST dictionary)'
/
alter table acc_entry_buffer add (register_timestamp timestamp(6))
/
comment on column acc_entry_buffer.register_timestamp is 'Timestamp of registration'
/
alter table acc_entry_buffer drop column register_timestamp
/
