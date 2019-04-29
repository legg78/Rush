alter table crd_debt add (constraint crd_debt_pk primary key(id))
/
alter table crd_debt drop primary key drop index
/
alter table crd_debt add (constraint crd_debt_pk primary key(id)
/****************** partition start ********************
    using index global
    partition by range (id)
(
    partition crd_debt_maxvalue values less than (maxvalue)
)
******************** partition end ********************/
)
/
