alter table crd_debt_balance add (constraint crd_debt_balance_pk primary key (id))
/
alter table crd_debt_balance drop primary key drop index
/
alter table crd_debt_balance add (constraint crd_debt_balance_pk primary key(id)
/****************** partition start ********************
    using index global
    partition by range (id)
(
    partition crd_debt_balance_maxvalue values less than (maxvalue)
)
******************** partition end ********************/
)
/
