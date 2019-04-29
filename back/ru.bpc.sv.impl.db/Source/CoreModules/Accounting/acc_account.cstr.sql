alter table acc_account add (
    constraint acc_account_pk primary key (id)
  , constraint acc_account_uk unique (account_number, inst_id)
)
/
