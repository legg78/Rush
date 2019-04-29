alter table crd_invoice_payment add (constraint crd_invoice_pay_pk primary key(id))
/
alter table crd_invoice_payment drop primary key drop index
/
alter table crd_invoice_payment add (constraint crd_invoice_payment_pk primary key(id)
/****************** partition start ********************
    using index global
    partition by range (id)
(
    partition crd_invoice_pay_maxvalue values less than (maxvalue)
)
******************** partition end ********************/
)
/
