alter table crd_debt_interest add (constraint crd_debt_interest_pk primary key(id))
/
alter table crd_debt_interest drop primary key drop index
/
alter table crd_debt_interest add (constraint crd_debt_interest_pk primary key(id)
/****************** partition start ********************
    using index global
    partition by range (id)
(
    partition crd_debt_intrst_maxvalue values less than (maxvalue)
)
******************** partition end ********************/
)
/
