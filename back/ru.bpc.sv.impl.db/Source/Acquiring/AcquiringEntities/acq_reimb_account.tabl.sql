create table acq_reimb_account(
    id                  number(12)
  , channel_id          number(4)           not null
  , account_id          number(12)          not null
  , split_hash          number(4)
)
/****************** partition start ********************
partition by list (split_hash)
(
    <partition_list>
)
******************** partition end ********************/
/

comment on table acq_reimb_account is 'Link accounts with reimbursement channels. Relation One channel-to-Many accounts.'
/

comment on column acq_reimb_account.id is 'Primary key.'
/
comment on column acq_reimb_account.channel_id is 'Reference to channel.'
/
comment on column acq_reimb_account.account_id is 'Reference to account.'
/
comment on column acq_reimb_account.split_hash is 'Split hash value.'
/
