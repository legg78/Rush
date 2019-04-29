alter table crd_debt_payment add (constraint crd_debt_payment_pk primary key(id))
/
alter table crd_debt_payment drop primary key drop index
/
alter table crd_debt_payment add (constraint crd_debt_payment_pk primary key(id)
/****************** partition start ********************
    using index global
    partition by range (id)
(
    partition crd_debt_pay_maxvalue values less than (maxvalue)
)
******************** partition end ********************/
)
/
