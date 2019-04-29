alter table crd_invoice_debt add (constraint crd_invoice_debt_pk primary key(id))
/
alter table crd_invoice_debt drop primary key drop index
/
alter table crd_invoice_debt add (constraint crd_invoice_debt_pk primary key(id)
/****************** partition start ********************
    using index global
    partition by range (id)
(
    partition crd_invoice_debt_maxvalue values less than (maxvalue)
)
******************** partition end ********************/
)
/
